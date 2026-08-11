import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'package:app_platform/app_platform.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:config/config.dart';
import 'package:database/database.dart';
import 'package:ec_data/ec_data.dart';
import 'package:feature_capture/feature_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show DeviceOrientation, SystemChrome, SystemUiMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:storage/storage.dart';

import 'app/bootstrap_error_app.dart';
import 'app/di/injection.dart';
import 'app/firebase.dart';
import 'core/platform/firebase/firebase_service.dart';
import 'data/ec_purchases.dart';
import 'ec_app.dart';

Future<void> main() async {
  // runZonedGuarded catches errors that escape asynchronous callbacks (unawaited
  // Futures, Timers, stream handlers) which PlatformDispatcher.onError does not
  // see. WidgetsFlutterBinding must be initialised inside the same zone as
  // runApp, so the whole bootstrap runs in the guarded zone.
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Vá bản CameraX của Android ngay sau khi plugin tự đăng ký, trước khi
      // màn quay dựng controller đầu tiên: bản gốc gỡ `VideoCapture` khỏi
      // lifecycle mỗi lần dừng quay, và cú dựng lại capture session ấy làm
      // preview ngoặt ngang một nhịp. Trên iOS không làm gì.
      ecInstallPinnedCameraX();

      // Portrait-only by default (matches iOS's Info.plist restriction and
      // the rest of the app's portrait-only design); the record screen lifts
      // this itself so the camera can follow however the phone is held.
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      // Hide the Android status/nav bar app-wide; a swipe from the edge
      // reveals it briefly, then it re-hides (sticky immersive).
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

      try {
        await configureDependencies();

        // Đường dẫn Documents phải có TRƯỚC khi giao diện dựng: ảnh đại diện
        // lưu theo đường dẫn tương đối và được đọc đồng bộ ngay trong `build`.
        ecRememberDocumentsPath(
          (await getApplicationDocumentsDirectory()).path,
        );

        // Drop any Keychain data that survived a previous install (iOS keeps it
        // across uninstalls) before session restore reads secure storage.
        await getIt<KeychainResetOnReinstall>().run();

        // Local notifications are not a Firebase service — always initialise.
        await getIt<NotificationsService>().init();

        // Reconnects the upload transport to tasks the OS ran (or killed) while
        // the app was suspended, so their outcome isn't lost on next launch.
        await FileDownloader().start();

        if (kFirebaseEnabled) {
          await getIt<FirebaseService>().init();
          await getIt<RemoteConfigService>().init();
          await getIt<FirebaseMessagingService>().init();
        }

        // Crash reporting goes through the CrashReporter port. The no-op binding
        // does nothing; the Firebase adapter requires Firebase initialised
        // above, so this must follow the platform block.
        await getIt<CrashReporter>().install();

        // Always wire the global Flutter/platform error handlers, routing them
        // through whichever CrashReporter is registered (no-op when crash
        // reporting is disabled). Decoupled from the reporter's own install()
        // so the handlers exist even in the Firebase-off flavor.
        installGlobalErrorHandlers(getIt<CrashReporter>());

        // App-wide logging seam + bloc observability. Verbose in dev, quiet in
        // release; bloc errors are forwarded to the crash reporter (bloc
        // swallows them into onError, so the global handlers never see them).
        final env = getIt<EnvConfig>();
        final logger = DeveloperAppLogger(
          minLevel: env.isDev ? LogLevel.debug : LogLevel.warn,
        );
        getIt.registerSingleton<AppLogger>(logger);
        Bloc.observer = AppBlocObserver(
          logger,
          crashReporter: getIt<CrashReporter>(),
          logStateChanges: env.isDev,
        );

        // Launch EvidenceCam through the production bootstrap above (DI, crash
        // reporting, notifications, Firebase). Firebase is initialised via
        // FirebaseService above, and this is the only auth the app binds —
        // there is no in-app fallback, so a build without Firebase config fails
        // here instead of signing a demo user in. The repository comes from
        // EC_API_URL/API_BASE_URL, which must name a real origin.
        final ecAuth = FirebaseEcAuth();

        // Góp ý đi thẳng sang CMS dùng chung (tenant zenpack), không qua backend
        // EvidenceCam.
        //
        // ponytail: build khai `EC_FEEDBACK_URL` rỗng thì không đăng ký và
        // `_sendFeedback` lặng lẽ bỏ qua — nút vẫn hiện và vẫn cảm ơn người
        // dùng. Chấp nhận được vì mặc định là một origin thật, chỉ bản offline
        // cố ý mới rơi vào nhánh này; cần chặt hơn thì truyền cờ xuống
        // EcAccountScreen để ẩn hẳn mục đó.
        final feedback = buildFeedback();
        if (feedback != null) getIt.registerSingleton<EcFeedback>(feedback);

        // Cửa hàng trong app (IAP qua RevenueCat). Phải xong TRƯỚC runApp: màn
        // Quota hỏi `EcPurchases.isAvailable` ngay ở lần dựng đầu để quyết định
        // có hiện nút mua, và cấu hình muộn hơn thì nút chớp hiện chớp tắt.
        //
        // Không có khoá cho nền tảng này → thoát êm, app chạy không cửa hàng.
        await EcPurchases.configure(
          Platform.isIOS ? env.revenueCatIosKey : env.revenueCatAndroidKey,
        );
        // Evidence clips persist in ObjectBox (opened by the @preResolve store
        // module during configureDependencies), so the upload queue survives
        // restarts — the single source of truth (FR-08/FR-09).
        runApp(
          EcApp(
            auth: ecAuth,
            repo: buildRepository(auth: ecAuth),
            evidenceStore: ObjectBoxEvidenceClipStore(getIt<Store>()),
          ),
        );
      } on Object catch (error, stackTrace) {
        await _reportBootstrapFailure(error, stackTrace);
        runApp(BootstrapErrorApp(error: error));
      }
    },
    (error, stackTrace) {
      // Uncaught async errors after (or during) bootstrap. Report best-effort;
      // never rethrow — this is the last line of defense.
      unawaited(_reportZoneError(error, stackTrace));
    },
  );
}

/// Records an uncaught error surfaced by the guarding zone. Always logs; also
/// reports through the [CrashReporter] port when one is registered.
Future<void> _reportZoneError(Object error, StackTrace stackTrace) async {
  developer.log(
    'Uncaught zone error',
    name: 'zone',
    level: 1000,
    error: error,
    stackTrace: stackTrace,
  );

  if (!getIt.isRegistered<CrashReporter>()) return;
  try {
    await getIt<CrashReporter>().recordError(
      error,
      stackTrace,
      reason: 'Uncaught zone error',
      fatal: true,
    );
  } on Object catch (_) {
    // Best-effort; the developer.log above already fired.
  }
}

/// Records a fatal bootstrap failure. Always logs via `dart:developer`; also
/// reports through the [CrashReporter] port when one is registered — the no-op
/// reporter (Firebase disabled) simply does nothing.
Future<void> _reportBootstrapFailure(
  Object error,
  StackTrace stackTrace,
) async {
  developer.log(
    'App bootstrap failed',
    name: 'bootstrap',
    level: 1000,
    error: error,
    stackTrace: stackTrace,
  );

  if (!getIt.isRegistered<CrashReporter>()) return;
  try {
    await getIt<CrashReporter>().recordError(
      error,
      stackTrace,
      reason: 'App bootstrap failed',
      fatal: true,
    );
  } on Object catch (_) {
    // Best-effort; the developer.log above already fired.
  }
}

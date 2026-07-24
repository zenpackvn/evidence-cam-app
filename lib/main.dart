import 'dart:async';
import 'dart:developer' as developer;

import 'package:app_platform/app_platform.dart';
import 'package:config/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storage/storage.dart';

import 'app/app.dart';
import 'app/bootstrap_error_app.dart';
import 'app/di/injection.dart';
import 'app/firebase.dart';
import 'core/platform/firebase/firebase_service.dart';

Future<void> main() async {
  // runZonedGuarded catches errors that escape asynchronous callbacks (unawaited
  // Futures, Timers, stream handlers) which PlatformDispatcher.onError does not
  // see. WidgetsFlutterBinding must be initialised inside the same zone as
  // runApp, so the whole bootstrap runs in the guarded zone.
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      try {
        await configureDependencies();

        // Drop any Keychain data that survived a previous install (iOS keeps it
        // across uninstalls) before session restore reads secure storage.
        await getIt<KeychainResetOnReinstall>().run();

        // Local notifications are not a Firebase service — always initialise.
        await getIt<NotificationsService>().init();

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

        runApp(const App());
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

/// Goldens for the *live* screens, at the design file's artboard size, so each
/// port can be diffed against its `design_*` counterpart rendered straight from
/// `pencil-app-dna.pen`.
library;

import 'dart:async';
import 'dart:io';

import 'package:feature_account/feature_account.dart';
import 'package:feature_capture/feature_capture.dart';
import 'package:feature_orders/feature_orders.dart';
import 'package:feature_shift/feature_shift.dart' as shift;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';
import 'package:localization/localization.dart';

const _designSize = Size(390, 844);

Future<void> _warmDesignArtwork() async {
  final files = Directory('packages/ec_ui/assets/design')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.png'));
  for (final file in files) {
    final done = Completer<void>();
    final stream = AssetImage(
      file.path.replaceFirst('packages/ec_ui/', ''),
      package: 'ec_ui',
    ).resolve(ImageConfiguration.empty);
    late ImageStreamListener listener;
    void finish() {
      stream.removeListener(listener);
      if (!done.isCompleted) done.complete();
    }

    listener = ImageStreamListener(
      (_, _) => finish(),
      onError: (_, _) => finish(),
    );
    stream.addListener(listener);
    await done.future;
  }
}

Future<void> _loadInter() async {
  final path = Platform.environment['EC_INTER_TTF'];
  if (path == null || !File(path).existsSync()) return;
  final bytes = File(path).readAsBytesSync().buffer.asByteData();
  await (FontLoader('Inter')..addFont(Future.value(bytes))).load();
}

/// Goldens are pixel comparisons against a specific typeface, so they only
/// mean anything when the real Inter is loaded. Without `EC_INTER_TTF` the run
/// would diff design pixels against the test fallback font, so skip instead.
final _hasInter = () {
  final path = Platform.environment['EC_INTER_TTF'];
  return path != null && File(path).existsSync();
}();

void main() {
  setUpAll(_loadInter);

  final screens = <String, Widget>{
    'ported_f1_01_splash': const shift.EcSplashScreen(),
    'ported_f1_02_login': const shift.EcLoginScreen(),
    'ported_f1_03_register': const shift.EcRegisterScreen(),
    'ported_f1_04_forgot': const shift.EcForgotPasswordScreen(),
    'ported_f1_05_choose_shop': const shift.EcChooseShopScreen(
      shops: [
        shift.EcShopSummary(
          name: 'Shop ABC',
          platform: 'shopee',
          meta: 'Shopee · ID: 123456',
        ),
        shift.EcShopSummary(
          name: 'Shop XYZ',
          platform: 'lazada',
          meta: 'Lazada · ID: 780012',
        ),
      ],
    ),
    'ported_f1_06_no_shop': const shift.EcNoShopScreen(),
    'ported_f1_07_create_shop': const shift.EcCreateShopScreen(),
    'ported_f1_08_shop_mgmt': const shift.EcShopMgmtScreen(
      shops: [
        shift.EcShopMgmtEntry(
          name: 'Shop ABC',
          meta: 'Shopee · 3 thành viên',
          platform: 'shopee',
        ),
        shift.EcShopMgmtEntry(
          name: 'Kho tổng',
          meta: 'Khác · 1 thành viên',
          platform: 'other',
        ),
      ],
    ),
    'ported_f1_09_shop_detail': const shift.EcShopDetailScreen(
      shopName: 'Shop ABC',
      platformLabel: 'shopee',
      members: [
        shift.EcShopMember(name: 'Nguyễn Văn A', role: 'Chủ shop'),
        shift.EcShopMember(name: 'Trần Thị B', role: 'Nhân viên'),
      ],
      videoTypes: [
        shift.EcVideoType(name: 'Đóng hàng', locked: true),
        shift.EcVideoType(name: 'Cân hàng'),
      ],
    ),
    'ported_f1_10_create_type': const shift.EcCreateTypeScreen(),
    'ported_f1_11_delete_type': const shift.EcConfirmDeleteScreen(),
    'ported_f1_12_orders_tab': const shift.EcHomeOrdersScreen(
      shopName: 'Shop ABC',
      queueCount: 3,
      orders: [
        shift.EcOrderRow(
          code: 'SPXVN024567890',
          time: '10:21',
          type: 'Đóng hàng',
          videoCount: 2,
        ),
        shift.EcOrderRow(
          code: 'SPXVN044556677',
          time: '07:15',
          type: 'Đơn vị vận chuyển',
          videoCount: 1,
          errorCount: 1,
        ),
      ],
    ),
    'ported_f2_02_evidence': const EcOrderTimelineScreen(
      orderCode: 'SPXVN024567890',
      pendingUploadCount: 4,
      dossierUrl: 'zenpack.vn/r/abc123...',
      days: [
        EcTimelineDay(
          date: '23/07/2026',
          videos: [
            EcTimelineVideo(
              time: '10:23',
              label: 'Đóng hàng',
              statusText: 'Đã upload',
            ),
            EcTimelineVideo(
              time: '10:35',
              label: 'Đơn vị vận chuyển',
              statusText: 'Đang tải 72%',
            ),
          ],
        ),
      ],
    ),
    'ported_f2_03_video_detail': const EcVideoDetailScreen(
      video: EcVideoDetail(
        title: 'Đóng hàng',
        duration: '02:45',
        recordedAt: '23/07/2026 · 10:23',
        recordedBy: 'Trần Thị B (Nhân viên)',
        device: 'iPhone 12 · app 1.0',
        uploadStatus: 'Đã upload',
      ),
    ),
    'ported_f3_01_idle': const EcWaitBill2Screen(),
    'ported_f3_03_rec': const EcRecording2Screen(elapsed: '00:12'),
    'ported_f4_01_account': const EcAccountTabScreen(
      shopName: 'Shop ABC',
      queueCount: 3,
      userName: 'Nguyễn Văn A',
      userEmail: 'nguyenvana@gmail.com',
    ),
    'ported_f4_03_language': const EcLanguageScreen(),
    'ported_f3_02_code': const EcManualEntryScreen(),
    'ported_f3_04_saved': const EcCutoverBScreen(),
    'ported_f3_05_ceiling': const EcNearLimitScreen(),
    'ported_f3_06_queue': const EcUploadQueueScreen(
      items: [
        EcUploadItem(
          code: 'SPXVN024567890',
          typeLabel: 'Đóng hàng',
          timeRange: '10:21 - 10:24',
          status: EcUploadStatus.uploading,
          progressPercent: 72,
        ),
        EcUploadItem(
          code: 'SPXVN098765432',
          typeLabel: 'Trả hàng',
          timeRange: '09:45 - 09:47',
          status: EcUploadStatus.error,
          retryCount: 2,
        ),
      ],
    ),
    'ported_f3_07_return': const EcReturnRecScreen(),
    'ported_f3_08_mismatch': const EcNoMatchScreen(),
    'ported_f3_09_pick_type': const EcTypeSheetScreen(),
    'ported_f4_02_profile': const EcEditProfileScreen(),
    'ported_f4_04_quota': const EcQuotaScreen(),
    'ported_f4_05_password': const EcChangePasswordScreen(),
    'ported_f4_06_delete': const EcDeleteAccountScreen(),
  };

  screens.forEach((name, screen) {
    testWidgets(
      name,
      skip: !_hasInter,
      experimentalLeakTesting: LeakTesting.settings.withIgnoredAll(),
      (tester) async {
        tester.view
          ..physicalSize = _designSize
          ..devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        await tester.runAsync(_warmDesignArtwork);

        await tester.pumpWidget(
          CupertinoApp(
            debugShowCheckedModeBanner: false,
            locale: const Locale('vi'),
            supportedLocales: const [Locale('vi'), Locale('en')],
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: const CupertinoThemeData(
              brightness: Brightness.light,
              textTheme: CupertinoTextThemeData(
                textStyle: TextStyle(fontFamily: 'Inter', fontSize: 14),
              ),
            ),
            home: RepaintBoundary(key: const Key('artboard'), child: screen),
          ),
        );
        await tester.pump();

        await expectLater(
          find.byKey(const Key('artboard')),
          matchesGoldenFile('goldens/$name.png'),
        );
      },
    );
  });
}

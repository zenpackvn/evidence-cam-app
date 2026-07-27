// Golden/pixel snapshots — a LOCAL eyeball tool, not a CI assertion (goldens
// don't match across OS / fonts). Tagged so `--exclude-tags golden` skips them
// per dart_test.yaml; regenerate with `flutter test --update-goldens --tags golden`.
@Tags(['golden'])
library;

import 'package:app_ui/app_ui.dart';
import 'package:feature_account/feature_account.dart';
import 'package:feature_capture/feature_capture.dart' hide EcVideoType;
import 'package:feature_orders/feature_orders.dart' hide EcOrderRow;
import 'package:feature_shift/feature_shift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';

// Renders each screen at iPhone size and writes a PNG so the design can be
// eyeballed (run with --update-goldens). Not a pass/fail assertion of pixels.
Future<void> _cap(WidgetTester t, String name, Widget screen) async {
  // iPhone 11 logical size (414×896) — verify layouts adapt beyond the 390×844
  // design canvas (the responsiveness the user flagged).
  t.view.physicalSize = const Size(414, 896);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('vi'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: screen,
    ),
  );
  await t.pumpAndSettle();
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$name.png'),
  );
}

const _orders = [
  EcOrderRow(
    code: 'SPXVN024567890',
    time: '10:23',
    type: 'Đóng hàng đi',
    videoCount: 2,
  ),
  EcOrderRow(
    code: 'SPXVN024567321',
    time: '10:19',
    type: 'Đóng hàng đi',
    videoCount: 1,
    errorCount: 1,
  ),
  EcOrderRow(
    code: 'SPXVN024560012',
    time: '09:58',
    type: 'Trả hàng',
    videoCount: 3,
  ),
];

const _timeline = [
  EcTimelineDay(
    date: 'Hôm nay, 24 Th7',
    videos: [
      EcTimelineVideo(
        time: '10:23',
        label: 'Đóng hàng đi',
        statusText: 'Đang tải 72%',
      ),
      EcTimelineVideo(time: '10:21', label: 'Đóng hàng đi'),
    ],
  ),
];

const _videoDetail = EcVideoDetail(
  title: 'Video đóng hàng',
  duration: '00:42',
  recordedAt: '24 Th7 · 10:23',
  recordedBy: 'Nguyễn Văn A',
  device: 'iPhone 13',
  uploadStatus: 'Đã tải lên',
);

const _members = [
  EcShopMember(name: 'Nguyễn Văn A', role: 'Chủ tài khoản'),
  EcShopMember(name: 'Trần Thị B', role: 'Nhân viên'),
];
const _types = [
  EcVideoType(
    name: 'Đóng hàng',
    locked: true,
    icon: Icons.inventory_2_outlined,
  ),
  EcVideoType(
    name: 'Trả hàng',
    locked: true,
    icon: Icons.assignment_return_outlined,
  ),
  EcVideoType(name: 'Cân hàng', locked: false, icon: Icons.scale_outlined),
];

void main() {
  // Offline: fall back to the bundled font instead of fetching Inter (which
  // throws in tests). Layout/proportion is what we're eyeballing here.
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('splash', (t) => _cap(t, 'splash', const EcSplashScreen()));
  testWidgets('login', (t) => _cap(t, 'login', const EcLoginScreen()));
  testWidgets('register', (t) => _cap(t, 'register', const EcRegisterScreen()));
  testWidgets(
    'home',
    (t) => _cap(
      t,
      'home',
      const EcHomeOrdersScreen(
        shopName: 'Shop ABC',
        orders: _orders,
        queueCount: 4,
      ),
    ),
  );
  testWidgets(
    'ordertimeline',
    (t) => _cap(
      t,
      'ordertimeline',
      const EcOrderTimelineScreen(
        orderCode: 'SPXVN024567890',
        days: _timeline,
        pendingUploadCount: 1,
        dossierUrl: 'https://cdn.evidencecam.app/d/x',
      ),
    ),
  );
  testWidgets(
    'videodetail',
    (t) =>
        _cap(t, 'videodetail', const EcVideoDetailScreen(video: _videoDetail)),
  );
  testWidgets(
    'waitbill',
    (t) => _cap(t, 'waitbill', const EcWaitBill2Screen()),
  );
  testWidgets(
    'recording',
    (t) => _cap(t, 'recording', const EcRecording2Screen()),
  );
  testWidgets(
    'typesheet',
    (t) => _cap(t, 'typesheet', const EcTypeSheetScreen()),
  );
  testWidgets(
    'uploadqueue',
    (t) => _cap(
      t,
      'uploadqueue',
      const EcUploadQueueScreen(items: ecDefaultUploadItems),
    ),
  );
  testWidgets('account', (t) => _cap(t, 'account', const EcAccountTabScreen()));
  testWidgets('quota', (t) => _cap(t, 'quota', const EcQuotaScreen()));
  testWidgets(
    'shopdetail',
    (t) => _cap(
      t,
      'shopdetail',
      const EcShopDetailScreen(
        shopName: 'Shop ABC',
        platformLabel: 'Shopee',
        members: _members,
        videoTypes: _types,
      ),
    ),
  );
  testWidgets(
    'choose_shop',
    (t) => _cap(
      t,
      'choose_shop',
      const EcChooseShopScreen(
        shops: [
          EcShopSummary(
            name: 'Shop ABC',
            platform: 'shopee',
            meta: 'Shopee · 24 đơn',
          ),
          EcShopSummary(name: 'Shop XYZ', platform: 'tiktok'),
        ],
      ),
    ),
  );

  // remaining layouts (full coverage of every screen's sizing)
  testWidgets(
    'forgot',
    (t) => _cap(t, 'forgot', const EcForgotPasswordScreen()),
  );
  testWidgets('noshop', (t) => _cap(t, 'noshop', const EcNoShopScreen()));
  testWidgets(
    'createshop',
    (t) => _cap(t, 'createshop', const EcCreateShopScreen()),
  );
  testWidgets(
    'createtype',
    (t) => _cap(t, 'createtype', const EcCreateTypeScreen()),
  );
  testWidgets(
    'confirmdelete',
    (t) => _cap(t, 'confirmdelete', const EcConfirmDeleteScreen()),
  );
  testWidgets('cutover', (t) => _cap(t, 'cutover', const EcCutoverBScreen()));
  testWidgets(
    'nearlimit',
    (t) => _cap(t, 'nearlimit', const EcNearLimitScreen()),
  );
  testWidgets(
    'returnrec',
    (t) => _cap(t, 'returnrec', const EcReturnRecScreen()),
  );
  testWidgets(
    'manualentry',
    (t) => _cap(t, 'manualentry', const EcManualEntryScreen()),
  );
  testWidgets('nomatch', (t) => _cap(t, 'nomatch', const EcNoMatchScreen()));
  testWidgets(
    'editprofile',
    (t) => _cap(t, 'editprofile', const EcEditProfileScreen()),
  );
  testWidgets('language', (t) => _cap(t, 'language', const EcLanguageScreen()));
  testWidgets(
    'deleteaccount',
    (t) => _cap(t, 'deleteaccount', const EcDeleteAccountScreen()),
  );
  testWidgets(
    'changepassword',
    (t) => _cap(t, 'changepassword', const EcChangePasswordScreen()),
  );
  testWidgets(
    'shopmgmt',
    (t) => _cap(
      t,
      'shopmgmt',
      const EcShopMgmtScreen(
        shops: [
          EcShopMgmtEntry(name: 'Shop ABC', meta: 'Shopee · 3 thành viên'),
          EcShopMgmtEntry(name: 'Shop XYZ', meta: 'TikTok · 1 thành viên'),
        ],
      ),
    ),
  );
}

/// Ảnh chụp bảy màn của bộ mock `ZenPack_App_Ban1_ChiTiet` (18/09/2026) với
/// phông và biểu tượng thật — công cụ NHÌN tại chỗ, không phải phép so pixel
/// của CI (gắn tag `golden` như các tệp cùng thư mục).
///
/// Chạy: `fvm flutter test test/capture/ban1_capture_test.dart
/// --update-goldens` rồi mở `test/capture/goldens/ban1-*.png`.
@Tags(['golden'])
library;

import 'dart:convert';

import 'package:app_ui/app_ui.dart';
import 'package:ec_ui/ec_ui.dart';
import 'package:feature_account/feature_account.dart';
import 'package:feature_orders/feature_orders.dart';
import 'package:feature_shift/feature_shift.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';
import 'package:localization/localization.dart';

Future<void> _cap(
  WidgetTester t,
  String name,
  Widget screen, {
  Size size = const Size(828, 1792),
}) async {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 2;
  // Tai thỏ + thanh home của iPhone 11, để dải cam và thanh tab đo đúng chỗ.
  t.view.padding = const FakeViewPadding(top: 96, bottom: 68);
  addTearDown(() async {
    await t.pumpWidget(const SizedBox.shrink());
    await t.pump();
    t.view.reset();
  });
  await t.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: const Locale('vi'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: Material(type: MaterialType.transparency, child: screen),
    ),
  );
  await t.pumpAndSettle();
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$name.png'),
  );
}

/// Xem `chu_ky_so_capture_test.dart` — cùng cách nạp phông.
Future<void> _loadFonts() async {
  final manifest =
      jsonDecode(await rootBundle.loadString('FontManifest.json'))
          as List<dynamic>;
  for (final entry in manifest) {
    final font = entry as Map<String, dynamic>;
    final loader = FontLoader(font['family'] as String);
    for (final f in (font['fonts'] as List<dynamic>)) {
      loader.addFont(
        rootBundle.load((f as Map<String, dynamic>)['asset'] as String),
      );
    }
    await loader.load();
  }
  const files = {
    'Inter_regular': 'assets/google_fonts/Inter-Regular.ttf',
    'Inter_500': 'assets/google_fonts/Inter-Regular.ttf',
    'Inter_600': 'assets/google_fonts/Inter-SemiBold.ttf',
    'Inter_bold': 'assets/google_fonts/Inter-Bold.ttf',
    'Inter_700': 'assets/google_fonts/Inter-Bold.ttf',
    'Inter_800': 'assets/google_fonts/Inter-Bold.ttf',
    'Inter': 'assets/google_fonts/Inter-Regular.ttf',
  };
  for (final e in files.entries) {
    final loader = FontLoader(e.key)..addFont(rootBundle.load(e.value));
    await loader.load();
  }
}

const _orders = [
  EcOrderRow(
    code: 'DHN-SHX-11E7C498',
    time: '16:59',
    type: 'Đơn vị vận chuyển',
    videoCount: 1,
    capturedAtMs: 1789020000000,
  ),
  EcOrderRow(
    code: 'DHN-SHX-A667681A',
    time: '09:57',
    type: 'Đóng hàng',
    videoCount: 1,
    pendingCount: 1,
    capturedAtMs: 1789700000000,
  ),
  EcOrderRow(
    code: 'DHN-SHX-23F0D889',
    time: '14:12',
    type: 'Đóng hàng',
    videoCount: 2,
    photoCount: 1,
    capturedAtMs: 1789620000000,
  ),
  EcOrderRow(
    code: 'DHN-SHX-77B2J910',
    time: '11:03',
    type: 'Trả hàng',
    videoCount: 0,
    capturedAtMs: 1789520000000,
  ),
  EcOrderRow(
    code: 'DHN-SHX-90A1B2C3',
    time: '08:40',
    type: 'Đóng hàng',
    videoCount: 1,
    errorCount: 1,
    capturedAtMs: 1789420000000,
  ),
];

final _stats = [
  const EcHomeStat(value: '12', label: 'Vận đơn'),
  EcHomeStat(
    value: '8',
    label: 'Video đã quay',
    icon: LucideIcons.video,
    accent: PenColors.success,
  ),
  EcHomeStat(
    value: '2',
    label: 'Chờ tải',
    icon: LucideIcons.cloudUpload,
    accent: PenColors.warning,
    tintValue: true,
    sublabel: 'Trong hàng đợi',
    followsTimeFilter: false,
  ),
];

const _timeline = EcOrderTimelineScreen(
  orderCode: 'DHN-SHX-A667681A',
  subtitle: 'Nhà Lam · Shopee',
  days: [
    EcTimelineDay(
      date: '18/09/2026',
      videos: [
        EcTimelineVideo(
          time: '09:57',
          label: 'Đơn vị vận chuyển',
          statusText: 'Đang đóng dấu thời gian…',
          statusTone: EcStatusTone.uploading,
          statusIcon: LucideIcons.loader,
          durationSeconds: 6,
        ),
        EcTimelineVideo(
          time: '09:41',
          label: 'Đóng hàng',
          statusText: 'Đã tải lên',
          statusTone: EcStatusTone.done,
          durationSeconds: 74,
        ),
      ],
    ),
  ],
);

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  setUpAll(_loadFonts);
  LeakTesting.settings = LeakTesting.settings.withIgnored(
    notDisposed: {
      'ImageStreamCompleterHandle': null,
      'ImageInfo': null,
      'Image': null,
      '_CachedImage': null,
    },
  );

  testWidgets(
    '01 chọn cửa hàng',
    (t) => _cap(
      t,
      'ban1-01-chon-cua-hang',
      EcChooseShopScreen(
        shops: const [
          EcShopSummary(
            name: 'Nhà Lam',
            platform: 'shopee',
            meta: 'Shopee · Chủ shop',
            pulse: EcShopPulse(ordersToday: 12, videosToday: 8),
          ),
          EcShopSummary(
            name: 'Kho Tiki',
            platform: 'tiki',
            meta: 'Tiki · Nhân viên',
            role: 'staff',
            pulse: EcShopPulse(ordersToday: 0, videosToday: 0),
          ),
        ],
        onSelect: (_) {},
        onAccountTap: () {},
        onAddShop: () {},
        onJoinByInvite: () {},
        onLogout: () {},
      ),
    ),
  );

  testWidgets(
    '02 vận đơn',
    (t) => _cap(
      t,
      'ban1-02-van-don',
      EcHomeOrdersScreen(
        shopName: 'Nhà Lam',
        shopSubtitle: 'Shopee · Chủ shop',
        platform: 'shopee',
        orders: _orders,
        stats: _stats,
        pageInfo: const EcOrderPage(page: 1, total: 12, shown: 5),
        onBack: () {},
        onSettings: () {},
        onScan: () async => null,
        onNavRecord: () {},
        onNavClaims: () {},
      ),
    ),
  );

  testWidgets(
    '03 hồ sơ khiếu nại trống',
    (t) => _cap(
      t,
      'ban1-03-ho-so-trong',
      EcClaimListScreen(
        onCreate: () {},
        onNavOrders: () {},
        onNavRecord: () {},
      ),
    ),
  );

  testWidgets(
    '04 chi tiết vận đơn',
    (t) => _cap(
      t,
      'ban1-04-chi-tiet-van-don',
      EcOrderTimelineScreen(
        orderCode: _timeline.orderCode,
        subtitle: _timeline.subtitle,
        days: _timeline.days,
        onBack: () {},
        onCopyCode: () {},
        onAttachCode: () {},
        onAttachPhoto: () {},
      ),
    ),
  );

  testWidgets(
    '05 chi tiết video',
    (t) => _cap(
      t,
      'ban1-05-chi-tiet-video',
      Stack(
        children: [
          const Positioned.fill(child: _timeline),
          Positioned.fill(
            child: EcVideoDetailScreen(
              video: const EcVideoDetail(
                title: 'Đơn vị vận chuyển',
                duration: '00:06',
                recordedAt: '18/09/2026 · 09:57',
                recordedBy: 'cosau docungcondao',
                device: 'iPhone 11',
                uploadStatus: 'Đã tải lên',
                storage: 'Cloud ZenPack',
                localPath: '/tmp/clip.mp4',
                seal: EcSealLine(
                  label: 'Đang đóng dấu thời gian…',
                  inProgress: true,
                ),
              ),
              onPlay: () {},
              onDelete: () {},
            ),
          ),
        ],
      ),
      size: const Size(828, 2000),
    ),
  );

  testWidgets(
    '06 chi tiết cửa hàng',
    (t) => _cap(
      t,
      'ban1-06-chi-tiet-cua-hang',
      EcShopDetailScreen(
        shopName: 'Nhã Lam',
        platformLabel: 'Shopee',
        roleLabel: 'Chủ shop',
        storageLabel: 'Cloud ZenPack',
        members: const [
          EcShopMember(
            name: 'cosau docungcondao',
            role: 'Chủ shop',
            email: 'docungcondaocosau@gmail.com',
            roleCode: 'owner',
          ),
        ],
        videoTypes: const [
          EcVideoType(
            name: 'Đóng hàng',
            locked: true,
            icon: Icons.inventory_2_outlined,
            hint: 'Quay quá trình đóng hàng',
          ),
          EcVideoType(
            name: 'Đơn vị vận chuyển',
            locked: true,
            icon: Icons.local_shipping_outlined,
            hint: 'Quay khi bàn giao cho đơn vị vận chuyển',
          ),
          EcVideoType(
            name: 'Trả hàng',
            locked: true,
            icon: Icons.assignment_return_outlined,
            hint: 'Quay khi nhận hàng trả',
          ),
        ],
        onBack: () {},
        onRenameShop: () {},
        onInviteMember: () {},
        onShopQr: () {},
        onTapStorage: () {},
        onTapCaiDatQuay: () {},
        onAddType: () {},
        onDeleteShop: () {},
      ),
      size: const Size(828, 2400),
    ),
  );

  testWidgets(
    '07 tài khoản',
    (t) => _cap(
      t,
      'ban1-07-tai-khoan',
      EcAccountTabScreen(
        userName: 'cosau docungcondao',
        userEmail: 'docungcondaocosau@gmail.com',
        planLabel: 'Miễn phí',
        loginMethodsLabel: '2 liên kết',
        passwordActionLabel: 'Tạo mật khẩu',
        notifValue: 'Đang tắt',
        themeValue: 'Theo máy',
        timezoneValue: 'Theo máy',
        invoiceValue: 'Chưa khai',
        onBack: () {},
        onProfileTap: () {},
        onChangePlanTap: () {},
      ),
      size: const Size(828, 2400),
    ),
  );
}

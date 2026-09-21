/// Goldens for the *live* screens, at the design file's artboard size, so each
/// port can be diffed against its `design_*` counterpart rendered straight from
/// `pencil-app-dna.pen`.
// Gắn tag `golden` — đúng quy ước sẵn có của kho này.
//
// Trước đây tệp này KHÔNG mang tag nào, nên nó không bị `--exclude-tags golden`
// loại ra; nó tự bỏ qua vì một lý do khác hẳn (thiếu biến môi trường
// EC_INTER_TTF). Nay lý do đó đã gỡ, nếu không gắn tag thì 62 ca chạy trong job
// CI trên Ubuntu — mà ảnh gốc sinh trên macOS, tức đỏ vì SAI NỀN TẢNG chứ không
// vì thiết kế trôi. Xem thẻ D-07.
@Tags(['golden'])
library;

import 'dart:async';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:feature_account/feature_account.dart';
import 'package:feature_capture/feature_capture.dart';
import 'package:feature_orders/feature_orders.dart';
import 'package:feature_shift/feature_shift.dart' as shift;
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';
import 'package:localization/localization.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'inter_font.dart';

const _designSize = Size(390, 844);

/// Bốn dòng vận đơn đúng như khung F1-12/F2-01 vẽ, kể cả dòng cuối báo lỗi.
const _sampleOrders = [
  shift.EcOrderRow(
    code: 'SPXVN024567890',
    time: '10:21',
    type: 'Đóng hàng',
    videoCount: 2,
  ),
  shift.EcOrderRow(
    code: 'SPXVN098765432',
    time: '09:45',
    type: 'Đơn vị vận chuyển',
    videoCount: 1,
  ),
  shift.EcOrderRow(
    code: 'SPXVN011122233',
    time: '08:30',
    type: 'Đóng hàng',
    videoCount: 3,
  ),
  shift.EcOrderRow(
    code: 'SPXVN044556677',
    time: '07:15',
    type: 'Đơn vị vận chuyển',
    videoCount: 1,
    errorCount: 1,
  ),
];

/// Ba con số khung F1-12/F2-01 in ra, để ảnh đối chiếu nói về layout chứ
/// không về dữ liệu mẫu.
const _sampleStats = [
  shift.EcHomeStat(value: '24', label: 'Vận đơn'),
  shift.EcHomeStat(
    value: '38',
    label: 'Video đã quay',
    icon: LucideIcons.video,
  ),
  shift.EcHomeStat(
    value: '4',
    label: 'Chờ tải',
    icon: LucideIcons.cloudUpload,
  ),
];

/// "1–10 / 128 vận đơn" với 13 trang — chính con số khung design in ra.
const _ordersPage = shift.EcOrderPage(
  page: 1,
  total: 128,
  pageSize: 10,
  shown: 10,
);

void _noopPage(int page) {}

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

/// Screens the app presents as a transparent modal route stack them over the
/// screen behind, and the design frame draws that backdrop too. Rendering the
/// modal alone would diff the whole backdrop as a mismatch, so compose the
/// pair exactly as the router does.
Widget _over(Widget backdrop, Widget modal) => Stack(
  children: [
    Positioned.fill(child: backdrop),
    Positioned.fill(child: modal),
  ],
);

const _accountBackdrop = EcAccountTabScreen(
  userName: 'Nguyễn Văn A',
  userEmail: 'nguyenvana@gmail.com',
);

const _evidenceBackdrop = EcOrderTimelineScreen(
  orderCode: 'SPXVN024567890',
  subtitle: 'Shop ABC · Shopee',
  pendingUploadCount: 4,
  days: [
    EcTimelineDay(
      date: '23/07/2026',
      videos: [
        EcTimelineVideo(
          time: '10:23',
          label: 'Đóng hàng',
          statusText: 'Đã upload',
          statusTone: EcStatusTone.done,
          durationSeconds: 165,
        ),
        EcTimelineVideo(
          time: '10:35',
          label: 'Đơn vị vận chuyển',
          statusText: 'Đang tải 72%',
          statusTone: EcStatusTone.uploading,
        ),
        EcTimelineVideo(
          time: '10:52',
          label: 'Ảnh kèm hàng',
          statusText: 'Chờ upload',
          statusTone: EcStatusTone.waiting,
        ),
      ],
    ),
    EcTimelineDay(
      date: '31/07/2026',
      videos: [
        EcTimelineVideo(
          time: '09:12',
          label: 'Trả hàng',
          statusText: 'Lỗi · Thử lại',
          statusTone: EcStatusTone.error,
        ),
        EcTimelineVideo(
          time: '09:30',
          label: 'Cân hàng',
          statusText: 'Chờ quota',
          statusTone: EcStatusTone.quota,
        ),
      ],
    ),
  ],
);

/// The design's viewfinder stills, so a camera screen's golden shows the same
/// scene the design frame does instead of an empty (camera-less) preview.
Widget _viewfinder(String name) => Image.asset(
  'assets/design/$name.png',
  package: 'ec_ui',
  fit: BoxFit.cover,
);

const _shopDetailBackdrop = shift.EcShopDetailScreen(
  shopName: 'Shop ABC',
  platformLabel: 'shopee',
  roleLabel: 'Chủ shop',
  storageLabel: 'Cloud ZenPack',
  members: [
    shift.EcShopMember(name: 'Nguyễn Văn A', role: 'Chủ shop'),
    shift.EcShopMember(name: 'Trần Thị B', role: 'Nhân viên'),
    shift.EcShopMember(name: 'Lê Văn C', role: 'Quản lý'),
  ],
  videoTypes: [
    shift.EcVideoType(
      name: 'Đóng hàng',
      locked: true,
      hint: 'Quay quá trình đóng hàng',
    ),
    shift.EcVideoType(
      name: 'Đơn vị vận chuyển',
      locked: true,
      hint: 'Quay khi bàn giao cho đơn vị vận chuyển',
    ),
    shift.EcVideoType(
      name: 'Trả hàng',
      locked: true,
      hint: 'Quay khi nhận hàng trả',
    ),
    shift.EcVideoType(name: 'Cân hàng'),
    shift.EcVideoType(name: 'Kiểm đếm sản phẩm'),
  ],
);

void main() {
  setUpAll(napInter);

  final screens = <String, Widget>{
    'ported_f1_01_splash': shift.EcSplashScreen(onStart: () {}),
    'ported_f1_02_login': shift.EcLoginScreen(onLogin: () {}),
    'ported_f1_03_register': shift.EcRegisterScreen(onRegister: () {}),
    'ported_f1_04_forgot': shift.EcForgotPasswordScreen(onSend: () {}),
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
          role: 'staff',
        ),
        shift.EcShopSummary(
          name: 'Shop 247',
          platform: 'tiktok',
          meta: 'TikTok Shop · ID: 345678',
        ),
        shift.EcShopSummary(
          name: 'Kho tổng',
          platform: 'other',
          meta: 'Khác · ID: 999999',
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
          name: 'Shop XYZ',
          meta: 'Lazada · 2 thành viên',
          platform: 'lazada',
        ),
        shift.EcShopMgmtEntry(
          name: 'Kho tổng',
          meta: 'Khác · 1 thành viên',
          platform: 'other',
        ),
      ],
    ),
    'ported_f1_09_shop_detail': _shopDetailBackdrop,
    'ported_f1_10_create_type': _over(
      _evidenceBackdrop,
      const shift.EcCreateTypeScreen(),
    ),
    'ported_f1_11_delete_type': _over(
      _shopDetailBackdrop,
      const shift.EcConfirmDeleteScreen(),
    ),
    'ported_f1_12_orders_tab': const shift.EcHomeOrdersScreen(
      shopName: 'Shop ABC',
      stats: _sampleStats,
      orders: _sampleOrders,
      pageInfo: _ordersPage,
      onPageChanged: _noopPage,
    ),
    // F1-12 và F2-01 là cùng một khung trong file design (danh sách vận đơn),
    // nên cùng một widget phải khớp cả hai.
    'ported_f2_01_orders': const shift.EcHomeOrdersScreen(
      shopName: 'Shop ABC',
      shopSubtitle: 'Shopee · Chủ shop',
      stats: _sampleStats,
      orders: _sampleOrders,
      pageInfo: _ordersPage,
      onPageChanged: _noopPage,
    ),
    'ported_f2_02_evidence': _evidenceBackdrop,
    'ported_f2_04_claims_empty': const EcClaimListScreen(),
    'ported_f2_03_video_detail': _over(
      _evidenceBackdrop,
      const EcVideoDetailScreen(
        video: EcVideoDetail(
          title: 'Đóng hàng',
          duration: '02:45',
          recordedAt: '23/07/2026 · 10:23',
          recordedBy: 'Trần Thị B (Nhân viên)',
          device: 'iPhone 12 · app 1.0',
          uploadStatus: 'Đã upload',
        ),
      ),
    ),
    'ported_f3_01_idle': EcWaitBill2Screen(
      preview: _viewfinder('ec-viewfinder-idle'),
    ),
    'ported_f3_03_rec': EcRecording2Screen(
      code: 'SPXVN024567890',
      elapsed: '00:12',
      preview: _viewfinder('ec-viewfinder-rec'),
    ),
    'ported_f4_01_account': const EcAccountTabScreen(
      userName: 'Nguyễn Văn A',
      userEmail: 'nguyenvana@gmail.com',
    ),
    'ported_f4_03_language': const EcLanguageScreen(),
    // Khung design vẽ sheet này đè lên màn chờ bill; thiếu nền thì ảnh đối
    // chiếu lệch phần lớn diện tích vì lý do không liên quan tới bản port.
    'ported_f3_02_code': _over(
      EcWaitBill2Screen(preview: _viewfinder('ec-viewfinder-idle')),
      const EcManualEntryScreen(),
    ),
    'ported_f3_04_saved': EcCutoverBScreen(
      closedCode: 'SPXVN024567890',
      newCode: 'SPXVN098765432',
      preview: _viewfinder('ec-viewfinder-saved-next'),
    ),
    'ported_f3_05_ceiling': EcNearLimitScreen(
      code: 'SPXVN024567890',
      preview: _viewfinder('ec-viewfinder-long-recording'),
    ),
    // Same four rows F3-06 draws, so the pair can be diffed state for state.
    'ported_f3_06_queue': const EcUploadQueueScreen(
      items: [
        EcUploadItem(
          code: 'SPXVN024567890',
          typeLabel: 'Đóng hàng đi',
          when: '02:45 · 10:23',
          status: EcUploadStatus.uploading,
          progressPercent: 72,
        ),
        EcUploadItem(
          code: 'SPXVN098765432',
          typeLabel: 'Đóng hàng đi',
          when: '03:12 · 10:28',
          status: EcUploadStatus.done,
        ),
        EcUploadItem(
          code: 'SPXVN011122233',
          typeLabel: 'Đơn vị vận chuyển',
          when: '01:05 · 10:40',
          status: EcUploadStatus.error,
          retryCount: 2,
        ),
        EcUploadItem(
          code: 'SPXVN044556677',
          typeLabel: 'Trả hàng',
          when: '04:20 · 10:55',
          status: EcUploadStatus.quotaWait,
        ),
      ],
    ),
    'ported_f3_07_return': EcReturnRecScreen(
      code: 'SPXVN088877766 (hoàn)',
      preview: _viewfinder('ec-viewfinder-return'),
    ),
    'ported_f3_08_mismatch': _over(
      EcReturnRecScreen(
        code: 'SPXVN088877766 (hoàn)',
        preview: _viewfinder('ec-viewfinder-return-mismatch'),
      ),
      // Nút phải có callback, nếu không nó vẽ ở trạng thái disabled và khung
      // design lại vẽ nút xanh đậm đang bật.
      EcNoMatchScreen(
        returnCode: 'SPXVN099988877',
        shopName: 'Shop ABC',
        onEnterManually: () {},
        onCreateNew: () {},
      ),
    ),
    'ported_f3_10_new_type': _over(
      EcRecording2Screen(
        code: 'SPXVN024567890',
        elapsed: '00:18',
        preview: _viewfinder('ec-viewfinder-new-video-type'),
      ),
      const shift.EcCreateTypeScreen(),
    ),
    'ported_f3_09_pick_type': _over(
      EcRecording2Screen(
        code: 'SPXVN024567890',
        elapsed: '00:14',
        preview: _viewfinder('ec-viewfinder-new-video-type'),
      ),
      const EcTypeSheetScreen(),
    ),
    'ported_f4_02_profile': EcEditProfileScreen(
      email: 'nguyenvana@gmail.com',
      nameController: TextEditingController(text: 'Nguyễn Văn A'),
      phoneController: TextEditingController(text: '090 123 4567'),
      onSave: () {},
    ),
    // Same sample figures the design frame shows, so the diff is about
    // layout rather than about which numbers happen to be loaded.
    'ported_f4_04_quota': const EcQuotaScreen(
      usedVideos: 263,
      capVideos: 1000,
      retentionTotalDays: 25,
      typeUsage: [
        EcQuotaTypeUsage(type: 'Đóng hàng', videoCount: 148),
        EcQuotaTypeUsage(type: 'Đơn vị vận chuyển', videoCount: 72),
        EcQuotaTypeUsage(type: 'Trả hàng', videoCount: 31),
        EcQuotaTypeUsage(type: 'Cân hàng', videoCount: 12),
      ],
    ),
    'ported_f4_05_password': _over(
      _accountBackdrop,
      const EcChangePasswordScreen(),
    ),
    'ported_f4_06_delete': _over(
      _accountBackdrop,
      const EcDeleteAccountScreen(),
    ),
  };

  screens.forEach((name, screen) {
    testWidgets(
      name,
      skip: !coInter,
      experimentalLeakTesting: LeakTesting.settings.withIgnoredAll(),
      (tester) async {
        tester.view
          ..physicalSize = _designSize
          ..devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        await tester.runAsync(_warmDesignArtwork);

        // Ghim đồng hồ: dấu giờ trên màn quay đọc `clock.now()`. Không ghim thì
        // ba màn quay đổi theo giây và golden không bao giờ xanh hai lần liền.
        await withClock(
          Clock.fixed(DateTime(2026, 9, 17, 9)),
          () => tester.pumpWidget(
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

// Golden/pixel snapshots — a LOCAL eyeball tool, not a CI assertion (goldens
// don't match across OS / fonts). Tagged so `--exclude-tags golden` skips them
// per dart_test.yaml; regenerate with `flutter test --update-goldens --tags golden`.
@Tags(['golden'])
library;

import 'package:app_ui/app_ui.dart';
import 'package:feature_account/feature_account.dart';
import 'package:feature_capture/feature_capture.dart' hide EcVideoType;
import 'package:feature_orders/feature_orders.dart';
import 'package:feature_shift/feature_shift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';
import 'package:localization/localization.dart';

// Renders each screen at iPhone size and writes a PNG so the design can be
// eyeballed (run with --update-goldens). Not a pass/fail assertion of pixels.
Future<void> _cap(WidgetTester t, String name, Widget screen) async {
  // iPhone 11 logical size (414×896) — verify layouts adapt beyond the 390×844
  // design canvas (the responsiveness the user flagged).
  t.view.physicalSize = const Size(414, 896);
  t.view.devicePixelRatio = 1;
  // THÁO cây widget khi test xong, đừng chỉ reset view.
  //
  // Không tháo thì mỗi màn chụp xong để lại nguyên cây của nó, và
  // `leak_tracker` (bật toàn cục ở `flutter_test_config.dart`) đếm sạch:
  // 795 đối tượng cho riêng màn chờ bill — 151 element render, 81
  // StatefulElement, 47 TextPainter… chứ không phải một rò rỉ cụ thể nào.
  //
  // Đây là con số từng làm tôi tưởng có rò rỉ thứ hai trong mã sản phẩm. Không
  // có: `AnimationController` và `CurvedAnimation` của khung ngắm nằm trong đó
  // chỉ vì chúng thuộc cái cây chưa ai tháo. `ec_app_test.dart` đã dùng đúng
  // khuôn này từ trước.
  addTearDown(() async {
    await t.pumpWidget(const SizedBox.shrink());
    await t.pump();
    t.view.reset();
  });
  await t.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('vi'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // `disableAnimations` — dùng đúng cái hook màn quay đã có sẵn.
      //
      // Khung ngắm chạy một vệt quét LẶP VÔ HẠN, nên `pumpAndSettle` không bao
      // giờ tới được lúc hết khung để bơm và ném timeout. `_FramingCornersState
      // .didChangeDependencies` vốn đã đọc cờ này để đỗ vệt quét ở giữa thay vì
      // quét mãi — đó là đường Reduce Motion của hệ điều hành, không phải một
      // lối tắt bịa ra cho test.
      //
      // Được thêm: mọi ảnh chụp thành tất định, không còn phụ thuộc vào việc
      // khung nào rơi đúng lúc bấm máy.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
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
  // Phông Inter nay nằm trong `assets/google_fonts/`, nên tắt tải qua mạng là
  // đọc thẳng từ assets chứ không còn ném lỗi. (Đặt cả ở
  // `flutter_test_config.dart` cho mọi file; giữ ở đây cho file này tự đứng.)
  GoogleFonts.config.allowRuntimeFetching = false;

  // Bộ nhớ đệm ảnh SỐNG LÂU HƠN cây widget — đó là việc của nó. Logo shop để
  // lại ba đối tượng trong đệm sau mỗi màn, và `leak_tracker` đếm chúng là rò.
  //
  // Đã thử dọn đệm trong teardown: hỏng ngay ba golden (login/register/forgot,
  // lệch 0.43% — đúng chỗ cái logo), vì màn sau không kịp nạp lại ảnh. Đệm là
  // thứ dùng chung giữa các test, dọn nó là phá bối cảnh của test kế tiếp.
  //
  // Nên khai báo bỏ qua đúng ba loại này, và CHỈ ba loại. Phần còn lại của cây
  // vẫn bị soi — chính nhờ vậy mà lượt này bắt được cả cây không được tháo (795
  // đối tượng) lẫn một rò rỉ thật ở `_FramingCornersState`.
  LeakTesting.settings = LeakTesting.settings.withIgnored(
    notDisposed: {
      'ImageStreamCompleterHandle': null,
      'ImageInfo': null,
      'Image': null,
      // Nội bộ của chính `imageCache` (`_CachedImage`) — cùng lý do.
      '_CachedImage': null,
    },
  );

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

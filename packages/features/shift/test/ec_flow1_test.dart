import 'package:app_ui/app_ui.dart';
import 'package:ec_ui/ec_ui.dart';
import 'package:feature_shift/feature_shift.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoActionSheet, CupertinoTextField;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_contracts/shared_contracts.dart';
import 'package:localization/localization.dart';

/// These screens read their copy through `context.l10n`, so the harness has to
/// install the delegates — without them `AppLocalizations.of` returns null and
/// every screen in this file throws on build. Pinned to `vi`, which is what
/// the expectations below are written against.
Future<void> _pump(WidgetTester tester, Widget screen) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('vi'),
      supportedLocales: const [Locale('vi'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: screen,
    ),
  );
}

void main() {
  group('EcRegisterScreen', () {
    testWidgets('renders the whole register layout without overflow', (
      tester,
    ) async {
      await _pump(tester, const EcRegisterScreen());
      expect(find.text('Đăng ký'), findsOneWidget);
      expect(find.text('Họ tên'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Số điện thoại'), findsOneWidget);
      expect(find.text('Mật khẩu'), findsOneWidget);
      expect(find.text('Nhập lại mật khẩu'), findsOneWidget);
      expect(find.text('Điều khoản sử dụng'), findsOneWidget);
      expect(find.text('Tạo tài khoản'), findsOneWidget);
      expect(find.text('Đăng nhập với Google'), findsOneWidget);
      expect(find.text('Đăng nhập với Apple'), findsOneWidget);
      expect(find.text('Đăng nhập'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('register + login callbacks fire', (tester) async {
      var registered = false;
      var loggedIn = false;
      final password = TextEditingController();
      await _pump(
        tester,
        EcRegisterScreen(
          nameController: TextEditingController(),
          emailController: TextEditingController(),
          phoneController: TextEditingController(),
          passwordController: password,
          confirmPasswordController: TextEditingController(),
          onRegister: () => registered = true,
          onLogin: () => loggedIn = true,
        ),
      );
      final fields = find.byType(CupertinoTextField);
      await tester.enterText(fields.at(0), 'Nguyễn Văn A');
      await tester.enterText(fields.at(1), 'a@b.com');
      await tester.enterText(fields.at(2), '0901234567');
      // Phải đạt chính sách mật khẩu (shared_contracts/password_policy.dart):
      // ≥8 ký tự, có chữ và số, không nằm trong danh sách phổ biến.
      await tester.enterText(fields.at(3), 'dongGoi2026');
      await tester.enterText(fields.at(4), 'dongGoi2026');
      await tester.pump();
      await tester.ensureVisible(find.text('Tạo tài khoản'));
      await tester.tap(find.text('Tạo tài khoản'));
      await tester.dragUntilVisible(
        find.text('Đăng nhập'),
        find.byType(CustomScrollView),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đăng nhập'));
      expect(registered, isTrue);
      expect(loggedIn, isTrue);
    });

    testWidgets('mật khẩu yếu chặn đăng ký và hiện lỗi', (tester) async {
      var registered = false;
      await _pump(
        tester,
        EcRegisterScreen(
          nameController: TextEditingController(),
          emailController: TextEditingController(),
          phoneController: TextEditingController(),
          passwordController: TextEditingController(),
          confirmPasswordController: TextEditingController(),
          onRegister: () => registered = true,
        ),
      );
      final fields = find.byType(CupertinoTextField);
      await tester.enterText(fields.at(0), 'Nguyễn Văn A');
      await tester.enterText(fields.at(1), 'a@b.com');
      await tester.enterText(fields.at(2), '0901234567');
      // Đủ 8 ký tự nhưng toàn chữ — phải bị từ chối.
      await tester.enterText(fields.at(3), 'matkhaudai');
      await tester.enterText(fields.at(4), 'matkhaudai');
      await tester.pump();
      await tester.ensureVisible(find.text('Tạo tài khoản'));
      await tester.tap(find.text('Tạo tài khoản'));
      await tester.pump();
      expect(registered, isFalse);
      expect(find.text('Mật khẩu cần có cả chữ và số'), findsOneWidget);
    });
  });

  group('EcForgotPasswordScreen', () {
    testWidgets('renders title, field and footer without overflow', (
      tester,
    ) async {
      await _pump(tester, const EcForgotPasswordScreen());
      expect(find.text('Quên mật khẩu'), findsOneWidget);
      // The design's email field carries a placeholder, not a label.
      expect(find.text('Nhập email của bạn'), findsOneWidget);
      expect(find.text('Gửi link đặt lại'), findsOneWidget);
      expect(find.text('Đăng nhập'), findsOneWidget);
      expect(
        find.text('Đã gửi — kiểm tra hộp thư (kể cả mục spam)'),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows sent confirmation box when sent is true', (
      tester,
    ) async {
      await _pump(tester, const EcForgotPasswordScreen(sent: true));
      expect(
        find.text('Đã gửi — kiểm tra hộp thư (kể cả mục spam)'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('send callback fires', (tester) async {
      var sent = false;
      await _pump(tester, EcForgotPasswordScreen(onSend: () => sent = true));
      await tester.enterText(find.byType(CupertinoTextField), 'a@b.com');
      await tester.pump();
      await tester.tap(find.text('Gửi link đặt lại'));
      expect(sent, isTrue);
    });
  });

  group('EcChooseShopScreen', () {
    const shops = [
      EcShopSummary(
        name: 'Shop ABC',
        platform: 'shopee',
        meta: 'Shopee · ID: 123456',
      ),
      EcShopSummary(
        name: 'Shop XYZ',
        platform: 'lazada',
        meta: 'Lazada · ID: 780012',
      ),
    ];

    testWidgets('renders shop list and management row without overflow', (
      tester,
    ) async {
      await _pump(tester, const EcChooseShopScreen(shops: shops));
      expect(find.text('Chọn cửa hàng'), findsOneWidget);
      expect(find.text('Shop ABC'), findsOneWidget);
      expect(find.text('Shop XYZ'), findsOneWidget);
      expect(find.text('Quản lý cửa hàng'), findsOneWidget);
      expect(find.text('Đăng xuất'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('select + manage callbacks fire', (tester) async {
      EcShopSummary? selected;
      var managed = false;
      await _pump(
        tester,
        EcChooseShopScreen(
          shops: shops,
          onSelect: (shop) => selected = shop,
          onManage: () => managed = true,
        ),
      );
      await tester.tap(find.text('Shop ABC'));
      await tester.tap(find.text('Quản lý cửa hàng'));
      expect(selected?.name, 'Shop ABC');
      expect(managed, isTrue);
    });
  });

  group('EcNoShopScreen', () {
    testWidgets('renders empty state without overflow', (tester) async {
      await _pump(tester, const EcNoShopScreen());
      expect(find.text('Chưa có shop nào'), findsOneWidget);
      expect(find.text('Tạo shop mới (tên + sàn)'), findsOneWidget);
      expect(find.text('Lời mời vào shop sẽ hiện ở đây'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('create callback fires', (tester) async {
      var created = false;
      await _pump(tester, EcNoShopScreen(onCreate: () => created = true));
      await tester.tap(find.text('Tạo shop mới (tên + sàn)'));
      expect(created, isTrue);
    });
  });

  group('EcCreateShopScreen', () {
    testWidgets('renders header, platforms and note without overflow', (
      tester,
    ) async {
      await _pump(tester, const EcCreateShopScreen());
      expect(find.text('Tạo shop'), findsNWidgets(2));
      expect(find.text('Tên shop'), findsOneWidget);
      expect(find.text('Sàn thương mại'), findsOneWidget);
      expect(find.text('Shopee'), findsOneWidget);
      expect(find.text('TikTok'), findsOneWidget);
      expect(find.text('Lazada'), findsOneWidget);
      expect(find.text('Tiki'), findsOneWidget);
      expect(find.text('Khác'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('platform selection + create callbacks fire', (
      tester,
    ) async {
      String? picked;
      var created = false;
      await _pump(
        tester,
        EcCreateShopScreen(
          onPlatformSelected: (id) => picked = id,
          onCreate: () => created = true,
        ),
      );
      await tester.enterText(find.byType(CupertinoTextField), 'Shop Test');
      await tester.pump();
      await tester.tap(find.text('Lazada'));
      await tester.tap(find.text('Tạo shop').last);
      expect(picked, 'lazada');
      expect(created, isTrue);
    });
  });

  group('EcShopMgmtScreen', () {
    const shops = [
      EcShopMgmtEntry(name: 'Shop ABC', meta: 'Shopee · 3 thành viên'),
      EcShopMgmtEntry(name: 'Shop XYZ', meta: 'Lazada · 2 thành viên'),
    ];

    testWidgets('renders shop list and add row without overflow', (
      tester,
    ) async {
      await _pump(tester, const EcShopMgmtScreen(shops: shops));
      expect(find.text('Quản lý cửa hàng'), findsOneWidget);
      expect(find.text('Shop ABC'), findsOneWidget);
      expect(find.text('Shop XYZ'), findsOneWidget);
      expect(find.text('Thêm shop mới (tên + sàn)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shop tap + add shop callbacks fire', (tester) async {
      EcShopMgmtEntry? tapped;
      var addTapped = false;
      await _pump(
        tester,
        EcShopMgmtScreen(
          shops: shops,
          onShopTap: (shop) => tapped = shop,
          onAddShop: () => addTapped = true,
        ),
      );
      await tester.tap(find.text('Shop ABC'));
      await tester.tap(find.text('Thêm shop mới (tên + sàn)'));
      expect(tapped?.name, 'Shop ABC');
      expect(addTapped, isTrue);
    });
  });

  group('EcShopDetailScreen', () {
    const members = [
      EcShopMember(name: 'Nguyễn Văn A', role: 'Quản lý shop'),
      EcShopMember(name: 'Trần Thị B', role: 'Nhân viên'),
    ];
    const videoTypes = [
      EcVideoType(name: 'Đóng hàng', locked: true),
      EcVideoType(name: 'Cân hàng'),
    ];

    testWidgets('renders members and settings without overflow', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcShopDetailScreen(
          shopName: 'Shop ABC',
          platformLabel: 'Shopee',
          members: members,
          videoTypes: videoTypes,
        ),
      );
      expect(find.text('Shop ABC'), findsOneWidget);
      expect(find.text('THÀNH VIÊN'), findsOneWidget);
      expect(find.text('Nguyễn Văn A'), findsOneWidget);
      expect(find.text('Trần Thị B'), findsOneWidget);
      expect(find.text('CÀI ĐẶT SHOP'), findsOneWidget);
      expect(find.text('Độ phân giải quay'), findsOneWidget);
      expect(find.text('Đóng hàng'), findsOneWidget);
      expect(find.text('Cân hàng'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'shows the recommendation caption and no warning at or below it',
      (
        tester,
      ) async {
        await _pump(
          tester,
          const EcShopDetailScreen(
            shopName: 'Shop ABC',
            platformLabel: 'Shopee',
            members: members,
            videoTypes: videoTypes,
            clipBudget: ClipBudget(
              seconds: 120,
              recommendedSeconds: 120,
              planMaxSeconds: 900,
              maxImageBytes: 10000000,
              maxVideoBytes: 30000000,
            ),
          ),
        );
        expect(find.text('Thời lượng/video'), findsOneWidget);
        expect(find.text('2 phút'), findsOneWidget);
        expect(
          find.text('Đề xuất 2 phút — theo Shopee (30 MB/video) + 720p'),
          findsOneWidget,
        );
        expect(find.textContaining('Vượt mức đề xuất'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'raising the cap past the recommendation shows the amber warning',
      (
        tester,
      ) async {
        await _pump(
          tester,
          const EcShopDetailScreen(
            shopName: 'Shop ABC',
            platformLabel: 'Shopee',
            members: members,
            videoTypes: videoTypes,
            clipBudget: ClipBudget(
              seconds: 300,
              recommendedSeconds: 120,
              planMaxSeconds: 900,
              maxImageBytes: 10000000,
              maxVideoBytes: 30000000,
            ),
          ),
        );
        expect(find.text('5 phút'), findsOneWidget);
        expect(
          find.textContaining('Vượt mức đề xuất 2 phút của Shopee'),
          findsOneWidget,
        );
        // 5 phút × 15 MB/phút = ~75 MB — con số phải thật, không phải nhãn suông.
        expect(find.textContaining('~75 MB'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('an unverified platform says so instead of quoting a number', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcShopDetailScreen(
          shopName: 'Kho tổng',
          platformLabel: 'Khác',
          members: members,
          videoTypes: videoTypes,
          clipBudget: ClipBudget(
            seconds: 120,
            recommendedSeconds: 120,
            planMaxSeconds: 900,
            maxImageBytes: 10000000,
            maxVideoBytes: 30000000,
            platformLimitsVerified: false,
          ),
        ),
      );
      expect(find.textContaining('chưa xác minh'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('clip duration row opens the picker', (tester) async {
      var tapped = false;
      await _pump(
        tester,
        EcShopDetailScreen(
          shopName: 'Shop ABC',
          platformLabel: 'Shopee',
          members: members,
          videoTypes: videoTypes,
          onTapClipDuration: () => tapped = true,
        ),
      );
      await tester.tap(find.text('Thời lượng/video'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('resolution + edit type callbacks fire', (tester) async {
      var resolutionTapped = false;
      EcVideoType? edited;
      await _pump(
        tester,
        EcShopDetailScreen(
          shopName: 'Shop ABC',
          platformLabel: 'Shopee',
          members: members,
          videoTypes: videoTypes,
          onTapResolution: () => resolutionTapped = true,
          onEditType: (type) => edited = type,
        ),
      );
      await tester.tap(find.text('Độ phân giải quay'));
      await tester.tap(find.byIcon(LucideIcons.pencil));
      expect(resolutionTapped, isTrue);
      expect(edited?.name, 'Cân hàng');
    });
  });

  group('EcCreateTypeScreen', () {
    testWidgets('renders dialog fields without overflow', (tester) async {
      await _pump(tester, const EcCreateTypeScreen());
      expect(find.text('Tạo loại video'), findsOneWidget);
      expect(find.text('Tên loại video'), findsOneWidget);
      expect(find.text('Hủy'), findsOneWidget);
      expect(find.text('Tạo loại'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('cancel + create callbacks fire', (tester) async {
      var cancelled = false;
      var created = false;
      await _pump(
        tester,
        EcCreateTypeScreen(
          onCancel: () => cancelled = true,
          onCreate: () => created = true,
        ),
      );
      await tester.tap(find.text('Hủy'));
      await tester.tap(find.text('Tạo loại'));
      expect(cancelled, isTrue);
      expect(created, isTrue);
    });
  });

  group('EcConfirmDeleteScreen', () {
    testWidgets('renders dialog copy without overflow', (tester) async {
      await _pump(tester, const EcConfirmDeleteScreen());
      // Straight quotes: the copy comes from `deleteVideoTypeTitle` in the ARB,
      // which the curly-quoted literal here predates.
      expect(find.text('Xóa loại "Cân hàng"?'), findsOneWidget);
      expect(find.text('Hủy'), findsOneWidget);
      expect(find.text('Xác nhận'), findsOneWidget);
      expect(find.text('Không mất bằng chứng'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('cancel + confirm callbacks fire', (tester) async {
      var cancelled = false;
      var confirmed = false;
      await _pump(
        tester,
        EcConfirmDeleteScreen(
          onCancel: () => cancelled = true,
          onConfirm: () => confirmed = true,
        ),
      );
      await tester.tap(find.text('Hủy'));
      await tester.tap(find.text('Xác nhận'));
      expect(cancelled, isTrue);
      expect(confirmed, isTrue);
    });
  });

  group('EcHomeOrdersScreen', () {
    const orders = [
      EcOrderRow(
        code: 'SPXVN024567890',
        time: '10:23',
        type: 'Đóng hàng đi',
        videoCount: 3,
      ),
      EcOrderRow(
        code: 'SPXVN044556677',
        time: '10:55',
        type: 'Trả hàng',
        videoCount: 1,
        errorCount: 1,
      ),
    ];

    testWidgets('renders stats, orders and bottom nav without overflow', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcHomeOrdersScreen(shopName: 'Shop ABC', orders: orders),
      );
      expect(find.text('Shop ABC'), findsOneWidget);
      expect(find.text('Vận đơn'), findsOneWidget);
      expect(find.text('SPXVN024567890'), findsOneWidget);
      expect(find.text('SPXVN044556677'), findsOneWidget);
      expect(find.text('1 lỗi'), findsOneWidget);
      expect(find.text('Vận đơn'), findsOneWidget);
      expect(find.text('Ghi hình'), findsOneWidget);
      expect(find.text('Tài khoản'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('order tap + nav record callbacks fire', (tester) async {
      EcOrderRow? tapped;
      var wentToRecord = false;
      await _pump(
        tester,
        EcHomeOrdersScreen(
          shopName: 'Shop ABC',
          orders: orders,
          onOrderTap: (order) => tapped = order,
          onNavRecord: () => wentToRecord = true,
        ),
      );
      await tester.tap(find.text('SPXVN024567890'));
      await tester.tap(find.text('Ghi hình'));
      expect(tapped?.code, 'SPXVN024567890');
      expect(wentToRecord, isTrue);
    });

    testWidgets('search field filters the order list live', (tester) async {
      await _pump(
        tester,
        const EcHomeOrdersScreen(shopName: 'Shop ABC', orders: orders),
      );
      // Both orders visible before typing.
      expect(find.text('SPXVN024567890'), findsOneWidget);
      expect(find.text('SPXVN044556677'), findsOneWidget);

      await tester.enterText(find.byType(EditableText), '0245');
      await tester.pump();

      // Only the matching order remains.
      expect(find.text('SPXVN024567890'), findsOneWidget);
      expect(find.text('SPXVN044556677'), findsNothing);
    });

    testWidgets('search field delegates to server callback when wired', (
      tester,
    ) async {
      final searches = <String>[];
      await _pump(
        tester,
        EcHomeOrdersScreen(
          shopName: 'Shop ABC',
          orders: orders,
          onSearchChanged: searches.add,
        ),
      );

      await tester.enterText(find.byType(EditableText), 'ZZZ');
      await tester.pump();

      expect(searches, ['ZZZ']);
      expect(find.text('SPXVN024567890'), findsOneWidget);
      expect(find.text('SPXVN044556677'), findsOneWidget);
    });

    testWidgets('the three filter chips start unfiltered', (tester) async {
      await _pump(
        tester,
        const EcHomeOrdersScreen(shopName: 'Shop ABC', orders: orders),
      );
      // Three chevron-down chips, each showing its own "no filter" value —
      // they used to be three chips whose sheets offered a single option
      // (themselves), which made two of the three dead controls.
      expect(find.byIcon(LucideIcons.chevronDown), findsNWidgets(3));
      expect(find.text('Tất cả'), findsOneWidget);
      expect(find.text('Mọi lúc'), findsOneWidget);
      expect(find.text('Loại video'), findsOneWidget);
    });

    testWidgets('status chip offers every upload state and reports the pick', (
      tester,
    ) async {
      final picked = <EcOrderFilters>[];
      await _pump(
        tester,
        EcHomeOrdersScreen(
          shopName: 'Shop ABC',
          orders: orders,
          onFiltersChanged: picked.add,
        ),
      );

      await tester.tap(find.text('Tất cả'));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoActionSheet), findsOneWidget);
      // A real option set, not just the chip's own label back at it.
      expect(find.text('Chờ upload'), findsOneWidget);
      expect(find.text('Có lỗi tải'), findsOneWidget);
      expect(find.text('Đã tải xong'), findsOneWidget);

      await tester.tap(find.text('Có lỗi tải'));
      await tester.pumpAndSettle();

      // The backend's `upload_state` value goes out, and the chip now shows
      // the selection instead of "Tất cả".
      expect(picked.single.uploadState, 'error');
      expect(picked.single.videoTypeId, isNull);
      expect(find.text('Có lỗi tải'), findsOneWidget);
      expect(find.text('Tất cả'), findsNothing);
    });

    testWidgets('time chip maps "Hôm nay" to local midnight', (tester) async {
      final picked = <EcOrderFilters>[];
      await _pump(
        tester,
        EcHomeOrdersScreen(
          shopName: 'Shop ABC',
          orders: orders,
          onFiltersChanged: picked.add,
        ),
      );

      await tester.tap(find.text('Mọi lúc'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hôm nay'));
      await tester.pumpAndSettle();

      final now = DateTime.now();
      expect(
        picked.single.fromTs,
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch,
      );
    });

    testWidgets('type chip lists the shop video types, not the loaded rows', (
      tester,
    ) async {
      final picked = <EcOrderFilters>[];
      await _pump(
        tester,
        EcHomeOrdersScreen(
          shopName: 'Shop ABC',
          orders: orders,
          // Deliberately a type no loaded order uses: the options come from the
          // shop's types, so a filter can reach rows on a later page.
          videoTypes: const [EcVideoTypeOption(id: 'vt-9', name: 'Cân hàng')],
          onFiltersChanged: picked.add,
        ),
      );

      await tester.ensureVisible(find.text('Loại video'));
      await tester.tap(find.text('Loại video'));
      await tester.pumpAndSettle();
      expect(find.text('Cân hàng'), findsOneWidget);

      await tester.tap(find.text('Cân hàng'));
      await tester.pumpAndSettle();

      expect(picked.single.videoTypeId, 'vt-9');
    });

    testWidgets('picking a filter never hides rows locally', (tester) async {
      // Filters are applied by the backend, so the widget must keep showing
      // whatever it was handed until the parent supplies a new page.
      await _pump(
        tester,
        EcHomeOrdersScreen(
          shopName: 'Shop ABC',
          orders: orders,
          videoTypes: const [EcVideoTypeOption(id: 'vt-9', name: 'Cân hàng')],
          onFiltersChanged: (_) {},
        ),
      );

      await tester.ensureVisible(find.text('Loại video'));
      await tester.tap(find.text('Loại video'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cân hàng'));
      await tester.pumpAndSettle();

      expect(find.text('SPXVN024567890'), findsOneWidget);
      expect(find.text('SPXVN044556677'), findsOneWidget);
    });

    testWidgets('an empty filtered list says "not found", not "no orders"', (
      tester,
    ) async {
      await _pump(
        tester,
        EcHomeOrdersScreen(
          shopName: 'Shop ABC',
          orders: const [],
          emptyText: 'Shop chưa có đơn nào',
          onFiltersChanged: (_) {},
        ),
      );
      expect(find.text('Shop chưa có đơn nào'), findsOneWidget);

      await tester.tap(find.text('Tất cả'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chờ upload'));
      await tester.pumpAndSettle();

      expect(find.text('Shop chưa có đơn nào'), findsNothing);
      expect(find.text('Không tìm thấy đơn hàng'), findsOneWidget);
    });
  });
}

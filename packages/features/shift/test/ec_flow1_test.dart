import 'package:app_ui/app_ui.dart';
import 'package:ec_ui/ec_ui.dart';
import 'package:feature_shift/feature_shift.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoActionSheet, CupertinoDatePicker, CupertinoTextField;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_contracts/shared_contracts.dart';
import 'package:localization/localization.dart';

/// These screens read their copy through `context.l10n`, so the harness has to
/// install the delegates — without them `AppLocalizations.of` returns null and
/// every screen in this file throws on build. Pinned to `vi`, which is what
/// the expectations below are written against.
Future<void> _pump(
  WidgetTester tester,
  Widget screen, {
  Size size = const Size(390, 844),
}) {
  tester.view.physicalSize = size;
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
  group('bottom sheets', () {
    // Bốn sheet của flow 1 từng tự dựng lại panel: góc vuông, không vuốt xuống
    // được, và SafeArea chồng lên padding đáy nên thừa một dải trắng. Chốt vào
    // PenSheet để cả ba thứ đến từ một chỗ.
    testWidgets('member actions is a PenSheet, not a hand-rolled panel', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcMemberActionsScreen(
          member: EcShopMember(name: 'A', role: 'Chủ shop'),
        ),
      );
      expect(find.byType(PenSheet), findsOneWidget);
    });

    // Lời mời chưa ai nhận không có tài khoản để đổi vai trò — hai dòng đó bấm
    // vào chỉ báo lỗi. Việc duy nhất làm được là xóa lời mời.
    testWidgets('lời mời còn treo chỉ có hành động xóa lời mời', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcMemberActionsScreen(
          member: EcShopMember(
            name: 'moi@test.co',
            role: 'Nhân viên · đã gửi lời mời',
            inviteId: 'inv-1',
          ),
        ),
      );

      expect(find.text('Xóa lời mời'), findsOneWidget);
      expect(find.text('Gỡ khỏi shop'), findsNothing);
      expect(find.text('Đặt làm quản lý shop'), findsNothing);
    });

    // Chủ cửa hàng không có hàng trong shop_members, nên đổi vai trò trả 404 và
    // gỡ thì máy chủ xoá 0 hàng. Bày hai việc đó ra là mời người dùng bấm vào
    // một thao tác không bao giờ xảy ra — và bản cũ còn báo "đã gỡ" cho nó.
    testWidgets('hàng chủ shop không có đổi vai trò và không có gỡ', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcMemberActionsScreen(
          member: EcShopMember(
            name: 'Chủ Shop',
            role: 'Chủ shop',
            roleCode: 'owner',
          ),
        ),
      );

      expect(find.text('Đặt làm Quản lý shop'), findsNothing);
      expect(find.text('Đặt làm Nhân viên'), findsNothing);
      expect(find.text('Gỡ khỏi shop'), findsNothing);
      // Và nói rõ vì sao, thay vì để một sheet trống không.
      expect(
        find.textContaining('quyền sở hữu gắn với cửa hàng'),
        findsOneWidget,
      );
    });

    // Shop chỉ còn HAI hạng: chủ và nhân viên. Hai dòng đổi vai trò đã bỏ —
    // không còn vai trò nào để đổi sang.
    testWidgets('thành viên thường chỉ còn một việc: gỡ khỏi shop', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcMemberActionsScreen(
          member: EcShopMember(
            name: 'Nhân viên A',
            role: 'Nhân viên',
            roleCode: 'staff',
          ),
        ),
      );

      expect(find.text('Đặt làm Quản lý shop'), findsNothing);
      expect(find.text('Đặt làm Nhân viên'), findsNothing);
      expect(find.text('Gỡ khỏi shop'), findsOneWidget);
    });

    testWidgets('màn mời chỉ chào một vai trò: nhân viên', (tester) async {
      await _pump(tester, const EcInviteMemberScreen());
      expect(find.text('Nhân viên'), findsOneWidget);
      expect(find.text('Quản lý shop'), findsNothing);
    });

    // Gõ sai định dạng thì backend vẫn tạo lời mời, nhưng mailer bỏ qua contact
    // không có '@' — lời mời treo mãi và không ai được báo gì.
    testWidgets('màn mời chỉ nhận email, gửi đi bản viết thường', (
      tester,
    ) async {
      EcMemberInvite? sent;
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await _pump(
        tester,
        EcInviteMemberScreen(
          contactController: controller,
          onInvite: (invite) => sent = invite,
        ),
      );

      await tester.enterText(find.byType(CupertinoTextField), 'nguyen van a');
      await tester.tap(find.text('Thêm'));
      await tester.pump();
      expect(sent, isNull);
      expect(find.text('Nhập đúng một địa chỉ email.'), findsOne);

      // Số điện thoại KHÔNG còn được nhận: backend khớp lời mời theo email và
      // chỉ email, nên một số gửi đi chỉ tạo ra lời mời treo vĩnh viễn.
      await tester.enterText(
        find.byType(CupertinoTextField),
        '+84 90 123 4567',
      );
      await tester.tap(find.text('Thêm'));
      await tester.pump();
      expect(sent, isNull);

      // Email lưu trong `accounts` là chữ thường, nên phải hạ chữ trước khi gửi
      // — không thì SQLite không khớp được tài khoản nào.
      await tester.enterText(
        find.byType(CupertinoTextField),
        'Ban@Email.com',
      );
      await tester.tap(find.text('Thêm'));
      await tester.pump();
      expect(sent?.contact, 'ban@email.com');
      // Mã vai trò, không phải nhãn hiển thị: nhãn đổi theo ngôn ngữ máy.
      expect(sent?.role, 'staff');
    });

    testWidgets('dragging the sheet down dismisses it', (tester) async {
      var dismissed = false;
      await _pump(
        tester,
        PenSheet(
          onDismiss: () => dismissed = true,
          children: const [Text('nội dung')],
        ),
      );
      await tester.drag(find.text('nội dung'), const Offset(0, 150));
      await tester.pumpAndSettle();
      expect(dismissed, isTrue);
    });

    testWidgets('a short drag snaps back instead of dismissing', (
      tester,
    ) async {
      var dismissed = false;
      await _pump(
        tester,
        PenSheet(
          onDismiss: () => dismissed = true,
          children: const [Text('nội dung')],
        ),
      );
      await tester.drag(find.text('nội dung'), const Offset(0, 20));
      await tester.pumpAndSettle();
      expect(dismissed, isFalse);
    });
  });

  group('EcRegisterScreen', () {
    testWidgets('renders the whole register layout without overflow', (
      tester,
    ) async {
      await _pump(tester, const EcRegisterScreen());
      expect(find.text('Đăng ký'), findsOneWidget);
      expect(find.text('Họ tên'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Số điện thoại (tùy chọn)'), findsOneWidget);
      expect(find.text('Mật khẩu'), findsOneWidget);
      expect(find.text('Nhập lại mật khẩu'), findsOneWidget);
      expect(find.text('Điều khoản sử dụng'), findsOneWidget);
      expect(find.text('Tạo tài khoản'), findsOneWidget);
      expect(find.text('Đăng ký với Google'), findsOneWidget);
      expect(find.text('Đăng ký với Apple'), findsOneWidget);
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
      expect(find.text('Gửi liên kết đặt lại'), findsOneWidget);
      expect(find.text('Đăng nhập'), findsOneWidget);
      expect(
        find.text('Đã gửi — kiểm tra hộp thư, kể cả mục spam'),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows sent confirmation box when sent is true', (
      tester,
    ) async {
      await _pump(tester, const EcForgotPasswordScreen(sent: true));
      expect(
        find.text('Đã gửi — kiểm tra hộp thư, kể cả mục spam'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('send callback fires', (tester) async {
      var sent = false;
      await _pump(tester, EcForgotPasswordScreen(onSend: () => sent = true));
      await tester.enterText(find.byType(CupertinoTextField), 'a@b.com');
      await tester.pump();
      await tester.tap(find.text('Gửi liên kết đặt lại'));
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
      // "Quản lý cửa hàng" đã dời vào bánh răng ở header trang Vận đơn; chỗ
      // này giờ là lối tạo shop duy nhất.
      expect(find.text('Quản lý cửa hàng'), findsNothing);
      expect(find.text('Thêm cửa hàng mới'), findsOneWidget);
      expect(find.text('Đăng xuất'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('select + add shop callbacks fire', (tester) async {
      EcShopSummary? selected;
      var added = false;
      await _pump(
        tester,
        EcChooseShopScreen(
          shops: shops,
          onSelect: (shop) => selected = shop,
          onAddShop: () => added = true,
        ),
      );
      await tester.tap(find.text('Shop ABC'));
      await tester.tap(find.text('Thêm cửa hàng mới'));
      expect(selected?.name, 'Shop ABC');
      expect(added, isTrue);
    });
  });

  group('EcHomeOrdersScreen — bánh răng cài đặt', () {
    // Quản lý cửa hàng trước nằm ở màn Chọn cửa hàng — một màn người dùng chỉ
    // đi qua lúc vào ca rồi không quay lại. Muốn sửa cài đặt shop thì phải
    // thoát cả ca ra ngoài.
    testWidgets('bánh răng chỉ hiện khi bên gọi nối', (tester) async {
      var opened = false;
      await _pump(
        tester,
        EcHomeOrdersScreen(
          shopName: 'Shop ABC',
          orders: const [],
          onSettings: () => opened = true,
        ),
      );
      await tester.tap(find.byIcon(LucideIcons.settings));
      expect(opened, isTrue);

      await _pump(
        tester,
        const EcHomeOrdersScreen(shopName: 'Shop ABC', orders: []),
      );
      expect(find.byIcon(LucideIcons.settings), findsNothing);
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
      expect(find.text('Thêm shop mới'), findsOneWidget);
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
      await tester.tap(find.text('Thêm shop mới'));
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

    // Nhân viên phải THẤY được shop mình tham gia — trước đây màn quản lý lọc
    // sạch shop vai trò `staff`, nên người vừa nhận lời mời mở app ra tưởng
    // mình chưa vào được shop nào.
    testWidgets('read-only hides the rows that only owners can act on', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcShopDetailScreen(
          readOnly: true,
          shopName: 'Shop ABC',
          platformLabel: 'Shopee',
          members: members,
          videoTypes: videoTypes,
        ),
      );

      // Vẫn xem được shop và mọi thứ trong đó.
      expect(find.text('Shop ABC'), findsOneWidget);
      expect(find.text('Nguyễn Văn A'), findsOneWidget);
      expect(find.text('Đóng hàng'), findsOneWidget);

      // Nhưng không còn lối vào thao tác nào.
      expect(find.text('Mời thành viên'), findsNothing);
      expect(find.text('Thêm loại (nhập tên)'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an owner still gets the invite and add-type rows', (
      tester,
    ) async {
      await _pump(
        tester,
        EcShopDetailScreen(
          shopName: 'Shop ABC',
          platformLabel: 'Shopee',
          members: members,
          videoTypes: videoTypes,
          onInviteMember: () {},
          onAddType: () {},
        ),
      );
      expect(find.text('Mời thành viên'), findsOneWidget);
      expect(find.text('Thêm loại (nhập tên)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

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

    testWidgets('hàng thời lượng hiện trần đang áp dụng, không nhắc dung lượng', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcShopDetailScreen(
          shopName: 'Shop ABC',
          platformLabel: 'Shopee',
          members: members,
          videoTypes: videoTypes,
          clipBudget: ClipBudget(seconds: 300, planMaxSeconds: 300),
        ),
      );
      // Nhãn là `shopDetailClipLength` = "Thời lượng video" (không có gạch
      // chéo) — `shopDetailClipDuration` cũ đã không còn ai dùng.
      expect(find.text('Thời lượng video'), findsOneWidget);
      expect(find.text('5 phút'), findsOneWidget);
      // Mức đề xuất, cảnh báo vượt sàn và trần dung lượng đều đã bỏ.
      expect(find.textContaining('Đề xuất'), findsNothing);
      expect(find.textContaining('Vượt mức đề xuất'), findsNothing);
      expect(find.textContaining('MB'), findsNothing);
      expect(find.text('Dung lượng/tệp'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    // sheet chọn mốc — cả sheet lẫn lối vào đều đã bỏ.
    testWidgets('hai mức cố định hiện ra, không bấm được', (tester) async {
      await _pump(
        tester,
        EcShopDetailScreen(
          shopName: 'Shop ABC',
          platformLabel: 'Shopee',
          members: members,
          videoTypes: videoTypes,
        ),
      );
      expect(find.text('5 phút'), findsOneWidget);
      // Chỉ còn MỘT hàng cố định: hàng dung lượng ảnh đã bỏ 2026-08-07.
      expect(find.text('mặc định'), findsOneWidget);
      // Không còn hàng nào mở sheet.
      expect(find.text('Dung lượng/tệp'), findsNothing);
      expect(find.text('Độ phân giải quay'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('sửa loại video vẫn gọi callback', (tester) async {
      EcVideoType? edited;
      await _pump(
        tester,
        EcShopDetailScreen(
          shopName: 'Shop ABC',
          platformLabel: 'Shopee',
          members: members,
          videoTypes: videoTypes,
          onEditType: (type) => edited = type,
        ),
      );
      await tester.tap(find.byIcon(LucideIcons.pencil));
      expect(edited?.name, 'Cân hàng');
    });

    testWidgets('xóa shop: chỉ hiện khi bên gọi nối, và ẩn với nhân viên', (
      tester,
    ) async {
      var deleted = false;
      await _pump(
        tester,
        EcShopDetailScreen(
          shopName: 'Shop ABC',
          platformLabel: 'Shopee',
          members: members,
          videoTypes: videoTypes,
          onDeleteShop: () => deleted = true,
        ),
      );
      // Nút nằm cuối một màn cuộn dài — phải kéo tới nơi rồi mới chạm được.
      await tester.ensureVisible(find.text('Xóa cửa hàng'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xóa cửa hàng'));
      await tester.pump();
      expect(deleted, isTrue);

      // Nhân viên: thao tác không hoàn tác được thì không được phép hiện ra,
      // kể cả dạng nút mờ.
      await _pump(
        tester,
        EcShopDetailScreen(
          shopName: 'Shop ABC',
          platformLabel: 'Shopee',
          members: members,
          videoTypes: videoTypes,
          readOnly: true,
          onDeleteShop: () => deleted = true,
        ),
      );
      expect(find.text('Xóa cửa hàng'), findsNothing);
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

    // Máy Android phổ thông rộng 360pt, hẹp hơn khung design 390pt: hàng màu
    // từng tràn ở đây vì ô màu cố định 44pt.
    testWidgets('color row survives a 360pt-wide screen', (tester) async {
      await _pump(
        tester,
        const EcCreateTypeScreen(),
        size: const Size(360, 800),
      );
      expect(find.text('Màu sắc'), findsOneWidget);
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
      expect(find.text('SPXVN024567890'), findsOneWidget);
      expect(find.text('SPXVN044556677'), findsOneWidget);
      expect(find.text('1 lỗi'), findsOneWidget);
      // "Vận đơn" labels both the first stat card and the orders tab.
      expect(find.text('Vận đơn'), findsNWidgets(2));
      expect(find.text('Ghi hình'), findsOneWidget);
      // Ô tab thứ ba nay là Hồ sơ khiếu nại; Tài khoản dời ra màn Chọn cửa
      // hàng.
      expect(find.text('Khiếu nại'), findsOneWidget);
      expect(find.text('Tài khoản'), findsNothing);
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
      // Khung F2-01 mới: cả ba chip đều là dropdown, và khi chưa lọc chip chỉ
      // hiện tên chiều lọc chứ không phải giá trị "tất cả" của nó.
      expect(find.byIcon(LucideIcons.chevronDown), findsNWidgets(3));
      expect(find.text('Trạng thái upload'), findsOneWidget);
      expect(find.text('Thời gian'), findsOneWidget);
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

      await tester.tap(find.text('Trạng thái upload'));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoActionSheet), findsOneWidget);
      // A real option set, not just the chip's own label back at it.
      expect(find.text('Chờ upload'), findsOneWidget);
      expect(find.text('Có lỗi tải'), findsOneWidget);
      expect(find.text('Đã tải xong'), findsOneWidget);

      await tester.tap(find.text('Có lỗi tải'));
      await tester.pumpAndSettle();

      // The backend's `upload_state` value goes out, and the chip now shows
      // the dimension plus the selection.
      expect(picked.single.uploadState, 'error');
      expect(picked.single.videoTypeId, isNull);
      expect(find.text('Trạng thái upload: Có lỗi tải'), findsOneWidget);
      expect(find.text('Trạng thái upload'), findsNothing);
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

      // Chip 'Trạng thái upload' dài hơn nhãn cũ nên hàng chip tràn ngang —
      // cuộn chip vào tầm nhìn trước khi bấm.
      await tester.ensureVisible(find.text('Thời gian'));
      await tester.tap(find.text('Thời gian'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hôm nay'));
      await tester.pumpAndSettle();

      final now = DateTime.now();
      expect(
        picked.single.fromTs,
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch,
      );
    });

    testWidgets('time chip bounds "Hôm qua" on both ends', (tester) async {
      final picked = <EcOrderFilters>[];
      await _pump(
        tester,
        EcHomeOrdersScreen(
          shopName: 'Shop ABC',
          orders: orders,
          onFiltersChanged: picked.add,
        ),
      );

      // Chip 'Trạng thái upload' dài hơn nhãn cũ nên hàng chip tràn ngang —
      // cuộn chip vào tầm nhìn trước khi bấm.
      await tester.ensureVisible(find.text('Thời gian'));
      await tester.tap(find.text('Thời gian'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hôm qua'));
      await tester.pumpAndSettle();

      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      final yesterday = midnight.subtract(const Duration(days: 1));
      expect(picked.single.fromTs, yesterday.millisecondsSinceEpoch);
      // Closed at the last millisecond of the day, not the next midnight: the
      // backend compares with `<=`, so an exclusive bound would leak today in.
      expect(picked.single.toTs, midnight.millisecondsSinceEpoch - 1);
    });

    testWidgets('backing out of the date picker leaves the filter alone', (
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

      // Chip 'Trạng thái upload' dài hơn nhãn cũ nên hàng chip tràn ngang —
      // cuộn chip vào tầm nhìn trước khi bấm.
      await tester.ensureVisible(find.text('Thời gian'));
      await tester.tap(find.text('Thời gian'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chọn ngày…'));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoDatePicker), findsOneWidget);

      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();

      // Cancelling must not half-apply an empty day window.
      expect(picked, isEmpty);
      expect(find.text('Thời gian'), findsOneWidget);
    });

    // Lọc theo ngày giờ do SERVER làm (cùng trục `created_at` với web), nên màn
    // này không được lọc lại lần nữa — lọc chồng sẽ giấu mất chính những đơn
    // server vừa trả về đúng, và làm app lại lệch với web thêm lần nữa.
    testWidgets('không lọc lại theo ngày ở máy — kể cả đơn chưa có clip', (
      tester,
    ) async {
      const rows = [
        EcOrderRow(
          code: 'TAO-HOM-NAY',
          time: '--:--',
          type: '—',
          videoCount: 0,
        ),
        EcOrderRow(
          code: 'DA-QUAY',
          time: '10:23',
          type: 'Đóng hàng',
          videoCount: 1,
          capturedAtMs: 1000,
        ),
      ];
      await _pump(
        tester,
        const EcHomeOrdersScreen(shopName: 'Shop ABC', orders: rows),
      );

      // Đơn chưa có clip trước đây bị ẩn khi có bộ lọc ngày vì không chứng minh
      // được nó thuộc ngày nào. Server đã trả nó về thì phải hiện.
      expect(find.text('TAO-HOM-NAY'), findsOneWidget);
      expect(find.text('DA-QUAY'), findsOneWidget);
    });

    testWidgets('picking a day filters to exactly that day', (tester) async {
      final picked = <EcOrderFilters>[];
      await _pump(
        tester,
        EcHomeOrdersScreen(
          shopName: 'Shop ABC',
          orders: orders,
          onFiltersChanged: picked.add,
        ),
      );

      // Chip 'Trạng thái upload' dài hơn nhãn cũ nên hàng chip tràn ngang —
      // cuộn chip vào tầm nhìn trước khi bấm.
      await tester.ensureVisible(find.text('Thời gian'));
      await tester.tap(find.text('Thời gian'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chọn ngày…'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xong'));
      await tester.pumpAndSettle();

      // The wheel opens on today, so confirming without scrolling picks today.
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      expect(picked.single.fromTs, midnight.millisecondsSinceEpoch);
      expect(
        picked.single.toTs,
        midnight.add(const Duration(days: 1)).millisecondsSinceEpoch - 1,
      );
      // The pill shows the chosen day rather than the generic prompt.
      expect(
        find.text('Thời gian: ${now.day}/${now.month}/${now.year}'),
        findsOneWidget,
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

      await tester.tap(find.text('Trạng thái upload'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chờ upload'));
      await tester.pumpAndSettle();

      expect(find.text('Shop chưa có đơn nào'), findsNothing);
      expect(find.text('Không tìm thấy đơn hàng'), findsOneWidget);
    });
  });
}

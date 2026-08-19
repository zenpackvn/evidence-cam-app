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
  /// Hàng thành viên: tên, EMAIL ngay dưới, và nhãn trạng thái nói đúng việc.
  ///
  /// Một cửa hàng có hai người trùng tên là chuyện thường, và tên hiển thị thì
  /// người dùng tự đặt — nên tên không phân biệt được ai với ai.
  group('hàng thành viên', () {
    testWidgets('email hiện ngay dưới tên', (tester) async {
      await _pump(
        tester,
        const EcShopDetailScreen(
          shopName: 'Shop ABC',
          platformLabel: 'Shopee',
          videoTypes: [],
          members: [
            EcShopMember(
              name: 'Trần Thị B',
              role: 'Nhân viên',
              email: 'b@shop.vn',
            ),
          ],
        ),
      );

      expect(find.text('Trần Thị B'), findsOneWidget);
      expect(find.text('b@shop.vn'), findsOneWidget);
    });

    // Lời mời chưa có tài khoản thì tên ĐÃ là địa chỉ đã mời. In lại lần nữa ở
    // dòng dưới là hai dòng nói cùng một điều.
    testWidgets('email trùng tên thì không in hai lần', (tester) async {
      await _pump(
        tester,
        const EcShopDetailScreen(
          shopName: 'Shop ABC',
          platformLabel: 'Shopee',
          videoTypes: [],
          members: [
            EcShopMember(name: 'moi@test.co', role: 'Nhân viên · chờ xác nhận'),
          ],
        ),
      );

      expect(find.text('moi@test.co'), findsOneWidget);
    });
  });

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

    // Một nút radio luôn sáng mà bấm không được trông như một lựa chọn, trong
    // khi shop chỉ có hai hạng và người được mời luôn là hạng dưới. Nói bằng
    // chữ, và tuyệt đối không nhắc tới vai trò đã bỏ.
    testWidgets('màn mời nói thẳng vai trò, không bày lựa chọn', (
      tester,
    ) async {
      await _pump(tester, const EcInviteMemberScreen());
      expect(find.textContaining('vai trò Nhân viên'), findsOneWidget);
      expect(find.textContaining('Quản lý'), findsNothing);
      // Không còn ô chọn nào để bấm.
      expect(find.byIcon(Icons.radio_button_checked), findsNothing);
      expect(find.byIcon(Icons.radio_button_off), findsNothing);
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
      await _pump(
        tester,
        EcChooseShopScreen(shops: shops, onAddShop: () {}),
      );
      expect(find.text('Chọn cửa hàng'), findsOneWidget);
      expect(find.text('Shop ABC'), findsOneWidget);
      expect(find.text('Shop XYZ'), findsOneWidget);
      // "Quản lý cửa hàng" đã dời vào bánh răng ở header trang Vận đơn; chỗ
      // này giờ là lối tạo shop duy nhất — nay là dấu cộng cạnh tiêu đề, nhãn
      // chữ chỉ còn trong Semantics.
      expect(find.text('Quản lý cửa hàng'), findsNothing);
      expect(find.text('Thêm cửa hàng mới'), findsNothing);
      expect(
        find.bySemanticsLabel('Thêm cửa hàng mới'),
        findsOneWidget,
      );
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
      await tester.tap(find.bySemanticsLabel('Thêm cửa hàng mới'));
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
      // Hàng "Lời mời vào shop sẽ hiện ở đây" đã bỏ: nó và "Tôi có lời mời"
      // cùng gọi một hàm nhận lời mời, nên hai hàng chỉ làm người mới tưởng
      // đây là hai việc khác nhau.
      expect(find.text('Lời mời vào shop sẽ hiện ở đây'), findsNothing);
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

  /// Hàng cài đặt: chữ "mặc định" và mũi tên đều phải chạm mép phải.
  ///
  /// Ba hàng này nằm cạnh nhau trong một thẻ — hai hàng cố định và một hàng mở
  /// sang màn Kho lưu trữ. Lệch nhau vài pixel là nhìn ra ngay, và trước đây
  /// chúng lệch thật: cả hai cột dùng `Flexible`, mà `Flexible` chỉ cho phép
  /// con nhỏ hơn phần được chia chứ không trả lại chỗ thừa — chỗ thừa rơi
  /// xuống cuối hàng nên thứ đứng cuối không bao giờ chạm mép.
  group('hàng cài đặt của chi tiết cửa hàng', () {
    testWidgets('"mặc định" và mũi tên cùng dồn sát mép phải', (tester) async {
      await _pump(
        tester,
        const EcShopDetailScreen(
          shopName: 'Shop ABC',
          platformLabel: 'Shopee',
          videoTypes: [],
          members: [],
          storageLabel: 'Cloud Zenpack',
          onTapStorage: _noop,
        ),
      );

      final defaults = find.text('mặc định');
      expect(defaults, findsWidgets, reason: 'không còn hàng cố định nào');
      final arrow = find.byIcon(LucideIcons.chevronRight);

      // Mọi hàng cố định phải kết thúc ở cùng một đường dọc.
      final rights = <double>{
        for (var i = 0; i < defaults.evaluate().length; i++)
          tester.getRect(defaults.at(i)).right,
      };
      expect(rights.length, 1, reason: 'các chữ "mặc định" lệch nhau: $rights');

      // Và mũi tên của hàng Kho lưu trữ kết thúc đúng ở đường đó.
      final arrowRight = tester.getRect(arrow.first).right;
      expect(
        (arrowRight - rights.first).abs() < 0.5,
        isTrue,
        reason:
            'mũi tên lệch khỏi mép của "mặc định": '
            '$arrowRight vs ${rights.first}',
      );
    });
  });

  /// Nhân viên ĐỌC được mọi thứ trên màn này, nhưng không có lối vào thao tác
  /// nào cả. Một cái nút bấm không ăn thì người dùng bấm đi bấm lại rồi kết
  /// luận app hỏng, chứ không đoán ra là mình thiếu quyền.
  group('chi tiết cửa hàng ở chế độ nhân viên', () {
    testWidgets('không có mũi tên ở hàng Kho lưu trữ', (tester) async {
      Future<void> pumpAs({required bool readOnly}) => _pump(
        tester,
        EcShopDetailScreen(
          shopName: 'Shop ABC',
          platformLabel: 'Shopee',
          videoTypes: const [],
          members: const [],
          readOnly: readOnly,
          storageLabel: 'Google Drive',
          onTapStorage: _noop,
        ),
      );

      await pumpAs(readOnly: false);
      // Chủ shop: đúng một mũi tên, của hàng Kho lưu trữ.
      expect(find.byIcon(LucideIcons.chevronRight), findsOneWidget);

      await pumpAs(readOnly: true);
      expect(find.byIcon(LucideIcons.chevronRight), findsNothing);
      // Tên kho vẫn đọc được — đó là thứ người đứng máy cần biết giữa ca.
      expect(find.text('Google Drive'), findsOneWidget);
    });

    // Tên kho nằm ở DÒNG DƯỚI nhãn, không dồn phải cùng dòng: nó là giá trị dài
    // nhất trong ba hàng cài đặt ("Kho đám mây riêng (chuẩn S3)"), và nhét
    // chung một dòng thì hoặc nhãn hoặc giá trị phải cắt ba chấm.
    testWidgets('tên kho nằm dưới chữ "Kho lưu trữ"', (tester) async {
      await _pump(
        tester,
        EcShopDetailScreen(
          shopName: 'Shop ABC',
          platformLabel: 'Shopee',
          videoTypes: const [],
          members: const [],
          storageLabel: 'Kho đám mây riêng (chuẩn S3)',
          onTapStorage: _noop,
        ),
      );

      final label = tester.getRect(find.text('Kho lưu trữ'));
      final value = tester.getRect(find.text('Kho đám mây riêng (chuẩn S3)'));
      expect(
        value.top,
        greaterThan(label.bottom - 1),
        reason: 'tên kho vẫn nằm cùng dòng với nhãn: $label / $value',
      );
      // Và nó bắt đầu thẳng hàng với nhãn, không thụt vào.
      expect(
        (value.left - label.left).abs() < 0.5,
        isTrue,
        reason: 'tên kho lệch trái so với nhãn',
      );
    });

    // Thêm loại video mở cho MỌI vai trò, khác các nút quản trị khác. Người
    // đứng máy là người phát hiện ra thiếu loại — giữa ca, lúc trên tay đang là
    // một đơn không biết xếp vào đâu.
    testWidgets('vẫn thêm được loại video', (tester) async {
      var added = 0;
      await _pump(
        tester,
        EcShopDetailScreen(
          shopName: 'Shop ABC',
          platformLabel: 'Shopee',
          videoTypes: const [],
          members: const [],
          readOnly: true,
          onAddType: () => added++,
        ),
      );

      final add = find.text('Thêm loại (nhập tên)');
      expect(add, findsOneWidget, reason: 'nhân viên không thấy nút thêm loại');
      await tester.tap(add);
      await tester.pumpAndSettle();
      expect(added, 1);
    });

    // Nhân viên không gọi được danh sách thành viên (máy chủ chặn ở
    // `requireOwner`), nên tên chủ shop dưới tên cửa hàng là chỗ DUY NHẤT họ
    // biết mình đang làm cho ai.
    testWidgets('thấy tên chủ shop, chỉ đọc', (tester) async {
      await _pump(
        tester,
        const EcShopDetailScreen(
          shopName: 'Shop ABC',
          platformLabel: 'Shopee',
          videoTypes: [],
          members: [],
          readOnly: true,
          ownerName: 'Chị Hoa',
          ownerEmail: 'hoa@shop.vn',
        ),
      );

      // Ba thứ: chức vụ, tên, email. Chức vụ nằm trong chính câu "Chủ shop:".
      expect(find.textContaining('Chủ shop'), findsOneWidget);
      expect(find.textContaining('Chị Hoa'), findsOneWidget);
      expect(find.text('hoa@shop.vn'), findsOneWidget);
    });

    // Chủ shop cũng thấy khối đó — không phải thứ chỉ dành cho nhân viên.
    testWidgets('chủ shop cũng thấy khối thông tin đó', (tester) async {
      await _pump(
        tester,
        const EcShopDetailScreen(
          shopName: 'Shop ABC',
          platformLabel: 'Shopee',
          videoTypes: [],
          members: [],
          ownerName: 'Chị Hoa',
          ownerEmail: 'hoa@shop.vn',
        ),
      );

      expect(find.textContaining('Chị Hoa'), findsOneWidget);
      expect(find.text('hoa@shop.vn'), findsOneWidget);
    });

    testWidgets('loại video không có nút sửa, xoá hay ổ khoá', (tester) async {
      const types = [
        EcVideoType(id: 't1', name: 'Đóng hàng', locked: true),
        EcVideoType(id: 't2', name: 'Trả hàng'),
      ];
      Future<void> pumpAs({required bool readOnly}) => _pump(
        tester,
        EcShopDetailScreen(
          shopName: 'Shop ABC',
          platformLabel: 'Shopee',
          videoTypes: types,
          members: const [],
          readOnly: readOnly,
          onEditType: (_) {},
          onDeleteType: (_) {},
        ),
      );

      await pumpAs(readOnly: false);
      expect(find.byIcon(LucideIcons.pencil), findsOneWidget);
      expect(find.byIcon(LucideIcons.trash2), findsOneWidget);
      expect(find.byIcon(LucideIcons.lock), findsOneWidget);

      await pumpAs(readOnly: true);
      expect(find.byIcon(LucideIcons.pencil), findsNothing);
      expect(find.byIcon(LucideIcons.trash2), findsNothing);
      // Ổ khoá đi theo: nó trả lời "vì sao hàng này không sửa được", câu chỉ có
      // nghĩa với người sửa được những hàng khác.
      expect(find.byIcon(LucideIcons.lock), findsNothing);
      // Tên loại vẫn đọc được.
      expect(find.text('Đóng hàng'), findsOneWidget);
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

    // Sửa tên shop là đặc quyền của chủ shop: nhân viên nhìn thấy tên mới,
    // nhưng không có lối để đổi nó.
    testWidgets('chỉ chủ shop mới thấy bút sửa tên', (tester) async {
      var renamed = 0;
      await _pump(
        tester,
        EcShopDetailScreen(
          shopName: 'Shop ABC',
          platformLabel: 'Shopee',
          members: members,
          videoTypes: videoTypes,
          onRenameShop: () => renamed++,
        ),
      );

      // Bút của TÊN SHOP, không phải bút sửa loại video — cùng icon, khác
      // việc, nên phải neo vào đúng thẻ chứa tên.
      final pencil = find.descendant(
        of: find.ancestor(
          of: find.text('Shop ABC'),
          matching: find.byType(PenCard),
        ),
        matching: find.byIcon(LucideIcons.pencil),
      );
      expect(pencil, findsOneWidget);
      await tester.tap(pencil);
      await tester.pump();
      expect(renamed, 1);

      await _pump(
        tester,
        EcShopDetailScreen(
          readOnly: true,
          shopName: 'Shop ABC',
          platformLabel: 'Shopee',
          members: members,
          videoTypes: videoTypes,
          onRenameShop: () => renamed++,
        ),
      );
      expect(
        find.descendant(
          of: find.ancestor(
            of: find.text('Shop ABC'),
            matching: find.byType(PenCard),
          ),
          matching: find.byIcon(LucideIcons.pencil),
        ),
        findsNothing,
      );
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
      // "Độ phân giải quay" KHÔNG còn ở đây — nó đổi ngay trên thanh dưới màn
      // quay. Test ngay dưới đã chốt điều đó; giữ assertion cũ ở đây là hai
      // test cùng file đòi hai điều ngược nhau.
      expect(find.text('Đóng hàng'), findsOneWidget);
      expect(find.text('Cân hàng'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'hàng thời lượng hiện trần đang áp dụng, không nhắc dung lượng',
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
            clipBudget: ClipBudget(seconds: 300, planMaxSeconds: 300),
          ),
        );
        // Nhãn là `shopDetailClipLength` = "Thời lượng video" (không có gạch
        // chéo) — `shopDetailClipDuration` cũ đã không còn ai dùng.
        expect(find.text('Thời lượng video'), findsOneWidget);
        expect(find.text('5 phút'), findsOneWidget);
        // Mức đề xuất và cảnh báo vượt sàn đã bỏ. Trần MỘT TỆP ảnh thì còn:
        // nó không phải quota (quota tính theo số video) mà là chặn để ảnh máy
        // ảnh 40MB không đi qua đường đính kèm.
        expect(find.textContaining('Đề xuất'), findsNothing);
        expect(find.textContaining('Vượt mức đề xuất'), findsNothing);
        expect(find.text('Dung lượng ảnh'), findsOneWidget);
        expect(find.text('5 MB'), findsOneWidget);
        // Trần dung lượng theo GÓI thì đã bỏ hẳn.
        expect(find.text('Dung lượng/tệp'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

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
      expect(find.text('5 MB'), findsOneWidget);
      // Không đếm số chữ "mặc định": `_FixedSettingRow` nay còn dựng cả hàng
      // Kho lưu trữ, nên đếm là mỗi lần thêm một hàng lại phải sửa test mà
      // chẳng canh được gì thêm.
      expect(find.text('mặc định'), findsWidgets);
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
      // Màn dài hơn từ khi có hàng Kho lưu trữ — phải kéo tới nơi rồi mới
      // chạm được.
      await tester.ensureVisible(find.byIcon(LucideIcons.pencil));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(LucideIcons.pencil));
      await tester.pump();
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

      // Vẫn báo lên trên để cha truy vấn lại…
      expect(searches, ['ZZZ']);
      // …VÀ lọc theo mã ngay tại máy. `EcApi.orders()` không gửi tham số `q`
      // (tìm kiếm là `searchOrders`, một đường riêng), nên tin hẳn vào server
      // là gõ một mã xong vẫn thấy nguyên danh sách cũ.
      expect(find.text('SPXVN024567890'), findsNothing);
      expect(find.text('SPXVN044556677'), findsNothing);
    });

    testWidgets('the three filter chips start unfiltered', (tester) async {
      await _pump(
        tester,
        const EcHomeOrdersScreen(shopName: 'Shop ABC', orders: orders),
      );
      // Khung F2-01 mới: cả ba chip đều là dropdown, và khi chưa lọc chip chỉ
      // hiện tên chiều lọc chứ không phải giá trị "tất cả" của nó.
      expect(find.byIcon(LucideIcons.chevronDown), findsNWidgets(3));
      expect(find.text('Trạng thái'), findsOneWidget);
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

      await tester.tap(find.text('Trạng thái'));
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
      expect(find.text('Trạng thái: Có lỗi tải'), findsOneWidget);
      expect(find.text('Trạng thái'), findsNothing);
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

      // Chip 'Trạng thái' nằm trong hàng chip có thể tràn ngang —
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

      // Chip 'Trạng thái' nằm trong hàng chip có thể tràn ngang —
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

      // Chip 'Trạng thái' nằm trong hàng chip có thể tràn ngang —
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

      // Chip 'Trạng thái' nằm trong hàng chip có thể tràn ngang —
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

      await tester.tap(find.text('Trạng thái'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chờ upload'));
      await tester.pumpAndSettle();

      expect(find.text('Shop chưa có đơn nào'), findsNothing);
      expect(find.text('Không tìm thấy đơn hàng'), findsOneWidget);
    });
  });
}

void _noop() {}

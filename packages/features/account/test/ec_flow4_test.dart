import 'package:app_ui/app_ui.dart';
import 'package:feature_account/feature_account.dart';
import 'package:flutter/cupertino.dart' show CupertinoTextField;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget screen) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: screen));
}

void main() {
  group('EcAccountTabScreen', () {
    testWidgets('shows profile, both setting groups and bottom nav', (
      tester,
    ) async {
      await _pump(tester, const EcAccountTabScreen());
      expect(find.text('Shop ABC'), findsOneWidget);
      expect(find.text('Nguyễn Văn A'), findsOneWidget);
      expect(find.text('nguyenvana@gmail.com'), findsOneWidget);
      expect(find.text('GÓI & ỨNG DỤNG'), findsOneWidget);
      expect(find.text('Gói cước & Quota'), findsOneWidget);
      expect(find.text('Pro 500'), findsOneWidget);
      expect(find.text('Ngôn ngữ'), findsOneWidget);
      expect(find.text('BẢO MẬT & ĐĂNG NHẬP'), findsOneWidget);
      expect(find.text('Đổi mật khẩu'), findsOneWidget);
      expect(find.text('Phương thức đăng nhập'), findsOneWidget);
      expect(find.text('3 liên kết'), findsOneWidget);
      expect(find.text('Đăng xuất'), findsOneWidget);
      expect(find.text('Xóa tài khoản'), findsOneWidget);
      expect(find.text('Đơn hàng'), findsOneWidget);
      expect(find.text('Ghi hình'), findsOneWidget);
      expect(find.text('Tài khoản'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('quota row fires its callback', (tester) async {
      var tapped = false;
      await _pump(
        tester,
        EcAccountTabScreen(onQuotaTap: () => tapped = true),
      );
      await tester.tap(find.text('Gói cước & Quota'));
      expect(tapped, isTrue);
    });
  });

  group('EcEditProfileScreen', () {
    testWidgets('shows header, fields and locked email', (tester) async {
      await _pump(tester, const EcEditProfileScreen());
      expect(find.text('Thông tin tài khoản'), findsOneWidget);
      expect(find.text('Đổi ảnh đại diện'), findsOneWidget);
      expect(find.text('Họ tên'), findsOneWidget);
      expect(find.text('Số điện thoại'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('nguyenvana@gmail.com'), findsOneWidget);
      expect(find.text('Lưu thay đổi'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('save button fires callback', (tester) async {
      var saved = false;
      await _pump(tester, EcEditProfileScreen(onSave: () => saved = true));
      await tester.enterText(
        find.byType(CupertinoTextField).first,
        'Nguyễn Văn A',
      );
      await tester.pump();
      await tester.tap(find.text('Lưu thay đổi'));
      expect(saved, isTrue);
    });
  });

  group('EcLanguageScreen', () {
    testWidgets('shows both language options with VI selected', (
      tester,
    ) async {
      await _pump(tester, const EcLanguageScreen());
      expect(find.text('Ngôn ngữ'), findsOneWidget);
      expect(find.text('Tiếng Việt'), findsOneWidget);
      expect(find.text('Vietnamese'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Tiếng Anh'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping English fires onSelect with EcAppLanguage.en', (
      tester,
    ) async {
      EcAppLanguage? picked;
      await _pump(
        tester,
        EcLanguageScreen(onSelect: (lang) => picked = lang),
      );
      await tester.tap(find.text('English'));
      expect(picked, EcAppLanguage.en);
    });
  });

  group('EcQuotaScreen', () {
    testWidgets('shows plan, quota usage and retention', (tester) async {
      await _pump(tester, const EcQuotaScreen());
      expect(find.text('Báo cáo & Quota'), findsOneWidget);
      expect(find.text('Gói hiện tại'), findsOneWidget);
      expect(find.text('Pro 500 (P1)'), findsOneWidget);
      expect(find.text('263 / 500 video'), findsOneWidget);
      expect(find.text('Đã dùng 52%'), findsOneWidget);
      expect(find.text('Lưu trữ'), findsOneWidget);
      expect(find.text('45 / 90 ngày'), findsOneWidget);
      expect(find.text('Nâng cấp gói'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('upgrade button fires callback', (tester) async {
      var upgraded = false;
      await _pump(tester, EcQuotaScreen(onUpgrade: () => upgraded = true));
      await tester.tap(find.text('Nâng cấp gói'));
      expect(upgraded, isTrue);
    });
  });

  group('EcDeleteAccountScreen', () {
    testWidgets('step 1 shows warning and note', (tester) async {
      await _pump(tester, const EcDeleteAccountScreen());
      expect(find.text('Xóa tài khoản?'), findsOneWidget);
      expect(find.textContaining('hồ sơ "đã gửi sàn"'), findsOneWidget);
      expect(find.text('Hủy'), findsOneWidget);
      expect(find.text('Xóa vĩnh viễn'), findsOneWidget);
      expect(find.textContaining('Bước 1/2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('confirming step 1 then step 2 fires onConfirmDelete', (
      tester,
    ) async {
      var deleted = false;
      await _pump(
        tester,
        EcDeleteAccountScreen(onConfirmDelete: () => deleted = true),
      );
      await tester.tap(find.text('Xóa vĩnh viễn'));
      await tester.pumpAndSettle();
      expect(find.text('Xác nhận xóa vĩnh viễn?'), findsOneWidget);
      expect(deleted, isFalse);

      await tester.tap(find.text('Xóa vĩnh viễn'));
      await tester.pumpAndSettle();
      expect(deleted, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('cancel on step 1 fires onCancel', (tester) async {
      var cancelled = false;
      await _pump(
        tester,
        EcDeleteAccountScreen(onCancel: () => cancelled = true),
      );
      await tester.tap(find.text('Hủy'));
      expect(cancelled, isTrue);
    });
  });

  group('EcChangePasswordScreen', () {
    testWidgets('change mode shows all three fields', (tester) async {
      await _pump(tester, const EcChangePasswordScreen());
      expect(find.text('Đổi mật khẩu'), findsOneWidget);
      expect(find.text('Mật khẩu hiện tại'), findsOneWidget);
      expect(find.text('Mật khẩu mới'), findsOneWidget);
      expect(find.text('Nhập lại mật khẩu mới'), findsOneWidget);
      expect(find.text('Lưu mật khẩu'), findsOneWidget);
      expect(
        find.text('(Đổi xong sẽ đăng xuất khỏi các thiết bị khác)'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('create mode hides current password field', (tester) async {
      await _pump(
        tester,
        const EcChangePasswordScreen(hasExistingPassword: false),
      );
      expect(find.text('Tạo mật khẩu'), findsWidgets);
      expect(find.text('Mật khẩu hiện tại'), findsNothing);
      expect(find.text('Mật khẩu mới'), findsOneWidget);
      expect(find.text('Nhập lại mật khẩu mới'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('save button fires callback', (tester) async {
      var saved = false;
      final newPassword = TextEditingController();
      await _pump(
        tester,
        EcChangePasswordScreen(
          newPasswordController: newPassword,
          onSave: () => saved = true,
        ),
      );
      final fields = find.byType(CupertinoTextField);
      await tester.enterText(fields.at(0), 'matkhaucu1');
      await tester.enterText(fields.at(1), 'matkhaumoi1');
      await tester.enterText(fields.at(2), 'matkhaumoi1');
      await tester.pump();
      await tester.tap(find.text('Lưu mật khẩu'));
      expect(saved, isTrue);
    });
  });
}

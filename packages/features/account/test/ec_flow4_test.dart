import 'package:app_ui/app_ui.dart';
import 'package:ec_ui/ec_ui.dart';
import 'package:feature_account/feature_account.dart';
import 'package:flutter/cupertino.dart' show CupertinoTextField;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
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
  group('EcAccountTabScreen', () {
    testWidgets('shows profile and both setting groups', (tester) async {
      await _pump(tester, const EcAccountTabScreen());
      // Không có tên shop ở đây: màn này đứng ngoài lớp shop, mở từ màn Chọn
      // cửa hàng.
      expect(find.text('Shop ABC'), findsNothing);
      expect(find.text('Nguyễn Văn A'), findsOneWidget);
      expect(find.text('nguyenvana@gmail.com'), findsOneWidget);
      expect(find.text('GÓI & ỨNG DỤNG'), findsOneWidget);
      expect(find.text('Gói cước & Quota'), findsOneWidget);
      expect(find.text('Cơ bản'), findsOneWidget);
      expect(find.text('Ngôn ngữ'), findsOneWidget);
      expect(find.text('BẢO MẬT & ĐĂNG NHẬP'), findsOneWidget);
      expect(find.text('Đổi mật khẩu'), findsOneWidget);
      expect(find.text('Phương thức đăng nhập'), findsOneWidget);
      expect(find.text('3 liên kết'), findsOneWidget);
      expect(find.text('Đăng xuất'), findsOneWidget);
      expect(find.text('Xóa tài khoản'), findsOneWidget);
      // Không còn thanh tab: màn này rời khỏi shell để nhường ô thứ ba cho Hồ
      // sơ khiếu nại, và nay được ĐẨY từ màn Chọn cửa hàng.
      expect(find.text('Ghi hình'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('opens on the brand banner and closes with the footer', (
      tester,
    ) async {
      await _pump(tester, const EcAccountTabScreen(appVersion: '2.3.4'));
      expect(find.byType(PenBrandBanner), findsOneWidget);
      await tester.scrollUntilVisible(find.text('ZenPack'), 200);
      expect(find.text('Phiên bản 2.3.4'), findsOneWidget);
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
      expect(find.text('Số điện thoại (tùy chọn)'), findsOneWidget);
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
      // Each row is titled in its own language and subtitled in the current
      // one, so under `vi` the Vietnamese row reads "Tiếng Việt" twice.
      expect(find.text('Tiếng Việt'), findsNWidgets(2));
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Tiếng Anh'), findsOneWidget);
      expect(find.byIcon(LucideIcons.check), findsOneWidget);
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
      // Bản 3 (2026-08-07): trục hạn mức là SỐ VIDEO mỗi tháng, không phải
      // dung lượng — mọi trần byte đã bỏ cùng lượt với quota theo dung lượng.
      await _pump(
        tester,
        const EcQuotaScreen(
          planLabel: 'Tiết kiệm',
          usedVideos: 200,
          capVideos: 1000,
          retentionTotalDays: 90,
        ),
      );
      expect(find.text('Báo cáo & Quota'), findsOneWidget);
      expect(find.text('Gói hiện tại'), findsOneWidget);
      expect(find.text('Tiết kiệm'), findsOneWidget);
      // Còn lại / trần, và phần trăm đã dùng khớp với hai số đó.
      expect(find.text('800 / 1.000'), findsOneWidget);
      expect(find.text('Đã dùng 20%'), findsOneWidget);
      expect(find.text('Lưu trữ'), findsOneWidget);
      expect(find.text('90 ngày'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // App KHÔNG bán gói nữa — mua ở web. Màn này chỉ trả lời "tôi đang ở gói
    // nào, còn bao nhiêu". Ba test cũ canh nút "Nâng cấp gói", pill "Nâng cấp"
    // và dòng "chỉ chủ tài khoản mới đổi được gói" đã bỏ cùng chúng.
    testWidgets('không còn đường mua gói nào trên màn này', (tester) async {
      await _pump(tester, const EcQuotaScreen());
      expect(find.text('Nâng cấp gói'), findsNothing);
      expect(find.text('Nâng cấp'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('nhân viên cũng thấy đúng màn đó, không thiếu không thừa', (
      tester,
    ) async {
      await _pump(tester, const EcQuotaScreen(canManagePlan: false));
      expect(find.text('Nâng cấp gói'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('EcDeleteAccountScreen', () {
    testWidgets('step 1 shows warning and note', (tester) async {
      await _pump(tester, const EcDeleteAccountScreen());
      expect(find.text('Xóa tài khoản?'), findsOneWidget);
      // Copy comes from the ARB: the dossier "đã gửi sàn" state was cut on
      // 2026-07-28 (a dossier is only đang mở / đã thu hồi now). Matched on
      // the tail, which is unique to the screen's warning — the toast opens
      // with the same "hồ sơ khiếu nại đang mở" phrase.
      expect(
        find.textContaining('link chia sẻ sẽ ngừng hoạt động'),
        findsOneWidget,
      );
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

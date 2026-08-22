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

/// Chữ của chrome lấy TỪ ĐIỂN, không ghim — xem lý do ở `ec_flow3_test.dart`.
late AppLocalizations vi;

void main() {
  setUpAll(() async {
    vi = await AppLocalizations.delegate.load(const Locale('vi'));
  });

  group('EcAccountTabScreen', () {
    testWidgets('shows profile and both setting groups', (tester) async {
      await _pump(
        tester,
        const EcAccountTabScreen(
          userName: 'Nguyễn Văn A',
          userEmail: 'nguyenvana@gmail.com',
        ),
      );
      // Không có tên shop ở đây: màn này đứng ngoài lớp shop, mở từ màn Chọn
      // cửa hàng.
      expect(find.text('Shop ABC'), findsNothing);
      expect(find.text('Nguyễn Văn A'), findsOneWidget);
      expect(find.text('nguyenvana@gmail.com'), findsOneWidget);
      expect(find.text('GÓI & ỨNG DỤNG'), findsOneWidget);
      // Tên gói hiện NGAY ở hàng này. App bán gói trở lại (IAP), nên "đang
      // dùng gói nào" là thứ phải đọc được mà không cần mở màn nào khác.
      expect(find.text(vi.accountPlanQuota), findsOneWidget);
      expect(find.text('Cơ bản'), findsOneWidget);
      // Không có callback → không có hàng "Đổi gói": build thiếu khoá cửa hàng
      // thì thà không có nút còn hơn nút bấm vào không mở được gì.
      expect(find.text(vi.accountChangePlan), findsNothing);
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
      await _pump(
        tester,
        const EcAccountTabScreen(
          userName: 'Nguyễn Văn A',
          userEmail: 'nguyenvana@gmail.com',
          appVersion: '2.3.4',
        ),
      );
      expect(find.byType(PenBrandBanner), findsOneWidget);
      await tester.scrollUntilVisible(find.text('ZenPack'), 200);
      expect(find.text('Phiên bản 2.3.4'), findsOneWidget);
    });

    testWidgets('quota row fires its callback', (tester) async {
      var tapped = false;
      await _pump(
        tester,
        EcAccountTabScreen(
          userName: 'Nguyễn Văn A',
          userEmail: 'nguyenvana@gmail.com',
          onQuotaTap: () => tapped = true,
        ),
      );
      await tester.tap(find.text(vi.accountPlanQuota));
      expect(tapped, isTrue);
    });

    testWidgets('change-plan row opens the paywall when it is available', (
      tester,
    ) async {
      var opened = false;
      await _pump(
        tester,
        EcAccountTabScreen(
          userName: 'Nguyễn Văn A',
          userEmail: 'nguyenvana@gmail.com',
          onChangePlanTap: () => opened = true,
        ),
      );
      await tester.tap(find.text(vi.accountChangePlan));
      expect(opened, isTrue);
    });
  });

  group('EcEditProfileScreen', () {
    testWidgets('shows header, fields and locked email', (tester) async {
      await _pump(
        tester,
        const EcEditProfileScreen(email: 'nguyenvana@gmail.com'),
      );
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
      await _pump(
        tester,
        EcEditProfileScreen(
          email: 'nguyenvana@gmail.com',
          onSave: () => saved = true,
        ),
      );
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
      // Mỗi hàng gọi tên ngôn ngữ đó bằng CHÍNH nó, phụ đề là tên tiếng Anh:
      // "Tiếng Việt / Vietnamese". Không dịch sang ngôn ngữ đang dùng — mười
      // thứ tiếng thì cách đó cần một trăm bản dịch, và người đi tìm tiếng của
      // mình vẫn tìm theo tên bản xứ.
      expect(find.text(vi.languageNameVietnamese), findsOneWidget);
      expect(find.text('Vietnamese'), findsOneWidget);
      // Hàng English chỉ có MỘT dòng: tên bản xứ và tên tiếng Anh trùng nhau,
      // in hai lần thì dòng dưới không nói thêm được gì.
      expect(find.text('English'), findsOneWidget);
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
      // Nhãn "Gói hiện tại" đã bỏ — tên gói tự nói lên nó là gói nào.
      expect(find.text('Gói hiện tại'), findsNothing);
      expect(find.text('Tiết kiệm'), findsOneWidget);
      // Còn lại, rồi tỉ số đã dùng / trần kèm phần trăm khớp với hai số đó.
      expect(find.text('800 còn lại'), findsOneWidget);
      expect(find.text('Đã dùng 200 / 1.000 · 20%'), findsOneWidget);
      expect(find.text('Lưu trữ'), findsOneWidget);
      expect(find.text('90 ngày'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // App KHÔNG bán gói nữa — mua ở web. Màn này chỉ trả lời "tôi đang ở gói
    // nào, còn bao nhiêu". Ba test cũ canh nút "Nâng cấp gói", pill "Nâng cấp"
    // và dòng "chỉ chủ tài khoản mới đổi được gói" đã bỏ cùng chúng.
    // Mặc định (build không có khoá RevenueCat → `onUpgrade` null) thì màn này
    // KHÔNG được có lối mua nào. Đây vẫn là hàng rào Guideline 3.1: khi không
    // bán được bằng IAP thì cũng không được chỉ đường đi mua chỗ khác.
    testWidgets('không có khoá cửa hàng thì không có đường mua nào', (
      tester,
    ) async {
      await _pump(tester, const EcQuotaScreen());
      expect(find.text('Nâng cấp gói'), findsNothing);
      expect(find.text('Nâng cấp'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    // Có khoá cửa hàng → nút mua hiện, và bấm vào phải gọi đúng callback mở
    // paywall IAP. Không có test này thì `onUpgrade` có thể bị rơi ở một trong
    // ba chặng truyền tham số mà không ai biết — nút vẫn hiện, bấm không làm gì.
    testWidgets('có cửa hàng: chủ shop thấy nút và bấm được', (tester) async {
      var opened = 0;
      await _pump(
        tester,
        EcQuotaScreen(onUpgrade: () => opened++),
      );
      await tester.tap(find.text('Nâng cấp gói'));
      await tester.pump();
      expect(opened, 1);
    });

    // Ai cũng mua được. Lý do ghi ở bản test trước — "gói lại cộng cho chủ
    // shop" — là SAI: `applyRevenueCatEvent` cấp theo `app_user_id`, tức uid
    // của chính người bấm mua. Nên nhân viên mua thì nâng tài khoản của họ.
    testWidgets('nhân viên cũng thấy nút mua', (tester) async {
      await _pump(
        tester,
        EcQuotaScreen(canManagePlan: false, onUpgrade: () {}),
      );
      expect(find.text('Nâng cấp gói'), findsOneWidget);
    });

    testWidgets('hết hạn mức, không cửa hàng: báo trạng thái, không lối mua', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcQuotaScreen(
          usedVideos: 1101,
          capVideos: 1000,
          blockAtVideos: 1100,
          blocked: true,
        ),
      );
      expect(find.text('Đã hết hạn mức video'), findsWidgets);
      expect(find.text('Nâng cấp'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    // Trục tính tiền là SỐ LƯỢNG video, không phải dung lượng (mục 6.3).
    testWidgets('nhân viên cũng thấy đúng màn đó, không thiếu không thừa', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcQuotaScreen(
          usedVideos: 200,
          capVideos: 1000,
          blockAtVideos: 1100,
        ),
      );
      // Con số đi qua `_vi()` nên có dấu nhóm nghìn kiểu Việt.
      expect(find.text('Đã dùng 200 / 1.000 · 20%'), findsOneWidget);
      expect(find.text('Chặn quay mới từ 1100 video'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // Nhân viên không sửa được gói. Khi bị chặn thì phải biết đi hỏi ai —
    // KHÔNG phải được chỉ đường sang trang thanh toán.
    testWidgets('nhân viên bị chặn: được chỉ đi hỏi chủ tài khoản', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcQuotaScreen(
          usedVideos: 1101,
          capVideos: 1000,
          blockAtVideos: 1100,
          blocked: true,
          canManagePlan: false,
        ),
      );
      expect(find.text('Nâng cấp gói'), findsNothing);
      // Câu này phải nói CẢ hai vế: hạn mức cửa hàng do chủ quyết, và gói tự
      // mua chỉ là của tài khoản mình. Thiếu vế sau thì người đang tắc sẽ bấm
      // mua để gỡ tắc, trả tiền xong vẫn tắc y nguyên.
      expect(
        find.textContaining('chỉ áp cho tài khoản của chính bạn'),
        findsOneWidget,
      );
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
      // Câu này đã bỏ CẶP NGOẶC ĐƠN. Lấy từ từ điển thì lần sau sửa chữ không
      // làm đỏ test nữa, mà vẫn đỏ thật nếu màn gọi nhầm khoá.
      expect(find.text(vi.passwordChangeLogoutNote), findsOneWidget);
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

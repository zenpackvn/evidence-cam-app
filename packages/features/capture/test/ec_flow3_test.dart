import 'package:app_ui/app_ui.dart';
import 'package:ec_ui/ec_ui.dart';
import 'package:feature_capture/feature_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';

Future<void> _pump(WidgetTester tester, Widget screen) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    MaterialApp(
      locale: const Locale('vi'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(),
      home: screen,
    ),
  );
}

/// Assert on the tab bar itself rather than its labels: the design titles the
/// recording screens "Ghi hình", which is also a tab label.
void _expectCameraBottomTabsHidden() {
  expect(find.byType(PenTabBar), findsNothing);
  expect(find.text('Vận đơn'), findsNothing);
  expect(find.text('Tài khoản'), findsNothing);
}

void main() {
  group('EcWaitBill2Screen', () {
    testWidgets('shows idle hint, upload chip and camera rail', (
      tester,
    ) async {
      await _pump(
        tester,
        EcWaitBill2Screen(
          onResolution: () {},
          onManualEntry: () {},
        ),
      );
      // The camera header is back button + upload chip only — no shop title.
      expect(find.text('Shop ABC'), findsNothing);
      expect(find.text('3'), findsOneWidget);
      // Hai dòng gợi ý lấy nguyên văn khung F3-01 (CenterHint > T và S).
      expect(find.text('Quét mã vận đơn'), findsOneWidget);
      expect(find.text('Đưa bill vào khung'), findsOneWidget);
      expect(find.text('Đóng hàng'), findsOneWidget);
      expect(find.text('1x'), findsOneWidget);
      expect(find.text('720p'), findsOneWidget);
      expect(find.byIcon(LucideIcons.keyboard), findsOneWidget);
      // Idle — no stop button yet.
      expect(find.byIcon(LucideIcons.check), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping the upload chip fires onQueueTap', (tester) async {
      var taps = 0;
      await _pump(tester, EcWaitBill2Screen(onQueueTap: () => taps++));
      await tester.tap(find.byIcon(LucideIcons.cloudUpload));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('hides the bottom tab bar while inside camera screens', (
      tester,
    ) async {
      await _pump(tester, const EcWaitBill2Screen());
      _expectCameraBottomTabsHidden();

      await _pump(tester, const EcRecording2Screen());
      _expectCameraBottomTabsHidden();

      await _pump(tester, const EcNearLimitScreen());
      _expectCameraBottomTabsHidden();

      await _pump(tester, const EcReturnRecScreen());
      _expectCameraBottomTabsHidden();

      await _pump(tester, const EcCutoverBScreen());
      _expectCameraBottomTabsHidden();
      expect(tester.takeException(), isNull);
    });

    testWidgets('back and type chip callbacks fire', (tester) async {
      var backTapped = false;
      var typeTapped = false;
      await _pump(
        tester,
        EcWaitBill2Screen(
          onBack: () => backTapped = true,
          onPickType: () => typeTapped = true,
        ),
      );
      await tester.tap(find.byIcon(LucideIcons.chevronLeft));
      await tester.tap(find.text('Đóng hàng'));
      expect(backTapped, isTrue);
      expect(typeTapped, isTrue);
    });
  });

  group('EcRecording2Screen', () {
    testWidgets('shows mã vận đơn and REC dot', (tester) async {
      await _pump(tester, const EcRecording2Screen());
      expect(find.text('SPXVN024567890'), findsOneWidget);
      expect(find.text('REC'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('stop button fires onStop', (tester) async {
      var stopped = false;
      await _pump(
        tester,
        EcRecording2Screen(onStop: () => stopped = true),
      );
      await tester.tap(find.byTooltip('Dừng quay'));
      expect(stopped, isTrue);
    });
  });

  group('EcCutoverBScreen', () {
    testWidgets('shows closed order A summary and new order B badge', (
      tester,
    ) async {
      // queueCount lệch 3 có chủ ý: chip hàng đợi cũng hiện một con số, để mặc
      // định thì `find.text('3')` không phân biệt được nó với vòng đếm ngược.
      await _pump(tester, const EcCutoverBScreen(queueCount: 7));
      // Khung F3-04: mã vừa chốt ở pill trên, xác nhận đã lưu, vòng đếm ngược,
      // rồi thẻ đơn kế tiếp. Cả bốn đều là thông tin, không phải trang trí —
      // thiếu cái nào là người quay mất một câu trả lời.
      expect(find.text('SPXVN024567890'), findsOneWidget);
      expect(find.text('Đã lưu video'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Chuẩn bị ghi hình tiếp theo'), findsOneWidget);
      expect(find.text('Đơn tiếp theo'), findsOneWidget);
      expect(find.text('SPXVN098765432'), findsOneWidget);
      expect(find.text('Đóng hàng • 10:28'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('onStop fires from the stop button', (tester) async {
      var stopped = false;
      await _pump(tester, EcCutoverBScreen(onStop: () => stopped = true));
      await tester.tap(find.byTooltip('Dừng quay'));
      expect(stopped, isTrue);
    });
  });

  group('EcNearLimitScreen', () {
    testWidgets('shows the 15-minute warning banner', (tester) async {
      await _pump(tester, const EcNearLimitScreen());
      expect(
        find.text('Sắp chạm trần 2 phút — video sẽ tự chốt'),
        findsOneWidget,
      );
      expect(find.text('SPXVN024567890'), findsOneWidget);
      expect(find.text('14:12'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('EcReturnRecScreen', () {
    testWidgets('shows return code, duration and link note', (tester) async {
      await _pump(tester, const EcReturnRecScreen());
      expect(find.text('SPXVN088877766 (hoàn)'), findsOneWidget);
      expect(find.text('00:32'), findsOneWidget);
      expect(find.text('Tự liên kết về hồ sơ mã vận đơn gốc'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('EcUploadQueueScreen', () {
    testWidgets('renders the queue list and every status variant', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcUploadQueueScreen(items: ecDefaultUploadItems),
      );
      expect(find.text('Hàng đợi upload'), findsOneWidget);
      expect(find.text('72%'), findsOneWidget);
      expect(find.text('Chờ upload'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
      expect(find.text('Chờ quota'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // Mỗi dòng chỉ được nói trạng thái đúng một lần — trước đây vừa có dòng
    // chữ dưới meta vừa có icon bên phải.
    testWidgets('states are not spelled out twice per row', (tester) async {
      await _pump(
        tester,
        const EcUploadQueueScreen(items: ecDefaultUploadItems),
      );
      expect(find.text('Đang tải 72%'), findsNothing);
      expect(find.text('Đã upload'), findsNothing);
      expect(find.textContaining('Tất cả ('), findsNothing);
      expect(find.textContaining('video đang chờ'), findsNothing);
    });

    testWidgets('retry callback fires', (tester) async {
      EcUploadItem? retried;
      await _pump(
        tester,
        EcUploadQueueScreen(
          items: ecDefaultUploadItems,
          onRetry: (item) => retried = item,
        ),
      );
      await tester.tap(find.text('Thử lại'));
      expect(retried?.status, EcUploadStatus.error);
    });

    // Biển báo hết dung lượng chỉ BÁO, không dẫn đi mua: app không bán gói, và
    // một dòng chỉ đường sang web để trả tiền là thứ guideline 3.1.1 cấm.
    testWidgets('biển báo quota không còn đường nâng gói', (tester) async {
      await _pump(
        tester,
        const EcUploadQueueScreen(items: ecDefaultUploadItems),
      );
      expect(find.text('Nâng gói'), findsNothing);
    });

    // FR-02 — Nhân viên không được xóa bằng chứng. Vai trò được chuyển xuống
    // đây bằng cách bỏ trống `onDelete` (xem `_QueueRoute` ở lib/ec_app.dart),
    // nên hàng đợi phải giấu hẳn nút xóa chứ không chỉ vô hiệu hóa nó.
    testWidgets('hides the delete affordance when deleting is not allowed', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcUploadQueueScreen(items: ecDefaultUploadItems),
      );
      expect(find.bySemanticsLabel('Xóa'), findsNothing);

      await _pump(
        tester,
        EcUploadQueueScreen(
          items: ecDefaultUploadItems,
          onDelete: (_) {},
        ),
      );
      expect(find.bySemanticsLabel('Xóa'), findsWidgets);
    });
  });

  group('EcManualEntryScreen', () {
    testWidgets('shows the manual entry sheet', (tester) async {
      await _pump(tester, const EcManualEntryScreen());
      expect(find.text('Nhập tay mã vận đơn'), findsOneWidget);
      expect(
        find.text('Dùng khi bill mờ — không quá 10 giây'),
        findsOneWidget,
      );
      expect(find.text('Hủy'), findsOneWidget);
      expect(find.text('Bắt đầu quay'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('submit fires onManualSubmit with the typed code', (
      tester,
    ) async {
      String? submitted;
      await _pump(
        tester,
        EcManualEntryScreen(onManualSubmit: (value) => submitted = value),
      );
      await tester.enterText(find.byType(EditableText), 'SPXVN000111222');
      await tester.tap(find.text('Bắt đầu quay'));
      expect(submitted, 'SPXVN000111222');
    });

    testWidgets('cancel fires onCancel', (tester) async {
      var cancelled = false;
      await _pump(
        tester,
        EcManualEntryScreen(onCancel: () => cancelled = true),
      );
      await tester.tap(find.text('Hủy'));
      expect(cancelled, isTrue);
    });
  });

  group('EcNoMatchScreen', () {
    testWidgets('shows the no-match dialog copy', (tester) async {
      await _pump(tester, const EcNoMatchScreen());
      expect(find.text('Mã hoàn không khớp'), findsOneWidget);
      expect(find.textContaining('SPXVN099988877'), findsOneWidget);
      expect(find.text('Nhập tay mã'), findsOneWidget);
      expect(find.text('Tạo vận đơn mới'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('create-new callback fires', (tester) async {
      var created = false;
      await _pump(
        tester,
        EcNoMatchScreen(onCreateNew: () => created = true),
      );
      await tester.tap(find.text('Tạo vận đơn mới'));
      expect(created, isTrue);
    });
  });

  group('EcTypeSheetScreen', () {
    testWidgets('shows all built-in types locked, with current selection', (
      tester,
    ) async {
      await _pump(tester, const EcTypeSheetScreen());
      // Khung F3-09: tiêu đề đầy đủ, và loại được chia hai nhóm có đề mục.
      expect(find.text('Chọn loại video'), findsOneWidget);
      expect(find.text('Loại mặc định (bắt buộc)'), findsOneWidget);
      // Chưa có loại tùy chỉnh nào thì đề mục nhóm đó phải biến mất hẳn.
      expect(find.text('Loại tùy chỉnh của shop'), findsNothing);
      expect(find.text('Đóng hàng'), findsOneWidget);
      expect(find.text('Đơn vị vận chuyển'), findsOneWidget);
      expect(find.text('Trả hàng'), findsOneWidget);
      expect(find.byIcon(LucideIcons.lock), findsNWidgets(3));
      expect(find.byIcon(LucideIcons.check), findsOneWidget);
      expect(
        find.text('Quản lý loại video — mở Chi tiết shop'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('selecting a type and manage callbacks fire', (
      tester,
    ) async {
      String? selected;
      var managed = false;
      await _pump(
        tester,
        EcTypeSheetScreen(
          types: const [
            ...ecDefaultVideoTypes,
            EcVideoType(label: 'Cân hàng', icon: Icons.scale_outlined),
          ],
          onSelectType: (type) => selected = type.label,
          onManageTypes: () => managed = true,
        ),
      );
      await tester.tap(find.text('Cân hàng'));
      await tester.tap(find.text('Quản lý loại video — mở Chi tiết shop'));
      expect(selected, 'Cân hàng');
      expect(managed, isTrue);
    });
  });
}

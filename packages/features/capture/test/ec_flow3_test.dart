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
    testWidgets('shows idle hint, shop header and camera rail', (
      tester,
    ) async {
      await _pump(
        tester,
        EcWaitBill2Screen(
          onResolution: () {},
          onManualEntry: () {},
        ),
      );
      expect(find.text('Shop ABC'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Đưa bill vào khung để bắt đầu'), findsOneWidget);
      expect(find.text('Camera nhìn xuống bàn'), findsOneWidget);
      expect(find.text('Đóng hàng'), findsOneWidget);
      expect(find.text('1x'), findsOneWidget);
      expect(find.text('720p'), findsOneWidget);
      expect(find.byIcon(LucideIcons.keyboard), findsOneWidget);
      // Idle — no stop button yet.
      expect(find.byIcon(LucideIcons.check), findsNothing);
      expect(tester.takeException(), isNull);
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
      await _pump(tester, const EcCutoverBScreen());
      expect(find.text('Đã chốt mã vận đơn A (02:45)'), findsOneWidget);
      expect(find.text('Âm báo + rung khi chuyển đơn'), findsOneWidget);
      expect(find.text('SPXVN098765432'), findsOneWidget);
      expect(find.text('00:01'), findsOneWidget);
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
      expect(find.text('Tất cả · 5'), findsOneWidget);
      expect(find.text('Đang tải 72%'), findsOneWidget);
      expect(find.text('Chờ upload'), findsOneWidget);
      expect(find.text('Đã upload'), findsOneWidget);
      expect(find.text('Lỗi · Thử lại (2)'), findsOneWidget);
      expect(find.text('Chờ quota'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tab selection and upgrade callbacks fire', (tester) async {
      int? selectedTab;
      var upgraded = false;
      await _pump(
        tester,
        EcUploadQueueScreen(
          items: ecDefaultUploadItems,
          onTabSelected: (index) => selectedTab = index,
          onUpgrade: () => upgraded = true,
        ),
      );
      await tester.tap(find.text('Đang tải · 1'));
      await tester.tap(find.text('Nâng gói'));
      expect(selectedTab, 1);
      expect(upgraded, isTrue);
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
      expect(find.text('Loại video'), findsOneWidget);
      expect(find.text('Đóng hàng'), findsOneWidget);
      expect(find.text('ĐV vận chuyển'), findsOneWidget);
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
          onSelectType: (label) => selected = label,
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

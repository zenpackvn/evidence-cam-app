import 'package:app_ui/app_ui.dart';
import 'package:feature_orders/feature_orders.dart'
    show EcEvidenceType, EcVideoDetail, EcVideoDetailScreen;
import 'package:feature_shift/feature_shift.dart';
import 'package:ec_ui/ec_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';

Future<void> _pump(WidgetTester tester, Widget screen) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('vi'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: screen,
    ),
  );
}

EcOrderRow _order(int i) => EcOrderRow(
  code: 'SPXVN$i',
  time: '10:00',
  type: 'Đóng hàng',
  videoCount: 1,
);

void main() {
  group('EcHomeOrdersScreen paging', () {
    testWidgets('shows the shop-empty state when there are no orders', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcHomeOrdersScreen(
          shopName: 'Shop ABC',
          orders: [],
          emptyText: 'Shop chưa có đơn nào',
        ),
      );
      expect(find.text('Shop chưa có đơn nào'), findsOneWidget);
      expect(find.text('Không tìm thấy đơn hàng'), findsNothing);
    });

    testWidgets('shows the page range and the current page', (tester) async {
      await _pump(
        tester,
        EcHomeOrdersScreen(
          shopName: 'Shop ABC',
          orders: [for (var i = 0; i < 10; i++) _order(i)],
          pageInfo: const EcOrderPage(
            page: 2,
            total: 128,
            pageSize: 10,
            shown: 10,
          ),
          onPageChanged: (_) {},
        ),
      );
      expect(find.text('11–20 / 128 vận đơn'), findsOneWidget);
      expect(find.text('13'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('hides the pager when everything fits on one page', (
      tester,
    ) async {
      await _pump(
        tester,
        EcHomeOrdersScreen(
          shopName: 'Shop ABC',
          orders: [for (var i = 0; i < 3; i++) _order(i)],
          pageInfo: const EcOrderPage(
            page: 1,
            total: 3,
            pageSize: 10,
            shown: 3,
          ),
          onPageChanged: (_) {},
        ),
      );
      expect(find.textContaining('/ 3 vận đơn'), findsNothing);
    });

    testWidgets('fires onPageChanged when a page number is tapped', (
      tester,
    ) async {
      final taps = <int>[];
      await _pump(
        tester,
        EcHomeOrdersScreen(
          shopName: 'Shop ABC',
          orders: [for (var i = 0; i < 10; i++) _order(i)],
          pageInfo: const EcOrderPage(
            page: 1,
            total: 128,
            pageSize: 10,
            shown: 10,
          ),
          onPageChanged: taps.add,
        ),
      );
      await tester.ensureVisible(find.text('2'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2'));
      await tester.pump();
      expect(taps, [2]);
    });

    test('the page window keeps the last page reachable', () {
      // Trang 1/32 khớp thiết kế F2-01: 1 2 3 … 32.
      expect(ecOrderPageWindow(1, 32), [1, 2, 3, null, 32]);
      // Sát cuối thì không còn dấu "…" vì chẳng còn khoảng trống nào.
      expect(ecOrderPageWindow(32, 32), [30, 31, 32]);
      expect(ecOrderPageWindow(30, 32), [29, 30, 31, 32]);
      // Ít trang thì liệt kê hết.
      expect(ecOrderPageWindow(1, 3), [1, 2, 3]);
    });

    testWidgets('a scanned code fills the search and filters the list', (
      tester,
    ) async {
      await _pump(
        tester,
        EcHomeOrdersScreen(
          shopName: 'Shop ABC',
          orders: [for (var i = 0; i < 3; i++) _order(i)],
          onScan: () async => 'SPXVN2',
        ),
      );
      expect(find.text('SPXVN1'), findsOneWidget);
      await tester.tap(find.byIcon(LucideIcons.scan));
      await tester.pumpAndSettle();
      // Scanned code lands in the search box and filters out non-matches
      // (SPXVN2 now shows in both the field and the matching row).
      expect(find.text('SPXVN2'), findsWidgets);
      expect(find.text('SPXVN1'), findsNothing);
      expect(find.text('SPXVN0'), findsNothing);
    });
  });

  group('EcVideoDetailScreen role gating', () {
    const video = EcVideoDetail(
      title: 'Video đóng hàng',
      duration: '00:42',
      recordedAt: '24 Th7 · 10:23',
      recordedBy: 'Trần Thị B (Nhân viên)',
      device: 'iPhone 13',
      uploadStatus: 'Đã tải lên',
    );

    testWidgets('owner/manager sees the delete action', (tester) async {
      await _pump(tester, const EcVideoDetailScreen(video: video));
      expect(find.text('Xóa video'), findsOneWidget);
    });

    testWidgets('staff (canDelete: false) does not see delete', (tester) async {
      await _pump(
        tester,
        const EcVideoDetailScreen(video: video, canDelete: false),
      );
      expect(find.text('Xóa video'), findsNothing);
    });

    testWidgets('shows the recorded clip duration for a video', (
      tester,
    ) async {
      await _pump(tester, const EcVideoDetailScreen(video: video));
      // The design folds the duration into the sheet's meta line rather than
      // giving it a row of its own.
      expect(find.textContaining('00:42'), findsOneWidget);
    });

    testWidgets('hides the duration row for a photo', (tester) async {
      const photo = EcVideoDetail(
        title: 'Ảnh đính kèm',
        duration: '—',
        recordedAt: '24 Th7 · 10:23',
        recordedBy: 'Trần Thị B (Nhân viên)',
        device: 'iPhone 13',
        uploadStatus: 'Đã tải lên',
        type: EcEvidenceType.image,
      );
      await _pump(tester, const EcVideoDetailScreen(video: photo));
      expect(find.text('Thời lượng'), findsNothing);
    });
  });
}

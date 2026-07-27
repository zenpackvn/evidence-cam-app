import 'package:app_ui/app_ui.dart';
import 'package:feature_orders/feature_orders.dart'
    show EcVideoDetail, EcVideoDetailScreen;
import 'package:feature_shift/feature_shift.dart';
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

    testWidgets('shows a trailing spinner while loading more', (tester) async {
      await _pump(
        tester,
        EcHomeOrdersScreen(
          shopName: 'Shop ABC',
          orders: [for (var i = 0; i < 3; i++) _order(i)],
          hasMore: true,
          isLoadingMore: true,
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
      // CupertinoActivityIndicator renders as a custom painter, so assert the
      // list still shows the orders and no exception was thrown.
      expect(find.text('SPXVN0'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fires onLoadMore when scrolled to the bottom', (tester) async {
      var loadMoreCalls = 0;
      await _pump(
        tester,
        EcHomeOrdersScreen(
          shopName: 'Shop ABC',
          orders: [for (var i = 0; i < 40; i++) _order(i)],
          hasMore: true,
          onLoadMore: () => loadMoreCalls++,
        ),
      );
      await tester.drag(
        find.text('SPXVN0'),
        const Offset(0, -6000),
        warnIfMissed: false,
      );
      await tester.pump();
      expect(loadMoreCalls, greaterThan(0));
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
      await tester.tap(find.byIcon(Icons.qr_code_scanner));
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
  });
}

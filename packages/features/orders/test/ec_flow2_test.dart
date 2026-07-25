import 'package:app_ui/app_ui.dart';
import 'package:feature_orders/feature_orders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget screen) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: screen));
}

const _orders = [
  EcOrderRow(
    code: 'SPXVN024567890',
    time: '10:23',
    videoType: 'Đóng hàng đi',
    videoCount: 5,
  ),
  EcOrderRow(
    code: 'SPXVN044556677',
    time: '10:55',
    videoType: 'Trả hàng',
    videoCount: 2,
    errorCount: 1,
  ),
];

const _days = [
  EcTimelineDay(
    date: '23/07/2026',
    videos: [
      EcTimelineVideo(time: '10:23', label: 'Đóng hàng đi'),
      EcTimelineVideo(
        time: '10:35',
        label: 'Đơn vị vận chuyển',
        statusText: 'Đang tải 72%',
      ),
    ],
  ),
  EcTimelineDay(
    date: '31/07/2026',
    videos: [
      EcTimelineVideo(
        time: '09:12',
        label: 'Trả hàng',
        statusText: 'Lỗi · Thử lại',
        statusIcon: Icons.refresh,
      ),
      EcTimelineVideo(
        time: '09:30',
        label: 'Cân hàng',
        type: EcEvidenceType.scale,
        statusText: 'Chờ quota',
      ),
    ],
  ),
];

const _videoDetail = EcVideoDetail(
  title: 'Đóng hàng đi',
  duration: '02:45',
  recordedAt: '23/07/2026 · 10:23',
  recordedBy: 'Trần Thị B (Nhân viên)',
  device: 'iPhone 12 · app 1.0',
  fileSize: '48,2 MB',
  uploadStatus: 'Đã upload ✓',
);

void main() {
  group('EcOrderListScreen', () {
    testWidgets('shows header, stats, search and order rows', (tester) async {
      await _pump(tester, const EcOrderListScreen(orders: _orders));

      expect(find.text('Shop ABC'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('24'), findsOneWidget);
      expect(find.text('38'), findsOneWidget);
      expect(find.text('Nhập mã vận đơn'), findsOneWidget);
      expect(find.text('Tất cả'), findsOneWidget);
      expect(find.text('SPXVN024567890'), findsOneWidget);
      expect(find.textContaining('1 lỗi'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('order row tap fires callback with the tapped order', (
      tester,
    ) async {
      EcOrderRow? tapped;
      await _pump(
        tester,
        EcOrderListScreen(
          orders: _orders,
          onOrderTap: (order) => tapped = order,
        ),
      );

      await tester.tap(find.text('SPXVN044556677'));
      await tester.pump();

      expect(tapped?.code, 'SPXVN044556677');
    });

    testWidgets('back and scan callbacks fire', (tester) async {
      var backTapped = false;
      var scanTapped = false;
      await _pump(
        tester,
        EcOrderListScreen(
          orders: _orders,
          onBack: () => backTapped = true,
          onScan: () => scanTapped = true,
        ),
      );

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.tap(find.byIcon(Icons.qr_code_scanner_outlined));

      expect(backTapped, isTrue);
      expect(scanTapped, isTrue);
    });
  });

  group('EcOrderTimelineScreen', () {
    testWidgets('shows order code, warning banner, and grouped rows', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcOrderTimelineScreen(
          orderCode: 'SPXVN024567890',
          days: _days,
          pendingUploadCount: 4,
          dossierUrl: 'evidencecam.vn/r/abc123…',
        ),
      );

      expect(find.text('SPXVN024567890'), findsOneWidget);
      expect(find.textContaining('bằng chứng chưa upload'), findsOneWidget);
      expect(find.text('23/07/2026'), findsOneWidget);
      expect(find.text('31/07/2026'), findsOneWidget);
      expect(find.text('Đóng hàng đi'), findsOneWidget);
      expect(find.text('Đang tải 72%'), findsOneWidget);
      expect(find.text('Lỗi · Thử lại'), findsOneWidget);
      expect(find.text('Link hồ sơ khiếu nại'), findsOneWidget);
      expect(find.text('Đính kèm ảnh vào đơn'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('hides the warning banner when nothing is pending', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcOrderTimelineScreen(orderCode: 'SPXVN024567890', days: _days),
      );

      expect(find.textContaining('bằng chứng chưa upload'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('retry banner and video play callbacks fire', (tester) async {
      var retried = false;
      EcTimelineVideo? played;
      await _pump(
        tester,
        EcOrderTimelineScreen(
          orderCode: 'SPXVN024567890',
          days: _days,
          pendingUploadCount: 4,
          onRetryUpload: () => retried = true,
          onVideoTap: (video) => played = video,
        ),
      );

      await tester.tap(find.text('Thử lại'));
      expect(retried, isTrue);

      await tester.tap(find.byIcon(Icons.play_arrow).first);
      expect(played?.label, 'Đóng hàng đi');
    });
  });

  group('EcVideoDetailScreen', () {
    testWidgets('shows video info and action rows', (tester) async {
      await _pump(tester, const EcVideoDetailScreen(video: _videoDetail));

      expect(find.text('Đóng hàng đi'), findsOneWidget);
      expect(find.text('02:45'), findsOneWidget);
      expect(find.text('Giờ quay'), findsOneWidget);
      expect(find.text('23/07/2026 · 10:23'), findsOneWidget);
      expect(find.text('Người quay'), findsOneWidget);
      expect(find.text('Dung lượng'), findsOneWidget);
      expect(find.text('48,2 MB'), findsOneWidget);
      expect(find.text('Trạng thái upload'), findsOneWidget);
      expect(find.text('Đã upload ✓'), findsOneWidget);
      expect(find.text('Phát video'), findsOneWidget);
      expect(find.text('Tải video về máy'), findsOneWidget);
      expect(find.text('Xóa video'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('play, download, delete and close callbacks fire', (
      tester,
    ) async {
      var played = false;
      var downloaded = false;
      var deleted = false;
      var closed = false;
      await _pump(
        tester,
        EcVideoDetailScreen(
          video: _videoDetail,
          onPlay: () => played = true,
          onDownload: () => downloaded = true,
          onDelete: () => deleted = true,
          onClose: () => closed = true,
        ),
      );

      await tester.tap(find.text('Phát video'));
      await tester.tap(find.text('Tải video về máy'));
      await tester.tap(find.text('Xóa video'));
      await tester.tapAt(const Offset(195, 100));

      expect(played, isTrue);
      expect(downloaded, isTrue);
      expect(deleted, isTrue);
      expect(closed, isTrue);
    });
  });
}

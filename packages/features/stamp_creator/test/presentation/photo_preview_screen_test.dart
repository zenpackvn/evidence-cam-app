// SM-005 (F02-S03): the "Xem trước ảnh" step confirms/zooms the picked photo
// before the filter wizard. It shows the zoom badge and Hủy / Xác nhận actions.
import 'package:app_ui/app_ui.dart';
import 'package:feature_stamp_creator/feature_stamp_creator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(
  WidgetTester tester, {
  required VoidCallback onConfirm,
  required VoidCallback onCancel,
}) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: PhotoPreviewScreen(
        imagePath: '/tmp/nonexistent.jpg',
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('renders the preview copy, zoom badge and actions', (
    tester,
  ) async {
    await _pump(tester, onConfirm: () {}, onCancel: () {});

    expect(find.text('Xem trước ảnh'), findsOneWidget);
    // The zoom badge starts at 1.0x.
    expect(find.text('1.0x'), findsOneWidget);
    expect(find.text('Hủy'), findsOneWidget);
    expect(find.text('Xác nhận'), findsOneWidget);
  });

  testWidgets('Xác nhận / Hủy fire their callbacks', (tester) async {
    var confirmed = false;
    var cancelled = false;
    await _pump(
      tester,
      onConfirm: () => confirmed = true,
      onCancel: () => cancelled = true,
    );

    await tester.tap(find.text('Xác nhận'));
    expect(confirmed, isTrue);

    await tester.tap(find.text('Hủy'));
    expect(cancelled, isTrue);
  });
}

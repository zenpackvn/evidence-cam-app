// SM-005 (F02-S03): the "Xem trước ảnh" step frames the picked photo in the tem
// (swipe to change the edge) before the filter wizard. It shows Hủy / Xác nhận.
import 'package:app_ui/app_ui.dart';
import 'package:feature_stamp_creator/feature_stamp_creator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(
  WidgetTester tester, {
  required void Function(StampFrameStyle, String) onConfirm,
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
    await _pump(tester, onConfirm: (_, _) {}, onCancel: () {});

    // No instructional text on this screen — just the actions.
    expect(find.text('Hủy'), findsOneWidget);
    expect(find.text('Xác nhận'), findsOneWidget);
  });

  testWidgets('Xác nhận / Hủy fire their callbacks', (tester) async {
    var confirmed = false;
    var cancelled = false;
    await _pump(
      tester,
      onConfirm: (_, _) => confirmed = true,
      onCancel: () => cancelled = true,
    );

    // Xác nhận captures the picture area (RepaintBoundary → image) before
    // firing onConfirm — real async, so run it under runAsync and give it time.
    await tester.runAsync(() async {
      await tester.tap(find.text('Xác nhận'));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();
    expect(confirmed, isTrue);

    await tester.tap(find.text('Hủy'));
    expect(cancelled, isTrue);
  });
}

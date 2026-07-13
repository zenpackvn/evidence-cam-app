import 'package:app_ui/app_ui.dart';
import 'package:feature_stamp_creator/feature_stamp_creator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Pump on a tall phone surface so the centered column lays out without
// overflowing the default 800px test view.
Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: child));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the SM-005 source picker copy and both cards', (
    tester,
  ) async {
    // picker: null keeps taps inert; this test asserts the pixel-faithful UI.
    await _pump(tester, StampSourceScreen(onPicked: (_) {}));

    expect(find.text('Chụp ảnh mới'), findsOneWidget);
    expect(find.text('Chọn từ thư viện'), findsOneWidget);
    // The tip panel's emoji marks its presence (its copy is a styled RichText).
    expect(find.text('💡'), findsOneWidget);
    // Two source cards, each a tappable InkWell.
    expect(find.byType(SourceCard), findsNWidgets(2));
  });

  testWidgets('tap on a card with no picker does not throw', (tester) async {
    await _pump(tester, StampSourceScreen(onPicked: (_) {}));
    await tester.tap(find.text('Chụp ảnh mới'));
    await tester.pump();
    // No exception — the null-picker guard holds.
  });
}

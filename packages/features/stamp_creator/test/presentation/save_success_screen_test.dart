// SM-011 success (F02-S09): the "Đã lưu vào Album!" screen shows the saved
// stamp's name on the result card and both actions, without overflow.
import 'package:app_ui/app_ui.dart';
import 'package:feature_stamp_creator/feature_stamp_creator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, {required String name}) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: SaveSuccessScreen(
        onViewAlbum: () {},
        onCreateAnother: () {},
        draft: const StampDraft(imagePath: '/tmp/nonexistent.jpg'),
        stampName: name,
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('shows the saved stamp name and both actions', (tester) async {
    await _pump(tester, name: 'Bình minh Cappadocia');

    expect(find.text('Đã lưu vào Album!'), findsOneWidget);
    // The name the user gave the stamp is echoed on the result card…
    expect(find.text('Bình minh Cappadocia'), findsOneWidget);
    expect(find.text('Đã thêm vào Album'), findsOneWidget);
    expect(find.text('Xem Album'), findsOneWidget);
    expect(find.text('Tạo tem mới'), findsOneWidget);
    // No overflow was thrown laying the screen out.
  });
}

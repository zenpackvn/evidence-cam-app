// SM-011 (F02-S13): the "Đã đạt giới hạn 30 tem/tháng" modal shown when a Free
// user's save hits the monthly quota.
import 'package:app_ui/app_ui.dart';
import 'package:feature_stamp_creator/feature_stamp_creator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, {VoidCallback? onUpgrade}) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: QuotaReachedSheet(onUpgrade: onUpgrade),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('renders the quota copy and both actions', (tester) async {
    await _pump(tester);

    expect(find.text('Đã đạt giới hạn 30 tem/tháng'), findsOneWidget);
    expect(
      find.text('Bạn đã đạt giới hạn 30 tem trong tháng này.'),
      findsOneWidget,
    );
    expect(find.text('Nâng cấp Premium'), findsOneWidget);
    expect(find.text('Để tháng sau'), findsOneWidget);
    // No overflow was thrown laying out the badge + card.
  });

  testWidgets('the upgrade button fires its callback', (tester) async {
    var upgraded = false;
    await _pump(tester, onUpgrade: () => upgraded = true);

    await tester.tap(find.text('Nâng cấp Premium'));
    await tester.pump();
    expect(upgraded, isTrue);
  });
}

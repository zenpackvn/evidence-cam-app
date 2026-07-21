// SM-009 (F02-S12): the "Mở sticker đặc biệt" upsell sheet lists the premium
// sticker packs and an upgrade CTA.
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
      home: PremiumStickerSheet(onUpgrade: onUpgrade),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('renders the packs and upgrade CTA', (tester) async {
    await _pump(tester);

    expect(find.text('Mở sticker đặc biệt'), findsOneWidget);
    expect(find.text('Chọn bộ sticker bạn muốn mở khóa'), findsOneWidget);
    expect(find.text('🍃 Mùa'), findsOneWidget);
    expect(find.text('💗 Cảm xúc'), findsOneWidget);
    expect(find.text('✈️ Du lịch'), findsOneWidget);
    expect(find.text('Nâng cấp Premium'), findsOneWidget);
  });

  testWidgets('the upgrade button fires its callback', (tester) async {
    var upgraded = false;
    await _pump(tester, onUpgrade: () => upgraded = true);

    await tester.tap(find.text('Nâng cấp Premium'));
    expect(upgraded, isTrue);
  });
}

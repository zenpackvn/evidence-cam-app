import 'package:flutter/material.dart';
import 'package:flutter_starter_template/ec_app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

void main() {
  testWidgets(
    'navigates Splash → Login → Shops → Home tab',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {'ImageStreamCompleterHandle': 1},
    ),
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        PaintingBinding.instance.imageCache
          ..clear()
          ..clearLiveImages();
        tester.view.reset();
      });

      await tester.pumpWidget(const EcApp());
      await tester.pumpAndSettle();

      // Splash
      expect(find.text('ZenPack'), findsOneWidget);
      await tester.tap(find.text('Bắt đầu'));
      await tester.pumpAndSettle();

      // Login
      expect(find.text('Đăng nhập'), findsWidgets);
      await tester.tap(find.text('Đăng nhập với Google'));
      await tester.pumpAndSettle();

      // Shop layer → pick a shop → Home tab (Đơn hàng)
      expect(find.text('Shop ABC'), findsWidgets);
      await tester.tap(find.text('Shop ABC').first);
      await tester.pumpAndSettle();

      // Home orders tab shows a sample order and no exceptions along the way.
      expect(find.textContaining('SPXVN'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
}

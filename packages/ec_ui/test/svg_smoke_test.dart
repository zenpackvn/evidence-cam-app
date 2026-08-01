import 'package:ec_ui/ec_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _platforms = ['shopee', 'tiktok', 'lazada', 'tiki'];

void main() {
  testWidgets('every marketplace logo renders without throwing', (
    tester,
  ) async {
    for (final p in [..._platforms, 'khac']) {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(child: PenPlatforms.logo(p, size: 40)),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: p);
    }
  });

  testWidgets('every logo occupies exactly the box it is asked for', (
    tester,
  ) async {
    // The four marks come from four brand kits at four aspect ratios; each
    // asset is normalised to a square canvas so no tile renders one logo
    // bigger than its neighbours, and a wide wordmark cannot push its row out
    // of bounds. This fails the day someone drops in a tight-bbox export.
    for (final p in _platforms) {
      final logo = PenPlatforms.logo(p, size: 40);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(child: logo),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byWidget(logo)),
        const Size(40, 40),
        reason: p,
      );
    }
  });
}

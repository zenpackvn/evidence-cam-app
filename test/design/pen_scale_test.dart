import 'package:ec_ui/ec_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('penTextSize', () {
    test('leaves body text at or below the pivot untouched', () {
      expect(penTextSize(12), 12);
      expect(penTextSize(14), 14);
    });

    test('compresses headings toward the iOS ramp', () {
      expect(penTextSize(19), closeTo(17.6, 0.05));
      expect(penTextSize(24), closeTo(21.2, 0.05));
      expect(penTextSize(26), closeTo(22.6, 0.05));
    });

    test('stays monotonic so the type hierarchy never inverts', () {
      var previous = 0.0;
      for (var size = 8.0; size <= 56; size += 0.5) {
        final scaled = penTextSize(size);
        expect(scaled, greaterThan(previous));
        previous = scaled;
      }
    });

    test('never scales a heading below the pivot', () {
      expect(penTextSize(56), greaterThan(penTypePivot));
    });
  });
}

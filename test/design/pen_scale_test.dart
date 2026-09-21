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

  // Hai núm nén phải TẮT được cho golden thiết kế (D-07, 17/09): ảnh gốc là
  // artboard pixel-true, app thì vẽ qua 0,72/0,85. Từng là `const`, nên harness
  // không tắt được và 31 màn "trôi 22%" chỉ vì so thiết kế với bản đã nén.
  group('PenScale', () {
    tearDown(PenScale.appScale);

    test('mặc định là mức app: 0,72 / 0,85', () {
      expect(penTypeCompress, 0.72);
      expect(penDensityScale, 0.85);
    });

    test('pixelTrue tắt nén — chữ và khoảng cách đúng như artboard', () {
      PenScale.pixelTrue();
      expect(penTextSize(26), 26);
      expect(penDensityScale, 1);
    });

    test('appScale trả về mức app sau khi một test khác đã tắt', () {
      PenScale.pixelTrue();
      PenScale.appScale();
      expect(penTextSize(26), closeTo(22.6, 0.05));
    });
  });
}

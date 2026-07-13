import 'package:feature_stamp_creator/src/domain/borders.dart';
import 'package:feature_stamp_creator/src/domain/filters.dart';
import 'package:feature_stamp_creator/src/domain/stamp_draft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const draft = StampDraft(imagePath: '/tmp/p.jpg');

  test('original filter + no adjustments applies no color filter', () {
    expect(effectiveColorFilter(draft), isNull);
  });

  test('a preset filter yields a color filter', () {
    expect(
      effectiveColorFilter(draft.copyWith(filterId: 'sepia')),
      isNotNull,
    );
  });

  test('a manual adjustment alone yields a color filter', () {
    final adjusted = draft.copyWith(
      adjustments: const Adjustments(brightness: 0.3),
    );
    expect(effectiveColorFilter(adjusted), isNotNull);
  });

  test('catalog has 16 filters, 8 of them premium (SM-006 / D6)', () {
    expect(stampFilters, hasLength(16));
    expect(stampFilters.where((f) => f.premium), hasLength(8));
  });

  test('borders catalog has 7, 4 premium (SM-009 / D6)', () {
    expect(stampBorders, hasLength(7));
    expect(stampBorders.where((b) => b.premium), hasLength(4));
  });

  test('adjustmentMatrix returns a well-formed 5x4 matrix', () {
    final m = adjustmentMatrix(const Adjustments(contrast: 0.5));
    expect(m, hasLength(20));
  });
}

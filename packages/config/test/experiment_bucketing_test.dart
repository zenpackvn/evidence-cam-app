import 'package:config/config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('bucketFor', () {
    test('is deterministic for the same id and salt', () {
      expect(bucketFor('user-1'), bucketFor('user-1'));
      expect(bucketFor('user-1', salt: 'exp'), bucketFor('user-1', salt: 'exp'));
    });

    test('always lands in [0, 100)', () {
      for (var i = 0; i < 1000; i++) {
        final bucket = bucketFor('user-$i');
        expect(bucket, inInclusiveRange(0, 99));
      }
    });

    test('different salts decorrelate cohorts', () {
      // The same user should not be forced into the same bucket across two
      // independent experiments. Over many users the assignments must differ
      // for at least some of them.
      var differing = 0;
      for (var i = 0; i < 200; i++) {
        if (bucketFor('user-$i', salt: 'a') !=
            bucketFor('user-$i', salt: 'b')) {
          differing++;
        }
      }
      expect(differing, greaterThan(100));
    });

    test('spreads ids across the range (rough uniformity)', () {
      final counts = List<int>.filled(10, 0);
      for (var i = 0; i < 10000; i++) {
        counts[bucketFor('id-$i') ~/ 10]++;
      }
      // Each decile should get roughly 1000; assert none is wildly off.
      for (final c in counts) {
        expect(c, inInclusiveRange(700, 1300));
      }
    });
  });

  group('isInRollout', () {
    test('0% excludes everyone, 100% includes everyone', () {
      for (var i = 0; i < 100; i++) {
        expect(isInRollout('user-$i', 0), isFalse);
        expect(isInRollout('user-$i', 100), isTrue);
      }
    });

    test('a partial rollout includes only the lower buckets', () {
      const percent = 30;
      for (var i = 0; i < 500; i++) {
        final id = 'user-$i';
        expect(isInRollout(id, percent), bucketFor(id) < percent);
      }
    });

    test('ramping the percentage never removes an already-included user', () {
      // Monotonicity: if a user is in at X%, they stay in at any Y > X.
      for (var i = 0; i < 200; i++) {
        final id = 'user-$i';
        if (isInRollout(id, 40)) {
          expect(isInRollout(id, 60), isTrue);
        }
      }
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_contracts/shared_contracts.dart';

void main() {
  group('ClipBudget', () {
    test('warns only once the shop raises the cap past the recommendation', () {
      const budget = ClipBudget(
        seconds: 120,
        recommendedSeconds: 120,
        planMaxSeconds: 900,
        maxImageBytes: 10000000,
        maxVideoBytes: 30000000,
        uploadBytes: 10000000,
      );

      expect(budget.exceedsRecommended, isFalse);
      expect(budget.copyWith(seconds: 300).exceedsRecommended, isTrue);
      expect(budget.copyWith(seconds: 60).exceedsRecommended, isFalse);
    });

    test('warns only once the upload cap passes the sàn attachment limit', () {
      const budget = ClipBudget(
        seconds: 120,
        recommendedSeconds: 120,
        planMaxSeconds: 900,
        maxImageBytes: 10000000,
        maxVideoBytes: 30000000,
        uploadBytes: 10000000,
      );

      expect(budget.exceedsRecommendedUpload, isFalse);
      expect(
        budget.copyWith(uploadBytes: 25000000).exceedsRecommendedUpload,
        isTrue,
      );
      expect(
        budget.copyWith(uploadBytes: 5000000).exceedsRecommendedUpload,
        isFalse,
      );
    });

    test('estimates clip size from the resolution bitrate', () {
      // Phải khớp BYTES_PER_SECOND của backend, nếu không con số "nặng ~X MB"
      // trong cảnh báo nói dối.
      expect(ClipBudget.estimatedBytes(60, '720p'), 15000000);
      expect(ClipBudget.estimatedBytes(60, '480p'), 6000000);
      expect(ClipBudget.estimatedBytes(60, '240p'), 3000000);
      // Độ phân giải lạ → giả định nặng nhất, cảnh báo sớm còn hơn muộn.
      expect(
        ClipBudget.estimatedBytes(60, 'unknown'),
        ClipBudget.estimatedBytes(60, '720p'),
      );
    });

    test('a 2-minute 720p clip lands just under Shopee 30 MB', () {
      const shopeeVideoLimit = 30000000;
      expect(
        ClipBudget.estimatedBytes(120, '720p'),
        lessThanOrEqualTo(shopeeVideoLimit),
      );
      expect(
        ClipBudget.estimatedBytes(180, '720p'),
        greaterThan(shopeeVideoLimit),
      );
    });

    test('maxRecording is what Flow 3 arms its auto-close timer with', () {
      const budget = ClipBudget(
        seconds: 300,
        recommendedSeconds: 120,
        planMaxSeconds: 900,
        maxImageBytes: 1,
        maxVideoBytes: 1,
        uploadBytes: 10000000,
      );
      expect(budget.maxRecording, const Duration(minutes: 5));
    });
  });
}

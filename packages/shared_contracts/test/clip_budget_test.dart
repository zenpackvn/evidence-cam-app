import 'package:flutter_test/flutter_test.dart';
import 'package:shared_contracts/shared_contracts.dart';

void main() {
  group('ClipBudget', () {
    test('maxRecording is what Flow 3 arms its auto-close timer with', () {
      const budget = ClipBudget(seconds: 300, planMaxSeconds: 300);
      expect(budget.maxRecording, const Duration(minutes: 5));
    });

    test('copyWith chỉ đổi thời lượng, trần gói giữ nguyên', () {
      const budget = ClipBudget(seconds: 120, planMaxSeconds: 300);
      final raised = budget.copyWith(seconds: 300);
      expect(raised.seconds, 300);
      expect(raised.planMaxSeconds, 300);
    });

    test('fallback bám đúng hằng số cố định', () {
      expect(ClipBudget.fallback.seconds, kFixedClipSeconds);
      expect(ClipBudget.fallback.planMaxSeconds, kFixedClipSeconds);
    });

    // Chốt cửa cho lần sửa sau: 2026-08-07 mọi trần dung lượng đã bỏ vì gói
    // cước tính theo SỐ VIDEO. Hai hằng số thời lượng là thứ duy nhất còn lại,
    // và phải khớp MIN_CLIP_SECONDS / MAX_CLIP_SECONDS của backend.
    test('chỉ còn hai hằng số thời lượng, không còn con số dung lượng nào', () {
      expect(kMinClipSeconds, 60);
      expect(kFixedClipSeconds, 300);
    });
  });
}

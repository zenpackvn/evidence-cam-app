import 'package:ec_data/ec_data.dart';
import 'package:flutter_test/flutter_test.dart';

/// Không chờ thật — bơm sleep giả để test chạy tức thì.
Future<void> _noSleep(Duration _) async {}

void main() {
  group('EcBilling.waitForPlanChange', () {
    test('trả true ngay khi backend đã đổi gói', () async {
      var calls = 0;
      final changed = await EcBilling.waitForPlanChange(
        fetchPlanCode: () async {
          calls++;
          return calls >= 3 ? 'saver' : 'free';
        },
        previousPlanCode: 'free',
        sleep: _noSleep,
      );
      expect(changed, isTrue);
      expect(calls, 3);
    });

    test('hết thời gian chờ thì trả false, không treo', () async {
      final changed = await EcBilling.waitForPlanChange(
        fetchPlanCode: () async => 'free',
        previousPlanCode: 'free',
        timeout: const Duration(seconds: 6),
        interval: const Duration(seconds: 2),
        sleep: _noSleep,
      );
      expect(changed, isFalse);
    });

    test('lỗi mạng giữa chừng không làm hỏng vòng chờ', () async {
      var calls = 0;
      final changed = await EcBilling.waitForPlanChange(
        fetchPlanCode: () async {
          calls++;
          if (calls < 3) throw Exception('mạng chập chờn');
          return 'premium';
        },
        previousPlanCode: 'free',
        sleep: _noSleep,
      );
      expect(changed, isTrue);
    });

    test('hỏi lại đúng số lần cho phép rồi mới bỏ cuộc', () async {
      var calls = 0;
      await EcBilling.waitForPlanChange(
        fetchPlanCode: () async {
          calls++;
          return 'free';
        },
        previousPlanCode: 'free',
        timeout: const Duration(seconds: 20),
        interval: const Duration(seconds: 2),
        sleep: _noSleep,
      );
      expect(calls, 10);
    });
  });
}

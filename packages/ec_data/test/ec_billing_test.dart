import 'package:ec_data/ec_data.dart';
import 'package:flutter_test/flutter_test.dart';

/// Không chờ thật — bơm sleep giả để test chạy tức thì.
Future<void> _noSleep(Duration _) async {}

void main() {
  group('EcBilling.waitForEntitlementChange', () {
    test('trả true ngay khi backend đã đổi gói', () async {
      var calls = 0;
      final changed = await EcBilling.waitForEntitlementChange(
        fetchSignature: () async {
          calls++;
          return calls >= 3 ? 'saver' : 'free';
        },
        previousSignature: 'free',
        sleep: _noSleep,
      );
      expect(changed, isTrue);
      expect(calls, 3);
    });

    test('hết thời gian chờ thì trả false, không treo', () async {
      final changed = await EcBilling.waitForEntitlementChange(
        fetchSignature: () async => 'free',
        previousSignature: 'free',
        timeout: const Duration(seconds: 6),
        interval: const Duration(seconds: 2),
        sleep: _noSleep,
      );
      expect(changed, isFalse);
    });

    test('lỗi mạng giữa chừng không làm hỏng vòng chờ', () async {
      var calls = 0;
      final changed = await EcBilling.waitForEntitlementChange(
        fetchSignature: () async {
          calls++;
          if (calls < 3) throw Exception('mạng chập chờn');
          return 'premium';
        },
        previousSignature: 'free',
        sleep: _noSleep,
      );
      expect(changed, isTrue);
    });

    test('hỏi lại đúng số lần cho phép rồi mới bỏ cuộc', () async {
      var calls = 0;
      await EcBilling.waitForEntitlementChange(
        fetchSignature: () async {
          calls++;
          return 'free';
        },
        previousSignature: 'free',
        timeout: const Duration(seconds: 20),
        interval: const Duration(seconds: 2),
        sleep: _noSleep,
      );
      expect(calls, 10);
    });

    test('gia hạn ĐÚNG gói đang dùng vẫn được nhận ra', () async {
      const before = EntitlementDto(
        planCode: 'saver',
        status: 'active',
        currentPeriodEnd: 1000,
      );
      const after = EntitlementDto(
        planCode: 'saver',
        status: 'active',
        currentPeriodEnd: 2000,
      );
      final changed = await EcBilling.waitForEntitlementChange(
        fetchSignature: () async => after.signature,
        previousSignature: before.signature,
        sleep: _noSleep,
      );
      expect(changed, isTrue);
    });
  });

  group('EntitlementDto', () {
    test('đọc được entitlement lồng trong /api/me', () {
      final account = AccountDto.fromJson({
        'uid': 'u1',
        'entitlement': {
          'plan_code': 'premium',
          'status': 'active',
          'current_period_end': 1750000000000,
        },
      });
      expect(account.entitlement?.planCode, 'premium');
      expect(account.entitlement?.currentPeriodEnd, 1750000000000);
    });

    test('thiếu entitlement thì null, không ném', () {
      expect(AccountDto.fromJson({'uid': 'u1'}).entitlement, isNull);
    });
  });
}

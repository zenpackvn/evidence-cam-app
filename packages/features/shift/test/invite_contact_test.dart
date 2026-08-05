import 'package:feature_shift/feature_shift.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bản sao của luật bên web (`web/src/lib/ec/validate.ts`). Lệch nhau là cùng
/// một địa chỉ được web nhận còn app từ chối — hoặc tệ hơn: app gửi đi một
/// chuỗi backend không khớp nổi với tài khoản nào.
void main() {
  group('isInviteContact', () {
    test('nhận email và SĐT Việt Nam', () {
      for (final ok in [
        'ban@email.com',
        'BAN@Email.COM',
        '0901234567',
        '+84 90 123 4567',
        '84901234567',
        '090-123-4567',
      ]) {
        expect(isInviteContact(ok), isTrue, reason: ok);
      }
    });

    test('từ chối thứ không phải email cũng không phải SĐT', () {
      for (final bad in ['', 'nguyen van a', 'abc@', '@x.com', '12345', 'x y']) {
        expect(isInviteContact(bad), isFalse, reason: bad);
      }
    });
  });

  group('inviteContactOf', () {
    test('đưa +84/84 về 0 đứng đầu — số lưu trong accounts đã qua bộ này', () {
      expect(inviteContactOf('+84 90 123 4567'), '0901234567');
      expect(inviteContactOf('84901234567'), '0901234567');
      expect(inviteContactOf('090.123.4567'), '0901234567');
    });

    test('email xuống chữ thường vì backend so bằng lower(email)', () {
      expect(inviteContactOf('  BAN@Email.COM '), 'ban@email.com');
    });
  });
}

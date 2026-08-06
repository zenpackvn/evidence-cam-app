import 'package:feature_shift/feature_shift.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bản sao của luật bên web (`web/src/lib/ec/validate.ts`). Lệch nhau là cùng
/// một địa chỉ được web nhận còn app từ chối — hoặc tệ hơn: app gửi đi một
/// chuỗi backend không khớp nổi với tài khoản nào.
void main() {
  group('isInviteContact', () {
    test('nhận email', () {
      for (final ok in ['ban@email.com', 'BAN@Email.COM', 'a.b+c@shop.vn']) {
        expect(isInviteContact(ok), isTrue, reason: ok);
      }
    });

    test('từ chối SĐT — backend khớp lời mời theo email và chỉ email', () {
      // Nhánh SĐT từng có ở đây và ở web. Nó tạo ra lời mời treo vĩnh viễn:
      // không tài khoản nào khớp được một dãy số, và mailer không có địa chỉ
      // nào để gửi tới. Web đã bỏ; app bỏ theo.
      for (final phone in [
        '0901234567',
        '+84 90 123 4567',
        '84901234567',
        '090-123-4567',
      ]) {
        expect(isInviteContact(phone), isFalse, reason: phone);
      }
    });

    test('từ chối thứ không phải email', () {
      for (final bad in ['', 'nguyen van a', 'abc@', '@x.com', 'x y']) {
        expect(isInviteContact(bad), isFalse, reason: bad);
      }
    });
  });

  group('inviteContactOf', () {
    test('email xuống chữ thường vì backend so bằng lower(email)', () {
      expect(inviteContactOf('  BAN@Email.COM '), 'ban@email.com');
    });

    test('thứ không nhận ra thì trả nguyên trạng, việc từ chối là của '
        'isInviteContact', () {
      expect(inviteContactOf(' 0901234567 '), '0901234567');
    });
  });
}

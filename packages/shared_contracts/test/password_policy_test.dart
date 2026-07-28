import 'package:flutter_test/flutter_test.dart';
import 'package:shared_contracts/shared_contracts.dart';

void main() {
  group('passwordProblem', () {
    test('chấp nhận mật khẩu đủ dài, có chữ và số', () {
      expect(passwordProblem('zenpack2026x'), isNull);
      expect(passwordProblem('Dong7Goi9Hang'), isNull);
    });

    test('từ chối khi ngắn hơn 8 ký tự', () {
      expect(passwordProblem('abc123'), PasswordProblem.tooShort);
      expect(passwordProblem('a1b2c3d'), PasswordProblem.tooShort);
      expect(passwordProblem(null), PasswordProblem.tooShort);
      expect(passwordProblem(''), PasswordProblem.tooShort);
    });

    test('từ chối khi thiếu chữ hoặc thiếu số', () {
      expect(passwordProblem('123456789'), PasswordProblem.needsLetterAndDigit);
      expect(passwordProblem('matkhaudai'), PasswordProblem.needsLetterAndDigit);
    });

    test('từ chối mật khẩu phổ biến', () {
      expect(passwordProblem('password123'), PasswordProblem.tooCommon);
      expect(passwordProblem('ZenPack123'), PasswordProblem.tooCommon);
    });

    test('từ chối mật khẩu lấy từ email', () {
      expect(
        passwordProblem('annguyen2026', email: 'annguyen@shop.vn'),
        PasswordProblem.tooCommon,
      );
    });

    test('email quá ngắn thì không dùng làm luật (tránh chặn oan)', () {
      // local-part 3 ký tự: "abc" xuất hiện trong vô số mật khẩu tử tế.
      expect(passwordProblem('abc12345x', email: 'abc@shop.vn'), isNull);
    });
  });
}

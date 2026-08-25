import 'package:ec_data/ec_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  group('isGoogleSignInCancellation', () {
    test('người dùng bấm ra ngoài hộp thoại là một cú huỷ', () {
      const error = GoogleSignInException(
        code: GoogleSignInExceptionCode.canceled,
        description: 'activity is cancelled by the user.',
      );

      expect(isGoogleSignInCancellation(error), isTrue);
    });

    test('mã canceled không kèm mô tả cũng là một cú huỷ', () {
      const error = GoogleSignInException(
        code: GoogleSignInExceptionCode.canceled,
      );

      expect(isGoogleSignInCancellation(error), isTrue);
    });

    // Đây là lượt hỏng thật quan sát được trên Android khi SHA-1 của bản cài
    // chưa đăng ký trên Firebase: Play services trả `UNREGISTERED_ON_API_CONSOLE`,
    // Credential Manager gói lại thành một `canceled` mang mã trạng thái GMS.
    test('lỗi Play services đội lốt canceled KHÔNG phải là huỷ', () {
      const error = GoogleSignInException(
        code: GoogleSignInExceptionCode.canceled,
        description: '[16] Account reauth failed.',
      );

      expect(isGoogleSignInCancellation(error), isFalse);
      expect(googleServicesStatusCode(error), 16);
    });

    test('mã lỗi khác canceled không bao giờ là huỷ', () {
      const error = GoogleSignInException(
        code: GoogleSignInExceptionCode.providerConfigurationError,
      );

      expect(isGoogleSignInCancellation(error), isFalse);
    });

    test('lỗi không phải của Google không bao giờ là huỷ', () {
      expect(isGoogleSignInCancellation(Exception('bất kỳ')), isFalse);
    });
  });

  group('googleServicesStatusCode', () {
    test('không có mã trạng thái thì về null', () {
      const error = GoogleSignInException(
        code: GoogleSignInExceptionCode.canceled,
        description: 'activity is cancelled by the user.',
      );

      expect(googleServicesStatusCode(error), isNull);
    });

    test('chỉ đọc mã ở ĐẦU mô tả', () {
      const error = GoogleSignInException(
        code: GoogleSignInExceptionCode.unknownError,
        description: 'No credential available: [8] Unknown error',
      );

      expect(googleServicesStatusCode(error), isNull);
    });
  });
}

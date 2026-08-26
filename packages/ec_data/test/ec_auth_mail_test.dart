import 'package:ec_data/ec_data.dart';
import 'package:flutter_test/flutter_test.dart';

/// Máy chủ mình giả lập: ghi lại nó có được gọi không, và có ném hay không.
class _MayChu implements EcAuthMailApi {
  _MayChu({this.hong = false});

  final bool hong;
  final List<String> nhatKy = [];

  @override
  Future<void> sendVerifyEmail() async {
    if (hong) throw StateError('503');
    nhatKy.add('verify');
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    if (hong) throw StateError('503');
    nhatKy.add('reset:$email');
  }
}

/// MAIL XÁC THỰC PHẢI ĐI QUA MÁY CHỦ MÌNH.
///
/// Firebase đã khoá phần thân của mẫu xác thực trong Console, nên để nó gửi là
/// gửi chữ mẫu của Google. Người dùng app và người dùng web phải nhận CÙNG MỘT
/// lá thư — và lá thư đó chỉ có ở đường của mình.
///
/// Ba ca dưới đây kiểm giao diện `EcAuthMailApi` chứ không dựng cả
/// `FirebaseEcAuth`: lớp đó đòi một `FirebaseAuth` thật ngay trong hàm dựng, và
/// một bộ giả cho toàn bộ SDK Firebase sẽ dài hơn phần đang kiểm nhiều lần.
/// Thứ đáng khoá ở đây là HỢP ĐỒNG giữa hai bên, và nó nằm gọn trong giao diện.
void main() {
  test('gửi xác minh gọi đúng tuyến của máy chủ mình', () async {
    final mayChu = _MayChu();
    await mayChu.sendVerifyEmail();
    expect(mayChu.nhatKy, ['verify']);
  });

  test('đặt lại mật khẩu mang theo đúng địa chỉ được yêu cầu', () async {
    final mayChu = _MayChu();
    await mayChu.sendPasswordReset('ai-do@test.co');
    expect(mayChu.nhatKy, ['reset:ai-do@test.co']);
  });

  /// Máy chủ hỏng thì NÉM, để lớp gọi biết mà rơi về Firebase.
  ///
  /// Nuốt lỗi ở đây là báo "đã gửi" cho một mail không bao giờ tới — và với
  /// người quên mật khẩu, đó là để họ ngồi chờ một lá thư không có.
  test('máy chủ hỏng thì ném ra, không nuốt', () async {
    final mayChu = _MayChu(hong: true);
    await expectLater(mayChu.sendVerifyEmail(), throwsA(isA<StateError>()));
    await expectLater(
      mayChu.sendPasswordReset('ai-do@test.co'),
      throwsA(isA<StateError>()),
    );
    expect(mayChu.nhatKy, isEmpty);
  });

  /// `EcApi` phải LÀ một `EcAuthMailApi`.
  ///
  /// Nếu ai đó đổi tên hàm hoặc bỏ `implements`, `main.dart` sẽ không biên dịch
  /// được — nhưng ca này nói ra lý do, còn lỗi biên dịch thì không.
  test('EcApi hiện thực đúng giao diện mà lớp xác thực cần', () {
    expect(buildApi(url: 'https://x.test') is EcAuthMailApi, isTrue);
  });
}

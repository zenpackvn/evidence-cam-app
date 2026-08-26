/// Một lượt khởi tạo DUY NHẤT cho `GoogleSignIn.instance`.
///
/// `GoogleSignIn` là singleton và tài liệu của nó nói thẳng: `initialize()`
/// phải gọi **đúng một lần**, gọi nhiều hơn là *undefined behavior*. Mỗi lượt
/// gọi thừa còn đăng ký thêm một người nghe vào luồng sự kiện xác thực, và
/// những người nghe đó không bao giờ được gỡ.
///
/// App từng gọi ở HAI chỗ với HAI cấu hình khác nhau: lượt đăng nhập bằng
/// Google khởi tạo không kèm `serverClientId`, còn lượt cắm Drive khởi tạo có.
/// Ai chạy trước thì cấu hình của người đó ở lại — nên người đăng nhập bằng
/// Google rồi mới vào Kho lưu trữ sẽ gặp một instance KHÔNG có
/// `serverClientId`, `serverAuthCode` về rỗng, và nhánh mã rỗng đọc đó là
/// "người dùng bấm Huỷ" rồi im lặng. Chạm vào Drive không ra gì, không một câu
/// báo nào — mà chỉ hỏng đúng cho người đăng nhập bằng Google.
///
/// Khởi tạo bằng cấu hình RỘNG NHẤT — luôn kèm `serverClientId` khi build có —
/// để một lượt duy nhất phục vụ được cả hai việc.
library;

import 'package:google_sign_in/google_sign_in.dart';

import 'ec_env.dart';

Future<void>? _initialized;

/// Đảm bảo `GoogleSignIn.instance` đã sẵn sàng, chạy thật sự đúng một lần.
///
/// Nhớ chính cái `Future` chứ không nhớ một cờ `bool`: hai lượt gọi sát nhau
/// (đăng nhập và cắm kho) cùng `await` một lượt khởi tạo, thay vì lượt sau
/// thấy cờ chưa kịp bật rồi khởi tạo lần hai.
///
/// Nhưng chỉ nhớ lượt THÀNH CÔNG. `initialize()` có thể hỏng vì thứ nhất thời
/// — Play services đang tự cập nhật, máy vừa mất mạng — và nếu cứ để cái
/// `Future` hỏng nằm lại thì mọi lượt bấm Google về sau `await` đúng lỗi cũ,
/// không bao giờ thử lại, cho tới khi người dùng tắt hẳn app. Hỏng thì quên
/// đi, để lượt bấm sau được khởi tạo lại từ đầu.
Future<void> ensureGoogleSignInReady() => _initialized ??= GoogleSignIn.instance
    .initialize(
      serverClientId: kGoogleServerClientId.isEmpty
          ? null
          : kGoogleServerClientId,
    )
    .onError<Object>((error, stack) {
      _initialized = null;
      Error.throwWithStackTrace(error, stack);
    });

/// Mã trạng thái của Google Play services nằm ở đầu phần mô tả, ví dụ
/// `[16] Account reauth failed.` — hoặc `null` khi mô tả không mang mã nào.
int? googleServicesStatusCode(GoogleSignInException error) {
  final match = RegExp(r'^\[(\d+)\]').firstMatch(error.description ?? '');
  return match == null ? null : int.tryParse(match.group(1)!);
}

/// `true` chỉ khi người dùng THẬT SỰ bỏ dở hộp thoại Google.
///
/// Trên Android không được tin mỗi mã `canceled`. Credential Manager gói MỌI
/// lượt hỏng của Play services vào `GetCredentialCancellationException`, và
/// plugin dịch trung thành thành `canceled`. Nên một bản cài chưa đăng ký SHA-1
/// trên Firebase về đây với đúng cái mã mà người dùng bấm ra ngoài cũng về — và
/// vì "huỷ" là im lặng theo thiết kế, nút Google trở thành một nút không làm gì
/// cả: không vào được, không một câu báo nào, không cả một dòng log.
///
/// Thứ còn phân biệt được là phần mô tả: lượt hỏng thật mang mã trạng thái GMS
/// ở đầu (`[16]`, `[8]`, …), còn người dùng bấm ra ngoài thì không.
bool isGoogleSignInCancellation(Object error) =>
    error is GoogleSignInException &&
    error.code == GoogleSignInExceptionCode.canceled &&
    googleServicesStatusCode(error) == null;

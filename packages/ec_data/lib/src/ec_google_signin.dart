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
Future<void> ensureGoogleSignInReady() =>
    _initialized ??= GoogleSignIn.instance.initialize(
      serverClientId: kGoogleServerClientId.isEmpty
          ? null
          : kGoogleServerClientId,
    );

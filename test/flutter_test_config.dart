import 'dart:async';

import 'package:google_fonts/google_fonts.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

/// Automatically loaded by the Flutter test runner for every test file under
/// this directory. Enables leak tracking globally — undisposed controllers,
/// subscriptions, and other disposable objects will fail the test.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  LeakTesting.enable();
  // `google_fonts` mặc định tải phông qua mạng khi chưa có sẵn trong assets.
  // Trong test thì mọi request HTTP trả 400, nên lượt tải ném lỗi và làm ĐỎ
  // những test chẳng liên quan gì tới phông — 25 test ở `ec_app_test.dart` đỏ
  // vì đúng lý do này.
  //
  // Tắt ở đây chứ không ở từng file: nó là thuộc tính của MÔI TRƯỜNG chạy test,
  // không phải của một bộ test nào. Trước đó chỉ `screens_capture_test.dart` tự
  // tắt cho riêng nó, nên mọi file thêm sau đều dẫm lại đúng cái bẫy đó.
  GoogleFonts.config.allowRuntimeFetching = false;
  await testMain();
}

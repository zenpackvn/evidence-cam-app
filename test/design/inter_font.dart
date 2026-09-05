import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Đường tới bộ chữ Inter dùng cho các ca golden.
///
/// Vì sao có tệp này (D-07): trước đây cả 62 ca golden thiết kế đều mang
/// `skip: !_hasInter`, và `_hasInter` chỉ bật khi biến môi trường
/// `EC_INTER_TTF` trỏ tới một tệp Inter có thật. KHÔNG NƠI NÀO đặt biến đó —
/// không máy dev, không workflow CI nào. Nên 62 ca tự bỏ qua, và bảng kết quả
/// vẫn đọc là "All tests passed".
///
/// Ba nơi cùng bỏ sót: máy dev thiếu biến, lượt test gốc của CI thiếu biến, và
/// job golden riêng của CI chạy ở `packages/app_ui` — một thư mục khác hẳn.
///
/// Bản Inter cần dùng NẰM SẴN TRONG REPO. Bắt người chạy phải tự trỏ biến môi
/// trường vào một tệp có sẵn là đặt một cái bẫy: quên thì không ai biết, vì
/// hình phạt là "bỏ qua trong im lặng" chứ không phải "đỏ".
const String interTrongRepo = 'assets/google_fonts/Inter-Regular.ttf';

/// Tệp Inter sẽ dùng, hoặc `null` nếu thật sự không tìm thấy ở đâu.
///
/// Biến môi trường vẫn được ưu tiên — có người cần chỉ vào một bản khác để so
/// sánh — nhưng nó là TUỲ CHỌN, không còn là điều kiện để ca chạy.
String? duongInter() {
  final moiTruong = Platform.environment['EC_INTER_TTF'];
  if (moiTruong != null && File(moiTruong).existsSync()) return moiTruong;
  if (File(interTrongRepo).existsSync()) return interTrongRepo;
  return null;
}

/// Có Inter để so pixel hay không. Nay gần như luôn `true`.
final bool coInter = duongInter() != null;

/// Nạp Inter vào harness. Gọi trong `setUpAll`.
Future<void> napInter() async {
  final duong = duongInter();
  if (duong == null) return;
  final bytes = File(duong).readAsBytesSync().buffer.asByteData();
  await (FontLoader('Inter')..addFont(Future.value(bytes))).load();
}

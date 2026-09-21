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

/// Ba độ đậm đi cùng bản Regular trong repo. Nạp CẢ BA vào cùng họ `Inter`:
/// bộ dựng test không tự làm đậm, nên chỉ nạp Regular là mọi tiêu đề
/// `FontWeight.w600/w700` vẽ bằng nét thường — và ảnh gốc (sinh 31/07 với đủ
/// độ đậm) lệch 1–4% ở MỌI màn chỉ vì thế. Đo 17/09 khi rà lại D-07.
///
/// Màn thiết kế còn dùng w500 (50 chỗ) và w800 (70 chỗ) — hai độ đậm app
/// KHÔNG đóng gói (không cần cho app), nên để riêng ở `test/design/fonts/`
/// (Inter 4.0, cùng bản 4.001 với ba tệp trong assets, giấy phép OFL kèm theo).
/// Thiếu chúng thì w500 vẽ bằng Regular, w800 bằng Bold — vẫn lệch 0,3–2%
/// ở mọi màn dù đã tắt nén.
const List<String> interTrongRepoCacDoDam = [
  'assets/google_fonts/Inter-Regular.ttf',
  'test/design/fonts/Inter-Medium.ttf',
  'assets/google_fonts/Inter-SemiBold.ttf',
  'assets/google_fonts/Inter-Bold.ttf',
  'test/design/fonts/Inter-ExtraBold.ttf',
];

/// Nạp Inter vào harness. Gọi trong `setUpAll`.
///
/// Có `EC_INTER_TTF` thì nạp đúng một tệp đó (người so sánh một bản khác tự
/// chịu độ đậm); không thì nạp đủ ba độ đậm trong repo.
Future<void> napInter() async {
  final duong = duongInter();
  if (duong == null) return;
  final loader = FontLoader('Inter');
  final cacTep = duong == interTrongRepo ? interTrongRepoCacDoDam : [duong];
  for (final tep in cacTep) {
    if (!File(tep).existsSync()) continue;
    final bytes = File(tep).readAsBytesSync().buffer.asByteData();
    loader.addFont(Future.value(bytes));
  }
  await loader.load();
}

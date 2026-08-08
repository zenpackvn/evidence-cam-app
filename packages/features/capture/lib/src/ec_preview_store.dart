/// Bản xem tạm: giữ clip trên máy trong đúng khoảng máy chủ còn đóng dấu.
///
/// Máy chủ CỐ TÌNH giấu link phát trong lúc `seal_status` là `pending` hoặc
/// `rendering` — bản đang nằm ở kho lúc đó chưa có giờ nung lên hình, phát ra
/// là đưa người bán cầm nhầm một file trông như bằng chứng. Đúng, nhưng nó bắt
/// người bán ngồi nhìn "đang đóng dấu thời gian…" trong khi **máy của họ vẫn
/// đang giữ nguyên đúng những byte đó**.
///
/// Nên: sau khi upload xong, thay vì xoá, clip được dời sang đây và đặt tên
/// theo `evidence_id` của máy chủ. Màn chi tiết mở nút Phát ngay từ bản này,
/// còn Sao chép link / Tải về vẫn khoá tới khi có bản đã niêm phong.
///
/// **Bất biến tuyệt đối**: bản ở đây là bản THÔ, không có dấu giờ trên hình.
/// Lối ra duy nhất của nó là màn phát trong app. Mọi nút xuất ra ngoài (chia
/// sẻ, lưu về thư viện, đính vào hồ sơ khiếu nại) phải đọc `mediaUrl` của máy
/// chủ — rò bản này ra ngoài là người bán gửi cho sàn một file trông y hệt
/// bằng chứng nhưng thiếu đúng thứ làm nó thành bằng chứng.
///
/// Thư mục RIÊNG, không dùng chung với thư mục hàng đợi: `_sweepOrphans` xoá
/// mọi tệp trong thư mục hàng đợi mà không task nào tham chiếu, nên để chung là
/// bản xem tạm bị quét sạch ngay lần mở app sau.
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:path_provider/path_provider.dart';

/// Ghi đè thư mục kho, chỉ dùng trong test — `path_provider` không có nền tảng
/// nào trả lời trong unit test, nên không có cái này thì mọi hàm ở đây im lặng
/// rơi vào nhánh nuốt lỗi và bài test xanh mà chẳng kiểm được gì.
@visibleForTesting
Directory? debugPreviewDir;

/// Trần tuổi của một bản xem tạm.
///
/// Lưới đỡ cho những bản không ai dọn: người bán không mở lại đơn đó nữa, hoặc
/// niêm phong hỏng nên `seal_status` nằm mãi ở `pending`. Sáu giờ là rộng rãi
/// so với đuôi chậm nhất đo được trên prod (51 phút) mà vẫn không để một ca
/// đóng hàng vài trăm clip lấp đầy bộ nhớ máy — hết chỗ là chính việc quay bị
/// chặn (FR-09).
const ecPreviewMaxAge = Duration(hours: 6);

Future<Directory> _previewDir() async {
  final dir =
      debugPreviewDir ??
      Directory(
        '${(await getApplicationDocumentsDirectory()).path}/ec_preview',
      );
  if (!dir.existsSync()) await dir.create(recursive: true);
  return dir;
}

/// Dời [fromPath] vào kho bản xem tạm dưới tên [evidenceId].
///
/// Dời chứ không chép: hai bản của cùng một clip trên cùng một máy là tốn chỗ
/// vô ích, mà chỗ trên máy đóng gói thì luôn thiếu.
///
/// Nuốt lỗi: giữ được bản xem tạm là điều tốt, không giữ được cũng chỉ quay về
/// đúng hành vi cũ (đợi máy chủ). Không có gì ở đây đáng làm hỏng một lượt
/// upload đã thành công.
Future<void> ecKeepPreview(String evidenceId, String fromPath) async {
  if (evidenceId.isEmpty) return;
  try {
    final source = File(fromPath);
    if (!source.existsSync()) return;
    final dir = await _previewDir();
    await source.rename('${dir.path}/$evidenceId${_ext(fromPath)}');
  } on Object {
    // Đổi tên hỏng (khác phân vùng, hết chỗ) — bỏ qua, bản trên máy chủ vẫn là
    // bản thật.
  }
}

/// Bản xem tạm đang có, theo `evidence_id` → đường dẫn tuyệt đối.
///
/// Đọc cả thư mục một lần thay vì hỏi từng clip: một đơn có vài chục dòng bằng
/// chứng, và `existsSync` từng dòng trong lúc dựng giao diện là vài chục lượt
/// chạm đĩa trên luồng UI.
Future<Map<String, String>> ecPreviews() async {
  try {
    final dir = await _previewDir();
    return {
      for (final file in dir.listSync().whereType<File>())
        _idOf(file.path): file.path,
    };
  } on Object {
    return const {};
  }
}

/// Xoá bản xem tạm của [evidenceId]. Gọi khi máy chủ đã có bản phát được —
/// từ giây đó bản trên máy chỉ còn là bản thô chiếm chỗ.
Future<void> ecDropPreview(String evidenceId) async {
  try {
    final dir = await _previewDir();
    for (final file in dir.listSync().whereType<File>()) {
      if (_idOf(file.path) == evidenceId) await file.delete();
    }
  } on Object {
    // Không xoá được thì lượt quét theo tuổi sẽ dọn.
  }
}

/// Dọn bản xem tạm quá [ecPreviewMaxAge]. Gọi lúc mở app.
Future<void> ecSweepPreviews() async {
  final cutoff = DateTime.now().subtract(ecPreviewMaxAge);
  try {
    final dir = await _previewDir();
    for (final file in dir.listSync().whereType<File>()) {
      if (file.statSync().modified.isBefore(cutoff)) await file.delete();
    }
  } on Object {
    // Thư mục không đọc được — không có gì để thu hồi.
  }
}

String _ext(String path) {
  final dot = path.lastIndexOf('.');
  final slash = path.lastIndexOf('/');
  return dot > slash && dot != -1 ? path.substring(dot) : '.mp4';
}

String _idOf(String path) {
  final name = path.split('/').last;
  final dot = name.lastIndexOf('.');
  return dot == -1 ? name : name.substring(0, dot);
}

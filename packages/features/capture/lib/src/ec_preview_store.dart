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
/// niêm phong hỏng nên `seal_status` nằm mãi ở `pending`.
///
/// Đây là lưới đỡ, KHÔNG phải cách dọn chính. Cách chính là [ecDropPreview]
/// gọi ngay khi biết máy chủ đã phát được — xem [ecReconcilePreviews]. Trần
/// cũ 6 giờ đủ rộng so với đuôi chậm nhất đo trên prod (51 phút), nhưng một
/// lượt niêm phong tắc lâu hơn thế là bản tạm bị xoá trong khi máy chủ VẪN
/// chưa có link: đúng lúc cần nhất thì không còn gì xem được, ngược hẳn với
/// việc kho này sinh ra để làm. 24 giờ vẫn chặn được một ca đóng hàng vài trăm
/// clip lấp đầy bộ nhớ (FR-09: hết chỗ là chặn cả việc quay) mà không cắt vào
/// khoảng chờ thật.
const ecPreviewMaxAge = Duration(hours: 24);

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
/// [tracking] là mã vận đơn của clip, ghi kèm vào tên tệp sau `__`. Nó là thứ
/// duy nhất nối một bản tạm về lại đơn của nó: tên tệp trước đây chỉ có
/// `evidence_id`, mà từ `evidence_id` thì không hỏi máy chủ được — không có
/// endpoint tra một bằng chứng lẻ. Có mã vận đơn thì [ecReconcilePreviews]
/// mới biết phải hỏi đơn nào. Thiếu nó (bản tạm của bản app cũ) cũng không
/// sao: bản đó rơi về lưới đỡ [ecPreviewMaxAge].
Future<void> ecKeepPreview(
  String evidenceId,
  String fromPath, {
  String? tracking,
}) async {
  if (evidenceId.isEmpty) return;
  try {
    final source = File(fromPath);
    if (!source.existsSync()) return;
    final dir = await _previewDir();
    final tag = _tagOf(tracking);
    await source.rename('${dir.path}/$evidenceId$tag${_ext(fromPath)}');
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

/// Mã vận đơn của những đơn đang còn bản tạm trên máy.
///
/// Dùng để thu hẹp lượt đối soát: chỉ hỏi máy chủ đúng những đơn có bản tạm,
/// thay vì hỏi cả trang danh sách.
Future<Set<String>> ecPreviewTrackings() async {
  try {
    final dir = await _previewDir();
    return {
      for (final file in dir.listSync().whereType<File>())
        ?_trackingOf(file.path),
    };
  } on Object {
    return const {};
  }
}

/// Xoá bản tạm của những clip máy chủ đã phát được, hỏi qua [orderEvidence].
///
/// Trước đây bản tạm chỉ được dọn khi người bán MỞ đúng đơn đó ra xem; ai
/// không mở lại thì bản tạm nằm trên máy tới khi hết hạn tuổi. Lượt này chạy
/// từ danh sách Vận đơn nên không cần vào đơn nữa.
///
/// [orders] là các đơn đang hiện trên danh sách, dạng `(mã vận đơn, id đơn)`.
/// Chỉ những đơn thật sự còn bản tạm mới bị hỏi, và tối đa [maxOrders] đơn mỗi
/// lượt — một lượt mở danh sách không được biến thành một tràng request.
///
/// [orderEvidence] trả về `(evidence_id, còn đang niêm phong?)` của một đơn.
/// Nuốt lỗi từng đơn: mạng hỏng thì để lượt sau, không có gì ở đây đáng làm
/// hỏng màn danh sách.
Future<void> ecReconcilePreviews(
  Iterable<(String tracking, String orderId)> orders,
  Future<List<(String id, bool sealing)>> Function(String orderId)
  orderEvidence, {
  int maxOrders = 5,
}) async {
  final pending = await ecPreviewTrackings();
  if (pending.isEmpty) return;
  var budget = maxOrders;
  for (final (tracking, orderId) in orders) {
    if (budget <= 0) return;
    if (!pending.contains(_normalizeTracking(tracking))) continue;
    budget--;
    try {
      for (final (id, sealing) in await orderEvidence(orderId)) {
        if (!sealing) await ecDropPreview(id);
      }
    } on Object {
      // Đơn này để lượt sau.
    }
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

/// Phần thân tên tệp, đã bỏ đuôi: `<evidence_id>` hoặc
/// `<evidence_id>__<mã vận đơn>`.
String _stemOf(String path) {
  final name = path.split('/').last;
  final dot = name.lastIndexOf('.');
  return dot == -1 ? name : name.substring(0, dot);
}

String _idOf(String path) {
  final stem = _stemOf(path);
  final tag = stem.indexOf(_tagSeparator);
  return tag == -1 ? stem : stem.substring(0, tag);
}

String? _trackingOf(String path) {
  final stem = _stemOf(path);
  final tag = stem.indexOf(_tagSeparator);
  if (tag == -1) return null;
  final tracking = stem.substring(tag + _tagSeparator.length);
  return tracking.isEmpty ? null : tracking;
}

const _tagSeparator = '__';

/// Mã vận đơn đưa vào tên tệp, đã bỏ những ký tự không được làm tên tệp và
/// chính chuỗi ngăn cách — mã lạ không được phép làm hỏng chỗ cắt.
String _tagOf(String? tracking) {
  if (tracking == null) return '';
  final safe = _normalizeTracking(tracking);
  return safe.isEmpty ? '' : '$_tagSeparator$safe';
}

/// Cùng một phép chuẩn hoá cho cả lúc ghi tên tệp lẫn lúc đối chiếu với mã
/// trên danh sách — hai bên lệch nhau là lượt đối soát không khớp được đơn nào.
String _normalizeTracking(String tracking) =>
    tracking.replaceAll(RegExp('[^A-Za-z0-9-]'), '');

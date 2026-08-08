import 'dart:io';

/// Máy chủ từ chối nhận clip vì shop đã vượt hạn mức video của tháng.
///
/// Khác MỌI lỗi upload khác ở một điểm quyết định: thử lại ngay không bao giờ
/// ăn thua. Hạn mức chỉ mở lại khi chủ shop mua thêm lượt hoặc sang tháng mới,
/// nên hàng đợi phải ĐỖ clip lại chứ không đếm nó vào số lần thất bại.
///
/// Sống ở package tính năng chứ không ở tầng app: hàng đợi cần phân biệt được
/// trường hợp này, mà `EcUploadQueue` thì không được phép import tầng app. Hiện
/// thực thật (`ApiEvidenceUploader`) implement giao diện dưới đây nên ném được
/// đúng kiểu này.
///
/// Trước đây hàng đợi dò bằng cách so chuỗi trong `error.toString()`. Cách đó
/// im lặng chết khi Dio bọc 403 thành "Máy chủ báo lỗi (mã 403)" — không còn
/// chữ `quota` nào, nên clip rơi vào nhánh `error` và người dùng đọc thành lỗi
/// máy chủ. Một kiểu dữ liệu thì không hỏng theo cách đó.
class EcQuotaExceededException implements Exception {
  const EcQuotaExceededException([this.message]);

  final String? message;

  @override
  String toString() =>
      message ?? 'video_quota_exceeded: shop đã hết hạn mức video tháng này';
}

/// Uploads a recorded evidence clip to the backend, reporting progress 0..1.
///
/// A seam so the offline queue can be tested with a fake and pointed at a real
/// backend. Concrete implementations (the presigned-R2 flow, the legacy
/// multipart POST) live in the app shell — they depend on the EC API client —
/// while this contract lives with the capture feature that produces clips.
// ignore: one_member_abstracts
abstract interface class EcEvidenceUploader {
  /// Uploads [file] for the order with tracking code [tracking] of the given
  /// video [type]; returns the server's **evidence id**. Throws on any failure
  /// so the queue can mark it errored.
  ///
  /// Phải là `evidence_id` chứ không phải một khoá lưu trữ nào khác: hàng đợi
  /// dùng nó để đặt tên bản xem tạm giữ lại trên máy (`ec_preview_store.dart`),
  /// và đó là khoá duy nhất khớp được clip trên máy với dòng bằng chứng máy chủ
  /// trả về.
  ///
  /// [shopId] and [capturedAt] are needed by the real backend flow (they scope
  /// the evidence to a shop/order); the legacy multipart uploader ignores them.
  /// [durationSeconds] is the recorded clip length, known at stop time; null
  /// for photos. [samplesJson] carries the device conditions sampled while
  /// recording (battery/network) — the backend stores them at presign time, so
  /// they must ride along with the bytes rather than be read at upload time:
  /// a clip queued offline uploads hours later, on a different battery and a
  /// different network.
  ///
  /// [videoTypeId] is the backend id of the chosen type, fixed at record time.
  /// It must ride along for the same reason the samples do — by upload time the
  /// type may have been renamed or deleted, so looking it up by [type] then
  /// silently loses the clip's type. Null for photos and for clips queued
  /// before this was carried, which fall back to the name lookup.
  Future<String> upload(
    File file, {
    required String tracking,
    required String type,
    String? shopId,
    String? videoTypeId,
    int? capturedAt,
    int? durationSeconds,
    String? samplesJson,
    void Function(double progress)? onProgress,
  });
}

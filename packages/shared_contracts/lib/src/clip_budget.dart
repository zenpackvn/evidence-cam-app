/// Ngân sách thời lượng một clip bằng chứng (product-spec 001 FR-17…FR-20).
library;

/// Dung lượng ~ mỗi giây quay theo độ phân giải.
///
/// PHẢI khớp `BYTES_PER_SECOND` của backend (`services/clip_budget.ts`) **và**
/// bitrate thật client đặt cho camera. Lệch một cái là con số "nặng ~X MB" nói
/// dối, và mức đề xuất mất luôn ý nghĩa.
const _bytesPerSecond = <String, int>{
  '240p': 50000,
  '480p': 100000,
  '720p': 250000,
};

const _fallbackBytesPerSecond = 250000;

/// Trần ngắn nhất cho phép đặt — dưới 1 phút thì một lần đóng gói bị cắt vụn
/// tới mức vô dụng làm bằng chứng.
const kMinClipSeconds = 60;

/// Thời lượng tối đa một clip: **5 phút, cố định**.
///
/// Không còn đặt được nữa. Màn chi tiết cửa hàng từng có một sheet chọn mốc,
/// nhưng con số ấy đi qua ba tầng (shop đặt → gói kẹp → server kẹp lại) nên
/// thứ hiện ra thường không phải thứ vừa chọn — đặt được mà không giữ được là
/// kiểu hỏng khó chịu hơn cả không cho đặt.
///
/// Đây là hằng số dùng ở MỌI nơi: dòng chữ trên màn cài đặt, và trần thật của
/// máy quay. Hai chỗ đọc hai nguồn là màn hình nói dối.
const kFixedClipSeconds = 300;

/// Trần dung lượng một ẢNH đính kèm: **5 MB, cố định**. Cùng lý do với
/// [kFixedClipSeconds].
const kFixedImageBytes = 5000000;

/// Khoảng hợp lệ của trần dung lượng mỗi tệp (FR-21). PHẢI khớp
/// `MIN_UPLOAD_BYTES` / `MAX_UPLOAD_BYTES` của backend, nếu không sheet chào
/// một mốc mà server trả về 400.
const kMinUploadBytes = 1000000;
const kMaxUploadBytes = 100000000;

/// Ba mốc, và chỉ mốc giữa là do shop chọn:
///   * [recommendedSeconds] — dài nhất mà clip vẫn **đính thẳng lên form khiếu
///     nại của sàn** được. Backend suy ra từ dung lượng sàn cho phép ÷ bitrate
///     của độ phân giải.
///   * [seconds] — trần shop đang áp dụng (đã kẹp vào trần gói).
///   * [planMaxSeconds] — trần cứng của gói cước; không đặt vượt.
///
/// Vượt [recommendedSeconds] **không bị chặn** — chỉ cảnh báo, vì bằng chứng
/// vẫn gửi được bằng link hồ sơ (FR-07), chỉ là không đính trực tiếp được.
class ClipBudget {
  const ClipBudget({
    required this.seconds,
    required this.recommendedSeconds,
    required this.planMaxSeconds,
    required this.maxImageBytes,
    required this.maxVideoBytes,
    required this.uploadBytes,
    this.platformLimitsVerified = true,
  });

  /// Giá trị dùng khi chưa gọi được backend (mock thiết kế, test widget).
  /// Bám mức Shopee + 720p + gói Cơ bản.
  static const fallback = ClipBudget(
    seconds: 120,
    recommendedSeconds: 120,
    planMaxSeconds: 900,
    // Ảnh đính kèm nhẹ hơn clip cả bậc — 5MB là mức đề xuất, 10MB cũ chỉ là
    // trần chung cũ dùng lại cho ảnh.
    maxImageBytes: 5000000,
    maxVideoBytes: 30000000,
    uploadBytes: 10000000,
  );

  /// Decimal MB, không phải MiB — sàn công bố "30 MB/video" theo nghĩa thập
  /// phân, và [estimatedBytes] cũng chia thập phân. Trộn MiB vào là nhãn "nặng
  /// ~X MB" lệch với chính con số giới hạn ngay bên cạnh nó.
  static String megabytesLabel(int bytes) {
    final mb = bytes / 1000000;
    return mb >= 10 ? mb.round().toString() : mb.toStringAsFixed(1);
  }

  final int seconds;
  final int recommendedSeconds;
  final int planMaxSeconds;
  final int maxImageBytes;
  final int maxVideoBytes;

  /// Trần dung lượng một tệp bằng chứng shop đang áp dụng (FR-21). Backend đã
  /// kẹp vào [kMinUploadBytes]..[kMaxUploadBytes], app dùng thẳng.
  final int uploadBytes;

  /// false = giới hạn của sàn này chưa đối chiếu tài liệu Seller Center, đang
  /// mượn bộ thận trọng nhất. UI nói rõ để chủ shop không tin nhầm.
  final bool platformLimitsVerified;

  Duration get maxRecording => Duration(seconds: seconds);

  /// Shop đã chỉnh vượt mức đính-thẳng-lên-sàn được → hiện cảnh báo vàng.
  bool get exceedsRecommended => seconds > recommendedSeconds;

  /// Trần tệp shop đặt đã vượt giới hạn ảnh của sàn → cảnh báo vàng thứ hai:
  /// tệp cỡ đó vẫn lưu được, chỉ là không đính thẳng lên form khiếu nại.
  bool get exceedsRecommendedUpload => uploadBytes > maxImageBytes;

  /// Dung lượng ước tính của một clip dài [forSeconds] ở [resolution].
  static int estimatedBytes(int forSeconds, String resolution) =>
      forSeconds * (_bytesPerSecond[resolution] ?? _fallbackBytesPerSecond);

  ClipBudget copyWith({int? seconds, int? uploadBytes}) => ClipBudget(
    seconds: seconds ?? this.seconds,
    recommendedSeconds: recommendedSeconds,
    planMaxSeconds: planMaxSeconds,
    maxImageBytes: maxImageBytes,
    maxVideoBytes: maxVideoBytes,
    uploadBytes: uploadBytes ?? this.uploadBytes,
    platformLimitsVerified: platformLimitsVerified,
  );
}

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
    this.platformLimitsVerified = true,
  });

  /// Giá trị dùng khi chưa gọi được backend (mock thiết kế, test widget).
  /// Bám mức Shopee + 720p + gói Cơ bản.
  static const fallback = ClipBudget(
    seconds: 120,
    recommendedSeconds: 120,
    planMaxSeconds: 900,
    maxImageBytes: 10000000,
    maxVideoBytes: 30000000,
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

  /// false = giới hạn của sàn này chưa đối chiếu tài liệu Seller Center, đang
  /// mượn bộ thận trọng nhất. UI nói rõ để chủ shop không tin nhầm.
  final bool platformLimitsVerified;

  Duration get maxRecording => Duration(seconds: seconds);

  /// Shop đã chỉnh vượt mức đính-thẳng-lên-sàn được → hiện cảnh báo vàng.
  bool get exceedsRecommended => seconds > recommendedSeconds;

  /// Dung lượng ước tính của một clip dài [forSeconds] ở [resolution].
  static int estimatedBytes(int forSeconds, String resolution) =>
      forSeconds * (_bytesPerSecond[resolution] ?? _fallbackBytesPerSecond);

  ClipBudget copyWith({int? seconds}) => ClipBudget(
    seconds: seconds ?? this.seconds,
    recommendedSeconds: recommendedSeconds,
    planMaxSeconds: planMaxSeconds,
    maxImageBytes: maxImageBytes,
    maxVideoBytes: maxVideoBytes,
    platformLimitsVerified: platformLimitsVerified,
  );
}

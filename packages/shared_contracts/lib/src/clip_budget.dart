/// Ngân sách thời lượng một clip bằng chứng (product-spec 001 FR-17…FR-20).
///
/// Từ 2026-08-07 ở đây KHÔNG còn con số dung lượng nào. Gói cước tính theo SỐ
/// VIDEO mỗi tháng, nên byte không còn là chính sách ở bất cứ đâu: trần mỗi tệp
/// do shop đặt, giới hạn dung lượng của sàn TMĐT, và "mức đề xuất thời lượng"
/// suy ra từ hai thứ đó — bỏ hết. Một tệp nặng bao nhiêu cũng gửi được; một
/// video vẫn chỉ trừ đúng một suất.
///
/// Còn lại đúng một đại lượng: clip dài bao nhiêu giây.
library;

/// Trần ngắn nhất cho phép đặt — dưới 1 phút thì một lần đóng gói bị cắt vụn
/// tới mức vô dụng làm bằng chứng. PHẢI khớp `MIN_CLIP_SECONDS` của backend.
const kMinClipSeconds = 60;

/// Thời lượng tối đa một clip: **5 phút, cố định**.
///
/// Không đặt được nữa. Màn chi tiết cửa hàng từng có một sheet chọn mốc, nhưng
/// con số ấy đi qua ba tầng (shop đặt → gói kẹp → server kẹp lại) nên thứ hiện
/// ra thường không phải thứ vừa chọn — đặt được mà không giữ được là kiểu hỏng
/// khó chịu hơn cả không cho đặt.
///
/// Đây là hằng số dùng ở MỌI nơi: dòng chữ trên màn cài đặt, và trần thật của
/// máy quay. Hai chỗ đọc hai nguồn là màn hình nói dối.
const kFixedClipSeconds = 300;

/// Trần thời lượng một clip mà shop đang áp dụng.
///
/// Chỉ còn một trường. Trước đây lớp này còn mang `maxImageBytes`,
/// `maxVideoBytes`, `uploadBytes` và `recommendedSeconds` để dựng nhãn
/// "nặng ~X MB" cùng hai cảnh báo vàng về mức đính thẳng lên sàn — tất cả đã bỏ
/// cùng lượt với quota theo byte.
class ClipBudget {
  const ClipBudget({required this.seconds, required this.planMaxSeconds});

  /// Giá trị dùng khi chưa gọi được backend (mock thiết kế, test widget).
  static const fallback = ClipBudget(
    seconds: kFixedClipSeconds,
    planMaxSeconds: kFixedClipSeconds,
  );

  /// Trần shop đang áp dụng, giây — backend đã kẹp vào
  /// [kMinClipSeconds]..[kFixedClipSeconds], app dùng thẳng.
  final int seconds;

  /// Trần cứng chung mọi gói, giây.
  final int planMaxSeconds;

  Duration get maxRecording => Duration(seconds: seconds);

  ClipBudget copyWith({int? seconds}) =>
      ClipBudget(seconds: seconds ?? this.seconds, planMaxSeconds: planMaxSeconds);
}

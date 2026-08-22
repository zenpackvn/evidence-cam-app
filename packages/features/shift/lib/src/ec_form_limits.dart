/// Trần độ dài cho các ô nhập của luồng tài khoản.
///
/// Sống ở MỘT chỗ vì cùng một ô email xuất hiện ở ba màn (đăng nhập, đăng ký,
/// quên mật khẩu) và ba trần khác nhau cho cùng một thứ là ba cách hỏng khác
/// nhau: gõ được ở màn này, bị cắt ở màn kia.
///
/// Đây là trần CHẶN LÚC GÕ, không phải luật nghiệp vụ. Luật nghiệp vụ (mật khẩu
/// phải có chữ và số, email phải đúng dạng) nằm ở validator; trần này chỉ để
/// một cú dán nhầm nguyên trang văn bản không đi tới được máy chủ.
library;

/// 254 là trần của một địa chỉ email theo RFC 5321 — dài hơn thì không máy chủ
/// thư nào nhận, nên chặn ở đây là chặn đúng chỗ.
const int kEmailMaxLength = 254;

/// Firebase nhận mật khẩu dài hơn nhiều, nhưng quá 64 ký tự thì không còn là
/// mật khẩu người ta gõ được nữa — gần như luôn là một cú dán nhầm.
const int kPasswordMaxLength = 64;

/// Họ tên. Đủ cho tên đầy đủ kèm chức danh; dài hơn là dán nhầm.
const int kNameMaxLength = 60;

/// Số điện thoại: 15 chữ số là trần của E.164, cộng chỗ cho dấu `+`, khoảng
/// trắng và gạch nối người ta quen gõ.
const int kPhoneMaxLength = 20;

/// Ô tìm kiếm (mã vận đơn, tên đơn). Mã vận đơn dài nhất của các sàn còn chưa
/// tới 40 ký tự.
const int kSearchMaxLength = 64;

/// Số chữ số tối thiểu/tối đa của một số điện thoại dùng được, sau khi bỏ hết
/// dấu cách và ký tự trang trí.
const int kPhoneMinDigits = 8;
const int kPhoneMaxDigits = 15;

/// Số điện thoại có dùng được không. Ô này KHÔNG bắt buộc, nên chuỗi rỗng là
/// hợp lệ — chỉ khi người dùng đã gõ gì đó mới xét.
bool isPlausiblePhone(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return true;
  // Chấp nhận dấu `+` mở đầu, khoảng trắng, `.`, `-`, `(`, `)` — thứ người ta
  // thật sự gõ. Mọi ký tự khác là sai.
  if (!RegExp(r'^\+?[\d\s.\-()]+$').hasMatch(trimmed)) return false;
  final digits = trimmed.replaceAll(RegExp(r'\D'), '').length;
  return digits >= kPhoneMinDigits && digits <= kPhoneMaxDigits;
}

/// Tên cửa hàng. Máy chủ chỉ đòi khác rỗng; trần này là để một cú dán nhầm
/// không đi tới đó.
const int kShopNameMaxLength = 60;

/// Tên loại video ("Đóng hàng đi", "Trả hàng"…). Ngắn hơn tên cửa hàng vì nó
/// còn phải vừa một viên chip trên màn quay.
const int kVideoTypeNameMaxLength = 40;

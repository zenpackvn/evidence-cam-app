/// Chính sách mật khẩu — dùng chung cho màn đăng ký (`feature_shift`) và màn
/// đổi mật khẩu (`feature_account`).
///
/// Firebase chỉ chặn dưới 6 ký tự; đây là mức của sản phẩm. Phải khớp bản sao
/// bên web (`evidence-website/public/js/validate.js`) — đổi một bên thì đổi cả
/// hai, nếu không người dùng đăng ký được trên web lại bị app từ chối.
///
/// Đây là lớp lịch sự với người dùng, KHÔNG phải lớp phòng thủ: ai gọi thẳng
/// REST của Firebase thì bỏ qua được hết. Phòng thủ thật là **Firebase password
/// policy** bật trong console (xem technical-spec/third-party-status.md §7).
library;

/// Độ dài tối thiểu. Cố ý không đặt trần: mật khẩu dài là mật khẩu tốt.
const int kMinPasswordLength = 8;

/// Lý do một mật khẩu bị từ chối. Tầng gọi tự dịch sang chuỗi l10n.
enum PasswordProblem { tooShort, needsLetterAndDigit, tooCommon }

/// Mật khẩu bị đoán ra ngay từ lần thử đầu.
///
/// ponytail: 20 chuỗi phổ biến nhất là đủ — nhồi cả rockyou vào app chỉ làm
/// phình bundle, chặn thật thuộc về Firebase.
const Set<String> _commonPasswords = {
  '12345678',
  '123456789',
  '1234567890',
  'password',
  'password1',
  'password123',
  'qwerty123',
  'qwertyuiop',
  '11111111',
  '00000000',
  '88888888',
  '12341234',
  'matkhau',
  'matkhau123',
  'abc12345',
  'iloveyou',
  'admin123',
  'zenpack',
  'zenpack123',
  'shopee123',
};

/// Trả về lý do từ chối, hoặc `null` nếu mật khẩu đạt.
///
/// [email] (tuỳ chọn) để chặn mật khẩu lấy thẳng từ địa chỉ email —
/// `an.nguyen@shop.vn` thì `annguyen123` bị từ chối.
PasswordProblem? passwordProblem(String? value, {String? email}) {
  final password = value ?? '';
  if (password.length < kMinPasswordLength) return PasswordProblem.tooShort;

  final hasLetter = RegExp('[a-zA-Z]').hasMatch(password);
  final hasDigit = RegExp(r'\d').hasMatch(password);
  if (!hasLetter || !hasDigit) return PasswordProblem.needsLetterAndDigit;

  final lower = password.toLowerCase();
  if (_commonPasswords.contains(lower)) return PasswordProblem.tooCommon;

  final local = (email ?? '').split('@').first.toLowerCase();
  if (local.length >= 4 && lower.contains(local)) {
    return PasswordProblem.tooCommon;
  }

  return null;
}

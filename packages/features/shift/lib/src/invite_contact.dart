/// Luật cho ô "email hoặc SĐT" của màn mời thành viên.
///
/// Backend khớp lời mời theo `uid OR lower(email) OR phone`
/// (`services/invites.ts`), nên hai thứ phải đúng trước khi gửi đi:
///
/// - **Định dạng.** Thứ không phải email cũng không phải SĐT chỉ tạo ra một lời
///   mời treo vĩnh viễn: không có `@` thì mailer bỏ qua, không gửi mail nào cả,
///   mà cũng chẳng tài khoản nào khớp được nó. Không ai được báo gì.
/// - **Chuẩn hoá.** "+84 90 123 4567" và "0901234567" là cùng một số với con
///   người nhưng là hai chuỗi khác nhau với SQLite. Số lưu trong `accounts` đã
///   qua bộ chuẩn hoá này, nên số đem đi mời cũng phải qua.
///
/// Bản sao của `evidence-website/web/src/lib/ec/validate.ts` — sửa một bên thì
/// sửa cả hai, lệch nhau là người mời từ app và từ web nhận kết quả khác nhau.
library;

/// Bỏ ký tự trình bày và đưa tiền tố +84/84 về số 0 đứng đầu.
String normalizeInvitePhone(String raw) => raw
    .replaceAll(RegExp(r'[\s.\-()]'), '')
    .replaceFirst(RegExp(r'^\+?84'), '0');

/// SĐT di động/cố định VN: số 0 rồi 8–10 chữ số nữa.
bool isValidInvitePhone(String raw) =>
    RegExp(r'^0\d{8,10}$').hasMatch(normalizeInvitePhone(raw));

bool isValidInviteEmail(String raw) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(raw.trim());

bool isInviteContact(String raw) =>
    isValidInviteEmail(raw) || isValidInvitePhone(raw);

/// Chuỗi thật sự gửi lên `POST /shops/:id/invites`: email viết thường, SĐT đã
/// chuẩn hoá. Thứ không nhận ra thì trả nguyên trạng — việc từ chối là của
/// [isInviteContact], không phải của hàm này.
String inviteContactOf(String raw) {
  final value = raw.trim();
  if (isValidInviteEmail(value)) return value.toLowerCase();
  if (isValidInvitePhone(value)) return normalizeInvitePhone(value);
  return value;
}

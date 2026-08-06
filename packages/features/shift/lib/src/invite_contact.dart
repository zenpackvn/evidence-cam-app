/// Luật cho ô "email" của màn mời thành viên.
///
/// Backend khớp lời mời theo **email** và chỉ email (`services/invites.ts`):
/// địa chỉ phải đã có tài khoản ZenPack, nếu không nó trả `account_not_found`.
/// Nên hai thứ phải đúng trước khi gửi đi:
///
/// - **Định dạng.** Thứ không có `@` thì mailer bỏ qua, không gửi mail nào cả,
///   mà cũng chẳng tài khoản nào khớp được nó. Không ai được báo gì.
/// - **Chuẩn hoá.** Email lưu trong `accounts` là chữ thường, nên địa chỉ đem
///   đi mời cũng phải viết thường thì SQLite mới khớp.
///
/// **Số điện thoại không còn được nhận.** Nhánh SĐT từng có ở đây (và ở web)
/// tạo ra những lời mời treo vĩnh viễn: backend không tra được tài khoản nào
/// theo số, mailer không có địa chỉ để gửi. Web đã bỏ; app bỏ theo.
///
/// Bản sao của `evidence-website/web/src/lib/ec/validate.ts` — sửa một bên thì
/// sửa cả hai, lệch nhau là người mời từ app và từ web nhận kết quả khác nhau.
library;

bool isValidInviteEmail(String raw) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(raw.trim());

bool isInviteContact(String raw) => isValidInviteEmail(raw);

/// Chuỗi thật sự gửi lên `POST /shops/:id/invites`: email viết thường. Thứ
/// không nhận ra thì trả nguyên trạng — việc từ chối là của [isInviteContact],
/// không phải của hàm này.
String inviteContactOf(String raw) {
  final value = raw.trim();
  return isValidInviteEmail(value) ? value.toLowerCase() : value;
}

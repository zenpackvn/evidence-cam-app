# Checklist QA — Xác thực tài khoản — Đăng ký, Đăng nhập & Bảo mật (001-auth)

---

## Điều kiện tiên quyết

- [ ] Có thiết bị iOS và Android để kiểm tra song song.
- [ ] Có tài khoản Google, Apple (iOS) và Facebook hợp lệ để kiểm tra đăng nhập mạng xã hội.
- [ ] Chuẩn bị tài khoản thử nghiệm đã đăng ký sẵn (bằng email/mật khẩu).
- [ ] Chuẩn bị tài khoản đã mua Premium/Dấu để kiểm tra khôi phục giao dịch.
- [ ] Có khả năng tắt Wi-Fi và dữ liệu di động để kiểm tra trường hợp offline.
- [ ] Có thể truy cập hòm thư email thử nghiệm để kiểm tra link xác nhận và link đặt lại mật khẩu.

---

## Luồng chính — Đăng ký (Happy Path)

- [ ] Đăng ký thành công bằng email hợp lệ, mật khẩu ≥6 ký tự, username 3–30 ký tự, tick xác nhận đủ 13 tuổi → tạo tài khoản gói Free, gửi email xác nhận. ✅
- [ ] Đăng ký thành công bằng Google → bỏ qua xác nhận email, vào chọn username. 🔲
- [ ] Đăng ký thành công bằng Apple → bỏ qua xác nhận email, vào chọn username. 🔲
- [ ] Đăng ký thành công bằng Facebook → bỏ qua xác nhận email, vào chọn username. 🔲
- [ ] Bỏ qua bước chọn ảnh đại diện → đăng ký vẫn hoàn tất, hiển thị ảnh mặc định. ✅
- [ ] Tài khoản mới vừa tạo mặc định ở gói Free (giới hạn 30 tem/tháng, 10 thư/tháng). ✅

---

## Luồng chính — Đăng nhập & Phiên (Happy Path)

- [ ] Đăng nhập thành công bằng email và mật khẩu đúng → vào màn hình chính. ✅
- [ ] Đăng nhập thành công bằng Google (đúng phương thức đã đăng ký) → vào app ngay. 🔲
- [ ] Đăng nhập thành công bằng Apple (đúng phương thức đã đăng ký) → vào app ngay. 🔲
- [ ] Đăng nhập thành công bằng Facebook (đúng phương thức đã đăng ký) → vào app ngay. 🔲
- [ ] Đóng app rồi mở lại trong vòng 90 ngày → vào thẳng màn hình chính, không cần đăng nhập lại. 🔲
- [ ] Đăng nhập bằng Facebook với tài khoản không chia sẻ email → vào app bình thường, không yêu cầu bổ sung email. 🔲

---

## Luồng chính — Bảo mật & Khôi phục (Happy Path)

- [ ] Yêu cầu đặt lại mật khẩu → hệ thống gửi link, không tiết lộ email có tồn tại không. ✅
- [ ] Đổi mật khẩu thành công → nhập đúng mật khẩu cũ, nhập mật khẩu mới → thiết bị khác bị đăng xuất. 🔲
- [ ] Liên kết thêm Google vào tài khoản email/mật khẩu → tài khoản có thêm phương thức Google. 🔲
- [ ] Đăng nhập thành công → khôi phục tự động giao dịch mua Premium/Dấu trên cùng App Store/Google Play. 🔲

---

## Luồng thất bại & Validation — Đăng ký

- [ ] Nhập username đã tồn tại → thông báo "Tên người dùng đã tồn tại" ngay tại ô username; không tạo tài khoản. ✅
- [ ] Nhập username < 3 ký tự → báo lỗi tại ô username, không cho tiếp tục. ✅
- [ ] Nhập username > 30 ký tự → báo lỗi tại ô username, không cho tiếp tục. ✅
- [ ] Mật khẩu < 6 ký tự → thông báo "Mật khẩu phải có ít nhất 6 ký tự" ngay dưới ô mật khẩu. ✅
- [ ] Không tick xác nhận đủ 13 tuổi → không hoàn tất được đăng ký. ✅
- [ ] Email đã có tài khoản → thông báo "Email này đã có tài khoản" ngay dưới ô email; không tạo tài khoản mới. ✅
- [ ] Xác nhận mật khẩu không khớp → thông báo "Mật khẩu không khớp" ngay dưới ô xác nhận; không tạo tài khoản. ✅

---

## Luồng thất bại & Validation — Đăng nhập

- [ ] Email để trống → thông báo "Vui lòng nhập email" ngay dưới ô email; không chuyển màn hình. ✅
- [ ] Email sai định dạng (ví dụ: "abcxyz") → thông báo "Email không hợp lệ" ngay dưới ô email. ✅
- [ ] Mật khẩu để trống → thông báo "Vui lòng nhập mật khẩu" ngay dưới ô mật khẩu. ✅
- [ ] Sai email hoặc mật khẩu (đúng định dạng) → thông báo "Đăng nhập không thành công. Sai email hoặc mật khẩu." ở cấp toàn biểu mẫu (không gắn dưới ô nào). ✅
- [ ] Nhập sai mật khẩu lần 1–4 → hiển thị số lần thử còn lại sau mỗi lần sai. ✅
- [ ] Nhập sai mật khẩu 5 lần liên tiếp → tài khoản bị khoá 15 phút, màn hình hiển thị đếm ngược. ✅
- [ ] Đăng nhập bằng sai phương thức (ví dụ: đăng ký email nhưng chọn Facebook) → thông báo tài khoản không liên kết; gợi ý phương thức đúng. 🔲
- [ ] Phiên hết hạn (>90 ngày không hoạt động) → mở app đưa về màn hình đăng nhập. 🚫

---

## Luồng thất bại & Validation — Đặt lại mật khẩu

- [ ] Email để trống ở màn hình quên mật khẩu → thông báo "Vui lòng nhập email" ngay tại ô. ✅
- [ ] Email sai định dạng ở màn hình quên mật khẩu → thông báo "Email không hợp lệ". ✅
- [ ] Email không tồn tại trong hệ thống → vẫn hiển thị "Nếu email tồn tại bạn sẽ nhận link" (không tiết lộ). ✅
- [ ] Link đặt lại dùng lần 2 → thông báo link không còn hợp lệ. 🔲
- [ ] Link đặt lại sau hơn 24 giờ → thông báo hết hạn, gợi ý gửi link mới. 🚫

---

## Luồng thất bại & Validation — Bảo mật

- [ ] Đổi mật khẩu với mật khẩu hiện tại sai → hệ thống từ chối, yêu cầu nhập lại đúng. ✅
- [ ] Huỷ liên kết phương thức đăng nhập duy nhất → hệ thống từ chối, giải thích cần ít nhất một phương thức. ✅
- [ ] Xóa tài khoản → nhấn Huỷ ở bước xác nhận → tài khoản không bị xóa, quay lại màn hình trước. ✅
- [ ] Xóa tài khoản → nhấn Xác nhận → tài khoản bị xóa, đăng xuất ngay; không đăng nhập lại được. ✅

---

## Trường hợp biên (Edge Cases)

- [ ] Người chưa đăng nhập cố truy cập tính năng trong app → luôn bị giữ ở màn hình đăng nhập. ✅
- [ ] Người dùng đã đăng ký email nhưng chưa xác nhận email → cố dùng tính năng tạo tem/gửi thư → bị chặn, có nút gửi lại email. ✅
- [ ] Mỗi nút đăng nhập (Google, Apple, Facebook, email) có trạng thái "đang xử lý" riêng; nhấn Google → chỉ nút Google loading, các nút khác không ảnh hưởng. ✅
- [ ] Đăng nhập bằng Facebook không chia sẻ email → vào app bình thường, không yêu cầu email bổ sung. 🔲
- [ ] Lỗi không xác định từ máy chủ trong khi đăng nhập → hiển thị "Đăng nhập không thành công. Vui lòng thử lại." kèm nút Thử lại; form không bị xóa. 🚫
- [ ] Thoát app giữa chừng khi đang điền form đăng nhập/đăng ký → mở lại app, nội dung đã nhập vẫn còn trên form. ✅
- [ ] Tài khoản bị đăng xuất từ xa (đổi mật khẩu trên thiết bị khác) → mở lại app → đưa về màn hình đăng nhập. 🔲
- [ ] Thông báo lỗi tiếng Việt và kiểu hiển thị (dưới ô / cấp biểu mẫu) thống nhất trên Android và iOS. 🔲

---

## Trường hợp offline

- [ ] Tắt mạng → nhấn Đăng nhập → thông báo "Không có kết nối. Vui lòng thử lại khi có mạng.", không gửi yêu cầu. 🔲
- [ ] Tắt mạng → nhấn Đăng ký → thông báo offline, dữ liệu form giữ nguyên. 🔲
- [ ] Tắt mạng → yêu cầu đặt lại mật khẩu → thông báo offline, ô email giữ nguyên. 🔲
- [ ] Mất mạng khi đang điền form → nội dung đã nhập không bị mất sau khi có mạng trở lại. 🔲
- [ ] Đã đăng nhập → mất mạng → mở lại app khi có mạng → vẫn đăng nhập, không bị yêu cầu xác thực lại. 🔲

---

## Ghi chú tự động hóa

- ✅ Maestro automatable — Validation ô nhập liệu (email trống, email sai định dạng, mật khẩu trống, mật khẩu < 6 ký tự, xác nhận mật khẩu không khớp, username trùng, username quá ngắn/dài, email đã tồn tại, sai thông tin đăng nhập cấp biểu mẫu); đăng nhập email thành công; khoá tạm và đếm lần thử; xóa tài khoản; trạng thái gói Free sau đăng ký; bỏ qua ảnh đại diện; không cho huỷ phương thức duy nhất; người chưa đăng nhập không vào được tính năng.
- 🔲 Manual only — Đăng nhập/đăng ký bằng Google, Apple, Facebook (yêu cầu xác thực OS/nền tảng thật); kiểm tra link email thật; phiên 90 ngày; đăng xuất thiết bị từ xa; offline (tắt mạng thực); thông báo nhất quán Android vs iOS; Facebook không chia sẻ email.
- 🚫 Not automatable — Phiên hết hạn sau 90 ngày không hoạt động (không thể mô phỏng thời gian); link đặt lại hết hạn sau 24 giờ (phụ thuộc thời gian thực); lỗi server không xác định (phụ thuộc trạng thái server).

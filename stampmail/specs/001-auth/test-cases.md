# Test Cases — Xác thực tài khoản — Đăng ký, Đăng nhập & Bảo mật (001-auth)

---

## TC-01-001: Đăng ký thành công bằng email và mật khẩu

**AC liên quan:** AC-01, BR-02, BR-05
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng chưa có tài khoản.
- Có kết nối mạng.

### Act (Thực hiện)
- Mở màn hình đăng ký.
- Nhập email hợp lệ chưa đăng ký.
- Nhập mật khẩu ít nhất sáu ký tự.
- Nhập lại mật khẩu khớp với ô trên.
- Chọn username chưa tồn tại (3–30 ký tự).
- Tick xác nhận đủ 13 tuổi.
- Nhấn nút Đăng ký.

### Assert (Kiểm tra)
- Hệ thống tạo tài khoản thành công ở gói Free.
- Màn hình hiển thị thông báo yêu cầu kiểm tra hộp thư xác nhận.
- Email xác nhận được gửi đến địa chỉ vừa nhập.
- Người dùng chưa vào được các tính năng đòi hỏi xác nhận email.

---

## TC-01-002: Đăng ký thành công bằng Google

**AC liên quan:** AC-02, BR-01, BR-05
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng chưa có tài khoản.
- Có tài khoản Google hợp lệ trên thiết bị.

### Act (Thực hiện)
- Mở màn hình đăng ký.
- Nhấn nút "Đăng ký bằng Google".
- Chọn tài khoản Google và xác thực thành công.

### Assert (Kiểm tra)
- Hệ thống tạo tài khoản ở gói Free.
- Bỏ qua bước xác nhận email.
- Người dùng được đưa đến màn hình chọn username.

---

## TC-01-003: Đăng ký thành công bằng Apple

**AC liên quan:** AC-02, BR-01
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Thiết bị iOS với tài khoản Apple đã đăng nhập.
- Người dùng chưa có tài khoản StampMail.

### Act (Thực hiện)
- Mở màn hình đăng ký.
- Nhấn nút "Đăng ký bằng Apple".
- Xác thực Apple thành công.

### Assert (Kiểm tra)
- Hệ thống tạo tài khoản ở gói Free, bỏ qua xác nhận email.
- Người dùng được đưa đến màn hình chọn username.

---

## TC-01-004: Đăng ký thành công bằng Facebook

**AC liên quan:** AC-02, BR-01
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng chưa có tài khoản StampMail.
- Có tài khoản Facebook hợp lệ.

### Act (Thực hiện)
- Mở màn hình đăng ký.
- Nhấn nút "Đăng ký bằng Facebook".
- Xác thực Facebook thành công.

### Assert (Kiểm tra)
- Tài khoản được tạo ở gói Free, bỏ qua xác nhận email.
- Người dùng được đưa đến màn hình chọn username.

---

## TC-01-005: Username đã tồn tại bị từ chối

**AC liên quan:** AC-03, BR-04
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Một username "testuser" đã được tài khoản khác sử dụng.

### Act (Thực hiện)
- Mở màn hình đăng ký.
- Nhập đầy đủ thông tin hợp lệ.
- Nhập username "testuser".
- Nhấn nút Đăng ký.

### Assert (Kiểm tra)
- Hệ thống hiển thị lỗi "Tên người dùng đã tồn tại" ngay tại ô username.
- Tài khoản không được tạo.
- Người dùng ở lại màn hình đăng ký.

---

## TC-01-006: Username quá ngắn (dưới 3 ký tự) bị từ chối

**AC liên quan:** AC-04, BR-04
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang điền form đăng ký.

### Act (Thực hiện)
- Nhập username chỉ có 2 ký tự (ví dụ: "ab").
- Nhấn nút Đăng ký.

### Assert (Kiểm tra)
- Hệ thống báo lỗi ngay tại ô username (ví dụ: "Tên người dùng phải từ 3 đến 30 ký tự").
- Không cho tiếp tục.

---

## TC-01-007: Username quá dài (trên 30 ký tự) bị từ chối

**AC liên quan:** AC-04, BR-04
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang điền form đăng ký.

### Act (Thực hiện)
- Nhập username gồm 31 ký tự (ví dụ: "abcdefghijklmnopqrstuvwxyz12345").
- Nhấn nút Đăng ký.

### Assert (Kiểm tra)
- Hệ thống báo lỗi ngay tại ô username.
- Không cho tiếp tục.

---

## TC-01-008: Mật khẩu dưới 6 ký tự bị từ chối khi đăng ký

**AC liên quan:** AC-05, BR-07, BR-19
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang điền form đăng ký.

### Act (Thực hiện)
- Nhập mật khẩu chỉ có 5 ký tự (ví dụ: "abc12").
- Nhấn nút Đăng ký.

### Assert (Kiểm tra)
- Thông báo "Mật khẩu phải có ít nhất 6 ký tự" hiện ngay dưới ô mật khẩu.
- Không tạo tài khoản.

---

## TC-01-009: Không tick xác nhận đủ 13 tuổi thì không hoàn tất đăng ký

**AC liên quan:** AC-06, BR-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng điền đầy đủ thông tin đăng ký hợp lệ nhưng không tick xác nhận đủ 13 tuổi.

### Act (Thực hiện)
- Nhấn nút Đăng ký.

### Assert (Kiểm tra)
- Hệ thống không cho hoàn tất đăng ký.
- Hiển thị thông báo yêu cầu xác nhận đủ tuổi.

---

## TC-01-010: Người dùng chưa xác nhận email bị giới hạn tính năng

**AC liên quan:** AC-07, BR-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng ký bằng email nhưng chưa nhấp link xác nhận.

### Act (Thực hiện)
- Cố gắng vào tính năng tạo tem hoặc gửi thư.

### Assert (Kiểm tra)
- Hệ thống thông báo yêu cầu xác nhận email trước.
- Có tuỳ chọn gửi lại email xác nhận.

---

## TC-01-011: Đăng nhập thành công bằng email và mật khẩu

**AC liên quan:** AC-08, BR-08, BR-09
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã có tài khoản được xác nhận.

### Act (Thực hiện)
- Mở màn hình đăng nhập.
- Nhập đúng email và mật khẩu.
- Nhấn nút Đăng nhập.

### Assert (Kiểm tra)
- Người dùng vào được màn hình chính của ứng dụng.
- Phiên được ghi nhớ tự động (không yêu cầu đăng nhập lại khi mở lại app).

---

## TC-01-012: Đăng nhập thành công bằng Google

**AC liên quan:** AC-09, BR-08
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng ký bằng Google.

### Act (Thực hiện)
- Mở màn hình đăng nhập.
- Nhấn "Đăng nhập bằng Google" và xác thực thành công.

### Assert (Kiểm tra)
- Người dùng vào được ứng dụng ngay, không cần nhập mật khẩu.

---

## TC-01-013: Đăng nhập thành công bằng Apple

**AC liên quan:** AC-09, BR-08
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Thiết bị iOS với người dùng đã đăng ký bằng Apple.

### Act (Thực hiện)
- Mở màn hình đăng nhập.
- Nhấn "Đăng nhập bằng Apple" và xác thực thành công.

### Assert (Kiểm tra)
- Người dùng vào được ứng dụng ngay, không cần nhập mật khẩu.

---

## TC-01-014: Đăng nhập thành công bằng Facebook

**AC liên quan:** AC-09, BR-08
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng ký bằng Facebook.

### Act (Thực hiện)
- Mở màn hình đăng nhập.
- Nhấn "Đăng nhập bằng Facebook" và xác thực thành công.

### Assert (Kiểm tra)
- Người dùng vào được ứng dụng ngay, không cần nhập mật khẩu.

---

## TC-01-015: Phiên được ghi nhớ — không cần đăng nhập lại trong 90 ngày

**AC liên quan:** AC-10, BR-09
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập thành công.
- Chưa quá 90 ngày kể từ lần đăng nhập gần nhất.

### Act (Thực hiện)
- Đóng app hoàn toàn.
- Mở lại app.

### Assert (Kiểm tra)
- Người dùng vào thẳng màn hình chính mà không bị yêu cầu đăng nhập lại.

---

## TC-01-016: Phiên hết hạn sau 90 ngày không hoạt động

**AC liên quan:** AC-11, BR-10
**Loại:** E2E
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Người dùng không sử dụng app hơn 90 ngày.

### Act (Thực hiện)
- Mở lại app sau khoảng thời gian đó.

### Assert (Kiểm tra)
- Hệ thống đưa người dùng về màn hình đăng nhập.
- Không vào thẳng màn hình chính.

---

## TC-01-017: Khoá tạm sau năm lần nhập sai mật khẩu liên tiếp

**AC liên quan:** AC-12, BR-11
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang ở màn hình đăng nhập với tài khoản hợp lệ.

### Act (Thực hiện)
- Nhập sai mật khẩu năm lần liên tiếp.

### Assert (Kiểm tra)
- Tài khoản bị khoá đăng nhập tạm mười lăm phút.
- Màn hình hiển thị đếm ngược thời gian chờ còn lại.
- Không thể nhấn đăng nhập trong thời gian bị khoá.

---

## TC-01-018: Hiển thị số lần thử còn lại trước khi bị khoá

**AC liên quan:** AC-31, BR-11
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang ở màn hình đăng nhập.

### Act (Thực hiện)
- Nhập sai mật khẩu lần 1 → quan sát thông báo.
- Nhập sai lần 2, lần 3, lần 4 → quan sát thông báo mỗi lần.

### Assert (Kiểm tra)
- Sau mỗi lần nhập sai (trước lần thứ năm), hệ thống hiển thị số lần thử còn lại (ví dụ: "Sai mật khẩu. Còn 3 lần thử.").
- Số lần thử giảm dần chính xác.

---

## TC-01-019: Sai phương thức đăng nhập bị từ chối

**AC liên quan:** AC-13, BR-08
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng ký bằng email, không liên kết Facebook.

### Act (Thực hiện)
- Mở màn hình đăng nhập.
- Chọn "Đăng nhập bằng Facebook" và xác thực Facebook thành công.

### Assert (Kiểm tra)
- Hệ thống hiển thị thông báo "Tài khoản này không liên kết với Facebook".
- Gợi ý người dùng dùng đúng phương thức đã đăng ký.
- Không cho vào ứng dụng.

---

## TC-01-020: Đặt lại mật khẩu qua email — link được gửi

**AC liên quan:** AC-14, BR-12, BR-21
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng ký bằng email.

### Act (Thực hiện)
- Vào màn hình "Quên mật khẩu".
- Nhập email đã đăng ký.
- Nhấn xác nhận.

### Assert (Kiểm tra)
- Hệ thống hiển thị thông báo "Nếu email tồn tại bạn sẽ nhận link đặt lại".
- Không tiết lộ email có tồn tại hay không.
- Link gửi đến email có hiệu lực hai mươi bốn giờ.

---

## TC-01-021: Quên mật khẩu với email không tồn tại — không tiết lộ thông tin

**AC liên quan:** AC-14, BR-12
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Email nhập vào không có trong hệ thống.

### Act (Thực hiện)
- Vào màn hình "Quên mật khẩu".
- Nhập email không tồn tại.
- Nhấn xác nhận.

### Assert (Kiểm tra)
- Hệ thống vẫn hiển thị thông báo "Nếu email tồn tại bạn sẽ nhận link đặt lại" (giống như email hợp lệ).
- Không thông báo email không tồn tại.

---

## TC-01-022: Link đặt lại mật khẩu chỉ dùng được một lần

**AC liên quan:** AC-15, BR-12
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã nhận link đặt lại và đã dùng thành công một lần.

### Act (Thực hiện)
- Nhấp lại vào cùng link đó lần nữa.

### Assert (Kiểm tra)
- Hệ thống thông báo link không còn hợp lệ.
- Không cho đặt lại mật khẩu lần nữa bằng link cũ.

---

## TC-01-023: Link đặt lại mật khẩu hết hạn sau 24 giờ

**AC liên quan:** AC-15, BR-12
**Loại:** E2E
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Người dùng nhận được link đặt lại mật khẩu.
- Chờ hơn 24 giờ mà không dùng link.

### Act (Thực hiện)
- Nhấp vào link đặt lại.

### Assert (Kiểm tra)
- Hệ thống thông báo link đã hết hạn.
- Gợi ý người dùng gửi lại link mới.

---

## TC-01-024: Đặt lại/đổi mật khẩu đăng xuất tất cả thiết bị khác

**AC liên quan:** AC-16, BR-14
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đang đăng nhập trên thiết bị A và thiết bị B.

### Act (Thực hiện)
- Trên thiết bị A, thực hiện đổi mật khẩu thành công.

### Assert (Kiểm tra)
- Thiết bị B bị đăng xuất ngay lập tức.
- Thiết bị B yêu cầu đăng nhập lại bằng mật khẩu mới khi mở app.
- Thiết bị A (nơi thực hiện thay đổi) vẫn giữ phiên.

---

## TC-01-025: Đổi mật khẩu yêu cầu nhập đúng mật khẩu hiện tại

**AC liên quan:** AC-17, BR-13
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang đăng nhập và vào màn hình đổi mật khẩu.

### Act (Thực hiện)
- Nhập sai mật khẩu hiện tại.
- Nhập mật khẩu mới và xác nhận mật khẩu mới hợp lệ.
- Nhấn xác nhận đổi mật khẩu.

### Assert (Kiểm tra)
- Hệ thống từ chối và yêu cầu nhập lại mật khẩu hiện tại đúng.
- Mật khẩu không được thay đổi.

---

## TC-01-026: Liên kết thêm phương thức đăng nhập Google

**AC liên quan:** AC-18, BR-15
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đang dùng email/mật khẩu và chưa liên kết Google.

### Act (Thực hiện)
- Vào cài đặt tài khoản.
- Chọn liên kết tài khoản Google.
- Xác thực Google thành công.

### Assert (Kiểm tra)
- Tài khoản hiển thị Google như một phương thức đăng nhập được liên kết.
- Người dùng có thể đăng nhập bằng Google từ lần sau.

---

## TC-01-027: Không cho huỷ phương thức đăng nhập duy nhất

**AC liên quan:** AC-19, BR-16
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng chỉ có một phương thức đăng nhập (ví dụ: chỉ email/mật khẩu, không liên kết mạng xã hội nào).

### Act (Thực hiện)
- Vào cài đặt tài khoản.
- Cố gắng huỷ liên kết phương thức duy nhất đó.

### Assert (Kiểm tra)
- Hệ thống từ chối yêu cầu.
- Hiển thị thông báo giải thích phải có ít nhất một phương thức đăng nhập còn lại.

---

## TC-01-028: Khôi phục giao dịch mua sau khi đăng nhập

**AC liên quan:** AC-20, BR-17
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã mua Premium hoặc Dấu trên cùng tài khoản App Store/Google Play.
- Đang dùng thiết bị mới (chưa đăng nhập).

### Act (Thực hiện)
- Đăng nhập thành công bằng tài khoản đã mua.

### Assert (Kiểm tra)
- Trạng thái Premium và số Dấu được khôi phục tự động.
- Người dùng không cần thực hiện thêm thao tác nào.

---

## TC-01-029: Email trống bị báo lỗi ngay tại ô — màn hình đăng nhập

**AC liên quan:** AC-21, BR-18
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang ở màn hình đăng nhập.

### Act (Thực hiện)
- Bỏ trống ô email.
- Nhấn nút Đăng nhập.

### Assert (Kiểm tra)
- Thông báo "Vui lòng nhập email" hiện ngay dưới ô email.
- Màn hình không chuyển.

---

## TC-01-030: Email trống bị báo lỗi ngay tại ô — màn hình đăng ký

**AC liên quan:** AC-21, BR-18
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang ở màn hình đăng ký.

### Act (Thực hiện)
- Bỏ trống ô email.
- Nhấn nút Đăng ký.

### Assert (Kiểm tra)
- Thông báo "Vui lòng nhập email" hiện ngay dưới ô email.
- Màn hình không chuyển.

---

## TC-01-031: Email trống bị báo lỗi ngay tại ô — màn hình quên mật khẩu

**AC liên quan:** AC-21, BR-18, BR-21
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang ở màn hình "Quên mật khẩu".

### Act (Thực hiện)
- Bỏ trống ô email.
- Nhấn xác nhận.

### Assert (Kiểm tra)
- Thông báo "Vui lòng nhập email" hiện ngay dưới ô email.
- Không gửi yêu cầu đặt lại.

---

## TC-01-032: Email sai định dạng bị báo lỗi

**AC liên quan:** AC-22, BR-18
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang ở màn hình đăng nhập hoặc đăng ký.

### Act (Thực hiện)
- Nhập email không hợp lệ (ví dụ: "abcxyz" hoặc "abc@" hoặc "abc.com").
- Nhấn tiếp tục.

### Assert (Kiểm tra)
- Thông báo "Email không hợp lệ" hiện ngay dưới ô email.
- Màn hình không chuyển.

---

## TC-01-033: Mật khẩu trống bị báo lỗi ngay tại ô

**AC liên quan:** AC-23, BR-19
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang ở màn hình đăng nhập hoặc đăng ký.

### Act (Thực hiện)
- Nhập email hợp lệ.
- Bỏ trống ô mật khẩu.
- Nhấn tiếp tục.

### Assert (Kiểm tra)
- Thông báo "Vui lòng nhập mật khẩu" hiện ngay dưới ô mật khẩu.
- Màn hình không chuyển.

---

## TC-01-034: Xác nhận mật khẩu không khớp bị báo lỗi

**AC liên quan:** AC-24, BR-20
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang điền form đăng ký.

### Act (Thực hiện)
- Nhập mật khẩu "password1".
- Nhập ô xác nhận mật khẩu "password2" (khác với ô trên).
- Nhấn Đăng ký.

### Assert (Kiểm tra)
- Thông báo "Mật khẩu không khớp" hiện ngay dưới ô xác nhận.
- Tài khoản không được tạo.

---

## TC-01-035: Đăng ký với email đã tồn tại — hiển thị lỗi tại ô email

**AC liên quan:** AC-25, BR-25
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Email "existing@example.com" đã có tài khoản trong hệ thống.

### Act (Thực hiện)
- Mở màn hình đăng ký.
- Nhập "existing@example.com" vào ô email cùng các thông tin hợp lệ khác.
- Nhấn Đăng ký.

### Assert (Kiểm tra)
- Thông báo "Email này đã có tài khoản" hiện ngay dưới ô email.
- Tài khoản mới không được tạo.

---

## TC-01-036: Sai thông tin đăng nhập — lỗi hiển thị cấp toàn biểu mẫu

**AC liên quan:** AC-26, BR-27
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang ở màn hình đăng nhập.

### Act (Thực hiện)
- Nhập email hợp lệ nhưng sai mật khẩu (mật khẩu đúng định dạng).
- Nhấn Đăng nhập.

### Assert (Kiểm tra)
- Thông báo "Đăng nhập không thành công. Sai email hoặc mật khẩu." hiện ở cấp toàn biểu mẫu (không gắn dưới ô cụ thể).
- Người dùng ở lại màn hình đăng nhập.
- Không tiết lộ email có tồn tại hay không.

---

## TC-01-037: Xóa tài khoản — hủy ở bước xác nhận thì tài khoản không bị xóa

**AC liên quan:** AC-27, BR-26
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang đăng nhập và vào màn hình xóa tài khoản.

### Act (Thực hiện)
- Hệ thống hiển thị bước xác nhận.
- Người dùng nhấn Huỷ.

### Assert (Kiểm tra)
- Tài khoản không bị xóa.
- Người dùng quay lại màn hình trước.

---

## TC-01-038: Xóa tài khoản — xác nhận thì tài khoản bị xóa

**AC liên quan:** AC-33, BR-26
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang đăng nhập và vào màn hình xóa tài khoản.

### Act (Thực hiện)
- Hệ thống hiển thị bước xác nhận.
- Người dùng nhấn Xác nhận.

### Assert (Kiểm tra)
- Tài khoản bị xóa.
- Người dùng bị đăng xuất ngay lập tức.
- Không thể đăng nhập lại bằng thông tin cũ.

---

## TC-01-039: Đăng nhập mạng xã hội không cung cấp email vẫn vào được app

**AC liên quan:** AC-28, BR-28
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng có tài khoản Facebook không chia sẻ email với ứng dụng.

### Act (Thực hiện)
- Mở màn hình đăng nhập.
- Chọn "Đăng nhập bằng Facebook" và xác thực thành công mà không cấp quyền email.

### Assert (Kiểm tra)
- Hệ thống cho vào ứng dụng bình thường.
- Không yêu cầu bổ sung hay xác minh email.

---

## TC-01-040: Tài khoản mới mặc định ở gói Free

**AC liên quan:** AC-29, BR-05
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng vừa đăng ký thành công bằng bất kỳ phương thức nào.

### Act (Thực hiện)
- Vào ứng dụng lần đầu.
- Kiểm tra trạng thái gói tài khoản.

### Assert (Kiểm tra)
- Tài khoản ở gói Free.
- Giới hạn Free được áp dụng (30 tem/tháng, 10 thư/tháng).
- Không có tính năng Premium nào được bật.

---

## TC-01-041: Bỏ qua ảnh đại diện khi đăng ký vẫn hoàn tất

**AC liên quan:** AC-30, BR-06
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang ở bước chọn ảnh đại diện trong quá trình đăng ký.

### Act (Thực hiện)
- Bỏ qua bước chọn ảnh, không tải ảnh nào.

### Assert (Kiểm tra)
- Đăng ký hoàn tất.
- Hệ thống hiển thị hình đại diện mặc định.
- Người dùng có thể cập nhật ảnh sau trong hồ sơ.

---

## TC-01-042: Mỗi phương thức đăng nhập có trạng thái xử lý riêng biệt

**AC liên quan:** AC-32, BR-24
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang ở màn hình đăng nhập.

### Act (Thực hiện)
- Nhấn nút "Đăng nhập bằng Google".
- Quan sát trạng thái các nút trong khi Google đang xử lý.

### Assert (Kiểm tra)
- Chỉ nút Google hiển thị trạng thái "đang xử lý".
- Các nút email, Apple, Facebook không bị ảnh hưởng (không mờ đi hay hiển thị loading).

---

## TC-01-043: Đăng nhập/đăng ký bị chặn khi mất mạng — hiển thị thông báo và giữ form

**AC liên quan:** AC-34, BR-29, BR-30
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Thiết bị đang mất kết nối mạng (tắt Wi-Fi và dữ liệu di động).
- Người dùng đã điền email và mật khẩu vào form đăng nhập.

### Act (Thực hiện)
- Nhấn nút Đăng nhập (hoặc Đăng ký).

### Assert (Kiểm tra)
- Hệ thống không gửi bất kỳ yêu cầu nào lên máy chủ.
- Hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."
- Toàn bộ nội dung đã nhập (email, mật khẩu) được giữ nguyên trên form.

---

## TC-01-044: Nội dung form được giữ nguyên khi mất mạng giữa chừng

**AC liên quan:** AC-34, BR-30
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đang điền form đăng ký/đăng nhập khi có mạng.
- Giữa chừng mạng bị ngắt.

### Act (Thực hiện)
- Cố nhấn Đăng ký/Đăng nhập.
- Quan sát form sau khi nhận thông báo lỗi mạng.

### Assert (Kiểm tra)
- Toàn bộ dữ liệu đã nhập vẫn còn trên màn hình.
- Người dùng không phải nhập lại từ đầu sau khi có mạng trở lại.

---

## TC-01-045: Phiên đã đăng nhập không bị huỷ khi mất mạng

**AC liên quan:** AC-35, BR-31
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đang đăng nhập với phiên còn hiệu lực.

### Act (Thực hiện)
- Tắt kết nối mạng (Wi-Fi và dữ liệu di động).
- Đóng app rồi mở lại sau khi có mạng trở lại.

### Assert (Kiểm tra)
- Người dùng vẫn ở trạng thái đã đăng nhập.
- Không bị yêu cầu xác thực lại.

---

## TC-01-046: Yêu cầu đặt lại mật khẩu bị chặn khi mất mạng

**AC liên quan:** AC-34, BR-29
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Thiết bị đang mất kết nối mạng.
- Người dùng đang ở màn hình "Quên mật khẩu".

### Act (Thực hiện)
- Nhập email hợp lệ.
- Nhấn xác nhận gửi link.

### Assert (Kiểm tra)
- Hệ thống không gửi yêu cầu lên máy chủ.
- Hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."
- Ô email giữ nguyên nội dung đã nhập.

---

## TC-01-047: Người chưa đăng nhập không vào được tính năng ứng dụng

**AC liên quan:** BR-02 (scope), Mục 5 — Chưa đăng nhập
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng chưa đăng nhập hoặc đã đăng xuất.

### Act (Thực hiện)
- Cố gắng truy cập vào màn hình chính hoặc bất kỳ tính năng nào của ứng dụng bằng cách bỏ qua màn hình đăng nhập.

### Assert (Kiểm tra)
- Hệ thống luôn giữ người dùng ở màn hình đăng nhập.
- Không cho phép vào bất kỳ tính năng nào khi chưa đăng nhập.

---

## TC-01-048: Phiên hết hạn hoặc bị đăng xuất từ xa — đưa về màn hình đăng nhập

**AC liên quan:** BR-14, AC-16, Mục 5 — Khi phiên hết hạn
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đang đăng nhập trên thiết bị B.
- Người dùng đổi mật khẩu trên thiết bị A (khiến thiết bị B bị đăng xuất từ xa).

### Act (Thực hiện)
- Mở lại app trên thiết bị B.

### Assert (Kiểm tra)
- Hệ thống đưa người dùng về màn hình đăng nhập.
- Không vào thẳng màn hình chính.

---

## TC-01-049: Thông báo lỗi server — hiển thị thông báo chung và nút thử lại

**AC liên quan:** BR-27 (lỗi không xác định), Mục 5 — Lỗi server
**Loại:** E2E
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Máy chủ trả lỗi hoặc hết thời gian chờ trong quá trình đăng nhập.

### Act (Thực hiện)
- Nhập thông tin đăng nhập đúng và nhấn Đăng nhập.

### Assert (Kiểm tra)
- Màn hình hiển thị thông báo "Đăng nhập không thành công. Vui lòng thử lại." kèm nút Thử lại.
- Biểu mẫu không bị xoá.
- Không hiển thị màn hình trắng hoặc treo.

---

## TC-01-050: Thông báo lỗi và câu chữ thống nhất trên Android và iOS

**AC liên quan:** BR-23, BR-27
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Có hai thiết bị: một Android, một iOS.

### Act (Thực hiện)
- Trên cả hai thiết bị, thực hiện cùng thao tác lỗi: nhập sai mật khẩu, email trống, mật khẩu trống.

### Assert (Kiểm tra)
- Thông báo lỗi tiếng Việt giống hệt nhau trên cả hai nền tảng.
- Kiểu hiển thị (dưới ô hay cấp biểu mẫu) thống nhất.

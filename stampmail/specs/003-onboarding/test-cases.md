# Test Cases — Onboarding Trải nghiệm lần đầu (003-onboarding)

## TC-03-001: Onboarding tự động hiển thị sau đăng ký lần đầu

**AC liên quan:** AC-01
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Tạo tài khoản mới chưa từng đăng nhập vào ứng dụng StampMail
- Hoàn tất luồng đăng ký theo SM-000 (điền đầy đủ thông tin, xác nhận tài khoản)
- Đảm bảo trạng thái onboarding của tài khoản này chưa được đánh dấu "đã xem"

### Act (Thực hiện)
- Hoàn tất bước cuối của luồng đăng ký và để hệ thống tự chuyển màn hình

### Assert (Kiểm tra)
- Màn hình onboarding xuất hiện ngay sau khi đăng ký xong, trước màn hình chính
- Màn hình đầu tiên của onboarding hiển thị nội dung giới thiệu "tạo tem từ ảnh"
- Người dùng chưa vào được màn hình chính của ứng dụng

---

## TC-03-002: Onboarding không hiển thị lại khi mở app lần hai

**AC liên quan:** AC-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Sử dụng tài khoản đã từng xem hoặc hoàn thành onboarding trước đó
- Đóng ứng dụng hoàn toàn (thoát khỏi background)

### Act (Thực hiện)
- Mở lại ứng dụng StampMail

### Assert (Kiểm tra)
- Onboarding không hiển thị
- Ứng dụng vào thẳng màn hình chính (không đi qua bất kỳ màn hình onboarding nào)

---

## TC-03-003: Nhấn "Bỏ qua" chuyển sang luồng tạo tem

**AC liên quan:** AC-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Mở ứng dụng với tài khoản mới vừa đăng ký, onboarding đang hiển thị
- Chuyển sang màn hình onboarding thứ hai (màn hình "viết thư và đính tem")

### Act (Thực hiện)
- Nhấn nút "Bỏ qua" trên màn hình onboarding thứ hai

### Assert (Kiểm tra)
- Toàn bộ onboarding đóng lại ngay lập tức
- Luồng tạo tem đầu tiên (SM-005) được mở ra
- Người dùng không bị đưa về màn hình chính mà vào thẳng màn hình tạo tem

---

## TC-03-004: Hoàn thành onboarding bằng nút "Bắt đầu" chuyển sang tạo tem

**AC liên quan:** AC-04
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Mở ứng dụng với tài khoản mới vừa đăng ký, onboarding đang hiển thị
- Đi qua tất cả các màn hình onboarding đến màn hình cuối cùng

### Act (Thực hiện)
- Nhấn nút "Bắt đầu" (hoặc tên hành động tương đương) ở màn hình cuối của onboarding

### Assert (Kiểm tra)
- Onboarding kết thúc và đóng lại
- Luồng tạo tem đầu tiên (SM-005) được mở ra
- Người dùng không bị đưa về màn hình chính mà vào thẳng màn hình tạo tem

---

## TC-03-005: Onboarding hoạt động bình thường khi mất kết nối mạng

**AC liên quan:** AC-05
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Mở ứng dụng với tài khoản mới vừa đăng ký, onboarding đang hiển thị
- Tắt kết nối mạng trên thiết bị (tắt Wifi và dữ liệu di động)

### Act (Thực hiện)
- Tiếp tục xem và chuyển qua từng màn hình onboarding khi không có mạng
- Nhấn "Bỏ qua" hoặc "Bắt đầu" để kết thúc onboarding

### Assert (Kiểm tra)
- Nội dung tất cả màn hình onboarding hiển thị đầy đủ mà không cần mạng
- Không có thông báo lỗi mạng hoặc màn hình tải vô hạn xuất hiện trong suốt quá trình onboarding
- Nút "Bỏ qua" và "Bắt đầu" vẫn phản hồi khi nhấn
- Sau khi kết thúc onboarding, luồng tạo tem đầu tiên (SM-005) được mở

---

## TC-03-006: Onboarding gồm đúng 3–4 màn hình với nội dung đúng thứ tự

**AC liên quan:** BR-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Mở ứng dụng với tài khoản mới vừa đăng ký, onboarding bắt đầu hiển thị

### Act (Thực hiện)
- Lần lượt chuyển qua từng màn hình onboarding từ đầu đến cuối

### Assert (Kiểm tra)
- Số màn hình onboarding là từ 3 đến 4 màn hình
- Màn hình 1 giới thiệu nội dung về "tạo tem từ ảnh"
- Màn hình 2 giới thiệu nội dung về "viết thư và đính tem"
- Màn hình 3 giới thiệu nội dung về "gửi thư qua mạng xã hội"
- Màn hình 4 (nếu có) giới thiệu nội dung về "sưu tầm và nhận tem"
- Mỗi màn hình ngắn gọn, không gây choáng ngợp

---

## TC-03-007: Nút "Bỏ qua" xuất hiện ở tất cả màn hình onboarding

**AC liên quan:** BR-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Mở ứng dụng với tài khoản mới vừa đăng ký, onboarding đang hiển thị

### Act (Thực hiện)
- Lần lượt quan sát từng màn hình onboarding mà không thao tác gì thêm

### Assert (Kiểm tra)
- Nút "Bỏ qua" hiển thị rõ ràng trên màn hình onboarding đầu tiên
- Nút "Bỏ qua" hiển thị rõ ràng trên tất cả các màn hình onboarding tiếp theo
- Nút "Bỏ qua" không bị ẩn hoặc mờ đi trên bất kỳ màn hình nào

---

## TC-03-008: Đăng xuất rồi đăng nhập lại trên cùng thiết bị — onboarding không hiện lại

**AC liên quan:** BR-01, AC-02
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Sử dụng tài khoản đã hoàn thành onboarding trên thiết bị này
- Đang ở màn hình chính của ứng dụng

### Act (Thực hiện)
- Đăng xuất khỏi tài khoản trong ứng dụng
- Đăng nhập lại bằng cùng tài khoản đó trên cùng thiết bị

### Assert (Kiểm tra)
- Sau khi đăng nhập lại, onboarding không hiển thị
- Ứng dụng vào thẳng màn hình chính

---

## TC-03-009: Tắt app giữa chừng onboarding — mở lại thì tiếp tục từ màn hình đã dừng

**AC liên quan:** Trường hợp ngoại lệ (Mục 5)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Mở ứng dụng với tài khoản mới vừa đăng ký, onboarding đang hiển thị
- Chuyển đến màn hình onboarding thứ hai hoặc thứ ba (chưa nhấn "Bắt đầu", chưa nhấn "Bỏ qua")

### Act (Thực hiện)
- Tắt ứng dụng hoàn toàn (force close / kill process)
- Mở lại ứng dụng StampMail

### Assert (Kiểm tra)
- Onboarding hiển thị lại và tiếp tục từ màn hình đã dừng trước đó (không bắt đầu lại từ màn hình đầu tiên)
- Không có lỗi hoặc màn hình trắng khi khởi động lại

---

## TC-03-010: Nhấn "Bỏ qua" ngay ở màn hình onboarding đầu tiên

**AC liên quan:** AC-03, BR-04
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Mở ứng dụng với tài khoản mới vừa đăng ký, onboarding đang hiển thị tại màn hình đầu tiên

### Act (Thực hiện)
- Nhấn nút "Bỏ qua" ngay tại màn hình onboarding đầu tiên mà không chuyển sang màn hình tiếp theo

### Assert (Kiểm tra)
- Onboarding đóng lại ngay lập tức
- Luồng tạo tem đầu tiên (SM-005) được mở
- Hệ thống ghi nhận onboarding đã được bỏ qua (không hiện lại ở lần mở app tiếp theo)

---

## TC-03-011: Nhấn "Bỏ qua" ở màn hình cuối — kết quả giống "Bắt đầu"

**AC liên quan:** AC-03, AC-04
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Mở ứng dụng với tài khoản mới vừa đăng ký, onboarding đang hiển thị
- Chuyển đến màn hình cuối cùng của onboarding

### Act (Thực hiện)
- Nhấn nút "Bỏ qua" thay vì nhấn "Bắt đầu" trên màn hình cuối

### Assert (Kiểm tra)
- Onboarding đóng lại
- Luồng tạo tem đầu tiên (SM-005) được mở (kết quả giống như nhấn "Bắt đầu")
- Không có sự khác biệt về hành vi điều hướng giữa "Bỏ qua" và "Bắt đầu" ở màn hình cuối

---

## TC-03-012: Hệ thống chỉ chạy onboarding đúng một lần — sau khi hoàn thành

**AC liên quan:** BR-01, AC-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Mở ứng dụng với tài khoản mới vừa đăng ký, hoàn thành onboarding bằng cách nhấn "Bắt đầu"

### Act (Thực hiện)
- Đóng ứng dụng hoàn toàn
- Mở lại ứng dụng lần thứ hai
- Đóng và mở ứng dụng thêm một lần (lần thứ ba)

### Assert (Kiểm tra)
- Cả lần mở thứ hai và thứ ba đều không hiển thị onboarding
- Trạng thái "đã hoàn thành onboarding" được lưu bền vững trên thiết bị
- Ứng dụng vào thẳng màn hình chính ở mọi lần mở tiếp theo

---

## TC-03-013: Không hiển thị thông báo lỗi mạng khi đang xem onboarding bị mất mạng

**AC liên quan:** AC-05, BR-06
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Mở ứng dụng với tài khoản mới vừa đăng ký, onboarding đang hiển thị và đang xem màn hình thứ hai
- Thiết bị đang có kết nối mạng bình thường

### Act (Thực hiện)
- Tắt kết nối mạng giữa chừng khi đang xem onboarding (tắt Wifi và dữ liệu di động)
- Tiếp tục xem các màn hình onboarding còn lại

### Assert (Kiểm tra)
- Không có thông báo lỗi mạng xuất hiện trong suốt thời gian xem onboarding
- Nội dung các màn hình onboarding vẫn hiển thị đầy đủ
- Hệ thống không ngắt quãng hoặc dừng luồng onboarding vì lý do mạng

---

## TC-03-014: Tắt app ngay tại màn hình cuối trước khi nhấn "Bắt đầu"

**AC liên quan:** Trường hợp ngoại lệ (Mục 5)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Mở ứng dụng với tài khoản mới vừa đăng ký, onboarding đang hiển thị
- Chuyển đến màn hình cuối cùng của onboarding nhưng chưa nhấn "Bắt đầu"

### Act (Thực hiện)
- Tắt ứng dụng hoàn toàn (force close / kill process)
- Mở lại ứng dụng StampMail

### Assert (Kiểm tra)
- Onboarding hiển thị lại và tiếp tục từ màn hình cuối (màn hình đã dừng)
- Onboarding chưa được đánh dấu là "đã hoàn thành"
- Không có lỗi hoặc màn hình trắng khi khởi động lại

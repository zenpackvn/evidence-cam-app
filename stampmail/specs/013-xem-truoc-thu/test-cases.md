# Test Cases — Xem trước thư trước khi gửi (013-xem-truoc-thu)

## TC-13-001: Xem trước hiển thị đầy đủ thư hoàn chỉnh

**AC liên quan:** AC-01
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Người dùng đã soạn nội dung thư với nội dung "Chúc mừng sinh nhật bạn!", chọn font "Roboto", chọn template nền màu vàng
- Người dùng đã đính 2 con tem: một tem ở góc trên bên phải, một tem ở góc dưới bên trái
- Người dùng đang ở màn hình bước 4 — xem trước thư

### Act (Thực hiện)
- Quan sát màn hình xem trước thư

### Assert (Kiểm tra)
- Màn hình xem trước hiển thị nền template màu vàng đã chọn
- Nội dung "Chúc mừng sinh nhật bạn!" hiển thị đúng trên thư
- Font chữ "Roboto" được áp dụng cho nội dung thư
- Tem thứ nhất hiển thị ở góc trên bên phải đúng vị trí đã đính
- Tem thứ hai hiển thị ở góc dưới bên trái đúng vị trí đã đính

---

## TC-13-002: Quay lại chỉnh nội dung từ màn hình xem trước

**AC liên quan:** AC-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang ở màn hình xem trước với nội dung thư "Chúc mừng sinh nhật bn!" (có lỗi chính tả "bn")
- Màn hình xem trước đang hiển thị nút "Chỉnh sửa lại"

### Act (Thực hiện)
- Nhấn nút "Chỉnh sửa lại"

### Assert (Kiểm tra)
- Ứng dụng điều hướng về màn hình soạn nội dung thư
- Nội dung "Chúc mừng sinh nhật bn!" vẫn còn trong ô soạn thảo (không bị xóa)
- Người dùng có thể chỉnh sửa nội dung để sửa lỗi chính tả

---

## TC-13-003: Chuyển sang màn hình gửi thư sau khi xem trước

**AC liên quan:** AC-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang ở màn hình xem trước với thư hoàn chỉnh (có nội dung, tem, template)
- Thiết bị đang có kết nối mạng
- Màn hình xem trước đang hiển thị nút "Gửi thư" ở trạng thái hoạt động

### Act (Thực hiện)
- Nhấn nút "Gửi thư"

### Assert (Kiểm tra)
- Ứng dụng điều hướng sang màn hình gửi thư qua mạng xã hội (SM-016)
- Màn hình SM-016 hiển thị đúng (bước tạo link và gửi thư)

---

## TC-13-004: Xem trước vẫn hiển thị đầy đủ khi mất mạng

**AC liên quan:** AC-04
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đang ở màn hình xem trước với thư có nội dung, template và tem đầy đủ
- Thiết bị đang có kết nối mạng

### Act (Thực hiện)
- Tắt kết nối mạng trên thiết bị (bật chế độ máy bay hoặc tắt Wi-Fi/data)
- Quan sát màn hình xem trước

### Assert (Kiểm tra)
- Nền template vẫn hiển thị đúng như trước khi mất mạng
- Nội dung thư vẫn hiển thị đầy đủ
- Các tem vẫn hiển thị ở đúng vị trí đã đính
- Nút "Chỉnh sửa lại" vẫn có thể nhấn được và hoạt động bình thường
- Nút "Gửi thư" bị vô hiệu hóa (không thể nhấn)
- Thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." xuất hiện trên màn hình

---

## TC-13-005: Nút Gửi thư tự động kích hoạt khi mạng trở lại

**AC liên quan:** AC-05
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đang ở màn hình xem trước trong trạng thái mất mạng
- Nút "Gửi thư" đang bị vô hiệu hóa
- Thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." đang hiển thị

### Act (Thực hiện)
- Bật lại kết nối mạng trên thiết bị (tắt chế độ máy bay hoặc bật Wi-Fi/data)
- Không thoát khỏi màn hình xem trước, chỉ quan sát

### Assert (Kiểm tra)
- Nút "Gửi thư" tự động chuyển về trạng thái hoạt động (có thể nhấn) mà không cần thoát màn hình
- Thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." tự động biến mất
- Nội dung xem trước không thay đổi

---

## TC-13-006: Cảnh báo khi gửi thư không có nội dung

**AC liên quan:** AC-03 (trường hợp ngoại lệ — mục 5)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã bỏ trống toàn bộ nội dung trong bước soạn thư (nội dung trống)
- Người dùng đã đến màn hình xem trước (thư không có nội dung)
- Thiết bị đang có kết nối mạng
- Màn hình xem trước hiển thị nút "Gửi thư"

### Act (Thực hiện)
- Nhấn nút "Gửi thư"

### Assert (Kiểm tra)
- Hệ thống hiển thị thông báo cảnh báo "thư chưa có nội dung"
- Thông báo hỏi xác nhận "Có chắc muốn gửi thư trống không?"
- Ứng dụng không chuyển sang màn hình SM-016 ngay lập tức (chờ người dùng xác nhận)

---

## TC-13-007: Xác nhận gửi thư trống sau cảnh báo

**AC liên quan:** AC-03 (trường hợp ngoại lệ — mục 5)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang thấy hộp thoại cảnh báo "Có chắc muốn gửi thư trống không?"

### Act (Thực hiện)
- Nhấn nút xác nhận đồng ý gửi thư trống

### Assert (Kiểm tra)
- Ứng dụng điều hướng sang màn hình gửi thư qua mạng xã hội (SM-016)

---

## TC-13-008: Hủy gửi thư trống khi thấy cảnh báo

**AC liên quan:** AC-03 (trường hợp ngoại lệ — mục 5)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang thấy hộp thoại cảnh báo "Có chắc muốn gửi thư trống không?"

### Act (Thực hiện)
- Nhấn nút hủy (không gửi)

### Assert (Kiểm tra)
- Hộp thoại cảnh báo đóng lại
- Người dùng vẫn ở màn hình xem trước (không điều hướng sang SM-016)
- Nội dung thư không thay đổi

---

## TC-13-009: Chưa đăng nhập không thể truy cập màn hình xem trước

**AC liên quan:** BR-01 (trường hợp ngoại lệ — mục 5)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng chưa đăng nhập vào ứng dụng StampMail

### Act (Thực hiện)
- Cố gắng truy cập màn hình xem trước (ví dụ: qua deep link hoặc điều hướng trực tiếp)

### Assert (Kiểm tra)
- Ứng dụng không hiển thị màn hình xem trước
- Hệ thống chuyển hướng về màn hình đăng nhập

---

## TC-13-010: Thoát app từ màn hình xem trước — nội dung bị mất khi mở lại

**AC liên quan:** BR-01 (trường hợp ngoại lệ — mục 5)
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đang ở màn hình xem trước với thư đã soạn đầy đủ

### Act (Thực hiện)
- Thoát hoàn toàn khỏi ứng dụng (force close hoặc vuốt đóng app)
- Mở lại ứng dụng StampMail

### Assert (Kiểm tra)
- Ứng dụng không mở lại màn hình xem trước
- Nội dung thư đã soạn không còn lưu lại
- Người dùng phải bắt đầu soạn thư từ đầu

---

## TC-13-011: Template hoặc tem không tải được — hiển thị lỗi và nút thử lại

**AC liên quan:** BR-01 (trường hợp ngoại lệ — mục 5, khi dữ liệu không tải được)
**Loại:** E2E
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Người dùng đang ở màn hình xem trước
- Máy chủ xảy ra lỗi khiến template hoặc hình ảnh tem không tải được

### Act (Thực hiện)
- Quan sát màn hình xem trước khi một phần nội dung không tải được

### Assert (Kiểm tra)
- Vùng bị lỗi (template hoặc tem) hiển thị biểu tượng lỗi thay vì nội dung thực
- Nút "Thử lại" xuất hiện tại vùng bị ảnh hưởng
- Nhấn "Thử lại" → ứng dụng cố gắng tải lại nội dung đó

---

## TC-13-012: Xem trước thư không có tem

**AC liên quan:** AC-01
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã soạn nội dung thư "Thư không có tem" và bỏ qua bước đính tem (SM-014)
- Người dùng đang ở màn hình xem trước

### Act (Thực hiện)
- Quan sát màn hình xem trước

### Assert (Kiểm tra)
- Màn hình xem trước hiển thị thư với nội dung "Thư không có tem"
- Không có tem nào xuất hiện trên thư
- Nền template và font chữ vẫn hiển thị đúng

---

## TC-13-013: Cuộn để xem toàn bộ thư có nội dung dài

**AC liên quan:** AC-01
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã soạn thư với nội dung rất dài (nhiều đoạn văn, vượt quá chiều cao màn hình)
- Người dùng đang ở màn hình xem trước

### Act (Thực hiện)
- Cuộn xuống trong màn hình xem trước để xem phần nội dung bên dưới

### Assert (Kiểm tra)
- Nội dung thư có thể cuộn được
- Toàn bộ nội dung thư hiển thị đầy đủ khi cuộn hết
- Nút "Chỉnh sửa lại" và "Gửi thư" vẫn truy cập được (cố định hoặc xuất hiện khi cuộn lên)

---

## TC-13-014: Nút Gửi thư bị vô hiệu hóa ngay khi vào màn hình xem trước lúc mất mạng

**AC liên quan:** AC-04, BR-05
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Thiết bị đang ở trạng thái mất kết nối mạng trước khi vào màn hình xem trước
- Người dùng đã soạn thư đầy đủ (nội dung, template, tem)

### Act (Thực hiện)
- Chuyển sang màn hình xem trước (bước 4) trong khi thiết bị chưa có mạng

### Assert (Kiểm tra)
- Màn hình xem trước hiển thị đầy đủ nội dung thư
- Nút "Gửi thư" đã bị vô hiệu hóa ngay từ lúc vào màn hình
- Thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." hiển thị
- Nút "Chỉnh sửa lại" hoạt động bình thường

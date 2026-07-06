# Checklist QA — Xem trước thư trước khi gửi (013-xem-truoc-thu)

## Điều kiện tiên quyết
- [ ] Người dùng đã đăng nhập vào ứng dụng StampMail
- [ ] Người dùng đã soạn nội dung thư (SM-013 hoàn tất)
- [ ] Người dùng đã đính tem hoặc bỏ qua bước đính tem (SM-014 hoàn tất)
- [ ] Ứng dụng đang ở bước 4 trong luồng soạn thư (màn hình xem trước)

## Luồng chính (Happy Path)

- [ ] Màn hình xem trước hiển thị đúng nền template đã chọn ✅
- [ ] Màn hình xem trước hiển thị đúng nội dung thư đã soạn ✅
- [ ] Màn hình xem trước hiển thị đúng font chữ đã chọn ✅
- [ ] Màn hình xem trước hiển thị tem đã đính ở đúng vị trí ✅
- [ ] Giao diện xem trước trông đúng như người nhận sẽ thấy khi mở link 🔲
- [ ] Nút "Chỉnh sửa lại" hiển thị trên màn hình xem trước ✅
- [ ] Nhấn "Chỉnh sửa lại" → quay về màn hình soạn nội dung ✅
- [ ] Nội dung thư được giữ nguyên sau khi quay lại chỉnh sửa (không mất dữ liệu) ✅
- [ ] Nút "Gửi thư" hiển thị trên màn hình xem trước (khi có mạng) ✅
- [ ] Nhấn "Gửi thư" khi có mạng → chuyển sang màn hình gửi thư qua MXH (SM-016) ✅

## Luồng thất bại & Validation

- [ ] Khi thư không có nội dung: hệ thống hiển thị cảnh báo "thư chưa có nội dung" ✅
- [ ] Cảnh báo thư trống hỏi xác nhận "Có chắc muốn gửi thư trống không?" ✅
- [ ] Người dùng có thể chọn hủy (không gửi) khi thấy cảnh báo thư trống ✅
- [ ] Người dùng có thể xác nhận gửi dù thư trống sau khi nhận cảnh báo ✅
- [ ] Chưa đăng nhập → không truy cập được màn hình xem trước, chuyển về màn hình đăng nhập ✅

## Trạng thái offline

- [ ] Mất mạng trong khi đang ở màn hình xem trước → nội dung thư (template, văn bản, tem) vẫn hiển thị đầy đủ 🔲
- [ ] Mất mạng → nút "Gửi thư" bị vô hiệu hóa ngay lập tức 🔲
- [ ] Mất mạng → thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." xuất hiện 🔲
- [ ] Mất mạng → nút "Chỉnh sửa lại" vẫn hoạt động bình thường 🔲
- [ ] Có mạng trở lại → nút "Gửi thư" tự động được kích hoạt lại (không cần thoát màn hình) 🔲
- [ ] Có mạng trở lại → thông báo mất mạng tự động biến mất 🔲
- [ ] Vào màn hình xem trước khi thiết bị đã mất mạng → nút "Gửi thư" bị vô hiệu hóa ngay từ đầu 🔲

## Trường hợp biên (Edge Cases)

- [ ] Xem trước thư không có tem (bỏ qua bước đính tem) → hiển thị đúng thư không có tem ✅
- [ ] Xem trước thư có nhiều tem ở nhiều vị trí khác nhau → tất cả tem hiển thị đúng vị trí 🔲
- [ ] Xem trước thư với nội dung dài → có thể cuộn để xem toàn bộ nội dung ✅
- [ ] Thoát app từ màn hình xem trước → mở lại app thì nội dung thư đã soạn bị mất 🔲
- [ ] Template hoặc hình ảnh tem không tải được (lỗi máy chủ) → hiển thị biểu tượng lỗi tại vùng bị ảnh hưởng 🚫
- [ ] Template hoặc hình ảnh tem không tải được → nút "Thử lại" xuất hiện để tải lại 🚫

## Ghi chú tự động hóa
- ✅ Maestro automatable — các luồng điều hướng, kiểm tra nội dung hiển thị, xác nhận hộp thoại
- 🔲 Manual only — kiểm tra trạng thái offline (bật/tắt mạng thực tế), so sánh giao diện xem trước với giao diện người nhận, kiểm tra thoát app
- 🚫 Not automatable — lỗi máy chủ khi tải template/tem (phụ thuộc trạng thái server không tái tạo được ổn định)

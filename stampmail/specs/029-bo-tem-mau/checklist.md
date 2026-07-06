# Checklist QA — Bộ tem mẫu (SM-035 / 029-bo-tem-mau)

## Điều kiện tiên quyết
- [ ] Người dùng đã đăng nhập thành công (SM-001)
- [ ] Hệ thống có ít nhất hai chủ đề tem mẫu khác nhau (ví dụ: Sinh nhật, Tết)
- [ ] Có ít nhất một tem mẫu miễn phí và một tem mẫu cần Dấu để mở khóa
- [ ] Có tài khoản test với đủ Dấu (ví dụ: ≥ 50📮) để kiểm thử mở khóa
- [ ] Có tài khoản test với Dấu ít hơn giá mở khóa (ví dụ: 10📮) để kiểm thử không đủ Dấu
- [ ] Có thiết bị thật để kiểm thử cử chỉ zoom và trạng thái offline

## Luồng chính (Happy Path)

- [ ] Mở màn hình Bộ tem mẫu → hiển thị danh sách các chủ đề để lọc ✅
- [ ] Chọn một chủ đề → chỉ hiển thị tem thuộc chủ đề đó, tem chủ đề khác bị ẩn ✅
- [ ] Bỏ chọn bộ lọc / chọn "Tất cả" → hiển thị toàn bộ tem mẫu ✅
- [ ] Nhấn vào tem mẫu miễn phí → hiển thị kích thước lớn với nhãn "Tem mẫu", tên chủ đề, nút "Lưu vào Album" ✅
- [ ] Nhấn vào tem mẫu bị khóa → hiển thị kích thước lớn với nhãn "Tem mẫu", giá Dấu cần mở khóa, nút mở khóa ✅
- [ ] Phóng to tem khi xem trước bằng cử chỉ banh hai ngón tay; chụm ngón tay thu về kích thước ban đầu 🔲
- [ ] Nhấn "Lưu vào Album" trên tem miễn phí → thông báo "Đã lưu vào Album", tem xuất hiện trong Album cá nhân với nhãn "Tem mẫu" ✅
- [ ] Mở khóa tem mẫu khi có đủ Dấu → tem mở vĩnh viễn, số Dấu giảm đúng, nút đổi thành "Lưu vào Album" ✅
- [ ] Tem mẫu đã lưu vào Album xuất hiện trong tab "Tất cả" khi đính tem lên thư (SM-014), có thể chọn bình thường ✅
- [ ] Tem mới vừa ra mắt có nhãn "Mới" hiển thị trên ảnh; tem cũ không có nhãn này 🔲

## Luồng thất bại & Validation

- [ ] Lưu lại tem đã có trong Album → thông báo "Tem này đã có trong Album của bạn", không tạo bản sao ✅
- [ ] Mở khóa khi không đủ Dấu → hiển thị số Dấu còn thiếu và hai lựa chọn "Chia sẻ tem để kiếm Dấu" / "Nạp Dấu"; không mở khóa ✅
- [ ] Mất kết nối → tem đã tải trước vẫn hiển thị; thông báo "Đang xem ngoại tuyến" xuất hiện ở đầu màn hình 🔲
- [ ] Mất kết nối → nhấn "Lưu vào Album" → hành động bị chặn, thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." 🔲
- [ ] Mất kết nối → nhấn "Mở khóa" → hành động bị chặn, thông báo lỗi kết nối, số Dấu không thay đổi 🔲
- [ ] Chưa đăng nhập → nhấn "Lưu vào Album" hoặc "Mở khóa" → chuyển hướng sang màn hình đăng nhập, giữ nguyên tem đang xem ✅
- [ ] Toàn bộ bộ tem không tải được → hiển thị thông báo lỗi và nút "Thử lại" 🚫
- [ ] Một chủ đề không tải được → hiển thị skeleton trong lúc chờ, sau đó hiện thông báo lỗi và nút "Thử lại" tại chỗ 🚫

## Trường hợp biên (Edge Cases)

- [ ] Chủ đề chưa có tem nào → hiển thị trạng thái "Sắp ra mắt" thay vì danh sách trống 🔲
- [ ] Tem chưa tải về khi mất mạng → hiển thị ảnh giữ chỗ (placeholder), không để trống 🔲
- [ ] Tem mẫu trong Album có nhãn "Tem mẫu" phân biệt rõ với tem cá nhân tự tạo ✅
- [ ] Tem mẫu đã lưu vào Album không có nút "Chỉnh sửa" hoặc tùy chọn thay đổi thiết kế ✅
- [ ] Thoát app khi đang xem tem mẫu → mở lại: không mất dữ liệu, màn hình trở về danh sách chủ đề (không khôi phục tem xem dở) 🔲

## Ghi chú tự động hóa
- ✅ Maestro automatable — tap, scroll, assert text, kiểm tra nhãn "Tem mẫu", kiểm tra số Dấu giảm đúng, trạng thái mở khóa, điều hướng sang đăng nhập, kiểm tra không tạo bản sao
- 🔲 Manual only — cử chỉ pinch zoom (hai ngón tay), trạng thái offline (cần bật/tắt mạng thật), nhãn "Mới" (phụ thuộc thời điểm ra mắt), placeholder khi mất mạng, trạng thái sau khi thoát app
- 🚫 Not automatable — lỗi máy chủ (không tải được bộ tem hoặc chủ đề); phụ thuộc trạng thái server-side không thể tái tạo bằng UI test

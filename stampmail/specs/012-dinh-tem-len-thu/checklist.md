# Checklist QA — Đính tem & Kéo thả lên thư (012-dinh-tem-len-thu)

---

## Điều kiện tiên quyết

- [ ] Người dùng đã đăng nhập thành công vào ứng dụng.
- [ ] Album có ít nhất một tem (SM-011 đã hoàn tất).
- [ ] Người dùng đã soạn xong nội dung thư (SM-013) và đang ở bước đính tem.
- [ ] Thiết bị kết nối mạng (cho các trường hợp online).

---

## Luồng chính (Happy Path)

- [ ] Mở màn hình chọn tem — danh sách album hiển thị với ba tab mặc định: "Tất cả", "Tự tạo", "Nhận được". ✅
- [ ] Tab album tùy chỉnh (nếu có) hiển thị sau ba tab mặc định, đúng tên album. ✅
- [ ] Chọn tem từ tab "Tất cả" — tem xuất hiện ở góc phải phía trên của thư. ✅
- [ ] Chọn tem từ tab "Tự tạo" — chỉ hiển thị tem tự tạo, đính lên thư thành công. ✅
- [ ] Chọn tem từ tab "Nhận được" — chỉ hiển thị tem nhận từ người khác, đính lên thư thành công. ✅
- [ ] Chọn tem từ album tùy chỉnh — đính lên thư thành công. ✅
- [ ] Chuyển qua lại giữa các tab — danh sách cập nhật đúng; tem đã đính không bị xóa. ✅
- [ ] Vị trí mặc định của mọi tem mới đính là góc phải phía trên của thư. ✅
- [ ] Đính một tem rồi nhấn "Tiếp tục" — chuyển sang bước xem trước thư (SM-015). ✅
- [ ] Màn hình xem trước hiển thị toàn bộ thư kèm tem đã đính. ✅
- [ ] Đính hai đến ba tem — tất cả tem hiển thị trong xem trước. ✅

---

## Luồng thất bại & Validation

- [ ] Chưa đính tem nào → nhấn "Tiếp tục": hệ thống thông báo yêu cầu đính ít nhất một tem, không chuyển bước. ✅
- [ ] Đã đính ba tem → cố chọn thêm tem thứ tư: hệ thống thông báo đã đạt giới hạn tối đa ba tem, không đính thêm. ✅
- [ ] Album trống (không có tem nào): màn hình hiển thị trạng thái trống kèm gợi ý tạo tem; có nút tắt/bỏ qua. ✅
- [ ] Người dùng chưa đăng nhập → vào bước đính tem: hệ thống chuyển hướng sang màn hình đăng nhập. ✅
- [ ] Tải Album thất bại do lỗi máy chủ: hiển thị thông báo lỗi và nút "Thử lại". 🔲
- [ ] Trong khi Album đang tải (skeleton): người dùng không thể chọn tem; sau khi tải xong có thể chọn bình thường. 🔲

---

## Trường hợp biên (Edge Cases)

- [ ] Thoát màn hình đính tem khi đã chọn tem: hệ thống hỏi xác nhận trước khi thoát; nội dung thư được giữ lại. ✅
- [ ] Thoát màn hình đính tem khi chưa chọn tem: thoát ngay không cần xác nhận; nội dung thư được giữ lại. ✅
- [ ] Mất mạng sau khi Album đã tải: danh sách tem vẫn hiển thị từ bộ nhớ đệm; thông báo "Đang xem ngoại tuyến" xuất hiện phía trên. 🔲
- [ ] Mất mạng sau khi Album đã tải: người dùng vẫn chọn và đính tem lên thư được bình thường. 🔲
- [ ] Mất mạng sau khi Album đã tải: nút làm mới danh sách bị vô hiệu hoá. 🔲
- [ ] Mất mạng khi Album chưa từng được tải: hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."; không hiển thị danh sách tem. 🔲
- [ ] Yêu cầu làm mới danh sách khi mất mạng: hệ thống thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." và không tải thêm dữ liệu. 🔲
- [ ] Tắt app đột ngột giữa bước đính tem → mở lại app: thư đang soạn và tem đã đính được khôi phục; tiếp tục được từ bước đính tem. 🔲
- [ ] Đính tem rồi điều chỉnh vị trí tem (kéo thả): vị trí tem thay đổi theo thao tác của người dùng; không cần mạng để thực hiện. 🔲

---

## Ghi chú tự động hóa

- ✅ Maestro automatable — Các thao tác chọn tab, chọn tem, kiểm tra thông báo giới hạn, kiểm tra nút "Tiếp tục" bị chặn, kiểm tra vị trí mặc định của tem, hộp thoại xác nhận thoát, chuyển hướng đăng nhập.
- 🔲 Manual only — Các kịch bản liên quan đến trạng thái mạng (mất kết nối, khôi phục kết nối), lỗi máy chủ, trạng thái skeleton loading, khôi phục dữ liệu sau khi tắt app đột ngột, điều chỉnh vị trí tem bằng kéo thả trên thiết bị thực.
- 🚫 Not automatable — (Không có trường hợp nào trong tính năng này thuộc loại không thể kiểm thử.)

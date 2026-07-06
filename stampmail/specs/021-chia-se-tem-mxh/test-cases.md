# Test Cases — Chia sẻ tem lên MXH (021-chia-se-tem-mxh)

## TC-21-001: Chia sẻ Mức 1 — native share sheet mở với ảnh 9:16 kèm watermark

**AC liên quan:** AC-01, AC-03, AC-05
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào StampMail
- Người dùng có ít nhất một tem trong Album
- Thiết bị có kết nối mạng

### Act (Thực hiện)
- Mở Album, chọn một tem
- Nhấn nút "Chia sẻ"
- Chọn mức nội dung "Mức 1 — Chỉ tem"
- Chọn định dạng "Dọc 9:16"
- Nhấn "Chia sẻ"

### Assert (Kiểm tra)
- Native share sheet của thiết bị mở ra
- Ảnh đính kèm trong share sheet có tỉ lệ 9:16
- Watermark StampMail xuất hiện ở góc ảnh
- Không có cảnh báo "Nội dung thư sẽ công khai" nào xuất hiện
- Người dùng tự chọn nền tảng (Instagram, TikTok, v.v.) từ danh sách của hệ điều hành

---

## TC-21-002: Chia sẻ Mức 1 — native share sheet mở với ảnh 1:1 kèm watermark

**AC liên quan:** AC-01, AC-03, AC-05
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào StampMail
- Người dùng có ít nhất một tem trong Album
- Thiết bị có kết nối mạng

### Act (Thực hiện)
- Mở Album, chọn một tem
- Nhấn nút "Chia sẻ"
- Chọn mức nội dung "Mức 1 — Chỉ tem"
- Chọn định dạng "Vuông 1:1"
- Nhấn "Chia sẻ"

### Assert (Kiểm tra)
- Native share sheet của thiết bị mở ra
- Ảnh đính kèm trong share sheet có tỉ lệ 1:1
- Watermark StampMail xuất hiện ở góc ảnh
- Không có cảnh báo "Nội dung thư sẽ công khai" nào xuất hiện

---

## TC-21-003: Cảnh báo khi chọn Mức 2 (kèm trích dẫn)

**AC liên quan:** AC-02, BR-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào StampMail
- Người dùng có ít nhất một tem trong Album, tem đó có thư đính kèm với nhiều câu

### Act (Thực hiện)
- Mở Album, chọn một tem có thư
- Nhấn nút "Chia sẻ"
- Chọn mức nội dung "Mức 2 — Tem + một dòng trích dẫn"
- Chọn một câu trích dẫn từ nội dung thư
- Nhấn "Tiếp tục"

### Assert (Kiểm tra)
- Hệ thống hiển thị hộp thoại cảnh báo với nội dung "Nội dung thư sẽ công khai"
- Hộp thoại có nút xác nhận và nút hủy
- Khi nhấn Hủy, hộp thoại đóng lại và người dùng quay về màn hình chia sẻ

---

## TC-21-004: Cảnh báo khi chọn Mức 3 (toàn bộ nội dung thư)

**AC liên quan:** AC-02, BR-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào StampMail
- Người dùng có ít nhất một tem trong Album, tem đó có thư đính kèm

### Act (Thực hiện)
- Mở Album, chọn một tem có thư
- Nhấn nút "Chia sẻ"
- Chọn mức nội dung "Mức 3 — Tem + toàn bộ nội dung thư"
- Nhấn "Tiếp tục"

### Assert (Kiểm tra)
- Hệ thống hiển thị hộp thoại cảnh báo với nội dung "Nội dung thư sẽ công khai"
- Hộp thoại yêu cầu xác nhận trước khi tiếp tục
- Khi nhấn xác nhận, luồng chia sẻ tiếp tục bình thường
- Cảnh báo không hiển thị lại trong cùng một luồng chia sẻ

---

## TC-21-005: Watermark StampMail luôn xuất hiện — không có tùy chọn xóa

**AC liên quan:** AC-03, BR-06
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào StampMail
- Người dùng có ít nhất một tem trong Album

### Act (Thực hiện)
- Mở Album, chọn một tem
- Nhấn nút "Chia sẻ"
- Lần lượt thử cả ba mức nội dung (Mức 1, Mức 2, Mức 3)
- Tạo ảnh chia sẻ cho từng mức, kiểm tra ảnh xem trước và ảnh lưu ra

### Assert (Kiểm tra)
- Watermark StampMail xuất hiện ở góc ảnh trong cả ba mức nội dung
- Không có tùy chọn "Xóa watermark", "Tắt watermark" hay bất kỳ nút nào liên quan
- Watermark không thể bị che hoặc xóa bởi người dùng

---

## TC-21-006: Lưu ảnh về thư viện điện thoại

**AC liên quan:** AC-04, BR-05
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào StampMail
- Người dùng có ít nhất một tem trong Album
- Người dùng đã cấp quyền truy cập thư viện ảnh cho StampMail

### Act (Thực hiện)
- Mở Album, chọn một tem
- Nhấn nút "Chia sẻ"
- Chọn Mức 1, chọn định dạng 9:16
- Nhấn "Lưu về thư viện" thay vì nhấn Chia sẻ

### Assert (Kiểm tra)
- Ảnh tem đúng định dạng 9:16 được lưu vào thư viện ảnh điện thoại
- Ảnh lưu có watermark StampMail ở góc
- Thông báo xác nhận lưu thành công hiển thị cho người dùng

---

## TC-21-007: Người dùng chọn định dạng trước khi share sheet mở

**AC liên quan:** AC-05, BR-04
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào StampMail
- Người dùng có ít nhất một tem trong Album

### Act (Thực hiện)
- Mở Album, chọn một tem
- Nhấn nút "Chia sẻ"
- Chọn Mức 1
- Chọn định dạng "Dọc 9:16"
- Nhấn "Chia sẻ"

### Assert (Kiểm tra)
- Màn hình hiển thị hai tùy chọn định dạng rõ ràng: "Dọc 9:16" và "Vuông 1:1"
- Native share sheet mở với ảnh tỉ lệ 9:16 — không phải 1:1
- Người dùng đã chọn định dạng xong trước khi share sheet xuất hiện

---

## TC-21-008: Lưu về thư viện vẫn thực hiện được khi mất mạng

**AC liên quan:** AC-06, BR-08
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào StampMail
- Người dùng có ít nhất một tem đã tải sẵn trong Album
- Người dùng đã cấp quyền truy cập thư viện ảnh
- Thiết bị đang mất kết nối mạng (tắt WiFi và dữ liệu di động)

### Act (Thực hiện)
- Mở Album, chọn một tem đã tải sẵn
- Nhấn nút "Chia sẻ"
- Chọn Mức 1, chọn định dạng 1:1
- Nhấn "Lưu về thư viện"

### Assert (Kiểm tra)
- Ảnh tem có watermark được lưu thành công vào thư viện điện thoại
- Không xuất hiện thông báo lỗi mạng
- Thông báo xác nhận lưu thành công hiển thị bình thường

---

## TC-21-009: Mở native share sheet khi mất mạng — hiển thị thông báo ngoại tuyến

**AC liên quan:** AC-07, BR-09
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào StampMail
- Người dùng có ít nhất một tem đã tải sẵn trong Album
- Thiết bị đang mất kết nối mạng (tắt WiFi và dữ liệu di động)

### Act (Thực hiện)
- Mở Album, chọn một tem đã tải sẵn
- Nhấn nút "Chia sẻ"
- Chọn Mức 1, chọn định dạng 9:16
- Nhấn "Chia sẻ"

### Assert (Kiểm tra)
- Native share sheet của thiết bị vẫn mở ra
- Hệ thống hiển thị thông báo "Thiết bị đang ngoại tuyến — chia sẻ lên mạng xã hội có thể không thành công"
- Share sheet không bị đóng lại — người dùng vẫn có thể tự quyết định chọn nền tảng

---

## TC-21-010: Tạo ảnh và chọn định dạng vẫn hoạt động khi mất mạng

**AC liên quan:** BR-08
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào StampMail
- Người dùng có ít nhất một tem đã tải sẵn trong Album
- Thiết bị đang mất kết nối mạng

### Act (Thực hiện)
- Mở Album, chọn một tem đã tải sẵn
- Nhấn nút "Chia sẻ"
- Chọn Mức 1
- Chọn định dạng "Dọc 9:16"
- Quan sát xem trước ảnh

### Assert (Kiểm tra)
- Màn hình chia sẻ hiển thị bình thường
- Ảnh xem trước tạo ra đúng tỉ lệ 9:16 với watermark
- Các bước chọn mức nội dung và định dạng không yêu cầu kết nối mạng

---

## TC-21-011: Từ chối cấp quyền lưu ảnh vào thư viện

**AC liên quan:** Mục 5 (trường hợp ngoại lệ)
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào StampMail
- Người dùng có ít nhất một tem trong Album
- Quyền truy cập thư viện ảnh bị từ chối hoặc chưa cấp cho StampMail

### Act (Thực hiện)
- Mở Album, chọn một tem
- Nhấn nút "Chia sẻ"
- Chọn Mức 1, chọn định dạng 1:1
- Nhấn "Lưu về thư viện"
- Từ chối cấp quyền khi hệ thống yêu cầu

### Assert (Kiểm tra)
- Hệ thống hiển thị thông báo yêu cầu quyền truy cập thư viện ảnh
- Thông báo có hướng dẫn rõ ràng để người dùng vào Cài đặt và cấp quyền thủ công
- Ảnh không được lưu vào thư viện khi quyền bị từ chối

---

## TC-21-012: Chưa đăng nhập — chuyển về màn hình đăng nhập

**AC liên quan:** Mục 5 (Nhóm 3)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng chưa đăng nhập vào StampMail

### Act (Thực hiện)
- Cố truy cập tính năng Chia sẻ tem (ví dụ qua deep link hoặc điều hướng trực tiếp)

### Assert (Kiểm tra)
- Hệ thống chuyển người dùng về màn hình đăng nhập
- Sau khi đăng nhập thành công, hệ thống quay lại luồng chia sẻ

---

## TC-21-013: Thoát app giữa luồng — trạng thái không được lưu

**AC liên quan:** Mục 5 (Nhóm 3)
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào StampMail
- Người dùng đang ở giữa luồng chia sẻ (đã chọn tem và mức nội dung nhưng chưa lưu hoặc chia sẻ)

### Act (Thực hiện)
- Thoát khỏi StampMail (nhấn Home hoặc chuyển sang app khác)
- Mở lại StampMail
- Vào lại màn hình Chia sẻ tem

### Assert (Kiểm tra)
- Trạng thái chưa lưu bị hủy
- Người dùng bắt đầu lại từ bước chọn tem — không có dữ liệu nào từ phiên trước được giữ lại

---

## TC-21-014: Album không tải được do lỗi mạng — hiển thị nút Thử lại

**AC liên quan:** Mục 5 (Nhóm 2)
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào StampMail
- Mạng hoặc máy chủ không khả dụng khi tải danh sách tem trong Album

### Act (Thực hiện)
- Mở màn hình Chia sẻ tem (hoặc Album)
- Quan sát kết quả khi danh sách tem không tải được

### Assert (Kiểm tra)
- Màn hình hiển thị thông báo lỗi rõ ràng
- Có nút "Thử lại" để người dùng nạp lại danh sách tem
- Các tem đã được lưu cục bộ trước đó vẫn hiển thị và dùng được bình thường

---

## TC-21-015: Chọn Mức 2 — màn hình cho phép chọn một câu trích dẫn từ thư

**AC liên quan:** BR-02 (Mức 2)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào StampMail
- Người dùng có tem trong Album với thư đính kèm có nhiều câu

### Act (Thực hiện)
- Mở Album, chọn tem có thư
- Nhấn nút "Chia sẻ"
- Chọn "Mức 2 — Tem + một dòng trích dẫn"

### Assert (Kiểm tra)
- Màn hình hiển thị danh sách các câu từ nội dung thư để người dùng chọn
- Người dùng chỉ có thể chọn một câu duy nhất làm trích dẫn
- Sau khi chọn, câu được chọn xuất hiện trong bản xem trước ảnh chia sẻ

---

## TC-21-016: Xác nhận cảnh báo Mức 2 — luồng chia sẻ tiếp tục bình thường

**AC liên quan:** AC-02, BR-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào StampMail
- Người dùng có tem trong Album với thư đính kèm

### Act (Thực hiện)
- Mở Album, chọn tem có thư
- Nhấn nút "Chia sẻ"
- Chọn "Mức 2 — Tem + một dòng trích dẫn", chọn một câu
- Nhấn "Tiếp tục"
- Hộp thoại cảnh báo xuất hiện — nhấn nút xác nhận

### Assert (Kiểm tra)
- Luồng chia sẻ tiếp tục sau khi xác nhận
- Màn hình chọn định dạng hoặc bước tiếp theo hiển thị
- Cảnh báo "Nội dung thư sẽ công khai" không xuất hiện lại trong cùng luồng

---

## TC-21-017: Hai định dạng 9:16 và 1:1 đều có sẵn để chọn

**AC liên quan:** BR-04, AC-05
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào StampMail
- Người dùng có ít nhất một tem trong Album

### Act (Thực hiện)
- Mở Album, chọn một tem
- Nhấn nút "Chia sẻ"
- Chọn Mức 1
- Quan sát màn hình chọn định dạng

### Assert (Kiểm tra)
- Màn hình hiển thị đúng hai tùy chọn định dạng: "Dọc 9:16" và "Vuông 1:1"
- Không có định dạng nào bị thiếu
- Người dùng chỉ có thể chọn một trong hai trước khi nhấn Chia sẻ

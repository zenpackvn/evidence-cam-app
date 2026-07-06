# Checklist QA — Chọn template thư (010-chon-template-thu)

## Điều kiện tiên quyết
- [ ] Người dùng đã đăng nhập vào ứng dụng StampMail (SM-001)
- [ ] Có ít nhất một tài khoản gói Thường (Free) và một tài khoản gói Premium để kiểm thử
- [ ] Danh sách template đã được tải sẵn trên server (ít nhất 3 template Free và hơn 20 template Premium)
- [ ] Thiết bị có kết nối mạng ổn định (trừ các trường hợp kiểm thử offline)

---

## Luồng chính (Happy Path)

### BR-01 / AC-01 — Danh sách template theo chủ đề
- [ ] Khi mở màn hình chọn template, danh sách template hiển thị được nhóm theo chủ đề (sinh nhật, tình yêu, cảm ơn, chúc mừng, nhớ nhung, lễ hội, v.v.) ✅
- [ ] Template Free hiển thị bình thường, không có biểu tượng khoá ✅
- [ ] Template Premium hiển thị có dấu khoá hoặc nhãn "Premium" rõ ràng ✅

### BR-02 / AC-01 — Template Free
- [ ] Người dùng gói Thường thấy đúng ba (3) template cơ bản không bị khoá ✅

### BR-03 / AC-01 — Template Premium (người dùng Premium)
- [ ] Người dùng gói Premium thấy hơn hai mươi (20) template theo nhiều chủ đề đặc biệt ✅
- [ ] Không có template nào có dấu khoá với người dùng Premium ✅
- [ ] Người dùng Premium có thể nhấn vào bất kỳ template nào để xem trước ✅

### BR-04 / AC-02 — Xem trước template Free
- [ ] Nhấn vào một template Free hiển thị màn hình xem trước với đầy đủ nền giấy, bố cục và họa tiết ✅
- [ ] Màn hình xem trước của template Free hiển thị nút "Chọn template này" ✅
- [ ] Không có gợi ý nâng cấp trên màn hình xem trước của template Free ✅

### BR-03 / AC-03 — Người dùng Free xem trước template Premium
- [ ] Người dùng gói Thường nhấn vào template Premium (có dấu khoá) mở được màn hình xem trước đầy đủ ✅
- [ ] Màn hình xem trước của template Premium hiển thị nền giấy, bố cục, họa tiết giống hệt khi xem template Free ✅

### BR-03 / AC-07 — Gợi ý nâng cấp trên xem trước template Premium (người dùng Free)
- [ ] Nút "Chọn template này" KHÔNG xuất hiện trên màn hình xem trước template Premium với người dùng Free ✅
- [ ] Nút "Nâng cấp Premium để dùng template này" hiển thị thay thế ✅
- [ ] Nhấn nút "Nâng cấp Premium để dùng template này" điều hướng đến màn hình Nâng cấp Premium (SM-028) ✅

### BR-05 / AC-04 — Chọn template và chuyển sang soạn thư
- [ ] Sau khi xem trước template Free, nhấn "Chọn template này" chuyển sang màn hình soạn nội dung (SM-013) ✅
- [ ] Template đã chọn được áp dụng đúng làm nền trên màn hình soạn nội dung ✅
- [ ] Người dùng Premium nhấn "Chọn template này" trên template Premium cũng chuyển sang soạn nội dung thành công ✅

### BR-05 — Đổi template sau khi đã bắt đầu soạn
- [ ] Khi người dùng đổi template sau khi đã soạn nội dung, nội dung thư (chữ, font) được giữ nguyên — chỉ nền giấy và bố cục thay đổi ✅
- [ ] Không có hộp thoại cảnh báo hay yêu cầu xác nhận khi đổi template ✅
- [ ] Sticker đã dán vẫn còn trên thư sau khi đổi template ✅
- [ ] Sticker nằm trong vùng hiển thị vẫn ở đúng vị trí cũ sau khi đổi template ✅

---

## Luồng thất bại & Validation

### BR-06 / AC-05 — Chế độ ngoại tuyến: template đã tải
- [ ] Khi mất kết nối, thông báo "Đang xem ngoại tuyến" hiển thị ở đầu màn hình 🚫
- [ ] Các template đã tải trước đó vẫn hiển thị và xem trước được bình thường khi mất mạng 🚫
- [ ] Template chưa tải hiển thị trạng thái không khả dụng tại ô tương ứng (không crash ứng dụng) 🚫

### BR-07 / AC-06 — Chặn chọn template khi mất kết nối
- [ ] Khi mất kết nối, nhấn "Chọn template này" không chuyển sang màn hình soạn nội dung 🚫
- [ ] Thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." hiển thị sau khi nhấn 🚫

### Lỗi tải danh sách (Mục 5)
- [ ] Khi không tải được danh sách template (lỗi mạng hoặc server), màn hình hiển thị trạng thái lỗi rõ ràng (không màn hình trắng, không crash) 🚫
- [ ] Nút "Thử lại" hiển thị và tải lại danh sách mà không cần thoát màn hình 🚫

### Chưa đăng nhập (Mục 5)
- [ ] Khi chưa đăng nhập, cố gắng vào màn hình chọn template bị chặn và tự động chuyển về màn hình đăng nhập ✅

---

## Trường hợp biên (Edge Cases)

- [ ] Người dùng quay lại màn hình danh sách từ màn hình xem trước mà không chọn template — không có template nào được xác nhận chọn ✅
- [ ] Danh sách template cuộn mượt mà khi số lượng template nhiều hơn kích thước màn hình ✅
- [ ] Sticker nằm ngoài vùng bố cục sau khi đổi template tự dịch vào trong vùng hiển thị, không bị mất 🔲
- [ ] Thoát app giữa chừng (chưa xác nhận chọn template) — mở lại app không có dữ liệu bị mất, người dùng quay về màn hình chọn template từ đầu 🔲

---

## Ghi chú tự động hóa
- ✅ Maestro automatable — có thể tự động hoá bằng Maestro YAML (tap, assert text/id, scroll, navigation)
- 🔲 Manual only — chỉ kiểm thử thủ công (animation, trạng thái thiết bị, force close app)
- 🚫 Not automatable — không thể tự động hoá (kiểm tra trạng thái offline/mạng thực, lỗi server, điều kiện không tái tạo được trong môi trường test)

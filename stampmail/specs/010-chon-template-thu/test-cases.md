# Test Cases — Chọn template thư (010-chon-template-thu)

## TC-10-001: Hiển thị danh sách template nhóm theo chủ đề

**AC liên quan:** AC-01 (BR-01)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản gói Thường (Free)
- Điều hướng đến luồng soạn thư mới

### Act (Thực hiện)
- Mở màn hình chọn template

### Assert (Kiểm tra)
- Màn hình hiển thị danh sách template được nhóm theo các chủ đề: sinh nhật, tình yêu, cảm ơn, chúc mừng, nhớ nhung, lễ hội
- Template Free hiển thị bình thường, không có biểu tượng khoá
- Template Premium có dấu khoá hoặc nhãn "Premium" hiển thị rõ ràng

---

## TC-10-002: Người dùng Free thấy đúng ba template cơ bản

**AC liên quan:** AC-01 (BR-02)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản gói Thường (Free)
- Mở màn hình chọn template

### Act (Thực hiện)
- Xem toàn bộ danh sách template, đếm số lượng template không có dấu khoá

### Assert (Kiểm tra)
- Đúng ba (3) template hiển thị không có dấu khoá (template cơ bản)
- Các template còn lại trong danh sách đều có dấu khoá Premium

---

## TC-10-003: Người dùng Premium thấy toàn bộ template không bị khoá

**AC liên quan:** AC-01 (BR-03)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản gói Premium
- Mở màn hình chọn template

### Act (Thực hiện)
- Xem danh sách toàn bộ template

### Assert (Kiểm tra)
- Hiển thị hơn hai mươi (20) template theo nhiều chủ đề đặc biệt
- Không có template nào có dấu khoá
- Tất cả template đều có thể nhấn vào để xem trước

---

## TC-10-004: Xem trước template Free trước khi chọn

**AC liên quan:** AC-02 (BR-04)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản gói Thường (Free)
- Mở màn hình chọn template
- Đảm bảo có ít nhất một template Free trong danh sách

### Act (Thực hiện)
- Nhấn vào một template Free (không có dấu khoá)

### Assert (Kiểm tra)
- Màn hình xem trước hiển thị đầy đủ nền giấy, bố cục và họa tiết của template đó
- Nút "Chọn template này" hiển thị trên màn hình xem trước
- Không có gợi ý nâng cấp trên màn hình này

---

## TC-10-005: Người dùng Free xem trước được template Premium

**AC liên quan:** AC-03 (BR-03)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản gói Thường (Free)
- Mở màn hình chọn template

### Act (Thực hiện)
- Nhấn vào một template Premium (có dấu khoá)

### Assert (Kiểm tra)
- Màn hình xem trước mở ra và hiển thị đầy đủ nền giấy, bố cục, họa tiết — giống hệt khi xem template Free
- Không bị chặn hay hiển thị lỗi khi mở xem trước

---

## TC-10-006: Nút chọn ẩn và gợi ý nâng cấp hiển thị trên xem trước template Premium

**AC liên quan:** AC-07 (BR-03)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản gói Thường (Free)
- Nhấn vào một template Premium để mở màn hình xem trước

### Act (Thực hiện)
- Quan sát màn hình xem trước của template Premium

### Assert (Kiểm tra)
- Nút "Chọn template này" KHÔNG xuất hiện trên màn hình
- Nút "Nâng cấp Premium để dùng template này" hiển thị thay thế

---

## TC-10-007: Nhấn gợi ý nâng cấp từ xem trước Premium dẫn đến màn hình Nâng cấp Premium

**AC liên quan:** AC-07 (BR-03)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản gói Thường (Free)
- Đang ở màn hình xem trước của một template Premium
- Nút "Nâng cấp Premium để dùng template này" đang hiển thị

### Act (Thực hiện)
- Nhấn vào nút "Nâng cấp Premium để dùng template này"

### Assert (Kiểm tra)
- Ứng dụng điều hướng sang màn hình Nâng cấp Premium (SM-028)

---

## TC-10-008: Chọn template Free và chuyển sang soạn nội dung

**AC liên quan:** AC-04 (BR-05)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản gói Thường (Free)
- Mở màn hình chọn template
- Nhấn vào một template Free để xem trước

### Act (Thực hiện)
- Nhấn nút "Chọn template này" trên màn hình xem trước

### Assert (Kiểm tra)
- Ứng dụng chuyển sang màn hình soạn nội dung (SM-013)
- Template đã chọn được áp dụng làm nền trên màn hình soạn nội dung
- Nền giấy và họa tiết của template hiển thị đúng

---

## TC-10-009: Người dùng Premium chọn template Premium thành công

**AC liên quan:** AC-04 (BR-03)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản gói Premium
- Mở màn hình chọn template
- Nhấn vào một template Premium để xem trước

### Act (Thực hiện)
- Nhấn nút "Chọn template này" trên màn hình xem trước

### Assert (Kiểm tra)
- Ứng dụng chuyển sang màn hình soạn nội dung (SM-013)
- Template Premium đã chọn được áp dụng làm nền
- Giao diện soạn nội dung hiển thị đúng với thiết kế của template Premium

---

## TC-10-010: Đổi template sau khi đã soạn — nội dung và font chữ được giữ lại

**AC liên quan:** BR-05
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản gói Thường (Free)
- Chọn template A và chuyển sang màn hình soạn nội dung (SM-013)
- Nhập nội dung "Chúc mừng sinh nhật!" và chọn font chữ

### Act (Thực hiện)
- Quay lại màn hình chọn template
- Nhấn vào template B (Free) khác và nhấn "Chọn template này"

### Assert (Kiểm tra)
- Nội dung "Chúc mừng sinh nhật!" vẫn còn nguyên
- Font chữ đã chọn vẫn được giữ
- Chỉ nền giấy và bố cục thay đổi theo template mới
- Không có hộp thoại cảnh báo hay yêu cầu xác nhận nào xuất hiện

---

## TC-10-011: Đổi template — sticker trong vùng hiển thị được giữ nguyên vị trí

**AC liên quan:** BR-05 (Mục 5)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã chọn template A và dán sticker ở vị trí trung tâm thư (trong vùng hiển thị của cả hai bố cục)

### Act (Thực hiện)
- Quay lại màn hình chọn template và chọn template B với bố cục khác
- Nhấn "Chọn template này"

### Assert (Kiểm tra)
- Sticker vẫn còn trên thư sau khi đổi template
- Sticker không bị xoá
- Người dùng có thể tiếp tục chỉnh vị trí sticker sau khi đổi template

---

## TC-10-012: Đổi template — sticker nằm ngoài vùng bố cục mới tự dịch vào trong

**AC liên quan:** BR-05 (Mục 5)
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đặt sticker ở góc ngoài cùng của template A (bố cục rộng)
- Đang chuẩn bị đổi sang template B có bố cục hẹp hơn

### Act (Thực hiện)
- Chọn template B với bố cục hẹp hơn và nhấn "Chọn template này"

### Assert (Kiểm tra)
- Sticker tự dịch vào trong vùng hiển thị của template B
- Sticker không bị mất, không bị xoá
- Người dùng có thể tiếp tục chỉnh vị trí sticker sau khi đổi template

---

## TC-10-013: Quay lại danh sách template từ màn hình xem trước

**AC liên quan:** AC-02 (BR-04)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản bất kỳ
- Mở màn hình xem trước của một template Free

### Act (Thực hiện)
- Nhấn nút quay lại (back) trên màn hình xem trước mà không nhấn "Chọn template này"

### Assert (Kiểm tra)
- Ứng dụng quay lại màn hình danh sách template
- Không có template nào được xác nhận chọn
- Không chuyển sang màn hình soạn nội dung

---

## TC-10-014: Cuộn danh sách template khi danh sách dài

**AC liên quan:** AC-01 (BR-01)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản gói Premium
- Mở màn hình chọn template (có hơn 20 template)

### Act (Thực hiện)
- Cuộn xuống danh sách template

### Assert (Kiểm tra)
- Danh sách cuộn mượt mà, hiển thị các template ở phần dưới
- Tất cả chủ đề và template đều có thể truy cập qua cuộn

---

## TC-10-015: Template đã tải vẫn xem được và thông báo ngoại tuyến hiển thị khi mất kết nối

**AC liên quan:** AC-05 (BR-06)
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Mở ứng dụng khi có kết nối, tải danh sách template
- Xem trước ít nhất một template Free để template được lưu vào bộ nhớ tạm
- Tắt kết nối mạng (WiFi và dữ liệu di động)

### Act (Thực hiện)
- Điều hướng đến màn hình chọn template
- Quan sát thông báo trên màn hình và nhấn vào template đã tải trước đó

### Assert (Kiểm tra)
- Thông báo "Đang xem ngoại tuyến" hiển thị ở đầu màn hình
- Các template đã tải trước đó vẫn hiện ra bình thường
- Màn hình xem trước của template đã tải hiển thị đúng dù không có mạng
- Ứng dụng không bị treo hoặc crash

---

## TC-10-016: Template chưa tải hiển thị trạng thái không khả dụng khi mất kết nối

**AC liên quan:** AC-05 (BR-06)
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Tắt kết nối mạng trước khi mở ứng dụng hoặc trước khi tải danh sách template
- Mở màn hình chọn template

### Act (Thực hiện)
- Xem danh sách template (trong trạng thái không có mạng)

### Assert (Kiểm tra)
- Các template chưa được tải hiển thị trạng thái không khả dụng tại ô tương ứng
- Ứng dụng không bị crash
- Người dùng vẫn thấy giao diện danh sách; chỉ các ô chưa tải mới không khả dụng

---

## TC-10-017: Không thể xác nhận chọn template khi mất kết nối

**AC liên quan:** AC-06 (BR-07)
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Mở ứng dụng khi có kết nối, tải danh sách template và mở xem trước một template Free
- Tắt kết nối mạng

### Act (Thực hiện)
- Nhấn "Chọn template này" trên màn hình xem trước khi đã mất kết nối

### Assert (Kiểm tra)
- Ứng dụng KHÔNG chuyển sang màn hình soạn nội dung
- Thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." hiển thị
- Người dùng vẫn ở lại màn hình xem trước

---

## TC-10-018: Màn hình lỗi và nút "Thử lại" khi không tải được danh sách template

**AC liên quan:** Mục 5 (lỗi mạng / lỗi server)
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Thiết bị có kết nối mạng nhưng server gặp sự cố hoặc kết nối rất chậm
- Mở màn hình chọn template

### Act (Thực hiện)
- Chờ quá trình tải dữ liệu thất bại
- Quan sát màn hình và nhấn nút "Thử lại"

### Assert (Kiểm tra)
- Màn hình hiển thị trạng thái lỗi rõ ràng (không màn hình trắng hay crash)
- Nút "Thử lại" hiển thị và có thể nhấn được
- Sau khi nhấn "Thử lại", ứng dụng tải lại danh sách template mà không cần thoát màn hình

---

## TC-10-019: Chưa đăng nhập — không vào được màn hình chọn template

**AC liên quan:** Mục 5 (chưa đăng nhập) / BR phạm vi SM-001
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đảm bảo người dùng chưa đăng nhập hoặc đã đăng xuất khỏi ứng dụng

### Act (Thực hiện)
- Cố gắng điều hướng đến màn hình chọn template (soạn thư mới)

### Assert (Kiểm tra)
- Ứng dụng không cho vào màn hình chọn template
- Tự động chuyển về màn hình đăng nhập

---

## TC-10-020: Thoát app giữa chừng — quay về màn hình chọn template từ đầu

**AC liên quan:** Mục 5 (thoát app giữa chừng)
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập và mở màn hình chọn template
- Chưa xác nhận chọn bất kỳ template nào

### Act (Thực hiện)
- Tắt hoàn toàn ứng dụng (force close)
- Mở lại ứng dụng

### Assert (Kiểm tra)
- Ứng dụng mở lại bình thường, không có dữ liệu bị mất (vì chưa có nội dung soạn)
- Người dùng cần bắt đầu lại từ màn hình chọn template nếu muốn soạn thư mới

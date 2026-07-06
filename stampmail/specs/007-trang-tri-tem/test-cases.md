# Test Cases — Trang trí tem (SM-008 / 007-trang-tri-tem)

## TC-07-001: Thêm sticker Free lên tem

**AC liên quan:** AC-01
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản gói Thường (Free)
- Hoàn thành bước xoá nền (SM-007) để vào bước trang trí tem

### Act (Thực hiện)
- Mở danh sách bộ sticker
- Chọn bộ sticker cơ bản (ví dụ: bộ "thiên nhiên")
- Nhấn vào một sticker Free để đặt lên tem

### Assert (Kiểm tra)
- Sticker xuất hiện trên vùng xem trước tem
- Sticker có thể kéo đến vị trí khác trong vùng tem

---

## TC-07-002: Sticker đặc biệt bị khoá — hiển thị hai lựa chọn mở khoá

**AC liên quan:** AC-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản gói Thường (Free)
- Đang ở bước trang trí tem

### Act (Thực hiện)
- Mở danh sách bộ sticker
- Nhấn vào một sticker thuộc bộ đặc biệt (có biểu tượng khoá)

### Assert (Kiểm tra)
- Hệ thống hiển thị hai lựa chọn: "Dùng 50📮 để mở bộ này" và "Nâng cấp Premium để mở tất cả"
- Không có sticker nào được đặt lên vùng xem trước tem
- Tem vẫn giữ nguyên trạng thái trước khi nhấn

---

## TC-07-003: Thêm chữ với font tay viết

**AC liên quan:** AC-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đang ở bước trang trí tem (bất kỳ loại tài khoản)

### Act (Thực hiện)
- Nhấn chức năng "Thêm chữ"
- Nhập nội dung văn bản (ví dụ: "Kỷ niệm mãi mãi")
- Chọn font "tay viết"
- Xác nhận thêm chữ

### Assert (Kiểm tra)
- Chữ "Kỷ niệm mãi mãi" xuất hiện trên vùng xem trước tem
- Chữ hiển thị đúng với font tay viết đã chọn
- Chữ có thể kéo đến vị trí mong muốn trên tem

---

## TC-07-004: Chọn font in ấn cho chữ

**AC liên quan:** AC-03 (BR-03)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đang ở bước trang trí tem
- Đã mở chức năng "Thêm chữ" và nhập nội dung

### Act (Thực hiện)
- Chọn font "in ấn" trong danh sách font
- Xác nhận thêm chữ

### Assert (Kiểm tra)
- Chữ hiển thị trên tem với font in ấn (khác với font tay viết)
- Danh sách font có ít nhất hai lựa chọn: tay viết và in ấn

---

## TC-07-005: Chỉnh kích thước và màu chữ

**AC liên quan:** AC-03 (BR-03)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đang ở bước trang trí tem
- Đã mở chức năng "Thêm chữ"

### Act (Thực hiện)
- Nhập nội dung chữ
- Chỉnh kích thước chữ (tăng)
- Chọn màu chữ khác màu mặc định
- Xác nhận thêm chữ

### Assert (Kiểm tra)
- Chữ hiển thị với kích thước đã chỉnh
- Chữ hiển thị với màu đã chọn

---

## TC-07-006: Chọn và di chuyển phần tử

**AC liên quan:** AC-04
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đang ở bước trang trí tem
- Đã thêm ít nhất một sticker lên tem

### Act (Thực hiện)
- Chạm một lần vào sticker — khung điều khiển xuất hiện xung quanh
- Giữ và kéo sticker sang góc khác của tem

### Assert (Kiểm tra)
- Sticker di chuyển theo đúng hướng ngón tay
- Sticker dừng tại vị trí thả tay
- Các phần tử khác trên tem không bị ảnh hưởng
- Chạm ra ngoài phần tử thì khung điều khiển biến mất

---

## TC-07-007: Phóng to sticker bằng banh ngón tay

**AC liên quan:** AC-05
**Loại:** E2E
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Đang ở bước trang trí tem
- Đã thêm một sticker lên tem và sticker đang được chọn

### Act (Thực hiện)
- Đặt hai ngón tay lên sticker
- Banh hai ngón tay ra

### Assert (Kiểm tra)
- Sticker to ra theo tỉ lệ trong suốt quá trình banh
- Thả tay, sticker giữ nguyên kích thước ở mức đó
- Tỉ lệ hình dạng sticker không bị méo

---

## TC-07-008: Thu nhỏ sticker bằng chụm ngón tay

**AC liên quan:** AC-09
**Loại:** E2E
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Đang ở bước trang trí tem
- Đã thêm một sticker kích thước lớn lên tem

### Act (Thực hiện)
- Đặt hai ngón tay lên sticker
- Chụm hai ngón tay vào

### Assert (Kiểm tra)
- Sticker nhỏ lại theo độ chụm
- Sticker không nhỏ hơn kích thước tối thiểu (vẫn nhìn thấy được — không nhỏ hơn một phần mười chiều rộng vùng tem)
- Khi đạt giới hạn tối thiểu, sticker không tiếp tục nhỏ thêm dù vẫn chụm

---

## TC-07-009: Xoay phần tử trang trí

**AC liên quan:** AC-10
**Loại:** E2E
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Đang ở bước trang trí tem
- Đã thêm một sticker lên tem

### Act (Thực hiện)
- Đặt hai ngón tay lên sticker
- Xoay hai ngón theo chiều kim đồng hồ

### Assert (Kiểm tra)
- Sticker xoay đúng theo chiều kim đồng hồ
- Thả tay, sticker giữ nguyên góc xoay đó
- Lặp lại theo chiều ngược kim đồng hồ: sticker xoay ngược lại đúng hướng

---

## TC-07-010: Giới hạn kích thước tối đa — không vượt vùng tem

**AC liên quan:** AC-11 (BR-10)
**Loại:** E2E
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Đang ở bước trang trí tem
- Đã thêm một sticker lên tem

### Act (Thực hiện)
- Banh hai ngón tay để phóng to sticker cho đến khi lấp đầy toàn bộ vùng tem
- Tiếp tục banh ngón tay thêm

### Assert (Kiểm tra)
- Sticker dừng phóng to khi đã vừa đủ toàn bộ vùng tem
- Sticker không lớn thêm dù vẫn tiếp tục banh ngón tay
- Không có thông báo lỗi, sticker không biến mất

---

## TC-07-011: Mở sticker đặc biệt bằng Dấu

**AC liên quan:** AC-06 (BR-07)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản gói Thường có ít nhất 50📮 trong ví Dấu
- Đang ở bước trang trí tem

### Act (Thực hiện)
- Nhấn vào một sticker thuộc bộ đặc biệt bị khoá
- Chọn lựa chọn "Dùng 50📮 để mở bộ này"
- Xác nhận mở khoá

### Assert (Kiểm tra)
- Bộ sticker đặc biệt được mở khoá vĩnh viễn cho tài khoản này
- Số Dấu trong ví giảm đúng 50📮
- Người dùng có thể dùng ngay các sticker trong bộ vừa mở
- Đăng xuất rồi đăng nhập lại: bộ sticker vẫn khả dụng (mở vĩnh viễn)

---

## TC-07-012: Mở sticker đặc biệt khi không đủ Dấu

**AC liên quan:** AC-06 (BR-07)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản gói Thường có ít hơn 50📮 trong ví Dấu
- Đang ở bước trang trí tem

### Act (Thực hiện)
- Nhấn vào một sticker thuộc bộ đặc biệt bị khoá
- Chọn lựa chọn "Dùng 50📮 để mở bộ này"

### Assert (Kiểm tra)
- Hệ thống thông báo không đủ Dấu để mở bộ sticker này
- Bộ sticker vẫn bị khoá
- Số Dấu trong ví không thay đổi

---

## TC-07-013: Người dùng Premium sử dụng sticker đặc biệt

**AC liên quan:** BR-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản gói Premium
- Đang ở bước trang trí tem

### Act (Thực hiện)
- Mở danh sách bộ sticker
- Nhấn vào một sticker từ bộ đặc biệt

### Assert (Kiểm tra)
- Sticker đặc biệt không hiển thị biểu tượng khoá
- Sticker xuất hiện trên vùng xem trước tem ngay sau khi chọn

---

## TC-07-014: Thêm biểu tượng nhỏ (icon) lên tem

**AC liên quan:** BR-04
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đang ở bước trang trí tem

### Act (Thực hiện)
- Mở phần thêm biểu tượng nhỏ (icon)
- Chọn một icon từ danh sách
- Đặt lên tem

### Assert (Kiểm tra)
- Icon xuất hiện trên vùng xem trước tem
- Icon có thể kéo đến vị trí khác trong vùng tem

---

## TC-07-015: Áp hoa văn nhẹ làm nền cho tem

**AC liên quan:** BR-04
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đang ở bước trang trí tem

### Act (Thực hiện)
- Mở phần chọn hoa văn nền
- Chọn một hoa văn nhẹ từ danh sách

### Assert (Kiểm tra)
- Hoa văn được áp vào nền vùng xem trước tem
- Hoa văn không che khuất ảnh chính đã xoá nền

---

## TC-07-016: Bỏ qua trang trí, chuyển thẳng sang bước viền tem

**AC liên quan:** BR-06
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đang ở bước trang trí tem, chưa thêm bất kỳ trang trí nào

### Act (Thực hiện)
- Nhấn nút "Tiếp theo" hoặc "Bỏ qua" để chuyển sang bước viền tem

### Assert (Kiểm tra)
- Ứng dụng chuyển thành công sang bước viền tem (SM-009)
- Không có thông báo lỗi hay cảnh báo bắt buộc phải thêm trang trí

---

## TC-07-017: Trang trí vẫn hoạt động bình thường khi mất mạng

**AC liên quan:** AC-07 (BR-08)
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đang ở bước trang trí tem
- Đã tải sẵn ít nhất một bộ sticker cơ bản trên thiết bị
- Tắt kết nối mạng (bật chế độ máy bay hoặc tắt Wi-Fi/dữ liệu di động)

### Act (Thực hiện)
- Thêm một sticker từ bộ đã tải sẵn lên tem
- Nhập một dòng chữ và đặt lên tem
- Kéo thả sticker và chữ sang vị trí khác
- Xoay một sticker

### Assert (Kiểm tra)
- Tất cả thao tác (thêm sticker đã có sẵn, nhập chữ, kéo thả, xoay) thực hiện được bình thường
- Không có thông báo lỗi nào xuất hiện trong suốt quá trình

---

## TC-07-018: Báo lỗi khi tải bộ sticker chưa có trên thiết bị lúc mất mạng

**AC liên quan:** AC-08 (BR-09)
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đang ở bước trang trí tem
- Có một bộ sticker đặc biệt chưa được tải về thiết bị
- Tắt kết nối mạng

### Act (Thực hiện)
- Chọn bộ sticker đặc biệt chưa được tải về thiết bị

### Assert (Kiểm tra)
- Hệ thống hiển thị thông báo: "Không có kết nối. Vui lòng thử lại khi có mạng."
- Bộ sticker đặc biệt không được tải xuống
- Các sticker đã có sẵn trên thiết bị vẫn dùng được bình thường
- Người dùng có thể tiếp tục trang trí bằng sticker đã có sẵn

---

## TC-07-019: Thêm và chỉnh chữ khi offline

**AC liên quan:** AC-07 (BR-08 — thêm chữ offline)
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đang ở bước trang trí tem
- Tắt kết nối mạng

### Act (Thực hiện)
- Nhấn chức năng "Thêm chữ"
- Nhập nội dung
- Chọn font, đổi màu, chỉnh kích thước
- Kéo thả chữ trên tem

### Assert (Kiểm tra)
- Tất cả thao tác với chữ thực hiện được bình thường khi không có mạng
- Không có thông báo lỗi liên quan đến kết nối

---

## TC-07-020: Lỗi máy chủ khi tải bộ sticker — hiển thị nút Thử lại

**AC liên quan:** Trường hợp ngoại lệ — lỗi máy chủ
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đang ở bước trang trí tem, có kết nối mạng
- Có bộ sticker đặc biệt chưa tải về thiết bị
- Giả lập máy chủ trả về lỗi khi tải sticker

### Act (Thực hiện)
- Chọn bộ sticker đặc biệt chưa tải về thiết bị

### Assert (Kiểm tra)
- Hệ thống hiển thị thông báo lỗi kèm nút "Thử lại"
- Người dùng có thể nhấn "Thử lại" mà không cần thoát khỏi bước trang trí
- Nhấn "Thử lại" và máy chủ tiếp tục lỗi: thông báo lỗi hiển thị lại
- Người dùng vẫn có thể dùng các sticker và font đã có sẵn trên thiết bị

---

## TC-07-021: Chưa đăng nhập — không vào được bước trang trí tem

**AC liên quan:** Trường hợp ngoại lệ — chưa đăng nhập
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Chưa đăng nhập vào ứng dụng

### Act (Thực hiện)
- Cố gắng vào luồng tạo tem (ví dụ: nhấn nút tạo tem trên màn hình chính)

### Assert (Kiểm tra)
- Hệ thống chuyển người dùng về màn hình đăng nhập
- Không vào được bước trang trí tem khi chưa đăng nhập

---

## TC-07-022: Thoát app giữa bước trang trí — nội dung bị mất khi mở lại

**AC liên quan:** Trường hợp ngoại lệ — thoát app giữa chừng
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đang ở bước trang trí tem
- Đã thêm một số sticker, chữ và icon lên tem

### Act (Thực hiện)
- Thoát hoàn toàn khỏi ứng dụng (force close hoặc swipe away)
- Mở lại ứng dụng

### Assert (Kiểm tra)
- Ứng dụng mở lại tại màn hình chính
- Toàn bộ nội dung trang trí đang chỉnh (sticker, chữ, icon) bị mất
- Không có thông báo lỗi bất thường

---

## TC-07-023: Xoá phần tử đã thêm

**AC liên quan:** Trường hợp ngoại lệ — xoá phần tử
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đang ở bước trang trí tem
- Đã thêm ít nhất một sticker hoặc chữ lên tem

### Act (Thực hiện)
- Chọn phần tử muốn xoá (nhấn vào phần tử để hiện khung điều khiển)
- Nhấn nút Xoá (hoặc biểu tượng thùng rác)

### Assert (Kiểm tra)
- Phần tử biến mất khỏi vùng xem trước tem
- Các phần tử khác (nếu có) không bị ảnh hưởng

---

## TC-07-024: Thêm nhiều phần tử không bị giới hạn số lượng

**AC liên quan:** Trường hợp ngoại lệ — quá nhiều phần tử
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đang ở bước trang trí tem

### Act (Thực hiện)
- Thêm liên tục nhiều sticker, chữ và icon lên tem (ít nhất 10 phần tử)

### Assert (Kiểm tra)
- Hệ thống không từ chối hay tự động xoá bất kỳ phần tử nào
- Tất cả phần tử đã thêm vẫn hiển thị trên vùng xem trước tem
- Không có thông báo lỗi về giới hạn số lượng

---

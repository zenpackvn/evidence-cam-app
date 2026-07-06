# Test Cases — Giới hạn tháng & Nhắc hạn mức (Free) (026-gioi-han-thang)

## TC-26-001: Cảnh báo khi còn 1 thư trong tháng

**AC liên quan:** AC-01
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản người dùng gói Thường (Free)
- Giả lập trạng thái: người dùng đã gửi 9 thư trong tháng hiện tại (còn 1 thư)

### Act (Thực hiện)
- Mở app và điều hướng đến màn hình liên quan đến gửi thư

### Assert (Kiểm tra)
- Màn hình hiển thị cảnh báo với nội dung "Còn 1 thư trong tháng này"
- Cảnh báo xuất hiện ở vị trí trực quan, rõ ràng cho người dùng thấy

---

## TC-26-002: Chặn gửi thư khi đã hết hạn mức

**AC liên quan:** AC-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản người dùng gói Thường (Free)
- Giả lập trạng thái: người dùng đã gửi đủ 10 thư trong tháng hiện tại

### Act (Thực hiện)
- Cố gắng soạn thêm một thư mới
- Nhấn nút gửi hoặc xác nhận gửi thư

### Assert (Kiểm tra)
- Hệ thống không cho tiếp tục gửi thư
- Hiển thị thông báo rõ ràng rằng đã hết hạn mức thư trong tháng
- Hiển thị gợi ý nâng cấp Premium hoặc chờ đến đầu tháng tiếp theo

---

## TC-26-003: Chặn lưu tem khi đã đạt 30 tem

**AC liên quan:** AC-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản người dùng gói Thường (Free)
- Giả lập trạng thái: người dùng đã lưu đủ 30 tem trong tháng hiện tại

### Act (Thực hiện)
- Cố gắng lưu thêm một tem mới qua chức năng SM-011

### Assert (Kiểm tra)
- Hệ thống không cho lưu tem mới
- Hiển thị thông báo rõ ràng rằng đã hết hạn mức tem trong tháng
- Hiển thị gợi ý nâng cấp Premium

---

## TC-26-004: Reset hạn mức vào đầu tháng mới

**AC liên quan:** AC-04
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản người dùng gói Thường (Free)
- Giả lập trạng thái: người dùng đã gửi hết 10 thư trong tháng trước
- Điều chỉnh ngày/giờ thiết bị đến ngày 1 của tháng mới theo múi giờ thiết bị

### Act (Thực hiện)
- Mở app vào ngày 1 của tháng mới

### Assert (Kiểm tra)
- Hạn mức thư được reset về 0 đã dùng (còn đủ 10 thư)
- Người dùng có thể soạn và gửi thư mới thành công mà không bị chặn
- Không còn hiển thị thông báo hết hạn mức từ tháng trước

---

## TC-26-005: Người dùng Premium không bị chặn bởi giới hạn tháng

**AC liên quan:** AC-05
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản người dùng đã nâng cấp Premium
- Chuẩn bị tạo tem và gửi thư vượt quá giới hạn Free (hơn 30 tem hoặc hơn 10 thư)

### Act (Thực hiện)
- Tạo thêm tem vượt quá ngưỡng 30 tem của Free
- Gửi thêm thư vượt quá ngưỡng 10 thư của Free

### Assert (Kiểm tra)
- Không bị chặn ở bất kỳ bước nào
- Không xuất hiện thông báo cảnh báo hạn mức
- Không xuất hiện gợi ý nâng cấp Premium (vì đã là Premium)

---

## TC-26-006: Hiển thị hạn mức còn lại khi offline

**AC liên quan:** AC-06
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản người dùng gói Thường (Free)
- Đảm bảo app đã đồng bộ hạn mức thành công khi có mạng (ví dụ: đã dùng 7 thư)
- Tắt kết nối mạng của thiết bị (bật chế độ máy bay hoặc tắt WiFi/dữ liệu di động)

### Act (Thực hiện)
- Mở app khi đang mất kết nối mạng
- Điều hướng đến màn hình theo dõi hạn mức

### Assert (Kiểm tra)
- App hiển thị đúng số thư và tem đã dùng theo dữ liệu lần cuối đồng bộ (ví dụ: đã dùng 7 thư)
- Không hiển thị màn hình trắng, giá trị trống, hoặc thông báo lỗi không có dữ liệu
- Người dùng vẫn thấy được hạn mức còn lại một cách rõ ràng

---

## TC-26-007: Chặn tạo tem khi offline

**AC liên quan:** AC-07
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản người dùng gói Thường (Free)
- Tắt kết nối mạng của thiết bị (bật chế độ máy bay hoặc tắt WiFi/dữ liệu di động)

### Act (Thực hiện)
- Cố gắng tạo tem mới trong khi mất kết nối mạng

### Assert (Kiểm tra)
- Hệ thống chặn thao tác tạo tem
- Hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."
- Không có tem nào được tạo ra

---

## TC-26-008: Chặn gửi thư khi offline

**AC liên quan:** AC-07
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản người dùng gói Thường (Free)
- Tắt kết nối mạng của thiết bị

### Act (Thực hiện)
- Cố gắng soạn và gửi thư trong khi mất kết nối mạng

### Assert (Kiểm tra)
- Hệ thống chặn thao tác gửi thư
- Hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."
- Không có thư nào được gửi đi hoặc link nào được tạo ra

---

## TC-26-009: Cảnh báo sớm khi còn dưới 6 tem

**AC liên quan:** BR-02 (hạn mức tem)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản người dùng gói Thường (Free)
- Giả lập trạng thái: người dùng đã lưu 25 tem trong tháng (còn 5 tem — dưới ngưỡng 6)

### Act (Thực hiện)
- Mở app và điều hướng đến màn hình liên quan đến quản lý tem

### Assert (Kiểm tra)
- App hiển thị cảnh báo trực quan về hạn mức tem sắp cạn
- Cảnh báo rõ ràng, dễ nhận thấy

---

## TC-26-010: Không hiển thị cảnh báo khi còn đúng 6 tem (ngưỡng biên)

**AC liên quan:** BR-02 (kiểm tra ngưỡng biên tem)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản người dùng gói Thường (Free)
- Giả lập trạng thái: người dùng đã lưu 24 tem trong tháng (còn đúng 6 tem — bằng ngưỡng, không phải dưới ngưỡng)

### Act (Thực hiện)
- Mở app và điều hướng đến màn hình quản lý tem

### Assert (Kiểm tra)
- Không hiển thị cảnh báo hạn mức tem
- Người dùng vẫn có thể lưu tem bình thường

---

## TC-26-011: Không hiển thị cảnh báo khi còn đúng 2 thư (ngưỡng biên)

**AC liên quan:** BR-02 (kiểm tra ngưỡng biên thư)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản người dùng gói Thường (Free)
- Giả lập trạng thái: người dùng đã gửi 8 thư trong tháng (còn đúng 2 thư — bằng ngưỡng)

### Act (Thực hiện)
- Mở app và điều hướng đến màn hình gửi thư

### Assert (Kiểm tra)
- Không hiển thị cảnh báo hạn mức thư
- Người dùng vẫn có thể gửi thư bình thường

---

## TC-26-012: Chặn lưu tem thứ 31 (kiểm tra biên chính xác)

**AC liên quan:** AC-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản người dùng gói Thường (Free)
- Giả lập trạng thái: người dùng đã lưu đúng 30 tem trong tháng (bằng giới hạn)

### Act (Thực hiện)
- Cố gắng lưu thêm 1 tem nữa (tức tem thứ 31)

### Assert (Kiểm tra)
- Hệ thống chặn việc lưu tem thứ 31
- Hiển thị thông báo hết hạn mức tem
- Tổng số tem trong tháng vẫn là 30, không tăng thêm

---

## TC-26-013: Chặn gửi thư thứ 11 (kiểm tra biên chính xác)

**AC liên quan:** AC-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản người dùng gói Thường (Free)
- Giả lập trạng thái: người dùng đã gửi đúng 10 thư trong tháng (bằng giới hạn)

### Act (Thực hiện)
- Cố gắng soạn và gửi thêm 1 thư nữa (tức thư thứ 11)

### Assert (Kiểm tra)
- Hệ thống chặn việc gửi thư thứ 11
- Hiển thị thông báo hết hạn mức thư
- Tổng số thư trong tháng vẫn là 10, không tăng thêm

---

## TC-26-014: Điều hướng đến màn hình nâng cấp Premium khi hết hạn mức

**AC liên quan:** AC-02, AC-03 (luồng gợi ý nâng cấp)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản người dùng gói Thường (Free)
- Giả lập trạng thái: người dùng đã hết hạn mức thư (đã gửi 10 thư)

### Act (Thực hiện)
- Cố gắng gửi thêm thư — bị chặn và thấy thông báo hết hạn mức
- Nhấn vào nút/link gợi ý nâng cấp Premium trong thông báo

### Assert (Kiểm tra)
- App điều hướng đến màn hình nâng cấp Premium (SM-028)
- Màn hình nâng cấp hiển thị đúng và có thể tương tác

---

## TC-26-015: Tạo link mới cho thư hết hạn trừ vào hạn mức thư

**AC liên quan:** Trường hợp ngoại lệ mục 5 (SM-021)
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản người dùng gói Thường (Free)
- Giả lập trạng thái: người dùng đã gửi 9 thư trong tháng (còn 1 thư)
- Có sẵn một thư đã hết hạn cần tạo link mới (qua SM-021)

### Act (Thực hiện)
- Vào thư đã hết hạn
- Thực hiện tạo link mới cho thư đó qua chức năng SM-021

### Assert (Kiểm tra)
- Link mới được tạo thành công và được tính vào hạn mức thư của tháng
- Hạn mức thư còn lại giảm từ 1 xuống 0
- Nếu thực hiện thêm lần nữa khi hết hạn mức: hệ thống chặn và thông báo hết hạn mức

---

## TC-26-016: Reset hạn mức theo múi giờ thiết bị người dùng

**AC liên quan:** Trường hợp ngoại lệ mục 5 (múi giờ)
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản người dùng gói Thường (Free)
- Giả lập trạng thái: đã hết hạn mức thư trong tháng
- Thiết lập múi giờ thiết bị khác với múi giờ server (ví dụ: UTC+12 hoặc UTC-8)
- Điều chỉnh ngày/giờ thiết bị đến 00:01 ngày 1 tháng mới theo múi giờ thiết bị

### Act (Thực hiện)
- Mở app vào đúng thời điểm ngày 1 tháng mới theo đồng hồ thiết bị

### Assert (Kiểm tra)
- Hạn mức được reset theo múi giờ thiết bị (không phải giờ server)
- Người dùng thấy ngày 1 tháng và hạn mức mới ngay trên điện thoại của họ
- Người dùng có thể gửi thư ngay sau khi reset mà không bị chặn

---

## TC-26-017: Nâng cấp Premium trong tháng — hết giới hạn ngay lập tức

**AC liên quan:** AC-05 (BR-05)
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản người dùng gói Thường (Free)
- Giả lập trạng thái: đã dùng gần hết hạn mức (ví dụ: đã gửi 9 thư, đã lưu 28 tem)
- Thực hiện nâng cấp lên gói Premium (SM-028)

### Act (Thực hiện)
- Sau khi nâng cấp Premium thành công
- Cố gắng tạo thêm tem và gửi thêm thư vượt quá ngưỡng Free

### Assert (Kiểm tra)
- Không bị chặn sau khi nâng cấp Premium
- Không hiển thị cảnh báo hạn mức
- Có thể tạo tem và gửi thư tự do không giới hạn

---

## TC-26-018: Hiển thị dữ liệu cache khi đồng bộ hạn mức thất bại (lỗi máy chủ)

**AC liên quan:** Trường hợp ngoại lệ mục 5 (lỗi mạng / lỗi máy chủ)
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản người dùng gói Thường (Free)
- App đã có dữ liệu hạn mức trong cache cục bộ từ lần đồng bộ trước
- Giả lập lỗi máy chủ hoặc mạng yếu khiến việc đồng bộ hạn mức thất bại

### Act (Thực hiện)
- Mở app và điều hướng đến màn hình theo dõi hạn mức

### Assert (Kiểm tra)
- App hiển thị số liệu từ cache cục bộ (dữ liệu lần đồng bộ gần nhất)
- Hiển thị thông báo "Không thể cập nhật dữ liệu" để người dùng biết dữ liệu chưa được làm mới
- Có nút "Thử lại" để người dùng đồng bộ lại thủ công
- Không hiển thị màn hình trắng hoặc lỗi không có dữ liệu

---

## TC-26-019: Không hiển thị hạn mức khi chưa đăng nhập

**AC liên quan:** Trường hợp ngoại lệ mục 5 (chưa đăng nhập)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đảm bảo người dùng chưa đăng nhập vào app (hoặc đăng xuất trước)

### Act (Thực hiện)
- Mở app ở trạng thái chưa đăng nhập
- Điều hướng đến các màn hình liên quan đến hạn mức (nếu có thể truy cập)

### Assert (Kiểm tra)
- Không hiển thị số liệu hạn mức (số tem đã dùng, số thư đã dùng)
- Không hiển thị banner cảnh báo hạn mức
- Toàn bộ phần theo dõi hạn mức bị ẩn hoàn toàn

---

## TC-26-020: Dữ liệu hạn mức không bị mất khi thoát app giữa chừng

**AC liên quan:** Trường hợp ngoại lệ mục 5 (thoát app giữa chừng)
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản người dùng gói Thường (Free)
- Điều hướng đến màn hình theo dõi hạn mức, ghi nhớ số liệu hiện tại (ví dụ: đã dùng 5 thư, 12 tem)

### Act (Thực hiện)
- Đóng/thoát app đột ngột (force close hoặc vuốt tắt app)
- Mở lại app sau một vài giây

### Assert (Kiểm tra)
- Dữ liệu hạn mức không bị mất
- Màn hình hạn mức hiển thị đúng số liệu theo cache đã lưu hoặc dữ liệu đồng bộ mới nhất
- Không phải nhập lại hay làm mới thủ công để thấy số liệu

---

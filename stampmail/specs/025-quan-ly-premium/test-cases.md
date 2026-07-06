# Test Cases — Quản lý đăng ký Premium (SM-029 / 025-quan-ly-premium)

## TC-25-001: Xem trạng thái gói và ngày hết hạn

**AC liên quan:** AC-01
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Tài khoản đã đăng nhập.
- Tài khoản đang dùng gói Premium tháng, chưa huỷ tự động gia hạn.
- Kỳ Premium còn hiệu lực (chưa hết hạn).

### Act (Thực hiện)
- Người dùng mở màn hình quản lý đăng ký (ví dụ: Tài khoản → Quản lý đăng ký).

### Assert (Kiểm tra)
- Màn hình hiển thị tên gói: "Premium tháng" (hoặc tương đương).
- Màn hình hiển thị ngày hết hạn cụ thể (ví dụ: "Hết hạn: 24/07/2026").
- Màn hình hiển thị trạng thái "Tự động gia hạn: Bật".

---

## TC-25-002: Huỷ tự động gia hạn và kiểm tra trạng thái sau huỷ

**AC liên quan:** AC-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Tài khoản đang dùng Premium tháng, tự động gia hạn đang Bật.
- Kỳ hiện tại còn mười ngày trước khi hết hạn.

### Act (Thực hiện)
- Người dùng mở màn hình quản lý đăng ký.
- Nhấn nút "Huỷ tự động gia hạn".
- Hộp thoại xác nhận xuất hiện; người dùng nhấn "Xác nhận".

### Assert (Kiểm tra)
- Trạng thái trên màn hình đổi thành "Tự động gia hạn: Đã huỷ".
- Ngày hết hạn không thay đổi (vẫn là ngày cuối kỳ đã trả).
- Không có thông báo cắt Premium ngay lập tức.

---

## TC-25-003: Tự động chuyển về Free sau khi hết kỳ Premium

**AC liên quan:** AC-03
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Tài khoản đã huỷ tự động gia hạn ở kỳ trước.
- Backend/môi trường test được thiết lập để kỳ Premium đã hết hạn (ngày hết hạn đã qua).

### Act (Thực hiện)
- Người dùng mở app sau ngày hết hạn của kỳ Premium.

### Assert (Kiểm tra)
- Tài khoản ở trạng thái Free (không còn biểu tượng / nhãn Premium).
- Các tính năng chỉ dành cho Premium bị khoá hoặc hiển thị gợi ý nâng cấp.
- Tem và thư đã tạo/nhận trong thời gian Premium vẫn còn nguyên trong Album (không bị xoá).

---

## TC-25-004: Lịch sử thanh toán đầy đủ ba kỳ

**AC liên quan:** AC-04
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Tài khoản đã thanh toán đúng ba kỳ Premium (dữ liệu được seed trong môi trường test).
- Mỗi kỳ có ngày khác nhau, số tiền khác nhau (ví dụ: tháng vs năm).

### Act (Thực hiện)
- Người dùng mở màn hình quản lý đăng ký.
- Chuyển sang tab hoặc kéo xuống phần lịch sử thanh toán.

### Assert (Kiểm tra)
- Danh sách hiển thị đúng ba kỳ.
- Mỗi kỳ có ngày thanh toán, số tiền và loại gói (tháng / năm) rõ ràng.
- Thứ tự hiển thị từ mới nhất đến cũ nhất (hoặc nhất quán theo thiết kế).

---

## TC-25-005: Dữ liệu giữ nguyên sau khi về Free

**AC liên quan:** AC-05
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Tài khoản Premium đã tạo ít nhất năm tem và ba thư trong thời gian Premium.
- Backend/môi trường test được thiết lập để kỳ Premium đã hết hạn và tài khoản đã chuyển về Free.

### Act (Thực hiện)
- Người dùng mở Album sau khi tài khoản chuyển về Free.

### Assert (Kiểm tra)
- Tất cả tem đã tạo/nhận trong thời gian Premium vẫn hiển thị đầy đủ trong Album.
- Tất cả thư đã tạo/nhận trong thời gian Premium vẫn hiển thị đầy đủ trong Album.
- Không có tem hay thư nào bị xoá hoặc ẩn đi.

---

## TC-25-006: Nhận thông báo push trước khi Premium hết hạn

**AC liên quan:** AC-06
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Tài khoản đang dùng Premium, còn một số ngày nhất định trước ngày hết hạn (theo cấu hình hệ thống).
- Ứng dụng đã được cấp quyền nhận thông báo push.
- Backend được kích hoạt gửi thông báo nhắc nhở.

### Act (Thực hiện)
- Hệ thống đến thời điểm gửi thông báo nhắc trước hạn.

### Assert (Kiểm tra)
- Người dùng nhận được thông báo push trên thiết bị.
- Nội dung thông báo đề cập Premium sắp hết hạn.
- Thông báo có tuỳ chọn (deeplink hoặc nút) dẫn đến màn hình gia hạn.

---

## TC-25-007: Giới hạn Free áp dụng ngay khi hết Premium giữa tháng — còn hạn mức

**AC liên quan:** AC-07
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Người dùng hết Premium vào ngày 15/6.
- Trong tháng 6, đã tạo 8 thư khi còn Premium (hạn mức Free là 10 thư/tháng).

### Act (Thực hiện)
- Ngay sau khi Premium hết hạn (ngày 16/6), người dùng cố tạo thêm thư.

### Assert (Kiểm tra)
- Hệ thống tính người dùng đã dùng 8/10 thư tháng này.
- Chỉ còn 2 thư nữa trước khi cạn hạn mức.
- Giới hạn được áp dụng ngay từ thời điểm hết hạn, không chờ đến đầu tháng tiếp theo.

---

## TC-25-008: Giới hạn Free áp dụng ngay khi hết Premium giữa tháng — đã vượt hạn mức

**AC liên quan:** AC-07
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Người dùng hết Premium vào ngày 20/6.
- Trong tháng 6, đã tạo 12 thư khi còn Premium (vượt hạn mức Free 10 thư/tháng).

### Act (Thực hiện)
- Ngay sau khi Premium hết hạn, người dùng cố tạo thêm thư.

### Assert (Kiểm tra)
- Hệ thống thông báo "Bạn đã dùng hết hạn mức thư tháng này".
- Không thể tạo thêm thư cho đến đầu tháng 7.
- Giới hạn được áp dụng ngay, không chờ đến đầu tháng tiếp theo.

---

## TC-25-009: Xem thông tin đăng ký khi mất mạng — dữ liệu cache hiển thị đầy đủ

**AC liên quan:** AC-08
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Tài khoản đang dùng Premium.
- Ứng dụng đã tải trang quản lý đăng ký ít nhất một lần khi có mạng (dữ liệu đã được lưu tạm).
- Tắt kết nối mạng trên thiết bị.

### Act (Thực hiện)
- Người dùng mở màn hình quản lý đăng ký trong trạng thái không có mạng.

### Assert (Kiểm tra)
- Màn hình vẫn hiển thị đầy đủ thông tin: tên gói, ngày hết hạn, trạng thái gia hạn và lịch sử thanh toán.
- Có thông báo "Đang xem ngoại tuyến — dữ liệu có thể chưa được cập nhật" hoặc tương đương.
- Không có lỗi unhandled hoặc màn hình trắng.

---

## TC-25-010: Không thể huỷ gia hạn khi mất mạng

**AC liên quan:** AC-09
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Tài khoản đang dùng Premium, tự động gia hạn đang Bật.
- Người dùng đang xem màn hình quản lý đăng ký.
- Tắt kết nối mạng trên thiết bị.

### Act (Thực hiện)
- Người dùng nhấn nút "Huỷ tự động gia hạn".

### Assert (Kiểm tra)
- Thao tác bị chặn — không gửi yêu cầu huỷ lên hệ thống.
- Hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."
- Trạng thái gia hạn vẫn là "Tự động gia hạn: Bật" — không thay đổi.

---

## TC-25-011: Màn hình lỗi khi không tải được thông tin đăng ký

**AC liên quan:** Mục 5 — Khi dữ liệu không tải được
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Tài khoản đang dùng Premium.
- Môi trường test được thiết lập để máy chủ trả về lỗi khi tải thông tin đăng ký.
- Không có dữ liệu cache từ lần trước (lần đầu mở).

### Act (Thực hiện)
- Người dùng mở màn hình quản lý đăng ký.

### Assert (Kiểm tra)
- Màn hình hiển thị thông báo lỗi thân thiện (không phải thông tin kỹ thuật).
- Có nút "Thử lại" để người dùng tải lại mà không cần thoát màn hình.
- Không có crash hoặc màn hình trắng.

---

## TC-25-012: Trạng thái thanh toán thất bại khi có vấn đề với phương thức thanh toán

**AC liên quan:** Mục 5 — Khi có vấn đề thanh toán
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Tài khoản Premium đang ở trạng thái gia hạn tự động.
- Nền tảng (App Store / Google Play) báo lỗi thanh toán khi gia hạn (thẻ hết hạn hoặc bị từ chối).

### Act (Thực hiện)
- Người dùng mở màn hình quản lý đăng ký sau khi có lỗi thanh toán.

### Assert (Kiểm tra)
- Màn hình hiển thị trạng thái "Thanh toán thất bại" (hoặc tương đương).
- Có gợi ý cập nhật phương thức thanh toán trong cài đặt nền tảng (App Store / Google Play).
- Không hiển thị thông tin kỹ thuật lỗi — chỉ thông báo thân thiện với người dùng.

---

## TC-25-013: Chưa đăng nhập — chuyển hướng về màn hình đăng nhập

**AC liên quan:** Mục 5 — Khi chưa đăng nhập
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng chưa đăng nhập vào ứng dụng.

### Act (Thực hiện)
- Người dùng truy cập màn hình quản lý đăng ký (ví dụ: qua deeplink hoặc menu).

### Assert (Kiểm tra)
- Hệ thống chuyển ngay về màn hình đăng nhập (SM-001).
- Không hiển thị bất kỳ thông tin Premium nào trước khi đăng nhập.

---

## TC-25-014: Lịch sử thanh toán rỗng khi chưa có giao dịch

**AC liên quan:** BR-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Tài khoản mới, chưa có bất kỳ giao dịch Premium nào được ghi nhận trong hệ thống.

### Act (Thực hiện)
- Người dùng mở màn hình quản lý đăng ký và chuyển sang phần lịch sử thanh toán.

### Assert (Kiểm tra)
- Danh sách lịch sử không hiển thị giao dịch nào.
- Có trạng thái rỗng rõ ràng (ví dụ: "Chưa có lịch sử thanh toán").
- Không có lỗi crash hoặc màn hình trắng.

---

## TC-25-015: Huỷ gia hạn rồi mở lại app — trạng thái không bị reset

**AC liên quan:** AC-02, BR-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Tài khoản Premium đã thực hiện huỷ tự động gia hạn thành công (trạng thái "Đã huỷ").

### Act (Thực hiện)
- Người dùng thoát khỏi ứng dụng hoàn toàn (kill app).
- Người dùng mở lại ứng dụng và vào màn hình quản lý đăng ký.

### Assert (Kiểm tra)
- Trạng thái vẫn hiển thị "Tự động gia hạn: Đã huỷ" (không bị reset về "Bật").
- Ngày hết hạn vẫn không thay đổi.

---

## TC-25-016: Thoát app giữa chừng khi đang xem — dữ liệu cache còn khi mở lại

**AC liên quan:** Mục 5 — Khi thoát app giữa chừng
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Tài khoản đang dùng Premium.
- Người dùng đã mở màn hình quản lý đăng ký và dữ liệu đã hiển thị đầy đủ.

### Act (Thực hiện)
- Người dùng thoát ứng dụng (kill app).
- Người dùng mở lại ứng dụng và vào lại màn hình quản lý đăng ký.

### Assert (Kiểm tra)
- Thông tin từ lần trước (gói, ngày hết hạn, trạng thái gia hạn) hiển thị ngay trong khi hệ thống làm mới dữ liệu ở nền.
- Không có trạng thái trắng kéo dài mà không có phản hồi.

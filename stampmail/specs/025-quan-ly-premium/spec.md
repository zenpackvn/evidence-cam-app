# Quản lý đăng ký Premium (SM-029)

**Feature Branch**: `025-quan-ly-premium`
**Ngày tạo**: 2026-06-24
**Trạng thái**: Draft
**Ưu tiên**: P2

> **Tài liệu thuần nghiệp vụ** cho Tester (QA), Business Analyst (BA), Product Owner (PO).
> **KHÔNG chứa chi tiết kỹ thuật**. Phần plan / vẽ giao diện / develop được làm RIÊNG ở bước sau.

---

## 1. Mục đích nghiệp vụ

Cho người dùng Premium minh bạch về trạng thái đăng ký của mình (còn bao lâu, đã trả bao nhiêu) và kiểm soát gia hạn tự động — không bị tính phí bất ngờ. Xử lý trơn tru khi Premium hết hạn.

## 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đang hoặc đã từng là Premium.
- **Khi nào dùng:** Khi muốn kiểm tra trạng thái, xem lịch sử, hoặc huỷ gia hạn.
- **Điều kiện tiên quyết:** Đã đăng nhập (SM-001). Đã nâng cấp Premium ít nhất một lần (SM-028).
- **Phạm vi:** Xem trạng thái gói, ngày hết hạn, lịch sử thanh toán, huỷ gia hạn tự động, và hành vi khi hết hạn. Không bao gồm thanh toán mới (SM-028).

## 3. Quy tắc nghiệp vụ

- **BR-01 — Hiển thị trạng thái gói:** Người dùng thấy: gói đang dùng (tháng/năm), ngày hết hạn, và trạng thái gia hạn (tự động gia hạn / đã huỷ tự động).
- **BR-02 — Lịch sử thanh toán:** Hiển thị danh sách các kỳ đã thanh toán: ngày, số tiền, gói (tháng/năm).
- **BR-03 — Huỷ gia hạn tự động:** Người dùng có thể huỷ tự động gia hạn bất kỳ lúc nào. Sau khi huỷ, Premium vẫn có hiệu lực đến hết kỳ đã trả — không bị cắt ngay lập tức.
- **BR-04 — Tự động về Free khi hết hạn:** Khi hết kỳ Premium (và không gia hạn), tài khoản tự động chuyển về gói Thường (Free). Không cần người dùng làm gì.
- **BR-05 — Giữ nguyên dữ liệu khi về Free:** Khi hết Premium, toàn bộ tem và thư đã tạo/nhận được giữ nguyên trong Album — không bị xoá. Giới hạn Free (SM-030) áp dụng **ngay lập tức** kể từ thời điểm Premium hết hạn — không chờ đến đầu tháng tiếp theo. Số lượng tem/thư đã tạo trong tháng đó được tính vào hạn mức Free còn lại của tháng.
- **BR-06 — Thông báo sắp hết hạn:** Hệ thống gửi thông báo nhắc trước khi Premium hết hạn để người dùng có thể gia hạn hoặc quyết định về Free.

### Trạng thái offline

- **BR-07 — Xem thông tin khi mất mạng:** Khi không có kết nối, màn hình quản lý đăng ký vẫn hiển thị thông tin đã tải lần cuối (gói, ngày hết hạn, trạng thái gia hạn, lịch sử thanh toán) kèm thông báo "Đang xem ngoại tuyến — dữ liệu có thể chưa được cập nhật".
- **BR-08 — Chặn thao tác cần mạng khi offline:** Khi không có kết nối, hành động "Huỷ tự động gia hạn" bị vô hiệu hoá. Người dùng thấy thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." — thao tác không được gửi đi.

## 4. Tiêu chí nghiệm thu

- **AC-01 — Xem ngày hết hạn:**
  - **Giả sử** người dùng đang dùng gói Premium tháng;
  - **Khi** mở màn hình quản lý đăng ký;
  - **Thì** thấy ngày hết hạn cụ thể và trạng thái "Tự động gia hạn: Bật".

- **AC-02 — Huỷ tự động gia hạn và dùng đến hết kỳ:**
  - **Giả sử** người dùng huỷ tự động gia hạn khi còn mười ngày trong kỳ;
  - **Khi** xác nhận huỷ;
  - **Thì** trạng thái đổi thành "Tự động gia hạn: Đã huỷ" nhưng Premium vẫn còn hiệu lực mười ngày còn lại.

- **AC-03 — Tự động về Free sau khi hết kỳ:**
  - **Giả sử** người dùng đã huỷ gia hạn và kỳ Premium đã hết;
  - **Khi** mở app sau ngày hết hạn;
  - **Thì** tài khoản ở trạng thái Free, tính năng Premium bị khoá, nhưng tem/thư cũ vẫn còn nguyên trong Album.

- **AC-04 — Lịch sử thanh toán đầy đủ:**
  - **Giả sử** người dùng đã thanh toán ba kỳ Premium;
  - **Khi** xem lịch sử thanh toán;
  - **Thì** thấy đủ ba kỳ với ngày và số tiền.

- **AC-05 — Dữ liệu giữ nguyên sau khi về Free:**
  - **Giả sử** người dùng vừa hết kỳ Premium và tài khoản đã chuyển về Free;
  - **Khi** mở Album;
  - **Thì** toàn bộ tem và thư đã tạo/nhận trong thời gian Premium vẫn còn nguyên, không bị xoá.

- **AC-06 — Nhận thông báo trước khi Premium hết hạn:**
  - **Giả sử** người dùng đang dùng Premium và sắp đến ngày hết hạn;
  - **Khi** còn một số ngày nhất định trước ngày hết hạn;
  - **Thì** người dùng nhận thông báo push nhắc Premium sắp hết, kèm tùy chọn gia hạn.

- **AC-07 — Giới hạn Free áp dụng ngay khi hết Premium giữa tháng:**
  - **Giả sử** người dùng hết Premium vào ngày 15/6 và trong tháng 6 đã tạo 8 thư khi còn Premium;
  - **Khi** cố tạo thư mới vào ngày 16/6;
  - **Thì** hệ thống tính người dùng đã dùng 8/10 thư tháng này — chỉ còn 2 thư trước khi cạn hạn mức Free.

### Offline

- **AC-08 — Xem thông tin đăng ký khi mất mạng:**
  - **Giả sử** người dùng đã từng mở màn hình quản lý đăng ký khi có mạng và dữ liệu đã được tải;
  - **Khi** mở lại màn hình này trong trạng thái không có kết nối;
  - **Thì** thông tin gói, ngày hết hạn, trạng thái gia hạn và lịch sử thanh toán vẫn hiển thị đầy đủ, kèm thông báo "Đang xem ngoại tuyến".

- **AC-09 — Không thể huỷ gia hạn khi mất mạng:**
  - **Giả sử** người dùng đang trong màn hình quản lý đăng ký và mất kết nối mạng;
  - **Khi** nhấn "Huỷ tự động gia hạn";
  - **Thì** thao tác bị chặn và người dùng thấy thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." — trạng thái gia hạn không thay đổi.

## 5. Trường hợp ngoại lệ & lỗi

### Khi mất kết nối (offline / no network)

- Màn hình quản lý vẫn hiển thị thông tin gói, ngày hết hạn, trạng thái gia hạn và lịch sử thanh toán đã tải lần cuối, kèm thông báo "Đang xem ngoại tuyến — dữ liệu có thể chưa được cập nhật".
- Nút "Huỷ tự động gia hạn" bị vô hiệu hoá; người dùng thấy thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." và thao tác không được gửi đi.

### Khi dữ liệu không tải được (lỗi mạng / lỗi máy chủ)

- Nếu không tải được thông tin đăng ký, màn hình hiển thị thông báo lỗi và nút "Thử lại" để người dùng tải lại mà không cần thoát màn hình.
- Khi có vấn đề thanh toán (thẻ hết hạn, từ chối): nền tảng (App Store/Google Play) xử lý và thông báo; StampMail hiển thị trạng thái "Thanh toán thất bại" và gợi ý cập nhật phương thức trong cài đặt nền tảng.

### Khi chưa đăng nhập / thoát app giữa chừng

- Nếu người dùng chưa đăng nhập và truy cập màn hình quản lý đăng ký, hệ thống chuyển ngay về màn hình đăng nhập (SM-001) — không hiển thị bất kỳ thông tin Premium nào.
- Nếu người dùng thoát app trong lúc đang xem thông tin, dữ liệu đã hiển thị không bị mất; lần sau mở lại màn hình, thông tin từ cache vẫn hiện ra trong khi hệ thống làm mới dữ liệu ở nền.

---

## Liên kết tính năng khác

- SM-028 (Nâng cấp Premium): nơi bắt đầu đăng ký Premium.
- SM-030 (Giới hạn tháng): giới hạn Free áp dụng lại khi hết Premium.
- SM-026 (Thông báo push): thông báo sắp hết hạn Premium.

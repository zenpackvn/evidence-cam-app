# Hộp thư đã gửi & Theo dõi trạng thái (SM-021)

**Feature Branch**: `019-hop-thu-da-gui`
**Ngày tạo**: 2026-06-24
**Trạng thái**: Draft
**Ưu tiên**: P2

> **Tài liệu thuần nghiệp vụ** cho Tester (QA), Business Analyst (BA), Product Owner (PO).
> **KHÔNG chứa chi tiết kỹ thuật**. Phần plan / vẽ giao diện / develop được làm RIÊNG ở bước sau.

---

## 1. Mục đích nghiệp vụ

Cho người gửi theo dõi số phận của từng thư đã gửi — link đang hoạt động, đã được đọc, hay đã hết hạn. Tạo cảm giác "đang chờ thư được mở" và cho phép tạo lại link khi cần.

## 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đã gửi ít nhất một thư.
- **Khi nào dùng:** Khi muốn xem lại danh sách thư đã gửi và trạng thái từng link.
- **Điều kiện tiên quyết:** Đã đăng nhập (SM-001). Đã gửi ít nhất một thư (SM-016).
- **Phạm vi:** Danh sách thư đã gửi, trạng thái link, tạo link mới cho thư hết hạn. Không bao gồm hộp thư đến (SM-018).

## 3. Quy tắc nghiệp vụ

- **BR-01 — Danh sách thư đã gửi:** Hiển thị tất cả thư đã gửi, mới nhất lên trước.
- **BR-02 — Trạng thái link:** Với mỗi thư, hiển thị trạng thái của từng link đã tạo: (1) Đang hoạt động — link còn hiệu lực chưa ai mở, (2) Đã đọc — người nhận đã mở link kèm thời điểm mở, (3) Hết hạn — link quá bảy ngày chưa ai mở.
- **BR-03 — Số người nhận:** Mỗi thư hiển thị tổng số link đã tạo (= số người gửi đến).
- **BR-04 — Tạo link mới cho thư hết hạn:** Với link đã hết hạn, người gửi có thể tạo link mới để gửi lại. Mỗi lần tạo link mới trừ một vào hạn mức tháng (áp dụng cho gói Thường).
- **BR-05 — Không tạo link mới cho thư đã đọc:** Thư mà link đã được mở (đã đọc) không cho tạo link mới — thư đã đến tay người nhận rồi.

### Trạng thái offline

- **BR-06 — Xem danh sách khi mất mạng:** Khi mất kết nối, người dùng vẫn thấy danh sách thư đã gửi và trạng thái link từ lần tải gần nhất; ứng dụng hiển thị thông báo "Đang xem ngoại tuyến — dữ liệu có thể chưa cập nhật".
- **BR-07 — Vô hiệu hóa tạo link mới khi mất mạng:** Khi mất kết nối, nút "Tạo link mới" bị vô hiệu hóa; nếu người dùng cố nhấn, hệ thống thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."
- **BR-08 — Tự động cập nhật khi có mạng trở lại:** Khi kết nối được khôi phục, danh sách và trạng thái link tự động làm mới để phản ánh dữ liệu mới nhất.

## 4. Tiêu chí nghiệm thu

- **AC-01 — Danh sách thư đã gửi đúng thứ tự:**
  - **Giả sử** người dùng đã gửi nhiều thư vào các thời điểm khác nhau;
  - **Khi** mở hộp thư đã gửi;
  - **Thì** thư mới nhất xuất hiện đầu danh sách.

- **AC-02 — Trạng thái từng link hiển thị đúng:**
  - **Giả sử** một thư có ba link: một đã đọc, một đang hoạt động, một hết hạn;
  - **Khi** mở chi tiết thư đó;
  - **Thì** ba link hiển thị ba trạng thái khác nhau: Đã đọc (kèm thời điểm), Đang hoạt động, Hết hạn.

- **AC-03 — Tạo link mới cho link hết hạn:**
  - **Giả sử** người dùng gói Thường có link hết hạn và còn hạn mức thư trong tháng;
  - **Khi** nhấn "Tạo link mới" cho link hết hạn đó;
  - **Thì** link mới được tạo, hạn mức tháng trừ đi một.

- **AC-04 — Không cho tạo link mới cho thư đã đọc:**
  - **Giả sử** link thư đã được người nhận mở;
  - **Khi** người gửi cố tạo link mới cho thư đó;
  - **Thì** hệ thống không cho và thông báo thư đã được nhận.

### Offline

- **AC-05 — Xem danh sách thư khi mất mạng:**
  - **Giả sử** người dùng đã từng tải danh sách thư đã gửi và sau đó mất kết nối mạng;
  - **Khi** mở hộp thư đã gửi trong trạng thái ngoại tuyến;
  - **Thì** danh sách thư và trạng thái link từ lần tải gần nhất vẫn hiển thị, kèm thông báo "Đang xem ngoại tuyến — dữ liệu có thể chưa cập nhật".

- **AC-06 — Không tạo được link mới khi mất mạng:**
  - **Giả sử** người dùng đang xem thư có link hết hạn nhưng thiết bị đang mất kết nối;
  - **Khi** người dùng nhấn "Tạo link mới";
  - **Thì** hành động bị chặn và hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."

## 5. Trường hợp ngoại lệ & lỗi

- Khi không có thư đã gửi: hiển thị trạng thái rỗng với gợi ý tạo thư đầu tiên.
- Khi hết hạn mức tháng và cố tạo link mới: hệ thống thông báo hết hạn mức, gợi ý nâng cấp Premium.
- Khi mất kết nối: danh sách thư và trạng thái link từ lần tải gần nhất vẫn hiển thị kèm thông báo "Đang xem ngoại tuyến — dữ liệu có thể chưa cập nhật"; nút "Tạo link mới" bị vô hiệu hoá cho đến khi có mạng trở lại.
- Khi dữ liệu không tải được (lỗi mạng hoặc máy chủ): màn hình hiển thị thông báo lỗi kèm nút "Thử lại" để người dùng tải lại danh sách.
- Khi chưa đăng nhập: hệ thống tự động chuyển về màn hình đăng nhập, không cho phép xem hộp thư đã gửi dưới bất kỳ hình thức nào.
- Khi thoát app giữa chừng: dữ liệu danh sách đã tải được giữ trong bộ nhớ đệm; lần sau mở lại, người dùng thấy ngay danh sách từ cache mà không cần chờ tải lại từ đầu.

---

## Liên kết tính năng khác

- SM-016 (Gửi thư qua MXH): nơi tạo link thư và gửi.
- SM-030 (Giới hạn tháng): áp dụng khi tạo link mới trừ vào hạn mức.
- SM-026 (Thông báo push): thông báo khi link được mở dẫn đến cập nhật trạng thái trong danh sách này.

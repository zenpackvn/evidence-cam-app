# Hộp thư đến (Inbox) — SM-018

**Feature Branch**: `016-hop-thu-den`
**Ngày tạo**: 2026-06-24
**Trạng thái**: Draft
**Ưu tiên**: P2

> **Tài liệu thuần nghiệp vụ** cho Tester (QA), Business Analyst (BA), Product Owner (PO).
> **KHÔNG chứa chi tiết kỹ thuật**. Phần plan / vẽ giao diện / develop được làm RIÊNG ở bước sau.

---

## 1. Mục đích nghiệp vụ

Là nơi người dùng xem lại toàn bộ thư đã nhận — không bỏ sót thư nào. Cung cấp bộ lọc đơn giản để tìm thư chưa đọc hoặc đã đọc.

## 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đã đăng nhập.
- **Khi nào dùng:** Khi muốn xem lại các thư đã nhận, phân biệt thư chưa đọc và đã đọc.
- **Điều kiện tiên quyết:** Đã đăng nhập (SM-001).
- **Phạm vi:** Danh sách thư nhận, bộ lọc trạng thái, mở từng thư. Không bao gồm trả lời thư (SM-020).

## 3. Quy tắc nghiệp vụ

- **BR-01 — Sắp xếp theo thời gian:** Thư mới nhất hiển thị đầu danh sách.
- **BR-02 — Thông tin hiển thị trong danh sách:** Mỗi thư trong danh sách hiển thị: ảnh nhỏ của tem, tên người gửi, thời gian nhận, và trạng thái (đọc/chưa đọc).
- **BR-03 — Bộ lọc ba trạng thái:** Người dùng lọc danh sách theo: tất cả / chưa đọc / đã đọc.
- **BR-04 — Thư lưu vĩnh viễn:** Thư đã nhận không bị tự động xoá sau bất kỳ thời gian nào — người dùng có thể xem lại bất kỳ lúc nào.

### Trạng thái offline

- **BR-05 — Hiển thị danh sách khi mất mạng:** Khi người dùng mất kết nối, hộp thư đến vẫn hiển thị danh sách thư đã tải từ lần truy cập trước — người dùng không thấy màn hình trắng hay lỗi ngay lập tức.
- **BR-06 — Thông báo ngoại tuyến:** Khi đang xem hộp thư mà không có kết nối, hệ thống hiển thị thông báo rõ ràng "Đang xem ngoại tuyến — danh sách có thể chưa cập nhật mới nhất".
- **BR-07 — Vô hiệu hoá tải thêm khi offline:** Khi không có kết nối, người dùng không thể tải thêm thư mới; hành động kéo làm mới danh sách bị vô hiệu hoá và hiển thị thông báo cần có mạng để cập nhật.

## 4. Tiêu chí nghiệm thu

- **AC-01 — Hiển thị danh sách thư đúng thứ tự:**
  - **Giả sử** người dùng đã nhận nhiều thư vào các thời điểm khác nhau;
  - **Khi** mở hộp thư đến;
  - **Thì** thư mới nhất xuất hiện đầu danh sách.

- **AC-02 — Lọc thư chưa đọc:**
  - **Giả sử** có cả thư đã đọc lẫn chưa đọc trong hộp thư;
  - **Khi** chọn bộ lọc "Chưa đọc";
  - **Thì** chỉ hiển thị các thư chưa đọc.

- **AC-03 — Mở thư từ danh sách:**
  - **Giả sử** người dùng thấy một thư trong danh sách;
  - **Khi** nhấn vào thư đó;
  - **Thì** mở màn hình mở thư với animation (SM-019).

- **AC-04 — Thư đã đọc vẫn còn trong danh sách:**
  - **Giả sử** người dùng đã đọc một thư trước đó;
  - **Khi** mở lại hộp thư sau nhiều ngày;
  - **Thì** thư đó vẫn còn trong danh sách với trạng thái "Đã đọc".

### Offline

- **AC-05 — Xem danh sách thư khi mất mạng:**
  - **Giả sử** người dùng đã mở hộp thư khi có mạng và danh sách đã tải thành công; sau đó mất kết nối;
  - **Khi** quay lại hộp thư đến trong lúc không có mạng;
  - **Thì** danh sách thư đã tải trước đó vẫn hiển thị đầy đủ kèm thông báo "Đang xem ngoại tuyến — danh sách có thể chưa cập nhật mới nhất".

- **AC-06 — Vô hiệu hoá làm mới danh sách khi offline:**
  - **Giả sử** người dùng đang xem hộp thư đến và không có kết nối mạng;
  - **Khi** người dùng thực hiện thao tác kéo để làm mới danh sách;
  - **Thì** danh sách không tải thêm thư mới và hệ thống hiển thị thông báo cần có kết nối mạng để cập nhật.

## 5. Trường hợp ngoại lệ & lỗi

- Khi chưa có thư nào: hiển thị trạng thái rỗng với lời nhắn thân thiện (ví dụ: "Hộp thư trống — chia sẻ StampMail để nhận thư đầu tiên").
- Khi mất kết nối (offline): danh sách thư đã tải từ lần truy cập trước vẫn hiển thị đầy đủ; thao tác kéo làm mới bị vô hiệu hoá và hệ thống hiển thị thông báo "Đang xem ngoại tuyến — không thể tải thư mới".
- Khi lỗi mạng hoặc máy chủ không phản hồi: màn hình hiển thị danh sách cache (nếu có) kèm thông báo lỗi và nút "Thử lại" để người dùng tải lại; nếu chưa có cache, hiển thị màn hình lỗi với nút "Thử lại".
- Khi chưa đăng nhập: hệ thống lập tức chuyển người dùng về màn hình đăng nhập và không hiển thị nội dung hộp thư đến.
- Khi thoát app giữa chừng: danh sách thư trong cache được giữ nguyên; lần sau mở lại app, hộp thư đến tiếp tục hiển thị danh sách đã cache và tự động tải cập nhật mới khi có mạng.

---

## Liên kết tính năng khác

- SM-017 (Nhận thư qua Link): cách thư vào hộp thư đến.
- SM-019 (Mở thư & Animation): mở khi nhấn vào thư trong danh sách.
- SM-026 (Thông báo push): thông báo khi có thư mới đến.

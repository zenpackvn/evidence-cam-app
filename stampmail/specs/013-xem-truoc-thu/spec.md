# Xem trước thư trước khi gửi (SM-015)

**Feature Branch**: `013-xem-truoc-thu`
**Ngày tạo**: 2026-06-24
**Trạng thái**: Draft
**Ưu tiên**: P2

> **Tài liệu thuần nghiệp vụ** cho Tester (QA), Business Analyst (BA), Product Owner (PO).
> **KHÔNG chứa chi tiết kỹ thuật**. Phần plan / vẽ giao diện / develop được làm RIÊNG ở bước sau.

---

## 1. Mục đích nghiệp vụ

Cho người dùng nhìn thấy thư đúng như người nhận sẽ thấy trước khi gửi — lần kiểm tra cuối cùng để tránh gửi nhầm hay gửi khi chưa hoàn chỉnh. Từ đây người dùng có thể quay lại chỉnh hoặc xác nhận gửi.

## 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng vừa hoàn tất đính tem và muốn kiểm tra trước khi gửi.
- **Khi nào dùng:** Bước 4 trong luồng soạn thư, sau SM-014.
- **Điều kiện tiên quyết:** Đã có nội dung thư (SM-013), tem đã đính (SM-014).
- **Phạm vi:** Xem trước đầy đủ thư, quay lại chỉnh sửa, và chuyển sang gửi thư. Không bao gồm bước tạo link và gửi (SM-016).

## 3. Quy tắc nghiệp vụ

- **BR-01 — Hiển thị đúng như người nhận thấy:** Xem trước phải hiển thị thư y hệt như người nhận sẽ thấy khi mở link: template nền, nội dung đã soạn, font chữ đã chọn, tem đã đính và vị trí của chúng.
- **BR-02 — Nút Chỉnh sửa lại:** Từ màn hình xem trước, người dùng quay lại bất kỳ bước nào trước đó (soạn nội dung, đính tem, chọn template) để chỉnh sửa.
- **BR-03 — Nút Gửi thư:** Xác nhận lần cuối và chuyển sang bước tạo link gửi (SM-016).

### Trạng thái offline

- **BR-04 — Xem trước vẫn hoạt động khi mất mạng:** Màn hình xem trước hiển thị bình thường vì toàn bộ nội dung (template, văn bản, tem, vị trí) đã có sẵn trên thiết bị; không cần kết nối mạng để xem.
- **BR-05 — Nút Gửi thư bị vô hiệu hóa khi mất mạng:** Khi thiết bị không có kết nối, nút Gửi thư bị vô hiệu hóa và hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." Nút Chỉnh sửa lại vẫn hoạt động bình thường.
- **BR-06 — Tự động cho phép gửi khi có mạng trở lại:** Khi kết nối được khôi phục, nút Gửi thư tự động được kích hoạt lại mà không cần người dùng thoát và vào lại màn hình.

## 4. Tiêu chí nghiệm thu

- **AC-01 — Xem trước hiển thị đầy đủ thư:**
  - **Giả sử** người dùng đã soạn xong thư và đính tem;
  - **Khi** chuyển sang màn hình xem trước;
  - **Thì** thấy thư hoàn chỉnh: nền template, nội dung, font, và tem ở đúng vị trí đã đính.

- **AC-02 — Quay lại chỉnh nội dung:**
  - **Giả sử** người dùng thấy lỗi chính tả trong thư;
  - **Khi** nhấn Chỉnh sửa lại;
  - **Thì** quay về màn hình soạn nội dung với nội dung đang có, không mất dữ liệu.

- **AC-03 — Chuyển sang gửi:**
  - **Giả sử** người dùng hài lòng với thư;
  - **Khi** nhấn Gửi thư;
  - **Thì** chuyển sang màn hình gửi thư qua MXH (SM-016).

### Offline

- **AC-04 — Xem trước vẫn hiển thị khi mất mạng:**
  - **Giả sử** người dùng đang ở màn hình xem trước và thiết bị mất kết nối mạng;
  - **Khi** quan sát màn hình xem trước;
  - **Thì** nội dung thư (template, văn bản, tem) vẫn hiển thị đầy đủ; nút Chỉnh sửa lại vẫn hoạt động; nút Gửi thư bị vô hiệu hóa và có thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."

- **AC-05 — Nút Gửi thư được kích hoạt lại khi có mạng trở lại:**
  - **Giả sử** người dùng đang ở màn hình xem trước trong trạng thái mất mạng (nút Gửi thư bị vô hiệu hóa);
  - **Khi** kết nối mạng được khôi phục;
  - **Thì** nút Gửi thư tự động được kích hoạt lại và thông báo mất mạng biến mất, không cần thoát màn hình.

## 5. Trường hợp ngoại lệ & lỗi

- Khi thư không có nội dung (người dùng bỏ trống): hệ thống cảnh báo thư chưa có nội dung và hỏi có chắc muốn gửi thư trống không.
- Khi thoát app từ màn hình này mà chưa gửi: nội dung thư bị mất và người dùng phải soạn lại từ đầu.

### Khi mất kết nối

- Màn hình xem trước vẫn hiển thị đầy đủ (template, nội dung, tem) vì toàn bộ dữ liệu đã có sẵn trên thiết bị, không cần mạng để xem.
- Nút Gửi thư bị vô hiệu hóa kèm thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."; nút Chỉnh sửa lại vẫn hoạt động bình thường.
- Khi kết nối được khôi phục, nút Gửi thư tự động kích hoạt lại mà không cần người dùng thoát màn hình.

### Khi dữ liệu không tải được

- Nếu template hoặc hình ảnh tem không hiển thị được (lỗi máy chủ), màn hình xem trước hiển thị biểu tượng lỗi tại vùng bị ảnh hưởng kèm nút "Thử lại" để tải lại nội dung đó.

### Khi chưa đăng nhập hoặc thoát app giữa chừng

- Người dùng chưa đăng nhập không thể truy cập tính năng xem trước; hệ thống chuyển về màn hình đăng nhập.
- Khi người dùng thoát app hoặc bị ngắt giữa chừng tại màn hình xem trước, toàn bộ nội dung thư đang soạn bị mất; lần mở lại app, người dùng phải bắt đầu soạn thư từ đầu.

## Liên kết tính năng khác

- SM-014 (Đính tem): bước trước.
- SM-016 (Gửi thư qua MXH): bước tiếp theo — tạo link và gửi.

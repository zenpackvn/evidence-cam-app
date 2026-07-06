# Trả lời thư (SM-020)

**Feature Branch**: `018-tra-loi-thu`
**Ngày tạo**: 2026-06-24
**Trạng thái**: Draft
**Ưu tiên**: 🟡 P1

> **Tài liệu thuần nghiệp vụ** cho Tester (QA), Business Analyst (BA), Product Owner (PO).
> **KHÔNG chứa chi tiết kỹ thuật**. Phần plan / vẽ giao diện / develop được làm RIÊNG ở bước sau.

---

## 1. Mục đích nghiệp vụ

Đóng vòng lặp hai chiều — người nhận trả lời lại người gửi tạo ra chuỗi trao đổi thư qua lại, tăng gắn kết giữa hai người và tần suất sử dụng app. Đồng thời, yêu cầu tải app để trả lời tạo ra một kênh acquisition tự nhiên: người nhận muốn trả lời phải cài StampMail, trở thành người dùng mới.

## 2. Đối tượng & phạm vi

- **Người dùng:** Người đã đọc thư (có hoặc chưa có tài khoản) — nhưng chỉ người đã cài app và đăng nhập mới thực sự trả lời được.
- **Khi nào dùng:** Sau khi đọc thư, nhấn nút Trả lời.
- **Điều kiện tiên quyết:** Đã đăng nhập (SM-001). Đã mở và đọc ít nhất một thư (SM-019).
- **Phạm vi:** Soạn thư trả lời với người gửi gốc đã điền sẵn, gửi qua cơ chế link MXH như bình thường. Không bao gồm thread/chuỗi thư có thể xem lịch sử (thư trả lời là thư độc lập).

## 3. Quy tắc nghiệp vụ

- **BR-01 — Người nhận tự động điền sẵn:** Khi nhấn Trả lời, luồng soạn thư mở ra với người nhận đã được điền sẵn là người gửi thư gốc. Người dùng không phải nhập lại.
- **BR-02 — Template reply:** Hệ thống gợi ý template có phong cách phù hợp với trả lời (ví dụ: template đơn giản hơn so với thư mới). Người dùng vẫn có thể chọn template khác.
- **BR-03 — Luồng gửi như thường:** Sau khi soạn xong, thư trả lời được gửi qua cùng cơ chế link MXH (SM-016) — không có luồng gửi riêng cho trả lời.
- **BR-04 — Thư trả lời là thư độc lập:** Thư trả lời không hiển thị nội dung thư gốc; không có threading/chuỗi thư. Mỗi thư là một phong bì riêng.
- **BR-05 — Bắt buộc cài app và đăng nhập để trả lời:** Chức năng trả lời chỉ khả dụng trong app StampMail. Người đọc thư trên trình duyệt web (chưa cài app) nhấn Trả lời sẽ thấy màn hình mời tải app với thông điệp rõ ràng — không thể trả lời thư trực tiếp từ web.

### Trạng thái offline

- **BR-06 — Chặn gửi thư khi mất mạng:** Khi người dùng đang soạn thư trả lời và mất kết nối mạng, nút Gửi bị vô hiệu hóa. Hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." Nội dung thư đã soạn được giữ nguyên để người dùng không phải nhập lại khi có mạng trở lại.
- **BR-07 — Vẫn cho phép soạn thư khi mất mạng:** Người dùng vẫn có thể mở màn hình trả lời, soạn nội dung thư và chọn template khi không có kết nối, vì các bước này không cần mạng. Chỉ thao tác gửi (tạo link và chia sẻ qua MXH) mới bị chặn cho đến khi có mạng.

## 4. Tiêu chí nghiệm thu

- **AC-01 — Nút Trả lời mở soạn thư với người nhận sẵn:**
  - **Giả sử** người dùng vừa đọc xong thư từ "An";
  - **Khi** nhấn Trả lời;
  - **Thì** màn hình soạn thư mở ra với "An" đã điền vào ô người nhận (không cần nhập thêm).

- **AC-02 — Hoàn tất trả lời gửi qua MXH:**
  - **Giả sử** người dùng đã soạn xong thư trả lời;
  - **Khi** xác nhận gửi;
  - **Thì** được chuyển đến màn hình chọn nền tảng MXH để chia sẻ link (SM-016) như một thư bình thường.

- **AC-03 — Người đọc thư trên web được mời tải app để trả lời:**
  - **Giả sử** người nhận đang xem thư trên trình duyệt web (chưa cài StampMail);
  - **Khi** nhấn nút Trả lời;
  - **Thì** hiển thị màn hình "Tải StampMail để trả lời thư này" với nút dẫn đến App Store/Google Play; không có cách trả lời từ web.

- **AC-04 — Người đã cài app nhưng chưa đăng nhập:**
  - **Giả sử** người nhận đã cài StampMail nhưng chưa đăng nhập;
  - **Khi** nhấn Trả lời từ trong app;
  - **Thì** được chuyển sang màn hình đăng nhập/đăng ký trước khi vào soạn thư trả lời.

### Offline

- **AC-05 — Soạn thư vẫn hoạt động khi mất mạng nhưng không thể gửi:**
  - **Giả sử** người dùng đang soạn thư trả lời và thiết bị không có kết nối mạng;
  - **Khi** hoàn tất nội dung và nhấn Gửi;
  - **Thì** nút Gửi bị vô hiệu hóa, hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng.", và toàn bộ nội dung thư đã soạn vẫn còn nguyên trên màn hình.

- **AC-06 — Soạn thư trả lời vẫn thực hiện được khi mất mạng:**
  - **Giả sử** người dùng mất kết nối mạng trước khi bắt đầu soạn thư trả lời;
  - **Khi** nhấn Trả lời và soạn nội dung thư;
  - **Thì** màn hình soạn thư mở ra bình thường, người nhận được điền sẵn, người dùng có thể nhập nội dung và chọn template mà không gặp lỗi; chỉ bước Gửi mới bị chặn.

## 5. Trường hợp ngoại lệ & lỗi

- Khi người gửi gốc đã xoá tài khoản: hệ thống vẫn cho soạn thư trả lời nhưng thông báo người nhận có thể không còn hoạt động.
- Khi người dùng thoát giữa chừng soạn thư trả lời: hỏi xác nhận "Bỏ thư này?" tương tự soạn thư mới.

**Nhóm 1 — Khi mất kết nối:**

- Người dùng vẫn mở được màn hình soạn thư trả lời và nhập nội dung bình thường khi mất mạng, vì bước soạn thư là cục bộ.
- Khi mất mạng, nút Gửi bị vô hiệu hoá và hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." — nội dung đã soạn không bị mất.
- Khi mạng trở lại, nút Gửi được kích hoạt lại và người dùng có thể gửi thư mà không cần nhập lại nội dung.

**Nhóm 2 — Khi dữ liệu không tải được:**

- Nếu thông tin người gửi gốc không tải được (lỗi mạng hoặc máy chủ), màn hình soạn thư hiển thị trạng thái lỗi với nút "Thử lại" thay vì điền sẵn tên người nhận.
- Người dùng nhấn "Thử lại" để hệ thống tải lại thông tin người gửi gốc và tiếp tục soạn thư.

**Nhóm 3 — Khi chưa đăng nhập / thoát app giữa chừng:**

- Người dùng chưa đăng nhập nhấn Trả lời trong app sẽ được chuyển sang màn hình đăng nhập/đăng ký trước; sau khi đăng nhập thành công, hệ thống quay lại màn hình soạn thư trả lời.
- Khi người dùng thoát app giữa chừng đang soạn thư trả lời, nội dung đã soạn được lưu nháp cục bộ; lần sau mở lại app hệ thống hỏi có muốn tiếp tục thư đang soạn dở không.

---

## Liên kết tính năng khác

- SM-019 (Mở thư & Animation): nút Trả lời xuất hiện sau animation.
- SM-016 (Gửi thư qua MXH): luồng gửi dùng chung cho thư trả lời.
- SM-012 (Chọn template thư): template reply được gợi ý sẵn nhưng người dùng có thể đổi.

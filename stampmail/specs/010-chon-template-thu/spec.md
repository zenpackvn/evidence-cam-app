# Chọn template thư (SM-012)

**Feature Branch**: `010-chon-template-thu`
**Ngày tạo**: 2026-06-24
**Trạng thái**: Draft
**Ưu tiên**: P2

> **Tài liệu thuần nghiệp vụ** cho Tester (QA), Business Analyst (BA), Product Owner (PO).
> **KHÔNG chứa chi tiết kỹ thuật**. Phần plan / vẽ giao diện / develop được làm RIÊNG ở bước sau.

---

## 1. Mục đích nghiệp vụ

Cung cấp cho người dùng các mẫu thư phù hợp theo dịp và tâm trạng — giúp người dùng bắt đầu soạn thư nhanh hơn mà không phải bắt đầu từ trang trắng. Mỗi template mang phong cách nền giấy và bố cục riêng phù hợp với chủ đề.

## 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đã đăng nhập muốn soạn thư mới.
- **Khi nào dùng:** Bước đầu tiên khi bắt đầu soạn thư mới.
- **Điều kiện tiên quyết:** Đã đăng nhập (SM-001).
- **Phạm vi:** Xem danh sách template, xem trước, chọn một template. Không bao gồm soạn nội dung (SM-013) hay đính tem (SM-014).

## 3. Quy tắc nghiệp vụ

- **BR-01 — Danh sách template theo chủ đề:** Template được nhóm theo các chủ đề dịp: sinh nhật, tình yêu, cảm ơn, chúc mừng, nhớ nhung, lễ hội, và các chủ đề khác.
- **BR-02 — Template Free:** Người dùng gói Thường có ba template cơ bản.
- **BR-03 — Template Premium:** Người dùng gói Premium có thêm hơn hai mươi template theo nhiều chủ đề đặc biệt. Với người dùng gói Thường:
  - Template Premium hiển thị trong danh sách với dấu khoá.
  - Nhấn vào template Premium → mở màn hình xem trước đầy đủ (nền giấy, bố cục, họa tiết) giống hệt người dùng Premium thấy.
  - Trong màn hình xem trước: nút "Chọn template này" không xuất hiện; thay vào đó hiển thị gợi ý nâng cấp "Nâng cấp Premium để dùng template này".
  - Nhấn vào gợi ý nâng cấp → chuyển đến màn hình nâng cấp Premium (SM-028).
- **BR-04 — Xem trước trước khi chọn:** Người dùng có thể xem trước từng template (nền giấy, bố cục, họa tiết) trước khi xác nhận chọn.
- **BR-05 — Mỗi thư dùng một template:** Người dùng chọn một template cho mỗi thư. Đã chọn rồi có thể đổi sang template khác bất kỳ lúc nào trong quá trình soạn — nội dung đang soạn (chữ, font, sticker) được giữ lại; chỉ nền và bố cục giấy thư thay đổi.

### Trạng thái offline

- **BR-06 — Xem template đã tải khi mất mạng:** Khi mất kết nối mạng, những template đã được tải trước đó vẫn hiển thị và xem trước được bình thường. Hệ thống hiển thị thông báo "Đang xem ngoại tuyến" ở đầu màn hình. Template chưa được tải xuất hiện ở trạng thái không khả dụng tại ô đó.
- **BR-07 — Chặn chọn template khi mất mạng:** Khi mất kết nối mạng, người dùng không thể xác nhận chọn template (nhấn "Chọn template này") vì bước tiếp theo cần kết nối để tiếp tục soạn và lưu thư. Hệ thống thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."

## 4. Tiêu chí nghiệm thu

- **AC-01 — Xem danh sách template:**
  - **Giả sử** người dùng bắt đầu luồng soạn thư;
  - **Khi** màn hình chọn template mở ra;
  - **Thì** thấy các template được nhóm theo chủ đề, template Free hiển thị bình thường, template Premium có dấu khoá.

- **AC-02 — Xem trước template trước khi chọn:**
  - **Giả sử** người dùng đang xem danh sách template;
  - **Khi** nhấn vào một template Free;
  - **Thì** màn hình xem trước hiển thị đầy đủ nền giấy, bố cục và họa tiết của template đó.

- **AC-03 — Người dùng Free xem trước được template Premium:**
  - **Giả sử** người dùng gói Thường đang xem danh sách template;
  - **Khi** nhấn vào một template Premium (có dấu khoá);
  - **Thì** màn hình xem trước mở ra và hiển thị đầy đủ nền giấy, bố cục, họa tiết — giống hệt khi xem template Free.

- **AC-07 — Nút chọn ẩn, gợi ý nâng cấp xuất hiện trên xem trước Premium:**
  - **Giả sử** người dùng gói Thường đang ở màn hình xem trước của một template Premium;
  - **Khi** xem màn hình đó;
  - **Thì** nút "Chọn template này" không xuất hiện; thay vào đó có nút "Nâng cấp Premium để dùng template này"; nhấn nút đó dẫn đến màn hình nâng cấp Premium.

- **AC-04 — Chọn template và soạn thư:**
  - **Giả sử** người dùng đã xem trước một template Free;
  - **Khi** nhấn Chọn template này;
  - **Thì** chuyển sang màn hình soạn nội dung (SM-013) với template đã chọn làm nền.

### Offline

- **AC-05 — Xem template đã tải khi mất mạng:**
  - **Giả sử** người dùng đang xem danh sách template và thiết bị mất kết nối mạng;
  - **Khi** màn hình chọn template hiển thị;
  - **Thì** các template đã tải trước đó vẫn hiện ra bình thường kèm thông báo "Đang xem ngoại tuyến"; template chưa tải hiển thị ở trạng thái không khả dụng.

- **AC-06 — Không thể xác nhận chọn template khi mất mạng:**
  - **Giả sử** người dùng đang xem trước một template Free và thiết bị mất kết nối mạng;
  - **Khi** nhấn "Chọn template này";
  - **Thì** hệ thống không chuyển sang bước soạn thư và hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."

## 5. Trường hợp ngoại lệ & lỗi

- Khi mất kết nối: template đã tải trước đó vẫn hiển thị và xem trước bình thường; template chưa tải hiển thị trạng thái không khả dụng tại ô đó; người dùng không thể xác nhận chọn template — hệ thống thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."
- Khi dữ liệu không tải được (lỗi mạng hoặc lỗi server): màn hình hiển thị trạng thái lỗi kèm nút "Thử lại" để người dùng tải lại danh sách template mà không cần thoát màn hình.
- Khi chưa đăng nhập: hệ thống không cho vào màn hình chọn template mà chuyển ngay về màn hình đăng nhập.
- Khi thoát app giữa chừng (chưa xác nhận chọn template): lần sau mở lại app, người dùng quay về màn hình chọn template từ đầu — không có dữ liệu bị mất vì chưa có nội dung soạn.
- Khi người dùng đổi template sau khi đã bắt đầu soạn: nội dung không bị mất — hệ thống áp template mới ngay mà không cần xác nhận. Nếu bố cục mới không hỗ trợ một số trang trí cũ (ví dụ sticker nằm ngoài vùng in): sticker tự dịch về trong vùng hiển thị.

---

## Liên kết tính năng khác

- SM-013 (Soạn nội dung thư): bước tiếp theo sau khi chọn template.
- SM-028 (Nâng cấp Premium): điểm đến khi nhấn gợi ý từ template Premium.

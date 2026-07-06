# Soạn nội dung thư (SM-013)

**Feature Branch**: `011-soan-noi-dung-thu`
**Ngày tạo**: 2026-06-24
**Trạng thái**: Draft
**Ưu tiên**: P2

> **Tài liệu thuần nghiệp vụ** cho Tester (QA), Business Analyst (BA), Product Owner (PO).
> **KHÔNG chứa chi tiết kỹ thuật**. Phần plan / vẽ giao diện / develop được làm RIÊNG ở bước sau.

---

## 1. Mục đích nghiệp vụ

Cho phép người dùng viết nội dung thư trong một ô soạn thảo bo góc tròn trên nền giấy thư — cảm giác như đang viết thư tay thật sự. Người dùng cá nhân hóa tờ thư bằng cách chọn màu nền giấy, phông chữ, kiểu kẻ dòng và thêm sticker trang trí.

## 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đang soạn thư mới, sau bước chọn template.
- **Khi nào dùng:** Bước 2 trong luồng soạn thư, sau SM-012.
- **Điều kiện tiên quyết:** Đã chọn template (SM-012).
- **Phạm vi:** Nhập và định dạng nội dung thư, chọn font, thêm sticker trang trí. Không bao gồm đính tem (SM-014) hay xem trước toàn bộ thư (SM-015).

## 3. Quy tắc nghiệp vụ

- **BR-01 — Viết trực tiếp trên template:** Người dùng nhập nội dung trực tiếp lên vùng giấy của template đã chọn — không phải soạn ở nơi khác rồi dán vào.
- **BR-02 — Định dạng cơ bản:** Hỗ trợ in đậm, in nghiêng, và căn lề (trái / giữa / phải).
- **BR-03 — Chọn phông chữ:** Người dùng chọn một trong ít nhất bốn phông chữ:
  - **Tay viết nhẹ** — nét uốn lượn tự nhiên, gần chữ viết tay thông thường.
  - **Tay viết đứng** — nét thẳng đứng, trang trọng hơn nhưng vẫn có cảm giác thủ công.
  - **In ấn hiện đại** — nét rõ, không chân, dễ đọc trên màn hình.
  - **In ấn cổ điển** — nét có chân, gợi cảm giác thư viết máy đánh chữ.
  Người dùng đổi phông bất kỳ lúc nào; toàn bộ nội dung đang soạn đổi phông ngay.
- **BR-04 — Giới hạn ký tự:** Mỗi thư có giới hạn khoảng năm trăm ký tự (có thể thay đổi tuỳ template). Hệ thống hiển thị số ký tự còn lại khi người dùng đang gần đến giới hạn.
- **BR-05 — Sticker trang trí:** Người dùng có thể thêm sticker trang trí xung quanh nội dung thư (không đè lên chữ). Sticker Free và Premium áp dụng tương tự như trong SM-008.
- **BR-06 — Màu nền giấy thư:** Người dùng chọn màu nền cho tờ giấy thư từ một bộ màu có sẵn (ít nhất năm màu: trắng, kem, hồng nhạt, xanh nhạt, vàng nhạt). Màu nền hiển thị đúng như vậy khi người nhận xem thư.
- **BR-07 — Ô soạn thảo bo góc:** Vùng nhập nội dung thư được hiển thị dưới dạng một ô riêng biệt có góc bo tròn, nổi lên trên nền giấy thư — gợi cảm giác tờ giấy viết đặt trên phong bì.
- **BR-08 — Kẻ dòng tùy chọn:** Bên trong ô soạn thảo, người dùng chọn một trong hai kiểu: có kẻ dòng ngang (như giấy học sinh) hoặc không kẻ dòng (giấy trắng). Kẻ dòng chỉ là trang trí nền — không cản trở nhập liệu và vẫn hiển thị khi người nhận xem thư.
- **BR-09 — Màu chữ theo từng đoạn:** Người dùng chọn màu chữ riêng cho từng đoạn văn bản — không bắt buộc toàn bộ thư phải cùng một màu. Để đổi màu, người dùng chọn (bôi đen) đoạn muốn đổi rồi chọn màu từ bảng màu có sẵn. Đoạn chưa chọn màu giữ màu mặc định.

### Trạng thái offline

- **BR-10 — Soạn thảo không cần mạng:** Khi thiết bị mất kết nối mạng, người dùng vẫn tiếp tục soạn nội dung thư bình thường — nhập chữ, chọn phông, chọn màu nền, chọn màu chữ, bật/tắt kẻ dòng, và sử dụng sticker đã tải về trước đó. Các thao tác này không phụ thuộc vào kết nối mạng.
- **BR-11 — Tải sticker cần mạng:** Khi người dùng đang offline và cố tải một sticker chưa có sẵn trên thiết bị (bao gồm sticker Premium chưa tải), hệ thống thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." và không tải sticker đó. Sticker đã tải từ trước vẫn dùng được bình thường.

## 4. Tiêu chí nghiệm thu

- **AC-01 — Nhập nội dung trên template:**
  - **Giả sử** người dùng đã chọn template và đang ở màn hình soạn thư;
  - **Khi** nhấn vào vùng giấy và gõ chữ;
  - **Thì** chữ xuất hiện trực tiếp trên nền template.

- **AC-02 — Áp định dạng in đậm:**
  - **Giả sử** người dùng đã chọn một đoạn chữ;
  - **Khi** nhấn nút in đậm;
  - **Thì** đoạn chữ đó hiển thị đậm hơn trên template.

- **AC-03 — Cảnh báo gần đến giới hạn ký tự:**
  - **Giả sử** giới hạn ký tự là năm trăm;
  - **Khi** người dùng đã nhập được bốn trăm năm mươi ký tự;
  - **Thì** hệ thống hiển thị số ký tự còn lại và/hoặc cảnh báo trực quan.

- **AC-04 — Không thể nhập quá giới hạn:**
  - **Giả sử** người dùng đã nhập đến giới hạn ký tự;
  - **Khi** cố gõ thêm ký tự;
  - **Thì** bàn phím không cho nhập thêm; số đếm ký tự hiển thị đã đạt giới hạn.

- **AC-05 — Chọn phông chữ:**
  - **Giả sử** người dùng đang soạn thư;
  - **Khi** chọn một phông chữ bất kỳ trong bốn lựa chọn;
  - **Thì** toàn bộ nội dung thư đổi sang phông đó ngay lập tức.

- **AC-06 — Chọn màu nền giấy thư:**
  - **Giả sử** người dùng đang soạn thư;
  - **Khi** chọn một màu nền từ bộ màu có sẵn;
  - **Thì** nền giấy thư đổi sang màu đó ngay; ô soạn thảo và nội dung không thay đổi.

- **AC-07 — Bật kẻ dòng:**
  - **Giả sử** người dùng đang ở chế độ không kẻ dòng (mặc định);
  - **Khi** chọn "Kẻ dòng";
  - **Thì** các dòng kẻ ngang xuất hiện trong ô soạn thảo ngay lập tức; nội dung đã nhập vẫn giữ nguyên.

- **AC-08 — Tắt kẻ dòng:**
  - **Giả sử** người dùng đang ở chế độ có kẻ dòng;
  - **Khi** chọn "Không kẻ dòng";
  - **Thì** dòng kẻ biến mất; nội dung đã nhập vẫn giữ nguyên.

- **AC-09 — Đổi màu chữ cho một đoạn:**
  - **Giả sử** người dùng đã nhập ít nhất hai đoạn chữ trong ô soạn thảo;
  - **Khi** bôi đen một đoạn và chọn màu khác từ bảng màu;
  - **Thì** chỉ đoạn được bôi đen đổi sang màu mới; các đoạn còn lại giữ nguyên màu của chúng.

- **AC-10 — Thêm sticker trang trí vào thư:**
  - **Giả sử** người dùng đang soạn nội dung thư;
  - **Khi** mở bộ sticker, chọn một sticker miễn phí và đặt lên thư;
  - **Thì** sticker xuất hiện ở vị trí được chọn, không đè lên vùng chữ; người nhận cũng thấy sticker khi xem thư.

### Offline

- **AC-11 — Soạn thảo hoạt động bình thường khi mất mạng:**
  - **Giả sử** thiết bị đang mất kết nối mạng và người dùng đang ở màn hình soạn thư;
  - **Khi** người dùng nhập chữ, chọn phông, đổi màu nền và bật kẻ dòng;
  - **Thì** tất cả thao tác đó vẫn thực hiện được và phản ánh ngay lên màn hình; không xuất hiện thông báo lỗi nào.

- **AC-12 — Tải sticker mới thất bại khi mất mạng:**
  - **Giả sử** thiết bị đang mất kết nối mạng và người dùng đang ở màn hình soạn thư;
  - **Khi** người dùng mở bộ sticker và chọn một sticker chưa có sẵn trên thiết bị;
  - **Thì** hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." và sticker đó không được thêm vào thư.

## 5. Trường hợp ngoại lệ & lỗi

- Khi thoát màn hình soạn thư giữa chừng: hệ thống hỏi xác nhận "Bỏ thư này?" trước khi thoát; nếu xác nhận, nội dung đang soạn bị mất.
- Khi bàn phím ảo che khuất vùng soạn thảo: vùng soạn thảo tự cuộn để ký tự đang nhập luôn hiển thị phía trên bàn phím.
- Khi mất kết nối mạng giữa chừng: người dùng vẫn tiếp tục soạn nội dung, chọn phông, đổi màu và dùng sticker đã tải về trước đó bình thường; chỉ khi cố tải sticker mới hệ thống mới hiển thị thông báo không có kết nối, nội dung đang soạn không bị mất.
- Khi danh sách sticker không tải được do lỗi mạng hoặc lỗi máy chủ: bộ sticker hiển thị trạng thái lỗi kèm nút "Thử lại"; sticker đã thêm vào thư trước đó vẫn giữ nguyên.
- Khi chưa đăng nhập: người dùng không thể truy cập màn hình soạn thư — hệ thống chuyển về màn hình đăng nhập trước khi vào luồng soạn thư.
- Khi thoát app giữa chừng (vuốt tắt hoặc hệ điều hành thu hồi bộ nhớ): nội dung đang soạn bị mất vì soạn thư là xử lý cục bộ không lưu nháp; lần sau mở lại app người dùng phải bắt đầu soạn thư từ đầu.

---

## Liên kết tính năng khác

- SM-012 (Chọn template thư): bước trước cung cấp nền template.
- SM-014 (Đính tem & Kéo thả lên thư): bước tiếp theo.

# Xem trước & Lưu tem (SM-010 + SM-011)

**Feature Branch**: `009-luu-tem`
**Ngày tạo**: 2026-06-24
**Trạng thái**: Draft
**Ưu tiên**: 🔴 P0

> **Tài liệu thuần nghiệp vụ** cho Tester (QA), Business Analyst (BA), Product Owner (PO).
> **KHÔNG chứa chi tiết kỹ thuật**. Phần plan / vẽ giao diện / develop được làm RIÊNG ở bước sau.

---

## 1. Mục đích nghiệp vụ

Hoàn tất luồng tạo tem qua hai bước liên tiếp:

1. **Xem trước (SM-010)** — Cho người dùng thấy tem đúng như kết quả cuối cùng trước khi lưu, trên nhiều màu nền khác nhau. Là bước "kiểm tra chất lượng" cuối — tránh lưu xong mới phát hiện cần chỉnh lại.
2. **Lưu vào Album (SM-011)** — Lưu tem đã hoàn chỉnh vào bộ sưu tập cá nhân và tạo điểm chuyển tiếp tự nhiên: gợi ý dùng tem vừa tạo ngay (đính lên thư hoặc chia sẻ lên mạng xã hội).

## 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đang trong luồng tạo tem, sau bước viền (SM-009).
- **Khi nào dùng:** Bước 5–6 (cuối) của luồng tạo tem.
- **Điều kiện tiên quyết:** Đã hoàn thành bước viền & khung tem (SM-009).
- **Phạm vi:** Xem trước tem ở kích thước thực, đổi màu nền xem trước, quay lại chỉnh sửa bất kỳ bước nào, lưu tem vào Album, gợi ý hành động sau lưu. Không bao gồm xem Album (SM-022) hay đính tem lên thư (SM-014).

## 3. Quy tắc nghiệp vụ

### A. Xem trước tem

- **BR-01 — Kích thước thật:** Tem hiển thị mặc định ở kích thước thật để người dùng đánh giá chính xác.
- **BR-02 — Nhiều màu nền:** Người dùng có thể xem tem trên ít nhất ba màu nền khác nhau (trắng, đen, xám nhạt) để kiểm tra tem trông như thế nào trong các ngữ cảnh khác nhau.
- **BR-03 — Quay lại chỉnh sửa:** Từ màn hình xem trước, người dùng có thể quay lại bất kỳ bước nào trước đó trong luồng tạo tem (bộ lọc màu, trang trí, viền) để chỉnh sửa.
- **BR-04 — Nút Lưu tem:** Từ màn hình xem trước, nhấn "Lưu tem" để chuyển sang bước lưu.
- **BR-05 — Phóng to kiểm tra chi tiết:** Người dùng có thể dùng cử chỉ banh/chụm ngón tay để phóng to bất kỳ vùng nào của tem nhằm kiểm tra chi tiết (viền, sticker, chữ, chất lượng ảnh). Chỉ để xem — không thay đổi tem thật.

### B. Lưu tem vào Album

- **BR-06 — Giới hạn tem tháng (Free):** Người dùng gói Thường được lưu tối đa ba mươi tem mỗi tháng. Sau khi đạt giới hạn, không lưu thêm được cho đến đầu tháng tiếp theo hoặc nâng cấp Premium.
- **BR-07 — Không giới hạn (Premium):** Người dùng gói Premium lưu tem không giới hạn số lượng mỗi tháng.
- **BR-08 — Ngày tạo tự động:** Khi lưu, hệ thống tự ghi ngày tạo cho tem — không yêu cầu người dùng nhập.
- **BR-09 — Gợi ý hành động sau lưu:** Sau khi lưu thành công, hệ thống hiển thị hai gợi ý: (1) "Gắn lên thư" — dẫn vào luồng soạn thư với tem vừa lưu, (2) "Chia sẻ & nhận 10📮" — xem BR-10.
- **BR-10 — Chia sẻ tem để kiếm Dấu (Share to Unlock):** Khi người dùng nhấn "Chia sẻ & nhận 10📮", hệ thống xuất ảnh tem kèm watermark StampMail nhỏ ở góc rồi mở native share sheet của hệ điều hành. Người dùng tự chọn app để đăng. Dấu được trao ngay khi nhấn nút — không yêu cầu xác nhận đã đăng thật.
- **BR-11 — Watermark bắt buộc trên ảnh chia sẻ:** Mọi ảnh tem xuất ra để chia sẻ đều có watermark StampMail ở góc. Không thể tắt hoặc xóa watermark.
- **BR-12 — Giới hạn chia sẻ tuần:** Tối đa ba lần chia sẻ được thưởng Dấu mỗi tuần (tuần tính từ thứ Hai đến Chủ Nhật). Từ lần thứ tư trở đi, nút vẫn hoạt động (vẫn mở share sheet) nhưng không trao thêm Dấu — hiển thị "Đã đạt giới hạn chia sẻ tuần này".

### Trạng thái offline

- **BR-13 — Xem trước không cần mạng:** Toàn bộ thao tác xem trước (đổi màu nền, phóng to/thu nhỏ, quay lại các bước chỉnh sửa) vẫn hoạt động bình thường khi mất kết nối, vì dữ liệu tem đang được xử lý cục bộ trên thiết bị.
- **BR-14 — Chặn Lưu tem khi mất mạng:** Khi không có kết nối, nút "Lưu tem" bị vô hiệu hóa và hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." Mọi thao tác xem trước được giữ nguyên để người dùng tiếp tục lưu ngay khi có mạng trở lại.
- **BR-15 — Chặn chia sẻ khi mất kết nối:** Khi mất mạng, nút "Chia sẻ & nhận 10📮" bị vô hiệu hóa và hiển thị thông báo yêu cầu kết nối. Không trao Dấu khi chưa thực hiện được thao tác.

## 4. Tiêu chí nghiệm thu

### A. Xem trước tem

- **AC-01 — Tem hiển thị đúng kích thước:**
  - **Giả sử** người dùng vừa hoàn tất bước viền;
  - **Khi** chuyển sang màn hình xem trước;
  - **Thì** tem hiển thị ở kích thước thật với đầy đủ: ảnh đã chỉnh, sticker/chữ đã trang trí, và viền đã chọn.

- **AC-02 — Đổi màu nền xem trước:**
  - **Giả sử** người dùng đang xem trước tem;
  - **Khi** chọn một màu nền khác;
  - **Thì** màu nền phía sau tem thay đổi ngay, tem không thay đổi.

- **AC-03 — Quay lại chỉnh bộ lọc:**
  - **Giả sử** người dùng đang ở màn hình xem trước và muốn đổi bộ lọc;
  - **Khi** nhấn "Chỉnh sửa lại" và chọn quay về bước Bộ lọc màu;
  - **Thì** hệ thống quay về bước lọc màu với ảnh và các thay đổi khác vẫn còn.

- **AC-04 — Phóng to kiểm tra chi tiết:**
  - **Giả sử** người dùng đang xem trước tem ở kích thước thật;
  - **Khi** banh ngón tay lên một vùng bất kỳ của tem;
  - **Thì** tem phóng to theo ngón tay; chụm ngón tay thu về kích thước thật; nút "Lưu tem" và "Chỉnh sửa lại" vẫn hiển thị.

### B. Lưu tem vào Album

- **AC-05 — Lưu tem thành công (Free còn hạn mức):**
  - **Giả sử** người dùng gói Thường còn dưới ba mươi tem trong tháng;
  - **Khi** nhấn "Lưu tem" từ màn hình xem trước;
  - **Thì** tem được lưu vào Album và hiển thị thông báo lưu thành công kèm hai gợi ý hành động tiếp theo.

- **AC-06 — Từ chối lưu khi hết hạn mức Free:**
  - **Giả sử** người dùng gói Thường đã lưu đủ ba mươi tem trong tháng;
  - **Khi** cố lưu thêm tem;
  - **Thì** hệ thống thông báo đã đạt giới hạn tháng, gợi ý nâng cấp Premium hoặc chờ đầu tháng mới.

- **AC-07 — Premium lưu không giới hạn:**
  - **Giả sử** người dùng gói Premium;
  - **Khi** lưu tem bất kỳ lúc nào;
  - **Thì** tem được lưu thành công không bị chặn bởi giới hạn.

- **AC-08 — Gợi ý đính lên thư:**
  - **Giả sử** tem vừa được lưu thành công;
  - **Khi** nhấn vào gợi ý "Gắn lên thư";
  - **Thì** mở luồng soạn thư với tem vừa lưu đã được chọn sẵn.

- **AC-09 — Ngày tạo hiển thị đúng trong Album:**
  - **Giả sử** tem vừa được lưu;
  - **Khi** mở Album và xem chi tiết tem vừa lưu;
  - **Thì** ngày tạo hiển thị đúng là ngày lưu.

- **AC-10 — Chia sẻ tem và nhận Dấu (còn trong giới hạn tuần):**
  - **Giả sử** người dùng vừa lưu tem và chưa chia sẻ đủ 3 lần trong tuần;
  - **Khi** nhấn "Chia sẻ & nhận 10📮";
  - **Thì** native share sheet mở với ảnh tem kèm watermark, và số Dấu tăng 10📮 ngay lập tức.

- **AC-11 — Chia sẻ khi đã đạt giới hạn tuần:**
  - **Giả sử** người dùng đã chia sẻ đủ 3 lần trong tuần này;
  - **Khi** nhấn nút chia sẻ lần thứ 4;
  - **Thì** native share sheet vẫn mở bình thường nhưng không trao Dấu; hiển thị thông báo "Đã đạt giới hạn chia sẻ tuần này".

### Offline

- **AC-12 — Xem trước tem khi mất mạng:**
  - **Giả sử** người dùng đang ở màn hình xem trước và thiết bị mất kết nối;
  - **Khi** người dùng đổi màu nền, phóng to/thu nhỏ tem, hoặc nhấn "Chỉnh sửa lại";
  - **Thì** các thao tác vẫn thực hiện được bình thường, tem hiển thị không bị ảnh hưởng.

- **AC-13 — Chặn Lưu tem khi mất mạng:**
  - **Giả sử** thiết bị không có kết nối và người dùng đang ở màn hình xem trước;
  - **Khi** nhấn "Lưu tem";
  - **Thì** hệ thống không lưu, hiển thị "Không có kết nối. Vui lòng thử lại khi có mạng." và giữ nguyên tem trên màn hình để người dùng thử lại.

- **AC-14 — Vô hiệu hóa nút chia sẻ khi mất mạng:**
  - **Giả sử** tem vừa được lưu thành công và thiết bị hiện mất kết nối;
  - **Khi** màn hình gợi ý hành động sau lưu hiển thị;
  - **Thì** nút "Chia sẻ & nhận 10📮" bị vô hiệu hóa kèm thông báo yêu cầu kết nối; không có Dấu nào được trao.

## 5. Trường hợp ngoại lệ & lỗi

**Xem trước:**
- Khi mất kết nối (offline): xem trước dùng dữ liệu cục bộ nên vẫn hoạt động đầy đủ; chỉ nút "Lưu tem" bị vô hiệu hóa (xem BR-14).
- Khi chưa đăng nhập: xem trước hiển thị bình thường; khi nhấn "Lưu tem", hệ thống chuyển đến màn hình đăng nhập trước.
- Khi thoát app tại màn hình xem trước: mất toàn bộ nội dung đang làm, lần sau mở lại quay về màn hình chính.

**Lưu vào Album:**
- Khi mất kết nối lúc đang lưu: thông báo lỗi mạng, tem chưa được lưu; nội dung tem được giữ nguyên trên màn hình để thử lại khi có mạng.
- Khi hết dung lượng thiết bị: thông báo lỗi bộ nhớ, hướng dẫn giải phóng dung lượng.
- Khi server trả lỗi: thông báo lỗi chung kèm nút "Thử lại" — tem chưa vào Album, dữ liệu tem vẫn giữ nguyên.
- Khi thoát app trước khi lưu xong: tiến trình lưu bị huỷ, tem không được ghi vào Album; lần sau mở lại phải tạo lại từ đầu.

---

## Liên kết tính năng khác

- SM-009 (Viền & Khung tem): bước trước dẫn vào đây.
- SM-022 (Album sưu tập tem): nơi tem được lưu vào.
- SM-014 (Đính tem lên thư): điểm đến khi chọn gợi ý "Gắn lên thư".
- SM-025 (Chia sẻ tem lên MXH): tính năng chia sẻ đầy đủ (P1) — MVP dùng native share sheet trực tiếp.
- SM-033 (Hệ thống Dấu): quy tắc thưởng và giới hạn tuần cho Share to Unlock.
- SM-030 (Giới hạn tháng & Nhắc hạn mức): quy tắc giới hạn ba mươi tem/tháng.
- SM-006/SM-008/SM-009: các bước có thể quay lại chỉnh từ màn hình xem trước.

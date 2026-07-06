# Viền & Khung tem (SM-009)

**Feature Branch**: `008-vien-khung-tem`
**Ngày tạo**: 2026-06-24
**Trạng thái**: Draft
**Ưu tiên**: 🔴 P0

> **Tài liệu thuần nghiệp vụ** cho Tester (QA), Business Analyst (BA), Product Owner (PO).
> **KHÔNG chứa chi tiết kỹ thuật**. Phần plan / vẽ giao diện / develop được làm RIÊNG ở bước sau.

---

## 1. Mục đích nghiệp vụ

Hoàn thiện tem bằng viền đặc trưng của tem thư thật — tạo nhận diện thị giác rõ ràng và cảm giác "đây đúng là một con tem". Viền là chi tiết định danh thương hiệu StampMail.

## 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đang trong luồng tạo tem, sau bước trang trí.
- **Khi nào dùng:** Bước 4 của luồng tạo tem, sau SM-008.
- **Điều kiện tiên quyết:** Đã qua bước trang trí tem (SM-008).
- **Phạm vi:** Chọn kiểu viền và màu viền; điều chỉnh vị trí và tỉ lệ ảnh bên trong khung. Không bao gồm xem trước toàn bộ tem hoàn chỉnh (SM-010) hay lưu (SM-011).

## 3. Quy tắc nghiệp vụ

- **BR-01 — Bảy kiểu viền:** Có bảy kiểu viền tổng cộng.
- **BR-02 — Viền Free:** Ba kiểu viền khả dụng cho tất cả người dùng gói Thường: Răng cưa cổ điển, Răng tròn, Gợn sóng.
- **BR-03 — Viền khóa:** Bốn kiểu viền còn lại bị khóa mặc định: Zigzag, Viền đôi, Retro bo mềm, Hoa văn nổi. Người dùng gói Thường thấy được nhưng không dùng được cho đến khi mở khóa theo một trong hai cách: nâng cấp Premium (mở toàn bộ) hoặc dùng Dấu (mở từng kiểu riêng lẻ, xem BR-06 và SM-033).
- **BR-04 — Màu viền:** Người dùng chọn màu cho viền từ một bảng màu có sẵn.
- **BR-05 — Xem trước trực tiếp:** Thay đổi kiểu viền hoặc màu viền phản ánh ngay trên ảnh xem trước tem, không cần xác nhận riêng.
- **BR-06 — Mở viền khóa bằng Dấu:** Người dùng gói Thường dùng **80📮** (SM-033 BR-12) để mở vĩnh viễn một kiểu viền đang bị khóa. Mỗi lần chỉ mở một kiểu; sau khi mở, kiểu đó luôn khả dụng cho tài khoản này.

### Điều chỉnh ảnh trong khung

- **BR-10 — Di chuyển ảnh trong khung:** Sau khi chọn kiểu viền, người dùng có thể kéo một ngón tay trên vùng ảnh để dịch chuyển ảnh bên trong khung. Khung và viền giữ nguyên vị trí; chỉ phần ảnh hiển thị bên trong thay đổi.
- **BR-11 — Phóng to ảnh trong khung:** Người dùng banh hai ngón tay trên vùng ảnh để phóng to — làm nổi bật vùng chi tiết muốn hiển thị trong khung.
- **BR-12 — Thu nhỏ ảnh trong khung:** Người dùng chụm hai ngón tay để thu nhỏ — xem được nhiều vùng ảnh hơn bên trong khung. Ảnh không được thu nhỏ đến mức để lộ vùng trống bên trong khung; hệ thống tự dừng khi ảnh vừa phủ kín khung.
- **BR-13 — Ảnh phải phủ kín khung mọi lúc:** Trong khi điều chỉnh, không có vùng trống nào hiển thị bên trong đường viền tem. Nếu kéo ảnh ra ngoài quá mức, hệ thống tự giới hạn để cạnh ảnh không lùi vào trong khung.
- **BR-14 — Vị trí mặc định khi chọn viền mới:** Khi người dùng đổi sang kiểu viền khác, ảnh tự động về vị trí trung tâm và tỉ lệ vừa khung. Các điều chỉnh trước đó (di chuyển, zoom) bị đặt lại.

### Trạng thái offline

- **BR-07 — Chỉnh viền không cần mạng:** Khi mất kết nối, người dùng vẫn chọn được kiểu viền (Free đã mở khóa), đổi màu viền và xem trước tem bình thường — các thao tác này diễn ra hoàn toàn trên thiết bị.
- **BR-08 — Mở khóa viền cần mạng:** Hành động dùng Dấu để mở viền khóa hoặc nâng cấp Premium đều yêu cầu kết nối mạng. Khi mất mạng, hệ thống chặn các hành động này và thông báo: "Không có kết nối. Vui lòng thử lại khi có mạng."
- **BR-09 — Trạng thái viền đã mở khóa vẫn giữ nguyên khi offline:** Các kiểu viền mà người dùng đã mở khóa trước đó vẫn khả dụng và có thể áp dụng khi không có mạng.

## 4. Tiêu chí nghiệm thu

- **AC-01 — Chọn viền Free và thấy ngay:**
  - **Giả sử** người dùng gói Thường đang ở bước viền;
  - **Khi** chọn một trong ba kiểu viền Free;
  - **Thì** xem trước tem hiển thị ngay kiểu viền đó.

- **AC-02 — Viền khóa — hiện hai lựa chọn:**
  - **Giả sử** người dùng gói Thường;
  - **Khi** nhấn vào một trong bốn kiểu viền đang bị khóa;
  - **Thì** hệ thống hiển thị hai lựa chọn: "Dùng 80📮 để mở kiểu viền này" và "Nâng cấp Premium để mở tất cả"; không áp viền cho đến khi chọn một trong hai.

- **AC-03 — Đổi màu viền:**
  - **Giả sử** người dùng đã chọn một kiểu viền;
  - **Khi** chọn màu khác từ bảng màu;
  - **Thì** viền trên xem trước chuyển sang màu mới ngay.

- **AC-04 — Tất cả viền khả dụng khi dùng Premium:**
  - **Giả sử** người dùng gói Premium;
  - **Khi** vào bước viền;
  - **Thì** cả bảy kiểu viền đều có thể chọn, không hiển thị gợi ý mở khóa.

- **AC-05 — Tiếp tục sang xem trước tem:**
  - **Giả sử** người dùng đã chọn xong kiểu và màu viền;
  - **Khi** nhấn Tiếp tục;
  - **Thì** chuyển sang màn hình xem trước tem hoàn chỉnh (SM-010).

- **AC-06 — Mở viền bằng Dấu:**
  - **Giả sử** người dùng gói Thường có ≥ 80📮 và nhấn vào kiểu viền đang bị khóa;
  - **Khi** chọn "Dùng 80📮 để mở kiểu viền này" và xác nhận;
  - **Thì** kiểu viền mở vĩnh viễn, số Dấu giảm 80📮, người dùng áp được ngay trên xem trước tem.

- **AC-09 — Di chuyển ảnh trong khung:**
  - **Giả sử** người dùng đã chọn một kiểu viền và đang ở bước viền;
  - **Khi** kéo một ngón tay trên vùng ảnh sang bên phải;
  - **Thì** ảnh dịch chuyển sang phải trong khung; viền và các thành phần trang trí giữ nguyên vị trí.

- **AC-10 — Phóng to ảnh trong khung:**
  - **Giả sử** người dùng đã chọn kiểu viền;
  - **Khi** đặt hai ngón tay lên vùng ảnh và banh ra;
  - **Thì** ảnh phóng to bên trong khung, làm nổi bật vùng chi tiết giữa hai ngón tay.

- **AC-11 — Thu nhỏ dừng khi ảnh vừa phủ khung:**
  - **Giả sử** người dùng đã phóng to ảnh;
  - **Khi** chụm hai ngón tay để thu nhỏ dần cho đến khi ảnh gần bằng kích thước khung;
  - **Thì** ảnh thu nhỏ đến mức vừa phủ kín toàn bộ khung rồi dừng lại; không có vùng trống nào xuất hiện bên trong viền tem.

- **AC-12 — Kéo ảnh không lộ vùng trống:**
  - **Giả sử** ảnh đang ở kích thước vừa khung và người dùng kéo ảnh về một phía;
  - **Khi** tiếp tục kéo đến mức cạnh ảnh gần vào trong khung;
  - **Thì** hệ thống chặn, ảnh không di chuyển thêm; cạnh ảnh không lùi vào bên trong đường viền.

- **AC-13 — Đổi kiểu viền đặt lại vị trí ảnh:**
  - **Giả sử** người dùng đã phóng to và dịch ảnh sang một góc;
  - **Khi** chọn sang kiểu viền khác;
  - **Thì** ảnh tự động về trung tâm, tỉ lệ vừa khung mới; các điều chỉnh trước bị đặt lại.

### Offline

- **AC-07 — Chỉnh viền và xem trước khi offline:**
  - **Giả sử** người dùng đang ở bước viền và thiết bị mất kết nối mạng;
  - **Khi** chọn kiểu viền Free (hoặc kiểu đã mở khóa trước đó) và đổi màu viền;
  - **Thì** xem trước tem cập nhật ngay như khi có mạng, không xuất hiện thông báo lỗi.

- **AC-08 — Chặn mở khóa viền khi offline:**
  - **Giả sử** người dùng gói Thường đang ở bước viền và thiết bị mất kết nối mạng;
  - **Khi** nhấn vào kiểu viền đang bị khóa và chọn mở bằng Dấu hoặc nâng cấp Premium;
  - **Thì** hệ thống chặn hành động và hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."; số Dấu không thay đổi.

## 5. Trường hợp ngoại lệ & lỗi

- Khi người dùng không chọn kiểu viền nào và nhấn Tiếp tục: hệ thống áp kiểu viền mặc định (Răng cưa cổ điển) và chuyển bước.
- Khi thoát app giữa bước viền: mất toàn bộ nội dung đang chỉnh, quay về màn hình chính khi mở lại.

### Khi mất kết nối (offline)

- Các kiểu viền đã tải về trước đó (Free và đã mở khóa) vẫn hiển thị và chọn được bình thường; xem trước tem hoạt động đầy đủ.
- Các kiểu viền chưa tải về (viền mới chưa từng tải) không hiển thị nội dung, kèm ghi chú "Cần kết nối để tải viền mới."
- Hành động mở khóa viền bằng Dấu hoặc nâng cấp Premium bị vô hiệu hoá; hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." và số Dấu không thay đổi.

### Khi dữ liệu không tải được (lỗi mạng / lỗi máy chủ)

- Nếu danh sách viền không tải được, màn hình hiển thị biểu tượng lỗi và thông báo "Không thể tải viền. Vui lòng thử lại."; có nút "Thử lại" để tải lại danh sách.
- Nếu thao tác mở khóa viền thất bại do lỗi máy chủ, hệ thống thông báo "Mở khóa không thành công. Vui lòng thử lại." và không trừ Dấu của người dùng.

### Khi chưa đăng nhập / thoát app giữa chừng

- Người dùng chưa đăng nhập không thể vào bước viền; hệ thống chuyển đến màn hình đăng nhập trước khi cho phép tạo tem.
- Khi thoát app giữa bước viền (đóng app hoặc chuyển app khác rồi bị hệ thống thu hồi), toàn bộ nội dung tem đang trang trí bị huỷ; lần mở lại app, người dùng bắt đầu lại từ màn hình chính.

---

## Liên kết tính năng khác

- SM-008 (Trang trí tem): bước trước.
- SM-010 (Xem trước tem hoàn chỉnh): bước tiếp theo.
- SM-028 (Nâng cấp Premium): lựa chọn mở toàn bộ viền khóa cùng lúc.
- SM-033 (Hệ thống Dấu): lựa chọn mở từng kiểu viền riêng lẻ bằng 80📮.

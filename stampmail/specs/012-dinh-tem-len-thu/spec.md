# Đính tem & Kéo thả lên thư (SM-014)

**Feature Branch**: `012-dinh-tem-len-thu`
**Ngày tạo**: 2026-06-24
**Trạng thái**: Draft
**Ưu tiên**: P2

> **Tài liệu thuần nghiệp vụ** cho Tester (QA), Business Analyst (BA), Product Owner (PO).
> **KHÔNG chứa chi tiết kỹ thuật**. Phần plan / vẽ giao diện / develop được làm RIÊNG ở bước sau.

---

## 1. Mục đích nghiệp vụ

Cho phép người dùng đính tem từ Album lên thư đang soạn — tạo ra sự kết hợp giữa nội dung thư và tem thư theo đúng phong cách tem thư truyền thống. Tem đặt ở vị trí quen thuộc (góc phải phía trên) nhưng người dùng có thể điều chỉnh.

## 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đang soạn thư và muốn đính tem.
- **Khi nào dùng:** Bước 3 trong luồng soạn thư, sau SM-013.
- **Điều kiện tiên quyết:** Đã có ít nhất một tem trong Album (SM-011). Đây là bước bắt buộc — người dùng phải đính ít nhất một tem để tiếp tục gửi thư. Đang soạn thư (SM-013).
- **Phạm vi:** Chọn tem từ Album, đính lên thư, điều chỉnh vị trí. Không bao gồm xem trước toàn bộ thư (SM-015).

## 3. Quy tắc nghiệp vụ

- **BR-01 — Nguồn tem:** Người dùng chọn tem từ bất kỳ album nào trong bộ sưu tập cá nhân. Khi chọn tem, màn hình hiển thị các album được phân nhóm để dễ tìm:
  - **Tất cả** — toàn bộ tem không lọc.
  - **Tự tạo** — các tem do người dùng tự tạo (SM-011).
  - **Nhận được** — các tem người khác gửi tặng.
  - **Album tùy chỉnh** — các album người dùng tự tạo (SM-022 BR-06); mỗi album tùy chỉnh hiển thị như một tab riêng, nằm sau ba tab mặc định ở trên.
  Người dùng chuyển tab giữa các nhóm album để tìm tem muốn đính.
- **BR-02 — Vị trí mặc định:** Tem được đặt mặc định ở góc phải phía trên của thư, theo phong cách tem thư thật.
- **BR-03 — Giới hạn số tem:** Mỗi thư đính được tối đa ba tem.
- **BR-04 — Xem trước tổng thể:** Sau khi đính tem, người dùng thấy xem trước toàn bộ thư kèm tem đã đính.
- **BR-05 — Tem bắt buộc:** Người dùng phải đính ít nhất một tem trước khi có thể chuyển sang bước xem trước thư. Không thể bỏ qua bước này.

### Trạng thái offline

- **BR-06 — Xem album khi mất mạng:** Nếu danh sách tem trong Album đã được tải trước đó, người dùng vẫn thấy và chọn được tem từ danh sách đó khi mất kết nối; hệ thống hiển thị thông báo "Đang xem ngoại tuyến" phía trên danh sách.
- **BR-07 — Đính tem cục bộ khi mất mạng:** Thao tác đính tem lên thư, điều chỉnh vị trí và xem trước vẫn thực hiện được khi không có mạng vì không cần kết nối máy chủ.
- **BR-08 — Chặn tải danh sách mới khi mất mạng:** Nếu Album chưa được tải lần nào hoặc người dùng yêu cầu làm mới danh sách khi mất mạng, hệ thống thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." và không cố tải thêm dữ liệu.

## 4. Tiêu chí nghiệm thu

- **AC-01 — Chọn tem từ Album và đính lên thư:**
  - **Giả sử** người dùng đang ở bước đính tem và có tem trong Album;
  - **Khi** chọn một tem từ bất kỳ nhóm album nào;
  - **Thì** tem xuất hiện ở góc phải phía trên của thư trong xem trước.

- **AC-02 — Đính tối đa ba tem:**
  - **Giả sử** người dùng đã đính ba tem lên thư;
  - **Khi** cố chọn thêm tem thứ tư;
  - **Thì** hệ thống thông báo đã đạt giới hạn ba tem một thư.

- **AC-03 — Chưa đính tem thì không chuyển bước được:**
  - **Giả sử** người dùng đang ở bước đính tem nhưng chưa chọn tem nào;
  - **Khi** nhấn Tiếp tục;
  - **Thì** hệ thống hiển thị thông báo yêu cầu đính ít nhất một tem, không chuyển sang bước xem trước.

- **AC-04 — Không có tem trong Album:**
  - **Giả sử** người dùng chưa có tem nào trong Album;
  - **Khi** vào bước đính tem;
  - **Thì** hệ thống hiển thị trạng thái trống kèm gợi ý tạo tem trước, có nút tắt để bỏ qua.

- **AC-05 — Chuyển tab giữa các nhóm album:**
  - **Giả sử** người dùng đang ở tab "Tất cả" trong màn hình chọn tem;
  - **Khi** nhấn sang tab "Nhận được";
  - **Thì** danh sách tem cập nhật chỉ hiển thị tem nhận từ người khác; tem đã đính (nếu có) không bị xóa.

### Offline

- **AC-06 — Chọn tem từ album đã tải khi mất mạng:**
  - **Giả sử** người dùng đang ở bước đính tem, Album đã được tải trước đó và thiết bị mất kết nối mạng;
  - **Khi** vào màn hình chọn tem;
  - **Thì** danh sách tem đã tải trước đó vẫn hiển thị đầy đủ, người dùng chọn và đính tem lên thư được bình thường, và hệ thống hiển thị thông báo "Đang xem ngoại tuyến".

- **AC-07 — Không tải được album khi mất mạng:**
  - **Giả sử** người dùng vào bước đính tem nhưng Album chưa từng được tải và thiết bị không có mạng;
  - **Khi** màn hình chọn tem mở ra;
  - **Thì** hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." và không hiển thị danh sách tem.

## 5. Trường hợp ngoại lệ & lỗi

- Khi thoát màn hình đính tem: nội dung thư đang soạn được giữ lại, tem đã chọn (nếu có) có thể bị mất — hỏi xác nhận trước khi thoát.
- Khi Album chưa tải xong: hiển thị trạng thái đang tải; không cho chọn tem khi chưa tải xong.

**Nhóm 1 — Khi mất kết nối (offline / no network):**
- Nếu Album đã tải trước đó, danh sách tem vẫn hiển thị từ bộ nhớ đệm và người dùng vẫn chọn, đính, điều chỉnh vị trí tem được bình thường (thao tác đính tem là cục bộ, không cần mạng).
- Nếu Album chưa từng được tải, hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." và không hiển thị danh sách tem; người dùng không thể chọn tem.
- Khi đang xem album đã tải trong lúc mất mạng, hệ thống hiển thị thông báo "Đang xem ngoại tuyến" phía trên danh sách; nút làm mới danh sách bị vô hiệu hoá cho đến khi có kết nối trở lại.

**Nhóm 2 — Khi dữ liệu không tải được (lỗi mạng / lỗi máy chủ):**
- Khi tải danh sách Album thất bại do lỗi máy chủ, màn hình hiển thị thông báo lỗi và nút "Thử lại" để người dùng tải lại danh sách.
- Trong khi chờ tải, hệ thống hiển thị trạng thái đang tải (skeleton); người dùng không thể chọn tem cho đến khi danh sách tải xong hoặc có kết quả lỗi.

**Nhóm 3 — Khi chưa đăng nhập / thoát app giữa chừng:**
- Nếu người dùng chưa đăng nhập, hệ thống chuyển hướng đến màn hình đăng nhập khi vào bước đính tem; không có chế độ khách cho tính năng này vì Album gắn với tài khoản.
- Nếu người dùng thoát app giữa chừng (nhấn Home hoặc thiết bị tắt đột ngột), thư đang soạn và tem đã đính được lưu tạm; lần sau mở lại app, người dùng có thể tiếp tục từ bước đính tem với dữ liệu đã có.

---

## Liên kết tính năng khác

- SM-013 (Soạn nội dung thư): bước trước.
- SM-015 (Xem trước thư trước khi gửi): bước tiếp theo.
- SM-022 (Album sưu tập tem): nguồn tem — nhóm "Tất cả", "Tự tạo", "Nhận được".

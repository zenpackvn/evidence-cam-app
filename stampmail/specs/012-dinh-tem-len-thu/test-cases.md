# Test Cases — Đính tem & Kéo thả lên thư (012-dinh-tem-len-thu)

---

## TC-12-001: Chọn tem từ tab "Tất cả" và đính lên thư

**AC liên quan:** AC-01, BR-01, BR-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập.
- Album có ít nhất một tem.
- Người dùng đang ở bước đính tem (sau khi soạn nội dung thư xong).

### Act (Thực hiện)
- Mở màn hình chọn tem.
- Chọn tab "Tất cả".
- Nhấn chọn một tem bất kỳ.

### Assert (Kiểm tra)
- Tem xuất hiện trên thư ở vị trí góc phải phía trên.
- Xem trước thư hiển thị tem vừa đính.

---

## TC-12-002: Chọn tem từ tab "Tự tạo" và đính lên thư

**AC liên quan:** AC-01, BR-01
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập.
- Album có ít nhất một tem tự tạo (SM-011).
- Người dùng đang ở bước đính tem.

### Act (Thực hiện)
- Mở màn hình chọn tem.
- Nhấn tab "Tự tạo".
- Chọn một tem trong danh sách.

### Assert (Kiểm tra)
- Danh sách chỉ hiển thị tem tự tạo.
- Tem được đính lên thư ở góc phải phía trên.

---

## TC-12-003: Chọn tem từ tab "Nhận được" và đính lên thư

**AC liên quan:** AC-01, AC-05, BR-01
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập.
- Album có ít nhất một tem nhận từ người khác.
- Người dùng đang ở bước đính tem, đang ở tab "Tất cả".

### Act (Thực hiện)
- Nhấn sang tab "Nhận được".
- Chọn một tem trong danh sách.

### Assert (Kiểm tra)
- Danh sách cập nhật chỉ hiển thị tem nhận từ người khác.
- Tem vừa chọn được đính lên thư.
- Tem đã đính trước đó (nếu có) không bị xóa.

---

## TC-12-004: Chọn tem từ album tùy chỉnh

**AC liên quan:** AC-01, BR-01
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập.
- Người dùng đã tạo ít nhất một album tùy chỉnh có chứa tem (SM-022 BR-06).
- Người dùng đang ở bước đính tem.

### Act (Thực hiện)
- Mở màn hình chọn tem.
- Nhấn vào tab album tùy chỉnh (nằm sau ba tab mặc định).
- Chọn một tem trong album đó.

### Assert (Kiểm tra)
- Tab album tùy chỉnh hiển thị đúng tên album và danh sách tem của album đó.
- Tem được đính lên thư thành công.

---

## TC-12-005: Chuyển qua lại giữa các tab không làm mất tem đã đính

**AC liên quan:** AC-05
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đính một tem lên thư.
- Người dùng đang ở tab "Tất cả" trong màn hình chọn tem.

### Act (Thực hiện)
- Nhấn sang tab "Nhận được".
- Nhấn lại tab "Tất cả".

### Assert (Kiểm tra)
- Danh sách tem cập nhật đúng theo từng tab.
- Tem đã đính trước đó vẫn còn trên thư, không bị xóa.

---

## TC-12-006: Vị trí mặc định của tem là góc phải phía trên

**AC liên quan:** AC-01, BR-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang ở bước đính tem, chưa đính tem nào.

### Act (Thực hiện)
- Chọn một tem bất kỳ từ Album.

### Assert (Kiểm tra)
- Tem xuất hiện đúng ở góc phải phía trên của thư (không nằm ở vị trí khác).

---

## TC-12-007: Đính tối đa ba tem — lần thứ tư bị chặn

**AC liên quan:** AC-02, BR-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đính đúng ba tem lên thư.

### Act (Thực hiện)
- Nhấn chọn thêm tem thứ tư từ Album.

### Assert (Kiểm tra)
- Hệ thống hiển thị thông báo đã đạt giới hạn tối đa ba tem mỗi thư.
- Tem thứ tư không được đính lên thư.

---

## TC-12-008: Chưa đính tem — nhấn Tiếp tục bị chặn

**AC liên quan:** AC-03, BR-05
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang ở bước đính tem, chưa chọn tem nào.

### Act (Thực hiện)
- Nhấn nút "Tiếp tục".

### Assert (Kiểm tra)
- Hệ thống hiển thị thông báo yêu cầu đính ít nhất một tem.
- Màn hình không chuyển sang bước xem trước thư.

---

## TC-12-009: Album trống — hiển thị trạng thái trống và gợi ý tạo tem

**AC liên quan:** AC-04
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập nhưng Album không có tem nào.
- Người dùng đang ở bước đính tem.

### Act (Thực hiện)
- Mở màn hình chọn tem.

### Assert (Kiểm tra)
- Màn hình hiển thị trạng thái trống (empty state).
- Có gợi ý tạo tem trước.
- Có nút tắt (hoặc bỏ qua) để đóng màn hình.

---

## TC-12-010: Album đã tải — chọn và đính tem được khi mất mạng

**AC liên quan:** AC-06, BR-06, BR-07
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập.
- Album đã được tải thành công ít nhất một lần (danh sách tem đang hiển thị đầy đủ).
- Tắt kết nối mạng trên thiết bị.

### Act (Thực hiện)
- Vào màn hình chọn tem.
- Chọn một tem từ danh sách đã hiển thị.

### Assert (Kiểm tra)
- Danh sách tem đã tải trước đó vẫn hiển thị đầy đủ.
- Thông báo "Đang xem ngoại tuyến" xuất hiện phía trên danh sách.
- Người dùng chọn và đính tem lên thư thành công.

---

## TC-12-011: Album chưa tải — thông báo lỗi kết nối khi mất mạng

**AC liên quan:** AC-07, BR-08
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập nhưng Album chưa được tải lần nào.
- Thiết bị không có kết nối mạng.

### Act (Thực hiện)
- Vào bước đính tem.
- Mở màn hình chọn tem.

### Assert (Kiểm tra)
- Hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."
- Không hiển thị danh sách tem.
- Người dùng không thể chọn tem.

---

## TC-12-012: Nút làm mới bị vô hiệu hoá khi mất mạng

**AC liên quan:** AC-06, BR-06
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Album đã được tải trước đó.
- Thiết bị đang mất kết nối mạng.
- Người dùng đang xem danh sách tem (từ bộ nhớ đệm).

### Act (Thực hiện)
- Quan sát hoặc nhấn nút làm mới danh sách.

### Assert (Kiểm tra)
- Nút làm mới danh sách bị vô hiệu hoá (không thể nhấn).
- Thông báo "Đang xem ngoại tuyến" vẫn hiển thị.

---

## TC-12-013: Tải Album thất bại — hiển thị lỗi và nút Thử lại

**AC liên quan:** BR (Nhóm 2 — lỗi máy chủ)
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập, có kết nối mạng.
- Máy chủ trả về lỗi khi tải danh sách Album.

### Act (Thực hiện)
- Vào màn hình chọn tem.

### Assert (Kiểm tra)
- Màn hình hiển thị thông báo lỗi tải dữ liệu.
- Có nút "Thử lại" để tải lại danh sách.
- Người dùng không thể chọn tem khi chưa có danh sách.

---

## TC-12-014: Hiển thị trạng thái đang tải khi Album chưa xong

**AC liên quan:** BR (Nhóm 2 — skeleton loading)
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập, có kết nối mạng.
- Album đang trong quá trình tải (mạng chậm hoặc dữ liệu lớn).

### Act (Thực hiện)
- Vào màn hình chọn tem trong lúc đang tải.

### Assert (Kiểm tra)
- Màn hình hiển thị trạng thái đang tải (skeleton/loading).
- Người dùng không thể chọn tem trong khi đang tải.
- Sau khi tải xong, danh sách tem hiển thị và có thể chọn bình thường.

---

## TC-12-015: Thoát màn hình đính tem — hiển thị xác nhận nếu đã chọn tem

**AC liên quan:** Mục 5 — thoát app giữa chừng
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang ở bước đính tem và đã chọn ít nhất một tem.

### Act (Thực hiện)
- Nhấn nút quay lại / thoát màn hình đính tem.

### Assert (Kiểm tra)
- Hệ thống hiển thị hộp thoại xác nhận trước khi thoát.
- Nội dung thư đang soạn được giữ lại.

---

## TC-12-016: Thoát màn hình đính tem khi chưa chọn tem — không cần xác nhận

**AC liên quan:** Mục 5 — thoát app giữa chừng
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang ở bước đính tem và chưa chọn tem nào.

### Act (Thực hiện)
- Nhấn nút quay lại / thoát màn hình đính tem.

### Assert (Kiểm tra)
- Hệ thống cho phép thoát mà không hiển thị hộp thoại xác nhận (vì chưa có thay đổi tem).
- Nội dung thư đang soạn được giữ lại.

---

## TC-12-017: Mở lại app sau khi tắt giữa chừng — tiếp tục từ bước đính tem

**AC liên quan:** Mục 5 — Nhóm 3
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đang ở bước đính tem, đã đính một tem, rồi tắt app đột ngột (hoặc nhấn Home).

### Act (Thực hiện)
- Mở lại app.

### Assert (Kiểm tra)
- Thư đang soạn được khôi phục.
- Tem đã đính được giữ lại.
- Người dùng có thể tiếp tục từ bước đính tem.

---

## TC-12-018: Người dùng chưa đăng nhập — chuyển đến màn hình đăng nhập

**AC liên quan:** Mục 5 — Nhóm 3
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng chưa đăng nhập vào ứng dụng.

### Act (Thực hiện)
- Cố vào bước đính tem.

### Assert (Kiểm tra)
- Hệ thống tự động chuyển hướng đến màn hình đăng nhập.
- Không có chế độ khách (guest) cho bước này.

---

## TC-12-019: Đính đúng một tem — chuyển được sang bước xem trước

**AC liên quan:** AC-03, BR-05, BR-04
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang ở bước đính tem và đã đính đúng một tem.

### Act (Thực hiện)
- Nhấn nút "Tiếp tục".

### Assert (Kiểm tra)
- Hệ thống chuyển sang bước xem trước thư (SM-015).
- Xem trước hiển thị toàn bộ thư kèm tem đã đính.

---

## TC-12-020: Xem trước tổng thể sau khi đính nhiều tem

**AC liên quan:** BR-04
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đính hai tem lên thư.

### Act (Thực hiện)
- Nhấn "Tiếp tục" để sang xem trước.

### Assert (Kiểm tra)
- Màn hình xem trước hiển thị toàn bộ thư kèm cả hai tem đã đính.

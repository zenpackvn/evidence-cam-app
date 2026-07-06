# Test Cases — Bộ tem mẫu (SM-035 / 029-bo-tem-mau)

## TC-29-001: Duyệt tem mẫu theo chủ đề — lọc đúng chủ đề

**AC liên quan:** AC-01
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập, đang ở màn hình Bộ tem mẫu
- Có ít nhất 2 chủ đề khác nhau (ví dụ: Sinh nhật, Tết)

### Act (Thực hiện)
- Chọn chủ đề "Sinh nhật"

### Assert (Kiểm tra)
- Chỉ hiển thị các tem thuộc chủ đề Sinh nhật
- Tem của các chủ đề khác bị ẩn khỏi danh sách

---

## TC-29-002: Duyệt tất cả chủ đề — hiển thị toàn bộ tem mẫu

**AC liên quan:** AC-01
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang xem Bộ tem mẫu và đang lọc theo một chủ đề cụ thể

### Act (Thực hiện)
- Chọn "Tất cả" hoặc bỏ chọn bộ lọc chủ đề hiện tại

### Assert (Kiểm tra)
- Hiển thị toàn bộ tem mẫu từ tất cả chủ đề

---

## TC-29-003: Xem trước chi tiết tem mẫu miễn phí — hiển thị thông tin đầy đủ

**AC liên quan:** AC-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang duyệt danh sách tem mẫu
- Có ít nhất một tem mẫu miễn phí

### Act (Thực hiện)
- Nhấn vào một tem mẫu miễn phí

### Assert (Kiểm tra)
- Tem hiển thị ở kích thước lớn
- Có nhãn "Tem mẫu"
- Hiển thị tên chủ đề
- Có nút "Lưu vào Album"

---

## TC-29-004: Xem trước chi tiết tem mẫu bị khóa — hiển thị thông tin mở khóa

**AC liên quan:** AC-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Có ít nhất một tem mẫu cần Dấu để mở khóa

### Act (Thực hiện)
- Nhấn vào tem mẫu bị khóa đó

### Assert (Kiểm tra)
- Tem hiển thị ở kích thước lớn với nhãn "Tem mẫu"
- Hiển thị tên chủ đề
- Hiển thị giá Dấu cần để mở khóa (ví dụ: "30📮")
- Có nút mở khóa thay vì "Lưu vào Album"

---

## TC-29-005: Phóng to tem mẫu để xem chi tiết bằng hai ngón tay

**AC liên quan:** AC-03
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đang xem trước một tem mẫu ở kích thước lớn

### Act (Thực hiện)
- Banh 2 ngón tay lên tem (pinch-out)

### Assert (Kiểm tra)
- Tem phóng to theo cử chỉ ngón tay
- Chụm ngón tay (pinch-in) thu về kích thước ban đầu

---

## TC-29-006: Lưu tem mẫu miễn phí vào Album cá nhân

**AC liên quan:** AC-04
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang xem trước một tem mẫu miễn phí
- Album cá nhân chưa có tem này

### Act (Thực hiện)
- Nhấn "Lưu vào Album"

### Assert (Kiểm tra)
- Hiển thị thông báo xác nhận "Đã lưu vào Album"
- Tem xuất hiện trong Album cá nhân (SM-022) với nhãn "Tem mẫu"

---

## TC-29-007: Lưu lại tem đã có trong Album — không tạo bản sao

**AC liên quan:** AC-05
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã lưu một tem mẫu vào Album trước đó (ví dụ: tem "Hoa đào")

### Act (Thực hiện)
- Tìm lại tem đó trong Bộ tem mẫu
- Nhấn "Lưu vào Album" lần thứ hai

### Assert (Kiểm tra)
- Hệ thống thông báo "Tem này đã có trong Album của bạn"
- Album không tạo thêm bản sao mới của tem

---

## TC-29-008: Mở khóa tem mẫu bằng Dấu — đủ Dấu, xác nhận thành công

**AC liên quan:** AC-06
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng có số Dấu >= giá mở khóa của tem (ví dụ: có 50📮, tem cần 30📮)
- Tem mẫu đang ở trạng thái bị khóa

### Act (Thực hiện)
- Nhấn vào tem mẫu bị khóa
- Nhấn "Mở khóa — 30📮"
- Xác nhận hành động

### Assert (Kiểm tra)
- Tem được mở khóa vĩnh viễn
- Số Dấu giảm đúng số lượng tương ứng (ví dụ: còn 20📮)
- Nút chuyển thành "Lưu vào Album"

---

## TC-29-009: Mở khóa tem mẫu — không đủ Dấu

**AC liên quan:** AC-07
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng chỉ có 10📮
- Tem mẫu cần 30📮 để mở khóa

### Act (Thực hiện)
- Nhấn "Mở khóa" trên tem mẫu đó

### Assert (Kiểm tra)
- Hiển thị số Dấu còn thiếu (ví dụ: "Bạn cần thêm 20📮 nữa")
- Có hai lựa chọn: "Chia sẻ tem để kiếm Dấu" và "Nạp Dấu"
- Tem không được mở khóa
- Số Dấu không thay đổi (vẫn 10📮)

---

## TC-29-010: Tem mẫu đã lưu dùng được khi đính lên thư mới

**AC liên quan:** AC-08
**Loại:** Integration
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã lưu ít nhất một tem mẫu vào Album cá nhân

### Act (Thực hiện)
- Soạn thư mới, vào bước đính tem (SM-014)
- Mở tab "Tất cả" trong Album

### Assert (Kiểm tra)
- Tem mẫu đã lưu xuất hiện trong tab "Tất cả" với nhãn "Tem mẫu"
- Có thể chọn và đính tem lên thư như tem thường

---

## TC-29-011: Tem mới gắn nhãn "Mới" khi ra mắt

**AC liên quan:** AC-09
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- StampMail vừa bổ sung bộ tem Tết mới
- Người dùng chưa mở Bộ tem mẫu kể từ khi bộ tem mới được thêm

### Act (Thực hiện)
- Mở Bộ tem mẫu

### Assert (Kiểm tra)
- Các tem mới trong bộ Tết có nhãn "Mới" hiển thị rõ ràng trên ảnh tem
- Tem cũ không có nhãn "Mới"

---

## TC-29-012: Duyệt tem đã tải khi mất mạng — thông báo ngoại tuyến

**AC liên quan:** AC-10
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã mở Bộ tem mẫu khi còn kết nối mạng (các tem đã được tải về)
- Tắt kết nối internet trên thiết bị

### Act (Thực hiện)
- Mở lại màn hình Bộ tem mẫu

### Assert (Kiểm tra)
- Các tem đã tải trước đó vẫn hiển thị được
- Thông báo "Đang xem ngoại tuyến" xuất hiện ở đầu màn hình
- Người dùng có thể duyệt bình thường các tem đã tải

---

## TC-29-013: Lưu và mở khóa bị chặn khi mất mạng

**AC liên quan:** AC-11
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đang xem một tem mẫu (miễn phí hoặc có Dấu để mở khóa)
- Thiết bị không có kết nối mạng

### Act (Thực hiện)
- Nhấn "Lưu vào Album" (hoặc "Mở khóa")

### Assert (Kiểm tra)
- Hành động không được thực hiện
- Hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."
- Số Dấu không thay đổi

---

## TC-29-014: Mở khóa bị chặn khi mất mạng — Dấu không bị trừ

**AC liên quan:** AC-11, BR-09
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng có đủ Dấu để mở khóa một tem mẫu
- Ghi nhớ số Dấu hiện tại
- Tắt kết nối internet

### Act (Thực hiện)
- Nhấn "Mở khóa" trên tem mẫu bị khóa
- Xác nhận nếu hệ thống hỏi

### Assert (Kiểm tra)
- Tem không được mở khóa
- Hiển thị thông báo lỗi kết nối
- Số Dấu giữ nguyên như trước khi nhấn

---

## TC-29-015: Tem chưa tải về không hiển thị được khi mất mạng — hiện placeholder

**AC liên quan:** BR-08, Mục 5
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Có các tem mẫu chưa từng được tải về trên thiết bị này
- Thiết bị không có kết nối mạng

### Act (Thực hiện)
- Mở Bộ tem mẫu và cuộn đến khu vực tem chưa tải

### Assert (Kiểm tra)
- Vị trí các tem chưa tải hiển thị ảnh giữ chỗ (placeholder)
- Không để vị trí trống hoàn toàn

---

## TC-29-016: Tải lại khi toàn bộ bộ tem không tải được

**AC liên quan:** Mục 5
**Loại:** E2E
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Mạng gặp sự cố hoặc máy chủ trả về lỗi khi tải bộ tem

### Act (Thực hiện)
- Mở màn hình Bộ tem mẫu

### Assert (Kiểm tra)
- Màn hình hiển thị biểu tượng lỗi kèm thông báo "Không thể tải bộ tem. Vui lòng thử lại."
- Có nút "Thử lại"
- Nhấn "Thử lại" → hệ thống tải lại bộ tem

---

## TC-29-017: Chủ đề không tải được — hiển thị lỗi tại chỗ và nút thử lại

**AC liên quan:** Mục 5
**Loại:** E2E
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Một chủ đề cụ thể gặp lỗi khi tải (các chủ đề khác vẫn tải bình thường)

### Act (Thực hiện)
- Mở Bộ tem mẫu và chọn chủ đề bị lỗi

### Assert (Kiểm tra)
- Trong thời gian đang tải, khu vực đó hiển thị khung giữ chỗ (skeleton)
- Sau khi hết thời gian chờ, khu vực đó hiển thị thông báo lỗi và nút "Thử lại" ngay tại chỗ
- Các chủ đề khác không bị ảnh hưởng

---

## TC-29-018: Chủ đề mới chưa có tem — hiển thị "Sắp ra mắt"

**AC liên quan:** Mục 5
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Có một chủ đề mới được tạo nhưng chưa có tem nào

### Act (Thực hiện)
- Chọn chủ đề đó

### Assert (Kiểm tra)
- Hiển thị trạng thái "Sắp ra mắt" thay vì danh sách trống

---

## TC-29-019: Chưa đăng nhập — nhấn "Lưu vào Album" chuyển sang đăng nhập

**AC liên quan:** Mục 5
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng chưa đăng nhập vào ứng dụng
- Đang xem một tem mẫu cụ thể

### Act (Thực hiện)
- Nhấn "Lưu vào Album"

### Assert (Kiểm tra)
- Hệ thống chuyển hướng sang màn hình đăng nhập (SM-001)
- Sau khi đăng nhập, tem đang xem vẫn được giữ nguyên (người dùng quay về đúng tem đó)

---

## TC-29-020: Tem mẫu không thể chỉnh sửa — không có nút Chỉnh sửa

**AC liên quan:** BR-04
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã lưu một tem mẫu vào Album cá nhân
- Mở Album cá nhân (SM-022)

### Act (Thực hiện)
- Nhấn vào tem mẫu đã lưu
- Quan sát các tùy chọn hiển thị

### Assert (Kiểm tra)
- Không có nút "Chỉnh sửa" hoặc tùy chọn thay đổi thiết kế tem mẫu

---

## TC-29-021: Tem mẫu trong Album có nhãn phân biệt với tem cá nhân

**AC liên quan:** BR-01, AC-04
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã lưu ít nhất 1 tem mẫu vào Album
- Album cũng có ít nhất 1 tem cá nhân do người dùng tự tạo

### Act (Thực hiện)
- Mở Album cá nhân (SM-022), tab "Tất cả"

### Assert (Kiểm tra)
- Tem mẫu hiển thị nhãn "Tem mẫu" rõ ràng
- Tem cá nhân không có nhãn "Tem mẫu"

---

## TC-29-022: Thoát app khi đang xem tem mẫu — không mất dữ liệu

**AC liên quan:** Mục 5
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đang xem chi tiết một tem mẫu cụ thể

### Act (Thực hiện)
- Thoát ứng dụng (vuốt đóng hoặc nhấn nút Home)
- Mở lại ứng dụng

### Assert (Kiểm tra)
- Không có dữ liệu nào bị mất
- Màn hình Bộ tem mẫu trở về trạng thái mặc định (danh sách chủ đề), không khôi phục tem đang xem dở

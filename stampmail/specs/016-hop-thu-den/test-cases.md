# Test Cases — Hộp thư đến (SM-018) (016-hop-thu-den)

## TC-16-001: Danh sách thư sắp xếp theo thời gian mới nhất trước

**AC liên quan:** AC-01
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào tài khoản StampMail
- Hộp thư có ít nhất 3 thư nhận vào các thời điểm khác nhau (thư A nhận lúc 08:00, thư B nhận lúc 10:00, thư C nhận lúc 14:00 cùng ngày)

### Act (Thực hiện)
- Người dùng mở màn hình Hộp thư đến

### Assert (Kiểm tra)
- Thư C (nhận lúc 14:00) hiển thị ở vị trí đầu tiên trong danh sách
- Thư B (nhận lúc 10:00) hiển thị ở vị trí thứ hai
- Thư A (nhận lúc 08:00) hiển thị ở vị trí thứ ba

---

## TC-16-002: Thông tin hiển thị đầy đủ cho mỗi thư trong danh sách

**AC liên quan:** AC-01 (BR-02)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào tài khoản StampMail
- Hộp thư có ít nhất một thư đã nhận

### Act (Thực hiện)
- Người dùng mở màn hình Hộp thư đến và quan sát mục thư đầu tiên

### Assert (Kiểm tra)
- Ảnh nhỏ của tem hiển thị trên mục thư
- Tên người gửi hiển thị trên mục thư
- Thời gian nhận hiển thị trên mục thư
- Trạng thái đọc/chưa đọc hiển thị trên mục thư

---

## TC-16-003: Lọc danh sách theo "Chưa đọc"

**AC liên quan:** AC-02 (BR-03)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào tài khoản StampMail
- Hộp thư có cả thư đã đọc (ít nhất 1) và thư chưa đọc (ít nhất 1)

### Act (Thực hiện)
- Người dùng mở màn hình Hộp thư đến
- Người dùng nhấn vào bộ lọc "Chưa đọc"

### Assert (Kiểm tra)
- Chỉ các thư chưa đọc hiển thị trong danh sách
- Không có thư đã đọc nào xuất hiện trong danh sách
- Bộ lọc "Chưa đọc" đang được chọn (trạng thái active)

---

## TC-16-004: Lọc danh sách theo "Đã đọc"

**AC liên quan:** AC-02 (BR-03)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào tài khoản StampMail
- Hộp thư có cả thư đã đọc (ít nhất 1) và thư chưa đọc (ít nhất 1)

### Act (Thực hiện)
- Người dùng mở màn hình Hộp thư đến
- Người dùng nhấn vào bộ lọc "Đã đọc"

### Assert (Kiểm tra)
- Chỉ các thư đã đọc hiển thị trong danh sách
- Không có thư chưa đọc nào xuất hiện trong danh sách
- Bộ lọc "Đã đọc" đang được chọn (trạng thái active)

---

## TC-16-005: Bộ lọc "Tất cả" hiển thị toàn bộ thư

**AC liên quan:** AC-02 (BR-03)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào tài khoản StampMail
- Hộp thư có cả thư đã đọc và thư chưa đọc
- Người dùng đang ở bộ lọc "Chưa đọc" hoặc "Đã đọc"

### Act (Thực hiện)
- Người dùng nhấn vào bộ lọc "Tất cả"

### Assert (Kiểm tra)
- Toàn bộ thư (cả đã đọc lẫn chưa đọc) hiển thị trong danh sách
- Bộ lọc "Tất cả" đang được chọn (trạng thái active)

---

## TC-16-006: Mở thư từ danh sách — chuyển sang màn hình SM-019

**AC liên quan:** AC-03
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào tài khoản StampMail
- Hộp thư có ít nhất một thư

### Act (Thực hiện)
- Người dùng mở màn hình Hộp thư đến
- Người dùng nhấn vào một thư trong danh sách

### Assert (Kiểm tra)
- Màn hình mở thư (SM-019) được hiển thị
- Animation chuyển màn hình diễn ra đúng như thiết kế
- Nội dung thư tương ứng được hiển thị trên màn hình SM-019

---

## TC-16-007: Thư đã đọc vẫn tồn tại trong danh sách sau nhiều ngày

**AC liên quan:** AC-04 (BR-04)
**Loại:** E2E
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào tài khoản StampMail
- Người dùng đã đọc ít nhất một thư (thư X) vào ngày hôm trước

### Act (Thực hiện)
- Người dùng mở lại ứng dụng StampMail sau nhiều ngày (ít nhất 1 ngày)
- Người dùng mở màn hình Hộp thư đến

### Assert (Kiểm tra)
- Thư X vẫn xuất hiện trong danh sách Hộp thư đến
- Thư X hiển thị với trạng thái "Đã đọc"
- Nội dung thư X vẫn có thể mở và xem lại

---

## TC-16-008: Xem danh sách thư khi mất mạng — hiển thị cache và thông báo ngoại tuyến

**AC liên quan:** AC-05 (BR-05, BR-06)
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào tài khoản StampMail
- Hộp thư đã tải thành công ít nhất một lần khi có mạng (có dữ liệu cache)
- Thiết bị đang kết nối mạng

### Act (Thực hiện)
- Tắt kết nối internet trên thiết bị (bật chế độ máy bay hoặc tắt WiFi/dữ liệu di động)
- Người dùng mở màn hình Hộp thư đến (hoặc điều hướng lại vào hộp thư)

### Assert (Kiểm tra)
- Danh sách thư đã tải từ lần truy cập trước vẫn hiển thị đầy đủ
- Thông báo ngoại tuyến hiển thị rõ ràng: "Đang xem ngoại tuyến — danh sách có thể chưa cập nhật mới nhất"
- Không xuất hiện màn hình trắng hoặc màn hình lỗi

---

## TC-16-009: Vô hiệu hoá kéo làm mới danh sách khi không có mạng

**AC liên quan:** AC-06 (BR-07)
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào tài khoản StampMail
- Hộp thư đã có dữ liệu cache từ lần truy cập trước
- Thiết bị không có kết nối internet

### Act (Thực hiện)
- Người dùng mở màn hình Hộp thư đến
- Người dùng thực hiện thao tác kéo xuống (pull-to-refresh) để làm mới danh sách

### Assert (Kiểm tra)
- Danh sách không tải thêm thư mới (không có cập nhật nào xảy ra)
- Hệ thống hiển thị thông báo yêu cầu có kết nối mạng để cập nhật
- Danh sách cache hiện tại vẫn giữ nguyên, không bị xoá hay thay đổi

---

## TC-16-010: Hộp thư trống — hiển thị trạng thái rỗng thân thiện

**AC liên quan:** Mục 5 — trường hợp ngoại lệ (hộp thư trống)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào tài khoản StampMail mới, chưa có thư nào trong hộp thư

### Act (Thực hiện)
- Người dùng mở màn hình Hộp thư đến

### Assert (Kiểm tra)
- Danh sách thư không hiển thị bất kỳ mục thư nào
- Thông báo trạng thái rỗng được hiển thị với lời nhắn thân thiện (ví dụ: "Hộp thư trống — chia sẻ StampMail để nhận thư đầu tiên")
- Không có lỗi hay màn hình trắng

---

## TC-16-011: Lỗi mạng/máy chủ — có cache: hiển thị danh sách cache và nút Thử lại

**AC liên quan:** Mục 5 — trường hợp ngoại lệ (lỗi mạng hoặc máy chủ không phản hồi, có cache)
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào tài khoản StampMail
- Hộp thư đã tải thành công ít nhất một lần (có dữ liệu cache)
- Máy chủ không phản hồi (ví dụ: giả lập lỗi server hoặc tắt kết nối khi đang tải mới)

### Act (Thực hiện)
- Người dùng mở màn hình Hộp thư đến trong khi máy chủ không phản hồi

### Assert (Kiểm tra)
- Danh sách thư từ cache vẫn hiển thị
- Thông báo lỗi xuất hiện (thông báo không thể tải dữ liệu mới)
- Nút "Thử lại" hiển thị để người dùng có thể tải lại

---

## TC-16-012: Lỗi mạng/máy chủ — chưa có cache: hiển thị màn hình lỗi và nút Thử lại

**AC liên quan:** Mục 5 — trường hợp ngoại lệ (lỗi mạng hoặc máy chủ không phản hồi, không có cache)
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào tài khoản StampMail mới (chưa có dữ liệu cache)
- Máy chủ không phản hồi hoặc thiết bị không có kết nối internet

### Act (Thực hiện)
- Người dùng mở màn hình Hộp thư đến

### Assert (Kiểm tra)
- Màn hình lỗi được hiển thị (không hiển thị danh sách thư hay trạng thái rỗng bình thường)
- Nút "Thử lại" hiển thị để người dùng có thể thử tải lại
- Không có lỗi crash hay màn hình trắng

---

## TC-16-013: Chưa đăng nhập — tự động chuyển về màn hình đăng nhập

**AC liên quan:** Mục 5 — trường hợp ngoại lệ (chưa đăng nhập)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng chưa đăng nhập vào tài khoản StampMail (hoặc đã đăng xuất)

### Act (Thực hiện)
- Người dùng cố gắng truy cập vào màn hình Hộp thư đến (ví dụ: qua deep link hoặc điều hướng thủ công)

### Assert (Kiểm tra)
- Hệ thống lập tức chuyển người dùng về màn hình đăng nhập (SM-001)
- Không hiển thị bất kỳ nội dung nào của hộp thư đến
- Không có lỗi crash

---

## TC-16-014: Thoát app giữa chừng — mở lại vẫn có cache và tự tải mới khi có mạng

**AC liên quan:** Mục 5 — trường hợp ngoại lệ (thoát app giữa chừng)
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào tài khoản StampMail
- Người dùng đã mở hộp thư đến và có dữ liệu cache

### Act (Thực hiện)
- Người dùng thoát ứng dụng đột ngột (ép buộc đóng app từ trình quản lý ứng dụng)
- Người dùng mở lại ứng dụng StampMail và điều hướng vào Hộp thư đến (thiết bị có kết nối mạng)

### Assert (Kiểm tra)
- Hộp thư đến hiển thị lại danh sách thư đã cache từ lần trước
- Ứng dụng tự động tải cập nhật mới từ máy chủ (danh sách được làm mới nếu có thư mới)
- Không có lỗi crash hay dữ liệu bị mất

---

## TC-16-015: Danh sách thư nhiều mục — cuộn và thứ tự đúng

**AC liên quan:** AC-01 (BR-01)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào tài khoản StampMail
- Hộp thư có hơn 20 thư nhận vào các thời điểm khác nhau

### Act (Thực hiện)
- Người dùng mở màn hình Hộp thư đến
- Người dùng cuộn xuống cuối danh sách

### Assert (Kiểm tra)
- Danh sách cuộn được và hiển thị toàn bộ thư
- Thứ tự thời gian vẫn đúng (mới nhất ở đầu, cũ nhất ở cuối)
- Không có thư nào bị mất hoặc lặp lại

---

## TC-16-016: Bộ lọc "Chưa đọc" khi tất cả thư đã đọc — hiển thị rỗng

**AC liên quan:** AC-02 (BR-03) — trường hợp biên
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào tài khoản StampMail
- Hộp thư có thư nhưng tất cả đã được đọc (không có thư chưa đọc)

### Act (Thực hiện)
- Người dùng mở màn hình Hộp thư đến
- Người dùng nhấn vào bộ lọc "Chưa đọc"

### Assert (Kiểm tra)
- Danh sách rỗng (không có thư nào hiển thị)
- Trạng thái rỗng được hiển thị phù hợp (không có lỗi)

---

## TC-16-017: Chuyển đổi qua lại giữa các bộ lọc nhiều lần — kết quả luôn đúng

**AC liên quan:** AC-02 (BR-03) — trường hợp biên
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào tài khoản StampMail
- Hộp thư có cả thư đã đọc và thư chưa đọc

### Act (Thực hiện)
- Người dùng mở màn hình Hộp thư đến
- Người dùng lần lượt nhấn: "Chưa đọc" → "Đã đọc" → "Tất cả" → "Chưa đọc" (lặp lại nhiều lần)

### Assert (Kiểm tra)
- Mỗi lần chuyển bộ lọc, danh sách hiển thị đúng theo bộ lọc đang được chọn
- Không có thư bị lẫn sang danh sách sai bộ lọc
- Không có lỗi giao diện hoặc danh sách bị trùng

---

## TC-16-018: Hai thư nhận gần như cùng lúc — thứ tự sắp xếp chính xác

**AC liên quan:** AC-01 (BR-01) — trường hợp biên
**Loại:** E2E
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào tài khoản StampMail
- Hộp thư có hai thư được gửi gần như cùng lúc (cách nhau vài giây)

### Act (Thực hiện)
- Người dùng mở màn hình Hộp thư đến

### Assert (Kiểm tra)
- Thư được gửi sau (thời điểm muộn hơn) hiển thị ở trên thư được gửi trước
- Không có trường hợp thứ tự bị đảo ngược hay không xác định

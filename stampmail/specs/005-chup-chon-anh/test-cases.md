# Test Cases — Chụp / Chọn ảnh (005-chup-chon-anh)

## TC-05-001: Chụp ảnh mới thành công

**AC liên quan:** AC-01
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Thiết bị có camera hoạt động
- Người dùng đã cấp quyền truy cập camera cho ứng dụng

### Act (Thực hiện)
- Nhấn nút "Tạo tem" trên thanh điều hướng hoặc gợi ý trên màn hình chính
- Trên màn hình chụp/chọn ảnh, nhấn "Chụp ảnh"
- Camera của thiết bị mở ra
- Chụp một bức ảnh bất kỳ (người, vật, phong cảnh, đồ vật)
- Xác nhận ảnh vừa chụp

### Assert (Kiểm tra)
- Màn hình xem trước ảnh hiển thị ảnh vừa chụp
- Sau khi nhấn "Xác nhận", app tự động chuyển sang màn hình bộ lọc màu (SM-006)
- Ảnh vừa chụp được hiển thị làm ảnh gốc ở bước bộ lọc màu
- Không còn ở màn hình chụp/chọn ảnh

---

## TC-05-002: Chọn ảnh từ thư viện thành công

**AC liên quan:** AC-02
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Thư viện ảnh điện thoại có ít nhất một ảnh
- Người dùng đã cấp quyền truy cập thư viện ảnh cho ứng dụng

### Act (Thực hiện)
- Nhấn nút "Tạo tem" trên thanh điều hướng hoặc gợi ý trên màn hình chính
- Trên màn hình chụp/chọn ảnh, nhấn "Chọn từ thư viện"
- Thư viện ảnh của thiết bị mở ra
- Chọn một ảnh bất kỳ từ thư viện

### Assert (Kiểm tra)
- Màn hình xem trước ảnh hiển thị ảnh vừa chọn
- Sau khi nhấn "Xác nhận", app tự động chuyển sang màn hình bộ lọc màu (SM-006)
- Ảnh vừa chọn được hiển thị làm ảnh gốc ở bước bộ lọc màu
- Không còn ở màn hình chụp/chọn ảnh

---

## TC-05-003: Từ chối ảnh có kích thước vượt giới hạn tối đa

**AC liên quan:** AC-03
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Chuẩn bị một ảnh có kích thước file vượt quá giới hạn tối đa cho phép
- Người dùng đã cấp quyền truy cập thư viện ảnh cho ứng dụng

### Act (Thực hiện)
- Nhấn nút "Tạo tem" trên thanh điều hướng hoặc gợi ý trên màn hình chính
- Nhấn "Chọn từ thư viện"
- Chọn ảnh có kích thước vượt giới hạn tối đa từ thư viện
- Xác nhận ảnh đã chọn

### Assert (Kiểm tra)
- App không chuyển sang màn hình bộ lọc màu (SM-006)
- Hiển thị thông báo lỗi rõ ràng rằng ảnh quá lớn
- Thông báo yêu cầu người dùng chọn ảnh khác nhỏ hơn
- Người dùng có thể tiếp tục thao tác chọn ảnh khác mà không cần khởi động lại luồng

---

## TC-05-004: Yêu cầu cấp quyền camera khi chưa có quyền

**AC liên quan:** AC-04
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Ứng dụng chưa được cấp quyền truy cập camera (quyền bị từ chối hoặc chưa được hỏi)

### Act (Thực hiện)
- Nhấn nút "Tạo tem" trên thanh điều hướng hoặc gợi ý trên màn hình chính
- Nhấn "Chụp ảnh" trên màn hình chụp/chọn ảnh

### Assert (Kiểm tra)
- Hệ thống hiển thị hộp thoại xin cấp quyền camera từ hệ điều hành (iOS/Android)
- Sau khi người dùng cấp quyền, camera được mở bình thường

---

## TC-05-005: Yêu cầu cấp quyền thư viện ảnh khi chưa có quyền

**AC liên quan:** AC-04
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Ứng dụng chưa được cấp quyền truy cập thư viện ảnh (quyền bị từ chối hoặc chưa được hỏi)

### Act (Thực hiện)
- Nhấn nút "Tạo tem" trên thanh điều hướng hoặc gợi ý trên màn hình chính
- Nhấn "Chọn từ thư viện" trên màn hình chụp/chọn ảnh

### Assert (Kiểm tra)
- Hệ thống hiển thị hộp thoại xin cấp quyền thư viện ảnh từ hệ điều hành (iOS/Android)
- Sau khi người dùng cấp quyền, thư viện ảnh được mở bình thường

---

## TC-05-006: Phóng to ảnh xem trước bằng thao tác banh hai ngón tay

**AC liên quan:** AC-05
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Người dùng đã chọn hoặc chụp một ảnh và đang ở màn hình xem trước ảnh

### Act (Thực hiện)
- Đặt hai ngón tay lên màn hình ảnh xem trước
- Banh hai ngón tay ra (thao tác phóng to)

### Assert (Kiểm tra)
- Ảnh phóng to theo hướng banh của ngón tay
- Sau khi phóng to, người dùng có thể kéo ảnh để xem các vùng khác nhau của ảnh
- Ảnh không bị vỡ hoặc mờ khi phóng to

---

## TC-05-007: Thu nhỏ ảnh xem trước về toàn khung bằng thao tác chụm hai ngón tay

**AC liên quan:** AC-08
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Người dùng đang ở màn hình xem trước ảnh và đã phóng to ảnh

### Act (Thực hiện)
- Đặt hai ngón tay lên màn hình ảnh đã phóng to
- Chụm hai ngón tay lại (thao tác thu nhỏ)
- Tiếp tục chụm cho đến khi ảnh thu nhỏ đến mức tối thiểu

### Assert (Kiểm tra)
- Ảnh thu nhỏ dần theo thao tác chụm
- Ảnh dừng lại ở mức vừa khung màn hình — không thu nhỏ hơn mức hiển thị toàn ảnh
- Ảnh không bị thu nhỏ xuống dưới kích thước toàn ảnh vừa khung

---

## TC-05-008: Chạm hai lần nhanh để phóng to vùng ảnh

**AC liên quan:** AC-09
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Người dùng đang ở màn hình xem trước ảnh (ảnh đang ở trạng thái toàn khung)

### Act (Thực hiện)
- Chạm hai lần nhanh (double-tap) vào một vùng bất kỳ trên ảnh

### Assert (Kiểm tra)
- Ảnh phóng to vào đúng vùng vừa chạm
- Thao tác phóng to diễn ra mượt mà, không giật lag

---

## TC-05-009: Chạm hai lần nhanh lần nữa để trở về toàn ảnh

**AC liên quan:** AC-09
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Người dùng đang ở màn hình xem trước ảnh và ảnh đang ở trạng thái phóng to (đã double-tap lần 1)

### Act (Thực hiện)
- Chạm hai lần nhanh (double-tap) lần nữa vào ảnh đang phóng to

### Assert (Kiểm tra)
- Ảnh trở về trạng thái toàn ảnh vừa khung màn hình
- Thao tác thu nhỏ diễn ra mượt mà

---

## TC-05-010: Ảnh gốc không thay đổi sau nhiều lần phóng to / thu nhỏ rồi xác nhận

**AC liên quan:** AC-10
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Người dùng đang ở màn hình xem trước ảnh với một ảnh đã chọn/chụp

### Act (Thực hiện)
- Banh ngón tay phóng to ảnh nhiều lần
- Chụm ngón tay thu nhỏ ảnh nhiều lần
- Double-tap để phóng to một vùng
- Double-tap lần nữa để trở về toàn ảnh
- Nhấn "Xác nhận" để chuyển sang bước bộ lọc màu (SM-006)

### Assert (Kiểm tra)
- Ảnh hiển thị ở bước bộ lọc màu (SM-006) giống hệt ảnh gốc đã chọn/chụp ban đầu
- Ảnh không bị cắt xén
- Ảnh không bị thay đổi tỉ lệ
- Ảnh không bị biến dạng so với ảnh gốc

---

## TC-05-011: Chụp và chọn ảnh bình thường khi mất kết nối mạng

**AC liên quan:** AC-06
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Thiết bị không có kết nối mạng (tắt WiFi và dữ liệu di động)
- Thiết bị có camera và thư viện ảnh có ảnh

### Act (Thực hiện)
- Nhấn nút "Tạo tem" để mở màn hình chụp/chọn ảnh
- **Nhánh A — Chụp ảnh:** Nhấn "Chụp ảnh", chụp một ảnh và xác nhận
- **Nhánh B — Chọn từ thư viện:** Nhấn "Chọn từ thư viện" và chọn một ảnh

### Assert (Kiểm tra)
- Thao tác chụp ảnh (Nhánh A) hoàn thành bình thường, ảnh hiển thị trên màn hình xem trước
- Thao tác chọn ảnh từ thư viện (Nhánh B) hoàn thành bình thường, ảnh hiển thị trên màn hình xem trước
- App không hiển thị thông báo lỗi mạng ở bước này
- Màn hình xem trước hiển thị giống như khi có mạng

---

## TC-05-012: Thông báo rõ khi bước tiếp theo cần mạng nhưng đang offline

**AC liên quan:** AC-07
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Thiết bị không có kết nối mạng (tắt WiFi và dữ liệu di động)
- Người dùng đã chọn hoặc chụp ảnh thành công và đang ở màn hình xem trước

### Act (Thực hiện)
- Nhấn "Xác nhận" để chuyển sang bước tiếp theo (SM-006)
- Hệ thống phát hiện bước tiếp theo yêu cầu kết nối mạng

### Assert (Kiểm tra)
- Hệ thống hiển thị thông báo rõ ràng rằng cần có kết nối mạng để tiếp tục
- Ảnh đã chọn/chụp vẫn được giữ nguyên trên màn hình xem trước
- Người dùng không cần chọn lại ảnh từ đầu sau khi có mạng
- App không bị crash

---

## TC-05-013: Xử lý khi người dùng từ chối quyền camera

**AC liên quan:** AC-04 (trường hợp ngoại lệ — mục 5)
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Ứng dụng chưa được cấp quyền camera

### Act (Thực hiện)
- Nhấn "Tạo tem" và mở màn hình chụp/chọn ảnh
- Nhấn "Chụp ảnh"
- Hộp thoại xin quyền camera từ hệ điều hành xuất hiện
- Nhấn "Từ chối" / "Deny" / "Không cho phép" trên hộp thoại

### Assert (Kiểm tra)
- App hiển thị thông báo rõ ràng rằng quyền camera bị từ chối
- Thông báo hướng dẫn người dùng vào cài đặt thiết bị để cấp quyền thủ công
- Tùy chọn "Chọn từ thư viện" vẫn hiển thị và có thể nhấn được
- App không bị crash hoặc treo

---

## TC-05-014: Xử lý khi người dùng từ chối quyền thư viện ảnh

**AC liên quan:** AC-04 (trường hợp ngoại lệ — mục 5)
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Ứng dụng chưa được cấp quyền thư viện ảnh

### Act (Thực hiện)
- Nhấn "Tạo tem" và mở màn hình chụp/chọn ảnh
- Nhấn "Chọn từ thư viện"
- Hộp thoại xin quyền thư viện ảnh từ hệ điều hành xuất hiện
- Nhấn "Từ chối" / "Deny" / "Không cho phép" trên hộp thoại

### Assert (Kiểm tra)
- App hiển thị thông báo rõ ràng rằng quyền thư viện ảnh bị từ chối
- Thông báo hướng dẫn người dùng vào cài đặt thiết bị để cấp quyền thủ công
- Tùy chọn "Chụp ảnh" vẫn hiển thị và có thể nhấn được
- App không bị crash hoặc treo

---

## TC-05-015: Ẩn tùy chọn chụp ảnh trên thiết bị không có camera

**AC liên quan:** BR-01 (trường hợp ngoại lệ — mục 5)
**Loại:** E2E
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Sử dụng thiết bị không có camera (ví dụ: máy tính bảng hoặc thiết bị ảo không có camera)

### Act (Thực hiện)
- Nhấn nút "Tạo tem" trên thanh điều hướng hoặc gợi ý trên màn hình chính
- Màn hình chụp/chọn ảnh được mở

### Assert (Kiểm tra)
- Tùy chọn "Chụp ảnh" không hiển thị trên màn hình
- Chỉ hiển thị tùy chọn "Chọn từ thư viện"
- Người dùng vẫn có thể tiếp tục tạo tem bằng cách chọn ảnh từ thư viện

---

## TC-05-016: Thoát màn hình giữa chừng — không lưu ảnh

**AC liên quan:** BR-04 (trường hợp ngoại lệ — mục 5)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Màn hình chụp/chọn ảnh đang mở (chưa chọn hoặc chụp ảnh nào)

### Act (Thực hiện)
- Nhấn nút "Tạo tem" và mở màn hình chụp/chọn ảnh
- Nhấn nút quay lại / đóng màn hình mà không chọn hoặc chụp ảnh nào

### Assert (Kiểm tra)
- App quay về màn hình chính (SM-004)
- Không có ảnh nào được lưu hoặc chuyển sang bước bộ lọc màu
- Trạng thái màn hình chính không thay đổi

---

## TC-05-017: Hai nguồn ảnh hiển thị đúng trên màn hình

**AC liên quan:** BR-01
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Thiết bị có camera

### Act (Thực hiện)
- Nhấn nút "Tạo tem" trên thanh điều hướng hoặc gợi ý trên màn hình chính

### Assert (Kiểm tra)
- Màn hình chụp/chọn ảnh hiển thị đúng hai tùy chọn: "Chụp ảnh" và "Chọn từ thư viện"
- Cả hai tùy chọn đều có thể nhấn được
- Không có tùy chọn nào khác gây nhầm lẫn

---

## TC-05-018: Lỗi máy chủ sau khi đã có mạng — giữ nguyên ảnh và cho thử lại

**AC liên quan:** BR-07 (trường hợp ngoại lệ — mục 5)
**Loại:** E2E
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Thiết bị có kết nối mạng nhưng máy chủ đang gặp sự cố (lỗi phản hồi từ máy chủ)
- Người dùng đã chọn hoặc chụp ảnh thành công và đang ở màn hình xem trước

### Act (Thực hiện)
- Nhấn "Xác nhận" để chuyển sang bước tiếp theo (SM-006)
- Bước tiếp theo trả về lỗi từ máy chủ

### Assert (Kiểm tra)
- Hệ thống hiển thị thông báo lỗi kèm nút "Thử lại"
- Ảnh đã chọn/chụp được giữ nguyên trên màn hình
- Người dùng không cần chọn lại ảnh từ đầu
- Nhấn "Thử lại" sẽ gửi lại yêu cầu mà không cần chọn ảnh lại

---

## TC-05-019: Khôi phục ảnh đã chọn khi mở lại app sau khi thoát giữa chừng

**AC liên quan:** BR-04 (trường hợp ngoại lệ — mục 5)
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Người dùng đã chọn/chụp ảnh và đang ở màn hình xem trước (chưa nhấn "Xác nhận")

### Act (Thực hiện)
- Thoát hoàn toàn khỏi app (không phải chỉ chuyển sang app khác)
- Mở lại ứng dụng StampMail

### Assert (Kiểm tra)
- App khôi phục đến màn hình xem trước ảnh
- Ảnh đã chọn/chụp vẫn còn đó, người dùng không cần chọn lại
- Người dùng có thể tiếp tục từ bước xem trước mà không mất công

---

## TC-05-020: Chưa đăng nhập — không thể truy cập tính năng chụp/chọn ảnh

**AC liên quan:** BR-01 (trường hợp ngoại lệ — mục 5)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng chưa đăng nhập vào ứng dụng StampMail

### Act (Thực hiện)
- Cố gắng truy cập tính năng tạo tem (nhấn nút "Tạo tem")

### Assert (Kiểm tra)
- App không mở màn hình chụp/chọn ảnh
- App chuyển người dùng đến màn hình đăng nhập
- Sau khi đăng nhập thành công, người dùng có thể tiếp tục tạo tem bình thường

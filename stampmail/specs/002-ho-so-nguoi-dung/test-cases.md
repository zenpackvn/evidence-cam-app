# Test Cases — Hồ sơ người dùng (002-ho-so-nguoi-dung)

## TC-02-001: Cập nhật ảnh đại diện thành công

**AC liên quan:** AC-01
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Đang ở màn hình hồ sơ cá nhân
- Thiết bị có ít nhất một ảnh trong thư viện ảnh

### Act (Thực hiện)
- Nhấn vào ảnh đại diện hoặc nút "Thay đổi ảnh đại diện"
- Chọn ảnh từ thư viện
- Sử dụng giao diện cắt ảnh để cắt thành hình vuông tỉ lệ 1:1
- Nhấn xác nhận lưu

### Assert (Kiểm tra)
- Ảnh đại diện mới hiển thị ngay tại màn hình hồ sơ
- Ảnh đại diện mới hiển thị đồng nhất ở mọi nơi trong ứng dụng (header, danh sách bạn bè, v.v.)
- Không hiển thị thông báo lỗi nào

---

## TC-02-002: Đổi tên hiển thị thành công

**AC liên quan:** AC-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Đang ở màn hình hồ sơ cá nhân

### Act (Thực hiện)
- Nhấn vào ô tên hiển thị hoặc nút chỉnh sửa tên
- Xóa tên hiển thị cũ
- Nhập tên hiển thị mới với tối đa 30 ký tự (ví dụ: "Nguyen Van An")
- Nhấn lưu

### Assert (Kiểm tra)
- Tên hiển thị mới "Nguyen Van An" xuất hiện ngay trên màn hình hồ sơ
- Tên cũ không còn xuất hiện
- Không hiển thị thông báo lỗi nào

---

## TC-02-003: Đổi username lần 2 thành công và nhận thông báo hết lượt

**AC liên quan:** AC-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Tài khoản chưa dùng lượt đổi username (vẫn còn 1 lượt)
- Đang ở màn hình hồ sơ cá nhân

### Act (Thực hiện)
- Nhấn vào ô username hoặc nút chỉnh sửa username
- Nhập username mới hợp lệ, chưa bị ai dùng (ví dụ: "new_username_test")
- Nhấn xác nhận

### Assert (Kiểm tra)
- Username được cập nhật thành "new_username_test"
- Hệ thống hiển thị thông báo đã hết lượt đổi username
- Trường username không còn cho phép chỉnh sửa (bị khoá)

---

## TC-02-004: Không cho đổi username khi đã hết lượt

**AC liên quan:** AC-04
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Tài khoản đã dùng hết 1 lượt đổi username (không còn lượt)
- Đang ở màn hình hồ sơ cá nhân

### Act (Thực hiện)
- Cố gắng nhấn vào ô username hoặc nút chỉnh sửa username

### Assert (Kiểm tra)
- Hệ thống hiển thị thông báo đã hết lượt đổi username
- Ô username không cho phép nhập liệu (bị khoá hoàn toàn)
- Username hiện tại không bị thay đổi

---

## TC-02-005: Ẩn thống kê với người dùng khác, chủ tài khoản vẫn thấy

**AC liên quan:** AC-05
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Tài khoản A đã đăng nhập, đang ở màn hình hồ sơ cá nhân
- Tài khoản B là tài khoản quan sát khác
- Tùy chọn ẩn thống kê của tài khoản A hiện đang tắt (thống kê công khai)

### Act (Thực hiện)
- Tài khoản A bật tùy chọn "Ẩn thống kê với người khác"
- Tài khoản B truy cập vào hồ sơ của tài khoản A
- Tài khoản A tự xem lại hồ sơ của mình

### Assert (Kiểm tra)
- Tài khoản B xem hồ sơ A: phần thống kê (tem đã tạo, thư đã gửi, thư đã nhận, bộ sưu tập hoàn chỉnh) không hiển thị
- Tài khoản A xem hồ sơ của mình: vẫn thấy đầy đủ bốn chỉ số thống kê

---

## TC-02-006: Nhập ngày sinh lần đầu thành công

**AC liên quan:** AC-06
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Đang ở màn hình hồ sơ cá nhân
- Chưa có ngày sinh trên hồ sơ

### Act (Thực hiện)
- Chọn điền ngày sinh
- Nhập ngày và tháng hợp lệ (ví dụ: ngày 15, tháng 8)
- Để trống hoặc bỏ qua ô năm sinh
- Nhấn lưu

### Assert (Kiểm tra)
- Ngày sinh được lưu và hiển thị trên hồ sơ của chính người dùng
- Không hiển thị thông báo lỗi

---

## TC-02-007: Nhập ngày sinh kèm năm sinh thành công

**AC liên quan:** AC-06
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Đang ở màn hình hồ sơ cá nhân
- Chưa có ngày sinh trên hồ sơ

### Act (Thực hiện)
- Chọn điền ngày sinh
- Nhập ngày, tháng và năm sinh hợp lệ (ví dụ: ngày 15, tháng 8, năm 1995)
- Nhấn lưu

### Assert (Kiểm tra)
- Ngày sinh được lưu và hiển thị trên hồ sơ của chính người dùng
- Không hiển thị thông báo lỗi

---

## TC-02-008: Xoá ngày sinh thành công

**AC liên quan:** AC-07
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Đã có ngày sinh trên hồ sơ
- Đang ở màn hình hồ sơ cá nhân

### Act (Thực hiện)
- Chọn xoá ngày sinh
- Xác nhận hành động xoá

### Assert (Kiểm tra)
- Trường ngày sinh trống
- Ngày sinh không còn hiển thị trên hồ sơ

---

## TC-02-009: Người dùng khác chỉ thấy ngày và tháng sinh khi được bật hiển thị

**AC liên quan:** AC-08
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Tài khoản A đã nhập ngày sinh đầy đủ (ngày, tháng, năm)
- Tài khoản A đã bật tùy chọn "Hiển thị ngày sinh với người khác"
- Tài khoản B là tài khoản quan sát khác

### Act (Thực hiện)
- Tài khoản B mở hồ sơ của tài khoản A

### Assert (Kiểm tra)
- Ngày và tháng sinh của tài khoản A hiển thị trên hồ sơ
- Năm sinh không xuất hiện dù tài khoản A đã nhập

---

## TC-02-010: Ngày sinh riêng tư theo mặc định

**AC liên quan:** AC-09
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Tài khoản A vừa nhập ngày sinh lần đầu (chưa thay đổi tùy chọn riêng tư)
- Tài khoản B là tài khoản quan sát khác

### Act (Thực hiện)
- Tài khoản B mở hồ sơ của tài khoản A ngay sau khi tài khoản A nhập ngày sinh

### Assert (Kiểm tra)
- Ngày sinh của tài khoản A không hiển thị trên hồ sơ khi tài khoản B xem
- Tùy chọn hiển thị ngày sinh mặc định là tắt (riêng tư)

---

## TC-02-011: Xem hồ sơ khi mất mạng — hiển thị dữ liệu cache và banner ngoại tuyến

**AC liên quan:** AC-10
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Đã mở và xem hồ sơ ít nhất một lần khi có mạng (dữ liệu đã được lưu cache)
- Sau đó tắt kết nối mạng (WiFi và dữ liệu di động)

### Act (Thực hiện)
- Mở lại màn hình hồ sơ cá nhân khi không có mạng

### Assert (Kiểm tra)
- Hồ sơ vẫn hiển thị: ảnh đại diện, tên hiển thị, username, các chỉ số thống kê theo dữ liệu đã tải lần cuối
- App hiển thị thông báo "Đang xem ngoại tuyến"
- Không có màn hình trắng hay lỗi toàn trang

---

## TC-02-012: Chặn lưu thay đổi khi mất mạng — giữ nguyên nội dung đang nhập

**AC liên quan:** AC-11
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Đang ở màn hình chỉnh sửa tên hiển thị và đã nhập tên mới nhưng chưa lưu
- Mất kết nối mạng trong lúc đang chỉnh sửa

### Act (Thực hiện)
- Nhấn nút lưu tên hiển thị mới

### Assert (Kiểm tra)
- App hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."
- Thay đổi không được lưu lên hệ thống
- Nội dung tên mới vừa nhập vẫn còn hiển thị trên ô nhập liệu (không bị xoá)

---

## TC-02-013: Chặn lưu ảnh đại diện khi mất mạng

**AC liên quan:** AC-11, BR-09
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Đang ở bước xác nhận ảnh đã cắt, chưa nhấn lưu
- Mất kết nối mạng trong lúc đang thực hiện

### Act (Thực hiện)
- Nhấn xác nhận lưu ảnh đại diện mới

### Assert (Kiểm tra)
- App thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."
- Ảnh đại diện cũ không bị thay đổi
- Ảnh mới vừa cắt vẫn hiển thị trong giao diện chờ lưu (không bị huỷ)

---

## TC-02-014: Chặn lưu ngày sinh và tùy chọn riêng tư khi mất mạng

**AC liên quan:** AC-11, BR-09
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Đang ở màn hình chỉnh sửa ngày sinh và đã nhập ngày sinh mới
- Mất kết nối mạng trong lúc đang chỉnh sửa

### Act (Thực hiện)
- Nhấn nút lưu ngày sinh

### Assert (Kiểm tra)
- App hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."
- Ngày sinh cũ không bị thay đổi
- Dữ liệu ngày sinh vừa nhập vẫn còn trên màn hình

---

## TC-02-015: Hồ sơ Premium — hiển thị nhãn và ngày hết hạn

**AC liên quan:** AC-12
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang ở gói Premium và đã đăng nhập vào ứng dụng StampMail

### Act (Thực hiện)
- Mở màn hình hồ sơ cá nhân

### Assert (Kiểm tra)
- Nhãn "Premium" hiển thị rõ ràng trên hồ sơ
- Ngày hết hạn gói Premium hiển thị
- Nút "Nâng cấp Premium" không xuất hiện

---

## TC-02-016: Hồ sơ Free — hiển thị nhãn và nút nâng cấp

**AC liên quan:** AC-13
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang ở gói Free và đã đăng nhập vào ứng dụng StampMail

### Act (Thực hiện)
- Mở màn hình hồ sơ cá nhân

### Assert (Kiểm tra)
- Nhãn "Free" hiển thị trên hồ sơ
- Nút "Nâng cấp Premium" xuất hiện trên màn hình hồ sơ
- Nhấn vào nút "Nâng cấp Premium" dẫn đến màn hình nâng cấp (SM-028)

---

## TC-02-017: Người xem khác không thấy thông tin gói đăng ký

**AC liên quan:** AC-14
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Tài khoản B (người xem) đã đăng nhập vào ứng dụng StampMail
- Tài khoản A (chủ hồ sơ) đang ở gói Premium hoặc Free

### Act (Thực hiện)
- Tài khoản B mở hồ sơ công khai của tài khoản A

### Assert (Kiểm tra)
- Không có nhãn "Free" hay "Premium" nào của tài khoản A hiển thị với tài khoản B
- Không có nút "Nâng cấp Premium" xuất hiện trong hồ sơ tài khoản A khi tài khoản B xem

---

## TC-02-018: Xem bốn chỉ số thống kê hoạt động

**AC liên quan:** BR-04
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Tài khoản đã có ít nhất một số liệu trong mỗi chỉ số (tem đã tạo, thư đã gửi, thư đã nhận, bộ sưu tập hoàn chỉnh)

### Act (Thực hiện)
- Mở màn hình hồ sơ cá nhân

### Assert (Kiểm tra)
- Hiển thị chỉ số "Tem đã tạo" với số đúng
- Hiển thị chỉ số "Thư đã gửi" với số đúng
- Hiển thị chỉ số "Thư đã nhận" với số đúng
- Hiển thị chỉ số "Bộ sưu tập hoàn chỉnh" với số đúng

---

## TC-02-019: Tên hiển thị vượt quá 30 ký tự bị từ chối

**AC liên quan:** AC-02, Mục 5 (lỗi validation)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Đang ở màn hình chỉnh sửa tên hiển thị

### Act (Thực hiện)
- Nhập chuỗi ký tự dài hơn 30 ký tự (ví dụ: "Nguyen Van An Tran Le Hoang Minh Duc")
- Cố gắng nhấn lưu

### Assert (Kiểm tra)
- Hệ thống hiển thị thông báo lỗi ngay tại ô nhập liệu
- Nút lưu bị vô hiệu hoá hoặc không thực hiện lưu
- Tên hiển thị cũ không bị thay đổi

---

## TC-02-020: Nhập tên hiển thị đúng giới hạn 30 ký tự (kiểm tra biên)

**AC liên quan:** AC-02 (trường hợp biên)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Đang ở màn hình chỉnh sửa tên hiển thị

### Act (Thực hiện)
- Nhập đúng 30 ký tự (ví dụ: "Nguyen Van An Tran Le Hoang Mi")
- Nhấn lưu

### Assert (Kiểm tra)
- Tên hiển thị mới được lưu thành công
- Không có thông báo lỗi nào hiển thị
- Tên mới xuất hiện trên màn hình hồ sơ

---

## TC-02-021: Tải ảnh định dạng không được hỗ trợ

**AC liên quan:** AC-01, Mục 5 (lỗi định dạng)
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Đang ở màn hình hồ sơ cá nhân
- Thiết bị có file ảnh định dạng không được hỗ trợ

### Act (Thực hiện)
- Nhấn thay đổi ảnh đại diện
- Chọn file ảnh có định dạng không được hỗ trợ từ thư viện

### Assert (Kiểm tra)
- Hệ thống hiển thị thông báo lỗi định dạng
- Thông báo gợi ý người dùng dùng ảnh khác
- Ảnh đại diện cũ không bị thay đổi

---

## TC-02-022: Username mới đã bị người dùng khác sử dụng

**AC liên quan:** AC-03, Mục 5 (lỗi username trùng)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng A đã đăng nhập, còn 1 lượt đổi username
- Tồn tại tài khoản B đang dùng username "existing_user_123"
- Đang ở màn hình chỉnh sửa username

### Act (Thực hiện)
- Nhập username "existing_user_123" vào ô username
- Nhấn xác nhận

### Assert (Kiểm tra)
- Hệ thống hiển thị thông báo "Tên người dùng đã tồn tại"
- Username không được thay đổi
- Lượt đổi username không bị trừ

---

## TC-02-023: Hồ sơ không tải được, không có cache — hiển thị lỗi và nút Thử lại

**AC liên quan:** Mục 5 (lỗi mạng/máy chủ, không có cache)
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Chưa từng tải hồ sơ lần nào (không có cache)
- Kết nối mạng không ổn định hoặc máy chủ gặp lỗi

### Act (Thực hiện)
- Mở màn hình hồ sơ cá nhân

### Assert (Kiểm tra)
- Màn hình hiển thị thông báo lỗi (không có dữ liệu trống trơn)
- Có nút "Thử lại" để người dùng tải lại mà không cần thoát ứng dụng

---

## TC-02-024: Hồ sơ có cache cũ, không tải được mới — hiển thị cache và nút Thử lại

**AC liên quan:** Mục 5 (lỗi mạng/máy chủ, có cache)
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Đã từng tải hồ sơ thành công (có cache cũ)
- Hiện tại kết nối mạng không ổn định hoặc máy chủ gặp lỗi

### Act (Thực hiện)
- Mở màn hình hồ sơ cá nhân

### Assert (Kiểm tra)
- Hồ sơ vẫn hiển thị theo dữ liệu cache cũ
- Có thông báo nhỏ cho biết dữ liệu có thể chưa cập nhật
- Có nút "Thử lại" để làm mới hồ sơ

---

## TC-02-025: Người dùng chưa đăng nhập cố truy cập màn hình hồ sơ

**AC liên quan:** Mục 5 (chưa đăng nhập)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng chưa đăng nhập vào ứng dụng StampMail

### Act (Thực hiện)
- Cố gắng truy cập màn hình hồ sơ (ví dụ: qua deep link hoặc điều hướng trong app)

### Assert (Kiểm tra)
- App chuyển ngay về màn hình đăng nhập
- Không có thông tin hồ sơ nào được hiển thị

---

## TC-02-026: Thoát app giữa chừng khi đang chỉnh sửa hồ sơ chưa lưu

**AC liên quan:** Mục 5 (thoát app giữa chừng)
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Đang ở màn hình chỉnh sửa tên hiển thị, đã nhập tên mới nhưng chưa lưu

### Act (Thực hiện)
- Thoát ứng dụng (vuốt đóng hoặc nhấn nút Home)
- Mở lại ứng dụng và vào màn hình hồ sơ

### Assert (Kiểm tra)
- Thay đổi chưa lưu bị huỷ
- Hồ sơ hiển thị thông tin đã lưu trước đó (không phải tên đang nhập dở)

---

## TC-02-027: Nhập ngày sinh chỉ có ngày mà không có tháng bị từ chối

**AC liên quan:** AC-06, BR-06 (bắt buộc cả ngày và tháng nếu chọn điền)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail
- Đang ở màn hình chỉnh sửa ngày sinh
- Chưa có ngày sinh trên hồ sơ

### Act (Thực hiện)
- Chọn điền ngày sinh
- Nhập ngày nhưng bỏ trống ô tháng
- Cố gắng nhấn lưu

### Assert (Kiểm tra)
- Hệ thống báo lỗi yêu cầu nhập cả ngày và tháng
- Ngày sinh không được lưu

---

## TC-02-028: Tắt ẩn thống kê — thống kê hiển thị lại với người khác

**AC liên quan:** AC-05, BR-05
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Tài khoản A đã bật tùy chọn "Ẩn thống kê với người khác"
- Tài khoản B đang xem hồ sơ tài khoản A (không thấy thống kê)

### Act (Thực hiện)
- Tài khoản A tắt tùy chọn "Ẩn thống kê với người khác"
- Tài khoản B làm mới và xem lại hồ sơ tài khoản A

### Assert (Kiểm tra)
- Bốn chỉ số thống kê của tài khoản A hiển thị trở lại với tài khoản B

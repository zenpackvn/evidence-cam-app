# Test Cases — Cài đặt tài khoản & Quyền riêng tư (023-cai-dat-tai-khoan)

## TC-23-001: Đăng xuất tất cả thiết bị

**AC liên quan:** AC-01
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Tài khoản người dùng A đã đăng nhập trên Thiết bị 1 và Thiết bị 2
- Cả hai thiết bị đang trong trạng thái đăng nhập bình thường

### Act (Thực hiện)
- Trên Thiết bị 1, vào màn hình Cài đặt tài khoản
- Chọn "Đăng xuất tất cả thiết bị"
- Xác nhận hành động khi có hộp thoại xác nhận

### Assert (Kiểm tra)
- Thiết bị 1 chuyển về màn hình đăng nhập
- Thiết bị 2 cũng chuyển về màn hình đăng nhập (hoặc yêu cầu đăng nhập lại khi mở app)
- Cả hai thiết bị phải đăng nhập lại bằng thông tin tài khoản

---

## TC-23-002: Yêu cầu xoá tài khoản

**AC liên quan:** AC-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập trên ứng dụng
- Người dùng ở màn hình Cài đặt tài khoản

### Act (Thực hiện)
- Tìm và chọn mục "Xoá tài khoản" trong cài đặt
- Đọc thông tin cảnh báo hiển thị
- Xác nhận yêu cầu xoá tài khoản

### Assert (Kiểm tra)
- Hệ thống hiển thị thông báo: tài khoản sẽ bị xoá sau bảy ngày
- Thông báo có hướng dẫn cách huỷ yêu cầu (đăng nhập lại trong vòng bảy ngày)
- Ứng dụng không xoá tài khoản ngay lập tức

---

## TC-23-003: Huỷ yêu cầu xoá tài khoản trong thời gian chờ

**AC liên quan:** AC-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã gửi yêu cầu xoá tài khoản
- Tài khoản đang trong trạng thái "chờ xoá" (chưa đủ bảy ngày)
- Người dùng đã đăng xuất sau khi yêu cầu xoá

### Act (Thực hiện)
- Mở ứng dụng và đăng nhập lại bằng tài khoản đang chờ xoá
- Hệ thống hiển thị thông báo tài khoản đang trong trạng thái chờ xoá
- Chọn xác nhận huỷ yêu cầu xoá

### Assert (Kiểm tra)
- Tài khoản được khôi phục về trạng thái hoạt động bình thường
- Người dùng có thể sử dụng đầy đủ chức năng của ứng dụng
- Không còn thông báo "tài khoản đang chờ xoá"

---

## TC-23-004: Tắt âm thanh animation thư — mở thư không có tiếng

**AC liên quan:** AC-04
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập
- Âm thanh animation đang ở trạng thái bật (mặc định)
- Có ít nhất một thư mới chưa mở trong hộp thư

### Act (Thực hiện)
- Vào màn hình Cài đặt tài khoản
- Tắt tùy chọn "Âm thanh animation thư"
- Quay về hộp thư và mở một thư mới

### Assert (Kiểm tra)
- Animation mở thư vẫn diễn ra bình thường (phong bì mở, hiệu ứng…)
- Không có âm thanh phát ra trong suốt quá trình animation
- Cài đặt "Âm thanh animation thư" hiển thị trạng thái tắt khi quay lại cài đặt

---

## TC-23-005: Chặn người dùng — người bị chặn không gửi thư được

**AC liên quan:** AC-05
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Người dùng A đã đăng nhập trên Thiết bị 1
- Người dùng B đã đăng nhập trên Thiết bị 2
- Người dùng B có link gửi thư đến A (hoặc có thể gửi thư đến A)

### Act (Thực hiện)
- Trên Thiết bị 1, vào Cài đặt → mục chặn người dùng
- Tìm kiếm và chặn tài khoản của người dùng B
- Trên Thiết bị 2, người dùng B cố gắng gửi thư đến A

### Assert (Kiểm tra)
- Người dùng B không thể gửi thư đến A thành công (link thư không hoạt động hoặc A không nhận được thư)
- Người dùng A không nhận được thư nào từ B sau khi chặn

---

## TC-23-006: Đổi mật khẩu thành công với mật khẩu cũ đúng

**AC liên quan:** AC-06
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập với mật khẩu hiện tại là "MatKhauCu123"
- Có thiết bị thứ hai cùng đăng nhập tài khoản này (để kiểm tra đăng xuất)

### Act (Thực hiện)
- Vào Cài đặt tài khoản → chọn "Đổi mật khẩu"
- Nhập mật khẩu cũ đúng: "MatKhauCu123"
- Nhập mật khẩu mới: "MatKhauMoi456"
- Nhập xác nhận mật khẩu mới: "MatKhauMoi456"
- Xác nhận đổi mật khẩu

### Assert (Kiểm tra)
- Hệ thống thông báo đổi mật khẩu thành công
- Thiết bị hiện tại và tất cả thiết bị khác bị đăng xuất
- Đăng nhập lại thành công bằng mật khẩu mới "MatKhauMoi456"
- Mật khẩu cũ "MatKhauCu123" không còn hoạt động

---

## TC-23-007: Đổi mật khẩu thất bại khi nhập sai mật khẩu cũ

**AC liên quan:** AC-06
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập
- Đang ở màn hình "Đổi mật khẩu"

### Act (Thực hiện)
- Nhập mật khẩu cũ sai: "SaiMatKhau999"
- Nhập mật khẩu mới: "MatKhauMoi456"
- Nhập xác nhận mật khẩu mới: "MatKhauMoi456"
- Nhấn xác nhận đổi mật khẩu

### Assert (Kiểm tra)
- Hệ thống hiển thị thông báo lỗi: mật khẩu cũ không đúng
- Mật khẩu không được thay đổi
- Người dùng vẫn đăng nhập bình thường với mật khẩu cũ

---

## TC-23-008: Đăng xuất chỉ thiết bị hiện tại

**AC liên quan:** AC-07
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Tài khoản người dùng đang đăng nhập trên Thiết bị 1 và Thiết bị 2
- Cả hai thiết bị đang hoạt động bình thường

### Act (Thực hiện)
- Trên Thiết bị 1, vào Cài đặt tài khoản
- Chọn "Đăng xuất" (chỉ thiết bị hiện tại)
- Xác nhận đăng xuất

### Assert (Kiểm tra)
- Thiết bị 1 chuyển về màn hình đăng nhập
- Thiết bị 2 vẫn đăng nhập bình thường, không bị ảnh hưởng
- Thiết bị 2 có thể tiếp tục sử dụng ứng dụng mà không cần đăng nhập lại

---

## TC-23-009: Đổi ngôn ngữ áp dụng ngay không cần khởi động lại

**AC liên quan:** AC-08
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập, giao diện ứng dụng đang hiển thị bằng "Tiếng Việt"

### Act (Thực hiện)
- Vào Cài đặt tài khoản → mục "Ngôn ngữ"
- Chọn ngôn ngữ "Tiếng Anh" (English)
- Xác nhận thay đổi

### Assert (Kiểm tra)
- Giao diện ứng dụng chuyển sang tiếng Anh ngay lập tức
- Không cần thoát và mở lại ứng dụng
- Các nhãn menu, tiêu đề, nút bấm đều hiển thị bằng tiếng Anh
- Mục "Ngôn ngữ" trong cài đặt hiển thị "English" là lựa chọn hiện tại

---

## TC-23-010: Ẩn thống kê hồ sơ với người xem khác

**AC liên quan:** AC-09
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Người dùng A đã đăng nhập; hồ sơ có hiển thị thống kê (tem đã tạo, thư đã gửi…)
- Người dùng B có thể xem hồ sơ của người dùng A
- Tùy chọn "Ẩn thống kê" đang ở trạng thái tắt

### Act (Thực hiện)
- Người dùng A vào Cài đặt tài khoản → bật tùy chọn "Ẩn thống kê"
- Người dùng B mở ứng dụng và xem hồ sơ của người dùng A

### Assert (Kiểm tra)
- Người dùng B không thấy phần thống kê (tem đã tạo, thư đã gửi…) trên hồ sơ của A
- Người dùng A vào xem hồ sơ của chính mình vẫn thấy đầy đủ số liệu thống kê
- Tùy chọn "Ẩn thống kê" hiển thị trạng thái bật trong cài đặt của A

---

## TC-23-011: Chặn thao tác bảo mật khi mất kết nối mạng — đổi mật khẩu

**AC liên quan:** AC-10
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập và đang ở màn hình Cài đặt tài khoản
- Kết nối mạng bị ngắt (tắt Wi-Fi và dữ liệu di động)

### Act (Thực hiện)
- Nhấn vào mục "Đổi mật khẩu"
- Điền mật khẩu cũ và mật khẩu mới (nếu ứng dụng cho phép vào màn hình này)
- Nhấn xác nhận đổi mật khẩu

### Assert (Kiểm tra)
- Thao tác không được thực hiện
- Hệ thống hiển thị thông báo: "Không có kết nối. Vui lòng thử lại khi có mạng."
- Dữ liệu đã nhập (mật khẩu cũ, mật khẩu mới) được giữ nguyên, không bị xoá

---

## TC-23-012: Chặn thao tác bảo mật khi mất kết nối mạng — đăng xuất tất cả thiết bị

**AC liên quan:** AC-10
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập và đang ở màn hình Cài đặt tài khoản
- Kết nối mạng bị ngắt

### Act (Thực hiện)
- Chọn "Đăng xuất tất cả thiết bị" và xác nhận

### Assert (Kiểm tra)
- Thao tác đăng xuất tất cả thiết bị không được thực hiện
- Hệ thống hiển thị thông báo: "Không có kết nối. Vui lòng thử lại khi có mạng."
- Người dùng vẫn đang đăng nhập trên thiết bị hiện tại

---

## TC-23-013: Chặn thao tác bảo mật khi mất kết nối mạng — yêu cầu xoá tài khoản

**AC liên quan:** AC-10
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập và đang ở màn hình Cài đặt tài khoản
- Kết nối mạng bị ngắt

### Act (Thực hiện)
- Chọn "Yêu cầu xoá tài khoản" và xác nhận

### Assert (Kiểm tra)
- Thao tác xoá tài khoản không được thực hiện
- Hệ thống hiển thị thông báo: "Không có kết nối. Vui lòng thử lại khi có mạng."
- Tài khoản vẫn ở trạng thái hoạt động bình thường

---

## TC-23-014: Tuỳ chọn cá nhân hoạt động offline và đồng bộ khi có mạng — ngôn ngữ

**AC liên quan:** AC-11
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập, giao diện đang hiển thị bằng "Tiếng Việt"
- Kết nối mạng bị ngắt

### Act (Thực hiện)
- Vào Cài đặt tài khoản → mục "Ngôn ngữ"
- Chọn ngôn ngữ "Tiếng Anh"
- Xác nhận thay đổi
- Bật lại kết nối mạng

### Assert (Kiểm tra)
- Giao diện ứng dụng chuyển sang tiếng Anh ngay lập tức dù đang offline
- Sau khi có mạng, cài đặt ngôn ngữ được đồng bộ lên tài khoản mà không cần thao tác thêm
- Khi đăng nhập trên thiết bị khác, ngôn ngữ hiển thị là tiếng Anh (đã đồng bộ)

---

## TC-23-015: Tuỳ chọn cá nhân hoạt động offline và đồng bộ khi có mạng — âm thanh animation

**AC liên quan:** AC-11
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập, âm thanh animation đang bật (mặc định)
- Kết nối mạng bị ngắt

### Act (Thực hiện)
- Vào Cài đặt tài khoản
- Tắt tùy chọn "Âm thanh animation thư"
- Bật lại kết nối mạng

### Assert (Kiểm tra)
- Trạng thái tắt âm thanh animation áp dụng ngay trên thiết bị dù đang offline
- Sau khi có mạng, trạng thái này được đồng bộ lên tài khoản tự động mà không cần thao tác thêm

---

## TC-23-016: Đổi mật khẩu thất bại khi xác nhận mật khẩu mới không khớp

**AC liên quan:** AC-06
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập
- Đang ở màn hình "Đổi mật khẩu"

### Act (Thực hiện)
- Nhập mật khẩu cũ đúng: "MatKhauCu123"
- Nhập mật khẩu mới: "MatKhauMoi456"
- Nhập xác nhận mật khẩu mới khác: "MatKhauMoi789"
- Nhấn xác nhận đổi mật khẩu

### Assert (Kiểm tra)
- Hệ thống hiển thị thông báo lỗi: mật khẩu xác nhận không khớp
- Mật khẩu không được thay đổi
- Người dùng vẫn đăng nhập bình thường

---

## TC-23-017: Bật lại âm thanh animation sau khi tắt

**AC liên quan:** AC-04 (BR-06 — mặc định bật)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã tắt âm thanh animation thư
- Đang ở màn hình Cài đặt tài khoản

### Act (Thực hiện)
- Bật lại tùy chọn "Âm thanh animation thư"

### Assert (Kiểm tra)
- Tùy chọn hiển thị trạng thái bật
- Cài đặt được lưu và duy trì sau khi thoát cài đặt

---

## TC-23-018: Bật/tắt từng loại thông báo push

**AC liên quan:** BR-09
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập
- Đang ở màn hình Cài đặt → mục Thông báo

### Act (Thực hiện)
- Tắt một loại thông báo cụ thể (ví dụ: thông báo khi có thư mới)
- Thoát cài đặt và quay lại kiểm tra

### Assert (Kiểm tra)
- Loại thông báo vừa tắt hiển thị trạng thái tắt khi quay lại cài đặt
- Các loại thông báo khác không bị ảnh hưởng, vẫn giữ trạng thái ban đầu

---

## TC-23-019: Màn hình cài đặt hiển thị đúng khi mất kết nối

**AC liên quan:** BR-10, BR-11 (Mục 5 — Trường hợp ngoại lệ)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập, đã vào màn hình Cài đặt tài khoản ít nhất một lần (dữ liệu đã được lưu cục bộ)
- Kết nối mạng bị ngắt

### Act (Thực hiện)
- Mở màn hình Cài đặt tài khoản khi đang offline

### Assert (Kiểm tra)
- Màn hình cài đặt hiển thị đầy đủ các mục (ngôn ngữ, âm thanh, danh sách chặn…) từ dữ liệu lưu trên thiết bị
- Người dùng có thể xem toàn bộ cài đặt mà không báo lỗi

---

## TC-23-020: Lỗi máy chủ khi tải danh sách chặn — nút thử lại

**AC liên quan:** Mục 5 — Trường hợp ngoại lệ (lỗi máy chủ)
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập
- Giả lập tình huống máy chủ trả về lỗi khi tải danh sách chặn hoặc cài đặt thông báo

### Act (Thực hiện)
- Vào mục "Danh sách chặn" hoặc "Cài đặt thông báo" trong màn hình cài đặt

### Assert (Kiểm tra)
- Màn hình hiển thị thông báo lỗi kèm nút "Thử lại"
- Người dùng không bị thoát khỏi màn hình cài đặt
- Nhấn "Thử lại" → ứng dụng tải lại dữ liệu mà không cần thoát màn hình

---

## TC-23-021: Chuyển hướng về đăng nhập khi chưa đăng nhập vào màn hình cài đặt

**AC liên quan:** Mục 5 — Trường hợp ngoại lệ (chưa đăng nhập)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng chưa đăng nhập (hoặc đã đăng xuất)

### Act (Thực hiện)
- Cố gắng truy cập vào màn hình Cài đặt tài khoản (qua link sâu hoặc điều hướng trực tiếp)

### Assert (Kiểm tra)
- Hệ thống chuyển ngay về màn hình Đăng nhập
- Người dùng không thể xem hay thay đổi bất kỳ cài đặt nào

---

## TC-23-022: Thoát app giữa chừng khi đang nhập mật khẩu mới — dữ liệu bị huỷ

**AC liên quan:** Mục 5 — Trường hợp ngoại lệ (thoát app giữa chừng)
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập
- Đang ở màn hình "Đổi mật khẩu" và đã điền một phần thông tin

### Act (Thực hiện)
- Thoát ứng dụng (vuốt tắt hoặc nhấn Home)
- Mở lại ứng dụng và vào lại màn hình "Đổi mật khẩu"

### Assert (Kiểm tra)
- Dữ liệu đã nhập trước đó (mật khẩu cũ, mật khẩu mới) không còn trong các ô nhập liệu
- Người dùng phải nhập lại từ đầu

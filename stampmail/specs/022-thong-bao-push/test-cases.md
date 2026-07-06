# Test Cases — Thông báo push (022-thong-bao-push)

## TC-22-001: Thông báo thư được đọc gửi đúng đến người gửi

**AC liên quan:** AC-01
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Người dùng A và người dùng B đều đã đăng nhập vào StampMail
- Người dùng A đã bật loại thông báo "Thư được đọc" trong cài đặt
- Người dùng A đã cấp quyền thông báo push ở cấp hệ điều hành
- Người dùng A đã gửi thư cho người dùng B (B nhận được link thư)

### Act (Thực hiện)
- Người dùng B mở link thư đã nhận từ A

### Assert (Kiểm tra)
- Người dùng A nhận thông báo push với nội dung "[Tên B] đã mở thư của bạn"
- Thông báo xuất hiện trên màn hình khóa hoặc thanh thông báo của thiết bị A

---

## TC-22-002: Tắt một loại thông báo không ảnh hưởng các loại khác

**AC liên quan:** AC-02
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào StampMail
- Tất cả năm loại thông báo đang bật
- Người dùng vào cài đặt → phần Thông báo

### Act (Thực hiện)
- Người dùng tắt toggle "Thông báo thư được đọc"
- Người nhận mở thư của người dùng

### Assert (Kiểm tra)
- Người dùng không nhận thông báo "[Tên] đã mở thư của bạn"
- Các loại thông báo khác (thư đến, hạn mức sắp cạn, Dấu) vẫn hoạt động bình thường khi có sự kiện tương ứng

---

## TC-22-003: Nhấn thông báo thư đến dẫn đến màn hình mở thư

**AC liên quan:** AC-03
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào StampMail
- Người dùng đã cấp quyền thông báo push ở hệ điều hành
- Thiết bị đang ở màn hình chờ hoặc đang dùng app khác
- Hệ thống gửi thông báo "Bạn có thư mới từ An" đến thiết bị

### Act (Thực hiện)
- Người dùng nhấn vào thông báo push "Bạn có thư mới từ An" trên thanh thông báo

### Assert (Kiểm tra)
- App StampMail mở ra
- App điều hướng thẳng đến màn hình mở thư đó (có animation theo SM-019)
- Người dùng không phải tự tìm thư trong danh sách

---

## TC-22-004: Thông báo hạn mức sắp cạn khi còn một thư

**AC liên quan:** AC-04
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Người dùng đang dùng gói Thường (Free) với hạn mức mười thư trong tháng
- Người dùng đã gửi tám thư trong tháng hiện tại (còn hai thư)
- Loại thông báo "Hạn mức sắp cạn" đang bật

### Act (Thực hiện)
- Người dùng gửi thư thứ chín trong tháng

### Assert (Kiểm tra)
- Người dùng nhận thông báo push "Bạn còn 1 thư trong tháng này"
- Nội dung thông báo phản ánh đúng số thư còn lại (1 thư)

---

## TC-22-005: Không nhận thông báo khi đã tắt quyền ở hệ điều hành

**AC liên quan:** AC-05
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào StampMail
- Người dùng tắt toàn bộ quyền thông báo của app StampMail trong cài đặt hệ điều hành (iOS: Cài đặt → Thông báo → StampMail → Tắt; Android: Cài đặt → Ứng dụng → StampMail → Thông báo → Tắt)

### Act (Thực hiện)
- Người nhận mở thư của người dùng (kích hoạt sự kiện thư được đọc)
- Có người gửi thư mới đến cho người dùng (kích hoạt sự kiện thư đến)
- Người dùng gửi thư đến ngưỡng hạn mức (kích hoạt sự kiện hạn mức sắp cạn)

### Assert (Kiểm tra)
- Người dùng không nhận được bất kỳ thông báo push nào
- Không có thông báo xuất hiện trên màn hình khóa hay thanh thông báo

---

## TC-22-006: Thông báo Dấu khi thư được mở lần đầu

**AC liên quan:** AC-06
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng A đã gửi thư và bật loại thông báo Dấu (loại 4 — thư được mở)
- Người dùng A đã cấp quyền thông báo push ở hệ điều hành
- Người nhận B chưa mở thư lần nào

### Act (Thực hiện)
- Người nhận B mở link thư và xem animation cho đến khi kết thúc lần đầu

### Assert (Kiểm tra)
- Người dùng A nhận thông báo push "Thư của bạn đã được mở — bạn nhận 15📮!"
- Thông báo chỉ đến một lần dù B mở lại thư nhiều lần sau đó (chỉ tính lần đầu hoàn thành animation)

---

## TC-22-007: Thông báo Dấu khi giới thiệu người dùng mới

**AC liên quan:** AC-07
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Người dùng A bật loại thông báo Dấu (loại 5 — giới thiệu người dùng mới)
- Người dùng A đã cấp quyền thông báo push ở hệ điều hành
- Người dùng A chưa đủ 5 lượt giới thiệu trong tháng hiện tại

### Act (Thực hiện)
- Người nhận cài đặt StampMail từ link thư của A và tạo tài khoản mới thành công

### Assert (Kiểm tra)
- Người dùng A nhận thông báo push "Bạn vừa giới thiệu người dùng mới và nhận 50📮!"

---

## TC-22-008: Thông báo được giao sau khi thiết bị có kết nối trở lại

**AC liên quan:** AC-08, BR-06, BR-07
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Thiết bị của người dùng A đang ở chế độ máy bay (ngoại tuyến / mất kết nối mạng)
- Hệ thống phát sinh thông báo "Bạn có thư mới từ Bình" trong khi A ngoại tuyến

### Act (Thực hiện)
- Người dùng A tắt chế độ máy bay và kết nối lại mạng

### Assert (Kiểm tra)
- Thiết bị A nhận được thông báo push "Bạn có thư mới từ Bình"
- Nội dung thông báo đúng với nội dung ban đầu — không bị sai tên người gửi hoặc mất thông tin
- Thông báo xuất hiện sau khi thiết bị có kết nối, không cần người dùng thao tác thêm

---

## TC-22-009: Nhiều thông báo xếp hàng đều được giao đủ khi có mạng

**AC liên quan:** AC-09, BR-06, BR-07
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Thiết bị của người dùng A đang mất kết nối mạng
- Cả ba loại thông báo (thư đến, thư được đọc, Dấu) đang bật trong cài đặt của A
- Trong khi A ngoại tuyến, ba sự kiện lần lượt xảy ra:
  - Sự kiện 1: A nhận link thư mới từ người khác
  - Sự kiện 2: Người nhận mở thư của A
  - Sự kiện 3: Người nhận hoàn thành xem animation lần đầu (sinh ra thông báo Dấu)

### Act (Thực hiện)
- Thiết bị A kết nối lại mạng

### Assert (Kiểm tra)
- Thiết bị A nhận đủ ba thông báo push
- Mỗi thông báo có đúng nội dung và đúng loại tương ứng với sự kiện ban đầu
- Không có thông báo bị mất hoặc bị hiển thị sai nội dung

---

## TC-22-010: Xin quyền thông báo lần đầu — người dùng chấp nhận

**AC liên quan:** BR-03
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng vừa cài đặt app StampMail và đăng nhập lần đầu
- Chưa có quyền thông báo nào được cấp cho app

### Act (Thực hiện)
- App kích hoạt flow xin quyền thông báo lần đầu
- Người dùng nhấn "Cho phép" trên hộp thoại quyền của hệ điều hành

### Assert (Kiểm tra)
- Hệ điều hành hiển thị hộp thoại hỏi quyền thông báo cho StampMail
- Sau khi chấp nhận, thông báo push hoạt động bình thường với các sự kiện tiếp theo

---

## TC-22-011: Xin quyền thông báo lần đầu — người dùng từ chối

**AC liên quan:** BR-03, Mục 5
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng vừa cài đặt app StampMail và đăng nhập lần đầu
- Chưa có quyền thông báo nào được cấp cho app

### Act (Thực hiện)
- App kích hoạt flow xin quyền thông báo lần đầu
- Người dùng nhấn "Không cho phép" trên hộp thoại quyền của hệ điều hành

### Assert (Kiểm tra)
- App không hỏi lại quyền thông báo tự động lần nữa
- Người dùng không nhận bất kỳ thông báo push nào

---

## TC-22-012: Hiển thị hướng dẫn cấp quyền thủ công sau khi từ chối

**AC liên quan:** BR-03, Mục 5
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã từ chối quyền thông báo push lần đầu (quyền hệ điều hành đang tắt)
- Người dùng mở app và vào màn hình cài đặt thông báo trong app

### Act (Thực hiện)
- Người dùng xem màn hình cài đặt thông báo

### Assert (Kiểm tra)
- App hiển thị hướng dẫn rõ ràng để người dùng tự cấp quyền thủ công từ cài đặt điện thoại
- Hướng dẫn chỉ dẫn đúng đường dẫn vào cài đặt hệ điều hành để bật quyền thông báo

---

## TC-22-013: Màn hình cài đặt hiển thị đủ năm toggle thông báo độc lập

**AC liên quan:** BR-02, BR-05
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào StampMail
- Người dùng đã cấp quyền thông báo push ở hệ điều hành

### Act (Thực hiện)
- Người dùng vào cài đặt tài khoản → phần Thông báo

### Assert (Kiểm tra)
- Màn hình hiển thị toggle "Thư đến"
- Màn hình hiển thị toggle "Thư được đọc"
- Màn hình hiển thị toggle "Hạn mức sắp cạn"
- Màn hình hiển thị toggle "Dấu khi thư được mở" (loại 4)
- Màn hình hiển thị toggle "Dấu khi giới thiệu người dùng mới" (loại 5)
- Mỗi toggle hoạt động độc lập — bật/tắt từng loại riêng biệt mà không ảnh hưởng loại khác

---

## TC-22-014: Nhấn thông báo thư được đọc dẫn đến hộp thư đã gửi

**AC liên quan:** BR-04
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng A đã gửi thư cho B
- Thiết bị A nhận thông báo push "[Tên B] đã mở thư của bạn"

### Act (Thực hiện)
- Người dùng A nhấn vào thông báo push "[Tên B] đã mở thư của bạn"

### Assert (Kiểm tra)
- App mở và điều hướng thẳng đến hộp thư đã gửi
- Người dùng A thấy được thư đã gửi cho B trong danh sách

---

## TC-22-015: Nhấn thông báo hạn mức sắp cạn dẫn đến màn hình nâng cấp Premium

**AC liên quan:** BR-04
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đang dùng gói Thường (Free)
- Thiết bị nhận được thông báo push "Bạn còn [N] thư trong tháng này"

### Act (Thực hiện)
- Người dùng nhấn vào thông báo push về hạn mức sắp cạn

### Assert (Kiểm tra)
- App mở và điều hướng thẳng đến màn hình nâng cấp Premium
- Người dùng không phải tự tìm màn hình nâng cấp

---

## TC-22-016: Nhấn thông báo Dấu dẫn đến màn hình số Dấu hiện có

**AC liên quan:** BR-04
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng A đã bật thông báo Dấu (loại 4 hoặc loại 5)
- Thiết bị A nhận thông báo push về Dấu (ví dụ: "Thư của bạn đã được mở — bạn nhận 15📮!")

### Act (Thực hiện)
- Người dùng A nhấn vào thông báo Dấu trên thanh thông báo

### Assert (Kiểm tra)
- App mở và điều hướng thẳng đến màn hình số Dấu hiện có của người dùng
- Người dùng thấy được số Dấu đã cập nhật sau sự kiện vừa xảy ra

---

## TC-22-017: Tắt thông báo Dấu độc lập — thông báo khác vẫn hoạt động

**AC liên quan:** BR-05
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Tất cả năm loại thông báo đang bật trong cài đặt của người dùng

### Act (Thực hiện)
- Người dùng vào cài đặt thông báo và tắt riêng "Dấu khi thư được mở" (loại 4) và "Dấu khi giới thiệu người dùng mới" (loại 5)

### Assert (Kiểm tra)
- Người dùng không nhận thông báo Dấu nữa
- Ba loại thông báo còn lại (thư đến, thư được đọc, hạn mức sắp cạn) vẫn hoạt động bình thường khi có sự kiện tương ứng

---

## TC-22-018: Bật lại thông báo sau khi đã tắt

**AC liên quan:** BR-02
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Người dùng đã tắt toggle "Thông báo thư được đọc" trong cài đặt app
- Người dùng vào cài đặt → phần Thông báo

### Act (Thực hiện)
- Người dùng bật lại toggle "Thông báo thư được đọc"
- Người nhận mở thư của người dùng sau đó

### Assert (Kiểm tra)
- Người dùng nhận được thông báo "[Tên người nhận] đã mở thư của bạn"
- Tính năng hoạt động bình thường sau khi bật lại

---

## TC-22-019: Thay đổi cài đặt thông báo khi mất mạng — đồng bộ khi có mạng

**AC liên quan:** Mục 5 (thay đổi cài đặt khi ngoại tuyến)
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Thiết bị của người dùng đang mất kết nối mạng
- Người dùng vào cài đặt thông báo trong app

### Act (Thực hiện)
- Người dùng tắt toggle "Thông báo thư đến" trong khi mất mạng
- Người dùng kết nối lại mạng sau đó

### Assert (Kiểm tra)
- Thay đổi được lưu ngay lập tức (hiển thị đúng trạng thái đã tắt trên giao diện)
- Sau khi có mạng, cài đặt tự đồng bộ lên hệ thống — người dùng không cần thao tác lại
- Người dùng không nhận thông báo "thư đến" sau khi đồng bộ thành công

---

## TC-22-020: Không hiển thị cài đặt thông báo khi chưa đăng nhập

**AC liên quan:** Mục 5 (chưa đăng nhập)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng chưa đăng nhập vào StampMail (hoặc đã đăng xuất)

### Act (Thực hiện)
- Người dùng cố truy cập vào màn hình cài đặt thông báo

### Assert (Kiểm tra)
- Màn hình cài đặt thông báo không hiển thị với người dùng chưa đăng nhập
- Không có thông báo cá nhân nào được gửi (thư đến, thư được đọc, hạn mức, Dấu)

---

## TC-22-021: Thoát app giữa chừng — cài đặt thông báo vẫn được giữ nguyên

**AC liên quan:** Mục 5 (thoát app giữa chừng)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào StampMail
- Người dùng đang ở màn hình cài đặt thông báo và vừa tắt một toggle

### Act (Thực hiện)
- Người dùng thoát app đột ngột (vuốt tắt app hoặc nhấn nút Home)
- Người dùng mở lại app và vào lại màn hình cài đặt thông báo

### Assert (Kiểm tra)
- Màn hình cài đặt hiển thị đúng trạng thái đã chỉnh trước đó (toggle đã tắt vẫn ở trạng thái tắt)
- Không có thay đổi nào bị mất sau khi thoát app

---

## TC-22-022: Lỗi máy chủ khi giao thông báo — không hiển thị lỗi với người dùng

**AC liên quan:** Mục 5 (lỗi máy chủ)
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Sự kiện "thư được đọc" xảy ra nhưng hệ thống gặp lỗi máy chủ trong quá trình giao thông báo
- Người dùng đang sử dụng app hoặc thiết bị đang hoạt động bình thường

### Act (Thực hiện)
- Hệ thống thất bại trong việc giao thông báo do lỗi máy chủ

### Assert (Kiểm tra)
- Người dùng không thấy bất kỳ màn hình lỗi hay cảnh báo nào trong app
- Thông báo bị bỏ qua lần đó (không tự gửi lại)
- Người dùng vẫn có thể kiểm tra trạng thái thư trong hộp thư thay thế

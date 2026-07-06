# Checklist QA — Thông báo push (022-thong-bao-push)

## Điều kiện tiên quyết
- [ ] Người dùng A và người dùng B đã đăng nhập vào app StampMail
- [ ] Người dùng A đã cấp quyền nhận thông báo push ở cấp hệ điều hành
- [ ] Người dùng B đã cấp quyền nhận thông báo push ở cấp hệ điều hành
- [ ] Người dùng A đang dùng gói Thường (Free) với hạn mức mười thư/tháng
- [ ] Tất cả năm loại thông báo đang ở trạng thái bật trong cài đặt app của người dùng A

## Luồng chính (Happy Path)

- [ ] Khi người dùng B mở link thư của A, A nhận thông báo push "[Tên B] đã mở thư của bạn" 🚫
- [ ] Thông báo thư được đọc hiển thị đúng tên người nhận trong nội dung thông báo 🚫
- [ ] Khi người dùng A nhận link thư mới, A nhận thông báo "Bạn có thư mới từ [tên người gửi]" 🚫
- [ ] Sau khi gửi thư thứ chín (còn 1 thư), người dùng Free nhận thông báo "Bạn còn 1 thư trong tháng này" 🚫
- [ ] Nhấn thông báo "Bạn có thư mới từ [tên]" → app mở thẳng màn hình mở thư đó (có animation SM-019) 🔲
- [ ] Nhấn thông báo "[Tên] đã mở thư của bạn" → app mở thẳng hộp thư đã gửi 🔲
- [ ] Nhấn thông báo hạn mức sắp cạn → app mở thẳng màn hình nâng cấp Premium 🔲
- [ ] Nhấn thông báo Dấu (loại 4 hoặc loại 5) → app mở thẳng màn hình số Dấu hiện có 🔲
- [ ] Khi người nhận hoàn thành animation lần đầu, người gửi A nhận thông báo "Thư của bạn đã được mở — bạn nhận 15📮!" 🚫
- [ ] Khi người nhận cài StampMail từ link thư của A, A nhận thông báo "Bạn vừa giới thiệu người dùng mới và nhận 50📮!" 🚫
- [ ] Thông báo Dấu loại 4 chỉ kích hoạt một lần duy nhất (lần đầu hoàn thành animation) 🚫

## Luồng thất bại & Validation

- [ ] Tắt toggle "Thư được đọc" → không nhận thông báo khi người nhận mở thư, loại khác không bị ảnh hưởng 🚫
- [ ] Tắt toggle "Dấu khi thư được mở" → không nhận thông báo Dấu loại 4, các loại còn lại vẫn hoạt động 🚫
- [ ] Tắt toggle "Dấu khi giới thiệu người dùng mới" → không nhận thông báo Dấu loại 5 🚫
- [ ] Khi người dùng từ chối quyền thông báo ở hệ điều hành, không nhận bất kỳ thông báo push nào 🚫
- [ ] Sau khi từ chối quyền thông báo lần đầu, app không hỏi lại quyền tự động 🔲
- [ ] Khi đã từ chối quyền hệ điều hành, màn hình cài đặt app hiển thị hướng dẫn cấp quyền thủ công từ cài đặt điện thoại 🔲
- [ ] Khi A đã đủ 5 lượt giới thiệu trong tháng, không gửi thêm thông báo Dấu loại 5 🚫

## Trường hợp biên (Edge Cases)

- [ ] Bật lại toggle thông báo sau khi đã tắt → thông báo hoạt động trở lại với sự kiện tiếp theo 🚫
- [ ] Thiết bị ngoại tuyến khi có sự kiện → thông báo được giao sau khi thiết bị có kết nối trở lại, nội dung đúng ban đầu 🚫
- [ ] Nhiều sự kiện xảy ra trong khi thiết bị ngoại tuyến → tất cả thông báo đều được giao đủ khi có mạng 🚫
- [ ] Thay đổi cài đặt thông báo khi mất mạng → thay đổi lưu ngay cục bộ, tự đồng bộ khi có mạng, không cần thao tác lại 🚫
- [ ] Mỗi loại trong năm thông báo có thể bật/tắt độc lập — không phải bật/tắt tất cả cùng lúc ✅
- [ ] Màn hình cài đặt hiển thị đủ năm toggle (3 loại sự kiện + 2 loại Dấu) ✅
- [ ] Màn hình cài đặt thông báo không hiển thị với người dùng chưa đăng nhập ✅
- [ ] Thoát app giữa chừng khi đang ở cài đặt thông báo → mở lại app vẫn hiển thị đúng trạng thái đã chỉnh ✅
- [ ] Khi máy chủ lỗi giao thông báo → người dùng không thấy màn hình lỗi, thông báo bị bỏ qua (không tự gửi lại) 🚫

## Ghi chú tự động hóa
- ✅ Maestro automatable — thao tác UI trong app: kiểm tra năm toggle cài đặt hoạt động độc lập, trạng thái bật/tắt từng loại, màn hình cài đặt ẩn khi chưa đăng nhập, trạng thái cài đặt còn nguyên sau khi thoát app
- 🔲 Manual only — deep link từ thông báo push bên ngoài app (nhấn notification điều hướng đến màn hình cụ thể), flow xin quyền hệ điều hành, màn hình hướng dẫn cấp quyền thủ công
- 🚫 Not automatable — thông báo do sự kiện phía hệ thống kích hoạt (gửi/nhận thư, mở thư, hạn mức, Dấu), trạng thái thiết bị ngoại tuyến và logic hàng đợi thông báo, lỗi máy chủ, giới hạn 5 lượt giới thiệu/tháng

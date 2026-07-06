# Checklist QA — Onboarding Trải nghiệm lần đầu (003-onboarding)

## Điều kiện tiên quyết
- [ ] Có tài khoản người dùng mới vừa hoàn tất đăng ký lần đầu (theo SM-000)
- [ ] Ứng dụng StampMail đã được cài đặt và có thể khởi động bình thường
- [ ] Trạng thái onboarding của tài khoản test chưa được đánh dấu "đã xem"
- [ ] Thiết bị có thể tắt/bật kết nối mạng chủ động (cho kiểm thử offline)

## Luồng chính (Happy Path)

- [ ] Sau khi đăng ký thành công, màn hình onboarding tự động hiển thị mà không cần thao tác thêm ✅
- [ ] Onboarding hiển thị đúng 3–4 màn hình ngắn theo thứ tự: (1) tạo tem từ ảnh, (2) viết thư và đính tem, (3) gửi thư qua mạng xã hội, (4) sưu tầm và nhận tem ✅
- [ ] Người dùng có thể chuyển qua từng màn hình onboarding (vuốt hoặc nhấn tiếp theo) ✅
- [ ] Màn hình cuối onboarding hiển thị nút "Bắt đầu" (hoặc tên hành động tương đương) ✅
- [ ] Nhấn "Bắt đầu" ở màn hình cuối → onboarding đóng lại và mở luồng tạo tem đầu tiên (SM-005) ✅
- [ ] Nút "Bỏ qua" hiển thị rõ ràng ở mọi màn hình onboarding, không bị ẩn hay mờ ✅
- [ ] Nhấn "Bỏ qua" ở bất kỳ màn hình nào → onboarding đóng lại và mở luồng tạo tem đầu tiên (SM-005) ✅

## Luồng thất bại & Validation

- [ ] Mở lại app lần thứ hai (sau khi đã hoàn thành onboarding bằng "Bắt đầu") → onboarding không hiển thị, vào thẳng màn hình chính ✅
- [ ] Mở lại app lần thứ hai (sau khi đã nhấn "Bỏ qua") → onboarding không hiển thị, vào thẳng màn hình chính ✅
- [ ] Đăng xuất rồi đăng nhập lại trên cùng thiết bị → onboarding không hiển thị lại 🔲
- [ ] Mất kết nối mạng trong khi đang xem onboarding → onboarding vẫn tiếp tục bình thường, không có thông báo lỗi mạng 🔲
- [ ] Mất kết nối mạng ngay từ đầu trước khi mở onboarding → tất cả màn hình onboarding vẫn hiển thị đầy đủ nội dung và các nút hoạt động bình thường 🔲

## Trường hợp biên (Edge Cases)

- [ ] Nhấn "Bỏ qua" ngay ở màn hình onboarding đầu tiên → chuyển thẳng vào luồng tạo tem, không đi qua màn hình chính ✅
- [ ] Nhấn "Bỏ qua" ở màn hình onboarding cuối cùng (thay vì nhấn "Bắt đầu") → kết quả giống nhau: mở luồng tạo tem ✅
- [ ] Tắt app giữa chừng onboarding (chưa hoàn thành, chưa bỏ qua) → mở lại app thì onboarding tiếp tục từ màn hình đã dừng (không bắt đầu lại từ màn hình đầu) ✅
- [ ] Tắt app ngay tại màn hình cuối onboarding trước khi nhấn "Bắt đầu" → mở lại app thì onboarding tiếp tục từ màn hình cuối ✅
- [ ] Hoàn thành onboarding bằng "Bắt đầu" → hệ thống đánh dấu onboarding đã hoàn thành bền vững, không chạy lại dù mở app nhiều lần ✅
- [ ] Bỏ qua onboarding bằng "Bỏ qua" → hệ thống đánh dấu onboarding đã xem bền vững, không chạy lại dù mở app nhiều lần ✅
- [ ] Lỗi máy chủ hoặc mất dữ liệu từ mạng trong khi onboarding → onboarding không bị ảnh hưởng, không hiển thị màn hình trắng hay nút "Thử lại" 🔲

## Ghi chú tự động hóa
- ✅ Maestro automatable — có thể tap, assert văn bản/id, điều hướng màn hình để tự động hóa
- 🔲 Manual only — cần kiểm tra thủ công: tắt mạng, đăng xuất/đăng nhập, điều kiện môi trường thiết bị thực
- 🚫 Not automatable — (không có mục nào trong tính năng này rơi vào trường hợp này)

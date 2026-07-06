# Checklist QA — Giới hạn tháng & Nhắc hạn mức (Free) (026-gioi-han-thang)

## Điều kiện tiên quyết
- [ ] Có tài khoản người dùng gói Thường (Free) đang hoạt động
- [ ] Có tài khoản người dùng gói Premium đang hoạt động (để kiểm tra BR-05/AC-05)
- [ ] Môi trường test cho phép giả lập số tem và thư đã dùng trong tháng
- [ ] Môi trường test cho phép giả lập ngày/giờ hệ thống (để kiểm tra reset đầu tháng)
- [ ] Thiết bị thực có thể tắt/bật kết nối mạng chủ động (để kiểm tra offline)

## Luồng chính (Happy Path)

- [ ] Người dùng Free dùng dưới 80% hạn mức (dưới 25 tem, dưới 9 thư): không hiển thị cảnh báo hạn mức nào ✅
- [ ] Người dùng Free còn dưới 6 tem trong tháng: app hiển thị cảnh báo trực quan về hạn mức tem ✅
- [ ] Người dùng Free còn dưới 2 thư trong tháng: app hiển thị cảnh báo trực quan về hạn mức thư ✅
- [ ] Người dùng Free còn đúng 1 thư: màn hình liên quan đến gửi thư hiển thị "Còn 1 thư trong tháng này" ✅
- [ ] Người dùng Free còn dưới 20% hạn mức: hệ thống gửi thông báo push cảnh báo hạn mức sắp cạn 🚫
- [ ] Người dùng Free đã dùng hết 10 thư: hành động gửi thêm thư bị chặn ✅
- [ ] Người dùng Free đã dùng hết 10 thư: hiển thị thông báo đã hết hạn mức thư ✅
- [ ] Người dùng Free đã dùng hết 10 thư: hiển thị gợi ý nâng cấp Premium hoặc chờ đầu tháng ✅
- [ ] Người dùng Free đã lưu đủ 30 tem: không thể lưu thêm tem mới ✅
- [ ] Người dùng Free đã lưu đủ 30 tem: hiển thị thông báo đã hết hạn mức tem ✅
- [ ] Người dùng Free đã lưu đủ 30 tem: hiển thị gợi ý nâng cấp Premium ✅
- [ ] Người dùng Premium tạo tem và gửi thư vượt quá giới hạn Free: không bị chặn ✅
- [ ] Người dùng Premium: không hiển thị bất kỳ cảnh báo hạn mức nào ✅

## Luồng thất bại & Validation

- [ ] Người dùng Free đã dùng hết thư, cố gắng soạn và gửi thêm thư: hệ thống ngăn chặn và thông báo rõ ràng ✅
- [ ] Người dùng Free đã dùng hết tem, cố gắng lưu tem mới qua SM-011: hệ thống ngăn chặn và thông báo rõ ràng ✅
- [ ] Người dùng Free tạo link mới cho thư hết hạn (SM-021): link mới được trừ vào hạn mức thư của tháng hiện tại 🚫
- [ ] Người dùng Free đã hết hạn mức thư, nhấn gợi ý nâng cấp: điều hướng đến màn hình nâng cấp Premium (SM-028) ✅
- [ ] Chưa đăng nhập: không hiển thị số liệu hạn mức và không hiển thị banner cảnh báo ✅
- [ ] Chưa đăng nhập: toàn bộ phần theo dõi hạn mức bị ẩn hoàn toàn ✅

## Trạng thái Offline

- [ ] Mất kết nối sau khi đồng bộ: app vẫn hiển thị đúng số tem và thư đã dùng theo dữ liệu lần cuối đồng bộ 🔲
- [ ] Mất kết nối: không hiển thị màn hình trắng hoặc giá trị trống ở màn hình hạn mức 🔲
- [ ] Mất kết nối: cố gắng tạo tem mới — hệ thống chặn và hiển thị "Không có kết nối. Vui lòng thử lại khi có mạng." 🔲
- [ ] Mất kết nối: cố gắng gửi thư — hệ thống chặn và hiển thị "Không có kết nối. Vui lòng thử lại khi có mạng." 🔲
- [ ] Mất kết nối: không có bất kỳ hành động ghi nào được thực hiện (tạo tem, gửi thư) 🔲
- [ ] Đồng bộ hạn mức thất bại (lỗi mạng/máy chủ): app hiển thị số liệu từ cache cục bộ 🚫
- [ ] Đồng bộ hạn mức thất bại: hiển thị thông báo "Không thể cập nhật dữ liệu" và nút "Thử lại" 🚫

## Trường hợp biên (Edge Cases)

- [ ] Hạn mức tự động reset về 0 vào ngày 1 của tháng mới theo múi giờ thiết bị người dùng 🚫
- [ ] Sau reset đầu tháng, người dùng Free đã hết thư tháng trước: có thể gửi thêm 10 thư trong tháng mới 🚫
- [ ] Người dùng dùng hết đúng 30 tem: bị chặn ngay tại lần lưu thứ 31 ✅
- [ ] Người dùng dùng hết đúng 10 thư: bị chặn ngay tại lần gửi thứ 11 ✅
- [ ] Người dùng còn đúng 5 tem (dưới ngưỡng 6): cảnh báo hiển thị ✅
- [ ] Người dùng còn đúng 6 tem (bằng ngưỡng, không phải dưới): không hiển thị cảnh báo ✅
- [ ] Người dùng còn đúng 1 thư (dưới 2): cảnh báo hiển thị ✅
- [ ] Người dùng còn đúng 2 thư (bằng ngưỡng, không phải dưới): không hiển thị cảnh báo ✅
- [ ] Người dùng nâng cấp Premium trong tháng: giới hạn tháng không còn áp dụng ngay sau khi nâng cấp 🔲
- [ ] Reset theo múi giờ thiết bị khác giờ server: người dùng thấy ngày 1 tháng đúng theo đồng hồ điện thoại của họ 🚫
- [ ] Thoát app giữa chừng khi đang xem màn hình hạn mức: mở lại app vẫn thấy đúng số liệu, không bị mất dữ liệu 🔲

## Ghi chú tự động hóa
- ✅ Maestro automatable — tap, assert text, navigation, trạng thái giả lập qua API/seeding
- 🔲 Manual only — yêu cầu tương tác thiết bị thực: tắt/bật mạng, force close app, thanh toán nâng cấp Premium
- 🚫 Not automatable — phụ thuộc thời gian thực (reset đầu tháng, múi giờ), trạng thái server, thông báo push hệ thống, lỗi máy chủ khó giả lập

# Checklist QA — Gửi thư qua MXH (014-gui-thu-mxh)

## Điều kiện tiên quyết
- [ ] Người dùng đã đăng nhập vào StampMail
- [ ] Người dùng đã soạn xong thư (SM-013) và đã xem trước (SM-015)
- [ ] Có tài khoản gói Thường (Free) để kiểm thử giới hạn mười thư/tháng
- [ ] Có tài khoản gói Premium để kiểm thử gửi không giới hạn
- [ ] Có ít nhất một ứng dụng MXH được hỗ trợ cài trên thiết bị (VD: Zalo, WhatsApp)
- [ ] Có thiết bị thứ hai (hoặc tài khoản khác) để mô phỏng hành động của người nhận
- [ ] Ghi nhận số Dấu hiện tại của người dùng trước khi kiểm thử các TC liên quan đến Dấu

## Luồng chính (Happy Path)
- [ ] Màn hình chọn nền tảng hiển thị đủ tám nền tảng: Facebook Messenger, Instagram DM, TikTok DM, Threads, Zalo, WhatsApp, iMessage, Twitter/X DM ✅
- [ ] Chọn "Gửi qua Zalo" → ứng dụng Zalo mở ra ở màn hình DM với link thư đã điền sẵn 🔲
- [ ] Chọn "Gửi qua WhatsApp" → ứng dụng WhatsApp mở ra ở màn hình DM với link thư đã điền sẵn 🔲
- [ ] Chọn hai nền tảng (VD: Zalo và Instagram DM) → mỗi nền tảng nhận một link khác nhau (không dùng chung link) ✅
- [ ] Chọn ba nền tảng → ba link riêng biệt được tạo, không link nào trùng nhau ✅
- [ ] Sau khi tạo link thành công → màn hình hiển thị thông báo "Bạn kiếm được 5📮" và số Dấu tăng thêm 5 ✅
- [ ] Người dùng gói Premium gửi hơn mười thư trong tháng → không bị chặn, link vẫn được tạo bình thường 🚫
- [ ] Người gửi nhận thông báo push "Tên người nhận đã mở thư của bạn" khi người nhận mở link 🚫
- [ ] Người nhận chưa có StampMail mở link trên trình duyệt → thấy trang xem thư kèm gợi ý tải StampMail 🔲
- [ ] Người nhận cài StampMail từ link thư (lượt ≤ 5 trong tháng) → người gửi nhận 50📮 và thông báo push 🚫
- [ ] Link mang thông tin nhận dạng người gửi; cài app từ link → hệ thống ghi nhận đúng nguồn giới thiệu 🚫

## Luồng thất bại & Validation
- [ ] Tài khoản Free gửi đủ mười thư rồi cố gửi thêm → thông báo đạt giới hạn tháng, có gợi ý nâng cấp Premium hoặc chờ đầu tháng ✅
- [ ] Tài khoản Free gửi đúng thư thứ mười → thành công, không hiển thị thông báo giới hạn ✅
- [ ] Người nhận mở link lần thứ hai sau khi đã đọc → thông báo "thư này đã được đọc", không xem được nội dung 🚫
- [ ] Nền tảng MXH chưa cài trên thiết bị → link được sao chép vào bộ nhớ tạm, thông báo hướng dẫn tự dán vào ứng dụng nhắn tin 🔲
- [ ] Mất kết nối khi tạo link → không tạo link, không mở MXH, hiển thị "Không có kết nối. Vui lòng thử lại khi có mạng.", thư vẫn còn nguyên ✅
- [ ] Chặn mở DM khi mất mạng → thao tác chia sẻ bị chặn hoàn toàn cho đến khi có mạng ✅
- [ ] Kết nối được khôi phục → nhấn thử lại → tạo link thành công và tiếp tục luồng gửi bình thường 🔲
- [ ] Lỗi phía máy chủ dù có mạng → hiển thị thông báo lỗi và nút "Thử lại", nội dung thư không mất 🚫
- [ ] Chưa đăng nhập mà cố gửi thư → chuyển ngay về màn hình đăng nhập, không tạo được link ✅
- [ ] Người gửi đã đủ 5 lượt thưởng cài app trong tháng → người nhận thứ 6 cài app → người gửi không nhận thêm Dấu, không có thông báo 🚫

## Trường hợp biên (Edge Cases)
- [ ] Link hết hạn sau bảy ngày (chưa được mở) → người nhận mở link thấy thông báo "link đã hết hạn", không xem được nội dung 🚫
- [ ] Người khác (không phải người nhận) dùng link đã được đọc → bị từ chối với thông báo đã được đọc 🚫
- [ ] Thoát màn hình gửi mà chưa chọn nền tảng → không tạo link, quay về màn hình xem trước (SM-015) hoặc màn hình chính, thư không bị xóa ✅
- [ ] Thoát app giữa chừng trước khi link được tạo → mở lại app → thư vẫn ở trạng thái chờ gửi, không mất dữ liệu 🔲
- [ ] Gửi cùng một thư đến tám nền tảng cùng lúc → tám link riêng biệt được tạo thành công, không link nào trùng nhau ✅
- [ ] Chọn iMessage trên thiết bị Android (iMessage không khả dụng) → link được sao chép vào bộ nhớ tạm, thông báo hướng dẫn 🔲
- [ ] Người dùng có đúng 0 thư đã gửi trong tháng (đầu tháng) → gửi thư đầu tiên thành công, nhận 5📮 ✅

## Ghi chú tự động hóa
- ✅ Maestro automatable — có thể kiểm tra bằng cách tap, nhập text, assert văn bản/ID hiển thị trong app (VD: danh sách nền tảng, thông báo giới hạn, thông báo Dấu, lỗi mạng)
- 🔲 Manual only — yêu cầu mở ứng dụng ngoài (Zalo, WhatsApp, iMessage…), kiểm tra bộ nhớ tạm thiết bị, hoặc thay đổi trạng thái mạng thực tế
- 🚫 Not automatable — phụ thuộc trạng thái server (link đã mở, link hết hạn 7 ngày), push notification cross-device, xác minh attribution, hoặc điều kiện không thể tái tạo tự động

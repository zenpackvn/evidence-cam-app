# Checklist QA — Hộp thư đã gửi & Theo dõi trạng thái (SM-021 / 019-hop-thu-da-gui)

## Điều kiện tiên quyết
- [ ] Tài khoản đã đăng nhập thành công (SM-001)
- [ ] Tài khoản đã gửi ít nhất một thư (SM-016)
- [ ] Có tài khoản gói Thường với hạn mức tháng còn lại để kiểm tra tạo link mới
- [ ] Có dữ liệu thư với đủ ba trạng thái link: Đang hoạt động, Đã đọc, Hết hạn
- [ ] Có môi trường để mô phỏng mất kết nối mạng (chế độ máy bay hoặc tắt WiFi)

## Luồng chính (Happy Path)

- [ ] Mở hộp thư đã gửi hiển thị danh sách tất cả thư đã gửi ✅
- [ ] Thư mới nhất xuất hiện đầu tiên trong danh sách (BR-01, AC-01) ✅
- [ ] Thứ tự danh sách đúng từ mới đến cũ sau khi cuộn (BR-01) ✅
- [ ] Mỗi thư hiển thị tổng số link đã tạo (= số người gửi đến) (BR-03) ✅
- [ ] Link trạng thái "Đang hoạt động" hiển thị đúng nhãn (BR-02) ✅
- [ ] Link trạng thái "Đã đọc" hiển thị đúng nhãn và kèm thời điểm mở (BR-02, AC-02) ✅
- [ ] Link trạng thái "Hết hạn" hiển thị đúng nhãn (BR-02, AC-02) ✅
- [ ] Một thư có nhiều link hiển thị từng trạng thái riêng biệt, không bị nhầm lẫn (AC-02) ✅
- [ ] Nhấn "Tạo link mới" cho link hết hạn tạo được link mới thành công (BR-04, AC-03) ✅
- [ ] Sau khi tạo link mới, hạn mức tháng của gói Thường giảm đi một (BR-04, AC-03) 🚫
- [ ] Nút "Tạo link mới" chỉ xuất hiện và có thể nhấn cho link "Hết hạn" (BR-04) ✅
- [ ] Nút "Tạo link mới" không xuất hiện hoặc bị vô hiệu hóa cho link "Đã đọc" (BR-05, AC-04) ✅
- [ ] Nút "Tạo link mới" không xuất hiện hoặc bị vô hiệu hóa cho link "Đang hoạt động" (BR-05) ✅
- [ ] Cố tạo link mới cho thư đã đọc: hệ thống hiển thị thông báo thư đã được nhận (AC-04) ✅

## Luồng thất bại & Validation

- [ ] Khi không có thư đã gửi: hiển thị trạng thái rỗng với gợi ý tạo thư đầu tiên ✅
- [ ] Khi hết hạn mức tháng và cố tạo link mới: thông báo hết hạn mức, gợi ý nâng cấp Premium 🚫
- [ ] Khi mất kết nối mạng: danh sách từ lần tải gần nhất vẫn hiển thị (BR-06, AC-05) 🔲
- [ ] Khi mất kết nối mạng: xuất hiện thông báo "Đang xem ngoại tuyến — dữ liệu có thể chưa cập nhật" (BR-06, AC-05) 🔲
- [ ] Khi mất kết nối mạng: nút "Tạo link mới" bị vô hiệu hóa (BR-07) 🔲
- [ ] Khi mất kết nối và nhấn "Tạo link mới": thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." (BR-07, AC-06) 🔲
- [ ] Khi kết nối được khôi phục: danh sách và trạng thái link tự động làm mới (BR-08) 🔲
- [ ] Khi dữ liệu không tải được (lỗi mạng/máy chủ): hiển thị thông báo lỗi kèm nút "Thử lại" 🔲
- [ ] Nhấn "Thử lại" khi mạng phục hồi: danh sách tải thành công 🔲
- [ ] Khi chưa đăng nhập và cố truy cập hộp thư đã gửi: tự động chuyển về màn hình đăng nhập ✅

## Trường hợp biên (Edge Cases)

- [ ] Danh sách chỉ có đúng một thư: hiển thị đúng, không bị lỗi giao diện ✅
- [ ] Thư có đúng một link duy nhất (một người nhận): hiển thị số người nhận là 1 ✅
- [ ] Thư có nhiều link, tất cả đều hết hạn: mỗi link đều hiển thị nút "Tạo link mới" ✅
- [ ] Thư có nhiều link, tất cả đều đã đọc: không link nào cho tạo link mới ✅
- [ ] Sau khi tạo link mới thành công, link cũ hết hạn không còn hiển thị tùy chọn tạo lại ✅
- [ ] Danh sách dài (hơn 20 thư): cuộn mượt, không mất dữ liệu, thứ tự vẫn đúng 🔲
- [ ] Thoát app giữa chừng và mở lại: danh sách hiển thị ngay từ cache, không cần chờ tải lại 🔲
- [ ] Mở lại app khi đang offline: hiển thị dữ liệu cache kèm thông báo ngoại tuyến 🔲

## Ghi chú tự động hóa
- ✅ Maestro automatable — các luồng UI thuần: điều hướng, hiển thị nhãn trạng thái, nút bật/tắt, thông báo văn bản
- 🔲 Manual only — yêu cầu thao tác thiết bị thực: bật/tắt mạng, mô phỏng lỗi máy chủ, cuộn danh sách dài, vòng lặp thoát/mở lại app
- 🚫 Not automatable — phụ thuộc trạng thái máy chủ hoặc thời gian thực: hạn mức tháng, hết hạn link (quá 7 ngày)

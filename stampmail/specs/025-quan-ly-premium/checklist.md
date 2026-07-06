# Checklist QA — Quản lý đăng ký Premium (SM-029 / 025-quan-ly-premium)

## Điều kiện tiên quyết
- [ ] Tài khoản đã đăng nhập (SM-001 đã hoàn thành).
- [ ] Tài khoản đã nâng cấp Premium ít nhất một lần (SM-028 đã hoàn thành).
- [ ] Môi trường test có ít nhất một giao dịch Premium trong lịch sử thanh toán.
- [ ] Môi trường test cho phép giả lập ngày hết hạn (backend/mock hỗ trợ).
- [ ] Ứng dụng đã được cấp quyền nhận thông báo push trên thiết bị test.

## Luồng chính (Happy Path)

- [ ] Mở màn hình quản lý đăng ký: thấy tên gói đang dùng (tháng hoặc năm). ✅
- [ ] Màn hình quản lý hiển thị ngày hết hạn cụ thể (BR-01, AC-01). ✅
- [ ] Màn hình quản lý hiển thị trạng thái "Tự động gia hạn: Bật" khi chưa huỷ (BR-01, AC-01). ✅
- [ ] Nhấn nút huỷ tự động gia hạn → hiện hộp thoại xác nhận (BR-03). ✅
- [ ] Sau khi xác nhận huỷ: trạng thái đổi thành "Tự động gia hạn: Đã huỷ" (BR-03, AC-02). ✅
- [ ] Sau khi huỷ tự động gia hạn: Premium vẫn còn hiệu lực đến hết ngày đã trả (BR-03, AC-02). 🚫
- [ ] Màn hình lịch sử thanh toán hiển thị danh sách các kỳ đã thanh toán (BR-02, AC-04). ✅
- [ ] Mỗi kỳ trong lịch sử thanh toán hiển thị đúng ngày, số tiền và loại gói (BR-02, AC-04). ✅
- [ ] Khi tài khoản vừa hết kỳ Premium (không gia hạn): tài khoản tự động chuyển về Free (BR-04, AC-03). 🚫
- [ ] Sau khi về Free: các tính năng Premium bị khoá (BR-04, AC-03). 🚫
- [ ] Sau khi về Free: toàn bộ tem và thư cũ vẫn còn nguyên trong Album (BR-05, AC-05). 🚫
- [ ] Trước ngày hết hạn Premium: người dùng nhận thông báo push nhắc Premium sắp hết (BR-06, AC-06). 🚫
- [ ] Thông báo sắp hết hạn kèm tuỳ chọn gia hạn (deeplink hoặc nút) (BR-06, AC-06). 🚫

## Luồng thất bại & Validation

- [ ] Khi mất kết nối lúc xem trang quản lý: hiển thị thông tin gói, ngày hết hạn, trạng thái gia hạn và lịch sử thanh toán đã lưu từ lần tải gần nhất (BR-07, AC-08). 🔲
- [ ] Khi mất kết nối: hiển thị thông báo "Đang xem ngoại tuyến — dữ liệu có thể chưa được cập nhật" (BR-07, AC-08). 🔲
- [ ] Khi mất kết nối: nút "Huỷ tự động gia hạn" bị vô hiệu hoá, không gửi yêu cầu (BR-08, AC-09). 🔲
- [ ] Khi mất kết nối và nhấn huỷ gia hạn: hiển thị "Không có kết nối. Vui lòng thử lại khi có mạng." (BR-08, AC-09). 🔲
- [ ] Khi không tải được thông tin đăng ký (lỗi máy chủ): hiển thị thông báo lỗi thân thiện và nút "Thử lại". 🔲
- [ ] Khi thanh toán thất bại (thẻ từ chối/hết hạn): màn hình hiển thị trạng thái "Thanh toán thất bại". 🔲
- [ ] Khi thanh toán thất bại: gợi ý người dùng cập nhật phương thức trong cài đặt nền tảng (App Store / Google Play). 🔲
- [ ] Khi chưa đăng nhập và truy cập màn hình quản lý: chuyển ngay về màn hình đăng nhập, không hiển thị thông tin Premium. ✅

## Trường hợp biên (Edge Cases)

- [ ] Người dùng có đúng ba kỳ thanh toán: lịch sử hiển thị đủ cả ba kỳ, đúng ngày và số tiền (AC-04). ✅
- [ ] Người dùng chưa từng có kỳ thanh toán nào: màn hình lịch sử hiển thị trạng thái rỗng rõ ràng. ✅
- [ ] Huỷ gia hạn rồi kill app và mở lại: trạng thái "Đã huỷ" được giữ nguyên, không bị reset (AC-02, BR-03). ✅
- [ ] Thoát app giữa chừng khi đang xem: mở lại màn hình vẫn thấy thông tin từ cache trong khi hệ thống làm mới ở nền. ✅
- [ ] Premium hết hạn giữa tháng: giới hạn Free áp dụng ngay lập tức từ thời điểm hết hạn, không chờ đầu tháng tiếp theo (BR-05, AC-07). 🚫
- [ ] Premium hết hạn giữa tháng khi đã dùng vượt hạn mức Free: thao tác tạo thêm bị chặn ngay (BR-05, AC-07). 🚫
- [ ] Gói Premium năm (thay vì tháng): màn hình quản lý hiển thị đúng "Premium năm" và ngày hết hạn tương ứng. ✅

## Ghi chú tự động hóa
- ✅ Maestro automatable — tap, assert visible text/id, scroll, navigation, kill và mở lại app
- 🔲 Manual only — tắt/bật mạng trên thiết bị thực, kiểm tra nền tảng App Store / Google Play
- 🚫 Not automatable — chuyển đổi trạng thái theo thời gian thực (hết hạn), gửi thông báo push từ backend, xác minh dữ liệu phía server

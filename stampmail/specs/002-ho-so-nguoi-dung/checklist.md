# Checklist QA — Hồ sơ người dùng (002-ho-so-nguoi-dung)

## Điều kiện tiên quyết
- [ ] Có ít nhất hai tài khoản test (tài khoản chủ A và tài khoản quan sát B)
- [ ] Tài khoản A chưa dùng lượt đổi username (còn 1 lượt) — dùng cho TC-02-003
- [ ] Tài khoản C đã dùng hết 1 lượt đổi username (không còn lượt) — dùng cho TC-02-004
- [ ] Tài khoản Free và tài khoản Premium sẵn sàng để kiểm tra AC-12, AC-13, AC-14
- [ ] Thiết bị có ảnh hợp lệ trong thư viện để tải lên ảnh đại diện
- [ ] Có thể bật/tắt kết nối mạng trên thiết bị test

## Luồng chính (Happy Path)

- [ ] Mở màn hình hồ sơ cá nhân — hiển thị đúng ảnh đại diện, tên hiển thị, username và bốn chỉ số thống kê ✅
- [ ] Chọn ảnh mới từ thư viện — giao diện cắt ảnh tỉ lệ 1:1 xuất hiện 🔲
- [ ] Xác nhận cắt và lưu ảnh đại diện mới — ảnh mới hiển thị ngay trên màn hình hồ sơ 🔲
- [ ] Ảnh đại diện mới hiển thị đồng nhất ở mọi nơi trong app sau khi lưu 🔲
- [ ] Nhập tên hiển thị mới (dưới 30 ký tự) và lưu thành công — tên mới hiển thị ngay ✅
- [ ] Nhập username mới hợp lệ khi còn lượt đổi — xác nhận thành công ✅
- [ ] Sau khi đổi username lần 2 thành công — hệ thống thông báo đã hết lượt đổi ✅
- [ ] Bốn chỉ số thống kê hiển thị đúng: tem đã tạo, thư đã gửi, thư đã nhận, bộ sưu tập hoàn chỉnh ✅
- [ ] Bật tùy chọn ẩn thống kê — thống kê vẫn hiển thị với chủ tài khoản 🚫
- [ ] Tài khoản khác xem hồ sơ khi chủ tài khoản bật ẩn thống kê — không thấy phần thống kê 🚫
- [ ] Tắt ẩn thống kê — thống kê hiển thị lại với người khác 🚫
- [ ] Nhập ngày và tháng sinh (bỏ qua năm) và lưu thành công ✅
- [ ] Nhập ngày, tháng và năm sinh đầy đủ và lưu thành công ✅
- [ ] Xoá ngày sinh — trường ngày sinh trống, không còn hiển thị ✅
- [ ] Bật hiển thị ngày sinh với người khác — người khác chỉ thấy ngày và tháng, không thấy năm 🚫
- [ ] Ngày sinh mặc định riêng tư — người khác không thấy sau khi vừa nhập 🚫
- [ ] Người dùng Premium xem hồ sơ — nhãn "Premium" và ngày hết hạn hiển thị, không có nút nâng cấp ✅
- [ ] Người dùng Free xem hồ sơ — nhãn "Free" hiển thị và nút "Nâng cấp Premium" xuất hiện ✅
- [ ] Nhấn nút "Nâng cấp Premium" — dẫn đến màn hình nâng cấp (SM-028) ✅
- [ ] Người khác xem hồ sơ — không thấy nhãn Free/Premium hay nút nâng cấp của chủ hồ sơ 🚫

## Luồng thất bại & Validation

- [ ] Nhập tên hiển thị vượt quá 30 ký tự — hiển thị lỗi ngay tại ô nhập, không cho lưu ✅
- [ ] Tải ảnh định dạng không được hỗ trợ — hiển thị thông báo lỗi định dạng và gợi ý dùng ảnh khác 🔲
- [ ] Tải ảnh kích thước quá lớn — hiển thị thông báo lỗi và gợi ý dùng ảnh khác 🔲
- [ ] Nhập username đã bị người khác dùng — thông báo "Tên người dùng đã tồn tại", không trừ lượt ✅
- [ ] Cố đổi username khi đã hết lượt — hệ thống thông báo đã hết lượt và không cho thực hiện ✅
- [ ] Nhập ngày sinh mà không có tháng (bỏ trống tháng) — hệ thống báo lỗi, không cho lưu ✅
- [ ] Mất kết nối khi lưu tên hiển thị — thông báo không có mạng, nội dung đang nhập vẫn còn trên màn hình 🔲
- [ ] Mất kết nối khi lưu ảnh đại diện — thông báo không có mạng, ảnh đại diện cũ không đổi 🔲
- [ ] Mất kết nối khi lưu ngày sinh — thông báo không có mạng, dữ liệu vừa nhập vẫn còn trên màn hình 🔲
- [ ] Mất kết nối khi thay đổi tùy chọn riêng tư — thông báo không có mạng, không lưu 🔲
- [ ] Mất kết nối khi lưu username mới — thông báo không có mạng, lượt đổi không bị trừ 🔲
- [ ] Người dùng chưa đăng nhập cố truy cập màn hình hồ sơ — app chuyển về màn hình đăng nhập ✅

## Trường hợp biên (Edge Cases)

- [ ] Nhập chính xác 30 ký tự cho tên hiển thị — lưu thành công, không hiện lỗi ✅
- [ ] Nhập 31 ký tự cho tên hiển thị — từ chối lưu và hiện lỗi ✅
- [ ] Nhập username trùng với username hiện tại của chính mình — hệ thống xử lý hợp lý (không trừ lượt hoặc thông báo rõ ràng) ✅
- [ ] Xem hồ sơ khi mất mạng — hiển thị cache, banner "Đang xem ngoại tuyến" xuất hiện 🔲
- [ ] Hồ sơ không tải được và không có cache — hiển thị thông báo lỗi và nút "Thử lại" 🔲
- [ ] Hồ sơ có cache cũ nhưng không tải được mới — hiển thị cache, có thông báo nhỏ và nút "Thử lại" 🔲
- [ ] Thoát app giữa chừng khi đang chỉnh sửa hồ sơ chưa lưu — mở lại hiển thị thông tin đã lưu trước đó 🔲
- [ ] Thống kê cập nhật đúng sau khi tạo tem mới hoặc gửi/nhận thư 🚫

## Ghi chú tự động hóa
- ✅ Maestro automatable — các luồng nhập liệu văn bản, điều hướng, kiểm tra nhãn UI, validation ký tự
- 🔲 Manual only — cần tương tác camera/thư viện ảnh, thao tác mạng thực, hoặc kiểm tra trạng thái thiết bị
- 🚫 Not automatable — phụ thuộc trạng thái máy chủ, kiểm tra đa tài khoản đồng thời, hoặc điều kiện khó tái tạo

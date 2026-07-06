# Checklist QA — Cài đặt tài khoản & Quyền riêng tư (023-cai-dat-tai-khoan)

## Điều kiện tiên quyết
- [ ] Tài khoản người dùng đã đăng nhập trên ít nhất một thiết bị
- [ ] Có sẵn ít nhất hai thiết bị (hoặc giả lập) đăng nhập cùng một tài khoản để kiểm tra AC-01, AC-07
- [ ] Có tài khoản người dùng B để kiểm tra chức năng chặn (AC-05)
- [ ] Kết nối mạng ổn định trước khi bắt đầu kiểm thử
- [ ] Có cách ngắt/bật kết nối mạng để kiểm tra luồng offline (AC-10, AC-11)

## Luồng chính (Happy Path)

- [ ] Vào màn hình Cài đặt tài khoản thành công từ menu hoặc hồ sơ ✅
- [ ] Đổi mật khẩu thành công khi nhập đúng mật khẩu cũ, mật khẩu mới và xác nhận (BR-01, AC-06) ✅
- [ ] Sau khi đổi mật khẩu, thiết bị hiện tại và tất cả thiết bị khác bị đăng xuất (BR-01, AC-06) 🚫
- [ ] Chọn "Đăng xuất" chỉ đăng xuất thiết bị hiện tại; thiết bị kia vẫn đăng nhập (BR-02, AC-07) 🚫
- [ ] Chọn "Đăng xuất tất cả thiết bị" đăng xuất cả hai thiết bị (BR-03, AC-01) 🚫
- [ ] Yêu cầu xoá tài khoản hiển thị thông báo xoá sau 7 ngày và hướng dẫn cách huỷ (BR-04, AC-02) ✅
- [ ] Đăng nhập lại trong 7 ngày và xác nhận huỷ xoá giữ lại tài khoản bình thường (BR-04, AC-03) ✅
- [ ] Bật/tắt âm thanh animation thư hoạt động đúng; mặc định là bật (BR-06) ✅
- [ ] Khi tắt âm thanh animation, mở thư mới có animation nhưng không có âm thanh (BR-06, AC-04) 🔲
- [ ] Đổi ngôn ngữ từ Tiếng Việt sang Tiếng Anh, giao diện chuyển ngay không cần khởi động lại (BR-05, AC-08) ✅
- [ ] Bật tùy chọn "Ẩn thống kê", người khác xem hồ sơ không thấy số liệu (BR-07, AC-09) 🚫
- [ ] Chủ tài khoản vẫn thấy số liệu của mình sau khi bật "Ẩn thống kê" (BR-07, AC-09) ✅
- [ ] Chặn người dùng B thành công từ danh sách chặn trong cài đặt (BR-08, AC-05) ✅
- [ ] Sau khi bị chặn, người dùng B không thể gửi thư đến người dùng A (BR-08, AC-05) 🚫
- [ ] Bật/tắt từng loại thông báo push hoạt động đúng; các loại khác không bị ảnh hưởng (BR-09) ✅

## Luồng thất bại & Validation

- [ ] Đổi mật khẩu với mật khẩu cũ sai → hiển thị thông báo lỗi, không thực hiện đổi (AC-06) ✅
- [ ] Đổi mật khẩu với xác nhận mật khẩu mới không khớp → hiển thị thông báo lỗi (AC-06) ✅
- [ ] Mất kết nối khi nhấn "Đổi mật khẩu" → thông báo "Không có kết nối. Vui lòng thử lại khi có mạng.", dữ liệu đã nhập giữ nguyên (AC-10) ✅
- [ ] Mất kết nối khi nhấn "Đăng xuất tất cả thiết bị" → thông báo lỗi mạng, thao tác chưa được thực hiện (AC-10) ✅
- [ ] Mất kết nối khi nhấn "Yêu cầu xoá tài khoản" → thông báo lỗi mạng, tài khoản không vào trạng thái chờ xoá (AC-10) ✅
- [ ] Lỗi máy chủ khi tải danh sách chặn → hiển thị thông báo lỗi và nút "Thử lại", không thoát màn hình ✅
- [ ] Lỗi máy chủ khi tải cài đặt thông báo → hiển thị thông báo lỗi và nút "Thử lại", không thoát màn hình ✅
- [ ] Chưa đăng nhập và cố truy cập màn hình Cài đặt → hệ thống chuyển về màn hình Đăng nhập ✅
- [ ] Thoát app giữa chừng khi đang điền biểu mẫu đổi mật khẩu → dữ liệu đã nhập bị huỷ, mở lại phải nhập từ đầu 🔲
- [ ] Tài khoản đã hết 7 ngày chờ xoá → tài khoản bị xoá vĩnh viễn; không thể đăng nhập lại 🚫

## Trường hợp biên (Edge Cases)

- [ ] Thay đổi ngôn ngữ khi offline → áp dụng ngay trên thiết bị; đồng bộ lên tài khoản tự động khi có mạng (AC-11) ✅
- [ ] Thay đổi trạng thái âm thanh animation khi offline → áp dụng ngay; đồng bộ tự động khi có mạng (AC-11) ✅
- [ ] Mở màn hình Cài đặt khi offline → hiển thị đầy đủ từ dữ liệu lưu cục bộ, không báo lỗi ✅
- [ ] Huỷ xoá tài khoản vào ngày thứ 7 (ngày cuối) vẫn thành công 🚫
- [ ] Đổi ngôn ngữ nhiều lần liên tiếp → mỗi lần thay đổi áp dụng ngay (BR-05) ✅
- [ ] Chặn người dùng đã bị chặn → ứng dụng không báo lỗi hay hành vi bất thường ✅
- [ ] Bỏ chặn người dùng → người đó có thể gửi thư trở lại 🚫
- [ ] Nhấn "Thử lại" sau lỗi máy chủ → ứng dụng tải lại dữ liệu mà không cần thoát màn hình ✅
- [ ] Các tuỳ chọn đã lưu cục bộ vẫn hiển thị đúng khi phần đồng bộ máy chủ báo lỗi ✅

## Ghi chú tự động hóa
- ✅ Maestro automatable — điều hướng màn hình, bật/tắt tùy chọn, kiểm tra thông báo lỗi, đổi ngôn ngữ, đổi mật khẩu (validation), mô phỏng offline bằng network intercept
- 🔲 Manual only — kiểm tra âm thanh thực tế, hành vi thoát app giữa chừng, giả lập lỗi máy chủ
- 🚫 Not automatable — trạng thái đa thiết bị (đăng xuất thiết bị kia), ẩn thống kê với người xem khác, hiệu lực chặn gửi thư, điều kiện hết 7 ngày xoá tài khoản

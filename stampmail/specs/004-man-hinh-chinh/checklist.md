# Checklist QA — Màn hình chính (Home) (004-man-hinh-chinh)

## Điều kiện tiên quyết
- [ ] Tài khoản người dùng đã đăng nhập thành công (xem SM-001)
- [ ] Có tài khoản thử nghiệm với các trạng thái: (a) có thư chưa đọc, (b) không có thư chưa đọc, (c) đã có tem, (d) chưa có tem, (e) tài khoản mới hoàn toàn
- [ ] Thiết bị có thể mô phỏng mất kết nối mạng (bật/tắt chế độ máy bay hoặc Wi-Fi)
- [ ] Có cách mô phỏng lỗi máy chủ hoặc kết nối mạng chậm cho môi trường thử nghiệm

## Luồng chính (Happy Path)

- [ ] Mở app khi đã đăng nhập → màn hình chính hiển thị ngay, không hiện màn đăng nhập ✅
- [ ] Khi người dùng có 2 thư chưa đọc → số "2" hiển thị tại vị trí thông báo thư ✅
- [ ] Khi người dùng có 1 thư chưa đọc → số "1" hiển thị tại vị trí thông báo thư ✅
- [ ] Khi người dùng không có thư chưa đọc → không hiển thị số (hoặc hiển thị "0") tại vị trí thông báo thư ✅
- [ ] Khi người dùng đã có ít nhất một tem → tem được tạo/nhận gần nhất hiển thị trên màn hình chính ✅
- [ ] Khi người dùng chưa có tem nào → khu vực tem hiển thị lời mời tạo tem đầu tiên thay vì ảnh tem ✅
- [ ] Thanh điều hướng phía dưới luôn hiển thị đủ bốn mục: "Tạo tem", "Thư", "Album", "Hồ sơ" ✅
- [ ] Nhấn "Tạo tem" trên thanh điều hướng → mở luồng tạo tem (SM-005) ✅
- [ ] Nhấn "Thư" trên thanh điều hướng → mở màn hình Hộp thư đến (SM-018) ✅
- [ ] Nhấn "Album" trên thanh điều hướng → mở màn hình Album sưu tập tem (SM-022) ✅
- [ ] Nhấn "Hồ sơ" trên thanh điều hướng → mở màn hình Hồ sơ người dùng (SM-024) ✅
- [ ] Hệ thống hiển thị tối đa một gợi ý hành động phù hợp với trạng thái người dùng hiện tại ✅
- [ ] Gợi ý hành động khi chưa gửi thư hiển thị đúng nội dung (ví dụ: "Bạn chưa gửi thư nào — thử gửi thư đầu tiên") ✅
- [ ] Gợi ý hành động khi có thư chưa đọc hiển thị đúng nội dung (ví dụ: "Bạn có thư chưa đọc") ✅

## Luồng thất bại & Validation

- [ ] Khi mất kết nối mạng → màn hình chính vẫn hiển thị dữ liệu đã lưu trước đó (số thư chưa đọc, tem gần nhất), không hiện màn trắng hay lỗi toàn trang 🔲
- [ ] Khi mất kết nối mạng → thông báo "Đang xem ngoại tuyến" xuất hiện ở vị trí không che khuất nội dung chính 🔲
- [ ] Khi đang ngoại tuyến → kéo để làm mới dữ liệu không thay đổi nội dung và không gây lỗi toàn trang 🔲
- [ ] Khi đang ngoại tuyến → các hành động cần mạng bị vô hiệu hóa, dữ liệu đang xem không bị mất 🔲
- [ ] Khi không tải được dữ liệu lần đầu (chưa có cache) → hiển thị skeleton loading trong khi chờ 🔲
- [ ] Khi không tải được dữ liệu lần đầu và hết thời gian thử → khu vực feed và gợi ý hiển thị trạng thái lỗi kèm nút "Thử lại" 🔲
- [ ] Nhấn nút "Thử lại" khi đã có mạng → dữ liệu được tải lại thành công, trạng thái lỗi biến mất 🔲
- [ ] Khi phiên đăng nhập hết hạn → tự động chuyển sang màn hình đăng nhập 🚫
- [ ] Thanh điều hướng không bị ẩn hoặc thiếu mục trong bất kỳ trạng thái nào ✅

## Trường hợp biên (Edge Cases)

- [ ] Người dùng mới đăng ký, chưa có tem và chưa có thư → màn hình chính hiển thị đầy đủ lời mời tạo tem, không có số thư, hiển thị đúng một gợi ý ✅
- [ ] Người dùng có đúng 1 thư chưa đọc → số "1" hiển thị chính xác ✅
- [ ] Người dùng có số lượng thư chưa đọc lớn (ví dụ: 99+) → hiển thị hợp lý (ví dụ: "99+"), không bị tràn giao diện 🔲
- [ ] Thoát app giữa chừng rồi mở lại → màn hình chính hiển thị ngay dữ liệu cache trong khi chờ tải mới từ máy chủ ✅
- [ ] Nhấn liên tục nhiều lần vào cùng một mục điều hướng → không xảy ra lỗi hay điều hướng chồng lặp ✅
- [ ] Màn hình chính hiển thị đúng bố cục trên cả thiết bị màn hình nhỏ và màn hình lớn 🔲

## Ghi chú tự động hóa
- ✅ Maestro automatable — các luồng hiển thị dữ liệu, điều hướng, trạng thái người dùng có thể kiểm thử bằng UI test
- 🔲 Manual only — kiểm thử offline cần thao tác thật trên thiết bị (bật/tắt mạng), skeleton loading, nút thử lại với lỗi mạng thật
- 🚫 Not automatable — phiên đăng nhập hết hạn phụ thuộc trạng thái máy chủ, không thể tái tạo tự động từ phía client

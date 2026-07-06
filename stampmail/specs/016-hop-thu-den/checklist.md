# Checklist QA — Hộp thư đến (SM-018) (016-hop-thu-den)

## Điều kiện tiên quyết
- [ ] Người dùng đã đăng nhập thành công (SM-001)
- [ ] Có ít nhất một tài khoản gửi thư để tạo dữ liệu test
- [ ] Môi trường test có kết nối internet ổn định để tải dữ liệu ban đầu
- [ ] Đã chuẩn bị tài khoản test với hộp thư rỗng (cho trường hợp rỗng)
- [ ] Đã chuẩn bị thiết bị thật để kiểm tra tắt/bật mạng (cho trường hợp offline)

## Luồng chính (Happy Path)

- [ ] Mở hộp thư đến: danh sách thư hiển thị với thư mới nhất ở đầu danh sách ✅
- [ ] Mỗi thư trong danh sách hiển thị ảnh nhỏ của tem ✅
- [ ] Mỗi thư trong danh sách hiển thị tên người gửi ✅
- [ ] Mỗi thư trong danh sách hiển thị thời gian nhận ✅
- [ ] Mỗi thư trong danh sách hiển thị trạng thái đọc/chưa đọc ✅
- [ ] Chọn bộ lọc "Chưa đọc": chỉ các thư chưa đọc hiển thị trong danh sách ✅
- [ ] Chọn bộ lọc "Đã đọc": chỉ các thư đã đọc hiển thị trong danh sách ✅
- [ ] Chọn bộ lọc "Tất cả": toàn bộ thư (đã đọc và chưa đọc) hiển thị ✅
- [ ] Nhấn vào một thư trong danh sách: màn hình mở thư (SM-019) được mở kèm animation đúng thiết kế 🔲
- [ ] Thư đã đọc trước đó vẫn còn trong danh sách sau nhiều ngày 🚫
- [ ] Thư đã đọc hiển thị đúng trạng thái "Đã đọc" khi mở lại hộp thư ✅

## Luồng thất bại & Validation

- [ ] Khi hộp thư trống: hiển thị trạng thái rỗng với lời nhắn thân thiện (ví dụ: "Hộp thư trống — chia sẻ StampMail để nhận thư đầu tiên") ✅
- [ ] Khi mất kết nối internet (có cache): danh sách thư đã tải trước đó vẫn hiển thị đầy đủ 🔲
- [ ] Khi mất kết nối internet: hiển thị thông báo "Đang xem ngoại tuyến — danh sách có thể chưa cập nhật mới nhất" ✅
- [ ] Khi mất kết nối internet: thao tác kéo làm mới bị vô hiệu hoá (danh sách không tải thêm thư mới) 🔲
- [ ] Khi mất kết nối internet sau khi kéo làm mới: thông báo yêu cầu có kết nối mạng để cập nhật được hiển thị 🔲
- [ ] Khi lỗi máy chủ (có cache): danh sách cache vẫn hiển thị kèm thông báo lỗi và nút "Thử lại" 🔲
- [ ] Khi lỗi máy chủ (không có cache): màn hình lỗi hiển thị với nút "Thử lại" (không crash, không màn hình trắng) 🔲
- [ ] Khi chưa đăng nhập: hệ thống chuyển ngay về màn hình đăng nhập, không hiển thị nội dung hộp thư ✅
- [ ] Khi thoát app đột ngột rồi mở lại: danh sách cache vẫn còn, ứng dụng tự tải mới khi có mạng 🔲

## Trường hợp biên (Edge Cases)

- [ ] Hộp thư có rất nhiều thư (50+): danh sách cuộn được và thứ tự thời gian vẫn đúng ✅
- [ ] Hai thư nhận gần như cùng lúc: thứ tự sắp xếp theo thời gian vẫn chính xác 🚫
- [ ] Chuyển đổi qua lại giữa các bộ lọc nhiều lần: kết quả lọc luôn đúng và không bị lẫn ✅
- [ ] Bộ lọc "Chưa đọc" khi tất cả thư đã đọc: hiển thị trạng thái rỗng phù hợp (không lỗi) ✅
- [ ] Bộ lọc "Đã đọc" khi chưa có thư nào được đọc: hiển thị trạng thái rỗng phù hợp (không lỗi) ✅
- [ ] Mất kết nối ngay khi đang tải danh sách lần đầu (không có cache): không crash, hiển thị màn hình lỗi với nút Thử lại 🔲

## Ghi chú tự động hóa
- ✅ Maestro automatable — có thể tự động hóa bằng Maestro (tap, assert text/id, scroll, điều hướng màn hình)
- 🔲 Manual only — cần kiểm tra thủ công (animation chuyển màn hình, tắt/bật kết nối mạng thực tế trên thiết bị, giả lập lỗi server, thoát app đột ngột)
- 🚫 Not automatable — không thể tự động hóa (phụ thuộc thời gian thực/trạng thái server bên ngoài, thứ tự thư cùng giây không thể tái tạo ổn định)

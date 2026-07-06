# Checklist QA — Mở thư & Animation (SM-019 / 017-mo-thu-animation)

## Điều kiện tiên quyết
- [ ] Có ít nhất một thư hợp lệ được gửi thành công (SM-017), link thư còn hiệu lực và chưa được mở
- [ ] Có tài khoản người nhận đã đăng nhập và một tài khoản chưa đăng nhập để kiểm tra các nút sau animation
- [ ] Cài đặt âm thanh animation đang ở trạng thái bật (mặc định) cho phần lớn test case; riêng TC-17-002 cần tắt âm thanh trước
- [ ] Có ít nhất một thư đã đọc trong hộp thư đến để kiểm tra AC-04
- [ ] Có tài khoản người gửi để kiểm tra thông báo và phần thưởng Dấu (AC-05, AC-06)
- [ ] Có thiết bị hoặc môi trường có thể mô phỏng mất kết nối (tắt wifi / dữ liệu di động) để kiểm tra các kịch bản offline

## Luồng chính (Happy Path)

### Trình tự animation (AC-01)
- [ ] Khi mở link thư hợp lệ lần đầu, phong bì hiện ra và bắt đầu mở chậm (bước 1 animation) 🔲
- [ ] Sau khi phong bì mở, giấy thư cuộn ra từ phong bì (bước 2 animation) 🔲
- [ ] Sau khi giấy cuộn ra, nội dung thư hiện dần (bước 3 animation) 🔲
- [ ] Sau khi nội dung hiện, tem sáng lên nổi bật (bước 4 animation) 🔲
- [ ] Bốn bước animation diễn ra theo đúng thứ tự, không bị đảo hoặc bỏ bước 🔲

### Âm thanh (AC-02)
- [ ] Animation kèm theo âm thanh khi cài đặt âm thanh đang bật 🔲
- [ ] Khi cài đặt âm thanh đã tắt, animation diễn ra bình thường nhưng không phát tiếng ✅

### Các nút sau animation (AC-03)
- [ ] Sau animation hoàn tất, người nhận đã đăng nhập thấy nút "Lưu tem vào Album" ✅
- [ ] Sau animation hoàn tất, người nhận đã đăng nhập thấy nút "Trả lời" ✅
- [ ] Sau animation hoàn tất, người dùng chưa có app thấy nút "Tải StampMail" ✅
- [ ] Nút "Lưu tem vào Album" và "Trả lời" không hiển thị với người nhận chưa đăng nhập (hoặc yêu cầu đăng nhập khi nhấn) ✅

### Xem lại thư (AC-04)
- [ ] Khi xem lại thư đã đọc từ hộp thư đến, thư hiển thị ngay nội dung đầy đủ, không có animation ✅
- [ ] Nội dung thư và hình ảnh tem hiển thị tức thì khi xem lại từ hộp thư đến ✅

### Đánh dấu đã đọc & thông báo người gửi (AC-05)
- [ ] Khi người nhận mở link thư lần đầu và animation kết thúc, thư được đánh dấu đã đọc 🚫
- [ ] Sau khi thư được đánh dấu đã đọc, người gửi nhận được thông báo trong app 🚫
- [ ] Thư trong danh sách đã gửi của người gửi chuyển sang trạng thái "đã đọc" 🚫

### Phần thưởng Dấu cho người gửi (AC-06)
- [ ] Người gửi nhận thêm 15📮 ngay khi thư được đánh dấu đã đọc lần đầu 🚫
- [ ] Người gửi nhận thông báo push "Thư của bạn đã được mở — bạn nhận 15📮!" 🚫
- [ ] Khi xem lại thư từ hộp thư đến, người gửi KHÔNG nhận thêm 📮 lần nữa 🚫
- [ ] Mỗi thư chỉ trao 15📮 đúng một lần, không trao lại dù người nhận xem nhiều lần từ hộp thư đến 🚫

### Phóng to tem (AC-07)
- [ ] Sau animation, người nhận có thể banh ngón tay để phóng to tem trên thư 🔲
- [ ] Chụm ngón tay thu tem về kích thước ban đầu 🔲
- [ ] Phóng to/thu nhỏ tem không thay đổi nội dung thư 🔲

## Luồng thất bại & Validation

### Mất mạng trước khi mở thư (AC-08)
- [ ] Khi thiết bị không có mạng và nhấn link thư, ứng dụng không bắt đầu animation 🔲
- [ ] Thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." hiển thị rõ ràng 🔲
- [ ] Khi thiết bị không có mạng và nhấn vào thư chưa đọc từ hộp thư đến, ứng dụng không bắt đầu animation 🔲
- [ ] Không có màn hình trắng hoặc thông báo lỗi không rõ ràng khi mất mạng 🔲

### Mất mạng sau khi thư đã tải (AC-09)
- [ ] Khi thư đã tải xong và đang hiển thị, mất mạng giữa chừng không làm mất nội dung thư 🔲
- [ ] Thông báo "Đang xem ngoại tuyến" hiển thị khi mất mạng sau khi thư đã tải 🔲
- [ ] Nút "Lưu tem" bị vô hiệu hóa khi đang xem ngoại tuyến 🔲
- [ ] Nút "Trả lời" bị vô hiệu hóa khi đang xem ngoại tuyến 🔲
- [ ] Khi bật lại mạng, nút "Lưu tem" và "Trả lời" hoạt động bình thường trở lại 🔲

### Khôi phục mạng tự động (BR-10)
- [ ] Khi mạng được khôi phục, hệ thống tự động ghi nhận trạng thái đã đọc mà không cần mở lại thư 🚫
- [ ] Sau khi mạng được khôi phục, người gửi nhận thông báo đã đọc và 15📮 mà không cần người nhận thao tác thêm 🚫

### Mất mạng giữa chừng animation (Mục 5)
- [ ] Khi mất mạng giữa chừng animation, animation dừng lại và hiển thị thông báo lỗi mạng 🔲
- [ ] Nút "Thử lại" xuất hiện khi mất mạng giữa chừng animation ✅
- [ ] Sau khi bật lại mạng và nhấn "Thử lại", animation tiếp tục hoặc khởi động lại từ đầu 🔲

### Thoát app giữa chừng (Mục 5)
- [ ] Khi người nhận thoát màn hình animation giữa chừng, thư vẫn được đánh dấu đã mở (link hết hiệu lực) 🚫
- [ ] Sau khi thoát giữa chừng, người nhận có thể xem lại thư từ hộp thư đến 🚫
- [ ] Khi mở lại thư đã thoát giữa chừng từ hộp thư đến, thư hiển thị ngay nội dung, không có animation ✅

### Lỗi máy chủ / link hết hạn (Mục 5)
- [ ] Khi link thư hết hạn, màn hình hiển thị thông báo lỗi rõ ràng (ví dụ: "Link đã hết hạn") 🚫
- [ ] Nút "Thử lại" hiển thị khi gặp lỗi máy chủ hoặc link hết hạn 🚫
- [ ] Không có màn hình trắng khi thư không tải được 🚫

### Lỗi tài nguyên animation (Mục 5)
- [ ] Khi tài nguyên animation không tải được nhưng nội dung thư có sẵn, thư hiển thị nội dung văn bản ngay 🚫
- [ ] Người nhận thấy thông báo ngắn gọn khi animation không tải được (không bị màn hình chờ vô hạn) 🚫

### Người chưa đăng nhập (Mục 5)
- [ ] Người nhận chưa đăng nhập mở thư qua link, animation vẫn phát bình thường ở chế độ khách 🔲
- [ ] Sau animation, khi người chưa đăng nhập nhấn "Lưu tem" hoặc "Trả lời", ứng dụng yêu cầu đăng nhập hoặc tải app ✅

## Trường hợp biên (Edge Cases)
- [ ] Khi thiết bị xử lý chậm làm animation bị lag, animation vẫn chạy đến hết các bước, không tự động bỏ qua 🔲
- [ ] Khi thiết bị yếu, animation không được tự động rút ngắn hay bỏ qua dù có độ trễ 🔲
- [ ] Link thư đã được mở trước đó (đã đọc) không kích hoạt lại animation khi mở link lần hai 🚫
- [ ] Sau khi thoát app và vào lại thư đã đọc từ hộp thư đến, không có animation, nội dung thư hiển thị ngay ✅
- [ ] Người gửi nhận đúng 15📮 — không nhiều hơn, không ít hơn — cho mỗi thư được mở lần đầu 🚫

## Ghi chú tự động hóa
- ✅ Maestro automatable — kiểm tra các phần tử UI (nút, text, trạng thái) hiện sau animation; kiểm tra trạng thái cài đặt âm thanh; kiểm tra nút yêu cầu đăng nhập khi người chưa đăng nhập nhấn vào lưu/trả lời
- 🔲 Manual only — quan sát trực tiếp trình tự và chất lượng animation; kiểm tra âm thanh phát ra; kiểm tra cử chỉ phóng to tem; kiểm tra mất mạng giữa chừng; kiểm tra thiết bị yếu/lag
- 🚫 Not automatable — trạng thái ghi nhận phía máy chủ (đã đọc, Dấu, thông báo push); link hết hiệu lực sau khi thoát giữa chừng; phục hồi tự động sau khi khôi phục mạng; lỗi máy chủ / link hết hạn

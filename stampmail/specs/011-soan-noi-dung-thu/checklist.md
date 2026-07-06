# Checklist QA — Soạn nội dung thư (011-soan-noi-dung-thu)

## Điều kiện tiên quyết
- [ ] Người dùng đã đăng nhập vào ứng dụng StampMail
- [ ] Người dùng đã hoàn thành bước chọn template (SM-012)
- [ ] Màn hình soạn thư đang hiển thị với template đã chọn
- [ ] Thiết bị có kết nối mạng bình thường (cho các test case cần mạng)

## Luồng chính (Happy Path)

### Nhập nội dung
- [ ] Màn hình soạn thư hiển thị nền template đã chọn từ bước trước ✅
- [ ] Nhấn vào vùng giấy thì bàn phím ảo xuất hiện ✅
- [ ] Gõ chữ thì chữ xuất hiện trực tiếp trên nền template (không phải ô riêng bên ngoài) ✅

### Định dạng văn bản
- [ ] Bôi đen đoạn chữ rồi nhấn nút in đậm thì đoạn chữ đó hiển thị đậm hơn; phần còn lại không bị ảnh hưởng ✅
- [ ] Bôi đen đoạn chữ rồi nhấn nút in nghiêng thì đoạn chữ đó hiển thị nghiêng; phần còn lại không bị ảnh hưởng ✅
- [ ] Nhấn nút căn trái / căn giữa / căn phải thì văn bản thay đổi căn lề tương ứng ✅

### Phông chữ
- [ ] Mở bảng chọn font — hiển thị ít nhất bốn phông: Tay viết nhẹ, Tay viết đứng, In ấn hiện đại, In ấn cổ điển ✅
- [ ] Chọn bất kỳ phông nào thì toàn bộ nội dung thư đổi sang phông đó ngay lập tức ✅
- [ ] Chuyển đổi qua lại giữa các phông thì nội dung không bị mất ✅

### Màu nền giấy thư
- [ ] Mở bảng màu nền — hiển thị ít nhất năm màu: trắng, kem, hồng nhạt, xanh nhạt, vàng nhạt ✅
- [ ] Chọn màu nền thì nền giấy thư đổi màu ngay; ô soạn thảo và nội dung không thay đổi ✅
- [ ] Có thể chọn lại màu khác và nền đổi tiếp theo màu mới ✅

### Kẻ dòng
- [ ] Chọn "Kẻ dòng" thì các dòng kẻ ngang xuất hiện trong ô soạn thảo ngay lập tức; nội dung không thay đổi ✅
- [ ] Chọn "Không kẻ dòng" thì các dòng kẻ ngang biến mất; nội dung không thay đổi ✅

### Màu chữ theo đoạn
- [ ] Bôi đen một đoạn rồi chọn màu từ bảng màu — chỉ đoạn được bôi đen đổi màu; các đoạn còn lại giữ nguyên ✅
- [ ] Đoạn chưa chọn màu giữ màu chữ mặc định ✅
- [ ] Có thể đổi màu cho nhiều đoạn khác nhau trong cùng một thư ✅

### Sticker trang trí
- [ ] Mở bộ sticker — sticker miễn phí hiển thị và chọn được không cần thanh toán ✅
- [ ] Chọn sticker miễn phí và đặt lên thư — sticker xuất hiện ở vị trí được chọn 🔲
- [ ] Sticker trang trí không đè lên vùng chữ đang soạn 🔲

## Luồng thất bại & Validation

### Giới hạn ký tự
- [ ] Khi đã nhập 450 ký tự thì hệ thống hiển thị số ký tự còn lại và/hoặc cảnh báo trực quan ✅
- [ ] Khi đã nhập đúng 500 ký tự thì không thể gõ thêm ký tự mới ✅
- [ ] Khi đã đạt giới hạn ký tự thì bộ đếm hiển thị "0 ký tự còn lại" hoặc tương đương — không hiển thị số âm ✅

### Thoát màn hình
- [ ] Nhấn nút thoát khi đang soạn thư thì hệ thống hiển thị hộp thoại "Bỏ thư này?" ✅
- [ ] Xác nhận "Bỏ thư này?" thì nội dung đang soạn bị mất và màn hình đóng lại ✅
- [ ] Hủy hộp thoại "Bỏ thư này?" thì quay lại màn hình soạn thư với nội dung còn nguyên ✅

### Offline — sticker mới
- [ ] Khi thiết bị mất mạng và cố chọn sticker chưa tải về — hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." 🔲
- [ ] Sticker chưa tải không được thêm vào thư khi mất mạng 🔲
- [ ] Sticker đã tải trước đó vẫn sử dụng được khi mất mạng 🔲

### Sticker Premium
- [ ] Sticker Premium hiển thị nhãn hoặc biểu tượng khóa với người dùng gói thường 🔲
- [ ] Người dùng gói thường không thể đặt sticker Premium lên thư mà không mở khóa 🔲
- [ ] Hệ thống hiển thị gợi ý mở khóa bằng Dấu hoặc nâng cấp gói Premium 🔲

### Quyền truy cập
- [ ] Người dùng chưa đăng nhập không thể vào màn hình soạn thư — hệ thống chuyển về màn hình đăng nhập ✅

## Trường hợp biên (Edge Cases)

### Ký tự
- [ ] Nhập đúng 449 ký tự thì chưa hiển thị cảnh báo; nhập ký tự thứ 450 thì cảnh báo xuất hiện ✅
- [ ] Template có giới hạn ký tự khác 500 thì giới hạn đúng theo template đó (không cố định 500) 🚫

### Font & Định dạng
- [ ] Nhập nội dung rồi chuyển font và chuyển lại nhiều lần thì nội dung vẫn còn nguyên, không bị mất ✅
- [ ] Áp định dạng in đậm cho một đoạn rồi chuyển font thì định dạng in đậm vẫn giữ nguyên 🔲

### Màu chữ
- [ ] Đổi màu chữ cho đoạn thứ nhất không ảnh hưởng màu chữ các đoạn còn lại ✅
- [ ] Có thể đổi màu khác nhau cho từng đoạn trong cùng một thư ✅

### Kẻ dòng & Màu nền khi gửi
- [ ] Màu nền giấy thư người gửi chọn hiển thị đúng khi người nhận xem thư 🔲
- [ ] Kẻ dòng ngang hiển thị đúng khi người nhận xem thư 🔲

### Mất kết nối giữa chừng
- [ ] Mất kết nối khi đang soạn thư — nội dung trước đó không bị mất 🔲
- [ ] Sau khi mất kết nối vẫn tiếp tục nhập chữ, chọn phông, đổi màu và dùng sticker đã tải về bình thường 🔲
- [ ] Chỉ khi cố tải sticker mới mới xuất hiện thông báo không có kết nối 🔲

### Bàn phím ảo
- [ ] Khi bàn phím ảo che khuất vùng soạn thảo thì vùng soạn thảo tự cuộn lên; ký tự đang nhập luôn hiển thị phía trên bàn phím 🔲

### Sticker — lỗi tải danh sách
- [ ] Khi danh sách sticker không tải được thì bộ sticker hiển thị trạng thái lỗi kèm nút "Thử lại" 🔲
- [ ] Sticker đã thêm vào thư trước đó vẫn giữ nguyên khi danh sách sticker gặp lỗi 🔲

### Thoát app
- [ ] Vuốt tắt app giữa chừng rồi mở lại — nội dung đang soạn bị mất (không có tính năng lưu nháp) 🔲

## Ghi chú tự động hóa
- ✅ Maestro automatable — thao tác tap, nhập văn bản, kiểm tra text/UI có thể tự động hóa bằng Maestro
- 🔲 Manual only — cần tắt mạng thực tế trên thiết bị, quan sát animation/vị trí sticker, kiểm tra xuyên tài khoản (người nhận xem thư), hoặc mô phỏng vuốt tắt app
- 🚫 Not automatable — phụ thuộc cấu hình template từ phía máy chủ (giới hạn ký tự thay đổi theo template), không thể tái tạo trong môi trường test tự động

# Test Cases — Soạn nội dung thư (011-soan-noi-dung-thu)

## TC-11-001: Nhập nội dung trực tiếp trên nền template

**AC liên quan:** AC-01
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập thành công
- Người dùng đã chọn template từ màn hình SM-012
- Màn hình soạn thư đang hiển thị với nền template đã chọn

### Act (Thực hiện)
- Nhấn vào vùng giấy trên template
- Gõ chuỗi ký tự: "Gửi bạn, mình nhớ bạn nhiều lắm!"

### Assert (Kiểm tra)
- Bàn phím ảo xuất hiện sau khi nhấn vào vùng giấy
- Chuỗi "Gửi bạn, mình nhớ bạn nhiều lắm!" hiển thị trực tiếp trên nền template
- Chữ không xuất hiện ở ô soạn thảo riêng bên ngoài template

---

## TC-11-002: Áp định dạng in đậm cho đoạn chữ đã chọn

**AC liên quan:** AC-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Màn hình soạn thư đang hiển thị
- Đã gõ nội dung "Chúc mừng sinh nhật bạn!" vào vùng giấy
- Chọn (bôi đen) đoạn chữ "Chúc mừng sinh nhật"

### Act (Thực hiện)
- Nhấn nút in đậm (Bold) trên thanh công cụ định dạng

### Assert (Kiểm tra)
- Đoạn "Chúc mừng sinh nhật" hiển thị với nét chữ đậm hơn trên template
- Phần " bạn!" không bị ảnh hưởng, vẫn giữ nét chữ bình thường

---

## TC-11-003: Áp định dạng in nghiêng cho đoạn chữ đã chọn

**AC liên quan:** AC-02 (BR-02)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Màn hình soạn thư đang hiển thị
- Đã gõ nội dung "Mình luôn ở đây vì bạn" vào vùng giấy
- Chọn (bôi đen) đoạn chữ "luôn ở đây vì bạn"

### Act (Thực hiện)
- Nhấn nút in nghiêng (Italic) trên thanh công cụ định dạng

### Assert (Kiểm tra)
- Đoạn "luôn ở đây vì bạn" hiển thị với nét chữ nghiêng trên template
- Phần "Mình " không bị ảnh hưởng, vẫn giữ kiểu chữ bình thường

---

## TC-11-004: Thay đổi căn lề văn bản (trái / giữa / phải)

**AC liên quan:** AC-02 (BR-02)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Màn hình soạn thư đang hiển thị
- Đã gõ nội dung nhiều dòng vào vùng giấy
- Văn bản đang ở trạng thái căn trái (mặc định)

### Act (Thực hiện)
- Nhấn nút căn giữa trên thanh công cụ định dạng; quan sát kết quả
- Nhấn nút căn phải; quan sát kết quả
- Nhấn nút căn trái để khôi phục; quan sát kết quả

### Assert (Kiểm tra)
- Sau khi nhấn căn giữa: toàn bộ văn bản được căn vào giữa vùng giấy
- Sau khi nhấn căn phải: toàn bộ văn bản được căn về phía phải
- Sau khi nhấn căn trái: toàn bộ văn bản trở về căn trái

---

## TC-11-005: Hiển thị cảnh báo khi gần đến giới hạn ký tự

**AC liên quan:** AC-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Màn hình soạn thư đang hiển thị với giới hạn 500 ký tự
- Chưa có nội dung nào trong vùng giấy
- Bộ đếm ký tự chưa hiển thị cảnh báo

### Act (Thực hiện)
- Nhập chính xác 449 ký tự vào vùng giấy (kiểm tra trạng thái chưa cảnh báo)
- Nhập thêm 1 ký tự để đạt 450 ký tự

### Assert (Kiểm tra)
- Tại 449 ký tự: chưa có cảnh báo trực quan về giới hạn
- Tại 450 ký tự: hệ thống hiển thị số ký tự còn lại (ví dụ: "50 ký tự còn lại") và/hoặc cảnh báo trực quan (màu đỏ, biểu tượng cảnh báo)

---

## TC-11-006: Không thể nhập quá giới hạn ký tự

**AC liên quan:** AC-04
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Màn hình soạn thư đang hiển thị với giới hạn 500 ký tự
- Đã nhập đúng 500 ký tự vào vùng giấy

### Act (Thực hiện)
- Cố gõ thêm 1 ký tự bất kỳ (ví dụ: chữ "A")

### Assert (Kiểm tra)
- Ký tự mới không xuất hiện trong vùng giấy (bàn phím không cho nhập thêm)
- Bộ đếm ký tự hiển thị trạng thái đã đạt giới hạn (ví dụ: "0 ký tự còn lại" hoặc "500/500")
- Không có ký tự nào bị cắt bỏ từ nội dung hiện có

---

## TC-11-007: Chuyển đổi font chữ — toàn bộ nội dung đổi ngay lập tức

**AC liên quan:** AC-05
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Màn hình soạn thư đang hiển thị
- Đã gõ nội dung "Thân gửi bạn yêu quý của mình!" vào vùng giấy
- Font hiện tại đang ở font tay viết nhẹ

### Act (Thực hiện)
- Mở bảng chọn font
- Chọn font in ấn hiện đại (nét rõ, dễ đọc)

### Assert (Kiểm tra)
- Toàn bộ nội dung "Thân gửi bạn yêu quý của mình!" đổi sang font in ấn ngay lập tức
- Không có độ trễ đáng kể khi chuyển đổi
- Nội dung không bị mất sau khi đổi font

---

## TC-11-008: Chuyển ngược từ font in ấn về font tay viết

**AC liên quan:** AC-05 (BR-03)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Màn hình soạn thư đang hiển thị
- Đã gõ nội dung vào vùng giấy
- Font hiện tại đang ở font in ấn hiện đại

### Act (Thực hiện)
- Mở bảng chọn font
- Chọn font tay viết đứng (nét thẳng đứng, trang trọng)

### Assert (Kiểm tra)
- Toàn bộ nội dung đổi sang font tay viết đứng ngay lập tức
- Nội dung không bị mất hoặc thay đổi sau khi đổi font

---

## TC-11-009: Chọn màu nền giấy thư — nền đổi ngay, nội dung không thay đổi

**AC liên quan:** AC-06 (BR-06)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Màn hình soạn thư đang hiển thị với màu nền trắng (mặc định)
- Đã gõ một đoạn nội dung vào vùng giấy

### Act (Thực hiện)
- Mở bảng chọn màu nền giấy thư
- Chọn màu kem (hoặc bất kỳ màu nào trong bộ có sẵn)

### Assert (Kiểm tra)
- Nền giấy thư đổi sang màu kem ngay lập tức
- Ô soạn thảo và toàn bộ nội dung đã nhập không thay đổi
- Có thể chọn lại màu khác và nền đổi tiếp theo màu mới

---

## TC-11-010: Hiển thị đủ ít nhất năm màu nền giấy thư

**AC liên quan:** AC-06 (BR-06)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Màn hình soạn thư đang hiển thị
- Chưa mở bảng chọn màu nền

### Act (Thực hiện)
- Mở bảng chọn màu nền giấy thư

### Assert (Kiểm tra)
- Bảng màu hiển thị ít nhất năm tùy chọn: trắng, kem, hồng nhạt, xanh nhạt, vàng nhạt
- Mỗi màu có thể chọn được và khi chọn thì nền thay đổi tương ứng

---

## TC-11-011: Bật kẻ dòng ngang trong ô soạn thảo

**AC liên quan:** AC-07 (BR-08)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Màn hình soạn thư đang hiển thị ở chế độ không kẻ dòng (mặc định)
- Đã gõ một đoạn nội dung vào vùng giấy

### Act (Thực hiện)
- Nhấn tùy chọn "Kẻ dòng" (hoặc tương đương) để bật chế độ kẻ dòng ngang

### Assert (Kiểm tra)
- Các dòng kẻ ngang xuất hiện trong ô soạn thảo ngay lập tức
- Nội dung đã nhập vẫn giữ nguyên, không bị xóa hoặc thay đổi
- Bàn phím ảo (nếu đang hiển thị) không bị ảnh hưởng

---

## TC-11-012: Tắt kẻ dòng ngang — nội dung giữ nguyên

**AC liên quan:** AC-08 (BR-08)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Màn hình soạn thư đang ở chế độ có kẻ dòng ngang
- Đã gõ một đoạn nội dung vào vùng giấy

### Act (Thực hiện)
- Nhấn tùy chọn "Không kẻ dòng" (hoặc tương đương) để tắt chế độ kẻ dòng

### Assert (Kiểm tra)
- Các dòng kẻ ngang biến mất khỏi ô soạn thảo ngay lập tức
- Nội dung đã nhập vẫn giữ nguyên, không bị xóa hoặc thay đổi

---

## TC-11-013: Đổi màu chữ cho một đoạn — các đoạn còn lại không bị ảnh hưởng

**AC liên quan:** AC-09 (BR-09)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Màn hình soạn thư đang hiển thị
- Đã gõ hai đoạn văn bản: "Đoạn một: xin chào." và "Đoạn hai: hẹn gặp lại."
- Cả hai đoạn đang hiển thị với màu chữ mặc định

### Act (Thực hiện)
- Bôi đen chỉ đoạn "Đoạn một: xin chào."
- Mở bảng màu chữ
- Chọn màu đỏ

### Assert (Kiểm tra)
- Chỉ đoạn "Đoạn một: xin chào." đổi sang màu đỏ
- Đoạn "Đoạn hai: hẹn gặp lại." giữ nguyên màu mặc định
- Có thể lặp lại thao tác đổi màu cho đoạn hai mà không ảnh hưởng đoạn một

---

## TC-11-014: Đoạn chưa chọn màu giữ màu mặc định

**AC liên quan:** AC-09 (BR-09)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Màn hình soạn thư đang hiển thị
- Đã gõ ba đoạn văn bản
- Chỉ đoạn thứ nhất đã được đổi sang màu xanh lá

### Act (Thực hiện)
- Quan sát màu chữ của đoạn thứ hai và đoạn thứ ba (chưa thao tác)

### Assert (Kiểm tra)
- Đoạn thứ hai và đoạn thứ ba hiển thị màu chữ mặc định
- Không có đoạn nào bị ảnh hưởng màu sắc ngoài ý muốn

---

## TC-11-015: Thêm sticker miễn phí vào thư — không đè lên vùng chữ

**AC liên quan:** AC-10 (BR-05)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang soạn nội dung thư với một đoạn văn bản đã nhập
- Bộ sticker miễn phí đang khả dụng (đã tải về)

### Act (Thực hiện)
- Mở bộ sticker
- Chọn một sticker miễn phí
- Đặt sticker vào vùng xung quanh nội dung thư

### Assert (Kiểm tra)
- Sticker xuất hiện ở vị trí được chọn trên template
- Sticker không đè lên vùng chữ đang soạn
- Nội dung thư vẫn đọc được sau khi thêm sticker
- Người nhận cũng sẽ thấy sticker này khi xem thư (ghi nhận để kiểm tra ở bước gửi)

---

## TC-11-016: Soạn thảo vẫn hoạt động bình thường khi mất mạng

**AC liên quan:** AC-11 (BR-10)
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đang ở màn hình soạn thư
- Tắt kết nối mạng trên thiết bị (bật chế độ máy bay hoặc tắt Wi-Fi/dữ liệu di động)

### Act (Thực hiện)
- Nhập một đoạn chữ vào vùng giấy
- Mở bảng chọn font và chuyển sang font khác
- Mở bảng màu nền và chọn màu khác
- Mở bảng màu chữ và đổi màu cho một đoạn
- Bật/tắt kẻ dòng ngang
- Chọn sticker đã tải về trước đó và đặt lên thư

### Assert (Kiểm tra)
- Tất cả thao tác trên đều thực hiện được bình thường
- Mỗi thay đổi phản ánh ngay lên màn hình
- Không xuất hiện thông báo lỗi hay màn hình mất kết nối
- Nội dung đang soạn không bị mất

---

## TC-11-017: Tải sticker mới thất bại khi mất mạng — hiển thị thông báo đúng

**AC liên quan:** AC-12 (BR-11)
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đang ở màn hình soạn thư
- Thiết bị đang mất kết nối mạng
- Có sticker trong bộ sưu tập chưa được tải về thiết bị

### Act (Thực hiện)
- Mở bộ sticker
- Chọn một sticker chưa có sẵn trên thiết bị (sticker chưa tải)

### Assert (Kiểm tra)
- Hệ thống hiển thị thông báo: "Không có kết nối. Vui lòng thử lại khi có mạng."
- Sticker đó không được thêm vào thư
- Sticker đã tải về trước đó vẫn chọn và sử dụng được bình thường

---

## TC-11-018: Sticker Premium chưa tải — thất bại khi mất mạng

**AC liên quan:** AC-12 (BR-11)
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng có gói Premium nhưng một số sticker Premium chưa được tải về thiết bị
- Thiết bị đang mất kết nối mạng

### Act (Thực hiện)
- Mở bộ sticker
- Chọn sticker Premium chưa được tải về thiết bị

### Assert (Kiểm tra)
- Hệ thống hiển thị thông báo: "Không có kết nối. Vui lòng thử lại khi có mạng."
- Sticker không được thêm vào thư
- Các sticker Premium đã tải trước đó vẫn dùng được

---

## TC-11-019: Hiển thị hộp thoại xác nhận khi thoát giữa chừng

**AC liên quan:** (Mục 5 — Ngoại lệ)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Màn hình soạn thư đang hiển thị
- Đã gõ một số nội dung vào vùng giấy (ví dụ: "Đây là nội dung thử nghiệm")

### Act (Thực hiện)
- Nhấn nút quay lại / thoát màn hình soạn thư

### Assert (Kiểm tra)
- Hộp thoại xác nhận "Bỏ thư này?" xuất hiện
- Hộp thoại có ít nhất hai lựa chọn: xác nhận thoát và hủy bỏ
- Màn hình soạn thư vẫn hiển thị phía sau hộp thoại

---

## TC-11-020: Xác nhận thoát thì nội dung bị mất

**AC liên quan:** (Mục 5 — Ngoại lệ)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Hộp thoại "Bỏ thư này?" đang hiển thị
- Nội dung "Đây là nội dung thử nghiệm" đang có trong vùng giấy

### Act (Thực hiện)
- Nhấn nút xác nhận thoát (ví dụ: "Bỏ" hoặc "Xác nhận")

### Assert (Kiểm tra)
- Màn hình soạn thư đóng lại
- Nội dung "Đây là nội dung thử nghiệm" không được lưu lại
- Người dùng được đưa về màn hình trước đó

---

## TC-11-021: Hủy hộp thoại — quay lại soạn thư với nội dung còn nguyên

**AC liên quan:** (Mục 5 — Ngoại lệ)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Hộp thoại "Bỏ thư này?" đang hiển thị
- Nội dung "Đây là nội dung thử nghiệm" đang có trong vùng giấy

### Act (Thực hiện)
- Nhấn nút hủy (ví dụ: "Hủy" hoặc "Tiếp tục soạn")

### Assert (Kiểm tra)
- Hộp thoại đóng lại
- Màn hình soạn thư hiển thị lại với nội dung "Đây là nội dung thử nghiệm" còn nguyên
- Người dùng có thể tiếp tục soạn thư

---

## TC-11-022: Bàn phím ảo che khuất vùng soạn thảo thì tự cuộn lên

**AC liên quan:** (Mục 5 — Ngoại lệ)
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Màn hình soạn thư đang hiển thị
- Template có vùng giấy dài chiếm gần hết màn hình

### Act (Thực hiện)
- Nhấn vào vùng giấy ở phía dưới màn hình để mở bàn phím ảo
- Bắt đầu gõ chữ khi bàn phím đang che khuất vùng soạn thảo

### Assert (Kiểm tra)
- Vùng soạn thảo tự động cuộn lên phía trên
- Vị trí con trỏ (ký tự đang nhập) luôn hiển thị phía trên bàn phím ảo
- Người dùng nhìn thấy nội dung đang gõ mà không cần cuộn thủ công

---

## TC-11-023: Danh sách sticker lỗi mạng — hiển thị nút Thử lại

**AC liên quan:** (Mục 5 — Ngoại lệ)
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đang ở màn hình soạn thư
- Mạng bị lỗi hoặc máy chủ không phản hồi khi tải danh sách sticker

### Act (Thực hiện)
- Mở bộ sticker
- Quan sát trạng thái hiển thị của bộ sticker

### Assert (Kiểm tra)
- Bộ sticker hiển thị trạng thái lỗi (không hiển thị danh sách trống không có thông báo)
- Có nút "Thử lại" để người dùng tải lại danh sách
- Sticker đã được thêm vào thư trước đó vẫn giữ nguyên trên template

---

## TC-11-024: Người dùng chưa đăng nhập — chuyển hướng về màn hình đăng nhập

**AC liên quan:** (Mục 5 — Ngoại lệ)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng chưa đăng nhập vào ứng dụng (hoặc phiên đăng nhập đã hết hạn)

### Act (Thực hiện)
- Cố gắng truy cập vào luồng soạn thư (ví dụ: nhấn nút tạo thư mới)

### Assert (Kiểm tra)
- Hệ thống không cho phép vào màn hình soạn thư
- Người dùng được chuyển về màn hình đăng nhập trước

---

## TC-11-025: Thoát app giữa chừng — nội dung bị mất khi mở lại

**AC liên quan:** (Mục 5 — Ngoại lệ)
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đang soạn nội dung thư với nội dung đáng kể đã nhập
- Ứng dụng đang chạy bình thường

### Act (Thực hiện)
- Vuốt tắt ứng dụng hoặc mô phỏng hệ điều hành thu hồi bộ nhớ
- Mở lại ứng dụng và vào luồng soạn thư mới

### Assert (Kiểm tra)
- Nội dung đang soạn trước đó không được khôi phục (không có tính năng lưu nháp)
- Người dùng bắt đầu soạn thư từ đầu
- Không có thông báo lỗi bất thường khi mở lại

---

## TC-11-026: Sticker Premium hiển thị nhãn khóa với người dùng gói thường

**AC liên quan:** AC-10 (BR-05)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang đăng nhập với tài khoản gói thường (không có Premium)
- Màn hình soạn thư đang hiển thị

### Act (Thực hiện)
- Mở bộ sticker
- Tìm đến sticker được đánh dấu Premium

### Assert (Kiểm tra)
- Sticker Premium hiển thị nhãn hoặc biểu tượng khóa
- Người dùng gói thường không thể đặt sticker Premium trực tiếp lên thư
- Hệ thống có thể hiển thị gợi ý mở khóa bằng Dấu hoặc nâng cấp Premium

---

## TC-11-027: Bộ đếm ký tự không hiển thị số âm khi đạt giới hạn

**AC liên quan:** AC-03, AC-04
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Màn hình soạn thư đang hiển thị với giới hạn 500 ký tự
- Đã nhập đúng 500 ký tự vào vùng giấy

### Act (Thực hiện)
- Quan sát bộ đếm ký tự còn lại
- Cố gõ thêm ký tự (hệ thống không cho nhập)

### Assert (Kiểm tra)
- Bộ đếm hiển thị "0" hoặc "500/500", không hiển thị số âm
- Không xảy ra lỗi crash hoặc hiển thị bất thường

---

## TC-11-028: Định dạng in đậm giữ nguyên sau khi đổi font

**AC liên quan:** AC-02, AC-05
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Màn hình soạn thư đang hiển thị
- Đã gõ nội dung "Xin chào bạn thân mến"
- Đã áp định dạng in đậm cho đoạn "bạn thân mến"
- Font hiện tại là font tay viết nhẹ

### Act (Thực hiện)
- Mở bảng chọn font
- Chuyển sang font in ấn cổ điển

### Assert (Kiểm tra)
- Toàn bộ nội dung đổi sang font in ấn cổ điển
- Đoạn "bạn thân mến" vẫn giữ định dạng in đậm sau khi đổi font
- Nội dung không bị mất hoặc thay đổi

---

## TC-11-029: Màu nền giấy thư hiển thị đúng khi người nhận xem thư

**AC liên quan:** AC-06 (BR-06)
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng A đã soạn thư với màu nền hồng nhạt và gửi đến người dùng B
- Người dùng B nhận được thư

### Act (Thực hiện)
- Người dùng B mở thư và xem nội dung

### Assert (Kiểm tra)
- Màu nền giấy thư hiển thị đúng là hồng nhạt (đúng như người gửi đã chọn)
- Sticker trang trí (nếu có) cũng hiển thị đúng

---

## TC-11-030: Kẻ dòng hiển thị khi người nhận xem thư

**AC liên quan:** AC-07, AC-08 (BR-08)
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng A soạn thư với chế độ kẻ dòng đang bật và gửi đến người dùng B
- Người dùng B nhận được thư

### Act (Thực hiện)
- Người dùng B mở thư và xem nội dung

### Assert (Kiểm tra)
- Các dòng kẻ ngang vẫn hiển thị trong thư như người gửi đã thiết lập
- Nội dung thư vẫn đọc được bình thường

---

## TC-11-031: Mất kết nối giữa chừng — nội dung đang soạn không bị mất

**AC liên quan:** AC-11 (BR-10, Mục 5)
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đang soạn thư với kết nối mạng bình thường
- Đã nhập khoảng 200 ký tự vào vùng giấy

### Act (Thực hiện)
- Tắt kết nối mạng (bật chế độ máy bay)
- Tiếp tục nhập thêm nội dung vào vùng giấy
- Chọn font, đổi màu nền, sử dụng sticker đã tải về trước

### Assert (Kiểm tra)
- Nội dung trước khi mất mạng vẫn còn nguyên trên màn hình
- Các thao tác tiếp theo (nhập chữ, chọn font, đổi màu) vẫn thực hiện được
- Không có thông báo lỗi nào xuất hiện trừ khi người dùng cố tải sticker mới

# Test Cases — Hộp thư đã gửi & Theo dõi trạng thái (SM-021 / 019-hop-thu-da-gui)

## TC-19-001: Danh sách thư đã gửi đúng thứ tự mới nhất lên trước

**AC liên quan:** AC-01 / BR-01
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập vào ứng dụng với tài khoản đã gửi ít nhất ba thư vào các thời điểm khác nhau
- Ghi nhận thời điểm gửi của từng thư (thư A gửi trước, thư B gửi sau, thư C gửi sau cùng)

### Act (Thực hiện)
- Mở màn hình "Hộp thư đã gửi"

### Assert (Kiểm tra)
- Thư C (gửi sau cùng) hiển thị đầu danh sách
- Thư B hiển thị ở vị trí thứ hai
- Thư A (gửi trước nhất) hiển thị ở cuối danh sách

---

## TC-19-002: Hiển thị đúng ba trạng thái link trên cùng một thư

**AC liên quan:** AC-02 / BR-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Tài khoản có một thư đã gửi với ba link:
  - Link 1: người nhận đã mở (trạng thái "Đã đọc")
  - Link 2: chưa ai mở, còn trong vòng bảy ngày (trạng thái "Đang hoạt động")
  - Link 3: chưa ai mở, đã quá bảy ngày (trạng thái "Hết hạn")

### Act (Thực hiện)
- Mở màn hình "Hộp thư đã gửi"
- Nhấn vào thư đó để xem chi tiết

### Assert (Kiểm tra)
- Link 1 hiển thị nhãn "Đã đọc" kèm thời điểm mở cụ thể
- Link 2 hiển thị nhãn "Đang hoạt động"
- Link 3 hiển thị nhãn "Hết hạn"
- Ba link hiển thị ba nhãn trạng thái khác nhau, không bị nhầm lẫn

---

## TC-19-003: Hiển thị thời điểm mở kèm nhãn "Đã đọc"

**AC liên quan:** AC-02 / BR-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Tài khoản có thư với link đã được người nhận mở vào một thời điểm cụ thể (ví dụ: 10:30 ngày 20/06/2026)

### Act (Thực hiện)
- Mở màn hình "Hộp thư đã gửi"
- Nhấn vào thư đó để xem chi tiết

### Assert (Kiểm tra)
- Link hiển thị nhãn "Đã đọc"
- Thời điểm mở được hiển thị cùng với nhãn (ví dụ: "10:30, 20/06/2026")

---

## TC-19-004: Hiển thị tổng số link đã tạo cho mỗi thư

**AC liên quan:** BR-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Tài khoản có một thư đã gửi đến ba người nhận (ba link đã tạo)

### Act (Thực hiện)
- Mở màn hình "Hộp thư đã gửi"

### Assert (Kiểm tra)
- Thư đó hiển thị số người nhận là "3" (hoặc dạng tương đương theo UI)

---

## TC-19-005: Tạo link mới thành công cho link đã hết hạn

**AC liên quan:** AC-03 / BR-04
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập với tài khoản gói Thường còn hạn mức tháng (ví dụ: còn 5 thư)
- Tài khoản có thư với ít nhất một link trạng thái "Hết hạn"

### Act (Thực hiện)
- Mở màn hình "Hộp thư đã gửi"
- Nhấn vào thư có link hết hạn
- Nhấn nút "Tạo link mới" cho link hết hạn đó

### Assert (Kiểm tra)
- Link mới được tạo thành công
- Link mới hiển thị trạng thái "Đang hoạt động"
- Có thể sao chép hoặc chia sẻ link mới

---

## TC-19-006: Tạo link mới trừ hạn mức tháng của gói Thường

**AC liên quan:** AC-03 / BR-04
**Loại:** Integration
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Đăng nhập với tài khoản gói Thường, ghi nhận hạn mức tháng hiện tại (ví dụ: còn 5 thư)
- Tài khoản có thư với link trạng thái "Hết hạn"

### Act (Thực hiện)
- Nhấn nút "Tạo link mới" cho link hết hạn

### Assert (Kiểm tra)
- Hạn mức tháng sau khi tạo giảm đúng một đơn vị (còn 4 thư)
- Hạn mức hiển thị đã được cập nhật trên giao diện

---

## TC-19-007: Không cho tạo link mới cho thư đã đọc

**AC liên quan:** AC-04 / BR-05
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Tài khoản có thư với link đã được người nhận mở (trạng thái "Đã đọc")

### Act (Thực hiện)
- Mở màn hình "Hộp thư đã gửi"
- Nhấn vào thư đó để xem chi tiết
- Cố gắng tìm và nhấn "Tạo link mới" cho link "Đã đọc"

### Assert (Kiểm tra)
- Nút "Tạo link mới" không xuất hiện hoặc bị vô hiệu hóa cho link "Đã đọc"
- Nếu người dùng vẫn thao tác được, hệ thống hiển thị thông báo "thư đã được nhận" (hoặc tương đương)
- Không có link mới nào được tạo

---

## TC-19-008: Nút "Tạo link mới" chỉ xuất hiện cho link hết hạn

**AC liên quan:** BR-04 / BR-05
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Tài khoản có thư với ba link: một "Đang hoạt động", một "Đã đọc", một "Hết hạn"

### Act (Thực hiện)
- Mở chi tiết thư đó

### Assert (Kiểm tra)
- Nút "Tạo link mới" chỉ xuất hiện (và có thể nhấn) tại link trạng thái "Hết hạn"
- Nút "Tạo link mới" không xuất hiện hoặc bị vô hiệu hóa tại link "Đang hoạt động"
- Nút "Tạo link mới" không xuất hiện hoặc bị vô hiệu hóa tại link "Đã đọc"

---

## TC-19-009: Xem danh sách thư khi mất kết nối mạng

**AC liên quan:** AC-05 / BR-06
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập và mở màn hình "Hộp thư đã gửi" khi có kết nối mạng
- Đảm bảo danh sách đã tải thành công và hiển thị ít nhất một thư

### Act (Thực hiện)
- Tắt kết nối mạng (bật chế độ máy bay hoặc tắt WiFi/dữ liệu di động)
- Quan sát màn hình "Hộp thư đã gửi"

### Assert (Kiểm tra)
- Danh sách thư từ lần tải gần nhất vẫn hiển thị đầy đủ
- Trạng thái từng link vẫn hiển thị (theo dữ liệu lần tải gần nhất)
- Xuất hiện thông báo "Đang xem ngoại tuyến — dữ liệu có thể chưa cập nhật"

---

## TC-19-010: Không tạo được link mới khi mất kết nối mạng

**AC liên quan:** AC-06 / BR-07
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Tài khoản có thư với link trạng thái "Hết hạn"
- Tắt kết nối mạng trước khi thực hiện thao tác

### Act (Thực hiện)
- Mở màn hình "Hộp thư đã gửi" (xem dữ liệu offline)
- Nhấn nút "Tạo link mới" cho link hết hạn

### Assert (Kiểm tra)
- Hành động bị chặn; không có link mới nào được tạo
- Hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."

---

## TC-19-011: Tự động làm mới danh sách khi kết nối mạng được khôi phục

**AC liên quan:** BR-08
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đã tải danh sách thư khi có mạng, sau đó mất kết nối (đang xem offline)
- Trong khi offline, phía người nhận đã mở một link thư (trạng thái thực tế đổi sang "Đã đọc" trên máy chủ)

### Act (Thực hiện)
- Bật lại kết nối mạng (tắt chế độ máy bay hoặc kết nối lại WiFi/dữ liệu di động)
- Quan sát màn hình "Hộp thư đã gửi"

### Assert (Kiểm tra)
- Danh sách và trạng thái link tự động làm mới mà không cần người dùng thao tác thêm
- Trạng thái link phản ánh dữ liệu mới nhất (link vừa được đọc hiển thị "Đã đọc")
- Thông báo "Đang xem ngoại tuyến" biến mất sau khi dữ liệu được làm mới

---

## TC-19-012: Hiển thị trạng thái rỗng khi chưa có thư đã gửi

**AC liên quan:** Mục 5 — Không có thư đã gửi
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập với tài khoản mới chưa gửi bất kỳ thư nào

### Act (Thực hiện)
- Mở màn hình "Hộp thư đã gửi"

### Assert (Kiểm tra)
- Danh sách không hiển thị thư nào
- Màn hình hiển thị trạng thái rỗng với gợi ý tạo thư đầu tiên (nội dung gợi ý liên quan đến việc tạo/gửi thư)

---

## TC-19-013: Thông báo hết hạn mức khi cố tạo link mới

**AC liên quan:** Mục 5 — Hết hạn mức tháng
**Loại:** E2E
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Đăng nhập với tài khoản gói Thường đã dùng hết toàn bộ hạn mức tháng (còn 0 thư)
- Tài khoản có thư với link trạng thái "Hết hạn"

### Act (Thực hiện)
- Mở màn hình "Hộp thư đã gửi"
- Nhấn vào thư có link hết hạn
- Nhấn nút "Tạo link mới" cho link hết hạn đó

### Assert (Kiểm tra)
- Hệ thống hiển thị thông báo hết hạn mức tháng
- Thông báo có gợi ý nâng cấp Premium
- Không có link mới nào được tạo

---

## TC-19-014: Hiển thị lỗi và nút "Thử lại" khi không tải được dữ liệu

**AC liên quan:** Mục 5 — Dữ liệu không tải được
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Mô phỏng trạng thái mạng có kết nối nhưng máy chủ không phản hồi (lỗi mạng hoặc lỗi máy chủ)
- Đăng nhập vào ứng dụng

### Act (Thực hiện)
- Mở màn hình "Hộp thư đã gửi"

### Assert (Kiểm tra)
- Màn hình hiển thị thông báo lỗi (không hiển thị danh sách trống trơn không giải thích)
- Có nút "Thử lại" để người dùng tải lại danh sách
- Nhấn "Thử lại" khi mạng phục hồi: danh sách tải thành công

---

## TC-19-015: Chuyển về màn hình đăng nhập khi chưa đăng nhập

**AC liên quan:** Mục 5 — Chưa đăng nhập
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Không đăng nhập vào ứng dụng (hoặc đăng xuất nếu đang đăng nhập)

### Act (Thực hiện)
- Cố truy cập màn hình "Hộp thư đã gửi" (qua deep link hoặc điều hướng trực tiếp)

### Assert (Kiểm tra)
- Hệ thống tự động chuyển hướng về màn hình đăng nhập
- Không hiển thị bất kỳ dữ liệu nào của hộp thư đã gửi

---

## TC-19-016: Dữ liệu giữ trong cache khi thoát và mở lại ứng dụng

**AC liên quan:** Mục 5 — Thoát app giữa chừng
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập và mở màn hình "Hộp thư đã gửi" khi có kết nối mạng
- Đảm bảo danh sách đã tải thành công

### Act (Thực hiện)
- Thoát khỏi ứng dụng hoàn toàn (đóng app, không chỉ đưa về nền)
- Mở lại ứng dụng và điều hướng đến màn hình "Hộp thư đã gửi"

### Assert (Kiểm tra)
- Danh sách thư hiển thị ngay lập tức từ cache, không cần chờ tải lại từ đầu
- Dữ liệu cache khớp với dữ liệu đã thấy trước khi thoát

---

## TC-19-017: Danh sách cuộn mượt khi có nhiều thư

**AC liên quan:** BR-01
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Tài khoản có hơn 20 thư đã gửi

### Act (Thực hiện)
- Mở màn hình "Hộp thư đã gửi"
- Cuộn xuống hết danh sách

### Assert (Kiểm tra)
- Danh sách cuộn mượt, không bị giật hoặc mất dữ liệu
- Thứ tự thư vẫn đúng (mới nhất lên trước) sau khi cuộn
- Không có thư nào bị mất hoặc bị nhân đôi

---

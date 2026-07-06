# Test Cases — Nhận thư qua Link (015-nhan-thu-qua-link)

## TC-15-001: Xem thư trên trình duyệt không cần cài app

**AC liên quan:** AC-01
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Chuẩn bị link thư hợp lệ, chưa được ai mở, chưa hết hạn
- Sử dụng thiết bị (điện thoại hoặc máy tính) chưa cài ứng dụng StampMail
- Mở trình duyệt web trên thiết bị thử nghiệm

### Act (Thực hiện)
- Nhập link thư vào thanh địa chỉ trình duyệt và nhấn truy cập

### Assert (Kiểm tra)
- Trang web tải thành công, không hiển thị màn hình yêu cầu đăng nhập
- Nội dung thư hiển thị đầy đủ: tiêu đề thư, nội dung thư, hình ảnh tem
- Không có thông báo lỗi hoặc yêu cầu cài đặt ứng dụng trước khi xem

---

## TC-15-002: Animation mở thư phát trên trình duyệt (SM-019)

**AC liên quan:** AC-01
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Chuẩn bị link thư hợp lệ, chưa được ai mở
- Sử dụng thiết bị chưa cài StampMail, mở trình duyệt web

### Act (Thực hiện)
- Truy cập link thư trên trình duyệt

### Assert (Kiểm tra)
- Animation mở thư (SM-019) được phát trước khi nội dung thư xuất hiện
- Sau khi animation kết thúc, nội dung thư và tem hiển thị đầy đủ

---

## TC-15-003: Link tự mở trong app khi đã cài StampMail

**AC liên quan:** AC-02
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Chuẩn bị link thư hợp lệ, chưa được ai mở
- Sử dụng thiết bị đã cài ứng dụng StampMail

### Act (Thực hiện)
- Nhấn vào link thư (nhận qua DM mạng xã hội hoặc nhập vào trình duyệt)

### Assert (Kiểm tra)
- Ứng dụng StampMail tự động khởi chạy (không mở trình duyệt web)
- Nội dung thư hiển thị đầy đủ bên trong ứng dụng StampMail

---

## TC-15-004: Người thứ hai mở link thấy thông báo đã được nhận

**AC liên quan:** AC-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Chuẩn bị link thư hợp lệ
- Người dùng A đã mở link trước và xem thư thành công
- Chuẩn bị thiết bị của người dùng B (có thể là cùng thiết bị hoặc thiết bị khác)

### Act (Thực hiện)
- Người dùng B nhấn cùng link thư đó

### Assert (Kiểm tra)
- Trang web hiển thị thông báo: thư này đã được nhận bởi người khác
- Nội dung thư (tiêu đề, nội dung, tem) không hiển thị
- Không có lỗi kỹ thuật hoặc trang trắng

---

## TC-15-005: Cùng người mở lại link đã dùng

**AC liên quan:** AC-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Chuẩn bị link thư hợp lệ
- Người dùng A đã mở link và xem thư thành công lần đầu

### Act (Thực hiện)
- Người dùng A nhấn lại đúng link đó lần thứ hai

### Assert (Kiểm tra)
- Trang web hiển thị thông báo thư đã được nhận
- Nội dung thư không hiển thị lại lần nữa

---

## TC-15-006: Gợi ý tải StampMail xuất hiện sau khi đọc thư

**AC liên quan:** AC-04
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Chuẩn bị link thư hợp lệ, chưa được ai mở
- Sử dụng thiết bị chưa cài StampMail, mở trình duyệt web

### Act (Thực hiện)
- Truy cập link thư và xem đầy đủ nội dung thư (chờ animation kết thúc)

### Assert (Kiểm tra)
- Gợi ý tải StampMail xuất hiện sau khi animation mở thư kết thúc
- Gợi ý có nội dung đề cập đến việc lưu tem và nhận thư của riêng mình
- Có nút hoặc link "Tải StampMail" hiển thị rõ ràng

---

## TC-15-007: Nút "Tải StampMail" dẫn đến cửa hàng ứng dụng

**AC liên quan:** AC-04
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đã xem thư trên trình duyệt và gợi ý tải app đang hiển thị

### Act (Thực hiện)
- Nhấn nút "Tải StampMail" trên trang web

### Assert (Kiểm tra)
- Trên iOS: chuyển đến App Store đúng trang của ứng dụng StampMail
- Trên Android: chuyển đến Google Play Store đúng trang của ứng dụng StampMail

---

## TC-15-008: Tem tự động vào Album sau khi đăng ký/đăng nhập

**AC liên quan:** AC-05
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Chuẩn bị link thư hợp lệ chứa ít nhất một tem
- Sử dụng thiết bị đã đọc thư trên trình duyệt (gợi ý tải StampMail đang hiển thị)
- Chuẩn bị tài khoản StampMail để đăng nhập

### Act (Thực hiện)
- Nhấn "Tải StampMail", cài đặt ứng dụng (bỏ qua nếu đã cài)
- Mở ứng dụng StampMail và đăng nhập bằng tài khoản đã có
- Hoàn tất đăng nhập thành công

### Assert (Kiểm tra)
- Tem trong thư được tự động thêm vào Album của người nhận
- Vào màn hình Album trong app và thấy tem vừa nhận xuất hiện
- Có thông báo hoặc dấu hiệu cho thấy tem mới vừa được thêm vào

---

## TC-15-009: Tem KHÔNG được lưu nếu chỉ xem web mà không đăng nhập

**AC liên quan:** AC-05
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Chuẩn bị link thư hợp lệ chứa ít nhất một tem
- Sử dụng thiết bị chưa cài StampMail
- Có tài khoản StampMail (nhưng chưa đăng nhập trong phiên này)

### Act (Thực hiện)
- Mở link thư trên trình duyệt và đọc toàn bộ nội dung
- Không nhấn "Tải StampMail" và không đăng nhập

### Assert (Kiểm tra)
- Đăng nhập vào StampMail qua cách khác (không qua link thư)
- Vào Album và xác nhận tem từ thư đó KHÔNG xuất hiện

---

## TC-15-010: Mở link thư đã hết hạn (quá 7 ngày)

**AC liên quan:** AC-06
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Chuẩn bị link thư đã được tạo hơn 7 ngày trước (đã hết hạn)
- Sử dụng bất kỳ thiết bị nào có trình duyệt web

### Act (Thực hiện)
- Nhấn hoặc truy cập link thư đã hết hạn

### Assert (Kiểm tra)
- Trang web hiển thị thông báo link đã hết hạn
- Nội dung thư (tiêu đề, nội dung, tem) không hiển thị
- Thông báo rõ ràng, thân thiện, không hiển thị lỗi kỹ thuật

---

## TC-15-011: Mở link khi không có kết nối mạng ngay từ đầu

**AC liên quan:** AC-07
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Chuẩn bị link thư hợp lệ
- Tắt hoàn toàn kết nối mạng (WiFi và dữ liệu di động) trên thiết bị

### Act (Thực hiện)
- Truy cập link thư khi không có kết nối mạng

### Assert (Kiểm tra)
- Trang web hiển thị thông báo "Không có kết nối mạng. Vui lòng thử lại khi có mạng."
- Nội dung thư không hiển thị (không có tiêu đề, nội dung, tem)
- Không có lỗi kỹ thuật hoặc trang trắng

---

## TC-15-012: Mất mạng giữa chừng sau khi đã tải xong thư

**AC liên quan:** AC-08
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Chuẩn bị link thư hợp lệ
- Mở link thư và chờ nội dung (thư + tem) tải hoàn tất trên trình duyệt

### Act (Thực hiện)
- Sau khi nội dung tải xong, tắt kết nối mạng (WiFi/dữ liệu di động)
- Tiếp tục đọc thư và xem tem trên trang

### Assert (Kiểm tra)
- Nội dung thư và tem vẫn hiển thị đầy đủ
- Trang hiển thị thông báo nhỏ "Đang xem ngoại tuyến"
- Nút đăng nhập/đăng ký bị vô hiệu hóa

---

## TC-15-013: Nhấn đăng nhập khi đang xem ngoại tuyến

**AC liên quan:** AC-08
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đã tải xong nội dung thư trên trình duyệt
- Mất kết nối mạng (trang đang hiển thị thông báo "Đang xem ngoại tuyến")

### Act (Thực hiện)
- Nhấn nút đăng nhập hoặc "Tải StampMail" trong khi không có mạng

### Assert (Kiểm tra)
- Thao tác bị chặn, không chuyển màn hình
- Hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."
- Dữ liệu đã nhập (nếu có) không bị mất

---

## TC-15-014: Nhấn "Tải StampMail" khi không có mạng (từ đầu)

**AC liên quan:** AC-07 / BR-09
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Thiết bị không có kết nối mạng
- Người dùng đang ở màn hình lỗi mạng (đã thử mở link nhưng không tải được)

### Act (Thực hiện)
- Nhấn nút "Tải StampMail" hoặc thực hiện thao tác đăng nhập/đăng ký

### Assert (Kiểm tra)
- Hệ thống chặn thao tác và hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."
- Dữ liệu đã nhập (nếu có) không bị mất

---

## TC-15-015: Lỗi máy chủ khi tải thư — hiển thị nút thử lại

**AC liên quan:** Ngoại lệ (Mục 5)
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Chuẩn bị link thư hợp lệ
- Môi trường kiểm thử có thể giả lập lỗi máy chủ (server error)

### Act (Thực hiện)
- Truy cập link thư khi máy chủ trả về lỗi

### Assert (Kiểm tra)
- Trang web hiển thị màn hình lỗi thân thiện (không phải lỗi kỹ thuật thô)
- Có nút "Thử lại" để người dùng tải lại thủ công
- Nhấn "Thử lại" khi máy chủ phục hồi: nội dung thư tải thành công

---

## TC-15-016: Mở link sai định dạng hoặc không tồn tại

**AC liên quan:** Ngoại lệ (Mục 5)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Chuẩn bị một URL có dạng link thư StampMail nhưng với ID không tồn tại hoặc sai định dạng
  (ví dụ: link bị sửa đổi, cắt bớt, hoặc ID ngẫu nhiên không có trong hệ thống)

### Act (Thực hiện)
- Truy cập link không hợp lệ trên trình duyệt web

### Assert (Kiểm tra)
- Trang web hiển thị thông báo "link không hợp lệ"
- Không hiển thị nội dung thư của bất kỳ ai
- Không có nút "Thử lại"
- Không hiển thị lỗi kỹ thuật (mã lỗi HTTP thô, stack trace)

---

## TC-15-017: Đóng trình duyệt giữa chừng rồi mở lại link

**AC liên quan:** Ngoại lệ (Mục 5)
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Chuẩn bị link thư hợp lệ, chưa được ai mở
- Mở link trên trình duyệt, bắt đầu xem nhưng chưa đăng nhập

### Act (Thực hiện)
- Đóng trình duyệt hoặc tab giữa chừng (chưa đăng nhập)
- Mở lại đúng link đó sau vài phút (link vẫn còn trong hạn 7 ngày)

### Assert (Kiểm tra)
- Link vẫn cho phép truy cập lại (vì chưa có người đăng nhập và nhận tem)
- Nội dung thư hiển thị lại bình thường

---

## TC-15-018: Xem thư trên trình duyệt máy tính (desktop)

**AC liên quan:** AC-01
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Chuẩn bị link thư hợp lệ, chưa được ai mở
- Sử dụng máy tính (desktop/laptop) với trình duyệt web phổ biến (Chrome, Safari, Firefox)

### Act (Thực hiện)
- Nhập link thư vào trình duyệt máy tính và nhấn truy cập

### Assert (Kiểm tra)
- Trang web tải thành công và hiển thị đầy đủ nội dung thư
- Bố cục hiển thị phù hợp với màn hình máy tính (không bị lỗi giao diện)
- Tem và nội dung thư hiển thị đúng

---

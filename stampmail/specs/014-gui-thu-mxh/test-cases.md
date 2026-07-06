# Test Cases — Gửi thư qua MXH (014-gui-thu-mxh)

## TC-14-001: Danh sách tám nền tảng hiển thị đầy đủ

**AC liên quan:** AC-07
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập
- Người dùng đã soạn xong thư và đã xem trước (SM-015)
- Người dùng vừa xác nhận gửi thư từ màn hình xem trước

### Act (Thực hiện)
- Quan sát màn hình chọn nền tảng vừa hiển thị

### Assert (Kiểm tra)
- Màn hình hiển thị đúng tám nền tảng: "Facebook Messenger", "Instagram DM", "TikTok DM", "Threads", "Zalo", "WhatsApp", "iMessage", "Twitter/X DM"
- Không nền tảng nào bị thiếu hoặc bị trùng lặp

---

## TC-14-002: Chọn nền tảng mở DM với link điền sẵn

**AC liên quan:** AC-01
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã xác nhận gửi thư; màn hình chọn nền tảng đang hiển thị
- Ứng dụng Zalo đã được cài trên thiết bị

### Act (Thực hiện)
- Nhấn "Gửi qua Zalo"

### Assert (Kiểm tra)
- Ứng dụng Zalo mở ra ở màn hình DM (giao diện nhắn tin)
- Ô soạn tin đã được điền sẵn link thư (bắt đầu bằng URL của StampMail)
- Người dùng chỉ cần chọn người nhận và nhấn gửi trong Zalo

---

## TC-14-003: Từ chối gửi khi tài khoản Free đã đạt giới hạn mười thư

**AC liên quan:** AC-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Tài khoản gói Thường (Free) đã gửi đủ mười thư trong tháng hiện tại
- Người dùng đã soạn xong thư thứ mười một và vào màn hình chọn nền tảng

### Act (Thực hiện)
- Nhấn chọn bất kỳ nền tảng nào (VD: "Gửi qua Zalo") và xác nhận gửi

### Assert (Kiểm tra)
- Hệ thống không tạo link mới, không mở ứng dụng Zalo
- Hiển thị thông báo: người dùng đã đạt giới hạn mười thư trong tháng
- Thông báo có gợi ý "nâng cấp Premium" hoặc "chờ đầu tháng mới"

---

## TC-14-004: Link chỉ mở được một lần — lần mở thứ hai bị từ chối

**AC liên quan:** AC-03
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Người gửi đã gửi link thư thành công cho người nhận
- Người nhận đã mở link lần đầu và đọc thư thành công

### Act (Thực hiện)
- Người nhận (hoặc bất kỳ người nào khác) nhấn vào đúng link đó lần thứ hai

### Assert (Kiểm tra)
- Hệ thống không hiển thị nội dung thư
- Trang (hoặc màn hình) hiển thị thông báo: thư này đã được đọc
- Không có cách nào xem lại nội dung thư qua link đó

---

## TC-14-005: Người gửi nhận thông báo khi thư được đọc

**AC liên quan:** AC-04
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Người gửi đã gửi link thư thành công qua Zalo cho người nhận tên "Minh"
- Ứng dụng StampMail của người gửi đang chạy nền hoặc đang mở

### Act (Thực hiện)
- Người nhận "Minh" mở link thư và đọc nội dung

### Assert (Kiểm tra)
- Người gửi nhận được thông báo push trong app với nội dung tương đương "Minh đã mở thư của bạn"
- Thông báo xuất hiện trong thời gian hợp lý sau khi người nhận mở link

---

## TC-14-006: Link tự hết hạn sau bảy ngày

**AC liên quan:** AC-05
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Người gửi đã tạo và gửi link thư
- Link chưa được ai mở
- Đã qua bảy ngày kể từ khi link được tạo (cần can thiệp môi trường kiểm thử để rút ngắn thời gian)

### Act (Thực hiện)
- Người nhận mở link thư trên trình duyệt hoặc trong ứng dụng

### Assert (Kiểm tra)
- Hệ thống không hiển thị nội dung thư
- Trang (hoặc màn hình) hiển thị thông báo: link đã hết hạn
- Không có cách nào truy cập nội dung qua link đó

---

## TC-14-007: Tài khoản Premium gửi không bị giới hạn

**AC liên quan:** AC-06
**Loại:** E2E
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Tài khoản gói Premium đã gửi hơn mười thư trong tháng hiện tại
- Người dùng đã soạn xong thêm một thư mới và vào màn hình chọn nền tảng

### Act (Thực hiện)
- Nhấn chọn nền tảng (VD: "Gửi qua WhatsApp") và xác nhận gửi

### Assert (Kiểm tra)
- Hệ thống tạo link mới thành công
- Không hiển thị thông báo giới hạn tháng
- Ứng dụng WhatsApp (hoặc nền tảng đã chọn) mở ra với link đã điền sẵn

---

## TC-14-008: Gửi thư đến nhiều nền tảng tạo link riêng cho mỗi nền tảng

**AC liên quan:** AC-08
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã xác nhận gửi thư; màn hình chọn nền tảng đang hiển thị
- Cả Zalo và Instagram DM đều có trong danh sách

### Act (Thực hiện)
- Chọn đồng thời hai nền tảng: "Zalo" và "Instagram DM"
- Xác nhận gửi

### Assert (Kiểm tra)
- Hệ thống tạo ra hai link khác nhau (hai URL không giống nhau)
- Zalo nhận một link, Instagram DM nhận một link khác
- Người dùng được hướng dẫn chia sẻ từng link qua từng app lần lượt

---

## TC-14-009: Attribution — người nhận cài app từ link được ghi nhận đúng nguồn

**AC liên quan:** AC-09
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Người gửi A đã gửi link thư cho người nhận B chưa có StampMail
- Người nhận B mở link trên trình duyệt; trang xem thư hiển thị với gợi ý tải StampMail

### Act (Thực hiện)
- Người nhận B nhấn gợi ý tải StampMail, tải về và cài đặt ứng dụng
- Người nhận B đăng ký tài khoản mới trong StampMail

### Assert (Kiểm tra)
- Hệ thống ghi nhận tài khoản mới của B được giới thiệu từ người gửi A
- Thông tin attribution được lưu đúng (có thể xác minh qua hộp thư đã gửi của A hoặc báo cáo)

---

## TC-14-010: Nhận 5 Dấu ngay khi tạo link thư thành công

**AC liên quan:** AC-10
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập và ghi nhận số Dấu hiện tại (VD: 100📮)
- Người dùng đã soạn xong thư và vào màn hình chọn nền tảng

### Act (Thực hiện)
- Chọn nền tảng (VD: "Gửi qua Zalo") và xác nhận gửi
- Hệ thống tạo link thư thành công

### Assert (Kiểm tra)
- Màn hình xác nhận gửi hiển thị thông báo nhỏ "Bạn kiếm được 5📮"
- Số Dấu của người dùng tăng thêm 5 (từ 100📮 lên 105📮)
- Số Dấu được cập nhật ngay lập tức mà không cần tải lại trang

---

## TC-14-011: Nhận 50 Dấu khi người nhận cài app (lượt ≤ 5 trong tháng)

**AC liên quan:** AC-11
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Người gửi A đã gửi link thư thành công cho người nhận B chưa có StampMail
- Người gửi A chưa đủ 5 lượt thưởng cài app trong tháng hiện tại
- Ghi nhận số Dấu hiện tại của người gửi A

### Act (Thực hiện)
- Người nhận B mở link thư, nhấn tải StampMail, cài đặt và tạo tài khoản mới thành công

### Assert (Kiểm tra)
- Người gửi A nhận được thông báo push: "Bạn vừa giới thiệu người dùng mới và nhận 50📮!"
- Số Dấu của người gửi A tăng thêm 50📮
- Thông báo xuất hiện trong thời gian hợp lý sau khi người nhận tạo tài khoản thành công

---

## TC-14-012: Không nhận thêm Dấu khi đã đủ 5 lượt cài app trong tháng

**AC liên quan:** AC-12
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Người gửi đã nhận thưởng cài app đúng 5 lần trong tháng hiện tại
- Ghi nhận số Dấu hiện tại của người gửi
- Người gửi gửi thêm link thư cho người nhận mới thứ 6 (chưa có StampMail)

### Act (Thực hiện)
- Người nhận thứ 6 mở link thư, cài StampMail và tạo tài khoản mới thành công

### Assert (Kiểm tra)
- Người gửi không nhận được thông báo thưởng 50📮
- Số Dấu của người gửi không thay đổi sau khi người nhận thứ 6 cài app
- Không có thông báo push nào về việc giới thiệu người dùng mới

---

## TC-14-013: Chặn tạo link khi mất kết nối mạng

**AC liên quan:** AC-13, BR-12
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã soạn xong thư và đang ở màn hình chọn nền tảng
- Thiết bị không có kết nối mạng (tắt Wi-Fi và dữ liệu di động)

### Act (Thực hiện)
- Nhấn chọn nền tảng (VD: "Gửi qua Zalo") và xác nhận

### Assert (Kiểm tra)
- Hệ thống không tạo link
- Không mở ứng dụng Zalo
- Hiển thị thông báo: "Không có kết nối. Vui lòng thử lại khi có mạng."
- Thư đã soạn vẫn còn nguyên trên màn hình (không mất dữ liệu)

---

## TC-14-014: Gửi thành công sau khi kết nối được khôi phục

**AC liên quan:** AC-14, BR-12
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã thấy thông báo lỗi mạng (từ TC-14-013)
- Thư đã soạn vẫn hiển thị trên màn hình
- Kết nối mạng được khôi phục (bật lại Wi-Fi hoặc dữ liệu di động)

### Act (Thực hiện)
- Người dùng nhấn "Thử lại" (hoặc chọn lại nền tảng và xác nhận gửi)

### Assert (Kiểm tra)
- Hệ thống tạo link thư thành công
- Ứng dụng MXH đã chọn mở ra với link đã điền sẵn
- Luồng gửi tiếp tục bình thường như khi có mạng ngay từ đầu

---

## TC-14-015: Nền tảng MXH chưa cài — tự động sao chép link vào bộ nhớ tạm

**AC liên quan:** Trường hợp ngoại lệ (Mục 5)
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã xác nhận gửi thư; màn hình chọn nền tảng đang hiển thị
- Ứng dụng TikTok chưa được cài trên thiết bị

### Act (Thực hiện)
- Nhấn "Gửi qua TikTok DM"

### Assert (Kiểm tra)
- Ứng dụng TikTok không được mở (vì chưa cài)
- Link thư được tự động sao chép vào bộ nhớ tạm của thiết bị
- Hiển thị thông báo: link đã được sao chép, hướng dẫn người dùng tự dán vào bất kỳ ứng dụng nhắn tin nào

---

## TC-14-016: Lỗi phía máy chủ khi tạo link dù có mạng

**AC liên quan:** Trường hợp ngoại lệ (Mục 5)
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Người dùng đang trên màn hình chọn nền tảng và có kết nối mạng
- Máy chủ đang gặp sự cố (mô phỏng lỗi server trong môi trường kiểm thử)

### Act (Thực hiện)
- Nhấn chọn nền tảng và xác nhận gửi

### Assert (Kiểm tra)
- Hệ thống không tạo link thành công
- Hiển thị thông báo lỗi và nút "Thử lại"
- Nội dung thư đã soạn vẫn còn nguyên (người dùng không cần soạn lại)
- Nhấn "Thử lại" để gửi lại mà không cần soạn lại thư

---

## TC-14-017: Chưa đăng nhập — chuyển về màn hình đăng nhập

**AC liên quan:** Trường hợp ngoại lệ (Mục 5)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng chưa đăng nhập vào StampMail (phiên đăng nhập đã hết hạn)

### Act (Thực hiện)
- Người dùng cố gắng thực hiện thao tác gửi thư (tạo link)

### Assert (Kiểm tra)
- Hệ thống không tạo link
- Ngay lập tức chuyển người dùng về màn hình đăng nhập
- Không cho phép thực hiện bất kỳ thao tác tạo link nào khi chưa đăng nhập

---

## TC-14-018: Thoát màn hình gửi mà chưa gửi — thư chưa được gửi đi

**AC liên quan:** Trường hợp ngoại lệ (Mục 5)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang trên màn hình chọn nền tảng, chưa chọn nền tảng nào

### Act (Thực hiện)
- Người dùng nhấn nút quay lại hoặc đóng màn hình chọn nền tảng

### Assert (Kiểm tra)
- Không có link nào được tạo
- Không có ứng dụng MXH nào được mở
- Hệ thống quay về màn hình xem trước thư (SM-015) hoặc màn hình chính
- Thư vẫn còn đó (chưa bị xóa), người dùng có thể gửi lại sau

---

## TC-14-019: Thoát app giữa chừng trước khi link được tạo — thư được giữ lại

**AC liên quan:** Trường hợp ngoại lệ (Mục 5)
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đang trên màn hình chọn nền tảng, chưa hoàn tất gửi
- Người dùng thoát khỏi ứng dụng StampMail (nhấn home hoặc vuốt tắt app)

### Act (Thực hiện)
- Người dùng mở lại ứng dụng StampMail

### Assert (Kiểm tra)
- Nội dung thư đã soạn vẫn được giữ lại
- Thư hiển thị ở trạng thái chờ gửi
- Người dùng có thể tiếp tục gửi thư mà không cần soạn lại

---

## TC-14-020: Mỗi người nhận nhận một link riêng biệt (BR-01)

**AC liên quan:** AC-08, BR-01
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã xác nhận gửi thư
- Người dùng chọn ba nền tảng khác nhau: Zalo, WhatsApp, Threads

### Act (Thực hiện)
- Xác nhận gửi cho cả ba nền tảng

### Assert (Kiểm tra)
- Ba link được tạo ra, mỗi link là một URL duy nhất
- Không có hai link nào giống nhau
- Mỗi link được gán đúng với nền tảng tương ứng

---

## TC-14-021: Chặn mở DM khi mất mạng (BR-13)

**AC liên quan:** AC-13, BR-13
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã soạn xong thư và đang ở màn hình chọn nền tảng
- Thiết bị không có kết nối mạng

### Act (Thực hiện)
- Chọn nền tảng bất kỳ

### Assert (Kiểm tra)
- Không có ứng dụng MXH nào được mở (vì link chưa được tạo)
- Hệ thống chặn hoàn toàn bước chia sẻ cho đến khi có mạng
- Hiển thị thông báo lỗi mạng rõ ràng

---

## TC-14-022: Chọn nền tảng iMessage trên Android — xử lý đúng

**AC liên quan:** AC-01, BR-04
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng sử dụng thiết bị Android
- Màn hình chọn nền tảng đang hiển thị

### Act (Thực hiện)
- Nhấn "Gửi qua iMessage"

### Assert (Kiểm tra)
- Vì iMessage không khả dụng trên Android: link thư được sao chép vào bộ nhớ tạm
- Hiển thị thông báo hướng dẫn người dùng tự dán link vào ứng dụng nhắn tin

---

## TC-14-023: Người dùng gói Thường gửi đúng thư thứ mười — thành công

**AC liên quan:** AC-02, BR-08
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Tài khoản gói Thường đã gửi 9 thư trong tháng hiện tại
- Người dùng đã soạn xong thư thứ mười và vào màn hình chọn nền tảng

### Act (Thực hiện)
- Nhấn chọn nền tảng và xác nhận gửi

### Assert (Kiểm tra)
- Hệ thống tạo link thành công (thư thứ mười vẫn được phép)
- Không hiển thị thông báo giới hạn
- Ứng dụng MXH đã chọn mở ra với link điền sẵn

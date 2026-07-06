# Test Cases — Nâng cấp Premium & Thanh toán (SM-028) (024-nang-cap-premium)

## TC-24-001: Màn hình so sánh Free vs Premium hiển thị đầy đủ

**AC liên quan:** AC-01, BR-01
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Tài khoản người dùng đã đăng nhập
- Tài khoản đang ở gói Thường (Free)

### Act (Thực hiện)
- Người dùng nhấn nút nâng cấp từ bất kỳ điểm nào trong app (tính năng bị khoá, hộp hết hạn mức, hoặc menu)
- Màn hình nâng cấp Premium hiển thị

### Assert (Kiểm tra)
- Bảng so sánh giữa Free và Premium hiển thị rõ ràng
- Bảng liệt kê đầy đủ 5 điểm khác biệt: bộ lọc, viền, template, giới hạn tem và giới hạn thư
- Cột Free hiển thị đúng giới hạn: 30 tem/tháng, 10 thư/tháng
- Cột Premium hiển thị: không giới hạn tem/tháng, không giới hạn thư/tháng, 8 bộ lọc, 3 kiểu viền, hơn 17 template

---

## TC-24-002: Gói năm hiển thị mức tiết kiệm so với gói tháng

**AC liên quan:** AC-02, BR-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Tài khoản đang ở gói Thường (Free)
- Màn hình nâng cấp Premium đang mở

### Act (Thực hiện)
- Người dùng nhìn vào phần chọn gói thời hạn với hai lựa chọn: gói tháng và gói năm

### Assert (Kiểm tra)
- Gói tháng hiển thị giá thanh toán mỗi tháng
- Gói năm hiển thị giá thanh toán một lần cho cả năm
- Gói năm hiển thị thông tin tiết kiệm (ví dụ: "Tiết kiệm X% so với mua tháng")
- Giá gói năm chia 12 thấp hơn giá gói tháng

---

## TC-24-003: Mở khoá nội dung Premium ngay sau thanh toán thành công

**AC liên quan:** AC-03, BR-04, BR-05
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Tài khoản đang ở gói Thường (Free)
- Màn hình nâng cấp Premium đang mở
- Tài khoản App Store (iOS) hoặc Google Play (Android) có phương thức thanh toán hợp lệ

### Act (Thực hiện)
- Người dùng chọn gói (tháng hoặc năm) và nhấn nút mua
- Cổng thanh toán App Store / Google Play mở ra
- Người dùng xác nhận thanh toán qua cổng của nền tảng
- Sau khi thanh toán thành công, quay lại app

### Assert (Kiểm tra)
- App nhận trạng thái Premium ngay mà không cần khởi động lại
- 8 bộ lọc Premium (Tâm trạng 4 + Mùa 4) hiển thị và có thể dùng được ngay
- 3 kiểu viền Premium (Zigzag, Viền đôi, Retro bo mềm) hiển thị và có thể dùng được ngay
- Hơn 17 template thư Premium có thể dùng được ngay
- Hạn mức tem tháng không còn hiển thị
- Hạn mức thư tháng không còn hiển thị
- Không còn biểu tượng khoá trên bất kỳ nội dung Premium nào

---

## TC-24-004: Thanh toán thất bại không trừ tiền và có thể thử lại

**AC liên quan:** AC-04
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Tài khoản đang ở gói Thường (Free)
- Màn hình nâng cấp Premium đang mở
- Tài khoản App Store / Google Play có phương thức thanh toán không hợp lệ hoặc bị từ chối

### Act (Thực hiện)
- Người dùng chọn gói và nhấn nút mua
- Cổng thanh toán App Store / Google Play mở ra
- Nền tảng từ chối giao dịch (thẻ hết hạn, không đủ số dư, v.v.)
- Người dùng quay lại app

### Assert (Kiểm tra)
- App hiển thị thông báo lỗi từ nền tảng (App Store / Google Play)
- Thông báo gợi ý kiểm tra phương thức thanh toán và thử lại
- Tài khoản vẫn ở gói Thường (Free)
- Không có khoản trừ nào xảy ra (kiểm tra lịch sử giao dịch trên nền tảng)
- Người dùng có thể nhấn thử lại và quay lại luồng thanh toán

---

## TC-24-005: Thông báo lỗi mạng khi nhấn nút xác nhận thanh toán lúc offline

**AC liên quan:** AC-05, BR-06
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Tài khoản đang ở gói Thường (Free)
- Màn hình nâng cấp Premium đang mở và đã tải xong
- Người dùng đã chọn gói tháng hoặc gói năm
- Tắt kết nối mạng trên thiết bị (tắt Wi-Fi và dữ liệu di động)

### Act (Thực hiện)
- Người dùng nhấn nút xác nhận thanh toán

### Assert (Kiểm tra)
- App hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."
- Nút thanh toán không phản hồi (không mở cổng thanh toán)
- Gói đã chọn (tháng hoặc năm) vẫn được giữ nguyên, không bị đặt lại
- Người dùng có thể tiếp tục xem bảng so sánh Free vs Premium

---

## TC-24-006: Màn hình so sánh vẫn xem được khi mất kết nối giữa chừng

**AC liên quan:** AC-06, BR-07
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Tài khoản đang ở gói Thường (Free)
- Màn hình so sánh Free vs Premium đã tải xong và đang hiển thị khi còn kết nối

### Act (Thực hiện)
- Tắt kết nối mạng trên thiết bị (tắt Wi-Fi và dữ liệu di động) sau khi màn hình đã hiển thị
- Tiếp tục đọc nội dung trên màn hình

### Assert (Kiểm tra)
- Bảng so sánh Free vs Premium vẫn hiển thị đầy đủ từ cache
- Thông tin giá gói tháng và gói năm vẫn hiển thị
- Nút xác nhận thanh toán bị vô hiệu hoá kèm thông báo lỗi mạng
- Người dùng có thể đọc toàn bộ nội dung so sánh mà không cần kết nối

---

## TC-24-007: Mở màn hình nâng cấp khi đã mất mạng và chưa có cache

**AC liên quan:** BR-06, Mục 5 — offline chưa có cache
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Tài khoản đang ở gói Thường (Free)
- Thiết bị không có kết nối mạng
- Màn hình nâng cấp chưa được mở lần nào trong phiên này (không có cache)

### Act (Thực hiện)
- Người dùng mở màn hình nâng cấp Premium

### Assert (Kiểm tra)
- App hiển thị thông báo lỗi mạng (không hiển thị bảng so sánh trống hay màn hình trắng)
- Không cho phép thực hiện thao tác mua
- Giao diện chờ người dùng kết nối lại trước khi tiếp tục

---

## TC-24-008: Màn hình so sánh hiển thị trạng thái đang tải và nút Thử lại khi lỗi máy chủ

**AC liên quan:** Mục 5 — lỗi mạng hoặc lỗi máy chủ
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Tài khoản đang ở gói Thường (Free)
- Thiết bị có kết nối mạng nhưng máy chủ trả về lỗi hoặc mạng không ổn định

### Act (Thực hiện)
- Người dùng mở màn hình nâng cấp Premium
- Dữ liệu gói không tải được do lỗi máy chủ

### Assert (Kiểm tra)
- Trong thời gian chờ tải: app hiển thị trạng thái đang tải (loading indicator)
- Không hiển thị màn hình trắng hay nội dung không đầy đủ mà không có thông báo
- Khi tải thất bại: app hiển thị thông báo lỗi và nút "Thử lại"
- Nhấn "Thử lại": app tải lại dữ liệu gói

---

## TC-24-009: Người dùng chưa đăng nhập cố truy cập màn hình nâng cấp

**AC liên quan:** Mục 5 — chưa đăng nhập
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng chưa đăng nhập (hoặc đã đăng xuất)

### Act (Thực hiện)
- Người dùng cố truy cập màn hình nâng cấp Premium

### Assert (Kiểm tra)
- App chuyển sang màn hình đăng nhập (SM-001)
- Sau khi đăng nhập thành công, người dùng được đưa trở lại màn hình nâng cấp Premium

---

## TC-24-010: Người dùng đã Premium vào màn hình nâng cấp

**AC liên quan:** Mục 5 — người dùng đã Premium
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Tài khoản đang ở gói Premium (đã thanh toán thành công)

### Act (Thực hiện)
- Người dùng vào màn hình nâng cấp (từ menu hoặc bất kỳ điểm nào)

### Assert (Kiểm tra)
- Màn hình hiển thị trạng thái đang là Premium
- Hiển thị ngày hết hạn của gói Premium hiện tại
- Có liên kết dẫn đến màn hình quản lý đăng ký (SM-029)
- Không hiển thị nút mua hoặc lựa chọn gói mới

---

## TC-24-011: Điều hướng đến màn hình nâng cấp từ nhiều điểm vào

**AC liên quan:** AC-01, BR-01 (phạm vi — "từ bất kỳ điểm nào trong app")
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Tài khoản đang ở gói Thường (Free)

### Act (Thực hiện)
- Lần lượt thực hiện 3 kịch bản điều hướng:
  1. Nhấn vào tính năng bị khoá (bộ lọc Premium, viền Premium, template Premium)
  2. Nhấn từ hộp thông báo hết hạn mức
  3. Nhấn từ menu chính

### Assert (Kiểm tra)
- Cả 3 điểm vào đều dẫn đến màn hình nâng cấp Premium
- Màn hình nâng cấp hiển thị đầy đủ bảng so sánh và các gói thời hạn
- Trải nghiệm nhất quán từ mọi điểm vào

---

## TC-24-012: Thanh toán chỉ qua cổng nền tảng, không nhập thẻ trực tiếp trong app

**AC liên quan:** BR-03
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Tài khoản đang ở gói Thường (Free)
- Màn hình nâng cấp Premium đang mở

### Act (Thực hiện)
- Người dùng chọn gói và nhấn nút mua

### Assert (Kiểm tra)
- Cổng thanh toán của nền tảng (App Store trên iOS, Google Play trên Android) được mở ra
- App StampMail không hiển thị form nhập thẻ tín dụng hay thông tin thanh toán trực tiếp
- Toàn bộ giao dịch diễn ra trong cổng của nền tảng

---

## TC-24-013: Mất kết nối giữa chừng sau khi đã mở cổng thanh toán

**AC liên quan:** Mục 5 — mất kết nối giữa chừng thanh toán
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Tài khoản đang ở gói Thường (Free)
- Cổng thanh toán App Store / Google Play đang mở và đang xử lý

### Act (Thực hiện)
- Tắt kết nối mạng của thiết bị trong khi cổng thanh toán đang xử lý
- Chờ một thời gian rồi bật lại kết nối mạng

### Assert (Kiểm tra)
- Nền tảng (App Store / Google Play) tự xử lý trạng thái giao dịch bị gián đoạn
- App hiển thị hướng dẫn người dùng kiểm tra trạng thái đăng ký trong App Store / Google Play
- Trạng thái tài khoản trong StampMail nhất quán với kết quả thực tế từ nền tảng sau khi có kết nối trở lại

---

## TC-24-014: Thoát app sau khi đã xác nhận thanh toán trên cổng nền tảng

**AC liên quan:** Mục 5 — thoát app sau khi xác nhận thanh toán
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Tài khoản đang ở gói Thường (Free)
- Cổng thanh toán App Store / Google Play đã mở và người dùng đã xác nhận thanh toán

### Act (Thực hiện)
- Tắt app hoàn toàn (force close) trong khi cổng thanh toán vẫn đang xử lý
- Mở lại app sau một khoảng thời gian ngắn

### Assert (Kiểm tra)
- Nếu thanh toán thành công: tài khoản đã được nâng cấp Premium khi mở app lại
- Nếu thanh toán thất bại: tài khoản vẫn ở gói Thường, app không bị lỗi

---

## TC-24-015: Thoát app khi đang xem màn hình so sánh (chưa xác nhận)

**AC liên quan:** Mục 5 — thoát app giữa chừng chưa xác nhận
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Tài khoản đang ở gói Thường (Free)
- Màn hình so sánh Free vs Premium đang mở, người dùng đã chọn gói nhưng chưa nhấn xác nhận

### Act (Thực hiện)
- Người dùng tắt app (hoặc chuyển sang app khác rồi quay lại)

### Assert (Kiểm tra)
- Không có dữ liệu nào bị mất hay giao dịch nào bị tạo
- Tài khoản vẫn ở gói Thường (Free)
- Lần mở app tiếp theo người dùng cần vào lại màn hình nâng cấp từ đầu

---

## TC-24-016: Mạng trở lại sau khi offline — gói đã chọn được giữ nguyên

**AC liên quan:** AC-05, BR-06 — giữ nguyên gói khi mạng trở lại
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Tài khoản đang ở gói Thường (Free)
- Màn hình nâng cấp đang mở, người dùng đã chọn gói (ví dụ: gói năm)
- Thiết bị đang mất kết nối mạng

### Act (Thực hiện)
- Bật lại kết nối mạng trên thiết bị

### Assert (Kiểm tra)
- Gói đã chọn trước đó (gói năm hoặc gói tháng) vẫn được giữ nguyên
- Người dùng không phải chọn lại gói
- Nút xác nhận thanh toán trở lại trạng thái hoạt động bình thường

---

## TC-24-017: Kiểm tra nội dung Premium chi tiết sau nâng cấp (BR-05)

**AC liên quan:** AC-03, BR-05
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Tài khoản vừa nâng cấp thành công lên gói Premium

### Act (Thực hiện)
- Người dùng lần lượt truy cập vào: danh sách bộ lọc, danh sách viền, danh sách template thư

### Assert (Kiểm tra)
- Danh sách bộ lọc hiển thị đủ 8 bộ lọc Premium (4 bộ Tâm trạng + 4 bộ Mùa) không bị khoá
- Danh sách viền hiển thị đủ 3 kiểu viền Premium (Zigzag, Viền đôi, Retro bo mềm) không bị khoá
- Danh sách template hiển thị hơn 17 template Premium không bị khoá
- Không còn biểu tượng khoá trên bất kỳ nội dung Premium nào

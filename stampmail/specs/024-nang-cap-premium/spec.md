# Nâng cấp Premium & Thanh toán (SM-028)

**Feature Branch**: `024-nang-cap-premium`
**Ngày tạo**: 2026-06-24
**Trạng thái**: Draft
**Ưu tiên**: P2

> **Tài liệu thuần nghiệp vụ** cho Tester (QA), Business Analyst (BA), Product Owner (PO).
> **KHÔNG chứa chi tiết kỹ thuật**. Phần plan / vẽ giao diện / develop được làm RIÊNG ở bước sau.

---

## 1. Mục đích nghiệp vụ

Chuyển đổi người dùng Free sang Premium bằng cách trình bày rõ ràng những gì họ được mở khoá — không ẩn giá, không gây bất ngờ. Thanh toán qua cổng của nền tảng (App Store / Google Play) để người dùng tin tưởng.

## 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng gói Thường muốn nâng cấp.
- **Khi nào dùng:** Khi nhấn nút nâng cấp từ bất kỳ điểm nào trong app (gợi ý từ tính năng bị khoá, từ hộp hết hạn mức, hoặc từ menu).
- **Điều kiện tiên quyết:** Đã đăng nhập (SM-001). Đang ở gói Thường.
- **Phạm vi:** Màn hình so sánh Free vs Premium, chọn gói (tháng/năm), và thanh toán. Không bao gồm quản lý đăng ký sau khi đã Premium (SM-029).

## 3. Quy tắc nghiệp vụ

- **BR-01 — Màn hình so sánh rõ ràng:** Người dùng thấy bảng so sánh Free vs Premium liệt kê đầy đủ sự khác biệt: bộ lọc, viền, template, giới hạn tem và thư.
- **BR-02 — Hai gói thời hạn:** Người dùng chọn gói tháng (thanh toán mỗi tháng) hoặc gói năm (thanh toán một lần cho cả năm, rẻ hơn tổng cộng so với mười hai tháng lẻ).
- **BR-03 — Thanh toán qua App Store / Google Play:** Toàn bộ giao dịch thanh toán diễn ra qua cổng thanh toán của nền tảng (Apple App Store trên iOS, Google Play trên Android). StampMail không xử lý thẻ tín dụng trực tiếp.
- **BR-04 — Mở khoá ngay sau thanh toán:** Ngay sau khi thanh toán thành công, toàn bộ nội dung và giới hạn Premium được mở khoá mà không cần khởi động lại app.
- **BR-05 — Nội dung Premium bao gồm:**
  - Tám bộ lọc Premium (Tâm trạng 4 + Mùa 4)
  - Ba kiểu viền Premium (Zigzag, Viền đôi, Retro bo mềm)
  - Hơn mười bảy template thư Premium
  - Không giới hạn tem tháng (Free: ba mươi)
  - Không giới hạn thư tháng (Free: mười)

### Trạng thái offline

- **BR-06 — Chặn thanh toán khi mất mạng:** Khi người dùng không có kết nối, nút xác nhận thanh toán bị vô hiệu hoá và app hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." Gói đang chọn và tuỳ chọn tháng/năm được giữ nguyên để người dùng không phải chọn lại.
- **BR-07 — Màn hình so sánh vẫn xem được khi mất mạng:** Nếu màn hình so sánh Free vs Premium đã hiển thị trước khi mất mạng, người dùng vẫn đọc được nội dung và giá gói; chỉ bước nhấn mua mới bị chặn.

## 4. Tiêu chí nghiệm thu

- **AC-01 — Màn hình so sánh hiển thị đầy đủ:**
  - **Giả sử** người dùng gói Thường mở màn hình nâng cấp;
  - **Khi** màn hình hiển thị;
  - **Thì** thấy bảng so sánh rõ ràng giữa Free và Premium với các điểm khác biệt về bộ lọc, viền, template, giới hạn tem và thư.

- **AC-02 — Gói năm rẻ hơn gói tháng nhân mười hai:**
  - **Giả sử** người dùng xem hai lựa chọn gói;
  - **Khi** nhìn vào giá;
  - **Thì** gói năm hiển thị tiết kiệm so với mua tháng (ví dụ: "Tiết kiệm X% so với mua tháng").

- **AC-03 — Mở khoá ngay sau thanh toán:**
  - **Giả sử** người dùng vừa hoàn tất thanh toán Premium;
  - **Khi** quay lại app;
  - **Thì** bộ lọc Premium, viền Premium và template Premium đều có thể dùng được ngay, hạn mức tháng không còn hiển thị.

- **AC-04 — Thanh toán thất bại không trừ tiền:**
  - **Giả sử** người dùng cố thanh toán nhưng nền tảng từ chối;
  - **Khi** nhận thông báo thất bại từ App Store/Google Play;
  - **Thì** tài khoản vẫn ở gói Thường, không có khoản trừ nào và có thể thử lại.

### Offline

- **AC-05 — Thông báo lỗi mạng khi nhấn mua:**
  - **Giả sử** người dùng đang ở màn hình nâng cấp và đã chọn gói tháng hoặc gói năm, nhưng thiết bị không có kết nối;
  - **Khi** nhấn nút xác nhận thanh toán;
  - **Thì** app hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng.", nút thanh toán không phản hồi, và gói đã chọn vẫn được giữ nguyên.

- **AC-06 — Màn hình so sánh vẫn xem được khi offline:**
  - **Giả sử** người dùng đã mở màn hình so sánh Free vs Premium, sau đó mất kết nối;
  - **Khi** tiếp tục đọc nội dung trên màn hình;
  - **Thì** bảng so sánh và thông tin giá gói vẫn hiển thị đầy đủ; chỉ nút xác nhận thanh toán bị vô hiệu hoá kèm thông báo lỗi mạng.

## 5. Trường hợp ngoại lệ & lỗi

- Khi thanh toán thất bại: hiển thị thông báo lỗi từ nền tảng, gợi ý kiểm tra phương thức thanh toán và thử lại.
- Khi mất kết nối giữa chừng thanh toán: nền tảng (App Store/Google Play) xử lý; người dùng kiểm tra trạng thái đăng ký trong App Store/Google Play.
- Khi người dùng đã là Premium và vào màn hình nâng cấp: hiển thị trạng thái đang là Premium với ngày hết hạn và liên kết đến quản lý đăng ký (SM-029).

### Khi mất kết nối (offline)

- Nếu màn hình so sánh đã tải trước khi mất mạng, thông tin gói giá (Free vs Premium, giá tháng/năm) vẫn hiển thị từ cache; nút xác nhận thanh toán bị vô hiệu hoá và app thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."
- Nếu người dùng mở màn hình nâng cấp trong khi đã mất mạng và dữ liệu gói chưa có trong cache, app hiển thị thông báo lỗi mạng và chờ người dùng kết nối lại; không cho phép thao tác mua.
- Gói đang chọn (tháng hoặc năm) được giữ nguyên khi mạng trở lại, người dùng không phải chọn lại.

### Khi dữ liệu không tải được (lỗi mạng hoặc lỗi máy chủ)

- Nếu màn hình so sánh không tải được danh sách gói (do lỗi máy chủ hoặc mạng không ổn định), app hiển thị thông báo lỗi và nút "Thử lại" để người dùng tải lại dữ liệu.
- Trong thời gian chờ tải, app hiển thị trạng thái đang tải (loading); không hiển thị màn hình trắng hay nội dung không đầy đủ mà không có thông báo.

### Khi chưa đăng nhập hoặc thoát app giữa chừng

- Nếu người dùng chưa đăng nhập và cố truy cập màn hình nâng cấp, app chuyển sang màn hình đăng nhập (SM-001); sau khi đăng nhập thành công, người dùng được đưa trở lại màn hình nâng cấp.
- Nếu người dùng thoát app trong khi đang xem màn hình so sánh hoặc chọn gói (chưa xác nhận thanh toán), không có dữ liệu nào bị mất; lần mở app tiếp theo người dùng cần vào lại màn hình nâng cấp từ đầu.
- Nếu người dùng thoát app sau khi đã xác nhận thanh toán trên cổng nền tảng, App Store/Google Play tiếp tục xử lý giao dịch; khi mở app lại, nếu thanh toán thành công thì tài khoản đã được nâng cấp Premium.

---

## Liên kết tính năng khác

- SM-029 (Quản lý đăng ký Premium): quản lý sau khi đã nâng cấp.
- SM-030 (Giới hạn tháng): hạn mức được gỡ bỏ sau khi nâng cấp.
- SM-006/009/012 (Bộ lọc/Viền/Template): nội dung được mở khoá.

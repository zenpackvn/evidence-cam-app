# Giới hạn tháng & Nhắc hạn mức (Free) — SM-030

**Feature Branch**: `026-gioi-han-thang`
**Ngày tạo**: 2026-06-24
**Trạng thái**: Draft
**Ưu tiên**: P2

> **Tài liệu thuần nghiệp vụ** cho Tester (QA), Business Analyst (BA), Product Owner (PO).
> **KHÔNG chứa chi tiết kỹ thuật**. Phần plan / vẽ giao diện / develop được làm RIÊNG ở bước sau.

---

## 1. Mục đích nghiệp vụ

Áp dụng và theo dõi giới hạn sử dụng hàng tháng cho người dùng gói Thường (Free) — nhắc nhở kịp thời khi gần hết để người dùng có thể nâng cấp hoặc lên kế hoạch sử dụng, không bị bất ngờ khi bị chặn.

## 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng gói Thường (Free).
- **Khi nào dùng:** Liên tục trong nền; nhắc nhở khi gần đến giới hạn; chặn khi đạt giới hạn.
- **Điều kiện tiên quyết:** Đang ở gói Thường.
- **Phạm vi:** Theo dõi số tem và thư đã dùng trong tháng, cảnh báo và chặn khi đạt giới hạn, reset đầu tháng. Không bao gồm Premium (không có giới hạn).

## 3. Quy tắc nghiệp vụ

- **BR-01 — Hai giới hạn tháng cho Free:**
  - Tối đa ba mươi tem tạo mới mỗi tháng.
  - Tối đa mười thư gửi mỗi tháng.
- **BR-02 — Cảnh báo sớm:** Khi còn dưới hai mươi phần trăm hạn mức (tức còn dưới sáu tem hoặc dưới hai thư), hệ thống hiển thị cảnh báo trực quan trong app và/hoặc gửi thông báo push.
- **BR-03 — Chặn khi hết hạn mức:** Khi đã dùng hết hạn mức, hệ thống không cho tạo thêm tem (hoặc gửi thêm thư). Thông báo rõ ràng và gợi ý nâng cấp Premium hoặc chờ đầu tháng tiếp.
- **BR-04 — Reset đầu tháng:** Hạn mức tự động reset về không vào đầu mỗi tháng dương lịch (ngày 1 của tháng). Không cần người dùng làm gì.
- **BR-05 — Premium không có giới hạn:** Khi người dùng nâng cấp Premium, giới hạn tháng không còn áp dụng nữa.

### Trạng thái offline

- **BR-06 — Hiển thị hạn mức đã lưu khi mất mạng:** Khi thiết bị mất kết nối, app vẫn hiển thị số tem và số thư đã dùng trong tháng theo dữ liệu lần đồng bộ gần nhất — người dùng vẫn thấy hạn mức còn lại dù không có mạng.
- **BR-07 — Chặn hành động ghi khi mất mạng:** Khi mất kết nối, mọi hành động cần kiểm tra hoặc cập nhật hạn mức (tạo tem mới, gửi thư) đều bị chặn. Hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." — không thực hiện thao tác cho đến khi có mạng trở lại.

## 4. Tiêu chí nghiệm thu

- **AC-01 — Cảnh báo khi còn ít hạn mức:**
  - **Giả sử** người dùng Free đã gửi chín thư trong tháng (còn một thư);
  - **Khi** xem bất kỳ màn hình nào liên quan đến gửi thư;
  - **Thì** thấy cảnh báo "Còn 1 thư trong tháng này".

- **AC-02 — Chặn khi hết hạn mức thư:**
  - **Giả sử** người dùng Free đã gửi đủ mười thư trong tháng;
  - **Khi** cố soạn và gửi thêm thư;
  - **Thì** hệ thống không cho tiếp tục, thông báo đã hết hạn mức và gợi ý nâng cấp Premium hoặc chờ đầu tháng.

- **AC-03 — Chặn khi hết hạn mức tem:**
  - **Giả sử** người dùng Free đã lưu đủ ba mươi tem trong tháng;
  - **Khi** cố lưu tem mới (SM-011);
  - **Thì** hệ thống không cho lưu, thông báo đã hết hạn mức và gợi ý nâng cấp Premium.

- **AC-04 — Reset hạn mức đầu tháng:**
  - **Giả sử** người dùng đã dùng hết mười thư trong tháng trước;
  - **Khi** đến ngày 1 của tháng mới và mở app;
  - **Thì** hạn mức được reset, người dùng có thể gửi thêm mười thư.

- **AC-05 — Premium không bị chặn:**
  - **Giả sử** người dùng vừa nâng cấp Premium;
  - **Khi** tiếp tục tạo tem và gửi thư vượt quá giới hạn Free;
  - **Thì** không bị chặn, không thấy cảnh báo hạn mức.

### Offline

- **AC-06 — Hiển thị hạn mức còn lại khi offline:**
  - **Giả sử** người dùng Free đã đồng bộ hạn mức (ví dụ: đã dùng bảy thư) và sau đó mất kết nối mạng;
  - **Khi** mở app và xem màn hình theo dõi hạn mức;
  - **Thì** app vẫn hiển thị đúng số thư và tem đã dùng theo dữ liệu lần cuối đồng bộ, không hiện lỗi trắng hay giá trị trống.

- **AC-07 — Chặn tạo tem và gửi thư khi offline:**
  - **Giả sử** người dùng Free đang mất kết nối mạng;
  - **Khi** cố tạo tem mới hoặc soạn gửi thư;
  - **Thì** hệ thống chặn thao tác và hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng.", không thực hiện bất kỳ hành động ghi nào.

## 5. Trường hợp ngoại lệ & lỗi

- Khi múi giờ người dùng khác giờ chuẩn của hệ thống: hạn mức được reset theo múi giờ của thiết bị người dùng tại thời điểm reset — đảm bảo người dùng thấy ngày 1 tháng là đầu tháng mới theo đồng hồ điện thoại của họ.
- Khi người dùng tạo link mới cho thư hết hạn (SM-021): link mới trừ vào hạn mức thư tháng.

### Khi mất kết nối (offline / no network)

- Số tem và số thư đã dùng trong tháng vẫn hiển thị đúng theo dữ liệu lần đồng bộ gần nhất — người dùng không thấy màn hình trắng hay giá trị trống.
- Mọi thao tác tạo tem mới hoặc gửi thư đều bị chặn và hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." cho đến khi có mạng trở lại.

### Khi dữ liệu không tải được (lỗi mạng / lỗi máy chủ)

- Nếu đồng bộ hạn mức thất bại, app hiển thị số liệu từ cache cục bộ kèm thông báo "Không thể cập nhật dữ liệu" và nút "Thử lại" để người dùng đồng bộ lại thủ công.

### Khi chưa đăng nhập / thoát app giữa chừng

- Người dùng chưa đăng nhập không thấy số liệu hạn mức và không thấy banner cảnh báo — toàn bộ phần theo dõi hạn mức bị ẩn.
- Khi người dùng thoát app giữa chừng (ví dụ: đang xem màn hình hạn mức), dữ liệu không bị mất — lần sau mở lại app vẫn thấy đúng số liệu theo cache đã lưu hoặc dữ liệu đồng bộ mới nhất.

## Clarifications

### Session 2026-06-24

- Q: Múi giờ nào được dùng để reset hạn mức tháng? → A: Múi giờ của thiết bị người dùng tại thời điểm reset — người dùng thấy ngày 1 tháng theo đồng hồ điện thoại của họ.

---

## Liên kết tính năng khác

- SM-011 (Lưu tem): kiểm tra hạn mức trước khi lưu.
- SM-016 (Gửi thư): kiểm tra hạn mức trước khi tạo link.
- SM-026 (Thông báo push): gửi cảnh báo hạn mức sắp cạn.
- SM-028 (Nâng cấp Premium): điểm đến khi gợi ý nâng cấp từ thông báo hạn mức.
- SM-029 (Quản lý Premium): giới hạn tháng được bỏ khi ở gói Premium.

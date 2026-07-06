# Cài đặt tài khoản & Quyền riêng tư (SM-027)

**Feature Branch**: `023-cai-dat-tai-khoan`
**Ngày tạo**: 2026-06-24
**Trạng thái**: Draft
**Ưu tiên**: P2

> **Tài liệu thuần nghiệp vụ** cho Tester (QA), Business Analyst (BA), Product Owner (PO).
> **KHÔNG chứa chi tiết kỹ thuật**. Phần plan / vẽ giao diện / develop được làm RIÊNG ở bước sau.

---

## 1. Mục đích nghiệp vụ

Là nơi người dùng kiểm soát tài khoản và trải nghiệm của mình: bảo mật (đổi mật khẩu, đăng xuất), tuỳ chọn cá nhân (ngôn ngữ, âm thanh), và quyền riêng tư (ẩn thống kê, chặn người dùng). Cũng là luồng xoá tài khoản với thời gian chờ an toàn.

## 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đã đăng nhập.
- **Khi nào dùng:** Khi muốn thay đổi cấu hình tài khoản hoặc quyền riêng tư.
- **Điều kiện tiên quyết:** Đã đăng nhập (SM-001).
- **Phạm vi:** Đổi mật khẩu, đăng xuất, đăng xuất tất cả thiết bị, xoá tài khoản, ngôn ngữ, âm thanh animation, ẩn thống kê, chặn người dùng, cài đặt thông báo. Không bao gồm nâng cấp Premium (SM-028) hay quản lý đăng ký (SM-029).

## 3. Quy tắc nghiệp vụ

- **BR-01 — Đổi mật khẩu:** Người dùng đổi mật khẩu bằng cách nhập mật khẩu cũ đúng trước. Sau khi đổi, tất cả thiết bị bị đăng xuất (xem SM-002).
- **BR-02 — Đăng xuất thiết bị hiện tại:** Đăng xuất chỉ thiết bị đang dùng; các thiết bị khác vẫn đăng nhập.
- **BR-03 — Đăng xuất tất cả thiết bị:** Đăng xuất toàn bộ thiết bị đang đăng nhập, kể cả thiết bị hiện tại.
- **BR-04 — Xoá tài khoản:** Người dùng yêu cầu xoá tài khoản → tài khoản vào trạng thái "chờ xoá" trong bảy ngày → sau bảy ngày tự xoá vĩnh viễn. Trong thời gian chờ, người dùng có thể huỷ yêu cầu xoá bằng cách đăng nhập lại.
- **BR-05 — Ngôn ngữ:** Người dùng chọn ngôn ngữ hiển thị của app. Thay đổi áp dụng ngay.
- **BR-06 — Âm thanh animation thư:** Người dùng bật/tắt âm thanh kèm animation mở thư (SM-019). Mặc định là bật.
- **BR-07 — Ẩn thống kê hồ sơ:** Người dùng bật/tắt ẩn thống kê hoạt động với người khác (xem SM-024).
- **BR-08 — Chặn người dùng:** Người dùng có thể chặn tài khoản khác. Khi bị chặn, người đó không thể gửi thư đến người chặn.
- **BR-09 — Cài đặt thông báo:** Bật/tắt từng loại thông báo push (xem SM-026).

### Trạng thái offline

- **BR-10 — Thao tác bảo mật cần mạng:** Các hành động cần xác thực với máy chủ — đổi mật khẩu, đăng xuất (thiết bị hiện tại hoặc tất cả thiết bị), yêu cầu xoá tài khoản — bị chặn khi mất kết nối. Hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." và giữ nguyên dữ liệu đã nhập.
- **BR-11 — Tuỳ chọn cá nhân lưu tạm cục bộ:** Thay đổi ngôn ngữ hiển thị và trạng thái âm thanh animation có thể áp dụng ngay trên thiết bị khi offline; khi có mạng trở lại, tuỳ chọn được đồng bộ lên tài khoản tự động.

## 4. Tiêu chí nghiệm thu

- **AC-01 — Đăng xuất tất cả thiết bị:**
  - **Giả sử** người dùng đang đăng nhập trên hai thiết bị;
  - **Khi** chọn "Đăng xuất tất cả thiết bị";
  - **Thì** cả hai thiết bị bị đăng xuất và phải đăng nhập lại.

- **AC-02 — Yêu cầu xoá tài khoản:**
  - **Giả sử** người dùng muốn xoá tài khoản;
  - **Khi** xác nhận yêu cầu xoá;
  - **Thì** hệ thống thông báo tài khoản sẽ bị xoá sau bảy ngày và hướng dẫn cách huỷ.

- **AC-03 — Huỷ yêu cầu xoá tài khoản:**
  - **Giả sử** người dùng đã yêu cầu xoá và tài khoản đang trong thời gian chờ;
  - **Khi** đăng nhập lại trong bảy ngày và xác nhận huỷ xoá;
  - **Thì** tài khoản được giữ lại bình thường.

- **AC-04 — Tắt âm thanh animation:**
  - **Giả sử** người dùng tắt âm thanh animation trong cài đặt;
  - **Khi** mở một thư mới;
  - **Thì** animation diễn ra nhưng không có âm thanh.

- **AC-05 — Chặn người dùng:**
  - **Giả sử** người dùng A chặn người dùng B;
  - **Khi** B cố gửi thư đến A;
  - **Thì** link thư A tạo cho B không thể gửi đến A, hoặc A không nhận được thư từ B.

- **AC-06 — Đổi mật khẩu yêu cầu mật khẩu cũ:**
  - **Giả sử** người dùng vào mục đổi mật khẩu trong cài đặt;
  - **Khi** nhập đúng mật khẩu hiện tại, nhập mật khẩu mới và xác nhận;
  - **Thì** mật khẩu được thay đổi thành công và tất cả thiết bị khác bị đăng xuất.

- **AC-07 — Đăng xuất chỉ thiết bị hiện tại:**
  - **Giả sử** người dùng đang đăng nhập trên hai thiết bị;
  - **Khi** chọn "Đăng xuất" (chỉ thiết bị hiện tại);
  - **Thì** thiết bị hiện tại bị đăng xuất; thiết bị kia vẫn đăng nhập bình thường.

- **AC-08 — Đổi ngôn ngữ áp dụng ngay:**
  - **Giả sử** người dùng đang dùng app bằng tiếng Việt;
  - **Khi** vào cài đặt, chọn ngôn ngữ khác (ví dụ: tiếng Anh) và xác nhận;
  - **Thì** giao diện app chuyển sang ngôn ngữ đã chọn ngay, không cần khởi động lại.

- **AC-09 — Ẩn thống kê hồ sơ với người khác:**
  - **Giả sử** người dùng bật tùy chọn "Ẩn thống kê" trong cài đặt;
  - **Khi** người dùng khác xem hồ sơ của người này;
  - **Thì** phần thống kê (tem đã tạo, thư đã gửi…) không hiển thị với người xem; chủ tài khoản vẫn thấy số liệu của mình.

### Offline

- **AC-10 — Chặn thao tác bảo mật khi mất mạng:**
  - **Giả sử** người dùng đang ở màn hình cài đặt và thiết bị mất kết nối mạng;
  - **Khi** người dùng nhấn "Đổi mật khẩu", "Đăng xuất tất cả thiết bị", hoặc "Yêu cầu xoá tài khoản";
  - **Thì** thao tác không được thực hiện, hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." và dữ liệu đã nhập (nếu có) được giữ nguyên.

- **AC-11 — Tuỳ chọn cá nhân hoạt động offline và đồng bộ khi có mạng:**
  - **Giả sử** người dùng đang ở màn hình cài đặt và thiết bị mất kết nối mạng;
  - **Khi** người dùng thay đổi ngôn ngữ hiển thị hoặc bật/tắt âm thanh animation;
  - **Thì** thay đổi áp dụng ngay trên thiết bị; khi kết nối mạng được khôi phục, tuỳ chọn được đồng bộ lên tài khoản mà không cần thao tác thêm.

## 5. Trường hợp ngoại lệ & lỗi

**Khi mất kết nối (offline):**
- Màn hình cài đặt vẫn hiển thị đầy đủ từ dữ liệu lưu trên thiết bị (ngôn ngữ, trạng thái âm thanh, danh sách chặn…); người dùng có thể xem nhưng không lưu thay đổi lên tài khoản.
- Khi mất kết nối lúc thực hiện thao tác quan trọng (xoá tài khoản, đăng xuất tất cả): hệ thống thông báo lỗi mạng, thao tác chưa được thực hiện và dữ liệu đã nhập được giữ nguyên.
- Thay đổi ngôn ngữ và trạng thái âm thanh animation vẫn áp dụng ngay trên thiết bị khi offline; các thay đổi này sẽ được đồng bộ lên tài khoản tự động khi có mạng trở lại.

**Khi dữ liệu không tải được (lỗi máy chủ):**
- Nếu danh sách chặn hoặc cài đặt thông báo không tải được, màn hình hiển thị thông báo lỗi kèm nút "Thử lại" để người dùng tải lại mà không cần thoát màn hình.
- Các tuỳ chọn đã được lưu cục bộ trước đó vẫn hiển thị đúng; chỉ phần cần đồng bộ từ máy chủ mới báo lỗi.

**Khi chưa đăng nhập hoặc thoát app giữa chừng:**
- Nếu người dùng chưa đăng nhập và truy cập vào màn hình Cài đặt, hệ thống chuyển ngay về màn hình Đăng nhập.
- Khi tài khoản đã trong thời gian chờ xoá và hết bảy ngày: tài khoản bị xoá vĩnh viễn; mọi dữ liệu (tem, thư) bị xoá theo.
- Nếu người dùng thoát app giữa chừng khi đang nhập mật khẩu mới hoặc điền biểu mẫu, dữ liệu đang nhập bị huỷ; lần sau mở lại cần nhập lại từ đầu.

---

## Liên kết tính năng khác

- SM-002 (Xác thực & Bảo mật): đổi mật khẩu, liên kết Google/Apple.
- SM-024 (Hồ sơ người dùng): ẩn/hiện thống kê được điều khiển từ đây.
- SM-026 (Thông báo push): cài đặt từng loại thông báo từ đây.
- SM-019 (Mở thư & Animation): âm thanh animation được điều khiển từ đây.

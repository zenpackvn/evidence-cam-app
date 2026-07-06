# Hồ sơ người dùng (SM-024)

**Feature Branch**: `002-ho-so-nguoi-dung`
**Ngày tạo**: 2026-06-24
**Trạng thái**: Draft
**Ưu tiên**: P2

> **Tài liệu thuần nghiệp vụ** cho Tester (QA), Business Analyst (BA), Product Owner (PO).
> **KHÔNG chứa chi tiết kỹ thuật**. Phần plan / vẽ giao diện / develop được làm RIÊNG ở bước sau.

---

## 1. Mục đích nghiệp vụ

Cho phép người dùng cá nhân hoá tài khoản (ảnh đại diện, tên hiển thị, username) và theo dõi tóm tắt hoạt động của mình (tem đã tạo, thư đã gửi, thư đã nhận, bộ sưu tập hoàn chỉnh). Hồ sơ cũng hiển thị trạng thái gói đăng ký hiện tại (Free / Premium) và lối tắt nâng cấp. Hồ sơ cũng là nơi người khác có thể thấy thông tin cơ bản về người dùng.

## 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đã đăng nhập.
- **Khi nào dùng:** Khi muốn cập nhật thông tin cá nhân hoặc xem lại thống kê hoạt động của mình.
- **Điều kiện tiên quyết:** Đã đăng nhập (xem SM-001).
- **Phạm vi:** Chỉnh ảnh đại diện, tên hiển thị, username, ngày sinh; xem thống kê hoạt động; ẩn/hiện thống kê với người khác. Không bao gồm xoá tài khoản hay đổi mật khẩu (xem SM-027 và SM-002).

## 3. Quy tắc nghiệp vụ

- **BR-01 — Ảnh đại diện:** Người dùng tải ảnh và cắt tự do thành hình vuông tỉ lệ một-một trước khi lưu.
- **BR-02 — Tên hiển thị:** Người dùng đổi tên hiển thị tự do, tối đa ba mươi ký tự, bất kỳ lúc nào.
- **BR-03 — Username — giới hạn đổi:** Username chỉ được đổi thêm một lần sau lần đầu đăng ký. Sau khi dùng hết lượt đổi, username bị khoá vĩnh viễn.
- **BR-04 — Thống kê hoạt động:** Hồ sơ hiển thị bốn chỉ số: tổng số tem đã tạo, tổng số thư đã gửi, tổng số thư đã nhận, số bộ sưu tập theo series đã hoàn chỉnh.
- **BR-05 — Ẩn thống kê:** Người dùng có thể chọn ẩn toàn bộ thống kê hoạt động với người khác. Khi ẩn, người khác xem hồ sơ không thấy các chỉ số này; chủ tài khoản vẫn thấy.
- **BR-06 — Ngày sinh (tùy chọn):** Người dùng có thể nhập ngày sinh gồm ngày và tháng (bắt buộc nếu chọn điền) và năm sinh (tùy chọn). Trường này không bắt buộc — người dùng có thể bỏ qua hoặc xoá bất kỳ lúc nào.
- **BR-07 — Riêng tư ngày sinh:** Ngày sinh mặc định chỉ hiển thị với chính người dùng. Người dùng có thể chọn cho người khác thấy ngày và tháng sinh trên hồ sơ — năm sinh không bao giờ hiển thị với người khác dù đã bật.
- **BR-10 — Trạng thái gói đăng ký trên hồ sơ:** Hồ sơ luôn hiển thị gói đăng ký hiện tại của người dùng: "Free" hoặc "Premium". Người dùng Premium thấy thêm ngày hết hạn gói. Thông tin này chỉ hiển thị với chính người dùng, không hiển thị cho người khác xem hồ sơ.
- **BR-11 — Lối tắt nâng cấp cho người dùng Free:** Người dùng đang ở gói Free thấy nút "Nâng cấp Premium" ngay trên màn hình hồ sơ. Nhấn vào dẫn thẳng đến màn hình nâng cấp (SM-028). Người dùng Premium không thấy nút này.

### Trạng thái offline

- **BR-08 — Xem hồ sơ khi mất mạng:** Khi mất kết nối, hồ sơ (ảnh đại diện, tên hiển thị, username, thống kê) vẫn hiển thị theo dữ liệu đã tải lần cuối; app thông báo "Đang xem ngoại tuyến" để người dùng biết dữ liệu có thể chưa được cập nhật mới nhất.
- **BR-09 — Chặn lưu thay đổi khi mất mạng:** Khi mất kết nối, mọi hành động cần ghi lên hệ thống (cập nhật ảnh đại diện, đổi tên hiển thị, đổi username, lưu ngày sinh, thay đổi tùy chọn riêng tư) đều bị vô hiệu hóa; app thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." Dữ liệu người dùng đang nhập được giữ nguyên trên màn hình để tiện chỉnh lại khi có mạng trở lại.

## 4. Tiêu chí nghiệm thu

- **AC-01 — Cập nhật ảnh đại diện:**
  - **Giả sử** người dùng đang ở màn hình hồ sơ;
  - **Khi** chọn ảnh mới, cắt thành hình vuông và xác nhận lưu;
  - **Thì** ảnh đại diện mới hiển thị ngay trên hồ sơ và trên mọi nơi trong app.

- **AC-02 — Đổi tên hiển thị:**
  - **Giả sử** người dùng đang ở màn hình hồ sơ;
  - **Khi** nhập tên hiển thị mới (không quá ba mươi ký tự) và lưu;
  - **Thì** tên hiển thị mới áp dụng ngay.

- **AC-03 — Đổi username lần 2 thành công:**
  - **Giả sử** người dùng chưa dùng lượt đổi username;
  - **Khi** nhập username mới hợp lệ và xác nhận;
  - **Thì** username được cập nhật và hệ thống thông báo đã hết lượt đổi.

- **AC-04 — Không cho đổi username lần 3:**
  - **Giả sử** người dùng đã dùng hết một lượt đổi username;
  - **Khi** cố gắng đổi username lần nữa;
  - **Thì** hệ thống thông báo đã hết lượt đổi và không cho thực hiện.

- **AC-05 — Ẩn thống kê với người khác:**
  - **Giả sử** người dùng bật tùy chọn ẩn thống kê;
  - **Khi** người dùng khác xem hồ sơ;
  - **Thì** phần thống kê không hiển thị; nhưng chủ tài khoản vẫn thấy thống kê của mình.

- **AC-06 — Nhập ngày sinh thành công:**
  - **Giả sử** người dùng đang ở màn hình hồ sơ và chưa có ngày sinh;
  - **Khi** chọn điền ngày sinh, nhập đúng ngày và tháng (năm tùy chọn) rồi lưu;
  - **Thì** ngày sinh được lưu và hiển thị trên hồ sơ của chính người dùng.

- **AC-07 — Xoá ngày sinh:**
  - **Giả sử** người dùng đã có ngày sinh trên hồ sơ;
  - **Khi** chọn xoá ngày sinh và xác nhận;
  - **Thì** trường ngày sinh trống, không còn hiển thị trên hồ sơ.

- **AC-08 — Cho phép người khác thấy ngày và tháng sinh:**
  - **Giả sử** người dùng đã nhập ngày sinh và bật tùy chọn hiển thị với người khác;
  - **Khi** người dùng khác xem hồ sơ;
  - **Thì** chỉ ngày và tháng sinh hiển thị — năm sinh không bao giờ xuất hiện.

- **AC-09 — Ngày sinh riêng tư theo mặc định:**
  - **Giả sử** người dùng vừa nhập ngày sinh lần đầu;
  - **Khi** người dùng khác xem hồ sơ ngay sau đó;
  - **Thì** ngày sinh không hiển thị — mặc định là riêng tư.

- **AC-12 — Hiển thị trạng thái Premium trên hồ sơ:**
  - **Giả sử** người dùng đang ở gói Premium và mở màn hình hồ sơ;
  - **Khi** xem trang hồ sơ của mình;
  - **Thì** nhãn "Premium" và ngày hết hạn gói hiển thị rõ ràng; không có nút "Nâng cấp Premium".

- **AC-13 — Người dùng Free thấy nút nâng cấp:**
  - **Giả sử** người dùng đang ở gói Free và mở màn hình hồ sơ;
  - **Khi** xem trang hồ sơ của mình;
  - **Thì** nhãn "Free" hiển thị và nút "Nâng cấp Premium" xuất hiện; nhấn vào dẫn đến màn hình nâng cấp.

- **AC-14 — Trạng thái gói không hiển thị với người xem khác:**
  - **Giả sử** người dùng A đang xem hồ sơ công khai của người dùng B;
  - **Khi** xem trang hồ sơ đó;
  - **Thì** không có nhãn Free / Premium nào của B hiển thị với A.

### Offline

- **AC-10 — Xem hồ sơ khi mất mạng:**
  - **Giả sử** người dùng đã từng xem hồ sơ khi có mạng và sau đó mất kết nối;
  - **Khi** mở lại màn hình hồ sơ;
  - **Thì** hồ sơ vẫn hiển thị theo dữ liệu đã tải lần cuối và app hiện thông báo "Đang xem ngoại tuyến".

- **AC-11 — Không cho lưu thay đổi khi mất mạng:**
  - **Giả sử** người dùng đang chỉnh sửa thông tin hồ sơ và mất kết nối trước khi lưu;
  - **Khi** nhấn lưu (ảnh đại diện, tên hiển thị, username, ngày sinh hoặc tùy chọn riêng tư);
  - **Thì** app thông báo "Không có kết nối. Vui lòng thử lại khi có mạng.", không thực hiện lưu, và giữ nguyên nội dung đã nhập trên màn hình.

## 5. Trường hợp ngoại lệ & lỗi

- Khi tên hiển thị vượt quá ba mươi ký tự: hệ thống báo lỗi ngay tại ô nhập, không cho lưu.
- Khi ảnh tải lên quá lớn hoặc định dạng không được hỗ trợ: thông báo lỗi định dạng và gợi ý dùng ảnh khác.
- Khi username mới đã bị người khác dùng: thông báo "Tên người dùng đã tồn tại".

### Khi mất kết nối (offline / no network)

- Khi mất kết nối, hồ sơ (ảnh đại diện, tên hiển thị, username, thống kê) vẫn hiển thị theo dữ liệu đã tải lần cuối; app hiện banner "Đang xem ngoại tuyến" để người dùng biết thông tin có thể chưa mới nhất.
- Khi mất kết nối, mọi nút lưu thay đổi (ảnh đại diện, tên hiển thị, username, ngày sinh, tùy chọn riêng tư) bị vô hiệu hoá; app thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." và giữ nguyên nội dung đang nhập trên màn hình để người dùng không phải nhập lại khi có mạng trở lại.

### Khi dữ liệu không tải được (lỗi mạng / lỗi máy chủ)

- Khi hồ sơ không tải được do lỗi mạng hoặc lỗi máy chủ và không có dữ liệu cache: màn hình hiển thị thông báo lỗi và nút "Thử lại" để người dùng tải lại mà không cần thoát.
- Khi có dữ liệu cache cũ nhưng không thể tải mới: hồ sơ vẫn hiển thị theo cache, đồng thời có thông báo nhỏ và nút "Thử lại" để làm mới.

### Khi chưa đăng nhập / thoát app giữa chừng

- Khi người dùng chưa đăng nhập cố truy cập màn hình hồ sơ: app chuyển ngay về màn hình đăng nhập, không hiển thị bất kỳ thông tin hồ sơ nào.
- Khi người dùng thoát app giữa chừng trong lúc đang chỉnh sửa hồ sơ nhưng chưa lưu: thay đổi chưa lưu bị huỷ; lần sau vào lại, hồ sơ hiển thị thông tin đã lưu trước đó.

---

## Liên kết tính năng khác

- SM-002 (Xác thực & Bảo mật): đổi mật khẩu trong cài đặt.
- SM-022 (Album sưu tập tem): bộ sưu tập hoàn chỉnh được đếm trong thống kê.
- SM-027 (Cài đặt tài khoản): ẩn thống kê hồ sơ, chặn người dùng.
- SM-028 (Nâng cấp Premium): lối tắt từ nút "Nâng cấp Premium" trên hồ sơ.
- SM-029 (Quản lý Premium): ngày hết hạn gói hiển thị trên hồ sơ lấy từ đây.

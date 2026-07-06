# Chụp / Chọn ảnh (SM-005)

**Feature Branch**: `005-chup-chon-anh`
**Ngày tạo**: 2026-06-24
**Trạng thái**: Draft
**Ưu tiên**: 🔴 P0

> **Tài liệu thuần nghiệp vụ** cho Tester (QA), Business Analyst (BA), Product Owner (PO).
> **KHÔNG chứa chi tiết kỹ thuật**. Phần plan / vẽ giao diện / develop được làm RIÊNG ở bước sau.

---

## 1. Mục đích nghiệp vụ

Là điểm bắt đầu của luồng tạo tem — người dùng cung cấp ảnh gốc để biến thành tem thư. Hỗ trợ chụp ảnh mới và chọn từ thư viện điện thoại để linh hoạt cho mọi tình huống.

## 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đã đăng nhập muốn tạo tem mới.
- **Khi nào dùng:** Khi bắt đầu luồng tạo tem (từ nút "Tạo tem" trên thanh điều hướng hoặc gợi ý trên màn hình chính).
- **Điều kiện tiên quyết:** Đã đăng nhập. App cần quyền truy cập camera và/hoặc thư viện ảnh của thiết bị.
- **Phạm vi:** Chụp ảnh mới hoặc chọn ảnh từ thư viện; kiểm tra kích thước tối đa. Không bao gồm xử lý ảnh (bộ lọc, xoá nền — các bước đó ở SM-006/007).

## 3. Quy tắc nghiệp vụ

- **BR-01 — Hai nguồn ảnh:** Người dùng chọn một trong hai: chụp ảnh bằng camera của thiết bị hoặc chọn ảnh có sẵn từ thư viện điện thoại.
- **BR-02 — Loại ảnh hỗ trợ:** Ứng dụng chấp nhận ảnh người, vật, phong cảnh, và đồ vật — không giới hạn chủ thể cụ thể.
- **BR-03 — Giới hạn kích thước file:** Ảnh được giới hạn kích thước tối đa để đảm bảo ứng dụng không bị chậm. Ảnh quá lớn bị từ chối với thông báo rõ ràng.
- **BR-04 — Chuyển sang bước tiếp:** Sau khi chọn/chụp ảnh thành công, tự động chuyển sang bước áp bộ lọc màu (SM-006).
- **BR-05 — Phóng to / thu nhỏ ảnh trước khi xác nhận:** Sau khi chụp hoặc chọn ảnh, màn hình xem trước cho phép người dùng kiểm tra ảnh kỹ trước khi sang bước tiếp theo. Cụ thể:
  - Banh hai ngón tay để phóng to; chụm hai ngón tay để thu nhỏ.
  - Chạm hai lần nhanh vào một vùng để phóng to vùng đó; chạm hai lần nhanh lần nữa để trở về toàn ảnh.
  - Mức thu nhỏ tối thiểu là vừa khung màn hình (không thu nhỏ hơn toàn ảnh).
  - Toàn bộ thao tác phóng to / thu nhỏ chỉ để xem — không thay đổi, không cắt xén ảnh gốc.
  - Khi nhấn "Xác nhận" hoặc chuyển bước, ảnh gốc nguyên vẹn được chuyển sang bước tiếp theo.

### Trạng thái offline

- **BR-06 — Chụp và chọn ảnh không cần mạng:** Việc chụp ảnh bằng camera và chọn ảnh từ thư viện điện thoại là thao tác cục bộ trên thiết bị — thực hiện được bình thường dù không có kết nối mạng.
- **BR-07 — Thông báo khi mất mạng ở bước cần kết nối:** Nếu bước tiếp theo sau khi chọn ảnh yêu cầu kết nối mạng (ví dụ: tải tài nguyên từ máy chủ), hệ thống thông báo rõ ràng rằng cần có mạng để tiếp tục và giữ nguyên ảnh đã chọn để người dùng không phải chọn lại.

## 4. Tiêu chí nghiệm thu

- **AC-01 — Chụp ảnh mới:**
  - **Giả sử** người dùng đã cấp quyền camera;
  - **Khi** chọn "Chụp ảnh" và chụp;
  - **Thì** ảnh vừa chụp được dùng cho bước tiếp theo (bộ lọc màu).

- **AC-02 — Chọn ảnh từ thư viện:**
  - **Giả sử** người dùng đã cấp quyền thư viện ảnh;
  - **Khi** chọn "Chọn từ thư viện" và chọn một ảnh;
  - **Thì** ảnh đó được dùng cho bước tiếp theo (bộ lọc màu).

- **AC-03 — Từ chối ảnh quá lớn:**
  - **Giả sử** người dùng chọn ảnh có kích thước vượt giới hạn tối đa;
  - **Khi** xác nhận ảnh;
  - **Thì** hệ thống thông báo ảnh quá lớn và yêu cầu chọn ảnh khác nhỏ hơn.

- **AC-04 — Yêu cầu cấp quyền khi chưa có:**
  - **Giả sử** người dùng chưa cấp quyền camera hoặc thư viện;
  - **Khi** chọn chụp ảnh hoặc chọn từ thư viện;
  - **Thì** hệ thống hiện hộp thoại xin cấp quyền từ hệ điều hành.

- **AC-05 — Phóng to bằng banh ngón tay:**
  - **Giả sử** người dùng đang ở màn hình xem trước ảnh;
  - **Khi** banh hai ngón tay trên ảnh;
  - **Thì** ảnh phóng to theo hướng banh; người dùng có thể kéo ảnh đã phóng to để xem các vùng khác nhau.

- **AC-08 — Thu nhỏ về toàn ảnh bằng chụm ngón tay:**
  - **Giả sử** người dùng đã phóng to ảnh;
  - **Khi** chụm hai ngón tay;
  - **Thì** ảnh thu nhỏ dần; dừng lại ở mức vừa khung màn hình và không thu nhỏ hơn nữa.

- **AC-09 — Chạm hai lần để phóng to / trở về toàn ảnh:**
  - **Giả sử** người dùng đang ở màn hình xem trước ảnh;
  - **Khi** chạm hai lần nhanh vào một vùng bất kỳ;
  - **Thì** ảnh phóng to vào vùng đó; chạm hai lần nhanh lần nữa thì trở về toàn ảnh vừa khung.

- **AC-10 — Ảnh gốc không đổi sau khi phóng to / thu nhỏ:**
  - **Giả sử** người dùng đã phóng to và thu nhỏ ảnh nhiều lần, rồi nhấn "Xác nhận";
  - **Khi** chuyển sang bước bộ lọc màu (SM-006);
  - **Thì** ảnh ở bước tiếp theo giống hệt ảnh gốc đã chọn — không bị cắt, không bị thay đổi tỉ lệ.

### Offline

- **AC-06 — Chụp và chọn ảnh khi mất mạng:**
  - **Giả sử** thiết bị không có kết nối mạng;
  - **Khi** người dùng chụp ảnh bằng camera hoặc chọn ảnh từ thư viện;
  - **Thì** thao tác hoàn thành bình thường, ảnh hiển thị trên màn hình xem trước đúng như khi có mạng.

- **AC-07 — Thông báo khi bước tiếp theo cần mạng nhưng đang offline:**
  - **Giả sử** thiết bị không có kết nối mạng và người dùng đã chọn ảnh thành công;
  - **Khi** hệ thống phát hiện bước tiếp theo yêu cầu kết nối mạng và không thể tiếp tục;
  - **Thì** hệ thống hiển thị thông báo rõ ràng rằng cần có mạng để tiếp tục, đồng thời giữ nguyên ảnh đã chọn để người dùng không cần chọn lại.

## 5. Trường hợp ngoại lệ & lỗi

- Khi người dùng từ chối cấp quyền camera: thông báo rõ ràng và hướng dẫn vào cài đặt thiết bị để cấp quyền thủ công; tùy chọn chọn ảnh từ thư viện vẫn khả dụng.
- Khi người dùng từ chối cấp quyền thư viện: tương tự, hướng dẫn vào cài đặt; tùy chọn chụp ảnh vẫn khả dụng.
- Khi không có camera (thiết bị không hỗ trợ): tùy chọn chụp ảnh bị ẩn, chỉ hiển thị chọn từ thư viện.
- Khi thoát màn hình này giữa chừng: quay về màn hình chính, không có ảnh nào được lưu.
- Khi mất kết nối mạng: việc chụp ảnh bằng camera và chọn ảnh từ thư viện vẫn thực hiện bình thường vì là thao tác cục bộ; chỉ khi chuyển sang bước tiếp theo cần mạng, hệ thống mới hiển thị thông báo yêu cầu kết nối và giữ nguyên ảnh đã chọn.
- Khi bước tiếp theo trả về lỗi máy chủ (sau khi đã có mạng): hệ thống hiển thị thông báo lỗi kèm nút "Thử lại"; ảnh đã chọn được giữ nguyên, người dùng không cần chọn lại từ đầu.
- Khi chưa đăng nhập: tính năng chụp và chọn ảnh không khả dụng; hệ thống chuyển người dùng đến màn hình đăng nhập trước khi tiếp tục.
- Khi thoát app trong lúc đang xem trước ảnh chưa xử lý: ảnh đã chọn/chụp được giữ lại, lần mở app tiếp theo người dùng có thể tiếp tục từ bước xem trước mà không cần chọn lại.

---

## Liên kết tính năng khác

- SM-006 (Bộ lọc màu & Chỉnh ảnh): bước tiếp theo trong luồng tạo tem.
- SM-004 (Màn hình chính): điểm xuất phát của luồng tạo tem.

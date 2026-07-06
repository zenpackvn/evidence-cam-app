# Bộ lọc màu & Chỉnh ảnh thủ công (SM-006)

**Feature Branch**: `006-bo-loc-mau`
**Ngày tạo**: 2026-06-24
**Trạng thái**: Draft
**Ưu tiên**: 🔴 P0

> **Tài liệu thuần nghiệp vụ** cho Tester (QA), Business Analyst (BA), Product Owner (PO).
> **KHÔNG chứa chi tiết kỹ thuật**. Phần plan / vẽ giao diện / develop được làm RIÊNG ở bước sau.

---

## 1. Mục đích nghiệp vụ

Cho phép người dùng biến ảnh gốc thành phong cách thị giác phù hợp trước khi tạo tem — qua bộ lọc màu có sẵn hoặc chỉnh tay ba thông số cơ bản. Trải nghiệm xem trước theo thời gian thực giúp người dùng quyết định nhanh.

## 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đang trong luồng tạo tem, sau bước chọn ảnh.
- **Khi nào dùng:** Bước 2 của luồng tạo tem, ngay sau khi chọn/chụp ảnh (SM-005).
- **Điều kiện tiên quyết:** Đã có ảnh từ SM-005.
- **Phạm vi:** Áp bộ lọc màu và chỉnh ba thông số thủ công. Không bao gồm SM-008 (Trang trí tem) hay các bước chỉnh sửa sau.

## 3. Quy tắc nghiệp vụ

- **BR-01 — Tổng số bộ lọc:** Có mười sáu bộ lọc màu chia thành bốn nhóm chủ đề.
- **BR-02 — Bộ lọc Free:** Tám bộ lọc đầu (nhóm Cổ điển gồm bốn bộ lọc và nhóm Retro/Vintage gồm bốn bộ lọc) khả dụng cho tất cả người dùng, kể cả gói Thường.
- **BR-03 — Bộ lọc Premium:** Tám bộ lọc còn lại (nhóm Tâm trạng gồm bốn bộ lọc và nhóm Mùa gồm bốn bộ lọc) chỉ khả dụng cho người dùng gói Premium. Người dùng gói Thường thấy các bộ lọc này nhưng bị khoá; nhấn vào thì gợi ý nâng cấp Premium.
- **BR-04 — Ba thanh chỉnh thủ công:** Ngoài bộ lọc, người dùng có thể chỉnh tay ba thông số độc lập:
  - **Sáng/Tối** — kéo về phía Sáng làm ảnh sáng hơn; kéo về Tối làm ảnh tối hơn.
  - **Ấm/Lạnh** — kéo về phía Ấm làm màu sắc ngả vàng/cam; kéo về Lạnh làm màu ngả xanh.
  - **Nhạt/Đậm** — kéo về phía Nhạt làm màu sắc nhạt dần đến gần đen trắng; kéo về Đậm làm màu sắc sặc sỡ hơn.
  - Mỗi thanh có vị trí trung tâm là mặc định (không thay đổi gì). Ba thanh hoạt động độc lập và tích luỹ lên nhau.
  - Kết quả chỉnh tay được áp dụng sau bộ lọc màu — có thể dùng đồng thời.
- **BR-10 — Đặt lại chỉnh tay về mặc định:** Người dùng có thể đặt lại cả ba thanh về vị trí trung tâm bằng một thao tác "Đặt lại". Bộ lọc màu đang chọn không bị ảnh hưởng.
- **BR-11 — Tuỳ chọn "Gốc" (không bộ lọc):** Trong danh sách bộ lọc luôn có mục "Gốc" — chọn mục này bỏ toàn bộ bộ lọc, ảnh xem trước chỉ phản ánh phần chỉnh tay đang áp dụng (nếu có).
- **BR-05 — Xem trước theo thời gian thực:** Thay đổi bộ lọc hoặc thanh điều chỉnh phải phản ánh ngay trên ảnh xem trước, không cần nhấn xác nhận riêng.
- **BR-06 — Không mất ảnh gốc:** Các thay đổi chỉ là xem trước, ảnh gốc không bị thay đổi cho đến khi người dùng chuyển sang bước tiếp. Nếu quay lại bước trước, ảnh gốc vẫn nguyên vẹn.

### Trạng thái offline

- **BR-07 — Chỉnh màu và áp bộ lọc không cần mạng:** Toàn bộ thao tác chỉnh Sáng/Tối, Ấm/Lạnh, Nhạt/Đậm và áp bộ lọc Free đều hoạt động bình thường khi thiết bị mất kết nối mạng, vì các thao tác này chỉ xử lý trên ảnh đã có sẵn trong thiết bị.
- **BR-08 — Bộ lọc Premium khi offline:** Nếu người dùng đã xác nhận gói Premium trước đó, bộ lọc Premium vẫn khả dụng khi offline. Nếu trạng thái gói chưa được xác nhận (người dùng mới nâng cấp nhưng chưa đồng bộ), hệ thống thông báo "Không thể xác minh gói Premium. Vui lòng kiểm tra kết nối và thử lại." và giữ bộ lọc Premium ở trạng thái khoá.
- **BR-09 — Chuyển bước khi offline:** Khi người dùng nhấn "Tiếp theo" để chuyển sang bước trang trí tem (SM-008) trong khi mất mạng, thao tác vẫn được phép vì dữ liệu chỉnh ảnh lưu tạm trên thiết bị; không chặn luồng tạo tem.

## 4. Tiêu chí nghiệm thu

- **AC-01 — Áp bộ lọc Free và thấy thay đổi ngay:**
  - **Giả sử** người dùng gói Thường đang ở màn hình bộ lọc;
  - **Khi** chạm vào một trong tám bộ lọc Free;
  - **Thì** ảnh xem trước thay đổi ngay lập tức theo bộ lọc đã chọn.

- **AC-02 — Bộ lọc Premium bị khoá với người dùng Free:**
  - **Giả sử** người dùng gói Thường;
  - **Khi** nhấn vào một bộ lọc Premium (nhóm Tâm trạng hoặc Mùa);
  - **Thì** hệ thống hiển thị gợi ý nâng cấp Premium, không áp bộ lọc.

- **AC-03 — Thanh Sáng/Tối:**
  - **Giả sử** người dùng đang ở màn hình bộ lọc;
  - **Khi** kéo thanh Sáng/Tối về phía Sáng;
  - **Thì** ảnh xem trước sáng lên theo thời gian thực; kéo về Tối thì ảnh tối dần.

- **AC-08 — Thanh Ấm/Lạnh:**
  - **Giả sử** người dùng đang ở màn hình bộ lọc;
  - **Khi** kéo thanh Ấm/Lạnh về phía Ấm;
  - **Thì** màu ảnh ngả vàng/cam theo thời gian thực; kéo về Lạnh thì ảnh ngả xanh.

- **AC-09 — Thanh Nhạt/Đậm:**
  - **Giả sử** người dùng đang ở màn hình bộ lọc;
  - **Khi** kéo thanh Nhạt/Đậm về phía Nhạt đến cùng;
  - **Thì** ảnh gần như chuyển sang đen trắng; kéo về Đậm thì màu sắc sặc sỡ hơn ảnh gốc.

- **AC-10 — Đặt lại chỉnh tay về mặc định:**
  - **Giả sử** người dùng đã kéo cả ba thanh khỏi vị trí trung tâm;
  - **Khi** nhấn "Đặt lại";
  - **Thì** cả ba thanh trở về vị trí trung tâm; ảnh xem trước quay về trạng thái chỉ có bộ lọc màu (nếu đang chọn bộ lọc).

- **AC-11 — Chọn "Gốc" bỏ toàn bộ bộ lọc:**
  - **Giả sử** người dùng đang áp một bộ lọc màu;
  - **Khi** chọn mục "Gốc" trong danh sách bộ lọc;
  - **Thì** bộ lọc bị bỏ; ảnh xem trước chỉ còn phản ánh phần chỉnh tay đang áp (ba thanh), không có bộ lọc nào.

- **AC-04 — Bộ lọc và chỉnh tay dùng đồng thời:**
  - **Giả sử** người dùng đã chọn một bộ lọc;
  - **Khi** kéo thêm thanh Ấm/Lạnh;
  - **Thì** ảnh xem trước phản ánh cả hai thay đổi cùng lúc.

- **AC-05 — Bộ lọc Premium mở khoá khi dùng Premium:**
  - **Giả sử** người dùng đã nâng cấp lên gói Premium;
  - **Khi** vào màn hình bộ lọc;
  - **Thì** tất cả mười sáu bộ lọc đều có thể chọn được.

### Offline

- **AC-06 — Chỉnh màu và bộ lọc Free hoạt động khi offline:**
  - **Giả sử** người dùng đang ở màn hình bộ lọc và thiết bị mất kết nối mạng;
  - **Khi** kéo thanh Sáng/Tối hoặc chạm vào một bộ lọc Free;
  - **Thì** ảnh xem trước vẫn cập nhật bình thường, không hiển thị lỗi mạng.

- **AC-07 — Bộ lọc Premium bị khoá khi offline và chưa xác nhận gói:**
  - **Giả sử** người dùng vừa nâng cấp Premium nhưng thiết bị mất mạng trước khi trạng thái gói được xác nhận;
  - **Khi** nhấn vào một bộ lọc Premium;
  - **Thì** hệ thống hiển thị thông báo "Không thể xác minh gói Premium. Vui lòng kiểm tra kết nối và thử lại.", bộ lọc không được áp dụng.

## 5. Trường hợp ngoại lệ & lỗi

- Khi thiết bị yếu xử lý chậm: xem trước có thể có độ trễ nhỏ nhưng phải cập nhật trong vòng vài giây; không được đứng hình.
- Khi quay lại bước chọn ảnh: ảnh gốc giữ nguyên, bộ lọc đang chọn bị huỷ.
- Khi thoát app giữa chừng bước này: khi quay lại app, trở về màn hình chính (không lưu trạng thái bộ lọc đang chọn).
- Khi mất kết nối (offline): toàn bộ thao tác chỉnh màu và áp bộ lọc Free vẫn hoạt động bình thường vì xử lý cục bộ trên thiết bị; chỉ xác minh gói Premium mới cần mạng.
- Khi không thể xác minh gói Premium do mất mạng: hệ thống hiển thị thông báo yêu cầu kiểm tra kết nối và giữ bộ lọc Premium ở trạng thái khoá; các bộ lọc Free vẫn dùng được bình thường.
- Khi chưa đăng nhập: người dùng vẫn có thể chỉnh ảnh và áp bộ lọc Free; các bộ lọc Premium bị khoá và hiển thị gợi ý đăng nhập / nâng cấp khi nhấn vào.

---

## Liên kết tính năng khác

- SM-005 (Chụp/Chọn ảnh): bước trước — cung cấp ảnh gốc.
- SM-008 (Trang trí tem): bước tiếp theo trong luồng tạo tem.
- SM-028 (Nâng cấp Premium): điểm đến khi nhấn gợi ý nâng cấp từ bộ lọc Premium.

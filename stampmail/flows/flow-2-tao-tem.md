# Flow 2 · Tạo tem

Từ một tấm ảnh đến con tem đã lưu trong Album.

---

## Chụp / Chọn ảnh (SM-005)

> Nguồn: `specs/005-chup-chon-anh.md`

**Màn hình & trạng thái:**

- **Nguồn ảnh**: Default · No-camera · Permission-denied
- **Xem ảnh**: Default · Zoomed · Too-large

### 1. Mục đích nghiệp vụ

Là điểm bắt đầu của luồng tạo tem — người dùng cung cấp ảnh gốc để biến thành tem thư. Hỗ trợ chụp ảnh mới và chọn từ thư viện điện thoại để linh hoạt cho mọi tình huống.

### 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đã đăng nhập muốn tạo tem mới.
- **Khi nào dùng:** Khi bắt đầu luồng tạo tem (từ nút "Tạo tem" trên thanh điều hướng hoặc gợi ý trên màn hình chính).
- **Điều kiện tiên quyết:** Đã đăng nhập. App cần quyền truy cập camera và/hoặc thư viện ảnh của thiết bị.
- **Phạm vi:** Chụp ảnh mới hoặc chọn ảnh từ thư viện; kiểm tra kích thước tối đa. Không bao gồm xử lý ảnh (bộ lọc, xoá nền — các bước đó ở SM-006/007).

### 3. Quy tắc nghiệp vụ

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

#### Trạng thái offline

- **BR-06 — Chụp và chọn ảnh không cần mạng:** Việc chụp ảnh bằng camera và chọn ảnh từ thư viện điện thoại là thao tác cục bộ trên thiết bị — thực hiện được bình thường dù không có kết nối mạng.
- **BR-07 — Thông báo khi mất mạng ở bước cần kết nối:** Nếu bước tiếp theo sau khi chọn ảnh yêu cầu kết nối mạng (ví dụ: tải tài nguyên từ máy chủ), hệ thống thông báo rõ ràng rằng cần có mạng để tiếp tục và giữ nguyên ảnh đã chọn để người dùng không phải chọn lại.

### 4. Tiêu chí nghiệm thu

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

#### Offline

- **AC-06 — Chụp và chọn ảnh khi mất mạng:**
  - **Giả sử** thiết bị không có kết nối mạng;
  - **Khi** người dùng chụp ảnh bằng camera hoặc chọn ảnh từ thư viện;
  - **Thì** thao tác hoàn thành bình thường, ảnh hiển thị trên màn hình xem trước đúng như khi có mạng.

- **AC-07 — Thông báo khi bước tiếp theo cần mạng nhưng đang offline:**
  - **Giả sử** thiết bị không có kết nối mạng và người dùng đã chọn ảnh thành công;
  - **Khi** hệ thống phát hiện bước tiếp theo yêu cầu kết nối mạng và không thể tiếp tục;
  - **Thì** hệ thống hiển thị thông báo rõ ràng rằng cần có mạng để tiếp tục, đồng thời giữ nguyên ảnh đã chọn để người dùng không cần chọn lại.

### 5. Trường hợp ngoại lệ & lỗi

- Khi người dùng từ chối cấp quyền camera: thông báo rõ ràng và hướng dẫn vào cài đặt thiết bị để cấp quyền thủ công; tùy chọn chọn ảnh từ thư viện vẫn khả dụng.
- Khi người dùng từ chối cấp quyền thư viện: tương tự, hướng dẫn vào cài đặt; tùy chọn chụp ảnh vẫn khả dụng.
- Khi không có camera (thiết bị không hỗ trợ): tùy chọn chụp ảnh bị ẩn, chỉ hiển thị chọn từ thư viện.
- Khi thoát màn hình này giữa chừng: quay về màn hình chính, không có ảnh nào được lưu.
- Khi mất kết nối mạng: việc chụp ảnh bằng camera và chọn ảnh từ thư viện vẫn thực hiện bình thường vì là thao tác cục bộ; chỉ khi chuyển sang bước tiếp theo cần mạng, hệ thống mới hiển thị thông báo yêu cầu kết nối và giữ nguyên ảnh đã chọn.
- Khi bước tiếp theo trả về lỗi máy chủ (sau khi đã có mạng): hệ thống hiển thị thông báo lỗi kèm nút "Thử lại"; ảnh đã chọn được giữ nguyên, người dùng không cần chọn lại từ đầu.
- Khi chưa đăng nhập: tính năng chụp và chọn ảnh không khả dụng; hệ thống chuyển người dùng đến màn hình đăng nhập trước khi tiếp tục.
- Khi thoát app trong lúc đang xem trước ảnh chưa xử lý: ảnh đã chọn/chụp được giữ lại, lần mở app tiếp theo người dùng có thể tiếp tục từ bước xem trước mà không cần chọn lại.

---

### Liên kết tính năng khác

- SM-006 (Bộ lọc màu & Chỉnh ảnh): bước tiếp theo trong luồng tạo tem.
- SM-004 (Màn hình chính): điểm xuất phát của luồng tạo tem.

---

## Bộ lọc màu & Chỉnh ảnh thủ công (SM-006)

> Nguồn: `specs/006-bo-loc-mau.md`

**Màn hình & trạng thái:**

- **Bộ lọc**: Default · Filter-applied · Manual-adjusted · Premium-locked · Offline

### 1. Mục đích nghiệp vụ

Cho phép người dùng biến ảnh gốc thành phong cách thị giác phù hợp trước khi tạo tem — qua bộ lọc màu có sẵn hoặc chỉnh tay ba thông số cơ bản. Trải nghiệm xem trước theo thời gian thực giúp người dùng quyết định nhanh.

### 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đang trong luồng tạo tem, sau bước chọn ảnh.
- **Khi nào dùng:** Bước 2 của luồng tạo tem, ngay sau khi chọn/chụp ảnh (SM-005).
- **Điều kiện tiên quyết:** Đã có ảnh từ SM-005.
- **Phạm vi:** Áp bộ lọc màu và chỉnh ba thông số thủ công. Không bao gồm SM-008 (Trang trí tem) hay các bước chỉnh sửa sau.

### 3. Quy tắc nghiệp vụ

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

#### Trạng thái offline

- **BR-07 — Chỉnh màu và áp bộ lọc không cần mạng:** Toàn bộ thao tác chỉnh Sáng/Tối, Ấm/Lạnh, Nhạt/Đậm và áp bộ lọc Free đều hoạt động bình thường khi thiết bị mất kết nối mạng, vì các thao tác này chỉ xử lý trên ảnh đã có sẵn trong thiết bị.
- **BR-08 — Bộ lọc Premium khi offline:** Nếu người dùng đã xác nhận gói Premium trước đó, bộ lọc Premium vẫn khả dụng khi offline. Nếu trạng thái gói chưa được xác nhận (người dùng mới nâng cấp nhưng chưa đồng bộ), hệ thống thông báo "Không thể xác minh gói Premium. Vui lòng kiểm tra kết nối và thử lại." và giữ bộ lọc Premium ở trạng thái khoá.
- **BR-09 — Chuyển bước khi offline:** Khi người dùng nhấn "Tiếp theo" để chuyển sang bước trang trí tem (SM-008) trong khi mất mạng, thao tác vẫn được phép vì dữ liệu chỉnh ảnh lưu tạm trên thiết bị; không chặn luồng tạo tem.

### 4. Tiêu chí nghiệm thu

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

#### Offline

- **AC-06 — Chỉnh màu và bộ lọc Free hoạt động khi offline:**
  - **Giả sử** người dùng đang ở màn hình bộ lọc và thiết bị mất kết nối mạng;
  - **Khi** kéo thanh Sáng/Tối hoặc chạm vào một bộ lọc Free;
  - **Thì** ảnh xem trước vẫn cập nhật bình thường, không hiển thị lỗi mạng.

- **AC-07 — Bộ lọc Premium bị khoá khi offline và chưa xác nhận gói:**
  - **Giả sử** người dùng vừa nâng cấp Premium nhưng thiết bị mất mạng trước khi trạng thái gói được xác nhận;
  - **Khi** nhấn vào một bộ lọc Premium;
  - **Thì** hệ thống hiển thị thông báo "Không thể xác minh gói Premium. Vui lòng kiểm tra kết nối và thử lại.", bộ lọc không được áp dụng.

### 5. Trường hợp ngoại lệ & lỗi

- Khi thiết bị yếu xử lý chậm: xem trước có thể có độ trễ nhỏ nhưng phải cập nhật trong vòng vài giây; không được đứng hình.
- Khi quay lại bước chọn ảnh: ảnh gốc giữ nguyên, bộ lọc đang chọn bị huỷ.
- Khi thoát app giữa chừng bước này: khi quay lại app, trở về màn hình chính (không lưu trạng thái bộ lọc đang chọn).
- Khi mất kết nối (offline): toàn bộ thao tác chỉnh màu và áp bộ lọc Free vẫn hoạt động bình thường vì xử lý cục bộ trên thiết bị; chỉ xác minh gói Premium mới cần mạng.
- Khi không thể xác minh gói Premium do mất mạng: hệ thống hiển thị thông báo yêu cầu kiểm tra kết nối và giữ bộ lọc Premium ở trạng thái khoá; các bộ lọc Free vẫn dùng được bình thường.
- Khi chưa đăng nhập: người dùng vẫn có thể chỉnh ảnh và áp bộ lọc Free; các bộ lọc Premium bị khoá và hiển thị gợi ý đăng nhập / nâng cấp khi nhấn vào.

---

### Liên kết tính năng khác

- SM-005 (Chụp/Chọn ảnh): bước trước — cung cấp ảnh gốc.
- SM-008 (Trang trí tem): bước tiếp theo trong luồng tạo tem.
- SM-028 (Nâng cấp Premium): điểm đến khi nhấn gợi ý nâng cấp từ bộ lọc Premium.

---

## Trang trí tem (SM-008)

> Nguồn: `specs/007-trang-tri-tem.md`

**Màn hình & trạng thái:**

- **Trang trí**: Default · Element-selected · Locked-sticker-sheet · Sticker-error

### 1. Mục đích nghiệp vụ

Cho phép người dùng thêm cá tính vào tem bằng sticker, chữ, biểu tượng và hoa văn nền — làm cho mỗi tem trở nên độc đáo và mang dấu ấn riêng của người gửi.

### 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đang trong luồng tạo tem, sau bước xoá nền.
- **Khi nào dùng:** Bước 3 của luồng tạo tem, sau SM-006.
- **Điều kiện tiên quyết:** Đã qua bước bộ lọc màu (SM-006).
- **Phạm vi:** Thêm và chỉnh vị trí sticker, chữ, biểu tượng, hoa văn nền. Không bao gồm viền tem (SM-009).

### 3. Quy tắc nghiệp vụ

- **BR-01 — Bộ sticker theo chủ đề:** Người dùng có thể thêm sticker từ các bộ theo chủ đề: mùa (xuân, hạ, thu, đông), cảm xúc (vui, yêu, nhớ…), thiên nhiên (hoa, lá, bầu trời…).
- **BR-02 — Sticker Free vs Khóa:** Bộ sticker cơ bản gồm năm mươi sticker khả dụng cho tất cả người dùng gói Thường. Bộ sticker đặc biệt bị khóa mặc định — người dùng gói Thường thấy được nhưng không dùng được cho đến khi mở khóa theo một trong hai cách: nâng cấp Premium (mở toàn bộ) hoặc dùng Dấu (mở từng bộ riêng lẻ, xem BR-07 và SM-033).
- **BR-03 — Chữ tuỳ chỉnh:** Người dùng có thể thêm dòng chữ, chọn font (ít nhất hai lựa chọn: tay viết và in ấn), chỉnh kích thước và màu chữ.
- **BR-04 — Biểu tượng và hoa văn nền:** Người dùng có thể thêm biểu tượng nhỏ (icon) và áp hoa văn nhẹ làm nền cho tem.
- **BR-05 — Thao tác trên phần tử trang trí:** Mọi thành phần đã thêm (sticker, chữ, biểu tượng) đều có thể thao tác trực tiếp trên vùng tem bằng các cử chỉ sau:
  - **Chọn:** Chạm một lần vào phần tử → phần tử được chọn, hiển thị khung điều khiển xung quanh. Chạm ra ngoài → bỏ chọn.
  - **Di chuyển:** Giữ và kéo ngón tay trên phần tử đang chọn → phần tử di chuyển theo ngón tay đến bất kỳ vị trí nào trong vùng tem.
  - **Phóng to:** Banh hai ngón tay trên phần tử → phần tử to ra theo tỉ lệ.
  - **Thu nhỏ:** Chụm hai ngón tay trên phần tử → phần tử nhỏ lại theo tỉ lệ.
  - **Xoay:** Xoay hai ngón tay theo chiều kim đồng hồ hoặc ngược lại → phần tử xoay theo góc tương ứng.
- **BR-10 — Giới hạn kích thước phần tử:** Mỗi phần tử có kích thước tối thiểu (đủ nhìn thấy, không nhỏ hơn một phần mười chiều rộng vùng tem) và tối đa (không lớn hơn toàn bộ vùng tem). Khi đạt giới hạn, hệ thống dừng thay đổi kích thước — không báo lỗi, không làm phần tử biến mất.
- **BR-06 — Bỏ qua trang trí:** Người dùng có thể không thêm gì và chuyển thẳng sang bước viền tem (SM-009).
- **BR-07 — Mở sticker đặc biệt bằng Dấu:** Người dùng gói Thường dùng **50📮** (SM-033 BR-11) để mở vĩnh viễn một bộ sticker đặc biệt cụ thể. Mỗi lần chỉ mở một bộ; sau khi mở, bộ đó luôn khả dụng cho tài khoản này.

#### Trạng thái offline

- **BR-08 — Trang trí cục bộ không cần mạng:** Khi mất kết nối mạng, người dùng vẫn thực hiện được toàn bộ thao tác trang trí (thêm sticker đã tải sẵn, thêm chữ, kéo thả, thay đổi kích thước, xoay) vì các thao tác này chỉ diễn ra trên thiết bị.
- **BR-09 — Tải sticker đặc biệt cần mạng:** Khi mất kết nối, nếu người dùng chọn một bộ sticker đặc biệt chưa được tải về thiết bị, hệ thống thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." và không tải bộ sticker đó; các sticker đã tải sẵn trước đó vẫn dùng được bình thường.

### 4. Tiêu chí nghiệm thu

- **AC-01 — Thêm sticker Free:**
  - **Giả sử** người dùng gói Thường đang ở bước trang trí;
  - **Khi** chọn một sticker từ bộ cơ bản và đặt lên tem;
  - **Thì** sticker xuất hiện trên vùng xem trước tem và có thể kéo đến vị trí mong muốn.

- **AC-02 — Sticker đặc biệt bị khóa — hiện hai lựa chọn:**
  - **Giả sử** người dùng gói Thường;
  - **Khi** nhấn vào một sticker đặc biệt bị khóa;
  - **Thì** hệ thống hiển thị hai lựa chọn: "Dùng 50📮 để mở bộ này" và "Nâng cấp Premium để mở tất cả"; không đặt sticker lên tem cho đến khi chọn một trong hai.

- **AC-03 — Thêm chữ và chọn font:**
  - **Giả sử** người dùng đang ở bước trang trí;
  - **Khi** chọn thêm chữ, nhập nội dung và chọn font;
  - **Thì** chữ hiển thị trên tem với font đã chọn và có thể kéo đến vị trí mong muốn.

- **AC-04 — Chọn và di chuyển phần tử:**
  - **Giả sử** đã có ít nhất một sticker trên tem;
  - **Khi** người dùng chạm vào sticker rồi kéo đến góc khác của tem;
  - **Thì** sticker di chuyển theo đúng hướng ngón tay và dừng tại vị trí thả; các phần tử khác không bị ảnh hưởng.

- **AC-05 — Phóng to sticker bằng banh ngón tay:**
  - **Giả sử** đã có một sticker trên tem và đang được chọn;
  - **Khi** người dùng đặt hai ngón tay lên sticker và banh ra;
  - **Thì** sticker to ra tỉ lệ theo độ banh; dừng banh thì kích thước giữ nguyên ở mức đó.

- **AC-09 — Thu nhỏ sticker bằng chụm ngón tay:**
  - **Giả sử** đã có một sticker kích thước lớn trên tem;
  - **Khi** người dùng đặt hai ngón tay lên sticker và chụm vào;
  - **Thì** sticker nhỏ lại theo độ chụm; không nhỏ hơn kích thước tối thiểu (vẫn nhìn thấy được).

- **AC-10 — Xoay phần tử:**
  - **Giả sử** đã có một sticker trên tem;
  - **Khi** người dùng đặt hai ngón tay lên sticker và xoay theo chiều kim đồng hồ;
  - **Thì** sticker xoay theo đúng hướng; thả tay thì sticker giữ nguyên góc xoay đó.

- **AC-11 — Kích thước tối đa không vượt vùng tem:**
  - **Giả sử** người dùng đang banh một sticker cho đến khi lấp đầy toàn bộ vùng tem;
  - **Khi** tiếp tục banh ngón tay;
  - **Thì** sticker không lớn thêm nữa — kích thước dừng lại ở mức vừa vùng tem.

- **AC-06 — Mở sticker đặc biệt bằng Dấu:**
  - **Giả sử** người dùng gói Thường có ≥ 50📮 và nhấn vào bộ sticker đặc biệt bị khóa;
  - **Khi** chọn "Dùng 50📮 để mở bộ này" và xác nhận;
  - **Thì** bộ sticker mở vĩnh viễn, số Dấu giảm 50📮, người dùng dùng được sticker đó ngay.

#### Offline

- **AC-07 — Trang trí vẫn hoạt động khi mất mạng:**
  - **Giả sử** người dùng đang ở bước trang trí và thiết bị mất kết nối mạng;
  - **Khi** người dùng thêm sticker đã tải sẵn, nhập chữ, kéo thả và xoay các phần tử trên tem;
  - **Thì** tất cả thao tác vẫn thực hiện được bình thường, không có thông báo lỗi nào xuất hiện.

- **AC-08 — Báo lỗi khi tải bộ sticker chưa có trên thiết bị lúc mất mạng:**
  - **Giả sử** người dùng đang ở bước trang trí và thiết bị mất kết nối mạng;
  - **Khi** người dùng chọn một bộ sticker đặc biệt chưa được tải về thiết bị;
  - **Thì** hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng.", bộ sticker không được tải, các sticker đã có sẵn trên thiết bị vẫn dùng được.

### 5. Trường hợp ngoại lệ & lỗi

- Khi người dùng thêm quá nhiều phần tử và tem trở nên chật: không giới hạn số lượng phần tử trang trí; hệ thống không tự xoá bất kỳ thứ gì.
- Khi thoát app giữa bước trang trí: mất toàn bộ nội dung đang chỉnh, quay về màn hình chính khi mở lại.
- Khi muốn xoá một phần tử đã thêm: người dùng chọn phần tử rồi nhấn xoá; phần tử biến mất khỏi tem.

#### Khi mất kết nối (offline)

- Toàn bộ thao tác trang trí với sticker và font đã tải sẵn vẫn hoạt động bình thường khi mất mạng — người dùng không thấy thông báo lỗi nào.
- Khi mất mạng mà người dùng chọn bộ sticker đặc biệt chưa tải về thiết bị, hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." và không tải bộ đó; các sticker đã có sẵn vẫn dùng được.
- Tính năng thêm và chỉnh chữ (nhập nội dung, chọn font, đổi màu, kéo thả) không cần mạng và vẫn hoạt động đầy đủ khi offline.

#### Khi dữ liệu không tải được (lỗi mạng / lỗi máy chủ)

- Khi có mạng nhưng tải bộ sticker đặc biệt thất bại do lỗi máy chủ, hệ thống hiển thị thông báo lỗi kèm nút "Thử lại" để người dùng tải lại mà không cần thoát bước trang trí.
- Nếu tải lại vẫn thất bại, người dùng có thể tiếp tục trang trí bằng các sticker và font đã có sẵn trên thiết bị.

#### Khi chưa đăng nhập / thoát app giữa chừng

- Người dùng chưa đăng nhập không thể truy cập bước trang trí tem; hệ thống chuyển về màn hình đăng nhập khi người dùng cố vào luồng tạo tem.
- Khi thoát app giữa bước trang trí (bao gồm cả trường hợp app bị đóng đột ngột), toàn bộ nội dung đang trang trí bị huỷ; lần sau vào lại app, người dùng phải bắt đầu lại từ đầu luồng tạo tem.

---

### Liên kết tính năng khác

- SM-009 (Viền & Khung tem): bước tiếp theo.
- SM-028 (Nâng cấp Premium): lựa chọn mở toàn bộ sticker đặc biệt cùng lúc.
- SM-033 (Hệ thống Dấu): lựa chọn mở từng bộ sticker riêng lẻ bằng 50📮.

---

## Viền & Khung tem (SM-009)

> Nguồn: `specs/008-vien-khung-tem.md`

**Màn hình & trạng thái:**

- **Viền & Khung**: Default · Border-selected · Locked-border-sheet · Offline

### 1. Mục đích nghiệp vụ

Hoàn thiện tem bằng viền đặc trưng của tem thư thật — tạo nhận diện thị giác rõ ràng và cảm giác "đây đúng là một con tem". Viền là chi tiết định danh thương hiệu StampMail.

### 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đang trong luồng tạo tem, sau bước trang trí.
- **Khi nào dùng:** Bước 4 của luồng tạo tem, sau SM-008.
- **Điều kiện tiên quyết:** Đã qua bước trang trí tem (SM-008).
- **Phạm vi:** Chọn kiểu viền và màu viền; điều chỉnh vị trí và tỉ lệ ảnh bên trong khung. Không bao gồm xem trước toàn bộ tem hoàn chỉnh (SM-010) hay lưu (SM-011).

### 3. Quy tắc nghiệp vụ

- **BR-01 — Bảy kiểu viền:** Có bảy kiểu viền tổng cộng.
- **BR-02 — Viền Free:** Ba kiểu viền khả dụng cho tất cả người dùng gói Thường: Răng cưa cổ điển, Răng tròn, Gợn sóng.
- **BR-03 — Viền khóa:** Bốn kiểu viền còn lại bị khóa mặc định: Zigzag, Viền đôi, Retro bo mềm, Hoa văn nổi. Người dùng gói Thường thấy được nhưng không dùng được cho đến khi mở khóa theo một trong hai cách: nâng cấp Premium (mở toàn bộ) hoặc dùng Dấu (mở từng kiểu riêng lẻ, xem BR-06 và SM-033).
- **BR-04 — Màu viền:** Người dùng chọn màu cho viền từ một bảng màu có sẵn.
- **BR-05 — Xem trước trực tiếp:** Thay đổi kiểu viền hoặc màu viền phản ánh ngay trên ảnh xem trước tem, không cần xác nhận riêng.
- **BR-06 — Mở viền khóa bằng Dấu:** Người dùng gói Thường dùng **80📮** (SM-033 BR-12) để mở vĩnh viễn một kiểu viền đang bị khóa. Mỗi lần chỉ mở một kiểu; sau khi mở, kiểu đó luôn khả dụng cho tài khoản này.

#### Điều chỉnh ảnh trong khung

- **BR-10 — Di chuyển ảnh trong khung:** Sau khi chọn kiểu viền, người dùng có thể kéo một ngón tay trên vùng ảnh để dịch chuyển ảnh bên trong khung. Khung và viền giữ nguyên vị trí; chỉ phần ảnh hiển thị bên trong thay đổi.
- **BR-11 — Phóng to ảnh trong khung:** Người dùng banh hai ngón tay trên vùng ảnh để phóng to — làm nổi bật vùng chi tiết muốn hiển thị trong khung.
- **BR-12 — Thu nhỏ ảnh trong khung:** Người dùng chụm hai ngón tay để thu nhỏ — xem được nhiều vùng ảnh hơn bên trong khung. Ảnh không được thu nhỏ đến mức để lộ vùng trống bên trong khung; hệ thống tự dừng khi ảnh vừa phủ kín khung.
- **BR-13 — Ảnh phải phủ kín khung mọi lúc:** Trong khi điều chỉnh, không có vùng trống nào hiển thị bên trong đường viền tem. Nếu kéo ảnh ra ngoài quá mức, hệ thống tự giới hạn để cạnh ảnh không lùi vào trong khung.
- **BR-14 — Vị trí mặc định khi chọn viền mới:** Khi người dùng đổi sang kiểu viền khác, ảnh tự động về vị trí trung tâm và tỉ lệ vừa khung. Các điều chỉnh trước đó (di chuyển, zoom) bị đặt lại.

#### Trạng thái offline

- **BR-07 — Chỉnh viền không cần mạng:** Khi mất kết nối, người dùng vẫn chọn được kiểu viền (Free đã mở khóa), đổi màu viền và xem trước tem bình thường — các thao tác này diễn ra hoàn toàn trên thiết bị.
- **BR-08 — Mở khóa viền cần mạng:** Hành động dùng Dấu để mở viền khóa hoặc nâng cấp Premium đều yêu cầu kết nối mạng. Khi mất mạng, hệ thống chặn các hành động này và thông báo: "Không có kết nối. Vui lòng thử lại khi có mạng."
- **BR-09 — Trạng thái viền đã mở khóa vẫn giữ nguyên khi offline:** Các kiểu viền mà người dùng đã mở khóa trước đó vẫn khả dụng và có thể áp dụng khi không có mạng.

### 4. Tiêu chí nghiệm thu

- **AC-01 — Chọn viền Free và thấy ngay:**
  - **Giả sử** người dùng gói Thường đang ở bước viền;
  - **Khi** chọn một trong ba kiểu viền Free;
  - **Thì** xem trước tem hiển thị ngay kiểu viền đó.

- **AC-02 — Viền khóa — hiện hai lựa chọn:**
  - **Giả sử** người dùng gói Thường;
  - **Khi** nhấn vào một trong bốn kiểu viền đang bị khóa;
  - **Thì** hệ thống hiển thị hai lựa chọn: "Dùng 80📮 để mở kiểu viền này" và "Nâng cấp Premium để mở tất cả"; không áp viền cho đến khi chọn một trong hai.

- **AC-03 — Đổi màu viền:**
  - **Giả sử** người dùng đã chọn một kiểu viền;
  - **Khi** chọn màu khác từ bảng màu;
  - **Thì** viền trên xem trước chuyển sang màu mới ngay.

- **AC-04 — Tất cả viền khả dụng khi dùng Premium:**
  - **Giả sử** người dùng gói Premium;
  - **Khi** vào bước viền;
  - **Thì** cả bảy kiểu viền đều có thể chọn, không hiển thị gợi ý mở khóa.

- **AC-05 — Tiếp tục sang xem trước tem:**
  - **Giả sử** người dùng đã chọn xong kiểu và màu viền;
  - **Khi** nhấn Tiếp tục;
  - **Thì** chuyển sang màn hình xem trước tem hoàn chỉnh (SM-010).

- **AC-06 — Mở viền bằng Dấu:**
  - **Giả sử** người dùng gói Thường có ≥ 80📮 và nhấn vào kiểu viền đang bị khóa;
  - **Khi** chọn "Dùng 80📮 để mở kiểu viền này" và xác nhận;
  - **Thì** kiểu viền mở vĩnh viễn, số Dấu giảm 80📮, người dùng áp được ngay trên xem trước tem.

- **AC-09 — Di chuyển ảnh trong khung:**
  - **Giả sử** người dùng đã chọn một kiểu viền và đang ở bước viền;
  - **Khi** kéo một ngón tay trên vùng ảnh sang bên phải;
  - **Thì** ảnh dịch chuyển sang phải trong khung; viền và các thành phần trang trí giữ nguyên vị trí.

- **AC-10 — Phóng to ảnh trong khung:**
  - **Giả sử** người dùng đã chọn kiểu viền;
  - **Khi** đặt hai ngón tay lên vùng ảnh và banh ra;
  - **Thì** ảnh phóng to bên trong khung, làm nổi bật vùng chi tiết giữa hai ngón tay.

- **AC-11 — Thu nhỏ dừng khi ảnh vừa phủ khung:**
  - **Giả sử** người dùng đã phóng to ảnh;
  - **Khi** chụm hai ngón tay để thu nhỏ dần cho đến khi ảnh gần bằng kích thước khung;
  - **Thì** ảnh thu nhỏ đến mức vừa phủ kín toàn bộ khung rồi dừng lại; không có vùng trống nào xuất hiện bên trong viền tem.

- **AC-12 — Kéo ảnh không lộ vùng trống:**
  - **Giả sử** ảnh đang ở kích thước vừa khung và người dùng kéo ảnh về một phía;
  - **Khi** tiếp tục kéo đến mức cạnh ảnh gần vào trong khung;
  - **Thì** hệ thống chặn, ảnh không di chuyển thêm; cạnh ảnh không lùi vào bên trong đường viền.

- **AC-13 — Đổi kiểu viền đặt lại vị trí ảnh:**
  - **Giả sử** người dùng đã phóng to và dịch ảnh sang một góc;
  - **Khi** chọn sang kiểu viền khác;
  - **Thì** ảnh tự động về trung tâm, tỉ lệ vừa khung mới; các điều chỉnh trước bị đặt lại.

#### Offline

- **AC-07 — Chỉnh viền và xem trước khi offline:**
  - **Giả sử** người dùng đang ở bước viền và thiết bị mất kết nối mạng;
  - **Khi** chọn kiểu viền Free (hoặc kiểu đã mở khóa trước đó) và đổi màu viền;
  - **Thì** xem trước tem cập nhật ngay như khi có mạng, không xuất hiện thông báo lỗi.

- **AC-08 — Chặn mở khóa viền khi offline:**
  - **Giả sử** người dùng gói Thường đang ở bước viền và thiết bị mất kết nối mạng;
  - **Khi** nhấn vào kiểu viền đang bị khóa và chọn mở bằng Dấu hoặc nâng cấp Premium;
  - **Thì** hệ thống chặn hành động và hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."; số Dấu không thay đổi.

### 5. Trường hợp ngoại lệ & lỗi

- Khi người dùng không chọn kiểu viền nào và nhấn Tiếp tục: hệ thống áp kiểu viền mặc định (Răng cưa cổ điển) và chuyển bước.
- Khi thoát app giữa bước viền: mất toàn bộ nội dung đang chỉnh, quay về màn hình chính khi mở lại.

#### Khi mất kết nối (offline)

- Các kiểu viền đã tải về trước đó (Free và đã mở khóa) vẫn hiển thị và chọn được bình thường; xem trước tem hoạt động đầy đủ.
- Các kiểu viền chưa tải về (viền mới chưa từng tải) không hiển thị nội dung, kèm ghi chú "Cần kết nối để tải viền mới."
- Hành động mở khóa viền bằng Dấu hoặc nâng cấp Premium bị vô hiệu hoá; hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." và số Dấu không thay đổi.

#### Khi dữ liệu không tải được (lỗi mạng / lỗi máy chủ)

- Nếu danh sách viền không tải được, màn hình hiển thị biểu tượng lỗi và thông báo "Không thể tải viền. Vui lòng thử lại."; có nút "Thử lại" để tải lại danh sách.
- Nếu thao tác mở khóa viền thất bại do lỗi máy chủ, hệ thống thông báo "Mở khóa không thành công. Vui lòng thử lại." và không trừ Dấu của người dùng.

#### Khi chưa đăng nhập / thoát app giữa chừng

- Người dùng chưa đăng nhập không thể vào bước viền; hệ thống chuyển đến màn hình đăng nhập trước khi cho phép tạo tem.
- Khi thoát app giữa bước viền (đóng app hoặc chuyển app khác rồi bị hệ thống thu hồi), toàn bộ nội dung tem đang trang trí bị huỷ; lần mở lại app, người dùng bắt đầu lại từ màn hình chính.

---

### Liên kết tính năng khác

- SM-008 (Trang trí tem): bước trước.
- SM-010 (Xem trước tem hoàn chỉnh): bước tiếp theo.
- SM-028 (Nâng cấp Premium): lựa chọn mở toàn bộ viền khóa cùng lúc.
- SM-033 (Hệ thống Dấu): lựa chọn mở từng kiểu viền riêng lẻ bằng 80📮.

---

## Xem trước & Lưu tem (SM-010 + SM-011)

> Nguồn: `specs/009-luu-tem.md`

**Màn hình & trạng thái:**

- **Xem trước tem**: Default · Bg-changed
- **Lưu tem**: Success · Quota-reached · Share-limit · Offline

### 1. Mục đích nghiệp vụ

Hoàn tất luồng tạo tem qua hai bước liên tiếp:

1. **Xem trước (SM-010)** — Cho người dùng thấy tem đúng như kết quả cuối cùng trước khi lưu, trên nhiều màu nền khác nhau. Là bước "kiểm tra chất lượng" cuối — tránh lưu xong mới phát hiện cần chỉnh lại.
2. **Lưu vào Album (SM-011)** — Lưu tem đã hoàn chỉnh vào bộ sưu tập cá nhân và tạo điểm chuyển tiếp tự nhiên: gợi ý dùng tem vừa tạo ngay (đính lên thư hoặc chia sẻ lên mạng xã hội).

### 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đang trong luồng tạo tem, sau bước viền (SM-009).
- **Khi nào dùng:** Bước 5–6 (cuối) của luồng tạo tem.
- **Điều kiện tiên quyết:** Đã hoàn thành bước viền & khung tem (SM-009).
- **Phạm vi:** Xem trước tem ở kích thước thực, đổi màu nền xem trước, quay lại chỉnh sửa bất kỳ bước nào, lưu tem vào Album, gợi ý hành động sau lưu. Không bao gồm xem Album (SM-022) hay đính tem lên thư (SM-014).

### 3. Quy tắc nghiệp vụ

#### A. Xem trước tem

- **BR-01 — Kích thước thật:** Tem hiển thị mặc định ở kích thước thật để người dùng đánh giá chính xác.
- **BR-02 — Nhiều màu nền:** Người dùng có thể xem tem trên ít nhất ba màu nền khác nhau (trắng, đen, xám nhạt) để kiểm tra tem trông như thế nào trong các ngữ cảnh khác nhau.
- **BR-03 — Quay lại chỉnh sửa:** Từ màn hình xem trước, người dùng có thể quay lại bất kỳ bước nào trước đó trong luồng tạo tem (bộ lọc màu, trang trí, viền) để chỉnh sửa.
- **BR-04 — Nút Lưu tem:** Từ màn hình xem trước, nhấn "Lưu tem" để chuyển sang bước lưu.
- **BR-05 — Phóng to kiểm tra chi tiết:** Người dùng có thể dùng cử chỉ banh/chụm ngón tay để phóng to bất kỳ vùng nào của tem nhằm kiểm tra chi tiết (viền, sticker, chữ, chất lượng ảnh). Chỉ để xem — không thay đổi tem thật.

#### B. Lưu tem vào Album

- **BR-06 — Giới hạn tem tháng (Free):** Người dùng gói Thường được lưu tối đa ba mươi tem mỗi tháng. Sau khi đạt giới hạn, không lưu thêm được cho đến đầu tháng tiếp theo hoặc nâng cấp Premium.
- **BR-07 — Không giới hạn (Premium):** Người dùng gói Premium lưu tem không giới hạn số lượng mỗi tháng.
- **BR-08 — Ngày tạo tự động:** Khi lưu, hệ thống tự ghi ngày tạo cho tem — không yêu cầu người dùng nhập.
- **BR-09 — Gợi ý hành động sau lưu:** Sau khi lưu thành công, hệ thống hiển thị hai gợi ý: (1) "Gắn lên thư" — dẫn vào luồng soạn thư với tem vừa lưu, (2) "Chia sẻ & nhận 10📮" — xem BR-10.
- **BR-10 — Chia sẻ tem để kiếm Dấu (Share to Unlock):** Khi người dùng nhấn "Chia sẻ & nhận 10📮", hệ thống xuất ảnh tem kèm watermark StampMail nhỏ ở góc rồi mở native share sheet của hệ điều hành. Người dùng tự chọn app để đăng. Dấu được trao ngay khi nhấn nút — không yêu cầu xác nhận đã đăng thật.
- **BR-11 — Watermark bắt buộc trên ảnh chia sẻ:** Mọi ảnh tem xuất ra để chia sẻ đều có watermark StampMail ở góc. Không thể tắt hoặc xóa watermark.
- **BR-12 — Giới hạn chia sẻ tuần:** Tối đa ba lần chia sẻ được thưởng Dấu mỗi tuần (tuần tính từ thứ Hai đến Chủ Nhật). Từ lần thứ tư trở đi, nút vẫn hoạt động (vẫn mở share sheet) nhưng không trao thêm Dấu — hiển thị "Đã đạt giới hạn chia sẻ tuần này".

#### Trạng thái offline

- **BR-13 — Xem trước không cần mạng:** Toàn bộ thao tác xem trước (đổi màu nền, phóng to/thu nhỏ, quay lại các bước chỉnh sửa) vẫn hoạt động bình thường khi mất kết nối, vì dữ liệu tem đang được xử lý cục bộ trên thiết bị.
- **BR-14 — Chặn Lưu tem khi mất mạng:** Khi không có kết nối, nút "Lưu tem" bị vô hiệu hóa và hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." Mọi thao tác xem trước được giữ nguyên để người dùng tiếp tục lưu ngay khi có mạng trở lại.
- **BR-15 — Chặn chia sẻ khi mất kết nối:** Khi mất mạng, nút "Chia sẻ & nhận 10📮" bị vô hiệu hóa và hiển thị thông báo yêu cầu kết nối. Không trao Dấu khi chưa thực hiện được thao tác.

### 4. Tiêu chí nghiệm thu

#### A. Xem trước tem

- **AC-01 — Tem hiển thị đúng kích thước:**
  - **Giả sử** người dùng vừa hoàn tất bước viền;
  - **Khi** chuyển sang màn hình xem trước;
  - **Thì** tem hiển thị ở kích thước thật với đầy đủ: ảnh đã chỉnh, sticker/chữ đã trang trí, và viền đã chọn.

- **AC-02 — Đổi màu nền xem trước:**
  - **Giả sử** người dùng đang xem trước tem;
  - **Khi** chọn một màu nền khác;
  - **Thì** màu nền phía sau tem thay đổi ngay, tem không thay đổi.

- **AC-03 — Quay lại chỉnh bộ lọc:**
  - **Giả sử** người dùng đang ở màn hình xem trước và muốn đổi bộ lọc;
  - **Khi** nhấn "Chỉnh sửa lại" và chọn quay về bước Bộ lọc màu;
  - **Thì** hệ thống quay về bước lọc màu với ảnh và các thay đổi khác vẫn còn.

- **AC-04 — Phóng to kiểm tra chi tiết:**
  - **Giả sử** người dùng đang xem trước tem ở kích thước thật;
  - **Khi** banh ngón tay lên một vùng bất kỳ của tem;
  - **Thì** tem phóng to theo ngón tay; chụm ngón tay thu về kích thước thật; nút "Lưu tem" và "Chỉnh sửa lại" vẫn hiển thị.

#### B. Lưu tem vào Album

- **AC-05 — Lưu tem thành công (Free còn hạn mức):**
  - **Giả sử** người dùng gói Thường còn dưới ba mươi tem trong tháng;
  - **Khi** nhấn "Lưu tem" từ màn hình xem trước;
  - **Thì** tem được lưu vào Album và hiển thị thông báo lưu thành công kèm hai gợi ý hành động tiếp theo.

- **AC-06 — Từ chối lưu khi hết hạn mức Free:**
  - **Giả sử** người dùng gói Thường đã lưu đủ ba mươi tem trong tháng;
  - **Khi** cố lưu thêm tem;
  - **Thì** hệ thống thông báo đã đạt giới hạn tháng, gợi ý nâng cấp Premium hoặc chờ đầu tháng mới.

- **AC-07 — Premium lưu không giới hạn:**
  - **Giả sử** người dùng gói Premium;
  - **Khi** lưu tem bất kỳ lúc nào;
  - **Thì** tem được lưu thành công không bị chặn bởi giới hạn.

- **AC-08 — Gợi ý đính lên thư:**
  - **Giả sử** tem vừa được lưu thành công;
  - **Khi** nhấn vào gợi ý "Gắn lên thư";
  - **Thì** mở luồng soạn thư với tem vừa lưu đã được chọn sẵn.

- **AC-09 — Ngày tạo hiển thị đúng trong Album:**
  - **Giả sử** tem vừa được lưu;
  - **Khi** mở Album và xem chi tiết tem vừa lưu;
  - **Thì** ngày tạo hiển thị đúng là ngày lưu.

- **AC-10 — Chia sẻ tem và nhận Dấu (còn trong giới hạn tuần):**
  - **Giả sử** người dùng vừa lưu tem và chưa chia sẻ đủ 3 lần trong tuần;
  - **Khi** nhấn "Chia sẻ & nhận 10📮";
  - **Thì** native share sheet mở với ảnh tem kèm watermark, và số Dấu tăng 10📮 ngay lập tức.

- **AC-11 — Chia sẻ khi đã đạt giới hạn tuần:**
  - **Giả sử** người dùng đã chia sẻ đủ 3 lần trong tuần này;
  - **Khi** nhấn nút chia sẻ lần thứ 4;
  - **Thì** native share sheet vẫn mở bình thường nhưng không trao Dấu; hiển thị thông báo "Đã đạt giới hạn chia sẻ tuần này".

#### Offline

- **AC-12 — Xem trước tem khi mất mạng:**
  - **Giả sử** người dùng đang ở màn hình xem trước và thiết bị mất kết nối;
  - **Khi** người dùng đổi màu nền, phóng to/thu nhỏ tem, hoặc nhấn "Chỉnh sửa lại";
  - **Thì** các thao tác vẫn thực hiện được bình thường, tem hiển thị không bị ảnh hưởng.

- **AC-13 — Chặn Lưu tem khi mất mạng:**
  - **Giả sử** thiết bị không có kết nối và người dùng đang ở màn hình xem trước;
  - **Khi** nhấn "Lưu tem";
  - **Thì** hệ thống không lưu, hiển thị "Không có kết nối. Vui lòng thử lại khi có mạng." và giữ nguyên tem trên màn hình để người dùng thử lại.

- **AC-14 — Vô hiệu hóa nút chia sẻ khi mất mạng:**
  - **Giả sử** tem vừa được lưu thành công và thiết bị hiện mất kết nối;
  - **Khi** màn hình gợi ý hành động sau lưu hiển thị;
  - **Thì** nút "Chia sẻ & nhận 10📮" bị vô hiệu hóa kèm thông báo yêu cầu kết nối; không có Dấu nào được trao.

### 5. Trường hợp ngoại lệ & lỗi

**Xem trước:**
- Khi mất kết nối (offline): xem trước dùng dữ liệu cục bộ nên vẫn hoạt động đầy đủ; chỉ nút "Lưu tem" bị vô hiệu hóa (xem BR-14).
- Khi chưa đăng nhập: xem trước hiển thị bình thường; khi nhấn "Lưu tem", hệ thống chuyển đến màn hình đăng nhập trước.
- Khi thoát app tại màn hình xem trước: mất toàn bộ nội dung đang làm, lần sau mở lại quay về màn hình chính.

**Lưu vào Album:**
- Khi mất kết nối lúc đang lưu: thông báo lỗi mạng, tem chưa được lưu; nội dung tem được giữ nguyên trên màn hình để thử lại khi có mạng.
- Khi hết dung lượng thiết bị: thông báo lỗi bộ nhớ, hướng dẫn giải phóng dung lượng.
- Khi server trả lỗi: thông báo lỗi chung kèm nút "Thử lại" — tem chưa vào Album, dữ liệu tem vẫn giữ nguyên.
- Khi thoát app trước khi lưu xong: tiến trình lưu bị huỷ, tem không được ghi vào Album; lần sau mở lại phải tạo lại từ đầu.

---

### Liên kết tính năng khác

- SM-009 (Viền & Khung tem): bước trước dẫn vào đây.
- SM-022 (Album sưu tập tem): nơi tem được lưu vào.
- SM-014 (Đính tem lên thư): điểm đến khi chọn gợi ý "Gắn lên thư".
- SM-025 (Chia sẻ tem lên MXH): tính năng chia sẻ đầy đủ (P1) — MVP dùng native share sheet trực tiếp.
- SM-033 (Hệ thống Dấu): quy tắc thưởng và giới hạn tuần cho Share to Unlock.
- SM-030 (Giới hạn tháng & Nhắc hạn mức): quy tắc giới hạn ba mươi tem/tháng.
- SM-006/SM-008/SM-009: các bước có thể quay lại chỉnh từ màn hình xem trước.

---

## Thiết kế màn hình

> **Quy tắc:** ✅ Vẽ riêng · 📝 Annotation trên frame gốc · ♻️ Dùng lại layout từ flow khác

### Tổng quan trạng thái trong spec

| Màn hình | Trạng thái |
|---|---|
| Nguồn ảnh | Default · No-camera · Permission-denied |
| Xem ảnh | Default · Zoomed · Too-large |
| Bộ lọc màu | Default · Filter-applied · Manual-adjusted · Premium-locked · Offline |
| Trang trí | Default · Element-selected · Locked-sticker-sheet · Sticker-error |
| Viền & Khung | Default · Border-selected · Locked-border-sheet · Offline |
| Xem trước tem | Default · Bg-changed |
| Lưu tem | Success · Quota-reached · Share-limit · Offline |

**Tổng: ~22 trạng thái / 7 loại màn hình**

### Frame cần thiết kế (13 frame)

| # | Frame | Ghi chú |
|---|---|---|
| 1 | Nguồn ảnh — Default | Camera view + gallery strip + 2 tab |
| 2 | Nguồn ảnh — No-camera | Gallery only, không có camera view |
| 3 | Xem ảnh | Zoomed → 📝 annotation; Too-large → 📝 toast alert |
| 4 | Bộ lọc màu — Default | 8 free + 8 locked filters + 3 sliders |
| 5 | Bộ lọc — Premium bottom sheet | Upsell khi chạm filter bị khóa |
| 6 | Trang trí — Default | Canvas + sticker panel mở sẵn |
| 7 | Trang trí — Element-selected | Handle xoay / resize / xóa xuất hiện |
| 8 | Trang trí — Locked sticker sheet | Bottom sheet: 50📮 hoặc Premium |
| 9 | Viền & Khung — Default | 3 free + 4 locked + color picker |
| 10 | Viền — Locked border sheet | Bottom sheet: 80📮 hoặc Premium |
| 11 | Xem trước tem | Bg-changed → 📝 annotation; Offline → 📝 banner |
| 12 | Lưu tem — Success | 2 CTA: "Gắn lên thư" + "Chia sẻ & nhận 10📮" |
| 13 | Lưu tem — Quota reached | Modal/toast: đã đạt 30 tem/tháng |

**Bỏ qua / annotation:** Permission-denied (OS dialog, không vẽ); Zoomed / Too-large (📝 annotation trên frame 3); Filter-applied / Manual-adjusted / Offline (📝 annotation); Sticker-error (📝 alert overlay); Border-selected (📝 annotation); Share-limit / Offline-save (📝 annotation).

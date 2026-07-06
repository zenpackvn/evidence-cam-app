# Album sưu tập tem (SM-022)

**Feature Branch**: `020-album-suu-tap`
**Ngày tạo**: 2026-06-24
**Trạng thái**: Draft
**Ưu tiên**: 🔴 P0

> **Tài liệu thuần nghiệp vụ** cho Tester (QA), Business Analyst (BA), Product Owner (PO).
> **KHÔNG chứa chi tiết kỹ thuật**. Phần plan / vẽ giao diện / develop được làm RIÊNG ở bước sau.

---

## 1. Mục đích nghiệp vụ

Là "ngăn kéo tem" cá nhân của người dùng — nơi lưu giữ toàn bộ tem đã tạo và tem đã nhận. Album vừa là bộ nhớ cảm xúc (tem gắn với ký ức) vừa là kho nguyên liệu để đính lên thư mới. Đây là hook giữ chân chính: người dùng quay lại để xem lại, tổ chức và dùng tem của mình.

## 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đã đăng nhập.
- **Khi nào dùng:** Khi muốn xem lại bộ sưu tập tem, tìm tem để dùng, hay kiểm tra tiến độ series.
- **Điều kiện tiên quyết:** Đã đăng nhập (SM-001).
- **Phạm vi:** Xem, lọc và tìm tem trong Album; xem chi tiết từng tem; chia sẻ và đính tem lên thư từ Album; tạo và quản lý album tùy chỉnh; chỉnh sửa tem trong Album (xóa tem, chọn nhiều, di chuyển giữa album). Không bao gồm tạo tem mới (SM-005→011).

## 3. Quy tắc nghiệp vụ

- **BR-01 — Nguồn tem trong Album:** Album chứa hai loại tem: (1) tem người dùng tự tạo (từ SM-011), (2) tem người dùng nhận được từ thư của người khác (từ SM-017 sau khi đăng nhập).
- **BR-02 — Chế độ xem:** Người dùng chuyển giữa hai chế độ hiển thị: lưới (nhiều tem, xem tổng thể) và danh sách (ít tem hơn, thấy thêm thông tin).
- **BR-03 — Bộ lọc và danh sách album:** Album được tổ chức thành hai nhóm:
  - **Album mặc định** (hệ thống tự tạo, không thể xóa hay đổi tên): Tất cả / Tự tạo / Nhận được.
  - **Album tùy chỉnh** (người dùng tự tạo): hiển thị ngay dưới album mặc định, có thể đổi tên và xóa.
- **BR-04 — Chi tiết tem:** Nhấn vào một tem → xem ảnh tem kích thước lớn, ngày tạo/nhận, tên người gửi (nếu là tem nhận), series (nếu thuộc series nào).
- **BR-05 — Hành động từ chi tiết tem:** Từ màn hình chi tiết tem, người dùng có thể: (1) chia sẻ tem lên MXH (SM-025), (2) đính tem lên thư mới (dẫn vào soạn thư SM-012 với tem đã chọn sẵn), (3) thêm tem vào album tùy chỉnh.
- **BR-06 — Tạo album tùy chỉnh:** Người dùng tạo album tùy chỉnh với tên tự đặt, tối đa ba mươi ký tự. Không giới hạn số lượng album tùy chỉnh.
- **BR-07 — Thêm tem vào album tùy chỉnh:** Người dùng thêm tem vào album tùy chỉnh từ màn hình chi tiết tem hoặc bằng cách chọn nhiều tem cùng lúc. Một tem có thể thuộc nhiều album tùy chỉnh cùng lúc — thêm vào album không xóa khỏi album khác.
- **BR-08 — Xóa album tùy chỉnh:** Xóa một album tùy chỉnh không xóa các tem bên trong — tem vẫn còn trong "Tất cả" và các album tùy chỉnh khác mà tem đó thuộc về.
- **BR-09 — Đổi tên album tùy chỉnh:** Người dùng đổi tên album tùy chỉnh bất kỳ lúc nào; tên mới áp dụng ngay.
- **BR-10 — Album mặc định không thể chỉnh:** Ba album mặc định (Tất cả / Tự tạo / Nhận được) không thể đổi tên hay xóa.

### Bên trong một album

- **BR-13 — Màn hình trong album:** Nhấn vào bất kỳ album nào (mặc định hoặc tùy chỉnh) → mở màn hình riêng chỉ hiển thị các tem thuộc album đó. Màn hình này có tên album ở tiêu đề, số lượng tem, và hai nút hành động chính: **Thêm tem** và **Chỉnh sửa**.
- **BR-14 — Thêm tem vào album từ bên trong album:** Nhấn "Thêm tem" khi đang ở trong một album tùy chỉnh → mở màn hình chọn tem từ "Tất cả". Người dùng chọn một hoặc nhiều tem rồi nhấn Xác nhận → các tem đó xuất hiện ngay trong album. Tem đã có trong album được đánh dấu để tránh thêm trùng.
- **BR-15 — Chế độ chỉnh sửa trong album:** Nhấn "Chỉnh sửa" khi đang ở trong album → bật chế độ chỉnh sửa: mỗi tem hiển thị ô chọn, thanh hành động xuất hiện bên dưới. Người dùng chạm tem để chọn hoặc bỏ chọn. Nhấn "Xong" để thoát chế độ chỉnh sửa.
- **BR-16 — Xóa tem khỏi album tùy chỉnh (trong chế độ chỉnh sửa):** Trong chế độ chỉnh sửa của album tùy chỉnh, chọn một hoặc nhiều tem rồi nhấn "Xóa khỏi album" → các tem bị gỡ khỏi album này. Tem vẫn còn trong "Tất cả" và mọi album tùy chỉnh khác mà nó thuộc về. Không cần xác nhận vì không xóa vĩnh viễn.
- **BR-17 — Xóa tem vĩnh viễn (trong chế độ chỉnh sửa):** Trong chế độ chỉnh sửa, chọn tem tự tạo rồi nhấn "Xóa vĩnh viễn" → hệ thống hiển thị thông báo xác nhận. Chỉ sau khi người dùng xác nhận, tem mới bị xóa khỏi "Tất cả" và mọi album — không thể hoàn tác. Tem nhận từ người khác không có tuỳ chọn này.
- **BR-18 — Đổi tên tem từ chi tiết tem:** Nhấn vào một tem trong album → màn hình chi tiết tem → nhấn vào tên tem để đổi tên (tối đa ba mươi ký tự). Tên mặc định khi tạo là ngày tạo tem.
- **BR-19 — Di chuyển tem sang album tùy chỉnh khác:** Trong chế độ chỉnh sửa của album tùy chỉnh, chọn tem rồi nhấn "Di chuyển sang" → chọn album đích → tem xuất hiện trong album đích và biến mất khỏi album nguồn; tem vẫn còn trong "Tất cả".
- **BR-20 — Album mặc định không có nút Thêm tem:** Ba album mặc định (Tất cả / Tự tạo / Nhận được) không có nút "Thêm tem" vì nội dung do hệ thống tự quản lý. Nút "Chỉnh sửa" chỉ cho phép xóa vĩnh viễn tem tự tạo từ "Tất cả" và "Tự tạo".

### Trạng thái offline

- **BR-11 — Xem album khi mất mạng:** Khi không có kết nối, người dùng vẫn thấy danh sách tem và album đã từng được tải trước đó; ứng dụng hiển thị thông báo "Đang xem ngoại tuyến" ở vị trí dễ thấy.
- **BR-12 — Hành động cần mạng bị vô hiệu khi offline:** Các thao tác cần kết nối — thêm tem vào album tùy chỉnh, tạo album mới, đổi tên album, xóa album — bị vô hiệu hóa khi mất mạng; nút hoặc tùy chọn tương ứng không phản hồi và hiển thị thông báo yêu cầu kết nối lại.

## 4. Tiêu chí nghiệm thu

- **AC-01 — Album hiển thị đủ tem tự tạo và tem nhận:**
  - **Giả sử** người dùng có cả tem tự tạo lẫn tem nhận từ thư;
  - **Khi** mở Album ở chế độ "Tất cả";
  - **Thì** thấy cả hai loại tem trong cùng một danh sách.

- **AC-02 — Lọc chỉ tem nhận:**
  - **Giả sử** Album có cả tem tự tạo lẫn tem nhận;
  - **Khi** chọn bộ lọc "Tem nhận được";
  - **Thì** chỉ hiển thị tem từ thư của người khác.

- **AC-04 — Xem chi tiết và đính lên thư mới:**
  - **Giả sử** người dùng đang xem chi tiết một tem;
  - **Khi** nhấn "Đính lên thư mới";
  - **Thì** mở luồng soạn thư (SM-012) với tem đó đã được chọn sẵn ở bước đính tem.

- **AC-05 — Album rỗng khi chưa có tem:**
  - **Giả sử** người dùng mới đăng ký, chưa tạo hoặc nhận tem nào;
  - **Khi** mở Album;
  - **Thì** thấy trạng thái rỗng với gợi ý tạo tem đầu tiên.

- **AC-06 — Tạo album tùy chỉnh:**
  - **Giả sử** người dùng đang ở màn hình Album;
  - **Khi** chọn "Tạo album mới", nhập tên và xác nhận;
  - **Thì** album tùy chỉnh mới xuất hiện trong danh sách bên dưới album mặc định, ban đầu rỗng.

- **AC-07 — Thêm tem vào album tùy chỉnh:**
  - **Giả sử** người dùng đang xem chi tiết một tem và đã có ít nhất một album tùy chỉnh;
  - **Khi** chọn "Thêm vào album" và chọn album tùy chỉnh;
  - **Thì** tem xuất hiện trong album đó; tem vẫn còn ở "Tất cả" và các album khác.

- **AC-08 — Xóa album tùy chỉnh không xóa tem:**
  - **Giả sử** người dùng có album tùy chỉnh "Yêu thích" chứa ba tem;
  - **Khi** xóa album "Yêu thích";
  - **Thì** album biến mất; ba tem đó vẫn còn trong "Tất cả" và không bị mất.

- **AC-09 — Không thể xóa album mặc định:**
  - **Giả sử** người dùng đang ở danh sách album;
  - **Khi** nhấn giữ hoặc vào tùy chọn của album "Tự tạo";
  - **Thì** không có tùy chọn xóa hay đổi tên — chỉ thấy tùy chọn xem.

- **AC-12 — Bấm vào album → thấy danh sách tem của album đó:**
  - **Giả sử** người dùng đang ở màn hình danh sách album và album tùy chỉnh "Kỷ niệm" có năm tem;
  - **Khi** nhấn vào album "Kỷ niệm";
  - **Thì** mở màn hình riêng hiển thị đúng năm tem của album đó; tiêu đề hiện tên "Kỷ niệm"; có nút "Thêm tem" và nút "Chỉnh sửa".

- **AC-13 — Thêm tem vào album từ bên trong album:**
  - **Giả sử** người dùng đang ở trong album tùy chỉnh "Kỷ niệm";
  - **Khi** nhấn "Thêm tem", chọn hai tem từ danh sách "Tất cả" rồi nhấn Xác nhận;
  - **Thì** hai tem đó xuất hiện ngay trong album "Kỷ niệm"; tem đã có sẵn trong album được đánh dấu và không thêm trùng.

- **AC-14 — Vào chế độ chỉnh sửa trong album:**
  - **Giả sử** người dùng đang ở trong album tùy chỉnh;
  - **Khi** nhấn "Chỉnh sửa";
  - **Thì** mỗi tem hiển thị ô chọn; thanh hành động xuất hiện bên dưới với "Xóa khỏi album", "Xóa vĩnh viễn", "Di chuyển sang"; nhấn "Xong" để thoát chế độ này.

- **AC-15 — Xóa tem khỏi album tùy chỉnh (không mất tem):**
  - **Giả sử** người dùng đang ở chế độ chỉnh sửa trong album "Kỷ niệm" và đã chọn hai tem;
  - **Khi** nhấn "Xóa khỏi album";
  - **Thì** hai tem biến mất khỏi "Kỷ niệm" ngay lập tức, không cần xác nhận; hai tem đó vẫn còn trong "Tất cả" và các album tùy chỉnh khác.

- **AC-16 — Xóa tem vĩnh viễn (bắt buộc xác nhận):**
  - **Giả sử** người dùng đang ở chế độ chỉnh sửa và đã chọn một tem tự tạo;
  - **Khi** nhấn "Xóa vĩnh viễn";
  - **Thì** hệ thống hiển thị thông báo xác nhận; chỉ sau khi nhấn Xác nhận, tem mới bị xóa khỏi "Tất cả" và mọi album tùy chỉnh — không thể hoàn tác.

- **AC-17 — Tem nhận không có tùy chọn xóa vĩnh viễn:**
  - **Giả sử** người dùng đang ở chế độ chỉnh sửa và chọn một tem nhận từ người khác;
  - **Khi** xem thanh hành động;
  - **Thì** tùy chọn "Xóa vĩnh viễn" không xuất hiện; chỉ có "Xóa khỏi album" (nếu đang trong album tùy chỉnh) và "Di chuyển sang".

- **AC-18 — Di chuyển tem sang album tùy chỉnh khác:**
  - **Giả sử** người dùng đang ở chế độ chỉnh sửa trong album "Mùa hè" và đã chọn một tem;
  - **Khi** nhấn "Di chuyển sang" và chọn album "Kỷ niệm";
  - **Thì** tem xuất hiện trong "Kỷ niệm" và biến mất khỏi "Mùa hè"; tem vẫn còn trong "Tất cả".

- **AC-19 — Đổi tên tem từ màn hình chi tiết:**
  - **Giả sử** người dùng nhấn vào một tem trong album → vào màn hình chi tiết;
  - **Khi** nhấn vào tên tem và nhập tên mới rồi xác nhận;
  - **Thì** tên tem cập nhật ngay trên chi tiết và trong danh sách album.

- **AC-20 — Album mặc định không có nút Thêm tem:**
  - **Giả sử** người dùng nhấn vào album mặc định "Tự tạo";
  - **Khi** xem màn hình trong album;
  - **Thì** không có nút "Thêm tem"; chỉ có nút "Chỉnh sửa" (cho phép xóa vĩnh viễn tem tự tạo, không có Xóa khỏi album hay Di chuyển sang).

### Offline

- **AC-10 — Xem tem đã tải trước khi mất mạng:**
  - **Giả sử** người dùng đã từng mở Album và tải danh sách tem; sau đó mất kết nối mạng;
  - **Khi** mở Album hoặc vào một album tùy chỉnh;
  - **Thì** các tem đã tải trước đó vẫn hiển thị đầy đủ và có thông báo "Đang xem ngoại tuyến" xuất hiện trên màn hình.

- **AC-11 — Hành động ghi bị chặn khi offline:**
  - **Giả sử** người dùng đang xem chi tiết một tem trong trạng thái mất mạng;
  - **Khi** nhấn "Thêm vào album" hoặc "Tạo album mới";
  - **Thì** hành động không thực hiện được và xuất hiện thông báo yêu cầu kết nối lại mạng.

## 5. Trường hợp ngoại lệ & lỗi

**Khi mất kết nối (offline):**
- Danh sách tem và album đã tải trước đó vẫn hiển thị đầy đủ; ứng dụng hiển thị thông báo "Đang xem ngoại tuyến" ở vị trí dễ thấy.
- Các thao tác ghi (tạo album mới, đổi tên album, xóa album, thêm tem vào album tùy chỉnh) bị vô hiệu hoá; nhấn vào các nút đó thì xuất hiện thông báo yêu cầu kết nối lại mạng.
- Tem chưa từng tải về không hiển thị; vị trí đó để trống hoặc hiển thị ký hiệu chưa tải được.
- Khi Album có rất nhiều tem (hàng trăm): hệ thống tải từng trang để tránh chậm máy.

**Khi dữ liệu không tải được (lỗi mạng / lỗi máy chủ):**
- Màn hình Album hiển thị trạng thái lỗi với thông báo ngắn gọn và nút "Thử lại" để người dùng tải lại danh sách.
- Nếu một số tem tải được và một số không, phần đã tải hiển thị bình thường; phần lỗi hiển thị ký hiệu lỗi thay vì ảnh tem.
- Nhấn "Thử lại" tải lại toàn bộ danh sách mà không mất bộ lọc hay vị trí đang xem.

**Khi chưa đăng nhập / thoát app giữa chừng:**
- Người dùng chưa đăng nhập truy cập vào Album thì được chuyển ngay về màn hình đăng nhập; không xem được Album ở chế độ khách.
- Thoát app giữa chừng khi đang xem hoặc tổ chức Album không làm mất dữ liệu — lần sau mở lại, Album hiển thị đúng trạng thái đã lưu (album tùy chỉnh, tên album vẫn còn nguyên).

---

## Liên kết tính năng khác

- SM-011 (Lưu tem): nguồn tem tự tạo vào Album.
- SM-017 (Nhận thư qua Link): nguồn tem nhận được vào Album.
- SM-014 (Đính tem): khi chọn "Đính lên thư mới" từ Album.
- SM-025 (Chia sẻ tem lên MXH): khi chọn chia sẻ từ chi tiết tem.

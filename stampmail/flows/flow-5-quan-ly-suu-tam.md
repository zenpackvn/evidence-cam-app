# Flow 5 · Quản lý & Sưu tầm

Theo dõi thư và bộ sưu tập tem.

---

## Hộp thư đã gửi & Theo dõi trạng thái (SM-021)

> Nguồn: `specs/019-hop-thu-da-gui.md`

**Màn hình & trạng thái:**

- **Đã gửi**: List-default · List-empty · List-offline · Detail-active-read · Detail-expired

### 1. Mục đích nghiệp vụ

Cho người gửi theo dõi số phận của từng thư đã gửi — link đang hoạt động, đã được đọc, hay đã hết hạn. Tạo cảm giác "đang chờ thư được mở" và cho phép tạo lại link khi cần.

### 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đã gửi ít nhất một thư.
- **Khi nào dùng:** Khi muốn xem lại danh sách thư đã gửi và trạng thái từng link.
- **Điều kiện tiên quyết:** Đã đăng nhập (SM-001). Đã gửi ít nhất một thư (SM-016).
- **Phạm vi:** Danh sách thư đã gửi, trạng thái link, tạo link mới cho thư hết hạn. Không bao gồm hộp thư đến (SM-018).

### 3. Quy tắc nghiệp vụ

- **BR-01 — Danh sách thư đã gửi:** Hiển thị tất cả thư đã gửi, mới nhất lên trước.
- **BR-02 — Trạng thái link:** Với mỗi thư, hiển thị trạng thái của từng link đã tạo: (1) Đang hoạt động — link còn hiệu lực chưa ai mở, (2) Đã đọc — người nhận đã mở link kèm thời điểm mở, (3) Hết hạn — link quá bảy ngày chưa ai mở.
- **BR-03 — Số người nhận:** Mỗi thư hiển thị tổng số link đã tạo (= số người gửi đến).
- **BR-04 — Tạo link mới cho thư hết hạn:** Với link đã hết hạn, người gửi có thể tạo link mới để gửi lại. Mỗi lần tạo link mới trừ một vào hạn mức tháng (áp dụng cho gói Thường).
- **BR-05 — Không tạo link mới cho thư đã đọc:** Thư mà link đã được mở (đã đọc) không cho tạo link mới — thư đã đến tay người nhận rồi.

#### Trạng thái offline

- **BR-06 — Xem danh sách khi mất mạng:** Khi mất kết nối, người dùng vẫn thấy danh sách thư đã gửi và trạng thái link từ lần tải gần nhất; ứng dụng hiển thị thông báo "Đang xem ngoại tuyến — dữ liệu có thể chưa cập nhật".
- **BR-07 — Vô hiệu hóa tạo link mới khi mất mạng:** Khi mất kết nối, nút "Tạo link mới" bị vô hiệu hóa; nếu người dùng cố nhấn, hệ thống thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."
- **BR-08 — Tự động cập nhật khi có mạng trở lại:** Khi kết nối được khôi phục, danh sách và trạng thái link tự động làm mới để phản ánh dữ liệu mới nhất.

### 4. Tiêu chí nghiệm thu

- **AC-01 — Danh sách thư đã gửi đúng thứ tự:**
  - **Giả sử** người dùng đã gửi nhiều thư vào các thời điểm khác nhau;
  - **Khi** mở hộp thư đã gửi;
  - **Thì** thư mới nhất xuất hiện đầu danh sách.

- **AC-02 — Trạng thái từng link hiển thị đúng:**
  - **Giả sử** một thư có ba link: một đã đọc, một đang hoạt động, một hết hạn;
  - **Khi** mở chi tiết thư đó;
  - **Thì** ba link hiển thị ba trạng thái khác nhau: Đã đọc (kèm thời điểm), Đang hoạt động, Hết hạn.

- **AC-03 — Tạo link mới cho link hết hạn:**
  - **Giả sử** người dùng gói Thường có link hết hạn và còn hạn mức thư trong tháng;
  - **Khi** nhấn "Tạo link mới" cho link hết hạn đó;
  - **Thì** link mới được tạo, hạn mức tháng trừ đi một.

- **AC-04 — Không cho tạo link mới cho thư đã đọc:**
  - **Giả sử** link thư đã được người nhận mở;
  - **Khi** người gửi cố tạo link mới cho thư đó;
  - **Thì** hệ thống không cho và thông báo thư đã được nhận.

#### Offline

- **AC-05 — Xem danh sách thư khi mất mạng:**
  - **Giả sử** người dùng đã từng tải danh sách thư đã gửi và sau đó mất kết nối mạng;
  - **Khi** mở hộp thư đã gửi trong trạng thái ngoại tuyến;
  - **Thì** danh sách thư và trạng thái link từ lần tải gần nhất vẫn hiển thị, kèm thông báo "Đang xem ngoại tuyến — dữ liệu có thể chưa cập nhật".

- **AC-06 — Không tạo được link mới khi mất mạng:**
  - **Giả sử** người dùng đang xem thư có link hết hạn nhưng thiết bị đang mất kết nối;
  - **Khi** người dùng nhấn "Tạo link mới";
  - **Thì** hành động bị chặn và hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."

### 5. Trường hợp ngoại lệ & lỗi

- Khi không có thư đã gửi: hiển thị trạng thái rỗng với gợi ý tạo thư đầu tiên.
- Khi hết hạn mức tháng và cố tạo link mới: hệ thống thông báo hết hạn mức, gợi ý nâng cấp Premium.
- Khi mất kết nối: danh sách thư và trạng thái link từ lần tải gần nhất vẫn hiển thị kèm thông báo "Đang xem ngoại tuyến — dữ liệu có thể chưa cập nhật"; nút "Tạo link mới" bị vô hiệu hoá cho đến khi có mạng trở lại.
- Khi dữ liệu không tải được (lỗi mạng hoặc máy chủ): màn hình hiển thị thông báo lỗi kèm nút "Thử lại" để người dùng tải lại danh sách.
- Khi chưa đăng nhập: hệ thống tự động chuyển về màn hình đăng nhập, không cho phép xem hộp thư đã gửi dưới bất kỳ hình thức nào.
- Khi thoát app giữa chừng: dữ liệu danh sách đã tải được giữ trong bộ nhớ đệm; lần sau mở lại, người dùng thấy ngay danh sách từ cache mà không cần chờ tải lại từ đầu.

---

### Liên kết tính năng khác

- SM-016 (Gửi thư qua MXH): nơi tạo link thư và gửi.
- SM-030 (Giới hạn tháng): áp dụng khi tạo link mới trừ vào hạn mức.
- SM-026 (Thông báo push): thông báo khi link được mở dẫn đến cập nhật trạng thái trong danh sách này.

---

## Album sưu tập tem (SM-022)

> Nguồn: `specs/020-album-suu-tap.md`

**Màn hình & trạng thái:**

- **Album**: Grid · List-view · Empty · Offline
- **Chi tiết tem**: Detail-own · Detail-received
- **Trong Album con**: Custom · Edit-mode
- **Thêm tem**: Picker

### 1. Mục đích nghiệp vụ

Là "ngăn kéo tem" cá nhân của người dùng — nơi lưu giữ toàn bộ tem đã tạo và tem đã nhận. Album vừa là bộ nhớ cảm xúc (tem gắn với ký ức) vừa là kho nguyên liệu để đính lên thư mới. Đây là hook giữ chân chính: người dùng quay lại để xem lại, tổ chức và dùng tem của mình.

### 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đã đăng nhập.
- **Khi nào dùng:** Khi muốn xem lại bộ sưu tập tem, tìm tem để dùng, hay kiểm tra tiến độ series.
- **Điều kiện tiên quyết:** Đã đăng nhập (SM-001).
- **Phạm vi:** Xem, lọc và tìm tem trong Album; xem chi tiết từng tem; chia sẻ và đính tem lên thư từ Album; tạo và quản lý album tùy chỉnh; chỉnh sửa tem trong Album (xóa tem, chọn nhiều, di chuyển giữa album). Không bao gồm tạo tem mới (SM-005→011).

### 3. Quy tắc nghiệp vụ

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

#### Bên trong một album

- **BR-13 — Màn hình trong album:** Nhấn vào bất kỳ album nào (mặc định hoặc tùy chỉnh) → mở màn hình riêng chỉ hiển thị các tem thuộc album đó. Màn hình này có tên album ở tiêu đề, số lượng tem, và hai nút hành động chính: **Thêm tem** và **Chỉnh sửa**.
- **BR-14 — Thêm tem vào album từ bên trong album:** Nhấn "Thêm tem" khi đang ở trong một album tùy chỉnh → mở màn hình chọn tem từ "Tất cả". Người dùng chọn một hoặc nhiều tem rồi nhấn Xác nhận → các tem đó xuất hiện ngay trong album. Tem đã có trong album được đánh dấu để tránh thêm trùng.
- **BR-15 — Chế độ chỉnh sửa trong album:** Nhấn "Chỉnh sửa" khi đang ở trong album → bật chế độ chỉnh sửa: mỗi tem hiển thị ô chọn, thanh hành động xuất hiện bên dưới. Người dùng chạm tem để chọn hoặc bỏ chọn. Nhấn "Xong" để thoát chế độ chỉnh sửa.
- **BR-16 — Xóa tem khỏi album tùy chỉnh (trong chế độ chỉnh sửa):** Trong chế độ chỉnh sửa của album tùy chỉnh, chọn một hoặc nhiều tem rồi nhấn "Xóa khỏi album" → các tem bị gỡ khỏi album này. Tem vẫn còn trong "Tất cả" và mọi album tùy chỉnh khác mà nó thuộc về. Không cần xác nhận vì không xóa vĩnh viễn.
- **BR-17 — Xóa tem vĩnh viễn (trong chế độ chỉnh sửa):** Trong chế độ chỉnh sửa, chọn tem tự tạo rồi nhấn "Xóa vĩnh viễn" → hệ thống hiển thị thông báo xác nhận. Chỉ sau khi người dùng xác nhận, tem mới bị xóa khỏi "Tất cả" và mọi album — không thể hoàn tác. Tem nhận từ người khác không có tuỳ chọn này.
- **BR-18 — Đổi tên tem từ chi tiết tem:** Nhấn vào một tem trong album → màn hình chi tiết tem → nhấn vào tên tem để đổi tên (tối đa ba mươi ký tự). Tên mặc định khi tạo là ngày tạo tem.
- **BR-19 — Di chuyển tem sang album tùy chỉnh khác:** Trong chế độ chỉnh sửa của album tùy chỉnh, chọn tem rồi nhấn "Di chuyển sang" → chọn album đích → tem xuất hiện trong album đích và biến mất khỏi album nguồn; tem vẫn còn trong "Tất cả".
- **BR-20 — Album mặc định không có nút Thêm tem:** Ba album mặc định (Tất cả / Tự tạo / Nhận được) không có nút "Thêm tem" vì nội dung do hệ thống tự quản lý. Nút "Chỉnh sửa" chỉ cho phép xóa vĩnh viễn tem tự tạo từ "Tất cả" và "Tự tạo".

#### Trạng thái offline

- **BR-11 — Xem album khi mất mạng:** Khi không có kết nối, người dùng vẫn thấy danh sách tem và album đã từng được tải trước đó; ứng dụng hiển thị thông báo "Đang xem ngoại tuyến" ở vị trí dễ thấy.
- **BR-12 — Hành động cần mạng bị vô hiệu khi offline:** Các thao tác cần kết nối — thêm tem vào album tùy chỉnh, tạo album mới, đổi tên album, xóa album — bị vô hiệu hóa khi mất mạng; nút hoặc tùy chọn tương ứng không phản hồi và hiển thị thông báo yêu cầu kết nối lại.

### 4. Tiêu chí nghiệm thu

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

#### Offline

- **AC-10 — Xem tem đã tải trước khi mất mạng:**
  - **Giả sử** người dùng đã từng mở Album và tải danh sách tem; sau đó mất kết nối mạng;
  - **Khi** mở Album hoặc vào một album tùy chỉnh;
  - **Thì** các tem đã tải trước đó vẫn hiển thị đầy đủ và có thông báo "Đang xem ngoại tuyến" xuất hiện trên màn hình.

- **AC-11 — Hành động ghi bị chặn khi offline:**
  - **Giả sử** người dùng đang xem chi tiết một tem trong trạng thái mất mạng;
  - **Khi** nhấn "Thêm vào album" hoặc "Tạo album mới";
  - **Thì** hành động không thực hiện được và xuất hiện thông báo yêu cầu kết nối lại mạng.

### 5. Trường hợp ngoại lệ & lỗi

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

### Liên kết tính năng khác

- SM-011 (Lưu tem): nguồn tem tự tạo vào Album.
- SM-017 (Nhận thư qua Link): nguồn tem nhận được vào Album.
- SM-014 (Đính tem): khi chọn "Đính lên thư mới" từ Album.
- SM-025 (Chia sẻ tem lên MXH): khi chọn chia sẻ từ chi tiết tem.

---

## Bộ tem mẫu (SM-035)

> Nguồn: `specs/029-bo-tem-mau.md`

**Màn hình & trạng thái:**

- **Tem mẫu**: Browse-default · Coming-soon · Detail-free · Detail-locked · Detail-saved · Insufficient

### 1. Mục đích nghiệp vụ

Cung cấp bộ sưu tập tem được thiết kế sẵn bởi StampMail — để người dùng tham khảo phong cách hoặc dùng ngay mà không cần tạo từ ảnh cá nhân. Hạ thấp rào cản gửi thư lần đầu (người mới không cần ảnh đẹp để bắt đầu); đồng thời tạo động lực chia sẻ app hoặc nạp Dấu để mở khóa các tem mẫu cao cấp hơn.

### 2. Đối tượng & phạm vi

- **Người dùng:** Mọi người dùng đã đăng nhập, bao gồm cả người mới chưa tạo tem lần nào.
- **Khi nào dùng:** Khi muốn tham khảo tem trước khi tạo, hoặc khi muốn dùng ngay một tem có sẵn để gửi thư mà không cần tự tạo.
- **Điều kiện tiên quyết:** Đã đăng nhập (SM-001).
- **Phạm vi:** Duyệt, xem chi tiết và lưu tem mẫu vào Album cá nhân. Không bao gồm chỉnh sửa tem mẫu hay tạo tem mới từ tem mẫu (đó là luồng SM-005→011).

### 3. Quy tắc nghiệp vụ

- **BR-01 — Nguồn tem mẫu:** Bộ tem mẫu do đội thiết kế StampMail biên soạn — không phải tem do người dùng tạo. Bộ tem mẫu là một album riêng, tách biệt hoàn toàn với Album cá nhân (SM-022). Tem mẫu luôn gắn nhãn "Tem mẫu" để phân biệt.
- **BR-02 — Phân loại theo chủ đề:** Trong album tem mẫu, tem được chia theo các chủ đề, ví dụ: Sinh nhật / Tết & Lễ hội / Tình yêu & Kỷ niệm / Bạn bè / Thiên nhiên & Phong cảnh / Động vật / Nghệ thuật & Họa tiết. Danh sách chủ đề có thể mở rộng theo thời gian.
- **BR-03 — Lưu tem mẫu vào Album cá nhân:** Sau khi mở khóa, người dùng lưu tem mẫu vào Album cá nhân để dùng khi gửi thư (SM-014). Mỗi tem mẫu chỉ cần lưu một lần — lưu lại không tạo bản sao.
- **BR-04 — Tem mẫu không thể chỉnh sửa:** Người dùng không thể thay đổi thiết kế của tem mẫu. Nếu muốn phong cách tương tự nhưng ảnh riêng, người dùng đi qua luồng tạo tem (SM-005→011).
- **BR-05 — Miễn phí một phần, phần còn lại cần Dấu:** Một số tem mẫu miễn phí cho tất cả người dùng (hiển thị ngay, lưu được không cần Dấu). Các tem mẫu còn lại bị khóa — mở bằng **Dấu** (SM-033): kiếm Dấu bằng cách chia sẻ tem/gửi thư, hoặc nạp Dấu bằng tiền thật. Giá mở khóa từng tem mẫu hiển thị rõ trên ảnh.
- **BR-06 — Cập nhật định kỳ:** StampMail bổ sung bộ tem mẫu mới theo mùa/dịp (Tết, Valentine, Giáng sinh, v.v.). Tem mới gắn nhãn "Mới" trong một khoảng thời gian sau khi ra mắt.
- **BR-07 — Xem trước trước khi mở khóa:** Người dùng xem tem mẫu ở kích thước lớn và phóng to kiểm tra chi tiết trước khi quyết định dùng Dấu mở khóa.

#### Trạng thái offline

- **BR-08 — Xem tem đã tải khi mất mạng:** Khi mất kết nối, người dùng vẫn thấy và duyệt được các tem mẫu đã được hiển thị trước đó; ứng dụng hiển thị thông báo "Đang xem ngoại tuyến" ở đầu màn hình để người dùng biết nội dung có thể chưa được cập nhật mới nhất.
- **BR-09 — Chặn lưu và mở khóa khi mất mạng:** Khi mất kết nối, nút "Lưu vào Album" và nút "Mở khóa" bị vô hiệu hóa; khi người dùng nhấn vào, hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." — không trừ Dấu, không ghi dữ liệu.

### 4. Tiêu chí nghiệm thu

- **AC-01 — Duyệt tem mẫu theo chủ đề:**
  - **Giả sử** người dùng đang ở màn hình Bộ tem mẫu;
  - **Khi** chọn chủ đề "Sinh nhật";
  - **Thì** chỉ hiển thị các tem mẫu thuộc chủ đề Sinh nhật; tem của chủ đề khác bị ẩn.

- **AC-02 — Xem trước chi tiết tem mẫu:**
  - **Giả sử** người dùng đang duyệt danh sách tem mẫu;
  - **Khi** nhấn vào một tem mẫu;
  - **Thì** tem hiển thị ở kích thước lớn với nhãn "Tem mẫu", tên chủ đề, và nút "Lưu vào Album" (hoặc thông tin mở khóa nếu là Premium).

- **AC-03 — Phóng to kiểm tra chi tiết:**
  - **Giả sử** người dùng đang xem trước một tem mẫu;
  - **Khi** banh ngón tay lên tem;
  - **Thì** tem phóng to theo ngón tay để xem chi tiết; chụm ngón tay thu về kích thước ban đầu.

- **AC-04 — Lưu tem mẫu miễn phí vào Album:**
  - **Giả sử** người dùng đang xem tem mẫu miễn phí;
  - **Khi** nhấn "Lưu vào Album";
  - **Thì** tem xuất hiện trong Album cá nhân (SM-022) với nhãn "Tem mẫu"; hiển thị thông báo xác nhận "Đã lưu vào Album".

- **AC-05 — Lưu lại không tạo bản sao:**
  - **Giả sử** người dùng đã lưu một tem mẫu trước đó;
  - **Khi** nhấn "Lưu vào Album" lần thứ hai cho cùng tem đó;
  - **Thì** hệ thống thông báo "Tem này đã có trong Album của bạn" và không tạo bản sao.

- **AC-06 — Mở khóa tem mẫu bằng Dấu:**
  - **Giả sử** người dùng đang xem tem mẫu bị khóa và có đủ Dấu;
  - **Khi** nhấn "Mở khóa — X📮" và xác nhận;
  - **Thì** tem được mở khóa vĩnh viễn, số Dấu giảm tương ứng, nút đổi thành "Lưu vào Album".

- **AC-07 — Không đủ Dấu — gợi ý chia sẻ hoặc nạp:**
  - **Giả sử** người dùng muốn mở tem mẫu nhưng không đủ Dấu;
  - **Khi** nhấn "Mở khóa";
  - **Thì** hiển thị số Dấu còn thiếu và hai lựa chọn: "Chia sẻ tem để kiếm Dấu" hoặc "Nạp Dấu"; không mở khóa cho đến khi đủ Dấu.

- **AC-08 — Tem mẫu đã lưu dùng được trong thư:**
  - **Giả sử** người dùng đã lưu một tem mẫu vào Album;
  - **Khi** soạn thư mới và vào bước đính tem (SM-014);
  - **Thì** tem mẫu đó xuất hiện trong tab "Tất cả" của Album, có thể chọn và đính lên thư như tem thường.

- **AC-09 — Tem mới được đánh dấu:**
  - **Giả sử** StampMail vừa bổ sung bộ tem Tết mới;
  - **Khi** người dùng mở Bộ tem mẫu;
  - **Thì** các tem mới có nhãn "Mới" hiển thị rõ ràng trên ảnh tem.

#### Offline

- **AC-10 — Duyệt tem đã tải khi mất mạng:**
  - **Giả sử** người dùng đã mở Bộ tem mẫu trước đó và sau đó mất kết nối mạng;
  - **Khi** người dùng mở lại màn hình Bộ tem mẫu;
  - **Thì** các tem đã tải trước đó vẫn hiển thị được; thông báo "Đang xem ngoại tuyến" xuất hiện ở đầu màn hình.

- **AC-11 — Lưu và mở khóa bị chặn khi mất mạng:**
  - **Giả sử** người dùng đang xem một tem mẫu và thiết bị không có kết nối mạng;
  - **Khi** người dùng nhấn "Lưu vào Album" hoặc "Mở khóa";
  - **Thì** hành động không được thực hiện; hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."; số Dấu không thay đổi.

### 5. Trường hợp ngoại lệ & lỗi

**Khi mất kết nối (offline):**
- Người dùng vẫn duyệt và xem được các tem đã hiển thị trước đó (từ bộ nhớ đệm); thông báo "Đang xem ngoại tuyến" xuất hiện ở đầu màn hình để người dùng biết nội dung có thể chưa cập nhật.
- Nút "Lưu vào Album" và nút "Mở khóa" bị vô hiệu hoá; khi nhấn vào, hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." — không trừ Dấu, không ghi dữ liệu.
- Các tem chưa từng tải về không hiển thị được khi mất mạng; vị trí đó hiển thị ảnh giữ chỗ (placeholder) thay vì để trống.

**Khi dữ liệu không tải được (lỗi mạng / lỗi máy chủ):**
- Nếu toàn bộ bộ tem không tải được, màn hình hiển thị biểu tượng lỗi kèm thông báo "Không thể tải bộ tem. Vui lòng thử lại." và nút "Thử lại" để người dùng tải lại.
- Nếu chỉ một chủ đề không tải được, danh sách hiển thị skeleton (khung giữ chỗ) trong thời gian tải; sau thời gian chờ, khu vực đó hiển thị thông báo lỗi và nút "Thử lại" ngay tại chỗ.
- Khi chủ đề chưa có tem nào (chủ đề mới chưa có nội dung): hiển thị trạng thái "Sắp ra mắt" thay vì danh sách trống.

**Khi chưa đăng nhập / thoát app giữa chừng:**
- Người dùng chưa đăng nhập vẫn xem và duyệt được bộ tem mẫu đã tải; nhưng khi nhấn "Lưu vào Album" hoặc "Mở khóa", hệ thống chuyển hướng sang màn hình đăng nhập (SM-001) và giữ nguyên tem đang xem để người dùng quay lại sau khi đăng nhập.
- Khi người dùng nhấn mở khóa nhưng không đủ Dấu: không trừ Dấu, không mở khóa; hiển thị gợi ý kiếm thêm hoặc nạp Dấu.
- Nếu người dùng thoát app khi đang xem tem mẫu, không có dữ liệu nào bị mất; lần sau mở lại, màn hình Bộ tem mẫu trở về trạng thái mặc định (danh sách chủ đề) thay vì khôi phục tem đang xem dở.

---

### Liên kết tính năng khác

- SM-022 (Album sưu tập tem): nơi lưu tem mẫu sau khi mở khóa; tem mẫu xuất hiện trong Album với nhãn phân biệt.
- SM-014 (Đính tem lên thư): tem mẫu đã lưu dùng được trong bước đính tem.
- SM-033 (Hệ thống Dấu): cơ chế mở khóa — dùng Dấu kiếm từ chia sẻ/gửi thư hoặc nạp bằng tiền thật.
- SM-034 (Tem giới hạn): khác với bộ tem mẫu — tem giới hạn gắn với sự kiện có thời hạn.

---

## Thiết kế màn hình

> **Quy tắc:** ✅ Vẽ riêng · 📝 Annotation trên frame gốc · ♻️ Dùng lại layout từ flow khác

### Tổng quan trạng thái trong spec

| Màn hình | Trạng thái |
|---|---|
| Hộp thư đã gửi | List-default · List-empty · List-offline · Detail-active-read · Detail-expired |
| Album | Grid · List-view · Empty · Offline |
| Trong Album | Default · Edit-mode |
| Chi tiết tem | Detail-own · Detail-received |
| Thêm tem | Picker |
| Bộ tem mẫu | Browse-default · Coming-soon · Detail-free · Detail-locked · Detail-saved · Insufficient |

**Tổng: ~22 trạng thái / 6 loại màn hình**

### Frame cần thiết kế (13 frame)

| # | Frame | Ghi chú |
|---|---|---|
| 1 | Hộp thư đã gửi — List | Badge trạng thái: Đang hoạt động / Đã đọc / Hết hạn |
| 2 | Hộp thư đã gửi — Detail | Link + trạng thái; Hết hạn → nút "Gia hạn link" |
| 3 | Hộp thư đã gửi — Empty | |
| 4 | Album — Grid | 3 tab mặc định + album tự tạo + nút "+" |
| 5 | Album — Empty | |
| 6 | Trong Album — Default | Lưới tem + nút Thêm tem + Chỉnh sửa |
| 7 | Trong Album — Edit-mode | Checkbox + action bar "Xóa / Chuyển album" |
| 8 | Chi tiết tem — Tự tạo | Nút: Chia sẻ / Gắn lên thư / Thêm vào album / Xóa |
| 9 | Chi tiết tem — Nhận được | Không có nút "Xóa vĩnh viễn" |
| 10 | Picker — Thêm vào album | Grid tem với dấu tick trên tem đã có |
| 11 | Bộ tem mẫu — Browse | Lưới chủ đề; tem bị khóa có badge giá Dấu |
| 12 | Bộ tem mẫu — Detail free | Preview lớn + nút "Lưu vào Album" |
| 13 | Bộ tem mẫu — Detail locked + Insufficient | Nút "Mở khóa X📮"; Insufficient → nút chuyển sang trạng thái disabled + gợi ý |

**Bỏ qua / annotation:** List-view (📝 toggle annotation trên frame 4); Offline (📝 banner); Coming-soon (📝 label annotation trên frame 11); Detail-saved (📝 nút đổi thành "Đã lưu" trên frame 12).

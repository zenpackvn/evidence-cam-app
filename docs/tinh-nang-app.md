# ZenPack EvidenceCam — Catalog chức năng app

> **Mục đích tài liệu**: nguyên liệu để lên kịch bản video giới thiệu app.
> Mỗi mục ghi *người dùng thấy gì trên màn hình* + *nó giải quyết chuyện gì* — đủ để dựng thành cảnh quay.
>
> **Nguồn**: mã nguồn `evidence-cam-app/` (đọc ngày 2026-08-21) và spec sản phẩm `specs/projects/evidencecam/`.
> Chức năng nào chỉ có trên **web admin** (không có trong app) đều được đánh dấu 🌐.

---

## 0. Một câu về sản phẩm

> **"Mỗi kiện hàng. Một bằng chứng. Bảo vệ doanh thu của bạn."**
> (đúng tagline màn onboarding trong app)

App quay video bằng chứng đóng hàng **rảnh tay** cho người bán TMĐT: đưa bill vào khung hình là camera tự quay,
quét bill kế tiếp là tự chốt đơn cũ và mở đơn mới. Video được **niêm phong số** (vân tay + dấu thời gian độc lập),
và khi bị khiếu nại thì gửi cho sàn bằng **một cái link** — sàn tự kiểm chứng, không cần tin ZenPack.

---

## 1. Bản đồ màn hình

**4 tab dưới cùng**: `Vận đơn` · `Ghi hình` · `Khiếu nại` · `Tài khoản`

**36 màn/route** trong app:

| Nhóm | Màn hình |
|---|---|
| Vào app | Onboarding · Đăng nhập · Đăng ký · Quên mật khẩu |
| Cửa hàng | Chọn shop · Chưa có shop · Tạo shop · Quản lý cửa hàng · Chi tiết cửa hàng · Đổi tên · Xóa cửa hàng · Thành viên · Mời thành viên (email/QR) · Quét mã mời · Thao tác thành viên · Tạo loại video · Xác nhận xóa · Sheet độ phân giải · Sheet thời lượng |
| Ghi hình | Camera chờ bill · Đang quay · Chuyển đơn A→B · Sắp chạm trần · Quay hàng hoàn · Nhập tay mã · Chọn loại video · Hàng đợi upload · Mã QR dừng quay |
| Vận đơn | Danh sách vận đơn (Home) · Timeline bằng chứng theo đơn · Chi tiết video · Chi tiết ảnh · Trình phát video · Cắt video |
| Khiếu nại | Danh sách hồ sơ · Tạo hồ sơ · Chi tiết hồ sơ (WebView trang công khai) |
| Tài khoản | Tài khoản · Sửa hồ sơ · Ngôn ngữ · Phương thức đăng nhập · Đổi/tạo mật khẩu · Gói cước & hạn mức · Kho lưu trữ · Cắm kho riêng · Xóa tài khoản |

---

## 2. Vào app — Onboarding & xác thực

| # | Chức năng | Chi tiết |
|---|---|---|
| 2.1 | Màn onboarding | 3 dòng tagline + nút "Bắt đầu" |
| 2.2 | Đăng nhập email/mật khẩu | Firebase Auth |
| 2.3 | Đăng nhập Google | 1 chạm |
| 2.4 | Đăng nhập Apple | 1 chạm (bắt buộc theo App Store) |
| 2.5 | Đăng ký tài khoản | Họ tên + email + mật khẩu + đồng ý điều khoản |
| 2.6 | Xác minh email | Gửi mail xác minh, chặn đăng nhập tới khi bấm link, có nút **gửi lại email** |
| 2.7 | Quên mật khẩu | Nhập email → nhận link đặt lại |
| 2.8 | Tự gộp tài khoản | Cùng một email đăng nhập bằng cách nào cũng về **một tài khoản** |
| 2.9 | Kiểm tra độ mạnh mật khẩu | ≥8 ký tự, có chữ và số, chặn mật khẩu dễ đoán |
| 2.10 | Cổng cập nhật app | Server bật cờ → hiện hộp thoại "Đã có phiên bản mới". Bản **bắt buộc** không tắt được; bản **mềm** bấm "Để sau" và im lặng trong khoảng thời gian cấu hình |

**Cảnh quay gợi ý**: mở app → chạm "Đăng nhập với Google" → vào thẳng màn chọn shop. 6 giây.

---

## 3. Cửa hàng & ca làm

### 3.1 Chọn shop / vào ca
- Danh sách shop tài khoản thuộc về, **chạm shop là vào ca**.
- Shop vào gần nhất sẽ tự mở ở lần sau (không phải chọn lại mỗi sáng).
- Trạng thái rỗng: "Chưa có shop nào" + nút tạo shop + gợi ý chờ lời mời.
- Hàng **"Tôi có lời mời"** — dán link mời từ email, hoặc **quét mã QR mời**.

### 3.2 Tạo & quản lý cửa hàng
| # | Chức năng | Chi tiết |
|---|---|---|
| 3.2.1 | Tạo shop | Tên shop + chọn sàn TMĐT. Người tạo là Chủ shop |
| 3.2.2 | Nhiều cửa hàng trên một tài khoản | Chuyển shop bất kỳ lúc nào |
| 3.2.3 | Đổi tên cửa hàng | |
| 3.2.4 | Xóa cửa hàng — **có xem trước** | Hộp thoại nói rõ "X đơn · Y video · Z thành viên sẽ bị xóa vĩnh viễn", cảnh báo riêng nếu còn **hồ sơ khiếu nại đang mở** (link đã gửi sàn sẽ chết) |
| 3.2.5 | Màn "Quản lý cửa hàng" | Chỉ Chủ tài khoản / Quản lý shop thấy — nhân viên không thấy màn này |

### 3.3 Cài đặt quay của shop (Chi tiết cửa hàng)
| # | Cài đặt | Chi tiết |
|---|---|---|
| 3.3.1 | **Độ phân giải quay** | Áp cho video quay mới của shop; 720p mặc định |
| 3.3.2 | **Thời lượng tối đa mỗi video** | Chạm mốc là tự chốt. App **gợi ý theo giới hạn của sàn đang bán** ("Đề xuất 5 phút — theo Shopee, 30 MB/video + 720p") và cảnh báo nếu chọn vượt: video nặng quá phải gửi bằng link hồ sơ thay vì đính thẳng lên form khiếu nại. Có ô nhập số phút tùy ý; trần cứng theo gói cước |
| 3.3.3 | **Dung lượng tối đa mỗi tệp** | Cùng logic đề xuất theo sàn; tệp vượt trần không đính được |
| 3.3.4 | **Loại video** | 3 loại có sẵn khóa cứng: *Đóng hàng · Đơn vị vận chuyển · Trả hàng*. Shop tự thêm loại riêng (tên + biểu tượng + màu). Không xóa được loại đã có video (chặn để không làm rối bộ lọc/thống kê) |

### 3.4 Thành viên & phân quyền
| # | Chức năng | Chi tiết |
|---|---|---|
| 3.4.1 | 3 vai trò | **Chủ shop** · **Quản lý shop** · **Nhân viên** |
| 3.4.2 | Mời bằng email | Người được mời phải có tài khoản ZenPack; họ nhận thư và phải bấm xác nhận. Lời mời sống **14 ngày** |
| 3.4.3 | Mời bằng **mã QR** | Chủ shop mở mã, người kia quét bằng app. Mã **dùng một lần**, sống 10 phút |
| 3.4.4 | Thu hồi lời mời | Link trong email hết tác dụng ngay |
| 3.4.5 | Gỡ thành viên | Video họ đã quay vẫn upload nốt, không mất |
| 3.4.6 | Trần số người theo gói | Lời mời đang chờ cũng tính vào trần |
| 3.4.7 | Bảo vệ chủ shop | Không đổi vai trò/gỡ chủ shop từ danh sách thành viên |
| 3.4.8 | Nhân viên chỉ thấy phần của mình | Danh sách thành viên chỉ chủ shop xem được |

---

## 4. Ghi hình rảnh tay — trái tim của app

Đây là phần đáng dành nhiều thời lượng video nhất.

| # | Chức năng | Chi tiết |
|---|---|---|
| 4.1 | **Quét bill là tự quay** | Camera chạy quét mã vạch/QR liên tục trên luồng khung hình (ML Kit, chạy **trên máy**, không gửi ảnh đi đâu). Đưa bill vào khung → app đọc mã vận đơn → bắt đầu quay. Không chạm tay |
| 4.2 | **Chuyển đơn A→B tự động** | Đang quay đơn A mà quét thấy bill B: app **chốt A, lưu, mở B** trong một nhịp. Có màn xác nhận chuyển đơn với vòng đếm ngược + thẻ "Đơn tiếp theo" |
| 4.3 | Chống quay trùng | Kiện vừa quay xong còn nằm trên bàn sẽ **không** bị quét lại thành clip mới (khóa theo mã + cửa sổ thời gian) |
| 4.4 | **Mã QR dừng quay** | Một tờ QR in ra dán ở bàn đóng gói. Đang quay mà đưa mã vào khung là **chốt video ngay**. Mã dùng chung cho mọi máy. App có sẵn màn hiển thị mã: **chia sẻ** hoặc **lưu vào thư viện ảnh** để in |
| 4.5 | Nhập tay mã vận đơn | Khi bill rách/mờ — gõ mã rồi quay |
| 4.6 | Tạo vận đơn mới khi mã lạ | Mã không khớp đơn nào trong shop → hỏi "Tạo vận đơn mới?" thay vì im lặng bỏ qua |
| 4.7 | Quay **hàng hoàn** | Video hoàn tự nối vào đúng đơn gốc; báo rõ nếu mã hoàn không khớp |
| 4.8 | **Tự chốt theo trần thời lượng** | Đếm ngược "Tự chốt sau 00:48" hiện ở phút cuối + banner "Sắp chạm trần 5 phút" |
| 4.9 | **Giọng đọc thành tiếng** (6 câu) | "Đã bắt đầu quay" / "Đã dừng quay" / "Sai mã" / "Video sắp tự chốt" / "Sắp chạm trần N phút" / "Quá trình quay bị gián đoạn" — người đóng hàng hai tay bận vẫn biết máy đang làm gì. Đọc đúng ngôn ngữ app đang chọn |
| 4.10 | Âm báo + rung khi chuyển đơn | |
| 4.11 | Đóng dấu giờ + mã lên khung hình | Khi quay đã thấy trước ngày–giờ–giây và mã vận đơn ở góc phải, **đúng bố cục sẽ được nung vào video** — quay nhầm mã là lộ ra ngay tại chỗ |
| 4.12 | Chọn loại video ngay trên màn quay | Chip loại video + bottom sheet chọn nhanh |
| 4.13 | Đổi camera trước/sau | |
| 4.14 | Đổi độ phân giải ngay trong lúc quay | |
| 4.15 | **Xử lý gián đoạn** | Có cuộc gọi/thông báo cắt ngang: clip **không mất**, app hỏi "Tiếp tục quay?" hay "Kết thúc" — chọn tiếp tục là ghi nối vào đúng clip đó |
| 4.16 | Cảnh báo máy gần đầy bộ nhớ | Chặn trước khi quay dở rồi mất |
| 4.17 | Xin quyền camera đúng lúc | Từ chối quyền vẫn dùng được phần xem/tìm/quản lý đơn; có lối tắt mở Cài đặt |
| 4.18 | Pill "Đã lưu video" | Xác nhận duy nhất người quay cần thấy trước khi chạm gói tiếp theo |
| 4.19 | Tối ưu phát nhanh (faststart) | Chỉ số của video được dời lên đầu tệp ngay sau khi quay → xem online là chạy ngay, không phải tải hết. **Remux, không nén lại** — từng khung hình còn nguyên vẹn |

**Cảnh quay gợi ý**: một mạch không cắt — người đóng gói dán bill, giơ vào khung (app kêu "Đã bắt đầu quay"), đóng hàng, giơ bill kiện tiếp theo (app chốt A mở B), cuối cùng giơ tờ QR dừng quay. Không chạm màn hình một lần nào.

---

## 5. Vận đơn & bằng chứng

### 5.1 Danh sách vận đơn (tab Vận đơn)
- **3 con số đầu màn**: Vận đơn · Video đã quay · Chờ tải.
- **Tìm kiếm** theo mã vận đơn.
- **Bộ lọc**: trạng thái (Tất cả / Chờ upload / Có lỗi tải / Đã tải xong) · thời gian (Hôm nay / Hôm qua / 7 ngày / 30 ngày / chọn ngày) · loại video.
- **Phân trang** ("1–20 / 137 vận đơn", trang trước/sau).
- Mỗi hàng đơn hiện số bằng chứng, số lỗi, số đang chờ.

### 5.2 Timeline bằng chứng của một đơn
- Video/ảnh **gom theo ngày**, mỗi hàng có ảnh poster lấy từ chính clip.
- 5 tông trạng thái: đã tải xong · đang tải · chờ · chờ hạn mức · lỗi.
- **Đính kèm ảnh vào đơn** từ thư viện máy (có trần dung lượng, báo rõ khi ảnh quá nặng).
- **Quét thêm mã vào đơn này** — một kiện có nhiều mã (mã vận đơn + mã trả hàng); app chặn nếu mã đang thuộc đơn khác.

### 5.3 Chi tiết video / chi tiết ảnh
Hiện: loại video · thời lượng · giờ quay · **người quay** · **thiết bị quay** (tên máy thật, vd "SM-M146B") · dung lượng · trạng thái upload · **niêm phong**.

Hành động:
| # | Hành động | Ghi chú |
|---|---|---|
| 5.3.1 | Phát video | Trình phát trong app |
| 5.3.2 | Sao chép link bằng chứng | Chặn nếu clip chưa upload xong (chưa có link) |
| 5.3.3 | **Tải video/ảnh về máy** | Lưu vào thư viện ảnh của máy. Chỉ Chủ/QL shop — dùng khi sàn đòi file gốc |
| 5.3.4 | **Cắt đoạn ngắn để gửi** | Chọn khoảng, xem ước tính dung lượng, lưu ra bản ngắn. **Bản đầy đủ vẫn nguyên**, đoạn cắt vẫn còn dấu giờ |
| 5.3.5 | Xóa video/ảnh | Chỉ Chủ/QL shop · **xác nhận 2 bước** · **bị khóa nếu bằng chứng đang nằm trong hồ sơ khiếu nại đang mở** |
| 5.3.6 | Chia sẻ | |

---

## 6. Niêm phong số & trang kiểm chứng công khai

Đây là điểm khác biệt lớn nhất so với đối thủ — nên nói kỹ trong video.

| # | Chức năng | Người dùng thấy gì |
|---|---|---|
| 6.1 | **Đồng hồ nung vào khung hình** | Video còn lại là bản đã có ngày–giờ–giây + mã vận đơn cháy trên hình. Bản thô từ camera bị xóa sau xử lý — không có hai bản để tranh cãi bản nào là gốc |
| 6.2 | **Vân tay số** | Mỗi video có một mã băm không làm giả được |
| 6.3 | **Dấu thời gian độc lập** | Của một tổ chức cấp dấu bên ngoài — chứng minh video đã tồn tại trước thời điểm đó |
| 6.4 | **Chứng thực trên sổ công khai** | App hiện "Đã có · mục #123456" hoặc "Đang ghi vào sổ công khai (vài giờ)" |
| 6.5 | Ghi nhận **lệch giờ máy quay** | Máy lệch quá 15 phút so với máy chủ → vẫn đóng dấu theo giờ máy nhưng ghi rõ có lệch (video quay offline sáng, tải lên chiều không bị vẽ sai giờ) |
| 6.6 | **Trang kiểm chứng công khai** | Nút "Xem trang kiểm chứng" mở trang ai cũng đọc được, không cần đăng nhập: mã vận đơn, giờ quay, giờ hệ thống nhận, giờ niêm phong, có lệch giờ không, vân tay, kết quả kiểm chữ ký, và một kết luận **ĐẠT / KHÔNG ĐẠT** |
| 6.7 | Nói thật khi niêm phong hỏng | "Vân tay không khớp — hãy quay lại clip này" / "Chưa đóng được dấu thời gian · video vẫn xem và tải được". Không giấu video đi |
| 6.8 | Không phát bản chưa đóng dấu | Trong lúc xử lý, app nói "Đang đóng dấu thời gian…" thay vì đưa ra một tệp trông như bằng chứng nhưng chưa phải |

**Câu chốt cho video**: *"Gửi link này cho sàn — họ tự kiểm chứng được, không cần tin ZenPack."*

---

## 7. Hàng đợi upload & chế độ offline-first

| # | Chức năng | Chi tiết |
|---|---|---|
| 7.1 | **Quay được khi mất mạng** | Clip lưu vào vùng dữ liệu riêng của app (không phải thư mục tạm) nên sống qua khởi động lại máy và qua đợt dọn rác của hệ điều hành |
| 7.2 | **Tự tải lên khi có mạng** | Không cần mở app canh |
| 7.3 | **Upload chạy nền** | Truyền qua tác vụ nền của hệ điều hành — thoát app ra vẫn tải tiếp, không đứng lại theo app |
| 7.4 | Upload nhiều phần (multipart) | Clip lớn không phải làm lại từ đầu khi rớt mạng |
| 7.5 | Màn **Hàng đợi upload** | Bộ lọc: Tất cả · Đang tải · Lỗi · Chờ hạn mức. Dòng tóm tắt "N video đang chờ · M đang tải · K lỗi" |
| 7.6 | % tiến độ từng clip | |
| 7.7 | Tạm dừng / Tiếp tục | |
| 7.8 | Xóa 1 mục / Xóa hết hàng chờ | Có cảnh báo: clip chưa tải lên chỉ nằm trên máy này, xóa là mất hẳn |
| 7.9 | Thử lại khi lỗi | Đếm số lần thử |
| 7.10 | Trạng thái nói đúng sự thật | "Tải lên chưa xong — clip vẫn nằm trên máy đã quay", "Tạm giữ do quota", "Đã quá hạn lưu trữ ngày 12/08" |
| 7.11 | **Cảnh báo video mắc kẹt trên máy** | "N video đang chờ trên máy này — mất máy, gỡ app hoặc xóa dữ liệu app là mất luôn." Kèm câu "Đừng gỡ app cho tới khi tải lên xong" |

---

## 8. Hồ sơ khiếu nại — gửi bằng chứng cho sàn trong 1 chạm

| # | Chức năng | Chi tiết |
|---|---|---|
| 8.1 | **Tạo hồ sơ** | Nhập **hoặc quét** mã vận đơn → app tìm đơn → chọn video/ảnh cần gửi → đặt tên hồ sơ ("VD: Khiếu nại đơn hoàn 12/08") |
| 8.2 | Gộp nhiều đơn vào một hồ sơ | Hiện "3 đơn · 8 bằng chứng" |
| 8.3 | **Link công khai** | Ai có link đều xem được, không cần đăng nhập. "Đã sao chép link hồ sơ. Dán vào kênh khiếu nại của sàn." |
| 8.4 | Xem đúng cái sắp gửi | Chi tiết hồ sơ nhúng **chính trang công khai** mà nhân viên sàn sẽ thấy — không có bản thứ hai để lệch |
| 8.5 | Đính thêm bằng chứng sau | Ảnh/video thêm vào hồ sơ đã tạo, gắn nhãn "đính thêm" |
| 8.6 | Gỡ bằng chứng khỏi hồ sơ | Video trong đơn hàng vẫn còn nguyên |
| 8.7 | **Thu hồi link** | Link chết ngay với bất kỳ ai đang giữ, kể cả sàn. Dữ liệu vẫn nguyên |
| 8.8 | Xóa hồ sơ | Nói rõ hậu quả với link đang mở |
| 8.9 | Hoạt động khi mất mạng | Tạo được hồ sơ tại chỗ, app nói rõ "chưa có link chia sẻ — mở lại khi có mạng" thay vì giả vờ đã gửi |
| 8.10 | Khóa xóa bằng chứng đang dùng | Bằng chứng nằm trong hồ sơ đang mở thì không xóa được, phải gỡ khỏi hồ sơ trước |

---

## 9. Kho lưu trữ của cửa hàng

| # | Chức năng | Chi tiết |
|---|---|---|
| 9.1 | **Cloud ZenPack** (mặc định) | Không phải cấu hình gì |
| 9.2 | **Kho riêng chuẩn S3** | AWS S3, Cloudflare R2, MinIO, Wasabi… Nhập Endpoint / Bucket / Access key / Secret / Region / Prefix |
| 9.3 | **Google Drive** | Cắm bằng một lượt cấp quyền, không cần dán khóa |
| 9.4 | **Kiểm tra trước khi lưu** | Hệ thống ghi–đọc–xóa thử một tệp nhỏ để chắc quyền đúng; có nút "Kiểm tra lại kết nối" bất kỳ lúc nào |
| 9.5 | **Tình trạng kho** | Tổng video · Còn nguyên vẹn · Không truy cập được · Sai lệch với hồ sơ niêm phong · Đang chờ ở vùng tạm. Kèm thời điểm rà gần nhất |
| 9.6 | Nói thẳng đánh đổi | Kho không ký được link → người nhận link thấy chậm hơn. Kho không khóa được đối tượng → không hứa với sàn là bằng chứng không xóa được |
| 9.7 | Thôi dùng kho riêng | Video mới về kho hệ thống; video cũ nằm lại kho của bạn |
| 9.8 | Giới hạn quyền | Chỉ chủ cửa hàng đổi kho; cần gói Chuyên nghiệp trở lên |
| 9.9 | **Niêm phong không phụ thuộc kho** | Cất ở đâu thì hồ sơ niêm phong vẫn nằm tại hệ thống — đổi kho không làm yếu bằng chứng |

---

## 10. Gói cước & hạn mức

| # | Chức năng | Chi tiết |
|---|---|---|
| 10.1 | Màn **Gói cước & dung lượng** | Gói hiện tại · "Còn lại trong tháng" · thanh tiến độ · "Đã dùng 340/1.000 video · 34%" |
| 10.2 | Số video đang lưu + thời gian lưu | "30 ngày" — kèm ghi chú dung lượng hoàn lại khi video hết hạn |
| 10.3 | **Bảng chia theo loại video** | Cột màu xếp chồng + một hàng cho mỗi loại video |
| 10.4 | Lượt mua thêm · mốc bị chặn · chu kỳ đếm | Mốc chặn hiện thành **số** ("Chặn quay mới từ 1.100 video"), không nói chung chung "sắp hết". Đếm lại từ đầu tháng sau, không cộng dồn |
| 10.5 | **Mua gói ngay trong app** | Paywall của RevenueCat qua IAP Apple/Google. Máy chủ mới là nơi cấp ngày — app mua xong chỉ hỏi lại máy chủ |
| 10.6 | Xử lý khi hết hạn mức | **Vẫn quay bình thường**; video nằm trên máy và tự tải lên khi hạn mức được nâng. App nói rõ chúng "chưa được bảo vệ" |
| 10.7 | Nhân viên hết hạn mức | Chỉ dẫn đúng người: "Hạn mức của cửa hàng này do chủ tài khoản quyết định — liên hệ họ để nâng" |
| 10.8 | 4 gói | Miễn phí (50 video/tháng · 2 người) · Cơ bản (1.000 · 5) · Chuyên nghiệp (3.000 · 15 · mở kho riêng) · Doanh nghiệp (8.000 · không giới hạn) |

---

## 11. Tài khoản cá nhân

| # | Chức năng | Chi tiết |
|---|---|---|
| 11.1 | Sửa hồ sơ | Họ tên · số điện thoại (tùy chọn) · **ảnh đại diện**. Email khóa cứng vì là định danh |
| 11.2 | **Phương thức đăng nhập** | Xem cái nào đã liên kết; **liên kết/hủy liên kết** Google, Apple. Email không gỡ được |
| 11.3 | Tạo / đổi mật khẩu | Đổi xong đăng xuất khỏi các thiết bị khác |
| 11.4 | **10 ngôn ngữ** | Tiếng Việt · Anh · Indonesia · Philippines · Thái · Malaysia · Đức · Pháp · Ý · Tây Ban Nha. Đổi là áp dụng ngay toàn app — kể cả **giọng đọc lúc quay** và nội dung hồ sơ |
| 11.5 | **Mã dừng quay** | Mở tờ QR để **chia sẻ** hoặc **lưu vào thư viện ảnh** đem đi in. Dòng thương hiệu được vẽ thẳng vào ảnh nên người nhận biết mã của đâu ra |
| 11.6 | Đăng xuất | Có xác nhận |
| 11.7 | **Xóa tài khoản** | **2 bước xác nhận**, cảnh báo riêng nếu còn hồ sơ đã gửi sàn ("link chia sẻ sẽ ngừng hoạt động") |
| 11.8 | Góp ý với chúng tôi | Gửi thẳng từ trong app |
| 11.9 | Đánh giá ứng dụng | Mở trang store |
| 11.10 | Hỗ trợ | Nhắn **Facebook** · nhắn **Zalo** · **Gọi hỗ trợ** |
| 11.11 | Số phiên bản | Cuối màn Tài khoản |

---

## 12. Bảng quyền theo vai trò

| Việc | Chủ shop | Quản lý shop | Nhân viên |
|---|:--:|:--:|:--:|
| Quay video, xem video mình quay | ✅ | ✅ | ✅ |
| Xem toàn bộ đơn & bằng chứng của shop | ✅ | ✅ | — |
| Tải video gốc về máy | ✅ | ✅ | — |
| Xóa video/ảnh | ✅ | ✅ | — |
| Xem/quản lý danh sách thành viên | ✅ | — | — |
| Mời & gỡ thành viên | ✅ | — | — |
| Đổi cài đặt quay của shop | ✅ | ✅ | — |
| Đổi kho lưu trữ | ✅ | — | — |
| Xóa cửa hàng | ✅ | — | — |

---

## 13. Có trên web admin, chưa có trong app 🌐

Nhắc để kịch bản không hứa nhầm — hoặc để làm cảnh "và trên máy tính thì…":

- 🌐 **Xuất Excel/CSV đối soát** (API đã có, app chưa gắn nút).
- 🌐 **Công cụ bàn đóng gói**: mã chuẩn bị, đóng mã lên bill, quét mã trên trình duyệt.
- 🌐 **Bảng giá & mua đứt theo tháng/năm** (trong app là gói IAP).
- 🌐 Thông báo qua **thư điện tử**: cảnh báo 90% hạn mức, lời mời vào shop, các mốc tài khoản.
- 🌐 Tổng quan cửa hàng & báo cáo chi tiết.

---

## 14. Gợi ý phân cảnh video (~90 giây)

| # | Thời lượng | Cảnh | Chức năng lên hình |
|---|---|---|---|
| 1 | 0:00–0:08 | Nỗi đau: seller ngồi trước màn hình khiếu nại "khách báo thiếu hàng", không có gì để cãi | — |
| 2 | 0:08–0:15 | Mở app, đăng nhập Google, chạm shop để vào ca | §2, §3.1 |
| 3 | 0:15–0:40 | **Một mạch không cắt tại bàn đóng gói**: giơ bill → "Đã bắt đầu quay" → đóng hàng → giơ bill kiện sau → chuyển đơn A→B → giơ tờ QR dừng quay | §4.1–4.4, §4.9, §4.11 |
| 4 | 0:40–0:50 | Máy tắt wifi: video vẫn quay, hàng đợi hiện "chờ tải" rồi tự chạy khi có mạng lại | §7 |
| 5 | 0:50–1:02 | Vài ngày sau: gõ mã vận đơn vào ô tìm kiếm → timeline → mở chi tiết video, thấy giờ nung trên hình + "Niêm phong: Đã khóa" | §5 |
| 6 | 1:02–1:15 | Chạm "Xem trang kiểm chứng" → trang công khai hiện **ĐẠT** — *"Gửi link này cho sàn, họ tự kiểm chứng, không cần tin ZenPack"* | §6 |
| 7 | 1:15–1:25 | Tạo hồ sơ khiếu nại → chọn 3 bằng chứng → chép link → dán vào form của sàn | §8 |
| 8 | 1:25–1:35 | Lướt nhanh: nhiều shop, mời nhân viên bằng QR, kho riêng S3, gói cước | §3, §9, §10 |
| 9 | 1:35–1:40 | Kết: logo + "Mỗi kiện hàng. Một bằng chứng." | — |

### Ba câu bán hàng lấy thẳng từ app
1. *"Đưa bill vào khung là quay. Đưa bill kế tiếp vào là chốt đơn cũ, mở đơn mới. Không chạm tay."*
2. *"Mất mạng vẫn quay. Có mạng là tự tải lên — kể cả khi bạn đã thoát app."*
3. *"Gửi link cho sàn. Họ tự kiểm chứng được, không cần tin ZenPack."*

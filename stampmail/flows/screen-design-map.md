# Screen Design Map — StampMail 2

Liệt kê toàn bộ màn hình + trạng thái đã ghi trong spec, và khuyến nghị frame nào cần thiết kế.

**Quy tắc phân loại:**
- ✅ **Vẽ riêng** — layout thay đổi đáng kể hoặc nội dung quan trọng với dev/QA
- 📝 **Annotation** — ghi chú trên frame đã có (thêm banner, disable nút, toast, text lỗi nhỏ)
- ♻️ **Dùng lại** — dùng lại layout/component từ flow khác

**Nguyên tắc tối ưu:**
- Trạng thái chỉ đổi text/màu → annotation
- Trạng thái thêm banner offline/toast → annotation trên frame gốc
- Trạng thái ẩn/hiện 1 button → annotation
- Layout thay đổi cấu trúc, empty state, màn hình xác nhận → vẽ riêng

---

## Flow 1 · Khởi đầu

### Tất cả màn hình trong spec

| Screen | Trạng thái từ spec |
|---|---|
| Splash | — |
| Onboarding | Slide 1 · Slide 2 · Slide 3 |
| Login | Default · Filled · Field-error · Form-error · Locked · Offline · Social-connecting · Wrong-method |
| Register | Default · Filled · Field-error · Email-exists · Choice |
| Verify | Email-code · Code-resent |
| Choose-username | Default · Username-taken |
| Avatar | — |
| Forgot | Default · Sent |
| Reset | Default · Link-expired · Link-used · Success |
| Home | ⚠️ chưa có frame |

**Tổng: ~30 trạng thái / 10 loại màn hình**

### Khuyến nghị vẽ (17 frame)

| # | Frame | Ghi chú |
|---|---|---|
| 1 | Splash | |
| 2 | Onboarding — 1 slide (template) | Slide 2, 3 dùng cùng layout → không vẽ riêng; chỉ đổi nội dung |
| 3 | Login — Default | Form email + PW + 4 nút social |
| 4 | Login — Field-error + Form-error | Gộp 2 loại lỗi trong 1 frame để tham chiếu |
| 5 | Login — Locked | Layout khác: ẩn nút, hiện đếm ngược 15 phút |
| 6 | Register — Default | Form đăng ký đầy đủ |
| 7 | Register — Choice (chọn phương thức) | Bottom sheet hoặc màn hình riêng khi chọn social |
| 8 | Verify email | OTP / link xác nhận |
| 9 | Choose username | Default; Username-taken → annotation (text lỗi dưới ô) |
| 10 | Avatar upload | Rõ nút "Bỏ qua" |
| 11 | Forgot — Default | Form nhập email |
| 12 | Forgot — Sent | Layout khác: không còn form, chỉ thông báo |
| 13 | Reset — Default | Form mật khẩu mới |
| 14 | Reset — Link expired / Link used | Không có form, chỉ thông báo + CTA gửi lại (gộp 2 trạng thái này) |
| 15 | Reset — Success | |
| 16 | Home — Empty (người dùng mới, chưa có tem) | |
| 17 | Home — Loaded | Chốt sau wireframe |

**Bỏ qua / annotation:** Filled, Offline, Social-connecting, Wrong-method trên Login; Code-resent trên Verify; Email-exists trên Register.

---

## Flow 2 · Tạo tem

### Tất cả màn hình trong spec

| Screen | Trạng thái từ spec |
|---|---|
| Nguồn ảnh | Default · No-camera · Permission-denied |
| Xem ảnh trước | Default · Zoomed · Too-large |
| Bộ lọc màu (SM-006) | Default · Filter-applied · Manual-adjusted · Premium-locked · Offline |
| Trang trí (SM-008) | Default · Element-selected · Locked-sticker-sheet · Sticker-error |
| Viền & Khung (SM-009) | Default · Border-selected · Locked-border-sheet · Offline |
| Xem trước tem (SM-010) | Default · Bg-changed |
| Lưu tem (SM-011) | Success · Quota-reached · Share-limit · Offline |

**Tổng: ~22 trạng thái / 7 loại màn hình**

### Khuyến nghị vẽ (13 frame)

| # | Frame | Ghi chú |
|---|---|---|
| 1 | Nguồn ảnh — Default | Camera + thư viện |
| 2 | Nguồn ảnh — No-camera | Chỉ thư viện (ẩn option camera) |
| 3 | Xem ảnh trước | Permission-denied → system dialog (OS xử lý, không vẽ); Zoomed → annotation; Too-large → alert overlay |
| 4 | Bộ lọc — Default | Lưới 16 bộ lọc (8 free + 8 khóa với icon lock) + 3 thanh chỉnh |
| 5 | Bộ lọc — Premium-locked tap | Bottom sheet gợi ý nâng cấp khi nhấn bộ lọc khóa |
| 6 | Trang trí — Default | Sticker picker mở, tem trống |
| 7 | Trang trí — Element-selected | Sticker đã đặt + handles (kéo/xoay/phóng to) |
| 8 | Trang trí — Locked sticker sheet | Bottom sheet 2 lựa chọn: "Dùng 50📮" / "Nâng cấp Premium" |
| 9 | Viền — Default | 7 kiểu viền (3 free + 4 khóa) + bảng màu |
| 10 | Viền — Locked border tap | Bottom sheet 2 lựa chọn: "Dùng 80📮" / "Nâng cấp Premium" |
| 11 | Xem trước tem | Filter-applied, Manual-adjusted, Offline → annotation; Bg-changed → annotation (đổi màu nền) |
| 12 | Lưu tem — Success | Hiện 2 CTA: "Gắn lên thư" + "Chia sẻ & nhận 10📮" |
| 13 | Lưu tem — Quota reached | Thông báo hết hạn mức + gợi ý Premium |

**Bỏ qua / annotation:** Border-selected (annotation trên frame Default), Offline states (banner annotation), Share-limit (annotation trên Success).

---

## Flow 3 · Soạn & Gửi thư

### Tất cả màn hình trong spec

| Screen | Trạng thái từ spec |
|---|---|
| Chọn template (SM-012) | List-default · List-premium-locked · List-offline · List-error |
| Xem trước template | Preview-free · Preview-premium |
| Soạn nội dung (SM-013) | Default · Typing · Near-limit · At-limit · Formatting |
| Đính tem (SM-014) | ⚠️ chưa có frame |
| Xem trước thư (SM-015) | Default · Empty-warning · Offline |
| Gửi thư (SM-016) | Platform-picker · Multi-select · App-not-installed · Quota-reached · Success |

**Tổng: ~20 trạng thái / 6 loại màn hình**

### Khuyến nghị vẽ (12 frame)

| # | Frame | Ghi chú |
|---|---|---|
| 1 | Danh sách template — Default | Phân nhóm chủ đề, icon khóa Premium |
| 2 | Xem trước template — Free | Full preview + nút "Chọn template này" |
| 3 | Xem trước template — Premium (người dùng Free) | Ẩn nút chọn, hiện nút "Nâng cấp Premium" |
| 4 | Soạn nội dung — Default | Ô bo góc trên nền giấy thư + toolbar (font/màu/kẻ dòng) |
| 5 | Soạn nội dung — Near-limit / At-limit | Annotation: hiện đếm ký tự còn lại; At-limit → disable nhập thêm |
| 6 | Soạn nội dung — Formatting (sticker) | Panel sticker mở trong soạn thư |
| 7 | Đính tem | Picker tab: Tất cả / Tự tạo / Nhận được / Album tùy chỉnh; chốt ở wireframe |
| 8 | Đính tem — Empty album | Trạng thái chưa có tem + gợi ý tạo tem |
| 9 | Xem trước thư — Default | Thư hoàn chỉnh như người nhận thấy |
| 10 | Xem trước thư — Empty-warning | Alert cảnh báo thư trống |
| 11 | Gửi thư — Platform picker | 8 nền tảng (Zalo, Messenger, Instagram…) |
| 12 | Gửi thư — Success | Xác nhận đã gửi + nhận 5📮 |

**Bỏ qua / annotation:** List-offline/error (banner + skeleton annotation), Multi-select (checkbox annotation trên Platform picker), App-not-installed (toast annotation), Quota-reached (modal annotation), Offline states (banner annotation).

---

## Flow 4 · Nhận & Đọc thư

### Tất cả màn hình trong spec

| Screen | Trạng thái từ spec |
|---|---|
| Web nhận thư (SM-017) | Guest · Already-opened · Link-expired · Invalid-link · Offline |
| Mở thư & Animation (SM-019) | Animating · Completed · Guest-completed · Re-view · Offline · Animation-error |
| Hộp thư đến (SM-018) | Default · Unread-filter · Empty · Offline · Error |
| Trả lời thư (SM-020) | Compose · Web-no-app · Offline |

**Tổng: ~16 trạng thái / 4 loại màn hình**

### Khuyến nghị vẽ (9 frame)

| # | Frame | Ghi chú |
|---|---|---|
| 1 | Web nhận thư — Guest | Trang web: hiện phong bì + nút mở thư + gợi ý tải app |
| 2 | Web nhận thư — Already-opened / Link-expired | Gộp 2: trang thông báo lỗi (không xem được nội dung) |
| 3 | Animation mở thư — Keyframes | Vẽ 2–3 keyframe (phong bì đóng → đang mở → giấy cuộn ra) để developer hiểu motion |
| 4 | Nội dung thư — Completed (đã đăng nhập) | Sau animation: thư đầy đủ + nút "Lưu tem" + "Trả lời" |
| 5 | Nội dung thư — Guest-completed (chưa đăng nhập) | Sau animation: nút "Lưu tem" disabled, nút "Tải StampMail" |
| 6 | Hộp thư đến — Default | Danh sách thư (ảnh tem · tên gửi · thời gian · trạng thái đọc) |
| 7 | Hộp thư đến — Empty | Trạng thái rỗng |
| 8 | Trả lời thư — Compose | Soạn thư + người nhận điền sẵn (♻️ layout gần giống Flow 3 Soạn nội dung) |
| 9 | Trả lời — Web-no-app | Màn hình "Tải StampMail để trả lời" |

**Bỏ qua / annotation:** Invalid-link (gộp với Already-opened), Re-view (annotation: không có animation), Offline/Error (banner annotation), Unread-filter (annotation trên Default).

---

## Flow 5 · Quản lý & Sưu tầm

### Tất cả màn hình trong spec

| Screen | Trạng thái từ spec |
|---|---|
| Hộp thư đã gửi (SM-021) | List-default · List-empty · List-offline · Detail-active-read · Detail-expired |
| Album (SM-022) | Grid · List-view · Empty · Offline |
| Trong Album con | Custom · Edit-mode |
| Chi tiết tem | Detail-own · Detail-received |
| Thêm tem (picker) | Picker |
| Bộ tem mẫu (SM-035) | Browse-default · Coming-soon · Detail-free · Detail-locked · Detail-saved · Insufficient |

**Tổng: ~22 trạng thái / 6 loại màn hình**

### Khuyến nghị vẽ (13 frame)

| # | Frame | Ghi chú |
|---|---|---|
| 1 | Hộp thư đã gửi — List | Badge trạng thái link: Đang hoạt động · Đã đọc · Hết hạn |
| 2 | Hộp thư đã gửi — Detail | Chi tiết từng link + nút "Tạo link mới" (chỉ với link hết hạn) |
| 3 | Hộp thư đã gửi — Empty | |
| 4 | Album — Grid view | 3 tab mặc định + album tùy chỉnh bên dưới |
| 5 | Album — Empty | Gợi ý tạo tem đầu tiên |
| 6 | Trong Album tùy chỉnh — Default | Danh sách tem + nút "Thêm tem" + nút "Chỉnh sửa" |
| 7 | Trong Album tùy chỉnh — Edit-mode | Mỗi tem có checkbox + thanh action bên dưới |
| 8 | Chi tiết tem — Tự tạo | Ảnh lớn + ngày tạo + nút chia sẻ / đính lên thư / thêm vào album |
| 9 | Chi tiết tem — Nhận được | Thêm tên người gửi; không có nút "Xóa vĩnh viễn" |
| 10 | Picker thêm tem vào album | Lưới tem "Tất cả" + checkmark tem đã có trong album |
| 11 | Bộ tem mẫu — Browse | Lưới tem theo chủ đề; tem có khóa hiện giá Dấu |
| 12 | Bộ tem mẫu — Detail free | Xem trước + nút "Lưu vào Album" |
| 13 | Bộ tem mẫu — Detail locked | Xem trước + nút "Mở khóa X📮" + trạng thái Insufficient |

**Bỏ qua / annotation:** List-view (toggle annotation trên Grid), Offline (banner annotation), Coming-soon (label annotation trên Browse), Detail-saved (nút đã đổi thành "Đã lưu").

---

## Flow 6 · Kiếm & tiêu Dấu

### Tất cả màn hình trong spec

| Screen | Trạng thái từ spec |
|---|---|
| Chia sẻ tem (SM-025) | Level-1 · Level-2 · Level-3 · Format-toggle · Saved · Offline |
| Số dư Dấu (SM-033) | Balance · Balance-offline · Logged-out · First-earn-reveal |
| Mua Dấu | Insufficient · Buy-default · Buy-success · Buy-error |

**Tổng: ~13 trạng thái / 3 loại màn hình**

### Khuyến nghị vẽ (7 frame)

| # | Frame | Ghi chú |
|---|---|---|
| 1 | Chia sẻ tem — Chọn mức + định dạng | 3 mức nội dung (radio) + toggle 9:16 / 1:1 + preview ảnh |
| 2 | Chia sẻ tem — Level-2/3 warning | Modal cảnh báo "nội dung thư sẽ công khai" trước khi share |
| 3 | Số dư Dấu — Balance | Hiện số Dấu + lịch sử kiếm/tiêu + CTA mua thêm |
| 4 | Số dư Dấu — First-earn-reveal | Modal giới thiệu hệ thống Dấu lần đầu |
| 5 | Mua Dấu — Default | Các gói Dấu (100📮 = 29k…) |
| 6 | Mua Dấu — Success | Xác nhận mua thành công |
| 7 | Mua Dấu — Insufficient / Error | Thông báo thiếu Dấu + 2 CTA (chia sẻ / mua thêm) |

**Bỏ qua / annotation:** Format-toggle (toggle annotation trên frame 1), Saved (toast annotation), Balance-offline (banner annotation), Logged-out (redirect về Login), Buy-error (annotation trên frame Success).

---

## Flow 7 · Tài khoản

### Tất cả màn hình trong spec

| Screen | Trạng thái từ spec |
|---|---|
| Hồ sơ (SM-024) | Own-Free · Own-Premium · Own-Stats-hidden · Viewed-others · Viewed-stats-hidden · Offline |
| Sửa hồ sơ | Avatar-crop · Display-name · Change-username · DOB-editor |
| Cài đặt (SM-027) | Default · Offline |
| Đổi mật khẩu | Default · Error · Success |
| Ngôn ngữ | Picker |
| Chặn người dùng | Empty |
| Liên kết tài khoản | List · Cannot-unlink-last · Unlink-success |
| Thông báo push (SM-026) | Default · Denied · Queued · Routes |

**Tổng: ~24 trạng thái / 8 loại màn hình**

### Khuyến nghị vẽ (13 frame)

| # | Frame | Ghi chú |
|---|---|---|
| 1 | Hồ sơ — Own Free | Nhãn "Free" + nút "Nâng cấp Premium" + thống kê |
| 2 | Hồ sơ — Own Premium | Nhãn "Premium" + ngày hết hạn; ẩn nút nâng cấp |
| 3 | Hồ sơ — Viewed by others | Không thấy trạng thái gói; thống kê có thể ẩn |
| 4 | Sửa hồ sơ — Avatar crop | Cropper hình vuông 1:1 |
| 5 | Sửa hồ sơ — Thông tin chung | Display name + username + DOB trong 1 màn hình edit |
| 6 | Cài đặt — Default | Menu đầy đủ: bảo mật / cá nhân / quyền riêng tư / nguy hiểm |
| 7 | Đổi mật khẩu | Form; Error annotation; Success annotation |
| 8 | Ngôn ngữ picker | Bottom sheet / màn hình chọn ngôn ngữ |
| 9 | Chặn người dùng — Empty | Danh sách rỗng |
| 10 | Chặn người dùng — Có user | Danh sách + nút bỏ chặn (nếu có nội dung; thiết kế như list thông thường) |
| 11 | Liên kết tài khoản | Danh sách phương thức + trạng thái linked/unlinked |
| 12 | Cài đặt thông báo | Toggle từng loại; Denied state → annotation hướng dẫn vào Settings OS |
| 13 | Xóa tài khoản — Confirm | Modal/màn hình xác nhận + thông báo 7 ngày chờ |

**Bỏ qua / annotation:** Own-Stats-hidden (annotation), Offline states (banner), Cannot-unlink-last (toast annotation trên frame 11), Unlink-success (toast annotation), Queued/Routes (không cần frame riêng — hành vi hệ thống).

---

## Flow 8 · Dịp đặc biệt

### Tất cả màn hình trong spec

| Screen | Trạng thái từ spec |
|---|---|
| Tạo thiệp nhóm (SM-032) | Default · Offline |
| Quản lý thiệp — Host | Draft · Collecting · Closed · Sent · Empty-warning |
| Đóng góp — Contributor | First-time · Already · Closed · Max-reached · No-tem · Guest |
| Người nhận | Open |

**Tổng: ~14 trạng thái / 4 loại màn hình**

### Khuyến nghị vẽ (8 frame)

| # | Frame | Ghi chú |
|---|---|---|
| 1 | Tạo thiệp nhóm | Form: tên dịp + hạn đóng góp (tuỳ chọn) |
| 2 | Host — Collecting | Danh sách đóng góp đang thu thập + nút "Đóng sổ" + link mời |
| 3 | Host — Closed | Danh sách đã đóng + nút "Gửi thiệp" + nút gửi nền tảng |
| 4 | Host — Empty-warning | Alert "Thiệp chưa có đóng góp, vẫn gửi?" |
| 5 | Contributor — First-time | Màn hình đóng góp: chọn tem + ô nhập lời nhắn |
| 6 | Contributor — Already | Hiển thị đóng góp cũ + nút "Chỉnh sửa" |
| 7 | Contributor — Closed | Chỉ-xem đóng góp cũ + label "Đã đóng sổ" |
| 8 | Người nhận — Open (sau animation) | Hiển thị tất cả tem + lời nhắn từng người đóng góp |

**Bỏ qua / annotation:** Offline (banner annotation), Host Draft (gần giống Collecting nhưng không có đóng góp), Max-reached (toast annotation), No-tem (redirect + alert annotation), Guest (redirect đăng nhập), Host Sent (annotation badge trên Closed state).

---

## Tổng kết

| Flow | Trạng thái spec | Frame thiết kế | Giảm |
|---|---|---|---|
| 1 · Khởi đầu | ~30 | 17 | −43% |
| 2 · Tạo tem | ~22 | 13 | −41% |
| 3 · Soạn & Gửi thư | ~20 | 12 | −40% |
| 4 · Nhận & Đọc thư | ~16 | 9 | −44% |
| 5 · Quản lý & Sưu tầm | ~22 | 13 | −41% |
| 6 · Kiếm & tiêu Dấu | ~13 | 7 | −46% |
| 7 · Tài khoản | ~24 | 13 | −46% |
| 8 · Dịp đặc biệt | ~14 | 8 | −43% |
| **Tổng** | **~161** | **92** | **−43%** |

### Thứ tự ưu tiên thiết kế (MVP)

**P0 — Golden path cần có trước:**
- Flow 1: Splash, Onboarding, Login, Register, Home
- Flow 2: Toàn bộ 13 frame (core product)
- Flow 3: Template list, Soạn nội dung, Gửi thư

**P1 — Cần trước khi test:**
- Flow 4: Animation keyframes, Completed state, Inbox
- Flow 7: Profile, Settings
- Flow 1: Verify, Choose username, Avatar

**P2 — Hoàn chỉnh sản phẩm:**
- Flow 5: Album, Chi tiết tem, Bộ tem mẫu
- Flow 6: Chia sẻ tem, Số dư Dấu
- Flow 8: Thiệp nhóm

**P3 — Edge cases / error screens:**
- Tất cả màn hình xác nhận, quota-reached, expired link
- Màn hình chặn người dùng, xóa tài khoản

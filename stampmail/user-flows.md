# StampMail — User Flows

**Cập nhật lần cuối**: 2026-06-29

> Tài liệu này mô tả các **luồng người dùng end-to-end** của app — chuỗi màn hình/hành động mà người dùng đi qua để hoàn thành một mục tiêu. Mỗi bước liên kết tới `spec.md` chi tiết. Đây là góc nhìn "hành trình"; [index.md](index.md) là catalog từng tính năng theo nhóm chức năng.
>
> Bản chi tiết tới từng **màn hình + trạng thái** (Default, Field-error, Offline…) nằm trong [flows/](flows/README.md).

---

## Flow 1 — Khởi đầu (lần đầu mở app)

Cài app → trải nghiệm lần đầu → vào màn hình chính.

1. [Onboarding](specs/003-onboarding.md) — giới thiệu app (SM-003)
2. [Xác thực — Đăng ký / Đăng nhập](specs/001-auth.md) (SM-000)
3. [Màn hình chính (Home)](specs/004-man-hinh-chinh.md) (SM-004)

---

## Flow 2 — Tạo tem

Từ một tấm ảnh đến con tem đã lưu trong Album.

1. [Chụp / Chọn ảnh](specs/005-chup-chon-anh.md) (SM-005)
2. [Bộ lọc màu & Chỉnh ảnh](specs/006-bo-loc-mau.md) (SM-006)
3. [Trang trí tem](specs/007-trang-tri-tem.md) (SM-008)
4. [Viền & Khung tem](specs/008-vien-khung-tem.md) (SM-009)
5. [Xem trước & Lưu tem vào Album](specs/009-luu-tem.md) (SM-010 + SM-011)

→ Sau khi lưu có thể rẽ sang **Flow 6** (Chia sẻ tem → nhận Dấu).

---

## Flow 3 — Soạn & Gửi thư

Từ chọn template đến gửi thư đi qua MXH.

1. [Chọn template thư](specs/010-chon-template-thu.md) (SM-012)
2. [Soạn nội dung thư](specs/011-soan-noi-dung-thu.md) (SM-013)
3. [Đính tem & Kéo thả lên thư](specs/012-dinh-tem-len-thu.md) (SM-014)
4. [Xem trước thư trước khi gửi](specs/013-xem-truoc-thu.md) (SM-015)
5. [Gửi thư qua MXH](specs/014-gui-thu-mxh.md) (SM-016)

→ Cần con tem từ **Flow 2**. Theo dõi trạng thái thư đã gửi ở **Flow 5**.

---

## Flow 4 — Nhận & Đọc thư

Người nhận mở thư qua link (có thể chưa cài app).

1. [Nhận thư qua Link](specs/015-nhan-thu-qua-link.md) (SM-017)
2. [Mở thư & Animation](specs/017-mo-thu-animation.md) (SM-019)
3. [Hộp thư đến (Inbox)](specs/016-hop-thu-den.md) (SM-018)
4. [Trả lời thư](specs/018-tra-loi-thu.md) (SM-020) → quay lại **Flow 3**

---

## Flow 5 — Quản lý thư & sưu tầm

Theo dõi thư và bộ sưu tập tem.

1. [Hộp thư đã gửi & Theo dõi trạng thái](specs/019-hop-thu-da-gui.md) (SM-021)
2. [Album sưu tập tem](specs/020-album-suu-tap.md) (SM-022)
3. [Bộ tem mẫu](specs/029-bo-tem-mau.md) (SM-035)

---

## Flow 6 — Kiếm & tiêu Dấu (Rewards)

Vòng lặp tăng trưởng: chia sẻ / gửi thư → nhận Dấu → mở khóa tính năng.

1. [Chia sẻ tem lên MXH](specs/021-chia-se-tem-mxh.md) (SM-025)
2. [Hệ thống Dấu — Share to Unlock + Chain Unlock](specs/028-he-thong-dau.md) (SM-033)

→ Nguồn Dấu nối với **Flow 2** (chia sẻ sau khi lưu tem) và **Flow 3/4** (gửi thư → người nhận mở → cài app).

---

## Flow 7 — Tài khoản

Hồ sơ và cài đặt.

1. [Hồ sơ người dùng](specs/002-ho-so-nguoi-dung.md) (SM-024)
2. [Cài đặt tài khoản & Quyền riêng tư](specs/023-cai-dat-tai-khoan.md) (SM-027)

---

## Flow 8 — Dịp đặc biệt

1. [Thiệp nhóm (Group Card)](specs/027-thiep-nhom.md) (SM-032) — nhiều người cùng ký một thiệp → gửi qua **Flow 3**.

---

## Tính năng nền (xuyên suốt mọi flow)

Không phải một bước trong hành trình, mà hỗ trợ nền cho toàn app:

- [Thông báo push](specs/022-thong-bao-push.md) (SM-026) — nhắc khi có thư mới, thư được mở, hết hạn mức…

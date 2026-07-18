# StampMail — Giới thiệu project & Quy ước viết spec

**Mô tả**: Ứng dụng di động cho phép người dùng tạo tem thư từ ảnh cá nhân, soạn thư số đính tem, và gửi đến bạn bè qua link chia sẻ trên mạng xã hội.

**Nền tảng**: iOS & Android
**Mô hình kinh doanh**: Freemium (Free + Premium)
**Ngày tạo**: 2026-06-24
**Trạng thái** (soát lại 2026-07-17): Spec đã ổn định (26 spec). **Đang code** — luồng lõi
tạo tem → gửi thư → nhận qua link đã chạy thật end-to-end. Chi tiết:
[e2e-execution-plan.md](e2e-execution-plan.md).
Chặn ra mắt hiện là **credentials + native config**, không phải thiếu tính năng —
xem [blockers.md](blockers.md).

---

## Nguyên tắc viết spec cho StampMail

1. **Phân biệt Free / Premium rõ ràng** trong mỗi BR liên quan đến giới hạn. Dùng bảng khi có nhiều bậc.
2. **Không dùng tên MXH làm điều kiện kỹ thuật** — nêu "nền tảng mạng xã hội được hỗ trợ" hoặc liệt kê tên thương mại khi cần mô tả UX người dùng thấy.
3. **Link thư** chỉ mở 1 lần, hiệu lực 7 ngày — đây là ràng buộc nghiệp vụ quan trọng, phải xuất hiện trong BR của mọi spec liên quan đến gửi/nhận thư.
4. **Người nhận chưa có tài khoản** vẫn đọc được thư trên web — spec nhận thư phải phản ánh điều này.
5. **Animation mở thư** là trải nghiệm cốt lõi — spec mở thư phải mô tả trình tự người dùng nhìn thấy (không mô tả kỹ thuật animation).
6. **Mã SM-NNN** dùng để tham chiếu chéo giữa các spec (không phải mã BR/AC).

## Sơ đồ nhóm tính năng

| Nhóm | Nội dung | Số spec |
|------|----------|---------|
| A — Tài khoản | Đăng ký, đăng nhập, bảo mật, hồ sơ | 4 |
| B — Lần đầu | Onboarding, màn hình chính | 2 |
| C — Tạo tem | Chụp ảnh đến lưu tem hoàn chỉnh | 5 |
| D — Soạn & Gửi thư | Chọn template đến gửi link | 5 |
| E — Nhận & Đọc thư | Nhận link đến trả lời | 5 |
| F — Sưu tầm | Album, bộ tem mẫu | 2 |
| G — Chia sẻ MXH | Chia sẻ tem lên mạng xã hội | 1 |
| H — Hệ thống | Thông báo, cài đặt, Premium, giới hạn | 5 |

## Ưu tiên MVP

- **P0 (MVP bắt buộc)**: SM-005→011 (Tạo tem), SM-016 (Gửi thư), SM-017 (Nhận thư), SM-019 (Mở thư), SM-022 (Album)
- **P1 (thêm ngay sau MVP)**: SM-020, SM-024→026
- **P2 (vận hành)**: Còn lại

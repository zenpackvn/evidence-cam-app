# StampMail — Flows (gộp đầy đủ spec)

**Cập nhật lần cuối**: 2026-06-30

> Mỗi file flow **gộp nguyên nội dung nghiệp vụ** của các spec liên quan (không chỉ link tham chiếu) — đọc một file là đủ cho cả hành trình. Đầu mỗi mục có bảng **màn hình + trạng thái** (Default, Field-error, Offline…), tiếp theo là toàn bộ BR/AC của spec đó.
>
> Nguồn của mỗi mục được ghi `> Nguồn: specs/NNN-….md`. Khi spec gốc thay đổi, chạy lại generator để đồng bộ. Catalog theo nhóm xem [index.md](../index.md); góc nhìn hành trình rút gọn xem [user-flows.md](../user-flows.md).

| # | Flow | File |
|---|------|------|
| 1 | Khởi đầu | [flow-1-khoi-dau.md](flow-1-khoi-dau.md) |
| 2 | Tạo tem | [flow-2-tao-tem.md](flow-2-tao-tem.md) |
| 3 | Soạn & Gửi thư | [flow-3-soan-gui-thu.md](flow-3-soan-gui-thu.md) |
| 4 | Nhận & Đọc thư | [flow-4-nhan-doc-thu.md](flow-4-nhan-doc-thu.md) |
| 5 | Quản lý & Sưu tầm | [flow-5-quan-ly-suu-tam.md](flow-5-quan-ly-suu-tam.md) |
| 6 | Kiếm & tiêu Dấu | [flow-6-kiem-tieu-dau.md](flow-6-kiem-tieu-dau.md) |
| 7 | Tài khoản | [flow-7-tai-khoan.md](flow-7-tai-khoan.md) |
| 8 | Dịp đặc biệt | [flow-8-dip-dac-biet.md](flow-8-dip-dac-biet.md) |

> **Màn chưa chốt layout**: Home (SM-004) và Đính tem & Kéo thả (SM-014) có heading nhưng **chưa có frame layout** — đánh dấu ⚠️ trong flow tương ứng để bước wireframe bổ sung.
>
> Generator: `scratchpad/build_flows.py` (gộp từ `specs/*.md`).

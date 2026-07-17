# Convergence status

**Khởi tạo**: 2026-07-17 · **Baseline**: `fvm flutter analyze` = No issues (3.0s); backend `go build ./...` = clean (blocker A0 đã xử).

Legend status: ⬜ pending · 🔍 verifying · 🔨 building · ✅ done (gate máy pass) · 🚫 blocked · ➖ skipped (ngoài MVP / disable v1)

> "done" chỉ đánh khi gate máy pass thật (analyze + test feature + golden nếu có). Cột "Assess" là khảo sát tĩnh lần đầu (đếm file presentation/data/domain/test), CHƯA phải verify bằng test.

| SM-ID | Product-spec | Feature package | Prio | Assess (pres/data/dom/test) | Status | Note |
|---|---|---|---|---|---|---|
| SM-000 | 001-auth | auth | P1 | 27/25/8/8 | 🔍 | Presentation dày, 8 test. Verify test pass + AC coverage |
| SM-024 | 002-ho-so-nguoi-dung | profile | P2 | 17/0/0/4 | ⬜ | UI-only (data qua shared_contracts) |
| SM-003 | 003-onboarding | onboarding | P2 | 3/1/0/2 | ⬜ | |
| SM-004 | 004-man-hinh-chinh | home | P2 | 5/0/1/3 | ⬜ | |
| SM-005 | 005-chup-chon-anh | stamp_creator | P0 | 15/1/3/4 | 🔍 | stamp_creator gộp SM-005/006/008/009/010/011 |
| SM-006 | 006-bo-loc-mau | stamp_creator | P0 | ↑ | 🔍 | |
| SM-008 | 007-trang-tri-tem | stamp_creator | P0 | ↑ | 🔍 | |
| SM-009 | 008-vien-khung-tem | stamp_creator | P0 | ↑ | 🔍 | 4 viền (D6): 3 Free / 1 khóa Premium |
| SM-010+011 | 009-luu-tem | stamp_creator | P0 | ↑ | 🔍 | Lưu tem trừ quota 30/tháng (SM-030) |
| SM-012 | 010-chon-template-thu | letters | P2 | 17/13/5/3 | ⬜ | Free 3 template (D15) |
| SM-013 | 011-soan-noi-dung-thu | letters | P2 | ↑ | ⬜ | |
| SM-014 | 012-dinh-tem-len-thu | letters | P2 | ↑ | ⬜ | |
| SM-015 | 013-xem-truoc-thu | letters | P2 | ↑ | ⬜ | |
| SM-016 | 014-gui-thu-mxh | letters | P0 | ↑ | ✅ | 8 nền tảng khớp AC-07 (đã sửa drift enum). Backend: single-use/expiry/quota/attribution test pass. Gate: analyze+test+build apk(dev) OK |
| SM-017 | 015-nhan-thu-qua-link | letter_inbox / web_letter | P0 | 5/7/2/2 | ✅ | Đã GỠ save-stamp (vi phạm BR-05). App 4-beat reveal + alreadyOpened/expired/invalid. Backend single-use/expiry test pass. Gate OK |
| SM-019 | 017-mo-thu-animation | letter_inbox | P0 | ↑ | ✅ | Animation 4 bước khớp BR-01. Nút chỉ còn Trả lời (BR-03). Gate OK |
| SM-020 | 018-tra-loi-thu | letter_inbox / letters | P1 | ↑ | ⬜ | |
| SM-021 | 019-hop-thu-da-gui | letters | P2 | ↑ | ⬜ | Recreate link cho thư tồn tại = miễn quota (D11) |
| SM-022 | 020-album-suu-tap | album | P0 | 7/28/6/2 | 🔨 | ĐÃ SỬA BR-01/03 (gỡ nhãn "Nhận"/"Nhận từ"), BR-02 danh sách phẳng, BR-05 sort, BR-09 xóa-xác-nhận OK. **GAP CÒN MỞ**: BR-04 toggle lưới/danh sách (chỉ có grid), BR-06/08 tên tem + đổi tên ≤30 (Stamp entity + backend DTO thiếu field `name` → gap full-stack), BR-07 share tem (dẫn SM-025). Xem note dưới |
| SM-035 | 029-bo-tem-mau | stamp_creator? | P1 | — | ⬜ | Tem mẫu — tất cả free (SM-033 gỡ) |
| SM-025 | 021-chia-se-tem-mxh | letters? / stamp_creator | P1 | — | ⬜ | 5 nền tảng share tem (khác 8 nền tảng link) |
| SM-026 | 022-thong-bao-push | notifications | P1 | 11/15/10/4 | ⬜ | 3 loại: letter_opened/quota_low/letter_received(reply) (D12) |
| SM-027 | 023-cai-dat-tai-khoan | profile / settings | P2 | — | ⬜ | SettingsScreen mounted ở router |
| SM-028 | 024-nang-cap-premium | premium | ⏸️ | 0/7/0/0 | ➖ | D17 disable v1 — khóa không CTA mua |
| SM-029 | 025-quan-ly-premium | premium | ⏸️ | ↑ | ➖ | D17 disable v1 |
| SM-030 | 026-gioi-han-thang | (quota) backend + premium/home | P2 | — | ⬜ | Quota atomic, reset theo tz thiết bị (D5) |

## Loại khỏi MVP (không build) — theo master-plan §3.1 + index.md

SM-007 (xóa nền AI), SM-033 (Dấu/Rewards), SM-023 (Series), SM-031 (Time Capsule), SM-032 (Group Card), SM-034 (tem giới hạn), SM-036 (nháp). Package legacy template `bookmarks`/`collections` sẽ gỡ (D9) — không thuộc SM-ID nào.

## GAP full-stack còn mở — cần quyết định scope (không kẹt, là công việc lớn)

- **SM-022 BR-06/BR-08 — Tên tem + đổi tên (≤30 ký tự)**: `Stamp` entity (client) và stamp DTO (backend) đều KHÔNG có field `name`; backend stamp table chưa lưu name; chưa có PATCH `/api/sm/stamps/{id}`. Cần: thêm `name` xuyên stamp domain client + DTO + migration backend + endpoint rename + UI đổi tên trong detail. Khối full-stack, làm ở phiên sau.
- **SM-022 BR-04 — Toggle chế độ lưới/danh sách**: album_screen mới chỉ render grid (crossAxisCount 3). Cần thêm list mode + nút chuyển. UI-only, làm được không cần backend.
- **SM-022 BR-07 — Chia sẻ tem từ chi tiết**: detail screen chưa có nút share (dẫn SM-025). Phụ thuộc SM-025 (P1, chưa verify).

## Nhật ký verify

- 2026-07-17: Khởi tạo. Baseline analyze sạch, backend build sạch (511 test).
- 2026-07-17: **SM-016 ✅** — sửa drift 8 nền tảng share cho khớp AC-07. Commit 7014c6f.
- 2026-07-17: **SM-017/019 ✅** — gỡ save-stamp (vi phạm BR-05/BR-03) xuyên stack + gỡ dep feature_album. Commit 4a44ae7.
- 2026-07-17: **SM-022 🔨** — gỡ nhãn nguồn (BR-01/03). Commit b15da2a. Còn gap BR-04/06/07/08 (xem trên).
- Gate cuối phiên: `analyze` sạch · root 38 + packages 515 test · golden 8 · `build apk --debug --flavor dev` OK. (staging flavor build đỏ vì google-services.json thiếu client `.staging` — blocker config có sẵn, không do converge.)

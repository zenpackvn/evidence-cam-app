# Convergence status

**Khởi tạo**: 2026-07-17 · **Baseline**: `fvm flutter analyze` = No issues (3.0s); backend `go build ./...` = clean (blocker A0 đã xử).

Legend status: ⬜ pending · 🔍 verifying · 🔨 building · ✅ done (gate máy pass) · 🚫 blocked · ➖ skipped (ngoài MVP / disable v1)

> "done" chỉ đánh khi gate máy pass thật (analyze + test feature + golden nếu có). Cột "Assess" là khảo sát tĩnh lần đầu (đếm file presentation/data/domain/test), CHƯA phải verify bằng test.

| SM-ID | Product-spec | Feature package | Prio | Assess (pres/data/dom/test) | Status | Note |
|---|---|---|---|---|---|---|
| SM-000 | 001-auth | auth | P1 | 27/25/8/8 | ✅ | 60 test pass. Verify: password<6 (BR-07/D7), username 3-30 (BR-04), forgot/verify LINK-based TTL 30ph resend 60s không OTP (BR-02/12), không tiết lộ email tồn tại, backend lockout 5 lần/15ph (BR-11). Không gap |
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
| SM-020 | 018-tra-loi-thu | letter_inbox / letters | P1 | ↑ | ✅ | Nút Trả lời khả dụng (BR-03/05 gửi qua link). BỔ SUNG BR-01 prefill người gửi: backend publicLetter trả sender_name (resolve username), client mang qua ReceivedLetter→onReply→template list hiển thị "Trả lời — Gửi tới [tên]". BR-04 thư độc lập/không threading giữ nguyên. Gate OK |
| SM-021 | 019-hop-thu-da-gui | letters | P2 | ↑ | ⬜ | Recreate link cho thư tồn tại = miễn quota (D11) |
| SM-022 | 020-album-suu-tap | album | P0 | 7/28/6/2 | ✅ | BR-01/02/03/05/09 OK. **ĐÃ BỔ SUNG full-stack**: BR-08 tên tem + đổi tên ≤30 (field `name` xuyên backend domain/SQLite/PATCH + client entity/DTO/sync-adapter/repo/dialog), BR-06 hiển thị tên, BR-04 toggle lưới/danh sách, BR-07 attach-to-letter. Gate: backend+analyze+test+build OK. Còn lại chỉ BR-07 điều hướng preselect stamp vào composer (khi composer nhận initial stamp — thuộc C3/letters) |
| SM-035 | 029-bo-tem-mau | album (sample_stamps) | P1 | — | ✅ | BUILD TỪ ĐẦU (chưa có gì). Backend: domain SampleStamp + themes, SampleCatalog in-memory, GET /api/sm/sample-stamps[?theme]. Client: entity/DTO/remote/repo/cubit + browse screen (theme chips, grid Mới/saved badge, detail pinch-zoom + Lưu). Dedupe qua StampInput.id (BR-03/AC-05), free (BR-05). Route /samples từ nút "Tem mẫu" trong Album. Gate OK |
| SM-025 | 021-chia-se-tem-mxh | album (share_stamp) | P1 | — | 🔨 | BUILD TỪ ĐẦU. Mức 1 (chỉ tem) đầy đủ: layout 9:16↔1:1 toggle (BR-04), watermark cưỡng bức baked-in PNG (BR-06/AC-03), capture RepaintBoundary→toImage, native share sheet qua SharePlus (BR-07). Nút Chia sẻ ở stamp detail. Test watermark/toggle/share-PNG. **CÒN MỞ**: Mức 2/3 (trích dẫn/toàn văn thư — cần letter content, thuộc reveal share path không phải Album), BR-05 lưu gallery (cần dep `gal` + iOS photo permission config), BR-03 cảnh báo lộ nội dung (chỉ khi có Mức 2/3). Gate OK |
| SM-026 | 022-thong-bao-push | notifications + app shell + backend | P1 | 11/15/10/4 | 🔨 | ĐÃ CÓ: FCM service (permission BR-03, token, foreground/bg/terminated), settings 3 toggle (BR-02 UI, local-only), letter_opened push. BỔ SUNG: quota_low push backend (BR-01.3/AC-04, once-per-cross), tap→route theo kind (BR-04/AC-03: letter_opened→sent, letter_received→reveal, quota_low→settings). **CÒN MỞ**: letter_received push (cần device token store + biết uid — D12), persist toggle lên server (BR-02 mới local). Gate OK |
| SM-027 | 023-cai-dat-tai-khoan | profile / settings | P2 | — | ⬜ | SettingsScreen mounted ở router |
| SM-028 | 024-nang-cap-premium | premium | ⏸️ | 0/7/0/0 | ➖ | D17 disable v1 — khóa không CTA mua |
| SM-029 | 025-quan-ly-premium | premium | ⏸️ | ↑ | ➖ | D17 disable v1 |
| SM-030 | 026-gioi-han-thang | (quota) backend + premium/home | P2 | — | ⬜ | Quota atomic, reset theo tz thiết bị (D5) |

## Loại khỏi MVP (không build) — theo master-plan §3.1 + index.md

SM-007 (xóa nền AI), SM-033 (Dấu/Rewards), SM-023 (Series), SM-031 (Time Capsule), SM-032 (Group Card), SM-034 (tem giới hạn), SM-036 (nháp). Package legacy template `bookmarks`/`collections` sẽ gỡ (D9) — không thuộc SM-ID nào.

## GAP full-stack còn mở — cần quyết định scope (không kẹt, là công việc lớn)

- **SM-025 Mức 2/3 + gallery save**: Mức 2 (tem + 1 dòng trích dẫn) và Mức 3 (tem + toàn văn thư) cần **letter content** — share tem từ Album chỉ có tem, không có context thư, nên Mức 2/3 phải làm ở luồng share từ màn đọc thư (reveal), không phải Album. BR-03 cảnh báo lộ nội dung chỉ áp khi có Mức 2/3. BR-05 lưu gallery cần thêm dep `gal` + cấu hình iOS `NSPhotoLibraryAddUsageDescription`. Làm riêng.
- **SM-025/backend đơn vị quota D11**: backend hiện trừ quota ở `CreateLink`; D11 chốt phải trừ ở cấp TẠO THƯ (nhiều link/1 thư không trừ thêm). Chưa verify/sửa — để khi rà lại letters/gửi.
- **SM-026 letter_received push + device token store (A11/D4)**: loại push thứ 3 cần bảng `device_tokens` + endpoint register/unregister + `MulticastMessage` + biết uid người nhận (D12: chỉ reply). Khối lớn, làm riêng. Hiện push qua topic (letter_opened) + quota_low đã chạy.
- **SM-026 persist notification toggle lên server (BR-02)**: settings screen mới toggle local state (`_values`), chưa lưu server nên tắt loại chưa thực sự chặn push phía server. Cần endpoint lưu preference + backend đọc trước khi push.

## Nhật ký verify

- 2026-07-17: Khởi tạo. Baseline analyze sạch, backend build sạch (511 test).
- 2026-07-17: **SM-016 ✅** — sửa drift 8 nền tảng share cho khớp AC-07. Commit 7014c6f.
- 2026-07-17: **SM-017/019 ✅** — gỡ save-stamp (vi phạm BR-05/BR-03) xuyên stack + gỡ dep feature_album. Commit 4a44ae7.
- 2026-07-17: **SM-022 🔨** — gỡ nhãn nguồn (BR-01/03). Commit b15da2a.
- 2026-07-17: **SM-022 ✅** — bổ sung full-stack rename (BR-08) + grid/list (BR-04) + tên tem (BR-06) + attach (BR-07). Backend commit 283dcfd, flutter commit 145657e. API contract cập nhật PATCH `/api/sm/stamps/{id}` + field `name`.
- 2026-07-17: **SM-000 ✅** — verify auth (60 test). Password<6/username 3-30/link-verify không OTP/lockout 5×15ph đều khớp. Không gap, không đổi code.
- 2026-07-17: **SM-020 ✅** — bổ sung BR-01 prefill người gửi (full-stack sender_name). Backend commit 967c9e0, flutter commit 2a3a59a.
- 2026-07-17: **SM-035 ✅** — build từ đầu bộ tem mẫu (backend catalog endpoint + client browse/save). Backend commit 41860e4, flutter commit 5d1708e.
- 2026-07-17: **SM-026 🔨** — quota_low push (backend 10677b0) + tap→route theo kind (flutter 639412d). letter_received + device token store + persist toggle còn mở (xem trên).
- 2026-07-17: **SM-025 🔨** — build từ đầu share-tem Mức 1 (layout+toggle+watermark+share sheet). Flutter commit a855c45. Mức 2/3 + gallery save (`gal`) còn mở.
- Gate cuối phiên: backend build+vet+test(race) sạch · `analyze` sạch · root 38 + packages 528 test · golden 8 · `build apk --debug --flavor dev` OK. (staging flavor build đỏ vì google-services.json thiếu client `.staging` — blocker config có sẵn, không do converge.)

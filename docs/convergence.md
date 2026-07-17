# Convergence status

**Khởi tạo**: 2026-07-17 · **Baseline**: `fvm flutter analyze` = No issues (3.0s); backend `go build ./...` = clean (blocker A0 đã xử).

Legend status: ⬜ pending · 🔍 verifying · 🔨 building · ✅ done (gate máy pass) · 🚫 blocked · ➖ skipped (ngoài MVP / disable v1)

> "done" chỉ đánh khi gate máy pass thật (analyze + test feature + golden nếu có). Cột "Assess" là khảo sát tĩnh lần đầu (đếm file presentation/data/domain/test), CHƯA phải verify bằng test.

| SM-ID | Product-spec | Feature package | Prio | Assess (pres/data/dom/test) | Status | Note |
|---|---|---|---|---|---|---|
| SM-000 | 001-auth | auth | P1 | 27/25/8/8 | ✅ | 60 test pass. Verify: password<6 (BR-07/D7), username 3-30 (BR-04), forgot/verify LINK-based TTL 30ph resend 60s không OTP (BR-02/12), không tiết lộ email tồn tại, backend lockout 5 lần/15ph (BR-11). Không gap |
| SM-024 | 002-ho-so-nguoi-dung | profile | P2 | 17/0/0/4 | 🔨 | Profile package = **presentation-only** (không data/domain). ĐÃ SỬA: BR-10/AC-12 hiển thị ngày hết hạn Premium. Stats (BR-04) OK. **GAP cần data layer+backend (ngoài package)**: BR-02 sửa tên, BR-03 giới hạn đổi username, BR-06 ngày sinh (cần PATCH /api/sm/me), avatar upload, offline. 18 test pass |
| SM-003 | 003-onboarding | onboarding | P2 | 3/1/0/2 | ⬜ | |
| SM-004 | 004-man-hinh-chinh | home | P2 | 5/0/1/3 | ✅ | Home đọc ĐÚNG domain StampMail (recentStamps từ album offline-first + recentLetters từ letters.sent, không phải bookmark/collection — cảnh báo master-plan đã lỗi thời). 10 test pass. Sửa platform label drift khớp 8 nền tảng SM-016. Gate OK |
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
| SM-021 | 019-hop-thu-da-gui | letters | P2 | ↑ | ✅ | ĐÃ CÓ: list + trạng thái link (BR-01/02/03). BỔ SUNG: recreateLink cho link hết hạn (BR-04) + guard chặn cho thư đã đọc (BR-05), nút "Tạo link mới" chỉ hiện ở expired. Test recreate/block. **D11 đã áp**: recreate KHÔNG trừ quota (quota tính 1 lần/thư ở link đầu) — mâu thuẫn BR-04-as-written đã resolve theo D11. Gate OK |
| SM-022 | 020-album-suu-tap | album | P0 | 7/28/6/2 | ✅ | BR-01/02/03/05/09 OK. **ĐÃ BỔ SUNG full-stack**: BR-08 tên tem + đổi tên ≤30 (field `name` xuyên backend domain/SQLite/PATCH + client entity/DTO/sync-adapter/repo/dialog), BR-06 hiển thị tên, BR-04 toggle lưới/danh sách, BR-07 attach-to-letter. Gate: backend+analyze+test+build OK. Còn lại chỉ BR-07 điều hướng preselect stamp vào composer (khi composer nhận initial stamp — thuộc C3/letters) |
| SM-035 | 029-bo-tem-mau | album (sample_stamps) | P1 | — | ✅ | BUILD TỪ ĐẦU (chưa có gì). Backend: domain SampleStamp + themes, SampleCatalog in-memory, GET /api/sm/sample-stamps[?theme]. Client: entity/DTO/remote/repo/cubit + browse screen (theme chips, grid Mới/saved badge, detail pinch-zoom + Lưu). Dedupe qua StampInput.id (BR-03/AC-05), free (BR-05). Route /samples từ nút "Tem mẫu" trong Album. Gate OK |
| SM-025 | 021-chia-se-tem-mxh | album (share_stamp) | P1 | — | ✅ | ĐẦY ĐỦ. Mức 1/2/3 (BR-02): ShareStampScreen nhận optional letterText → level selector + cảnh báo lộ nội dung (BR-03) + composite text vào post. Toggle 9:16↔1:1 (BR-04), watermark baked-in (BR-06/AC-03), share sheet (BR-07). Gallery save (BR-05): GallerySaveService (gal) + nút Lưu + snackbar. Share từ Album (chỉ tem) VÀ từ màn đọc thư (Mức 2/3 với letter text). ShareStampScreen dùng stampImageUrl (không phụ thuộc entity). Test level chips/warning/watermark/share-PNG. Gate OK |
| SM-026 | 022-thong-bao-push | notifications + app shell + backend | P1 | 11/15/10/4 | ✅ | ĐẦY ĐỦ 3 loại push end-to-end: letter_opened, quota_low (once-per-cross), letter_received (reply threading: publicLetter sender_uid→ReceivedLetter→onReply→composer→LetterInput→reply_to_uid→push once-per-letter). Per-type FCM topic user_<uid>_<kind>; toggle BR-02 = subscribe/unsubscribe + persist prefs (không local nữa); subscribe khi login. Tap→route theo kind (BR-04). Backend tests + composer thread test. Gate OK |
| SM-027 | 023-cai-dat-tai-khoan | profile / settings | P2 | — | 🔨 | UI đầy đủ: đổi mật khẩu, đăng xuất, xóa TK 7 ngày + huỷ, ngôn ngữ, âm thanh (default bật), cài đặt thông báo 3 toggle. **GAP ngoài package**: logout-single vs logout-all (BR-02 vs BR-03, cần backend token revoke), language persist (locale store), pending-delete endpoint, offline chặn thao tác bảo mật. UI-side pass |
| SM-028 | 024-nang-cap-premium | premium | ⏸️ | 0/7/0/0 | ➖ | D17 disable v1 — khóa không CTA mua |
| SM-029 | 025-quan-ly-premium | premium | ⏸️ | ↑ | ➖ | D17 disable v1 |
| SM-030 | 026-gioi-han-thang | (quota) backend + premium/home | P2 | — | ⬜ | Quota atomic, reset theo tz thiết bị (D5) |

## Loại khỏi MVP (không build) — theo master-plan §3.1 + index.md

SM-007 (xóa nền AI), SM-033 (Dấu/Rewards), SM-023 (Series), SM-031 (Time Capsule), SM-032 (Group Card), SM-034 (tem giới hạn), SM-036 (nháp). Package legacy template `bookmarks`/`collections` sẽ gỡ (D9) — không thuộc SM-ID nào.

## GAP full-stack còn mở — cần quyết định scope (không kẹt, là công việc lớn)

- **Quota theo D11** (SM-016/backend): backend hiện trừ quota ở `CreateLink`; D11 chốt phải trừ ở cấp TẠO THƯ (nhiều link/1 thư không trừ thêm). Chưa verify/sửa — để khi rà lại letters/gửi.
- **SM-026 device token store (nâng cấp tùy chọn)**: hiện dùng per-type topic (đủ cho BR-02 toggle + 3 loại push). Chỉ cần token store nếu muốn delivery receipt / targeting chính xác từng thiết bị — không bắt buộc cho MVP.
- **SM-026 notification toggle — persist server-side**: hiện lưu prefs local + subscribe/unsubscribe FCM topic (đủ chặn push phía FCM). Nếu muốn preference đọc được từ backend (đa thiết bị đồng bộ) thì thêm endpoint — không bắt buộc.

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
- 2026-07-17: **SM-025 🔨** — build từ đầu share-tem Mức 1 (layout+toggle+watermark+share sheet). Flutter commit a855c45.
- 2026-07-17: **SM-026 ✅ (full)** — letter_received push + per-type topic + reply threading full-stack + persist toggle. Backend 2efb59a/69dfa3a, flutter 862f95f.
- 2026-07-17: **SM-025 ✅ (full)** — Mức 2/3 (level selector + cảnh báo BR-03) + gallery save (gal) + share từ màn đọc thư. Flutter commit 1184712.
- 2026-07-17: **P2 bắt đầu.** SM-004 Home ✅ (verify + fix label, commit be88411). SM-021 Sent box ✅ (recreate link BR-04/05, commit bcb70bb).
- Gate cuối phiên: backend build+vet+test(race) sạch · `analyze` sạch · root 38 + packages 533 test · golden 8 · `build apk --debug --flavor dev` OK. (staging flavor build đỏ vì google-services.json thiếu client `.staging` — blocker config có sẵn, không do converge.)

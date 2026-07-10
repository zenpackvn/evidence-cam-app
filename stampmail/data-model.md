# StampMail — Data Model & Backend Logic

**Cập nhật lần cuối**: 2026-07-07
**Backend**: Go server (mở rộng `simple_backend_server`), SQLite (dev) / Postgres (prod)
**Căn cứ**: 29 spec, [tech-stack.md](tech-stack.md) TD-001→012

> Nguồn sự thật cho toàn bộ bảng, quan hệ, và logic nghiệp vụ server-side. Mọi cộng/trừ Dấu, quota, link-1-lần đều **server-side** (client chỉ đọc). Bám pattern Go hiện có: mỗi entity có `domain` struct + repository interface, các bảng sync dùng `rev` (per-owner, tăng dần) + `deleted_at` (tombstone) như bookmark/collection.

---

## 0. Quy ước chung

- **ID**: TEXT, random opaque (IDGenerator hiện có).
- **Thời gian**: DATETIME UTC.
- **Sync (offline-first)**: bảng client cần đồng bộ (stamps, albums, letters_received, seals_balance cache) mang `rev INTEGER` + `deleted_at DATETIME NULL`. Client kéo delta bằng `rev > cursor`.
- **owner_id**: `uid` từ Firebase ID token (TD-002). Bảng `users.id` = Firebase `uid` (không tự sinh id user nữa — dùng uid).
- **Tiền/thưởng**: mọi thay đổi Dấu ghi vào `seal_ledger` (append-only); số dư = tổng ledger (hoặc cache có kiểm chứng). Không update trực tiếp balance từ client.

---

## 1. Bảng & quan hệ

### users (mở rộng bảng hiện có)
Danh tính từ Firebase; hồ sơ nghiệp vụ ở đây.

| Cột | Kiểu | Ghi chú |
|---|---|---|
| id | TEXT PK | = Firebase `uid` |
| username | TEXT UNIQUE | 3–30 ký tự (BR-04 SM-000) |
| email | TEXT | từ Firebase, có thể NULL (BR-28 social không email) |
| avatar_url | TEXT NULL | |
| plan | TEXT | `free` \| `premium`, mặc định `free` (BR-05) |
| email_verified | BOOLEAN | (BR-02) |
| created_at | DATETIME | |

> Bảng `refresh_tokens` hiện có: **giữ** nếu dùng phương án B (JWT-Go); **bỏ qua** khi dùng Firebase Auth (token do Firebase quản). Xem TD-002.

### usernames
Bảo đảm username duy nhất qua unique constraint (thay vì check-then-insert).

| Cột | Kiểu | Ghi chú |
|---|---|---|
| username | TEXT PK | lowercase |
| user_id | TEXT | → users.id |

### auth_lockout
Khoá 5-lần/15-phút (BR-11 SM-000).

| Cột | Kiểu | Ghi chú |
|---|---|---|
| email | TEXT PK | (hoặc uid) |
| failed_count | INTEGER | |
| locked_until | DATETIME NULL | |
| updated_at | DATETIME | |

### stamps (sync)
Tem — tự tạo hoặc nhận. Ảnh trên Firebase Storage, DB giữ URL.

| Cột | Kiểu | Ghi chú |
|---|---|---|
| id | TEXT PK | |
| owner_id | TEXT | |
| image_url | TEXT | tem đã render (PNG) |
| thumb_url | TEXT NULL | |
| source | TEXT | `created` \| `received` (BR-01 SM-022) |
| sender_name | TEXT NULL | khi `received` |
| sender_uid | TEXT NULL | |
| created_at | DATETIME | ngày tạo/nhận (BR-08 SM-011) |
| rev, deleted_at | sync | |

> Metadata chỉnh sửa (filter, sticker, viền) **không lưu server** — tem là ảnh đã render phẳng. Chỉnh lại = tạo tem mới. (Đơn giản hoá; nếu sau cần "chỉnh lại tem cũ" thì thêm `recipe_json`.)

### albums (sync)
Album tùy chỉnh (BR-06 SM-022). Album mặc định Tất cả/Tự tạo/Nhận được **không phải row** — suy ra từ `stamps.source`.

| Cột | Kiểu | Ghi chú |
|---|---|---|
| id | TEXT PK | |
| owner_id | TEXT | |
| name | TEXT | ≤30 ký tự |
| stamp_ids | TEXT (JSON) | mảng id; 1 tem nhiều album (BR-07) |
| created_at | DATETIME | |
| rev, deleted_at | sync | |

### letters
Thư đã soạn (nội dung + tem đính). Nguồn cho link.

| Cột | Kiểu | Ghi chú |
|---|---|---|
| id | TEXT PK | |
| sender_uid | TEXT | |
| content_json | TEXT | template, text, style, màu giấy, kẻ dòng, sticker (SM-013) |
| stamp_ids | TEXT (JSON) | ≤3 tem (BR-03 SM-014) |
| created_at | DATETIME | |
| rev, deleted_at | sync | (để "hộp thư đã gửi" SM-021) |

### letter_links ⭐ (logic cốt lõi — TD-006)
Mỗi người nhận = 1 link (BR-01 SM-016). Link 1-lần / 7-ngày.

| Cột | Kiểu | Ghi chú |
|---|---|---|
| id | TEXT PK | = token trong URL |
| letter_id | TEXT | → letters.id |
| sender_uid | TEXT | |
| platform | TEXT NULL | nền tảng gửi (BR-04) — chỉ để thống kê |
| created_at | DATETIME | |
| expires_at | DATETIME | = created_at + 7 ngày (BR-03) |
| opened_by | TEXT NULL | uid \| `"anonymous"` \| NULL (chưa mở) |
| opened_at | DATETIME NULL | |
| read_seal_awarded | BOOLEAN | đã trao 15📮 cho người gửi chưa (idempotent BR-06 SM-019) |

**Trạng thái khi mở** (transaction):
- `opened_by IS NULL` && `now < expires_at` → cho mở, set `opened_by`+`opened_at`, trả nội dung.
- `opened_by IS NOT NULL` → "đã đọc" (AC-03 SM-016).
- `now >= expires_at` → "hết hạn" (AC-05).

### seal_ledger ⭐ (append-only — nguồn sự thật số Dấu)
Mọi cộng/trừ Dấu (SM-033).

| Cột | Kiểu | Ghi chú |
|---|---|---|
| id | TEXT PK | |
| user_id | TEXT | người nhận Dấu |
| amount | INTEGER | +/- (âm khi tiêu) |
| reason | TEXT | `share`\|`send`\|`opened`\|`install`\|`unlock_sticker`\|`unlock_border`\|`unlock_template_stamp`\|`purchase` |
| ref_id | TEXT NULL | id liên quan (letter_link, stamp pack...) — chống trùng |
| created_at | DATETIME | |

**Số dư** = `SUM(amount) WHERE user_id`. Cache ở `users.seals_balance` (cập nhật cùng transaction) để đọc nhanh + offline (BR-16).

### seal_limits
Đếm hạn mức Dấu theo chu kỳ.

| Cột | Kiểu | Ghi chú |
|---|---|---|
| user_id | TEXT | |
| kind | TEXT | `share_weekly` (cap 3/tuần BR-06) \| `install_monthly` (cap 5/tháng BR-10) |
| period | TEXT | mốc chu kỳ, vd `2026-W28` \| `2026-07` |
| count | INTEGER | |
| PK | (user_id, kind, period) | |

### unlocks (sync)
Item đã mở vĩnh viễn bằng Dấu (BR-11/12/13 SM-033).

| Cột | Kiểu | Ghi chú |
|---|---|---|
| user_id | TEXT | |
| item_type | TEXT | `sticker_pack`\|`border`\|`template_stamp` |
| item_id | TEXT | id bộ sticker / kiểu viền / tem mẫu |
| unlocked_at | DATETIME | |
| PK | (user_id, item_type, item_id) | |

### quota_monthly
Hạn mức tháng Free (SM-030): 30 tem, 10 thư.

| Cột | Kiểu | Ghi chú |
|---|---|---|
| user_id | TEXT | |
| period | TEXT | `2026-07` |
| stamps_saved | INTEGER | cap 30 (BR-06 SM-011) |
| letters_sent | INTEGER | cap 10 (BR-08 SM-016) |
| PK | (user_id, period) | |

> Premium bỏ qua check. Reset = period mới (không cần job xoá; period khác = count 0).

### referrals
Ghi nhận cài app từ link (BR-09/11 SM-016) — AppsFlyer postback → server.

| Cột | Kiểu | Ghi chú |
|---|---|---|
| new_user_uid | TEXT PK | tài khoản mới |
| referrer_uid | TEXT | người giới thiệu |
| link_id | TEXT NULL | letter_link nguồn |
| created_at | DATETIME | |
| seal_awarded | BOOLEAN | đã trao 50📮 chưa (cap 5/tháng) |

### entitlements
Trạng thái Premium (RevenueCat webhook → server, TD-007).

| Cột | Kiểu | Ghi chú |
|---|---|---|
| user_id | TEXT PK | |
| is_premium | BOOLEAN | |
| product_id | TEXT NULL | tháng/năm |
| expires_at | DATETIME NULL | |
| updated_at | DATETIME | |

### notifications (bảng hiện có — tái dùng)
Push 5 loại (SM-026). Giữ nguyên schema, thêm `type` values mới.

---

## 2. Logic nghiệp vụ server-side (service layer)

### Link thư (LetterLinkService)
- **CreateLink(letterID, senderUID, platform)** → kiểm quota `letters_sent < 10` (Free); tạo `letter_links` (expires +7d); **+5📮** ghi ledger (`send`); tăng quota. (BR-08/10 SM-016)
- **OpenLink(linkID, viewerUID?)** → transaction:
  1. Lock row; nếu `opened_by != NULL` → trả `already_read`; nếu hết hạn → `expired`.
  2. Set `opened_by`, `opened_at`.
  3. Nếu chưa `read_seal_awarded`: **+15📮** cho `sender_uid` (`opened`), set flag. (BR-06 SM-019)
  4. Push FCM cho người gửi "đã mở thư". (BR-07 SM-016)
  5. Trả nội dung thư (letter + stamps).

### Dấu (SealService)
- **AwardShare(uid)** → cap `share_weekly < 3` tuần này; nếu còn: **+10📮** (`share`), tăng limit; nếu hết: no-op + trả "đã đạt giới hạn". (BR-05/06 SM-033)
- **AwardInstall(referrerUID, newUID, linkID)** → chỉ khi new user thật + `install_monthly < 5`: **+50📮** (`install`), set `referrals.seal_awarded`, push. (BR-10)
- **Spend(uid, itemType, itemId, cost)** → transaction: kiểm balance ≥ cost; nếu đủ: ghi `unlocks` + **−cost📮** (`unlock_*`); nếu thiếu: trả `insufficient` + số thiếu. (BR-11/12/13/14)
- **Purchase(uid, pack)** → sau IAP consumable verify: **+N📮** (`purchase`). (BR-15)
- **Balance(uid)** = users.seals_balance (đồng bộ với ledger).

### Quota (QuotaService)
- **CheckAndIncStamp(uid)** / **CheckAndIncLetter(uid)** → Premium: luôn OK; Free: kiểm `< cap` period hiện tại, tăng nếu OK, else `quota_exceeded`. (SM-030)

### Entitlement (EntitlementService)
- **HandleRevenueCatWebhook(event)** → cập nhật `entitlements` + `users.plan`. (TD-007)
- **IsPremium(uid)** → đọc entitlements (cache client cho offline BR-08 SM-006).

### Auth bổ sung (AuthService mở rộng)
- **VerifyFirebaseToken(idToken)** → uid (Firebase Admin SDK). Middleware.
- **EnsureUser(uid, email)** → tạo users row nếu chưa có (lần đầu đăng nhập).
- **ClaimUsername(uid, username)** → insert `usernames` (unique) + set users.username. Trùng → `username_taken`. (BR-04, SM Choose Username)
- **RecordFailedLogin / CheckLockout(email)** → auth_lockout. (BR-11)

---

## 3. REST endpoints (transport)

Tất cả (trừ open-link công khai) qua `authMiddleware` (verify Firebase ID token).

```
POST   /api/auth/ensure-user           # sau đăng nhập Firebase lần đầu
POST   /api/auth/claim-username
GET    /api/auth/me

GET    /api/stamps        /api/stamps/{id}   POST /api/stamps   DELETE ...   # +sync ?since=rev
GET    /api/albums ...    (CRUD + sync)
POST   /api/stamps/{id}/save            # lưu tem (check quota 30/tháng)

POST   /api/letters                     # tạo thư
POST   /api/letters/{id}/links          # tạo link + +5📮  (body: platform)
GET    /api/sent                        # hộp thư đã gửi (SM-021)

GET    /public/letter/{linkId}          # CÔNG KHAI — trang web xem thư gọi (OpenLink)
                                        # không auth; trả nội dung hoặc already_read/expired

GET    /api/inbox                        # thư đã nhận (SM-018)
GET    /api/seals                        # số dư + lịch sử
POST   /api/seals/share                  # +10📮 (cap tuần)
POST   /api/seals/spend                  # tiêu Dấu mở item
POST   /api/seals/purchase               # sau IAP

POST   /api/webhooks/revenuecat          # entitlement (verify signature)
POST   /api/webhooks/appsflyer           # referral install → +50📮
POST   /api/webhooks/... (internal)

GET    /api/entitlement                  # trạng thái Premium
```

---

## 4. Thứ tự hiện thực (khớp todo)

1. **domain**: struct + repository interface cho stamp, album, letter, letter_link, seal_ledger, seal_limit, unlock, quota, referral, entitlement, + mở rộng user.
2. **storage/sqlite**: schema migration + repository impl (theo pattern bookmark.go).
3. **service**: LetterLink, Seal, Quota, Entitlement, Auth mở rộng — nơi logic nghiệp vụ + transaction.
4. **transport**: endpoints + Firebase verify middleware.
5. **tests**: service (link 1-lần race, Dấu cap tuần/tháng, quota reset, spend thiếu Dấu).

---

## 5. Điểm cần lưu ý khi hiện thực

- **Transaction cho tiền**: OpenLink, Spend, AwardShare/Install phải trong 1 transaction (đọc-kiểm-ghi) để tránh race. SQLite serialize sẵn (single writer); Postgres cần `SELECT FOR UPDATE`.
- **Idempotent**: OpenLink trao 15📮 đúng 1 lần (`read_seal_awarded`); referral 50📮 đúng 1 lần (`seal_awarded`). Chống double-award khi retry/webhook lặp.
- **balance cache**: cập nhật `users.seals_balance` **cùng transaction** với ledger insert, không tách rời.
- **period string**: tính theo múi giờ thiết bị cho tuần (BR reset thứ Hai), theo lịch cho tháng — chốt 1 chuẩn (đề xuất UTC + tuần ISO) để test ổn định.
- **Firebase Storage**: server không giữ ảnh; client upload thẳng lên Storage (signed URL) hoặc qua `/api/upload` hiện có → chốt khi làm slice tem.

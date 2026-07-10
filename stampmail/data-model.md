# StampMail — Data Model & Backend Logic

**Cập nhật lần cuối**: 2026-07-07
**Backend**: Go server (mở rộng `simple_backend_server`), SQLite (dev) / Postgres (prod)
**Căn cứ**: 27 spec, [tech-stack.md](tech-stack.md) TD-001→012

> Nguồn sự thật cho toàn bộ bảng, quan hệ, và logic nghiệp vụ server-side. Mọi quota và link-1-lần đều **server-side** (client chỉ đọc). Bám pattern Go hiện có: mỗi entity có `domain` struct + repository interface, các bảng sync dùng `rev` (per-owner, tăng dần) + `deleted_at` (tombstone) như bookmark/collection.

---

## 0. Quy ước chung

- **ID**: TEXT, random opaque (IDGenerator hiện có).
- **Thời gian**: DATETIME UTC.
- **Sync (offline-first)**: bảng client cần đồng bộ (stamps, albums, letters_received) mang `rev INTEGER` + `deleted_at DATETIME NULL`. Client kéo delta bằng `rev > cursor`.
- **owner_id**: `uid` từ Firebase ID token (TD-002). Bảng `users.id` = Firebase `uid` (không tự sinh id user nữa — dùng uid).

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

### verification_codes
Mã OTP 6 số do **backend tự phát & verify** (không dùng link/email của Firebase). Dùng cho xác nhận email (BR-02 SM-000) và đặt lại mật khẩu (BR-12 SM-000).

| Cột | Kiểu | Ghi chú |
|---|---|---|
| id | TEXT PK | |
| email | TEXT | địa chỉ nhận mã |
| purpose | TEXT | `email_verify` \| `password_reset` |
| code_hash | TEXT | hash của mã 6 số (không lưu plaintext) |
| expires_at | DATETIME | = created_at + 5 phút (BR-02/12) |
| consumed_at | DATETIME NULL | đã dùng chưa (một lần) |
| created_at | DATETIME | dùng cho throttle gửi lại 120s |

> Gửi lại tạo mã mới → mã cũ hết hiệu lực (đánh dấu consumed/xoá). Không tiết lộ email có tồn tại hay không (BR-12).

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

**Trạng thái khi mở** (transaction):
- `opened_by IS NULL` && `now < expires_at` → cho mở, set `opened_by`+`opened_at`, trả nội dung.
- `opened_by IS NOT NULL` → "đã đọc" (AC-03 SM-016).
- `now >= expires_at` → "hết hạn" (AC-05).

> **Mở khóa nội dung cao cấp**: sticker đặc biệt (SM-008) và viền/khung khóa (SM-009) chỉ mở bằng **Premium** — kiểm qua `entitlements.is_premium`, không có bảng "mở khóa từng item". Toàn bộ tem mẫu (SM-035) **miễn phí**, không có phần khóa. (Tem là ảnh render phẳng nên không lưu metadata sticker/viền server-side — xem ghi chú bảng `stamps`.)

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

### attribution
Ghi nhận **nguồn giới thiệu** khi người nhận cài app từ link (BR-09 SM-016) — AppsFlyer postback → server. Chỉ để attribution/thống kê; **không** trao thưởng.

| Cột | Kiểu | Ghi chú |
|---|---|---|
| new_user_uid | TEXT PK | tài khoản mới |
| referrer_uid | TEXT | nguồn giới thiệu (người gửi link) |
| link_id | TEXT NULL | letter_link nguồn |
| created_at | DATETIME | |

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
- **CreateLink(letterID, senderUID, platform)** → kiểm quota `letters_sent < 10` (Free); tạo `letter_links` (expires +7d); tăng quota. (BR-08/10 SM-016)
- **OpenLink(linkID, viewerUID?)** → transaction:
  1. Lock row; nếu `opened_by != NULL` → trả `already_read`; nếu hết hạn → `expired`.
  2. Set `opened_by`, `opened_at`.
  3. Push FCM cho người gửi "đã mở thư". (BR-07 SM-016)
  4. Trả nội dung thư (letter + stamps).

### Attribution (AttributionService)
- **RecordInstall(referrerUID, newUID, linkID)** → khi AppsFlyer báo cài app từ link: ghi 1 row `attribution` (idempotent theo `new_user_uid`). Chỉ ghi nhận nguồn giới thiệu, không trao thưởng. (BR-09 SM-016)

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
- **IssueEmailOtp(email, purpose)** → phát mã 6 số, lưu hash vào `verification_codes` (hiệu lực 5 phút), gửi email; throttle gửi lại 120s, mã cũ hết hiệu lực. Dùng cho `email_verify` (BR-02) và `password_reset` (BR-12). Với reset không tiết lộ email có tồn tại.
- **VerifyEmailOtp(email, purpose, code)** → so hash + kiểm hạn/consumed; đúng thì đánh dấu consumed. Với `email_verify` set `users.email_verified = true`; với `password_reset` cho phép đặt mật khẩu mới. Mã hết hạn/đã dùng → `code_invalid`. (BR-02/12 SM-000)

---

## 3. REST endpoints (transport)

Tất cả (trừ open-link công khai) qua `authMiddleware` (verify Firebase ID token).

```
POST   /api/auth/ensure-user           # sau đăng nhập Firebase lần đầu
POST   /api/auth/claim-username
GET    /api/auth/me
POST   /api/auth/email-otp             # phát mã 6 số (email_verify | password_reset); throttle 120s
POST   /api/auth/verify-email-otp      # xác nhận email bằng mã (BR-02)
POST   /api/auth/reset-password        # verify mã + đặt mật khẩu mới (BR-12)

GET    /api/stamps        /api/stamps/{id}   POST /api/stamps   DELETE ...   # +sync ?since=rev
GET    /api/albums ...    (CRUD + sync)
POST   /api/stamps/{id}/save            # lưu tem (check quota 30/tháng)

POST   /api/letters                     # tạo thư
POST   /api/letters/{id}/links          # tạo link (body: platform)
GET    /api/sent                        # hộp thư đã gửi (SM-021)

GET    /public/letter/{linkId}          # CÔNG KHAI — trang web xem thư gọi (OpenLink)
                                        # không auth; trả nội dung hoặc already_read/expired

GET    /api/inbox                        # thư đã nhận (SM-018)

POST   /api/webhooks/revenuecat          # entitlement (verify signature)
POST   /api/webhooks/appsflyer           # attribution install (ghi nhận nguồn giới thiệu; deferred deep link SM-017)
POST   /api/webhooks/... (internal)

GET    /api/entitlement                  # trạng thái Premium
```

---

## 4. Thứ tự hiện thực (khớp todo)

1. **domain**: struct + repository interface cho stamp, album, letter, letter_link, quota, attribution, entitlement, verification_code, + mở rộng user.
2. **storage/sqlite**: schema migration + repository impl (theo pattern bookmark.go).
3. **service**: LetterLink, Quota, Entitlement, Attribution, Auth mở rộng — nơi logic nghiệp vụ + transaction.
4. **transport**: endpoints + Firebase verify middleware.
5. **tests**: service (link 1-lần race, quota reset, OTP hết hạn/gửi-lại, attribution idempotent).

---

## 5. Điểm cần lưu ý khi hiện thực

- **Transaction cho mở link**: OpenLink phải trong 1 transaction (đọc-kiểm-ghi `opened_by`) để tránh race 2 người mở cùng lúc. SQLite serialize sẵn (single writer); Postgres cần `SELECT FOR UPDATE`.
- **Idempotent**: OpenLink set `opened_by` đúng 1 lần; attribution ghi đúng 1 lần theo `new_user_uid`. Chống double-xử-lý khi retry/webhook lặp.
- **period string**: quota tính theo lịch cho tháng — chốt 1 chuẩn (đề xuất UTC) để test ổn định.
- **Firebase Storage**: server không giữ ảnh; client upload thẳng lên Storage (signed URL) hoặc qua `/api/upload` hiện có → chốt khi làm slice tem.

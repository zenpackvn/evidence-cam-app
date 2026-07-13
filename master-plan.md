# StampMail — Master Plan Triển Khai End-to-End (Production-Ready)

> Tài liệu chính giao cho Product Owner / team. Tổng hợp từ context-brief + 6 draft workstream (A Backend, B Client Foundation/Auth, C Client Features, D Integrations, E Infra/QA/Release) + Flow-map. Nguồn đã đối chiếu code thật. **15 OPEN DECISIONS đã được chốt 2026-07-10 (xem §3.2).**
> **Rev 2 (review kỹ thuật 2026-07-10):** sửa mâu thuẫn D11↔C5/Flow-5 (recreate link KHÔNG trừ quota); bổ sung **D15** (bảng gốc thiếu dòng) + **D16 claim thư sau cài app (⚠️ OPEN)**; D5 tz làm ngay Phase 0 trong A1; +2–3 ED **D1.5 web letter renderer parity**; A6 OTP relabel P0; spike C1 mở rộng 3 ứng viên; C3 chốt `flutter_quill`.
> Repo gốc: `/Users/company/Documents/ex/stampmail/` — Docs `docs/projects/stampmail/` · Backend `stamp-mail-backend/` · Mobile `stamp-mail-flutter-app/`

---

## 1. Tóm tắt điều hành

**Bản chất bài toán: "hoàn thiện + productionize", KHÔNG phải greenfield.** Hai codebase đã có scaffold chất lượng cao; nhiệm vụ là lấp gap lõi, wire tích hợp cloud/SaaS, và đưa lên chuẩn production.

**Hiện trạng thực (đã kiểm chứng bằng đọc code, không chỉ theo brief):**

| Mảng | Mức hoàn thiện | Chốt chặn quan trọng |
|---|---|---|
| **Backend Go** | ~85% logic domain/service/storage sạch (Clean/hexagonal), nhưng **BUILD ĐANG FAIL** | 🔴 `main.go` import `internal/uploads` — **package chưa từng commit** ⇒ `go build ./...` đỏ + `go mod tidy` đỏ (aws-sdk deps mồ côi). Đây là blocker số 0. |
| **Flutter client** | **~5% thực chất** (LOC lớn = data/domain, gần như **0 presentation**). Scaffold production-grade (network, ObjectBox+sync, DI, go_router, theme) | Auth vẫn REST legacy chưa migrate Firebase; `stamp_creator` **chưa có package**; `firebase_options.dart` trỏ project cũ (project thật `stamp-mail` đã tồn tại trong `google-services2.json`) |
| **Design system + specs** | Hoàn chỉnh: 27 product-spec + test-cases, 7 flow, `pencil-new.pen` (49 component, token coral #F35B43) | Vài frame còn thiếu (SM-028 paywall, Flow 6 chia sẻ); vài mâu thuẫn số liệu cần chốt |

**Mục tiêu MVP:** đưa vào production vòng lan truyền lõi **Tạo tem → Soạn/gửi thư qua link DM → Người lạ mở thư trên web (không cần app) → cài app → trả lời**, cộng Album (nguồn tem), Auth 4-provider, Premium/IAP, và đủ hardening để chịu tải + tiền thật. Các feature P2 (Home/Profile/Settings đầy đủ, Sent box, Tem mẫu) hoàn tất ngay sau khi loop chạy.

---

## 2. Nguyên tắc & kiến trúc

1. **Tái dùng tối đa template** — network layer (Dio + retry/jitter/idempotency/ETag/cert-pinning), ObjectBox + delta-sync (`rev` cursor + `deleted_at`), DI (get_it/injectable), go_router typed + auth-redirect 3-phase + deep-link cold-start replay, theme/token, architecture boundary tests đều **giữ nguyên**. Không viết lại thứ đã tốt.
2. **Clean Architecture 2 phía** — Backend: `transport → service → domain`, hạ tầng implement port. Client: `app → features → shared_contracts/shared_ui → app_ui/infra`. **Feature không import feature** (rule-of-three để promote lên shared).
3. **Offline-first** — client mint entity id, ghi ObjectBox trước, sync delta khi online. Ranh giới cho phép/chặn offline theo context-brief §8 (chặn: lưu tem, gửi thư, mở thư chưa tải, thanh toán, thao tác bảo mật).
4. **Backend Go + Cloudflare R2 + Firebase (CHỈ Auth + FCM)** — R2 lưu ảnh (presigned URL, egress-free), Firebase là source-of-truth identity + push; **mọi business state (profile, quota, entitlement, letter, link) ở Go/DB**. Không dùng Firestore/Firebase Storage.
5. **Monorepo Flutter** (dart workspace) — feature package hóa; mỗi feature export `xxxRoutes` + `FeaturePackageModule` mount qua `FeatureModule.routes`.
6. **Entitlement server là source-of-truth** cho Premium; client mở khóa tức thời bằng RevenueCat `CustomerInfo` rồi reconcile với backend.

---

## 3. Phạm vi & quyết định cần chốt

### 3.1 Phạm vi 27 feature (MVP cut)

- **P0 (vòng lan truyền + nền tảng):** SM-005/006/008/009/010/011 (tạo tem), SM-016 (gửi link), SM-017/019 (nhận + animation), SM-022 (Album). Nền kỹ thuật P0: `internal/uploads`, auto-EnsureUser, OTP, inbox persistence, quota atomic, web viewer.
- **P1:** SM-000 Auth (email/social — nền tảng, kỹ thuật P0), SM-020 (trả lời), SM-035 (tem mẫu), SM-025 (chia sẻ tem), SM-026 (push).
- **P2:** SM-024 (Hồ sơ), SM-003 (Onboarding), SM-004 (Home), SM-012/013/014/015 (soạn thư — nhưng gắn liền SM-016 nên phải xong để gửi), SM-018/021 (inbox/sent), SM-027/028/029/030 (settings/premium/quota).

- **ĐÃ LOẠI khỏi MVP (không build):** SM-007 (xóa nền AI), SM-033 (Dấu/Rewards), SM-023 (Series), SM-031 (Time Capsule), SM-032 (Group Card), SM-034 (tem giới hạn thời gian), SM-036 (nháp). Vĩnh viễn: kết bạn 2 chiều, tìm bạn (thay bằng gửi link). **Báo cáo nội dung** đã loại — ⚠️ xem OPEN DECISION D14 về rủi ro store UGC.

> Kiểm đếm: đủ **27 feature** (28 SM-ID, trong đó SM-010 preview + SM-011 lưu được gộp một khối triển khai). Không feature nào bị bỏ sót; priority tag khớp brief.

### 3.2 Quyết định đã CHỐT (cập nhật 2026-07-10)

Toàn bộ 15 OPEN DECISIONS đã được chốt. Bảng dưới là quyết định cuối + tác động lên task. **Rev 2:** thêm dòng **D15** (bảng gốc thiếu dù C3/C6/§10 tham chiếu) và **D16 (⚠️ OPEN — cần PO xác nhận)** phát hiện khi review kỹ thuật.

| # | Chủ đề | ✅ QUYẾT ĐỊNH CHỐT | Tác động task |
|---|---|---|---|
| **D1** | Giá Premium | **Quyết sau qua RevenueCat** — dựng paywall + product **placeholder**, điền giá thật trước Phase 4 | C6/D5 dùng offering placeholder; không chặn code |
| **D2** | Animation mở thư | **Dựng bằng CODE cho MVP** (AnimationController native + CSS web) **bám keyframe đã thiết kế trong `pencil-new.pen`** (Flow 4 Keyframe A/B); Rive là nâng cấp tùy chọn sau | D2 code MVP; extract keyframe từ .pen; bỏ phụ thuộc designer Rive khỏi critical path |
| **D3** | Host web viewer | **Cloudflare Pages** (HTML tĩnh + vanilla JS, Worker same-origin, cùng hệ R2) | D1 (WS-D) deploy Cloudflare Pages |
| **D4** | Seal/Dấu economy | **GỠ HẲN seal economy, GIỮ referral attribution** | A4 thực thi (xóa seal.go/routes/handlers/DTO); B4.1 gỡ feature_rewards; letter_link bỏ AwardSend/AwardOpened giữ single-use |
| **D5** | Múi giờ quota | **Theo MÚI GIỜ THIẾT BỊ** (client gửi tz offset, backend key period local) | A1/period.go đổi từ UTC→local; client gửi tz header. **Làm NGAY trong A1 (Phase 0)** — không để Phase 5: quota enforce từ Phase 2, đổi period key giữa chừng sẽ reset/lệch counter |
| **D6** | Số viền Premium | **4 viền khóa** (theo SM-009, gồm "Hoa văn nổi"); sửa SM-028 BR-05 cho khớp | C1 gate viền = 3 Free / 4 khóa |
| **D7** | Mật khẩu tối thiểu | **6 ký tự** (BR ưu tiên hơn ảnh mockup) | B2.4 validate |
| **D8** | Gap frame .pen | **Task xác minh .pen + bổ sung design** (Home/Đính tem/SM-028/Flow6) — không phải decision | C6/C7/C8 phụ thuộc design bổ sung; dùng placeholder+flag nếu trễ |
| **D9** | Tái dùng collections cho Album | **KHÔNG** — feature_album đã đủ; gỡ collections | B4.2 |
| **D10** | Team size (giả định) | **Giả định 2 mobile + 1 backend + 0.5 devops** (chưa xác nhận thực tế) — timeline §5 tính theo đây; sẽ recalibrate khi biết team thật | §5 roadmap |
| **D11** | Đơn vị quota thư | **10 THƯ / tháng (1 thư = 1 quota, dù gửi nhiều nền tảng/link)** — KHÔNG trừ theo link | ⚠️ **Đổi logic**: trừ quota ở **cấp tạo THƯ** (không phải mỗi CreateLink). Xem "Thay đổi kéo theo D11" bên dưới |
| **D12** | Trigger push "thư đến" | **Chỉ áp cho reply (SM-020)** + `letter_opened` + `quota_low` (mô hình link-pull không biết uid người nhận trước khi mở nên không có push "thư mới" cho lần gửi đầu) | D4/A11: 3 loại push = letter_opened / quota_low / letter_received(reply) |
| **D13** | Postgres timing | **SAU launch** — SQLite + volume bền + backup ≤24h, Cloud Run 1-instance; **làm migration tool ngay Phase 1** để port rẻ | A14 hạ xuống post-launch; A12 giữ Phase 1 |
| **D14** | UGC/report (Apple 1.2) | **CHỈ chặn người dùng + link 1-lần/7-ngày** (KHÔNG thêm report cho MVP) — chấp nhận rủi ro review | ⚠️ **Rủi ro R2 GIỮ NGUYÊN**: chuẩn bị bổ sung "report thư" tối thiểu nếu Apple review flag |
| **D15** | Số template thư Free/Premium *(dòng bổ sung Rev 2 — bảng gốc thiếu dù được C3/C6/§10 tham chiếu)* | **Free 3 template; số lượng + danh sách template Premium quyết sau cùng giá (D1), chốt trước Phase 4** — placeholder qua config/offering | C3 template list; C6 bảng so sánh; không chặn code |
| **D16** | ⚠️ **OPEN — Claim thư sau khi cài app** (gap vòng viral, phát hiện Rev 2) | **KHUYẾN NGHỊ (cần PO duyệt):** web viewer phát **open-token** khi consume link (lưu localStorage + gắn vào OneLink); sau khi cài app + đăng nhập, app gọi `POST /api/sm/inbox/claim` (token) → bind thư vào inbox uid mới. Nếu KHÔNG có: link đã consume trên web (anonymous) → deferred deep-link mở app nhận 410 → **persona lõi "người lạ → cài → trả lời" không có thư để trả lời** | A17 (+claim endpoint), D3 (OneLink mang token), Phase 3 gate, §10 gate 3, R11 |

#### Thay đổi kéo theo D11 (quota theo THƯ, không theo link) — cần sửa

1. **Backend `letter_link.CreateLink`**: bỏ `CheckAndIncLetter` khỏi mỗi lần tạo link. Thay bằng: trừ quota **1 lần khi TẠO THƯ** (`POST /api/sm/letters`) — hoặc đếm distinct letter đã "phát hành" trong tháng. Việc tạo nhiều link cho cùng 1 thư (nhiều nền tảng) **không** trừ thêm quota.
2. **Mâu thuẫn với SM-021** ("tạo lại link cho thư hết hạn trừ 1 quota"): với D11, **tạo lại link cho thư ĐÃ TỒN TẠI không trừ quota** (quota đã tính khi tạo thư). → Cần cập nhật spec SM-021 + task C5/A17 cho khớp: recreate link = miễn phí quota, chỉ chặn recreate cho thư đã đọc.
3. **Định nghĩa "đã dùng 1 thư"**: khuyến nghị trừ quota tại thời điểm **tạo link ĐẦU TIÊN của một thư** (không phải lúc lưu draft), để thư soạn dở không tốn quota. Đánh dấu `letter.quota_counted` idempotent.
4. **A1 (atomic)** vẫn áp dụng nhưng ở cấp thư; **nudge SM-030** đếm số thư còn lại (không phải link).

> **Các mục đã tự resolve (ghi để reviewer khỏi hiểu là bỏ sót):** Push = 3 loại (letter_opened/quota_low/letter_received) theo SM-026. Share tem = 5 nền tảng (SM-025), khác 8 nền tảng gửi link (SM-016). Token JSON stale → dọn theo B5 (.pen là chuẩn). `internal/uploads` là action blocker A0, không phải decision.


---

## 4. Năm Workstream

Ký hiệu: ✅ **ĐÃ CÓ** (tái dùng) · 🔨 **PHẢI LÀM** · effort S≈≤1d, M≈2–3d, L≈4–6d, XL>6d.

### Workstream A — Backend Go productionization

| # | Task | P | Effort | Acceptance | Trạng thái |
|---|---|---|---|---|---|
| **A0** | 🔴 **BLOCKER: viết `internal/uploads`** (`uploads.go`+`r2.go`+`local.go`) thỏa port `service.Uploader`. Field `Config` khớp `main.go:120-127`; `NewR2`(aws-sdk-go-v2 S3 presign PutObject, region=auto, static creds, TTL 5-15′) + `NewLocal` (fallback `/api/upload`); key namespace `stamps/<uid>/<id>.png` | P0 | S–M | `go build ./...` xanh; `go mod tidy` không đổi; unit test presign R2+Local; server boot cả 2 nhánh | ✅ port+call-site+DTO+deps · 🔨 mỗi package. **Chặn TẤT CẢ** |
| **A0.1** | 🔴 **Verify/implement auto-EnsureUser trong `smAuth` middleware** (seam S0-1). Brief KHÔNG xác nhận middleware tự provisioning; đây là phụ thuộc cứng của toàn bộ auth Phase 1. Nếu chưa có: middleware sau khi verify ID token → tra profile theo uid → nếu thiếu thì tạo Free-profile lazy (idempotent, race-safe). KHÔNG có route `/ensure-user` | P0 | S–M | Login lần đầu → gọi `/api/sm/me` → profile Free tự tạo, không 404; gọi đồng thời không tạo trùng | 🔨 verify trước, impl nếu thiếu. **Chặn auth Phase 1** |
| **A1** | 🔴 **Quota race → atomic conditional UPDATE**. Thêm `TryIncStamps/Letters` = `INSERT...ON CONFLICT DO UPDATE...WHERE counter<cap RETURNING`; bỏ Get→Inc. **Period key theo tz thiết bị ngay từ đầu (D5)** — client gửi tz header; tránh đổi key UTC→local giữa chừng khi quota đã chạy từ Phase 2 | P0 | S–M | Test đồng thời N>cap → tổng không bao giờ > cap; Premium bypass; period key đúng theo tz client | ✅ `IncStamps` nền · 🔨 conditional + tz key + test race |
| **A2** | 🔴 **Config fail-fast + CORS siết**. `APP_ENV=prod` thiếu `JWT_SECRET`/Firebase/R2 → `log.Fatal`; `CORS_ALLOWED_ORIGINS` thay `*` | P0 | S | prod thiếu secret → exit≠0; CORS chỉ origin cấu hình | 🔨 |
| **A3** | 🔴 **Graceful shutdown + timeouts + body limit**. `http.Server{ReadHeaderTimeout,...}` + `Shutdown(ctx)` khi SIGTERM (Cloud Run drain); `MaxBytesReader` | P0 | S | SIGTERM khi in-flight → request hoàn tất rồi exit; body quá cỡ → 413 | ✅ `Timeout(15s)` context · 🔨 Server struct + signal |
| **A4** | 🔴 **Gỡ seal economy, GIỮ referral attribution** (D4). Xóa `seal.go`(service/domain/storage), routes/handlers/DTO `/seals*`; sửa `letter_link.go` (bỏ `AwardSend/AwardOpened`, giữ single-use + rename `MarkReadNotified`), `referral.go` (bỏ `AwardInstall`, giữ `Create` idempotent), `main.go`, profile `seals_balance`, test | P0 quyết định / **P1 thực thi** | M | Build+test xanh; không còn `/seals`; referral vẫn ghi idempotent; không còn `📮` | Refactor phá vỡ nhiều file |
| **A5.1** | 🔴 **`GET /api/sm/quota`** (nudge SM-030 <20%) → `Quota.Remaining` | P0 | S | Trả `{stamps_remaining,letters_remaining,caps,period}` | ✅ service có · 🔨 handler+route |
| **A5.2** | 🔴 **Letters list/get/delete** `GET/DELETE /api/sm/letters(/{id})` | P0 | S | Delta-sync letters ở client | ✅ store `ListBySenderSince/GetOwned/Delete` có · 🔨 handler |
| **A5.3** | **`GET single stamp/album`** dùng `GetOwned` | P1 | S | Màn chi tiết + resolve conflict | ✅ store có |
| **A6** | 🔴 **OTP 6 số** (verify email BR-02 + reset pw BR-12). Bảng `otp_codes` (hash, TTL 5′, resend 120s, attempts lockout); `POST /api/otp/request` (luôn 200, không lộ email) + `/verify`. Ranh giới: Firebase = identity; backend = OTP + `email_verified` + reset qua Admin `UpdateUser` | **P0** (launch gate §10-#4 yêu cầu Email+OTP → email/pw LÀ bắt buộc launch) | M–L | Happy/expired/resend<120s→429/email-không-tồn-tại→200; mã hash | 🔨 toàn bộ (grep sạch — chưa có) |
| **A7** | **Wire lockout** (5 sai → 15′) vào OTP flow (`CheckLock/RecordFailure` đã có nhưng chưa gắn route) | P1 | S | Sai OTP 5 lần → khóa 15′, trả `retries_left` | ✅ service+bảng có · 🔨 wire |
| **A8** | **Rate limiting** (`x/time/rate` token-bucket): `/api/otp/*` chặt, `/public/letter/{id}` theo IP, `presign` theo uid, webhook theo IP | P1 | M | Vượt ngưỡng → 429 + Retry-After | 🔨 |
| **A9** | **Webhook idempotency + ordering** (RevenueCat). Bảng `webhook_events(event_id PK)`; `Apply` chỉ ghi nếu `event_timestamp >= updated_at` (chống EXPIRATION cũ downgrade sau RENEWAL) | P1 | M | Event lặp → apply 1 lần; EXPIRATION cũ không downgrade | ✅ Authorization constant-time secret · 🔨 idempotency |
| **A10** | **Structured logging + OTel + `/readyz`**. `slog` JSON + request_id/uid/route; metrics request/quota_exceeded/webhook/presign | P1 | M | Log JSON xuyên suốt; trace xuất; dashboard latency/error | 🔨 (deps đã kéo) |
| **A11** | **Push 3 loại + device tokens**. Bảng `device_tokens`; `POST/DELETE /api/sm/devices`; `Notifier` → `MulticastMessage`; 3 loại `letter_opened`(✅)/`quota_low`/`letter_received` | P1 | M | Token đăng ký → push đúng thiết bị; tắt loại → không nhận | ✅ 1 loại qua topic · 🔨 token store + 2 loại |
| **A12** | **Migration tool versioned** (goose/golang-migrate, `//go:embed`). Baseline = schema hiện tại + `otp_codes`/`webhook_events`/`device_tokens`/`sm_inbox`/drop seals; `rev`/`deleted_at` vào baseline (bỏ hack `addSyncColumns`) | P1 | M | `migrate up/down` SQLite; CI chạy migrate. **Làm TRƯỚC Postgres** | 🔨 (hiện 1 khối `CREATE TABLE IF NOT EXISTS`) |
| **A13** | **Integration test HTTP e2e + CI build `main`**. `httptest.NewServer` router thật + SQLite tạm: presign, open-link (200→410 already→410 expired), webhook (idempotent), quota (30→403), inbox persistence. CI thêm `go build .` tường minh | P1 | M | Test xanh; CI đỏ nếu `main` không build | ✅ fakes/dev verifier · 🔨 suite |
| **A17** | 🔴 **Inbox persistence + `GET /api/sm/inbox` + count** (gap P0 — `OpenLink` hiện KHÔNG lưu record người nhận ⇒ Flow 4 + Home badge gãy). Bảng `sm_inbox(recipient_uid, letter_id, link_id, opened_at, read, rev, deleted_at)`; `OpenLink` ghi record khi viewer đã đăng nhập; **viewer anonymous → phát open-token + `POST /api/sm/inbox/claim` bind thư vào uid sau khi cài app + đăng nhập (D16 — đóng gap "người lạ → cài → trả lời")**; endpoint list + unread count; delta-sync client. **Enforce block-user tại đây** (xem A15) | P0 | M–L | Mở link khi đăng nhập → xuất hiện trong `GET /api/sm/inbox`; count unread đúng; re-view không tạo trùng; **mở web anonymous → cài → đăng nhập → claim → thư trong inbox** | 🔨 toàn bộ. **Chặn Flow 4** |
| **A5.4/A15** | **delta-pull profile + CRUD nghiệp vụ** (SM-024/027). `profiles.updated_at/rev`; `PUT /api/sm/me`, `POST /api/sm/username/change` (+1 lần rồi khóa), delete grace 7 ngày (`deletion_requested_at` + job), **block-user (CRUD + ENFORCE ở luồng nhận thư)**, revoke-sessions (Admin `revokeRefreshTokens`) | P2 (block-enforce P1) | M | Đổi username lần 2 → 409; xóa → grace, login lại hủy; stats ẩn; DOB không lộ; **A chặn B → thư từ A không vào inbox B / OpenLink từ chối** | 🔨 |
| **A14** | **Migrate SQLite → Postgres/Cloud SQL** (D13). Impl `storage/postgres/*`; sửa `nextRev` MAX+1 race → sequence/UPDATE RETURNING; error-string `UNIQUE constraint` → `pgconn 23505`; `?`→`$1`; driver pgx | P2 (P1 nếu multi-instance) | L | Cùng suite A13 xanh trên Postgres; `rev`/`deleted_at` monotonic dưới concurrency | ✅ repo interface tách sạch · 🔨 impl. **Sau A12** |
| **A16** | **Dọn legacy API** sau flag `ENABLE_LEGACY_API=false` prod (giảm attack surface) | P2 | S | — | 🔨 |

**Backend HTTP e2e (backend HTTP integration suite)** làm được NGAY sau A0/A0.1/A4, không chờ UI — là lưới an toàn cho toàn bộ seam.

**Endpoint GAP bổ sung (từ flow-map, ghép vào A5/A15/A17):** `PATCH /api/sm/stamps/{id}` rename (P1), guard "không tạo link cho thư đã đọc" BR-05 (P1), tem mẫu catalog + dedupe (P1), nguồn template thư (xác minh bundle vs endpoint).

**Ước lượng A:** P0 ≈ 7–10 ED (thêm A0.1 + A17 gồm claim D16 + A6 relabel P0) · P1 ≈ 5–9 ED · P2 ≈ 6–9 ED. **Tổng ≈ 20–28 ED.**

---

### Workstream B — Client Foundation, Auth → Firebase, Cấu hình & Dọn dẹp

> Đính chính hiện trạng: (1) native bundle id **đã đúng** `com.aktechvn.stampmail`; sai là **3 file Firebase config** trỏ project cũ. (2) Firebase project thật `stamp-mail` (project_number 975726644424) **đã tồn tại** trong `google-services2.json`. (3) Design token trong `app_ui` đã đúng hệ mới (coral, Baloo2+BeVietnamPro).

| # | Task | P | Effort | Acceptance | Trạng thái |
|---|---|---|---|---|---|
| **B4.1/4.2** | **Gỡ `feature_rewards` (orphan) + demo `collections`/`bookmarks`** (D9). Gỡ pubspec/DI/router/features.dart/reader_fallbacks + maestro 05/06 | P1 (làm sớm để build xanh) | M | `pub get`+build_runner+`analyze` xanh; boundary tests xanh | ✅ rewards chỉ ref ở DI |
| **B1.1** | 🔴 **`flutterfire configure --project=stamp-mail`** sinh config thật (ghi đè `firebase_options.dart` + 2 file native); xóa `google-services2.json` + plist cũ; thêm SHA-1/256 Android | P0 | S | `projectId:'stamp-mail'`; login test → ID token verify PASS backend | ✅ project tồn tại · 🔨 chạy CLI (chặn A1 access) |
| **B1.2** | **Điền env staging/prod** (thay `example.com` bằng URL Cloud Run thật) | P1 | S | Build prod/staging trỏ đúng API | ✅ cơ chế dart-define · 🔨 URL (chặn A3/A9) |
| **B2.1** | 🔴 **Add deps Firebase/social** (`firebase_auth`, `google_sign_in`, `sign_in_with_apple`, `flutter_facebook_auth`) | P0 | S | pub get xanh | 🔨 |
| **B2.2** | 🔴 **Datasource Firebase + sm-user**. `FirebaseAuth` wrapper (signIn/create/social/getIdToken/link/unlink/reauth); `sm_user_data_source` (`/api/sm/me` + `claim-username`). ⚠️ **KHÔNG có route `ensure-user`** — provisioning Free-profile **lazy trong `smAuth` middleware** (seam S0-1, phụ thuộc A0.1) | P0 | M | Login Firebase → ID token → profile tạo/đọc | 🔨 (thay REST) |
| **B2.3** | 🔴 **ID token qua network layer**. `AuthInterceptor` lấy token tươi mỗi request (`getIdToken()`); `TokenRefresher`→`getIdToken(true)`. Bơm `TokenProvider` callback từ auth qua DI (network KHÔNG import `firebase_auth` — giữ layering) | P0 | M | `/api/sm/*` luôn kèm token còn hạn; 401→refresh+retry 1 lần; offline không xóa session | ✅ interceptor/refresher/store · 🔨 rewire |
| **B2.4** | 🔴 **AuthRepository + AuthBloc đa provider**. `signInWithEmail/registerWithEmail/signInWithProvider/link/unlink/claimUsername`; nhánh "cần chọn username" → `/choose-username`. BR: pw ≥6 (D7), username 3–30 unique, ≥13 tuổi | P0 | L | 4 nút provider hoạt động (Email/Google trước; Apple/FB khi A5/A6); sai provider → lỗi rõ | ✅ toàn bộ UI auth đã dựng · 🔨 wire logic |
| **B2.5** | 🔴 **OTP 6 số + lockout** (backend endpoint, KHÔNG email-link Firebase). Wire `verify_email`/`forgot_password` screen; sửa hằng số → **TTL 5′/resend 120s** | P0 | M | OTP đúng→verified; resend<120s chặn; sai 5→lockout đếm ngược; email-không-tồn-tại vẫn "đã gửi" | ✅ UI+`otp_input` · 🔨 wire (chặn A6 backend) |
| **B2.6** | **Link/unlink, session 90 ngày idle (client-side `lastActiveAt`), đổi pw→revoke devices, auto-restore Premium (BR-17), offline guard thao tác bảo mật, xóa tài khoản grace 7 ngày** | P1 | M–L | Unlink chặn <2 provider; đổi pw đăng xuất device khác; offline disable đúng nút | ✅ UI screens · 🔨 wire |
| **B3.1** | 🔴 **Bottom-nav 4 tab StampMail** (Tạo tem·Thư·Album·Hồ sơ) thay 4 branch demo; sửa `app_shell` icon/label theo .pen | P0 | M | 4 tab đúng thứ tự/nhãn; StatefulShell giữ state | ✅ `StatefulShellRoute` typed · 🔨 đổi branch |
| **B3.2** | 🔴 **Routes full-screen cho flow** (creator/compose/reader/premium/settings) — skeleton + placeholder; export `xxxRoutes` mỗi feature | P0 | M | Mọi route resolve; codegen xanh | ✅ `FeatureModule.routes` · 🔨 export + placeholder |
| **B3.3** | **Auth-redirect route mới** — `/letter/:id` cho phép guest (SM-017), reply mới bắt auth | P1 | S | Guest mở `/letter/:id` không bị đẩy login | ✅ `resolveSplashRedirect` · 🔨 allowlist |
| **B3.4** | **Deep-link route letter** + `app_links` (⚠️ **chưa có trong pubspec** dù brief nói có) | P1 | S | Click link đã cài → mở `/letter/:id` | ✅ replay · 🔨 add lib + listener (chặn A9 native) |
| **B3.5** | 🔴 **DI đăng ký module StampMail, bỏ demo**; regen `injection.config.dart` | P0 | S | DI khởi động không lỗi binding | 🔨 |
| **B4.3** | **Gỡ auth REST cũ** sau B2 (`auth_remote_data_source` + models + `auth_network_module`) | P1 | S | `grep api/auth` rỗng | 🔨 |
| **B4.4** | **Dọn preview + maestro appId** (`quangsat`→`stampmail` 14 file) | P2 | S | grep quangsat rỗng | 🔨 |
| **B5** | **Design system alignment**: verify token (gần xong); dọn `stampmail-tokens.json` stale (Fredoka/nâu); **inventory 49 component .pen ↔ widget** | P1–P2 | S | 1 nguồn chuẩn .pen; bảng gap component | ✅ token đúng · 🔨 dọn JSON + inventory |
| **B6** | **Nợ test gate CI**: fix `onboarding_screen_test` (heroAsset vs icon); giữ boundary/layering tests xanh sau mọi thay đổi | P0/P1 | S–M | `flutter test` xanh; không import feature↔feature | ✅ hạ tầng · 🔨 fix + duy trì |

**Ước lượng B: ~22–26 ED** (chưa gồm UI feature StampMail — đó là WS-C). **Auth là nút thắt critical path.**

---

### Workstream C — Client Feature UI Build-out (BLoC + go_router)

| # | Khối | P | ED | Điểm chính / Acceptance |
|---|---|---|---|---|
| **C0** | **Foundation chung** (gate mọi feature): shared UI kit (`StampCard` răng cưa vector CustomPainter, `PremiumLockBadge`+`PremiumUpsellSheet`, `QuotaNudgeBanner`, `OfflineBanner`, `GestureTransformBox`); `QuotaReader` impl + NoOp fallback; reconcile `SharePlatform` (**8 nền tảng cho SM-016 gửi link**; **share-tem SM-025 dùng tập con 5** — IG/TikTok/FB/Threads/X); mở rộng `LetterContent` = **schema rich-text Delta** (đậm/nghiêng/căn lề + màu theo đoạn — BR-02/BR-09 SM-013; font/ruling/paper-color/sticker/charLimit; server opaque; **schema = contract app↔web viewer, chốt đầu Phase 3 cho D1.5**); add libs + spike editor | P0 | 9–10 | Foundation xanh; Free/Premium gate đọc đúng quota |
| **C1** | 🔴 **`stamp_creator` (TẠO PACKAGE MỚI — nặng nhất)**: SM-005 nguồn ảnh+preview, SM-006 16 filter/4 nhóm (8 Premium gate)+3 slider (`ColorFilter.matrix` — preset sẵn từ `colorfilter_generator`/`color_filter_extension`, GPU-accelerated), SM-008 canvas sticker/chữ multi-touch (**SPIKE 2 ED — 3 ứng viên:** pro_image_editor nguyên khối [rủi ro: khó ép theo wizard 4 màn design .pen] vs **sticker-canvas package** `lindi_sticker_widget`/`sticker_editor_plus` nhúng wizard tự dựng vs native `GestureTransformBox` C0 [gesture `onScale` Flutter có sẵn pan+pinch+rotation] — **nghiêng về 2 phương án sau**), SM-009 7 viền (Free 3/khóa 4 — **D6**; ưu tiên **asset overlay SVG/PNG** thay vì code-draw cả 7 kiểu), SM-010 preview, export PNG+**watermark cưỡng bức** (RepaintBoundary, trong ảnh capture), SM-011 lưu (**presign 3-hop** POST→PUT R2→POST stamps, quota 403) | P0 | 22–25 | Ảnh gốc → 4 bước → lưu → tem trong Album mở được R2; Free chặn tem 31; offline chặn Lưu. **Gốc của loop** |
| **C2** | **`album`** (SM-022+SM-035): grid/list phẳng (tem tạo + mẫu, KHÔNG tem-nhận), chi tiết/đổi tên/xóa, tem mẫu Free chống trùng | P0/P1 | 5–6 | ✅ data/domain/sync đủ · 🔨 chỉ UI |
| **C3** | **`letters` composer** (SM-012→016): template list (Free 3 / Premium theo **D15**), **rich editor** (spec SM-013 yêu cầu **đậm/nghiêng/căn lề theo selection [BR-02] + màu chữ theo vùng bôi đen [BR-09]** → rich-text đúng nghĩa, KHÔNG làm được bằng TextField thường; 4 font, 5+ nền giấy, kẻ dòng, ~500 ký tự, không nháp — **CHỐT `flutter_quill`** [bold/italic/align/color/font đều là attribute Delta chuẩn], **toolbar TỰ DỰNG theo .pen** không dùng toolbar mặc định; kẻ dòng = khóa line-height `DefaultStyles` qua 4 font, nếu align tuyệt đối quá tốn công → hạ BR-08 về "trang trí nền" [spec đã cho phép]; serialize **Delta JSON làm `LetterContent`**), đính tem ≤3/≥1, preview, **platform picker 8 + gửi link (SM-016 P0)** | P0 (SM-016)/P2 (soạn) | 12 | ✅ repo · 🔨 presentation + rich editor. Cần **C1 xong** (tem để đính) |
| **C4** | **`letter_inbox` + animation** (SM-017/018/019/020): inbox list+filter (dùng `GET /api/sm/inbox` — A17), **animation 4 bước** (SPIKE D2, dùng chung web viewer), reply (cần C3) | P0/P1 | 8–9 | ✅ `open/saveStamps` · 🔨 UI+animation |
| **C5** | **Sent box** (SM-021): trạng thái link, tạo lại link cho thư hết hạn (**miễn phí quota — D11**, quota đã tính khi phát hành thư; cập nhật spec SM-021 cho khớp), chặn recreate thư đã đọc | P2 | 2 | ✅ `sent()` · 🔨 UI |
| **C6** | **`premium`/paywall** (SM-028/029): bảng so sánh, 2 gói RevenueCat, restore, quản lý/hủy. ⚠️ **SM-028 chưa có frame .pen (D8)**; ship stub sớm để unblock gate | P2 (gate C1/C3) | 4–5 | ✅ `EntitlementReaderImpl` cache · 🔨 UI+`purchases_flutter` |
| **C7** | **Home + Profile/Settings** (SM-004/024/027): viết lại ruột home/profile (đang đọc sai domain bookmark/collection); settings đổi pw/đăng xuất/xóa grace/ngôn ngữ/âm thanh/block/push/ẩn stats | P2 | **9–11** (nâng từ 7 — Home rewrite + Profile + full Settings đa mục nặng hơn ước ban đầu) | 🔨 viết lại |
| **C8** | **Share tem** (SM-025): 3 mức nội dung, toggle 9:16↔1:1, watermark cưỡng bức, native share (`share_plus`, **5 nền tảng**), lưu gallery (`gal`). ⚠️ **Flow 6 chưa có frame (D8)** | P1 | 3 | ✅ export từ C1 · 🔨 UI |
| **C9** | **`onboarding` UI** (SM-003): màn onboarding hiển thị 1 lần sau đăng ký/lần mở đầu (giá trị cốt lõi + quyền). B6 chỉ *fix test*, không build màn — task này build thật (hoặc gộp vào C7 với ED riêng) | P2 | 2–3 | Chạy đúng 1 lần, cờ persisted; skip khi đã xem; heroAsset đúng .pen | 🔨 |

**Ước lượng C: ~76–84 ED** (+ buffer QA/golden/maestro 15–20% ≈ **90–100 ED** — buffer này phải được rải vào các phase, xem §5). **Ràng buộc cứng:** C1 là gốc (không có tem → không gửi thư); C3 cần C1; reply cần C3; mọi upsell cần C6 (ship stub SM-028 sớm).

---

### Workstream D — Tích hợp xuyên suốt & SaaS

| # | Khối | P | ED | Điểm chính / Chốt đề xuất |
|---|---|---|---|---|
| **D1** | **Web letter viewer** (SM-017, TD-011). ✅ `web_letter/index.html` self-contained + backend `GET /public/letter/{id}` single-use atomic. 🔨 Deploy Cloudflare Pages + inject config env; đổi CTA → OneLink (deferred); **fix re-view: consume-on-load → 410 khi reload** → cache `localStorage` render lại không animation; in-app gọi `?viewer=<uid>` (web anonymous); 🔨 **D1.5 letter renderer parity (+2–3 ED, Rev 2):** render Delta JSON→HTML (đậm/nghiêng/căn lề/màu đoạn/kẻ dòng/sticker/≤3 tem đính) — Quill gốc là JS nên có đường sẵn (nhúng quill core hoặc renderer nhỏ cho tập attribute giới hạn); **4 font nhúng self-contained đủ glyph tiếng Việt**; golden so khớp app↔web; dùng schema contract từ C0 | P0 | L | Chốt **HTML+vanilla JS + Cloudflare Pages same-origin** |
| **D2** | **Animation mở thư** (SM-019, TD-010). Interface `LetterRevealController` (4 bước+muted); impl code native (`AnimationController`) + web CSS mở rộng 2→4 bước; âm thanh (`just_audio`/`audioplayers` — **chưa trong pubspec**); Rive vào Phase 6 | P0 (code) / P2 (Rive) | M + L | **Rive đích, code MVP** (D2) |
| **D3** | **Deep link + attribution**. Add `app_links` (**chưa có**) + route `/letter/:id`; iOS Associated Domains + Android App Links (host AASA/assetlinks cạnh viewer); AppsFlyer SDK deferred deep link; OneLink mang `link_id`+`sender_uid`+**open/claim-token (D16)**; **gỡ seal khỏi referral giữ attribution**; push→màn qua `DeepLinkState` | P0/P1 | M mỗi | Chặn A6/A8/A9 native |
| **D4** | **Push/FCM** (SM-026, **3 loại**). ✅ `FirebaseMessagingService` (token/permission/tap chưa wire) + backend `Notifier`. 🔨 **per-type topic** (`user_<uid>_<kind>`, toggle = sub/unsub) cho MVP → **token store P1**; bắn `quota_low` + `letter_received` (D12); wire tap→màn; APNs `.p8` (A6) | P0/P1 | M mỗi | Chốt **topic MVP → token store P1**; đã resolve 5→3 loại |
| **D5** | **IAP RevenueCat** (SM-028). Add `purchases_flutter`; `Purchases.logIn(firebaseUid)` (= webhook AppUserID); paywall 2 offering; restore BR-17; **mở khóa tức thời bằng `CustomerInfo`** + reconcile backend; webhook hardening (A9); ⚠️ **cửa sổ lệch quota server-side** sau mua (D5.5 — refresh endpoint vs chấp nhận độ trễ) | P0/P1 | L | Chốt **appUserID=firebaseUid, unlock tức thời** |
| **D6** | **Offline-first boundaries**. `ConnectivityCubit` app-wide; `OfflineGuard` chặn đúng tập §8; cache quota/entitlement ObjectBox; `OfflineBanner` ở app_shell; phân biệt "chưa verify Premium" vs "đã verify mất mạng" | P0/P1 | S–M | Đúng bảng offline §8 |

**Ước lượng D (phần unique, không trùng B/C):** ~22–28 ED (deploy viewer, **letter renderer parity D1.5 +2–3 ED**, native deep-link config, push wiring, IAP flow, offline guard).

---

### Workstream E — Infra/DevOps, QA & Release

> ✅ CI/CD chất lượng cao đã có: backend CI (gofmt/vet/build/test-race/coverage), Flutter CI (codegen+l10n verify, analyze, coverage gate 53%, build-android/ios, golden), `release.yml`+Fastlane (TestFlight/Play, obfuscate, dSYM→Crashlytics, match), CodeQL, Dependabot, Crashlytics wired. **Chủ yếu wire secrets + sửa target + viết lại E2E.**

| # | Task | P | Effort | Điểm chính |
|---|---|---|---|---|
| **E2.1** | 🔴 **Sửa `backend-deploy.yml` target**: đang build/deploy submodule `simple_backend_server` (template) **KHÔNG phải** `stamp-mail-backend`. Khuyến nghị chuyển workflow vào repo backend thật. **+ SQLite volume**: hiện `--min/max=1` nhưng **không mount volume** → mất data mỗi cold start → thêm `--add-volume` GCS FUSE hoặc Cloud SQL | P0 | S+M | Data bền qua restart |
| **E2.2** | **Graceful shutdown + prod hardening** (đồng bộ A2/A3); rate-limit/CORS/webhook (A8/A9) | P0/P1 | S–M | (xem A) |
| **E2.3** | **Cloud SQL decision** (D13). Soft-launch SQLite+backup vs Cloud SQL HA. Nếu (b): instance + connector `--add-cloudsql-instances` | P0 quyết định / P1–2 impl | L | Không launch prod với SQLite ephemeral |
| **E2.4/2.5** | **Multi-env dev/staging/prod** Cloud Run + R2 CDN custom domain `cdn.stampmail.app` | P1 | M+S | 3 flavor trỏ đúng 3 backend |
| **E3.1** | **Backend CI**: đảm bảo build `main` (đang đỏ do thiếu uploads); migration check; coverage gate | P0/P1 | S–M | CI đỏ tới khi A0 xong |
| **E3.3** | 🔴 **Wire signing release** (hard gate ship store): match repo iOS + keystore Android + ASC/Play keys + Firebase config secrets base64 | P0 | M | `workflow_dispatch prod` build ký + upload |
| **E4.2** | 🔴 **Viết lại `integration_test`** journey StampMail (login→tạo tem→gửi→mở→cài) thay demo. **Backend HTTP e2e làm NGAY** (không chờ UI); full app journey khi UI xong. Tái dùng `tool/run_e2e.sh` | P0 (backend) / P1 (app) | M mỗi | `run_e2e.sh` xanh |
| **E4.3** | **Maestro thay flow + appId** (`quangsat`→`stampmail`); flow SM theo test-cases ✅Maestro | P1 | L | Trace ngược test-cases |
| **E4.4** | **Giữ architecture boundary tests xanh** khi thêm package mới (allowlist) | P0 | S mỗi | Guardrail rẻ |
| **E5** | **Store readiness**: listing App Store/Play; **privacy manifest `PrivacyInfo.xcprivacy` + ATT** (AppsFlyer IDFA) + Play Data safety; **Info.plist strings** (camera/photo/tracking); age rating ≥13 + UGC (D14); **Sign in with Apple bắt buộc (Apple 4.8)**; IAP compliance (không link ngoài); Restore Purchases | P0 | M | Không reject vì ATT/Apple-4.8/UGC |
| **E5.5** | **Staged rollout + crash alert + kill-switch** (`force_update_gate` — xác minh Remote Config vs endpoint) | P1 | S–M | Phased 5→100% |
| **E6** | **Observability + backup + runbook**: structured log→Cloud Logging, OTel metrics 4 golden signals + alert (5xx/p95/webhook fail/letter-open-error); **backup DB** (SQLite snapshot→R2 hoặc Cloud SQL PITR); incident runbook (rollback/kill-switch/key-rotate/restore) | P0 (backup) / P1 | M+S | Backup ≤24h + restore diễn tập |

**Canonicalize bundle id** `com.aktechvn.stampmail` (dev `.dev`, staging `.staging`) khắp firebase_options/maestro/CI/App IDs — **P0, S, chặn A1/A6**.

**Ước lượng E: ~20–25 ED** (chủ yếu config/wire + viết lại QA).

---

## 5. Roadmap theo phase/milestone

**Giả định team (D10):** 2 mobile Flutter (M1, M2) + 1 backend Go (B) + 0.5 devops/infra (I) + design support (gap frame). 1 eng-week (ew) = 5 ED.

**Reconcile effort (Rev 2):** tổng effort thực = A ~20–28 + B ~22–26 + C ~90–100 (đã gồm buffer QA/golden/maestro) + D ~22–28 + E ~20–25 = **~174–207 ED ≈ 35–41 ew**. Buffer QA của WS-C được **rải vào từng phase** (không để lơ lửng). **Lưu ý số học (Rev 2):** tổng ED gắn vào 7 phase ≈ 156–185 — phần chênh ~18–22 ED là công việc WS-E xuyên suốt (CI/observability/store prep chạy song song mọi phase), đã nằm trong tổng, KHÔNG phải slack. Với parallelism ~3.5 FTE và critical path auth→features, **calendar ≈ 15–19 tuần tới MVP launch**.

> ⚠️ **Cảnh báo ước lượng (không phải baseline chắc chắn):** phần mobile-only (B ~24 + C ~95 ≈ 119 ED) chia 2 dev ≈ 12 tuần *thuần code*, bị nối tiếp bởi phase-gate + spike C1 (canvas) + nút thắt auth. Mốc 15–19 tuần là **khả thi nhưng aggressive, gần như không có slack**. Nếu C1 spike trượt hoặc assets/design gap frame trễ, timeline trượt trực tiếp. Khuyến nghị: theo dõi sát 2 mốc rủi ro (auth Phase 1, C1 Phase 2) và có kế hoạch cắt phạm vi P2 nếu cần.

### Phase 0 — UNBLOCK (build + config + credentials) · ~1–1.5 tuần · ~6–8 ED
Mục tiêu: server build được, project chạy thật, credentials sẵn sàng.
- **B:** A0 `internal/uploads` (🔴 chặn tất cả) + A0.1 verify/impl auto-EnsureUser + A1 quota atomic (**gồm period key theo tz thiết bị — D5**) + A2/A3 config/shutdown; chốt A4 (gỡ seal).
- **M1/M2:** B4 dọn rewards/collections/bookmarks; B1.1 flutterfire configure (project `stamp-mail`); canonicalize bundle id; B6 fix onboarding test.
- **I + PO:** credentials A1 Firebase (4 provider), A2 R2 bucket, A3 GCP/Cloud Run + WIF, A4 Secret Manager, A9 domain. Sửa `backend-deploy.yml` target + volume (E2.1).
- **Gate ra:** `go build ./...` xanh; CI backend xanh; app khởi động Firebase không lỗi; deploy staging thành công.

### Phase 1 — AUTH + FOUNDATION · ~2.5–3 tuần · ~28–32 ED
Mục tiêu: đăng nhập thật + shell 4 tab + nền client.
- **B:** A6 OTP endpoints + A7 lockout + A12 migration tool + A13 backend HTTP e2e; thực thi A4 (xóa seal code); xác nhận A0.1 auto-EnsureUser hoạt động.
- **M1:** B2.2/2.3/2.4 auth Firebase (critical path, ~9 ED) — **cần hợp đồng API OTP/auto-EnsureUser chốt sớm với B**.
- **M2:** B3 router/DI 4 tab + routes skeleton; C0 foundation (shared UI kit, QuotaReader, SharePlatform); B4.3 gỡ REST.
- **Gate ra:** login email+OTP+Google → Home; `/api/sm/me` trả 200 (profile Free tự tạo lazy); 4 tab điều hướng; boundary tests xanh.

### Phase 2 — TẠO TEM + ALBUM (P0) · ~3–3.5 tuần · ~30–34 ED
Mục tiêu: tạo và lưu tem lên R2, xem trong Album.
- **M1+M2:** C1 `stamp_creator` (22–25 ED — **spike canvas 2 ED trước**, D6 chốt viền) + C2 album.
- **B:** A5.1 `/quota` + A5.2 letters CRUD + presign hardening; A5.4 rename stamp.
- **I:** R2 CDN domain (E2.5); assets sticker/viền (design — nếu chậm dùng placeholder + flag).
- **Gate ra:** ảnh → 4 bước → lưu → tem trong Album mở được qua R2; Free chặn tem 31; **S0-2 round-trip R2 test xanh**.

### Phase 3 — SOẠN/GỬI/NHẬN THƯ + WEB VIEWER (P0 lan truyền) · ~3.5–4 tuần · ~36–43 ED
Mục tiêu: đóng vòng viral tem→gửi→mở→(cài)→trả lời.
- **B:** 🔴 **A17 inbox persistence + `GET /api/sm/inbox` + count** (gap P0 — `OpenLink` hiện không lưu record người nhận) + **claim-token thư sau cài app (D16)** + block-user enforce ở receive path; guard BR-05.
- **M1:** C3 letters composer + SM-016 gửi link.
- **M2:** C4 inbox + animation (D2 code, SPIKE) + reply.
- **I + M2:** D1 web viewer Cloudflare Pages + **D1.5 letter renderer parity (chốt letter-content schema contract NGAY ĐẦU phase)** + D3 deep-link native (iOS Associated Domains + Android App Links + AASA/assetlinks); D2.3 web animation 4 bước.
- **Gate ra:** người lạ mở link web (không app) thấy animation+nội dung+tem **render khớp app (font/màu đoạn/kẻ dòng — D1.5)**; người 2 → 410; đã cài → app tự mở; **người lạ mở web → cài app → đăng nhập → claim → thư trong Inbox và trả lời được (D16)**; sender nhận push "đã mở"; người nhận đăng nhập thấy Inbox + re-view không animation.

### Phase 4 — PREMIUM/IAP + PUSH · ~2–2.5 tuần · ~20–24 ED
- **M1:** C6 paywall + D5 RevenueCat (logIn firebaseUid, unlock tức thời, restore). ⚠️ SM-028 frame (D8) + giá (D1) + template count (D15).
- **M2:** D4 push 3 loại (topic MVP) + wire tap→màn + APNs; C8 share tem (5 nền tảng, Flow 6 frame D8); C5 sent box.
- **B:** A9 webhook idempotency (trước bật RevenueCat prod) + A11 device tokens; A5.4 profile CRUD.
- **Gate ra:** mua sandbox → Premium mở khóa <1s + webhook set đúng user; tạo tem 31 sau mua không bị chặn; 3 loại push đúng màn.

### Phase 5 — HARDENING + POSTGRES · ~2–2.5 tuần · ~18–22 ED
- **B:** A8 rate-limit + A10 structured log/OTel + A14 Postgres (nếu D13=trước launch hoặc auto-scale); A15 delete-grace/block/revoke. *(D5 tz đã làm từ Phase 0 trong A1 — Rev 2.)*
- **I:** E2.3 Cloud SQL + E2.4 multi-env + E6 observability/backup/runbook; E5.5 kill-switch.
- **M:** C7 home/profile/settings đầy đủ (9–11 ED) + C9 onboarding UI (SM-003); D6 offline guard hoàn thiện.
- **Gate ra:** cùng suite integration xanh trên Postgres (nếu port); alerting + backup + runbook diễn tập xong.

### Phase 6 — QA/E2E + RELEASE · ~2–2.5 tuần · ~18–22 ED
- **All:** E4.2 full app journey + E4.3 Maestro suite SM; Rive polish (D2.5) nếu asset sẵn; golden animation.
- **I + PO:** E3.3 wire signing; E5 store listing + privacy manifest/ATT + Sign in with Apple + UGC (D14); staged rollout.
- **Gate ra:** MVP launch gate (§10) xanh.

### Critical Path

```
A0 uploads + A0.1 auto-EnsureUser (Phase 0) ──► A6 OTP + B2 auth Firebase (Phase 1, NÚT THẮT ~9 ED)
   └► C1 stamp_creator (Phase 2, gốc loop ~22 ED)
        └► C3 composer + SM-016 (Phase 3)
             └► A17 inbox + C4 inbox/reply + D1 web viewer + D3 deep-link (Phase 3, đóng loop)
                  └► D5 IAP + D4 push (Phase 4)
                       └► A14 Postgres/hardening (Phase 5) ──► QA/E2E + Release (Phase 6)

Song song không trên critical path: C2 album (Phase 2), C6 stub (sớm), C8 share, C7 home/profile,
   C9 onboarding, D6 offline guard, E infra/CI (xuyên suốt).
```

**Điểm nghẽn cần quản lý:** (1) Auth Firebase (Phase 1) chặn mọi flow authenticated **và** phụ thuộc hợp đồng OTP/auto-EnsureUser của backend → **đồng bộ API contract B↔A ngay đầu Phase 1**. (2) C1 stamp_creator là gốc — spike canvas + assets phải sẵn. (3) A17 inbox persistence + claim D16 (gap P0 backend) phải xong đầu Phase 3 nếu không Flow 4 + Home badge + vòng "cài → trả lời" gãy.

---

## 6. Bản đồ E2E 7 Flows

**7 seam dùng chung (vỡ 1 seam → nhiều flow gãy):** S0-1 Firebase ID token→`smAuth`→auto EnsureUser (lazy, KHÔNG có `/ensure-user` route — phụ thuộc A0.1) · S0-2 R2 upload 3-hop presign→PUT→POST · S0-3 offline delta-sync (client mint id, retry 409=success) · S0-4 entitlement sync sau mua (webhook lag) · S0-5 web-host/universal-link consistency · S0-6 attribution/deferred deep-link + claim thư sau cài (D16) · S0-7 quota period tz + race.

| Flow | P | Chuỗi E2E gọn | Điểm mạnh ✅ / GAP 🔴 |
|---|---|---|---|
| **1 Khởi đầu** (Auth/Onboarding/Home) | P1 (OTP+S0-1 P0 kỹ thuật) | Splash→Register→OTP→auto-EnsureUser lazy→claim-username→avatar(R2)→Onboarding 1 lần (SM-003, C9)→Home. Social bỏ OTP. Restore Premium | ✅ auth-redirect, claim-username · 🔴 OTP endpoint (A6), auto-EnsureUser (A0.1), token audience (fix firebase_options), Onboarding UI (C9) |
| **2 Tạo tem** | **P0** | picker→filter(8 Free/8 Premium gate)→sticker→viền→preview→lưu (presign→PUT R2→POST stamps, quota 403) | ✅ StampsRepo save · 🔴 `internal/uploads` build (A0), quota atomic (A1) |
| **3 Soạn/gửi thư** | **P0** | template→soạn→đính tem(≤3/≥1)→preview→8 platform→createLink (single-use, TTL 7d; **−1 quota THƯ chỉ ở link ĐẦU TIÊN của thư — D11**) | ✅ **link Consume atomic** (điểm mạnh) · 🔴 ngữ nghĩa quota/link (D11), số template (D15) |
| **4 Nhận/đọc** | **P0** | link DM→app deep-link/web viewer→`GET /public/letter/{id}`(410 opened/expired, 404)→animation 4 bước→mark-read+push sender→Inbox/reply | ✅ `OpenLink` atomic · 🔴 **inbox persistence** (A17 — OpenLink không lưu record người nhận), **claim sau cài (D16)**, block-user enforce ở receive (A15), web viewer (D1) + renderer parity (D1.5) |
| **5 Quản lý/sưu tầm** | Album **P0** / Sent+Tem mẫu P1 | Album phẳng (`GET /stamps`), rename/delete; Sent trạng thái link, recreate link thư hết hạn **miễn phí quota (D11)**, chặn recreate thư đã đọc; tem mẫu Free dedupe | ✅ stamps sync · 🔴 `PATCH stamps` rename, guard BR-05, catalog tem mẫu |
| **6 Chia sẻ tem** | P1 (client-only) | Album→chọn tem→3 mức nội dung→toggle 9:16↔1:1→watermark cưỡng bức→`share_plus`/gallery (**5 nền tảng**) | ✅ export C1 · 🔴 frame .pen (D8), ít seam backend |
| **7 Tài khoản** | P2 | Profile(`GET /me`)→edit(PATCH — thiếu)→settings(đổi pw revoke, xóa grace 7d, block, push)→Premium(webhook S0-4) | 🔴 PATCH profile, delete+job, block-user (A15), revoke-sessions |

**Thứ tự dựng E2E:** (1) nền chung: uploads+auto-EnsureUser+firebase_options+OTP+backend HTTP suite → (2) loop lõi Flow 2→3→4 (+inbox persistence A17+viewer) → (3) hỗ trợ Flow 5 Album→Flow 1 hoàn thiện (+Onboarding) → (4) Flow 6→7 + push + dọn seal.

---

## 7. Production Readiness Checklist

**Hard gate (chặn launch)** · Nice-to-have (sau launch)

**Backend**
- 🔴 `go build ./...` xanh (A0) · 🔴 auto-EnsureUser lazy (A0.1) · 🔴 quota atomic (A1) · 🔴 graceful shutdown SIGTERM (A3) · 🔴 config fail-fast prod (A2) · 🔴 webhook idempotency trước RevenueCat prod (A9) · 🔴 inbox persistence + claim sau cài (A17/D16) · Migration versioned (A12) · Postgres (A14, tùy D13) · Rate-limit (A8) · legacy API tắt (A16)

**Client**
- 🔴 firebase_options project `stamp-mail` (B1.1) · 🔴 auth Firebase 4-provider (B2) · 🔴 offline guard §8 (D6) · 🔴 boundary tests xanh (B6) · gỡ orphan rewards/collections (B4) · session 90 ngày · design token 1 nguồn

**Infra**
- 🔴 deploy target đúng + DB bền (E2.1) · 🔴 wire signing (E3.3) · 🔴 backup DB ≤24h (E6.2) · multi-env (E2.4) · CDN domain · kill-switch

**Security**
- 🔴 JWT_SECRET fail-fast + Secret Manager (A4) · 🔴 CORS siết (A2) · 🔴 block-user enforce ở receive path (A15) · rate-limit (A8) · webhook verify/idempotency (A9) · cert pinning (✅) · không lộ email OTP (A6)

**Observability**
- 🔴 Crashlytics (✅ wired) · structured log→Cloud Logging (A10) · alert 4 golden signals + webhook fail (E6.1) · `/readyz` · OTel metrics · runbook (E6.3)

**Store**
- 🔴 Sign in with Apple (Apple 4.8, A6) · 🔴 privacy manifest + ATT + Data safety (E5.2) · 🔴 Info.plist camera/photo/tracking · 🔴 IAP compliance + Restore · 🔴 age ≥13 + UGC block (D14) · staged rollout

---

## 8. Credentials & External Accounts Checklist (blockers A)

| # | Tài khoản | Ai | Output artifact | Chặn | P |
|---|---|---|---|---|---|
| **A1** | Firebase project ×2 (dev/prod) — 4 provider Auth + FCM + service account | PO+B | `firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`; `FIREBASE_PROJECT_ID`+`GOOGLE_APPLICATION_CREDENTIALS`→Secret Manager | Auth, Push, verify token | P0 |
| **A2** | Cloudflare R2 bucket + S3 API token | PO | `R2_ACCOUNT_ID/BUCKET/ACCESS_KEY_ID/SECRET_ACCESS_KEY/PUBLIC_BASE_URL/S3_ENDPOINT`→Secret Manager | Upload ảnh, presign | P0 |
| **A3** | GCP + Cloud Run + Artifact Registry `stampmail` + WIF + deploy SA | PO+I | GH Variables `GCP_PROJECT_ID/REGION`; Secrets `GCP_WIF_PROVIDER/DEPLOY_SA` | Deploy backend | P0 |
| **A4** | Secret Manager runtime | I | `JWT_SECRET`, `REVENUECAT_WEBHOOK_AUTH`, `APPSFLYER_WEBHOOK_SECRET` + R2/Firebase | Backend prod an toàn | P0 |
| **A5** | Meta app (Facebook Login) | PO | `Info.plist` FacebookAppID + Android strings.xml | Provider Facebook | P1 |
| **A6** | Apple Developer ($99) — Sign in with Apple (.p8), App ID + Associated Domains, ASC API key, APNs .p8 | PO | `APPLE_TEAM_ID`, `APP_STORE_CONNECT_API_*`, `MATCH_*`, AASA | **Apple 4.8**, universal link, TestFlight, push iOS | P0 |
| **A7** | RevenueCat + products (chờ giá D1), entitlement `premium` | PO | Public API key→env; webhook secret→A4 | Premium SM-028/029 | P1 |
| **A8** | AppsFlyer (trả phí) + OneLink | PO+Growth | Dev key→client, OneLink subdomain, postback secret→A4 | Deferred deep-link + referral | P1 |
| **A9** | Domain (`stampmail.app`) + DNS + R2 CDN subdomain | PO | DNS; AASA + `.well-known/assetlinks.json` cạnh viewer | Web viewer + universal/app link + CDN | P0 |

---

## 9. Rủi ro & giảm thiểu

| # | Rủi ro | Mức | Giảm thiểu |
|---|---|---|---|
| R1 | **Spike editor canvas (C1.4)** — pro_image_editor có thể không khớp design/watermark cưỡng bức; native tốn công | Cao | Spike 2 ED dứt điểm **so 3 ứng viên** (pro_image_editor / `lindi_sticker_widget`·`sticker_editor_plus` / native `GestureTransformBox`) — nghiêng về canvas nhẹ nhúng wizard tự dựng theo .pen; prototype rotate+scale+clamp chạy iOS/Android; watermark trong ảnh capture (không overlay); pixelRatio cao |
| R2 | **Store review** — Apple 4.8 (thiếu Sign in with Apple → reject chắc), ATT/privacy manifest, UGC 1.2 (đã loại report) | Cao | A6 xong sớm; privacy manifest + ATT trước submit; xác minh D14 (có thể bổ sung report tối thiểu); IAP không link ngoài + Restore |
| R3 | **Quota race** vượt cap khi đồng thời | Trung | A1 conditional UPDATE atomic + test goroutine ×N |
| R4 | **Link single-use consume-on-load** — web reload → 410 dù chính người nhận | Trung | D1.4 cache localStorage render lại không animation; hoặc chốt đổi semantics (D-open) |
| R5 | **Animation 1 asset app+web** — code MVP phải làm 2 bản; Rive cần designer | Trung | Interface `LetterRevealController` chung; ship code Phase 3, nâng Rive Phase 6 khi có `.riv` |
| R6 | **Timeline aggressive, thiếu slack** — auth (nút thắt) + C1 (nặng nhất) + A17 inbox persistence (gap P0) trễ → loop trễ; mobile-only ~119 ED / 2 dev gần như không có buffer | Cao | Chốt API contract B↔A đầu Phase 1; stub SM-028 sớm; assets sớm hoặc placeholder+flag; backend HTTP e2e chạy trước UI; sẵn kế hoạch cắt phạm vi P2 nếu 2 mốc rủi ro (auth, C1) trượt |
| R7 | **Webhook out-of-order/lặp** downgrade sai tiền thật | Cao | A9 idempotency + event_timestamp guard trước bật RevenueCat prod; nếu multi-instance → Postgres trước launch |
| R8 | **SQLite ephemeral** trên Cloud Run mất data | Cao | Volume mount (E2.1) hoặc Cloud SQL; A12 migration tool sớm để port rẻ |
| R9 | **Cửa sổ lệch entitlement** sau mua (quota server-side vẫn Free) | Trung | D5.5 refresh endpoint hoặc chấp nhận độ trễ webhook vài giây (chốt) |
| R10 | **auto-EnsureUser chưa tồn tại** — nếu `smAuth` không tự provisioning, mọi call authenticated 404 sau đăng ký, auth Phase 1 gãy ngầm | Cao | A0.1 verify ngay Phase 0; nếu thiếu impl idempotent race-safe trước khi wire B2 |
| R11 | **Người lạ mở web → cài app KHÔNG claim được thư** (Rev 2) — link single-use đã consume anonymous, deferred deep-link mở app nhận 410 → persona lõi của vòng viral không có thư để trả lời | Cao | D16: open-token + `POST /api/sm/inbox/claim` (A17); OneLink mang token (D3); e2e claim nằm trong gate Phase 3 |
| R12 | **Render thư lệch app↔web** (Rev 2) — 2 renderer (Flutter + vanilla JS) cho cùng nội dung (font/màu đoạn/kẻ dòng/sticker/tem) | Trung | Chốt letter-content schema (Delta, tập attribute giới hạn) làm contract đầu Phase 3 (C0 ↔ D1.5); 4 font nhúng đủ glyph tiếng Việt; golden so sánh 2 nền |

---

## 10. Định nghĩa Done / MVP Launch Gate

**MVP "Done" khi TẤT CẢ hard gate xanh:**

**Kỹ thuật (build + loop lõi):**
1. `go build ./...` + CI backend + Flutter CI xanh; boundary/layering tests xanh.
2. Backend HTTP e2e + full app integration journey **tạo tem → gửi link → mở web (không app) → cài → trả lời** xanh trên thiết bị thật.
3. Vòng lan truyền chạy end-to-end: presign R2 round-trip, quota atomic enforce (Free 30 tem/10 thư — theo THƯ, D11), link single-use + TTL 7d, inbox persistence + claim thư sau cài app (A17/D16) + re-view không animation, nội dung thư render khớp app↔web (D1.5), push "đã mở" tới sender.

**Auth + Premium:**
4. Đăng nhập 4 provider (tối thiểu Email+OTP+Google+Apple) → `/api/sm/*` trả 200 (auto-EnsureUser lazy hoạt động); auto-restore Premium.
5. Mua Premium (RevenueCat) mở khóa tức thời + webhook set đúng user + idempotent; hết kỳ về Free giữ dữ liệu.

**Production hardening:**
6. Graceful shutdown + config fail-fast + Secret Manager + rate-limit + CORS siết; DB bền (volume/Cloud SQL) + backup ≤24h + restore diễn tập; block-user enforce ở luồng nhận thư.
7. Crashlytics + structured log + alert 4 golden signals; runbook rollback/kill-switch.

**Store:**
8. Sign in with Apple hoạt động; privacy manifest + ATT + Data safety khớp SDK thật; age ≥13 + UGC block; IAP compliance + Restore; build ký + upload TestFlight/Play internal.

**Đóng tất cả OPEN DECISIONS blocking** (D1 giá, D2 animation, D3 host, D4 seal, D6 viền, D7 pw, D11 quota, D13 Postgres, D14 UGC, D15 template count — trước Phase 4, **D16 claim thư — trước Phase 3**) trước phase tương ứng.

> **Launch = staged rollout** (Play 5%→100%, iOS phased 7 ngày) sau khi 8 hard gate xanh + crash-free rate theo dõi ổn định ở internal/TestFlight.
# StampMail — Plan triển khai End-to-End (chi tiết, chờ duyệt)

**Tạo**: 2026-07-07
**Mục tiêu**: Đưa app chạy **end-to-end thật** toàn bộ luồng nghiệp vụ (Phase 0→7),
**cloud thật** (Cloud Run + Cloudflare R2 + Firebase Auth/FCM).
**Trạng thái**: ✅ **ĐÃ DUYỆT + đang thực thi.** Cập nhật tiến độ 2026-07-17 ở mục dưới.

## Tiến độ thực thi (2026-07-17)

> Bảng này soát lại **từ code thực tế** ngày 2026-07-17. Bản trước (07-07) đã lệch xa:
> nó ghi client Flutter ~5% trong khi 4/5 feature package đã có UI đầy đủ, và đánh
> Phase 1 là "chờ Firebase config" trong khi `firebase_options.dart` đã là giá trị
> thật của project `stampmail-dev`.
>
> **Đọc ✅ cho đúng**: ✅ = luồng chạy thật, có UI, analyze + test xanh. Không phải
> "data layer xong". Ở bản 07-07, ✅ **loại trừ toàn bộ UI** — nay thì không.

Blocker gom ở [blockers.md](blockers.md) — phần lớn là **credentials, không phải code**.

| Phase | Trạng thái | Ghi chú |
|---|---|---|
| **0 — Nền** | ✅ | shared_contracts, R2 presign (`internal/uploads`), webhook verify, Dockerfile+CloudRun, design tokens. Postgres hoãn (TD-003) |
| **1 — Auth client** | ✅ ~85% | Firebase Auth SDK **thật**, `firebase_options.dart` = `stampmail-dev` thật, email + Google chạy. ❌ **Apple + Facebook mới là snackbar "sắp ra mắt"** |
| **2 — Tem + Album** | ✅ | `feature_album` (offline-first, delta sync) **và** `feature_stamp_creator` (wizard đủ 5 bước, upload R2 thật qua presign). `pro_image_editor` spike: đã đi hướng native Stack/Matrix4 |
| **3 — Gửi/Nhận thư + Web** | ✅ ~80% | `feature_letters` (10 màn hình) + `feature_letter_inbox` + web viewer. Undo/redo (07-17) và **web viewer render Delta** (07-17) đã xong — trước đó người nhận mất trắng mọi định dạng. ❌ Sticker vẫn **chỉ là UI** (xem D8: cần chốt BR-05 + host ảnh). Animation CSS placeholder (B2) |
| **4 — Push** | ✅ ~60% | FCM client thật — **nằm ở `packages/app_platform`**, không phải `features/notifications` (cái đó là rác template). Topic + tap-routing + màn hình tuỳ chọn đều chạy. Thiết kế push là **topic-based**, không cần device-token |
| **5 — Premium** | 🔴 ~15% | Chỉ `EntitlementReader` + cache. ❌ Không paywall, ❌ không RevenueCat SDK, ❌ `isPremium` **hardcode `false`** ở `router.dart:126/:329` → gating không hoạt động. Spec mới đánh SM-028/029 `⏸️ Tạm disable v1` |
| **6 — P1/P2** | 🟡 ~70% | "Đăng xuất tất cả thiết bị" đã thật (revoke refresh token, 07-17). ❌ **Xoá tài khoản vẫn giả** (bấm xác nhận chỉ đóng sheet; `DeleteAccountCubit` đã có + có test nhưng chưa nối). Ngôn ngữ/âm thanh liệt |
| **7 — Ra mắt** | ⏸️ | Chờ credentials + native config |

**Bằng chứng luồng lõi chạy thật**: `maestro/stampmail/` (login → tạo tem → gửi thư → nhận link → "Đã mở") bắn vào backend dev thật, assert cả upload R2. Đây là bằng chứng mạnh nhất, không phải tự nhận.

**Đã build/analyze/test xanh (07-17)**: backend Go `build`+`vet`+`go test -race` toàn bộ pass; app `flutter analyze` **No issues found**; auth 64 test, letters 79, root 38, architecture 12 — tất cả pass.

### Chặn deploy thật (không phải thiếu tính năng)

- 🔴 **Firebase native config sai project**: `firebase_options.dart` = `stampmail-dev` (sender `725681265816`) nhưng `GoogleService-Info.plist` ở root = project `stamp-mail` (sender `975726644424`). Plist lại nằm sai chỗ — đường dẫn iOS build đọc (`ios/Runner/GoogleService-Info.plist`) đang bị gitignore. **Không có `google-services.json`** cho Android.
- ⚠️ `integration_test/` vẫn là code template cũ 100% (bookmarks/collections) — **zero coverage StampMail**. E2E thật chỉ có ở `maestro/stampmail/`.
- ⚠️ `web_letter/` **không có test nào trong repo** và CI không đụng tới. Delta renderer (07-17) verify bằng headless Chrome thủ công.

---


> Plan này là nguồn sự thật cho việc thực thi. Bám `data-model.md` + `tech-stack.md`
> (bản đảo hướng 07-07: Go server + R2, KHÔNG Firestore/Cloud Functions).
> `implementation-plan.md` (07-06) đã lỗi thời ở phần backend — sẽ cập nhật lại ở cuối.

---

## 0. Thực trạng đã khảo sát — ẢNH CHỤP 2026-07-07 (lịch sử, KHÔNG phải hiện tại)

> ⚠️ **Đây là điểm xuất phát ngày 07-07, giữ lại để đối chiếu — đừng đọc như trạng
> thái hôm nay.** Mọi con số dưới đây đã lỗi thời:
> - "Flutter client ~5%" → thực tế 07-17 là **~75%**, 4/5 feature package có UI đầy đủ
> - "6 feature package chưa tồn tại" → **đã tồn tại đủ cả 6**
> - "`firebase_options.dart` = placeholder" → **đã là giá trị thật** của `stampmail-dev`
> - "Web viewer 0%" → **đã có** `web_letter/`, và từ 07-17 render được cả Delta
> - "R2 presign chưa có" → **đã có** `internal/uploads` + `POST /api/sm/uploads/presign`
>
> Trạng thái hiện tại: xem bảng **Tiến độ thực thi (2026-07-17)** ở đầu file.

Khác hẳn ước lượng ban đầu — backend đã đi rất xa:

| Tầng | % | Chi tiết |
|---|---|---|
| **Go backend** business logic | **~85%** | domain + storage/sqlite + service (LetterLink OpenLink transaction 1-lần/7-ngày, Quota 30/10, Attribution idempotent (ghi nhận nguồn giới thiệu), Entitlement, ProfileService lockout 5-lần/15-phút, ClaimUsername unique). **Build OK, tests pass.** 14 SM handlers + routes đủ. |
| **Backend gap** | — | ❌ R2 presign (chưa có, đang dùng `/api/upload` local) · ❌ webhook signature verify (đánh dấu `ponytail:` chưa wire) · ❌ Postgres driver (mới SQLite) · ⚠️ auth REST cũ `/api/auth/*` còn song song `/api/sm/*` |
| **Flutter client** | **~5%** | Chỉ UI auth/onboarding (preview mode). Auth data layer vẫn nối `/api/auth/*` REST cũ. 6 feature package (stamp_creator/album/letters/letter_send/letter_inbox/premium) **chưa tồn tại**. `shared_contracts` chưa có Entitlement/StampRef/QuotaReader. `firebase_options.dart` = placeholder `your-firebase-project`. |
| **Web viewer thư** | **0%** | `web/` chỉ là Flutter web shell mặc định — chưa có trang riêng (TD-011). |
| **Animation mở thư** | **0%** | Chưa chốt Rive/Lottie, chưa asset (TD-010). |

**Hệ quả cho plan**: trọng tâm còn lại là **client Flutter + web viewer + animation + hạ tầng cloud thật**, không phải viết lại backend. Backend chỉ cần *bịt gap* (presign, webhook verify, Postgres) — không xây lại.

**Khuôn mẫu tái dùng**: `packages/features/collections` là blueprint offline-first hoàn chỉnh
(data/domain/presentation + sync adapter + SyncController + DI module). Mỗi feature mới clone khuôn này.

---

## PHASE 0 — Nền móng cloud thật + hợp nhất auth

Mục tiêu: mọi credential thật sẵn sàng; auth client chuyển sang `/api/sm/*` + Firebase.

### 0.1 — Việc CỦA BẠN (blocker, tôi không tự làm được)
- [ ] **Firebase project** (dev + prod): bật Authentication (Email/Password, Google, Apple, Facebook) + FCM. Tải `google-services.json` (Android) + `GoogleService-Info.plist` (iOS) → gửi tôi, hoặc chạy `flutterfire configure` cùng tôi.
- [ ] **Cloudflare R2**: tạo bucket + API token → cung cấp `R2_ACCOUNT_ID`, `R2_BUCKET`, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, `R2_PUBLIC_BASE_URL` (xem `r2-setup.md`).
- [ ] **GCP project + Cloud Run**: quyền deploy (tôi viết Dockerfile + CI; bạn cấp service account/quyền).
- [ ] **Meta app** (Facebook Login) + **Apple Sign-In** cấu hình (cần Apple Developer account).
- [ ] **RevenueCat** account + **AppsFlyer** account (dùng ở Phase 5/3; cần trước khi tới đó).
- [ ] Domain cho universal link + trang web xem thư (Firebase Hosting hoặc Cloudflare Pages).

### 0.2 — Tôi làm (không cần chờ credentials) — ✅ XONG 2026-07-07
- [x] **`shared_contracts`**: `Entitlement`+`EntitlementReader`, `StampRef`, `QuotaRemaining`+`QuotaReader`. Analyze sạch, export barrel.
- [x] **Design tokens + theme**: `app_ui` đã hoàn chỉnh — `AppTheme.light/dark` dùng `StampMailColors` + `SemanticColors`/`BrandColors` extensions + Google Fonts (Baloo2/BeVietnamPro). Đủ token elevation/icon/radius/spacing. (Phần lớn đã có sẵn.)
- [x] **Backend — bịt gap hạ tầng**:
  - [x] R2 adapter (`internal/uploads`, AWS SDK v2) + `POST /api/sm/uploads/presign` → `{upload_url, public_url, key}`; `Local` fallback trỏ `/api/upload` khi thiếu R2 env.
  - [x] Webhook signature verify (RevenueCat `Authorization` + AppsFlyer secret header/query) — `secretMatches` constant-time, skip khi secret rỗng (dev). Có test.
  - [~] **Postgres driver — HOÃN tới Phase 5** (chỉ prod đa-instance cần; E2E chạy đủ trên SQLite; transaction OpenLink đã race-safe trên PG). Ghi decision ở `tech-stack.md` TD-003.
  - [x] Dockerfile (distroless, CGO_ENABLED=0, **image build OK**) + `.dockerignore` + `.github/workflows/backend-deploy.yml` (Cloud Run + WIF, skip khi chưa có GCP vars). Server đọc `PORT`/`DB_PATH` cho Cloud Run.
- [ ] **Gỡ auth REST cũ khỏi luồng**: đánh dấu `/api/auth/*` deprecated — làm ở Phase 1 khi client chuyển sang Firebase.

**Nghiệm thu Phase 0**: backend build + test xanh, image Docker build OK. Deploy thật lên Cloud Run + presign R2 thật = chờ credentials của bạn (mục 0.1).

---

## PHASE 1 — Auth Firebase trên client (SM-000)

Slice: mở app → đăng ký/đăng nhập 4 phương thức → ensure-user → chọn username → session → Home rỗng.

- [ ] `feature_auth` **thay data layer**: thêm `firebase_auth`, `google_sign_in`, `sign_in_with_apple`, `flutter_facebook_auth`. Datasource mới `AuthFirebaseDataSource` (đăng nhập → ID token) thay `auth_remote_data_source` REST. Giữ nguyên `AuthBloc`/`Session` contract (chỉ thay ruột repository).
- [ ] Nối `/api/sm/*`: sau đăng nhập Firebase → gọi `POST /api/sm/...ensure-user` (backend `ProfileService.EnsureUser`), `POST /api/sm/claim-username`, `GET /api/sm/me`.
- [ ] Middleware client: mọi request `/api/sm/*` gắn `Authorization: Bearer <firebase_id_token>` (interceptor trong `network` package).
- [ ] Wire các màn đã có UI vào logic thật: `choose_username_screen` (nối claim-username + username_taken), `verify_email_screen` (xác nhận email bằng mã OTP 6 số — BR-02; hiệu lực 5 phút, gửi lại sau 120s; backend tự phát/verify), `forgot_password_screen` (đặt lại mật khẩu bằng mã OTP 6 số — BR-12; nhập mã → đặt mật khẩu mới), `change_password_screen`. (Firebase chỉ bật Email/Password; OTP do backend gửi, KHÔNG dùng email link của Firebase.)
- [ ] Khoá 5-lần/15-phút: client hiển thị đếm ngược từ `CheckLock`/`RecordFailure` (backend đã có).
- [ ] Link/unlink provider (giữ ≥1) — `linkWithCredential` client + check server.
- [ ] Offline guard: chặn thao tác auth khi mất mạng, giữ form.
- [ ] Router redirect theo Session.

**Nghiệm thu**: đăng nhập thật cả 4 provider trên máy thật → user row tạo ở backend → Home. AC-01→35 SM-000. Test theo khuôn test feature auth có sẵn.

---

## PHASE 2 — Tạo tem end-to-end + Album (SM-005, 006, 008, 009, 010, 011, SM-022) 🔴 lõi MVP

Slice: Home → chụp/chọn ảnh → lọc màu → trang trí → viền → xem trước → lưu vào Album → thấy trong Album (offline).

- [ ] **Spike 1 buổi** (TD-004): `pro_image_editor` — nhét được watermark + gating + viền không? Ghi kết quả vào `tech-stack.md`. (Quyết trước khi code editor.)
- [ ] **`feature_stamp_creator`** (clone khuôn collections, phần presentation nặng):
  - SM-005: `image_picker` + zoom (InteractiveViewer), giới hạn size (TD-009), permission flow (`permission_handler` có sẵn).
  - SM-006: 16 filter (`color_filter_extension`) + 3 thanh ColorMatrix; gate 8 filter Premium (đọc `Entitlement` từ `/api/sm/entitlement`).
  - SM-008: sticker/chữ/icon kéo-xoay-phóng (kết quả spike); gate sticker đặc biệt CHỈ bằng Premium (đọc `Entitlement`).
  - SM-009: viền/khung (đọc spec `008-vien-khung-tem` khi làm); gate viền khóa CHỈ bằng Premium (đọc `Entitlement`).
  - SM-010/011: xem trước đa nền → `RepaintBoundary`→PNG + **watermark cưỡng bức** → presign R2 upload → `POST /api/sm/stamps` (backend check quota 30/tháng qua `QuotaService`).
- [ ] **`feature_album`** (SM-022, clone collections offline-first): lưới "Tất cả/Tự tạo/Nhận được" (suy từ `stamps.source`), chi tiết tem, sync ObjectBox ↔ `/api/sm/stamps` (rev cursor). Album tùy chỉnh CRUD `/api/sm/albums`.
- [ ] Nút "Chia sẻ tem" (SM-025): `share_plus` + watermark cưỡng bức.

**Nghiệm thu**: người dùng thật tạo tem từ ảnh → thấy trong Album; offline vẫn trang trí + xem album.

---

## PHASE 3 — Gửi & nhận thư + Web viewer + Animation (SM-012→017, 019) 🔴 lõi lan truyền

Slice: chọn tem từ Album → soạn thư tối giản → tạo link → gửi DM → người nhận mở **web** → animation → (cài app → tem vào Album) → người gửi nhận noti "đã mở".

- [ ] **`feature_letters`** (bản tối thiểu P0): 1–2 template, soạn text (SM-013 rút gọn), đính ≤3 tem (SM-014), xem trước (SM-015 rút gọn). `POST /api/sm/letters`.
- [ ] **`feature_letter_send`** (SM-016): chọn nền tảng (8 MXH), `POST /api/sm/letters/{id}/links` (backend `CreateLink`, quota 10/tháng), URL scheme mở DM + fallback copy link (`share_plus`). AppsFlyer OneLink làm URL.
- [ ] **Web xem thư** (TD-011 — **chốt stack tại đây**): đề xuất **HTML+JS thuần** host Firebase Hosting/Cloudflare Pages, gọi `GET /public/letter/{id}` (backend `OpenLink` transaction 1-lần/7-ngày đã có). Trạng thái đã-đọc/hết-hạn/không-hợp-lệ.
- [ ] **Animation mở thư** (TD-010 — **chốt Rive/Lottie tại đây**): 1 asset chạy app + web. Âm thanh nhẹ. Nghiêng Rive (1 asset 2 runtime).
- [ ] **`feature_letter_inbox`** (P0): mở thư trong app qua `app_links` (universal link); tem từ thư → Album sau đăng nhập (SM-017 BR-05).
- [ ] **AppsFlyer SDK** + deferred deep link: cài từ link → app mở đúng thư (SM-017) + attribution (ghi nhận nguồn giới thiệu, 014 BR-09).

**Nghiệm thu**: 2 máy thật — A gửi qua Zalo/Messenger, B (chưa cài) mở web thấy animation, cài app, tem về Album, A nhận noti "đã mở thư".

---

## PHASE 4 — Thông báo push (SM-026)

Slice: sự kiện gửi/mở thư → noti FCM đúng loại → deep-link mở đúng màn.

- [ ] **`feature_notifications` → FCM**: 5 loại noti + preference bật/tắt + deep-link đúng màn (SM-026). Backend `NotificationService` đã có.

**Nghiệm thu**: noti "đã mở thư" tới máy người gửi; bật/tắt preference + deep-link đúng màn trên 2 máy thật.

---

## PHASE 5 — Premium & tiền (SM-028, 029, 030)

- [ ] **`feature_premium`**: paywall Free/Premium, gói tháng/năm (RevenueCat `purchases_flutter`), mở khoá tức thì, quản lý/huỷ, restore khi đăng nhập (SM-000 BR-17).
- [ ] `Entitlement` hoàn chỉnh: RevenueCat webhook → `POST /api/webhooks/revenuecat` → `EntitlementService.Apply` (đã có) → gate stamp_creator/letters đọc `/api/sm/entitlement`; cache offline (SM-006 BR-08).
- [ ] SM-030: nhắc hạn mức (còn N tem/thư từ `QuotaService.Remaining`), reset ngày 1 (period string), noti hạn mức.

**Nghiệm thu**: mua sandbox iOS + Android, restore máy thứ hai, gate mở đúng.

---

## PHASE 6 — Hoàn thiện P1/P2 (song song hoá được)

- [ ] SM-020 Trả lời thư (nối inbox → soạn thư).
- [ ] SM-025 Chia sẻ tem đầy đủ · SM-035 Bộ tem mẫu đầy đủ (TOÀN BỘ FREE, không có phần khóa).
- [ ] SM-003 Onboarding + SM-004 Home hoàn chỉnh (thay scaffold).
- [ ] SM-012/013/014/015 đầy đủ (template, font, màu giấy, kẻ dòng, sticker trên thư).
- [ ] SM-018 Inbox + SM-021 Hộp đã gửi đầy đủ.
- [ ] SM-024 Hồ sơ + SM-027 Cài đặt (thay ruột `profile`); xoá tài khoản (BR-26/AC-33).
- [ ] SM-022 Album đầy đủ: album tùy chỉnh, chế độ chỉnh sửa, xoá/di chuyển tem.

---

## PHASE 7 — Ra mắt

- [ ] Gỡ `collections`/`bookmarks` demo + auth REST cũ `/api/auth/*`.
- [ ] Hardening: security rules/authz review, rate limit, App Check (nếu dùng), webhook secret enforce.
- [ ] Store listing, privacy manifest (Apple), Data Safety (Google), compliance Facebook/Apple Sign-In.
- [ ] Analytics funnel (tạo→gửi→mở→cài) + Crashlytics.
- [ ] Beta TestFlight/Internal → fix → release.

---

## Thứ tự phụ thuộc

```
P0 (nền+auth-infra) → P1 (auth client) → P2 (tem+album) ─┬→ P3 (thư+web+anim) → P4 (push) → P5 (Premium)
                                                          └→ (Album cùng P2)
P6 (P1/P2 đầy đủ) song song sau P4 · P7 ra mắt cuối
```

- Auth trước tất cả (mọi spec "đã đăng nhập" là tiên quyết).
- Tạo tem trước thư (thư bắt buộc đính tem).
- Push sau thư (noti "đã mở" từ luồng thư; backend `NotificationService` đã ghi sẵn, P4 bật UI).
- Premium sau tạo tem (paywall cần gate sticker/viền đã tồn tại).

---

## Quyết định còn treo (chốt tại phase ghi kèm)

| # | Việc | Chốt tại | Ghi chú |
|---|---|---|---|
| 1 | Stack render web xem thư | Phase 3 tuần 1 (TD-011) | Đề xuất HTML+JS thuần |
| 2 | Rive vs Lottie | Phase 3 (TD-010) | Nghiêng Rive |
| 3 | Kết quả spike `pro_image_editor` | Phase 2 buổi đầu (TD-004) | Fallback native Stack+Matrix4 |
| 4 | Chi tiết viền/khung tem | Phase 2 (đọc spec `008-vien-khung-tem`) | |
| 5 | Giá gói Premium | Trước Phase 5 | **Business bạn quyết** |

---

## Điểm khác biệt so với `implementation-plan.md` (cần bạn xác nhận)

`implementation-plan.md` (07-06) viết **Firestore + Cloud Functions**. Nhưng
`tech-stack.md`/`data-model.md` (07-07) + backend thực tế đã **đảo sang Go server + R2**.
Plan này bám bản mới. → Sau khi bạn duyệt, tôi sẽ **cập nhật `implementation-plan.md`** cho khớp
(hoặc đánh dấu nó lỗi thời, trỏ sang file này).

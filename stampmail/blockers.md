# StampMail — Blockers (cần bạn xử 1 lượt)

**Tạo**: 2026-07-07
**Mục đích**: Gom mọi thứ **tôi không tự làm được** (cần credentials, tài khoản
bên thứ ba, quyết định business, hoặc native config) để bạn xử lý một lượt. Sau
khi có các mục này, phần lớn code đã sẵn sàng chạy end-to-end thật.

> Trạng thái code: backend Go + 4 feature package client (album, letters,
> premium, letter_inbox) + web viewer **đã build/analyze/test xanh**.
> Các mục dưới đây là cái chặn "chạy thật trên cloud", không phải chặn code.

---

## A. Credentials / tài khoản (chặn deploy + chạy thật)

| # | Việc | Dùng ở | Env / file cần |
|---|------|--------|----------------|
| A1 | **Firebase project** (dev+prod): bật Authentication (Email/Password, Google, Apple, Facebook) + FCM | Auth, Push | `google-services.json` (Android), `GoogleService-Info.plist` (iOS), `FIREBASE_PROJECT_ID`, `GOOGLE_APPLICATION_CREDENTIALS` (server verify ID token) |
| A2 | **Cloudflare R2** bucket + API token | Ảnh tem/avatar | `R2_ACCOUNT_ID`, `R2_BUCKET`, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, `R2_PUBLIC_BASE_URL` (xem `r2-setup.md`) |
| A3 | **GCP + Cloud Run**: project, region, Artifact Registry `stampmail`, Workload Identity provider + deploy service account | Deploy backend | Repo **Variables**: `GCP_PROJECT_ID`, `GCP_REGION`; **Secrets**: `GCP_WIF_PROVIDER`, `GCP_DEPLOY_SA` (workflow `.github/workflows/backend-deploy.yml` đã sẵn, tự skip tới khi có) |
| A4 | **Secret Manager** cho Cloud Run runtime | Backend prod | `JWT_SECRET`, `REVENUECAT_WEBHOOK_AUTH`, `APPSFLYER_WEBHOOK_SECRET` + toàn bộ R2_* / FIREBASE (workflow map sẵn từ Secret Manager) |
| A5 | **Meta app** (Facebook Login) | Auth | Facebook App ID + config native (Info.plist / strings.xml) |
| A6 | **Apple Developer** account | Sign in with Apple (bắt buộc khi có social login) + universal link | Service ID, key, entitlements |
| A7 | **RevenueCat** account + products (gói tháng/năm) | Premium | RevenueCat API key (client), webhook auth secret (A4) |
| A8 | **AppsFlyer** account (bản trả phí đã có) + OneLink | Deferred deep link + attribution (ghi nhận nguồn giới thiệu) | AppsFlyer dev key, OneLink template, postback secret (A4) |
| A9 | **Domain** cho link thư + trang web xem thư | Web viewer + universal link | Ví dụ `stampmail.app`; trỏ `/letter/*` → `web_letter/index.html` |

---

## B. Quyết định business (chặn phần liên quan)

| # | Quyết định | Chặn |
|---|-----------|------|
| B1 | **Giá gói Premium** (tháng/năm) | Paywall (Phase 5) — cấu hình RevenueCat |
| B2 | **Animation mở thư**: giữ CSS thuần (đã làm, nhẹ) hay đầu tư 1 asset **Rive/Lottie** (đẹp hơn, dùng lại cả app + web)? | Trải nghiệm cốt lõi SM-017. Web viewer hiện dùng CSS placeholder (`web_letter/`) — chạy được ngay; nâng cấp Rive cần asset designer |
| B3 | **Stack host web viewer**: Firebase Hosting hay Cloudflare Pages? | Deploy `web_letter/` (A9) |

---

## C. Native config (chặn deep link + build store)

| # | Việc | Ghi chú |
|---|------|---------|
| C1 | Universal Link (iOS) / App Link (Android) association files | `apple-app-site-association` + `assetlinks.json` đặt cạnh web viewer; cần App ID (A6) + package name |
| C2 | `app_links` native setup (intent-filter Android, associated domains iOS) | Cho letter_inbox mở thư in-app |
| C3 | `image_picker` + `permission_handler` Info.plist strings (camera/photo) | Stamp creator (khi làm UI) |
| C4 | Facebook/Google/Apple sign-in native config | Sau A1/A5/A6 |

---

## D. Việc CODE còn lại (không chặn bởi bạn — tôi làm tiếp khi bạn muốn)

Những mục này tôi hoãn có chủ đích, **không** vì thiếu credentials mà vì thứ tự
hợp lý / tránh làm thừa:

| # | Việc | Vì sao hoãn |
|---|------|-------------|
| D1 | **Auth client → Firebase Auth SDK** (4 provider) + nối `/api/sm/*` | Cần A1 config files để chạy/test thật; UI auth đã có sẵn. Data layer swap làm khi có A1 |
| D2 | **Postgres driver** (`storage/postgres`) | Chỉ prod đa-instance cần; E2E chạy trên SQLite. Làm ở Phase 5 (xem `tech-stack.md` TD-003) |
| D3 | **RevenueCat purchase flow** (`purchases_flutter`) | Cần A7 keys; `EntitlementReader` (đọc trạng thái) đã xong, chỉ thiếu luồng mua |
| D4 | **AppsFlyer SDK** client init + deferred deep link | Cần A8; webhook backend đã xong |
| D5 | **Toàn bộ UI** các feature (stamp editor, album grid, letter composer, paywall...) | Bạn dặn "bỏ lại UI". Data/domain/wiring đã sẵn cho UI cắm vào |
| D6 | **stamp_creator** editor (image_picker, filter, sticker, viền, xuất PNG + watermark) | Chủ yếu là UI + `pro_image_editor` spike (TD-004). Backend save-stamp + presign + album đã sẵn |

---

## E. Nợ có sẵn (pre-existing, không do phần này tạo)

| # | Việc | Ghi chú |
|---|------|---------|
| E1 | `feature_onboarding` test lỗi (4 error: `heroAsset`/`icon`) | Do UI onboarding sửa ở commit trước (`3db72f8d`) mà chưa cập nhật test. Sửa = đụng UI |

---

## Sau khi bạn cấp A + quyết B, thứ tự tôi chạy tiếp

1. **A1 (Firebase)** → D1 auth client → chạy thật đăng nhập.
2. **A2 (R2) + A3/A4 (Cloud Run)** → deploy backend staging → presign upload thật.
3. **A9 + B3** → deploy `web_letter/` → mở thư thật trên web.
4. **A7/A8 + B1** → D3/D4 → Premium + attribution (ghi nhận nguồn giới thiệu) thật.
5. (Khi cần) D2 Postgres, D5/D6 UI.

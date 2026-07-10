# StampMail — Quyết định công nghệ (Tech Decisions)

**Cập nhật lần cuối**: 2026-07-07
**Trạng thái**: Chốt sơ bộ cho MVP (P0/P1). **2026-07-07: đảo hướng backend từ Firebase/Firestore sang Go server (Cloud Run) — xem TD-001.**

> Tài liệu này ghi lại **các quyết định về công nghệ/thư viện** cho StampMail và **lý do** đằng sau. Mỗi mục nêu: quyết định, vì sao, phương án đã loại. Khi làm từng feature, tra ở đây trước khi thêm dependency mới. Cập nhật khi có quyết định mới hoặc đảo ngược quyết định cũ (ghi rõ ngày + lý do đảo).
>
> Nguyên tắc xuyên suốt: **dùng thứ template đã wire sẵn trước; native/stdlib trước dependency; chỉ thêm SDK bên thứ ba cho phần thực sự không tự làm nổi.**

---

## Bảng tổng hợp nhanh

| Lĩnh vực | Quyết định | Loại |
|----------|-----------|------|
| Backend | **Go server** (mở rộng `simple_backend_server`) → **Cloud Run** | tự host, có sẵn |
| DB server | **SQLite (dev) → Postgres/Cloud SQL (prod)**, cùng interface repository | tự host |
| Server logic (link thư, cấp Dấu, referral, IAP) | Go service layer (không phải Cloud Functions) | tự viết |
| Auth | **Firebase Auth (4 provider) + Go verify ID token** | SaaS + tự host |
| Kho ảnh (tem/avatar) | **Cloudflare R2** (S3-compat, presigned URL) — KHÔNG Firebase Storage | SaaS |
| Client ↔ server | REST/Dio (data layer template đã có) | có sẵn |
| Web xem thư | Trang riêng (KHÔNG Flutter Web) — cách render chốt sau (TD-011) | quyết |
| Push | FCM (`firebase_messaging`) | SaaS + client |
| Local DB | ObjectBox | template có sẵn |
| Deep link (đã cài app) | `app_links` | client, miễn phí |
| Deferred deep link + referral | **AppsFlyer OneLink** | SaaS |
| IAP Premium + restore | **RevenueCat** (`purchases_flutter`) | SaaS |
| Chụp/chọn ảnh | `image_picker` | client |
| Quyền hệ thống | `permission_handler` | template có sẵn |
| Filter màu (SM-006) | `color_filter_extension` (MIT, free) | client |
| Editor sticker/chữ (SM-007) | `pro_image_editor` (BSD-3, free) — thử trước, fallback native | client ⚠️ spike |
| Xuất tem PNG + watermark | Native `RepaintBoundary` (tự làm, package không lo) | không dependency |
| Animation mở thư | Rive/Lottie (nghiêng mạnh) — chốt khi làm slice (TD-010) | ⚠️ gần chốt |
| Native share sheet | `share_plus` | client |

---

## TD-001 — Backend: Go server (Cloud Run), KHÔNG Firestore

> **2026-07-07 — ĐẢO HƯỚNG.** Bản đầu chốt Firebase toàn phần (Firestore + Cloud Functions). Sau khi khảo sát repo phát hiện `simple_backend_server` là **Go backend hoàn chỉnh** (auth JWT, kiến trúc domain/service/transport/storage sạch, có tests, **sync protocol offline-first sẵn** với `rev`+`deleted_at`). Vứt đi để viết lại Firestore đi ngược "dùng lại cái đã có". Quyết định mới bên dưới.

**Quyết định**: Backend là **Go server**, mở rộng `simple_backend_server`, deploy lên **Cloud Run**.
- **Runtime**: Cloud Run (container Docker). Cloud Run chạy nguyên server đa-endpoint (chi router) — hợp hơn Cloud Functions Gen2 (hợp app 1-vài function). Cả hai đều chạy Go; Firebase Functions "cổ điển" (`firebase deploy`) thì KHÔNG có Go, chỉ Node/Python.
- **DB**: SQLite (`modernc.org/sqlite`, pure-Go) cho **dev/local**; **Postgres/Cloud SQL** cho **prod**. Tầng `storage/` đã tách theo repository interface → đổi driver = thêm `storage/postgres`, không đụng domain/service.
- **Client ↔ server**: REST/Dio — data layer template hiện có (`auth_remote_data_source`, `network` package) dùng lại, không viết lại sang Firebase SDK.

**Vì sao**:
- Tận dụng Go backend sạch đã có (auth, sync delta, repository pattern) — tiết kiệm phần lớn Phase 0–1.
- Cloud Run: serverless (autoscale, trả theo request), giữ nguyên Go, cùng hệ GCP với Firebase Auth/FCM/Storage.
- Postgres prod: SQLite là file cục bộ → không share giữa nhiều Cloud Run instance; logic tiền (Dấu) + link-1-lần cần transaction row-level (`SELECT FOR UPDATE`) mà SQLite khoá cả file.

**Firebase VẪN dùng cho** (không phải toàn phần): **Auth** (TD-002), **FCM** push (TD-008), **Cloud Storage** ảnh tem. KHÔNG dùng Firestore, KHÔNG dùng Cloud Functions.

**Đã loại**:
- **Firestore + Cloud Functions**: viết lại từ đầu trong khi đã có Go backend tương đương — YAGNI ngược.
- **SQLite ở prod**: không share qua nhiều instance Cloud Run.
- **Cloud Functions Gen2 (Go)**: chạy Go được nhưng hợp app ít-function; server đa-route này hợp Cloud Run hơn.

**Ràng buộc phát sinh**: logic "link 1 lần / hết hạn 7 ngày", sổ cái Dấu, quota — tự viết trong Go service layer + transaction Postgres (xem TD-006).

---

## TD-002 — Auth: Firebase Auth + 4 provider

**Quyết định**: Firebase Auth cho toàn bộ vòng đời xác thực. Client SDK:
- `firebase_auth`
- `google_sign_in`
- `sign_in_with_apple`
- `flutter_facebook_auth`

**Vì sao**:
- SM-000 BR-01 yêu cầu 4 phương thức: email/mật khẩu, Google, Apple, Facebook — Firebase Auth hỗ trợ cả 4 trực tiếp.
- Session 90 ngày (BR-09), xác nhận email (BR-02), đặt lại mật khẩu qua link 24h (BR-12), đăng xuất mọi thiết bị sau đổi mật khẩu (BR-14): đều là hành vi Firebase Auth có sẵn hoặc cấu hình được.

**Kiến trúc**: Firebase Auth lo **đăng nhập** phía client (4 provider), phát **ID token**. **Go server verify ID token** mỗi request (Firebase Admin SDK for Go) → lấy `uid`, tạo/đọc bản ghi user trong Postgres. Danh tính nguồn ở Firebase; hồ sơ nghiệp vụ (username, plan, seals) ở Go DB, khoá theo `uid`.

**Vì sao Firebase Auth thay vì JWT-Go tự quản**:
- Social login (Google/Apple/Facebook) do Firebase lo — tự verify token 3 nhà cung cấp phía Go là nhiều việc dễ sai.
- UI auth đã dựng sẵn hợp Firebase (`login_screen` v.v.).
- Go server chỉ cần verify ID token (1 lib), nhẹ hơn tự quản vòng đời token + reset + social.

**Tự viết thêm (không có sẵn trong Firebase Auth) — nay ở Go server, không phải Functions**:
- **Khoá tạm 15 phút sau 5 lần sai** (BR-11, AC-12): đếm lần thất bại + khoá trong Go/Postgres.
- **Username duy nhất 3–30 ký tự** (BR-04): bảng `usernames` + unique constraint Postgres.
- **Liên kết/huỷ liên kết provider, giữ ≥1 phương thức** (BR-15/16): `linkWithCredential` phía client + kiểm tra ở server.

**Phương án B (giữ lại)**: JWT-Go tự quản (server đã có sẵn password hash + JWT). Quay lại nếu muốn bỏ hẳn phụ thuộc Firebase Auth — nhưng phải tự làm social verify.

**Đã loại**: Firestore-based auth logic (không dùng Firestore nữa — TD-001).

---

## TD-003 — Cơ sở dữ liệu

**Quyết định**:
- **Server**: Postgres/Cloud SQL (prod), SQLite (dev) — nguồn sự thật cho user, thư, tem, link, dấu, referral, entitlement. Truy cập qua repository interface Go (tầng `storage/` đã tách).
- **Local (client)**: ObjectBox (album tem, cache thư đã tải — offline-first), đồng bộ delta với server qua `rev`+`deleted_at` (sync protocol server đã có sẵn).

**Vì sao**:
- Go backend đã có tầng storage + sync protocol → dùng lại, chỉ thêm bảng/driver.
- ObjectBox đã có trong template, offline-first khớp yêu cầu offline trong spec (xem thư đã tải khi mất mạng, album xem offline...).
- "Thông báo khi thư được đọc" (BR-07 SM-016): không cần realtime DB — dùng **FCM push** từ Go server khi `openLetter` chạy.

**Đã loại**:
- **Firestore**: TD-001 đã bỏ.
- **SQLite ở prod**: không share qua nhiều Cloud Run instance.

> **2026-07-07 — Postgres driver HOÃN tới trước prod (Phase 5).** Port `storage/postgres`
> là việc **cơ học** (~2500 LOC: đổi `?`→`$N`, `INSERT OR REPLACE`/`ON CONFLICT`, `SELECT
> FOR UPDATE` cho seal/link transaction) nhưng **chỉ prod đa-instance mới cần**. Toàn bộ
> luồng E2E (dev + staging 1 instance) chạy đủ trên SQLite. Đã kiểm: transaction tiền
> (`SealRepository.Append` dùng `UPDATE balance = balance + ?`) **race-safe cả trên Postgres**
> (row-lock ở UPDATE), không phụ thuộc single-writer của SQLite → port sau không đổi logic.
> Làm khi vào Phase 5 (Premium/tiền thật) hoặc khi cần scale >1 instance. Cho tới đó Cloud Run
> chạy SQLite trên volume (staging, 1 instance, `min-instances=max-instances=1`).

---

## TD-004 — Xử lý ảnh & editor tem: thử package trước, fallback native

**Quyết định**: Thử hai package **miễn phí (license thương mại)** trước; nếu vướng ràng buộc riêng của StampMail thì rơi về native Flutter. Quyết cuối bằng **spike 1 buổi** (xem dưới).

- **Filter màu (SM-006)** → **`color_filter_extension`** (MIT, 30+ filter + 90+ preset): nguồn ma trận cho 16 bộ lọc, khỏi tự tính ColorMatrix từ đầu. Ba thanh sáng/ấm/đậm vẫn tự dựng bằng `ColorFilter.matrix` nhân thêm.
- **Engine sticker/chữ kéo–xoay–phóng (SM-007)** → cân nhắc **`pro_image_editor`** (BSD-3, ~583 likes): làm sẵn phần cơ khí tốn công nhất (gesture transform, layer, text, crop). Nếu UI mặc định không khớp thẩm mỹ StampMail và phải custom nhiều → tự dựng `Stack` + `Matrix4` + `GestureDetector` (giới hạn min/max BR-10 kẹp trong handler).
- **Xuất tem PNG + watermark (SM-011 BR-11)** → luôn tự làm: bọc vùng tem trong `RepaintBoundary`, `toImage()` → PNG; watermark vẽ lớp trên cùng trước khi capture → không thể tắt. (Package editor **không** lo phần này.)

**Vì sao dùng package cho phần cơ khí**:
- `color_filter_extension` (MIT) và `pro_image_editor` (BSD-3) đều **miễn phí kể cả app thương mại** — không như vài editor SaaS-Flutter tính phí license.
- Gesture transform + layer sticker là phần tốn công nhất, dễ có bug — tái dùng code đã được nhiều app kiểm chứng đúng tinh thần "đừng viết lại thứ đã có".
- Xử lý cục bộ → thoả offline (BR-07 SM-006, BR-08 SM-007) miễn phí.

**Package KHÔNG lo được — 3 ràng buộc riêng vẫn phải tự code lên trên**:

| Ràng buộc StampMail | pro_image_editor có sẵn? |
|---|---|
| **Watermark cưỡng bức** khi xuất (SM-011 BR-11, không tắt được) | ❌ tự chèn lớp watermark trước khi capture |
| **16 filter chia nhóm Free/Premium + khoá/gợi ý nâng cấp** (SM-006 BR-02/03) | ❌ filter phẳng, không có gating |
| **Mở sticker đặc biệt bằng 50📮 Dấu** (SM-007 BR-07) | ❌ logic nghiệp vụ riêng |
| Khung/viền tem (SM-008) | ❌ không phải editor ảnh chung |

→ Package cho **engine kéo–thả–xoay + preview filter**; gating Free/Premium, watermark, Dấu, viền tem là lớp StampMail tự bọc.

**Kế hoạch spike (chốt rẻ nhất)**: dựng thử màn SM-007 bằng `pro_image_editor` trong ~1 buổi, kiểm tra có nhét được watermark + gating Free/Premium + viền tem vào không. Khớp → giữ package. Vướng → rơi về native `Stack`+`Matrix4` (vẫn giữ `color_filter_extension` cho phần filter). Ghi kết quả spike ngược lại vào mục này.

**Đã loại**: `image_editor` / chỉnh pixel bằng `image` package — ColorMatrix trên GPU nhẹ hơn chỉnh pixel CPU cho preview real-time.

**Lưu ý khi làm**: nếu preview real-time giật trên máy yếu (spec mục 5 SM-006 cho phép trễ nhỏ, cấm đứng hình) → cân nhắc `compute()` cho bước **xuất PNG cuối**, không cho preview.

---

## TD-005 — Deep link: tách 2 phần

Nhu cầu tách làm hai bài toán khác nhau — giải bằng hai công cụ:

### TD-005a — Universal Link / App Link (đã cài app): `app_links`
**Quyết định**: Dùng package `app_links` + cấu hình universal link (iOS) / App Link (Android) trỏ về domain Hosting.

**Vì sao**: SM-017 BR-02 "đã cài app → mở thẳng trong app" là năng lực OS gốc, miễn phí, không cần SDK bên thứ ba.

### TD-005b — Deferred deep link + referral attribution: AppsFlyer OneLink
**Quyết định**: Dùng **AppsFlyer OneLink** cho phần link thư đi qua bước cài đặt từ store + gán nguồn giới thiệu.

**Vì sao**:
- SM-016 BR-09/BR-11 + SM-017 AC-09: người nhận **chưa cài app** → mở web → cài từ store → app phải biết "thư nào + ai giới thiệu" để trao **50📮**. Đây là *deferred deep link* survive qua store — cực khó tự làm tin cậy (iOS chặn fingerprint ngày càng gắt).
- AppsFlyer OneLink lo **cả** deferred deep link **lẫn** attribution referral — đúng hai thứ spec cần trong một SDK.
- Đây là thay thế hợp lý sau khi **Firebase Dynamic Links bị khai tử (shutdown 2025-08)**.

**Đã loại**:
- **Firebase Dynamic Links**: đã chết, không dùng.
- **Tự host + fingerprint/clipboard** cho deferred: mong manh, iOS siết dần → rủi ro cho một tính năng P0.
- **Branch.io / Adjust**: tương đương AppsFlyer; chọn AppsFlyer theo yêu cầu người dùng. (Nếu đổi sau, điểm thay thế khu trú ở lớp adapter deep-link.)

**Ranh giới cố ý**: AppsFlyer **chỉ** gánh link thư + referral. Universal link thường để `app_links` lo (miễn phí) — không bắt AppsFlyer làm thay để giảm phụ thuộc + chi phí.

**Gói**: bản **trả phí** (đã có), nên không vướng giới hạn conversions của free tier — dùng thoải mái cho link thư + attribution.

---

## TD-006 — Link thư 1-lần / hết hạn 7 ngày: tự viết trên Firestore + Functions

**Quyết định**: Logic nghiệp vụ tự cài, **không** phải tính năng có sẵn.
- Mỗi người nhận → 1 document link riêng (SM-016 BR-01), có `createdAt`, `expiresAt = +7 ngày`, `openedBy` (null khi chưa mở).
- Mở link = **Firestore transaction**: nếu `openedBy == null` và chưa hết hạn → set `openedBy` + trả nội dung; ngược lại trả "đã đọc" / "hết hạn" (BR-02/BR-03, AC-03/AC-05).
- Dọn link hết hạn: TTL policy của Firestore hoặc Cloud Function theo lịch.

**Vì sao**: đây là ràng buộc nghiệp vụ cốt lõi (một-lần, 7 ngày) — không có dịch vụ nào làm sẵn; transaction đảm bảo "chỉ người đầu tiên nhận".

**Ghi chú**: URL link công khai trỏ về Hosting; Hosting/Function đọc document này để render (xem TD-011).

---

## TD-007 — IAP Premium + khôi phục: RevenueCat

**Quyết định**: Dùng **RevenueCat** (`purchases_flutter`) cho subscription Premium (SM-028) và khôi phục giao dịch (SM-000 BR-17).

**Vì sao**:
- SM-028 BR-03 bắt buộc thanh toán qua App Store / Google Play — RevenueCat bọc cả hai sau một API entitlement.
- SM-000 BR-17 (tự động restore khi đăng nhập) + cross-device Premium: RevenueCat lo receipt-verify, restore, đồng bộ entitlement theo user gần như miễn phí công.
- Free tier tới ~$2.5k doanh thu/tháng — dư cho MVP.

**Đã loại**:
- **`in_app_purchase` thuần + Cloud Function verify**: chính chủ, không phụ thuộc bên thứ ba, nhưng phải tự code restore + grace period + cross-device + verify hai store → nhiều việc dễ sai cho một luồng tiền. Chỉ quay lại nếu chi phí RevenueCat thành vấn đề khi scale.

**Ranh giới**: entitlement Premium là nguồn sự thật ở RevenueCat, nhưng app vẫn cache trạng thái gói để **BR-08 SM-006** hoạt động offline ("đã xác nhận Premium trước đó thì lọc Premium vẫn dùng khi mất mạng").

---

## TD-008 — Push notification: FCM

**Quyết định**: Firebase Cloud Messaging (`firebase_messaging`) cho 5 loại thông báo (SM-026).

**Vì sao**: đã trong hệ Firebase; xếp hàng chờ khi offline + giao lại khi có mạng (BR-06/07 SM-026) là hành vi FCM có sẵn. Bật/tắt từng loại (BR-02) là logic phía app + preference trên Firestore.

**Đã loại**: OneSignal và tương tự (thừa khi đã dùng Firebase).

---

## TD-009 — Chụp/chọn ảnh & quyền

**Quyết định**:
- `image_picker` cho chụp camera + chọn thư viện (SM-005 BR-01).
- `permission_handler` (**template đã có**) cho quyền camera/thư viện/thông báo.

**Vì sao**: cả hai là chuẩn de-facto của Flutter; thao tác cục bộ → offline OK (BR-06 SM-005). `permission_handler` đã wire sẵn (kể cả cấu hình iOS 15 / no-SPM).

**Lưu ý**: giới hạn kích thước file (BR-03 SM-005) tự kiểm tra sau khi picker trả về; nén nếu cần trước khi lên Storage.

---

## TD-010 — Animation mở thư: CHƯA CHỐT ⚠️

**Vấn đề**: SM-019 — trình tự phong bì mở → giấy cuộn → nội dung hiện → tem sáng, kèm âm thanh. **AC-01 SM-017 yêu cầu animation chạy CẢ trên web (người nhận chưa cài app) LẪN trong app.**

**Hai hướng**:
- **Rive**: một asset chạy được cả Flutter (app) lẫn web runtime → không phải làm animation hai lần. Nhỉnh hơn vì ràng buộc "web cũng phải có animation".
- **`AnimationController` thuần**: kiểm soát bằng code, không thêm asset tool, nhưng nếu web xem thư **không** phải Flutter Web (xem TD-011) thì phải dựng lại animation bằng CSS/JS → làm hai lần.

**Quyết định**: chốt khi làm slice mở thư. Vì web xem thư đã chốt là **trang riêng, không phải Flutter Web** (TD-011) → app và web là hai codebase khác nhau. **Rive/Lottie nhỉnh hơn rõ**: một asset animation dùng lại được ở cả app (Flutter runtime) lẫn web (JS runtime) → chỉ dựng animation một lần thay vì code tay hai lần. Chốt cuối khi làm slice, nhưng nghiêng mạnh về Rive/Lottie.

---

## TD-011 — Web xem thư: trang riêng, KHÔNG dùng Flutter Web

**Quyết định**: Trang xem thư (SM-017) là **một trang web viết riêng**, tách khỏi codebase app — **không** dùng Flutter Web. Stack/cách render cụ thể (HTML thuần, framework JS, SSR từ Function...) **quyết định sau**, nhưng hướng đã chốt là trang độc lập nhẹ.

**Vì sao**:
- Mục tiêu spec: *giảm ma sát tối đa* cho người nhận lần đầu → trang phải nhẹ, tải nhanh. Flutter Web (~2MB+ tải đầu) đi ngược mục tiêu này.
- Người nhận có thể mở trên máy tính/trình duyệt bất kỳ → một trang web thuần phù hợp hơn app-shell nặng.

**Đã loại**: **Flutter Web** — bundle nặng, không đáng để tái dùng code cho một trang read-only + animation.

**Hệ quả**: animation mở thư trên web phải dựng riêng (không tái dùng widget Flutter) → xem TD-010.

---

## TD-012 — Native share sheet: `share_plus`

**Quyết định**: `share_plus` để mở native share sheet khi chia sẻ tem nhận Dấu (SM-011 BR-10) và mở DM nền tảng khi gửi thư (SM-016 BR-05).

**Vì sao**: BR-10 nói rõ dùng **native share sheet của hệ điều hành**; `share_plus` là chuẩn. Với SM-016, mở DM từng nền tảng cụ thể có thể cần URL scheme riêng (Zalo, Messenger...) — fallback copy-to-clipboard khi app chưa cài (mục 5 SM-016).

---

## TD-013 — Kho ảnh: Cloudflare R2 (KHÔNG Firebase Storage)

**Quyết định**: Ảnh tem đã render, ảnh trong thư, avatar lưu trên **Cloudflare R2** (S3-compatible). Upload bằng **presigned URL**: app xin backend URL tạm → upload thẳng lên R2 → không đi qua server. DB (Postgres) chỉ giữ URL công khai. Setup: [r2-setup.md](r2-setup.md).

**Vì sao R2 thay Firebase Storage**:
- **Egress miễn phí** — R2 không tính tiền băng thông tải ảnh ra; StampMail nhiều ảnh (tem xem đi xem lại, người nhận tải qua web) → tiết kiệm lớn so với Firebase Storage/S3.
- S3-compatible → dùng AWS SDK for Go chuẩn để ký presigned URL, không khoá vào Firebase.
- Presigned URL: không tốn băng thông Cloud Run (ảnh không qua server).

**Backend cần**:
- R2 adapter (AWS SDK for Go, endpoint `https://<account>.r2.cloudflarestorage.com`) ký presigned PUT URL.
- Endpoint `POST /api/sm/uploads/presign` → `{upload_url, public_url, key}`.
- **Dev fallback**: khi thiếu R2 env → dùng `/api/upload` local sẵn có (lưu file + serve `/uploads/`), server vẫn chạy không cần R2.

**Đã loại**:
- **Firebase Storage**: egress tính tiền, khoá vào Firebase. Firebase giờ chỉ còn Auth + FCM.
- **Upload qua backend**: ảnh qua Cloud Run tốn băng thông; presigned URL tốt hơn cho ảnh nhiều.

**Env cần** (xem r2-setup.md): `R2_ACCOUNT_ID`, `R2_BUCKET`, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, `R2_PUBLIC_BASE_URL`.

---

## Việc còn treo (cần quyết trước khi code phần liên quan)

1. **TD-011** — Web xem thư: đã chốt "trang riêng, không Flutter Web"; còn lại chọn stack render cụ thể (HTML thuần / framework JS / SSR) — quyết khi làm slice nhận-thư.
2. **TD-010** — Animation mở thư: Rive vs Lottie vs code thuần — quyết khi làm slice mở-thư (nghiêng Rive/Lottie).
3. **Facebook Login** cần cấu hình app riêng trên Meta; kiểm tra chính sách store hiện hành.

# StampMail — Quyết định công nghệ (Tech Decisions)

**Cập nhật lần cuối**: 2026-07-06
**Trạng thái**: Chốt sơ bộ cho MVP (P0/P1)

> Tài liệu này ghi lại **các quyết định về công nghệ/thư viện** cho StampMail và **lý do** đằng sau. Mỗi mục nêu: quyết định, vì sao, phương án đã loại. Khi làm từng feature, tra ở đây trước khi thêm dependency mới. Cập nhật khi có quyết định mới hoặc đảo ngược quyết định cũ (ghi rõ ngày + lý do đảo).
>
> Nguyên tắc xuyên suốt: **dùng thứ template đã wire sẵn trước; native/stdlib trước dependency; chỉ thêm SDK bên thứ ba cho phần thực sự không tự làm nổi.**

---

## Bảng tổng hợp nhanh

| Lĩnh vực | Quyết định | Loại |
|----------|-----------|------|
| Backend | Firebase toàn phần | SaaS |
| Auth | Firebase Auth + 4 provider SDK | SaaS + client |
| DB server | Firestore | có sẵn (Firebase) |
| Server logic (link thư, cấp Dấu, referral) | Cloud Functions | có sẵn (Firebase) |
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

## TD-001 — Backend: Firebase toàn phần

**Quyết định**: Dùng Firebase làm backend cho toàn bộ server-side: Auth, Firestore, Cloud Functions, Hosting, Cloud Storage, FCM.

**Vì sao**:
- Template đã wire sẵn Firebase (bootstrap, iOS deployment target 15.0, CocoaPods) → chi phí khởi động gần bằng 0.
- Nhu cầu server của StampMail (auth đa provider, lưu thư/tem/dấu, tạo link, push) đều nằm trong bộ Firebase tiêu chuẩn.
- Không cần vận hành server riêng cho MVP.

**Đã loại**:
- **Backend riêng** (thư mục `simple_backend_server` trong repo): thêm việc vận hành/deploy mà chưa có nhu cầu Firebase không đáp ứng. YAGNI cho tới khi lộ ra giới hạn thật.

**Ràng buộc phát sinh**: logic "link 1 lần / hết hạn 7 ngày" **không phải tính năng có sẵn** — phải tự viết bằng Firestore transaction + trường TTL trên Cloud Functions (xem TD-006).

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

**Tự viết thêm (không có sẵn trong Firebase Auth)**:
- **Khoá tạm 15 phút sau 5 lần sai** (BR-11, AC-12): Firebase không có rate-lock built-in kiểu này → đếm lần thất bại + khoá phía Cloud Functions/Firestore.
- **Username duy nhất 3–30 ký tự** (BR-04): Firebase Auth không có "username" → collection `usernames` trên Firestore + kiểm tra trùng qua transaction.
- **Liên kết/huỷ liên kết provider, giữ ≥1 phương thức** (BR-15/16): dùng `linkWithCredential` + kiểm tra số provider còn lại.

**Đã loại**: giải pháp auth tự host (thừa — Firebase Auth đã đủ và template đã sẵn).

---

## TD-003 — Cơ sở dữ liệu

**Quyết định**:
- **Server**: Firestore (nguồn sự thật cho thư, link, dấu, referral, entitlement).
- **Local**: ObjectBox (album tem, cache thư đã tải — offline-first).

**Vì sao**:
- ObjectBox đã có trong template, offline-first khớp với hàng loạt yêu cầu offline trong spec (xem thư đã tải khi mất mạng, album xem offline...).
- Firestore đồng bộ realtime hợp với "thông báo khi thư được đọc" (BR-07 SM-016).

**Đã loại**: SQLite/drift (ObjectBox đã sẵn, không thêm ORM thứ hai).

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

## Việc còn treo (cần quyết trước khi code phần liên quan)

1. **TD-011** — Web xem thư: đã chốt "trang riêng, không Flutter Web"; còn lại chọn stack render cụ thể (HTML thuần / framework JS / SSR) — quyết khi làm slice nhận-thư.
2. **TD-010** — Animation mở thư: Rive vs Lottie vs code thuần — quyết khi làm slice mở-thư (nghiêng Rive/Lottie).
3. **Facebook Login** cần cấu hình app riêng trên Meta; kiểm tra chính sách store hiện hành.

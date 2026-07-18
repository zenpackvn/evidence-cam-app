# StampMail — Blockers (cần bạn xử 1 lượt)

**Tạo**: 2026-07-07
**Mục đích**: Gom mọi thứ **tôi không tự làm được** (cần credentials, tài khoản
bên thứ ba, quyết định business, hoặc native config) để bạn xử lý một lượt. Sau
khi có các mục này, phần lớn code đã sẵn sàng chạy end-to-end thật.

**Soát lại**: 2026-07-17

> Trạng thái code (07-17): backend Go + 5 feature package client (album,
> stamp_creator, letters, letter_inbox, premium) + web viewer **đã build/analyze/
> test xanh**. Các mục dưới đây là cái chặn "chạy thật trên cloud", không phải chặn code.
>
> **Đã đổi so với bản 07-07:**
> - **A1 Firebase — coi như XONG một phần.** Project `stampmail-dev` đã chạy thật;
>   `firebase_options.dart` là giá trị thật, không còn placeholder. **Nhưng native
>   config đang sai**: `GoogleService-Info.plist` ở root trỏ project `stamp-mail`
>   (sender `975726644424`) ≠ `stampmail-dev` (sender `725681265816`) trong
>   `firebase_options.dart`; plist lại nằm sai chỗ (đường dẫn iOS build đọc là
>   `ios/Runner/GoogleService-Info.plist`, đang bị gitignore); **thiếu hẳn
>   `google-services.json`** cho Android. → Đây là blocker A1 còn lại.
> - **D1 Auth client — XONG.** Firebase Auth SDK thật, email + Google chạy.
>   Còn thiếu: **Apple + Facebook** (hiện là snackbar "sắp ra mắt") → cần A5/A6.
> - **D5/D6 UI — XONG phần lớn.** 4/5 feature package đã có UI đầy đủ; wizard tạo
>   tem chạy hết và upload R2 thật. Còn lại: **paywall (Premium) chưa có gì**.

---

## A. Credentials / tài khoản (chặn deploy + chạy thật)

| # | Việc | Dùng ở | Env / file cần |
|---|------|--------|----------------|
| A1 | **Firebase project** (dev+prod): bật Authentication (Email/Password, Google, Apple, Facebook) + FCM | Auth, Push | `google-services.json` (Android), `GoogleService-Info.plist` (iOS), `FIREBASE_PROJECT_ID`, `GOOGLE_APPLICATION_CREDENTIALS` (server verify ID token) |
| A2 | **Cloudflare R2** bucket + API token | Ảnh tem/avatar | `R2_ACCOUNT_ID`, `R2_BUCKET`, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, `R2_PUBLIC_BASE_URL` (xem `r2-setup.md`) |
| A3 | **GCP + Cloud Run**: project, region, Artifact Registry `stampmail`, Workload Identity provider + deploy service account | Deploy backend | Repo **Variables**: `GCP_PROJECT_ID`, `GCP_REGION`; **Secrets**: `GCP_WIF_PROVIDER`, `GCP_DEPLOY_SA` (workflow `.github/workflows/backend-deploy.yml` đã sẵn, tự skip tới khi có) |
| A4 | **Secret Manager** cho Cloud Run runtime | Backend prod | `JWT_SECRET`, `REVENUECAT_WEBHOOK_AUTH`, `APPSFLYER_WEBHOOK_SECRET` + toàn bộ R2_* / FIREBASE (workflow map sẵn từ Secret Manager). ⚠️ Từ 07-18, prod **thiếu webhook secret → webhook fail-closed (401)** thay vì bỏ auth — an toàn, nhưng phải set các secret này thì webhook mới hoạt động |
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
| ~~D1~~ | ~~**Auth client → Firebase Auth SDK** + nối `/api/sm/*`~~ | ✅ **XONG (07-17)** — Firebase Auth SDK thật, email + Google chạy, `/api/sm/*` nối qua `SmUserDataSource`. Còn **Apple + Facebook** (snackbar "sắp ra mắt") → chờ A5/A6 |
| D2 | **Postgres driver** (`storage/postgres`) | Chỉ prod đa-instance cần; E2E chạy trên SQLite. Làm ở Phase 5 (xem `tech-stack.md` TD-003) |
| D3 | **RevenueCat purchase flow** (`purchases_flutter`) | Cần A7 keys; `EntitlementReader` (đọc trạng thái) đã xong, chỉ thiếu luồng mua |
| D4 | **AppsFlyer SDK** client init + deferred deep link | Cần A8; webhook backend đã xong |
| D5 | ~~Toàn bộ UI các feature~~ → còn **paywall** | ✅ Album grid, letter composer, stamp editor **đã xong**. ❌ **Paywall chưa có gì** — `feature_premium` mới có data layer; `isPremium` **hardcode `false`** ở `router.dart:126/:329` nên gating không chạy. Cần A7 + B1 |
| ~~D6~~ | ~~**stamp_creator** editor~~ | ✅ **XONG** — wizard đủ 5 bước (source → filter → decorate → preview → save), upload R2 thật qua presign. Đi hướng native Stack/Matrix4, không dùng `pro_image_editor` |
| ~~D7~~ | ~~**Xoá tài khoản chưa nối**~~ | ✅ **XONG (07-18)** — chọn hướng **xoá ngay** (khớp `AuthRepository.deleteAccount` = Firebase `user.delete()` xoá cứng). Settings → xoá tài khoản giờ nối `DeleteAccountCubit` (đã có + test): xác nhận → submit → success clear session (router về login) / failure snackbar. **Sửa text UI bỏ lời hứa "7 ngày"** (inline, không đụng arb team) → giờ nói đúng "xoá ngay lập tức, vĩnh viễn, không thể hoàn tác". Test cập nhật khớp. ⚠️ Verify thật cần chạy app (Firebase). Gỡ chặn App Store về mặt code |
| ~~D12~~ | ~~**Avatar**~~ | ✅ **XONG toàn bộ 5 mảnh (07-18)** — feature avatar hoàn chỉnh, end-to-end: ① Backend `PATCH /api/sm/me` nhận `avatar_url` + validate `trustedUploadURL` + `""`=xoá (4 test + curl); ② `AvatarUploader` (presign kind=avatar → PUT R2) + `ProfileEdit.avatarUrl` (3 test); ③ `CropAvatarScreen` chụp khung 1:1 qua `RepaintBoundary.toImage` → `Uint8List` PNG (widget test magic-number); ④ `EditProfileCubit.changeAvatar` upload→PATCH→cập nhật profile giữ form, chống double-tap (6 test); ⑤ `EditProfileScreen` có avatar widget (ảnh/placeholder chữ cái + badge/spinner) tap → `ImagePickerService` (thread qua router như stamp) → crop → `changeAvatar` (2 widget test mock picker). ⚠️ **Chưa verify bằng chạy app thật** (native gallery) — chặn bởi Firebase config. Logic + wiring đã test đầy đủ bằng widget test |
| D8 | **Sticker trong composer** | Chỉ là UI — `LetterContent` chưa mang decoration. **Cần bạn quyết 2 thứ trước khi làm:** ① BR-05 *"xung quanh nội dung thư (không đè lên chữ)"* đọc được 3 kiểu — chỉ đặt ở lề / đặt tự do nhưng render dưới chữ / đặt tự do tự tránh; mỗi kiểu ra một mô hình tương tác khác hẳn. ② 10 PNG sticker đang đóng gói trong app, **web viewer không với tới được** — mà AC-10 bắt buộc người nhận phải thấy → cần host lên CDN (dính A2) |
| ~~D9~~ | ~~Undo/redo trong composer~~ | ✅ **XONG (07-17)** — nối vào history sẵn có của Quill (`QuillController.undo/redo` + `hasUndo/hasRedo`). Composer không cần tự giữ history. 5 test qua UI thật |
| ~~D10~~ | ~~Web viewer không render Delta~~ | ✅ **XONG (07-17)** — người nhận giờ thấy đúng in đậm/nghiêng/gạch chân/màu chữ/căn lề + giấy kẻ dòng + màu giấy. Trước đó **mọi định dạng SM-013 đều mất trắng** khi người nhận mở thư (web chỉ đọc `text` thuần) |
| D11 | ~~Ngôn ngữ~~ → còn **âm thanh mở thư** | ✅ **Ngôn ngữ XONG (07-18)** — `LocaleBloc` (mirror `ThemeBloc`) persist locale, nối MaterialApp + picker. Đổi vi↔en chạy thật, chỉ nhận ngôn ngữ có bản dịch (ko/ja no-op như thiết kế). 6 test. ❌ **Âm thanh mở thư vẫn liệt** — nhưng chặn ở **tài nguyên**: không có audio package, không có asset âm thanh (giống sticker thiếu PNG). Switch để `onChanged: null`. Cần asset + `audioplayers` trước khi wire |

---

## E. Nợ có sẵn (pre-existing, không do phần này tạo)

| # | Việc | Ghi chú |
|---|------|---------|
| ~~E1~~ | ~~`feature_onboarding` test lỗi (4 error)~~ | ✅ **Đã hết (kiểm chứng 07-17: 13/13 test pass, `flutter analyze` sạch)**. Không rõ sửa ở commit nào |

---

## Thứ tự chạy tiếp (soát lại 07-17)

Thứ tự cũ đã lỗi thời — nó mở đầu bằng "A1 → D1 auth client", mà cả hai giờ đã xong.

**Làm được ngay, không chờ ai:**

1. **D7 xoá tài khoản** — cần bạn chốt hướng. Đang là tính năng giả, mà App Store bắt
   buộc phải có → chặn submit.
2. **A1 còn lại: sửa native config Firebase** — thống nhất `stampmail-dev`, đặt plist
   đúng `ios/Runner/`, thêm `google-services.json`. Chặn build thật trên máy/CI.
3. **D11** ngôn ngữ/âm thanh — thuần client, nhỏ.

**Chờ bạn cấp / quyết:**

4. **A2 (R2) + A3/A4 (Cloud Run)** → deploy backend staging thật.
5. **A9 + B3** → deploy `web_letter/`. **B2** → chốt animation (đang là CSS placeholder).
6. **A5/A6** → Apple + Facebook sign-in (đang là snackbar).
7. **D8 sticker** → cần chốt BR-05 + host 10 PNG (dính A2).
8. **A7 + B1** → D5 paywall + D3 purchase flow. ⚠️ Spec mới đánh SM-028/029
   **`⏸️ Tạm disable v1`** — nếu v1 không bán gói thì cả nhánh này hoãn được.
9. **A8** → D4 AppsFlyer SDK. (Khi cần) **D2** Postgres.

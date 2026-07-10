# StampMail — Firebase setup checklist

**Cập nhật**: 2026-07-07
**Package/Bundle ID mục tiêu**: `com.aktechvn.stampmail` (iOS + Android)

> Checklist đầy đủ để dựng Firebase cho StampMail chạy thật. Làm theo thứ tự. Đánh dấu `[x]` khi xong. Backend Go đã chạy được ở dev mode không cần bước này; các bước dưới là để **auth thật + push + verify token** hoạt động.
>
> StampMail cần từ Firebase: **Auth (4 provider)**, **Cloud Messaging (FCM)**, và **service account** cho Go server verify ID token + gửi push. KHÔNG dùng Firestore, KHÔNG dùng Cloud Functions, **KHÔNG dùng Cloud Storage** (ảnh lưu trên Cloudflare R2 — xem [r2-setup.md](r2-setup.md), tech-stack TD-013).

---

## 0. Đổi package/bundle ID sang com.aktechvn.stampmail (làm TRƯỚC)

Hiện tại repo là id của project khác — phải đổi trước khi tạo app trên Firebase, vì Firebase khớp theo id này.

- [ ] **Android** — `android/app/build.gradle.kts`:
  - `applicationId = "com.aktechvn.quangsat"` → `"com.aktechvn.stampmail"`
  - `namespace = "com.lucistudio.flutter_starter_template"` → `"com.aktechvn.stampmail"`
  - Giữ hay bỏ `applicationIdSuffix = ".staging"` tuỳ ý — nếu giữ, bản staging sẽ là `com.aktechvn.stampmail.staging` (phải tạo **app Android thứ 2** trên Firebase cho id này, hoặc bỏ suffix cho gọn khi mới bắt đầu).
- [ ] **iOS** — mở `ios/Runner.xcodeproj` bằng Xcode → target Runner → Signing & Capabilities → **Bundle Identifier** = `com.aktechvn.stampmail` (cả Debug/Release/Profile). Hoặc sửa `PRODUCT_BUNDLE_IDENTIFIER` trong `project.pbxproj`.
- [ ] Đổi tên app hiển thị (tuỳ chọn): `android/app/src/main/AndroidManifest.xml` (`android:label`), iOS `Info.plist` (`CFBundleDisplayName`).

> **Mẹo**: có thể để `flutterfire configure` (bước 3) tự ghi id vào native config, nhưng `applicationId`/`bundleId` trong project vẫn phải khớp `com.aktechvn.stampmail` thủ công như trên.

---

## 1. Tạo Firebase project

- [ ] Vào https://console.firebase.google.com → **Add project**.
- [ ] Tên: `StampMail` (hoặc `stampmail-prod`). Project ID sẽ dạng `stampmail-xxxxx` — **ghi lại**, cần cho backend (`FIREBASE_PROJECT_ID`).
- [ ] Bật Google Analytics: tuỳ chọn (không bắt buộc cho MVP).
- [ ] (Khuyến nghị) Tạo **2 project**: `stampmail-dev` và `stampmail-prod`, tách môi trường. Ít nhất làm `dev` trước.

---

## 2. Bật các dịch vụ Firebase cần dùng

Trong Firebase Console của project:

### 2.1 Authentication (Build → Authentication → Get started)
Bật 4 sign-in provider (SM-000 BR-01):
- [ ] **Email/Password** — bật. (Bật cả "Email link" nếu muốn, không bắt buộc.)
- [ ] **Google** — bật. Chọn support email.
- [ ] **Apple** — bật. *(Cần Apple Developer account — xem bước 5.)*
- [ ] **Facebook** — bật. Cần **App ID + App Secret** từ Meta (xem bước 6).
- [ ] (Tuỳ chọn) Settings → Authorized domains: thêm domain trang web xem thư sau này.

### 2.2 Cloud Messaging (Build → Messaging)
- [ ] Không cần bật gì đặc biệt — có sẵn khi tạo project. Chỉ cần service account (bước 4) để Go gửi push.
- [ ] **iOS**: cần **APNs key** (bước 5.2) upload vào Project Settings → Cloud Messaging.

> **KHÔNG bật Cloud Storage** — ảnh tem/avatar lưu trên **Cloudflare R2** (xem [r2-setup.md](r2-setup.md)).
> **KHÔNG bật Firestore** — StampMail dùng Postgres/Go, không dùng Firestore.

---

## 3. Đăng ký app (Android + iOS) & sinh config

Cách nhanh nhất — dùng FlutterFire CLI (tự tạo cả 3 app + config):

- [ ] Cài CLI:
  ```bash
  dart pub global activate flutterfire_cli
  # firebase CLI đã có sẵn trên máy; nếu chưa: npm i -g firebase-tools
  firebase login
  ```
- [ ] Chạy tại gốc repo:
  ```bash
  cd /Users/sontruong/workspace/ex/flutter-template
  fvm flutter pub get
  flutterfire configure \
    --project=<PROJECT_ID> \
    --ios-bundle-id=com.aktechvn.stampmail \
    --android-package-name=com.aktechvn.stampmail
  ```
- [ ] Lệnh trên GHI ĐÈ (thật) các file placeholder hiện có:
  - `lib/firebase_options.dart` ✅
  - `android/app/google-services.json` ✅
  - `ios/Runner/GoogleService-Info.plist` ✅
- [ ] Nếu giữ flavor `.staging`: chạy `flutterfire configure` lần nữa với `--android-package-name=com.aktechvn.stampmail.staging` (hoặc bỏ suffix).

---

## 4. Service account cho Go backend (verify ID token + gửi FCM)

- [ ] Firebase Console → ⚙️ **Project settings** → **Service accounts** → **Generate new private key** → tải file JSON.
- [ ] Đặt file ở nơi an toàn (KHÔNG commit). Ví dụ: `simple_backend_server/serviceAccount.json` (đã nên thêm vào `.gitignore`).
- [ ] Set env khi chạy backend:
  ```bash
  export FIREBASE_PROJECT_ID=<PROJECT_ID>
  export GOOGLE_APPLICATION_CREDENTIALS=/đường/dẫn/serviceAccount.json
  ```
  → backend tự chuyển từ dev-mode sang **verify Firebase ID token thật + gửi FCM thật** (đã wire sẵn trong `main.go` / `firebaseadmin`).

---

## 5. iOS: Apple Sign-In + APNs (nếu build iOS)

### 5.1 Sign in with Apple
- [ ] Cần **Apple Developer Program** ($99/năm).
- [ ] developer.apple.com → Identifiers → App ID `com.aktechvn.stampmail` → bật capability **Sign In with Apple**.
- [ ] Xcode → target Runner → Signing & Capabilities → **+ Capability → Sign in with Apple**.
- [ ] Firebase Auth → Apple provider: điền Service ID / Team ID / Key nếu console yêu cầu.

### 5.2 APNs (để FCM push chạy trên iOS)
- [ ] developer.apple.com → Keys → tạo **APNs Auth Key** (.p8), ghi Key ID + Team ID.
- [ ] Firebase Console → Project settings → **Cloud Messaging** → Apple app config → upload .p8 + Key ID + Team ID.
- [ ] Xcode → Runner → Signing & Capabilities → **+ Push Notifications** và **+ Background Modes → Remote notifications**.

---

## 6. Facebook Login (nếu dùng provider Facebook)

- [ ] Tạo app tại https://developers.facebook.com → thêm sản phẩm **Facebook Login**.
- [ ] Lấy **App ID** + **App Secret** → điền vào Firebase Auth → Facebook provider.
- [ ] Copy **OAuth redirect URI** Firebase cấp → dán vào Facebook Login settings → Valid OAuth Redirect URIs.
- [ ] Android: thêm **key hash**; iOS: thêm bundle id vào Facebook app.
- [ ] App config (`android`/`ios`) cần chèn App ID theo hướng dẫn của `flutter_facebook_auth`.

> Facebook phức tạp nhất trong 4 provider — nếu muốn ra MVP nhanh, có thể tạm bỏ Facebook, làm Email + Google + Apple trước.

---

## 7. Android: SHA fingerprint (cho Google Sign-In)

- [ ] Lấy SHA-1 + SHA-256 debug:
  ```bash
  cd android && ./gradlew signingReport
  # hoặc: keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
  ```
- [ ] Firebase Console → Project settings → app Android `com.aktechvn.stampmail` → **Add fingerprint** → dán SHA-1 + SHA-256.
- [ ] Tải lại `google-services.json` sau khi thêm SHA (hoặc chạy lại `flutterfire configure`).
- [ ] Làm lại với SHA của **release keystore** khi build production.

---

## 8. Verify — chạy thử

- [ ] `fvm flutter pub get`
- [ ] iOS: `cd ios && pod install` (nhớ SPM đã tắt — xem CLAUDE.md).
- [ ] Chạy app: `fvm flutter run` — Firebase khởi tạo không lỗi.
- [ ] Backend: chạy với 2 env ở bước 4 → đăng nhập trong app → ID token gửi lên `/api/sm/*` → verify PASS.

---

## Tóm tắt "cần cung cấp cho Claude"

Sau khi làm xong, để tôi (Claude) nối Flutter end-to-end, chỉ cần:
1. ✅ `flutterfire configure` đã chạy (3 file config đã thật) — commit `firebase_options.dart`, KHÔNG commit 2 file native (đã gitignore).
2. ✅ **PROJECT_ID** để tôi ghi vào README backend.
3. Provider nào đã bật (Email/Google/Apple/Facebook) — để tôi làm đúng nút nào hoạt động thật.

Bảng phụ thuộc tiền/tài khoản:
| Provider | Cần gì |
|---|---|
| Email/Password | Không gì thêm |
| Google | SHA fingerprint (Android) |
| Apple | Apple Developer $99/năm |
| Facebook | Meta app + App ID/Secret |
| FCM iOS | APNs key (.p8) — cần Apple Developer |

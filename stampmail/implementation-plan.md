# StampMail — Plan triển khai full

**Cập nhật lần cuối**: 2026-07-06
**Căn cứ**: 27 spec trong [specs/](specs/), [tech-stack.md](tech-stack.md), kiến trúc template hiện có
**Chiến lược**: Vertical slice theo ưu tiên P0 → P1 → P2. Mỗi slice đi hết stack (UI → domain → data → Firebase), mỏng nhưng chạy được end-to-end.

> ⚠️ **LỖI THỜI Ở PHẦN BACKEND (2026-07-07).** Tài liệu này viết theo hướng
> **Firestore + Cloud Functions**. Hướng đó đã bị **đảo sang Go server (Cloud Run) +
> Cloudflare R2** — xem `tech-stack.md` TD-001 và `data-model.md`. Backend thực tế
> (`simple_backend_server`) đã build theo hướng mới (~85%, tests pass).
> **Plan thực thi end-to-end hiện hành: [e2e-execution-plan.md](e2e-execution-plan.md)** (đã duyệt 2026-07-07).
> Phần map SM-NNN → feature package + thứ tự phase dưới đây vẫn còn giá trị; chỉ đọc phần
> "Firestore/Cloud Functions/data model Firestore" như tham khảo lịch sử.

> Plan này map từng SM-NNN vào feature package cụ thể, chia phase có thứ tự phụ thuộc, và ghi rõ việc backend đi kèm từng phase. Khi bắt đầu một phase, tạo branch theo tên spec (`001-auth`, `005-chup-chon-anh`...) như spec đã ghi sẵn `Feature Branch`.

---

## 0. Hiện trạng template (điểm xuất phát)

**Có sẵn, tái dùng:**
- Pub workspace + kiến trúc feature-package (`packages/features/<name>` với data/domain/presentation, DI module, routes, tests).
- Feature scaffold: `auth`, `home`, `onboarding`, `profile`, `notifications`, `splash` — đúng các feature StampMail cần, chỉ thay ruột.
- `collections` + `bookmarks`: **khuôn mẫu** cho pattern offline-first + SyncController — nhân bản cho `album`, `letters`.
- Infra: `network` (dio), `storage`, `database` (ObjectBox), `theme`, `app_ui`, `localization`, `analytics`, `sync_connectivity_plus`, `shared_contracts`/`shared_ui` (Session pattern).
- App shell: router (go_router typed), DI composition, `FeatureModule` wiring, Firebase bootstrap (`lib/app/firebase.dart`).

**Phải thay:**
- Auth data layer hiện là REST/Dio → Go server (`simple_backend_server`). **Quyết định: viết lại sang `firebase_auth`** (TD-001/TD-002). Go server ngừng dùng — xoá khỏi luồng build khi auth chuyển xong.
- `collections`/`bookmarks` là demo — giữ lại làm khuôn tham chiếu tới khi album/letters xong, rồi gỡ.

---

## 1. Bức tranh feature package đích

```
packages/features/
├── auth            (SM-000)  — viết lại data layer sang Firebase Auth, thêm 3 social provider
├── onboarding      (SM-003)  — thay nội dung scaffold
├── home            (SM-004)  — thay nội dung scaffold
├── profile         (SM-024, SM-027) — hồ sơ + cài đặt tài khoản
├── notifications   (SM-026)  — FCM + preference 5 loại
├── splash          — giữ nguyên vai trò
├── stamp_creator   (SM-005→011: chụp ảnh, lọc màu, trang trí, viền, xem trước, lưu) [MỚI]
├── album           (SM-022, SM-035: album + bộ tem mẫu)                              [MỚI]
├── letters         (SM-012→015: template, soạn, đính tem, xem trước)                 [MỚI]
├── letter_send     (SM-016: tạo link + share DM) — có thể gộp vào letters            [MỚI]
├── letter_inbox    (SM-017→021: nhận, mở+animation, inbox, trả lời, đã gửi)          [MỚI]
└── premium         (SM-028, SM-029, SM-030: paywall, quản lý, giới hạn tháng)        [MỚI]

shared_contracts (mở rộng):
├── Session (có sẵn) → gắn AuthUser Firebase
├── Entitlement     — trạng thái Free/Premium + item đã mở khoá (premium/editor cùng đọc)
├── StampRef        — tem tối thiểu (id, ảnh, ngày) cho letters/album/stamp_creator trao đổi
└── QuotaReader     — đọc hạn mức tháng (tem/thư) cho stamp_creator + letters

web/  (ngoài workspace Flutter — trang xem thư riêng, TD-011)
functions/ (Cloud Functions — link thư, attribution nguồn giới thiệu, quota)
```

**Nguyên tắc ranh giới** (theo CLAUDE.md): feature không import feature; trao đổi qua `shared_contracts` khi ≥2 consumer; capability đơn-consumer thì import trực tiếp qua barrel.

---

## 2. Data model Firestore (phác thảo — chốt chi tiết ở đầu Phase 1)

```
users/{uid}
  username, email, avatarUrl, plan (free|premium), createdAt
  stamps_count_month, letters_count_month   (đếm quota, reset ngày 1)
  attribution: { source }                    (nguồn giới thiệu ghi nhận 1 lần — SM-016 BR-09)

usernames/{username} → uid                   (unique check bằng transaction)

stamps/{stampId}
  ownerUid, imageUrl (Storage), createdAt, source (created|received), senderName?

albums/{uid}/custom/{albumId}
  name, stampIds[]

letters/{letterId}
  senderUid, contentJson (template, text, style), stampIds[], createdAt, status

letter_links/{linkId}                        (TD-006 — 1 link / người nhận)
  letterId, senderUid, createdAt, expiresAt (+7d), openedBy (null|uid|anonymous), openedAt

quota_events/{uid}                           (đếm hạn mức tem/thư theo tháng — SM-030)
```

**Cloud Functions chính:**
| Function | Việc | Spec |
|---|---|---|
| `createLetterLink` | tạo link, trừ quota thư | SM-016 |
| `openLetter` | transaction 1-lần, đánh dấu đã đọc, bắn FCM cho người gửi | SM-017/019 |
| `resetMonthlyQuota` (scheduled) | reset quota ngày 1 | SM-030 |
| RevenueCat webhook | đồng bộ entitlement premium | SM-028 |

> **Mọi check quota đều ở server-side (Functions + security rules)** — client chỉ đọc. Đây là moat tăng trưởng, không tin client.

---

## 3. Các phase

### Phase 0 — Nền móng (1 tuần)
Mục tiêu: repo sẵn sàng cho mọi slice sau; không có UI mới.

- [ ] Tạo Firebase project (dev + prod), bật Auth (4 provider), Firestore, Storage, Functions, Hosting, FCM. App Check.
- [ ] Chốt data model Firestore chi tiết (mục 2) + security rules khung.
- [ ] `shared_contracts`: thêm `Entitlement`, `StampRef`, `QuotaReader` (interface rỗng cũng được — chốt chữ ký).
- [ ] Design tokens + theme StampMail vào `packages/theme` / `app_ui` (từ design/design2/stage2-design-tokens.md). **Chỉ token + theme — component để nổi lên sau (rule of three).**
- [ ] Scaffold `functions/` (TypeScript) + CI deploy.
- [ ] Gỡ `simple_backend_server` khỏi luồng dev (giữ thư mục tới khi auth chuyển xong).

### Phase 1 — Auth trên Firebase (SM-000, 1.5–2 tuần)
Slice: mở app → đăng ký/đăng nhập 4 phương thức → session 90 ngày → Home rỗng.

- [ ] Viết lại `feature_auth` data layer: `firebase_auth` + `google_sign_in` + `sign_in_with_apple` + `flutter_facebook_auth`. Giữ nguyên domain/presentation contract (AuthBloc, Session) — chỉ thay datasource/repository.
- [ ] Username duy nhất: collection `usernames` + transaction (BR-04).
- [ ] Khoá 5-lần/15-phút: đếm phía Functions (BR-11) — client hiển thị đếm ngược.
- [ ] Xác nhận email (BR-02) + đặt lại mật khẩu (BR-12) bằng **mã OTP 6 số** (hiệu lực 5 phút, gửi lại sau 120s) do backend tự phát/verify — **không dùng link email/Firebase reset**. Đổi mật khẩu, link/unlink provider (BR-13→16).
- [ ] Offline guard (BR-29→31): chặn thao tác auth khi mất mạng, giữ form.
- [ ] Cập nhật router redirect theo Session.
- **Nghiệm thu**: toàn bộ AC-01→35 của SM-000; test theo khuôn test có sẵn của feature auth.

### Phase 2 — Luồng tạo tem end-to-end (SM-005→011 + Album cơ bản, 3–4 tuần) 🔴 lõi MVP
Slice: Home → chụp/chọn ảnh → lọc màu → trang trí → viền → xem trước → lưu vào Album → thấy trong Album.

- [ ] **Spike 1 buổi** (TD-004): `pro_image_editor` cho editor trang trí (SM-008) — quyết dùng hay tự viết. Ghi kết quả vào tech-stack.md.
- [ ] `feature_stamp_creator`:
  - SM-005: `image_picker` + preview zoom (InteractiveViewer), giới hạn size, permission flow.
  - SM-006: 16 filter (`color_filter_extension`) + 3 thanh chỉnh (ColorMatrix), gate 8 filter Premium (đọc `Entitlement`).
  - SM-008: sticker/chữ/icon kéo–xoay–phóng (kết quả spike), gate sticker đặc biệt **chỉ mở bằng Premium** (đọc `Entitlement`); nhấn sticker khóa → gợi ý nâng cấp Premium (SM-008 BR-02/BR-07).
  - SM-009: viền/khung (đọc kỹ spec SM-009 khi làm), gate viền khóa **chỉ mở bằng Premium** (SM-009 BR-03/BR-06).
  - SM-010/011: xem trước đa nền, RepaintBoundary → PNG + watermark, upload Storage, ghi Firestore, quota 30 tem/tháng (check qua Function).
- [ ] `feature_album` (SM-022 mức cơ bản): lưới tem "Tất cả/Tự tạo/Nhận được", chi tiết tem, offline-first ObjectBox (nhân khuôn `collections`).
- [ ] Nút "Chia sẻ tem": mở share sheet (`share_plus`) + watermark (SM-025 bản cơ bản).
- **Nghiệm thu**: một người dùng thật tạo tem từ ảnh và thấy nó trong Album, offline vẫn trang trí được.

### Phase 3 — Gửi & nhận thư (SM-016, 017, 019 + soạn thư tối thiểu SM-012→015, 3–4 tuần) 🔴 lõi lan truyền
Slice: chọn tem từ Album → soạn thư tối giản → tạo link → gửi DM → người nhận mở web → animation → (cài app → tem vào Album).

- [ ] `feature_letters` (bản tối thiểu để P0 chạy): 1–2 template, soạn text (SM-013 rút gọn), đính tem (SM-014), xem trước (SM-015 rút gọn). *(Bản đầy đủ P2 quay lại ở Phase 6.)*
- [ ] `createLetterLink` Function + `feature_letter_send`: chọn nền tảng (8 MXH), URL scheme mở DM, fallback copy link; quota 10 thư/tháng; AppsFlyer OneLink làm URL.
- [ ] **Web xem thư** (TD-011 — trang riêng): chốt stack render (đề xuất: HTML+JS nhẹ, host Firebase Hosting, gọi `openLetter` Function). Transaction 1-lần/7-ngày, trạng thái đã-đọc/hết-hạn/không-hợp-lệ (SM-017).
- [ ] **Animation mở thư** (TD-010 — chốt Rive/Lottie tại đây): 1 asset chạy app + web. Âm thanh nhẹ.
- [ ] `feature_letter_inbox` (mức P0): mở thư trong app qua `app_links`, xem thư đã nhận; tem từ thư vào Album sau đăng nhập (SM-017 BR-05).
- [ ] AppsFlyer SDK + deferred deep link: cài từ link → app mở đúng thư (SM-017) + ghi nhận nguồn giới thiệu (attribution — SM-016 BR-09). Chỉ ghi nhận nguồn, không trao thưởng.
- **Nghiệm thu**: 2 máy thật — máy A gửi qua Zalo/Messenger, máy B (chưa cài app) mở web thấy animation, cài app, tem về Album, máy A nhận noti "đã mở thư".

### Phase 4 — Push (SM-026, 1 tuần) 🔴 khép vòng tương tác
Slice: các sự kiện mở thư / trả lời / hạn mức bắn thông báo đẩy đúng màn.

- [ ] `feature_notifications` → FCM: 5 loại noti + preference bật/tắt từng loại + deep-link đúng màn (SM-026).
- **Nghiệm thu**: AC của SM-026; noti "đã mở thư" đến máy người gửi trên 2 máy thật.

### Phase 5 — Premium & tiền (SM-028, 029, 030 + phần restore SM-000 BR-17, 1.5–2 tuần)
- [ ] `feature_premium`: paywall so sánh Free/Premium, gói tháng/năm (RevenueCat), mở khoá tức thì, quản lý/huỷ đăng ký, restore khi đăng nhập.
- [ ] `Entitlement` hoàn chỉnh: RevenueCat webhook → Firestore → các gate ở stamp_creator/letters đọc; cache offline (SM-006 BR-08).
- [ ] SM-030: nhắc hạn mức (còn N tem/thư), reset ngày 1, noti hạn mức.
- **Nghiệm thu**: mua sandbox iOS + Android, restore trên máy thứ hai, gate mở đúng.

### Phase 6 — Hoàn thiện trải nghiệm P1/P2 (3–4 tuần, song song hoá được)
Thứ tự trong phase linh hoạt, các mục độc lập nhau:

- [ ] SM-020 Trả lời thư (P1) — nối inbox → luồng soạn thư.
- [ ] SM-025 Chia sẻ tem bản đầy đủ (P1).
- [ ] SM-035 Bộ tem mẫu bản đầy đủ (P1) — **toàn bộ miễn phí**, không có phần khóa/mở-khóa (SM-035 BR-05).
- [ ] SM-003 Onboarding + SM-004 Home hoàn chỉnh (P2) — thay scaffold.
- [ ] SM-012/013/014/015 bản đầy đủ (P2): đủ template, font, màu giấy, kẻ dòng, màu chữ theo đoạn, sticker trên thư.
- [ ] SM-018 Inbox + SM-021 Hộp đã gửi đầy đủ (P2).
- [ ] SM-024 Hồ sơ + SM-027 Cài đặt (P2) — thay ruột `profile`; xoá tài khoản (SM-000 BR-26/AC-33).
- [ ] SM-022 Album đầy đủ: album tùy chỉnh, chế độ chỉnh sửa, xoá/di chuyển tem.

### Phase 7 — Ra mắt (1–2 tuần)
- [ ] Gỡ `collections`/`bookmarks` demo + `simple_backend_server`.
- [ ] Hardening: security rules review, App Check enforce, rate limit Functions.
- [ ] Store listing, privacy manifest (Apple), Data Safety (Google), review Facebook Login/Apple Sign-In compliance.
- [ ] Analytics funnel (tạo tem → gửi → mở → cài) + Crashlytics.
- [ ] Beta TestFlight/Internal testing → fix → release.

---

## 4. Thứ tự phụ thuộc (vì sao xếp vậy)

```
P0: Nền → Auth → Tạo tem ─┬→ Gửi/Nhận thư → Push → Premium
                          └→ Album (cùng Phase 2)
```

- **Auth trước tất cả**: mọi spec đều "đã đăng nhập" là tiên quyết.
- **Tạo tem trước thư**: thư bắt buộc đính tem (SM-014 BR-05) — không có tem thì không test được thư.
- **Push sau thư**: noti chính (đã mở thư, trả lời) phát sinh từ luồng gửi/nhận; có luồng thư rồi mới test được noti thật.
- **Premium sau tạo tem**: paywall cần các điểm gate đã tồn tại (filter/sticker/viền/quota) — tất cả có sau Phase 2.
- **P2 cuối**: home/onboarding/hồ sơ scaffold đã chạy tạm được từ template, không chặn ai.

## 5. Ước lượng tổng

| Phase | Thời lượng (1 dev full-time) |
|---|---|
| 0 — Nền | 1 tuần |
| 1 — Auth | 1.5–2 tuần |
| 2 — Tạo tem + Album | 3–4 tuần |
| 3 — Gửi/Nhận thư + Web | 3–4 tuần |
| 4 — Push | 1 tuần |
| 5 — Premium | 1.5–2 tuần |
| 6 — P1/P2 đầy đủ | 3–4 tuần |
| 7 — Ra mắt | 1–2 tuần |
| **MVP dùng được (hết Phase 4)** | **~9–12 tuần** |
| **Full** | **~15–20 tuần** |

> Ước lượng cho 1 dev; 2 dev có thể chạy song song từ Phase 3 (một người app, một người web+Functions) rút ~25–30%.

## 6. Rủi ro chính & giảm nhẹ

| # | Rủi ro | Giảm nhẹ |
|---|---|---|
| 1 | **Editor tem phức tạp hơn dự kiến** (gesture, giới hạn kích thước, xuất ảnh chất lượng) | Spike Phase 2 tuần đầu; nếu `pro_image_editor` fail → native có sẵn kế hoạch B trong TD-004 |
| 2 | **Deferred deep link không nhận diện đúng** (iOS privacy) | Test AppsFlyer sandbox sớm ngay Phase 3 tuần 1, trên thiết bị thật cả 2 OS |
| 3 | **Mở DM từng MXH** (8 nền tảng, URL scheme thay đổi, app không cài) | Fallback copy-link đã nằm trong spec (mục 5 SM-016) — làm fallback trước, scheme từng app sau |
| 4 | **Review store** (Facebook Login, quyền ảnh, IAP) | Compliance checklist ở Phase 7 nhưng cấu hình đúng ngay từ Phase 1 (Sign in with Apple bắt buộc khi có social login) |
| 5 | **Animation web ≠ app** | Chốt Rive/Lottie Phase 3, 1 asset 2 runtime; test trên trình duyệt yếu |

## 7. Việc còn treo (chốt tại phase ghi kèm)

1. Stack render trang web xem thư — **Phase 3, tuần 1** (TD-011).
2. Rive vs Lottie — **Phase 3, cùng lúc** (TD-010).
3. Kết quả spike `pro_image_editor` — **Phase 2, buổi đầu** (TD-004).
4. Chi tiết viền/khung tem — đọc kỹ spec SM-009 khi vào Phase 2.
5. Giá gói Premium — cần trước Phase 5 (business quyết).

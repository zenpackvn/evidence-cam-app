# StampMail — Plan triển khai full

**Cập nhật lần cuối**: 2026-07-06
**Căn cứ**: 29 spec trong [specs/](specs/), [tech-stack.md](tech-stack.md), kiến trúc template hiện có
**Chiến lược**: Vertical slice theo ưu tiên P0 → P1 → P2. Mỗi slice đi hết stack (UI → domain → data → Firebase), mỏng nhưng chạy được end-to-end.

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
├── rewards         (SM-033: Dấu — số dư, kiếm, tiêu, mua)                            [MỚI]
├── premium         (SM-028, SM-029, SM-030: paywall, quản lý, giới hạn tháng)        [MỚI]
└── group_card      (SM-032: thiệp nhóm)                                              [MỚI, P1 cuối]

shared_contracts (mở rộng):
├── Session (có sẵn) → gắn AuthUser Firebase
├── Entitlement     — trạng thái Free/Premium + item đã mở khoá (rewards/premium/editor cùng đọc)
├── StampRef        — tem tối thiểu (id, ảnh, ngày) cho letters/album/stamp_creator trao đổi
└── QuotaReader     — đọc hạn mức tháng (tem/thư) cho stamp_creator + letters

web/  (ngoài workspace Flutter — trang xem thư riêng, TD-011)
functions/ (Cloud Functions — link thư, Dấu, referral, quota)
```

**Nguyên tắc ranh giới** (theo CLAUDE.md): feature không import feature; trao đổi qua `shared_contracts` khi ≥2 consumer; capability đơn-consumer thì import trực tiếp qua barrel.

---

## 2. Data model Firestore (phác thảo — chốt chi tiết ở đầu Phase 1)

```
users/{uid}
  username, email, avatarUrl, plan (free|premium), createdAt
  stamps_count_month, letters_count_month   (đếm quota, reset ngày 1)
  seals_balance                              (số Dấu 📮)
  referral: { installs_this_month }

usernames/{username} → uid                   (unique check bằng transaction)

stamps/{stampId}
  ownerUid, imageUrl (Storage), createdAt, source (created|received), senderName?

albums/{uid}/custom/{albumId}
  name, stampIds[]

letters/{letterId}
  senderUid, contentJson (template, text, style), stampIds[], createdAt, status

letter_links/{linkId}                        (TD-006 — 1 link / người nhận)
  letterId, senderUid, createdAt, expiresAt (+7d), openedBy (null|uid|anonymous), openedAt

seal_ledger/{uid}/entries/{entryId}          (sổ cái Dấu — nguồn sự thật, balance là tổng)
  amount (+/-), reason (share|send|opened|install|unlock_sticker|unlock_border|purchase), refId, createdAt

unlocks/{uid}/items/{itemId}                 (sticker pack / viền / tem mẫu đã mở vĩnh viễn)

quota_events, share_weekly/{uid}             (đếm 3 lượt chia sẻ/tuần, 5 lượt install/tháng)
```

**Cloud Functions chính:**
| Function | Việc | Spec |
|---|---|---|
| `createLetterLink` | tạo link, trừ quota thư, cộng 5📮 | SM-016 |
| `openLetter` | transaction 1-lần, đánh dấu đã đọc, cộng 15📮, bắn FCM cho người gửi | SM-017/019 |
| `onNewUserFromReferral` | verify AppsFlyer postback → cộng 50📮 (cap 5/tháng) | SM-016 BR-11 |
| `awardShareSeal` | cộng 10📮, cap 3/tuần | SM-011/033 |
| `spendSeals` | transaction trừ Dấu + ghi unlock | SM-033 |
| `resetMonthlyQuota` (scheduled) | reset quota ngày 1 | SM-030 |
| RevenueCat webhook | đồng bộ entitlement premium + gói Dấu mua | SM-028 |

> **Mọi cộng/trừ Dấu và check quota đều ở server-side (Functions + security rules)** — client chỉ đọc. Đây là tiền/moat tăng trưởng, không tin client.

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
- [ ] Email verify, quên mật khẩu, đổi mật khẩu, link/unlink provider (BR-12→16).
- [ ] Offline guard (BR-29→31): chặn thao tác auth khi mất mạng, giữ form.
- [ ] Cập nhật router redirect theo Session.
- **Nghiệm thu**: toàn bộ AC-01→35 của SM-000; test theo khuôn test có sẵn của feature auth.

### Phase 2 — Luồng tạo tem end-to-end (SM-005→011 + Album cơ bản, 3–4 tuần) 🔴 lõi MVP
Slice: Home → chụp/chọn ảnh → lọc màu → trang trí → viền → xem trước → lưu vào Album → thấy trong Album.

- [ ] **Spike 1 buổi** (TD-004): `pro_image_editor` cho SM-007 — quyết dùng hay tự viết. Ghi kết quả vào tech-stack.md.
- [ ] `feature_stamp_creator`:
  - SM-005: `image_picker` + preview zoom (InteractiveViewer), giới hạn size, permission flow.
  - SM-006: 16 filter (`color_filter_extension`) + 3 thanh chỉnh (ColorMatrix), gate 8 filter Premium (đọc `Entitlement`).
  - SM-007: sticker/chữ/icon kéo–xoay–phóng (kết quả spike), gate sticker đặc biệt (Premium hoặc 50📮 — nút gọi sang rewards, Phase 4 mới hoạt động thật; tạm stub "sắp có").
  - SM-009: viền/khung (đọc spec 008 chi tiết khi làm), gate viền Premium/80📮.
  - SM-010/011: xem trước đa nền, RepaintBoundary → PNG + watermark, upload Storage, ghi Firestore, quota 30 tem/tháng (check qua Function).
- [ ] `feature_album` (SM-022 mức cơ bản): lưới tem "Tất cả/Tự tạo/Nhận được", chi tiết tem, offline-first ObjectBox (nhân khuôn `collections`).
- [ ] Nút "Chia sẻ & nhận 10📮": mở share sheet (`share_plus`) + watermark; **cộng Dấu stub** (ghi event, chưa có UI Dấu — Phase 4 bật).
- **Nghiệm thu**: một người dùng thật tạo tem từ ảnh và thấy nó trong Album, offline vẫn trang trí được.

### Phase 3 — Gửi & nhận thư (SM-016, 017, 019 + soạn thư tối thiểu SM-012→015, 3–4 tuần) 🔴 lõi lan truyền
Slice: chọn tem từ Album → soạn thư tối giản → tạo link → gửi DM → người nhận mở web → animation → (cài app → tem vào Album).

- [ ] `feature_letters` (bản tối thiểu để P0 chạy): 1–2 template, soạn text (SM-013 rút gọn), đính tem (SM-014), xem trước (SM-015 rút gọn). *(Bản đầy đủ P2 quay lại ở Phase 6.)*
- [ ] `createLetterLink` Function + `feature_letter_send`: chọn nền tảng (8 MXH), URL scheme mở DM, fallback copy link; quota 10 thư/tháng; AppsFlyer OneLink làm URL.
- [ ] **Web xem thư** (TD-011 — trang riêng): chốt stack render (đề xuất: HTML+JS nhẹ, host Firebase Hosting, gọi `openLetter` Function). Transaction 1-lần/7-ngày, trạng thái đã-đọc/hết-hạn/không-hợp-lệ (SM-017).
- [ ] **Animation mở thư** (TD-010 — chốt Rive/Lottie tại đây): 1 asset chạy app + web. Âm thanh nhẹ.
- [ ] `feature_letter_inbox` (mức P0): mở thư trong app qua `app_links`, xem thư đã nhận; tem từ thư vào Album sau đăng nhập (SM-017 BR-05).
- [ ] AppsFlyer SDK + deferred deep link: cài từ link → app mở đúng thư + referral ghi nhận (`onNewUserFromReferral`).
- **Nghiệm thu**: 2 máy thật — máy A gửi qua Zalo/Messenger, máy B (chưa cài app) mở web thấy animation, cài app, tem về Album, máy A nhận noti "đã mở thư".

### Phase 4 — Hệ thống Dấu + Push (SM-033, SM-026, 2 tuần) 🔴 khép vòng tăng trưởng
Slice: các sự kiện Phase 2–3 bắt đầu trả Dấu thật; tiêu Dấu mở sticker/viền.

- [ ] `feature_rewards`: số dư Dấu (realtime từ `seal_ledger`), progressive disclosure (BR-04), màn giới thiệu lần đầu, lịch sử.
- [ ] Bật 4 nguồn kiếm: share 10📮 (cap 3/tuần), gửi 5📮, mở thư 15📮, install 50📮 (cap 5/tháng) — Functions đã stub từ Phase 2–3, giờ hoàn thiện + test cap/reset.
- [ ] Tiêu Dấu: `spendSeals` + UI mở sticker pack (50), viền (80), tem mẫu (30 — SM-035 làm luôn phần khoá); màn "thiếu X📮" (BR-14).
- [ ] Mua Dấu IAP (BR-15) qua RevenueCat consumable.
- [ ] `feature_notifications` → FCM: 5 loại noti + preference bật/tắt từng loại + deep-link đúng màn (SM-026).
- **Nghiệm thu**: AC-01→15 SM-033; vòng lặp gửi→mở→Dấu chạy trên 2 máy thật.

### Phase 5 — Premium & tiền (SM-028, 029, 030 + phần restore SM-000 BR-17, 1.5–2 tuần)
- [ ] `feature_premium`: paywall so sánh Free/Premium, gói tháng/năm (RevenueCat), mở khoá tức thì, quản lý/huỷ đăng ký, restore khi đăng nhập.
- [ ] `Entitlement` hoàn chỉnh: RevenueCat webhook → Firestore → các gate ở stamp_creator/letters đọc; cache offline (SM-006 BR-08).
- [ ] SM-030: nhắc hạn mức (còn N tem/thư), reset ngày 1, noti hạn mức.
- **Nghiệm thu**: mua sandbox iOS + Android, restore trên máy thứ hai, gate mở đúng.

### Phase 6 — Hoàn thiện trải nghiệm P1/P2 (3–4 tuần, song song hoá được)
Thứ tự trong phase linh hoạt, các mục độc lập nhau:

- [ ] SM-020 Trả lời thư (P1) — nối inbox → luồng soạn thư.
- [ ] SM-025 Chia sẻ tem bản đầy đủ (P1).
- [ ] SM-035 Bộ tem mẫu bản đầy đủ (P1).
- [ ] SM-032 Thiệp nhóm (P1) — `feature_group_card`; nhiều người ký chung, cần thêm collection + Functions riêng. *Mục lớn nhất phase này.*
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
P0: Nền → Auth → Tạo tem ─┬→ Gửi/Nhận thư → Dấu+Push → Premium
                          └→ Album (cùng Phase 2)
```

- **Auth trước tất cả**: mọi spec đều "đã đăng nhập" là tiên quyết.
- **Tạo tem trước thư**: thư bắt buộc đính tem (SM-014 BR-05) — không có tem thì không test được thư.
- **Dấu sau thư**: 3/4 nguồn kiếm Dấu phát sinh từ luồng thư; làm Dấu trước là xây kho cho hàng chưa tồn tại. Phase 2–3 ghi *event* sẵn, Phase 4 chỉ bật UI + hoàn thiện Function.
- **Premium sau Dấu**: paywall cần các điểm gate đã tồn tại (filter/sticker/viền/quota) — tất cả có sau Phase 2–4.
- **P2 cuối**: home/onboarding/hồ sơ scaffold đã chạy tạm được từ template, không chặn ai.

## 5. Ước lượng tổng

| Phase | Thời lượng (1 dev full-time) |
|---|---|
| 0 — Nền | 1 tuần |
| 1 — Auth | 1.5–2 tuần |
| 2 — Tạo tem + Album | 3–4 tuần |
| 3 — Gửi/Nhận thư + Web | 3–4 tuần |
| 4 — Dấu + Push | 2 tuần |
| 5 — Premium | 1.5–2 tuần |
| 6 — P1/P2 đầy đủ | 3–4 tuần |
| 7 — Ra mắt | 1–2 tuần |
| **MVP dùng được (hết Phase 4)** | **~10–13 tuần** |
| **Full** | **~16–21 tuần** |

> Ước lượng cho 1 dev; 2 dev có thể chạy song song từ Phase 3 (một người app, một người web+Functions) rút ~25–30%.

## 6. Rủi ro chính & giảm nhẹ

| # | Rủi ro | Giảm nhẹ |
|---|---|---|
| 1 | **Editor tem phức tạp hơn dự kiến** (gesture, giới hạn kích thước, xuất ảnh chất lượng) | Spike Phase 2 tuần đầu; nếu `pro_image_editor` fail → native có sẵn kế hoạch B trong TD-004 |
| 2 | **Deferred deep link không nhận diện đúng** (iOS privacy) | Test AppsFlyer sandbox sớm ngay Phase 3 tuần 1, trên thiết bị thật cả 2 OS |
| 3 | **Mở DM từng MXH** (8 nền tảng, URL scheme thay đổi, app không cài) | Fallback copy-link đã nằm trong spec (mục 5 SM-016) — làm fallback trước, scheme từng app sau |
| 4 | **Gian lận Dấu** (client giả event) | Toàn bộ cộng/trừ ở Functions + App Check; ledger bất biến, balance tính từ ledger |
| 5 | **Review store** (Facebook Login, quyền ảnh, IAP) | Compliance checklist ở Phase 7 nhưng cấu hình đúng ngay từ Phase 1 (Sign in with Apple bắt buộc khi có social login) |
| 6 | **Animation web ≠ app** | Chốt Rive/Lottie Phase 3, 1 asset 2 runtime; test trên trình duyệt yếu |

## 7. Việc còn treo (chốt tại phase ghi kèm)

1. Stack render trang web xem thư — **Phase 3, tuần 1** (TD-011).
2. Rive vs Lottie — **Phase 3, cùng lúc** (TD-010).
3. Kết quả spike `pro_image_editor` — **Phase 2, buổi đầu** (TD-004).
4. Chi tiết viền/khung tem — đọc kỹ spec 008 khi vào Phase 2.
5. Giá gói Premium + gói Dấu — cần trước Phase 5 (business quyết).

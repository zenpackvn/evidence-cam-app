# Maestro E2E Tests

End-to-end flows cho toàn bộ app. Chạy với [Maestro CLI](https://maestro.mobile.dev/).

## Cài đặt

```bash
curl -Ls "https://get.maestro.mobile.dev" | bash
```

## Chạy tất cả flows theo thứ tự

```bash
maestro test .maestro/flows/
```

## Chạy từng flow

```bash
maestro test .maestro/flows/01_onboarding.yaml
```

## Flows

| File | Mô tả |
|------|-------|
| `01_onboarding.yaml` | Cold start → register → walk through 3 onboarding steps → Home |
| `01b_onboarding_skip.yaml` | Onboarding: bấm Skip ở step 1 |
| `02_register.yaml` | Register form: validation (email không hợp lệ, password ngắn, trống) + đăng ký thành công |
| `03_login_validation.yaml` | Login: validation trống, sai credentials, toggle password, forgot password, social, navigate to register/back, đăng nhập thành công |
| `04_home.yaml` | Home screen: bottom nav tabs, search, Quick Add |
| `05_bookmarks_crud.yaml` | Bookmarks: Create (validation + form), Read, Update (edit title), Delete, Search, Sort |
| `06_collections_crud.yaml` | Collections: Create (từ bookmark detail), Read, Update, Remove bookmark, Delete |
| `07_notifications.yaml` | Notifications: 2 tabs (Notifications + Activity), pull-to-refresh |
| `08_profile.yaml` | Profile: header, theme switch, color swatch, copy user ID, About section |
| `09_change_password.yaml` | Change Password: validation (trống, mismatch), đổi thành công, verify login với mật khẩu mới |
| `10_signout.yaml` | Sign out: cancel dialog, confirm, verify session cleared sau khi relaunch |
| `11_delete_account.yaml` | Delete account (destructive): cancel, type username, confirm xóa |

## Test account

- **Email**: `onboarding_test@example.com`
- **Password**: `TestPass123` (đổi thành `NewPass456` sau flow 09)

Flow 11 dùng account riêng `delete_me@example.com` để tránh ảnh hưởng các flows khác.

## Lưu ý

- `_login_helper.yaml` là sub-flow dùng chung (không chạy trực tiếp).
- Các flows từ 03 trở đi giả sử account `onboarding_test@example.com` đã tồn tại (tạo bởi flow 01 hoặc 02).
- Flow 09 thay đổi password → các flows chạy sau cần dùng `NewPass456` nếu không reset state.
- Chạy `clearState: true` chỉ khi cần test fresh install.

## StampMail flows ([stampmail/](stampmail/))

Các flow production của StampMail (login → tạo tem → gửi thư → nhận thư) nằm
trong `stampmail/` với runner riêng `stampmail/run.sh` (iOS Simulator, cần
backend dev `https://stampmail-backend-dev.sabeel.app` sống — xem header của script).

## Chạy smoke trên CI

Workflow [.github/workflows/maestro-smoke.yml](../.github/workflows/maestro-smoke.yml)
build APK dev-debug, boot Android emulator và chạy `stampmail/01_login.yaml`
against backend dev hosted. Trigger thủ công:

```bash
gh workflow run maestro-smoke.yml
```

(hoặc tab Actions → "Maestro smoke" → Run workflow). Chủ đích **không** gắn vào
PR/nightly — repo private tính phí từng phút và flow phụ thuộc hạ tầng ngoài;
lý do đầy đủ ở [docs/decisions/0002](../docs/decisions/0002-maestro-smoke-manual-dispatch.md).

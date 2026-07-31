# Maestro E2E Tests

> ⚠️ **Hai bộ flow trong cùng thư mục.** Các flow `01`–`11` bên dưới là của
> Flutter Starter Template (bookmarks / collections) và trỏ vào appId cũ
> `com.aktechvn.quangsat` — **không chạy được với EvidenceCam**. Bộ đang dùng là
> `20`/`21` (Flow 2) và `30`/`31` (Flow 3), xem mục ngay dưới đây.

## EvidenceCam — Flow 2 & Flow 3

```bash
maestro test maestro/ \
  -e EC_EMAIL=nhanvien@shoptest.vn \
  -e EC_PASSWORD='...' \
  -e EC_TRACKING=SPXVN024567890 \
  -e EC_TRACKING_LOWER=spxvn024567890 \
  -e EC_VIDEO_TYPE='Đóng hàng'
```

| File | Phủ cái gì |
|------|-----------|
| `_ec_login.yaml` | Sub-flow đăng nhập + cấp sẵn quyền camera. Không chạy trực tiếp. |
| `20_flow2_orders.yaml` | Tab Vận đơn: thống kê, tìm kiếm (kể cả lệch hoa-thường), trạng thái rỗng, kéo làm mới, vào hàng đợi, bottom nav |
| `21_flow2_order_detail.yaml` | Dòng thời gian bằng chứng, sheet chi tiết (4 dữ kiện chain-of-custody), phát video + nhãn đè khung hình, đính kèm ảnh, thẻ link hồ sơ |
| `30_flow3_record.yaml` | Ghi hình bằng **nhập tay**: tạo đơn mới, quay, dừng, clip vào hàng đợi |
| `31_flow3_queue.yaml` | Hàng đợi: bộ lọc, tạm dừng/tiếp tục, **mất mạng không mất task**, sống sót restart, xóa |

`EC_TRACKING` nên là đơn **đã có sẵn bằng chứng đã upload xong**, nếu không
`21` sẽ dừng ở dòng thời gian rỗng. `EC_VIDEO_TYPE` phải khớp tên loại video
của chính shop đó (mỗi shop tự đặt).

### Không phủ được — và vì sao

| Nhánh | Vì sao |
|---|---|
| Quét bill để bắt đầu quay | Maestro chạm được màn hình, không giơ được tờ bill vào ống kính |
| Cut-over sang đơn khác giữa lúc quay | Cần mã thứ hai xuất hiện trong khung hình |
| QR kết thúc `EVIDENCECAM:END` | Như trên |
| Nhập tay mã **chữ-số** | Bàn phím nhập tay chỉ có số — xem mục dưới |
| **Tạo** hồ sơ khiếu nại | Cố ý: app chỉ đọc/copy/chia sẻ, việc tạo là của web admin |

Muốn phủ ba nhánh quét thì rẻ nhất là thêm một **deep link chỉ có ở bản debug**
bơm thẳng `RecordingCodeScanned(code)` vào bloc — khoảng 10 dòng, và mở khóa
được cả cut-over lẫn QR kết thúc mà không cần dựng giàn quay. Cách còn lại là
giàn thật: kẹp điện thoại nhìn xuống màn hình thứ hai đang hiện barcode.

### Đã phát hiện khi viết bộ test này

1. **Nhập tay không gõ được mã chữ-số.** `_Keypad` trong `ec_flow3.dart` chỉ
   phát ra chữ số (`onTap: () => onDigit(digit)`); các nhãn `ABC`/`DEF` là trang
   trí kiểu bàn phím điện thoại. Mã Shopee `SPXVN…` vì thế **không nhập tay
   được** — mà nhập tay chính là đường thoát khi tem rách/mờ (FR-01.9).
2. **Selector mong manh nhất là nút "Dừng quay"** — nó chỉ có `Tooltip`, không
   có nhãn chữ. Vài chỗ đáng thêm `Semantics(identifier:)` để bộ test hết phụ
   thuộc vào chuỗi tiếng Việt: nút dừng, dòng bằng chứng trên timeline, phím số,
   thẻ link hồ sơ.

---

## Bộ cũ (Starter Template — không còn chạy được)

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

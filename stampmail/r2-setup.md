# StampMail — Cloudflare R2 setup (kho ảnh)

**Cập nhật**: 2026-07-07
**Dùng cho**: lưu ảnh tem đã render, ảnh trong thư, avatar (thay Firebase Storage)
**Cơ chế upload**: **presigned URL** — app xin backend URL tạm rồi upload thẳng lên R2 (không qua server, không tốn băng thông Cloud Run).

> R2 tương thích S3 API. Backend Go dùng AWS SDK for Go (S3) trỏ endpoint R2 để ký presigned URL. Egress miễn phí → rẻ hơn nhiều S3/Firebase cho app nhiều ảnh.

---

## 1. Tạo R2 bucket

- [ ] Đăng nhập https://dash.cloudflare.com
- [ ] Menu trái → **R2** → (lần đầu phải thêm thẻ thanh toán, nhưng có free tier 10GB/tháng)
- [ ] **Create bucket**:
  - Tên: `stampmail-dev` (làm dev trước; prod tạo bucket riêng `stampmail-prod`)
  - Location: **Automatic** hoặc chọn APAC gần VN
- [ ] Tạo xong → **ghi lại tên bucket**

---

## 2. Lấy Account ID

- [ ] Trang R2 Overview → góc phải hiện **Account ID** (chuỗi hex ~32 ký tự) → ghi lại.
  - R2 endpoint sẽ là: `https://<ACCOUNT_ID>.r2.cloudflarestorage.com`

---

## 3. Tạo API token (Access Key)

- [ ] R2 → **Manage R2 API Tokens** (hoặc "API" → "Create API token")
- [ ] **Create API token**:
  - Permission: **Object Read & Write**
  - Bucket: chọn `stampmail-dev` (giới hạn đúng bucket, an toàn hơn "all buckets")
  - TTL: để mặc định / forever cho dev
- [ ] Tạo xong hiện **Access Key ID** + **Secret Access Key** → **COPY NGAY** (secret chỉ hiện 1 lần).
  - Ghi 2 giá trị này vào nơi an toàn (KHÔNG commit).

---

## 4. Public access cho ảnh (để người nhận xem thư trên web)

Ảnh tem phải xem được công khai qua URL (SM-017 — người nhận chưa cài app vẫn mở web thấy tem). 2 cách:

### Cách A — R2 public bucket qua custom domain (khuyên dùng cho prod)
- [ ] Bucket → **Settings** → **Public access** → **Connect Domain**
- [ ] Trỏ 1 subdomain bạn quản lý qua Cloudflare, vd `cdn.stampmail.com` → R2 tự cấu hình
- [ ] Public URL ảnh: `https://cdn.stampmail.com/<key>`

### Cách B — r2.dev subdomain (nhanh, cho dev)
- [ ] Bucket → Settings → Public access → bật **Allow Access** cho `r2.dev` subdomain
- [ ] Cloudflare cấp URL dạng `https://pub-xxxx.r2.dev/<key>`
- [ ] ⚠️ r2.dev có rate limit, chỉ nên dùng dev — prod dùng Cách A.

> Ghi lại **PUBLIC_BASE_URL** (dạng ở trên) — backend ghép với object key thành URL công khai lưu vào DB.

---

## 5. Tóm tắt "cần cung cấp cho Claude/backend"

Sau khi làm xong, set các env này cho Go backend:

```bash
export R2_ACCOUNT_ID=<Account ID bước 2>
export R2_BUCKET=stampmail-dev
export R2_ACCESS_KEY_ID=<Access Key ID bước 3>
export R2_SECRET_ACCESS_KEY=<Secret bước 3>
export R2_PUBLIC_BASE_URL=<PUBLIC_BASE_URL bước 4>   # vd https://pub-xxxx.r2.dev
```

→ Backend tự chuyển từ dev-mode (lưu file local qua `/api/upload` sẵn có) sang **ký presigned URL R2 thật**.

Chỉ cần đưa Claude 5 giá trị trên (Secret có thể để bạn tự set env, không cần gửi qua chat).

---

## 6. Luồng upload trong app (đã thiết kế)

```
1. App render tem → PNG
2. App gọi  POST /api/sm/uploads/presign  {content_type, kind:"stamp"}
   → backend ký, trả { upload_url, public_url, key }
3. App PUT ảnh thẳng lên upload_url (R2), không qua server
4. App gọi  POST /api/sm/stamps  {image_url: public_url, ...}
5. Backend lưu public_url vào Postgres (cột stamps.image_url)
```

DB chỉ giữ URL; ảnh nằm ở R2. (Khớp data-model.md — chỉ đổi nơi host ảnh từ Firebase Storage sang R2.)

---

## Ghi chú
- **Firebase Storage: KHÔNG dùng nữa** — bỏ khỏi firebase-setup (Firebase chỉ còn Auth + FCM).
- Free tier R2: 10GB lưu trữ + 1M class-A ops/tháng — dư cho MVP.
- CORS: nếu app/web upload trực tiếp gặp lỗi CORS, thêm CORS policy cho bucket (Settings → CORS) cho phép PUT từ origin app.

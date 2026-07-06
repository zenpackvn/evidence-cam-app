# Chia sẻ tem lên MXH (SM-025)

**Feature Branch**: `021-chia-se-tem-mxh`
**Ngày tạo**: 2026-06-24
**Trạng thái**: Draft
**Ưu tiên**: 🟡 P1

> **Tài liệu thuần nghiệp vụ** cho Tester (QA), Business Analyst (BA), Product Owner (PO).
> **KHÔNG chứa chi tiết kỹ thuật**. Phần plan / vẽ giao diện / develop được làm RIÊNG ở bước sau.

---

## 1. Mục đích nghiệp vụ

Biến tem đẹp thành kênh marketing hữu cơ — người dùng chia sẻ tem lên Stories/Feed của mạng xã hội, người lạ thấy tem đẹp và tò mò tải StampMail. Không tốn quảng cáo, watermark nhỏ trên tem là đủ.

## 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đã đăng nhập có ít nhất một tem trong Album.
- **Khi nào dùng:** Khi muốn khoe tem hoặc nội dung thư lên mạng xã hội công khai.
- **Điều kiện tiên quyết:** Đã đăng nhập (SM-001). Có tem trong Album (SM-022).
- **Phạm vi:** Chọn tem, chọn mức nội dung chia sẻ, chọn định dạng theo nền tảng, và xuất ảnh/chia sẻ. Không bao gồm gửi thư (SM-016) — đây là chia sẻ công khai lên feed/stories, không phải gửi riêng tư.

## 3. Quy tắc nghiệp vụ

- **BR-01 — Nền tảng hỗ trợ:** Có thể chia sẻ lên năm nền tảng: Instagram, TikTok, Facebook, Threads, Twitter/X.
- **BR-02 — Ba mức nội dung (người dùng tự chọn):**
  - Mức 1 — Chỉ tem: Chỉ ảnh tem, nội dung thư hoàn toàn riêng tư.
  - Mức 2 — Tem + một dòng trích dẫn: Người dùng tự chọn một câu từ thư để kèm theo tem.
  - Mức 3 — Tem + toàn bộ nội dung thư: Lộ đầy đủ nội dung thư kèm tem.
- **BR-03 — Cảnh báo trước khi lộ nội dung:** Với Mức 2 và Mức 3, hệ thống hiển thị cảnh báo rõ rằng nội dung thư sẽ được chia sẻ công khai. Người dùng phải xác nhận trước khi tiếp tục.
- **BR-04 — Người dùng chọn định dạng trước khi chia sẻ:** Vì ảnh được xuất trước khi người dùng chọn nền tảng, người dùng tự chọn một trong hai định dạng:
  - **Dọc 9:16** — phù hợp Stories (Instagram, Facebook, TikTok).
  - **Vuông 1:1** — phù hợp Feed/Post (Instagram, Facebook, Threads, Twitter/X).
- **BR-05 — Lưu về thư viện:** Người dùng có thể lưu ảnh đã định dạng về thư viện điện thoại để chia sẻ thủ công sau.
- **BR-06 — Watermark bắt buộc:** Mọi ảnh chia sẻ đều có watermark StampMail nhỏ ở góc — không thể tắt, không thể xoá. Đây là yêu cầu bắt buộc để duy trì nhận diện thương hiệu.
- **BR-07 — Cơ chế chia sẻ qua native share sheet:** Sau khi chọn định dạng và nội dung, hệ thống mở native share sheet của hệ điều hành. Người dùng tự chọn nền tảng từ danh sách do thiết bị cung cấp. App không tự mở thẳng vào từng nền tảng — không cần liên kết tài khoản MXH với StampMail.

### Trạng thái offline

- **BR-08 — Tạo ảnh và lưu về thư viện không cần mạng:** Khi thiết bị mất kết nối mạng, người dùng vẫn chọn được tem, chọn mức nội dung, chọn định dạng và lưu ảnh về thư viện điện thoại bình thường — các bước này hoàn toàn thực hiện cục bộ trên thiết bị.
- **BR-09 — Mở native share sheet vẫn cho phép nhưng hiển thị thông báo:** Khi thiết bị mất mạng, người dùng vẫn có thể mở native share sheet để chọn nền tảng; tuy nhiên ngay khi share sheet mở, hệ thống hiển thị thông báo nhắc nhở "Thiết bị đang ngoại tuyến — chia sẻ lên mạng xã hội có thể không thành công". Kết quả thực tế phụ thuộc vào từng nền tảng người dùng chọn.

## 4. Tiêu chí nghiệm thu

- **AC-01 — Chọn Mức 1 (chỉ tem), chọn định dạng và chia sẻ:**
  - **Giả sử** người dùng đang ở màn hình chia sẻ, chọn Mức 1 và định dạng 9:16;
  - **Khi** nhấn Chia sẻ;
  - **Thì** native share sheet của thiết bị mở ra với ảnh tem 9:16 kèm watermark — người dùng tự chọn Instagram, TikTok hoặc bất kỳ app nào từ sheet.

- **AC-02 — Cảnh báo khi chọn Mức 2/3:**
  - **Giả sử** người dùng chọn Mức 2 (kèm trích dẫn) hoặc Mức 3 (toàn bộ nội dung);
  - **Khi** nhấn Tiếp tục;
  - **Thì** hệ thống hiển thị cảnh báo "Nội dung thư sẽ công khai", yêu cầu xác nhận trước khi tiến hành.

- **AC-03 — Watermark luôn có trên ảnh chia sẻ:**
  - **Giả sử** người dùng chọn chia sẻ bất kỳ tem nào;
  - **Khi** ảnh được tạo ra để chia sẻ;
  - **Thì** watermark StampMail luôn xuất hiện ở góc ảnh, không có tùy chọn xoá.

- **AC-04 — Lưu về thư viện:**
  - **Giả sử** người dùng muốn đăng thủ công lên mạng xã hội;
  - **Khi** chọn "Lưu về thư viện";
  - **Thì** ảnh tem đã định dạng và có watermark được lưu vào thư viện ảnh điện thoại.

- **AC-05 — Người dùng chọn định dạng trước khi share sheet mở:**
  - **Giả sử** người dùng muốn đăng lên Stories;
  - **Khi** chọn định dạng 9:16 rồi nhấn Chia sẻ;
  - **Thì** native share sheet mở với ảnh tỉ lệ 9:16 — không phải 1:1.

### Offline

- **AC-06 — Lưu về thư viện vẫn thực hiện được khi mất mạng:**
  - **Giả sử** thiết bị đang mất kết nối mạng và người dùng đã chọn tem, chọn định dạng;
  - **Khi** chọn "Lưu về thư viện";
  - **Thì** ảnh tem có watermark được lưu thành công vào thư viện điện thoại mà không có thông báo lỗi mạng.

- **AC-07 — Hiển thị thông báo ngoại tuyến khi mở share sheet lúc mất mạng:**
  - **Giả sử** thiết bị đang mất kết nối mạng và người dùng nhấn Chia sẻ;
  - **Khi** native share sheet mở ra;
  - **Thì** hệ thống hiển thị thông báo "Thiết bị đang ngoại tuyến — chia sẻ lên mạng xã hội có thể không thành công" ngay trong màn hình, share sheet vẫn mở để người dùng tự quyết định.

## 5. Trường hợp ngoại lệ & lỗi

- Khi nền tảng MXH chưa được cài trên thiết bị: thay vì mở app, hệ thống cung cấp tùy chọn "Lưu về thư viện" để người dùng tự đăng thủ công.
- Khi người dùng từ chối cấp quyền lưu ảnh vào thư viện: thông báo cần quyền và hướng dẫn vào cài đặt.

### Nhóm 1 — Khi mất kết nối (offline / no network)

- Tạo ảnh, chọn mức nội dung và định dạng hoàn toàn thực hiện được khi mất mạng vì đây là bước xử lý cục bộ trên thiết bị.
- Lưu ảnh về thư viện điện thoại cũng thực hiện được khi mất mạng, không có thông báo lỗi mạng.
- Khi người dùng nhấn Chia sẻ lúc mất mạng, native share sheet vẫn mở nhưng hệ thống hiển thị cảnh báo "Thiết bị đang ngoại tuyến — chia sẻ lên mạng xã hội có thể không thành công"; việc đăng lên MXH có thành công hay không phụ thuộc vào ứng dụng MXH người dùng chọn.

### Nhóm 2 — Khi dữ liệu không tải được (network error / server error)

- Nếu danh sách tem trong Album không tải được do lỗi mạng hoặc máy chủ, màn hình hiển thị thông báo lỗi và nút "Thử lại" để người dùng nạp lại danh sách.
- Ảnh tem đã được lưu trong Album cục bộ vẫn dùng được bình thường để tạo hình chia sẻ ngay cả khi có lỗi máy chủ.

### Nhóm 3 — Khi chưa đăng nhập / thoát app giữa chừng

- Khi chưa đăng nhập mà cố truy cập tính năng Chia sẻ tem, hệ thống chuyển người dùng về màn hình đăng nhập; sau khi đăng nhập thành công, hệ thống quay lại luồng chia sẻ.
- Tạo ảnh chia sẻ (chọn tem, chọn định dạng) yêu cầu đăng nhập; không có chế độ khách cho tính năng này.
- Khi người dùng thoát app hoặc chuyển sang app khác giữa chừng (chưa kịp lưu hay chia sẻ), trạng thái chưa lưu bị huỷ; lần sau vào lại, người dùng bắt đầu lại từ bước chọn tem.

---

## Liên kết tính năng khác

- SM-022 (Album sưu tập tem): điểm xuất phát để chọn tem chia sẻ.
- SM-011 (Lưu tem): gợi ý chia sẻ xuất hiện ngay sau khi lưu tem.

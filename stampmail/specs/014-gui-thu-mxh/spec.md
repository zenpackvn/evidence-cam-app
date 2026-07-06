# Gửi thư qua MXH (SM-016)

**Feature Branch**: `014-gui-thu-mxh`
**Ngày tạo**: 2026-06-24
**Trạng thái**: Draft
**Ưu tiên**: 🔴 P0

> **Tài liệu thuần nghiệp vụ** cho Tester (QA), Business Analyst (BA), Product Owner (PO).
> **KHÔNG chứa chi tiết kỹ thuật**. Phần plan / vẽ giao diện / develop được làm RIÊNG ở bước sau.

---

## 1. Mục đích nghiệp vụ

Là cơ chế lan truyền cốt lõi của StampMail — người gửi chia sẻ link thư qua tin nhắn riêng (DM) trên mạng xã hội, không cần người nhận cài app trước. Mỗi link là một phong bì kỹ thuật số duy nhất, chỉ mở được một lần, tạo cảm giác "thư thật" chứ không phải tin nhắn đại trà.

## 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đã soạn xong thư và xác nhận gửi (SM-015).
- **Khi nào dùng:** Bước 5 (cuối) trong luồng soạn & gửi thư, sau SM-015.
- **Điều kiện tiên quyết:** Đã có thư hoàn chỉnh (SM-013), đã qua xem trước (SM-015). Đã đăng nhập.
- **Phạm vi:** Tạo link thư, mở DM của mạng xã hội đã chọn với link điền sẵn, theo dõi trạng thái gửi. Không bao gồm hộp thư đến của người nhận (SM-017/018).

## 3. Quy tắc nghiệp vụ

- **BR-01 — Mỗi thư = một link duy nhất:** Với mỗi người nhận, hệ thống tạo một link riêng biệt — không dùng chung link cho nhiều người nhận.
- **BR-02 — Link chỉ mở được một lần:** Người đầu tiên mở link sẽ nhận thư. Sau khi được mở, link không còn hiệu lực cho bất kỳ ai khác.
- **BR-03 — Link có thời hạn bảy ngày:** Link tự hết hiệu lực sau bảy ngày kể từ khi tạo, dù chưa được mở.
- **BR-04 — Nền tảng hỗ trợ:** Người dùng chọn mạng xã hội để gửi. Các nền tảng được hỗ trợ: Facebook Messenger, Instagram DM, TikTok DM, Threads, Zalo, WhatsApp, iMessage, Twitter/X DM.
- **BR-05 — Luồng mở DM:** Người dùng chọn nền tảng → ứng dụng mở sẵn DM của nền tảng đó với link thư đã điền vào → người dùng chọn người nhận trong ứng dụng MXH đó và gửi.
- **BR-06 — Gửi nhiều nền tảng cùng lúc:** Người dùng có thể gửi đến nhiều nền tảng trong cùng một lần gửi (mỗi nền tảng một link riêng).
- **BR-07 — Thông báo khi thư được đọc:** Người gửi nhận thông báo khi người nhận mở link và đọc thư.
- **BR-08 — Giới hạn thư tháng:**
  - Gói Thường: tối đa mười thư mỗi tháng.
  - Gói Premium: không giới hạn.
- **BR-09 — Attribution link:** Mỗi link mang thông tin nhận dạng người gửi để khi người nhận cài app từ link, hệ thống ghi nhận đúng nguồn giới thiệu.
- **BR-10 — Kiếm Dấu khi gửi thư:** Mỗi lần tạo link thư thành công, người gửi nhận ngay **5📮** (SM-033 BR-08). Không giới hạn số lần trong ngày.
- **BR-11 — Kiếm Dấu khi người nhận cài app:** Khi người nhận là tài khoản hoàn toàn mới và cài StampMail từ link thư (BR-09), người gửi nhận thêm **50📮** (SM-033 BR-10). Tối đa 5 lượt được thưởng loại này mỗi tháng.

### Trạng thái offline

- **BR-12 — Chặn tạo link khi mất mạng:** Khi người dùng không có kết nối mạng, thao tác tạo link thư bị chặn ngay lập tức. Hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." và giữ nguyên thư đã soạn để người dùng gửi lại sau.
- **BR-13 — Chặn mở DM khi mất mạng:** Khi không có kết nối, thao tác mở DM của mạng xã hội cũng bị chặn (vì link chưa được tạo). Người dùng không thể tiến hành bước chia sẻ cho đến khi có mạng trở lại.

## 4. Tiêu chí nghiệm thu

- **AC-01 — Chọn nền tảng và mở DM với link sẵn:**
  - **Giả sử** người dùng vừa xác nhận gửi thư;
  - **Khi** chọn "Gửi qua Zalo" (hoặc bất kỳ nền tảng nào trong danh sách);
  - **Thì** ứng dụng Zalo (hoặc nền tảng tương ứng) mở ra ở màn hình DM với nội dung link thư đã điền sẵn.

- **AC-02 — Từ chối tạo thêm link khi hết hạn mức Free:**
  - **Giả sử** người dùng gói Thường đã gửi đủ mười thư trong tháng;
  - **Khi** cố gắng gửi thêm thư;
  - **Thì** hệ thống thông báo đã đạt giới hạn tháng, gợi ý nâng cấp Premium hoặc chờ đầu tháng mới.

- **AC-03 — Link chỉ mở được một lần:**
  - **Giả sử** người nhận đã mở link và đọc thư;
  - **Khi** người nhận (hoặc người khác) nhấn link đó lần nữa;
  - **Thì** hệ thống thông báo thư này đã được đọc và không cho xem lại nội dung.

- **AC-04 — Người gửi nhận thông báo khi thư được đọc:**
  - **Giả sử** người gửi đã gửi link thư thành công;
  - **Khi** người nhận mở link và đọc thư;
  - **Thì** người gửi nhận thông báo trong app "[Tên người nhận] đã mở thư của bạn" (hoặc tương đương).

- **AC-05 — Link tự hết hạn sau bảy ngày:**
  - **Giả sử** link thư đã được tạo nhưng chưa ai mở;
  - **Khi** quá bảy ngày kể từ khi tạo;
  - **Thì** người nhận mở link thấy thông báo link đã hết hạn, không xem được nội dung.

- **AC-06 — Premium gửi không giới hạn:**
  - **Giả sử** người dùng gói Premium;
  - **Khi** gửi thư bất kỳ lúc nào trong tháng;
  - **Thì** không bị chặn bởi giới hạn số lượng.

- **AC-07 — Danh sách nền tảng hiển thị đúng:**
  - **Giả sử** người dùng vừa xác nhận gửi thư;
  - **Khi** màn hình chọn nền tảng hiển thị;
  - **Thì** thấy đủ tám nền tảng: Facebook Messenger, Instagram DM, TikTok DM, Threads, Zalo, WhatsApp, iMessage, Twitter/X DM.

- **AC-08 — Gửi cùng một thư đến nhiều nền tảng tạo link riêng cho mỗi nền tảng:**
  - **Giả sử** người dùng muốn gửi thư đến cả Zalo lẫn Instagram DM;
  - **Khi** chọn cả hai nền tảng và xác nhận;
  - **Thì** mỗi nền tảng nhận một link khác nhau (không dùng chung link); người dùng chia sẻ từng link qua từng app lần lượt.

- **AC-09 — Người nhận cài app từ link được ghi nhận đúng nguồn:**
  - **Giả sử** người nhận chưa có StampMail và mở link thư trên trình duyệt;
  - **Khi** người nhận tải và cài StampMail từ gợi ý trên trang xem thư;
  - **Thì** hệ thống ghi nhận tài khoản mới này được giới thiệu từ người gửi ban đầu.

- **AC-10 — Nhận Dấu ngay khi gửi thư thành công:**
  - **Giả sử** người dùng vừa xác nhận gửi thư và link được tạo thành công;
  - **Khi** màn hình xác nhận gửi hiển thị;
  - **Thì** số Dấu của người dùng tăng 5📮 và hiện thông báo nhỏ "Bạn kiếm được 5📮".

- **AC-11 — Nhận Dấu khi người nhận cài app (lượt ≤ 5 trong tháng):**
  - **Giả sử** người nhận chưa có StampMail và vừa hoàn tất cài app từ link thư, người gửi chưa đủ 5 lượt thưởng loại này trong tháng;
  - **Khi** tài khoản mới của người nhận được tạo thành công;
  - **Thì** người gửi nhận 50📮 và thông báo push "Bạn vừa giới thiệu người dùng mới và nhận 50📮!".

- **AC-12 — Không nhận thêm Dấu khi đã đủ 5 lượt cài app trong tháng:**
  - **Giả sử** người gửi đã nhận thưởng cài app đủ 5 lần trong tháng;
  - **Khi** người nhận thứ 6 cài app từ link của người gửi;
  - **Thì** người gửi không nhận thêm Dấu và không có thông báo thưởng.

### Offline

- **AC-13 — Chặn tạo link khi mất mạng:**
  - **Giả sử** người dùng đã soạn xong thư và đang ở màn hình chọn nền tảng để gửi, nhưng thiết bị không có kết nối mạng;
  - **Khi** người dùng nhấn nút xác nhận gửi (hoặc chọn nền tảng để tạo link);
  - **Thì** hệ thống không tạo link, hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng.", và giữ nguyên thư đã soạn trên màn hình.

- **AC-14 — Gửi thành công ngay khi kết nối được khôi phục:**
  - **Giả sử** người dùng đã thấy thông báo lỗi mạng ở AC-13 và thiết bị vừa có mạng trở lại;
  - **Khi** người dùng nhấn thử lại;
  - **Thì** hệ thống tạo link thư bình thường và tiếp tục luồng gửi qua MXH như khi có mạng.

## 5. Trường hợp ngoại lệ & lỗi

- Khi ứng dụng MXH chưa được cài trên thiết bị: thay vì mở ứng dụng, hệ thống sao chép link vào bộ nhớ tạm và thông báo người dùng tự dán vào bất kỳ ứng dụng nhắn tin nào.
- Khi mất kết nối lúc tạo link: hệ thống chặn thao tác tạo link, hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng.", và giữ nguyên toàn bộ nội dung thư đã soạn — người dùng không mất dữ liệu và có thể thử lại khi có mạng.
- Khi lỗi phía máy chủ (tạo link thất bại dù có mạng): hệ thống hiển thị thông báo lỗi và nút "Thử lại" để người dùng gửi lại mà không cần soạn lại thư.
- Khi chưa đăng nhập mà cố gắng gửi thư: hệ thống chuyển ngay về màn hình đăng nhập, không cho thực hiện thao tác tạo link.
- Khi người dùng thoát app giữa chừng (trước khi link được tạo thành công): nội dung thư đã soạn được giữ lại, lần sau mở app người dùng vẫn thấy thư ở trạng thái chờ gửi.
- Khi người dùng thoát màn hình gửi mà chưa gửi: thư chưa được gửi đi; quay về xem trước thư (SM-015) hoặc màn hình chính.

---

## Liên kết tính năng khác

- SM-015 (Xem trước thư): bước trước xác nhận gửi.
- SM-017 (Nhận thư qua Link): hành trình của người nhận sau khi nhận link.
- SM-021 (Hộp thư đã gửi): theo dõi trạng thái link sau khi gửi.
- SM-026 (Thông báo push): cơ chế thông báo khi thư được đọc.
- SM-030 (Giới hạn tháng): quy tắc giới hạn mười thư/tháng Free.
- SM-033 (Hệ thống Dấu): quy tắc thưởng 5📮 khi gửi và 50📮 khi người nhận cài app.

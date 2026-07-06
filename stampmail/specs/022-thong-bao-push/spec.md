# Thông báo push (SM-026)

**Feature Branch**: `022-thong-bao-push`
**Ngày tạo**: 2026-06-24
**Trạng thái**: Draft
**Ưu tiên**: 🟡 P1

> **Tài liệu thuần nghiệp vụ** cho Tester (QA), Business Analyst (BA), Product Owner (PO).
> **KHÔNG chứa chi tiết kỹ thuật**. Phần plan / vẽ giao diện / develop được làm RIÊNG ở bước sau.

---

## 1. Mục đích nghiệp vụ

Kéo người dùng quay lại app vào đúng thời điểm họ cần — khi có thư mới đến, khi thư được đọc, khi hạn mức sắp cạn. Mỗi loại thông báo phục vụ một vòng lặp re-engagement khác nhau.

## 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đã đăng nhập và đã cấp quyền nhận thông báo.
- **Khi nào dùng:** Hệ thống tự động gửi dựa trên sự kiện; người dùng không kích hoạt thủ công.
- **Điều kiện tiên quyết:** Đã đăng nhập (SM-001). Đã cấp quyền thông báo cho app.
- **Phạm vi:** Năm loại thông báo push (3 loại sự kiện thông thường + 2 loại Dấu) và cài đặt bật/tắt từng loại độc lập. Không bao gồm thông báo trong app (in-app notification — hiển thị khi đang dùng app).

## 3. Quy tắc nghiệp vụ

- **BR-01 — Năm loại thông báo:** Hệ thống gửi thông báo push cho năm sự kiện sau:
  - (1) **Thư đến:** "Bạn có thư mới từ [tên người gửi]" — khi người dùng nhận được link thư mới.
  - (2) **Thư được đọc:** "[Tên người nhận] đã mở thư của bạn" — khi người nhận mở link thư.
  - (3) **Hạn mức Free sắp cạn:** "Bạn còn [N] thư / [N] tem trong tháng này"
  - (4) **Kiếm Dấu khi thư được mở:** "Thư của bạn đã được mở — bạn nhận 15📮!" — khi người nhận hoàn thành xem animation lần đầu (SM-019 BR-06).
  - (5) **Kiếm Dấu khi giới thiệu người dùng mới:** "Bạn vừa giới thiệu người dùng mới và nhận 50📮!" — khi người nhận cài app từ link thư trong hạn mức 5 lượt/tháng (SM-016 BR-11).
- **BR-02 — Cài đặt bật/tắt từng loại:** Người dùng có thể bật hoặc tắt từng loại thông báo riêng biệt trong cài đặt — không phải bật/tắt tất cả cùng lúc.
- **BR-03 — Cần quyền hệ điều hành:** Trước khi gửi thông báo lần đầu, app phải xin quyền thông báo từ hệ điều hành. Nếu người dùng từ chối, không có thông báo nào được gửi.
- **BR-04 — Nhấn thông báo dẫn đến đúng màn hình:** Nhấn vào thông báo mở thẳng màn hình liên quan (thư đến → màn hình mở thư; thư được đọc → hộp thư đã gửi; hạn mức → màn hình nâng cấp Premium; thông báo Dấu → màn hình số Dấu hiện có).
- **BR-05 — Thông báo Dấu có thể tắt riêng:** Hai loại thông báo Dấu (loại 4 và 5) có thể bật/tắt riêng biệt, độc lập với ba loại thông báo còn lại.

### Trạng thái offline

- **BR-06 — Xếp hàng chờ khi thiết bị mất mạng:** Khi thiết bị của người nhận đang mất kết nối mạng, thông báo push chưa được giao vẫn được giữ lại trong hàng chờ và tự động giao đến thiết bị ngay khi có kết nối trở lại — không cần người dùng thao tác thêm.
- **BR-07 — Nội dung thông báo không thay đổi sau khi chờ:** Thông báo được giao sau khi thiết bị có mạng trở lại phải giữ nguyên nội dung ban đầu (tên người gửi, số Dấu, v.v.) — không bị mất dữ liệu hoặc hiển thị sai trong khi chờ.

## 4. Tiêu chí nghiệm thu

- **AC-01 — Thông báo thư đến:**
  - **Giả sử** người dùng A gửi link thư cho người dùng B và B mở link;
  - **Khi** B nhận và mở link thư;
  - **Thì** A nhận thông báo push "B đã mở thư của bạn" (nếu loại này đang bật).

- **AC-02 — Tắt một loại thông báo:**
  - **Giả sử** người dùng vào cài đặt và tắt "Thông báo thư được đọc";
  - **Khi** người nhận mở thư của người dùng;
  - **Thì** người dùng không nhận thông báo "đã mở thư", nhưng các loại thông báo khác vẫn hoạt động.

- **AC-03 — Nhấn thông báo dẫn đúng màn hình:**
  - **Giả sử** người dùng nhận thông báo "Bạn có thư mới từ An";
  - **Khi** nhấn vào thông báo;
  - **Thì** app mở và chuyển thẳng đến màn hình mở thư đó (với animation — SM-019).

- **AC-04 — Thông báo hạn mức sắp cạn:**
  - **Giả sử** người dùng gói Thường còn hai thư trong tháng (hạn mức tháng là mười thư);
  - **Khi** gửi thư thứ chín;
  - **Thì** nhận thông báo "Bạn còn 1 thư trong tháng này".

- **AC-05 — Không thông báo khi đã tắt tất cả:**
  - **Giả sử** người dùng đã tắt toàn bộ quyền thông báo ở cài đặt hệ điều hành;
  - **Khi** có bất kỳ sự kiện nào xảy ra;
  - **Thì** người dùng không nhận được thông báo push nào.

- **AC-06 — Thông báo Dấu khi thư được mở:**
  - **Giả sử** người dùng A đã gửi thư và bật loại thông báo loại 4;
  - **Khi** người nhận hoàn thành xem animation lần đầu;
  - **Thì** A nhận thông báo push "Thư của bạn đã được mở — bạn nhận 15📮!".

- **AC-07 — Thông báo Dấu khi giới thiệu người dùng mới:**
  - **Giả sử** người dùng A đã gửi thư và bật loại thông báo loại 5;
  - **Khi** người nhận cài StampMail từ link thư và A chưa đủ 5 lượt trong tháng;
  - **Thì** A nhận thông báo push "Bạn vừa giới thiệu người dùng mới và nhận 50📮!".

### Offline

- **AC-08 — Thông báo được giao sau khi có mạng trở lại:**
  - **Giả sử** thiết bị của người dùng A đang mất kết nối mạng và hệ thống phát sinh thông báo "Bạn có thư mới từ Bình";
  - **Khi** thiết bị của A kết nối mạng trở lại;
  - **Thì** A nhận được thông báo đó với đúng nội dung ban đầu, không bị mất hay sai thông tin.

- **AC-09 — Nhiều thông báo xếp hàng đều được giao đủ:**
  - **Giả sử** trong khi thiết bị của người dùng A mất mạng, có ba sự kiện phát sinh (một thư đến, một thư được đọc, một thông báo Dấu) và cả ba loại tương ứng đang bật;
  - **Khi** thiết bị kết nối lại;
  - **Thì** A nhận đủ ba thông báo, mỗi thông báo đúng nội dung và đúng loại.

## 5. Trường hợp ngoại lệ & lỗi

- Khi người dùng từ chối quyền thông báo: trong lần đầu từ chối, app không hỏi lại; nhưng trong cài đặt, hiển thị hướng dẫn cấp quyền thủ công từ cài đặt điện thoại.
- Khi thiết bị đang tắt hoặc ngoại tuyến: thông báo được hàng đợi và gửi khi thiết bị có kết nối trở lại (tùy hệ điều hành).
- Khi mất kết nối và người dùng thay đổi cài đặt thông báo: thay đổi bật/tắt từng loại thông báo vẫn được lưu cục bộ ngay lập tức và tự đồng bộ lên hệ thống khi có mạng trở lại — người dùng không cần thao tác lại.
- Khi hệ thống không giao được thông báo do lỗi máy chủ: người dùng không thấy màn hình lỗi; thông báo bị bỏ qua lần đó và sẽ không tự gửi lại — người dùng có thể kiểm tra trạng thái thư trong hộp thư thay thế.
- Khi chưa đăng nhập: app không gửi bất kỳ thông báo cá nhân nào (thư đến, thư được đọc, hạn mức, Dấu); màn hình cài đặt thông báo không hiển thị với người dùng chưa đăng nhập.
- Khi người dùng thoát app giữa chừng (đang xem cài đặt thông báo): các thay đổi đã lưu được giữ nguyên; lần sau vào lại app, cài đặt hiển thị đúng trạng thái đã chỉnh trước đó.

---

## Liên kết tính năng khác

- SM-027 (Cài đặt tài khoản): nơi người dùng bật/tắt từng loại thông báo.
- SM-016 (Gửi thư): kích hoạt thông báo "thư được đọc".
- SM-017 (Nhận thư): kích hoạt thông báo "thư đến".
- SM-030 (Giới hạn tháng): kích hoạt thông báo "hạn mức sắp cạn".
- SM-033 (Hệ thống Dấu): nguồn của thông báo loại 4 (thư được mở → 15📮) và loại 5 (giới thiệu người dùng mới → 50📮).

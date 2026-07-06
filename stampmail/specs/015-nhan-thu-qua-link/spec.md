# Nhận thư qua Link (SM-017)

**Feature Branch**: `015-nhan-thu-qua-link`
**Ngày tạo**: 2026-06-24
**Trạng thái**: Draft
**Ưu tiên**: 🔴 P0

> **Tài liệu thuần nghiệp vụ** cho Tester (QA), Business Analyst (BA), Product Owner (PO).
> **KHÔNG chứa chi tiết kỹ thuật**. Phần plan / vẽ giao diện / develop được làm RIÊNG ở bước sau.

---

## 1. Mục đích nghiệp vụ

Là điểm tiếp xúc đầu tiên của người nhận với StampMail — mở link mà không cần cài app trước, xem thư ngay trên trình duyệt web, rồi được mời cài StampMail để sưu tầm tem. Giảm ma sát tối đa để tăng tỉ lệ người nhận thực sự đọc thư và sau đó tải app.

## 2. Đối tượng & phạm vi

- **Người dùng:** Người nhận link thư (có thể chưa có tài khoản StampMail, chưa cài app).
- **Khi nào dùng:** Khi nhấn link thư nhận được qua DM trên mạng xã hội.
- **Điều kiện tiên quyết:** Có link thư hợp lệ chưa hết hạn và chưa được ai mở.
- **Phạm vi:** Xem thư trên web (không cần app), gợi ý cài app để lưu tem, và lưu tem vào Album khi có tài khoản. Không bao gồm animation chi tiết của việc mở thư (SM-019).

## 3. Quy tắc nghiệp vụ

- **BR-01 — Xem được trên web không cần app:** Người nhận mở link trên trình duyệt của điện thoại hoặc máy tính, thấy đầy đủ thư mà không cần cài StampMail.
- **BR-02 — Xem được trong app nếu đã cài:** Nếu điện thoại đã cài StampMail, link tự mở trong app thay vì trình duyệt.
- **BR-03 — Chỉ người đầu tiên mở link nhận được thư:** Đây là link một lần. Người thứ hai nhấp cùng link thấy thông báo thư đã được nhận bởi người khác.
- **BR-04 — Gợi ý cài app sau khi đọc:** Sau khi đọc thư, người nhận chưa có app thấy gợi ý tải StampMail để lưu tem và tạo tem của riêng mình.
- **BR-05 — Tem vào Album khi có tài khoản:** Tem trong thư chỉ được thêm vào Album của người nhận khi người nhận đăng nhập (hoặc đăng ký) vào StampMail sau khi đọc thư. Nếu chỉ xem trên web không đăng nhập, tem không được lưu.
- **BR-06 — Link hết hạn:** Người nhận mở link sau bảy ngày kể từ khi tạo thấy thông báo link đã hết hạn, không xem được nội dung.

### Trạng thái offline

- **BR-07 — Không tải được thư khi mất mạng ngay từ đầu:** Nếu người nhận nhấn link trong khi không có kết nối, trang web hiển thị thông báo "Không có kết nối mạng. Vui lòng thử lại khi có mạng." và không hiển thị nội dung thư.
- **BR-08 — Vẫn đọc được thư đã tải xong nếu mất mạng giữa chừng:** Nếu người nhận đã tải xong nội dung thư rồi mới mất mạng, nội dung thư (bao gồm tem) vẫn hiển thị được để đọc; trang hiển thị thông báo nhỏ "Đang xem ngoại tuyến".
- **BR-09 — Chặn đăng nhập/đăng ký khi mất mạng:** Nếu người nhận nhấn "Tải StampMail" hoặc thực hiện đăng nhập/đăng ký trong khi không có kết nối, hệ thống chặn thao tác và thông báo "Không có kết nối. Vui lòng thử lại khi có mạng.", giữ nguyên dữ liệu đã nhập.

## 4. Tiêu chí nghiệm thu

- **AC-01 — Xem thư trên trình duyệt không cần app:**
  - **Giả sử** người nhận chưa cài StampMail và nhận được link;
  - **Khi** nhấn link và mở bằng trình duyệt;
  - **Thì** thấy đầy đủ nội dung thư: animation mở thư (SM-019), nội dung, tem, không cần đăng nhập.

- **AC-02 — Link mở trong app nếu đã cài:**
  - **Giả sử** người nhận đã cài StampMail trên điện thoại;
  - **Khi** nhấn link thư;
  - **Thì** StampMail tự mở và hiển thị thư trong app.

- **AC-03 — Người thứ hai mở link thấy đã được nhận:**
  - **Giả sử** link đã được một người mở trước;
  - **Khi** người khác (hoặc cùng người) nhấn link lần nữa;
  - **Thì** thấy thông báo thư này đã được nhận, không thấy nội dung.

- **AC-04 — Gợi ý tải app sau khi đọc (người dùng chưa có app):**
  - **Giả sử** người đọc thư trên trình duyệt, chưa cài app;
  - **Khi** kết thúc animation mở thư và đọc xong;
  - **Thì** thấy gợi ý tải StampMail để lưu tem và nhận thư của mình.

- **AC-05 — Tem vào Album sau khi đăng nhập:**
  - **Giả sử** người nhận vừa đọc thư trên web và nhấn "Tải StampMail" rồi đăng ký/đăng nhập;
  - **Khi** đăng nhập thành công;
  - **Thì** tem trong thư được tự động thêm vào Album của người nhận.

- **AC-06 — Link hết hạn:**
  - **Giả sử** link thư đã quá bảy ngày từ khi được tạo;
  - **Khi** người nhận nhấn link;
  - **Thì** thấy thông báo link đã hết hạn, không xem được nội dung thư.

### Offline

- **AC-07 — Không tải được thư khi mất mạng ngay từ đầu:**
  - **Giả sử** người nhận không có kết nối mạng và nhấn link thư;
  - **Khi** trang web cố tải nội dung thư;
  - **Thì** trang hiển thị thông báo "Không có kết nối mạng. Vui lòng thử lại khi có mạng." và không hiển thị nội dung thư.

- **AC-08 — Đọc được thư đã tải xong dù mất mạng giữa chừng:**
  - **Giả sử** người nhận đã tải xong toàn bộ nội dung thư và tem, sau đó mất kết nối mạng;
  - **Khi** tiếp tục đọc thư hoặc xem tem trên trang;
  - **Thì** nội dung thư và tem vẫn hiển thị đầy đủ, trang hiển thị thông báo nhỏ "Đang xem ngoại tuyến"; nút đăng nhập/đăng ký bị vô hiệu hóa và thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." khi nhấn vào.

## 5. Trường hợp ngoại lệ & lỗi

**Khi mất kết nối (offline / không có mạng):**
- Nếu người nhận nhấn link khi chưa có mạng, trang web hiển thị thông báo "Không có kết nối mạng. Vui lòng thử lại khi có mạng." và không hiển thị nội dung thư.
- Nếu người nhận đã tải xong toàn bộ nội dung thư rồi mới mất mạng, nội dung thư và tem vẫn hiển thị để đọc, trang hiển thị thông báo nhỏ "Đang xem ngoại tuyến".
- Khi đang xem ngoại tuyến, mọi thao tác cần mạng (đăng nhập, đăng ký, tải app) bị vô hiệu hoá và hiển thị thông báo yêu cầu kết nối lại; dữ liệu đã nhập không bị mất.

**Khi dữ liệu không tải được (lỗi mạng / lỗi máy chủ):**
- Nếu trang web không lấy được nội dung thư do lỗi kết nối hoặc lỗi máy chủ, hiển thị màn hình lỗi kèm nút "Thử lại" để người nhận tải lại thủ công.
- Khi link sai định dạng hoặc không tồn tại, trang web hiển thị thông báo link không hợp lệ, không có nút thử lại.
- Khi link đã hết hạn (quá bảy ngày), trang web hiển thị thông báo link đã hết hạn, người nhận không xem được nội dung.

**Khi chưa đăng nhập / thoát app giữa chừng:**
- Người nhận chưa có tài khoản vẫn mở và đọc thư bình thường ở chế độ khách; chỉ cần đăng nhập nếu muốn lưu tem vào Album hoặc trả lời thư.
- Nếu người nhận nhấn "Tải StampMail" hoặc đăng nhập rồi thoát app hoặc đóng trình duyệt giữa chừng, nội dung thư trên web vẫn có thể truy cập lại qua link gốc (nếu link còn hợp lệ và chưa bị người khác nhận).

---

## Liên kết tính năng khác

- SM-016 (Gửi thư qua MXH): nơi tạo link thư.
- SM-019 (Mở thư & Animation): animation mở thư diễn ra sau khi nhận được link hợp lệ.
- SM-022 (Album sưu tập tem): nơi tem được lưu vào sau khi người nhận đăng nhập.

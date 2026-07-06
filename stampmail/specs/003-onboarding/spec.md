# Onboarding — Trải nghiệm lần đầu (SM-003)

**Feature Branch**: `003-onboarding`
**Ngày tạo**: 2026-06-24
**Trạng thái**: Draft
**Ưu tiên**: P2

> **Tài liệu thuần nghiệp vụ** cho Tester (QA), Business Analyst (BA), Product Owner (PO).
> **KHÔNG chứa chi tiết kỹ thuật**. Phần plan / vẽ giao diện / develop được làm RIÊNG ở bước sau.

---

## 1. Mục đích nghiệp vụ

Giới thiệu nhanh cách dùng StampMail cho người dùng mới ngay sau khi đăng ký, giúp họ hiểu được ba hành động cốt lõi (tạo tem → viết thư → gửi bạn) mà không bị choáng ngợp. Kết thúc onboarding đưa thẳng vào luồng tạo tem đầu tiên để tạo ngay giá trị.

## 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng vừa hoàn tất đăng ký lần đầu tiên.
- **Khi nào dùng:** Tự động chạy một lần duy nhất ngay sau khi đăng ký xong.
- **Điều kiện tiên quyết:** Đã hoàn tất đăng ký (xem SM-000).
- **Phạm vi:** Màn hình giới thiệu ngắn, nút Bỏ qua, và chuyển sang tạo tem đầu tiên. Không bao gồm hướng dẫn tương tác chi tiết (tooltip, coach mark trong từng màn hình).

## 3. Quy tắc nghiệp vụ

- **BR-01 — Chỉ chạy một lần:** Onboarding xuất hiện đúng một lần ngay sau khi đăng ký. Những lần mở app sau, onboarding không hiện lại dù người dùng đăng xuất rồi đăng nhập lại trên cùng thiết bị.
- **BR-02 — Số màn hình:** Onboarding gồm ba đến bốn màn hình ngắn, mỗi màn hình giới thiệu một bước: (1) tạo tem từ ảnh, (2) viết thư và đính tem, (3) gửi thư qua mạng xã hội, (4) sưu tầm và nhận tem.
- **BR-03 — Nút Bỏ qua:** Người dùng có thể bỏ qua toàn bộ onboarding bất kỳ lúc nào bằng nút Bỏ qua.
- **BR-04 — Kết thúc dẫn vào tạo tem:** Dù hoàn thành onboarding hay nhấn Bỏ qua, hệ thống đưa người dùng vào màn hình tạo tem đầu tiên (SM-005).

### Trạng thái offline

- **BR-05 — Nội dung onboarding hiển thị không cần mạng:** Toàn bộ các màn hình onboarding đều là nội dung tĩnh; khi mất kết nối mạng, onboarding vẫn hiển thị và người dùng vẫn có thể lướt qua từng màn hình, nhấn Bỏ qua hoặc nhấn Bắt đầu bình thường.
- **BR-06 — Không chặn onboarding khi offline:** Hệ thống không hiển thị thông báo lỗi mạng trong quá trình xem onboarding; thông báo lỗi mạng (nếu có) chỉ xuất hiện ở bước tiếp theo nếu bước đó yêu cầu kết nối.

## 4. Tiêu chí nghiệm thu

- **AC-01 — Onboarding chạy sau đăng ký:**
  - **Giả sử** người dùng vừa hoàn tất đăng ký lần đầu;
  - **Khi** màn hình đầu tiên của app xuất hiện;
  - **Thì** onboarding tự động hiển thị trước khi vào màn hình chính.

- **AC-02 — Không hiện lại lần hai:**
  - **Giả sử** người dùng đã từng thấy onboarding;
  - **Khi** mở lại app lần tiếp theo;
  - **Thì** onboarding không xuất hiện, vào thẳng màn hình chính.

- **AC-03 — Bỏ qua chuyển sang tạo tem:**
  - **Giả sử** người dùng đang xem màn hình onboarding bất kỳ;
  - **Khi** nhấn Bỏ qua;
  - **Thì** onboarding đóng lại và mở luồng tạo tem đầu tiên.

- **AC-04 — Hoàn thành onboarding chuyển sang tạo tem:**
  - **Giả sử** người dùng xem đến màn hình cuối của onboarding;
  - **Khi** nhấn Bắt đầu (hoặc tên hành động tương đương ở màn hình cuối);
  - **Thì** onboarding kết thúc và mở luồng tạo tem đầu tiên.

### Offline

- **AC-05 — Onboarding chạy bình thường khi mất mạng:**
  - **Giả sử** người dùng đang xem onboarding và thiết bị không có kết nối mạng;
  - **Khi** lướt qua từng màn hình onboarding và nhấn Bỏ qua hoặc Bắt đầu;
  - **Thì** tất cả màn hình onboarding hiển thị đầy đủ, các nút phản hồi đúng, không có thông báo lỗi mạng nào xuất hiện trong suốt quá trình onboarding.

## 5. Trường hợp ngoại lệ & lỗi

- Khi mất kết nối (offline): toàn bộ màn hình onboarding vẫn hiển thị đầy đủ hình ảnh và nội dung vì đây là nội dung tĩnh được đóng gói sẵn trong app; người dùng lướt qua từng bước và nhấn Bỏ qua / Bắt đầu bình thường mà không thấy bất kỳ thông báo lỗi mạng nào.
- Khi xảy ra lỗi máy chủ hoặc không tải được dữ liệu từ mạng: onboarding không bị ảnh hưởng vì không phụ thuộc dữ liệu từ máy chủ; không hiển thị màn hình trống, skeleton hay nút Thử lại trong phạm vi tính năng này.
- Chưa đăng nhập: onboarding chạy trước bước đăng nhập nên điều kiện đăng nhập không áp dụng; người dùng xem và hoàn tất onboarding bình thường mà không cần tài khoản.
- Khi thoát app giữa chừng onboarding: hệ thống lưu lại bước đang xem; lần mở app tiếp theo, onboarding tiếp tục từ màn hình đã dừng thay vì bắt đầu lại từ đầu.

---

## Liên kết tính năng khác

- SM-000 (Đăng ký): onboarding chạy ngay sau đăng ký.
- SM-005 (Chụp/Chọn ảnh): điểm đến sau khi kết thúc onboarding.
- SM-004 (Màn hình chính): điểm đến sau khi hoàn thành tạo tem đầu tiên.

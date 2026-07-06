# Màn hình chính (Home) — SM-004

**Feature Branch**: `004-man-hinh-chinh`
**Ngày tạo**: 2026-06-24
**Trạng thái**: Draft
**Ưu tiên**: P2

> **Tài liệu thuần nghiệp vụ** cho Tester (QA), Business Analyst (BA), Product Owner (PO).
> **KHÔNG chứa chi tiết kỹ thuật**. Phần plan / vẽ giao diện / develop được làm RIÊNG ở bước sau.

---

## 1. Mục đích nghiệp vụ

Là trung tâm điều hướng của ứng dụng — người dùng nhìn vào biết ngay mình cần làm gì tiếp theo (tạo tem, đọc thư mới, xem album). Giảm thời gian tìm kiếm chức năng, tăng tần suất quay lại.

## 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đã đăng nhập.
- **Khi nào dùng:** Mỗi khi mở app (sau onboarding hoặc từ những lần sau).
- **Điều kiện tiên quyết:** Đã đăng nhập (xem SM-001).
- **Phạm vi:** Hiển thị số thư chưa đọc, tem gần nhất, gợi ý hành động và thanh điều hướng. Không bao gồm chi tiết từng chức năng (mỗi chức năng có spec riêng).

## 3. Quy tắc nghiệp vụ

- **BR-01 — Số thư chưa đọc:** Màn hình chính hiển thị số thư chưa đọc. Khi không có thư chưa đọc, không hiển thị số (hoặc hiển thị bằng không).
- **BR-02 — Tem gần nhất:** Hiển thị tem được tạo hoặc nhận gần nhất. Nếu người dùng chưa có tem nào, hiển thị gợi ý tạo tem đầu tiên.
- **BR-03 — Gợi ý hành động:** Hệ thống hiển thị tối đa một gợi ý hành động phù hợp với trạng thái người dùng (ví dụ: "Bạn chưa gửi thư nào — thử gửi thư đầu tiên", hoặc "Bạn có thư chưa đọc").
- **BR-04 — Thanh điều hướng:** Thanh điều hướng phía dưới luôn hiển thị bốn mục: Tạo tem · Thư · Album · Hồ sơ.
- **BR-05 — Điểm vào tạo tem:** Nhấn "Tạo tem" trên thanh điều hướng mở luồng tạo tem (SM-005).

### Trạng thái offline

- **BR-06 — Hiển thị dữ liệu đã tải khi mất mạng:** Khi người dùng mất kết nối, màn hình chính vẫn hiển thị đầy đủ nội dung đã tải trước đó (số thư chưa đọc, tem gần nhất, gợi ý hành động, thanh điều hướng). Người dùng không thấy màn hình trắng hoặc lỗi toàn trang.
- **BR-07 — Thông báo trạng thái ngoại tuyến:** Khi đang ngoại tuyến, hệ thống hiển thị thông báo "Đang xem ngoại tuyến" ở vị trí không che khuất nội dung chính. Các hành động cần kết nối mạng (làm mới dữ liệu, điều hướng sang màn hình yêu cầu tải mới) bị vô hiệu hóa cho đến khi có mạng trở lại.

## 4. Tiêu chí nghiệm thu

- **AC-01 — Hiển thị số thư chưa đọc:**
  - **Giả sử** người dùng có hai thư chưa đọc;
  - **Khi** mở màn hình chính;
  - **Thì** số "2" hiển thị tại vị trí thông báo thư.

- **AC-02 — Hiển thị tem gần nhất:**
  - **Giả sử** người dùng đã có ít nhất một tem trong album;
  - **Khi** mở màn hình chính;
  - **Thì** tem được tạo/nhận gần nhất hiển thị trên màn hình chính.

- **AC-03 — Gợi ý tạo tem đầu tiên khi chưa có tem:**
  - **Giả sử** người dùng mới đăng ký, chưa có tem nào;
  - **Khi** mở màn hình chính;
  - **Thì** khu vực tem hiển thị lời mời tạo tem đầu tiên thay vì ảnh tem.

- **AC-04 — Điều hướng qua thanh dưới:**
  - **Giả sử** người dùng đang ở màn hình chính;
  - **Khi** nhấn từng mục trên thanh điều hướng (Tạo tem / Thư / Album / Hồ sơ);
  - **Thì** màn hình tương ứng mở ra.

### Offline

- **AC-05 — Hiển thị nội dung đã tải khi mất mạng:**
  - **Giả sử** người dùng đã mở màn hình chính khi có mạng, sau đó mất kết nối;
  - **Khi** xem lại màn hình chính trong trạng thái ngoại tuyến;
  - **Thì** số thư chưa đọc và tem gần nhất vẫn hiển thị đúng như lần tải gần nhất, và thông báo "Đang xem ngoại tuyến" xuất hiện mà không che khuất nội dung chính.

- **AC-06 — Vô hiệu hóa làm mới dữ liệu khi mất mạng:**
  - **Giả sử** người dùng đang ngoại tuyến và đang xem màn hình chính;
  - **Khi** người dùng thực hiện thao tác làm mới dữ liệu (kéo để tải lại);
  - **Thì** dữ liệu không thay đổi, thông báo "Đang xem ngoại tuyến" vẫn hiển thị, và không có lỗi toàn trang xuất hiện.

## 5. Trường hợp ngoại lệ & lỗi

- Khi mất kết nối: màn hình chính vẫn hiển thị với dữ liệu đã lưu trước đó (số thư, tem gần nhất); thông báo đang ngoại tuyến ở vị trí không che khuất nội dung chính.
- Khi mất kết nối: các thao tác cần mạng (làm mới feed, điều hướng sang màn hình yêu cầu tải mới) bị vô hiệu hoá cho đến khi có kết nối trở lại; dữ liệu đang xem không bị mất.
- Khi dữ liệu không tải được (lỗi mạng hoặc lỗi máy chủ): khu vực feed và gợi ý hiển thị trạng thái lỗi (ví dụ: biểu tượng lỗi kèm dòng chữ "Không thể tải dữ liệu") cùng nút "Thử lại" để người dùng tải lại mà không cần khởi động lại ứng dụng.
- Khi dữ liệu không tải được lần đầu (chưa có cache): màn hình hiển thị skeleton loading trong lúc chờ, sau đó chuyển sang trạng thái lỗi nếu vẫn không có dữ liệu.
- Khi chưa đăng nhập (phiên hết hạn): tự động chuyển sang màn hình đăng nhập.
- Khi thoát app giữa chừng: dữ liệu đã hiển thị (số thư, tem gần nhất) được giữ trong cache; lần mở lại, màn hình chính hiển thị ngay dữ liệu cache trong khi chờ tải mới từ máy chủ.

---

## Liên kết tính năng khác

- SM-005 (Chụp/Chọn ảnh): điểm đến khi nhấn "Tạo tem".
- SM-018 (Hộp thư đến): điểm đến khi nhấn "Thư".
- SM-022 (Album sưu tập tem): điểm đến khi nhấn "Album".
- SM-024 (Hồ sơ người dùng): điểm đến khi nhấn "Hồ sơ".

# Mở thư & Animation (SM-019)

**Feature Branch**: `017-mo-thu-animation`
**Ngày tạo**: 2026-06-24
**Trạng thái**: Draft
**Ưu tiên**: 🔴 P0

> **Tài liệu thuần nghiệp vụ** cho Tester (QA), Business Analyst (BA), Product Owner (PO).
> **KHÔNG chứa chi tiết kỹ thuật**. Phần plan / vẽ giao diện / develop được làm RIÊNG ở bước sau.

---

## 1. Mục đích nghiệp vụ

Tạo ra "khoảnh khắc vui" (moment of delight) khi người nhận mở thư — phong bì mở ra từ từ như thư thật, giấy thư cuộn ra, tem sáng lên. Trải nghiệm này là yếu tố cảm xúc cốt lõi khiến người nhận muốn chia sẻ lại và người gửi muốn gửi thêm.

## 2. Đối tượng & phạm vi

- **Người dùng:** Người nhận khi mở thư (cả trên web lẫn trong app).
- **Khi nào dùng:** Ngay sau khi người nhận nhấn link thư hợp lệ (SM-017), hoặc khi nhấn vào thư trong hộp thư đến (SM-018).
- **Điều kiện tiên quyết:** Link thư hợp lệ, chưa hết hạn, chưa được mở. Hoặc: xem lại thư đã đọc từ hộp thư đến (animation có thể bỏ qua khi xem lại).
- **Phạm vi:** Trình tự animation phong bì mở thư và hiển thị nội dung thư đầy đủ. Không bao gồm trả lời thư (SM-020) hay lưu tem (thuộc SM-017/022).

## 3. Quy tắc nghiệp vụ

- **BR-01 — Trình tự animation:** Khi mở thư, người nhận trải qua trình tự sau (theo thứ tự): (1) Phong bì hiện ra và mở chậm, (2) Giấy thư cuộn ra từ phong bì, (3) Nội dung thư hiện dần, (4) Tem sáng lên nổi bật.
- **BR-02 — Âm thanh kèm animation:** Animation kèm theo âm thanh nhẹ phù hợp. Người dùng có thể tắt âm thanh từ cài đặt (SM-027).
- **BR-03 — Hành động sau animation:** Sau khi animation hoàn tất, người nhận thấy thư đầy đủ với ba lựa chọn: (1) Lưu tem vào Album (chỉ khả dụng khi đã đăng nhập), (2) Trả lời thư (chỉ khả dụng khi đã đăng nhập), (3) Tải StampMail (chỉ hiển thị với người chưa có app).
- **BR-04 — Xem lại thư không có animation:** Khi xem lại thư đã đọc từ hộp thư đến, không có animation — thư hiển thị ngay.
- **BR-05 — Đánh dấu đã đọc:** Khi người nhận xem thư lần đầu (qua link), thư được đánh dấu là đã đọc và người gửi nhận thông báo.
- **BR-06 — Kiếm Dấu khi thư được mở lần đầu:** Ngay khi thư được đánh dấu đã đọc lần đầu qua link (BR-05), người gửi nhận thêm **15📮** (SM-033 BR-09). Chỉ áp dụng cho lần mở đầu tiên qua link — không trao khi người dùng xem lại thư từ hộp thư đến (BR-04). Mỗi thư chỉ trao một lần, không có rủi ro lạm dụng.
- **BR-07 — Phóng to tem sau animation:** Sau khi animation kết thúc và nội dung thư hiển thị đầy đủ, người nhận có thể dùng cử chỉ chụm/banh ngón tay để phóng to tem trên thư. Chỉ để xem — không thay đổi nội dung thư.

### Trạng thái offline

- **BR-08 — Không thể mở thư khi mất mạng:** Nếu người nhận nhấn link thư hoặc mở thư từ hộp thư đến trong khi mất kết nối, ứng dụng hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." — không bắt đầu animation.
- **BR-09 — Thư đã tải vẫn đọc được khi mất mạng giữa chừng:** Nếu thư đã được tải đầy đủ về máy trước khi mất mạng, người nhận vẫn đọc được nội dung thư; ứng dụng hiển thị thông báo "Đang xem ngoại tuyến". Các hành động cần mạng (lưu tem, trả lời thư) bị vô hiệu hóa cho đến khi có kết nối trở lại.
- **BR-10 — Thông báo đã đọc và Dấu ghi nhận khi có mạng:** Nếu việc đánh dấu đã đọc (BR-05) và trao Dấu (BR-06) chưa ghi nhận được do mất mạng, hệ thống tự động hoàn thành hai thao tác này ngay khi kết nối được khôi phục — không yêu cầu người nhận mở thư lại.

## 4. Tiêu chí nghiệm thu

- **AC-01 — Trình tự animation đúng thứ tự:**
  - **Giả sử** người nhận vừa mở link thư hợp lệ;
  - **Khi** trang/màn hình tải xong;
  - **Thì** animation diễn ra theo đúng thứ tự: phong bì mở → giấy cuộn ra → nội dung hiện → tem sáng lên.

- **AC-02 — Tắt âm thanh hoạt động:**
  - **Giả sử** người dùng đã tắt âm thanh animation trong cài đặt;
  - **Khi** mở một thư mới;
  - **Thì** animation diễn ra bình thường nhưng không có tiếng.

- **AC-03 — Nút lưu tem sau animation:**
  - **Giả sử** người nhận đã đăng nhập và animation kết thúc;
  - **Khi** nhìn vào màn hình sau animation;
  - **Thì** thấy nút "Lưu tem vào Album" và "Trả lời".

- **AC-04 — Xem lại không có animation:**
  - **Giả sử** người dùng đã đọc thư này trước đó;
  - **Khi** mở lại thư từ hộp thư đến;
  - **Thì** thư hiển thị ngay nội dung đầy đủ, không lặp lại animation.

- **AC-05 — Người gửi nhận thông báo đã đọc:**
  - **Giả sử** người nhận vừa mở link và hoàn thành animation;
  - **Khi** animation kết thúc và thư được đánh dấu đã đọc;
  - **Thì** người gửi nhận thông báo trong app.

- **AC-06 — Người gửi nhận Dấu khi thư được mở:**
  - **Giả sử** người nhận vừa hoàn thành xem animation và thư được đánh dấu đã đọc;
  - **Khi** trạng thái đã đọc được ghi nhận;
  - **Thì** người gửi nhận thêm 15📮 và thông báo push (nếu đã bật SM-026) "Thư của bạn đã được mở — bạn nhận 15📮!".

- **AC-07 — Phóng to tem trên thư:**
  - **Giả sử** người nhận đang xem nội dung thư sau khi animation kết thúc;
  - **Khi** banh ngón tay lên tem đính trên thư;
  - **Thì** tem phóng to theo ngón tay; chụm ngón tay thu về kích thước ban đầu.

### Offline

- **AC-08 — Chặn mở thư khi mất mạng:**
  - **Giả sử** thiết bị của người nhận đang không có kết nối mạng;
  - **Khi** người nhận nhấn link thư hoặc mở thư từ hộp thư đến;
  - **Thì** ứng dụng không bắt đầu animation và hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."

- **AC-09 — Xem thư đã tải khi mất mạng giữa chừng:**
  - **Giả sử** thư đã tải xong và đang hiển thị nội dung đầy đủ, sau đó thiết bị mất kết nối;
  - **Khi** người nhận tiếp tục đọc thư;
  - **Thì** nội dung thư vẫn hiển thị bình thường với thông báo "Đang xem ngoại tuyến"; các nút "Lưu tem" và "Trả lời" bị vô hiệu hóa.

## 5. Trường hợp ngoại lệ & lỗi

**Nhóm 1 — Khi mất kết nối (offline / không có mạng):**
- Nếu thư chưa được tải về máy và mất mạng khi nhấn link: animation không bắt đầu, hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." — thư không mở được.
- Nếu thư đã tải đầy đủ về máy trước khi mất mạng: người nhận vẫn xem được nội dung thư với thông báo "Đang xem ngoại tuyến"; các nút "Lưu tem" và "Trả lời" bị vô hiệu hóa cho đến khi có mạng trở lại.
- Khi mất kết nối giữa chừng animation (thư chưa tải xong): animation dừng lại, hiển thị thông báo lỗi mạng và nút thử lại.
- Khi thiết bị yếu, animation giật lag: animation vẫn phải chạy đến cuối dù có độ trễ; không được bỏ qua tự động.

**Nhóm 2 — Khi dữ liệu không tải được (lỗi mạng / lỗi máy chủ):**
- Nếu thư không tải được do lỗi máy chủ hoặc link hết hạn: màn hình hiển thị thông báo lỗi rõ ràng (ví dụ: "Không tìm thấy thư" hoặc "Link đã hết hạn") cùng nút "Thử lại"; không hiển thị màn hình trắng trống.
- Nếu lỗi chỉ xảy ra khi tải tài nguyên animation (hình ảnh, âm thanh) nhưng nội dung thư đã có: thư hiển thị nội dung văn bản ngay, phần animation bị lược bỏ và người nhận thấy thông báo ngắn gọn.

**Nhóm 3 — Khi chưa đăng nhập / thoát app giữa chừng:**
- Người nhận chưa đăng nhập mở thư qua link: animation vẫn phát bình thường ở chế độ khách; sau animation, các lựa chọn "Lưu tem" và "Trả lời" được hiển thị nhưng khi nhấn vào thì yêu cầu đăng nhập hoặc tải app.
- Khi người nhận nhấn ra khỏi màn hình animation giữa chừng: thư được đánh dấu là đã mở (link hết hiệu lực), người nhận có thể xem lại thư từ hộp thư đến.
- Khi người nhận thoát app sau khi animation đã kết thúc và thư đã đánh dấu đã đọc: lần vào lại thư từ hộp thư đến không có animation, nội dung thư hiển thị ngay.

---

## Liên kết tính năng khác

- SM-017 (Nhận thư qua Link): kích hoạt animation khi mở link lần đầu.
- SM-018 (Hộp thư đến): xem lại thư đã đọc từ đây (không có animation).
- SM-020 (Trả lời thư): hành động khả dụng sau khi đọc thư.
- SM-022 (Album sưu tập tem): lưu tem sau khi đọc thư.
- SM-027 (Cài đặt): bật/tắt âm thanh animation.
- SM-033 (Hệ thống Dấu): quy tắc thưởng 15📮 khi thư được mở.

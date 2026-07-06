# Trang trí tem (SM-008)

**Feature Branch**: `007-trang-tri-tem`
**Ngày tạo**: 2026-06-24
**Trạng thái**: Draft
**Ưu tiên**: 🔴 P0

> **Tài liệu thuần nghiệp vụ** cho Tester (QA), Business Analyst (BA), Product Owner (PO).
> **KHÔNG chứa chi tiết kỹ thuật**. Phần plan / vẽ giao diện / develop được làm RIÊNG ở bước sau.

---

## 1. Mục đích nghiệp vụ

Cho phép người dùng thêm cá tính vào tem bằng sticker, chữ, biểu tượng và hoa văn nền — làm cho mỗi tem trở nên độc đáo và mang dấu ấn riêng của người gửi.

## 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đang trong luồng tạo tem, sau bước xoá nền.
- **Khi nào dùng:** Bước 3 của luồng tạo tem, sau SM-006.
- **Điều kiện tiên quyết:** Đã qua bước bộ lọc màu (SM-006).
- **Phạm vi:** Thêm và chỉnh vị trí sticker, chữ, biểu tượng, hoa văn nền. Không bao gồm viền tem (SM-009).

## 3. Quy tắc nghiệp vụ

- **BR-01 — Bộ sticker theo chủ đề:** Người dùng có thể thêm sticker từ các bộ theo chủ đề: mùa (xuân, hạ, thu, đông), cảm xúc (vui, yêu, nhớ…), thiên nhiên (hoa, lá, bầu trời…).
- **BR-02 — Sticker Free vs Khóa:** Bộ sticker cơ bản gồm năm mươi sticker khả dụng cho tất cả người dùng gói Thường. Bộ sticker đặc biệt bị khóa mặc định — người dùng gói Thường thấy được nhưng không dùng được cho đến khi mở khóa theo một trong hai cách: nâng cấp Premium (mở toàn bộ) hoặc dùng Dấu (mở từng bộ riêng lẻ, xem BR-07 và SM-033).
- **BR-03 — Chữ tuỳ chỉnh:** Người dùng có thể thêm dòng chữ, chọn font (ít nhất hai lựa chọn: tay viết và in ấn), chỉnh kích thước và màu chữ.
- **BR-04 — Biểu tượng và hoa văn nền:** Người dùng có thể thêm biểu tượng nhỏ (icon) và áp hoa văn nhẹ làm nền cho tem.
- **BR-05 — Thao tác trên phần tử trang trí:** Mọi thành phần đã thêm (sticker, chữ, biểu tượng) đều có thể thao tác trực tiếp trên vùng tem bằng các cử chỉ sau:
  - **Chọn:** Chạm một lần vào phần tử → phần tử được chọn, hiển thị khung điều khiển xung quanh. Chạm ra ngoài → bỏ chọn.
  - **Di chuyển:** Giữ và kéo ngón tay trên phần tử đang chọn → phần tử di chuyển theo ngón tay đến bất kỳ vị trí nào trong vùng tem.
  - **Phóng to:** Banh hai ngón tay trên phần tử → phần tử to ra theo tỉ lệ.
  - **Thu nhỏ:** Chụm hai ngón tay trên phần tử → phần tử nhỏ lại theo tỉ lệ.
  - **Xoay:** Xoay hai ngón tay theo chiều kim đồng hồ hoặc ngược lại → phần tử xoay theo góc tương ứng.
- **BR-10 — Giới hạn kích thước phần tử:** Mỗi phần tử có kích thước tối thiểu (đủ nhìn thấy, không nhỏ hơn một phần mười chiều rộng vùng tem) và tối đa (không lớn hơn toàn bộ vùng tem). Khi đạt giới hạn, hệ thống dừng thay đổi kích thước — không báo lỗi, không làm phần tử biến mất.
- **BR-06 — Bỏ qua trang trí:** Người dùng có thể không thêm gì và chuyển thẳng sang bước viền tem (SM-009).
- **BR-07 — Mở sticker đặc biệt bằng Dấu:** Người dùng gói Thường dùng **50📮** (SM-033 BR-11) để mở vĩnh viễn một bộ sticker đặc biệt cụ thể. Mỗi lần chỉ mở một bộ; sau khi mở, bộ đó luôn khả dụng cho tài khoản này.

### Trạng thái offline

- **BR-08 — Trang trí cục bộ không cần mạng:** Khi mất kết nối mạng, người dùng vẫn thực hiện được toàn bộ thao tác trang trí (thêm sticker đã tải sẵn, thêm chữ, kéo thả, thay đổi kích thước, xoay) vì các thao tác này chỉ diễn ra trên thiết bị.
- **BR-09 — Tải sticker đặc biệt cần mạng:** Khi mất kết nối, nếu người dùng chọn một bộ sticker đặc biệt chưa được tải về thiết bị, hệ thống thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." và không tải bộ sticker đó; các sticker đã tải sẵn trước đó vẫn dùng được bình thường.

## 4. Tiêu chí nghiệm thu

- **AC-01 — Thêm sticker Free:**
  - **Giả sử** người dùng gói Thường đang ở bước trang trí;
  - **Khi** chọn một sticker từ bộ cơ bản và đặt lên tem;
  - **Thì** sticker xuất hiện trên vùng xem trước tem và có thể kéo đến vị trí mong muốn.

- **AC-02 — Sticker đặc biệt bị khóa — hiện hai lựa chọn:**
  - **Giả sử** người dùng gói Thường;
  - **Khi** nhấn vào một sticker đặc biệt bị khóa;
  - **Thì** hệ thống hiển thị hai lựa chọn: "Dùng 50📮 để mở bộ này" và "Nâng cấp Premium để mở tất cả"; không đặt sticker lên tem cho đến khi chọn một trong hai.

- **AC-03 — Thêm chữ và chọn font:**
  - **Giả sử** người dùng đang ở bước trang trí;
  - **Khi** chọn thêm chữ, nhập nội dung và chọn font;
  - **Thì** chữ hiển thị trên tem với font đã chọn và có thể kéo đến vị trí mong muốn.

- **AC-04 — Chọn và di chuyển phần tử:**
  - **Giả sử** đã có ít nhất một sticker trên tem;
  - **Khi** người dùng chạm vào sticker rồi kéo đến góc khác của tem;
  - **Thì** sticker di chuyển theo đúng hướng ngón tay và dừng tại vị trí thả; các phần tử khác không bị ảnh hưởng.

- **AC-05 — Phóng to sticker bằng banh ngón tay:**
  - **Giả sử** đã có một sticker trên tem và đang được chọn;
  - **Khi** người dùng đặt hai ngón tay lên sticker và banh ra;
  - **Thì** sticker to ra tỉ lệ theo độ banh; dừng banh thì kích thước giữ nguyên ở mức đó.

- **AC-09 — Thu nhỏ sticker bằng chụm ngón tay:**
  - **Giả sử** đã có một sticker kích thước lớn trên tem;
  - **Khi** người dùng đặt hai ngón tay lên sticker và chụm vào;
  - **Thì** sticker nhỏ lại theo độ chụm; không nhỏ hơn kích thước tối thiểu (vẫn nhìn thấy được).

- **AC-10 — Xoay phần tử:**
  - **Giả sử** đã có một sticker trên tem;
  - **Khi** người dùng đặt hai ngón tay lên sticker và xoay theo chiều kim đồng hồ;
  - **Thì** sticker xoay theo đúng hướng; thả tay thì sticker giữ nguyên góc xoay đó.

- **AC-11 — Kích thước tối đa không vượt vùng tem:**
  - **Giả sử** người dùng đang banh một sticker cho đến khi lấp đầy toàn bộ vùng tem;
  - **Khi** tiếp tục banh ngón tay;
  - **Thì** sticker không lớn thêm nữa — kích thước dừng lại ở mức vừa vùng tem.

- **AC-06 — Mở sticker đặc biệt bằng Dấu:**
  - **Giả sử** người dùng gói Thường có ≥ 50📮 và nhấn vào bộ sticker đặc biệt bị khóa;
  - **Khi** chọn "Dùng 50📮 để mở bộ này" và xác nhận;
  - **Thì** bộ sticker mở vĩnh viễn, số Dấu giảm 50📮, người dùng dùng được sticker đó ngay.

### Offline

- **AC-07 — Trang trí vẫn hoạt động khi mất mạng:**
  - **Giả sử** người dùng đang ở bước trang trí và thiết bị mất kết nối mạng;
  - **Khi** người dùng thêm sticker đã tải sẵn, nhập chữ, kéo thả và xoay các phần tử trên tem;
  - **Thì** tất cả thao tác vẫn thực hiện được bình thường, không có thông báo lỗi nào xuất hiện.

- **AC-08 — Báo lỗi khi tải bộ sticker chưa có trên thiết bị lúc mất mạng:**
  - **Giả sử** người dùng đang ở bước trang trí và thiết bị mất kết nối mạng;
  - **Khi** người dùng chọn một bộ sticker đặc biệt chưa được tải về thiết bị;
  - **Thì** hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng.", bộ sticker không được tải, các sticker đã có sẵn trên thiết bị vẫn dùng được.

## 5. Trường hợp ngoại lệ & lỗi

- Khi người dùng thêm quá nhiều phần tử và tem trở nên chật: không giới hạn số lượng phần tử trang trí; hệ thống không tự xoá bất kỳ thứ gì.
- Khi thoát app giữa bước trang trí: mất toàn bộ nội dung đang chỉnh, quay về màn hình chính khi mở lại.
- Khi muốn xoá một phần tử đã thêm: người dùng chọn phần tử rồi nhấn xoá; phần tử biến mất khỏi tem.

### Khi mất kết nối (offline)

- Toàn bộ thao tác trang trí với sticker và font đã tải sẵn vẫn hoạt động bình thường khi mất mạng — người dùng không thấy thông báo lỗi nào.
- Khi mất mạng mà người dùng chọn bộ sticker đặc biệt chưa tải về thiết bị, hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." và không tải bộ đó; các sticker đã có sẵn vẫn dùng được.
- Tính năng thêm và chỉnh chữ (nhập nội dung, chọn font, đổi màu, kéo thả) không cần mạng và vẫn hoạt động đầy đủ khi offline.

### Khi dữ liệu không tải được (lỗi mạng / lỗi máy chủ)

- Khi có mạng nhưng tải bộ sticker đặc biệt thất bại do lỗi máy chủ, hệ thống hiển thị thông báo lỗi kèm nút "Thử lại" để người dùng tải lại mà không cần thoát bước trang trí.
- Nếu tải lại vẫn thất bại, người dùng có thể tiếp tục trang trí bằng các sticker và font đã có sẵn trên thiết bị.

### Khi chưa đăng nhập / thoát app giữa chừng

- Người dùng chưa đăng nhập không thể truy cập bước trang trí tem; hệ thống chuyển về màn hình đăng nhập khi người dùng cố vào luồng tạo tem.
- Khi thoát app giữa bước trang trí (bao gồm cả trường hợp app bị đóng đột ngột), toàn bộ nội dung đang trang trí bị huỷ; lần sau vào lại app, người dùng phải bắt đầu lại từ đầu luồng tạo tem.

---

## Liên kết tính năng khác

- SM-009 (Viền & Khung tem): bước tiếp theo.
- SM-028 (Nâng cấp Premium): lựa chọn mở toàn bộ sticker đặc biệt cùng lúc.
- SM-033 (Hệ thống Dấu): lựa chọn mở từng bộ sticker riêng lẻ bằng 50📮.

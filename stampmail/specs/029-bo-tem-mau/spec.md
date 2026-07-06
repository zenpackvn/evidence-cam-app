# Bộ tem mẫu (SM-035)

**Feature Branch**: `029-bo-tem-mau`
**Ngày tạo**: 2026-06-25
**Trạng thái**: Draft
**Ưu tiên**: 🟡 P1

> **Tài liệu thuần nghiệp vụ** cho Tester (QA), Business Analyst (BA), Product Owner (PO).
> **KHÔNG chứa chi tiết kỹ thuật**. Phần plan / vẽ giao diện / develop được làm RIÊNG ở bước sau.

---

## 1. Mục đích nghiệp vụ

Cung cấp bộ sưu tập tem được thiết kế sẵn bởi StampMail — để người dùng tham khảo phong cách hoặc dùng ngay mà không cần tạo từ ảnh cá nhân. Hạ thấp rào cản gửi thư lần đầu (người mới không cần ảnh đẹp để bắt đầu); đồng thời tạo động lực chia sẻ app hoặc nạp Dấu để mở khóa các tem mẫu cao cấp hơn.

## 2. Đối tượng & phạm vi

- **Người dùng:** Mọi người dùng đã đăng nhập, bao gồm cả người mới chưa tạo tem lần nào.
- **Khi nào dùng:** Khi muốn tham khảo tem trước khi tạo, hoặc khi muốn dùng ngay một tem có sẵn để gửi thư mà không cần tự tạo.
- **Điều kiện tiên quyết:** Đã đăng nhập (SM-001).
- **Phạm vi:** Duyệt, xem chi tiết và lưu tem mẫu vào Album cá nhân. Không bao gồm chỉnh sửa tem mẫu hay tạo tem mới từ tem mẫu (đó là luồng SM-005→011).

## 3. Quy tắc nghiệp vụ

- **BR-01 — Nguồn tem mẫu:** Bộ tem mẫu do đội thiết kế StampMail biên soạn — không phải tem do người dùng tạo. Bộ tem mẫu là một album riêng, tách biệt hoàn toàn với Album cá nhân (SM-022). Tem mẫu luôn gắn nhãn "Tem mẫu" để phân biệt.
- **BR-02 — Phân loại theo chủ đề:** Trong album tem mẫu, tem được chia theo các chủ đề, ví dụ: Sinh nhật / Tết & Lễ hội / Tình yêu & Kỷ niệm / Bạn bè / Thiên nhiên & Phong cảnh / Động vật / Nghệ thuật & Họa tiết. Danh sách chủ đề có thể mở rộng theo thời gian.
- **BR-03 — Lưu tem mẫu vào Album cá nhân:** Sau khi mở khóa, người dùng lưu tem mẫu vào Album cá nhân để dùng khi gửi thư (SM-014). Mỗi tem mẫu chỉ cần lưu một lần — lưu lại không tạo bản sao.
- **BR-04 — Tem mẫu không thể chỉnh sửa:** Người dùng không thể thay đổi thiết kế của tem mẫu. Nếu muốn phong cách tương tự nhưng ảnh riêng, người dùng đi qua luồng tạo tem (SM-005→011).
- **BR-05 — Miễn phí một phần, phần còn lại cần Dấu:** Một số tem mẫu miễn phí cho tất cả người dùng (hiển thị ngay, lưu được không cần Dấu). Các tem mẫu còn lại bị khóa — mở bằng **Dấu** (SM-033): kiếm Dấu bằng cách chia sẻ tem/gửi thư, hoặc nạp Dấu bằng tiền thật. Giá mở khóa từng tem mẫu hiển thị rõ trên ảnh.
- **BR-06 — Cập nhật định kỳ:** StampMail bổ sung bộ tem mẫu mới theo mùa/dịp (Tết, Valentine, Giáng sinh, v.v.). Tem mới gắn nhãn "Mới" trong một khoảng thời gian sau khi ra mắt.
- **BR-07 — Xem trước trước khi mở khóa:** Người dùng xem tem mẫu ở kích thước lớn và phóng to kiểm tra chi tiết trước khi quyết định dùng Dấu mở khóa.

### Trạng thái offline

- **BR-08 — Xem tem đã tải khi mất mạng:** Khi mất kết nối, người dùng vẫn thấy và duyệt được các tem mẫu đã được hiển thị trước đó; ứng dụng hiển thị thông báo "Đang xem ngoại tuyến" ở đầu màn hình để người dùng biết nội dung có thể chưa được cập nhật mới nhất.
- **BR-09 — Chặn lưu và mở khóa khi mất mạng:** Khi mất kết nối, nút "Lưu vào Album" và nút "Mở khóa" bị vô hiệu hóa; khi người dùng nhấn vào, hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." — không trừ Dấu, không ghi dữ liệu.

## 4. Tiêu chí nghiệm thu

- **AC-01 — Duyệt tem mẫu theo chủ đề:**
  - **Giả sử** người dùng đang ở màn hình Bộ tem mẫu;
  - **Khi** chọn chủ đề "Sinh nhật";
  - **Thì** chỉ hiển thị các tem mẫu thuộc chủ đề Sinh nhật; tem của chủ đề khác bị ẩn.

- **AC-02 — Xem trước chi tiết tem mẫu:**
  - **Giả sử** người dùng đang duyệt danh sách tem mẫu;
  - **Khi** nhấn vào một tem mẫu;
  - **Thì** tem hiển thị ở kích thước lớn với nhãn "Tem mẫu", tên chủ đề, và nút "Lưu vào Album" (hoặc thông tin mở khóa nếu là Premium).

- **AC-03 — Phóng to kiểm tra chi tiết:**
  - **Giả sử** người dùng đang xem trước một tem mẫu;
  - **Khi** banh ngón tay lên tem;
  - **Thì** tem phóng to theo ngón tay để xem chi tiết; chụm ngón tay thu về kích thước ban đầu.

- **AC-04 — Lưu tem mẫu miễn phí vào Album:**
  - **Giả sử** người dùng đang xem tem mẫu miễn phí;
  - **Khi** nhấn "Lưu vào Album";
  - **Thì** tem xuất hiện trong Album cá nhân (SM-022) với nhãn "Tem mẫu"; hiển thị thông báo xác nhận "Đã lưu vào Album".

- **AC-05 — Lưu lại không tạo bản sao:**
  - **Giả sử** người dùng đã lưu một tem mẫu trước đó;
  - **Khi** nhấn "Lưu vào Album" lần thứ hai cho cùng tem đó;
  - **Thì** hệ thống thông báo "Tem này đã có trong Album của bạn" và không tạo bản sao.

- **AC-06 — Mở khóa tem mẫu bằng Dấu:**
  - **Giả sử** người dùng đang xem tem mẫu bị khóa và có đủ Dấu;
  - **Khi** nhấn "Mở khóa — X📮" và xác nhận;
  - **Thì** tem được mở khóa vĩnh viễn, số Dấu giảm tương ứng, nút đổi thành "Lưu vào Album".

- **AC-07 — Không đủ Dấu — gợi ý chia sẻ hoặc nạp:**
  - **Giả sử** người dùng muốn mở tem mẫu nhưng không đủ Dấu;
  - **Khi** nhấn "Mở khóa";
  - **Thì** hiển thị số Dấu còn thiếu và hai lựa chọn: "Chia sẻ tem để kiếm Dấu" hoặc "Nạp Dấu"; không mở khóa cho đến khi đủ Dấu.

- **AC-08 — Tem mẫu đã lưu dùng được trong thư:**
  - **Giả sử** người dùng đã lưu một tem mẫu vào Album;
  - **Khi** soạn thư mới và vào bước đính tem (SM-014);
  - **Thì** tem mẫu đó xuất hiện trong tab "Tất cả" của Album, có thể chọn và đính lên thư như tem thường.

- **AC-09 — Tem mới được đánh dấu:**
  - **Giả sử** StampMail vừa bổ sung bộ tem Tết mới;
  - **Khi** người dùng mở Bộ tem mẫu;
  - **Thì** các tem mới có nhãn "Mới" hiển thị rõ ràng trên ảnh tem.

### Offline

- **AC-10 — Duyệt tem đã tải khi mất mạng:**
  - **Giả sử** người dùng đã mở Bộ tem mẫu trước đó và sau đó mất kết nối mạng;
  - **Khi** người dùng mở lại màn hình Bộ tem mẫu;
  - **Thì** các tem đã tải trước đó vẫn hiển thị được; thông báo "Đang xem ngoại tuyến" xuất hiện ở đầu màn hình.

- **AC-11 — Lưu và mở khóa bị chặn khi mất mạng:**
  - **Giả sử** người dùng đang xem một tem mẫu và thiết bị không có kết nối mạng;
  - **Khi** người dùng nhấn "Lưu vào Album" hoặc "Mở khóa";
  - **Thì** hành động không được thực hiện; hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."; số Dấu không thay đổi.

## 5. Trường hợp ngoại lệ & lỗi

**Khi mất kết nối (offline):**
- Người dùng vẫn duyệt và xem được các tem đã hiển thị trước đó (từ bộ nhớ đệm); thông báo "Đang xem ngoại tuyến" xuất hiện ở đầu màn hình để người dùng biết nội dung có thể chưa cập nhật.
- Nút "Lưu vào Album" và nút "Mở khóa" bị vô hiệu hoá; khi nhấn vào, hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." — không trừ Dấu, không ghi dữ liệu.
- Các tem chưa từng tải về không hiển thị được khi mất mạng; vị trí đó hiển thị ảnh giữ chỗ (placeholder) thay vì để trống.

**Khi dữ liệu không tải được (lỗi mạng / lỗi máy chủ):**
- Nếu toàn bộ bộ tem không tải được, màn hình hiển thị biểu tượng lỗi kèm thông báo "Không thể tải bộ tem. Vui lòng thử lại." và nút "Thử lại" để người dùng tải lại.
- Nếu chỉ một chủ đề không tải được, danh sách hiển thị skeleton (khung giữ chỗ) trong thời gian tải; sau thời gian chờ, khu vực đó hiển thị thông báo lỗi và nút "Thử lại" ngay tại chỗ.
- Khi chủ đề chưa có tem nào (chủ đề mới chưa có nội dung): hiển thị trạng thái "Sắp ra mắt" thay vì danh sách trống.

**Khi chưa đăng nhập / thoát app giữa chừng:**
- Người dùng chưa đăng nhập vẫn xem và duyệt được bộ tem mẫu đã tải; nhưng khi nhấn "Lưu vào Album" hoặc "Mở khóa", hệ thống chuyển hướng sang màn hình đăng nhập (SM-001) và giữ nguyên tem đang xem để người dùng quay lại sau khi đăng nhập.
- Khi người dùng nhấn mở khóa nhưng không đủ Dấu: không trừ Dấu, không mở khóa; hiển thị gợi ý kiếm thêm hoặc nạp Dấu.
- Nếu người dùng thoát app khi đang xem tem mẫu, không có dữ liệu nào bị mất; lần sau mở lại, màn hình Bộ tem mẫu trở về trạng thái mặc định (danh sách chủ đề) thay vì khôi phục tem đang xem dở.

---

## Liên kết tính năng khác

- SM-022 (Album sưu tập tem): nơi lưu tem mẫu sau khi mở khóa; tem mẫu xuất hiện trong Album với nhãn phân biệt.
- SM-014 (Đính tem lên thư): tem mẫu đã lưu dùng được trong bước đính tem.
- SM-033 (Hệ thống Dấu): cơ chế mở khóa — dùng Dấu kiếm từ chia sẻ/gửi thư hoặc nạp bằng tiền thật.
- SM-034 (Tem giới hạn): khác với bộ tem mẫu — tem giới hạn gắn với sự kiện có thời hạn.

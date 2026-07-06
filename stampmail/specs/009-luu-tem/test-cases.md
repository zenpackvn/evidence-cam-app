# Test Cases — Xem trước & Lưu tem (009-luu-tem)

---

## TC-09-001: Tem hiển thị đúng kích thước thật trên màn hình xem trước

**AC liên quan:** AC-01
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản bất kỳ
- Hoàn tất bước viền & khung tem (SM-009), đang ở bước cuối của luồng tạo tem

### Act (Thực hiện)
- Chuyển sang màn hình xem trước (SM-010)

### Assert (Kiểm tra)
- Tem hiển thị ở kích thước thật (không bị thu nhỏ hay cắt xén)
- Ảnh đã chỉnh sửa hiển thị đầy đủ
- Sticker, chữ trang trí đã thêm hiển thị đúng vị trí
- Viền đã chọn bao quanh tem đúng như thiết kế

---

## TC-09-002: Đổi màu nền xem trước tem

**AC liên quan:** AC-02, BR-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đang ở màn hình xem trước tem
- Màu nền mặc định đang hiển thị (ví dụ: trắng)

### Act (Thực hiện)
- Chọn màu nền thứ hai (ví dụ: đen)
- Chọn màu nền thứ ba (ví dụ: xám nhạt)
- Chọn lại màu nền đầu tiên (trắng)

### Assert (Kiểm tra)
- Màu nền thay đổi ngay lập tức sau mỗi lần chọn, không có độ trễ đáng kể
- Tem không thay đổi về nội dung, sticker, viền hay bất kỳ thành phần nào
- Có ít nhất ba tùy chọn màu nền: trắng, đen, xám nhạt

---

## TC-09-003: Quay lại bước Bộ lọc màu từ màn hình xem trước

**AC liên quan:** AC-03, BR-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đang ở màn hình xem trước tem
- Tem được tạo có áp dụng bộ lọc màu, sticker trang trí, và viền

### Act (Thực hiện)
- Nhấn "Chỉnh sửa lại"
- Chọn quay về bước Bộ lọc màu

### Assert (Kiểm tra)
- Màn hình bộ lọc màu mở ra
- Ảnh gốc và bộ lọc đang áp dụng vẫn được giữ nguyên
- Các thay đổi ở bước trang trí và viền không bị mất

---

## TC-09-004: Phóng to kiểm tra chi tiết tem bằng cử chỉ banh ngón tay

**AC liên quan:** AC-04, BR-05
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đang ở màn hình xem trước tem ở kích thước thật

### Act (Thực hiện)
- Đặt hai ngón tay lên tem và banh ra để phóng to
- Quan sát vùng chi tiết của tem (viền, sticker, chữ)
- Chụm ngón tay để thu nhỏ về kích thước thật

### Assert (Kiểm tra)
- Tem phóng to mượt mà theo cử chỉ ngón tay
- Chi tiết viền, sticker, chữ và chất lượng ảnh có thể kiểm tra rõ ràng khi phóng to
- Chụm ngón tay thu tem về kích thước thật
- Nút "Lưu tem" và "Chỉnh sửa lại" vẫn hiển thị trong suốt quá trình phóng to/thu nhỏ
- Tem thật không bị thay đổi sau thao tác phóng to/thu nhỏ

---

## TC-09-005: Lưu tem thành công với tài khoản Free còn hạn mức

**AC liên quan:** AC-05, BR-06
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản gói Thường (Free)
- Tài khoản đã lưu ít hơn 30 tem trong tháng hiện tại (ví dụ: 15 tem)
- Đang ở màn hình xem trước tem

### Act (Thực hiện)
- Nhấn nút "Lưu tem"

### Assert (Kiểm tra)
- Tem được lưu vào Album thành công
- Thông báo lưu thành công hiển thị trên màn hình
- Hai gợi ý hành động tiếp theo xuất hiện: "Gắn lên thư" và "Chia sẻ & nhận 10📮"

---

## TC-09-006: Từ chối lưu khi tài khoản Free đã đạt giới hạn 30 tem/tháng

**AC liên quan:** AC-06, BR-06
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản gói Thường (Free)
- Tài khoản đã lưu đúng 30 tem trong tháng hiện tại (đạt giới hạn)
- Đang ở màn hình xem trước tem

### Act (Thực hiện)
- Nhấn nút "Lưu tem"

### Assert (Kiểm tra)
- Hệ thống không lưu tem
- Thông báo hiển thị nội dung đã đạt giới hạn tháng
- Có gợi ý "Nâng cấp Premium"
- Có thông tin chờ đến đầu tháng mới

---

## TC-09-007: Tài khoản Premium lưu tem không bị giới hạn

**AC liên quan:** AC-07, BR-07
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản gói Premium
- Tài khoản đã lưu hơn 30 tem trong tháng hiện tại (vượt ngưỡng giới hạn Free)
- Đang ở màn hình xem trước tem

### Act (Thực hiện)
- Nhấn nút "Lưu tem"

### Assert (Kiểm tra)
- Tem được lưu thành công vào Album
- Không xuất hiện thông báo giới hạn tháng
- Thông báo lưu thành công hiển thị

---

## TC-09-008: Nhấn gợi ý "Gắn lên thư" sau khi lưu tem

**AC liên quan:** AC-08, BR-09
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Vừa lưu tem thành công
- Màn hình đang hiển thị thông báo lưu thành công và hai gợi ý hành động

### Act (Thực hiện)
- Nhấn vào gợi ý "Gắn lên thư"

### Assert (Kiểm tra)
- Luồng soạn thư (SM-014) được mở
- Tem vừa lưu đã được chọn sẵn trong luồng soạn thư, không cần chọn lại

---

## TC-09-009: Ngày tạo hiển thị đúng trong Album sau khi lưu

**AC liên quan:** AC-09, BR-08
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Ghi nhận ngày hiện tại (ví dụ: 26/06/2026)
- Đăng nhập tài khoản bất kỳ
- Vừa lưu tem thành công

### Act (Thực hiện)
- Mở Album sưu tập tem (SM-022)
- Tìm và nhấn vào tem vừa lưu để xem chi tiết

### Assert (Kiểm tra)
- Ngày tạo tem hiển thị đúng bằng ngày lưu (ví dụ: 26/06/2026)
- Không có bước nào trong luồng yêu cầu người dùng nhập ngày tạo

---

## TC-09-010: Chia sẻ tem và nhận Dấu khi còn trong giới hạn tuần

**AC liên quan:** AC-10, BR-10, BR-11
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản bất kỳ
- Tài khoản chưa chia sẻ đủ 3 lần trong tuần này (ví dụ: mới chia sẻ 1 lần)
- Ghi nhận số Dấu hiện tại trong tài khoản
- Vừa lưu tem thành công, đang thấy màn hình gợi ý hành động

### Act (Thực hiện)
- Nhấn nút "Chia sẻ & nhận 10📮"

### Assert (Kiểm tra)
- Native share sheet của hệ điều hành mở ra
- Ảnh tem trong share sheet có watermark StampMail ở góc
- Số Dấu trong tài khoản tăng thêm 10📮 ngay khi nhấn nút (không cần xác nhận đã đăng)
- Có thể tiếp tục chọn app chia sẻ hoặc hủy trong share sheet

---

## TC-09-011: Watermark StampMail bắt buộc trên ảnh chia sẻ

**AC liên quan:** AC-10, BR-11
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Vừa lưu tem thành công, đang thấy màn hình gợi ý hành động

### Act (Thực hiện)
- Nhấn nút "Chia sẻ & nhận 10📮"
- Quan sát ảnh tem trong native share sheet

### Assert (Kiểm tra)
- Ảnh tem trong share sheet có watermark StampMail rõ ràng ở góc
- Không có tùy chọn nào cho phép tắt hoặc xóa watermark
- Watermark không che khuất nội dung chính của tem

---

## TC-09-012: Chia sẻ lần thứ 4 trong tuần — không nhận Dấu nhưng share sheet vẫn mở

**AC liên quan:** AC-11, BR-12
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản đã chia sẻ đúng 3 lần trong tuần này (đạt giới hạn)
- Ghi nhận số Dấu hiện tại trong tài khoản
- Vừa lưu tem thành công, đang thấy màn hình gợi ý hành động

### Act (Thực hiện)
- Nhấn nút "Chia sẻ & nhận 10📮" (lần thứ 4)

### Assert (Kiểm tra)
- Native share sheet vẫn mở bình thường
- Số Dấu trong tài khoản không thay đổi (không trao thêm Dấu)
- Hiển thị thông báo "Đã đạt giới hạn chia sẻ tuần này"

---

## TC-09-013: Xem trước tem hoạt động đầy đủ khi mất mạng

**AC liên quan:** AC-12, BR-13
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đang ở màn hình xem trước tem với kết nối mạng bình thường
- Tắt kết nối mạng (bật chế độ máy bay hoặc ngắt Wi-Fi/dữ liệu di động)

### Act (Thực hiện)
- Đổi màu nền xem trước sang màu khác
- Banh ngón tay phóng to tem, sau đó chụm thu nhỏ
- Nhấn "Chỉnh sửa lại" để quay lại bước trước

### Assert (Kiểm tra)
- Đổi màu nền hoạt động bình thường, không có thông báo lỗi mạng
- Phóng to/thu nhỏ tem hoạt động mượt mà
- Nút "Chỉnh sửa lại" dẫn về bước trước bình thường
- Nội dung tem không bị mất hay thay đổi khi offline

---

## TC-09-014: Nút "Lưu tem" bị vô hiệu hóa khi mất mạng

**AC liên quan:** AC-13, BR-14
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đang ở màn hình xem trước tem
- Tắt kết nối mạng

### Act (Thực hiện)
- Nhấn nút "Lưu tem"

### Assert (Kiểm tra)
- Hệ thống không lưu tem
- Thông báo xuất hiện với nội dung "Không có kết nối. Vui lòng thử lại khi có mạng."
- Tem và toàn bộ nội dung vẫn còn hiển thị trên màn hình (không bị mất)
- Khi bật lại mạng và nhấn "Lưu tem" — tem được lưu thành công

---

## TC-09-015: Nút "Chia sẻ & nhận 10📮" bị vô hiệu hóa khi mất mạng

**AC liên quan:** AC-14, BR-15
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Lưu tem thành công khi còn mạng
- Màn hình gợi ý hành động sau lưu đang hiển thị
- Tắt kết nối mạng

### Act (Thực hiện)
- Quan sát nút "Chia sẻ & nhận 10📮"
- Cố nhấn vào nút chia sẻ

### Assert (Kiểm tra)
- Nút "Chia sẻ & nhận 10📮" ở trạng thái vô hiệu hóa (không phản hồi khi nhấn)
- Có thông báo yêu cầu kết nối mạng để chia sẻ
- Không có Dấu nào được trao

---

## TC-09-016: Chưa đăng nhập — bị chuyển đến màn hình đăng nhập khi nhấn "Lưu tem"

**AC liên quan:** Mục 5 — Chưa đăng nhập
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng chưa đăng nhập (khách / guest)
- Hoàn tất luồng tạo tem đến màn hình xem trước

### Act (Thực hiện)
- Nhấn nút "Lưu tem"

### Assert (Kiểm tra)
- Hệ thống không lưu tem ngay
- Chuyển hướng đến màn hình đăng nhập
- Sau khi đăng nhập thành công, hệ thống có thể tiếp tục luồng lưu (hoặc người dùng được hướng dẫn quay lại)

---

## TC-09-017: Lỗi server khi lưu tem — hiển thị nút "Thử lại"

**AC liên quan:** Mục 5 — Lỗi server
**Loại:** E2E
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản bất kỳ còn hạn mức
- Đang ở màn hình xem trước tem
- Server được giả lập trả về lỗi (500 hoặc lỗi tương đương)

### Act (Thực hiện)
- Nhấn nút "Lưu tem"

### Assert (Kiểm tra)
- Thông báo lỗi chung xuất hiện (không hiển thị thông tin kỹ thuật cho người dùng)
- Có nút "Thử lại" trong thông báo
- Tem chưa được lưu vào Album
- Dữ liệu tem vẫn giữ nguyên, người dùng có thể nhấn "Thử lại" để thực hiện lại

---

## TC-09-018: Hết dung lượng thiết bị khi lưu tem

**AC liên quan:** Mục 5 — Hết dung lượng
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản bất kỳ còn hạn mức
- Đảm bảo dung lượng trống trên thiết bị gần như bằng 0
- Đang ở màn hình xem trước tem

### Act (Thực hiện)
- Nhấn nút "Lưu tem"

### Assert (Kiểm tra)
- Thông báo lỗi liên quan đến bộ nhớ thiết bị xuất hiện
- Có hướng dẫn người dùng giải phóng dung lượng
- Tem không được lưu vào Album

---

## TC-09-019: Lưu tem thứ 30 (đúng bằng giới hạn) — vẫn thành công

**AC liên quan:** AC-05, AC-06, BR-06
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản gói Thường (Free)
- Tài khoản đã lưu đúng 29 tem trong tháng hiện tại
- Đang ở màn hình xem trước tem

### Act (Thực hiện)
- Nhấn nút "Lưu tem" (đây là tem thứ 30 trong tháng)

### Assert (Kiểm tra)
- Tem được lưu thành công (tem thứ 30 vẫn trong giới hạn)
- Thông báo lưu thành công hiển thị, không có thông báo giới hạn
- Hai gợi ý hành động tiếp theo xuất hiện

---

## TC-09-020: Thoát app tại màn hình xem trước — mất nội dung, quay về màn hình chính

**AC liên quan:** Mục 5 — Thoát app trước khi lưu
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đang ở màn hình xem trước tem, tem chưa được lưu

### Act (Thực hiện)
- Thoát khỏi ứng dụng (vuốt đóng app hoặc nhấn nút Home)
- Mở lại ứng dụng

### Assert (Kiểm tra)
- Ứng dụng mở lại về màn hình chính
- Nội dung tem đang làm bị mất (không có chức năng tự lưu nháp)
- Không có thông báo phục hồi phiên làm việc trước

---

## TC-09-021: Chia sẻ lần đầu trong tuần mới — được trao Dấu bình thường

**AC liên quan:** AC-10, BR-12
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản đã chia sẻ đủ 3 lần vào tuần trước (đặt lại vào thứ Hai)
- Đã sang tuần mới (thứ Hai đầu tuần)
- Ghi nhận số Dấu hiện tại
- Vừa lưu tem thành công

### Act (Thực hiện)
- Nhấn nút "Chia sẻ & nhận 10📮"

### Assert (Kiểm tra)
- Native share sheet mở ra bình thường
- Số Dấu tăng thêm 10📮 (giới hạn tuần đã được đặt lại)
- Không hiển thị thông báo "Đã đạt giới hạn chia sẻ tuần này"

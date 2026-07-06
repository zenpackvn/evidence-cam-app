# Checklist QA — Xem trước & Lưu tem (009-luu-tem)

## Điều kiện tiên quyết
- [ ] Tài khoản gói Thường (Free) đã đăng nhập và xác thực thành công
- [ ] Tài khoản gói Premium đã đăng nhập và xác thực thành công
- [ ] Đã hoàn tất bước viền & khung tem (SM-009), đang ở màn hình xem trước
- [ ] Dữ liệu test: tài khoản Free có 29 tem đã lưu trong tháng (một tem trước giới hạn)
- [ ] Dữ liệu test: tài khoản Free có đúng 30 tem đã lưu trong tháng (đạt giới hạn)
- [ ] Dữ liệu test: tài khoản đã chia sẻ 3 lần trong tuần này (đạt giới hạn tuần)
- [ ] Thiết bị có kết nối mạng ổn định

---

## Luồng chính (Happy Path)

### Xem trước tem
- [ ] Tem hiển thị ở kích thước thật khi chuyển sang màn hình xem trước ✅
- [ ] Ảnh, sticker, chữ trang trí và viền hiển thị đầy đủ, đúng vị trí ✅
- [ ] Có ít nhất ba tùy chọn màu nền: trắng, đen, xám nhạt ✅
- [ ] Chọn màu nền khác — màu nền thay đổi ngay, tem không thay đổi ✅
- [ ] Banh ngón tay phóng to tem — hiển thị chi tiết rõ hơn ✅
- [ ] Chụm ngón tay thu nhỏ — tem về kích thước thật ✅
- [ ] Nút "Lưu tem" và "Chỉnh sửa lại" vẫn hiển thị khi đang phóng to/thu nhỏ ✅
- [ ] Nhấn "Chỉnh sửa lại" — có thể chọn quay lại bất kỳ bước nào (bộ lọc, trang trí, viền) ✅
- [ ] Quay lại bước bộ lọc màu — ảnh và các thay đổi ở bước sau vẫn được giữ nguyên ✅

### Lưu tem vào Album
- [ ] Người dùng Free (còn dưới 30 tem/tháng) nhấn "Lưu tem" — lưu vào Album thành công ✅
- [ ] Sau khi lưu thành công, thông báo xác nhận lưu thành công xuất hiện ✅
- [ ] Sau khi lưu thành công, hai gợi ý hiển thị: "Gắn lên thư" và "Chia sẻ & nhận 10📮" ✅
- [ ] Hệ thống tự ghi ngày tạo đúng là ngày lưu, không yêu cầu người dùng nhập ✅
- [ ] Nhấn "Gắn lên thư" — mở luồng soạn thư với tem vừa lưu được chọn sẵn ✅
- [ ] Người dùng Premium lưu tem khi đã vượt 30 tem/tháng — vẫn lưu thành công ✅

### Chia sẻ tem & nhận Dấu
- [ ] Nhấn "Chia sẻ & nhận 10📮" (còn trong giới hạn tuần) — native share sheet mở ra ✅
- [ ] Ảnh tem trong share sheet có watermark StampMail ở góc 🔲
- [ ] Số Dấu tăng 10📮 ngay khi nhấn nút, không cần xác nhận đã đăng thật 🔲
- [ ] Không có tùy chọn tắt hay xóa watermark trên ảnh chia sẻ 🔲

---

## Luồng thất bại & Validation

- [ ] Người dùng Free đã lưu đủ 30 tem/tháng — không thể lưu thêm, hiển thị thông báo đạt giới hạn ✅
- [ ] Thông báo giới hạn tháng có gợi ý "Nâng cấp Premium" ✅
- [ ] Thông báo giới hạn tháng có thông tin chờ đến đầu tháng mới ✅
- [ ] Người dùng chưa đăng nhập nhấn "Lưu tem" — chuyển đến màn hình đăng nhập ✅
- [ ] Lỗi server khi lưu — thông báo lỗi chung + nút "Thử lại" xuất hiện, tem chưa được lưu 🚫
- [ ] Hết dung lượng thiết bị khi lưu — thông báo lỗi bộ nhớ + hướng dẫn giải phóng dung lượng 🔲
- [ ] Chia sẻ lần thứ 4 trong tuần — share sheet vẫn mở nhưng không trao Dấu 🔲
- [ ] Chia sẻ lần thứ 4 trong tuần — hiển thị thông báo "Đã đạt giới hạn chia sẻ tuần này" 🔲

---

## Trường hợp biên (Edge Cases)

- [ ] Người dùng Free lưu tem thứ 30 (đúng bằng giới hạn) — lưu thành công, không bị chặn ✅
- [ ] Người dùng Free lưu tem thứ 31 trong tháng — bị từ chối, hiển thị thông báo đúng ✅
- [ ] Mở Album sau khi lưu — tem vừa lưu xuất hiện trong danh sách ✅
- [ ] Xem chi tiết tem trong Album — ngày tạo hiển thị đúng là ngày lưu 🔲
- [ ] Chia sẻ lần đầu trong tuần mới (sau thứ Hai) — được trao Dấu bình thường 🔲
- [ ] Phóng to tem — tem thật không bị thay đổi sau thao tác phóng to/thu nhỏ ✅
- [ ] Thoát app tại màn hình xem trước — mở lại về màn hình chính, nội dung bị mất 🔲

---

## Trường hợp offline

- [ ] Mất mạng tại màn hình xem trước — đổi màu nền vẫn hoạt động bình thường 🔲
- [ ] Mất mạng tại màn hình xem trước — phóng to/thu nhỏ tem vẫn hoạt động bình thường 🔲
- [ ] Mất mạng tại màn hình xem trước — "Chỉnh sửa lại" vẫn dẫn về bước trước bình thường 🔲
- [ ] Mất mạng khi nhấn "Lưu tem" — thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." 🔲
- [ ] Mất mạng khi nhấn "Lưu tem" — tem và nội dung vẫn giữ nguyên trên màn hình 🔲
- [ ] Có mạng trở lại sau offline — nhấn "Lưu tem" thành công 🔲
- [ ] Mất mạng sau khi lưu xong — nút "Chia sẻ & nhận 10📮" bị vô hiệu hóa 🔲
- [ ] Mất mạng sau khi lưu xong — không có Dấu nào được trao khi nút chia sẻ bị vô hiệu hóa 🔲

---

## Ghi chú tự động hóa
- ✅ Maestro automatable — điều hướng màn hình, kiểm tra hiển thị nút, thông báo, luồng lưu
- 🔲 Manual only — thao tác mạng (offline/online), native share sheet, kiểm tra watermark, xác nhận số Dấu, kiểm tra lịch tuần
- 🚫 Not automatable — giả lập lỗi server trên môi trường thật

# Checklist QA — Trang trí tem (SM-008 / 007-trang-tri-tem)

## Điều kiện tiên quyết
- [ ] Có tài khoản người dùng gói Thường (Free) với ít nhất 50📮 trong ví Dấu
- [ ] Có tài khoản người dùng gói Thường (Free) với ít hơn 50📮 trong ví Dấu
- [ ] Có tài khoản người dùng gói Premium
- [ ] Đã hoàn thành bước xoá nền (SM-007) — ảnh tem đã được xử lý
- [ ] Ứng dụng đang ở bước "Trang trí tem" trong luồng tạo tem
- [ ] Đã xác định bộ sticker đặc biệt nào đã tải về thiết bị và bộ nào chưa tải

## Luồng chính (Happy Path)

- [ ] Màn hình trang trí tem hiển thị đúng vùng xem trước tem với ảnh đã xoá nền ✅
- [ ] Danh sách bộ sticker theo chủ đề (mùa, cảm xúc, thiên nhiên) hiển thị đầy đủ ✅
- [ ] Bộ sticker cơ bản có đúng 50 sticker khả dụng cho người dùng Free ✅
- [ ] Người dùng Free chọn sticker từ bộ cơ bản → sticker xuất hiện trên vùng xem trước tem ✅
- [ ] Sticker đặc biệt hiển thị trong danh sách kèm biểu tượng khoá cho người dùng Free ✅
- [ ] Nhấn vào sticker đặc biệt bị khoá (người dùng Free) → hiển thị đúng hai lựa chọn: "Dùng 50📮 để mở bộ này" và "Nâng cấp Premium để mở tất cả" ✅
- [ ] Người dùng Premium chọn sticker từ bộ đặc biệt → sticker xuất hiện ngay, không có biểu tượng khoá ✅
- [ ] Nhấn "Thêm chữ" → nhập nội dung → chữ xuất hiện trên vùng xem trước tem ✅
- [ ] Danh sách font có ít nhất hai lựa chọn: tay viết và in ấn ✅
- [ ] Chọn font tay viết → chữ hiển thị đúng font tay viết ✅
- [ ] Chọn font in ấn → chữ hiển thị đúng font in ấn ✅
- [ ] Chỉnh kích thước chữ (tăng/giảm) → chữ thay đổi kích thước tương ứng ✅
- [ ] Chỉnh màu chữ → chữ hiển thị đúng màu đã chọn ✅
- [ ] Thêm biểu tượng nhỏ (icon) → icon xuất hiện trên tem và có thể kéo thả ✅
- [ ] Áp hoa văn nhẹ làm nền → hoa văn xuất hiện ở nền tem, không che ảnh chính ✅
- [ ] Chạm một lần vào phần tử → khung điều khiển xuất hiện xung quanh; chạm ra ngoài → khung biến mất ✅
- [ ] Kéo phần tử (sticker/chữ/icon) đang được chọn → phần tử di chuyển theo ngón tay, dừng tại vị trí thả 🔲
- [ ] Kéo phần tử → các phần tử khác trên tem không bị ảnh hưởng 🔲
- [ ] Banh hai ngón tay trên phần tử → phần tử to ra theo tỉ lệ, tỉ lệ hình dạng giữ nguyên 🚫
- [ ] Chụm hai ngón tay trên phần tử → phần tử nhỏ lại, dừng ở kích thước tối thiểu khi đã đủ nhỏ 🚫
- [ ] Xoay hai ngón tay theo chiều kim đồng hồ → phần tử xoay đúng chiều, giữ nguyên góc khi thả tay 🚫
- [ ] Xoay hai ngón tay ngược chiều kim đồng hồ → phần tử xoay ngược lại đúng chiều 🚫
- [ ] Nút "Bỏ qua" / "Tiếp theo" mà không thêm bất kỳ trang trí nào → chuyển thẳng sang bước viền tem (SM-009) ✅

## Mở khoá sticker đặc biệt

- [ ] Người dùng Free có đủ 50📮 → chọn "Dùng 50📮 để mở bộ này" → bộ sticker mở vĩnh viễn, số Dấu giảm đúng 50📮 ✅
- [ ] Sau khi mở bằng Dấu → có thể dùng ngay sticker từ bộ vừa mở ✅
- [ ] Đăng xuất rồi đăng nhập lại → bộ sticker đã mở bằng Dấu vẫn khả dụng (vĩnh viễn) ✅
- [ ] Người dùng Free không đủ 50📮 → hệ thống thông báo không đủ Dấu, bộ sticker vẫn bị khoá ✅
- [ ] Chọn "Nâng cấp Premium" từ màn hình gợi ý → chuyển đến luồng nâng cấp Premium (SM-028) ✅

## Luồng thất bại & Validation

- [ ] Nhấn vào sticker đặc biệt bị khoá (người dùng Free) → không có sticker nào được đặt lên tem ✅
- [ ] Thêm chữ với nội dung rỗng → không cho phép lưu / chữ không xuất hiện trên tem ✅
- [ ] Chọn phần tử rồi nhấn Xoá → phần tử biến mất, các phần tử khác không bị ảnh hưởng ✅
- [ ] Thoát app giữa bước trang trí rồi mở lại → ứng dụng về màn hình chính, toàn bộ nội dung đang chỉnh bị mất 🔲
- [ ] Chưa đăng nhập cố vào luồng tạo tem → hệ thống chuyển về màn hình đăng nhập ✅

## Trường hợp biên (Edge Cases)

- [ ] Banh phần tử đến kích thước tối đa (lấp đầy vùng tem) rồi tiếp tục banh → phần tử dừng lại, không lớn thêm, không biến mất 🚫
- [ ] Chụm phần tử đến kích thước tối thiểu (1/10 chiều rộng vùng tem) rồi tiếp tục chụm → phần tử dừng lại, vẫn nhìn thấy được 🚫
- [ ] Thêm nhiều phần tử liên tục (ít nhất 10 sticker/chữ/icon) → hệ thống không giới hạn, không tự xoá bất kỳ phần tử nào ✅
- [ ] Kéo phần tử đến sát mép vùng tem → kiểm tra hành vi (giữ lại trong vùng hoặc cho phép ra ngoài một phần) 🔲
- [ ] App bị đóng đột ngột (crash) giữa bước trang trí → mở lại ứng dụng: về màn hình chính, nội dung đang trang trí bị huỷ 🔲

## Trường hợp offline

- [ ] Mất mạng → thêm sticker từ bộ đã tải sẵn → thao tác thành công, không có thông báo lỗi 🔲
- [ ] Mất mạng → nhập chữ, chọn font, đổi màu, kéo thả chữ → tất cả thao tác thực hiện được bình thường 🔲
- [ ] Mất mạng → chọn bộ sticker đặc biệt chưa tải về thiết bị → thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." hiển thị đúng 🔲
- [ ] Mất mạng → chọn bộ sticker đặc biệt chưa tải → bộ sticker không được tải, các sticker đã có sẵn vẫn dùng được 🔲
- [ ] Có mạng nhưng máy chủ lỗi khi tải sticker → thông báo lỗi kèm nút "Thử lại" xuất hiện 🔲
- [ ] Nhấn "Thử lại" sau lỗi máy chủ → không cần thoát bước trang trí, thử tải lại bình thường 🔲
- [ ] Thử lại vẫn thất bại → có thể tiếp tục trang trí bằng sticker và font đã có sẵn 🔲

## Ghi chú tự động hóa
- ✅ Maestro automatable — thao tác đơn: tap, assert text/element, scroll, navigation, nhập văn bản
- 🔲 Manual only — cần kiểm thử thủ công: kéo thả phức tạp trên canvas, tắt mạng thiết bị thật, hành vi sau thoát app, lỗi máy chủ cần giả lập
- 🚫 Not automatable — không thể tự động hoá: cử chỉ đa điểm chạm (pinch-zoom, xoay hai ngón tay) không thể mô phỏng bằng Maestro

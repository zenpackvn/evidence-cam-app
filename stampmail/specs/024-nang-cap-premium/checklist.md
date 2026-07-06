# Checklist QA — Nâng cấp Premium & Thanh toán (SM-028) (024-nang-cap-premium)

## Điều kiện tiên quyết
- [ ] Tài khoản người dùng đã đăng nhập (SM-001)
- [ ] Tài khoản đang ở gói Thường (Free)
- [ ] Thiết bị có kết nối internet ổn định
- [ ] Tài khoản App Store / Google Play đã được thiết lập (để kiểm tra luồng thanh toán)
- [ ] Có sẵn tài khoản thử nghiệm có gói Premium (để kiểm tra TC người dùng đã Premium)

## Luồng chính (Happy Path)

- [ ] Nhấn nút nâng cấp từ tính năng bị khoá → màn hình nâng cấp hiển thị đúng ✅
- [ ] Nhấn nút nâng cấp từ hộp hết hạn mức → màn hình nâng cấp hiển thị đúng ✅
- [ ] Nhấn nút nâng cấp từ menu → màn hình nâng cấp hiển thị đúng ✅
- [ ] Màn hình nâng cấp hiển thị bảng so sánh Free vs Premium (BR-01, AC-01) ✅
- [ ] Bảng so sánh liệt kê đầy đủ 5 điểm khác biệt: bộ lọc, viền, template, giới hạn tem, giới hạn thư (BR-01, AC-01) ✅
- [ ] Cột Free hiển thị đúng: 30 tem/tháng, 10 thư/tháng (BR-05, AC-01) ✅
- [ ] Cột Premium hiển thị đúng: không giới hạn tem, không giới hạn thư, 8 bộ lọc, 3 viền, hơn 17 template (BR-05, AC-01) ✅
- [ ] Hai gói thời hạn được hiển thị: gói tháng và gói năm (BR-02, AC-02) ✅
- [ ] Gói năm hiển thị thông tin tiết kiệm so với mua tháng (ví dụ: "Tiết kiệm X% so với mua tháng") (AC-02) ✅
- [ ] Giá gói năm chia 12 thấp hơn giá gói tháng (AC-02) ✅
- [ ] Chọn gói tháng → cổng thanh toán App Store / Google Play mở ra (BR-03) 🔲
- [ ] Chọn gói năm → cổng thanh toán App Store / Google Play mở ra (BR-03) 🔲
- [ ] App không hiển thị form nhập thẻ tín dụng trực tiếp — toàn bộ giao dịch qua cổng nền tảng (BR-03) 🔲
- [ ] Hoàn tất thanh toán thành công → ngay lập tức nhận trạng thái Premium, không cần khởi động lại (BR-04, AC-03) 🔲
- [ ] Sau thanh toán: 8 bộ lọc Premium (Tâm trạng 4 + Mùa 4) có thể dùng được ngay, không bị khoá (BR-05, AC-03) 🔲
- [ ] Sau thanh toán: 3 kiểu viền Premium (Zigzag, Viền đôi, Retro bo mềm) có thể dùng được ngay (BR-05, AC-03) 🔲
- [ ] Sau thanh toán: hơn 17 template thư Premium có thể dùng được ngay (BR-05, AC-03) 🔲
- [ ] Sau thanh toán: hạn mức tem tháng không còn hiển thị (BR-05, AC-03) 🔲
- [ ] Sau thanh toán: hạn mức thư tháng không còn hiển thị (BR-05, AC-03) 🔲

## Luồng thất bại & Validation

- [ ] Thanh toán thất bại (nền tảng từ chối) → hiển thị thông báo lỗi từ nền tảng (AC-04) 🔲
- [ ] Thanh toán thất bại → thông báo gợi ý kiểm tra phương thức thanh toán và thử lại (AC-04) ✅
- [ ] Thanh toán thất bại → tài khoản vẫn ở gói Thường (Free), không có khoản trừ (AC-04) 🚫
- [ ] Thanh toán thất bại → người dùng có thể thử lại từ màn hình (AC-04) 🔲
- [ ] Người dùng chưa đăng nhập cố vào màn hình nâng cấp → chuyển đến màn hình đăng nhập (SM-001) ✅
- [ ] Sau đăng nhập thành công từ luồng trên → được đưa trở lại màn hình nâng cấp ✅
- [ ] Người dùng đã là Premium vào màn hình nâng cấp → hiển thị trạng thái Premium với ngày hết hạn 🔲
- [ ] Người dùng đã là Premium → có liên kết đến quản lý đăng ký (SM-029) ✅
- [ ] Người dùng đã là Premium → không hiển thị nút mua hay lựa chọn gói mới 🔲
- [ ] Màn hình so sánh đang tải: hiển thị loading indicator, không hiển thị màn hình trắng hay nội dung thiếu (Mục 5) ✅
- [ ] Dữ liệu gói tải thất bại (lỗi máy chủ): hiển thị thông báo lỗi và nút "Thử lại" (Mục 5) ✅
- [ ] Nhấn "Thử lại" sau lỗi máy chủ → app tải lại danh sách gói ✅

## Offline — Chặn thanh toán (BR-06, AC-05)

- [ ] Mất mạng → nhấn nút xác nhận thanh toán → hiển thị "Không có kết nối. Vui lòng thử lại khi có mạng." (AC-05, BR-06) 🔲
- [ ] Mất mạng khi nhấn mua → nút thanh toán không phản hồi, không mở cổng nền tảng (AC-05, BR-06) 🔲
- [ ] Mất mạng khi nhấn mua → gói đã chọn (tháng hoặc năm) vẫn được giữ nguyên (AC-05, BR-06) 🔲
- [ ] Mạng trở lại → gói đã chọn trước đó vẫn được giữ nguyên, không phải chọn lại (BR-06) 🔲

## Offline — Xem nội dung so sánh (BR-07, AC-06)

- [ ] Màn hình so sánh đã tải → mất mạng → bảng so sánh vẫn hiển thị đầy đủ (AC-06, BR-07) 🔲
- [ ] Màn hình so sánh đã tải → mất mạng → thông tin giá gói tháng/năm vẫn hiển thị (AC-06, BR-07) 🔲
- [ ] Màn hình so sánh đã tải → mất mạng → chỉ nút xác nhận thanh toán bị vô hiệu hoá (AC-06, BR-07) 🔲
- [ ] Mở màn hình nâng cấp khi đã mất mạng và chưa có cache → app hiển thị thông báo lỗi mạng, không màn hình trắng (Mục 5) 🔲

## Trường hợp biên (Edge Cases)

- [ ] Người dùng nhấn nút nâng cấp nhiều lần liên tiếp → chỉ một phiên thanh toán được khởi tạo ✅
- [ ] Mất kết nối giữa chừng sau khi cổng thanh toán đã mở → nền tảng tự xử lý; app hiển thị hướng dẫn kiểm tra trạng thái đăng ký (Mục 5) 🚫
- [ ] Thoát app khi cổng thanh toán đang mở (chưa xác nhận) → tài khoản vẫn gói Thường, không có giao dịch (Mục 5) 🚫
- [ ] Thoát app sau khi đã xác nhận thanh toán trên cổng nền tảng → mở lại app → trạng thái tài khoản đúng với kết quả thanh toán từ nền tảng (Mục 5) 🚫
- [ ] Thoát app khi đang xem màn hình so sánh (chưa xác nhận) → không tạo giao dịch, không mất dữ liệu (Mục 5) ✅
- [ ] Trên iOS: cổng thanh toán là App Store (không phải Google Play) 🔲
- [ ] Trên Android: cổng thanh toán là Google Play (không phải App Store) 🔲

## Ghi chú tự động hóa
- ✅ Maestro automatable — kiểm tra UI hiển thị: bảng so sánh, thông tin giá, thông báo lỗi mạng, trạng thái loading, điều hướng đa điểm vào, chuyển hướng đăng nhập
- 🔲 Manual only — luồng thanh toán thực tế qua App Store / Google Play, mở khoá nội dung sau thanh toán, kiểm tra trạng thái mạng offline, xác nhận trạng thái Premium
- 🚫 Not automatable — xác minh phía máy chủ (không trừ tiền), xử lý mất kết nối giữa chừng thanh toán, trạng thái đăng ký cross-platform, kiểm tra lịch sử giao dịch nền tảng

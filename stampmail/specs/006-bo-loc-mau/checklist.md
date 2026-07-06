# Checklist QA — Bộ lọc màu & Chỉnh ảnh thủ công (006-bo-loc-mau)

## Điều kiện tiên quyết
- [ ] Ứng dụng StampMail đã cài đặt và khởi động được trên thiết bị iOS và Android
- [ ] Có tài khoản test gói Thường (Free) đã đăng nhập
- [ ] Có tài khoản test gói Premium đã đăng nhập
- [ ] Có tình huống test tài khoản chưa đăng nhập (khách)
- [ ] Đã hoàn thành bước chọn/chụp ảnh (SM-005) với ảnh gốc hợp lệ để vào màn hình Bộ lọc màu
- [ ] Thiết bị thật có cấu hình thấp sẵn sàng (cho test hiệu năng)
- [ ] Ảnh test kích thước lớn (trên 5 MB) sẵn sàng

## Luồng chính (Happy Path)

- [ ] Màn hình Bộ lọc màu hiển thị đúng 16 bộ lọc chia thành 4 nhóm chủ đề  ✅
- [ ] Nhóm Cổ điển có đúng 4 bộ lọc; nhóm Retro/Vintage có đúng 4 bộ lọc  ✅
- [ ] Nhóm Tâm trạng có đúng 4 bộ lọc; nhóm Mùa có đúng 4 bộ lọc  ✅
- [ ] Mục "Gốc" luôn hiển thị trong danh sách bộ lọc với mọi loại tài khoản  ✅
- [ ] Người dùng Free nhấn bộ lọc Free → ảnh xem trước thay đổi ngay lập tức, không cần xác nhận (AC-01)  ✅
- [ ] Bộ lọc đang chọn hiển thị trạng thái active (viền hoặc highlight)  ✅
- [ ] Thanh Sáng/Tối hiển thị, kéo được; kéo về Sáng → ảnh sáng lên; kéo về Tối → ảnh tối dần (AC-03)  🔲
- [ ] Thanh Ấm/Lạnh hiển thị, kéo được; kéo về Ấm → màu ngả vàng/cam; kéo về Lạnh → màu ngả xanh (AC-08)  🔲
- [ ] Thanh Nhạt/Đậm hiển thị, kéo được; kéo về Nhạt → ảnh gần đen trắng; kéo về Đậm → màu sặc sỡ hơn (AC-09)  🔲
- [ ] Ba thanh hoạt động độc lập, mỗi thay đổi phản ánh ngay trên xem trước, không cần xác nhận (BR-05)  🔲
- [ ] Kéo thanh Ấm/Lạnh sau khi đã chọn bộ lọc → ảnh xem trước kết hợp cả hai hiệu ứng (AC-04)  🔲
- [ ] Nhấn "Đặt lại" khi cả ba thanh đã kéo → ba thanh về trung tâm; bộ lọc đang chọn không thay đổi (AC-10)  ✅
- [ ] Chọn "Gốc" khi đang áp bộ lọc → bộ lọc bị bỏ; ảnh chỉ phản ánh phần chỉnh tay (AC-11)  ✅
- [ ] Người dùng Premium vào màn hình bộ lọc → tất cả 16 bộ lọc có thể chọn, không có biểu tượng khoá (AC-05)  ✅
- [ ] Người dùng Premium nhấn bộ lọc Premium → ảnh xem trước thay đổi ngay, không có gợi ý nâng cấp (AC-05)  ✅

## Luồng thất bại & Validation

- [ ] Người dùng Free nhấn bộ lọc Premium → hiển thị gợi ý nâng cấp, ảnh xem trước không thay đổi (AC-02)  ✅
- [ ] 8 bộ lọc nhóm Tâm trạng và Mùa hiển thị biểu tượng khoá với người dùng Free (BR-03)  ✅
- [ ] 8 bộ lọc nhóm Cổ điển và Retro/Vintage không có biểu tượng khoá với người dùng Free  ✅
- [ ] Nhấn nút "Nâng cấp" trong gợi ý → điều hướng đến màn hình Nâng cấp Premium SM-028 (BR-03)  ✅
- [ ] Người dùng chưa đăng nhập nhấn bộ lọc Premium → hiển thị gợi ý đăng nhập hoặc nâng cấp  ✅
- [ ] Người dùng chưa đăng nhập có thể dùng bộ lọc Free và ba thanh chỉnh tay bình thường  ✅
- [ ] Nhấn Quay lại về bước chọn ảnh → ảnh gốc nguyên vẹn, bộ lọc đang chọn bị huỷ (BR-06)  ✅
- [ ] Trên thiết bị yếu: xem trước có thể trễ nhưng phải cập nhật trong vài giây; không đứng hình  🔲

## Trường hợp biên (Edge Cases)

- [ ] Kéo thanh Sáng/Tối về cực tối → ảnh tối nhưng không hoàn toàn đen; nội dung vẫn nhận ra  🔲
- [ ] Kéo thanh Sáng/Tối về cực sáng → ảnh sáng nhưng nội dung vẫn nhận ra  🔲
- [ ] Kéo thanh Nhạt/Đậm về cực Nhạt → ảnh gần như đen trắng hoàn toàn  🔲
- [ ] Kéo thanh Nhạt/Đậm về cực Đậm → màu sắc sặc sỡ rõ rệt hơn ảnh gốc  🔲
- [ ] Áp đồng thời cả 3 thanh điều chỉnh + 1 bộ lọc → ảnh xem trước phản ánh tổng hợp tất cả  🔲
- [ ] Nhấn "Đặt lại" khi ba thanh đang ở trung tâm → không có thay đổi gì; ảnh xem trước giữ nguyên  ✅
- [ ] Chuyển nhanh giữa nhiều bộ lọc Free liên tiếp → ảnh xem trước luôn phản ánh bộ lọc cuối cùng (BR-05)  ✅
- [ ] Thoát app giữa chừng bước Bộ lọc màu rồi mở lại → về màn hình chính, không lưu trạng thái bộ lọc  🚫
- [ ] Người dùng Premium đã xác nhận gói trước đó → khi offline vẫn dùng được bộ lọc Premium (BR-08)  🔲
- [ ] Nhấn bộ lọc Premium khi offline và chưa xác nhận gói → thông báo lỗi xác minh đúng nội dung (AC-07)  🔲
- [ ] Nhấn "Tiếp theo" sang SM-008 khi đang offline → chuyển bước thành công, không bị chặn (BR-09)  🔲

## Offline

- [ ] Kéo ba thanh chỉnh tay khi offline → ảnh xem trước vẫn cập nhật bình thường (AC-06)  🔲
- [ ] Áp bộ lọc Free khi offline → ảnh xem trước thay đổi ngay, không có thông báo lỗi mạng (AC-06)  🔲
- [ ] Tài khoản Premium đã xác nhận: bộ lọc Premium khả dụng khi offline (BR-08)  🔲
- [ ] Tài khoản vừa nâng cấp chưa xác nhận gói, offline → bộ lọc Premium bị khoá + thông báo "Không thể xác minh gói Premium. Vui lòng kiểm tra kết nối và thử lại." (AC-07)  🔲
- [ ] Nhấn "Tiếp theo" sang SM-008 khi offline → luồng tạo tem không bị chặn (BR-09)  🔲

## Ghi chú tự động hóa
- ✅ Maestro automatable — kiểm tra bằng tap, assert visible text/id, scroll, điều hướng màn hình
- 🔲 Manual only — cần kéo thanh trượt (slider drag) và quan sát thay đổi màu sắc/độ sáng trực quan theo thời gian thực; hoặc cần tắt mạng thực tế trên thiết bị; hoặc cần thiết bị thật cấu hình thấp
- 🚫 Không thể tự động hóa — kiểm tra hành vi sau khi ép thoát app (force-kill), phụ thuộc trạng thái hệ điều hành không thể tái tạo ổn định qua UI test

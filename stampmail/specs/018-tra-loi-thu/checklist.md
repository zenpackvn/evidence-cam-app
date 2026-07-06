# Checklist QA — Trả lời thư (018-tra-loi-thu)

## Điều kiện tiên quyết
- [ ] Người dùng đã đăng nhập vào ứng dụng StampMail (SM-001)
- [ ] Người dùng đã mở và đọc ít nhất một thư từ người khác (SM-019)
- [ ] Có ít nhất một thư hợp lệ trong hộp thư đến với thông tin người gửi rõ ràng
- [ ] Animation mở thư (SM-019) đã hoàn tất trước khi kiểm tra nút Trả lời

## Luồng chính (Happy Path)

- [ ] Nút "Trả lời" hiển thị trên màn hình đọc thư sau khi animation mở thư hoàn tất ✅
- [ ] Nhấn nút "Trả lời" mở màn hình soạn thư ✅
- [ ] Ô người nhận đã được điền sẵn tên người gửi gốc (ví dụ: "An") khi màn hình soạn thư mở ra — người dùng không phải nhập thêm (BR-01, AC-01) ✅
- [ ] Hệ thống gợi ý template trả lời (reply template) phù hợp được chọn sẵn khi mở soạn thư (BR-02) ✅
- [ ] Danh sách template khác vẫn có thể chọn được (BR-02) ✅
- [ ] Người dùng có thể thay đổi template sang template khác; ô người nhận giữ nguyên sau khi đổi (BR-02) ✅
- [ ] Người dùng có thể soạn nội dung thư trả lời bình thường ✅
- [ ] Nhấn xác nhận gửi chuyển người dùng đến màn hình chọn nền tảng MXH để chia sẻ link (BR-03, AC-02) ✅
- [ ] Màn hình chọn MXH cho thư trả lời giống hệt luồng gửi thư mới (SM-016) (BR-03) ✅
- [ ] Màn hình soạn thư không hiển thị nội dung thư gốc — không có phần trích dẫn hay threading (BR-04) ✅

## Luồng thất bại & Validation

- [ ] Người đọc thư trên web nhấn "Trả lời" — hiển thị màn hình "Tải StampMail để trả lời thư này" kèm nút App Store/Google Play; KHÔNG có form soạn thư trực tiếp trên web (BR-05, AC-03) 🔲
- [ ] Người dùng trong app chưa đăng nhập nhấn "Trả lời" — chuyển sang màn hình đăng nhập/đăng ký trước khi mở soạn thư (AC-04) 🔲
- [ ] Sau khi đăng nhập thành công, hệ thống tự quay lại màn hình soạn thư trả lời với người nhận đã điền sẵn (AC-04, Nhóm 3) 🔲
- [ ] Khi mất mạng, nút "Gửi" bị vô hiệu hóa và hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." (BR-06, AC-05) 🔲
- [ ] Khi mất mạng, nội dung thư đã soạn không bị mất — vẫn hiển thị nguyên vẹn trên màn hình (BR-06, AC-05) 🔲
- [ ] Khi mạng trở lại, nút "Gửi" được kích hoạt lại tự động, không cần nhập lại nội dung (BR-06, Nhóm 1) 🔲
- [ ] Người dùng mất mạng trước khi soạn thư vẫn mở được màn hình trả lời và nhập nội dung bình thường (BR-07, AC-06) 🔲
- [ ] Người dùng mất mạng trước khi soạn thư vẫn chọn được template mà không gặp lỗi (BR-07, AC-06) 🔲
- [ ] Khi thông tin người gửi gốc không tải được — màn hình soạn thư hiển thị trạng thái lỗi với nút "Thử lại" thay vì điền sẵn tên người nhận (Nhóm 2) 🔲
- [ ] Nhấn "Thử lại" → hệ thống tải lại thông tin người gửi gốc và điền vào ô người nhận (Nhóm 2) 🔲
- [ ] Khi người gửi gốc đã xoá tài khoản — hệ thống vẫn cho phép soạn thư nhưng hiển thị cảnh báo "người nhận có thể không còn hoạt động" (Mục 5) 🔲
- [ ] Thông báo cảnh báo người nhận không còn hoạt động hiển thị rõ ràng nhưng không chặn người dùng gửi (Mục 5) 🔲
- [ ] Người dùng thoát khỏi màn hình soạn thư khi đang soạn dở — ứng dụng hiển thị hộp thoại xác nhận "Bỏ thư này?" ✅
- [ ] Chọn "Hủy" trong hộp thoại "Bỏ thư này?" — quay lại màn hình soạn thư, nội dung vẫn còn ✅
- [ ] Chọn "Đồng ý" trong hộp thoại "Bỏ thư này?" — màn hình soạn thư đóng lại, nội dung bị xoá ✅

## Trường hợp biên (Edge Cases)

- [ ] Nhấn "Trả lời" ngay khi animation mở thư chưa kết thúc — nút không phản hồi hoặc bị vô hiệu hóa cho đến khi animation xong (liên kết SM-019) 🔲
- [ ] Thoát app giữa chừng đang soạn thư trả lời — lần sau mở app hệ thống hỏi có muốn tiếp tục thư đang soạn dở không (Nhóm 3) 🔲
- [ ] Chọn tiếp tục nháp sau khi mở lại app — nội dung đã soạn hiển thị nguyên vẹn (Nhóm 3) 🔲
- [ ] Chọn không tiếp tục nháp sau khi mở lại app — nháp bị xoá, vào màn hình chính (Nhóm 3) 🔲
- [ ] Thư trả lời đã gửi hiển thị trong lịch sử như một thư độc lập, không gộp vào chuỗi với thư gốc (BR-04) 🔲
- [ ] Đổi template nhiều lần trước khi gửi — chỉ template cuối cùng được áp dụng ✅
- [ ] Người dùng web không thấy bất kỳ form hay tùy chọn soạn thư nào trực tiếp trên trang web (BR-05) 🔲

## Ghi chú tự động hóa
- ✅ Maestro automatable — tap, nhập văn bản, assert văn bản/thành phần hiển thị, kiểm tra trạng thái nút, chọn template
- 🔲 Manual only — trạng thái offline (tắt/bật mạng thiết bị thực), animation timing (SM-019), tài khoản đã xoá (cần thao tác hệ thống quản trị), kiểm tra lưu nháp sau khi thoát app, luồng đăng nhập trước khi trả lời, web browser reader
- 🚫 Không thể tự động hóa — xác minh trạng thái tài khoản đã xoá thực sự trên máy chủ, lỗi máy chủ ngẫu nhiên không tái tạo được

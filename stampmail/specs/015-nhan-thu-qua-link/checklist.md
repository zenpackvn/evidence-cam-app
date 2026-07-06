# Checklist QA — Nhận thư qua Link (015-nhan-thu-qua-link)

## Điều kiện tiên quyết
- [ ] Có tài khoản người gửi đã cài StampMail và đã tạo thư có tem hợp lệ
- [ ] Có link thư hợp lệ chưa được ai mở, chưa hết hạn (trong 7 ngày kể từ khi tạo)
- [ ] Có thiết bị thử nghiệm: một thiết bị chưa cài StampMail, một thiết bị đã cài StampMail
- [ ] Có tài khoản StampMail để đăng nhập sau khi đọc thư (cho AC-05)
- [ ] Có link thư đã hết hạn (quá 7 ngày) để kiểm tra BR-06 / AC-06
- [ ] Có link thư đã được người khác mở trước để kiểm tra BR-03 / AC-03

## Luồng chính (Happy Path)

### BR-01 / AC-01 — Xem thư trên trình duyệt không cần app
- [ ] Mở link thư trên trình duyệt (thiết bị chưa cài StampMail) — trang web tải thành công mà không yêu cầu đăng nhập ✅
- [ ] Trang web hiển thị đầy đủ nội dung thư: tiêu đề, nội dung, hình ảnh tem ✅
- [ ] Animation mở thư (SM-019) được phát trên trang web trước khi hiển thị nội dung 🔲

### BR-02 / AC-02 — Link mở trong app nếu đã cài
- [ ] Nhấn link thư trên thiết bị đã cài StampMail — ứng dụng StampMail tự động mở (không mở trình duyệt) 🔲
- [ ] Nội dung thư hiển thị đầy đủ bên trong app StampMail ✅

### BR-04 / AC-04 — Gợi ý tải app sau khi đọc (người chưa có app)
- [ ] Sau khi xem xong thư trên trình duyệt, gợi ý tải StampMail xuất hiện ✅
- [ ] Gợi ý có nội dung mời lưu tem và nhận thư của riêng mình ✅
- [ ] Nút/link "Tải StampMail" dẫn đến đúng cửa hàng ứng dụng (App Store hoặc Google Play) 🔲

### BR-05 / AC-05 — Tem vào Album sau khi đăng nhập
- [ ] Sau khi đọc thư trên web, nhấn "Tải StampMail" rồi đăng ký/đăng nhập thành công ✅
- [ ] Tem trong thư được tự động thêm vào Album của người nhận sau khi đăng nhập ✅
- [ ] Đăng nhập bằng tài khoản đã có (không phải đăng ký mới) — tem vẫn được thêm vào Album ✅
- [ ] Nếu chỉ xem thư trên web mà không đăng nhập, tem không xuất hiện trong Album 🚫

## Luồng thất bại & Validation

### BR-03 / AC-03 — Link một lần (chỉ người đầu tiên nhận được thư)
- [ ] Người thứ hai nhấn link đã được người khác mở trước — thấy thông báo "thư đã được nhận" ✅
- [ ] Nội dung thư không hiển thị cho người thứ hai ✅
- [ ] Cùng người mở lại link đã dùng — thấy thông báo thư đã được nhận (không xem lại được) ✅

### BR-06 / AC-06 — Link hết hạn
- [ ] Mở link thư quá 7 ngày — thấy thông báo link đã hết hạn 🚫
- [ ] Nội dung thư không hiển thị khi link hết hạn 🚫
- [ ] Thông báo hết hạn rõ ràng, thân thiện, không phải lỗi kỹ thuật 🚫

### BR-07 / AC-07 — Không có mạng ngay từ đầu
- [ ] Mở link khi không có kết nối mạng — trang hiển thị "Không có kết nối mạng. Vui lòng thử lại khi có mạng." 🔲
- [ ] Nội dung thư không hiển thị khi mất mạng từ đầu 🔲

### BR-08 / AC-08 — Mất mạng sau khi đã tải xong thư
- [ ] Mất mạng sau khi nội dung thư đã tải hoàn tất — nội dung thư và tem vẫn hiển thị đầy đủ 🔲
- [ ] Trang hiển thị thông báo nhỏ "Đang xem ngoại tuyến" 🔲
- [ ] Nút đăng nhập/đăng ký bị vô hiệu hóa khi đang xem ngoại tuyến 🔲

### BR-09 / AC-08 — Chặn đăng nhập/đăng ký khi mất mạng
- [ ] Nhấn đăng nhập hoặc "Tải StampMail" khi không có mạng — thao tác bị chặn 🔲
- [ ] Hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." 🔲
- [ ] Dữ liệu đã nhập không bị mất sau khi thông báo xuất hiện 🔲

### Lỗi máy chủ
- [ ] Máy chủ trả về lỗi khi tải thư — hiển thị màn hình lỗi thân thiện kèm nút "Thử lại" 🔲
- [ ] Nhấn "Thử lại" khi máy chủ phục hồi — nội dung thư tải thành công 🔲

### Link không hợp lệ
- [ ] Mở link sai định dạng hoặc không tồn tại — hiển thị thông báo "link không hợp lệ" ✅
- [ ] Không có nút "Thử lại" khi link không hợp lệ ✅

## Trường hợp biên (Edge Cases)

- [ ] Người dùng mở link trên máy tính (desktop) — nội dung thư hiển thị đúng trên trình duyệt desktop 🔲
- [ ] Người dùng đã cài app nhưng mở link từ trình duyệt thủ công — xác nhận hành vi (mở app hay tiếp tục web) 🔲
- [ ] Link được chia sẻ lại sau khi đã có người mở — người nhận mới thấy thông báo thư đã được nhận ✅
- [ ] Đóng trình duyệt giữa chừng (chưa đăng nhập) rồi mở lại link — link vẫn truy cập được nếu chưa có ai nhận tem 🔲
- [ ] Kết nối mạng phục hồi sau khi trang báo lỗi mạng từ đầu — người dùng có thể thử lại và xem thư thành công 🔲

## Ghi chú tự động hóa
- ✅ Maestro automatable — Có thể kiểm tra bằng Maestro: tải trang web, xác nhận văn bản hiển thị, nhấn nút, kiểm tra trạng thái Album, xác nhận thông báo lỗi.
- 🔲 Manual only — Yêu cầu kiểm tra thủ công: animation mở thư, deep link mở app từ hệ điều hành, điều hướng đến cửa hàng ứng dụng, giả lập mất mạng, lỗi máy chủ, kiểm tra trên nhiều trình duyệt/thiết bị.
- 🚫 Not automatable — Không thể tự động hóa: kiểm tra trạng thái phía máy chủ (link đã dùng / hết hạn theo thời gian thực 7 ngày), xác minh tem không có trong Album khi không đăng nhập.

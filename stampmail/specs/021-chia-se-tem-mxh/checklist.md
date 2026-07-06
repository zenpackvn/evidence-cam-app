# Checklist QA — Chia sẻ tem lên MXH (021-chia-se-tem-mxh)

## Điều kiện tiên quyết
- [ ] Người dùng đã đăng nhập vào tài khoản StampMail (SM-001)
- [ ] Người dùng có ít nhất một tem trong Album (SM-022)
- [ ] Thiết bị có kết nối mạng ổn định
- [ ] Đã cấp quyền lưu ảnh vào thư viện điện thoại cho StampMail (cho TC liên quan đến lưu ảnh)

## Luồng chính (Happy Path)

- [ ] Người dùng mở màn hình chia sẻ từ Album — màn hình hiển thị đúng hai tùy chọn định dạng: "Dọc 9:16" và "Vuông 1:1" ✅
- [ ] Chọn Mức 1 (Chỉ tem) — không có cảnh báo nào xuất hiện, luồng tiếp tục bình thường ✅
- [ ] Chọn định dạng 9:16 rồi nhấn Chia sẻ → native share sheet mở với ảnh tỉ lệ 9:16 kèm watermark StampMail 🔲
- [ ] Chọn định dạng 1:1 rồi nhấn Chia sẻ → native share sheet mở với ảnh tỉ lệ 1:1 kèm watermark StampMail 🔲
- [ ] Native share sheet do hệ điều hành cung cấp — người dùng tự chọn nền tảng (Instagram, TikTok, Facebook, Threads, Twitter/X hoặc bất kỳ app nào khác) 🔲
- [ ] Chọn Mức 2 (Tem + trích dẫn) → màn hình cho phép chọn một câu từ nội dung thư ✅
- [ ] Chọn Mức 3 (Tem + toàn bộ nội dung thư) → nội dung thư đầy đủ kèm theo tem trong ảnh ✅
- [ ] Nhấn "Lưu về thư viện" → ảnh đúng định dạng và có watermark được lưu vào thư viện ảnh điện thoại 🔲
- [ ] Watermark StampMail xuất hiện trên mọi ảnh chia sẻ (cả Mức 1, 2, 3) — không có nút/tùy chọn xóa hoặc tắt 🔲

## Luồng thất bại & Validation

- [ ] Chọn Mức 2 rồi nhấn Tiếp tục → cảnh báo "Nội dung thư sẽ công khai" hiển thị và yêu cầu xác nhận ✅
- [ ] Chọn Mức 3 rồi nhấn Tiếp tục → cảnh báo "Nội dung thư sẽ công khai" hiển thị và yêu cầu xác nhận ✅
- [ ] Người dùng nhấn Hủy trên hộp thoại cảnh báo → không chia sẻ, quay về màn hình chia sẻ ✅
- [ ] Người dùng xác nhận cảnh báo Mức 2/3 → luồng tiếp tục, cảnh báo không hiển thị lại trong cùng phiên ✅
- [ ] Người dùng từ chối quyền lưu ảnh vào thư viện → thông báo yêu cầu quyền và hướng dẫn vào Cài đặt hiển thị 🔲
- [ ] Album không tải được do lỗi mạng/máy chủ → thông báo lỗi và nút "Thử lại" hiển thị 🔲
- [ ] Tem đã lưu cục bộ vẫn dùng được ngay cả khi có lỗi máy chủ 🔲
- [ ] Người dùng chưa đăng nhập cố truy cập tính năng Chia sẻ → chuyển về màn hình đăng nhập, sau đăng nhập quay lại luồng ✅

## Trường hợp ngoại lệ & Offline (Edge Cases)

- [ ] Thiết bị mất mạng — chọn tem, chọn mức nội dung, chọn định dạng vẫn hoạt động bình thường (xử lý cục bộ) 🔲
- [ ] Thiết bị mất mạng — nhấn "Lưu về thư viện" → ảnh được lưu thành công, không có thông báo lỗi mạng 🔲
- [ ] Thiết bị mất mạng — nhấn "Chia sẻ" → native share sheet vẫn mở, đồng thời thông báo "Thiết bị đang ngoại tuyến — chia sẻ lên mạng xã hội có thể không thành công" hiển thị 🔲
- [ ] Thoát app giữa luồng chia sẻ (chưa lưu/chia sẻ) → mở lại app, người dùng bắt đầu lại từ bước chọn tem 🔲
- [ ] Chọn Mức 2 nhưng nội dung thư chỉ có một câu → chỉ câu duy nhất đó hiển thị để chọn làm trích dẫn ✅
- [ ] Album chỉ có đúng một tem → luồng chia sẻ hoạt động bình thường với tem đó ✅
- [ ] Ảnh tem gốc không có tỉ lệ 9:16 — sau khi chọn định dạng 9:16, ảnh xuất ra vẫn đúng tỉ lệ 9:16 🔲
- [ ] Không có ứng dụng MXH nào cài trên thiết bị — native share sheet vẫn mở, người dùng có thể chọn các tùy chọn khác do hệ điều hành cung cấp (lưu file, gửi qua tin nhắn, v.v.) 🔲

## Ghi chú tự động hóa
- ✅ Maestro automatable — điều hướng màn hình, nhấn nút, kiểm tra văn bản/hộp thoại, chọn mức nội dung, xác nhận cảnh báo, kiểm tra trạng thái đăng nhập
- 🔲 Manual only — kiểm tra tỉ lệ ảnh thực tế được tạo ra, watermark trên ảnh, lưu ảnh vào thư viện, native share sheet của thiết bị, trạng thái mất mạng, thoát/quay lại app
- 🚫 Not automatable — kiểm tra ảnh thực sự được đăng lên MXH, trạng thái server-side của từng nền tảng

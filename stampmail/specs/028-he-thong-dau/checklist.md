# Checklist QA — Hệ thống Dấu (SM-033 / 028-he-thong-dau)

## Điều kiện tiên quyết
- [ ] Người dùng A đã đăng nhập thành công
- [ ] Người dùng B đã đăng nhập trên thiết bị khác (để tạo sự kiện kiếm Dấu từ Chain Unlock)
- [ ] Môi trường test cho phép reset số Dấu và giới hạn tuần/tháng
- [ ] Có tài khoản test với đúng 0📮 để kiểm thử trường hợp không đủ Dấu
- [ ] Có bộ sticker, kiểu viền và tem mẫu chưa mở khóa để kiểm thử tiêu Dấu
- [ ] Có phương thức thanh toán sandbox (App Store / Google Play) để kiểm thử IAP

## Luồng chính (Happy Path)

### Kiếm Dấu — Share to Unlock
- [ ] Chia sẻ tem lần 1 trong tuần → nhận đúng 10📮, số Dấu tăng ngay lập tức 🔲
- [ ] Chia sẻ tem lần 2 trong tuần → nhận đúng 10📮 (tổng 20📮 từ chia sẻ) 🔲
- [ ] Chia sẻ tem lần 3 trong tuần → nhận đúng 10📮 (đạt giới hạn 3 lần/tuần) 🔲
- [ ] Thông báo nhỏ "Bạn kiếm được 10📮" hiển thị mỗi lần chia sẻ hợp lệ ✅

### Kiếm Dấu — Chain Unlock
- [ ] Gửi thư thành công → nhận đúng 5📮 ngay tại màn hình xác nhận gửi ✅
- [ ] Gửi nhiều thư liên tiếp → mỗi lần đều nhận 5📮 (không giới hạn số lần/ngày) ✅
- [ ] Người nhận mở thư lần đầu và animation kết thúc hoàn toàn → người gửi nhận đúng 15📮 🔲
- [ ] Người nhận cài StampMail từ link thư (tài khoản mới hoàn toàn) → người gửi nhận đúng 50📮 🔲

### Tiêu Dấu
- [ ] Tiêu 50📮 mở bộ sticker đặc biệt → bộ sticker khả dụng ngay, số Dấu giảm đúng 50📮 ✅
- [ ] Tiêu 80📮 mở kiểu viền → kiểu viền áp được ngay, số Dấu giảm đúng 80📮 ✅
- [ ] Tiêu 30📮 mở tem mẫu → tem mẫu khả dụng, nút đổi thành "Lưu vào Album", số Dấu giảm đúng 30📮 ✅

### Mua Dấu (IAP)
- [ ] Mua gói 100📮 (29.000đ) → số Dấu tăng đúng 100📮 sau giao dịch thành công 🔲
- [ ] Dấu mua có tính chất giống Dấu kiếm được: không hết hạn, dùng được để mở item 🔲

### Hiển thị & Trạng thái
- [ ] Số Dấu hiển thị ở vị trí dễ thấy (màn hình chính hoặc trang hồ sơ) ✅
- [ ] Số Dấu nhất quán giữa tất cả màn hình: chính, hồ sơ, sticker, viền, tem mẫu ✅
- [ ] Số Dấu cập nhật ngay sau mỗi lần cộng hoặc trừ (không cần reload) ✅

## Luồng thất bại & Validation

### Giới hạn kiếm Dấu
- [ ] Chia sẻ tem lần 4 trong tuần → share sheet vẫn mở nhưng không trao Dấu, hiển thị "Đã đạt giới hạn chia sẻ tuần này" 🔲
- [ ] Người nhận mở thư lần thứ 2 → người gửi không nhận thêm 15📮 🔲
- [ ] Người nhận thứ 6 cài app trong tháng → người gửi không nhận thêm 50📮 🔲
- [ ] Người nhận đã có tài khoản StampMail từ trước → người gửi không nhận 50📮 🔲

### Không đủ Dấu
- [ ] Tiêu Dấu khi số dư không đủ → hệ thống từ chối, hiển thị "Bạn cần thêm X📮 nữa" ✅
- [ ] Màn hình không đủ Dấu hiển thị đúng hai lựa chọn: "Kiếm thêm" và "Mua Dấu" ✅
- [ ] Item bị khóa không được mở khi không đủ Dấu ✅

### Lỗi giao dịch
- [ ] Thanh toán IAP thất bại → số Dấu không thay đổi, không trừ tiền, hiển thị thông báo lỗi kèm hướng dẫn liên hệ hỗ trợ 🔲
- [ ] Thoát app giữa chừng giao dịch tiêu Dấu chưa xác nhận → mở lại app: item vẫn khóa, số Dấu không bị trừ 🔲

## Trường hợp biên (Edge Cases)

### Progressive Disclosure
- [ ] Người dùng chưa từng kiếm Dấu → không thấy bất kỳ UI Dấu nào trong app ✅
- [ ] Lần đầu tiên kiếm được Dấu (từ bất kỳ nguồn nào) → màn hình giới thiệu Dấu hiện ra trước khi quay về luồng chính ✅
- [ ] Lần kiếm Dấu thứ 2 trở đi → màn hình giới thiệu không xuất hiện lại ✅
- [ ] Người dùng chưa đăng nhập → ẩn hoàn toàn: số dư, lịch sử, nút mở item bằng Dấu ✅

### Tính vĩnh viễn của item và Dấu
- [ ] Item đã mở không bị khóa lại sau khi khởi động lại app 🔲
- [ ] Item đã mở không bị khóa lại sau khi đăng xuất và đăng nhập lại ✅
- [ ] Số Dấu không giảm theo thời gian (kiểm tra sau 3 tháng không dùng app) 🚫

### Reset giới hạn
- [ ] Giới hạn chia sẻ tuần (3 lần) reset đúng vào 00:00 thứ Hai theo múi giờ thiết bị 🔲
- [ ] Giới hạn cài app tháng (5 lượt) reset đúng vào ngày 1 mỗi tháng (cùng chu kỳ SM-030) 🔲

### Ngoại lệ kiếm Dấu
- [ ] Animation thư bị gián đoạn giữa chừng → người gửi không nhận 15📮; Dấu chỉ trao khi animation hoàn tất đầy đủ 🔲
- [ ] Người gửi xóa thư sau khi đã gửi → 5📮 đã trao không bị thu hồi ✅

### Trạng thái Offline
- [ ] Mất mạng → màn hình số Dấu hiển thị giá trị từ lần đồng bộ cuối kèm nhãn "Đang xem ngoại tuyến..." 🔲
- [ ] Mất mạng → chặn tiêu Dấu (mở sticker/viền/tem mẫu), hiển thị "Không có kết nối..." 🔲
- [ ] Mất mạng → chặn mua Dấu bằng tiền, không thực hiện giao dịch IAP 🔲
- [ ] Có mạng trở lại → số Dấu được đồng bộ lại, Dấu từ Chain Unlock nhận được khi offline được cộng ngay 🔲

### Lỗi tải dữ liệu
- [ ] Lỗi server khi tải số Dấu → hiển thị skeleton hoặc icon lỗi, có nút "Thử lại", không hiển thị giá trị sai lệch 🔲

## Ghi chú tự động hóa
- ✅ Maestro automatable — Xác nhận số Dấu thay đổi trên UI sau thao tác tiêu/nhận; kiểm tra trạng thái mở khóa item; kiểm tra ẩn UI khi chưa đăng nhập; kiểm tra Progressive Disclosure; kiểm tra màn hình không đủ Dấu
- 🔲 Manual only — Thanh toán IAP (cần sandbox App Store/Google Play); sự kiện Chain Unlock (thư được mở, cài app) do phía người nhận kích hoạt; kiểm tra offline (tắt mạng thiết bị thật); reset giới hạn tuần/tháng; animation thư bị gián đoạn; thoát app giữa chừng giao dịch
- 🚫 Not automatable — Kiểm tra Dấu không hết hạn sau 3 tháng không dùng app (điều kiện thời gian thực không thể tái tạo trong test)

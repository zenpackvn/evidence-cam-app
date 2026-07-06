# Checklist QA — Thiệp nhóm (Group Card — nhiều người ký chung) (027-thiep-nhom)

## Điều kiện tiên quyết
- [ ] Có tài khoản Host đã đăng nhập vào ứng dụng StampMail
- [ ] Có ít nhất 2 tài khoản người đóng góp đã đăng nhập, mỗi tài khoản có ít nhất 1 tem trong Album
- [ ] Có 1 tài khoản người đóng góp chưa có tem trong Album (để kiểm tra trường hợp Album trống)
- [ ] Có 1 thiết bị/trình duyệt không đăng nhập (để mô phỏng người chưa có tài khoản)
- [ ] Kết nối mạng ổn định cho các luồng chính; có thể tắt mạng để kiểm tra lỗi mạng

## Luồng chính (Happy Path)

### Tạo thiệp và chia sẻ link mời
- [ ] Host tạo thiệp nhóm với tên dịp (ví dụ: "Sinh nhật An") và nhấn Tạo — thiệp được tạo thành công ✅
- [ ] Sau khi tạo, Host nhận được link mời riêng để chia sẻ vào group chat ✅

### Đóng góp của thành viên
- [ ] Người đóng góp bấm link mời → ứng dụng hiển thị màn hình đóng góp ✅
- [ ] Người đóng góp chọn tem từ Album của mình và viết lời nhắn → nhấn Xác nhận ✅
- [ ] Sau khi xác nhận đóng góp, thành viên thấy thông báo "Đã đóng góp thành công" ✅

### Chỉnh sửa đóng góp
- [ ] Người dùng đã đóng góp nhấn link mời lần nữa → hệ thống hiển thị đóng góp cũ (tem + lời nhắn) và hai nút "Chỉnh sửa đóng góp" / "Đóng"; không tạo đóng góp mới ✅
- [ ] Nhấn "Chỉnh sửa đóng góp" → đổi tem và sửa lời nhắn → xác nhận → đóng góp mới thay thế hoàn toàn đóng góp cũ, số lượng đóng góp không tăng ✅

### Đóng sổ và gửi thiệp
- [ ] Host nhấn Đóng sổ và xác nhận → trạng thái thiệp chuyển sang "Đã đóng sổ" ✅
- [ ] Sau khi đóng sổ, link mời không còn nhận đóng góp mới ✅
- [ ] Host chọn Gửi thiệp (đã đóng sổ) và chọn nền tảng MXH → link thiệp được tạo và ứng dụng MXH mở sẵn với link điền vào ✅
- [ ] Trạng thái thiệp chuyển sang "Đã gửi" sau khi Host gửi thiệp 🔲

### Người nhận mở thiệp
- [ ] Người nhận mở link thiệp → animation phong bì mở ra 🔲
- [ ] Sau animation, người nhận thấy đầy đủ tem và lời nhắn của từng người đóng góp, hiển thị riêng biệt theo từng đóng góp ✅

## Luồng thất bại & Validation

### Kiểm soát đóng góp
- [ ] Thành viên nhấn link mời sau khi Host đã đóng sổ → hệ thống thông báo thiệp đã đóng sổ, không nhận đóng góp ✅
- [ ] Người dùng đã đóng góp nhấn link mời sau khi đóng sổ → hệ thống hiển thị đóng góp cũ ở chế độ chỉ xem, có thông báo "Thiệp nhóm đã đóng sổ", không có nút "Chỉnh sửa đóng góp" ✅
- [ ] Người thứ 51 nhấn link mời khi thiệp đã đủ 50 đóng góp → hệ thống thông báo đã đủ số lượng tối đa, không nhận thêm ✅

### Phân quyền
- [ ] Người đóng góp (không phải Host) không thấy nút Đóng sổ / Gửi thiệp ✅

### Trường hợp đặc biệt khi đóng góp
- [ ] Người đóng góp không có tem trong Album → hiển thị trạng thái trống Album và gợi ý tạo tem trước ✅
- [ ] Người chưa có tài khoản bấm link mời → hệ thống chuyển đến màn hình đăng ký/đăng nhập; sau khi đăng nhập thành công quay lại đúng luồng đóng góp ✅
- [ ] Host gửi thiệp khi chưa có đóng góp nào → hệ thống hiển thị cảnh báo "Thiệp chưa có đóng góp" và hỏi xác nhận "Gửi thiệp trống?" ✅

### Lỗi mạng — người đóng góp
- [ ] Mất kết nối mạng khi người đóng góp nhấn Xác nhận → thông báo "Không có kết nối. Vui lòng thử lại khi có mạng.", đóng góp chưa được ghi nhận, nội dung tem + lời nhắn vẫn còn trên màn hình 🔲

### Lỗi mạng — Host
- [ ] Mất kết nối mạng khi Host nhấn Đóng sổ → hệ thống chặn thao tác, thông báo "Không có kết nối.", trạng thái thiệp không thay đổi 🔲
- [ ] Mất kết nối mạng khi Host nhấn Gửi thiệp → hệ thống chặn thao tác, thông báo "Không có kết nối.", trạng thái thiệp không thay đổi 🔲

## Trường hợp biên (Edge Cases)
- [ ] Thiệp nhóm có đúng 50 đóng góp: người thứ 50 đóng góp thành công, người thứ 51 bị từ chối ✅
- [ ] Người nhận mở thiệp nhóm có đúng 5 đóng góp → thấy đủ 5 tem và 5 lời nhắn riêng biệt ✅
- [ ] Host xem danh sách đóng góp ở chế độ ngoại tuyến (đã tải từ trước) → thấy dữ liệu gần nhất; nút Đóng sổ và Gửi thiệp bị vô hiệu hoá, có chú thích "Đang xem ngoại tuyến" 🔲
- [ ] Người dùng thoát app giữa chừng khi đang soạn lời nhắn chưa xác nhận → vào lại từ link mời thì nội dung không được lưu, phải soạn lại từ đầu 🔲
- [ ] Danh sách đóng góp không tải được (lỗi máy chủ / mạng chập chờn) → hiển thị màn hình lỗi có nút "Thử lại", không cần thoát màn hình 🔲
- [ ] Trạng thái thiệp nhóm chuyển đúng thứ tự: Đang soạn → Đang thu thập → Đã đóng sổ → Đã gửi (không thể đảo ngược) ✅
- [ ] Host xoá tài khoản trước khi gửi thiệp → thiệp nhóm bị huỷ sau 7 ngày chờ xoá; tài khoản và Album của người đóng góp vẫn nguyên vẹn 🚫

## Ghi chú tự động hóa
- ✅ Maestro automatable — tạo thiệp, bấm link mời, chọn tem, nhập lời nhắn, xác nhận đóng góp, xem và chỉnh sửa đóng góp, đóng sổ, kiểm tra trạng thái, kiểm tra giới hạn 50 người, kiểm tra phân quyền nút, kiểm tra Album trống, kiểm tra đăng nhập bắt buộc, kiểm tra cảnh báo gửi thiệp trống
- 🔲 Manual only — animation mở phong bì, mở ứng dụng MXH từ trong app, kiểm tra lỗi mạng thực tế (tắt Wi-Fi/data), kiểm tra chế độ ngoại tuyến Host, kiểm tra nội dung không lưu khi thoát app, kiểm tra màn hình lỗi khi server gặp sự cố
- 🚫 Not automatable — kiểm tra huỷ thiệp sau 7 ngày xoá tài khoản (phụ thuộc trạng thái server và thời gian thực)

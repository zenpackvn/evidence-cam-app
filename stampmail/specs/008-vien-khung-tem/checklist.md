# Checklist QA — Viền & Khung tem (008-vien-khung-tem)

## Điều kiện tiên quyết
- [ ] Người dùng đã đăng nhập ứng dụng StampMail
- [ ] Đã hoàn thành bước trang trí tem (SM-008) để vào được bước viền
- [ ] Có tài khoản gói Thường (Free) để kiểm thử giới hạn khóa viền
- [ ] Có tài khoản gói Premium để kiểm thử mở khóa toàn bộ viền
- [ ] Có tài khoản gói Thường với số dư ≥ 80📮 để kiểm thử mở khóa bằng Dấu
- [ ] Có tài khoản gói Thường với số dư < 80📮 để kiểm thử trường hợp thiếu Dấu (nếu cần)
- [ ] Thiết bị có thể bật/tắt kết nối mạng để kiểm thử trường hợp offline

## Luồng chính (Happy Path)

- [ ] Bước viền hiển thị đúng 7 kiểu viền: Răng cưa cổ điển, Răng tròn, Gợn sóng, Zigzag, Viền đôi, Retro bo mềm, Hoa văn nổi ✅
- [ ] Người dùng Free chọn kiểu viền "Răng cưa cổ điển" — xem trước tem cập nhật ngay, không cần xác nhận ✅
- [ ] Người dùng Free chọn kiểu viền "Răng tròn" — xem trước tem cập nhật ngay ✅
- [ ] Người dùng Free chọn kiểu viền "Gợn sóng" — xem trước tem cập nhật ngay ✅
- [ ] Chuyển đổi qua lại giữa 3 viền Free nhiều lần — xem trước luôn phản ánh lựa chọn mới nhất ✅
- [ ] Người dùng chọn màu từ bảng màu — màu viền trên xem trước thay đổi ngay, không cần xác nhận ✅
- [ ] Đổi màu viền nhiều lần liên tiếp — xem trước luôn phản ánh màu mới nhất ✅
- [ ] Người dùng Premium vào bước viền — cả 7 kiểu viền đều hiển thị không có dấu khóa ✅
- [ ] Người dùng Premium chọn kiểu viền "Zigzag" — xem trước tem cập nhật ngay ✅
- [ ] Người dùng Premium chọn kiểu viền "Viền đôi" — xem trước tem cập nhật ngay ✅
- [ ] Người dùng Premium chọn kiểu viền "Retro bo mềm" — xem trước tem cập nhật ngay ✅
- [ ] Người dùng Premium chọn kiểu viền "Hoa văn nổi" — xem trước tem cập nhật ngay ✅
- [ ] Sau khi chọn xong kiểu và màu viền, nhấn "Tiếp tục" — chuyển sang màn hình xem trước tem hoàn chỉnh (SM-010) ✅
- [ ] Người dùng có ≥ 80📮 nhấn vào viền khóa, chọn dùng Dấu và xác nhận — viền mở vĩnh viễn, Dấu giảm đúng 80📮, viền áp lên xem trước ngay ✅
- [ ] Viền đã mở khóa bằng Dấu vẫn mở khi vào bước viền của tem mới ✅

## Điều chỉnh ảnh trong khung (Happy Path)

- [ ] Kéo một ngón tay trên vùng ảnh sang bên phải — ảnh dịch chuyển sang phải, viền giữ nguyên vị trí ✅
- [ ] Kéo một ngón tay sang trái, lên, xuống — ảnh dịch chuyển tương ứng, khung và viền không thay đổi ✅
- [ ] Banh hai ngón tay trên vùng ảnh — ảnh phóng to trong khung ✅
- [ ] Chụm hai ngón tay — ảnh thu nhỏ dần; dừng tự động khi ảnh vừa phủ kín khung ✅
- [ ] Sau khi phóng to và dịch chuyển, đổi sang kiểu viền khác — ảnh tự về trung tâm, tỉ lệ vừa khung mới ✅

## Luồng thất bại & Validation

- [ ] Người dùng Free nhấn vào viền "Zigzag" — hiện đúng hai lựa chọn mở khóa, viền KHÔNG được áp lên tem ✅
- [ ] Người dùng Free nhấn vào viền "Viền đôi" — hiện đúng hai lựa chọn mở khóa, viền KHÔNG được áp lên tem ✅
- [ ] Người dùng Free nhấn vào viền "Retro bo mềm" — hiện đúng hai lựa chọn mở khóa, viền KHÔNG được áp lên tem ✅
- [ ] Người dùng Free nhấn vào viền "Hoa văn nổi" — hiện đúng hai lựa chọn mở khóa, viền KHÔNG được áp lên tem ✅
- [ ] Nhấn "Tiếp tục" mà chưa chọn kiểu viền — hệ thống tự áp viền mặc định "Răng cưa cổ điển" và chuyển bước ✅
- [ ] Người dùng chưa đăng nhập cố vào luồng tạo tem — hệ thống chuyển đến màn hình đăng nhập ✅
- [ ] Kéo ảnh đến cạnh khung — hệ thống tự dừng, không để lộ vùng trống bên trong viền ✅
- [ ] Thu nhỏ ảnh đến giới hạn vừa khung — hệ thống tự dừng, không để lộ vùng trống ✅

## Trường hợp biên (Edge Cases)

- [ ] Người dùng Free thấy 4 viền khóa có dấu hiệu bị khóa nhưng vẫn nhìn thấy được trong danh sách ✅
- [ ] Chọn màu viền rồi đổi kiểu viền — màu viền vẫn giữ nguyên trên kiểu mới ✅
- [ ] Đổi kiểu viền nhiều lần nhanh liên tiếp — xem trước không bị lỗi hiển thị hay đứng hình 🔲
- [ ] Bảng màu hiển thị đủ các màu có sẵn để chọn ✅
- [ ] Gợi ý mở khóa khi nhấn viền khóa có thể điều hướng sang luồng nâng cấp (SM-028) 🔲
- [ ] Phóng to ảnh rồi kéo nhiều hướng liên tiếp — không xuất hiện vùng trống trong khung ở bất kỳ hướng nào ✅
- [ ] Đổi kiểu viền ngay sau khi phóng to và kéo ảnh — ảnh về đúng trung tâm và tỉ lệ mặc định ✅
- [ ] Thoát ứng dụng giữa bước viền rồi mở lại — nội dung đang chỉnh bị mất, quay về màn hình chính 🚫

## Trạng thái offline

- [ ] Tắt mạng khi đang ở bước viền — chọn viền Free và đổi màu vẫn hoạt động bình thường, không báo lỗi 🔲
- [ ] Tắt mạng khi đang ở bước viền — viền đã mở khóa trước đó vẫn có thể chọn và áp bình thường 🔲
- [ ] Tắt mạng, nhấn vào viền khóa và chọn mở bằng Dấu — hệ thống chặn và hiển thị "Không có kết nối. Vui lòng thử lại khi có mạng.", Dấu không thay đổi 🔲
- [ ] Tắt mạng, nhấn vào viền khóa và chọn Nâng cấp Premium — hệ thống chặn và hiển thị "Không có kết nối. Vui lòng thử lại khi có mạng." 🔲
- [ ] Tắt mạng lần đầu vào bước viền (viền chưa tải về) — hiển thị ghi chú "Cần kết nối để tải viền mới." cho các viền chưa tải 🔲

## Lỗi máy chủ

- [ ] Danh sách viền không tải được do lỗi máy chủ — hiển thị biểu tượng lỗi, thông báo "Không thể tải viền. Vui lòng thử lại.", có nút "Thử lại" 🔲
- [ ] Thao tác mở khóa viền bằng Dấu thất bại do lỗi máy chủ — hiển thị "Mở khóa không thành công. Vui lòng thử lại.", số Dấu không bị trừ 🔲

## Ghi chú tự động hóa
- ✅ Maestro automatable — tap chọn viền, assert xem trước cập nhật, assert text hiển thị, kiểm tra trạng thái khóa/mở khóa, điều hướng giữa các bước, kiểm tra phủ khung (không vùng trống)
- 🔲 Manual only — bật/tắt mạng thiết bị thật, kiểm tra animation mượt mà khi đổi viền nhanh, điều hướng sang luồng bên ngoài (SM-028), kiểm tra lỗi máy chủ
- 🚫 Not automatable — kiểm thử mất dữ liệu khi kill process (phụ thuộc vòng đời app do hệ điều hành quản lý)

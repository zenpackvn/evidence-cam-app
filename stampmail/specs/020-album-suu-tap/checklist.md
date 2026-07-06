# Checklist QA — Album sưu tập tem (020-album-suu-tap)

## Điều kiện tiên quyết
- [ ] Người dùng đã đăng nhập thành công (SM-001)
- [ ] Có tài khoản thử nghiệm với ít nhất 1 tem tự tạo (SM-011)
- [ ] Có tài khoản thử nghiệm với ít nhất 1 tem nhận được từ thư người khác (SM-017)
- [ ] Có tài khoản thử nghiệm với tem thuộc series (để kiểm tra hiển thị thông tin series)
- [ ] Có tài khoản thử nghiệm mới hoàn toàn, chưa có bất kỳ tem nào
- [ ] Có ít nhất 2 album tùy chỉnh để kiểm tra luồng di chuyển tem giữa album
- [ ] Môi trường staging sẵn sàng cho kiểm thử lỗi mạng và pagination

## Luồng chính (Happy Path)

### Hiển thị Album
- [ ] Mở Album → hiển thị tất cả tem tự tạo và tem nhận trong cùng một danh sách (chế độ "Tất cả") ✅
- [ ] Album mới đăng ký → hiển thị trạng thái rỗng với gợi ý tạo tem đầu tiên ✅
- [ ] Chuyển sang chế độ xem lưới → nhiều tem hiển thị đồng thời, xem tổng thể ✅
- [ ] Chuyển sang chế độ xem danh sách → ít tem hơn, hiển thị thêm thông tin từng tem ✅
- [ ] Chọn bộ lọc "Tem tự tạo" → chỉ hiển thị tem do người dùng tự tạo ✅
- [ ] Chọn bộ lọc "Tem nhận được" → chỉ hiển thị tem từ thư của người khác ✅
- [ ] Chuyển đổi qua lại giữa các bộ lọc nhiều lần → kết quả luôn đúng, không bị lẫn lộn ✅

### Chi tiết tem
- [ ] Nhấn vào một tem → mở màn hình chi tiết tem ✅
- [ ] Chi tiết tem tự tạo: hiển thị ảnh lớn, ngày tạo, tên series (nếu có), không hiện tên người gửi ✅
- [ ] Chi tiết tem nhận: hiển thị ảnh lớn, ngày nhận, tên người gửi, tên series (nếu có) ✅
- [ ] Từ chi tiết tem → nhấn "Đính lên thư mới" → mở luồng soạn thư (SM-012) với tem đã chọn sẵn ✅
- [ ] Từ chi tiết tem → nhấn chia sẻ → mở luồng chia sẻ tem lên MXH (SM-025) 🔲

### Quản lý album tùy chỉnh
- [ ] Tạo album tùy chỉnh mới với tên hợp lệ (tối đa 30 ký tự) → album xuất hiện bên dưới 3 album mặc định, ban đầu rỗng ✅
- [ ] Đổi tên album tùy chỉnh → tên mới áp dụng ngay, các tem bên trong không bị ảnh hưởng ✅
- [ ] Xóa album tùy chỉnh → album biến mất; các tem bên trong vẫn còn trong "Tất cả" ✅
- [ ] Album mặc định (Tất cả / Tự tạo / Nhận được): không thể xóa hay đổi tên ✅

### Điều hướng trong album
- [ ] Nhấn vào album → mở màn hình riêng hiển thị đúng số tem của album đó ✅
- [ ] Tiêu đề màn hình trong album hiển thị tên album và số lượng tem ✅
- [ ] Album tùy chỉnh có nút "Thêm tem" và nút "Chỉnh sửa" ✅
- [ ] Album mặc định KHÔNG có nút "Thêm tem", chỉ có nút "Chỉnh sửa" ✅

### Thêm tem vào album
- [ ] Từ chi tiết tem → "Thêm vào album" → tem xuất hiện trong album đích; tem vẫn còn ở "Tất cả" ✅
- [ ] Một tem có thể thuộc nhiều album tùy chỉnh cùng lúc (không tạo bản sao) ✅
- [ ] Từ trong album tùy chỉnh → nhấn "Thêm tem" → chọn tem từ "Tất cả" → tem xuất hiện ngay trong album ✅
- [ ] Tem đã có trong album được đánh dấu riêng, không chọn thêm được (tránh trùng) ✅

### Chế độ chỉnh sửa trong album
- [ ] Nhấn "Chỉnh sửa" → mỗi tem hiển thị ô chọn; thanh hành động xuất hiện bên dưới ✅
- [ ] Nhấn "Xong" → thoát chế độ chỉnh sửa, ô chọn biến mất ✅
- [ ] Chọn nhiều tem cùng lúc trong chế độ chỉnh sửa ✅

### Xóa và di chuyển tem
- [ ] Trong album tùy chỉnh (chế độ chỉnh sửa): chọn tem → "Xóa khỏi album" → tem biến mất khỏi album này, không cần xác nhận, không mất ở "Tất cả" ✅
- [ ] Trong chế độ chỉnh sửa: chọn tem tự tạo → "Xóa vĩnh viễn" → hiện hộp xác nhận → xác nhận → tem mất khỏi mọi nơi, không hoàn tác được ✅
- [ ] Trong chế độ chỉnh sửa: chọn tem tự tạo → "Xóa vĩnh viễn" → nhấn Hủy → không có gì thay đổi ✅
- [ ] Tem nhận từ người khác: KHÔNG có tùy chọn "Xóa vĩnh viễn" trong thanh hành động ✅
- [ ] Trong album tùy chỉnh (chế độ chỉnh sửa): "Di chuyển sang" → chọn album đích → tem xuất hiện ở album đích, biến mất khỏi album nguồn; vẫn còn trong "Tất cả" ✅

### Đổi tên tem
- [ ] Từ màn hình chi tiết tem → nhấn vào tên tem → nhập tên mới → xác nhận → tên cập nhật ngay trên chi tiết và trong danh sách album ✅
- [ ] Tên tem mặc định khi mới tạo là ngày tạo tem ✅

## Luồng thất bại & Validation

### Giới hạn ký tự
- [ ] Tên album tùy chỉnh quá 30 ký tự → hệ thống từ chối hoặc cắt bớt tại 30 ký tự ✅
- [ ] Tên tem quá 30 ký tự → hệ thống từ chối hoặc cắt bớt tại 30 ký tự ✅

### Bảo vệ dữ liệu
- [ ] Album mặc định không có tùy chọn đổi tên hoặc xóa ✅
- [ ] Xóa album tùy chỉnh không xóa các tem bên trong ✅
- [ ] Xóa vĩnh viễn tem luôn yêu cầu bước xác nhận trước khi thực hiện ✅

### Trạng thái offline
- [ ] Mất kết nối mạng → Album vẫn hiển thị các tem đã tải trước đó, không bị trắng màn hình 🔲
- [ ] Mất kết nối mạng → xuất hiện thông báo "Đang xem ngoại tuyến" ở vị trí dễ thấy 🔲
- [ ] Offline: nhấn "Thêm vào album" → không thực hiện, hiện thông báo yêu cầu kết nối lại 🔲
- [ ] Offline: nhấn "Tạo album mới" → không thực hiện, hiện thông báo yêu cầu kết nối lại 🔲
- [ ] Offline: thử đổi tên album → không thực hiện, hiện thông báo yêu cầu kết nối lại 🔲
- [ ] Offline: thử xóa album → không thực hiện, hiện thông báo yêu cầu kết nối lại 🔲

### Lỗi mạng / lỗi máy chủ
- [ ] Lỗi tải Album → hiển thị trạng thái lỗi với thông báo ngắn gọn và nút "Thử lại" 🔲
- [ ] Nhấn "Thử lại" → tải lại danh sách mà không mất bộ lọc hay vị trí đang xem 🔲
- [ ] Một số tem tải lỗi → phần tải được hiển thị bình thường; phần lỗi hiển thị ký hiệu lỗi thay vì ảnh 🔲

### Truy cập chưa đăng nhập
- [ ] Người dùng chưa đăng nhập vào Album → chuyển ngay về màn hình đăng nhập, không xem được Album khách ✅

## Trường hợp biên (Edge Cases)

- [ ] Tem không thuộc series nào → trường series ẩn hoặc không hiển thị ở màn hình chi tiết ✅
- [ ] Tem nhận được không có tên người gửi → trường tên người gửi ẩn hoặc hiển thị giá trị mặc định ✅
- [ ] Album tùy chỉnh rỗng (không có tem) → hiển thị trạng thái rỗng rõ ràng ✅
- [ ] Xóa album tùy chỉnh duy nhất → hệ thống không bị lỗi; album "Tất cả" vẫn bình thường ✅
- [ ] Offline: tem chưa từng tải về → không hiển thị hoặc hiển thị ký hiệu "chưa tải được", không crash ✅
- [ ] Album có hàng trăm tem → hệ thống tải từng trang (pagination), không bị chậm hoặc treo 🚫
- [ ] Thoát app giữa chừng khi đang tổ chức album → mở lại app: dữ liệu album vẫn đúng, không mất 🔲
- [ ] Chuyển đổi nhiều lần giữa lưới và danh sách → số lượng tem không thay đổi ✅
- [ ] Di chuyển tem sang album đích là album đang xem → tem biến mất khỏi album nguồn, vẫn ở "Tất cả" ✅

## Ghi chú tự động hóa
- ✅ Maestro automatable — tap, nhập text, scroll, kiểm tra text/id: áp dụng cho hầu hết luồng chính, validation ký tự, điều hướng, và trạng thái UI
- 🔲 Manual only — chia sẻ lên MXH (mở app bên ngoài), kiểm tra offline (cần thao tác thiết bị thực: bật/tắt mạng), lỗi mạng/server, thoát app đột ngột
- 🚫 Không thể tự động hóa — pagination với hàng trăm tem thực tế (cần dữ liệu quy mô lớn trong staging)

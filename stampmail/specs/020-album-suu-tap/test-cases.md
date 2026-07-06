# Test Cases — Album sưu tập tem (020-album-suu-tap)

## TC-20-001: Album hiển thị đủ cả hai loại tem ở chế độ "Tất cả"

**AC liên quan:** AC-01
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập với tài khoản có ít nhất 1 tem tự tạo (từ SM-011) và ít nhất 1 tem nhận được từ thư người khác (từ SM-017)
- Đảm bảo đang ở bộ lọc Album "Tất cả"

### Act (Thực hiện)
- Mở màn hình Album

### Assert (Kiểm tra)
- Danh sách tem hiển thị cả tem tự tạo lẫn tem nhận được trong cùng một màn hình
- Tổng số tem hiển thị khớp với tổng số tem người dùng sở hữu (tự tạo + nhận)

---

## TC-20-002: Lọc chỉ hiển thị tem nhận được

**AC liên quan:** AC-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập với tài khoản có cả tem tự tạo và tem nhận được từ thư của người khác
- Mở màn hình Album ở chế độ "Tất cả"

### Act (Thực hiện)
- Nhấn vào bộ lọc "Tem nhận được"

### Assert (Kiểm tra)
- Danh sách chỉ hiển thị các tem nhận được từ thư của người khác
- Không có tem tự tạo nào xuất hiện trong danh sách
- Số lượng tem khớp với số tem nhận thực tế của tài khoản

---

## TC-20-003: Lọc chỉ hiển thị tem tự tạo

**AC liên quan:** BR-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập với tài khoản có cả tem tự tạo và tem nhận được
- Mở màn hình Album ở chế độ "Tất cả"

### Act (Thực hiện)
- Nhấn vào bộ lọc "Tem tự tạo"

### Assert (Kiểm tra)
- Danh sách chỉ hiển thị các tem do người dùng tự tạo
- Không có tem nhận được nào xuất hiện trong danh sách
- Số lượng tem khớp với số tem tự tạo thực tế của tài khoản

---

## TC-20-004: Đính tem lên thư mới từ màn hình chi tiết tem

**AC liên quan:** AC-04
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập với tài khoản có ít nhất một tem trong Album
- Mở Album và nhấn vào một tem để vào màn hình chi tiết

### Act (Thực hiện)
- Tại màn hình chi tiết tem, nhấn nút "Đính lên thư mới"

### Assert (Kiểm tra)
- Ứng dụng chuyển sang luồng soạn thư (SM-012)
- Tem vừa chọn đã được chọn sẵn ở bước đính tem, không cần chọn lại
- Người dùng có thể tiếp tục soạn thư bình thường với tem đó

---

## TC-20-005: Album rỗng khi người dùng chưa có tem nào

**AC liên quan:** AC-05
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập với tài khoản mới đăng ký, chưa tạo hoặc nhận bất kỳ tem nào

### Act (Thực hiện)
- Mở màn hình Album

### Assert (Kiểm tra)
- Màn hình hiển thị trạng thái rỗng (empty state) — không có danh sách tem
- Hiển thị gợi ý hoặc nút kêu gọi hành động để người dùng tạo tem đầu tiên
- Không có lỗi hoặc màn hình trắng

---

## TC-20-006: Tạo album tùy chỉnh mới

**AC liên quan:** AC-06
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang ở màn hình Album sưu tập tem

### Act (Thực hiện)
- Nhấn "Tạo album mới"
- Nhập tên "Bạn bè thân thiết" (17 ký tự)
- Xác nhận tạo

### Assert (Kiểm tra)
- Album "Bạn bè thân thiết" xuất hiện trong danh sách bên dưới các album mặc định
- Album mới ban đầu rỗng (chưa có tem)

---

## TC-20-007: Tên album tùy chỉnh quá 30 ký tự bị từ chối

**AC liên quan:** AC-06, BR-06
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang thực hiện tạo album mới

### Act (Thực hiện)
- Nhập tên album gồm 31 ký tự
- Nhấn xác nhận

### Assert (Kiểm tra)
- Hệ thống từ chối hoặc tự cắt bớt tên tại giới hạn 30 ký tự
- Không tạo album với tên vượt quá 30 ký tự
- Có thông báo hoặc phản hồi cho người dùng biết giới hạn ký tự

---

## TC-20-008: Thêm tem vào album tùy chỉnh từ màn hình chi tiết tem

**AC liên quan:** AC-07
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng có ít nhất một album tùy chỉnh (ví dụ: "Gia đình")
- Đang xem màn hình chi tiết của một tem

### Act (Thực hiện)
- Nhấn "Thêm vào album"
- Chọn album "Gia đình"
- Xác nhận

### Assert (Kiểm tra)
- Tem xuất hiện trong album "Gia đình"
- Tem vẫn còn trong album "Tất cả" và các album cũ (không bị xóa khỏi nơi cũ)

---

## TC-20-009: Một tem thuộc nhiều album tùy chỉnh cùng lúc

**AC liên quan:** AC-07, BR-07
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Có 2 album tùy chỉnh: "Gia đình" và "Kỷ niệm"

### Act (Thực hiện)
- Thêm cùng một tem vào album "Gia đình"
- Thêm cùng tem đó vào album "Kỷ niệm"

### Assert (Kiểm tra)
- Tem xuất hiện trong cả album "Gia đình" lẫn "Kỷ niệm"
- Tổng số tem trong hệ thống không tăng (không tạo bản sao)
- Tem vẫn còn trong "Tất cả"

---

## TC-20-010: Xóa album tùy chỉnh — tem bên trong không bị xóa

**AC liên quan:** AC-08
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Album tùy chỉnh "Yêu thích" có 3 tem
- Cả 3 tem đều có mặt trong album "Tất cả"

### Act (Thực hiện)
- Xóa album "Yêu thích"

### Assert (Kiểm tra)
- Album "Yêu thích" biến mất khỏi danh sách album
- Ba tem đó vẫn còn trong tab "Tất cả" (không bị xóa theo album)

---

## TC-20-011: Không thể xóa hoặc đổi tên album mặc định

**AC liên quan:** AC-09, BR-10
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang ở màn hình Album, có thể thấy 3 album mặc định: Tất cả, Tự tạo, Nhận được

### Act (Thực hiện)
- Nhấn giữ hoặc mở tùy chọn cho album "Tự tạo"
- Lặp lại với album "Tất cả" và "Nhận được"

### Assert (Kiểm tra)
- Không có tùy chọn "Đổi tên" hay "Xóa" trên bất kỳ album mặc định nào
- Chỉ có thể xem nội dung album mặc định

---

## TC-20-012: Xem Album khi đang mất kết nối mạng (offline)

**AC liên quan:** AC-10, BR-11
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập với tài khoản có tem trong Album
- Mở Album khi đang có mạng để các tem được tải về
- Đóng màn hình Album

### Act (Thực hiện)
- Tắt kết nối mạng (bật chế độ máy bay hoặc tắt WiFi/data)
- Mở lại màn hình Album

### Assert (Kiểm tra)
- Album vẫn hiển thị các tem đã tải trước đó — không bị màn hình trắng hoặc lỗi
- Có thông báo "Đang xem ngoại tuyến" xuất hiện ở vị trí dễ thấy
- Người dùng vẫn xem được chi tiết các tem đã tải trước đó

---

## TC-20-013: Hành động ghi bị chặn khi mất mạng

**AC liên quan:** AC-11, BR-12
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đang xem chi tiết một tem, trạng thái đang mất mạng

### Act (Thực hiện)
- Nhấn "Thêm vào album" hoặc "Tạo album mới"

### Assert (Kiểm tra)
- Hành động không được thực hiện
- Xuất hiện thông báo yêu cầu kết nối lại mạng
- Nút hoặc tùy chọn tương ứng không phản hồi như thường lệ

---

## TC-20-014: Nhấn vào album — mở màn hình riêng của album đó

**AC liên quan:** AC-12, BR-13
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Có album tùy chỉnh "Kỷ niệm" chứa đúng 5 tem

### Act (Thực hiện)
- Nhấn vào album "Kỷ niệm"

### Assert (Kiểm tra)
- Mở màn hình riêng hiển thị đúng 5 tem của album "Kỷ niệm"
- Tiêu đề màn hình hiển thị tên "Kỷ niệm"
- Có nút "Thêm tem" và nút "Chỉnh sửa" trên màn hình này

---

## TC-20-015: Thêm tem vào album từ bên trong album

**AC liên quan:** AC-13, BR-14
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang ở trong album tùy chỉnh "Kỷ niệm" (đang có ít nhất 1 tem)
- Có ít nhất 2 tem chưa thuộc album "Kỷ niệm" ở "Tất cả"

### Act (Thực hiện)
- Nhấn "Thêm tem"
- Chọn 2 tem từ danh sách "Tất cả"
- Nhấn Xác nhận

### Assert (Kiểm tra)
- Hai tem đó xuất hiện ngay trong album "Kỷ niệm"
- Tem nào đã có sẵn trong album được đánh dấu riêng và không thể chọn thêm (tránh trùng)

---

## TC-20-016: Bật chế độ chỉnh sửa trong album tùy chỉnh

**AC liên quan:** AC-14, BR-15
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang ở trong một album tùy chỉnh có ít nhất 2 tem

### Act (Thực hiện)
- Nhấn nút "Chỉnh sửa"

### Assert (Kiểm tra)
- Mỗi tem hiển thị ô chọn (checkbox hoặc dấu tick)
- Thanh hành động xuất hiện bên dưới với các tùy chọn: "Xóa khỏi album", "Xóa vĩnh viễn", "Di chuyển sang"
- Nhấn "Xong" → thoát chế độ chỉnh sửa, các ô chọn biến mất

---

## TC-20-017: Xóa tem khỏi album tùy chỉnh (không mất tem)

**AC liên quan:** AC-15, BR-16
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang ở chế độ chỉnh sửa trong album tùy chỉnh "Kỷ niệm"
- Đã chọn 2 tem trong album

### Act (Thực hiện)
- Nhấn "Xóa khỏi album"

### Assert (Kiểm tra)
- Hai tem biến mất khỏi album "Kỷ niệm" ngay lập tức, không hiện hộp thoại xác nhận
- Hai tem vẫn còn trong album "Tất cả" (không bị xóa vĩnh viễn)
- Nếu tem đó còn thuộc album tùy chỉnh khác, nó vẫn còn ở đó

---

## TC-20-018: Xóa tem vĩnh viễn — bắt buộc xác nhận

**AC liên quan:** AC-16, BR-17
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang ở chế độ chỉnh sửa và đã chọn một tem tự tạo

### Act (Thực hiện)
- Nhấn "Xóa vĩnh viễn"

### Assert (Kiểm tra)
- Hệ thống hiển thị hộp thoại xác nhận trước khi xóa
- Khi nhấn Xác nhận: tem bị xóa khỏi "Tất cả" và mọi album tùy chỉnh — không thể hoàn tác
- Khi nhấn Hủy: không có gì thay đổi, tem vẫn còn nguyên

---

## TC-20-019: Tem nhận từ người khác không có tùy chọn xóa vĩnh viễn

**AC liên quan:** AC-17, BR-17
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang ở chế độ chỉnh sửa trong một album tùy chỉnh
- Chọn một tem nhận được từ người khác

### Act (Thực hiện)
- Xem thanh hành động bên dưới sau khi chọn tem nhận

### Assert (Kiểm tra)
- Tùy chọn "Xóa vĩnh viễn" không xuất hiện trên thanh hành động
- Chỉ có "Xóa khỏi album" (vì đang trong album tùy chỉnh) và "Di chuyển sang"

---

## TC-20-020: Di chuyển tem sang album tùy chỉnh khác

**AC liên quan:** AC-18, BR-19
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Có hai album tùy chỉnh: "Mùa hè" và "Kỷ niệm"
- Người dùng đang ở chế độ chỉnh sửa trong album "Mùa hè" và đã chọn một tem

### Act (Thực hiện)
- Nhấn "Di chuyển sang"
- Chọn album "Kỷ niệm" làm album đích
- Xác nhận

### Assert (Kiểm tra)
- Tem xuất hiện trong album "Kỷ niệm"
- Tem biến mất khỏi album "Mùa hè"
- Tem vẫn còn trong album "Tất cả"

---

## TC-20-021: Đổi tên tem từ màn hình chi tiết tem

**AC liên quan:** AC-19, BR-18
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng nhấn vào một tem trong album, đã vào màn hình chi tiết tem

### Act (Thực hiện)
- Nhấn vào tên tem
- Nhập tên mới (hợp lệ, tối đa 30 ký tự)
- Xác nhận

### Assert (Kiểm tra)
- Tên tem cập nhật ngay trên màn hình chi tiết
- Khi quay lại danh sách album, tên mới cũng hiển thị đúng

---

## TC-20-022: Tên tem quá 30 ký tự bị từ chối

**AC liên quan:** BR-18
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang đổi tên tem trên màn hình chi tiết

### Act (Thực hiện)
- Nhập tên mới gồm 31 ký tự
- Nhấn xác nhận

### Assert (Kiểm tra)
- Hệ thống từ chối hoặc tự cắt bớt tên tại giới hạn 30 ký tự
- Có phản hồi rõ ràng cho người dùng về giới hạn ký tự

---

## TC-20-023: Album mặc định không có nút "Thêm tem"

**AC liên quan:** AC-20, BR-20
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng nhấn vào album mặc định "Tự tạo"

### Act (Thực hiện)
- Quan sát màn hình bên trong album "Tự tạo"

### Assert (Kiểm tra)
- Không có nút "Thêm tem" trên màn hình
- Chỉ có nút "Chỉnh sửa"
- Khi vào chế độ chỉnh sửa: chỉ có tùy chọn "Xóa vĩnh viễn" (cho tem tự tạo), không có "Xóa khỏi album" hay "Di chuyển sang"

---

## TC-20-024: Chuyển đổi chế độ xem lưới và danh sách

**AC liên quan:** BR-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập với tài khoản có ít nhất 5 tem trong Album
- Mở màn hình Album

### Act (Thực hiện)
- Nhấn nút chuyển sang chế độ xem lưới
- Quan sát màn hình
- Nhấn nút chuyển sang chế độ xem danh sách
- Quan sát màn hình

### Assert (Kiểm tra)
- Chế độ lưới: nhiều tem hiển thị trên mỗi hàng, xem tổng thể được nhiều tem hơn
- Chế độ danh sách: ít tem hơn trên mỗi hàng, hiển thị thêm thông tin cho từng tem
- Không có tem nào bị mất khi chuyển đổi chế độ xem

---

## TC-20-025: Xem chi tiết tem tự tạo — thông tin đầy đủ

**AC liên quan:** BR-04
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập với tài khoản có tem tự tạo thuộc một series
- Mở Album, ở chế độ "Tất cả"

### Act (Thực hiện)
- Nhấn vào một tem tự tạo thuộc series

### Assert (Kiểm tra)
- Màn hình chi tiết tem mở ra
- Ảnh tem hiển thị kích thước lớn
- Hiển thị ngày tạo tem
- Hiển thị tên series mà tem thuộc về
- Không hiển thị trường "Tên người gửi" (vì là tem tự tạo)

---

## TC-20-026: Xem chi tiết tem nhận — hiển thị tên người gửi

**AC liên quan:** BR-04
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập với tài khoản đã nhận tem từ thư của người khác
- Mở Album, chọn bộ lọc "Tem nhận được"

### Act (Thực hiện)
- Nhấn vào một tem nhận được

### Assert (Kiểm tra)
- Màn hình chi tiết tem mở ra
- Ảnh tem hiển thị kích thước lớn
- Hiển thị ngày nhận tem
- Hiển thị tên người gửi tem
- Nếu tem thuộc series, hiển thị tên series

---

## TC-20-027: Chia sẻ tem lên mạng xã hội từ màn hình chi tiết

**AC liên quan:** BR-05
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập với tài khoản có ít nhất một tem trong Album
- Mở Album và nhấn vào một tem để vào màn hình chi tiết

### Act (Thực hiện)
- Tại màn hình chi tiết tem, nhấn nút chia sẻ

### Assert (Kiểm tra)
- Ứng dụng mở luồng chia sẻ lên mạng xã hội (SM-025)
- Người dùng có thể chọn kênh chia sẻ
- Tem được đính kèm đúng vào nội dung chia sẻ

---

## TC-20-028: Đổi tên album tùy chỉnh — áp dụng ngay lập tức

**AC liên quan:** BR-09
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Có album tùy chỉnh tên "Album cũ"

### Act (Thực hiện)
- Chọn tùy chọn đổi tên album "Album cũ"
- Nhập tên mới "Album mới"
- Xác nhận

### Assert (Kiểm tra)
- Album hiển thị tên "Album mới" ngay trong danh sách
- Tem trong album không bị ảnh hưởng

---

## TC-20-029: Tải lại danh sách khi gặp lỗi mạng / lỗi máy chủ

**AC liên quan:** Mục 5 — Ngoại lệ lỗi mạng
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Mô phỏng trạng thái lỗi mạng hoặc máy chủ không phản hồi (dùng môi trường staging)

### Act (Thực hiện)
- Mở màn hình Album khi đang gặp lỗi
- Nhấn nút "Thử lại" khi thấy thông báo lỗi

### Assert (Kiểm tra)
- Màn hình Album hiển thị trạng thái lỗi với thông báo ngắn gọn và nút "Thử lại"
- Sau khi nhấn "Thử lại": danh sách tem được tải lại mà không mất bộ lọc hay vị trí đang xem
- Nếu một số tem tải được, phần đó hiển thị bình thường; phần lỗi hiển thị ký hiệu lỗi thay vì ảnh tem

---

## TC-20-030: Album tải từng trang khi có rất nhiều tem

**AC liên quan:** Mục 5 — Ngoại lệ pagination
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Chuẩn bị tài khoản thử nghiệm với hàng trăm tem (dùng môi trường staging có dữ liệu lớn)

### Act (Thực hiện)
- Đăng nhập và mở màn hình Album
- Cuộn xuống cuối danh sách

### Assert (Kiểm tra)
- Màn hình Album mở nhanh, không bị đứng hoặc chậm khi tải lần đầu
- Khi cuộn gần hết danh sách, hệ thống tự động tải thêm tem (pagination)
- Không có hiện tượng lag hoặc treo ứng dụng trong suốt quá trình cuộn

---

## TC-20-031: Người dùng chưa đăng nhập truy cập Album bị chuyển về đăng nhập

**AC liên quan:** Mục 5 — Ngoại lệ chưa đăng nhập
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng chưa đăng nhập (hoặc đã đăng xuất)

### Act (Thực hiện)
- Truy cập vào màn hình Album

### Assert (Kiểm tra)
- Ứng dụng chuyển ngay về màn hình đăng nhập
- Không hiển thị nội dung Album ở chế độ khách

---

## TC-20-032: Thoát app giữa chừng không mất dữ liệu album

**AC liên quan:** Mục 5 — Ngoại lệ thoát app
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đang ở trong màn hình Album đang tổ chức album tùy chỉnh

### Act (Thực hiện)
- Thoát ứng dụng đột ngột (swipe away)
- Mở lại ứng dụng

### Assert (Kiểm tra)
- Album hiển thị đúng trạng thái đã lưu (album tùy chỉnh, tên album vẫn còn nguyên)
- Không có dữ liệu bị mất

---

## TC-20-033: Đổi tên album tùy chỉnh quá 30 ký tự bị từ chối

**AC liên quan:** BR-09
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang thực hiện đổi tên một album tùy chỉnh

### Act (Thực hiện)
- Nhập tên mới gồm 31 ký tự
- Nhấn xác nhận

### Assert (Kiểm tra)
- Hệ thống từ chối hoặc cắt bớt tên tại 30 ký tự
- Tên album cũ vẫn được giữ nguyên nếu người dùng hủy hoặc nhập sai

---

## TC-20-034: Đổi tên album — thao tác đổi tên bị chặn khi offline

**AC liên quan:** BR-12
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đang ở trạng thái mất mạng
- Đang ở màn hình danh sách album

### Act (Thực hiện)
- Thử thao tác đổi tên album tùy chỉnh

### Assert (Kiểm tra)
- Thao tác không thực hiện được
- Hiển thị thông báo yêu cầu kết nối lại mạng

---

## TC-20-035: Xóa album tùy chỉnh bị chặn khi offline

**AC liên quan:** BR-12
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đang ở trạng thái mất mạng
- Có ít nhất một album tùy chỉnh trong danh sách

### Act (Thực hiện)
- Thử xóa album tùy chỉnh

### Assert (Kiểm tra)
- Thao tác không thực hiện được
- Hiển thị thông báo yêu cầu kết nối lại mạng

---

## TC-20-036: Tạo album mới bị chặn khi offline

**AC liên quan:** BR-12
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đang ở trạng thái mất mạng
- Đang ở màn hình Album

### Act (Thực hiện)
- Thử tạo album tùy chỉnh mới

### Assert (Kiểm tra)
- Thao tác không thực hiện được
- Hiển thị thông báo yêu cầu kết nối lại mạng

---

## TC-20-037: Tem chưa từng tải về không hiển thị khi offline

**AC liên quan:** Mục 5 — Ngoại lệ offline
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập, nhưng chưa mở Album (hoặc chưa cuộn tới một số tem mới)
- Mất kết nối mạng

### Act (Thực hiện)
- Mở Album và xem danh sách

### Assert (Kiểm tra)
- Các tem chưa từng tải về không hiển thị hoặc hiển thị ký hiệu "chưa tải được"
- Không bị lỗi crash ứng dụng
- Các tem đã tải trước đó vẫn hiển thị bình thường

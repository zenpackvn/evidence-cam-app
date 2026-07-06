# Test Cases — Thiệp nhóm (Group Card — nhiều người ký chung) (027-thiep-nhom)

## TC-27-001: Host tạo thiệp nhóm thành công

**AC liên quan:** AC-01
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào ứng dụng StampMail với tư cách Host

### Act (Thực hiện)
- Điều hướng đến chức năng tạo thiệp nhóm
- Nhập tên dịp: "Sinh nhật An"
- Nhấn nút Tạo

### Assert (Kiểm tra)
- Thiệp nhóm được tạo thành công với tên "Sinh nhật An"
- Host nhìn thấy link mời riêng để chia sẻ vào group chat
- Thiệp nhóm xuất hiện trong danh sách thiệp của Host với trạng thái "Đang thu thập"

---

## TC-27-002: Người đóng góp thêm tem và lời nhắn thành công

**AC liên quan:** AC-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Thiệp nhóm "Sinh nhật An" đã được tạo bởi Host và đang ở trạng thái "Đang thu thập"
- Người đóng góp đã đăng nhập, có ít nhất 1 tem trong Album
- Người đóng góp đã nhận được link mời từ Host

### Act (Thực hiện)
- Người đóng góp bấm link mời
- Chọn 1 tem từ Album cá nhân
- Viết lời nhắn: "Chúc mừng sinh nhật nhé!"
- Nhấn Xác nhận đóng góp

### Assert (Kiểm tra)
- Hệ thống hiển thị thông báo "Đã đóng góp thành công"
- Đóng góp của thành viên được ghi nhận vào thiệp nhóm
- Số lượng đóng góp trong thiệp tăng lên 1

---

## TC-27-003: Nhấn link mời lần hai thấy đóng góp cũ và có thể chỉnh sửa

**AC liên quan:** AC-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Thiệp nhóm đang ở trạng thái "Đang thu thập"
- Người dùng đã đóng góp 1 lần thành công vào thiệp nhóm này (đã chọn tem A và viết lời nhắn "X")

### Act (Thực hiện)
- Người dùng nhấn link mời lần nữa

### Assert (Kiểm tra)
- Hệ thống hiển thị đóng góp cũ: tem đã chọn và lời nhắn đã viết trước đó
- Màn hình có nút "Chỉnh sửa đóng góp" và nút "Đóng"
- Hệ thống không tạo đóng góp mới; số lượng đóng góp trong thiệp không thay đổi

---

## TC-27-004: Chỉnh sửa đóng góp trước khi đóng sổ — đóng góp mới thay thế cũ

**AC liên quan:** AC-03b
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Thiệp nhóm đang ở trạng thái "Đang thu thập"
- Người dùng đã đóng góp 1 lần với tem A và lời nhắn "Lời nhắn cũ"
- Người dùng đang xem đóng góp cũ sau khi nhấn link lần hai

### Act (Thực hiện)
- Nhấn "Chỉnh sửa đóng góp"
- Chọn tem khác (tem B thay vì tem A)
- Sửa lời nhắn thành "Lời nhắn mới"
- Nhấn Xác nhận

### Assert (Kiểm tra)
- Hệ thống hiển thị xác nhận chỉnh sửa thành công
- Đóng góp trong thiệp nhóm chỉ ghi nhận đóng góp mới nhất (tem B + "Lời nhắn mới")
- Đóng góp cũ (tem A + "Lời nhắn cũ") không còn tồn tại trong thiệp
- Số lượng đóng góp vẫn là 1, không tăng lên 2

---

## TC-27-005: Không cho sửa đóng góp sau khi đóng sổ

**AC liên quan:** AC-03c
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đóng góp vào thiệp nhóm
- Host đã đóng sổ thiệp nhóm (trạng thái "Đã đóng sổ")

### Act (Thực hiện)
- Người dùng nhấn link mời lần nữa

### Assert (Kiểm tra)
- Hệ thống hiển thị đóng góp cũ ở chế độ chỉ xem (không thể chỉnh sửa)
- Không có nút "Chỉnh sửa đóng góp"
- Có thông báo "Thiệp nhóm đã đóng sổ"

---

## TC-27-006: Đóng sổ ngăn đóng góp mới từ người chưa đóng góp

**AC liên quan:** AC-04
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Thiệp nhóm đã được Host đóng sổ (trạng thái "Đã đóng sổ")
- Thành viên chưa đóng góp lần nào vào thiệp nhóm này

### Act (Thực hiện)
- Thành viên nhấn link mời

### Assert (Kiểm tra)
- Hệ thống hiển thị thông báo thiệp đã đóng sổ, không còn nhận đóng góp
- Thành viên không thể chọn tem hay viết lời nhắn

---

## TC-27-007: Người nhận thấy đủ tất cả đóng góp sau animation

**AC liên quan:** AC-05
**Loại:** E2E
**Tự động hóa:** ✅ Maestro (nội dung) / 🔲 Manual (animation)

### Arrange (Chuẩn bị)
- Thiệp nhóm có đúng 5 đóng góp từ 5 người khác nhau, mỗi đóng góp kèm 1 tem và 1 lời nhắn riêng
- Host đã gửi thiệp và người nhận có link thiệp

### Act (Thực hiện)
- Người nhận mở link thiệp

### Assert (Kiểm tra)
- Animation mở phong bì hiển thị
- Sau animation, người nhận thấy đủ 5 tem và 5 lời nhắn
- Mỗi lời nhắn hiển thị riêng biệt tương ứng với từng người đóng góp

---

## TC-27-008: Từ chối đóng góp khi đã đủ 50 người

**AC liên quan:** AC-06
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Thiệp nhóm đang ở trạng thái "Đang thu thập"
- Đã có đúng 50 đóng góp trong thiệp

### Act (Thực hiện)
- Người dùng thứ 51 nhấn link mời

### Assert (Kiểm tra)
- Hệ thống hiển thị thông báo "Đã đủ số lượng đóng góp tối đa" (hoặc tương đương)
- Người dùng thứ 51 không thể chọn tem hay viết lời nhắn
- Số lượng đóng góp trong thiệp vẫn giữ nguyên 50

---

## TC-27-009: Chỉ Host mới thấy và dùng được nút Đóng sổ / Gửi thiệp

**AC liên quan:** AC-07
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Thiệp nhóm đang ở trạng thái "Đang thu thập"
- Người đóng góp (không phải Host) đã đăng nhập và đã đóng góp vào thiệp nhóm

### Act (Thực hiện)
- Người đóng góp xem thông tin thiệp nhóm
- Người đóng góp tìm nút Đóng sổ hoặc Gửi thiệp

### Assert (Kiểm tra)
- Màn hình của người đóng góp không hiển thị nút "Đóng sổ"
- Màn hình của người đóng góp không hiển thị nút "Gửi thiệp"
- Chỉ tài khoản Host mới thấy và thao tác được hai nút trên

---

## TC-27-010: Host đóng sổ và trạng thái thiệp chuyển sang Đã đóng sổ

**AC liên quan:** AC-08
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Thiệp nhóm đang ở trạng thái "Đang thu thập" với ít nhất 1 đóng góp
- Host đã đăng nhập

### Act (Thực hiện)
- Host nhấn nút Đóng sổ
- Xác nhận hành động trong hộp thoại xác nhận

### Assert (Kiểm tra)
- Trạng thái thiệp chuyển sang "Đã đóng sổ"
- Link mời hiển thị thông báo không còn nhận đóng góp khi có người truy cập
- Nút Gửi thiệp xuất hiện để Host có thể gửi thiệp cho người nhận

---

## TC-27-011: Host gửi thiệp sau khi đóng sổ và trạng thái chuyển sang Đã gửi

**AC liên quan:** AC-09
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Thiệp nhóm đang ở trạng thái "Đã đóng sổ" với ít nhất 1 đóng góp
- Host đã đăng nhập

### Act (Thực hiện)
- Host nhấn nút Gửi thiệp
- Chọn nền tảng MXH (ví dụ: Zalo, Facebook Messenger)

### Assert (Kiểm tra)
- Link thiệp được tạo thành công
- Ứng dụng MXH được chọn mở ra với link thiệp đã điền sẵn vào ô soạn tin
- Trạng thái thiệp trong ứng dụng StampMail chuyển sang "Đã gửi"

---

## TC-27-012: Người nhận thấy animation và đủ đóng góp khi mở thiệp

**AC liên quan:** AC-10
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Thiệp nhóm đã được gửi với đúng 3 đóng góp từ 3 người khác nhau
- Người nhận có link thiệp, có thể chưa có tài khoản StampMail

### Act (Thực hiện)
- Người nhận mở link thiệp

### Assert (Kiểm tra)
- Animation phong bì mở ra hiển thị đúng
- Sau animation, người nhận thấy đủ 3 tem kèm 3 lời nhắn
- Mỗi tem và lời nhắn hiển thị riêng biệt theo từng người đóng góp, không bị gộp chung

---

## TC-27-013: Mất mạng khi người đóng góp xác nhận đóng góp

**AC liên quan:** AC-11
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Thiệp nhóm đang ở trạng thái "Đang thu thập"
- Người đóng góp đã đăng nhập, đã chọn tem và viết lời nhắn
- Chuẩn bị tắt kết nối mạng ngay trước khi nhấn Xác nhận

### Act (Thực hiện)
- Tắt kết nối mạng (tắt Wi-Fi / dữ liệu di động)
- Người đóng góp nhấn Xác nhận đóng góp

### Assert (Kiểm tra)
- Hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."
- Đóng góp chưa được ghi nhận (số lượng đóng góp trong thiệp không thay đổi)
- Nội dung tem đã chọn và lời nhắn đã viết vẫn còn hiển thị trên màn hình để người dùng thử lại

---

## TC-27-014: Mất mạng khi Host đóng sổ thiệp nhóm

**AC liên quan:** AC-12
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Thiệp nhóm đang ở trạng thái "Đang thu thập"
- Host đã đăng nhập
- Chuẩn bị tắt kết nối mạng trước khi Host nhấn Đóng sổ

### Act (Thực hiện)
- Tắt kết nối mạng
- Host nhấn nút Đóng sổ

### Assert (Kiểm tra)
- Hệ thống chặn thao tác, hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."
- Trạng thái thiệp không thay đổi (vẫn là "Đang thu thập")

---

## TC-27-015: Mất mạng khi Host gửi thiệp

**AC liên quan:** AC-12
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Thiệp nhóm đang ở trạng thái "Đã đóng sổ"
- Host đã đăng nhập
- Chuẩn bị tắt kết nối mạng trước khi Host nhấn Gửi thiệp

### Act (Thực hiện)
- Tắt kết nối mạng
- Host nhấn nút Gửi thiệp

### Assert (Kiểm tra)
- Hệ thống chặn thao tác, hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."
- Trạng thái thiệp không thay đổi (vẫn là "Đã đóng sổ")

---

## TC-27-016: Host xem danh sách đóng góp ở chế độ ngoại tuyến

**AC liên quan:** BR-13
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Thiệp nhóm có ít nhất 2 đóng góp
- Host đã từng mở màn hình danh sách đóng góp khi có mạng (dữ liệu đã được tải về)
- Tắt kết nối mạng

### Act (Thực hiện)
- Host mở lại màn hình danh sách đóng góp của thiệp nhóm ở chế độ ngoại tuyến

### Assert (Kiểm tra)
- Hệ thống hiển thị danh sách đóng góp với dữ liệu đã tải gần nhất (không bị trắng trơn)
- Nút Đóng sổ và Gửi thiệp bị vô hiệu hoá, có chú thích "Đang xem ngoại tuyến"
- Người dùng không thể thực hiện các thao tác yêu cầu mạng

---

## TC-27-017: Người đóng góp không có tem trong Album bị nhắc tạo tem trước

**AC liên quan:** Mục 5 (Trường hợp ngoại lệ)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Thiệp nhóm đang ở trạng thái "Đang thu thập"
- Người đóng góp đã đăng nhập nhưng Album hoàn toàn trống, không có tem nào

### Act (Thực hiện)
- Người đóng góp bấm link mời
- Hệ thống hiển thị bước chọn tem

### Assert (Kiểm tra)
- Hệ thống hiển thị trạng thái trống Album (empty state)
- Hệ thống gợi ý người dùng tạo tem trước khi đóng góp (liên kết hoặc nút dẫn đến chức năng tạo tem)
- Người đóng góp không thể tiến hành đóng góp khi chưa có tem

---

## TC-27-018: Người chưa có tài khoản bấm link mời phải đăng ký/đăng nhập trước

**AC liên quan:** Mục 5 (Trường hợp ngoại lệ)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Thiệp nhóm đang ở trạng thái "Đang thu thập"
- Thiết bị/trình duyệt chưa đăng nhập tài khoản nào

### Act (Thực hiện)
- Người chưa có tài khoản bấm link mời

### Assert (Kiểm tra)
- Hệ thống chuyển đến màn hình đăng ký/đăng nhập, không hiển thị màn hình đóng góp trực tiếp
- Sau khi đăng ký/đăng nhập thành công, người dùng được chuyển lại đúng luồng đóng góp với link mời vẫn còn hiệu lực

---

## TC-27-019: Host gửi thiệp trống — cảnh báo xác nhận trước khi gửi

**AC liên quan:** Mục 5 (Trường hợp ngoại lệ)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Thiệp nhóm đã được đóng sổ nhưng chưa có đóng góp nào (0 đóng góp)
- Host đã đăng nhập

### Act (Thực hiện)
- Host nhấn nút Gửi thiệp

### Assert (Kiểm tra)
- Hệ thống hiển thị cảnh báo "Thiệp chưa có đóng góp" (hoặc tương đương)
- Hệ thống hỏi xác nhận "Gửi thiệp trống?"
- Nếu Host xác nhận, thiệp được gửi; nếu huỷ, Host quay lại màn hình thiệp

---

## TC-27-020: Người dùng thoát app giữa chừng khi đang soạn lời nhắn — nội dung không được lưu

**AC liên quan:** Mục 5 (Trường hợp ngoại lệ)
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Thiệp nhóm đang ở trạng thái "Đang thu thập"
- Người đóng góp đã bấm link mời, đã chọn tem và đang soạn lời nhắn nhưng chưa xác nhận

### Act (Thực hiện)
- Người dùng thoát ứng dụng giữa chừng (ép tắt app hoặc nhấn nút Home)
- Sau đó, người dùng bấm link mời lại để vào lại màn hình đóng góp

### Assert (Kiểm tra)
- Nội dung lời nhắn chưa xác nhận không được lưu
- Người dùng bắt đầu soạn lại từ đầu (không hiển thị nội dung đã nhập trước đó)

---

## TC-27-021: Danh sách đóng góp không tải được — hiển thị màn hình lỗi với nút Thử lại

**AC liên quan:** Mục 5 (Trường hợp ngoại lệ)
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Thiệp nhóm có ít nhất 1 đóng góp
- Mô phỏng lỗi mạng chập chờn hoặc lỗi máy chủ khiến danh sách đóng góp không tải được

### Act (Thực hiện)
- Host hoặc người đóng góp mở màn hình xem danh sách đóng góp

### Assert (Kiểm tra)
- Hệ thống hiển thị màn hình lỗi với thông báo ngắn gọn
- Có nút "Thử lại" để tải lại danh sách mà không cần thoát màn hình

---

## TC-27-022: Thiệp nhóm bị huỷ khi Host xoá tài khoản trước khi gửi

**AC liên quan:** Mục 5 (Trường hợp ngoại lệ)
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Thiệp nhóm ở trạng thái "Đã đóng sổ" chưa được gửi, có ít nhất 2 đóng góp từ 2 người khác nhau
- Host yêu cầu xoá tài khoản (SM-027)

### Act (Thực hiện)
- Chờ 7 ngày sau khi Host yêu cầu xoá tài khoản để tài khoản bị xoá hoàn toàn

### Assert (Kiểm tra)
- Thiệp nhóm bị huỷ cùng với tài khoản Host sau 7 ngày chờ
- Tài khoản và Album của người đóng góp vẫn nguyên vẹn, không bị ảnh hưởng
- Chỉ mất đóng góp đã gửi vào thiệp đó; các tem trong Album của người đóng góp vẫn còn

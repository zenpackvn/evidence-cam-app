# Test Cases — Viền & Khung tem (008-vien-khung-tem)

## TC-08-001: Người dùng Free chọn viền Free và thấy xem trước ngay

**AC liên quan:** AC-01
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản gói Thường (Free)
- Hoàn thành bước trang trí tem (SM-008) để vào bước viền

### Act (Thực hiện)
- Nhấn vào kiểu viền "Răng cưa cổ điển"

### Assert (Kiểm tra)
- Ảnh xem trước tem hiển thị ngay kiểu viền "Răng cưa cổ điển" mà không cần nhấn xác nhận thêm

---

## TC-08-002: Người dùng Free chọn lần lượt từng viền Free khác nhau

**AC liên quan:** AC-01
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản gói Thường (Free)
- Vào bước viền

### Act (Thực hiện)
- Nhấn vào kiểu viền "Răng tròn"
- Sau đó nhấn vào kiểu viền "Gợn sóng"

### Assert (Kiểm tra)
- Sau khi nhấn "Răng tròn": xem trước hiển thị viền Răng tròn ngay
- Sau khi nhấn "Gợn sóng": xem trước chuyển sang viền Gợn sóng ngay
- Xem trước luôn phản ánh lựa chọn mới nhất

---

## TC-08-003: Người dùng Free nhấn vào viền khóa — hiện hai lựa chọn mở khóa

**AC liên quan:** AC-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản gói Thường (Free)
- Vào bước viền

### Act (Thực hiện)
- Nhấn vào kiểu viền "Zigzag"

### Assert (Kiểm tra)
- Hệ thống hiển thị hai lựa chọn: "Dùng 80📮 để mở kiểu viền này" và "Nâng cấp Premium để mở tất cả"
- Viền "Zigzag" KHÔNG được áp lên ảnh xem trước tem
- Ảnh xem trước giữ nguyên kiểu viền cũ (hoặc mặc định nếu chưa chọn)

---

## TC-08-004: Người dùng Free nhấn vào từng viền khóa — đều hiện hai lựa chọn

**AC liên quan:** AC-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản gói Thường (Free)
- Vào bước viền

### Act (Thực hiện)
- Nhấn vào "Viền đôi"
- Đóng hộp thoại, sau đó nhấn vào "Retro bo mềm"
- Đóng hộp thoại, sau đó nhấn vào "Hoa văn nổi"

### Assert (Kiểm tra)
- Nhấn "Viền đôi": hiện hai lựa chọn mở khóa, không áp viền
- Nhấn "Retro bo mềm": hiện hai lựa chọn mở khóa, không áp viền
- Nhấn "Hoa văn nổi": hiện hai lựa chọn mở khóa, không áp viền
- Cả bốn viền khóa đều cho hành vi giống nhau

---

## TC-08-005: Đổi màu viền — xem trước cập nhật ngay

**AC liên quan:** AC-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản gói Thường (Free)
- Vào bước viền, đã chọn kiểu viền "Răng cưa cổ điển"

### Act (Thực hiện)
- Nhấn vào một màu khác trong bảng màu

### Assert (Kiểm tra)
- Viền trên ảnh xem trước chuyển sang màu mới ngay tức thì, không cần xác nhận
- Không có độ trễ đáng kể giữa thao tác chọn màu và xem trước cập nhật

---

## TC-08-006: Đổi màu viền nhiều lần liên tiếp — xem trước luôn phản ánh màu mới nhất

**AC liên quan:** AC-03, BR-05
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản gói Thường (Free)
- Vào bước viền, đã chọn kiểu viền "Gợn sóng"

### Act (Thực hiện)
- Nhấn lần lượt ba màu khác nhau trong bảng màu

### Assert (Kiểm tra)
- Sau mỗi lần chọn màu, xem trước cập nhật ngay với màu tương ứng
- Màu hiện tại trên xem trước khớp với màu vừa chọn cuối cùng

---

## TC-08-007: Người dùng Premium — cả 7 kiểu viền đều mở khóa

**AC liên quan:** AC-04
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản gói Premium
- Vào bước viền

### Act (Thực hiện)
- Quan sát danh sách các kiểu viền
- Nhấn lần lượt vào "Zigzag", "Viền đôi", "Retro bo mềm", "Hoa văn nổi"

### Assert (Kiểm tra)
- Cả 7 kiểu viền (Răng cưa cổ điển, Răng tròn, Gợn sóng, Zigzag, Viền đôi, Retro bo mềm, Hoa văn nổi) đều hiển thị không có dấu khóa
- Nhấn vào từng viền: xem trước cập nhật ngay, KHÔNG hiện hộp thoại nâng cấp

---

## TC-08-008: Nhấn "Tiếp tục" sau khi chọn viền — chuyển sang SM-010

**AC liên quan:** AC-05
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản bất kỳ
- Vào bước viền, đã chọn kiểu viền và màu viền

### Act (Thực hiện)
- Nhấn nút "Tiếp tục"

### Assert (Kiểm tra)
- Ứng dụng chuyển sang màn hình xem trước tem hoàn chỉnh (SM-010)
- Không ở lại màn hình viền sau khi nhấn "Tiếp tục"

---

## TC-08-009: Nhấn "Tiếp tục" khi chưa chọn viền — áp viền mặc định

**AC liên quan:** AC-05 (trường hợp ngoại lệ)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản bất kỳ
- Vào bước viền, KHÔNG chọn kiểu viền nào

### Act (Thực hiện)
- Nhấn nút "Tiếp tục"

### Assert (Kiểm tra)
- Hệ thống tự áp kiểu viền mặc định "Răng cưa cổ điển"
- Ứng dụng chuyển sang màn hình xem trước tem hoàn chỉnh (SM-010) với viền "Răng cưa cổ điển"
- Không hiện thông báo lỗi yêu cầu chọn viền

---

## TC-08-010: Mở khóa viền bằng Dấu — đủ 80📮

**AC liên quan:** AC-06
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản gói Thường có ≥ 80📮
- Có ít nhất một kiểu viền trong bốn viền khóa chưa mở

### Act (Thực hiện)
- Nhấn vào kiểu viền đang bị khóa (ví dụ: "Zigzag")
- Chọn "Dùng 80📮 để mở kiểu viền này"
- Xác nhận hành động

### Assert (Kiểm tra)
- Kiểu viền "Zigzag" được mở khóa vĩnh viễn, biểu tượng khóa biến mất
- Số Dấu giảm đúng 80📮
- Viền được áp ngay lên ảnh xem trước tem

---

## TC-08-011: Mở khóa viền bằng Dấu — vĩnh viễn cho tài khoản

**AC liên quan:** AC-06, BR-06
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản gói Thường đã từng mở khóa kiểu viền "Retro bo mềm" bằng Dấu
- Thoát bước viền, sau đó vào lại bước viền (tạo tem mới)

### Act (Thực hiện)
- Quan sát danh sách kiểu viền ở bước viền của tem mới

### Assert (Kiểm tra)
- Kiểu viền "Retro bo mềm" vẫn hiển thị đã mở khóa (không có biểu tượng khóa)
- Có thể chọn và áp trực tiếp mà không cần trả Dấu lần nữa

---

## TC-08-012: Chỉnh viền và xem trước khi thiết bị mất mạng (offline)

**AC liên quan:** AC-07
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản gói Thường
- Vào bước viền (đang có mạng)
- Tắt kết nối mạng trên thiết bị (bật chế độ Máy bay)

### Act (Thực hiện)
- Nhấn chọn kiểu viền Free "Răng tròn"
- Chọn một màu viền khác từ bảng màu

### Assert (Kiểm tra)
- Xem trước tem cập nhật ngay như khi có mạng
- Không xuất hiện thông báo lỗi kết nối
- Toàn bộ thao tác chọn viền Free và màu viền hoạt động bình thường

---

## TC-08-013: Viền đã mở khóa trước đó vẫn khả dụng khi offline

**AC liên quan:** AC-07, BR-09
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản gói Thường đã mở khóa kiểu viền "Zigzag" bằng Dấu
- Tắt kết nối mạng trên thiết bị
- Vào bước viền

### Act (Thực hiện)
- Nhấn vào kiểu viền "Zigzag"

### Assert (Kiểm tra)
- "Zigzag" có thể chọn và áp lên xem trước bình thường khi offline
- Không xuất hiện hộp thoại mở khóa hay thông báo cần kết nối

---

## TC-08-014: Chặn mở khóa viền bằng Dấu khi offline

**AC liên quan:** AC-08
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản gói Thường có ≥ 80📮
- Tắt kết nối mạng trên thiết bị
- Vào bước viền

### Act (Thực hiện)
- Nhấn vào kiểu viền đang bị khóa (ví dụ: "Viền đôi")
- Chọn "Dùng 80📮 để mở kiểu viền này"

### Assert (Kiểm tra)
- Hệ thống chặn hành động mở khóa
- Hiển thị thông báo: "Không có kết nối. Vui lòng thử lại khi có mạng."
- Số Dấu không thay đổi (không bị trừ)
- Kiểu viền vẫn bị khóa

---

## TC-08-015: Chặn nâng cấp Premium khi offline

**AC liên quan:** AC-08, BR-08
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản gói Thường
- Tắt kết nối mạng trên thiết bị
- Vào bước viền

### Act (Thực hiện)
- Nhấn vào kiểu viền đang bị khóa
- Chọn "Nâng cấp Premium để mở tất cả"

### Assert (Kiểm tra)
- Hệ thống chặn hành động nâng cấp
- Hiển thị thông báo: "Không có kết nối. Vui lòng thử lại khi có mạng."
- Không điều hướng sang luồng thanh toán

---

## TC-08-016: Di chuyển ảnh trong khung bằng một ngón tay

**AC liên quan:** AC-09
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản bất kỳ
- Vào bước viền, đã chọn một kiểu viền

### Act (Thực hiện)
- Kéo một ngón tay trên vùng ảnh sang bên phải

### Assert (Kiểm tra)
- Ảnh dịch chuyển sang phải trong khung tem
- Viền và các thành phần trang trí giữ nguyên vị trí, không dịch chuyển
- Chỉ phần ảnh bên trong khung thay đổi vị trí

---

## TC-08-017: Phóng to ảnh trong khung bằng hai ngón tay

**AC liên quan:** AC-10
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản bất kỳ
- Vào bước viền, đã chọn một kiểu viền

### Act (Thực hiện)
- Đặt hai ngón tay lên vùng ảnh và banh ra (pinch-out)

### Assert (Kiểm tra)
- Ảnh phóng to bên trong khung
- Vùng chi tiết giữa hai ngón tay trở nên nổi bật hơn
- Khung và viền giữ nguyên, không thay đổi kích thước

---

## TC-08-018: Thu nhỏ ảnh dừng khi ảnh vừa phủ kín khung

**AC liên quan:** AC-11
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản bất kỳ
- Vào bước viền, đã phóng to ảnh trong khung

### Act (Thực hiện)
- Chụm hai ngón tay liên tục để thu nhỏ ảnh dần dần cho đến giới hạn

### Assert (Kiểm tra)
- Ảnh thu nhỏ đến mức vừa phủ kín toàn bộ khung rồi dừng lại
- Không có vùng trống nào xuất hiện bên trong đường viền tem
- Không thể thu nhỏ ảnh thêm sau khi đã đạt giới hạn

---

## TC-08-019: Kéo ảnh không để lộ vùng trống trong khung

**AC liên quan:** AC-12
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản bất kỳ
- Vào bước viền, ảnh ở kích thước vừa khung (chưa phóng to)

### Act (Thực hiện)
- Kéo ảnh liên tục về một phía cho đến khi cạnh ảnh gần chạm vào trong khung

### Assert (Kiểm tra)
- Hệ thống chặn, ảnh không di chuyển thêm khi cạnh đã giáp mép khung
- Cạnh ảnh không lùi vào bên trong đường viền tem
- Không có vùng trống nào xuất hiện bên trong khung

---

## TC-08-020: Đổi kiểu viền đặt lại vị trí và tỉ lệ ảnh

**AC liên quan:** AC-13
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản bất kỳ
- Vào bước viền, đã chọn kiểu viền "Răng tròn"
- Phóng to ảnh và kéo ảnh sang một góc

### Act (Thực hiện)
- Chọn sang kiểu viền khác (ví dụ: "Gợn sóng")

### Assert (Kiểm tra)
- Ảnh tự động về vị trí trung tâm, tỉ lệ vừa khung mới
- Các điều chỉnh phóng to và dịch chuyển trước đó bị đặt lại hoàn toàn

---

## TC-08-021: Danh sách viền hiển thị đúng trạng thái cho người dùng Free

**AC liên quan:** BR-01, BR-02, BR-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản gói Thường (Free)
- Vào bước viền

### Act (Thực hiện)
- Quan sát toàn bộ danh sách 7 kiểu viền

### Assert (Kiểm tra)
- 3 viền Free (Răng cưa cổ điển, Răng tròn, Gợn sóng) hiển thị không có dấu khóa, có thể nhấn chọn bình thường
- 4 viền khóa (Zigzag, Viền đôi, Retro bo mềm, Hoa văn nổi) hiển thị với dấu hiệu bị khóa
- Cả 7 kiểu đều nhìn thấy được trong danh sách

---

## TC-08-022: Đổi màu viền rồi đổi kiểu viền — màu được giữ nguyên

**AC liên quan:** AC-03, BR-04
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản gói Thường (Free)
- Vào bước viền, đã chọn kiểu "Răng cưa cổ điển"
- Đã chọn một màu cụ thể từ bảng màu (ví dụ: màu đỏ)

### Act (Thực hiện)
- Chuyển sang chọn kiểu viền "Gợn sóng"

### Assert (Kiểm tra)
- Xem trước hiển thị kiểu viền "Gợn sóng" với màu đỏ đã chọn trước
- Màu viền không bị reset về mặc định khi đổi kiểu

---

## TC-08-023: Gợi ý mở khóa có thể điều hướng sang luồng nâng cấp Premium

**AC liên quan:** BR-03, AC-02
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản gói Thường (Free)
- Vào bước viền

### Act (Thực hiện)
- Nhấn vào viền "Zigzag" để kích hoạt hộp thoại mở khóa
- Nhấn vào lựa chọn "Nâng cấp Premium để mở tất cả"

### Assert (Kiểm tra)
- Ứng dụng điều hướng sang màn hình/luồng nâng cấp Premium (SM-028)
- Không bị kẹt lại trên màn hình viền

---

## TC-08-024: Danh sách viền không tải được — hiện thông báo lỗi và nút Thử lại

**AC liên quan:** Mục 5 (lỗi mạng / lỗi máy chủ)
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Thiết lập môi trường có lỗi máy chủ hoặc mạng kém đến mức danh sách viền không tải được
- Đăng nhập tài khoản bất kỳ
- Vào bước viền

### Act (Thực hiện)
- Quan sát màn hình viền khi dữ liệu không tải được

### Assert (Kiểm tra)
- Màn hình hiển thị biểu tượng lỗi và thông báo "Không thể tải viền. Vui lòng thử lại."
- Có nút "Thử lại" để người dùng tải lại danh sách

---

## TC-08-025: Mở khóa viền thất bại do lỗi máy chủ — không trừ Dấu

**AC liên quan:** Mục 5 (lỗi mạng / lỗi máy chủ)
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản gói Thường có ≥ 80📮
- Thiết lập môi trường có lỗi máy chủ trong quá trình xác nhận mở khóa
- Vào bước viền

### Act (Thực hiện)
- Nhấn vào kiểu viền đang bị khóa
- Chọn "Dùng 80📮 để mở kiểu viền này" và xác nhận

### Assert (Kiểm tra)
- Hệ thống thông báo "Mở khóa không thành công. Vui lòng thử lại."
- Số Dấu không thay đổi (không bị trừ 80📮)
- Kiểu viền vẫn bị khóa, chưa được mở

---

## TC-08-026: Người dùng chưa đăng nhập không thể vào bước viền

**AC liên quan:** Mục 5 (chưa đăng nhập)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Chưa đăng nhập vào ứng dụng (hoặc đã đăng xuất)

### Act (Thực hiện)
- Thử vào luồng tạo tem để đến bước viền

### Assert (Kiểm tra)
- Hệ thống không cho vào bước viền
- Ứng dụng chuyển đến màn hình đăng nhập

---

## TC-08-027: Thoát app giữa bước viền — mất dữ liệu khi mở lại

**AC liên quan:** Mục 5 (thoát app giữa chừng)
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản bất kỳ
- Vào bước viền, đã chọn kiểu viền và màu viền (chưa nhấn Tiếp tục)

### Act (Thực hiện)
- Thoát hoàn toàn khỏi ứng dụng (kill process)
- Mở lại ứng dụng

### Assert (Kiểm tra)
- Ứng dụng quay về màn hình chính, không quay lại bước viền
- Toàn bộ nội dung đang chỉnh (kiểu viền, màu, điều chỉnh ảnh) bị mất

---

## TC-08-028: Viền mới chưa tải về không hiển thị nội dung khi offline

**AC liên quan:** Mục 5 (offline — viền chưa tải)
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản lần đầu, chưa từng vào bước viền (viền chưa được tải về thiết bị)
- Tắt kết nối mạng
- Vào bước viền

### Act (Thực hiện)
- Quan sát danh sách kiểu viền

### Assert (Kiểm tra)
- Các kiểu viền chưa tải về không hiển thị nội dung ảnh đại diện
- Hiển thị ghi chú "Cần kết nối để tải viền mới."

---

## TC-08-029: Kéo ảnh sang bốn hướng — không lộ vùng trống ở bất kỳ hướng nào

**AC liên quan:** AC-12, BR-13
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản bất kỳ
- Vào bước viền, ảnh ở kích thước vừa khung

### Act (Thực hiện)
- Kéo ảnh lần lượt sang trái, phải, trên, dưới đến mức tối đa

### Assert (Kiểm tra)
- Ở mỗi hướng, cạnh ảnh không lùi vào bên trong đường viền
- Không có vùng trống nào xuất hiện bên trong khung ở bất kỳ hướng kéo nào

---

## TC-08-030: Phóng to ảnh rồi kéo — vẫn giữ ảnh phủ kín khung

**AC liên quan:** AC-12, BR-13
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản bất kỳ
- Vào bước viền, phóng to ảnh lên đáng kể

### Act (Thực hiện)
- Kéo ảnh ra ngoài khung theo mọi hướng đến mức tối đa

### Assert (Kiểm tra)
- Ở mỗi hướng, hệ thống tự dừng khi cạnh ảnh đạt mép khung
- Không có vùng trống nào xuất hiện bên trong đường viền

# Test Cases — Trả lời thư (018-tra-loi-thu)

## TC-18-001: Nút Trả lời mở soạn thư với người nhận đã điền sẵn

**AC liên quan:** AC-01, BR-01
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập vào ứng dụng với tài khoản hợp lệ
- Có thư đến từ người dùng tên "An" trong hộp thư
- Mở và đọc thư từ "An" cho đến khi animation mở thư hoàn tất

### Act (Thực hiện)
- Nhấn nút "Trả lời" trên màn hình đọc thư

### Assert (Kiểm tra)
- Màn hình soạn thư mở ra
- Ô người nhận hiển thị "An" (tên người gửi gốc) đã được điền sẵn
- Người dùng không cần nhập tên người nhận

---

## TC-18-002: Hoàn tất soạn thư trả lời và gửi qua MXH

**AC liên quan:** AC-02, BR-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập vào ứng dụng với tài khoản hợp lệ
- Đang ở màn hình soạn thư trả lời với người nhận "An" đã điền sẵn
- Đã chọn template và soạn nội dung thư trả lời hợp lệ

### Act (Thực hiện)
- Nhấn nút xác nhận gửi (ví dụ: "Gửi")

### Assert (Kiểm tra)
- Màn hình chọn nền tảng MXH (mạng xã hội) để chia sẻ link hiển thị
- Luồng này giống hệt luồng gửi thư mới (SM-016)
- Không có màn hình xác nhận đặc biệt nào khác biệt so với gửi thư thông thường

---

## TC-18-003: Người đọc thư trên web nhấn Trả lời — hiển thị CTA tải app

**AC liên quan:** AC-03, BR-05
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người nhận mở link thư trên trình duyệt web (không có app StampMail)
- Đang xem nội dung thư trên web reader

### Act (Thực hiện)
- Nhấn nút "Trả lời" trên trang web

### Assert (Kiểm tra)
- Hiển thị màn hình "Tải StampMail để trả lời thư này" với thông điệp rõ ràng
- Có nút dẫn đến App Store (iOS) và/hoặc Google Play (Android)
- Không có form soạn thư trả lời trực tiếp trên web
- Không thể trả lời thư từ trình duyệt

---

## TC-18-004: Đã cài app nhưng chưa đăng nhập — chuyển sang đăng nhập trước

**AC liên quan:** AC-04
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người nhận có app StampMail đã cài nhưng chưa đăng nhập
- Đang xem thư trong app và muốn trả lời

### Act (Thực hiện)
- Nhấn "Trả lời" trong app

### Assert (Kiểm tra)
- App chuyển sang màn hình đăng nhập/đăng ký
- Màn hình soạn thư trả lời KHÔNG mở ra ngay lập tức
- Sau khi đăng nhập thành công, hệ thống quay lại màn hình soạn thư trả lời

---

## TC-18-005: Soạn thư không thể gửi khi mất mạng — nút Gửi bị vô hiệu hóa

**AC liên quan:** AC-05, BR-06
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập vào ứng dụng với tài khoản hợp lệ
- Đang ở màn hình soạn thư trả lời
- Đã soạn xong nội dung thư (ví dụ: "Chào bạn, mình đã nhận được thư...")
- Tắt kết nối mạng trên thiết bị

### Act (Thực hiện)
- Hoàn tất nội dung và nhấn nút "Gửi"

### Assert (Kiểm tra)
- Nút "Gửi" bị vô hiệu hóa (không thực hiện được thao tác gửi)
- Hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."
- Toàn bộ nội dung thư đã soạn vẫn còn nguyên trên màn hình
- Ô người nhận vẫn hiển thị "An" đầy đủ

---

## TC-18-006: Mở và soạn thư trả lời bình thường khi mất mạng

**AC liên quan:** AC-06, BR-07
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập vào ứng dụng với tài khoản hợp lệ
- Đã mở và đọc thư từ "An" (trước khi mất mạng)
- Tắt kết nối mạng trên thiết bị

### Act (Thực hiện)
- Nhấn nút "Trả lời"
- Soạn nội dung thư trả lời
- Chọn template khác từ danh sách

### Assert (Kiểm tra)
- Màn hình soạn thư mở ra bình thường (không báo lỗi mạng ở bước này)
- Ô người nhận được điền sẵn "An" như bình thường
- Người dùng có thể nhập nội dung thư mà không gặp lỗi
- Người dùng có thể chọn template khác mà không gặp lỗi
- Chỉ khi nhấn "Gửi" mới hiển thị thông báo mất kết nối

---

## TC-18-007: Mạng trở lại sau khi mất — nút Gửi được kích hoạt lại, nội dung giữ nguyên

**AC liên quan:** BR-06, Mục 5 — Nhóm 1
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đang ở màn hình soạn thư trả lời với nội dung đã nhập
- Nút "Gửi" đang bị vô hiệu hóa do mất mạng
- Thông báo "Không có kết nối..." đang hiển thị

### Act (Thực hiện)
- Bật lại kết nối mạng trên thiết bị

### Assert (Kiểm tra)
- Nút "Gửi" được kích hoạt lại (có thể nhấn)
- Thông báo mất kết nối biến mất hoặc cập nhật trạng thái
- Toàn bộ nội dung đã soạn vẫn còn nguyên — người dùng không phải nhập lại
- Người dùng có thể gửi thư ngay mà không cần thao tác thêm

---

## TC-18-008: Hệ thống gợi ý template reply phù hợp khi mở soạn thư trả lời

**AC liên quan:** BR-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập vào ứng dụng với tài khoản hợp lệ
- Đang đọc thư từ một người dùng khác, animation đã hoàn tất

### Act (Thực hiện)
- Nhấn nút "Trả lời"

### Assert (Kiểm tra)
- Màn hình soạn thư mở ra với một template được chọn sẵn (template reply)
- Template được gợi ý có phong cách phù hợp với trả lời thư
- Danh sách các template khác vẫn có thể chọn được

---

## TC-18-009: Người dùng thay đổi template reply sang template khác

**AC liên quan:** BR-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đang ở màn hình soạn thư trả lời với template reply mặc định đã được chọn sẵn

### Act (Thực hiện)
- Nhấn vào tùy chọn chọn template
- Chọn một template khác từ danh sách

### Assert (Kiểm tra)
- Template mới được áp dụng vào màn hình soạn thư
- Giao diện soạn thư phản ánh template vừa chọn
- Ô người nhận vẫn được giữ nguyên sau khi đổi template

---

## TC-18-010: Thư trả lời không hiển thị nội dung thư gốc

**AC liên quan:** BR-04
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đang ở màn hình soạn thư trả lời sau khi nhấn "Trả lời" từ một thư có nội dung cụ thể

### Act (Thực hiện)
- Quan sát màn hình soạn thư trả lời

### Assert (Kiểm tra)
- Nội dung thư gốc KHÔNG hiển thị trong vùng soạn thư
- Không có phần "Nội dung gốc:" hoặc trích dẫn nội dung thư cũ
- Màn hình soạn thư trống (chỉ có ô người nhận đã điền sẵn và template)

---

## TC-18-011: Thoát khỏi soạn thư trả lời dở dang — hiển thị xác nhận

**AC liên quan:** Mục 5 — Người dùng thoát giữa chừng
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đang ở màn hình soạn thư trả lời
- Đã nhập một phần nội dung thư (ví dụ: "Chào bạn, mình...")

### Act (Thực hiện)
- Nhấn nút "Quay lại" hoặc vuốt để đóng màn hình soạn thư

### Assert (Kiểm tra)
- Hộp thoại xác nhận hiển thị với nội dung "Bỏ thư này?" (hoặc tương đương)
- Có ít nhất hai lựa chọn: xác nhận bỏ thư và hủy (tiếp tục soạn)

---

## TC-18-012: Xác nhận "Bỏ thư này?" — chọn hủy để quay lại soạn

**AC liên quan:** Mục 5 — Người dùng thoát giữa chừng
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Hộp thoại "Bỏ thư này?" đang hiển thị
- Người dùng đã nhập nội dung "Chào bạn, mình nhớ..."

### Act (Thực hiện)
- Nhấn nút "Hủy" hoặc tùy chọn tiếp tục soạn trong hộp thoại

### Assert (Kiểm tra)
- Hộp thoại đóng lại
- Màn hình soạn thư trả lời vẫn hiển thị
- Nội dung đã nhập "Chào bạn, mình nhớ..." vẫn còn nguyên

---

## TC-18-013: Xác nhận "Bỏ thư này?" — chọn đồng ý để đóng soạn thư

**AC liên quan:** Mục 5 — Người dùng thoát giữa chừng
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Hộp thoại "Bỏ thư này?" đang hiển thị
- Người dùng đã nhập nội dung một phần

### Act (Thực hiện)
- Nhấn nút "Đồng ý" hoặc tùy chọn bỏ thư trong hộp thoại

### Assert (Kiểm tra)
- Màn hình soạn thư trả lời đóng lại
- Người dùng quay về màn hình đọc thư gốc hoặc màn hình trước đó
- Nội dung đã nhập bị xoá hoàn toàn

---

## TC-18-014: Gửi thư trả lời khi người gửi gốc đã xoá tài khoản

**AC liên quan:** Mục 5 — Người gửi gốc đã xoá tài khoản
**Loại:** 🔲 Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Có thư đến từ người dùng "Bình" trong hộp thư
- Tài khoản của "Bình" đã bị xoá khỏi hệ thống (cần thao tác trực tiếp trên hệ thống quản trị)
- Đăng nhập và mở thư từ "Bình"

### Act (Thực hiện)
- Nhấn nút "Trả lời"

### Assert (Kiểm tra)
- Màn hình soạn thư vẫn mở ra bình thường
- Ô người nhận điền sẵn tên "Bình"
- Hiển thị thông báo cảnh báo rõ ràng rằng người nhận có thể không còn hoạt động (ví dụ: "Người nhận này có thể không còn hoạt động")
- Người dùng vẫn có thể tiếp tục soạn và gửi thư

---

## TC-18-015: Thông tin người gửi gốc không tải được — hiển thị trạng thái lỗi và nút Thử lại

**AC liên quan:** Mục 5 — Nhóm 2
**Loại:** 🔲 Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập vào ứng dụng
- Kết nối mạng không ổn định hoặc máy chủ trả về lỗi khi tải thông tin người gửi

### Act (Thực hiện)
- Nhấn nút "Trả lời" trên thư

### Assert (Kiểm tra)
- Màn hình soạn thư hiển thị trạng thái lỗi thay vì điền sẵn tên người nhận
- Có nút "Thử lại" rõ ràng trên màn hình
- Nhấn "Thử lại" → hệ thống tải lại thông tin người gửi gốc và điền vào ô người nhận

---

## TC-18-016: Lưu nháp khi thoát app giữa chừng đang soạn thư trả lời

**AC liên quan:** Mục 5 — Nhóm 3 (thoát app giữa chừng)
**Loại:** 🔲 Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đang ở màn hình soạn thư trả lời với nội dung đã nhập một phần
- Chưa nhấn gửi

### Act (Thực hiện)
- Thoát khỏi app (vuốt ra ngoài, nhấn Home, hoặc bị gián đoạn)
- Mở lại app

### Assert (Kiểm tra)
- Hệ thống hỏi "Bạn có muốn tiếp tục thư đang soạn dở không?" (hoặc tương đương)
- Nếu chọn tiếp tục: màn hình soạn thư mở ra với nội dung đã nhập còn nguyên
- Nếu chọn không tiếp tục: nháp bị xoá và người dùng vào màn hình chính

---

## TC-18-017: Sau khi đăng nhập thành công, hệ thống quay lại soạn thư trả lời

**AC liên quan:** AC-04, Mục 5 — Nhóm 3
**Loại:** 🔲 Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng chưa đăng nhập, nhấn "Trả lời" và được chuyển sang màn hình đăng nhập
- Nhập thông tin đăng nhập hợp lệ

### Act (Thực hiện)
- Hoàn tất đăng nhập

### Assert (Kiểm tra)
- Sau khi đăng nhập thành công, hệ thống tự động quay lại màn hình soạn thư trả lời
- Người nhận đã được điền sẵn là người gửi thư gốc
- Người dùng không phải tìm lại thư và nhấn Trả lời từ đầu

---

## TC-18-018: Nút Trả lời chỉ hiển thị sau khi animation mở thư hoàn tất

**AC liên quan:** Liên kết SM-019
**Loại:** 🔲 Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đang ở màn hình danh sách thư
- Chọn một thư để mở — animation mở phong bì đang chạy

### Act (Thực hiện)
- Quan sát màn hình trong suốt quá trình animation mở thư

### Assert (Kiểm tra)
- Nút "Trả lời" KHÔNG hiển thị hoặc bị vô hiệu hóa trong khi animation đang chạy
- Nút "Trả lời" chỉ xuất hiện/kích hoạt sau khi animation mở thư hoàn tất

---

## TC-18-019: Thư trả lời đã gửi hiển thị là thư độc lập trong lịch sử

**AC liên quan:** BR-04
**Loại:** 🔲 Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đã gửi thành công một thư trả lời cho người dùng "An"
- Mở màn hình lịch sử thư hoặc hộp thư đã gửi

### Act (Thực hiện)
- Tìm thư trả lời vừa gửi trong lịch sử

### Assert (Kiểm tra)
- Thư trả lời hiển thị như một thư độc lập, không gộp vào chuỗi với thư gốc
- Không có nhãn "Trả lời:" hoặc chỉ báo threading nào liên kết với thư gốc
- Mỗi thư (gốc và trả lời) là một phong bì riêng biệt

---

## TC-18-020: Web reader — không có form soạn thư trả lời nào trên trang web

**AC liên quan:** BR-05
**Loại:** 🔲 Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người nhận đang xem thư trên trình duyệt web

### Act (Thực hiện)
- Quan sát toàn bộ trang web reader

### Assert (Kiểm tra)
- Không có form nhập nội dung thư trả lời nào trên trang web
- Chỉ có CTA tải app nếu muốn trả lời
- Không có cách nào để trả lời trực tiếp từ web

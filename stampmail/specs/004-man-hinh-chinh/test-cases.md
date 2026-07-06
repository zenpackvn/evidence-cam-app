# Test Cases — Màn hình chính (Home) (004-man-hinh-chinh)

## TC-04-001: Hiển thị số thư chưa đọc khi có thư

**AC liên quan:** AC-01
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản người dùng đã có 2 thư chưa đọc trong hộp thư
- Đảm bảo ứng dụng chưa mở màn hình chính

### Act (Thực hiện)
- Mở ứng dụng và điều hướng đến màn hình chính

### Assert (Kiểm tra)
- Số "2" hiển thị tại vị trí thông báo thư trên màn hình chính
- Số được hiển thị rõ ràng, không bị che khuất bởi thành phần khác

---

## TC-04-002: Không hiển thị số khi không có thư chưa đọc

**AC liên quan:** AC-01 (BR-01)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản người dùng không có thư chưa đọc (tất cả thư đã đọc hoặc hộp thư trống)

### Act (Thực hiện)
- Mở màn hình chính

### Assert (Kiểm tra)
- Vị trí thông báo thư không hiển thị số hoặc hiển thị "0"
- Không có badge đỏ hay chỉ số nào xuất hiện tại biểu tượng thư

---

## TC-04-003: Hiển thị tem gần nhất khi người dùng đã có tem

**AC liên quan:** AC-02 (BR-02)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản người dùng đã có ít nhất một tem trong album
- Xác định tem được tạo hoặc nhận gần nhất

### Act (Thực hiện)
- Mở màn hình chính

### Assert (Kiểm tra)
- Khu vực tem trên màn hình chính hiển thị ảnh tem được tạo/nhận gần nhất
- Ảnh tem hiển thị đúng, không bị vỡ hay trống

---

## TC-04-004: Hiển thị lời mời tạo tem khi chưa có tem nào

**AC liên quan:** AC-03 (BR-02)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản người dùng mới đăng ký, chưa tạo hoặc nhận tem nào

### Act (Thực hiện)
- Mở màn hình chính

### Assert (Kiểm tra)
- Khu vực tem không hiển thị ảnh tem
- Khu vực tem hiển thị lời mời tạo tem đầu tiên (ví dụ: nút hoặc văn bản gợi ý tạo tem)
- Không hiển thị ảnh placeholder hay ảnh lỗi

---

## TC-04-005: Điều hướng đến "Tạo tem" qua thanh điều hướng

**AC liên quan:** AC-04 (BR-04, BR-05)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập và đang ở màn hình chính
- Thanh điều hướng phía dưới hiển thị bốn mục: "Tạo tem", "Thư", "Album", "Hồ sơ"

### Act (Thực hiện)
- Nhấn vào mục "Tạo tem" trên thanh điều hướng

### Assert (Kiểm tra)
- Luồng tạo tem (SM-005) được mở ra
- Màn hình tạo tem hiển thị đúng, không có lỗi điều hướng

---

## TC-04-006: Điều hướng đến "Thư" qua thanh điều hướng

**AC liên quan:** AC-04 (BR-04)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập và đang ở màn hình chính

### Act (Thực hiện)
- Nhấn vào mục "Thư" trên thanh điều hướng

### Assert (Kiểm tra)
- Màn hình Hộp thư đến (SM-018) được mở ra
- Không có lỗi điều hướng xảy ra

---

## TC-04-007: Điều hướng đến "Album" qua thanh điều hướng

**AC liên quan:** AC-04 (BR-04)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập và đang ở màn hình chính

### Act (Thực hiện)
- Nhấn vào mục "Album" trên thanh điều hướng

### Assert (Kiểm tra)
- Màn hình Album sưu tập tem (SM-022) được mở ra
- Không có lỗi điều hướng xảy ra

---

## TC-04-008: Điều hướng đến "Hồ sơ" qua thanh điều hướng

**AC liên quan:** AC-04 (BR-04)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập và đang ở màn hình chính

### Act (Thực hiện)
- Nhấn vào mục "Hồ sơ" trên thanh điều hướng

### Assert (Kiểm tra)
- Màn hình Hồ sơ người dùng (SM-024) được mở ra
- Không có lỗi điều hướng xảy ra

---

## TC-04-009: Thanh điều hướng hiển thị đủ bốn mục

**AC liên quan:** AC-04 (BR-04)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản bất kỳ

### Act (Thực hiện)
- Mở màn hình chính và quan sát thanh điều hướng phía dưới

### Assert (Kiểm tra)
- Thanh điều hướng hiển thị đúng bốn mục: "Tạo tem", "Thư", "Album", "Hồ sơ"
- Tất cả bốn mục đều hiển thị đồng thời, không bị ẩn hay cắt bớt

---

## TC-04-010: Hiển thị gợi ý hành động khi chưa gửi thư

**AC liên quan:** BR-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản người dùng chưa gửi thư nào

### Act (Thực hiện)
- Mở màn hình chính

### Assert (Kiểm tra)
- Màn hình hiển thị tối đa một gợi ý hành động (ví dụ: "Bạn chưa gửi thư nào — thử gửi thư đầu tiên")
- Chỉ hiển thị đúng một gợi ý, không hiển thị nhiều gợi ý cùng lúc

---

## TC-04-011: Hiển thị gợi ý khi có thư chưa đọc

**AC liên quan:** BR-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản người dùng có thư chưa đọc

### Act (Thực hiện)
- Mở màn hình chính

### Assert (Kiểm tra)
- Màn hình hiển thị gợi ý hành động liên quan đến thư chưa đọc (ví dụ: "Bạn có thư chưa đọc")
- Chỉ hiển thị đúng một gợi ý, không hiển thị nhiều gợi ý cùng lúc

---

## TC-04-012: Hiển thị nội dung đã tải khi mất kết nối mạng

**AC liên quan:** AC-05 (BR-06)
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập và mở màn hình chính khi có kết nối mạng để dữ liệu được tải về
- Ghi nhớ số thư chưa đọc và tem gần nhất đang hiển thị

### Act (Thực hiện)
- Tắt kết nối mạng (bật chế độ máy bay hoặc tắt Wi-Fi/dữ liệu di động)
- Chuyển sang ứng dụng khác rồi quay lại màn hình chính

### Assert (Kiểm tra)
- Màn hình chính vẫn hiển thị với dữ liệu đã lưu trước đó
- Số thư chưa đọc và tem gần nhất vẫn hiển thị đúng như lần tải gần nhất
- Thông báo "Đang xem ngoại tuyến" xuất hiện ở vị trí không che khuất nội dung chính
- Màn hình không trắng, không hiển thị lỗi toàn trang

---

## TC-04-013: Thao tác làm mới dữ liệu khi đang ngoại tuyến không gây lỗi

**AC liên quan:** AC-06 (BR-07)
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đã mở màn hình chính khi có mạng (dữ liệu đã được tải)
- Tắt kết nối mạng — thông báo "Đang xem ngoại tuyến" đang hiển thị

### Act (Thực hiện)
- Kéo màn hình xuống để thực hiện thao tác làm mới dữ liệu (pull-to-refresh)

### Assert (Kiểm tra)
- Dữ liệu trên màn hình không thay đổi so với trước khi kéo
- Thông báo "Đang xem ngoại tuyến" vẫn hiển thị
- Không xuất hiện lỗi toàn trang hay thông báo lỗi nghiêm trọng

---

## TC-04-014: Vô hiệu hóa hành động cần mạng khi ngoại tuyến

**AC liên quan:** AC-06 (BR-07)
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đã mở màn hình chính khi có mạng
- Tắt kết nối mạng

### Act (Thực hiện)
- Thử nhấn vào các hành động trên màn hình yêu cầu tải dữ liệu mới từ mạng

### Assert (Kiểm tra)
- Các hành động cần mạng bị vô hiệu hóa hoặc hiển thị thông báo ngoại tuyến
- Dữ liệu đang xem (số thư, tem gần nhất) không bị mất hay xóa đi

---

## TC-04-015: Hiển thị skeleton loading khi lần đầu tải và chưa có cache

**AC liên quan:** Mục 5 — Trường hợp ngoại lệ & lỗi
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản lần đầu, chưa có dữ liệu cache trên thiết bị
- Kết nối mạng chậm hoặc có độ trễ cao để kéo dài thời gian tải

### Act (Thực hiện)
- Mở màn hình chính

### Assert (Kiểm tra)
- Trong khi chờ dữ liệu tải về, màn hình hiển thị skeleton loading (phần khung chờ) thay vì màn hình trắng
- Khi dữ liệu tải xong, skeleton được thay thế bằng nội dung thật

---

## TC-04-016: Hiển thị trạng thái lỗi kèm nút "Thử lại" khi không tải được dữ liệu lần đầu

**AC liên quan:** Mục 5 — Trường hợp ngoại lệ & lỗi
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản chưa có dữ liệu cache trên thiết bị
- Tắt kết nối mạng hoặc mô phỏng lỗi máy chủ trước khi mở màn hình chính

### Act (Thực hiện)
- Mở màn hình chính và chờ đến khi hết thời gian thử tải

### Assert (Kiểm tra)
- Khu vực feed và gợi ý hiển thị trạng thái lỗi (biểu tượng lỗi kèm dòng chữ "Không thể tải dữ liệu" hoặc tương tự)
- Nút "Thử lại" hiển thị để người dùng có thể thử tải lại mà không cần khởi động lại ứng dụng

---

## TC-04-017: Nhấn "Thử lại" tải lại dữ liệu thành công

**AC liên quan:** Mục 5 — Trường hợp ngoại lệ & lỗi
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đang ở trạng thái lỗi tải dữ liệu (màn hình hiển thị nút "Thử lại")
- Khôi phục kết nối mạng

### Act (Thực hiện)
- Nhấn nút "Thử lại"

### Assert (Kiểm tra)
- Dữ liệu được tải lại từ máy chủ
- Màn hình chính hiển thị đầy đủ thông tin (số thư chưa đọc, tem gần nhất, gợi ý hành động)
- Trạng thái lỗi và nút "Thử lại" biến mất

---

## TC-04-018: Phiên đăng nhập hết hạn tự động chuyển hướng sang đăng nhập

**AC liên quan:** Mục 5 — Trường hợp ngoại lệ & lỗi
**Loại:** E2E
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản người dùng
- Từ phía máy chủ, làm hết hạn phiên đăng nhập của tài khoản này

### Act (Thực hiện)
- Mở ứng dụng hoặc điều hướng đến màn hình chính

### Assert (Kiểm tra)
- Ứng dụng tự động chuyển sang màn hình đăng nhập
- Không hiển thị màn hình chính với dữ liệu cũ sau khi phiên hết hạn

---

## TC-04-019: Màn hình chính hiển thị dữ liệu cache khi mở lại sau khi thoát app

**AC liên quan:** Mục 5 — Trường hợp ngoại lệ & lỗi
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập và mở màn hình chính — dữ liệu (số thư, tem gần nhất) đã hiển thị
- Ghi nhớ số thư chưa đọc và tem gần nhất

### Act (Thực hiện)
- Thoát ứng dụng hoàn toàn (force quit)
- Mở lại ứng dụng

### Assert (Kiểm tra)
- Màn hình chính hiển thị ngay dữ liệu cache (số thư và tem gần nhất) trong khi chờ tải mới từ máy chủ
- Không hiển thị màn hình trắng hoặc skeleton kéo dài bất thường trước khi có cache hiện ra

---

## TC-04-020: Hiển thị đúng khi số thư chưa đọc rất lớn (99+)

**AC liên quan:** AC-01 (BR-01)
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản có số lượng thư chưa đọc lớn (ví dụ: 99 hoặc hơn)

### Act (Thực hiện)
- Mở màn hình chính

### Assert (Kiểm tra)
- Số thư chưa đọc hiển thị hợp lý (ví dụ: "99+" nếu vượt quá ngưỡng hiển thị)
- Giao diện không bị vỡ layout hoặc tràn chữ ra ngoài vùng hiển thị

---

## TC-04-021: Người dùng mới — màn hình chính hiển thị đầy đủ trạng thái ban đầu

**AC liên quan:** AC-01, AC-03, BR-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập tài khoản mới đăng ký, chưa có tem và chưa có thư

### Act (Thực hiện)
- Mở màn hình chính

### Assert (Kiểm tra)
- Vị trí thông báo thư không hiển thị số hoặc hiển thị "0"
- Khu vực tem hiển thị lời mời tạo tem đầu tiên
- Hệ thống hiển thị đúng một gợi ý hành động phù hợp với trạng thái người dùng mới
- Thanh điều hướng hiển thị đủ bốn mục

---

## TC-04-022: Nhấn liên tục vào cùng một mục điều hướng không gây lỗi

**AC liên quan:** AC-04 (BR-04)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập và đang ở màn hình chính

### Act (Thực hiện)
- Nhấn liên tục nhiều lần (3-5 lần) vào cùng một mục trên thanh điều hướng (ví dụ: "Thư")

### Assert (Kiểm tra)
- Không xảy ra lỗi hay điều hướng chồng lặp (mở nhiều màn hình Thư xếp chồng nhau)
- Màn hình đích chỉ mở một lần hoặc xử lý nhấn trùng lặp một cách hợp lý

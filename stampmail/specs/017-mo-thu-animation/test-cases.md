# Test Cases — Mở thư & Animation (SM-019 / 017-mo-thu-animation)

## TC-17-001: Trình tự animation đúng thứ tự khi mở link lần đầu

**AC liên quan:** AC-01
**Loại:** E2E | Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng A (người gửi) đã gửi thành công một thư có tem tới người dùng B (người nhận)
- Link thư còn hiệu lực, chưa được mở lần nào
- Người nhận B đang truy cập link thư trên thiết bị di động (trong app hoặc web)
- Kết nối internet ổn định

### Act (Thực hiện)
- Người nhận B nhấn vào link thư hợp lệ
- Chờ trang/màn hình tải xong

### Assert (Kiểm tra)
- Phong bì hiện ra và bắt đầu mở chậm (bước 1)
- Sau khi phong bì mở, giấy thư cuộn ra từ phong bì (bước 2)
- Sau khi giấy cuộn ra, nội dung thư hiện dần (bước 3)
- Sau khi nội dung hiện, tem sáng lên nổi bật (bước 4)
- Bốn bước diễn ra theo đúng thứ tự trên, không bị đảo hoặc bỏ qua bất kỳ bước nào

---

## TC-17-002: Animation không phát âm thanh khi cài đặt âm thanh đã tắt

**AC liên quan:** AC-02
**Loại:** E2E | Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã vào phần Cài đặt (SM-027) và tắt âm thanh animation
- Có một thư hợp lệ chưa được mở, link còn hiệu lực

### Act (Thực hiện)
- Người nhận mở link thư hợp lệ lần đầu
- Chờ animation bắt đầu và kết thúc hoàn toàn

### Assert (Kiểm tra)
- Animation diễn ra đầy đủ bốn bước (phong bì mở → giấy cuộn ra → nội dung hiện → tem sáng lên)
- Không có âm thanh nào phát ra trong suốt quá trình animation
- Nội dung thư hiển thị đầy đủ sau khi animation kết thúc

---

## TC-17-003: Nút "Lưu tem vào Album" và "Trả lời" hiển thị sau animation với người đã đăng nhập

**AC liên quan:** AC-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người nhận đã đăng nhập vào tài khoản StampMail
- Có một thư hợp lệ chưa được mở, link còn hiệu lực
- Mở link thư và để animation chạy đến hết

### Act (Thực hiện)
- Chờ animation hoàn tất hoàn toàn (cả bốn bước kết thúc)
- Quan sát màn hình sau animation

### Assert (Kiểm tra)
- Nút "Lưu tem vào Album" hiển thị trên màn hình
- Nút "Trả lời" hiển thị trên màn hình
- Nội dung thư đầy đủ hiển thị bên dưới hoặc cùng màn hình

---

## TC-17-004: Nút "Tải StampMail" hiển thị với người dùng chưa có app

**AC liên quan:** AC-03 (trường hợp người chưa có app)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người nhận chưa cài app StampMail (truy cập qua web hoặc trình duyệt)
- Người nhận chưa đăng nhập
- Có một thư hợp lệ chưa được mở, link còn hiệu lực
- Để animation chạy đến hết

### Act (Thực hiện)
- Chờ animation hoàn tất hoàn toàn
- Quan sát màn hình sau animation

### Assert (Kiểm tra)
- Nút "Tải StampMail" hiển thị trên màn hình
- Nút "Lưu tem vào Album" và "Trả lời" không hiển thị (người dùng chưa đăng nhập)

---

## TC-17-005: Xem lại thư đã đọc từ hộp thư đến không có animation

**AC liên quan:** AC-04
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập vào tài khoản StampMail
- Có ít nhất một thư đã được đọc (đã mở trước đó) trong hộp thư đến (SM-018)

### Act (Thực hiện)
- Người dùng vào màn hình Hộp thư đến
- Nhấn vào thư đã đọc đó để xem lại

### Assert (Kiểm tra)
- Thư hiển thị ngay nội dung đầy đủ mà không có bất kỳ animation nào (không có phong bì mở, không có giấy cuộn ra)
- Nội dung thư, hình ảnh tem hiển thị tức thì
- Các nút "Lưu tem vào Album" và "Trả lời" hiển thị ngay lập tức

---

## TC-17-006: Người gửi nhận thông báo khi người nhận hoàn thành animation lần đầu

**AC liên quan:** AC-05
**Loại:** E2E | Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Người gửi A đã gửi thư tới người nhận B, đang đăng nhập trên thiết bị khác
- Link thư còn hiệu lực, chưa được mở lần nào
- Người nhận B mở link thư lần đầu

### Act (Thực hiện)
- Người nhận B để animation chạy đến hết (hoàn tất cả bốn bước)
- Thư được đánh dấu đã đọc sau khi animation kết thúc

### Assert (Kiểm tra)
- Người gửi A nhận được thông báo trong app rằng người nhận đã đọc thư
- Thông báo xuất hiện trong khoảng thời gian hợp lý sau khi animation kết thúc
- Thư trong danh sách đã gửi của người gửi A hiển thị trạng thái "đã đọc"

---

## TC-17-007: Người gửi nhận 15📮 khi thư được mở lần đầu qua link

**AC liên quan:** AC-06
**Loại:** E2E | Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Người gửi A đã gửi thư tới người nhận B
- Link thư còn hiệu lực, chưa được mở lần nào
- Ghi nhận số Dấu (📮) hiện tại của người gửi A trước khi thư được mở
- Người gửi A đã bật thông báo push (SM-026)

### Act (Thực hiện)
- Người nhận B mở link thư lần đầu
- Để animation chạy đến hết
- Thư được đánh dấu đã đọc

### Assert (Kiểm tra)
- Người gửi A nhận thêm 15📮 vào tổng số Dấu của mình
- Người gửi A nhận thông báo push: "Thư của bạn đã được mở — bạn nhận 15📮!"
- Số Dấu của người gửi A tăng đúng 15📮 so với trước khi thư được mở

---

## TC-17-008: Người gửi KHÔNG nhận thêm 📮 khi xem lại thư từ hộp thư đến

**AC liên quan:** AC-06 (trường hợp xem lại — BR-06)
**Loại:** E2E | Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Thư đã được người nhận B mở lần đầu qua link (người gửi A đã nhận 15📮 lần đầu)
- Ghi nhận số Dấu (📮) hiện tại của người gửi A sau lần mở đầu tiên
- Người nhận B đăng nhập vào hộp thư đến của mình

### Act (Thực hiện)
- Người nhận B vào Hộp thư đến và nhấn vào thư đã đọc để xem lại
- Thư hiển thị ngay nội dung (không có animation)

### Assert (Kiểm tra)
- Số Dấu (📮) của người gửi A KHÔNG thay đổi sau lần xem lại này
- Người gửi A KHÔNG nhận thêm bất kỳ thông báo nào về "đã mở thư"

---

## TC-17-009: Phóng to tem bằng cử chỉ banh ngón tay

**AC liên quan:** AC-07
**Loại:** E2E | Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người nhận đang xem nội dung thư sau khi animation kết thúc hoàn toàn
- Thư có tem đính kèm hiển thị trên màn hình
- Kết nối internet ổn định (hoặc thư đã tải xong)

### Act (Thực hiện)
- Người nhận đặt hai ngón tay lên vị trí tem trên màn hình
- Thực hiện cử chỉ banh ngón tay (pinch out) để phóng to tem
- Sau đó thực hiện cử chỉ chụm ngón tay (pinch in) để thu nhỏ tem về kích thước ban đầu

### Assert (Kiểm tra)
- Tem phóng to dần theo cử chỉ banh ngón tay
- Tem thu về kích thước ban đầu khi chụm ngón tay lại
- Nội dung thư KHÔNG bị thay đổi sau khi phóng to/thu nhỏ tem
- Chỉ là xem — không có thay đổi nào được lưu lại

---

## TC-17-010: Chặn mở thư khi thiết bị không có kết nối mạng

**AC liên quan:** AC-08
**Loại:** E2E | Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Thiết bị của người nhận đang không có kết nối internet (tắt wifi và dữ liệu di động)
- Có một link thư hợp lệ chưa được mở

### Act (Thực hiện)
- Người nhận nhấn link thư hợp lệ khi không có mạng
- Quan sát phản ứng của ứng dụng

### Assert (Kiểm tra)
- Ứng dụng KHÔNG bắt đầu animation
- Thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." hiển thị rõ ràng
- Không có màn hình trắng hoặc lỗi không rõ ràng

---

## TC-17-011: Chặn mở thư từ hộp thư đến khi không có mạng

**AC liên quan:** AC-08 (mở từ hộp thư đến khi mất mạng)
**Loại:** E2E | Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người nhận đã đăng nhập, có thư chưa đọc trong hộp thư đến
- Thiết bị đang không có kết nối internet (tắt wifi và dữ liệu di động)

### Act (Thực hiện)
- Người nhận vào Hộp thư đến và nhấn vào thư chưa đọc để mở
- Quan sát phản ứng của ứng dụng

### Assert (Kiểm tra)
- Ứng dụng KHÔNG bắt đầu animation
- Thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." hiển thị rõ ràng

---

## TC-17-012: Xem thư đã tải đầy đủ khi mất mạng giữa chừng

**AC liên quan:** AC-09
**Loại:** E2E | Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người nhận đã mở thư và animation đã hoàn tất, nội dung thư hiển thị đầy đủ (thư đã tải xong)
- Kết nối internet vẫn đang ổn định tại thời điểm này

### Act (Thực hiện)
- Trong khi người nhận đang xem nội dung thư, tắt kết nối internet (tắt wifi/dữ liệu di động)
- Người nhận tiếp tục đọc nội dung thư sau khi mất mạng

### Assert (Kiểm tra)
- Nội dung thư (văn bản, hình ảnh tem) vẫn hiển thị bình thường
- Thông báo "Đang xem ngoại tuyến" xuất hiện trên màn hình
- Nút "Lưu tem" bị vô hiệu hóa (không thể nhấn)
- Nút "Trả lời" bị vô hiệu hóa (không thể nhấn)
- Khi bật mạng trở lại, các nút "Lưu tem" và "Trả lời" hoạt động bình thường trở lại

---

## TC-17-013: Hệ thống tự động đánh dấu đã đọc và trao Dấu khi kết nối được khôi phục

**AC liên quan:** BR-10 (offline recovery)
**Loại:** E2E | Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Người nhận đã mở thư và xem xong animation nhưng thiết bị mất mạng trước khi hệ thống ghi nhận đã đọc
- Ghi nhận số Dấu (📮) hiện tại của người gửi
- Thiết bị hiện tại vẫn đang mất kết nối

### Act (Thực hiện)
- Bật lại kết nối internet trên thiết bị người nhận
- KHÔNG mở lại thư; chỉ khôi phục mạng và chờ

### Assert (Kiểm tra)
- Hệ thống tự động ghi nhận trạng thái đã đọc của thư (không cần mở lại)
- Người gửi nhận được thông báo đã đọc thư
- Người gửi nhận thêm 15📮 mà không cần người nhận thao tác thêm

---

## TC-17-014: Mất kết nối internet giữa chừng animation

**AC liên quan:** Mục 5 — Ngoại lệ lỗi mạng
**Loại:** E2E | Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Có một thư hợp lệ chưa được mở, link còn hiệu lực
- Người nhận mở link thư, animation đang chạy (ví dụ đang ở bước 2 — giấy cuộn ra)
- Tắt kết nối internet trên thiết bị trong khi animation đang diễn ra

### Act (Thực hiện)
- Để animation chạy đến thời điểm tắt mạng
- Tắt wifi/dữ liệu di động đột ngột giữa chừng animation
- Quan sát phản ứng của app

### Assert (Kiểm tra)
- Animation dừng lại
- Thông báo lỗi mạng hiển thị rõ ràng
- Nút "Thử lại" xuất hiện trên màn hình
- Sau khi bật lại kết nối internet và nhấn "Thử lại", animation tiếp tục hoặc khởi động lại từ đầu

---

## TC-17-015: Animation trên thiết bị yếu vẫn chạy đến cuối

**AC liên quan:** Mục 5 — Thiết bị yếu, animation bị lag
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Sử dụng thiết bị cấu hình thấp hoặc kích hoạt chế độ hạn chế hiệu suất
- Có một thư hợp lệ chưa được mở, link còn hiệu lực
- Kết nối internet ổn định

### Act (Thực hiện)
- Mở link thư trên thiết bị yếu
- Để animation tự chạy, không thao tác gì thêm
- Chú ý theo dõi xem animation có bị bỏ qua hoặc rút ngắn không

### Assert (Kiểm tra)
- Animation diễn ra đầy đủ cả bốn bước dù có độ trễ hoặc giật lag
- App không tự động bỏ qua animation hay nhảy thẳng vào nội dung thư
- Sau khi animation hoàn tất (dù chậm), nội dung thư đầy đủ hiển thị bình thường

---

## TC-17-016: Thoát màn hình animation giữa chừng — thư vẫn được đánh dấu đã mở

**AC liên quan:** Mục 5 — Người nhận thoát giữa chừng
**Loại:** E2E | Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Có một thư hợp lệ chưa được mở, link còn hiệu lực
- Người nhận đã đăng nhập vào StampMail
- Mở link thư, animation đang chạy ở bước giữa (ví dụ bước 2 hoặc 3)

### Act (Thực hiện)
- Người nhận nhấn nút Back hoặc chuyển sang màn hình khác khi animation đang diễn ra

### Assert (Kiểm tra)
- Thư được đánh dấu là đã mở (link thư không còn có thể mở lại animation lần nữa)
- Người nhận có thể tìm thấy thư này trong Hộp thư đến (SM-018)
- Khi mở lại thư từ Hộp thư đến, thư hiển thị ngay nội dung đầy đủ, không có animation

---

## TC-17-017: Lỗi máy chủ hoặc link hết hạn — hiển thị thông báo lỗi rõ ràng

**AC liên quan:** Mục 5 — Lỗi máy chủ / link hết hạn
**Loại:** E2E | Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Có một link thư đã hết hạn (hoặc link không hợp lệ)
- Kết nối internet ổn định

### Act (Thực hiện)
- Người nhận nhấn vào link thư hết hạn hoặc không hợp lệ
- Quan sát phản ứng của ứng dụng

### Assert (Kiểm tra)
- Màn hình hiển thị thông báo lỗi rõ ràng (ví dụ: "Không tìm thấy thư" hoặc "Link đã hết hạn")
- Nút "Thử lại" hiển thị trên màn hình
- Không có màn hình trắng hoặc lỗi không có thông tin
- Animation không bắt đầu

---

## TC-17-018: Lỗi tải tài nguyên animation nhưng nội dung thư vẫn hiển thị

**AC liên quan:** Mục 5 — Lỗi chỉ xảy ra khi tải tài nguyên animation
**Loại:** E2E | Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Người nhận mở link thư hợp lệ
- Nội dung thư tải được nhưng tài nguyên animation (hình ảnh phong bì, âm thanh) không tải được do lỗi mạng chậm hoặc lỗi cục bộ

### Act (Thực hiện)
- Người nhận mở link thư
- Quan sát khi tài nguyên animation không tải được

### Assert (Kiểm tra)
- Thư hiển thị nội dung văn bản ngay mà không có animation
- Người nhận thấy thông báo ngắn gọn rằng animation không tải được
- Không có màn hình trắng hay trạng thái chờ vô hạn

---

## TC-17-019: Người chưa đăng nhập mở thư qua link — yêu cầu đăng nhập khi nhấn nút lưu/trả lời

**AC liên quan:** Mục 5 — Người chưa đăng nhập
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người nhận CHƯA đăng nhập vào StampMail (chế độ khách / truy cập qua link web)
- Có một link thư hợp lệ chưa được mở

### Act (Thực hiện)
- Người nhận mở link thư
- Để animation chạy đến hết
- Sau animation, nhấn vào nút "Lưu tem vào Album" hoặc "Trả lời"

### Assert (Kiểm tra)
- Animation phát bình thường ở chế độ khách
- Sau animation, các nút "Lưu tem vào Album" và "Trả lời" hiển thị (nhưng yêu cầu đăng nhập khi nhấn)
- Khi nhấn nút, ứng dụng hiển thị yêu cầu đăng nhập hoặc tải app
- Nút "Tải StampMail" hiển thị với người chưa có app

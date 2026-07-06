# Test Cases — Bộ lọc màu & Chỉnh ảnh thủ công (006-bo-loc-mau)

## TC-06-001: Áp bộ lọc Free — ảnh xem trước thay đổi ngay

**AC liên quan:** AC-01
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản gói Thường (Free)
- Hoàn thành bước chọn ảnh (SM-005) với một ảnh hợp lệ
- Đang ở màn hình Bộ lọc màu (bước 2 luồng tạo tem)

### Act (Thực hiện)
- Nhấn vào một bộ lọc thuộc nhóm Cổ điển hoặc Retro/Vintage

### Assert (Kiểm tra)
- Ảnh xem trước thay đổi màu sắc ngay lập tức theo bộ lọc đã chọn (không cần nhấn nút xác nhận riêng)
- Bộ lọc được chọn hiển thị trạng thái đang active (highlight hoặc viền nổi bật)

---

## TC-06-002: Bộ lọc Premium bị khoá — hiển thị gợi ý nâng cấp

**AC liên quan:** AC-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản gói Thường (Free)
- Hoàn thành bước chọn ảnh (SM-005)
- Đang ở màn hình Bộ lọc màu

### Act (Thực hiện)
- Nhấn vào một bộ lọc thuộc nhóm Tâm trạng hoặc nhóm Mùa (bộ lọc Premium)

### Assert (Kiểm tra)
- Hệ thống hiển thị gợi ý nâng cấp lên gói Premium
- Ảnh xem trước KHÔNG thay đổi (bộ lọc Premium không được áp dụng)
- Người dùng có thể nhấn để đến màn hình Nâng cấp Premium (SM-028)

---

## TC-06-003: Thanh Sáng/Tối — ảnh xem trước thay đổi theo thời gian thực

**AC liên quan:** AC-03
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản bất kỳ
- Hoàn thành bước chọn ảnh (SM-005)
- Đang ở màn hình Bộ lọc màu, chưa điều chỉnh thanh nào

### Act (Thực hiện)
- Kéo thanh Sáng/Tối về phía Sáng (cực phải)
- Kéo thanh Sáng/Tối về phía Tối (cực trái)

### Assert (Kiểm tra)
- Khi kéo về phía Sáng: ảnh xem trước sáng lên rõ ràng theo thời gian thực trong lúc kéo
- Khi kéo về phía Tối: ảnh xem trước tối dần theo thời gian thực trong lúc kéo
- Không cần nhấn nút xác nhận riêng; thay đổi phản ánh ngay

---

## TC-06-004: Thanh Ấm/Lạnh — ảnh xem trước thay đổi theo thời gian thực

**AC liên quan:** AC-08
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản bất kỳ
- Hoàn thành bước chọn ảnh (SM-005)
- Đang ở màn hình Bộ lọc màu, chưa điều chỉnh thanh nào

### Act (Thực hiện)
- Kéo thanh Ấm/Lạnh về phía Ấm (cực phải)
- Kéo thanh Ấm/Lạnh về phía Lạnh (cực trái)

### Assert (Kiểm tra)
- Khi kéo về phía Ấm: màu ảnh xem trước ngả vàng/cam rõ ràng theo thời gian thực
- Khi kéo về phía Lạnh: màu ảnh xem trước ngả xanh rõ ràng theo thời gian thực
- Không cần nhấn nút xác nhận riêng

---

## TC-06-005: Thanh Nhạt/Đậm — ảnh xem trước thay đổi theo thời gian thực

**AC liên quan:** AC-09
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản bất kỳ
- Hoàn thành bước chọn ảnh (SM-005)
- Đang ở màn hình Bộ lọc màu, chưa điều chỉnh thanh nào

### Act (Thực hiện)
- Kéo thanh Nhạt/Đậm về phía Nhạt đến cùng (cực trái)
- Kéo thanh Nhạt/Đậm về phía Đậm đến cùng (cực phải)

### Assert (Kiểm tra)
- Khi kéo đến cực Nhạt: ảnh xem trước gần như chuyển sang đen trắng
- Khi kéo đến cực Đậm: màu sắc ảnh xem trước sặc sỡ hơn hẳn so với ảnh gốc
- Thay đổi hiển thị theo thời gian thực trong lúc kéo, không cần xác nhận riêng

---

## TC-06-006: Đặt lại ba thanh chỉnh tay về mặc định

**AC liên quan:** AC-10
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản bất kỳ
- Hoàn thành bước chọn ảnh (SM-005)
- Đang ở màn hình Bộ lọc màu
- Đã kéo cả ba thanh (Sáng/Tối, Ấm/Lạnh, Nhạt/Đậm) ra khỏi vị trí trung tâm

### Act (Thực hiện)
- Nhấn nút "Đặt lại"

### Assert (Kiểm tra)
- Cả ba thanh trở về vị trí trung tâm (mặc định)
- Ảnh xem trước quay về trạng thái chỉ có bộ lọc màu đang chọn (nếu có), không còn ảnh hưởng từ ba thanh
- Bộ lọc màu đang được chọn không bị thay đổi hoặc huỷ

---

## TC-06-007: Chọn "Gốc" bỏ toàn bộ bộ lọc màu

**AC liên quan:** AC-11
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản bất kỳ
- Hoàn thành bước chọn ảnh (SM-005)
- Đang ở màn hình Bộ lọc màu
- Đã chọn và đang áp một bộ lọc màu Free

### Act (Thực hiện)
- Chọn mục "Gốc" trong danh sách bộ lọc

### Assert (Kiểm tra)
- Bộ lọc màu bị bỏ hoàn toàn
- Ảnh xem trước chỉ phản ánh phần điều chỉnh từ ba thanh (nếu có); không có bộ lọc nào
- Mục "Gốc" hiển thị trạng thái đang active

---

## TC-06-008: Bộ lọc và chỉnh tay dùng đồng thời

**AC liên quan:** AC-04
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản bất kỳ
- Hoàn thành bước chọn ảnh (SM-005)
- Đang ở màn hình Bộ lọc màu

### Act (Thực hiện)
- Nhấn vào một bộ lọc Free (ví dụ: bộ lọc đầu tiên trong nhóm Cổ điển) để áp dụng
- Kéo thanh Ấm/Lạnh sang bên phải (hướng Ấm)

### Assert (Kiểm tra)
- Ảnh xem trước phản ánh đồng thời hiệu ứng của bộ lọc đã chọn VÀ điều chỉnh tông màu Ấm/Lạnh
- Hai thay đổi cùng tồn tại và kết hợp trên ảnh xem trước, không cái nào ghi đè cái kia

---

## TC-06-009: Bộ lọc Premium mở khoá khi dùng gói Premium

**AC liên quan:** AC-05
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản đã nâng cấp gói Premium
- Hoàn thành bước chọn ảnh (SM-005)

### Act (Thực hiện)
- Vào màn hình Bộ lọc màu
- Quan sát danh sách bộ lọc nhóm Tâm trạng và nhóm Mùa
- Nhấn vào một bộ lọc trong nhóm Tâm trạng

### Assert (Kiểm tra)
- Tất cả 16 bộ lọc đều hiển thị không có biểu tượng khoá
- Bộ lọc Premium nhấn được bình thường; ảnh xem trước thay đổi ngay lập tức
- Không có thông báo gợi ý nâng cấp xuất hiện

---

## TC-06-010: Chỉnh màu và bộ lọc Free hoạt động bình thường khi offline

**AC liên quan:** AC-06
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản bất kỳ
- Hoàn thành bước chọn ảnh (SM-005)
- Đang ở màn hình Bộ lọc màu
- Tắt hoàn toàn kết nối mạng (tắt Wi-Fi và dữ liệu di động trên thiết bị)

### Act (Thực hiện)
- Kéo thanh Sáng/Tối
- Kéo thanh Ấm/Lạnh
- Kéo thanh Nhạt/Đậm
- Nhấn vào một bộ lọc Free

### Assert (Kiểm tra)
- Ảnh xem trước vẫn cập nhật bình thường theo từng thao tác
- Không hiển thị thông báo lỗi mạng nào
- Tất cả ba thanh chỉnh tay và bộ lọc Free hoạt động như khi có mạng

---

## TC-06-011: Bộ lọc Premium bị khoá khi offline và chưa xác nhận gói

**AC liên quan:** AC-07
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Tài khoản vừa nâng cấp Premium nhưng chưa đồng bộ trạng thái gói (chưa mở lại app sau khi nâng cấp)
- Tắt hoàn toàn kết nối mạng trên thiết bị
- Mở ứng dụng, hoàn thành bước chọn ảnh (SM-005)
- Đang ở màn hình Bộ lọc màu

### Act (Thực hiện)
- Nhấn vào một bộ lọc Premium (nhóm Tâm trạng hoặc nhóm Mùa)

### Assert (Kiểm tra)
- Hệ thống hiển thị thông báo: "Không thể xác minh gói Premium. Vui lòng kiểm tra kết nối và thử lại."
- Bộ lọc Premium không được áp dụng, ảnh xem trước không thay đổi
- Bộ lọc Premium vẫn ở trạng thái khoá

---

## TC-06-012: Bộ lọc Premium đã xác nhận trước — vẫn khả dụng khi offline

**AC liên quan:** AC-07, BR-08
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản Premium đã xác nhận trạng thái gói (đã mở app khi có mạng ít nhất một lần)
- Tắt hoàn toàn kết nối mạng trên thiết bị
- Hoàn thành bước chọn ảnh (SM-005)
- Đang ở màn hình Bộ lọc màu

### Act (Thực hiện)
- Nhấn vào một bộ lọc Premium (nhóm Tâm trạng hoặc nhóm Mùa)

### Assert (Kiểm tra)
- Bộ lọc Premium được áp dụng bình thường
- Ảnh xem trước thay đổi ngay lập tức theo bộ lọc đã chọn
- Không hiển thị thông báo lỗi hoặc yêu cầu kết nối mạng

---

## TC-06-013: Chuyển sang bước tiếp theo (SM-008) khi offline

**AC liên quan:** BR-09
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản bất kỳ
- Hoàn thành bước chọn ảnh (SM-005)
- Đang ở màn hình Bộ lọc màu; đã áp một bộ lọc và điều chỉnh thanh trượt
- Tắt hoàn toàn kết nối mạng trên thiết bị

### Act (Thực hiện)
- Nhấn nút "Tiếp theo" để chuyển sang bước trang trí tem (SM-008)

### Assert (Kiểm tra)
- Ứng dụng chuyển sang màn hình SM-008 thành công, không bị chặn
- Dữ liệu chỉnh ảnh (bộ lọc và thanh điều chỉnh) được giữ nguyên khi sang bước tiếp
- Không hiển thị thông báo lỗi mạng liên quan đến bước chuyển này

---

## TC-06-014: Quay lại bước chọn ảnh — ảnh gốc nguyên vẹn, bộ lọc bị huỷ

**AC liên quan:** BR-06
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản bất kỳ
- Hoàn thành bước chọn ảnh (SM-005)
- Đang ở màn hình Bộ lọc màu
- Đã chọn một bộ lọc Free và điều chỉnh ít nhất một thanh trượt

### Act (Thực hiện)
- Nhấn nút Quay lại để trở về bước chọn ảnh (SM-005)

### Assert (Kiểm tra)
- Màn hình chuyển về bước chọn ảnh
- Ảnh gốc vẫn nguyên vẹn, không bị thay đổi bởi bộ lọc hoặc thanh điều chỉnh đã áp
- Không có bộ lọc nào được lưu lại từ phiên bộ lọc này

---

## TC-06-015: Thoát app giữa chừng — không lưu trạng thái bộ lọc

**AC liên quan:** BR-06 (ngoại lệ thoát app)
**Loại:** Manual
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản bất kỳ
- Hoàn thành bước chọn ảnh (SM-005)
- Đang ở màn hình Bộ lọc màu
- Đã chọn một bộ lọc và điều chỉnh các thanh trượt

### Act (Thực hiện)
- Thoát ứng dụng (swipe off từ app switcher hoặc ép buộc thoát)
- Mở lại ứng dụng StampMail

### Assert (Kiểm tra)
- Ứng dụng mở về màn hình chính (không phải màn hình Bộ lọc màu)
- Trạng thái bộ lọc đang chọn không được lưu lại
- Không có ảnh tạm nào còn tồn tại từ phiên trước

---

## TC-06-016: Người dùng Free thấy biểu tượng khoá trên bộ lọc Premium

**AC liên quan:** AC-02, BR-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản gói Thường (Free)
- Hoàn thành bước chọn ảnh (SM-005)

### Act (Thực hiện)
- Vào màn hình Bộ lọc màu
- Cuộn đến nhóm Tâm trạng và nhóm Mùa

### Assert (Kiểm tra)
- Tám bộ lọc thuộc nhóm Tâm trạng và Mùa đều hiển thị biểu tượng khoá (hoặc dấu hiệu Premium)
- Tám bộ lọc Free (nhóm Cổ điển và Retro/Vintage) không có biểu tượng khoá

---

## TC-06-017: Tổng số bộ lọc hiển thị đúng theo nhóm

**AC liên quan:** BR-01, BR-02, BR-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản bất kỳ
- Hoàn thành bước chọn ảnh (SM-005)

### Act (Thực hiện)
- Vào màn hình Bộ lọc màu
- Đếm số lượng bộ lọc trong từng nhóm

### Assert (Kiểm tra)
- Nhóm Cổ điển: đúng 4 bộ lọc
- Nhóm Retro/Vintage: đúng 4 bộ lọc
- Nhóm Tâm trạng: đúng 4 bộ lọc
- Nhóm Mùa: đúng 4 bộ lọc
- Tổng cộng: đúng 16 bộ lọc (chưa tính mục "Gốc")

---

## TC-06-018: Gợi ý nâng cấp dẫn đến màn hình SM-028

**AC liên quan:** AC-02, BR-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản gói Thường (Free)
- Đang ở màn hình Bộ lọc màu, popup gợi ý nâng cấp đang hiển thị (sau khi nhấn bộ lọc Premium)

### Act (Thực hiện)
- Nhấn nút "Nâng cấp" trong popup gợi ý nâng cấp

### Assert (Kiểm tra)
- Ứng dụng điều hướng đến màn hình Nâng cấp Premium (SM-028)
- Màn hình Bộ lọc màu và trạng thái ảnh được bảo toàn để người dùng có thể quay lại

---

## TC-06-019: Ba thanh + bộ lọc áp đồng thời — kết quả tổng hợp đúng

**AC liên quan:** AC-04, BR-04
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản bất kỳ
- Hoàn thành bước chọn ảnh (SM-005)
- Đang ở màn hình Bộ lọc màu

### Act (Thực hiện)
- Chọn một bộ lọc Free bất kỳ
- Kéo thanh Sáng/Tối đến giữa (nửa mức Sáng)
- Kéo thanh Ấm/Lạnh đến cực phải (Ấm nhất)
- Kéo thanh Nhạt/Đậm đến giữa (nửa mức Đậm)

### Assert (Kiểm tra)
- Ảnh xem trước phản ánh tổng hợp: màu của bộ lọc + độ sáng + tông ấm + độ bão hòa
- Không có hiệu ứng nào bị mất hoặc ghi đè lên nhau không đúng

---

## TC-06-020: Chuyển nhanh giữa các bộ lọc Free — xem trước luôn đúng bộ lọc cuối

**AC liên quan:** AC-01, BR-05
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản bất kỳ
- Hoàn thành bước chọn ảnh (SM-005)
- Đang ở màn hình Bộ lọc màu

### Act (Thực hiện)
- Nhấn nhanh lần lượt các bộ lọc Free: bộ lọc 1 → bộ lọc 2 → bộ lọc 3 → bộ lọc 4
- Dừng lại ở bộ lọc 4

### Assert (Kiểm tra)
- Ảnh xem trước hiển thị đúng hiệu ứng của bộ lọc 4 (bộ lọc được chọn cuối cùng)
- Không bị "kẹt" ở hiệu ứng của bộ lọc trước đó

---

## TC-06-021: Thiết bị yếu — xem trước không đứng hình

**AC liên quan:** Mục 5 (Trường hợp ngoại lệ — thiết bị yếu)
**Loại:** Manual
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Sử dụng thiết bị thật có cấu hình thấp (RAM 2 GB, CPU yếu)
- Đăng nhập, hoàn thành bước chọn ảnh với ảnh kích thước lớn (trên 5 MB)
- Đang ở màn hình Bộ lọc màu

### Act (Thực hiện)
- Nhấn nhanh lần lượt nhiều bộ lọc Free liên tiếp
- Kéo thanh Sáng/Tối liên tục qua lại

### Assert (Kiểm tra)
- Ảnh xem trước có thể có độ trễ nhỏ nhưng phải cập nhật trong vài giây
- Ứng dụng không bị đứng hình (freeze) hoặc crash
- Giao diện vẫn phản hồi được các thao tác của người dùng

---

## TC-06-022: Người dùng chưa đăng nhập — bộ lọc Free khả dụng, Premium bị khoá

**AC liên quan:** Mục 5 (Trường hợp ngoại lệ — chưa đăng nhập)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Chưa đăng nhập vào ứng dụng StampMail
- Hoàn thành bước chọn ảnh (SM-005) với tư cách khách

### Act (Thực hiện)
- Vào màn hình Bộ lọc màu
- Nhấn vào một bộ lọc Free
- Nhấn vào một bộ lọc Premium

### Assert (Kiểm tra)
- Bộ lọc Free được áp dụng bình thường, ảnh xem trước thay đổi ngay
- Bộ lọc Premium bị khoá; nhấn vào hiển thị gợi ý đăng nhập hoặc nâng cấp
- Bộ lọc Premium không được áp dụng

---

## TC-06-023: Kéo thanh Sáng/Tối về cực trị — nội dung ảnh không bị mất

**AC liên quan:** AC-03, BR-04
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản bất kỳ
- Hoàn thành bước chọn ảnh (SM-005)
- Đang ở màn hình Bộ lọc màu

### Act (Thực hiện)
- Kéo thanh Sáng/Tối về cực tối (tận cùng bên trái)
- Sau đó kéo về cực sáng (tận cùng bên phải)

### Assert (Kiểm tra)
- Ở cực tối: ảnh xem trước rất tối nhưng không hoàn toàn đen; nội dung ảnh vẫn còn nhận ra
- Ở cực sáng: ảnh xem trước rất sáng nhưng nội dung ảnh vẫn còn nhận ra
- Không có crash hoặc hiển thị lỗi nào

---

## TC-06-024: Đặt lại — ba thanh về trung tâm nhưng bộ lọc không thay đổi

**AC liên quan:** AC-10, BR-10
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản bất kỳ
- Hoàn thành bước chọn ảnh (SM-005)
- Đang ở màn hình Bộ lọc màu
- Đã chọn bộ lọc Free thứ hai và đã kéo cả ba thanh ra khỏi vị trí trung tâm

### Act (Thực hiện)
- Nhấn nút "Đặt lại"

### Assert (Kiểm tra)
- Ba thanh đều trở về vị trí trung tâm
- Bộ lọc Free thứ hai vẫn còn được chọn (không bị huỷ)
- Ảnh xem trước phản ánh bộ lọc Free thứ hai nhưng không còn ảnh hưởng từ ba thanh

---

## TC-06-025: Mục "Gốc" luôn hiển thị trong danh sách bộ lọc

**AC liên quan:** AC-11, BR-11
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Đăng nhập bằng tài khoản bất kỳ (Free hoặc Premium)
- Hoàn thành bước chọn ảnh (SM-005)

### Act (Thực hiện)
- Vào màn hình Bộ lọc màu
- Quan sát danh sách bộ lọc

### Assert (Kiểm tra)
- Mục "Gốc" luôn hiển thị trong danh sách bộ lọc (đầu hoặc vị trí cố định)
- Mục "Gốc" không bị khoá với bất kỳ loại tài khoản nào

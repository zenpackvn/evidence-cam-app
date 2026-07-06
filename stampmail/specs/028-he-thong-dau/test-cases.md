# Test Cases — Hệ thống Dấu (SM-033 / 028-he-thong-dau)

## TC-28-001: Nhận 10📮 khi chia sẻ tem lần đầu trong tuần

**AC liên quan:** AC-01
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã đăng nhập, vừa lưu tem thành công
- Tuần hiện tại chưa có lần chia sẻ nào được thưởng Dấu

### Act (Thực hiện)
- Nhấn "Chia sẻ & nhận 10📮" từ màn hình sau khi lưu tem
- Native share sheet hiện ra

### Assert (Kiểm tra)
- Số Dấu hiển thị trong app tăng thêm 10📮 ngay lập tức
- Hiển thị thông báo nhỏ "Bạn kiếm được 10📮"

---

## TC-28-002: Nhận 10📮 ở lần chia sẻ thứ 2 và thứ 3 trong tuần

**AC liên quan:** AC-01
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã chia sẻ 1 lần trong tuần, còn 2 lượt được thưởng

### Act (Thực hiện)
- Nhấn "Chia sẻ & nhận 10📮" lần thứ 2

### Assert (Kiểm tra)
- Số Dấu tăng thêm 10📮
- Tổng Dấu đã nhận từ chia sẻ trong tuần: 20📮

---

## TC-28-003: Lần chia sẻ thứ 4 không trao Dấu nhưng share sheet vẫn mở

**AC liên quan:** AC-02
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã chia sẻ đủ 3 lần trong tuần này (đã nhận 30📮 từ chia sẻ)
- Ghi nhớ số Dấu hiện tại

### Act (Thực hiện)
- Nhấn nút chia sẻ lần thứ 4

### Assert (Kiểm tra)
- Native share sheet vẫn mở bình thường (tính năng chia sẻ không bị khóa)
- Số Dấu không thay đổi
- Hiển thị thông báo "Đã đạt giới hạn chia sẻ tuần này"

---

## TC-28-004: Giới hạn chia sẻ reset vào thứ Hai — nhận Dấu bình thường tuần mới

**AC liên quan:** AC-02
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã chia sẻ 3 lần trong tuần trước (hết giới hạn)
- Thời gian đã qua thứ Hai 00:00 của tuần mới theo múi giờ thiết bị

### Act (Thực hiện)
- Nhấn nút chia sẻ tem

### Assert (Kiểm tra)
- Số Dấu tăng thêm 10📮 (tuần mới, giới hạn đã reset)
- Không còn thông báo "đạt giới hạn"

---

## TC-28-005: Nhận 5📮 ngay khi tạo link thư thành công

**AC liên quan:** AC-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã soạn thư hoàn chỉnh, sẵn sàng gửi
- Ghi nhớ số Dấu hiện tại

### Act (Thực hiện)
- Nhấn "Gửi thư" → link thư được tạo thành công

### Assert (Kiểm tra)
- Số Dấu tăng thêm 5📮 ngay tại màn hình xác nhận gửi
- Hiển thị thông báo "Bạn kiếm được 5📮"

---

## TC-28-006: Gửi nhiều thư liên tiếp — không giới hạn số lần nhận 5📮

**AC liên quan:** AC-03 (BR-08)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã gửi 5 thư trong ngày và nhận 25📮
- Ghi nhớ số Dấu hiện tại

### Act (Thực hiện)
- Gửi thêm thư thứ 6

### Assert (Kiểm tra)
- Số Dấu tăng thêm 5📮 (tổng 30📮 từ gửi thư)
- Không có thông báo đạt giới hạn (vì không giới hạn số lần gửi thư)

---

## TC-28-007: Nhận 15📮 khi người nhận hoàn thành xem animation lần đầu

**AC liên quan:** AC-04
**Loại:** Integration
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng A đã gửi thư cho người nhận B (B chưa mở thư)
- Ghi nhớ số Dấu của A

### Act (Thực hiện)
- Người nhận B mở link thư và xem animation cho đến khi kết thúc hoàn toàn

### Assert (Kiểm tra)
- Số Dấu của A tăng thêm 15📮
- A nhận thông báo push (nếu đã bật SM-026): "Thư của bạn đã được mở — bạn nhận 15📮!"

---

## TC-28-008: Không nhận 15📮 khi người nhận mở thư lần thứ 2 trở đi

**AC liên quan:** AC-04 (BR-09)
**Loại:** Integration
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người nhận B đã mở thư lần đầu và A đã nhận 15📮
- Ghi nhớ số Dấu của A

### Act (Thực hiện)
- B mở lại link thư lần thứ 2

### Assert (Kiểm tra)
- Số Dấu của A không tăng thêm
- A không nhận thông báo push mới

---

## TC-28-009: Không nhận 15📮 khi animation bị gián đoạn giữa chừng

**AC liên quan:** AC-04 (Mục 5 — trường hợp ngoại lệ)
**Loại:** Integration
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người nhận đang xem animation thư, mất mạng trước khi animation kết thúc

### Act (Thực hiện)
- Animation dừng do mất mạng, không hoàn tất

### Assert (Kiểm tra)
- Người gửi không nhận 15📮
- Khi người nhận xem lại và animation hoàn tất đầy đủ, Dấu mới được trao

---

## TC-28-010: Nhận 50📮 khi người nhận cài app lần đầu (lượt ≤ 5 trong tháng)

**AC liên quan:** AC-05
**Loại:** Integration
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng A đã gửi thư cho B — B chưa có tài khoản StampMail
- A chưa nhận đủ 5 lượt thưởng cài app trong tháng này

### Act (Thực hiện)
- B cài StampMail từ link thư và tạo tài khoản mới thành công

### Assert (Kiểm tra)
- Số Dấu của A tăng thêm 50📮
- A nhận thông báo "Bạn vừa giới thiệu người dùng mới và nhận 50📮!"

---

## TC-28-011: Không nhận 50📮 khi người nhận đã có tài khoản StampMail từ trước

**AC liên quan:** AC-05 (Mục 5 — trường hợp ngoại lệ)
**Loại:** Integration
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người nhận B đã có tài khoản StampMail từ trước
- A gửi thư cho B

### Act (Thực hiện)
- B mở thư bằng tài khoản cũ đã có

### Assert (Kiểm tra)
- Số Dấu của A không tăng thêm 50📮
- A không nhận thông báo "giới thiệu người dùng mới"

---

## TC-28-012: Không nhận thêm khi đã đủ 5 lượt cài app trong tháng

**AC liên quan:** AC-06
**Loại:** Integration
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng A đã nhận đủ 5 lần thưởng cài app trong tháng này (250📮 từ giới thiệu)

### Act (Thực hiện)
- Người nhận thứ 6 cài StampMail từ link thư của A

### Assert (Kiểm tra)
- Số Dấu của A không thay đổi
- A không nhận thông báo thưởng 50📮

---

## TC-28-013: Giới hạn tháng (cài app) reset vào ngày 1 — nhận Dấu bình thường tháng mới

**AC liên quan:** AC-06 (Mục 5 — trường hợp ngoại lệ)
**Loại:** Integration
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng A đã nhận đủ 5 lượt cài app trong tháng trước
- Hiện tại đã sang ngày 1 của tháng mới

### Act (Thực hiện)
- Người nhận mới (tài khoản hoàn toàn mới) cài app từ link thư của A

### Assert (Kiểm tra)
- Số Dấu của A tăng thêm 50📮 (tháng mới, giới hạn đã reset)

---

## TC-28-014: Tiêu 50📮 mở sticker pack thành công

**AC liên quan:** AC-07
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng gói Thường có ≥ 50📮
- Có ít nhất một bộ sticker đặc biệt chưa mở khóa

### Act (Thực hiện)
- Nhấn vào bộ sticker đặc biệt bị khóa
- Chọn "Dùng 50📮 để mở bộ này"
- Xác nhận

### Assert (Kiểm tra)
- Bộ sticker mở vĩnh viễn, khả dụng ngay trong phiên này
- Số Dấu giảm đúng 50📮
- Biểu tượng khóa biến mất, sticker có thể chọn và dùng ngay

---

## TC-28-015: Tiêu 80📮 mở kiểu viền thành công

**AC liên quan:** AC-08
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng gói Thường có ≥ 80📮
- Có kiểu viền chưa mở khóa

### Act (Thực hiện)
- Vào màn hình chọn viền tem (SM-009)
- Nhấn vào kiểu viền bị khóa
- Chọn "Dùng 80📮 để mở kiểu viền này" và xác nhận

### Assert (Kiểm tra)
- Kiểu viền mở vĩnh viễn, áp được ngay
- Số Dấu giảm đúng 80📮
- Kiểu viền đó không còn hiển thị khóa trong các lần dùng tiếp theo

---

## TC-28-016: Không đủ Dấu — hiển thị số thiếu và 2 lựa chọn

**AC liên quan:** AC-09
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng chỉ có 30📮
- Nhấn vào bộ sticker cần 50📮

### Act (Thực hiện)
- Màn hình gợi ý hiển thị

### Assert (Kiểm tra)
- Hiển thị "Bạn cần thêm 20📮 nữa" (50 − 30 = 20)
- Có đúng hai lựa chọn: "Chia sẻ tem hoặc gửi thư để kiếm thêm" và "Mua Dấu"
- Bộ sticker không được mở khóa

---

## TC-28-017: Lần đầu kiếm Dấu — màn hình giới thiệu hệ thống xuất hiện

**AC liên quan:** AC-10
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng chưa từng kiếm Dấu lần nào (tài khoản mới hoặc chưa thực hiện hành động nào)

### Act (Thực hiện)
- Thực hiện hành động kiếm Dấu lần đầu (ví dụ: gửi thư → nhận 5📮)

### Assert (Kiểm tra)
- Hệ thống hiển thị màn hình giới thiệu: "Bạn kiếm được [X]📮 đầu tiên! Tích Dấu để mở sticker và viền đặc biệt"
- Sau khi đóng màn hình, quay về luồng chính bình thường
- Màn hình giới thiệu không xuất hiện lại ở lần kiếm Dấu thứ 2 trở đi

---

## TC-28-018: Người dùng chưa kiếm Dấu lần nào — không thấy UI Dấu

**AC liên quan:** AC-10 (BR-04)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng mới chưa từng kiếm Dấu lần nào

### Act (Thực hiện)
- Mở app, vào màn hình chính và trang hồ sơ

### Assert (Kiểm tra)
- Không hiển thị bất kỳ UI nào liên quan đến Dấu (số dư, lịch sử, nút mở item bằng Dấu)

---

## TC-28-019: Item đã mở không bị khóa lại sau khi đăng xuất/đăng nhập

**AC liên quan:** AC-11
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã dùng 50📮 mở bộ sticker thành công
- Đăng xuất khỏi tài khoản

### Act (Thực hiện)
- Đăng nhập lại bằng cùng tài khoản đó
- Vào màn hình trang trí tem

### Assert (Kiểm tra)
- Bộ sticker đó vẫn khả dụng, không hiển thị khóa
- Không yêu cầu tiêu thêm Dấu

---

## TC-28-020: Item đã mở không bị khóa lại sau khi khởi động lại app

**AC liên quan:** AC-11
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đã dùng 80📮 mở kiểu viền thành công
- Đóng app hoàn toàn

### Act (Thực hiện)
- Mở lại app vào ngày hôm sau

### Assert (Kiểm tra)
- Kiểu viền đó vẫn khả dụng, không bị khóa lại
- Số Dấu không bị trừ thêm

---

## TC-28-021: Dấu không giảm sau 3 tháng không dùng app

**AC liên quan:** AC-12
**Loại:** Integration
**Tự động hóa:** 🚫 Không thể

### Arrange (Chuẩn bị)
- Người dùng có 80📮, ghi lại ngày kiểm tra
- Không mở app và không thực hiện bất kỳ hành động nào trong 3 tháng

### Act (Thực hiện)
- Mở app sau 3 tháng

### Assert (Kiểm tra)
- Số Dấu hiển thị vẫn là 80📮, không bị trừ

---

## TC-28-022: Tiêu 30📮 mở tem mẫu thành công

**AC liên quan:** AC-13
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng có ≥ 30📮
- Có tem mẫu chưa mở khóa trong Bộ tem mẫu (SM-035)

### Act (Thực hiện)
- Mở Bộ tem mẫu, nhấn vào tem bị khóa
- Chọn "Dùng 30📮 để mở tem này" và xác nhận

### Assert (Kiểm tra)
- Tem mẫu mở vĩnh viễn
- Số Dấu giảm đúng 30📮
- Nút đổi thành "Lưu vào Album"

---

## TC-28-023: Xem số Dấu khi mất mạng — hiển thị từ lần đồng bộ cuối

**AC liên quan:** AC-14
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đã mở app ít nhất một lần khi có mạng, số Dấu đã được đồng bộ (ví dụ: 75📮)
- Tắt kết nối mạng trên thiết bị

### Act (Thực hiện)
- Vào màn hình hiển thị số Dấu (màn hình chính hoặc trang hồ sơ)

### Assert (Kiểm tra)
- App hiển thị số Dấu từ lần đồng bộ cuối cùng (75📮)
- Kèm thông báo "Đang xem ngoại tuyến — số Dấu có thể chưa được cập nhật mới nhất"
- Số Dấu được làm mới ngay khi bật mạng trở lại

---

## TC-28-024: Chặn tiêu Dấu mở sticker khi mất mạng

**AC liên quan:** AC-15
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đang mất kết nối mạng
- Người dùng có ≥ 50📮 và nhấn vào bộ sticker bị khóa

### Act (Thực hiện)
- Chọn "Dùng 50📮 để mở bộ này" và xác nhận thao tác

### Assert (Kiểm tra)
- Hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."
- Số Dấu không bị trừ
- Bộ sticker vẫn ở trạng thái khóa

---

## TC-28-025: Chặn mua Dấu bằng tiền khi mất mạng

**AC liên quan:** AC-15 (BR-17)
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đang mất kết nối mạng
- Người dùng nhấn "Mua Dấu" và chọn gói 100📮

### Act (Thực hiện)
- Xác nhận thao tác mua

### Assert (Kiểm tra)
- Hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."
- Không thực hiện giao dịch IAP
- Số Dấu không thay đổi

---

## TC-28-026: Nhận Dấu từ Chain Unlock sau khi kết nối được khôi phục

**AC liên quan:** BR-18
**Loại:** Integration
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người gửi A đang mất kết nối mạng
- Trong khi A mất mạng, người nhận B mở thư và hoàn thành animation (sự kiện ghi nhận phía máy chủ)

### Act (Thực hiện)
- A bật mạng trở lại và mở app

### Assert (Kiểm tra)
- Số Dấu của A tăng thêm 15📮 ngay khi kết nối được khôi phục
- A nhận thông báo tích lũy về Dấu vừa được cộng

---

## TC-28-027: Số Dấu hiển thị cập nhật ngay sau khi nhận

**AC liên quan:** AC-03 (BR-03)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng đang ở màn hình chính, thấy số Dấu hiện tại (ví dụ: 45📮)

### Act (Thực hiện)
- Gửi thư thành công

### Assert (Kiểm tra)
- Số Dấu trên màn hình chính cập nhật thành 50📮 ngay (không cần reload trang)

---

## TC-28-028: Mua 100📮 qua IAP — Dấu được cộng thành công

**AC liên quan:** BR-15
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng có 20📮 và muốn mua thêm
- Phương thức thanh toán hợp lệ đã cài trong App Store/Google Play

### Act (Thực hiện)
- Vào màn hình mua Dấu
- Chọn gói 100📮 (29.000đ)
- Xác nhận thanh toán qua App Store/Google Play

### Assert (Kiểm tra)
- Số Dấu tăng thêm 100📮 (tổng: 120📮)
- Dấu mua có cùng tính chất: không hết hạn, dùng được để mở item

---

## TC-28-029: Mua Dấu lỗi thanh toán — không cộng Dấu, không trừ tiền

**AC liên quan:** BR-15 (Mục 5 — trường hợp ngoại lệ)
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Giao dịch IAP thất bại (thẻ hết hạn hoặc bị từ chối)
- Ghi nhớ số Dấu hiện tại

### Act (Thực hiện)
- Cố mua gói 100📮

### Assert (Kiểm tra)
- Số Dấu không thay đổi
- Không trừ tiền
- Hiển thị thông báo lỗi và hướng dẫn liên hệ hỗ trợ

---

## TC-28-030: Gửi thư xong xóa thư — 5📮 đã trao không bị thu hồi

**AC liên quan:** BR-08 (Mục 5 — trường hợp ngoại lệ)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng vừa gửi thư và nhận 5📮
- Ghi nhớ số Dấu hiện tại

### Act (Thực hiện)
- Xóa thư vừa gửi khỏi hộp thư đã gửi

### Assert (Kiểm tra)
- Số Dấu giữ nguyên (không bị thu hồi 5📮)

---

## TC-28-031: Thoát app giữa chừng giao dịch tiêu Dấu chưa hoàn tất

**AC liên quan:** BR-17 (Mục 5 — trường hợp ngoại lệ)
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Người dùng đang ở màn hình xác nhận tiêu 50📮 mở sticker, chưa nhấn xác nhận cuối

### Act (Thực hiện)
- Thoát app (kill app) trước khi xác nhận giao dịch

### Assert (Kiểm tra)
- Khi mở lại app, bộ sticker vẫn ở trạng thái khóa
- Số Dấu không thay đổi (không bị trừ)

---

## TC-28-032: Lỗi tải số Dấu — hiển thị skeleton và nút Thử lại

**AC liên quan:** BR-16 (Mục 5 — trường hợp ngoại lệ)
**Loại:** E2E
**Tự động hóa:** 🔲 Manual

### Arrange (Chuẩn bị)
- Mạng có nhưng máy chủ không phản hồi (lỗi server hoặc timeout)

### Act (Thực hiện)
- Mở màn hình hiển thị số Dấu

### Assert (Kiểm tra)
- Màn hình hiển thị trạng thái skeleton hoặc icon lỗi
- Có nút "Thử lại" khả dụng
- Không hiển thị giá trị số Dấu sai lệch
- Nhấn "Thử lại" → gửi lại yêu cầu tải số dư Dấu

---

## TC-28-033: Người dùng chưa đăng nhập — ẩn toàn bộ UI Dấu

**AC liên quan:** BR-17 (Mục 5 — trường hợp ngoại lệ: chưa đăng nhập)
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng chưa đăng nhập (hoặc đã đăng xuất)

### Act (Thực hiện)
- Mở app, duyệt qua màn hình chính, trang hồ sơ, màn hình sticker, màn hình viền

### Assert (Kiểm tra)
- Không hiển thị số dư Dấu ở bất kỳ nơi nào
- Không hiển thị lịch sử Dấu
- Không hiển thị nút mở item bằng Dấu
- Sau khi đăng nhập, UI Dấu xuất hiện bình thường (nếu đã từng kiếm Dấu)

---

## TC-28-034: Số Dấu nhất quán giữa các màn hình khác nhau trong app

**AC liên quan:** BR-03
**Loại:** E2E
**Tự động hóa:** ✅ Maestro

### Arrange (Chuẩn bị)
- Người dùng có số Dấu cụ thể (ví dụ: 120📮)

### Act (Thực hiện)
- Mở lần lượt: màn hình chính → trang hồ sơ → màn hình sticker (SM-008) → màn hình viền (SM-009) → Bộ tem mẫu (SM-035)

### Assert (Kiểm tra)
- Số Dấu hiển thị là 120📮 ở tất cả các màn hình (nhất quán, không lệch nhau)

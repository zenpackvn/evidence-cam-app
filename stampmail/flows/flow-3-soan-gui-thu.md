# Flow 3 · Soạn & Gửi thư

Từ chọn template đến gửi thư đi qua MXH.

---

## Chọn template thư (SM-012)

> Nguồn: `specs/010-chon-template-thu.md`

**Màn hình & trạng thái:**

- **Danh sách template**: List-default · List-premium-locked · List-offline · List-error
- **Xem trước template**: Preview-free · Preview-premium

### 1. Mục đích nghiệp vụ

Cung cấp cho người dùng các mẫu thư phù hợp theo dịp và tâm trạng — giúp người dùng bắt đầu soạn thư nhanh hơn mà không phải bắt đầu từ trang trắng. Mỗi template mang phong cách nền giấy và bố cục riêng phù hợp với chủ đề.

### 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đã đăng nhập muốn soạn thư mới.
- **Khi nào dùng:** Bước đầu tiên khi bắt đầu soạn thư mới.
- **Điều kiện tiên quyết:** Đã đăng nhập (SM-001).
- **Phạm vi:** Xem danh sách template, xem trước, chọn một template. Không bao gồm soạn nội dung (SM-013) hay đính tem (SM-014).

### 3. Quy tắc nghiệp vụ

- **BR-01 — Danh sách template theo chủ đề:** Template được nhóm theo các chủ đề dịp: sinh nhật, tình yêu, cảm ơn, chúc mừng, nhớ nhung, lễ hội, và các chủ đề khác.
- **BR-02 — Template Free:** Người dùng gói Thường có ba template cơ bản.
- **BR-03 — Template Premium:** Người dùng gói Premium có thêm hơn hai mươi template theo nhiều chủ đề đặc biệt. Với người dùng gói Thường:
  - Template Premium hiển thị trong danh sách với dấu khoá.
  - Nhấn vào template Premium → mở màn hình xem trước đầy đủ (nền giấy, bố cục, họa tiết) giống hệt người dùng Premium thấy.
  - Trong màn hình xem trước: nút "Chọn template này" không xuất hiện; thay vào đó hiển thị gợi ý nâng cấp "Nâng cấp Premium để dùng template này".
  - Nhấn vào gợi ý nâng cấp → chuyển đến màn hình nâng cấp Premium (SM-028).
- **BR-04 — Xem trước trước khi chọn:** Người dùng có thể xem trước từng template (nền giấy, bố cục, họa tiết) trước khi xác nhận chọn.
- **BR-05 — Mỗi thư dùng một template:** Người dùng chọn một template cho mỗi thư. Đã chọn rồi có thể đổi sang template khác bất kỳ lúc nào trong quá trình soạn — nội dung đang soạn (chữ, font, sticker) được giữ lại; chỉ nền và bố cục giấy thư thay đổi.

#### Trạng thái offline

- **BR-06 — Xem template đã tải khi mất mạng:** Khi mất kết nối mạng, những template đã được tải trước đó vẫn hiển thị và xem trước được bình thường. Hệ thống hiển thị thông báo "Đang xem ngoại tuyến" ở đầu màn hình. Template chưa được tải xuất hiện ở trạng thái không khả dụng tại ô đó.
- **BR-07 — Chặn chọn template khi mất mạng:** Khi mất kết nối mạng, người dùng không thể xác nhận chọn template (nhấn "Chọn template này") vì bước tiếp theo cần kết nối để tiếp tục soạn và lưu thư. Hệ thống thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."

### 4. Tiêu chí nghiệm thu

- **AC-01 — Xem danh sách template:**
  - **Giả sử** người dùng bắt đầu luồng soạn thư;
  - **Khi** màn hình chọn template mở ra;
  - **Thì** thấy các template được nhóm theo chủ đề, template Free hiển thị bình thường, template Premium có dấu khoá.

- **AC-02 — Xem trước template trước khi chọn:**
  - **Giả sử** người dùng đang xem danh sách template;
  - **Khi** nhấn vào một template Free;
  - **Thì** màn hình xem trước hiển thị đầy đủ nền giấy, bố cục và họa tiết của template đó.

- **AC-03 — Người dùng Free xem trước được template Premium:**
  - **Giả sử** người dùng gói Thường đang xem danh sách template;
  - **Khi** nhấn vào một template Premium (có dấu khoá);
  - **Thì** màn hình xem trước mở ra và hiển thị đầy đủ nền giấy, bố cục, họa tiết — giống hệt khi xem template Free.

- **AC-07 — Nút chọn ẩn, gợi ý nâng cấp xuất hiện trên xem trước Premium:**
  - **Giả sử** người dùng gói Thường đang ở màn hình xem trước của một template Premium;
  - **Khi** xem màn hình đó;
  - **Thì** nút "Chọn template này" không xuất hiện; thay vào đó có nút "Nâng cấp Premium để dùng template này"; nhấn nút đó dẫn đến màn hình nâng cấp Premium.

- **AC-04 — Chọn template và soạn thư:**
  - **Giả sử** người dùng đã xem trước một template Free;
  - **Khi** nhấn Chọn template này;
  - **Thì** chuyển sang màn hình soạn nội dung (SM-013) với template đã chọn làm nền.

#### Offline

- **AC-05 — Xem template đã tải khi mất mạng:**
  - **Giả sử** người dùng đang xem danh sách template và thiết bị mất kết nối mạng;
  - **Khi** màn hình chọn template hiển thị;
  - **Thì** các template đã tải trước đó vẫn hiện ra bình thường kèm thông báo "Đang xem ngoại tuyến"; template chưa tải hiển thị ở trạng thái không khả dụng.

- **AC-06 — Không thể xác nhận chọn template khi mất mạng:**
  - **Giả sử** người dùng đang xem trước một template Free và thiết bị mất kết nối mạng;
  - **Khi** nhấn "Chọn template này";
  - **Thì** hệ thống không chuyển sang bước soạn thư và hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."

### 5. Trường hợp ngoại lệ & lỗi

- Khi mất kết nối: template đã tải trước đó vẫn hiển thị và xem trước bình thường; template chưa tải hiển thị trạng thái không khả dụng tại ô đó; người dùng không thể xác nhận chọn template — hệ thống thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."
- Khi dữ liệu không tải được (lỗi mạng hoặc lỗi server): màn hình hiển thị trạng thái lỗi kèm nút "Thử lại" để người dùng tải lại danh sách template mà không cần thoát màn hình.
- Khi chưa đăng nhập: hệ thống không cho vào màn hình chọn template mà chuyển ngay về màn hình đăng nhập.
- Khi thoát app giữa chừng (chưa xác nhận chọn template): lần sau mở lại app, người dùng quay về màn hình chọn template từ đầu — không có dữ liệu bị mất vì chưa có nội dung soạn.
- Khi người dùng đổi template sau khi đã bắt đầu soạn: nội dung không bị mất — hệ thống áp template mới ngay mà không cần xác nhận. Nếu bố cục mới không hỗ trợ một số trang trí cũ (ví dụ sticker nằm ngoài vùng in): sticker tự dịch về trong vùng hiển thị.

---

### Liên kết tính năng khác

- SM-013 (Soạn nội dung thư): bước tiếp theo sau khi chọn template.
- SM-028 (Nâng cấp Premium): điểm đến khi nhấn gợi ý từ template Premium.

---

## Soạn nội dung thư (SM-013)

> Nguồn: `specs/011-soan-noi-dung-thu.md`

**Màn hình & trạng thái:**

- **Soạn thư**: Default · Typing · Near-limit · At-limit · Formatting

### 1. Mục đích nghiệp vụ

Cho phép người dùng viết nội dung thư trong một ô soạn thảo bo góc tròn trên nền giấy thư — cảm giác như đang viết thư tay thật sự. Người dùng cá nhân hóa tờ thư bằng cách chọn màu nền giấy, phông chữ, kiểu kẻ dòng và thêm sticker trang trí.

### 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đang soạn thư mới, sau bước chọn template.
- **Khi nào dùng:** Bước 2 trong luồng soạn thư, sau SM-012.
- **Điều kiện tiên quyết:** Đã chọn template (SM-012).
- **Phạm vi:** Nhập và định dạng nội dung thư, chọn font, thêm sticker trang trí. Không bao gồm đính tem (SM-014) hay xem trước toàn bộ thư (SM-015).

### 3. Quy tắc nghiệp vụ

- **BR-01 — Viết trực tiếp trên template:** Người dùng nhập nội dung trực tiếp lên vùng giấy của template đã chọn — không phải soạn ở nơi khác rồi dán vào.
- **BR-02 — Định dạng cơ bản:** Hỗ trợ in đậm, in nghiêng, và căn lề (trái / giữa / phải).
- **BR-03 — Chọn phông chữ:** Người dùng chọn một trong ít nhất bốn phông chữ:
  - **Tay viết nhẹ** — nét uốn lượn tự nhiên, gần chữ viết tay thông thường.
  - **Tay viết đứng** — nét thẳng đứng, trang trọng hơn nhưng vẫn có cảm giác thủ công.
  - **In ấn hiện đại** — nét rõ, không chân, dễ đọc trên màn hình.
  - **In ấn cổ điển** — nét có chân, gợi cảm giác thư viết máy đánh chữ.
  Người dùng đổi phông bất kỳ lúc nào; toàn bộ nội dung đang soạn đổi phông ngay.
- **BR-04 — Giới hạn ký tự:** Mỗi thư có giới hạn khoảng năm trăm ký tự (có thể thay đổi tuỳ template). Hệ thống hiển thị số ký tự còn lại khi người dùng đang gần đến giới hạn.
- **BR-05 — Sticker trang trí:** Người dùng có thể thêm sticker trang trí xung quanh nội dung thư (không đè lên chữ). Sticker Free và Premium áp dụng tương tự như trong SM-008.
- **BR-06 — Màu nền giấy thư:** Người dùng chọn màu nền cho tờ giấy thư từ một bộ màu có sẵn (ít nhất năm màu: trắng, kem, hồng nhạt, xanh nhạt, vàng nhạt). Màu nền hiển thị đúng như vậy khi người nhận xem thư.
- **BR-07 — Ô soạn thảo bo góc:** Vùng nhập nội dung thư được hiển thị dưới dạng một ô riêng biệt có góc bo tròn, nổi lên trên nền giấy thư — gợi cảm giác tờ giấy viết đặt trên phong bì.
- **BR-08 — Kẻ dòng tùy chọn:** Bên trong ô soạn thảo, người dùng chọn một trong hai kiểu: có kẻ dòng ngang (như giấy học sinh) hoặc không kẻ dòng (giấy trắng). Kẻ dòng chỉ là trang trí nền — không cản trở nhập liệu và vẫn hiển thị khi người nhận xem thư.
- **BR-09 — Màu chữ theo từng đoạn:** Người dùng chọn màu chữ riêng cho từng đoạn văn bản — không bắt buộc toàn bộ thư phải cùng một màu. Để đổi màu, người dùng chọn (bôi đen) đoạn muốn đổi rồi chọn màu từ bảng màu có sẵn. Đoạn chưa chọn màu giữ màu mặc định.

#### Trạng thái offline

- **BR-10 — Soạn thảo không cần mạng:** Khi thiết bị mất kết nối mạng, người dùng vẫn tiếp tục soạn nội dung thư bình thường — nhập chữ, chọn phông, chọn màu nền, chọn màu chữ, bật/tắt kẻ dòng, và sử dụng sticker đã tải về trước đó. Các thao tác này không phụ thuộc vào kết nối mạng.
- **BR-11 — Tải sticker cần mạng:** Khi người dùng đang offline và cố tải một sticker chưa có sẵn trên thiết bị (bao gồm sticker Premium chưa tải), hệ thống thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." và không tải sticker đó. Sticker đã tải từ trước vẫn dùng được bình thường.

### 4. Tiêu chí nghiệm thu

- **AC-01 — Nhập nội dung trên template:**
  - **Giả sử** người dùng đã chọn template và đang ở màn hình soạn thư;
  - **Khi** nhấn vào vùng giấy và gõ chữ;
  - **Thì** chữ xuất hiện trực tiếp trên nền template.

- **AC-02 — Áp định dạng in đậm:**
  - **Giả sử** người dùng đã chọn một đoạn chữ;
  - **Khi** nhấn nút in đậm;
  - **Thì** đoạn chữ đó hiển thị đậm hơn trên template.

- **AC-03 — Cảnh báo gần đến giới hạn ký tự:**
  - **Giả sử** giới hạn ký tự là năm trăm;
  - **Khi** người dùng đã nhập được bốn trăm năm mươi ký tự;
  - **Thì** hệ thống hiển thị số ký tự còn lại và/hoặc cảnh báo trực quan.

- **AC-04 — Không thể nhập quá giới hạn:**
  - **Giả sử** người dùng đã nhập đến giới hạn ký tự;
  - **Khi** cố gõ thêm ký tự;
  - **Thì** bàn phím không cho nhập thêm; số đếm ký tự hiển thị đã đạt giới hạn.

- **AC-05 — Chọn phông chữ:**
  - **Giả sử** người dùng đang soạn thư;
  - **Khi** chọn một phông chữ bất kỳ trong bốn lựa chọn;
  - **Thì** toàn bộ nội dung thư đổi sang phông đó ngay lập tức.

- **AC-06 — Chọn màu nền giấy thư:**
  - **Giả sử** người dùng đang soạn thư;
  - **Khi** chọn một màu nền từ bộ màu có sẵn;
  - **Thì** nền giấy thư đổi sang màu đó ngay; ô soạn thảo và nội dung không thay đổi.

- **AC-07 — Bật kẻ dòng:**
  - **Giả sử** người dùng đang ở chế độ không kẻ dòng (mặc định);
  - **Khi** chọn "Kẻ dòng";
  - **Thì** các dòng kẻ ngang xuất hiện trong ô soạn thảo ngay lập tức; nội dung đã nhập vẫn giữ nguyên.

- **AC-08 — Tắt kẻ dòng:**
  - **Giả sử** người dùng đang ở chế độ có kẻ dòng;
  - **Khi** chọn "Không kẻ dòng";
  - **Thì** dòng kẻ biến mất; nội dung đã nhập vẫn giữ nguyên.

- **AC-09 — Đổi màu chữ cho một đoạn:**
  - **Giả sử** người dùng đã nhập ít nhất hai đoạn chữ trong ô soạn thảo;
  - **Khi** bôi đen một đoạn và chọn màu khác từ bảng màu;
  - **Thì** chỉ đoạn được bôi đen đổi sang màu mới; các đoạn còn lại giữ nguyên màu của chúng.

- **AC-10 — Thêm sticker trang trí vào thư:**
  - **Giả sử** người dùng đang soạn nội dung thư;
  - **Khi** mở bộ sticker, chọn một sticker miễn phí và đặt lên thư;
  - **Thì** sticker xuất hiện ở vị trí được chọn, không đè lên vùng chữ; người nhận cũng thấy sticker khi xem thư.

#### Offline

- **AC-11 — Soạn thảo hoạt động bình thường khi mất mạng:**
  - **Giả sử** thiết bị đang mất kết nối mạng và người dùng đang ở màn hình soạn thư;
  - **Khi** người dùng nhập chữ, chọn phông, đổi màu nền và bật kẻ dòng;
  - **Thì** tất cả thao tác đó vẫn thực hiện được và phản ánh ngay lên màn hình; không xuất hiện thông báo lỗi nào.

- **AC-12 — Tải sticker mới thất bại khi mất mạng:**
  - **Giả sử** thiết bị đang mất kết nối mạng và người dùng đang ở màn hình soạn thư;
  - **Khi** người dùng mở bộ sticker và chọn một sticker chưa có sẵn trên thiết bị;
  - **Thì** hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." và sticker đó không được thêm vào thư.

### 5. Trường hợp ngoại lệ & lỗi

- Khi thoát màn hình soạn thư giữa chừng: hệ thống hỏi xác nhận "Bỏ thư này?" trước khi thoát; nếu xác nhận, nội dung đang soạn bị mất.
- Khi bàn phím ảo che khuất vùng soạn thảo: vùng soạn thảo tự cuộn để ký tự đang nhập luôn hiển thị phía trên bàn phím.
- Khi mất kết nối mạng giữa chừng: người dùng vẫn tiếp tục soạn nội dung, chọn phông, đổi màu và dùng sticker đã tải về trước đó bình thường; chỉ khi cố tải sticker mới hệ thống mới hiển thị thông báo không có kết nối, nội dung đang soạn không bị mất.
- Khi danh sách sticker không tải được do lỗi mạng hoặc lỗi máy chủ: bộ sticker hiển thị trạng thái lỗi kèm nút "Thử lại"; sticker đã thêm vào thư trước đó vẫn giữ nguyên.
- Khi chưa đăng nhập: người dùng không thể truy cập màn hình soạn thư — hệ thống chuyển về màn hình đăng nhập trước khi vào luồng soạn thư.
- Khi thoát app giữa chừng (vuốt tắt hoặc hệ điều hành thu hồi bộ nhớ): nội dung đang soạn bị mất vì soạn thư là xử lý cục bộ không lưu nháp; lần sau mở lại app người dùng phải bắt đầu soạn thư từ đầu.

---

### Liên kết tính năng khác

- SM-012 (Chọn template thư): bước trước cung cấp nền template.
- SM-014 (Đính tem & Kéo thả lên thư): bước tiếp theo.

---

## Đính tem & Kéo thả lên thư (SM-014)

> Nguồn: `specs/012-dinh-tem-len-thu.md`

**Màn hình & trạng thái:**

- **Đính tem & Kéo thả**: ⚠️ Có heading nhưng chưa có frame layout — chốt ở bước wireframe

### 1. Mục đích nghiệp vụ

Cho phép người dùng đính tem từ Album lên thư đang soạn — tạo ra sự kết hợp giữa nội dung thư và tem thư theo đúng phong cách tem thư truyền thống. Tem đặt ở vị trí quen thuộc (góc phải phía trên) nhưng người dùng có thể điều chỉnh.

### 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đang soạn thư và muốn đính tem.
- **Khi nào dùng:** Bước 3 trong luồng soạn thư, sau SM-013.
- **Điều kiện tiên quyết:** Đã có ít nhất một tem trong Album (SM-011). Đây là bước bắt buộc — người dùng phải đính ít nhất một tem để tiếp tục gửi thư. Đang soạn thư (SM-013).
- **Phạm vi:** Chọn tem từ Album, đính lên thư, điều chỉnh vị trí. Không bao gồm xem trước toàn bộ thư (SM-015).

### 3. Quy tắc nghiệp vụ

- **BR-01 — Nguồn tem:** Người dùng chọn tem từ bất kỳ album nào trong bộ sưu tập cá nhân. Khi chọn tem, màn hình hiển thị các album được phân nhóm để dễ tìm:
  - **Tất cả** — toàn bộ tem không lọc.
  - **Tự tạo** — các tem do người dùng tự tạo (SM-011).
  - **Nhận được** — các tem người khác gửi tặng.
  - **Album tùy chỉnh** — các album người dùng tự tạo (SM-022 BR-06); mỗi album tùy chỉnh hiển thị như một tab riêng, nằm sau ba tab mặc định ở trên.
  Người dùng chuyển tab giữa các nhóm album để tìm tem muốn đính.
- **BR-02 — Vị trí mặc định:** Tem được đặt mặc định ở góc phải phía trên của thư, theo phong cách tem thư thật.
- **BR-03 — Giới hạn số tem:** Mỗi thư đính được tối đa ba tem.
- **BR-04 — Xem trước tổng thể:** Sau khi đính tem, người dùng thấy xem trước toàn bộ thư kèm tem đã đính.
- **BR-05 — Tem bắt buộc:** Người dùng phải đính ít nhất một tem trước khi có thể chuyển sang bước xem trước thư. Không thể bỏ qua bước này.

#### Trạng thái offline

- **BR-06 — Xem album khi mất mạng:** Nếu danh sách tem trong Album đã được tải trước đó, người dùng vẫn thấy và chọn được tem từ danh sách đó khi mất kết nối; hệ thống hiển thị thông báo "Đang xem ngoại tuyến" phía trên danh sách.
- **BR-07 — Đính tem cục bộ khi mất mạng:** Thao tác đính tem lên thư, điều chỉnh vị trí và xem trước vẫn thực hiện được khi không có mạng vì không cần kết nối máy chủ.
- **BR-08 — Chặn tải danh sách mới khi mất mạng:** Nếu Album chưa được tải lần nào hoặc người dùng yêu cầu làm mới danh sách khi mất mạng, hệ thống thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." và không cố tải thêm dữ liệu.

### 4. Tiêu chí nghiệm thu

- **AC-01 — Chọn tem từ Album và đính lên thư:**
  - **Giả sử** người dùng đang ở bước đính tem và có tem trong Album;
  - **Khi** chọn một tem từ bất kỳ nhóm album nào;
  - **Thì** tem xuất hiện ở góc phải phía trên của thư trong xem trước.

- **AC-02 — Đính tối đa ba tem:**
  - **Giả sử** người dùng đã đính ba tem lên thư;
  - **Khi** cố chọn thêm tem thứ tư;
  - **Thì** hệ thống thông báo đã đạt giới hạn ba tem một thư.

- **AC-03 — Chưa đính tem thì không chuyển bước được:**
  - **Giả sử** người dùng đang ở bước đính tem nhưng chưa chọn tem nào;
  - **Khi** nhấn Tiếp tục;
  - **Thì** hệ thống hiển thị thông báo yêu cầu đính ít nhất một tem, không chuyển sang bước xem trước.

- **AC-04 — Không có tem trong Album:**
  - **Giả sử** người dùng chưa có tem nào trong Album;
  - **Khi** vào bước đính tem;
  - **Thì** hệ thống hiển thị trạng thái trống kèm gợi ý tạo tem trước, có nút tắt để bỏ qua.

- **AC-05 — Chuyển tab giữa các nhóm album:**
  - **Giả sử** người dùng đang ở tab "Tất cả" trong màn hình chọn tem;
  - **Khi** nhấn sang tab "Nhận được";
  - **Thì** danh sách tem cập nhật chỉ hiển thị tem nhận từ người khác; tem đã đính (nếu có) không bị xóa.

#### Offline

- **AC-06 — Chọn tem từ album đã tải khi mất mạng:**
  - **Giả sử** người dùng đang ở bước đính tem, Album đã được tải trước đó và thiết bị mất kết nối mạng;
  - **Khi** vào màn hình chọn tem;
  - **Thì** danh sách tem đã tải trước đó vẫn hiển thị đầy đủ, người dùng chọn và đính tem lên thư được bình thường, và hệ thống hiển thị thông báo "Đang xem ngoại tuyến".

- **AC-07 — Không tải được album khi mất mạng:**
  - **Giả sử** người dùng vào bước đính tem nhưng Album chưa từng được tải và thiết bị không có mạng;
  - **Khi** màn hình chọn tem mở ra;
  - **Thì** hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." và không hiển thị danh sách tem.

### 5. Trường hợp ngoại lệ & lỗi

- Khi thoát màn hình đính tem: nội dung thư đang soạn được giữ lại, tem đã chọn (nếu có) có thể bị mất — hỏi xác nhận trước khi thoát.
- Khi Album chưa tải xong: hiển thị trạng thái đang tải; không cho chọn tem khi chưa tải xong.

**Nhóm 1 — Khi mất kết nối (offline / no network):**
- Nếu Album đã tải trước đó, danh sách tem vẫn hiển thị từ bộ nhớ đệm và người dùng vẫn chọn, đính, điều chỉnh vị trí tem được bình thường (thao tác đính tem là cục bộ, không cần mạng).
- Nếu Album chưa từng được tải, hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." và không hiển thị danh sách tem; người dùng không thể chọn tem.
- Khi đang xem album đã tải trong lúc mất mạng, hệ thống hiển thị thông báo "Đang xem ngoại tuyến" phía trên danh sách; nút làm mới danh sách bị vô hiệu hoá cho đến khi có kết nối trở lại.

**Nhóm 2 — Khi dữ liệu không tải được (lỗi mạng / lỗi máy chủ):**
- Khi tải danh sách Album thất bại do lỗi máy chủ, màn hình hiển thị thông báo lỗi và nút "Thử lại" để người dùng tải lại danh sách.
- Trong khi chờ tải, hệ thống hiển thị trạng thái đang tải (skeleton); người dùng không thể chọn tem cho đến khi danh sách tải xong hoặc có kết quả lỗi.

**Nhóm 3 — Khi chưa đăng nhập / thoát app giữa chừng:**
- Nếu người dùng chưa đăng nhập, hệ thống chuyển hướng đến màn hình đăng nhập khi vào bước đính tem; không có chế độ khách cho tính năng này vì Album gắn với tài khoản.
- Nếu người dùng thoát app giữa chừng (nhấn Home hoặc thiết bị tắt đột ngột), thư đang soạn và tem đã đính được lưu tạm; lần sau mở lại app, người dùng có thể tiếp tục từ bước đính tem với dữ liệu đã có.

---

### Liên kết tính năng khác

- SM-013 (Soạn nội dung thư): bước trước.
- SM-015 (Xem trước thư trước khi gửi): bước tiếp theo.
- SM-022 (Album sưu tập tem): nguồn tem — nhóm "Tất cả", "Tự tạo", "Nhận được".

---

## Xem trước thư trước khi gửi (SM-015)

> Nguồn: `specs/013-xem-truoc-thu.md`

**Màn hình & trạng thái:**

- **Xem trước thư**: Default · Empty-warning · Offline

### 1. Mục đích nghiệp vụ

Cho người dùng nhìn thấy thư đúng như người nhận sẽ thấy trước khi gửi — lần kiểm tra cuối cùng để tránh gửi nhầm hay gửi khi chưa hoàn chỉnh. Từ đây người dùng có thể quay lại chỉnh hoặc xác nhận gửi.

### 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng vừa hoàn tất đính tem và muốn kiểm tra trước khi gửi.
- **Khi nào dùng:** Bước 4 trong luồng soạn thư, sau SM-014.
- **Điều kiện tiên quyết:** Đã có nội dung thư (SM-013), tem đã đính (SM-014).
- **Phạm vi:** Xem trước đầy đủ thư, quay lại chỉnh sửa, và chuyển sang gửi thư. Không bao gồm bước tạo link và gửi (SM-016).

### 3. Quy tắc nghiệp vụ

- **BR-01 — Hiển thị đúng như người nhận thấy:** Xem trước phải hiển thị thư y hệt như người nhận sẽ thấy khi mở link: template nền, nội dung đã soạn, font chữ đã chọn, tem đã đính và vị trí của chúng.
- **BR-02 — Nút Chỉnh sửa lại:** Từ màn hình xem trước, người dùng quay lại bất kỳ bước nào trước đó (soạn nội dung, đính tem, chọn template) để chỉnh sửa.
- **BR-03 — Nút Gửi thư:** Xác nhận lần cuối và chuyển sang bước tạo link gửi (SM-016).

#### Trạng thái offline

- **BR-04 — Xem trước vẫn hoạt động khi mất mạng:** Màn hình xem trước hiển thị bình thường vì toàn bộ nội dung (template, văn bản, tem, vị trí) đã có sẵn trên thiết bị; không cần kết nối mạng để xem.
- **BR-05 — Nút Gửi thư bị vô hiệu hóa khi mất mạng:** Khi thiết bị không có kết nối, nút Gửi thư bị vô hiệu hóa và hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." Nút Chỉnh sửa lại vẫn hoạt động bình thường.
- **BR-06 — Tự động cho phép gửi khi có mạng trở lại:** Khi kết nối được khôi phục, nút Gửi thư tự động được kích hoạt lại mà không cần người dùng thoát và vào lại màn hình.

### 4. Tiêu chí nghiệm thu

- **AC-01 — Xem trước hiển thị đầy đủ thư:**
  - **Giả sử** người dùng đã soạn xong thư và đính tem;
  - **Khi** chuyển sang màn hình xem trước;
  - **Thì** thấy thư hoàn chỉnh: nền template, nội dung, font, và tem ở đúng vị trí đã đính.

- **AC-02 — Quay lại chỉnh nội dung:**
  - **Giả sử** người dùng thấy lỗi chính tả trong thư;
  - **Khi** nhấn Chỉnh sửa lại;
  - **Thì** quay về màn hình soạn nội dung với nội dung đang có, không mất dữ liệu.

- **AC-03 — Chuyển sang gửi:**
  - **Giả sử** người dùng hài lòng với thư;
  - **Khi** nhấn Gửi thư;
  - **Thì** chuyển sang màn hình gửi thư qua MXH (SM-016).

#### Offline

- **AC-04 — Xem trước vẫn hiển thị khi mất mạng:**
  - **Giả sử** người dùng đang ở màn hình xem trước và thiết bị mất kết nối mạng;
  - **Khi** quan sát màn hình xem trước;
  - **Thì** nội dung thư (template, văn bản, tem) vẫn hiển thị đầy đủ; nút Chỉnh sửa lại vẫn hoạt động; nút Gửi thư bị vô hiệu hóa và có thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."

- **AC-05 — Nút Gửi thư được kích hoạt lại khi có mạng trở lại:**
  - **Giả sử** người dùng đang ở màn hình xem trước trong trạng thái mất mạng (nút Gửi thư bị vô hiệu hóa);
  - **Khi** kết nối mạng được khôi phục;
  - **Thì** nút Gửi thư tự động được kích hoạt lại và thông báo mất mạng biến mất, không cần thoát màn hình.

### 5. Trường hợp ngoại lệ & lỗi

- Khi thư không có nội dung (người dùng bỏ trống): hệ thống cảnh báo thư chưa có nội dung và hỏi có chắc muốn gửi thư trống không.
- Khi thoát app từ màn hình này mà chưa gửi: nội dung thư bị mất và người dùng phải soạn lại từ đầu.

#### Khi mất kết nối

- Màn hình xem trước vẫn hiển thị đầy đủ (template, nội dung, tem) vì toàn bộ dữ liệu đã có sẵn trên thiết bị, không cần mạng để xem.
- Nút Gửi thư bị vô hiệu hóa kèm thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."; nút Chỉnh sửa lại vẫn hoạt động bình thường.
- Khi kết nối được khôi phục, nút Gửi thư tự động kích hoạt lại mà không cần người dùng thoát màn hình.

#### Khi dữ liệu không tải được

- Nếu template hoặc hình ảnh tem không hiển thị được (lỗi máy chủ), màn hình xem trước hiển thị biểu tượng lỗi tại vùng bị ảnh hưởng kèm nút "Thử lại" để tải lại nội dung đó.

#### Khi chưa đăng nhập hoặc thoát app giữa chừng

- Người dùng chưa đăng nhập không thể truy cập tính năng xem trước; hệ thống chuyển về màn hình đăng nhập.
- Khi người dùng thoát app hoặc bị ngắt giữa chừng tại màn hình xem trước, toàn bộ nội dung thư đang soạn bị mất; lần mở lại app, người dùng phải bắt đầu soạn thư từ đầu.

### Liên kết tính năng khác

- SM-014 (Đính tem): bước trước.
- SM-016 (Gửi thư qua MXH): bước tiếp theo — tạo link và gửi.

---

## Gửi thư qua MXH (SM-016)

> Nguồn: `specs/014-gui-thu-mxh.md`

**Màn hình & trạng thái:**

- **Gửi thư**: Platform-picker · Multi-select · App-not-installed · Quota-reached · Success

### 1. Mục đích nghiệp vụ

Là cơ chế lan truyền cốt lõi của StampMail — người gửi chia sẻ link thư qua tin nhắn riêng (DM) trên mạng xã hội, không cần người nhận cài app trước. Mỗi link là một phong bì kỹ thuật số duy nhất, chỉ mở được một lần, tạo cảm giác "thư thật" chứ không phải tin nhắn đại trà.

### 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đã soạn xong thư và xác nhận gửi (SM-015).
- **Khi nào dùng:** Bước 5 (cuối) trong luồng soạn & gửi thư, sau SM-015.
- **Điều kiện tiên quyết:** Đã có thư hoàn chỉnh (SM-013), đã qua xem trước (SM-015). Đã đăng nhập.
- **Phạm vi:** Tạo link thư, mở DM của mạng xã hội đã chọn với link điền sẵn, theo dõi trạng thái gửi. Không bao gồm hộp thư đến của người nhận (SM-017/018).

### 3. Quy tắc nghiệp vụ

- **BR-01 — Mỗi thư = một link duy nhất:** Với mỗi người nhận, hệ thống tạo một link riêng biệt — không dùng chung link cho nhiều người nhận.
- **BR-02 — Link chỉ mở được một lần:** Người đầu tiên mở link sẽ nhận thư. Sau khi được mở, link không còn hiệu lực cho bất kỳ ai khác.
- **BR-03 — Link có thời hạn bảy ngày:** Link tự hết hiệu lực sau bảy ngày kể từ khi tạo, dù chưa được mở.
- **BR-04 — Nền tảng hỗ trợ:** Người dùng chọn mạng xã hội để gửi. Các nền tảng được hỗ trợ: Facebook Messenger, Instagram DM, TikTok DM, Threads, Zalo, WhatsApp, iMessage, Twitter/X DM.
- **BR-05 — Luồng mở DM:** Người dùng chọn nền tảng → ứng dụng mở sẵn DM của nền tảng đó với link thư đã điền vào → người dùng chọn người nhận trong ứng dụng MXH đó và gửi.
- **BR-06 — Gửi nhiều nền tảng cùng lúc:** Người dùng có thể gửi đến nhiều nền tảng trong cùng một lần gửi (mỗi nền tảng một link riêng).
- **BR-07 — Thông báo khi thư được đọc:** Người gửi nhận thông báo khi người nhận mở link và đọc thư.
- **BR-08 — Giới hạn thư tháng:**
  - Gói Thường: tối đa mười thư mỗi tháng.
  - Gói Premium: không giới hạn.
- **BR-09 — Attribution link:** Mỗi link mang thông tin nhận dạng người gửi để khi người nhận cài app từ link, hệ thống ghi nhận đúng nguồn giới thiệu.
- **BR-10 — Kiếm Dấu khi gửi thư:** Mỗi lần tạo link thư thành công, người gửi nhận ngay **5📮** (SM-033 BR-08). Không giới hạn số lần trong ngày.
- **BR-11 — Kiếm Dấu khi người nhận cài app:** Khi người nhận là tài khoản hoàn toàn mới và cài StampMail từ link thư (BR-09), người gửi nhận thêm **50📮** (SM-033 BR-10). Tối đa 5 lượt được thưởng loại này mỗi tháng.

#### Trạng thái offline

- **BR-12 — Chặn tạo link khi mất mạng:** Khi người dùng không có kết nối mạng, thao tác tạo link thư bị chặn ngay lập tức. Hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." và giữ nguyên thư đã soạn để người dùng gửi lại sau.
- **BR-13 — Chặn mở DM khi mất mạng:** Khi không có kết nối, thao tác mở DM của mạng xã hội cũng bị chặn (vì link chưa được tạo). Người dùng không thể tiến hành bước chia sẻ cho đến khi có mạng trở lại.

### 4. Tiêu chí nghiệm thu

- **AC-01 — Chọn nền tảng và mở DM với link sẵn:**
  - **Giả sử** người dùng vừa xác nhận gửi thư;
  - **Khi** chọn "Gửi qua Zalo" (hoặc bất kỳ nền tảng nào trong danh sách);
  - **Thì** ứng dụng Zalo (hoặc nền tảng tương ứng) mở ra ở màn hình DM với nội dung link thư đã điền sẵn.

- **AC-02 — Từ chối tạo thêm link khi hết hạn mức Free:**
  - **Giả sử** người dùng gói Thường đã gửi đủ mười thư trong tháng;
  - **Khi** cố gắng gửi thêm thư;
  - **Thì** hệ thống thông báo đã đạt giới hạn tháng, gợi ý nâng cấp Premium hoặc chờ đầu tháng mới.

- **AC-03 — Link chỉ mở được một lần:**
  - **Giả sử** người nhận đã mở link và đọc thư;
  - **Khi** người nhận (hoặc người khác) nhấn link đó lần nữa;
  - **Thì** hệ thống thông báo thư này đã được đọc và không cho xem lại nội dung.

- **AC-04 — Người gửi nhận thông báo khi thư được đọc:**
  - **Giả sử** người gửi đã gửi link thư thành công;
  - **Khi** người nhận mở link và đọc thư;
  - **Thì** người gửi nhận thông báo trong app "[Tên người nhận] đã mở thư của bạn" (hoặc tương đương).

- **AC-05 — Link tự hết hạn sau bảy ngày:**
  - **Giả sử** link thư đã được tạo nhưng chưa ai mở;
  - **Khi** quá bảy ngày kể từ khi tạo;
  - **Thì** người nhận mở link thấy thông báo link đã hết hạn, không xem được nội dung.

- **AC-06 — Premium gửi không giới hạn:**
  - **Giả sử** người dùng gói Premium;
  - **Khi** gửi thư bất kỳ lúc nào trong tháng;
  - **Thì** không bị chặn bởi giới hạn số lượng.

- **AC-07 — Danh sách nền tảng hiển thị đúng:**
  - **Giả sử** người dùng vừa xác nhận gửi thư;
  - **Khi** màn hình chọn nền tảng hiển thị;
  - **Thì** thấy đủ tám nền tảng: Facebook Messenger, Instagram DM, TikTok DM, Threads, Zalo, WhatsApp, iMessage, Twitter/X DM.

- **AC-08 — Gửi cùng một thư đến nhiều nền tảng tạo link riêng cho mỗi nền tảng:**
  - **Giả sử** người dùng muốn gửi thư đến cả Zalo lẫn Instagram DM;
  - **Khi** chọn cả hai nền tảng và xác nhận;
  - **Thì** mỗi nền tảng nhận một link khác nhau (không dùng chung link); người dùng chia sẻ từng link qua từng app lần lượt.

- **AC-09 — Người nhận cài app từ link được ghi nhận đúng nguồn:**
  - **Giả sử** người nhận chưa có StampMail và mở link thư trên trình duyệt;
  - **Khi** người nhận tải và cài StampMail từ gợi ý trên trang xem thư;
  - **Thì** hệ thống ghi nhận tài khoản mới này được giới thiệu từ người gửi ban đầu.

- **AC-10 — Nhận Dấu ngay khi gửi thư thành công:**
  - **Giả sử** người dùng vừa xác nhận gửi thư và link được tạo thành công;
  - **Khi** màn hình xác nhận gửi hiển thị;
  - **Thì** số Dấu của người dùng tăng 5📮 và hiện thông báo nhỏ "Bạn kiếm được 5📮".

- **AC-11 — Nhận Dấu khi người nhận cài app (lượt ≤ 5 trong tháng):**
  - **Giả sử** người nhận chưa có StampMail và vừa hoàn tất cài app từ link thư, người gửi chưa đủ 5 lượt thưởng loại này trong tháng;
  - **Khi** tài khoản mới của người nhận được tạo thành công;
  - **Thì** người gửi nhận 50📮 và thông báo push "Bạn vừa giới thiệu người dùng mới và nhận 50📮!".

- **AC-12 — Không nhận thêm Dấu khi đã đủ 5 lượt cài app trong tháng:**
  - **Giả sử** người gửi đã nhận thưởng cài app đủ 5 lần trong tháng;
  - **Khi** người nhận thứ 6 cài app từ link của người gửi;
  - **Thì** người gửi không nhận thêm Dấu và không có thông báo thưởng.

#### Offline

- **AC-13 — Chặn tạo link khi mất mạng:**
  - **Giả sử** người dùng đã soạn xong thư và đang ở màn hình chọn nền tảng để gửi, nhưng thiết bị không có kết nối mạng;
  - **Khi** người dùng nhấn nút xác nhận gửi (hoặc chọn nền tảng để tạo link);
  - **Thì** hệ thống không tạo link, hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng.", và giữ nguyên thư đã soạn trên màn hình.

- **AC-14 — Gửi thành công ngay khi kết nối được khôi phục:**
  - **Giả sử** người dùng đã thấy thông báo lỗi mạng ở AC-13 và thiết bị vừa có mạng trở lại;
  - **Khi** người dùng nhấn thử lại;
  - **Thì** hệ thống tạo link thư bình thường và tiếp tục luồng gửi qua MXH như khi có mạng.

### 5. Trường hợp ngoại lệ & lỗi

- Khi ứng dụng MXH chưa được cài trên thiết bị: thay vì mở ứng dụng, hệ thống sao chép link vào bộ nhớ tạm và thông báo người dùng tự dán vào bất kỳ ứng dụng nhắn tin nào.
- Khi mất kết nối lúc tạo link: hệ thống chặn thao tác tạo link, hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng.", và giữ nguyên toàn bộ nội dung thư đã soạn — người dùng không mất dữ liệu và có thể thử lại khi có mạng.
- Khi lỗi phía máy chủ (tạo link thất bại dù có mạng): hệ thống hiển thị thông báo lỗi và nút "Thử lại" để người dùng gửi lại mà không cần soạn lại thư.
- Khi chưa đăng nhập mà cố gắng gửi thư: hệ thống chuyển ngay về màn hình đăng nhập, không cho thực hiện thao tác tạo link.
- Khi người dùng thoát app giữa chừng (trước khi link được tạo thành công): nội dung thư đã soạn được giữ lại, lần sau mở app người dùng vẫn thấy thư ở trạng thái chờ gửi.
- Khi người dùng thoát màn hình gửi mà chưa gửi: thư chưa được gửi đi; quay về xem trước thư (SM-015) hoặc màn hình chính.

---

### Liên kết tính năng khác

- SM-015 (Xem trước thư): bước trước xác nhận gửi.
- SM-017 (Nhận thư qua Link): hành trình của người nhận sau khi nhận link.
- SM-021 (Hộp thư đã gửi): theo dõi trạng thái link sau khi gửi.
- SM-026 (Thông báo push): cơ chế thông báo khi thư được đọc.
- SM-030 (Giới hạn tháng): quy tắc giới hạn mười thư/tháng Free.
- SM-033 (Hệ thống Dấu): quy tắc thưởng 5📮 khi gửi và 50📮 khi người nhận cài app.

---

## Thiết kế màn hình

> **Quy tắc:** ✅ Vẽ riêng · 📝 Annotation trên frame gốc · ♻️ Dùng lại layout từ flow khác

### Tổng quan trạng thái trong spec

| Màn hình | Trạng thái |
|---|---|
| Danh sách template | List-default · List-premium-locked · List-offline · List-error |
| Xem trước template | Preview-free · Preview-premium |
| Soạn nội dung | Default · Typing · Near-limit · At-limit · Formatting |
| Đính tem | Picker-default · Picker-empty-tab |
| Xem trước thư | Default · Empty-warning · Offline |
| Gửi thư | Platform-picker · Multi-select · App-not-installed · Quota-reached · Success |

**Tổng: ~20 trạng thái / 6 loại màn hình**

### Frame cần thiết kế (12 frame)

| # | Frame | Ghi chú |
|---|---|---|
| 1 | Danh sách template — Default | Grid cards: free + locked với badge giá Premium |
| 2 | Xem trước template — Free | Preview full màn + nút "Dùng template này" |
| 3 | Xem trước template — Premium-locked | Nút bị thay bằng CTA upsell |
| 4 | Soạn nội dung — Default | Canvas thư + toolbar font / màu / size |
| 5 | Soạn nội dung — Near-limit | Bộ đếm ký tự xuất hiện, màu cảnh báo |
| 6 | Soạn nội dung — Formatting panel | Bottom sheet sticker / trang trí chữ |
| 7 | Đính tem — Picker | 4 tab: Tất cả / Tự tạo / Nhận được / Mẫu |
| 8 | Đính tem — Empty tab | Tab rỗng + CTA "Tạo tem mới" |
| 9 | Xem trước thư — Default | Render thư hoàn chỉnh |
| 10 | Xem trước thư — Empty-warning | Modal: "Thư chưa có nội dung, vẫn gửi?" |
| 11 | Platform picker — Default | 8 nền tảng, multi-select |
| 12 | Gửi thư — Success | Thông báo thành công + "Theo dõi thư" |

**Bỏ qua / annotation:** List-offline / error (📝 banner + skeleton); List-premium-locked (📝 lock badge annotation trên grid); Preview-premium layout (♻️ frame 2 + 📝 lock badge); Typing / At-limit (📝 annotation Near-limit); Multi-select (📝 checkbox annotation); App-not-installed (📝 toast "sao chép link"); Quota-reached (📝 modal annotation); Offline (📝 banner).

# Flow 6 · Kiếm & tiêu Dấu (Rewards)

Vòng lặp tăng trưởng: chia sẻ / gửi thư → nhận Dấu → mở khóa tính năng.

---

## Chia sẻ tem lên MXH (SM-025)

> Nguồn: `specs/021-chia-se-tem-mxh.md`

**Màn hình & trạng thái:**

- **Chia sẻ tem**: Level-1 · Level-2 · Level-3 · Format-toggle · Saved · Offline

### 1. Mục đích nghiệp vụ

Biến tem đẹp thành kênh marketing hữu cơ — người dùng chia sẻ tem lên Stories/Feed của mạng xã hội, người lạ thấy tem đẹp và tò mò tải StampMail. Không tốn quảng cáo, watermark nhỏ trên tem là đủ.

### 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đã đăng nhập có ít nhất một tem trong Album.
- **Khi nào dùng:** Khi muốn khoe tem hoặc nội dung thư lên mạng xã hội công khai.
- **Điều kiện tiên quyết:** Đã đăng nhập (SM-001). Có tem trong Album (SM-022).
- **Phạm vi:** Chọn tem, chọn mức nội dung chia sẻ, chọn định dạng theo nền tảng, và xuất ảnh/chia sẻ. Không bao gồm gửi thư (SM-016) — đây là chia sẻ công khai lên feed/stories, không phải gửi riêng tư.

### 3. Quy tắc nghiệp vụ

- **BR-01 — Nền tảng hỗ trợ:** Có thể chia sẻ lên năm nền tảng: Instagram, TikTok, Facebook, Threads, Twitter/X.
- **BR-02 — Ba mức nội dung (người dùng tự chọn):**
  - Mức 1 — Chỉ tem: Chỉ ảnh tem, nội dung thư hoàn toàn riêng tư.
  - Mức 2 — Tem + một dòng trích dẫn: Người dùng tự chọn một câu từ thư để kèm theo tem.
  - Mức 3 — Tem + toàn bộ nội dung thư: Lộ đầy đủ nội dung thư kèm tem.
- **BR-03 — Cảnh báo trước khi lộ nội dung:** Với Mức 2 và Mức 3, hệ thống hiển thị cảnh báo rõ rằng nội dung thư sẽ được chia sẻ công khai. Người dùng phải xác nhận trước khi tiếp tục.
- **BR-04 — Người dùng chọn định dạng trước khi chia sẻ:** Vì ảnh được xuất trước khi người dùng chọn nền tảng, người dùng tự chọn một trong hai định dạng:
  - **Dọc 9:16** — phù hợp Stories (Instagram, Facebook, TikTok).
  - **Vuông 1:1** — phù hợp Feed/Post (Instagram, Facebook, Threads, Twitter/X).
- **BR-05 — Lưu về thư viện:** Người dùng có thể lưu ảnh đã định dạng về thư viện điện thoại để chia sẻ thủ công sau.
- **BR-06 — Watermark bắt buộc:** Mọi ảnh chia sẻ đều có watermark StampMail nhỏ ở góc — không thể tắt, không thể xoá. Đây là yêu cầu bắt buộc để duy trì nhận diện thương hiệu.
- **BR-07 — Cơ chế chia sẻ qua native share sheet:** Sau khi chọn định dạng và nội dung, hệ thống mở native share sheet của hệ điều hành. Người dùng tự chọn nền tảng từ danh sách do thiết bị cung cấp. App không tự mở thẳng vào từng nền tảng — không cần liên kết tài khoản MXH với StampMail.

#### Trạng thái offline

- **BR-08 — Tạo ảnh và lưu về thư viện không cần mạng:** Khi thiết bị mất kết nối mạng, người dùng vẫn chọn được tem, chọn mức nội dung, chọn định dạng và lưu ảnh về thư viện điện thoại bình thường — các bước này hoàn toàn thực hiện cục bộ trên thiết bị.
- **BR-09 — Mở native share sheet vẫn cho phép nhưng hiển thị thông báo:** Khi thiết bị mất mạng, người dùng vẫn có thể mở native share sheet để chọn nền tảng; tuy nhiên ngay khi share sheet mở, hệ thống hiển thị thông báo nhắc nhở "Thiết bị đang ngoại tuyến — chia sẻ lên mạng xã hội có thể không thành công". Kết quả thực tế phụ thuộc vào từng nền tảng người dùng chọn.

### 4. Tiêu chí nghiệm thu

- **AC-01 — Chọn Mức 1 (chỉ tem), chọn định dạng và chia sẻ:**
  - **Giả sử** người dùng đang ở màn hình chia sẻ, chọn Mức 1 và định dạng 9:16;
  - **Khi** nhấn Chia sẻ;
  - **Thì** native share sheet của thiết bị mở ra với ảnh tem 9:16 kèm watermark — người dùng tự chọn Instagram, TikTok hoặc bất kỳ app nào từ sheet.

- **AC-02 — Cảnh báo khi chọn Mức 2/3:**
  - **Giả sử** người dùng chọn Mức 2 (kèm trích dẫn) hoặc Mức 3 (toàn bộ nội dung);
  - **Khi** nhấn Tiếp tục;
  - **Thì** hệ thống hiển thị cảnh báo "Nội dung thư sẽ công khai", yêu cầu xác nhận trước khi tiến hành.

- **AC-03 — Watermark luôn có trên ảnh chia sẻ:**
  - **Giả sử** người dùng chọn chia sẻ bất kỳ tem nào;
  - **Khi** ảnh được tạo ra để chia sẻ;
  - **Thì** watermark StampMail luôn xuất hiện ở góc ảnh, không có tùy chọn xoá.

- **AC-04 — Lưu về thư viện:**
  - **Giả sử** người dùng muốn đăng thủ công lên mạng xã hội;
  - **Khi** chọn "Lưu về thư viện";
  - **Thì** ảnh tem đã định dạng và có watermark được lưu vào thư viện ảnh điện thoại.

- **AC-05 — Người dùng chọn định dạng trước khi share sheet mở:**
  - **Giả sử** người dùng muốn đăng lên Stories;
  - **Khi** chọn định dạng 9:16 rồi nhấn Chia sẻ;
  - **Thì** native share sheet mở với ảnh tỉ lệ 9:16 — không phải 1:1.

#### Offline

- **AC-06 — Lưu về thư viện vẫn thực hiện được khi mất mạng:**
  - **Giả sử** thiết bị đang mất kết nối mạng và người dùng đã chọn tem, chọn định dạng;
  - **Khi** chọn "Lưu về thư viện";
  - **Thì** ảnh tem có watermark được lưu thành công vào thư viện điện thoại mà không có thông báo lỗi mạng.

- **AC-07 — Hiển thị thông báo ngoại tuyến khi mở share sheet lúc mất mạng:**
  - **Giả sử** thiết bị đang mất kết nối mạng và người dùng nhấn Chia sẻ;
  - **Khi** native share sheet mở ra;
  - **Thì** hệ thống hiển thị thông báo "Thiết bị đang ngoại tuyến — chia sẻ lên mạng xã hội có thể không thành công" ngay trong màn hình, share sheet vẫn mở để người dùng tự quyết định.

### 5. Trường hợp ngoại lệ & lỗi

- Khi nền tảng MXH chưa được cài trên thiết bị: thay vì mở app, hệ thống cung cấp tùy chọn "Lưu về thư viện" để người dùng tự đăng thủ công.
- Khi người dùng từ chối cấp quyền lưu ảnh vào thư viện: thông báo cần quyền và hướng dẫn vào cài đặt.

#### Nhóm 1 — Khi mất kết nối (offline / no network)

- Tạo ảnh, chọn mức nội dung và định dạng hoàn toàn thực hiện được khi mất mạng vì đây là bước xử lý cục bộ trên thiết bị.
- Lưu ảnh về thư viện điện thoại cũng thực hiện được khi mất mạng, không có thông báo lỗi mạng.
- Khi người dùng nhấn Chia sẻ lúc mất mạng, native share sheet vẫn mở nhưng hệ thống hiển thị cảnh báo "Thiết bị đang ngoại tuyến — chia sẻ lên mạng xã hội có thể không thành công"; việc đăng lên MXH có thành công hay không phụ thuộc vào ứng dụng MXH người dùng chọn.

#### Nhóm 2 — Khi dữ liệu không tải được (network error / server error)

- Nếu danh sách tem trong Album không tải được do lỗi mạng hoặc máy chủ, màn hình hiển thị thông báo lỗi và nút "Thử lại" để người dùng nạp lại danh sách.
- Ảnh tem đã được lưu trong Album cục bộ vẫn dùng được bình thường để tạo hình chia sẻ ngay cả khi có lỗi máy chủ.

#### Nhóm 3 — Khi chưa đăng nhập / thoát app giữa chừng

- Khi chưa đăng nhập mà cố truy cập tính năng Chia sẻ tem, hệ thống chuyển người dùng về màn hình đăng nhập; sau khi đăng nhập thành công, hệ thống quay lại luồng chia sẻ.
- Tạo ảnh chia sẻ (chọn tem, chọn định dạng) yêu cầu đăng nhập; không có chế độ khách cho tính năng này.
- Khi người dùng thoát app hoặc chuyển sang app khác giữa chừng (chưa kịp lưu hay chia sẻ), trạng thái chưa lưu bị huỷ; lần sau vào lại, người dùng bắt đầu lại từ bước chọn tem.

---

### Liên kết tính năng khác

- SM-022 (Album sưu tập tem): điểm xuất phát để chọn tem chia sẻ.
- SM-011 (Lưu tem): gợi ý chia sẻ xuất hiện ngay sau khi lưu tem.

---

## Hệ thống Dấu — Rewards (SM-033)

> Nguồn: `specs/028-he-thong-dau.md`

**Màn hình & trạng thái:**

- **Số dư Dấu**: Balance · Balance-offline · Logged-out · First-earn-reveal
- **Mua Dấu**: Insufficient · Buy-default · Buy-success · Buy-error

### 1. Mục đích nghiệp vụ

Thưởng người dùng bằng đơn vị "Dấu" (📮) cho các hành động tạo giá trị — chia sẻ tem, gửi thư, được người nhận mở thư, giới thiệu người dùng mới — để người dùng có thể đổi lấy tính năng cao cấp mà không bắt buộc phải trả tiền ngay. Hệ thống tạo đồng thời hai vòng lặp tăng trưởng: Share to Unlock (chia sẻ tem → kiếm Dấu) và Chain Unlock (gửi thư → người nhận mở → cài app → kiếm Dấu).

### 2. Đối tượng & phạm vi

- **Người dùng:** Tất cả người dùng đã đăng nhập (gói Thường và Premium).
- **Khi nào dùng:** Liên tục — Dấu được cộng tự động sau mỗi hành động đủ điều kiện; tiêu Dấu khi người dùng chủ động mở item bị khóa.
- **Điều kiện tiên quyết:** Đã đăng nhập. Người dùng Premium vẫn tích Dấu nhưng không cần dùng (đã có toàn bộ tính năng).
- **Phạm vi (MVP):** Bốn nguồn kiếm Dấu (chia sẻ tem, gửi thư, thư được mở, người nhận cài app); hai loại tiêu Dấu (mở sticker pack, mở kiểu viền). Các cơ chế sự kiện theo mùa, streak và multiplier thuộc P1 trở đi.

### 3. Quy tắc nghiệp vụ

#### Định nghĩa cơ bản

- **BR-01 — Đơn vị duy nhất:** "Dấu" (📮) là đơn vị thưởng duy nhất. Không có đơn vị hay tiền tệ thứ hai song song.
- **BR-02 — Dấu không hết hạn:** Dấu tích lũy không có thời hạn sử dụng — người dùng giữ bao lâu cũng được.
- **BR-03 — Hiển thị số Dấu:** Số Dấu hiện có hiển thị ở vị trí dễ thấy trong app (màn hình chính hoặc trang hồ sơ), cập nhật ngay sau mỗi lần cộng hoặc trừ.
- **BR-04 — Progressive disclosure:** Người dùng chưa từng kiếm Dấu không thấy UI Dấu trong app. Sau lần đầu tiên kiếm được Dấu (từ bất kỳ nguồn nào), hệ thống hiển thị màn hình giới thiệu ngắn về Dấu trước khi quay về luồng chính.

#### Kiếm Dấu — Share to Unlock

- **BR-05 — Chia sẻ tem:** Khi người dùng nhấn "Chia sẻ & nhận 10📮" từ màn hình sau khi lưu tem (SM-011 BR-06), người dùng nhận ngay **10📮**.
- **BR-06 — Giới hạn chia sẻ tuần:** Tối đa **3 lần** chia sẻ được thưởng Dấu mỗi tuần (tuần tính từ thứ Hai đến Chủ Nhật). Từ lần thứ 4 trở đi trong tuần, nút chia sẻ vẫn hoạt động nhưng không trao thêm Dấu.
- **BR-07 — Trao Dấu ngay khi nhấn:** Dấu được trao ngay tại thời điểm người dùng nhấn nút chia sẻ — không yêu cầu xác nhận đã đăng thật. Đây là cơ chế đơn giản cho MVP; xác minh nâng cao thuộc P1.

#### Kiếm Dấu — Chain Unlock

- **BR-08 — Gửi thư:** Mỗi lần tạo link thư thành công (SM-016), người gửi nhận ngay **5📮**. Không giới hạn số lần trong ngày.
- **BR-09 — Thư được mở:** Khi người nhận mở link thư lần đầu và animation kết thúc hoàn toàn (SM-019 BR-05), người gửi nhận thêm **15📮**. Không giới hạn số lần.
- **BR-10 — Người nhận cài app:** Khi người nhận chưa có StampMail và cài app từ link thư (SM-016 BR-09), người gửi nhận thêm **50📮**. Giới hạn tối đa **5 lượt** được thưởng loại này mỗi tháng; từ lượt thứ 6 không trao thêm. Chỉ trao khi người nhận là tài khoản hoàn toàn mới.

#### Tiêu Dấu

- **BR-11 — Mở sticker pack:** Người dùng gói Thường dùng **50📮** để mở vĩnh viễn một bộ sticker đặc biệt đang bị khóa (SM-008). Mỗi lần chỉ mở một bộ cụ thể; hiệu lực vĩnh viễn cho tài khoản đó.
- **BR-12 — Mở kiểu viền:** Người dùng gói Thường dùng **80📮** để mở vĩnh viễn một kiểu viền đang bị khóa (SM-009). Mỗi lần chỉ mở một kiểu cụ thể; hiệu lực vĩnh viễn cho tài khoản đó.
- **BR-13 — Mở tem mẫu:** Người dùng dùng **30📮** để mở vĩnh viễn một tem mẫu đang bị khóa (SM-035). Mỗi lần chỉ mở một tem cụ thể; hiệu lực vĩnh viễn cho tài khoản đó.
- **BR-14 — Không đủ Dấu:** Khi số Dấu không đủ để mở item, hệ thống hiển thị số Dấu còn thiếu và gợi ý hai hướng: chia sẻ tem hoặc gửi thư để kiếm thêm, hoặc mua Dấu bằng tiền thật.

#### Mua Dấu

- **BR-15 — Mua Dấu bằng tiền thật (IAP):** Người dùng có thể mua gói Dấu trực tiếp trong app. Giá tham khảo: **100📮 = 29.000đ**. Dấu mua có cùng tính chất (không hết hạn, dùng để mở item) như Dấu kiếm được.

#### Trạng thái offline

- **BR-16 — Xem số Dấu khi mất mạng:** Khi thiết bị không có kết nối, app vẫn hiển thị số Dấu đã được tải lần cuối kèm thông báo "Đang xem ngoại tuyến — số Dấu có thể chưa được cập nhật mới nhất". Số Dấu thực tế được đồng bộ lại ngay khi có mạng trở lại.
- **BR-17 — Tiêu Dấu và mua Dấu khi mất mạng:** Các hành động tiêu Dấu (mở sticker pack, mở kiểu viền, mở tem mẫu) và mua Dấu bằng tiền thật đều yêu cầu kết nối mạng. Khi mất mạng, hệ thống chặn hành động và hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." — không trừ Dấu, không thực hiện giao dịch.
- **BR-18 — Nhận Dấu từ sự kiện Chain Unlock khi mất mạng:** Các sự kiện trao Dấu do phía người nhận kích hoạt (thư được mở, cài app) được ghi nhận phía máy chủ và cộng vào tài khoản người gửi ngay khi người gửi có mạng trở lại. Người gửi nhận thông báo tích lũy sau khi kết nối được khôi phục.

### 4. Tiêu chí nghiệm thu

- **AC-01 — Nhận Dấu khi chia sẻ tem (còn trong giới hạn tuần):**
  - **Giả sử** người dùng vừa lưu tem và chưa chia sẻ đủ 3 lần trong tuần này;
  - **Khi** nhấn "Chia sẻ & nhận 10📮" và native share sheet mở ra;
  - **Thì** số Dấu tăng 10📮 ngay lập tức và hiện thông báo nhỏ "Bạn kiếm được 10📮".

- **AC-02 — Không nhận thêm Dấu khi đã đủ 3 lần chia sẻ trong tuần:**
  - **Giả sử** người dùng đã chia sẻ đủ 3 lần trong tuần này;
  - **Khi** nhấn nút chia sẻ lần thứ 4;
  - **Thì** native share sheet vẫn mở bình thường nhưng không trao Dấu; hiển thị thông báo "Đã đạt giới hạn chia sẻ tuần này".

- **AC-03 — Nhận Dấu ngay khi gửi thư:**
  - **Giả sử** người dùng vừa tạo link thư thành công;
  - **Khi** màn hình xác nhận gửi hiển thị;
  - **Thì** số Dấu tăng 5📮 và hiện thông báo nhỏ "Bạn kiếm được 5📮".

- **AC-04 — Nhận Dấu khi người nhận mở thư:**
  - **Giả sử** người dùng đã gửi thư và người nhận vừa hoàn thành xem animation;
  - **Khi** thư được đánh dấu đã đọc;
  - **Thì** người gửi nhận thêm 15📮 và thông báo push (nếu bật SM-026) "Thư của bạn đã được mở — bạn nhận 15📮!".

- **AC-05 — Nhận Dấu khi người nhận cài app (lượt ≤ 5 trong tháng):**
  - **Giả sử** người nhận chưa có StampMail và vừa hoàn tất cài app từ link thư;
  - **Khi** tài khoản mới được tạo thành công;
  - **Thì** người gửi nhận 50📮 và thông báo "Bạn vừa giới thiệu người dùng mới và nhận 50📮!".

- **AC-06 — Không nhận thêm khi đã đủ 5 lượt cài app trong tháng:**
  - **Giả sử** người gửi đã nhận thưởng cài app đủ 5 lần trong tháng;
  - **Khi** người nhận thứ 6 cài app từ link của người gửi;
  - **Thì** người gửi không nhận thêm Dấu, không có thông báo thưởng.

- **AC-07 — Tiêu Dấu mở sticker pack thành công:**
  - **Giả sử** người dùng gói Thường có ≥ 50📮 và nhấn vào bộ sticker đặc biệt bị khóa;
  - **Khi** chọn "Dùng 50📮 để mở bộ này" và xác nhận;
  - **Thì** bộ sticker mở vĩnh viễn, số Dấu giảm 50📮, người dùng dùng được ngay.

- **AC-08 — Tiêu Dấu mở kiểu viền thành công:**
  - **Giả sử** người dùng gói Thường có ≥ 80📮 và nhấn vào kiểu viền bị khóa;
  - **Khi** chọn "Dùng 80📮 để mở kiểu viền này" và xác nhận;
  - **Thì** kiểu viền mở vĩnh viễn, số Dấu giảm 80📮, áp được ngay.

- **AC-09 — Không đủ Dấu — thông báo số thiếu:**
  - **Giả sử** người dùng chỉ có 30📮 và nhấn vào bộ sticker cần 50📮;
  - **Khi** màn hình gợi ý hiển thị;
  - **Thì** thấy "Bạn cần thêm 20📮 nữa" và hai lựa chọn: "Chia sẻ tem hoặc gửi thư để kiếm thêm" và "Mua Dấu".

- **AC-10 — Lần đầu kiếm Dấu — reveal hệ thống:**
  - **Giả sử** người dùng chưa từng kiếm Dấu lần nào;
  - **Khi** kiếm được Dấu lần đầu (từ bất kỳ nguồn nào);
  - **Thì** hệ thống hiển thị màn hình giới thiệu ngắn "Bạn kiếm được [X]📮 đầu tiên! Tích Dấu để mở sticker và viền đặc biệt", sau đó quay về luồng chính.

- **AC-11 — Item đã mở không bị khóa lại:**
  - **Giả sử** người dùng đã dùng Dấu mở một bộ sticker;
  - **Khi** mở lại app vào ngày hôm sau hoặc đăng xuất rồi đăng nhập lại;
  - **Thì** bộ sticker đó vẫn khả dụng, không cần tiêu Dấu thêm lần nào.

- **AC-12 — Dấu không giảm theo thời gian:**
  - **Giả sử** người dùng có 80📮 và không dùng app trong 3 tháng;
  - **Khi** mở app sau 3 tháng;
  - **Thì** số Dấu vẫn là 80📮, không bị trừ.

- **AC-13 — Tiêu Dấu mở tem mẫu thành công:**
  - **Giả sử** người dùng có ≥ 30📮 và nhấn vào tem mẫu bị khóa (SM-035);
  - **Khi** chọn "Dùng 30📮 để mở tem này" và xác nhận;
  - **Thì** tem mẫu được mở vĩnh viễn, số Dấu giảm 30📮, nút đổi thành "Lưu vào Album".

#### Offline

- **AC-14 — Xem số Dấu khi mất mạng:**
  - **Giả sử** người dùng đã mở app ít nhất một lần khi có mạng và hiện đang mất kết nối;
  - **Khi** vào màn hình hiển thị số Dấu;
  - **Thì** app hiển thị số Dấu từ lần đồng bộ cuối cùng kèm thông báo "Đang xem ngoại tuyến — số Dấu có thể chưa được cập nhật mới nhất"; số Dấu được làm mới ngay khi có mạng trở lại.

- **AC-15 — Chặn tiêu Dấu và mua Dấu khi mất mạng:**
  - **Giả sử** người dùng đang mất kết nối mạng và nhấn vào item bị khóa để dùng Dấu mở (hoặc nhấn "Mua Dấu");
  - **Khi** xác nhận thao tác;
  - **Thì** hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng.", không trừ Dấu và không thực hiện giao dịch; item vẫn ở trạng thái khóa.

### 5. Trường hợp ngoại lệ & lỗi

- Khi tạo link thư thành công nhưng người gửi xóa thư ngay sau: 5📮 đã được trao không bị thu hồi.
- Khi người nhận mở link nhưng mất mạng giữa chừng animation: 15📮 chỉ được trao sau khi animation hoàn tất — không trao nếu animation bị gián đoạn chưa xong.
- Khi người nhận đã có tài khoản StampMail từ trước: không trao 50📮 — chỉ trao khi người nhận là tài khoản hoàn toàn mới.
- Khi mua Dấu qua IAP nhưng giao dịch lỗi: Dấu không được cộng; hiển thị thông báo lỗi và hướng dẫn liên hệ hỗ trợ; không trừ tiền.
- Khi reset hạn mức tháng (5 lượt cài app): reset vào ngày 1 mỗi tháng cùng chu kỳ với SM-030.
- Khi reset giới hạn tuần (3 lượt chia sẻ): reset vào 00:00 thứ Hai mỗi tuần theo múi giờ thiết bị.
- **Khi mất kết nối (offline):** App hiển thị số Dấu từ lần đồng bộ cuối cùng kèm nhãn "Đang xem ngoại tuyến"; mọi thao tác tiêu Dấu, mua Dấu và kiếm Dấu chủ động (chia sẻ tem) bị vô hiệu hoá với thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." — dữ liệu không bị mất; Dấu nhận từ Chain Unlock (thư được mở, cài app) được ghi nhận phía máy chủ và hiển thị cho người gửi ngay khi có mạng trở lại.
- **Khi dữ liệu số Dấu không tải được (lỗi mạng / server):** Màn hình hiển thị số Dấu ở trạng thái skeleton hoặc icon lỗi kèm nút "Thử lại"; nhấn "Thử lại" sẽ gửi lại yêu cầu tải số dư Dấu — không hiển thị giá trị sai lệch.
- **Khi chưa đăng nhập:** Toàn bộ UI liên quan đến Dấu (số dư, lịch sử, nút mở item bằng Dấu) bị ẩn hoàn toàn; người dùng không thấy bất kỳ thông tin Dấu nào cho đến khi đăng nhập.
- **Khi thoát app giữa chừng giao dịch tiêu Dấu chưa hoàn tất:** Giao dịch chưa được xác nhận không được ghi nhận; lần mở app kế tiếp item vẫn ở trạng thái khóa và số Dấu không thay đổi.

---

### Liên kết tính năng khác

- SM-008 (Trang trí tem): tiêu 50📮 tại đây để mở sticker pack đặc biệt.
- SM-009 (Viền & Khung tem): tiêu 80📮 tại đây để mở kiểu viền bị khóa.
- SM-035 (Bộ tem mẫu): tiêu 30📮 tại đây để mở từng tem mẫu bị khóa.
- SM-011 (Lưu tem): nguồn kiếm Dấu — Share to Unlock (10📮/lần, 3 lần/tuần).
- SM-016 (Gửi thư qua MXH): nguồn kiếm Dấu — gửi thư (5📮) và cài app (50📮).
- SM-019 (Mở thư & Animation): nguồn kiếm Dấu — thư được mở (15📮).
- SM-026 (Thông báo push): gửi thông báo khi Dấu được cộng từ Chain Unlock.
- SM-028 (Nâng cấp Premium): lựa chọn thay thế khi không muốn dùng Dấu — mở toàn bộ tính năng.
- SM-030 (Giới hạn tháng): hạn mức 5 lượt cài app/tháng reset cùng chu kỳ.

---

## Thiết kế màn hình

> **Quy tắc:** ✅ Vẽ riêng · 📝 Annotation trên frame gốc · ♻️ Dùng lại layout từ flow khác

### Tổng quan trạng thái trong spec

| Màn hình | Trạng thái |
|---|---|
| Chia sẻ tem | Level-1 · Level-2 · Level-3 · Format-toggle · Saved · Offline |
| Số dư Dấu | Balance · Balance-offline · Logged-out · First-earn-reveal |
| Mua Dấu | Insufficient · Buy-default · Buy-success · Buy-error |

**Tổng: ~13 trạng thái / 3 loại màn hình**

### Frame cần thiết kế (7 frame)

| # | Frame | Ghi chú |
|---|---|---|
| 1 | Chia sẻ tem — Default | Selector level 1/2/3 + toggle 9:16/1:1 + preview + nút Chia sẻ |
| 2 | Chia sẻ tem — Level 2/3 warning modal | Cảnh báo tem gốc sẽ bị public, xác nhận tiếp tục |
| 3 | Số dư Dấu — Balance | Số dư lớn + lịch sử Earn/Spend + nút "Nạp thêm" |
| 4 | Số dư Dấu — First-earn-reveal modal | Giới thiệu hệ thống Dấu lần đầu tiên kiếm được |
| 5 | Mua Dấu — Default | Các gói Dấu với giá tiền |
| 6 | Mua Dấu — Success | Xác nhận + số dư cập nhật |
| 7 | Mua Dấu — Insufficient | Triggered khi thiếu Dấu: 2 CTA "Chia sẻ kiếm thêm" / "Nạp Dấu" |

**Bỏ qua / annotation:** Format-toggle (📝 annotation trên frame 1); Saved (📝 toast annotation); Balance-offline (📝 banner); Logged-out (redirect đến login); Buy-error (📝 toast annotation trên frame 5).

# Flow 4 · Nhận & Đọc thư

Người nhận mở thư qua link (có thể chưa cài app).

---

## Nhận thư qua Link (SM-017)

> Nguồn: `specs/015-nhan-thu-qua-link.md`

**Màn hình & trạng thái:**

- **Web nhận thư**: Guest · Already-opened · Link-expired · Invalid-link · Offline

### 1. Mục đích nghiệp vụ

Là điểm tiếp xúc đầu tiên của người nhận với StampMail — mở link mà không cần cài app trước, xem thư ngay trên trình duyệt web, rồi được mời cài StampMail để sưu tầm tem. Giảm ma sát tối đa để tăng tỉ lệ người nhận thực sự đọc thư và sau đó tải app.

### 2. Đối tượng & phạm vi

- **Người dùng:** Người nhận link thư (có thể chưa có tài khoản StampMail, chưa cài app).
- **Khi nào dùng:** Khi nhấn link thư nhận được qua DM trên mạng xã hội.
- **Điều kiện tiên quyết:** Có link thư hợp lệ chưa hết hạn và chưa được ai mở.
- **Phạm vi:** Xem thư trên web (không cần app), gợi ý cài app để lưu tem, và lưu tem vào Album khi có tài khoản. Không bao gồm animation chi tiết của việc mở thư (SM-019).

### 3. Quy tắc nghiệp vụ

- **BR-01 — Xem được trên web không cần app:** Người nhận mở link trên trình duyệt của điện thoại hoặc máy tính, thấy đầy đủ thư mà không cần cài StampMail.
- **BR-02 — Xem được trong app nếu đã cài:** Nếu điện thoại đã cài StampMail, link tự mở trong app thay vì trình duyệt.
- **BR-03 — Chỉ người đầu tiên mở link nhận được thư:** Đây là link một lần. Người thứ hai nhấp cùng link thấy thông báo thư đã được nhận bởi người khác.
- **BR-04 — Gợi ý cài app sau khi đọc:** Sau khi đọc thư, người nhận chưa có app thấy gợi ý tải StampMail để lưu tem và tạo tem của riêng mình.
- **BR-05 — Tem vào Album khi có tài khoản:** Tem trong thư chỉ được thêm vào Album của người nhận khi người nhận đăng nhập (hoặc đăng ký) vào StampMail sau khi đọc thư. Nếu chỉ xem trên web không đăng nhập, tem không được lưu.
- **BR-06 — Link hết hạn:** Người nhận mở link sau bảy ngày kể từ khi tạo thấy thông báo link đã hết hạn, không xem được nội dung.

#### Trạng thái offline

- **BR-07 — Không tải được thư khi mất mạng ngay từ đầu:** Nếu người nhận nhấn link trong khi không có kết nối, trang web hiển thị thông báo "Không có kết nối mạng. Vui lòng thử lại khi có mạng." và không hiển thị nội dung thư.
- **BR-08 — Vẫn đọc được thư đã tải xong nếu mất mạng giữa chừng:** Nếu người nhận đã tải xong nội dung thư rồi mới mất mạng, nội dung thư (bao gồm tem) vẫn hiển thị được để đọc; trang hiển thị thông báo nhỏ "Đang xem ngoại tuyến".
- **BR-09 — Chặn đăng nhập/đăng ký khi mất mạng:** Nếu người nhận nhấn "Tải StampMail" hoặc thực hiện đăng nhập/đăng ký trong khi không có kết nối, hệ thống chặn thao tác và thông báo "Không có kết nối. Vui lòng thử lại khi có mạng.", giữ nguyên dữ liệu đã nhập.

### 4. Tiêu chí nghiệm thu

- **AC-01 — Xem thư trên trình duyệt không cần app:**
  - **Giả sử** người nhận chưa cài StampMail và nhận được link;
  - **Khi** nhấn link và mở bằng trình duyệt;
  - **Thì** thấy đầy đủ nội dung thư: animation mở thư (SM-019), nội dung, tem, không cần đăng nhập.

- **AC-02 — Link mở trong app nếu đã cài:**
  - **Giả sử** người nhận đã cài StampMail trên điện thoại;
  - **Khi** nhấn link thư;
  - **Thì** StampMail tự mở và hiển thị thư trong app.

- **AC-03 — Người thứ hai mở link thấy đã được nhận:**
  - **Giả sử** link đã được một người mở trước;
  - **Khi** người khác (hoặc cùng người) nhấn link lần nữa;
  - **Thì** thấy thông báo thư này đã được nhận, không thấy nội dung.

- **AC-04 — Gợi ý tải app sau khi đọc (người dùng chưa có app):**
  - **Giả sử** người đọc thư trên trình duyệt, chưa cài app;
  - **Khi** kết thúc animation mở thư và đọc xong;
  - **Thì** thấy gợi ý tải StampMail để lưu tem và nhận thư của mình.

- **AC-05 — Tem vào Album sau khi đăng nhập:**
  - **Giả sử** người nhận vừa đọc thư trên web và nhấn "Tải StampMail" rồi đăng ký/đăng nhập;
  - **Khi** đăng nhập thành công;
  - **Thì** tem trong thư được tự động thêm vào Album của người nhận.

- **AC-06 — Link hết hạn:**
  - **Giả sử** link thư đã quá bảy ngày từ khi được tạo;
  - **Khi** người nhận nhấn link;
  - **Thì** thấy thông báo link đã hết hạn, không xem được nội dung thư.

#### Offline

- **AC-07 — Không tải được thư khi mất mạng ngay từ đầu:**
  - **Giả sử** người nhận không có kết nối mạng và nhấn link thư;
  - **Khi** trang web cố tải nội dung thư;
  - **Thì** trang hiển thị thông báo "Không có kết nối mạng. Vui lòng thử lại khi có mạng." và không hiển thị nội dung thư.

- **AC-08 — Đọc được thư đã tải xong dù mất mạng giữa chừng:**
  - **Giả sử** người nhận đã tải xong toàn bộ nội dung thư và tem, sau đó mất kết nối mạng;
  - **Khi** tiếp tục đọc thư hoặc xem tem trên trang;
  - **Thì** nội dung thư và tem vẫn hiển thị đầy đủ, trang hiển thị thông báo nhỏ "Đang xem ngoại tuyến"; nút đăng nhập/đăng ký bị vô hiệu hóa và thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." khi nhấn vào.

### 5. Trường hợp ngoại lệ & lỗi

**Khi mất kết nối (offline / không có mạng):**
- Nếu người nhận nhấn link khi chưa có mạng, trang web hiển thị thông báo "Không có kết nối mạng. Vui lòng thử lại khi có mạng." và không hiển thị nội dung thư.
- Nếu người nhận đã tải xong toàn bộ nội dung thư rồi mới mất mạng, nội dung thư và tem vẫn hiển thị để đọc, trang hiển thị thông báo nhỏ "Đang xem ngoại tuyến".
- Khi đang xem ngoại tuyến, mọi thao tác cần mạng (đăng nhập, đăng ký, tải app) bị vô hiệu hoá và hiển thị thông báo yêu cầu kết nối lại; dữ liệu đã nhập không bị mất.

**Khi dữ liệu không tải được (lỗi mạng / lỗi máy chủ):**
- Nếu trang web không lấy được nội dung thư do lỗi kết nối hoặc lỗi máy chủ, hiển thị màn hình lỗi kèm nút "Thử lại" để người nhận tải lại thủ công.
- Khi link sai định dạng hoặc không tồn tại, trang web hiển thị thông báo link không hợp lệ, không có nút thử lại.
- Khi link đã hết hạn (quá bảy ngày), trang web hiển thị thông báo link đã hết hạn, người nhận không xem được nội dung.

**Khi chưa đăng nhập / thoát app giữa chừng:**
- Người nhận chưa có tài khoản vẫn mở và đọc thư bình thường ở chế độ khách; chỉ cần đăng nhập nếu muốn lưu tem vào Album hoặc trả lời thư.
- Nếu người nhận nhấn "Tải StampMail" hoặc đăng nhập rồi thoát app hoặc đóng trình duyệt giữa chừng, nội dung thư trên web vẫn có thể truy cập lại qua link gốc (nếu link còn hợp lệ và chưa bị người khác nhận).

---

### Liên kết tính năng khác

- SM-016 (Gửi thư qua MXH): nơi tạo link thư.
- SM-019 (Mở thư & Animation): animation mở thư diễn ra sau khi nhận được link hợp lệ.
- SM-022 (Album sưu tập tem): nơi tem được lưu vào sau khi người nhận đăng nhập.

---

## Mở thư & Animation (SM-019)

> Nguồn: `specs/017-mo-thu-animation.md`

**Màn hình & trạng thái:**

- **Mở thư**: Animating · Completed · Guest-completed · Re-view · Offline · Animation-error

### 1. Mục đích nghiệp vụ

Tạo ra "khoảnh khắc vui" (moment of delight) khi người nhận mở thư — phong bì mở ra từ từ như thư thật, giấy thư cuộn ra, tem sáng lên. Trải nghiệm này là yếu tố cảm xúc cốt lõi khiến người nhận muốn chia sẻ lại và người gửi muốn gửi thêm.

### 2. Đối tượng & phạm vi

- **Người dùng:** Người nhận khi mở thư (cả trên web lẫn trong app).
- **Khi nào dùng:** Ngay sau khi người nhận nhấn link thư hợp lệ (SM-017), hoặc khi nhấn vào thư trong hộp thư đến (SM-018).
- **Điều kiện tiên quyết:** Link thư hợp lệ, chưa hết hạn, chưa được mở. Hoặc: xem lại thư đã đọc từ hộp thư đến (animation có thể bỏ qua khi xem lại).
- **Phạm vi:** Trình tự animation phong bì mở thư và hiển thị nội dung thư đầy đủ. Không bao gồm trả lời thư (SM-020) hay lưu tem (thuộc SM-017/022).

### 3. Quy tắc nghiệp vụ

- **BR-01 — Trình tự animation:** Khi mở thư, người nhận trải qua trình tự sau (theo thứ tự): (1) Phong bì hiện ra và mở chậm, (2) Giấy thư cuộn ra từ phong bì, (3) Nội dung thư hiện dần, (4) Tem sáng lên nổi bật.
- **BR-02 — Âm thanh kèm animation:** Animation kèm theo âm thanh nhẹ phù hợp. Người dùng có thể tắt âm thanh từ cài đặt (SM-027).
- **BR-03 — Hành động sau animation:** Sau khi animation hoàn tất, người nhận thấy thư đầy đủ với ba lựa chọn: (1) Lưu tem vào Album (chỉ khả dụng khi đã đăng nhập), (2) Trả lời thư (chỉ khả dụng khi đã đăng nhập), (3) Tải StampMail (chỉ hiển thị với người chưa có app).
- **BR-04 — Xem lại thư không có animation:** Khi xem lại thư đã đọc từ hộp thư đến, không có animation — thư hiển thị ngay.
- **BR-05 — Đánh dấu đã đọc:** Khi người nhận xem thư lần đầu (qua link), thư được đánh dấu là đã đọc và người gửi nhận thông báo.
- **BR-06 — Kiếm Dấu khi thư được mở lần đầu:** Ngay khi thư được đánh dấu đã đọc lần đầu qua link (BR-05), người gửi nhận thêm **15📮** (SM-033 BR-09). Chỉ áp dụng cho lần mở đầu tiên qua link — không trao khi người dùng xem lại thư từ hộp thư đến (BR-04). Mỗi thư chỉ trao một lần, không có rủi ro lạm dụng.
- **BR-07 — Phóng to tem sau animation:** Sau khi animation kết thúc và nội dung thư hiển thị đầy đủ, người nhận có thể dùng cử chỉ chụm/banh ngón tay để phóng to tem trên thư. Chỉ để xem — không thay đổi nội dung thư.

#### Trạng thái offline

- **BR-08 — Không thể mở thư khi mất mạng:** Nếu người nhận nhấn link thư hoặc mở thư từ hộp thư đến trong khi mất kết nối, ứng dụng hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." — không bắt đầu animation.
- **BR-09 — Thư đã tải vẫn đọc được khi mất mạng giữa chừng:** Nếu thư đã được tải đầy đủ về máy trước khi mất mạng, người nhận vẫn đọc được nội dung thư; ứng dụng hiển thị thông báo "Đang xem ngoại tuyến". Các hành động cần mạng (lưu tem, trả lời thư) bị vô hiệu hóa cho đến khi có kết nối trở lại.
- **BR-10 — Thông báo đã đọc và Dấu ghi nhận khi có mạng:** Nếu việc đánh dấu đã đọc (BR-05) và trao Dấu (BR-06) chưa ghi nhận được do mất mạng, hệ thống tự động hoàn thành hai thao tác này ngay khi kết nối được khôi phục — không yêu cầu người nhận mở thư lại.

### 4. Tiêu chí nghiệm thu

- **AC-01 — Trình tự animation đúng thứ tự:**
  - **Giả sử** người nhận vừa mở link thư hợp lệ;
  - **Khi** trang/màn hình tải xong;
  - **Thì** animation diễn ra theo đúng thứ tự: phong bì mở → giấy cuộn ra → nội dung hiện → tem sáng lên.

- **AC-02 — Tắt âm thanh hoạt động:**
  - **Giả sử** người dùng đã tắt âm thanh animation trong cài đặt;
  - **Khi** mở một thư mới;
  - **Thì** animation diễn ra bình thường nhưng không có tiếng.

- **AC-03 — Nút lưu tem sau animation:**
  - **Giả sử** người nhận đã đăng nhập và animation kết thúc;
  - **Khi** nhìn vào màn hình sau animation;
  - **Thì** thấy nút "Lưu tem vào Album" và "Trả lời".

- **AC-04 — Xem lại không có animation:**
  - **Giả sử** người dùng đã đọc thư này trước đó;
  - **Khi** mở lại thư từ hộp thư đến;
  - **Thì** thư hiển thị ngay nội dung đầy đủ, không lặp lại animation.

- **AC-05 — Người gửi nhận thông báo đã đọc:**
  - **Giả sử** người nhận vừa mở link và hoàn thành animation;
  - **Khi** animation kết thúc và thư được đánh dấu đã đọc;
  - **Thì** người gửi nhận thông báo trong app.

- **AC-06 — Người gửi nhận Dấu khi thư được mở:**
  - **Giả sử** người nhận vừa hoàn thành xem animation và thư được đánh dấu đã đọc;
  - **Khi** trạng thái đã đọc được ghi nhận;
  - **Thì** người gửi nhận thêm 15📮 và thông báo push (nếu đã bật SM-026) "Thư của bạn đã được mở — bạn nhận 15📮!".

- **AC-07 — Phóng to tem trên thư:**
  - **Giả sử** người nhận đang xem nội dung thư sau khi animation kết thúc;
  - **Khi** banh ngón tay lên tem đính trên thư;
  - **Thì** tem phóng to theo ngón tay; chụm ngón tay thu về kích thước ban đầu.

#### Offline

- **AC-08 — Chặn mở thư khi mất mạng:**
  - **Giả sử** thiết bị của người nhận đang không có kết nối mạng;
  - **Khi** người nhận nhấn link thư hoặc mở thư từ hộp thư đến;
  - **Thì** ứng dụng không bắt đầu animation và hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng."

- **AC-09 — Xem thư đã tải khi mất mạng giữa chừng:**
  - **Giả sử** thư đã tải xong và đang hiển thị nội dung đầy đủ, sau đó thiết bị mất kết nối;
  - **Khi** người nhận tiếp tục đọc thư;
  - **Thì** nội dung thư vẫn hiển thị bình thường với thông báo "Đang xem ngoại tuyến"; các nút "Lưu tem" và "Trả lời" bị vô hiệu hóa.

### 5. Trường hợp ngoại lệ & lỗi

**Nhóm 1 — Khi mất kết nối (offline / không có mạng):**
- Nếu thư chưa được tải về máy và mất mạng khi nhấn link: animation không bắt đầu, hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." — thư không mở được.
- Nếu thư đã tải đầy đủ về máy trước khi mất mạng: người nhận vẫn xem được nội dung thư với thông báo "Đang xem ngoại tuyến"; các nút "Lưu tem" và "Trả lời" bị vô hiệu hóa cho đến khi có mạng trở lại.
- Khi mất kết nối giữa chừng animation (thư chưa tải xong): animation dừng lại, hiển thị thông báo lỗi mạng và nút thử lại.
- Khi thiết bị yếu, animation giật lag: animation vẫn phải chạy đến cuối dù có độ trễ; không được bỏ qua tự động.

**Nhóm 2 — Khi dữ liệu không tải được (lỗi mạng / lỗi máy chủ):**
- Nếu thư không tải được do lỗi máy chủ hoặc link hết hạn: màn hình hiển thị thông báo lỗi rõ ràng (ví dụ: "Không tìm thấy thư" hoặc "Link đã hết hạn") cùng nút "Thử lại"; không hiển thị màn hình trắng trống.
- Nếu lỗi chỉ xảy ra khi tải tài nguyên animation (hình ảnh, âm thanh) nhưng nội dung thư đã có: thư hiển thị nội dung văn bản ngay, phần animation bị lược bỏ và người nhận thấy thông báo ngắn gọn.

**Nhóm 3 — Khi chưa đăng nhập / thoát app giữa chừng:**
- Người nhận chưa đăng nhập mở thư qua link: animation vẫn phát bình thường ở chế độ khách; sau animation, các lựa chọn "Lưu tem" và "Trả lời" được hiển thị nhưng khi nhấn vào thì yêu cầu đăng nhập hoặc tải app.
- Khi người nhận nhấn ra khỏi màn hình animation giữa chừng: thư được đánh dấu là đã mở (link hết hiệu lực), người nhận có thể xem lại thư từ hộp thư đến.
- Khi người nhận thoát app sau khi animation đã kết thúc và thư đã đánh dấu đã đọc: lần vào lại thư từ hộp thư đến không có animation, nội dung thư hiển thị ngay.

---

### Liên kết tính năng khác

- SM-017 (Nhận thư qua Link): kích hoạt animation khi mở link lần đầu.
- SM-018 (Hộp thư đến): xem lại thư đã đọc từ đây (không có animation).
- SM-020 (Trả lời thư): hành động khả dụng sau khi đọc thư.
- SM-022 (Album sưu tập tem): lưu tem sau khi đọc thư.
- SM-027 (Cài đặt): bật/tắt âm thanh animation.
- SM-033 (Hệ thống Dấu): quy tắc thưởng 15📮 khi thư được mở.

---

## Hộp thư đến (Inbox) — SM-018

> Nguồn: `specs/016-hop-thu-den.md`

**Màn hình & trạng thái:**

- **Hộp thư đến**: Default · Unread-filter · Empty · Offline · Error

### 1. Mục đích nghiệp vụ

Là nơi người dùng xem lại toàn bộ thư đã nhận — không bỏ sót thư nào. Cung cấp bộ lọc đơn giản để tìm thư chưa đọc hoặc đã đọc.

### 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đã đăng nhập.
- **Khi nào dùng:** Khi muốn xem lại các thư đã nhận, phân biệt thư chưa đọc và đã đọc.
- **Điều kiện tiên quyết:** Đã đăng nhập (SM-001).
- **Phạm vi:** Danh sách thư nhận, bộ lọc trạng thái, mở từng thư. Không bao gồm trả lời thư (SM-020).

### 3. Quy tắc nghiệp vụ

- **BR-01 — Sắp xếp theo thời gian:** Thư mới nhất hiển thị đầu danh sách.
- **BR-02 — Thông tin hiển thị trong danh sách:** Mỗi thư trong danh sách hiển thị: ảnh nhỏ của tem, tên người gửi, thời gian nhận, và trạng thái (đọc/chưa đọc).
- **BR-03 — Bộ lọc ba trạng thái:** Người dùng lọc danh sách theo: tất cả / chưa đọc / đã đọc.
- **BR-04 — Thư lưu vĩnh viễn:** Thư đã nhận không bị tự động xoá sau bất kỳ thời gian nào — người dùng có thể xem lại bất kỳ lúc nào.

#### Trạng thái offline

- **BR-05 — Hiển thị danh sách khi mất mạng:** Khi người dùng mất kết nối, hộp thư đến vẫn hiển thị danh sách thư đã tải từ lần truy cập trước — người dùng không thấy màn hình trắng hay lỗi ngay lập tức.
- **BR-06 — Thông báo ngoại tuyến:** Khi đang xem hộp thư mà không có kết nối, hệ thống hiển thị thông báo rõ ràng "Đang xem ngoại tuyến — danh sách có thể chưa cập nhật mới nhất".
- **BR-07 — Vô hiệu hoá tải thêm khi offline:** Khi không có kết nối, người dùng không thể tải thêm thư mới; hành động kéo làm mới danh sách bị vô hiệu hoá và hiển thị thông báo cần có mạng để cập nhật.

### 4. Tiêu chí nghiệm thu

- **AC-01 — Hiển thị danh sách thư đúng thứ tự:**
  - **Giả sử** người dùng đã nhận nhiều thư vào các thời điểm khác nhau;
  - **Khi** mở hộp thư đến;
  - **Thì** thư mới nhất xuất hiện đầu danh sách.

- **AC-02 — Lọc thư chưa đọc:**
  - **Giả sử** có cả thư đã đọc lẫn chưa đọc trong hộp thư;
  - **Khi** chọn bộ lọc "Chưa đọc";
  - **Thì** chỉ hiển thị các thư chưa đọc.

- **AC-03 — Mở thư từ danh sách:**
  - **Giả sử** người dùng thấy một thư trong danh sách;
  - **Khi** nhấn vào thư đó;
  - **Thì** mở màn hình mở thư với animation (SM-019).

- **AC-04 — Thư đã đọc vẫn còn trong danh sách:**
  - **Giả sử** người dùng đã đọc một thư trước đó;
  - **Khi** mở lại hộp thư sau nhiều ngày;
  - **Thì** thư đó vẫn còn trong danh sách với trạng thái "Đã đọc".

#### Offline

- **AC-05 — Xem danh sách thư khi mất mạng:**
  - **Giả sử** người dùng đã mở hộp thư khi có mạng và danh sách đã tải thành công; sau đó mất kết nối;
  - **Khi** quay lại hộp thư đến trong lúc không có mạng;
  - **Thì** danh sách thư đã tải trước đó vẫn hiển thị đầy đủ kèm thông báo "Đang xem ngoại tuyến — danh sách có thể chưa cập nhật mới nhất".

- **AC-06 — Vô hiệu hoá làm mới danh sách khi offline:**
  - **Giả sử** người dùng đang xem hộp thư đến và không có kết nối mạng;
  - **Khi** người dùng thực hiện thao tác kéo để làm mới danh sách;
  - **Thì** danh sách không tải thêm thư mới và hệ thống hiển thị thông báo cần có kết nối mạng để cập nhật.

### 5. Trường hợp ngoại lệ & lỗi

- Khi chưa có thư nào: hiển thị trạng thái rỗng với lời nhắn thân thiện (ví dụ: "Hộp thư trống — chia sẻ StampMail để nhận thư đầu tiên").
- Khi mất kết nối (offline): danh sách thư đã tải từ lần truy cập trước vẫn hiển thị đầy đủ; thao tác kéo làm mới bị vô hiệu hoá và hệ thống hiển thị thông báo "Đang xem ngoại tuyến — không thể tải thư mới".
- Khi lỗi mạng hoặc máy chủ không phản hồi: màn hình hiển thị danh sách cache (nếu có) kèm thông báo lỗi và nút "Thử lại" để người dùng tải lại; nếu chưa có cache, hiển thị màn hình lỗi với nút "Thử lại".
- Khi chưa đăng nhập: hệ thống lập tức chuyển người dùng về màn hình đăng nhập và không hiển thị nội dung hộp thư đến.
- Khi thoát app giữa chừng: danh sách thư trong cache được giữ nguyên; lần sau mở lại app, hộp thư đến tiếp tục hiển thị danh sách đã cache và tự động tải cập nhật mới khi có mạng.

---

### Liên kết tính năng khác

- SM-017 (Nhận thư qua Link): cách thư vào hộp thư đến.
- SM-019 (Mở thư & Animation): mở khi nhấn vào thư trong danh sách.
- SM-026 (Thông báo push): thông báo khi có thư mới đến.

---

## Trả lời thư (SM-020)

> Nguồn: `specs/018-tra-loi-thu.md`

**Màn hình & trạng thái:**

- **Trả lời thư**: Compose · Web-no-app · Offline

### 1. Mục đích nghiệp vụ

Đóng vòng lặp hai chiều — người nhận trả lời lại người gửi tạo ra chuỗi trao đổi thư qua lại, tăng gắn kết giữa hai người và tần suất sử dụng app. Đồng thời, yêu cầu tải app để trả lời tạo ra một kênh acquisition tự nhiên: người nhận muốn trả lời phải cài StampMail, trở thành người dùng mới.

### 2. Đối tượng & phạm vi

- **Người dùng:** Người đã đọc thư (có hoặc chưa có tài khoản) — nhưng chỉ người đã cài app và đăng nhập mới thực sự trả lời được.
- **Khi nào dùng:** Sau khi đọc thư, nhấn nút Trả lời.
- **Điều kiện tiên quyết:** Đã đăng nhập (SM-001). Đã mở và đọc ít nhất một thư (SM-019).
- **Phạm vi:** Soạn thư trả lời với người gửi gốc đã điền sẵn, gửi qua cơ chế link MXH như bình thường. Không bao gồm thread/chuỗi thư có thể xem lịch sử (thư trả lời là thư độc lập).

### 3. Quy tắc nghiệp vụ

- **BR-01 — Người nhận tự động điền sẵn:** Khi nhấn Trả lời, luồng soạn thư mở ra với người nhận đã được điền sẵn là người gửi thư gốc. Người dùng không phải nhập lại.
- **BR-02 — Template reply:** Hệ thống gợi ý template có phong cách phù hợp với trả lời (ví dụ: template đơn giản hơn so với thư mới). Người dùng vẫn có thể chọn template khác.
- **BR-03 — Luồng gửi như thường:** Sau khi soạn xong, thư trả lời được gửi qua cùng cơ chế link MXH (SM-016) — không có luồng gửi riêng cho trả lời.
- **BR-04 — Thư trả lời là thư độc lập:** Thư trả lời không hiển thị nội dung thư gốc; không có threading/chuỗi thư. Mỗi thư là một phong bì riêng.
- **BR-05 — Bắt buộc cài app và đăng nhập để trả lời:** Chức năng trả lời chỉ khả dụng trong app StampMail. Người đọc thư trên trình duyệt web (chưa cài app) nhấn Trả lời sẽ thấy màn hình mời tải app với thông điệp rõ ràng — không thể trả lời thư trực tiếp từ web.

#### Trạng thái offline

- **BR-06 — Chặn gửi thư khi mất mạng:** Khi người dùng đang soạn thư trả lời và mất kết nối mạng, nút Gửi bị vô hiệu hóa. Hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." Nội dung thư đã soạn được giữ nguyên để người dùng không phải nhập lại khi có mạng trở lại.
- **BR-07 — Vẫn cho phép soạn thư khi mất mạng:** Người dùng vẫn có thể mở màn hình trả lời, soạn nội dung thư và chọn template khi không có kết nối, vì các bước này không cần mạng. Chỉ thao tác gửi (tạo link và chia sẻ qua MXH) mới bị chặn cho đến khi có mạng.

### 4. Tiêu chí nghiệm thu

- **AC-01 — Nút Trả lời mở soạn thư với người nhận sẵn:**
  - **Giả sử** người dùng vừa đọc xong thư từ "An";
  - **Khi** nhấn Trả lời;
  - **Thì** màn hình soạn thư mở ra với "An" đã điền vào ô người nhận (không cần nhập thêm).

- **AC-02 — Hoàn tất trả lời gửi qua MXH:**
  - **Giả sử** người dùng đã soạn xong thư trả lời;
  - **Khi** xác nhận gửi;
  - **Thì** được chuyển đến màn hình chọn nền tảng MXH để chia sẻ link (SM-016) như một thư bình thường.

- **AC-03 — Người đọc thư trên web được mời tải app để trả lời:**
  - **Giả sử** người nhận đang xem thư trên trình duyệt web (chưa cài StampMail);
  - **Khi** nhấn nút Trả lời;
  - **Thì** hiển thị màn hình "Tải StampMail để trả lời thư này" với nút dẫn đến App Store/Google Play; không có cách trả lời từ web.

- **AC-04 — Người đã cài app nhưng chưa đăng nhập:**
  - **Giả sử** người nhận đã cài StampMail nhưng chưa đăng nhập;
  - **Khi** nhấn Trả lời từ trong app;
  - **Thì** được chuyển sang màn hình đăng nhập/đăng ký trước khi vào soạn thư trả lời.

#### Offline

- **AC-05 — Soạn thư vẫn hoạt động khi mất mạng nhưng không thể gửi:**
  - **Giả sử** người dùng đang soạn thư trả lời và thiết bị không có kết nối mạng;
  - **Khi** hoàn tất nội dung và nhấn Gửi;
  - **Thì** nút Gửi bị vô hiệu hóa, hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng.", và toàn bộ nội dung thư đã soạn vẫn còn nguyên trên màn hình.

- **AC-06 — Soạn thư trả lời vẫn thực hiện được khi mất mạng:**
  - **Giả sử** người dùng mất kết nối mạng trước khi bắt đầu soạn thư trả lời;
  - **Khi** nhấn Trả lời và soạn nội dung thư;
  - **Thì** màn hình soạn thư mở ra bình thường, người nhận được điền sẵn, người dùng có thể nhập nội dung và chọn template mà không gặp lỗi; chỉ bước Gửi mới bị chặn.

### 5. Trường hợp ngoại lệ & lỗi

- Khi người gửi gốc đã xoá tài khoản: hệ thống vẫn cho soạn thư trả lời nhưng thông báo người nhận có thể không còn hoạt động.
- Khi người dùng thoát giữa chừng soạn thư trả lời: hỏi xác nhận "Bỏ thư này?" tương tự soạn thư mới.

**Nhóm 1 — Khi mất kết nối:**

- Người dùng vẫn mở được màn hình soạn thư trả lời và nhập nội dung bình thường khi mất mạng, vì bước soạn thư là cục bộ.
- Khi mất mạng, nút Gửi bị vô hiệu hoá và hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." — nội dung đã soạn không bị mất.
- Khi mạng trở lại, nút Gửi được kích hoạt lại và người dùng có thể gửi thư mà không cần nhập lại nội dung.

**Nhóm 2 — Khi dữ liệu không tải được:**

- Nếu thông tin người gửi gốc không tải được (lỗi mạng hoặc máy chủ), màn hình soạn thư hiển thị trạng thái lỗi với nút "Thử lại" thay vì điền sẵn tên người nhận.
- Người dùng nhấn "Thử lại" để hệ thống tải lại thông tin người gửi gốc và tiếp tục soạn thư.

**Nhóm 3 — Khi chưa đăng nhập / thoát app giữa chừng:**

- Người dùng chưa đăng nhập nhấn Trả lời trong app sẽ được chuyển sang màn hình đăng nhập/đăng ký trước; sau khi đăng nhập thành công, hệ thống quay lại màn hình soạn thư trả lời.
- Khi người dùng thoát app giữa chừng đang soạn thư trả lời, nội dung đã soạn được lưu nháp cục bộ; lần sau mở lại app hệ thống hỏi có muốn tiếp tục thư đang soạn dở không.

---

### Liên kết tính năng khác

- SM-019 (Mở thư & Animation): nút Trả lời xuất hiện sau animation.
- SM-016 (Gửi thư qua MXH): luồng gửi dùng chung cho thư trả lời.
- SM-012 (Chọn template thư): template reply được gợi ý sẵn nhưng người dùng có thể đổi.

---

## Thiết kế màn hình

> **Quy tắc:** ✅ Vẽ riêng · 📝 Annotation trên frame gốc · ♻️ Dùng lại layout từ flow khác

### Tổng quan trạng thái trong spec

| Màn hình | Trạng thái |
|---|---|
| Web nhận thư | Guest · Already-opened · Link-expired · Invalid-link · Offline |
| Mở thư & Animation | Animating · Completed · Guest-completed · Re-view · Offline · Animation-error |
| Hộp thư đến | Default · Unread-filter · Empty · Offline · Error |
| Trả lời thư | Compose · Web-no-app · Offline |

**Tổng: ~16 trạng thái / 4 loại màn hình**

### Frame cần thiết kế (9 frame)

| # | Frame | Ghi chú |
|---|---|---|
| 1 | Web nhận thư — Guest | Phong bì lớn + nút "Mở thư" + banner tải app |
| 2 | Web nhận thư — Already-opened / Expired | Trang lỗi + CTA "Yêu cầu link mới"; gộp 2 trạng thái |
| 3 | Animation — Keyframe A | Phong bì rung + nắp mở |
| 4 | Animation — Keyframe B | Giấy thư trượt ra |
| 5 | Thư đã mở — Completed | Đã đăng nhập: tem + nội dung + nút Trả lời + Lưu |
| 6 | Thư đã mở — Guest-completed | Nút Lưu bị disable + banner "Tải app để lưu" |
| 7 | Hộp thư đến — Default | Danh sách thư với badge chưa đọc |
| 8 | Hộp thư đến — Empty | |
| 9 | Trả lời thư — Compose | ♻️ Layout tương tự flow 3 Soạn thư, chỉ chọn 1 tem |

**Bỏ qua / annotation:** Invalid-link (📝 gộp vào frame 2); Re-view (📝 annotation trên frame 5); Offline / Animation-error (📝 banner / toast); Unread-filter (📝 chip filter annotation trên frame 7); Hộp thư Error (📝 skeleton + nút retry); Web-no-app (📝 modal "tải app để trả lời").

# Flow 7 · Tài khoản

Hồ sơ và cài đặt.

---

## Hồ sơ người dùng (SM-024)

> Nguồn: `specs/002-ho-so-nguoi-dung.md`

**Màn hình & trạng thái:**

- **Hồ sơ**: Own-Free · Own-Premium · Own-Stats-hidden · Viewed-others · Viewed-stats-hidden · Offline
- **Sửa hồ sơ**: Avatar-crop · Display-name · Change-username · DOB-editor

### 1. Mục đích nghiệp vụ

Cho phép người dùng cá nhân hoá tài khoản (ảnh đại diện, tên hiển thị, username) và theo dõi tóm tắt hoạt động của mình (tem đã tạo, thư đã gửi, thư đã nhận, bộ sưu tập hoàn chỉnh). Hồ sơ cũng hiển thị trạng thái gói đăng ký hiện tại (Free / Premium) và lối tắt nâng cấp. Hồ sơ cũng là nơi người khác có thể thấy thông tin cơ bản về người dùng.

### 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đã đăng nhập.
- **Khi nào dùng:** Khi muốn cập nhật thông tin cá nhân hoặc xem lại thống kê hoạt động của mình.
- **Điều kiện tiên quyết:** Đã đăng nhập (xem SM-001).
- **Phạm vi:** Chỉnh ảnh đại diện, tên hiển thị, username, ngày sinh; xem thống kê hoạt động; ẩn/hiện thống kê với người khác. Không bao gồm xoá tài khoản hay đổi mật khẩu (xem SM-027 và SM-002).

### 3. Quy tắc nghiệp vụ

- **BR-01 — Ảnh đại diện:** Người dùng tải ảnh và cắt tự do thành hình vuông tỉ lệ một-một trước khi lưu.
- **BR-02 — Tên hiển thị:** Người dùng đổi tên hiển thị tự do, tối đa ba mươi ký tự, bất kỳ lúc nào.
- **BR-03 — Username — giới hạn đổi:** Username chỉ được đổi thêm một lần sau lần đầu đăng ký. Sau khi dùng hết lượt đổi, username bị khoá vĩnh viễn.
- **BR-04 — Thống kê hoạt động:** Hồ sơ hiển thị bốn chỉ số: tổng số tem đã tạo, tổng số thư đã gửi, tổng số thư đã nhận, số bộ sưu tập theo series đã hoàn chỉnh.
- **BR-05 — Ẩn thống kê:** Người dùng có thể chọn ẩn toàn bộ thống kê hoạt động với người khác. Khi ẩn, người khác xem hồ sơ không thấy các chỉ số này; chủ tài khoản vẫn thấy.
- **BR-06 — Ngày sinh (tùy chọn):** Người dùng có thể nhập ngày sinh gồm ngày và tháng (bắt buộc nếu chọn điền) và năm sinh (tùy chọn). Trường này không bắt buộc — người dùng có thể bỏ qua hoặc xoá bất kỳ lúc nào.
- **BR-07 — Riêng tư ngày sinh:** Ngày sinh mặc định chỉ hiển thị với chính người dùng. Người dùng có thể chọn cho người khác thấy ngày và tháng sinh trên hồ sơ — năm sinh không bao giờ hiển thị với người khác dù đã bật.
- **BR-10 — Trạng thái gói đăng ký trên hồ sơ:** Hồ sơ luôn hiển thị gói đăng ký hiện tại của người dùng: "Free" hoặc "Premium". Người dùng Premium thấy thêm ngày hết hạn gói. Thông tin này chỉ hiển thị với chính người dùng, không hiển thị cho người khác xem hồ sơ.
- **BR-11 — Lối tắt nâng cấp cho người dùng Free:** Người dùng đang ở gói Free thấy nút "Nâng cấp Premium" ngay trên màn hình hồ sơ. Nhấn vào dẫn thẳng đến màn hình nâng cấp (SM-028). Người dùng Premium không thấy nút này.

#### Trạng thái offline

- **BR-08 — Xem hồ sơ khi mất mạng:** Khi mất kết nối, hồ sơ (ảnh đại diện, tên hiển thị, username, thống kê) vẫn hiển thị theo dữ liệu đã tải lần cuối; app thông báo "Đang xem ngoại tuyến" để người dùng biết dữ liệu có thể chưa được cập nhật mới nhất.
- **BR-09 — Chặn lưu thay đổi khi mất mạng:** Khi mất kết nối, mọi hành động cần ghi lên hệ thống (cập nhật ảnh đại diện, đổi tên hiển thị, đổi username, lưu ngày sinh, thay đổi tùy chọn riêng tư) đều bị vô hiệu hóa; app thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." Dữ liệu người dùng đang nhập được giữ nguyên trên màn hình để tiện chỉnh lại khi có mạng trở lại.

### 4. Tiêu chí nghiệm thu

- **AC-01 — Cập nhật ảnh đại diện:**
  - **Giả sử** người dùng đang ở màn hình hồ sơ;
  - **Khi** chọn ảnh mới, cắt thành hình vuông và xác nhận lưu;
  - **Thì** ảnh đại diện mới hiển thị ngay trên hồ sơ và trên mọi nơi trong app.

- **AC-02 — Đổi tên hiển thị:**
  - **Giả sử** người dùng đang ở màn hình hồ sơ;
  - **Khi** nhập tên hiển thị mới (không quá ba mươi ký tự) và lưu;
  - **Thì** tên hiển thị mới áp dụng ngay.

- **AC-03 — Đổi username lần 2 thành công:**
  - **Giả sử** người dùng chưa dùng lượt đổi username;
  - **Khi** nhập username mới hợp lệ và xác nhận;
  - **Thì** username được cập nhật và hệ thống thông báo đã hết lượt đổi.

- **AC-04 — Không cho đổi username lần 3:**
  - **Giả sử** người dùng đã dùng hết một lượt đổi username;
  - **Khi** cố gắng đổi username lần nữa;
  - **Thì** hệ thống thông báo đã hết lượt đổi và không cho thực hiện.

- **AC-05 — Ẩn thống kê với người khác:**
  - **Giả sử** người dùng bật tùy chọn ẩn thống kê;
  - **Khi** người dùng khác xem hồ sơ;
  - **Thì** phần thống kê không hiển thị; nhưng chủ tài khoản vẫn thấy thống kê của mình.

- **AC-06 — Nhập ngày sinh thành công:**
  - **Giả sử** người dùng đang ở màn hình hồ sơ và chưa có ngày sinh;
  - **Khi** chọn điền ngày sinh, nhập đúng ngày và tháng (năm tùy chọn) rồi lưu;
  - **Thì** ngày sinh được lưu và hiển thị trên hồ sơ của chính người dùng.

- **AC-07 — Xoá ngày sinh:**
  - **Giả sử** người dùng đã có ngày sinh trên hồ sơ;
  - **Khi** chọn xoá ngày sinh và xác nhận;
  - **Thì** trường ngày sinh trống, không còn hiển thị trên hồ sơ.

- **AC-08 — Cho phép người khác thấy ngày và tháng sinh:**
  - **Giả sử** người dùng đã nhập ngày sinh và bật tùy chọn hiển thị với người khác;
  - **Khi** người dùng khác xem hồ sơ;
  - **Thì** chỉ ngày và tháng sinh hiển thị — năm sinh không bao giờ xuất hiện.

- **AC-09 — Ngày sinh riêng tư theo mặc định:**
  - **Giả sử** người dùng vừa nhập ngày sinh lần đầu;
  - **Khi** người dùng khác xem hồ sơ ngay sau đó;
  - **Thì** ngày sinh không hiển thị — mặc định là riêng tư.

- **AC-12 — Hiển thị trạng thái Premium trên hồ sơ:**
  - **Giả sử** người dùng đang ở gói Premium và mở màn hình hồ sơ;
  - **Khi** xem trang hồ sơ của mình;
  - **Thì** nhãn "Premium" và ngày hết hạn gói hiển thị rõ ràng; không có nút "Nâng cấp Premium".

- **AC-13 — Người dùng Free thấy nút nâng cấp:**
  - **Giả sử** người dùng đang ở gói Free và mở màn hình hồ sơ;
  - **Khi** xem trang hồ sơ của mình;
  - **Thì** nhãn "Free" hiển thị và nút "Nâng cấp Premium" xuất hiện; nhấn vào dẫn đến màn hình nâng cấp.

- **AC-14 — Trạng thái gói không hiển thị với người xem khác:**
  - **Giả sử** người dùng A đang xem hồ sơ công khai của người dùng B;
  - **Khi** xem trang hồ sơ đó;
  - **Thì** không có nhãn Free / Premium nào của B hiển thị với A.

#### Offline

- **AC-10 — Xem hồ sơ khi mất mạng:**
  - **Giả sử** người dùng đã từng xem hồ sơ khi có mạng và sau đó mất kết nối;
  - **Khi** mở lại màn hình hồ sơ;
  - **Thì** hồ sơ vẫn hiển thị theo dữ liệu đã tải lần cuối và app hiện thông báo "Đang xem ngoại tuyến".

- **AC-11 — Không cho lưu thay đổi khi mất mạng:**
  - **Giả sử** người dùng đang chỉnh sửa thông tin hồ sơ và mất kết nối trước khi lưu;
  - **Khi** nhấn lưu (ảnh đại diện, tên hiển thị, username, ngày sinh hoặc tùy chọn riêng tư);
  - **Thì** app thông báo "Không có kết nối. Vui lòng thử lại khi có mạng.", không thực hiện lưu, và giữ nguyên nội dung đã nhập trên màn hình.

### 5. Trường hợp ngoại lệ & lỗi

- Khi tên hiển thị vượt quá ba mươi ký tự: hệ thống báo lỗi ngay tại ô nhập, không cho lưu.
- Khi ảnh tải lên quá lớn hoặc định dạng không được hỗ trợ: thông báo lỗi định dạng và gợi ý dùng ảnh khác.
- Khi username mới đã bị người khác dùng: thông báo "Tên người dùng đã tồn tại".

#### Khi mất kết nối (offline / no network)

- Khi mất kết nối, hồ sơ (ảnh đại diện, tên hiển thị, username, thống kê) vẫn hiển thị theo dữ liệu đã tải lần cuối; app hiện banner "Đang xem ngoại tuyến" để người dùng biết thông tin có thể chưa mới nhất.
- Khi mất kết nối, mọi nút lưu thay đổi (ảnh đại diện, tên hiển thị, username, ngày sinh, tùy chọn riêng tư) bị vô hiệu hoá; app thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." và giữ nguyên nội dung đang nhập trên màn hình để người dùng không phải nhập lại khi có mạng trở lại.

#### Khi dữ liệu không tải được (lỗi mạng / lỗi máy chủ)

- Khi hồ sơ không tải được do lỗi mạng hoặc lỗi máy chủ và không có dữ liệu cache: màn hình hiển thị thông báo lỗi và nút "Thử lại" để người dùng tải lại mà không cần thoát.
- Khi có dữ liệu cache cũ nhưng không thể tải mới: hồ sơ vẫn hiển thị theo cache, đồng thời có thông báo nhỏ và nút "Thử lại" để làm mới.

#### Khi chưa đăng nhập / thoát app giữa chừng

- Khi người dùng chưa đăng nhập cố truy cập màn hình hồ sơ: app chuyển ngay về màn hình đăng nhập, không hiển thị bất kỳ thông tin hồ sơ nào.
- Khi người dùng thoát app giữa chừng trong lúc đang chỉnh sửa hồ sơ nhưng chưa lưu: thay đổi chưa lưu bị huỷ; lần sau vào lại, hồ sơ hiển thị thông tin đã lưu trước đó.

---

### Liên kết tính năng khác

- SM-002 (Xác thực & Bảo mật): đổi mật khẩu trong cài đặt.
- SM-022 (Album sưu tập tem): bộ sưu tập hoàn chỉnh được đếm trong thống kê.
- SM-027 (Cài đặt tài khoản): ẩn thống kê hồ sơ, chặn người dùng.
- SM-028 (Nâng cấp Premium): lối tắt từ nút "Nâng cấp Premium" trên hồ sơ.
- SM-029 (Quản lý Premium): ngày hết hạn gói hiển thị trên hồ sơ lấy từ đây.

---

## Cài đặt tài khoản & Quyền riêng tư (SM-027)

> Nguồn: `specs/023-cai-dat-tai-khoan.md`

**Màn hình & trạng thái:**

- **Cài đặt**: Default · Offline
- **Đổi mật khẩu**: Default · Error · Success
- **Ngôn ngữ**: Picker
- **Chặn người dùng**: Empty
- **Liên kết tài khoản**: List · Cannot-unlink-last · Unlink-success

### 1. Mục đích nghiệp vụ

Là nơi người dùng kiểm soát tài khoản và trải nghiệm của mình: bảo mật (đổi mật khẩu, đăng xuất), tuỳ chọn cá nhân (ngôn ngữ, âm thanh), và quyền riêng tư (ẩn thống kê, chặn người dùng). Cũng là luồng xoá tài khoản với thời gian chờ an toàn.

### 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đã đăng nhập.
- **Khi nào dùng:** Khi muốn thay đổi cấu hình tài khoản hoặc quyền riêng tư.
- **Điều kiện tiên quyết:** Đã đăng nhập (SM-001).
- **Phạm vi:** Đổi mật khẩu, đăng xuất, đăng xuất tất cả thiết bị, xoá tài khoản, ngôn ngữ, âm thanh animation, ẩn thống kê, chặn người dùng, cài đặt thông báo. Không bao gồm nâng cấp Premium (SM-028) hay quản lý đăng ký (SM-029).

### 3. Quy tắc nghiệp vụ

- **BR-01 — Đổi mật khẩu:** Người dùng đổi mật khẩu bằng cách nhập mật khẩu cũ đúng trước. Sau khi đổi, tất cả thiết bị bị đăng xuất (xem SM-002).
- **BR-02 — Đăng xuất thiết bị hiện tại:** Đăng xuất chỉ thiết bị đang dùng; các thiết bị khác vẫn đăng nhập.
- **BR-03 — Đăng xuất tất cả thiết bị:** Đăng xuất toàn bộ thiết bị đang đăng nhập, kể cả thiết bị hiện tại.
- **BR-04 — Xoá tài khoản:** Người dùng yêu cầu xoá tài khoản → tài khoản vào trạng thái "chờ xoá" trong bảy ngày → sau bảy ngày tự xoá vĩnh viễn. Trong thời gian chờ, người dùng có thể huỷ yêu cầu xoá bằng cách đăng nhập lại.
- **BR-05 — Ngôn ngữ:** Người dùng chọn ngôn ngữ hiển thị của app. Thay đổi áp dụng ngay.
- **BR-06 — Âm thanh animation thư:** Người dùng bật/tắt âm thanh kèm animation mở thư (SM-019). Mặc định là bật.
- **BR-07 — Ẩn thống kê hồ sơ:** Người dùng bật/tắt ẩn thống kê hoạt động với người khác (xem SM-024).
- **BR-08 — Chặn người dùng:** Người dùng có thể chặn tài khoản khác. Khi bị chặn, người đó không thể gửi thư đến người chặn.
- **BR-09 — Cài đặt thông báo:** Bật/tắt từng loại thông báo push (xem SM-026).

#### Trạng thái offline

- **BR-10 — Thao tác bảo mật cần mạng:** Các hành động cần xác thực với máy chủ — đổi mật khẩu, đăng xuất (thiết bị hiện tại hoặc tất cả thiết bị), yêu cầu xoá tài khoản — bị chặn khi mất kết nối. Hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." và giữ nguyên dữ liệu đã nhập.
- **BR-11 — Tuỳ chọn cá nhân lưu tạm cục bộ:** Thay đổi ngôn ngữ hiển thị và trạng thái âm thanh animation có thể áp dụng ngay trên thiết bị khi offline; khi có mạng trở lại, tuỳ chọn được đồng bộ lên tài khoản tự động.

### 4. Tiêu chí nghiệm thu

- **AC-01 — Đăng xuất tất cả thiết bị:**
  - **Giả sử** người dùng đang đăng nhập trên hai thiết bị;
  - **Khi** chọn "Đăng xuất tất cả thiết bị";
  - **Thì** cả hai thiết bị bị đăng xuất và phải đăng nhập lại.

- **AC-02 — Yêu cầu xoá tài khoản:**
  - **Giả sử** người dùng muốn xoá tài khoản;
  - **Khi** xác nhận yêu cầu xoá;
  - **Thì** hệ thống thông báo tài khoản sẽ bị xoá sau bảy ngày và hướng dẫn cách huỷ.

- **AC-03 — Huỷ yêu cầu xoá tài khoản:**
  - **Giả sử** người dùng đã yêu cầu xoá và tài khoản đang trong thời gian chờ;
  - **Khi** đăng nhập lại trong bảy ngày và xác nhận huỷ xoá;
  - **Thì** tài khoản được giữ lại bình thường.

- **AC-04 — Tắt âm thanh animation:**
  - **Giả sử** người dùng tắt âm thanh animation trong cài đặt;
  - **Khi** mở một thư mới;
  - **Thì** animation diễn ra nhưng không có âm thanh.

- **AC-05 — Chặn người dùng:**
  - **Giả sử** người dùng A chặn người dùng B;
  - **Khi** B cố gửi thư đến A;
  - **Thì** link thư A tạo cho B không thể gửi đến A, hoặc A không nhận được thư từ B.

- **AC-06 — Đổi mật khẩu yêu cầu mật khẩu cũ:**
  - **Giả sử** người dùng vào mục đổi mật khẩu trong cài đặt;
  - **Khi** nhập đúng mật khẩu hiện tại, nhập mật khẩu mới và xác nhận;
  - **Thì** mật khẩu được thay đổi thành công và tất cả thiết bị khác bị đăng xuất.

- **AC-07 — Đăng xuất chỉ thiết bị hiện tại:**
  - **Giả sử** người dùng đang đăng nhập trên hai thiết bị;
  - **Khi** chọn "Đăng xuất" (chỉ thiết bị hiện tại);
  - **Thì** thiết bị hiện tại bị đăng xuất; thiết bị kia vẫn đăng nhập bình thường.

- **AC-08 — Đổi ngôn ngữ áp dụng ngay:**
  - **Giả sử** người dùng đang dùng app bằng tiếng Việt;
  - **Khi** vào cài đặt, chọn ngôn ngữ khác (ví dụ: tiếng Anh) và xác nhận;
  - **Thì** giao diện app chuyển sang ngôn ngữ đã chọn ngay, không cần khởi động lại.

- **AC-09 — Ẩn thống kê hồ sơ với người khác:**
  - **Giả sử** người dùng bật tùy chọn "Ẩn thống kê" trong cài đặt;
  - **Khi** người dùng khác xem hồ sơ của người này;
  - **Thì** phần thống kê (tem đã tạo, thư đã gửi…) không hiển thị với người xem; chủ tài khoản vẫn thấy số liệu của mình.

#### Offline

- **AC-10 — Chặn thao tác bảo mật khi mất mạng:**
  - **Giả sử** người dùng đang ở màn hình cài đặt và thiết bị mất kết nối mạng;
  - **Khi** người dùng nhấn "Đổi mật khẩu", "Đăng xuất tất cả thiết bị", hoặc "Yêu cầu xoá tài khoản";
  - **Thì** thao tác không được thực hiện, hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." và dữ liệu đã nhập (nếu có) được giữ nguyên.

- **AC-11 — Tuỳ chọn cá nhân hoạt động offline và đồng bộ khi có mạng:**
  - **Giả sử** người dùng đang ở màn hình cài đặt và thiết bị mất kết nối mạng;
  - **Khi** người dùng thay đổi ngôn ngữ hiển thị hoặc bật/tắt âm thanh animation;
  - **Thì** thay đổi áp dụng ngay trên thiết bị; khi kết nối mạng được khôi phục, tuỳ chọn được đồng bộ lên tài khoản mà không cần thao tác thêm.

### 5. Trường hợp ngoại lệ & lỗi

**Khi mất kết nối (offline):**
- Màn hình cài đặt vẫn hiển thị đầy đủ từ dữ liệu lưu trên thiết bị (ngôn ngữ, trạng thái âm thanh, danh sách chặn…); người dùng có thể xem nhưng không lưu thay đổi lên tài khoản.
- Khi mất kết nối lúc thực hiện thao tác quan trọng (xoá tài khoản, đăng xuất tất cả): hệ thống thông báo lỗi mạng, thao tác chưa được thực hiện và dữ liệu đã nhập được giữ nguyên.
- Thay đổi ngôn ngữ và trạng thái âm thanh animation vẫn áp dụng ngay trên thiết bị khi offline; các thay đổi này sẽ được đồng bộ lên tài khoản tự động khi có mạng trở lại.

**Khi dữ liệu không tải được (lỗi máy chủ):**
- Nếu danh sách chặn hoặc cài đặt thông báo không tải được, màn hình hiển thị thông báo lỗi kèm nút "Thử lại" để người dùng tải lại mà không cần thoát màn hình.
- Các tuỳ chọn đã được lưu cục bộ trước đó vẫn hiển thị đúng; chỉ phần cần đồng bộ từ máy chủ mới báo lỗi.

**Khi chưa đăng nhập hoặc thoát app giữa chừng:**
- Nếu người dùng chưa đăng nhập và truy cập vào màn hình Cài đặt, hệ thống chuyển ngay về màn hình Đăng nhập.
- Khi tài khoản đã trong thời gian chờ xoá và hết bảy ngày: tài khoản bị xoá vĩnh viễn; mọi dữ liệu (tem, thư) bị xoá theo.
- Nếu người dùng thoát app giữa chừng khi đang nhập mật khẩu mới hoặc điền biểu mẫu, dữ liệu đang nhập bị huỷ; lần sau mở lại cần nhập lại từ đầu.

---

### Liên kết tính năng khác

- SM-002 (Xác thực & Bảo mật): đổi mật khẩu, liên kết Google/Apple.
- SM-024 (Hồ sơ người dùng): ẩn/hiện thống kê được điều khiển từ đây.
- SM-026 (Thông báo push): cài đặt từng loại thông báo từ đây.
- SM-019 (Mở thư & Animation): âm thanh animation được điều khiển từ đây.

---

## Thông báo push (SM-026)

> Nguồn: `specs/022-thong-bao-push.md`

**Màn hình & trạng thái:**

- **Thông báo**: Default
- **Quyền thông báo**: Denied
- **Hàng chờ offline**: Queued
- **Điều hướng từ thông báo**: Routes

### 1. Mục đích nghiệp vụ

Kéo người dùng quay lại app vào đúng thời điểm họ cần — khi có thư mới đến, khi thư được đọc, khi hạn mức sắp cạn. Mỗi loại thông báo phục vụ một vòng lặp re-engagement khác nhau.

### 2. Đối tượng & phạm vi

- **Người dùng:** Người dùng đã đăng nhập và đã cấp quyền nhận thông báo.
- **Khi nào dùng:** Hệ thống tự động gửi dựa trên sự kiện; người dùng không kích hoạt thủ công.
- **Điều kiện tiên quyết:** Đã đăng nhập (SM-001). Đã cấp quyền thông báo cho app.
- **Phạm vi:** Năm loại thông báo push (3 loại sự kiện thông thường + 2 loại Dấu) và cài đặt bật/tắt từng loại độc lập. Không bao gồm thông báo trong app (in-app notification — hiển thị khi đang dùng app).

### 3. Quy tắc nghiệp vụ

- **BR-01 — Năm loại thông báo:** Hệ thống gửi thông báo push cho năm sự kiện sau:
  - (1) **Thư đến:** "Bạn có thư mới từ [tên người gửi]" — khi người dùng nhận được link thư mới.
  - (2) **Thư được đọc:** "[Tên người nhận] đã mở thư của bạn" — khi người nhận mở link thư.
  - (3) **Hạn mức Free sắp cạn:** "Bạn còn [N] thư / [N] tem trong tháng này"
  - (4) **Kiếm Dấu khi thư được mở:** "Thư của bạn đã được mở — bạn nhận 15📮!" — khi người nhận hoàn thành xem animation lần đầu (SM-019 BR-06).
  - (5) **Kiếm Dấu khi giới thiệu người dùng mới:** "Bạn vừa giới thiệu người dùng mới và nhận 50📮!" — khi người nhận cài app từ link thư trong hạn mức 5 lượt/tháng (SM-016 BR-11).
- **BR-02 — Cài đặt bật/tắt từng loại:** Người dùng có thể bật hoặc tắt từng loại thông báo riêng biệt trong cài đặt — không phải bật/tắt tất cả cùng lúc.
- **BR-03 — Cần quyền hệ điều hành:** Trước khi gửi thông báo lần đầu, app phải xin quyền thông báo từ hệ điều hành. Nếu người dùng từ chối, không có thông báo nào được gửi.
- **BR-04 — Nhấn thông báo dẫn đến đúng màn hình:** Nhấn vào thông báo mở thẳng màn hình liên quan (thư đến → màn hình mở thư; thư được đọc → hộp thư đã gửi; hạn mức → màn hình nâng cấp Premium; thông báo Dấu → màn hình số Dấu hiện có).
- **BR-05 — Thông báo Dấu có thể tắt riêng:** Hai loại thông báo Dấu (loại 4 và 5) có thể bật/tắt riêng biệt, độc lập với ba loại thông báo còn lại.

#### Trạng thái offline

- **BR-06 — Xếp hàng chờ khi thiết bị mất mạng:** Khi thiết bị của người nhận đang mất kết nối mạng, thông báo push chưa được giao vẫn được giữ lại trong hàng chờ và tự động giao đến thiết bị ngay khi có kết nối trở lại — không cần người dùng thao tác thêm.
- **BR-07 — Nội dung thông báo không thay đổi sau khi chờ:** Thông báo được giao sau khi thiết bị có mạng trở lại phải giữ nguyên nội dung ban đầu (tên người gửi, số Dấu, v.v.) — không bị mất dữ liệu hoặc hiển thị sai trong khi chờ.

### 4. Tiêu chí nghiệm thu

- **AC-01 — Thông báo thư đến:**
  - **Giả sử** người dùng A gửi link thư cho người dùng B và B mở link;
  - **Khi** B nhận và mở link thư;
  - **Thì** A nhận thông báo push "B đã mở thư của bạn" (nếu loại này đang bật).

- **AC-02 — Tắt một loại thông báo:**
  - **Giả sử** người dùng vào cài đặt và tắt "Thông báo thư được đọc";
  - **Khi** người nhận mở thư của người dùng;
  - **Thì** người dùng không nhận thông báo "đã mở thư", nhưng các loại thông báo khác vẫn hoạt động.

- **AC-03 — Nhấn thông báo dẫn đúng màn hình:**
  - **Giả sử** người dùng nhận thông báo "Bạn có thư mới từ An";
  - **Khi** nhấn vào thông báo;
  - **Thì** app mở và chuyển thẳng đến màn hình mở thư đó (với animation — SM-019).

- **AC-04 — Thông báo hạn mức sắp cạn:**
  - **Giả sử** người dùng gói Thường còn hai thư trong tháng (hạn mức tháng là mười thư);
  - **Khi** gửi thư thứ chín;
  - **Thì** nhận thông báo "Bạn còn 1 thư trong tháng này".

- **AC-05 — Không thông báo khi đã tắt tất cả:**
  - **Giả sử** người dùng đã tắt toàn bộ quyền thông báo ở cài đặt hệ điều hành;
  - **Khi** có bất kỳ sự kiện nào xảy ra;
  - **Thì** người dùng không nhận được thông báo push nào.

- **AC-06 — Thông báo Dấu khi thư được mở:**
  - **Giả sử** người dùng A đã gửi thư và bật loại thông báo loại 4;
  - **Khi** người nhận hoàn thành xem animation lần đầu;
  - **Thì** A nhận thông báo push "Thư của bạn đã được mở — bạn nhận 15📮!".

- **AC-07 — Thông báo Dấu khi giới thiệu người dùng mới:**
  - **Giả sử** người dùng A đã gửi thư và bật loại thông báo loại 5;
  - **Khi** người nhận cài StampMail từ link thư và A chưa đủ 5 lượt trong tháng;
  - **Thì** A nhận thông báo push "Bạn vừa giới thiệu người dùng mới và nhận 50📮!".

#### Offline

- **AC-08 — Thông báo được giao sau khi có mạng trở lại:**
  - **Giả sử** thiết bị của người dùng A đang mất kết nối mạng và hệ thống phát sinh thông báo "Bạn có thư mới từ Bình";
  - **Khi** thiết bị của A kết nối mạng trở lại;
  - **Thì** A nhận được thông báo đó với đúng nội dung ban đầu, không bị mất hay sai thông tin.

- **AC-09 — Nhiều thông báo xếp hàng đều được giao đủ:**
  - **Giả sử** trong khi thiết bị của người dùng A mất mạng, có ba sự kiện phát sinh (một thư đến, một thư được đọc, một thông báo Dấu) và cả ba loại tương ứng đang bật;
  - **Khi** thiết bị kết nối lại;
  - **Thì** A nhận đủ ba thông báo, mỗi thông báo đúng nội dung và đúng loại.

### 5. Trường hợp ngoại lệ & lỗi

- Khi người dùng từ chối quyền thông báo: trong lần đầu từ chối, app không hỏi lại; nhưng trong cài đặt, hiển thị hướng dẫn cấp quyền thủ công từ cài đặt điện thoại.
- Khi thiết bị đang tắt hoặc ngoại tuyến: thông báo được hàng đợi và gửi khi thiết bị có kết nối trở lại (tùy hệ điều hành).
- Khi mất kết nối và người dùng thay đổi cài đặt thông báo: thay đổi bật/tắt từng loại thông báo vẫn được lưu cục bộ ngay lập tức và tự đồng bộ lên hệ thống khi có mạng trở lại — người dùng không cần thao tác lại.
- Khi hệ thống không giao được thông báo do lỗi máy chủ: người dùng không thấy màn hình lỗi; thông báo bị bỏ qua lần đó và sẽ không tự gửi lại — người dùng có thể kiểm tra trạng thái thư trong hộp thư thay thế.
- Khi chưa đăng nhập: app không gửi bất kỳ thông báo cá nhân nào (thư đến, thư được đọc, hạn mức, Dấu); màn hình cài đặt thông báo không hiển thị với người dùng chưa đăng nhập.
- Khi người dùng thoát app giữa chừng (đang xem cài đặt thông báo): các thay đổi đã lưu được giữ nguyên; lần sau vào lại app, cài đặt hiển thị đúng trạng thái đã chỉnh trước đó.

---

### Liên kết tính năng khác

- SM-027 (Cài đặt tài khoản): nơi người dùng bật/tắt từng loại thông báo.
- SM-016 (Gửi thư): kích hoạt thông báo "thư được đọc".
- SM-017 (Nhận thư): kích hoạt thông báo "thư đến".
- SM-030 (Giới hạn tháng): kích hoạt thông báo "hạn mức sắp cạn".
- SM-033 (Hệ thống Dấu): nguồn của thông báo loại 4 (thư được mở → 15📮) và loại 5 (giới thiệu người dùng mới → 50📮).

---

## Thiết kế màn hình

> **Quy tắc:** ✅ Vẽ riêng · 📝 Annotation trên frame gốc · ♻️ Dùng lại layout từ flow khác

### Tổng quan trạng thái trong spec

| Màn hình | Trạng thái |
|---|---|
| Hồ sơ người dùng | Own-Free · Own-Premium · Own-Stats-hidden · Viewed-others · Viewed-stats-hidden · Offline |
| Sửa hồ sơ | Avatar-crop · Display-name · Change-username · DOB-editor |
| Cài đặt | Default · Offline |
| Đổi mật khẩu | Default · Error · Success |
| Ngôn ngữ | Picker |
| Chặn người dùng | Empty · Has-users |
| Liên kết tài khoản | List · Cannot-unlink-last · Unlink-success |
| Thông báo | Default · Denied · Queued · Routes |

**Tổng: ~24 trạng thái / 8 loại màn hình**

### Frame cần thiết kế (13 frame)

| # | Frame | Ghi chú |
|---|---|---|
| 1 | Hồ sơ — Own Free | Nhãn "Miễn phí" + nút Nâng cấp + thống kê |
| 2 | Hồ sơ — Own Premium | Nhãn "Premium" + ngày hết hạn, không có nút Nâng cấp |
| 3 | Hồ sơ — Xem người khác | Không có nhãn gói; thống kê có thể ẩn |
| 4 | Sửa hồ sơ — Crop avatar | Khung cắt 1:1 + tay kéo |
| 5 | Sửa hồ sơ — Thông tin | Display name + Username + Ngày sinh trong 1 form |
| 6 | Cài đặt — Default | Menu: Bảo mật / Cá nhân / Quyền riêng tư / Danger zone |
| 7 | Đổi mật khẩu — Default | Error + Success → 📝 annotation cùng layout |
| 8 | Ngôn ngữ — Picker | Danh sách ngôn ngữ hỗ trợ |
| 9 | Chặn người dùng — Empty | |
| 10 | Chặn người dùng — Has-users | Danh sách + nút "Bỏ chặn" |
| 11 | Liên kết tài khoản — List | Icon mạng xã hội + trạng thái Liên kết / Huỷ liên kết |
| 12 | Thông báo — Default | Toggle cho từng loại thông báo |
| 13 | Xoá tài khoản — Confirm | Thông báo 7 ngày chờ + 2 nút Xác nhận / Huỷ |

**Bỏ qua / annotation:** Own-Stats-hidden (📝 annotation trên frame 1 và 3); Offline (📝 banner); Cannot-unlink-last (📝 toast annotation); Unlink-success (📝 toast); Denied (📝 annotation + link OS settings); Queued / Routes (hành vi hệ thống, không vẽ).

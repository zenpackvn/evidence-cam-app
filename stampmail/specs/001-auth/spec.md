# Xác thực tài khoản — Đăng ký, Đăng nhập & Bảo mật (SM-000)

**Feature Branch**: `001-auth`
**Ngày tạo**: 2026-06-26
**Trạng thái**: Draft
**Ưu tiên**: P1

> **Tài liệu thuần nghiệp vụ** cho Tester (QA), Business Analyst (BA), Product Owner (PO).
> **KHÔNG chứa chi tiết kỹ thuật**. Phần plan / vẽ giao diện / develop được làm RIÊNG ở bước sau.

> Spec này gộp ba spec cũ: `001-dang-ky`, `002-dang-nhap`, `003-xac-thuc-bao-mat`.

---

## 1. Mục đích nghiệp vụ

Quản lý toàn bộ vòng đời xác thực tài khoản: cho phép người dùng mới tạo tài khoản, người dùng cũ đăng nhập trở lại, và mọi người dùng duy trì quyền kiểm soát tài khoản (đổi mật khẩu, khôi phục khi quên, quản lý phương thức đăng nhập). Đây là cổng vào duy nhất của hệ thống — không có tài khoản thì không tạo/lưu/gửi được.

## 2. Đối tượng & phạm vi

- **Người dùng:** Người chưa có tài khoản (đăng ký) và người đã có tài khoản (đăng nhập, bảo mật).
- **Khi nào dùng:** Lần đầu mở ứng dụng; khi mở app trên thiết bị mới; sau khi đăng xuất hoặc phiên hết hạn; khi muốn đổi/khôi phục mật khẩu.
- **Điều kiện tiên quyết:** Không (đăng ký không yêu cầu gì trước).
- **Phạm vi:** Đăng ký, đăng nhập, phiên tự động, khoá tạm, quên mật khẩu, đổi mật khẩu, liên kết/huỷ liên kết phương thức. Không bao gồm xoá tài khoản (SM-027) và onboarding sau đăng ký (SM-003).

---

## 3. Quy tắc nghiệp vụ

### Đăng ký

- **BR-01 — Phương thức đăng ký:** Người dùng đăng ký bằng một trong bốn cách: email và mật khẩu, tài khoản Google, tài khoản Apple, hoặc tài khoản Facebook.
- **BR-02 — Xác nhận email bắt buộc:** Sau khi đăng ký bằng email/mật khẩu, hệ thống gửi email xác nhận. Người dùng phải nhấp link trong email trước khi sử dụng đầy đủ ứng dụng. Đăng ký qua Google/Apple/Facebook bỏ qua bước này.
- **BR-03 — Tuổi tối thiểu:** Người dùng phải xác nhận đủ 13 tuổi trở lên khi đăng ký. Nếu không xác nhận, không hoàn tất được đăng ký.
- **BR-04 — Username:** Người dùng chọn tên người dùng duy nhất, từ 3 đến 30 ký tự. Không được trùng với bất kỳ tài khoản nào đã có.
- **BR-05 — Gói mặc định:** Tài khoản mới tạo mặc định ở gói Free.
- **BR-06 — Ảnh đại diện:** Người dùng có thể tải ảnh đại diện ngay khi đăng ký hoặc bỏ qua và cập nhật sau.
- **BR-07 — Mật khẩu:** Mật khẩu tối thiểu sáu ký tự. (Quy tắc chi tiết xem BR-19.)

### Đăng nhập & Phiên

- **BR-08 — Phương thức đăng nhập:** Người dùng đăng nhập bằng đúng phương thức đã dùng khi đăng ký. Dùng sai phương thức (ví dụ: đăng ký bằng email nhưng chọn đăng nhập bằng Facebook) thì bị thông báo lỗi.
- **BR-09 — Phiên tự động:** Sau khi đăng nhập thành công, phiên được ghi nhớ tự động chín mươi ngày. Người dùng không cần đăng nhập lại mỗi lần mở app trong thời gian đó.
- **BR-10 — Hết hạn phiên:** Phiên tự động hết hiệu lực sau chín mươi ngày không có hoạt động nào. Sau đó người dùng phải đăng nhập lại.
- **BR-11 — Khoá tạm thời sau nhập sai:** Nếu người dùng nhập sai mật khẩu năm lần liên tiếp, tài khoản bị khoá đăng nhập tạm thời trong mười lăm phút. Hệ thống thông báo số lần thử còn lại trước mỗi lần bị khoá.

### Bảo mật & Khôi phục

- **BR-12 — Quên mật khẩu:** Khi yêu cầu đặt lại mật khẩu, hệ thống gửi một link đặt lại đến email đã đăng ký. Link chỉ có hiệu lực trong hai mươi bốn giờ và chỉ dùng được một lần duy nhất. Hệ thống không tiết lộ email có tồn tại hay không.
- **BR-13 — Đổi mật khẩu:** Để đổi mật khẩu khi đang đăng nhập, người dùng phải nhập đúng mật khẩu hiện tại trước. Không được bỏ qua bước này.
- **BR-14 — Đăng xuất tất cả thiết bị:** Sau khi đặt lại hoặc đổi mật khẩu thành công, tất cả thiết bị đang đăng nhập (trừ thiết bị thực hiện thay đổi) bị đăng xuất ngay lập tức.
- **BR-15 — Liên kết phương thức đăng nhập:** Người dùng có thể thêm liên kết Google, Apple hoặc Facebook vào tài khoản hiện có để dùng được nhiều phương thức đăng nhập.
- **BR-16 — Huỷ liên kết:** Người dùng chỉ được huỷ liên kết một phương thức nếu vẫn còn ít nhất một phương thức đăng nhập khác — tránh khoá mình khỏi tài khoản.

### Khôi phục & Đồng bộ

- **BR-17 — Khôi phục giao dịch mua khi đăng nhập:** Khi người dùng đăng nhập thành công, hệ thống tự động khôi phục các giao dịch mua trong ứng dụng (Premium, Dấu) đã thực hiện trước đó trên cùng tài khoản App Store/Google Play. Người dùng không cần thực hiện thêm thao tác nào.

### Nhập liệu & Validation

- **BR-18 — Quy tắc nhập email (3 luồng email/mật khẩu):** Áp dụng đồng nhất cho cả đăng nhập, đăng ký và quên mật khẩu:
  - Email bắt buộc nhập; nếu để trống báo "Vui lòng nhập email".
  - Email phải đúng định dạng địa chỉ email hợp lệ; nếu sai báo "Email không hợp lệ".
- **BR-19 — Quy tắc nhập mật khẩu (đăng nhập & đăng ký):**
  - Mật khẩu bắt buộc nhập; nếu để trống báo "Vui lòng nhập mật khẩu".
  - Mật khẩu phải có ít nhất 6 ký tự; nếu ngắn hơn báo "Mật khẩu phải có ít nhất 6 ký tự".
- **BR-20 — Quy tắc xác nhận mật khẩu (chỉ khi đăng ký):**
  - Bắt buộc nhập ô xác nhận mật khẩu; nếu để trống báo "Vui lòng xác nhận mật khẩu".
  - Giá trị xác nhận phải khớp với mật khẩu; nếu không khớp báo "Mật khẩu không khớp".
- **BR-21 — Quy tắc kiểm tra khi quên mật khẩu:** Luồng quên mật khẩu chỉ yêu cầu nhập email hợp lệ (bắt buộc và đúng định dạng), không yêu cầu mật khẩu.
- **BR-22 — Hiển thị lỗi theo từng ô:** Lỗi nhập liệu được hiển thị ngay dưới đúng ô tương ứng (email, mật khẩu, xác nhận mật khẩu) để người dùng biết chính xác chỗ cần sửa.
- **BR-23 — Quy tắc nhập liệu thống nhất:** Quy tắc kiểm tra email/mật khẩu là duy nhất và giống hệt nhau trên cả hai nền tảng (Android và iOS); cùng một thông báo lỗi tiếng Việt.
- **BR-24 — Trạng thái xử lý độc lập:** Mỗi cách đăng nhập (email, Google, Apple, Facebook) có trạng thái "đang xử lý" riêng để người dùng thấy rõ đang chờ ở luồng nào.
- **BR-25 — Đăng ký với email đã tồn tại:** Khi người dùng đăng ký bằng một email đã có tài khoản, hệ thống không tạo tài khoản mới và hiển thị thông báo "Email này đã có tài khoản" ngay dưới ô email.
- **BR-26 — Xác nhận trước khi xóa tài khoản:** Việc xóa tài khoản chỉ được thực hiện sau khi người dùng xác nhận rõ ràng ở một bước xác nhận; nếu người dùng huỷ ở bước này thì tài khoản không bị xóa. Không yêu cầu đăng nhập lại để xóa.
- **BR-27 — Sai thông tin đăng nhập:** Khi email và mật khẩu đúng định dạng nhưng không khớp với bất kỳ tài khoản nào, hệ thống từ chối đăng nhập và hiển thị thông báo ở **cấp toàn biểu mẫu** (không gắn dưới ô cụ thể): "Đăng nhập không thành công. Sai email hoặc mật khẩu." Thông báo không phân biệt sai email hay sai mật khẩu (không tiết lộ tài khoản có tồn tại không). Nếu thất bại vì lý do không xác định: "Đăng nhập không thành công. Vui lòng thử lại." Câu chữ và kiểu hiển thị thống nhất trên cả Android và iOS.
- **BR-28 — Đăng nhập mạng xã hội không bắt buộc email:** Khi đăng nhập bằng tài khoản mạng xã hội mà nhà cung cấp không chia sẻ email, hệ thống vẫn cho người dùng vào ứng dụng; danh tính dựa trên tài khoản nhà cung cấp, không yêu cầu bổ sung hay xác minh email. (Quy tắc xác nhận email ở BR-02 chỉ áp dụng cho tài khoản đăng ký bằng email.)

### Trạng thái offline

- **BR-29 — Chặn mọi thao tác xác thực khi mất mạng:** Khi thiết bị không có kết nối mạng, tất cả các hành động đòi hỏi xác thực với máy chủ (đăng ký, đăng nhập, yêu cầu đặt lại mật khẩu, liên kết phương thức) đều bị chặn. Hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." và không gửi bất kỳ yêu cầu nào lên máy chủ.
- **BR-30 — Giữ nguyên dữ liệu đã nhập khi mất mạng:** Khi người dùng đang điền biểu mẫu (đăng ký hoặc đăng nhập) và gặp lỗi mất kết nối, toàn bộ nội dung đã nhập được giữ nguyên trên màn hình. Người dùng không phải nhập lại từ đầu sau khi có mạng trở lại.
- **BR-31 — Phiên hiện tại không bị ảnh hưởng khi mất mạng:** Nếu người dùng đã đăng nhập thành công và sau đó mất kết nối, phiên đang hoạt động không bị huỷ. Khi có mạng trở lại, người dùng không cần đăng nhập lại.

---

## 4. Tiêu chí nghiệm thu

### Đăng ký

- **AC-01 — Đăng ký thành công bằng email:**
  - **Giả sử** người dùng chưa có tài khoản;
  - **Khi** nhập email hợp lệ, mật khẩu ít nhất sáu ký tự, xác nhận mật khẩu khớp, chọn username chưa tồn tại, xác nhận đủ 13 tuổi, và nhấn Đăng ký;
  - **Thì** hệ thống tạo tài khoản ở gói Free, gửi email xác nhận, và thông báo người dùng kiểm tra hộp thư.

- **AC-02 — Đăng ký thành công bằng Google / Apple / Facebook:**
  - **Giả sử** người dùng chưa có tài khoản;
  - **Khi** chọn Đăng ký bằng Google, Apple hoặc Facebook và xác thực thành công với nền tảng đó;
  - **Thì** hệ thống tạo tài khoản ở gói Free, bỏ qua bước xác nhận email, đưa người dùng vào chọn username.

- **AC-03 — Username trùng bị từ chối:**
  - **Giả sử** một username đã được người khác sử dụng;
  - **Khi** người dùng mới nhập đúng username đó;
  - **Thì** hệ thống báo lỗi "Tên người dùng đã tồn tại" và yêu cầu chọn tên khác.

- **AC-04 — Username không hợp lệ bị từ chối:**
  - **Giả sử** người dùng đang điền form đăng ký;
  - **Khi** nhập username ngắn hơn 3 ký tự hoặc dài hơn 30 ký tự;
  - **Thì** hệ thống báo lỗi ngay tại ô nhập và không cho tiếp tục.

- **AC-05 — Mật khẩu không đủ tiêu chuẩn bị từ chối:**
  - **Giả sử** người dùng đang điền form đăng ký;
  - **Khi** nhập mật khẩu ít hơn sáu ký tự;
  - **Thì** hệ thống báo lỗi "Mật khẩu phải có ít nhất 6 ký tự" ngay dưới ô mật khẩu và không cho tiếp tục.

- **AC-06 — Không xác nhận đủ 13 tuổi thì bị chặn:**
  - **Giả sử** người dùng đang điền form đăng ký;
  - **Khi** không tick xác nhận đủ 13 tuổi;
  - **Thì** không thể hoàn tất đăng ký.

- **AC-07 — Chưa xác nhận email bị giới hạn tính năng:**
  - **Giả sử** người dùng đã đăng ký bằng email nhưng chưa nhấp link xác nhận;
  - **Khi** cố gắng dùng tính năng đòi hỏi tài khoản đầy đủ (tạo tem, gửi thư);
  - **Thì** hệ thống thông báo yêu cầu xác nhận email trước, kèm tuỳ chọn gửi lại email.

### Đăng nhập & Phiên

- **AC-08 — Đăng nhập thành công bằng email:**
  - **Giả sử** người dùng đã có tài khoản;
  - **Khi** nhập đúng email và mật khẩu rồi nhấn Đăng nhập;
  - **Thì** vào được ứng dụng và phiên được ghi nhớ tự động.

- **AC-09 — Đăng nhập thành công bằng Google / Apple / Facebook:**
  - **Giả sử** người dùng đã đăng ký bằng Google, Apple hoặc Facebook;
  - **Khi** chọn đúng nền tảng tương ứng và xác thực thành công;
  - **Thì** vào được ứng dụng ngay không cần nhập mật khẩu.

- **AC-10 — Phiên không yêu cầu đăng nhập lại trong 90 ngày:**
  - **Giả sử** người dùng đã đăng nhập và chưa đến 90 ngày;
  - **Khi** đóng app rồi mở lại;
  - **Thì** vào thẳng màn hình chính mà không cần đăng nhập lại.

- **AC-11 — Phiên hết hạn yêu cầu đăng nhập lại:**
  - **Giả sử** người dùng không dùng app hơn chín mươi ngày;
  - **Khi** mở lại app;
  - **Thì** hệ thống yêu cầu đăng nhập lại thay vì vào thẳng.

- **AC-12 — Khoá tạm sau năm lần nhập sai:**
  - **Giả sử** người dùng đang ở màn hình đăng nhập;
  - **Khi** nhập sai mật khẩu năm lần liên tiếp;
  - **Thì** tài khoản bị khoá đăng nhập tạm mười lăm phút và màn hình hiển thị đếm ngược thời gian chờ còn lại.

- **AC-13 — Sai phương thức đăng nhập bị từ chối:**
  - **Giả sử** người dùng đăng ký bằng email nhưng chọn đăng nhập bằng Facebook;
  - **Khi** xác thực Facebook thành công nhưng tài khoản không liên kết với Facebook;
  - **Thì** hệ thống thông báo "Tài khoản này không liên kết với Facebook" và gợi ý dùng đúng phương thức.

### Bảo mật & Khôi phục

- **AC-14 — Đặt lại mật khẩu qua email:**
  - **Giả sử** người dùng đã đăng ký bằng email và quên mật khẩu;
  - **Khi** nhập email trên màn hình "Quên mật khẩu" và xác nhận;
  - **Thì** hệ thống gửi email chứa link đặt lại có hiệu lực hai mươi bốn giờ; nếu email không tồn tại hệ thống vẫn báo "nếu email tồn tại bạn sẽ nhận link" (không tiết lộ).

- **AC-15 — Link đặt lại chỉ dùng một lần:**
  - **Giả sử** người dùng đã dùng link đặt lại mật khẩu thành công;
  - **Khi** nhấp lại đúng link đó lần nữa;
  - **Thì** hệ thống thông báo link không còn hợp lệ.

- **AC-16 — Đặt lại hoặc đổi mật khẩu đăng xuất tất cả thiết bị:**
  - **Giả sử** người dùng đang đăng nhập trên hai thiết bị và thay đổi mật khẩu trên một thiết bị;
  - **Khi** hoàn tất thay đổi;
  - **Thì** thiết bị còn lại bị đăng xuất và phải đăng nhập lại bằng mật khẩu mới.

- **AC-17 — Đổi mật khẩu yêu cầu mật khẩu cũ:**
  - **Giả sử** người dùng đang đăng nhập và vào cài đặt đổi mật khẩu;
  - **Khi** nhập sai mật khẩu hiện tại;
  - **Thì** hệ thống từ chối và yêu cầu nhập lại mật khẩu hiện tại đúng.

- **AC-18 — Liên kết thêm phương thức đăng nhập:**
  - **Giả sử** người dùng đang dùng email/mật khẩu và chưa liên kết Google;
  - **Khi** vào cài đặt, chọn liên kết Google và xác thực thành công;
  - **Thì** tài khoản có thêm tuỳ chọn đăng nhập bằng Google.

- **AC-19 — Không cho huỷ phương thức đăng nhập duy nhất:**
  - **Giả sử** người dùng chỉ có một phương thức đăng nhập;
  - **Khi** cố gắng huỷ liên kết phương thức duy nhất đó;
  - **Thì** hệ thống từ chối và giải thích phải có ít nhất một phương thức còn lại.

### Khôi phục & Đồng bộ

- **AC-20 — Khôi phục giao dịch mua sau đăng nhập:**
  - **Giả sử** người dùng đã mua Premium hoặc Dấu trên tài khoản App Store/Google Play và đăng nhập lại trên thiết bị mới;
  - **Khi** đăng nhập thành công;
  - **Thì** trạng thái Premium và số Dấu được khôi phục tự động mà không cần thao tác thêm.

### Nhập liệu & Validation

- **AC-21 — Email trống bị báo lỗi ngay tại ô:**
  - **Giả sử** người dùng đang ở màn hình đăng nhập, đăng ký hoặc quên mật khẩu;
  - **Khi** bỏ trống ô email và nhấn tiếp tục;
  - **Thì** thông báo "Vui lòng nhập email" hiện ngay dưới ô email; không chuyển màn hình.

- **AC-22 — Email sai định dạng bị báo lỗi ngay tại ô:**
  - **Giả sử** người dùng nhập chuỗi không phải email hợp lệ (ví dụ: "abcxyz");
  - **Khi** nhấn tiếp tục;
  - **Thì** thông báo "Email không hợp lệ" hiện ngay dưới ô email; không chuyển màn hình.

- **AC-23 — Mật khẩu trống bị báo lỗi ngay tại ô:**
  - **Giả sử** người dùng đang ở màn hình đăng nhập hoặc đăng ký;
  - **Khi** bỏ trống ô mật khẩu và nhấn tiếp tục;
  - **Thì** thông báo "Vui lòng nhập mật khẩu" hiện ngay dưới ô mật khẩu.

- **AC-24 — Xác nhận mật khẩu không khớp bị báo lỗi:**
  - **Giả sử** người dùng đang điền form đăng ký;
  - **Khi** nhập ô xác nhận mật khẩu với giá trị khác với ô mật khẩu;
  - **Thì** thông báo "Mật khẩu không khớp" hiện ngay dưới ô xác nhận; không tạo tài khoản.

- **AC-25 — Đăng ký email đã tồn tại hiện lỗi tại ô email:**
  - **Giả sử** người dùng nhập email đã có tài khoản;
  - **Khi** nhấn Đăng ký;
  - **Thì** thông báo "Email này đã có tài khoản" hiện ngay dưới ô email; không tạo tài khoản mới.

- **AC-26 — Sai thông tin đăng nhập hiển thị lỗi cấp biểu mẫu:**
  - **Giả sử** người dùng nhập email và mật khẩu đúng định dạng nhưng không khớp tài khoản nào;
  - **Khi** nhấn Đăng nhập;
  - **Thì** thông báo "Đăng nhập không thành công. Sai email hoặc mật khẩu." hiển thị ở cấp toàn biểu mẫu (không gắn dưới ô cụ thể); người dùng vẫn ở màn hình đăng nhập.

- **AC-27 — Xóa tài khoản yêu cầu bước xác nhận:**
  - **Giả sử** người dùng chọn xóa tài khoản;
  - **Khi** hệ thống hiển thị bước xác nhận và người dùng nhấn Huỷ;
  - **Thì** tài khoản không bị xóa và người dùng quay lại màn hình trước.

- **AC-28 — Đăng nhập MXH không có email vẫn vào được app:**
  - **Giả sử** người dùng đăng nhập bằng Facebook với tài khoản không chia sẻ email;
  - **Khi** xác thực Facebook thành công;
  - **Thì** hệ thống cho vào ứng dụng bình thường mà không yêu cầu bổ sung email.

- **AC-29 — Tài khoản mới mặc định ở gói Free:**
  - **Giả sử** người dùng vừa đăng ký thành công bằng bất kỳ phương thức nào;
  - **Khi** vào ứng dụng lần đầu;
  - **Thì** tài khoản ở gói Free với đầy đủ giới hạn Free (30 tem/tháng, 10 thư/tháng); không có tính năng Premium nào được bật.

- **AC-30 — Bỏ qua ảnh đại diện khi đăng ký vẫn hoàn tất:**
  - **Giả sử** người dùng đang ở bước chọn ảnh đại diện khi đăng ký;
  - **Khi** bỏ qua không tải ảnh;
  - **Thì** đăng ký vẫn hoàn tất; hệ thống hiển thị hình đại diện mặc định và người dùng có thể cập nhật sau trong hồ sơ.

- **AC-31 — Thông báo số lần thử còn lại trước khi bị khoá:**
  - **Giả sử** người dùng nhập sai mật khẩu nhưng chưa đến lần thứ năm;
  - **Khi** mỗi lần nhập sai;
  - **Thì** hệ thống thông báo rõ còn bao nhiêu lần thử trước khi bị khoá tạm (ví dụ: "Sai mật khẩu. Còn 2 lần thử.").

- **AC-32 — Trạng thái xử lý hiển thị riêng từng luồng đăng nhập:**
  - **Giả sử** người dùng đang ở màn hình đăng nhập;
  - **Khi** nhấn nút đăng nhập bằng Google trong khi luồng email đang không hoạt động;
  - **Thì** chỉ nút Google hiển thị trạng thái "đang xử lý"; các nút còn lại (email, Apple, Facebook) không bị ảnh hưởng.

- **AC-33 — Xác nhận xóa tài khoản thành công:**
  - **Giả sử** người dùng chọn xóa tài khoản và hệ thống hiển thị bước xác nhận;
  - **Khi** người dùng nhấn Xác nhận;
  - **Thì** tài khoản bị xóa và người dùng bị đăng xuất ngay; không thể đăng nhập lại bằng thông tin cũ.

### Offline

- **AC-34 — Đăng nhập/đăng ký bị chặn khi mất mạng:**
  - **Giả sử** thiết bị của người dùng đang mất kết nối mạng;
  - **Khi** người dùng nhấn nút Đăng nhập hoặc Đăng ký (bất kỳ phương thức nào);
  - **Thì** hệ thống không gửi yêu cầu lên máy chủ, hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng.", và giữ nguyên toàn bộ nội dung đã nhập trên biểu mẫu.

- **AC-35 — Phiên đã đăng nhập không bị huỷ khi mất mạng:**
  - **Giả sử** người dùng đang đăng nhập trong phiên còn hiệu lực và thiết bị mất kết nối;
  - **Khi** kết nối mạng được khôi phục và người dùng mở lại app;
  - **Thì** người dùng vẫn ở trạng thái đã đăng nhập mà không cần xác thực lại.

---

## 5. Trường hợp ngoại lệ & lỗi

**Đăng ký:**
- Email đã được đăng ký → thông báo "Email này đã có tài khoản" và gợi ý đăng nhập hoặc đặt lại mật khẩu.
- Mất kết nối trong quá trình đăng ký → thông báo lỗi mạng, dữ liệu đã nhập được giữ nguyên để thử lại.
- Email xác nhận không đến → người dùng yêu cầu gửi lại từ màn hình chờ xác nhận.
- Đăng ký qua Google/Apple/Facebook thất bại → thông báo lỗi từ nền tảng đó, gợi ý thử lại hoặc dùng email/mật khẩu.

**Đăng nhập:**
- Nhập sai mật khẩu (chưa đến năm lần) → thông báo cấp biểu mẫu "Đăng nhập không thành công. Sai email hoặc mật khẩu." kèm số lần thử còn lại (AC-31). Không gắn lỗi riêng dưới ô email hay mật khẩu.
- Thất bại vì lý do không xác định (không phải sai thông tin) → "Đăng nhập không thành công. Vui lòng thử lại."
- Mất kết nối → thông báo lỗi mạng, giữ nguyên form để thử lại.
- Tài khoản đang bị khoá tạm → hiển thị đếm ngược; sau hết thời gian khoá tự động cho phép thử lại.

**Bảo mật:**
- Link đặt lại hết hạn (quá 24 giờ) → thông báo hết hạn và gợi ý gửi lại link mới.
- Mất kết nối trong quá trình đổi mật khẩu → thông báo lỗi mạng, không lưu thay đổi, người dùng thử lại.
- Xác thực Google/Apple thất bại khi liên kết → thông báo lỗi từ nền tảng, không liên kết được, gợi ý thử lại.

**Khi mất kết nối (offline / no network):**
- Mọi thao tác đăng ký, đăng nhập, gửi yêu cầu đặt lại mật khẩu đều bị chặn; hệ thống hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." và không gửi bất kỳ yêu cầu nào lên máy chủ.
- Toàn bộ nội dung đã nhập trong biểu mẫu (email, mật khẩu) được giữ nguyên trên màn hình; người dùng không phải nhập lại từ đầu sau khi mạng trở lại.
- Nếu người dùng đã đăng nhập trước đó, phiên đang hoạt động không bị huỷ khi mất mạng; khi có mạng trở lại, người dùng vẫn ở trạng thái đã đăng nhập mà không cần xác thực lại.

**Khi dữ liệu không tải được (network error / server error):**
- Khi máy chủ trả lỗi hoặc hết thời gian chờ trong quá trình đăng nhập hay đăng ký, màn hình hiển thị thông báo "Đăng nhập không thành công. Vui lòng thử lại." (hoặc tương đương tuỳ luồng) kèm nút Thử lại; biểu mẫu không bị xoá.
- Khi yêu cầu gửi email đặt lại mật khẩu thất bại do lỗi máy chủ, hệ thống thông báo lỗi và cho phép người dùng gửi lại; không hiển thị màn hình trắng hoặc treo vô thời hạn.

**Khi chưa đăng nhập / thoát app giữa chừng:**
- Khi người dùng chưa đăng nhập, hệ thống luôn giữ người dùng ở màn hình đăng nhập; không cho phép vào bất kỳ tính năng nào của ứng dụng cho đến khi đăng nhập thành công.
- Khi người dùng thoát app giữa chừng trong lúc đang điền biểu mẫu đăng nhập hoặc đăng ký, email và mật khẩu đã nhập được giữ nguyên; lần sau mở lại app, nội dung vẫn còn trên biểu mẫu mà không bị mất.
- Khi phiên hết hạn hoặc người dùng bị đăng xuất (ví dụ: do đổi mật khẩu trên thiết bị khác), lần mở app tiếp theo hệ thống đưa người dùng về màn hình đăng nhập thay vì vào thẳng nội dung.

---

## Liên kết tính năng khác

- SM-003 (Onboarding): chạy ngay sau khi đăng ký thành công lần đầu.
- SM-027 (Cài đặt tài khoản): đăng xuất thiết bị, xoá tài khoản.

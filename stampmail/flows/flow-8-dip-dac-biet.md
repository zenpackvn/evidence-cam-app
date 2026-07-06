# Flow 8 · Dịp đặc biệt

Thiệp nhóm — nhiều người cùng ký một thiệp rồi gửi đến người nhận.

---

## Thiệp nhóm (Group Card — nhiều người ký chung) — SM-032

> Nguồn: `specs/027-thiep-nhom.md`

**Màn hình & trạng thái:**

- **Tạo thiệp**: Default · Offline
- **Host**: Draft · Collecting · Closed · Sent · Empty-warning
- **Contributor**: First-time · Already · Closed · Max-reached · No-tem · Guest
- **Recipient**: Open

### 1. Mục đích nghiệp vụ

Giải quyết vấn đề Zalo xử lý tệ — khi cả nhóm muốn chúc mừng một người (sinh nhật, tốt nghiệp, chia tay đồng nghiệp), lời chúc bị xé lẻ khắp group chat, không ai tổng hợp được. Thiệp nhóm cho phép mọi người đóng góp tem + lời nhắn riêng vào cùng một phong bì, người nhận mở ra thấy tất cả cùng một lúc. Viral kép: host chia sẻ link mời → cả nhóm vào app để đóng góp.

### 2. Đối tượng & phạm vi

- **Người dùng (Host):** Người dùng đã đăng nhập, khởi tạo thiệp nhóm cho một dịp.
- **Người dùng (Người đóng góp):** Thành viên nhóm nhận link mời, đóng góp tem + lời nhắn.
- **Người nhận:** Người được tặng thiệp — có thể chưa có tài khoản.
- **Khi nào dùng:** Khi muốn tổ chức thiệp chúc mừng tập thể (sinh nhật, tốt nghiệp, sự kiện nhóm).
- **Điều kiện tiên quyết (Host):** Đã đăng nhập (SM-001).
- **Điều kiện tiên quyết (Người đóng góp):** Nhận link mời; cần đăng nhập/đăng ký để đóng góp.
- **Phạm vi:** Tạo thiệp nhóm, mời đóng góp, thu thập tem + lời nhắn của nhiều người, đóng sổ và gửi cho người nhận. Không bao gồm real-time collaboration (đây là đóng góp bất đồng bộ).

### 3. Quy tắc nghiệp vụ

- **BR-01 — Host tạo thiệp nhóm:** Host tạo một "thiệp nhóm" cho một dịp cụ thể, đặt tên dịp (ví dụ: "Sinh nhật An") và tuỳ chọn đặt hạn đóng góp.
- **BR-02 — Link mời đóng góp:** Host nhận một link mời riêng để chia sẻ vào group chat. Người nhận link mời này KHÔNG phải người nhận thiệp — họ là người đóng góp.
- **BR-03 — Mỗi người đóng góp thêm tem + lời nhắn:** Mỗi người đóng góp bấm link mời → chọn một tem từ Album của mình → viết một lời nhắn ngắn → xác nhận đóng góp. Mỗi lượt đóng góp là một tem + một lời nhắn.
- **BR-04 — Mỗi người đóng góp tối đa một lần, được phép sửa trước khi đóng sổ:** Mỗi tài khoản chỉ đóng góp được một lần cho mỗi thiệp nhóm. Tuy nhiên, khi nhấn lại link mời trong khi thiệp nhóm vẫn đang ở trạng thái "Đang thu thập", người đóng góp thấy đóng góp cũ của mình (tem + lời nhắn) và có thể chỉnh sửa: đổi tem khác hoặc sửa lời nhắn, rồi xác nhận lại. Đóng góp mới thay thế hoàn toàn đóng góp cũ. Sau khi Host đóng sổ, không ai được chỉnh sửa nữa.
- **BR-05 — Giới hạn số người đóng góp:** Tối đa năm mươi người đóng góp trên một thiệp nhóm để tránh lạm dụng.
- **BR-06 — Trạng thái thiệp nhóm:** Thiệp nhóm trải qua bốn trạng thái theo thứ tự: Đang soạn → Đang thu thập → Đã đóng sổ → Đã gửi. Chỉ Host mới chuyển trạng thái (đóng sổ, gửi).
- **BR-07 — Đóng sổ:** Host đóng sổ thiệp nhóm để kết thúc giai đoạn thu thập — sau đó không ai đóng góp thêm được nữa.
- **BR-08 — Gửi thiệp cho người nhận:** Sau khi đóng sổ, Host gửi thiệp (toàn bộ tem và lời nhắn đã thu thập) cho người nhận qua link — tương tự cơ chế gửi thư một lần (SM-016).
- **BR-09 — Người nhận xem tất cả đóng góp:** Người nhận mở link → animation mở phong bì → thấy toàn bộ tem + lời nhắn của từng người đóng góp trong một phong bì duy nhất.
- **BR-10 — Đóng góp sau khi đóng sổ bị từ chối:** Nếu ai đó nhấn link mời sau khi đã đóng sổ, hệ thống thông báo thiệp này đã đóng sổ và không cho đóng góp.

#### Trạng thái offline

- **BR-11 — Chặn đóng góp khi mất mạng:** Khi người đóng góp mất kết nối mạng trong lúc xác nhận đóng góp (gửi tem + lời nhắn), hệ thống chặn thao tác và hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." — đóng góp chưa được ghi nhận, nội dung đã soạn vẫn giữ nguyên trên màn hình để người dùng thử lại.
- **BR-12 — Chặn tạo và gửi thiệp khi mất mạng:** Khi Host mất kết nối mạng trong lúc tạo thiệp nhóm hoặc đóng sổ hoặc gửi thiệp, hệ thống chặn thao tác và hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng." — trạng thái thiệp không thay đổi.
- **BR-13 — Chế độ xem ngoại tuyến cho Host:** Host đã từng mở danh sách đóng góp trước đó có thể xem lại danh sách đó ở chế độ ngoại tuyến với dữ liệu đã tải gần nhất; các thao tác yêu cầu mạng (đóng sổ, gửi thiệp) bị vô hiệu hoá và hiển thị chú thích "Đang xem ngoại tuyến".

### 4. Tiêu chí nghiệm thu

- **AC-01 — Host tạo thiệp nhóm thành công:**
  - **Giả sử** người dùng đã đăng nhập;
  - **Khi** tạo thiệp nhóm với tên "Sinh nhật An" và nhấn Tạo;
  - **Thì** thiệp nhóm được tạo, Host nhận link mời để chia sẻ vào group chat.

- **AC-02 — Người đóng góp thêm tem + lời nhắn:**
  - **Giả sử** một thành viên nhóm nhận link mời và đã đăng nhập;
  - **Khi** chọn tem từ Album và viết lời nhắn rồi xác nhận;
  - **Thì** đóng góp được ghi nhận, thành viên thấy xác nhận "Đã đóng góp thành công".

- **AC-03 — Nhấn link mời lần hai → thấy đóng góp cũ và được sửa:**
  - **Giả sử** người dùng đã đóng góp vào thiệp nhóm đang ở trạng thái "Đang thu thập";
  - **Khi** nhấn link mời lần nữa;
  - **Thì** hệ thống hiển thị đóng góp cũ (tem đã chọn và lời nhắn đã viết) cùng hai nút "Chỉnh sửa đóng góp" và "Đóng"; không tạo đóng góp mới.

- **AC-03b — Chỉnh sửa đóng góp trước khi đóng sổ:**
  - **Giả sử** người dùng đang xem đóng góp cũ sau khi nhấn link lần hai;
  - **Khi** nhấn "Chỉnh sửa đóng góp", đổi sang tem khác, sửa lại lời nhắn, rồi xác nhận;
  - **Thì** đóng góp mới thay thế hoàn toàn đóng góp cũ; thiệp nhóm chỉ ghi nhận đóng góp mới nhất của người đó.

- **AC-03c — Không cho sửa sau khi đóng sổ:**
  - **Giả sử** người dùng đã đóng góp và Host đã đóng sổ thiệp nhóm;
  - **Khi** nhấn link mời lần nữa;
  - **Thì** hệ thống hiển thị đóng góp cũ ở chế độ chỉ xem; không có nút "Chỉnh sửa đóng góp"; có thông báo "Thiệp nhóm đã đóng sổ".

- **AC-04 — Đóng sổ ngăn đóng góp mới:**
  - **Giả sử** Host đã đóng sổ thiệp nhóm;
  - **Khi** một thành viên chưa đóng góp nhấn link mời;
  - **Thì** hệ thống thông báo thiệp đã đóng sổ, không còn nhận đóng góp.

- **AC-05 — Người nhận thấy tất cả đóng góp:**
  - **Giả sử** thiệp nhóm có năm đóng góp từ năm người;
  - **Khi** người nhận mở link thiệp;
  - **Thì** sau animation mở phong bì, thấy đủ năm tem và năm lời nhắn riêng của từng người.

- **AC-06 — Giới hạn năm mươi người đóng góp:**
  - **Giả sử** thiệp nhóm đã có đủ năm mươi đóng góp;
  - **Khi** người thứ năm mươi mốt nhấn link mời;
  - **Thì** hệ thống thông báo đã đủ số lượng đóng góp tối đa, không nhận thêm.

- **AC-07 — Chỉ Host mới chuyển trạng thái:**
  - **Giả sử** thiệp nhóm đang ở trạng thái Đang thu thập;
  - **Khi** một người đóng góp (không phải Host) cố đóng sổ hoặc gửi thiệp;
  - **Thì** hệ thống không cho thực hiện; chỉ Host mới thấy và dùng được nút Đóng sổ / Gửi thiệp.

- **AC-08 — Host đóng sổ và trạng thái chuyển sang Đã đóng sổ:**
  - **Giả sử** thiệp nhóm đang ở trạng thái Đang thu thập với ít nhất một đóng góp;
  - **Khi** Host nhấn Đóng sổ và xác nhận;
  - **Thì** trạng thái thiệp chuyển sang Đã đóng sổ và link mời không còn nhận đóng góp mới.

- **AC-09 — Host gửi thiệp sau khi đóng sổ:**
  - **Giả sử** thiệp nhóm đang ở trạng thái Đã đóng sổ;
  - **Khi** Host chọn gửi thiệp và chọn nền tảng MXH;
  - **Thì** link thiệp được tạo, ứng dụng MXH mở sẵn với link điền vào, trạng thái thiệp chuyển sang Đã gửi.

- **AC-10 — Người nhận mở thiệp thấy animation và đủ đóng góp:**
  - **Giả sử** thiệp nhóm đã được gửi với ba đóng góp;
  - **Khi** người nhận mở link thiệp;
  - **Thì** animation phong bì mở ra và người nhận thấy đủ ba tem kèm ba lời nhắn của từng người, hiển thị riêng biệt theo từng đóng góp.

#### Offline

- **AC-11 — Mất mạng khi người đóng góp xác nhận đóng góp:**
  - **Giả sử** người đóng góp đã chọn tem và viết lời nhắn nhưng thiết bị mất kết nối mạng;
  - **Khi** nhấn Xác nhận đóng góp;
  - **Thì** hệ thống không gửi đóng góp, hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng.", và nội dung tem + lời nhắn đã soạn vẫn còn trên màn hình.

- **AC-12 — Mất mạng khi Host thao tác quản lý thiệp:**
  - **Giả sử** Host đang xem thiệp nhóm nhưng thiết bị mất kết nối mạng;
  - **Khi** Host nhấn Đóng sổ hoặc Gửi thiệp;
  - **Thì** hệ thống chặn thao tác, hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng.", và trạng thái thiệp không thay đổi.

### 5. Trường hợp ngoại lệ & lỗi

- Khi người đóng góp nhấn link mời lần hai nhưng thiệp đã đóng sổ: hiển thị đóng góp cũ ở chế độ chỉ xem, kèm thông báo "Thiệp nhóm đã đóng sổ" — không có nút chỉnh sửa, không thể thay đổi đóng góp.
- Khi người đóng góp không có tem trong Album: hiển thị trạng thái trống Album và gợi ý tạo tem trước (SM-005→011).
- Khi người đóng góp chưa có tài khoản: hệ thống chuyển sang màn hình đăng nhập/đăng ký; sau khi đăng nhập thành công, quay lại trang đóng góp với link mời vẫn còn hiệu lực.
- Khi Host gửi thiệp chưa có đóng góp nào: hệ thống cảnh báo thiệp chưa có đóng góp và hỏi xác nhận "Gửi thiệp trống?".
- Khi mất kết nối lúc người đóng góp xác nhận đóng góp: hệ thống chặn gửi, hiển thị thông báo "Không có kết nối. Vui lòng thử lại khi có mạng.", nội dung tem và lời nhắn đã soạn vẫn còn trên màn hình để người dùng thử lại khi có mạng.
- Khi mất kết nối lúc Host tạo thiệp nhóm, đóng sổ hoặc gửi thiệp: hệ thống chặn thao tác và thông báo "Không có kết nối.", trạng thái thiệp không thay đổi; Host xem được danh sách đóng góp đã tải gần nhất ở chế độ ngoại tuyến, các nút thao tác bị vô hiệu hoá và hiển thị chú thích "Đang xem ngoại tuyến".
- Khi danh sách đóng góp không tải được do lỗi máy chủ hoặc mạng chập chờn: hệ thống hiển thị màn hình lỗi với thông báo ngắn và nút "Thử lại" để người dùng tải lại mà không cần thoát màn hình.
- Khi người dùng chưa đăng nhập cố tạo thiệp nhóm hoặc bấm link mời để đóng góp: hệ thống chuyển ngay sang màn hình đăng nhập, không cho thực hiện ở chế độ khách; sau khi đăng nhập thành công, hệ thống quay lại đúng màn hình đang dang dở.
- Khi người dùng thoát app giữa chừng khi đang soạn lời nhắn đóng góp: nội dung lời nhắn chưa xác nhận không được lưu, lần sau vào lại từ link mời người dùng bắt đầu soạn lại từ đầu.
- Khi Host xoá tài khoản trước khi gửi thiệp: thiệp nhóm bị huỷ cùng với tài khoản Host sau thời gian chờ xoá bảy ngày (SM-027 BR-04). Người đóng góp không bị ảnh hưởng — tài khoản và Album của họ vẫn nguyên vẹn; chỉ mất đóng góp đã gửi vào thiệp đó.

### Clarifications

#### Session 2026-06-24

- Q: Khi Host xoá tài khoản trước khi gửi thiệp nhóm, thiệp đó xử lý thế nào? → A: Thiệp bị huỷ cùng tài khoản Host sau 7 ngày chờ xoá; tài khoản và Album của người đóng góp không bị ảnh hưởng.

---

### Liên kết tính năng khác

- SM-022 (Album sưu tập tem): người đóng góp chọn tem từ Album của mình.
- SM-016 (Gửi thư qua MXH): cơ chế link gửi dùng chung khi Host gửi thiệp cho người nhận.
- SM-019 (Mở thư & Animation): animation mở phong bì khi người nhận mở thiệp nhóm.
- SM-026 (Thông báo push): thông báo cho người đóng góp khi Host đóng sổ/gửi thiệp.
- SM-005→011 (Tạo tem): người đóng góp chưa có tem cần tạo trước.

---

## Thiết kế màn hình

> **Quy tắc:** ✅ Vẽ riêng · 📝 Annotation trên frame gốc · ♻️ Dùng lại layout từ flow khác

### Tổng quan trạng thái trong spec

| Màn hình | Trạng thái |
|---|---|
| Tạo thiệp | Default · Offline |
| Host — Sổ lưu bút | Draft · Collecting · Closed · Sent · Empty-warning |
| Contributor — Đóng góp | First-time · Already · Closed · Max-reached · No-tem · Guest |
| Người nhận | Open |

**Tổng: ~14 trạng thái / 4 luồng người dùng**

### Frame cần thiết kế (8 frame)

| # | Frame | Ghi chú |
|---|---|---|
| 1 | Tạo thiệp — Form | Tên dịp + deadline tuỳ chọn + nút "Tạo & Lấy link mời" |
| 2 | Host — Collecting | Danh sách đóng góp + link mời + nút "Đóng sổ" |
| 3 | Host — Closed + Send | Danh sách hoàn tất + platform picker; gộp 2 bước |
| 4 | Host — Empty-warning modal | "Thiệp chưa có đóng góp nào, vẫn gửi?" |
| 5 | Contributor — First-time | Chọn tem + soạn lời nhắn + nút "Đóng góp" |
| 6 | Contributor — Already | Xem lại đóng góp cũ + nút "Sửa" |
| 7 | Contributor — Closed | Read-only + thông báo "Sổ đã đóng" |
| 8 | Người nhận — Open | Sau animation: toàn bộ tem + lời nhắn của từng người |

**Bỏ qua / annotation:** Offline (📝 banner); Host Draft (📝 annotation trên frame 2 — danh sách trống); Host Sent (📝 badge annotation); Max-reached / No-tem (📝 toast / modal alert); Guest (redirect đến màn login).

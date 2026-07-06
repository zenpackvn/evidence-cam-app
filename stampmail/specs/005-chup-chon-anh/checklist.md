# Checklist QA — Chụp / Chọn ảnh (005-chup-chon-anh)

## Điều kiện tiên quyết
- [ ] Người dùng đã đăng nhập vào ứng dụng StampMail
- [ ] Thiết bị có camera (cho các kiểm thử liên quan đến chụp ảnh)
- [ ] Có ảnh trong thư viện điện thoại (cho các kiểm thử liên quan đến chọn ảnh)
- [ ] Chuẩn bị ảnh có kích thước vượt giới hạn tối đa (cho kiểm thử BR-03 / AC-03)
- [ ] Màn hình "Chụp / Chọn ảnh" có thể mở từ nút "Tạo tem" trên thanh điều hướng hoặc gợi ý trên màn hình chính

## Luồng chính (Happy Path)

- [ ] Màn hình hiển thị hai tùy chọn: "Chụp ảnh" và "Chọn từ thư viện" (BR-01) ✅
- [ ] Khi nhấn "Tạo tem" trên thanh điều hướng, màn hình chụp/chọn ảnh được mở ✅
- [ ] Khi nhấn gợi ý tạo tem trên màn hình chính, màn hình chụp/chọn ảnh được mở ✅
- [ ] Nhấn "Chụp ảnh" — camera của thiết bị được mở khi đã có quyền (AC-01) 🔲
- [ ] Sau khi chụp và xác nhận ảnh, app chuyển sang màn hình xem trước (AC-01) 🔲
- [ ] Sau khi nhấn "Xác nhận" trên màn hình xem trước, app chuyển sang bộ lọc màu SM-006 (BR-04, AC-01) 🔲
- [ ] Nhấn "Chọn từ thư viện" — thư viện ảnh của thiết bị được mở khi đã có quyền (AC-02) 🔲
- [ ] Sau khi chọn ảnh từ thư viện và xác nhận, app chuyển sang bộ lọc màu SM-006 (BR-04, AC-02) 🔲
- [ ] App chấp nhận ảnh thuộc nhiều chủ thể: người, vật, phong cảnh, đồ vật (BR-02) 🔲

## Phóng to / Thu nhỏ ảnh xem trước (BR-05)

- [ ] Banh hai ngón tay trên ảnh xem trước — ảnh phóng to theo hướng banh (AC-05) 🔲
- [ ] Sau khi phóng to, có thể kéo ảnh để xem các vùng khác nhau (AC-05) 🔲
- [ ] Chụm hai ngón tay — ảnh thu nhỏ dần (AC-08) 🔲
- [ ] Ảnh không thu nhỏ hơn mức toàn ảnh vừa khung màn hình (AC-08) 🔲
- [ ] Chạm hai lần nhanh vào một vùng — ảnh phóng to vào đúng vùng đó (AC-09) 🔲
- [ ] Chạm hai lần nhanh lần nữa — ảnh trở về toàn ảnh vừa khung màn hình (AC-09) 🔲
- [ ] Sau nhiều lần phóng to / thu nhỏ rồi nhấn "Xác nhận", ảnh ở bước SM-006 giống hệt ảnh gốc ban đầu (AC-10) 🔲
- [ ] Ảnh không bị cắt xén hoặc thay đổi tỉ lệ sau khi xác nhận (AC-10) 🔲

## Luồng thất bại & Validation

- [ ] Khi chọn ảnh có kích thước vượt giới hạn tối đa, hiển thị thông báo lỗi rõ ràng (AC-03) ✅
- [ ] Thông báo lỗi ảnh quá lớn yêu cầu người dùng chọn ảnh khác nhỏ hơn (AC-03) ✅
- [ ] Sau thông báo ảnh quá lớn, người dùng có thể tiếp tục chọn ảnh khác mà không cần khởi động lại luồng (AC-03) ✅
- [ ] Khi chưa cấp quyền camera và nhấn "Chụp ảnh", hệ thống hiển thị hộp thoại xin quyền từ hệ điều hành (AC-04) 🔲
- [ ] Khi chưa cấp quyền thư viện và nhấn "Chọn từ thư viện", hệ thống hiển thị hộp thoại xin quyền từ hệ điều hành (AC-04) 🔲
- [ ] Khi người dùng từ chối quyền camera, app hiển thị thông báo và hướng dẫn vào cài đặt thiết bị (mục 5) 🔲
- [ ] Khi từ chối quyền camera, tùy chọn "Chọn từ thư viện" vẫn khả dụng (mục 5) ✅
- [ ] Khi người dùng từ chối quyền thư viện, app hiển thị thông báo và hướng dẫn vào cài đặt thiết bị (mục 5) 🔲
- [ ] Khi từ chối quyền thư viện, tùy chọn "Chụp ảnh" vẫn khả dụng (mục 5) ✅

## Offline & Lỗi mạng

- [ ] Khi mất mạng, nhấn "Chụp ảnh" và chụp ảnh vẫn thành công bình thường (AC-06) 🔲
- [ ] Khi mất mạng, nhấn "Chọn từ thư viện" và chọn ảnh vẫn thành công bình thường (AC-06) 🔲
- [ ] Khi mất mạng, ảnh vừa chụp/chọn hiển thị đúng trên màn hình xem trước (AC-06) 🔲
- [ ] Khi đang offline và nhấn "Xác nhận" chuyển bước, app hiển thị thông báo cần có mạng (AC-07) 🔲
- [ ] Khi offline, ảnh đã chọn được giữ nguyên — người dùng không cần chọn lại sau khi có mạng (AC-07) 🔲
- [ ] Khi bước tiếp theo trả về lỗi máy chủ, hiển thị thông báo lỗi kèm nút "Thử lại" (mục 5) 🚫
- [ ] Sau lỗi máy chủ, ảnh đã chọn được giữ nguyên và "Thử lại" gửi lại yêu cầu mà không cần chọn ảnh lại (mục 5) 🚫

## Trường hợp biên (Edge Cases)

- [ ] Khi thiết bị không có camera, tùy chọn "Chụp ảnh" bị ẩn và chỉ hiển thị "Chọn từ thư viện" (mục 5) 🚫
- [ ] Khi thoát màn hình chụp/chọn ảnh giữa chừng (chưa chọn ảnh), app quay về màn hình chính (mục 5) ✅
- [ ] Khi thoát giữa chừng, không có ảnh nào được lưu hoặc chuyển sang bước tiếp theo ✅
- [ ] Khi người dùng hủy chụp ảnh (đóng camera mà không chụp), app quay về màn hình chọn nguồn ảnh 🔲
- [ ] Khi người dùng hủy chọn ảnh (đóng thư viện mà không chọn), app quay về màn hình chọn nguồn ảnh 🔲
- [ ] Khi thoát app trong lúc xem trước ảnh chưa xử lý, mở lại app khôi phục đến màn hình xem trước với ảnh cũ (mục 5) 🔲
- [ ] Khi chưa đăng nhập và cố truy cập "Tạo tem", app chuyển đến màn hình đăng nhập (mục 5) ✅

## Ghi chú tự động hóa
- ✅ Maestro automatable — kiểm tra tap, navigation, assert văn bản hiển thị, điều hướng màn hình
- 🔲 Manual only — yêu cầu camera thực, tương tác với thư viện ảnh hệ thống, kiểm tra UI hệ điều hành, thao tác đa điểm (pinch/zoom), hoặc điều kiện mạng thực tế
- 🚫 Not automatable — phụ thuộc vào phần cứng thiết bị (thiết bị không có camera), trạng thái lỗi máy chủ không thể giả lập ổn định

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get bundleBackendPending =>
      'Chức năng này đang chờ backend mở endpoint';

  @override
  String get bundleCreate => 'Tạo';

  @override
  String get bundleCreateClaim => 'Tạo hồ sơ khiếu nại';

  @override
  String get accountClaims => 'Hồ sơ khiếu nại';

  @override
  String get claimsTitle => 'Hồ sơ khiếu nại';

  @override
  String get claimsLocalOnlyNote =>
      'Danh sách này lưu trên máy này. Gỡ ứng dụng hoặc đổi máy là không còn.';

  @override
  String get claimsEmpty =>
      'Chưa có hồ sơ nào. Vào tab Vận đơn, bấm dấu cộng rồi chọn bằng chứng để tạo.';

  @override
  String claimsSummary(int orders, int evidence) {
    return '$orders đơn · $evidence bằng chứng';
  }

  @override
  String claimsEvidenceOnly(int evidence) {
    return '$evidence bằng chứng';
  }

  @override
  String get claimsCopied => 'Đã sao chép nội dung hồ sơ';

  @override
  String get claimsCreated => 'Đã tạo hồ sơ khiếu nại';

  @override
  String get claimsPickNothing => 'Chưa chọn bằng chứng nào';

  @override
  String get claimsDelete => 'Xóa hồ sơ';

  @override
  String get claimsDeleteConfirm =>
      'Xóa hồ sơ này? Bằng chứng trong đơn hàng vẫn còn nguyên.';

  @override
  String get claimsDeleteConfirmLink =>
      'Xóa hồ sơ này? Link công khai chết ngay — ai đã nhận link sẽ mở ra trang trống. Bằng chứng trong đơn hàng vẫn còn nguyên.';

  @override
  String get claimsRevokeFailed =>
      'Chưa thu hồi được link nên hồ sơ vẫn giữ nguyên. Link đang còn mở — thử lại khi mạng tốt hơn, hoặc nhờ chủ cửa hàng thu hồi.';

  @override
  String get claimsDeleted => 'Đã xóa hồ sơ';

  @override
  String get claimsPhotoAdded => 'Đã thêm ảnh vào hồ sơ và đưa lên đơn hàng';

  @override
  String get claimsAddedLater => 'đính thêm';

  @override
  String get claimsCreateTitle => 'Tạo hồ sơ khiếu nại';

  @override
  String get claimsCreateSearchHint => 'Nhập hoặc quét mã vận đơn';

  @override
  String get claimsCreateNameHint => 'VD: Khiếu nại đơn hoàn 12/08';

  @override
  String get claimsCreateNameLabel => 'Tên hồ sơ';

  @override
  String get claimInfoTitle => 'Thông tin hồ sơ';

  @override
  String get claimTrackingLabel => 'Mã vận đơn';

  @override
  String get claimShopLabel => 'Shop';

  @override
  String get claimChannelLabel => 'Kênh bán';

  @override
  String get claimOrderCreatedAt => 'Ngày tạo đơn';

  @override
  String get claimEvidenceLabel => 'Bằng chứng';

  @override
  String claimEvidenceCount(int videos, int photos) {
    return '$videos video · $photos ảnh';
  }

  @override
  String get claimCreatedAtLabel => 'Ngày tạo hồ sơ';

  @override
  String get claimLinkLabel => 'Link hồ sơ khiếu nại';

  @override
  String get claimLinkHint =>
      'Ai có link đều xem được, không cần đăng nhập. Link sống mãi tới khi bạn thu hồi.';

  @override
  String get claimRevokedBadge => 'Đã thu hồi';

  @override
  String get claimRevokedHint =>
      'Link đã chết. Dữ liệu vẫn còn nguyên — muốn gửi lại thì tạo hồ sơ mới.';

  @override
  String get claimRevoke => 'Thu hồi';

  @override
  String get claimUntitled => 'Hồ sơ không đặt tên';

  @override
  String get claimRevokeConfirmTitle => 'Thu hồi hồ sơ này?';

  @override
  String get claimRevokeConfirmBody =>
      'Link chết ngay với bất kỳ ai đang giữ, kể cả sàn. Dữ liệu và link theo từng đơn không bị ảnh hưởng.';

  @override
  String get claimRevoked => 'Đã thu hồi hồ sơ. Link không mở được nữa.';

  @override
  String get claimRevokeFailed => 'Chưa thu hồi được. Thử lại khi có mạng.';

  @override
  String get claimNotUploaded =>
      'Hồ sơ này chưa gửi lên được nên chưa có link. Mở lại khi có mạng.';

  @override
  String get claimDetailLoadFailed =>
      'Chưa đọc được hồ sơ. Kiểm tra mạng rồi mở lại.';

  @override
  String get claimsCreateStart =>
      'Nhập mã vận đơn hoặc bấm quét để tìm đơn cần khiếu nại.';

  @override
  String get claimsCreateNoOrder =>
      'Không tìm thấy mã vận đơn này trong cửa hàng đang chọn.';

  @override
  String get claimsRemoveItemTitle => 'Gỡ khỏi hồ sơ';

  @override
  String get claimsRemoveItemConfirm =>
      'Gỡ bằng chứng này khỏi hồ sơ khiếu nại? Video/ảnh trong đơn hàng vẫn còn nguyên.';

  @override
  String get claimsItemRemoved => 'Đã gỡ khỏi hồ sơ';

  @override
  String get claimsItemAdded => 'Đã thêm vào hồ sơ';

  @override
  String get commonRemove => 'Gỡ';

  @override
  String get commonDelete => 'Xóa';

  @override
  String get settingDefaultSuffix => 'mặc định';

  @override
  String get shopDetailClipLength => 'Thời lượng video';

  @override
  String get shopDeleteTitle => 'Xóa cửa hàng';

  @override
  String get shopDeleteConfirm =>
      'Xóa cửa hàng này? Toàn bộ đơn hàng, video và ảnh của nó sẽ mất và không lấy lại được.';

  @override
  String get shopDeleteBlockedTitle => 'Còn thành viên trong shop';

  @override
  String shopDeleteBlockedBody(int count) {
    return 'Phải gỡ hết thành viên khỏi cửa hàng trước khi xóa. Hiện còn $count người.';
  }

  @override
  String get shopDeleted => 'Đã xoá cửa hàng.';

  @override
  String bundleSelected(int count) {
    return 'Đã chọn $count bằng chứng';
  }

  @override
  String get bundleUploadDrive => 'Đẩy lên Drive';

  @override
  String get commonCancel => 'Hủy';

  @override
  String get commonRetry => 'Thử lại';

  @override
  String get commonClose => 'Đóng';

  @override
  String get toastChangeLanguage => 'Đổi ngôn ngữ';

  @override
  String get toastTermsPolicy => 'Điều khoản & Chính sách';

  @override
  String get toastInfoSaved => 'Đã lưu thông tin';

  @override
  String get toastPasswordCreated => 'Đã tạo mật khẩu';

  @override
  String get toastPasswordChanged => 'Đã đổi mật khẩu';

  @override
  String get toastPendingDossierConfirm =>
      'Bạn còn hồ sơ khiếu nại đang mở, vui lòng xác nhận lại';

  @override
  String get toastCopiedShareLink => 'Đã sao chép link để chia sẻ';

  @override
  String get toastShareFailed => 'Không chia sẻ được, thử lại sau';

  @override
  String get toastDownloadingVideo => 'Đang tải video';

  @override
  String get toastVideoDownloadedCopied => 'Đã tải video và sao chép đường dẫn';

  @override
  String get toastVideoSavedToGallery => 'Đã lưu video vào thư viện trên máy';

  @override
  String get toastVideoDownloadFailed => 'Không tải được video, thử lại sau';

  @override
  String get toastVideoDeleteUnavailable => 'Không thể xóa video này';

  @override
  String get toastDownloadingPhoto => 'Đang tải ảnh';

  @override
  String get toastPhotoSavedToGallery => 'Đã lưu ảnh vào thư viện trên máy';

  @override
  String get toastPhotoDownloadedCopied => 'Đã tải ảnh và sao chép đường dẫn';

  @override
  String get toastPhotoDownloadFailed => 'Không tải được ảnh, thử lại sau';

  @override
  String get toastPhotoNoDownloadLink => 'Ảnh chưa có link tải';

  @override
  String get toastPhotoQueued => 'Đã đính kèm ảnh — đưa vào hàng chờ tải';

  @override
  String imageOverFixedCap(String megabytes, String limit) {
    return 'Ảnh $megabytes MB — vượt trần $limit MB nên chưa đính. Chọn ảnh nhỏ hơn.';
  }

  @override
  String get toastInvitePending => 'Chờ lời mời vào shop';

  @override
  String get toastInviteSent => 'Đã gửi lời mời';

  @override
  String get toastMemberAdded => 'Đã thêm thành viên';

  @override
  String get toastVideoPlayFailed => 'Không phát được video';

  @override
  String get toastShopCreated => 'Đã tạo shop mới';

  @override
  String get toastVideoQueued => 'Đã lưu video — đưa vào hàng chờ tải';

  @override
  String get toastVideoNoPlayLink => 'Video chưa có link phát';

  @override
  String get toastVideoNoDownloadLink => 'Video chưa có link tải';

  @override
  String get toastVideoDeleted => 'Đã xóa video';

  @override
  String get toastVideoTypeSaved => 'Đã lưu loại video';

  @override
  String get toastVideoTypeDeleted => 'Đã xóa loại video';

  @override
  String get toastNoVideoTypeToDelete => 'Không có loại video để xóa';

  @override
  String get toastNoMemberToUpdate => 'Không có thành viên để cập nhật';

  @override
  String get toastMemberRemoved =>
      'Đã gỡ khỏi shop (video đã quay vẫn upload nốt)';

  @override
  String get toastInviteRevoked =>
      'Đã xóa lời mời — link trong email hết tác dụng';

  @override
  String copiedLabel(String label) {
    return 'Đã sao chép $label';
  }

  @override
  String get labelTrackingCode => 'mã vận đơn';

  @override
  String resolutionChanged(String value) {
    return 'Độ phân giải: $value';
  }

  @override
  String get accountNoName => 'Chưa đặt tên';

  @override
  String get accountNoShop => 'Chưa chọn shop';

  @override
  String get accountCreatePassword => 'Tạo mật khẩu';

  @override
  String get accountChangePassword => 'Đổi mật khẩu';

  @override
  String accountLinkedMethods(int count) {
    return '$count liên kết';
  }

  @override
  String get roleOwner => 'Chủ shop';

  @override
  String get roleStaff => 'Nhân viên';

  @override
  String memberInviteSent(String role) {
    return '$role · đã gửi lời mời';
  }

  @override
  String memberInviteAccepted(String role) {
    return '$role · đã nhận lời mời';
  }

  @override
  String get planFree => 'Miễn phí';

  @override
  String get planBasic => 'Cơ bản';

  @override
  String get planSaver => 'Tiết kiệm';

  @override
  String get planPremium => 'Cao cấp';

  @override
  String get planPro => 'Chuyên nghiệp';

  @override
  String get planEnterprise => 'Doanh nghiệp';

  @override
  String get roleOther => 'Khác';

  @override
  String get roleUnknown => 'Không rõ';

  @override
  String get memberFallbackName => 'Thành viên';

  @override
  String get uploadStatusDone => 'Đã tải lên';

  @override
  String get uploadStatusPending => 'Đang chờ tải';

  @override
  String get uploadStatusQuotaHold => 'Tạm giữ do quota';

  @override
  String get uploadStatusDeleted => 'Đã xóa';

  @override
  String get uploadStatusError => 'Lỗi xử lý phía máy chủ';

  @override
  String get uploadStatusExpired => 'Đã quá hạn lưu trữ';

  @override
  String expiredOnDate(String date) {
    return 'Đã quá hạn lưu trữ ngày $date';
  }

  @override
  String get kindPhoto => 'Ảnh đính kèm';

  @override
  String get kindVideo => 'Video';

  @override
  String get recordedByFallback => 'Tài khoản hiện tại';

  @override
  String get deviceUnknown => 'Không rõ thiết bị';

  @override
  String get orderNoEvidence => 'Chưa có bằng chứng';

  @override
  String get timelineEmpty => 'Mã vận đơn này chưa có video hoặc ảnh nào';

  @override
  String get errorGenericRetry => 'Không thực hiện được, vui lòng thử lại.';

  @override
  String get errorPendingDossier =>
      'Bạn còn hồ sơ khiếu nại đang mở, vui lòng xử lý trước khi tiếp tục.';

  @override
  String get errorSessionExpired =>
      'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.';

  @override
  String get errorNoNetwork => 'Không có kết nối mạng, vui lòng thử lại.';

  @override
  String get errorNoPermission => 'Bạn không có quyền thực hiện thao tác này.';

  @override
  String get errorServerBusy => 'Hệ thống đang bận, vui lòng thử lại sau.';

  @override
  String get errorSessionInvalid =>
      'Phiên đăng nhập không hợp lệ, vui lòng đăng nhập lại.';

  @override
  String get errorVideoTypeInUse =>
      'Không thể xóa loại video đã có video. Vui lòng xem các video đang dùng loại này trước.';

  @override
  String get errorBuiltinVideoTypeLocked =>
      '3 loại video có sẵn không thể sửa hoặc xóa.';

  @override
  String get errorVideoTypeNameExists =>
      'Tên loại video đã tồn tại trong shop.';

  @override
  String get errorCheckNetwork => 'Kiểm tra mạng hoặc thử lại sau.';

  @override
  String get errorLoadShopList => 'Không tải được danh sách shop';

  @override
  String get errorLoadShopMgmt => 'Không tải được quản lý shop';

  @override
  String get errorLoadShopDetail => 'Không tải được chi tiết shop';

  @override
  String get errorLoadMembers => 'Không tải được danh sách thành viên';

  @override
  String get membersRestricted => 'Chỉ chủ shop xem được danh sách thành viên';

  @override
  String get errorLoadOrders => 'Không tải được đơn hàng';

  @override
  String get errorLoadOrderDetail => 'Không tải được chi tiết đơn';

  @override
  String get noShopSelectedOrdersDetail =>
      'Vui lòng chọn shop trước khi xem đơn hàng.';

  @override
  String get noShopSelectedRecordDetail =>
      'Vui lòng chọn shop trước khi ghi hình.';

  @override
  String get noShopSelectedManageDetail => 'Vui lòng chọn shop để quản lý.';

  @override
  String get noOrdersTitle => 'Chưa có đơn hàng';

  @override
  String get noOrdersDetail => 'Vui lòng chọn một đơn hàng từ danh sách.';

  @override
  String get noVideoDataTitle => 'Không có dữ liệu video';

  @override
  String get cannotOpenVideoTitle => 'Không mở được video';

  @override
  String get cannotOpenVideoDetail => 'Video chưa có link phát.';

  @override
  String get createOrderDialogTitle => 'Tạo vận đơn mới?';

  @override
  String createOrderDialogBody(String code) {
    return '$code không khớp mã vận đơn nào trong shop hiện tại. Kiểm tra lại mã hoặc xác nhận tạo vận đơn mới.';
  }

  @override
  String get createOrderConfirm => 'Tạo vận đơn mới';

  @override
  String get statOrdersToday => 'Vận đơn';

  @override
  String get statVideosRecorded => 'Video đã quay';

  @override
  String get statPendingUpload => 'Chờ tải';

  @override
  String get accountPlanQuota => 'Gói cước & dung lượng';

  @override
  String get accountChangePlan => 'Đổi gói';

  @override
  String get accountSectionApp => 'GÓI & ỨNG DỤNG';

  @override
  String get accountLanguage => 'Ngôn ngữ';

  @override
  String get accountSectionSecurity => 'BẢO MẬT & ĐĂNG NHẬP';

  @override
  String get accountLoginMethods => 'Phương thức đăng nhập';

  @override
  String get accountSignOut => 'Đăng xuất';

  @override
  String get accountSignOutConfirmTitle => 'Đăng xuất?';

  @override
  String get accountSignOutConfirmMessage =>
      'Bạn sẽ cần đăng nhập lại để tiếp tục sử dụng.';

  @override
  String get accountDeleteAccount => 'Xóa tài khoản';

  @override
  String accountVersion(String version) {
    return 'Phiên bản $version';
  }

  @override
  String get accountShopMgmtHint =>
      'Quản lý shop/thành viên: bấm back trên header để về lớp Shop';

  @override
  String get accountInfoTitle => 'Thông tin tài khoản';

  @override
  String get accountFullName => 'Họ tên';

  @override
  String get accountFullNameHint => 'Nhập họ tên';

  @override
  String get accountFullNameRequired => 'Vui lòng nhập họ tên';

  @override
  String get phoneOptionalLabel => 'Số điện thoại (tùy chọn)';

  @override
  String get phoneOptionalHint => 'Tùy chọn — chỉ dùng để hỗ trợ tài khoản';

  @override
  String get phoneInvalid => 'Số điện thoại không hợp lệ';

  @override
  String get accountSaveChanges => 'Lưu thay đổi';

  @override
  String get accountEmailLockedHint =>
      'Email dùng để đăng nhập, không thể thay đổi';

  @override
  String get commonContinue => 'Tiếp tục';

  @override
  String get commonLater => 'Để sau';

  @override
  String get cameraPermissionRationaleTitle => 'Cần quyền camera';

  @override
  String get cameraPermissionRationaleBody =>
      'ZenPack cần camera để quay video bằng chứng đóng hàng cho đơn của bạn.';

  @override
  String get cameraPermissionDeniedTitle => 'Chưa thể quay video';

  @override
  String get cameraPermissionDeniedBody =>
      'Chưa thể quay video vì ZenPack chưa được cấp quyền camera. Bạn vẫn xem, tìm kiếm và quản lý đơn hàng bình thường.';

  @override
  String get cameraPermissionOpenSettings => 'Mở Cài đặt';

  @override
  String get languageNameVietnamese => 'Tiếng Việt';

  @override
  String get languageNameEnglish => 'Tiếng Anh';

  @override
  String get languageChangeAppliesNote =>
      'Thay đổi áp dụng ngay trên toàn bộ app';

  @override
  String get linkLinked => 'Đã liên kết';

  @override
  String get linkNotLinked => 'Chưa liên kết';

  @override
  String get loginMethodsEmailNote =>
      'Email là định danh tài khoản — không thể gỡ. Liên kết Google/Apple để đăng nhập nhanh cùng một tài khoản.';

  @override
  String get loginMethodIdentity => 'Định danh';

  @override
  String get linkAction => 'Liên kết';

  @override
  String get linkUnlink => 'Hủy liên kết';

  @override
  String get quotaScreenTitle => 'Báo cáo & Quota';

  @override
  String get quotaRemainingThisMonth => 'Còn lại trong tháng';

  @override
  String get quotaSubtitle => 'Theo dõi dung lượng đang dùng';

  @override
  String quotaRemainingAmount(String amount) {
    return '$amount còn lại';
  }

  @override
  String get quotaStorage => 'Lưu trữ';

  @override
  String get deleteAccountTitleStep1 => 'Xóa tài khoản?';

  @override
  String get deleteAccountTitleStep2 => 'Xác nhận xóa vĩnh viễn?';

  @override
  String get deleteAccountBodyStep1 =>
      'Toàn bộ video, vận đơn và hồ sơ của bạn sẽ bị xóa vĩnh viễn. Hành động này không thể hoàn tác.';

  @override
  String get deleteAccountBodyStep2 =>
      'Đây là bước xác nhận cuối cùng. Sau khi xóa, bạn sẽ được đăng xuất khỏi ứng dụng ngay lập tức.';

  @override
  String get deleteConfirmPermanent => 'Xóa vĩnh viễn';

  @override
  String get deleteStep1Hint => 'Bước 1/2 — sẽ yêu cầu xác nhận lại';

  @override
  String get deleteStep2Hint => 'Bước 2/2 — hành động này không thể hoàn tác';

  @override
  String get passwordCurrentLabel => 'Mật khẩu hiện tại';

  @override
  String get passwordCurrentRequired => 'Vui lòng nhập mật khẩu hiện tại';

  @override
  String get passwordNewLabel => 'Mật khẩu mới';

  @override
  String get passwordMinHint => 'Tối thiểu 8 ký tự';

  @override
  String get passwordNewRequired => 'Vui lòng nhập mật khẩu mới';

  @override
  String get passwordMin8Error => 'Mật khẩu tối thiểu 8 ký tự';

  @override
  String get passwordNeedsLetterDigit => 'Mật khẩu cần có cả chữ và số';

  @override
  String get passwordTooCommon =>
      'Mật khẩu quá dễ đoán, hãy chọn mật khẩu khác';

  @override
  String get passwordConfirmLabel => 'Nhập lại mật khẩu mới';

  @override
  String get passwordMismatch => 'Mật khẩu nhập lại không khớp';

  @override
  String get passwordSave => 'Lưu mật khẩu';

  @override
  String get passwordChangeLogoutNote =>
      'Đổi xong sẽ đăng xuất khỏi các thiết bị khác';

  @override
  String get navOrders => 'Vận đơn';

  @override
  String get navRecord => 'Ghi hình';

  @override
  String get navAccount => 'Tài khoản';

  @override
  String get navClaims => 'Khiếu nại';

  @override
  String get changeAvatar => 'Đổi ảnh đại diện';

  @override
  String quotaVideosRatio(int remaining, int total) {
    return '$remaining / $total video';
  }

  @override
  String quotaUsedPercent(int percent) {
    return 'Đã dùng $percent%';
  }

  @override
  String quotaRetentionDays(int days) {
    return '$days ngày';
  }

  @override
  String quotaUsedRatio(String used, String cap, int percent) {
    return 'Đã dùng $used / $cap · $percent%';
  }

  @override
  String get quotaVideosStored => 'Video đang lưu';

  @override
  String quotaVideosStoredCount(int count) {
    return '$count video';
  }

  @override
  String get quotaByType => 'Dung lượng theo loại';

  @override
  String quotaByTypeVideosCount(int count) {
    return '$count video đang lưu';
  }

  @override
  String quotaRefundNote(int days) {
    return 'Dung lượng hoàn lại khi video hết hạn lưu trữ $days ngày';
  }

  @override
  String deletePendingProfilesWarning(int count) {
    return 'Bạn còn $count hồ sơ “đã gửi sàn” — link chia sẻ sẽ ngừng hoạt động';
  }

  @override
  String get detailRecordedTime => 'Giờ quay';

  @override
  String get detailDuration => 'Thời lượng';

  @override
  String get detailRecordedBy => 'Người quay';

  @override
  String get detailCapturedTime => 'Giờ chụp';

  @override
  String get detailCapturedBy => 'Người chụp';

  @override
  String get detailDevice => 'Thiết bị';

  @override
  String get detailSize => 'Dung lượng';

  @override
  String get detailUploadStatus => 'Trạng thái upload';

  @override
  String get detailSeal => 'Niêm phong';

  @override
  String sealSealed(String at) {
    return 'Đã khoá · $at';
  }

  @override
  String get sealWorking => 'Đang đóng dấu thời gian…';

  @override
  String get sealWorkingHint =>
      'Bản trên máy chủ chưa có dấu thời gian, nên link chia sẻ và tải về đợi thêm chút. Thường mất vài giây.';

  @override
  String get playLocalCopyNote =>
      'Bản tạm trên máy — chưa có dấu giờ trên hình';

  @override
  String get sealNone => 'Quay trước khi có niêm phong';

  @override
  String get sealFailed =>
      'Chưa đóng được dấu thời gian · video vẫn xem và tải được';

  @override
  String get sealMismatch => 'Vân tay không khớp — hãy quay lại clip này';

  @override
  String get sealTimeDrift =>
      'Đồng hồ máy quay lệch so với máy chủ, nên dấu nung ghi thêm giờ máy chủ nhận clip.';

  @override
  String get detailSealAnchor => 'Chứng thực độc lập';

  @override
  String sealAnchorConfirmed(String block) {
    return 'Đã có · mục #$block';
  }

  @override
  String get sealAnchorConfirmedNoBlock => 'Đã có';

  @override
  String get sealAnchorPending => 'Đang ghi vào sổ công khai (vài giờ)';

  @override
  String get sealAnchorNone => 'Không có';

  @override
  String get sealVerifyOpen => 'Xem trang kiểm chứng';

  @override
  String get sealVerifyHint =>
      'Gửi link này cho sàn — họ tự kiểm chứng được, không cần tin ZenPack.';

  @override
  String get sealVerifyFailed => 'Không mở được trang kiểm chứng.';

  @override
  String get detailPlayVideo => 'Phát video';

  @override
  String get detailCopyAssetLink => 'Sao chép link';

  @override
  String get assetLinkTitle => 'Link bằng chứng';

  @override
  String get detailDownloadVideo => 'Tải video về máy';

  @override
  String get detailDownloadNote =>
      'Chỉ Chủ/QL shop · dùng khi sàn yêu cầu file gốc';

  @override
  String get detailTrimVideo => 'Cắt đoạn ngắn để gửi';

  @override
  String get detailTrimNote =>
      'Bản đầy đủ vẫn giữ nguyên · đoạn cắt vẫn có dấu giờ';

  @override
  String get trimSave => 'Lưu';

  @override
  String get trimEstimatedSize => 'Ước tính';

  @override
  String get trimFailed => 'Không cắt được video. Bản đầy đủ vẫn còn nguyên.';

  @override
  String get trimPreparing => 'Đang tải bản đầy đủ về máy…';

  @override
  String get detailDownloadPhoto => 'Tải ảnh về máy';

  @override
  String get attachPhotoToOrder => 'Đính kèm ảnh vào đơn';

  @override
  String get deleteVideoAction => 'Xóa video';

  @override
  String get deletePhotoAction => 'Xóa ảnh';

  @override
  String get deleteVideoNote =>
      'Chỉ Chủ/QL shop · khóa nếu hồ sơ đang mở · xác nhận 2 bước';

  @override
  String get deleteVideoConfirmTitle => 'Xác nhận lần cuối';

  @override
  String get deleteVideoConfirmBody =>
      'Bằng chứng sẽ mất vĩnh viễn, không thể khôi phục — vẫn xóa?';

  @override
  String get deleteVideoConfirmAction => 'Xóa vĩnh viễn';

  @override
  String ordersErrorCount(int count) {
    return '· $count lỗi';
  }

  @override
  String ordersPendingCount(int count) {
    return '· $count chờ';
  }

  @override
  String ordersPendingEvidenceWarning(int count) {
    return '$count bằng chứng chưa upload · chưa có link để sao chép';
  }

  @override
  String get captureFramePrompt => 'Quét mã vận đơn';

  @override
  String get captureCameraDownHint => 'Đưa bill vào khung';

  @override
  String get cutoverSavedVideo => 'Đã lưu video';

  @override
  String get cutoverPreparingNext => 'Chuẩn bị ghi hình tiếp theo';

  @override
  String get cutoverNextOrder => 'Đơn tiếp theo';

  @override
  String get lowStorageTitle => 'Máy gần đầy bộ nhớ';

  @override
  String get lowStorageBody =>
      'Máy còn ít bộ nhớ trống — video đang quay dở có thể không lưu được hết. Giải phóng bớt bộ nhớ trước khi tiếp tục quay.';

  @override
  String get lowStorageAction => 'Đã hiểu';

  @override
  String cutoverClosedSummary(String code, String duration) {
    return 'Đã chốt mã vận đơn $code ($duration)';
  }

  @override
  String get cutoverSignalText => 'Âm báo + rung khi chuyển đơn';

  @override
  String get tooltipBack => 'Quay lại';

  @override
  String get tooltipSwitchCamera => 'Đổi camera';

  @override
  String get tooltipEnterTracking => 'Nhập mã vận đơn';

  @override
  String get tooltipZoomIn => 'Phóng to';

  @override
  String get tooltipZoomOut => 'Thu nhỏ';

  @override
  String get captureResolution => 'Độ phân giải';

  @override
  String get stopRecording => 'Dừng quay';

  @override
  String get videoTypeSettings => 'Cài đặt loại video';

  @override
  String get uploadQueueTitle => 'Hàng đợi upload';

  @override
  String get quotaExhaustedNote =>
      'Hết hạn mức tháng này. Video vẫn quay được, nhưng đang nằm TRÊN MÁY NÀY và chưa được bảo vệ — chúng sẽ tự tải lên khi hạn mức được nâng.';

  @override
  String get queueEmpty => 'Chưa có video trong hàng đợi';

  @override
  String get queueAutoUploadNote =>
      'Upload khi có mạng sẽ được tự động thực hiện';

  @override
  String get waitingUpload => 'Chờ upload';

  @override
  String get uploaded => 'Đã upload';

  @override
  String get waitingQuota => 'Chờ hạn mức · còn trên máy';

  @override
  String get pausedUpload => 'Đã tạm dừng';

  @override
  String get queuePauseAction => 'Tạm dừng';

  @override
  String get queueResumeAction => 'Tiếp tục';

  @override
  String get queueDeleteAction => 'Xóa';

  @override
  String get queueClearAction => 'Xoá hết';

  @override
  String get queueClearConfirmTitle => 'Xoá toàn bộ hàng chờ?';

  @override
  String get queueClearConfirmBody =>
      'Những clip chưa tải lên chỉ nằm trên máy này. Xoá là mất hẳn, không lấy lại được.';

  @override
  String get queueDeleteConfirmTitle => 'Xóa khỏi hàng đợi?';

  @override
  String get queueDeleteConfirmBody =>
      'Video/ảnh này chưa được tải lên — xóa sẽ mất vĩnh viễn khỏi máy.';

  @override
  String get toastQueueItemDeleted => 'Đã xóa khỏi hàng đợi tải lên';

  @override
  String get manualTrackingTitle => 'Nhập mã vận đơn';

  @override
  String get manualTrackingNote => 'Nhập hoặc quét lại mã vận đơn';

  @override
  String get commonDone => 'Xong';

  @override
  String get startRecording => 'Bắt đầu quay';

  @override
  String get returnCodeMismatch => 'Mã hoàn không khớp';

  @override
  String get enterCodeManually => 'Nhập tay mã';

  @override
  String get videoTypeLabel => 'Loại video';

  @override
  String get videoTypeSelectNote =>
      'Chọn loại phù hợp — thêm/sửa/xóa trong Chi tiết shop';

  @override
  String get videoTypeSheetTitle => 'Chọn loại video';

  @override
  String get videoTypeGroupDefault => 'Loại mặc định (bắt buộc)';

  @override
  String get videoTypeGroupCustom => 'Loại tùy chỉnh của shop';

  @override
  String get manageVideoTypesNote => 'Quản lý loại video — mở Chi tiết shop';

  @override
  String queueFilterAll(int count) {
    return 'Tất cả ($count)';
  }

  @override
  String queueFilterUploading(int count) {
    return 'Đang tải ($count)';
  }

  @override
  String queueFilterErrored(int count) {
    return 'Lỗi ($count)';
  }

  @override
  String queueFilterQuotaWait(int count) {
    return 'Chờ hạn mức ($count)';
  }

  @override
  String queueSummary(int pending, int uploading, int errored) {
    return '$pending video đang chờ · $uploading đang tải · $errored lỗi';
  }

  @override
  String uploadingProgress(int percent) {
    return 'Đang tải $percent%';
  }

  @override
  String errorRetryCount(int count) {
    return 'Lỗi · Thử lại ($count)';
  }

  @override
  String returnCodeMismatchBody(String returnCode, String shopName) {
    return '$returnCode không khớp mã vận đơn nào trong $shopName. Kiểm tra lại mã, nhập tay hoặc xác nhận tạo vận đơn mới.';
  }

  @override
  String get onboardingSubtitle =>
      'Quay video bằng chứng đóng hàng cho seller TMĐT';

  @override
  String get onboardingStart => 'Bắt đầu';

  @override
  String get authSignIn => 'Đăng nhập';

  @override
  String get authChooseMethod => 'Chọn phương thức đăng nhập';

  @override
  String get authEmailRequired => 'Vui lòng nhập email';

  @override
  String get authEmailInvalid => 'Email không hợp lệ';

  @override
  String get authPassword => 'Mật khẩu';

  @override
  String get authPasswordRequired => 'Vui lòng nhập mật khẩu';

  @override
  String get authForgotPassword => 'Quên mật khẩu?';

  @override
  String get registerWithGoogle => 'Đăng ký với Google';

  @override
  String get registerWithApple => 'Đăng ký với Apple';

  @override
  String get authSignInGoogle => 'Đăng nhập với Google';

  @override
  String get authSignInApple => 'Đăng nhập với Apple';

  @override
  String get authNoAccountPrompt => 'Bạn chưa có tài khoản? ';

  @override
  String get authRegister => 'Đăng ký';

  @override
  String get authOr => 'hoặc';

  @override
  String get registerTitle => 'Tạo tài khoản mới';

  @override
  String get registerConfirmPassword => 'Nhập lại mật khẩu';

  @override
  String get registerAgreePolicy => 'Tôi đồng ý chính sách ';

  @override
  String get registerViewPolicy => 'Xem chính sách';

  @override
  String get registerCreateAccount => 'Tạo tài khoản';

  @override
  String get registerSameEmailNote =>
      'Cùng email sẽ tự liên kết về một tài khoản';

  @override
  String get registerHaveAccountPrompt => 'Đã có tài khoản? ';

  @override
  String get registerSuccessTitle => 'Đã tạo tài khoản';

  @override
  String registerSuccessVerifyMessage(String email) {
    return 'Đã gửi email xác minh tới $email. Kiểm tra hộp thư (kể cả mục spam), rồi đăng nhập.';
  }

  @override
  String get registerSuccessMessage =>
      'Tài khoản đã sẵn sàng. Đăng nhập bằng email và mật khẩu vừa đăng ký.';

  @override
  String get registerSuccessAction => 'Đăng nhập';

  @override
  String get loginNotVerifiedTitle => 'Email chưa xác minh';

  @override
  String loginNotVerifiedMessage(String email) {
    return 'Mở email xác minh đã gửi tới $email (kiểm tra cả mục spam), bấm link trong đó rồi đăng nhập lại.';
  }

  @override
  String get loginResendVerification => 'Gửi lại email';

  @override
  String get loginVerificationResent => 'Đã gửi lại email xác minh';

  @override
  String get forgotPasswordTitle => 'Quên mật khẩu';

  @override
  String get forgotPasswordSubtitle =>
      'Nhập email để nhận liên kết đặt lại mật khẩu';

  @override
  String get forgotPasswordSubmit => 'Gửi liên kết đặt lại';

  @override
  String get forgotPasswordSent => 'Đã gửi — kiểm tra hộp thư, kể cả mục spam';

  @override
  String get forgotPasswordRememberPrompt => 'Nhớ mật khẩu rồi? ';

  @override
  String get shopYourShops => 'Shop của bạn';

  @override
  String get shopTapToClockIn => 'Chạm shop để vào ca · quản lý ngay tại đây';

  @override
  String get shopLastOpenedNote =>
      'Shop vào gần nhất sẽ được mở thẳng ở lần sau';

  @override
  String get shopManageStore => 'Quản lý cửa hàng';

  @override
  String get shopManageVisibilityNote =>
      'Chỉ hiện với Chủ tài khoản / Quản lý shop';

  @override
  String get shopEmpty => 'Chưa có shop nào';

  @override
  String get shopEmptyBody =>
      'Tài khoản của bạn chưa thuộc shop nào. Tạo shop mới để bắt đầu, hoặc chờ lời mời từ chủ shop.';

  @override
  String get shopCreateNew => 'Tạo shop mới (tên + sàn)';

  @override
  String get shopInvitesHere => 'Lời mời vào shop sẽ hiện ở đây';

  @override
  String get shopCreateTitle => 'Tạo shop';

  @override
  String get shopNameLabel => 'Tên shop';

  @override
  String get shopNameRequired => 'Vui lòng nhập tên shop';

  @override
  String get shopPlatform => 'Sàn thương mại';

  @override
  String get shopCreateOwnerNote =>
      'Bạn sẽ là Chủ shop — thêm thành viên sau trong Quản lý cửa hàng';

  @override
  String get shopMgmtVisibilityNote =>
      'Nhân viên không thấy màn này · QL shop chỉ thấy shop mình quản';

  @override
  String get shopAddNew => 'Thêm cửa hàng mới';

  @override
  String get sectionMembers => 'THÀNH VIÊN';

  @override
  String get sectionShopSettings => 'CÀI ĐẶT SHOP';

  @override
  String get sectionVideoTypes => 'LOẠI VIDEO';

  @override
  String get videoTypesLockedNote =>
      '3 loại có sẵn bị khóa — không sửa/xóa được';

  @override
  String get addMemberByContact => 'Thêm thành viên bằng email/SĐT';

  @override
  String get recordResolution => 'Độ phân giải quay';

  @override
  String get addVideoType => 'Thêm loại (nhập tên)';

  @override
  String get createVideoTypeTitle => 'Tạo loại video';

  @override
  String get videoTypeName => 'Tên loại video';

  @override
  String get videoTypeNameHint => 'Ví dụ: Cân hàng';

  @override
  String get createVideoType => 'Tạo loại';

  @override
  String get deleteVideoTypeBody =>
      'Chỉ xóa được khi loại này chưa có video nào. Nếu đã có video, hệ thống sẽ chặn để tránh làm rối bộ lọc và thống kê bằng chứng.';

  @override
  String get deleteVideoTypeConfirm => 'Xóa loại';

  @override
  String get deleteVideoTypeNote => '(Chỉ xóa khi loại chưa có video nào)';

  @override
  String get addMemberTitle => 'Thêm thành viên';

  @override
  String get addMemberBody =>
      'Nhập email của tài khoản ZenPack đã đăng ký. Họ nhận được lời mời và phải bấm xác nhận mới vào shop.';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailRequired => 'Nhập email.';

  @override
  String get emailInvalid => 'Nhập đúng một địa chỉ email.';

  @override
  String get errorInviteAccountNotFound =>
      'Email này chưa có tài khoản ZenPack. Bảo họ đăng ký trước rồi mời lại.';

  @override
  String get errorInviteAlreadyMember => 'Người này đã là thành viên của shop.';

  @override
  String get errorInviteMemberLimit =>
      'Đã đủ số người của gói hiện tại. Lời mời đang chờ cũng tính — thu hồi một lời mời để có chỗ.';

  @override
  String get errorInviteAlreadyOwner => 'Đây là chủ shop, không cần mời.';

  @override
  String get errorInviteInvalidRequest =>
      'Email không hợp lệ. Kiểm tra lại rồi gửi.';

  @override
  String get addMemberSubmit => 'Thêm';

  @override
  String get memberOwnerLocked =>
      'Chủ cửa hàng không đổi vai trò hay gỡ ở đây được — quyền sở hữu gắn với cửa hàng, không phải một hàng thành viên.';

  @override
  String get removeFromShop => 'Gỡ khỏi shop';

  @override
  String get revokeInvite => 'Xóa lời mời';

  @override
  String get resolutionAppliesNote => 'Áp dụng cho video quay mới của shop';

  @override
  String get resolutionDefaultOption => '720p (mặc định)';

  @override
  String get ordersSearchHint => 'Nhập mã vận đơn';

  @override
  String get ordersEmpty => 'Shop chưa có đơn nào';

  @override
  String recordAutoStopIn(String time) {
    return 'Tự chốt sau $time';
  }

  @override
  String get ordersNotFound => 'Không tìm thấy đơn hàng';

  @override
  String get ordersNotFoundHint => 'Kiểm tra lại mã vận đơn và thử lại';

  @override
  String ordersPageRange(int first, int last, int total) {
    return '$first–$last / $total vận đơn';
  }

  @override
  String get ordersPagePrevious => 'Trang trước';

  @override
  String get ordersPageNext => 'Trang sau';

  @override
  String ordersPageNumber(int page) {
    return 'Trang $page';
  }

  @override
  String get filterStatusLabel => 'Trạng thái';

  @override
  String get filterStatusAll => 'Tất cả';

  @override
  String get filterStatusPending => 'Chờ upload';

  @override
  String get filterStatusError => 'Có lỗi tải';

  @override
  String get filterStatusDone => 'Đã tải xong';

  @override
  String get filterTimeLabel => 'Thời gian';

  @override
  String get filterTimeAll => 'Mọi lúc';

  @override
  String get filterTimeToday => 'Hôm nay';

  @override
  String get filterTimeYesterday => 'Hôm qua';

  @override
  String get filterTime7d => '7 ngày qua';

  @override
  String get filterTime30d => '30 ngày qua';

  @override
  String get filterTimePickDate => 'Chọn ngày…';

  @override
  String get filterTypeLabel => 'Loại video';

  @override
  String get filterTypeAll => 'Tất cả';

  @override
  String deleteVideoTypeTitle(String typeName) {
    return 'Xóa loại \"$typeName\"?';
  }

  @override
  String memberCurrentRole(String role) {
    return 'Vai trò hiện tại: $role';
  }

  @override
  String get stopCodeTitle => 'Mã QR dừng quay';

  @override
  String get stopCodeInstructions =>
      'In mã này ra và dán ở bàn đóng hàng. Đưa mã vào khung hình camera khi đang quay để tự động dừng quay.';

  @override
  String get scannedCodeNotFound => 'Không tìm thấy vận đơn khớp mã đã quét';

  @override
  String get onboardingTaglineOne => 'Mỗi kiện hàng.';

  @override
  String get onboardingTaglineTwo => 'Một bằng chứng.';

  @override
  String get onboardingTaglineThree => 'Bảo vệ doanh thu của bạn.';

  @override
  String get authEmailPlaceholder => 'Nhập email của bạn';

  @override
  String get authPasswordPlaceholder => 'Nhập mật khẩu của bạn';

  @override
  String get registerCreateAccountSubtitle => 'Tạo tài khoản mới';

  @override
  String get registerFullName => 'Họ tên';

  @override
  String get registerFullNameRequired => 'Vui lòng nhập họ tên';

  @override
  String get registerAgreePrefix => 'Tôi đồng ý với';

  @override
  String get registerTermsOfUse => 'Điều khoản sử dụng';

  @override
  String get shopChooseTitle => 'Chọn cửa hàng';

  @override
  String get shopChooseSubtitle => 'Chọn cửa hàng để tiếp tục';

  @override
  String get shopManageTitle => 'Quản lý cửa hàng';

  @override
  String get shopManageOwnerOnly =>
      'Chỉ hiển thị với Chủ tài khoản / Quản lý shop';

  @override
  String get noShopTitle => 'Chưa có shop nào';

  @override
  String get noShopLineOne => 'Tài khoản của bạn chưa thuộc shop nào.';

  @override
  String get noShopLineTwo => 'Tạo shop mới để bắt đầu,';

  @override
  String get noShopLineThree => 'hoặc chờ lời mời từ chủ shop.';

  @override
  String get noShopCreateCta => 'Tạo shop mới (tên + sàn)';

  @override
  String get noShopInviteHint => 'Lời mời vào shop sẽ hiện ở đây';

  @override
  String get createShopTitle => 'Tạo shop';

  @override
  String get createShopNameLabel => 'Tên shop';

  @override
  String get createShopNameHint => 'Ví dụ: Shop ABC';

  @override
  String get createShopPlatformLabel => 'Sàn thương mại';

  @override
  String get createShopOwnerNote =>
      'Bạn sẽ là chủ shop — thêm thành viên sau trong Quản lý cửa hàng';

  @override
  String get createShopSubmit => 'Tạo shop';

  @override
  String get shopManageDescription =>
      'Xem và quản lý danh sách các cửa hàng bạn có quyền quản lý.';

  @override
  String get shopManageAddCta => 'Thêm shop mới';

  @override
  String get shopManageStaffNote =>
      'Nhân viên không thấy màn này — chỉ chủ shop và quản lý shop mới xem được.';

  @override
  String get shopDetailTitle => 'Chi tiết cửa hàng';

  @override
  String get shopDetailResolution => 'Độ phân giải quay';

  @override
  String get shopDetailClipDuration => 'Thời lượng/video';

  @override
  String clipDurationValue(String minutes) {
    return '$minutes phút';
  }

  @override
  String clipRecommendedHint(
    String minutes,
    String platform,
    String megabytes,
    String resolution,
  ) {
    return 'Đề xuất $minutes phút — theo $platform ($megabytes MB/video) + $resolution';
  }

  @override
  String clipRecommendedHintUnverified(String minutes, String platform) {
    return 'Đề xuất $minutes phút — giới hạn của $platform chưa xác minh, đang dùng mức chung thận trọng nhất';
  }

  @override
  String clipOverRecommendedWarning(
    String minutes,
    String platform,
    String chosen,
    String megabytes,
  ) {
    return 'Vượt mức đề xuất $minutes phút của $platform — video $chosen phút nặng ~$megabytes MB, phải gửi bằng link hồ sơ thay vì đính trực tiếp lên form khiếu nại.';
  }

  @override
  String get clipDurationTitle => 'Thời lượng tối đa mỗi video';

  @override
  String get clipDurationSubtitle => 'Chạm mốc này là tự chốt';

  @override
  String clipDurationPlanCap(String minutes) {
    return 'Gói của bạn cho tối đa $minutes phút';
  }

  @override
  String clipDurationChanged(String minutes) {
    return 'Thời lượng/video: $minutes phút';
  }

  @override
  String get shopDetailImageSize => 'Dung lượng ảnh';

  @override
  String get shopDetailVideoSize => 'Dung lượng video';

  @override
  String get shopDetailUploadSize => 'Dung lượng/tệp';

  @override
  String uploadSizeValue(String megabytes) {
    return '$megabytes MB';
  }

  @override
  String uploadRecommendedHint(String megabytes, String platform) {
    return 'Đề xuất $megabytes MB — theo giới hạn ảnh đính kèm của $platform';
  }

  @override
  String uploadOverRecommendedWarning(
    String megabytes,
    String platform,
    String chosen,
  ) {
    return 'Vượt mức đề xuất $megabytes MB của $platform — tệp tới $chosen MB vẫn lưu nguyên vẹn, nhưng phải gửi bằng link hồ sơ thay vì đính trực tiếp lên form khiếu nại.';
  }

  @override
  String get uploadSizeValueUnlimited => 'Không giới hạn';

  @override
  String get uploadSizeTitle => 'Dung lượng tối đa mỗi tệp';

  @override
  String uploadSizeSubtitle(String megabytes, String platform) {
    return 'Tệp vượt trần sẽ không đính được; $megabytes MB vẫn đính thẳng lên $platform';
  }

  @override
  String uploadSizeOptionRecommended(String megabytes) {
    return '$megabytes MB (đề xuất)';
  }

  @override
  String uploadSizeChanged(String megabytes) {
    return 'Dung lượng/tệp: $megabytes';
  }

  @override
  String avatarTooLarge(String megabytes, String limit) {
    return 'Đã lưu tên và SĐT. Ảnh đại diện $megabytes MB vượt trần $limit MB nên chưa lên máy chủ — chọn ảnh nhỏ hơn.';
  }

  @override
  String avatarUploadFailed(String reason) {
    return 'Đã lưu tên và SĐT. Ảnh đại diện chưa lên máy chủ: $reason';
  }

  @override
  String nearClipLimitWarning(String minutes) {
    return 'Sắp chạm trần $minutes phút — video sẽ tự chốt';
  }

  @override
  String get shopDetailAddType => 'Thêm loại (nhập tên)';

  @override
  String get inviteMemberTitle => 'Mời thành viên';

  @override
  String get inviteRoleFixedNote =>
      'Người được mời vào shop với vai trò Nhân viên: quay video và xem lại video của chính mình.';

  @override
  String get inviteMemberHint => '(chưa có tài khoản → gửi lời mời)';

  @override
  String get videoTypeIcon => 'Biểu tượng';

  @override
  String get videoTypeColor => 'Màu sắc';

  @override
  String get createVideoTypeSubmit => 'Tạo loại';

  @override
  String get deleteVideoTypeSafeNote => 'Không mất bằng chứng';

  @override
  String get commonConfirm => 'Xác nhận';

  @override
  String orderErrorCount(int count) {
    return '$count lỗi';
  }

  @override
  String get videoDetailSheetTitle => 'Chi tiết video';

  @override
  String get tooltipStopRecording => 'Dừng quay';

  @override
  String get dossierLinkTitle => 'Link hồ sơ khiếu nại';

  @override
  String get accountEndQr => 'Mã dừng quay';

  @override
  String get accountEndQrTitle => 'Mã dừng quay';

  @override
  String get accountEndQrShare => 'Chia sẻ mã';

  @override
  String get accountEndQrSave => 'Lưu vào thư viện ảnh';

  @override
  String get recordInterruptedTitle => 'Đã tạm dừng quay';

  @override
  String get recordInterruptedBody =>
      'Quá trình quay đã tạm dừng do có tác động từ bên ngoài. Bạn có muốn tiếp tục quay không?';

  @override
  String get recordInterruptedResume => 'Tiếp tục';

  @override
  String get recordInterruptedFinish => 'Kết thúc';

  @override
  String get commonApply => 'Áp dụng';

  @override
  String get unitMinutes => 'phút';

  @override
  String get clipDurationCustomLabel => 'Hoặc nhập số phút bạn muốn';

  @override
  String get supportOpenFailed =>
      'Không mở được, kiểm tra xem máy đã cài ứng dụng chưa';

  @override
  String get feedbackThanksTitle => 'Cảm ơn bạn!';

  @override
  String get feedbackThanksBody =>
      'Phản hồi của bạn giúp ZenPack ngày càng tốt hơn.';

  @override
  String get feedbackTitle => 'Bạn muốn chia sẻ điều gì với chúng tôi?';

  @override
  String get feedbackHint => 'Nhập góp ý của bạn...';

  @override
  String get feedbackSend => 'Gửi góp ý';

  @override
  String get feedbackThanks => 'Cảm ơn bạn đã góp ý';

  @override
  String get accountSectionAbout => 'GIỚI THIỆU';

  @override
  String get accountFeedback => 'Góp ý với chúng tôi';

  @override
  String get accountFeedbackNote => 'Chia sẻ ý kiến để ZenPack tốt hơn';

  @override
  String get accountRateApp => 'Đánh giá ứng dụng';

  @override
  String get accountRateAppNote => 'Hỗ trợ phát triển ZenPack';

  @override
  String get supportFacebook => 'Nhắn Facebook';

  @override
  String get supportZalo => 'Nhắn Zalo';

  @override
  String get supportCall => 'Gọi hỗ trợ';

  @override
  String sheetCustomMin(String min, String unit) {
    return 'Nhập từ $min $unit trở lên';
  }

  @override
  String sheetCustomRange(String min, String max, String unit) {
    return 'Nhập từ $min đến $max $unit';
  }

  @override
  String get accountEndQrNote =>
      'In tờ này dán ở bàn đóng hàng. Đang quay mà quét vào là chốt video ngay. Mã dùng chung cho mọi máy.';

  @override
  String get languageChangeScopeNote =>
      'Toàn bộ nhãn, thông báo và hồ sơ\nsẽ đổi sang ngôn ngữ bạn chọn.';

  @override
  String get manualEntryEmptyError => 'Vui lòng nhập mã vận đơn trước khi quay';

  @override
  String get appUpdateTitle => 'Đã có phiên bản mới';

  @override
  String get appUpdateMessage => 'Cập nhật ZenPack để dùng bản mới nhất.';

  @override
  String get appUpdateNow => 'Cập nhật';

  @override
  String get appUpdateLater => 'Để sau';

  @override
  String get quotaVideosThisMonth => 'Video tháng này';

  @override
  String get quotaSubtitleVideos => 'Theo dõi số video đã quay trong tháng';

  @override
  String get quotaUpgrade => 'Nâng cấp gói';

  @override
  String get quotaBlockedTitle => 'Đã hết hạn mức video';

  @override
  String get quotaBlockedNote =>
      'Video vẫn quay bình thường, nhưng chưa tải lên được — chúng đang nằm trên máy và chưa được bảo vệ. Hạn mức được nâng thì chúng tự tải lên.';

  @override
  String get quotaBlockedOwnerNote =>
      'Hạn mức của cửa hàng này do chủ tài khoản quyết định — liên hệ họ để nâng. Gói bạn tự mua chỉ áp cho tài khoản của chính bạn.';

  @override
  String get quotaTopupCredits => 'Lượt mua thêm';

  @override
  String get quotaOverCap => 'Đã vượt trần gói';

  @override
  String quotaBlockAt(int n) {
    return 'Chặn quay mới từ $n video';
  }

  @override
  String get quotaResetMonthly => 'Đếm lại từ đầu tháng sau, không cộng dồn';

  @override
  String get storageOwnTitle => 'Kho riêng của shop';

  @override
  String storageOwnPending(int count) {
    return '$count video đang chờ đẩy sang kho của bạn';
  }

  @override
  String storageOwnProblem(int count) {
    return '$count video trong kho của bạn có vấn đề';
  }

  @override
  String get quotaExhaustedWarn =>
      'Đừng gỡ app hay xoá dữ liệu app cho tới khi tải lên xong.';

  @override
  String quotaStrandedTitle(int count) {
    return '$count video đang chờ trên máy này';
  }

  @override
  String get quotaStrandedNote =>
      'Những video này chỉ tồn tại trên điện thoại. Mất máy, gỡ app hoặc xoá dữ liệu app là mất luôn.';

  @override
  String get storageTitle => 'Kho lưu trữ';

  @override
  String get storageSystemName => 'Cloud Zenpack';

  @override
  String get storageS3Name => 'Kho riêng của bạn (S3)';

  @override
  String get storageDriveName => 'Google Drive của bạn';

  @override
  String get storageSystemDesc =>
      'Mặc định, không phải cấu hình gì. Đây là nơi duy nhất hệ thống bảo đảm được đầy đủ mọi cam kết về bằng chứng.';

  @override
  String get storageOwnDesc =>
      'Video mới lưu thẳng vào kho của bạn. Video cũ nằm nguyên chỗ cũ cho tới khi hết hạn lưu.';

  @override
  String get storageNoPresign =>
      'Kho này không ký được link tải, nên video phải đi vòng qua máy chủ — người nhận link sẽ thấy chậm hơn.';

  @override
  String get storageNoObjectLock =>
      'Kho này không khoá được đối tượng. Không thể hứa với sàn rằng bằng chứng không xoá được.';

  @override
  String get storageNotInPlan =>
      'Gói hiện tại chưa mở kho riêng. Nâng gói trên web để dùng.';

  @override
  String get storageHealthTitle => 'Tình trạng kho';

  @override
  String get storageHealthTotal => 'Tổng video';

  @override
  String get storageHealthIntact => 'Còn nguyên vẹn';

  @override
  String get storageHealthUnreachable => 'Không truy cập được';

  @override
  String get storageHealthMismatched => 'Sai lệch với hồ sơ niêm phong';

  @override
  String get storageHealthPendingRelay => 'Đang chờ ở vùng tạm';

  @override
  String get storageProblemsNote =>
      'Có video đang gặp vấn đề ở kho của bạn. Kiểm tra lại quyền truy cập bên phía nhà cung cấp.';

  @override
  String get storageTest => 'Kiểm tra lại kết nối';

  @override
  String get storageDisconnect => 'Thôi dùng kho riêng';

  @override
  String get storageDisconnectConfirm =>
      'Video quay từ lúc này sẽ về kho hệ thống. Video cũ vẫn nằm trong kho của bạn và hệ thống sẽ mất đường tới chúng.';

  @override
  String get storageConnectS3 => 'Cắm kho S3';

  @override
  String get storageConnectDrive => 'Kết nối Google Drive';

  @override
  String get storageConnectHint =>
      'Chỉ cần cấp quyền đọc/ghi/xoá trên đúng prefix bên dưới, không cần quyền trên cả bucket.';

  @override
  String get storageConnectSubmit => 'Kiểm tra và lưu';

  @override
  String get storageFieldEndpoint => 'Endpoint';

  @override
  String get storageFieldBucket => 'Bucket';

  @override
  String get storageFieldAccessKey => 'Access key ID';

  @override
  String get storageFieldSecretKey => 'Secret access key';

  @override
  String get storageFieldRegion => 'Region';

  @override
  String get storageFieldPrefix => 'Prefix';

  @override
  String get storageFieldPrefixHint =>
      'Thư mục con trong bucket. Để mặc định nếu không chắc.';

  @override
  String get storageConnected => 'Đã cắm kho riêng.';

  @override
  String get storageDisconnected => 'Đã thôi dùng kho riêng.';

  @override
  String get storageTestOk => 'Kết nối bình thường.';

  @override
  String get storageOwnerOnly => 'Chỉ chủ cửa hàng đổi được kho lưu trữ.';

  @override
  String get dangerZone => 'Vùng nguy hiểm';

  @override
  String get shopDelete => 'Xoá cửa hàng';

  @override
  String get shopDeleteDesc =>
      'Xoá hẳn đơn, bằng chứng, tệp trên kho và thành viên. Không lùi lại được.';

  @override
  String get shopDeleteConfirmTitle => 'Xoá cửa hàng này?';

  @override
  String shopDeleteConfirmBody(int orders, int videos, int members) {
    return '$orders đơn · $videos video · $members thành viên sẽ bị xoá vĩnh viễn.';
  }

  @override
  String shopDeleteOpenDossiers(int n) {
    return '$n hồ sơ khiếu nại đang mở. Link đã gửi cho sàn sẽ chết ngay khi xoá.';
  }

  @override
  String get shopDeleteForce => 'Vẫn xoá';

  @override
  String get shopDeleteFailed => 'Không xoá được cửa hàng.';

  @override
  String get claimsCreatedLocalOnly =>
      'Đã tạo hồ sơ trên máy. Chưa gửi lên được nên chưa có link chia sẻ — mở lại khi có mạng.';

  @override
  String get claimsLinkCopied =>
      'Đã sao chép link hồ sơ. Dán vào kênh khiếu nại của sàn.';

  @override
  String get shopRenameTitle => 'Đổi tên cửa hàng';

  @override
  String get shopRenameHint => 'Tên cửa hàng';

  @override
  String get shopRenamed => 'Đã đổi tên cửa hàng';

  @override
  String get commonSave => 'Lưu';

  @override
  String get inviteJoinRow => 'Tôi có lời mời';

  @override
  String inviteJoinedShop(String shop) {
    return 'Đã vào cửa hàng $shop';
  }

  @override
  String inviteAlreadyJoined(String shop) {
    return 'Bạn đã ở trong cửa hàng $shop rồi';
  }

  @override
  String get inviteBadLink =>
      'Link không đúng. Hãy dán nguyên link trong email.';

  @override
  String get inviteNotFound => 'Lời mời không tồn tại hoặc đã bị thu hồi';

  @override
  String get inviteTaken => 'Lời mời này đã có người khác nhận';

  @override
  String get inviteExpired => 'Lời mời đã quá hạn. Nhờ chủ shop gửi lại.';

  @override
  String get inviteQrRow => 'Mã QR';

  @override
  String get inviteScanTitle => 'Quét mã mời';

  @override
  String get inviteScanDetail => 'Nhờ chủ shop mở mã QR mời rồi quét vào đây.';

  @override
  String get commonShare => 'Chia sẻ';

  @override
  String get inviteQrSaved => 'Đã lưu mã vào thư viện';

  @override
  String get inviteQrSaveFailed => 'Không lưu được mã vào thư viện';

  @override
  String get voiceRecordingStarted => 'Đã bắt đầu quay';

  @override
  String get voiceRecordingStopped => 'Đã dừng quay';

  @override
  String get voiceWrongCode => 'Sai mã';

  @override
  String get voiceCapSoon => 'Video sắp tự chốt';

  @override
  String voiceCapNear(int minutes) {
    return 'Sắp chạm trần $minutes phút, video sẽ tự chốt';
  }

  @override
  String get voiceInterrupted => 'Quá trình quay bị gián đoạn';

  @override
  String get videoTypePacking => 'Đóng hàng';

  @override
  String get videoTypeCarrier => 'Đơn vị vận chuyển';

  @override
  String get videoTypeReturn => 'Trả hàng';

  @override
  String get storageIntro =>
      'Video của shop cất ở đâu. Dù cất ở đâu, hồ sơ niêm phong luôn nằm tại hệ thống — đổi kho không làm yếu bằng chứng.';

  @override
  String get storageS3Title => 'Kho đám mây riêng (chuẩn S3)';

  @override
  String get storageS3Desc =>
      'AWS S3, Cloudflare R2, MinIO, Wasabi… Video nằm trong bucket của bạn, bạn tự chịu trách nhiệm về độ bền.';

  @override
  String get storageDriveTitle => 'Google Drive';

  @override
  String get storageDriveDesc =>
      'Cắm bằng một lượt cấp quyền, không cần dán khoá. Tài khoản miễn phí chỉ có 15 GB dùng chung với Gmail.';

  @override
  String get storageNeedProPlan =>
      'Cắm kho riêng cần gói Chuyên nghiệp trở lên.';

  @override
  String get attachCodeToOrder => 'Quét thêm mã vào đơn này';

  @override
  String get attachedCodes => 'Mã đã gắn thêm';

  @override
  String get codeAttached => 'Đã gắn mã vào đơn này';

  @override
  String get codeBelongsToAnotherOrder =>
      'Mã này đang thuộc đơn khác — không gộp được.';

  @override
  String get codeAttachFailed => 'Không gắn được mã. Thử lại.';
}

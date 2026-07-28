// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

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
  String get toastUpgradeComingSoon => 'Nâng cấp gói — sắp ra mắt';

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
  String get toastPhotoQueued => 'Đã đính kèm ảnh — đưa vào hàng chờ tải';

  @override
  String get toastInvitePending => 'Chờ lời mời vào shop';

  @override
  String get toastInviteSent => 'Đã gửi lời mời';

  @override
  String get toastMemberAdded => 'Đã thêm thành viên';

  @override
  String get toastDossierLinkCreated => 'Đã tạo link hồ sơ';

  @override
  String get toastDossierLinkRevoked => 'Đã thu hồi link hồ sơ';

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
  String get toastRoleChangedManager => 'Đã đổi vai trò: Quản lý shop';

  @override
  String get toastRoleChangedStaff => 'Đã đổi vai trò: Nhân viên';

  @override
  String get toastNoMemberToUpdate => 'Không có thành viên để cập nhật';

  @override
  String get toastMemberRemoved =>
      'Đã gỡ khỏi shop (video đã quay vẫn upload nốt)';

  @override
  String copiedLabel(String label) {
    return 'Đã sao chép $label';
  }

  @override
  String get labelTrackingCode => 'mã vận đơn';

  @override
  String get labelDossierLink => 'link hồ sơ';

  @override
  String resolutionChanged(String value) {
    return 'Độ phân giải: $value';
  }

  @override
  String dossierShareText(String tracking) {
    return 'Hồ sơ khiếu nại $tracking';
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
  String get roleManager => 'Quản lý';

  @override
  String get roleStaff => 'Nhân viên';

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
  String get statOrdersToday => 'Vận đơn hôm nay';

  @override
  String get statVideosRecorded => 'Video đã quay';

  @override
  String get statPendingUpload => 'Chờ tải';

  @override
  String get accountPlanQuota => 'Gói cước & Quota';

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
  String get accountDeleteAccount => 'Xóa tài khoản';

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
  String get phoneLabel => 'Số điện thoại';

  @override
  String get phoneHint => 'Nhập số điện thoại';

  @override
  String get phoneRequired => 'Vui lòng nhập số điện thoại';

  @override
  String get phoneInvalid => 'Số điện thoại không hợp lệ';

  @override
  String get accountSaveChanges => 'Lưu thay đổi';

  @override
  String get phoneAddTitle => 'Thêm số điện thoại';

  @override
  String get phoneAddBody =>
      'Tài khoản đăng nhập bằng Apple/Google chưa có số điện thoại. Vui lòng nhập số điện thoại để tiếp tục.';

  @override
  String get commonContinue => 'Tiếp tục';

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
  String get quotaCurrentPlan => 'Gói hiện tại';

  @override
  String get quotaRemainingThisMonth => 'Còn lại trong tháng';

  @override
  String get quotaStorage => 'Lưu trữ';

  @override
  String get quotaUpgradePlan => 'Nâng cấp gói';

  @override
  String get deleteAccountTitleStep1 => 'Xóa tài khoản?';

  @override
  String get deleteAccountTitleStep2 => 'Xác nhận xóa vĩnh viễn?';

  @override
  String get deleteAccountBodyStep1 =>
      'Toàn bộ video, đơn hàng và hồ sơ của bạn sẽ bị xóa vĩnh viễn. Hành động này không thể hoàn tác.';

  @override
  String get deleteAccountBodyStep2 =>
      'Đây là bước xác nhận cuối cùng. Sau khi xóa, bạn sẽ được đăng xuất khỏi ứng dụng ngay lập tức.';

  @override
  String get deleteConfirmPermanent => 'Xóa vĩnh viễn';

  @override
  String get deleteStep1Hint =>
      'Bước 1/2 — sẽ yêu cầu xác nhận lại · xong đăng xuất ngay';

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
  String get passwordConfirmLabel => 'Nhập lại mật khẩu mới';

  @override
  String get passwordMismatch => 'Mật khẩu nhập lại không khớp';

  @override
  String get passwordSave => 'Lưu mật khẩu';

  @override
  String get passwordChangeLogoutNote =>
      '(Đổi xong sẽ đăng xuất khỏi các thiết bị khác)';

  @override
  String get navOrders => 'Vận đơn';

  @override
  String get navRecord => 'Ghi hình';

  @override
  String get navAccount => 'Tài khoản';

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
  String deletePendingProfilesWarning(int count) {
    return 'Bạn còn $count hồ sơ khiếu nại đang mở — link chia sẻ sẽ ngừng hoạt động';
  }

  @override
  String get detailRecordedTime => 'Giờ quay';

  @override
  String get detailRecordedBy => 'Người quay';

  @override
  String get detailDevice => 'Thiết bị';

  @override
  String get detailSize => 'Dung lượng';

  @override
  String get detailUploadStatus => 'Trạng thái upload';

  @override
  String get detailPlayVideo => 'Phát video';

  @override
  String get detailDownloadVideo => 'Tải video về máy';

  @override
  String get detailDownloadNote =>
      'Chỉ Chủ tài khoản / QL shop — để đính kèm form khiếu nại sàn';

  @override
  String get attachPhotoToOrder => 'Đính kèm ảnh vào đơn';

  @override
  String get createDossierLink => 'Tạo link hồ sơ khiếu nại';

  @override
  String get dossierLinkLabel => 'Link hồ sơ khiếu nại';

  @override
  String get revoke => 'Thu hồi';

  @override
  String get deleteVideoAction => 'Xóa video';

  @override
  String get deleteVideoNote =>
      'Chỉ Chủ tài khoản / QL shop · xác nhận 2 bước · mất vĩnh viễn';

  @override
  String ordersErrorCount(int count) {
    return '· $count lỗi';
  }

  @override
  String ordersPendingEvidenceWarning(int count) {
    return '$count bằng chứng chưa upload — hồ sơ sẽ thiếu';
  }

  @override
  String get captureFramePrompt => 'Đưa bill vào khung để bắt đầu';

  @override
  String get captureCameraDownHint => 'Camera nhìn xuống bàn';

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
  String get quotaExhaustedNote => 'Hết quota tháng này — video sẽ chờ quota';

  @override
  String get upgradePlanShort => 'Nâng gói';

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
  String get waitingQuota => 'Chờ quota';

  @override
  String get manualTrackingTitle => 'Nhập tay mã vận đơn';

  @override
  String get manualTrackingNote => 'Dùng khi bill mờ — không quá 10 giây';

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
      'Chọn loại cho phiên quay — thêm/sửa/xóa trong Chi tiết shop';

  @override
  String get manageVideoTypesNote => 'Quản lý loại video — mở Chi tiết shop';

  @override
  String queueFilterAll(int count) {
    return 'Tất cả · $count';
  }

  @override
  String queueFilterUploading(int count) {
    return 'Đang tải · $count';
  }

  @override
  String queueFilterErrored(int count) {
    return 'Lỗi · $count';
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
    return '$returnCode không khớp vận đơn nào trong $shopName. Kiểm tra lại mã, nhập tay hoặc xác nhận tạo vận đơn mới.';
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
  String get forgotPasswordTitle => 'Quên mật khẩu';

  @override
  String get forgotPasswordSubtitle =>
      'Nhập email để nhận link đặt lại mật khẩu';

  @override
  String get forgotPasswordSubmit => 'Gửi link đặt lại';

  @override
  String get forgotPasswordSent => 'Đã gửi — kiểm tra hộp thư (kể cả mục spam)';

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
  String get shopAddNew => 'Thêm shop mới (tên + sàn)';

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
      'Nhập email hoặc số điện thoại của tài khoản đã đăng ký để thêm vào shop.';

  @override
  String get emailOrPhone => 'Email hoặc số điện thoại';

  @override
  String get addMemberSubmit => 'Thêm';

  @override
  String get setAsManager => 'Đặt làm Quản lý shop';

  @override
  String get setAsStaff => 'Đặt làm Nhân viên';

  @override
  String get removeFromShop => 'Gỡ khỏi shop';

  @override
  String get resolutionAppliesNote => 'Áp dụng cho video quay mới của shop';

  @override
  String get resolutionDefaultOption => '720p (mặc định)';

  @override
  String get ordersNotFound => 'Không tìm thấy đơn hàng';

  @override
  String get filterStatusLabel => 'Trạng thái upload';

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
  String get filterTime7d => '7 ngày qua';

  @override
  String get filterTime30d => '30 ngày qua';

  @override
  String get filterTypeLabel => 'Loại video';

  @override
  String get filterTypeAll => 'Loại video';

  @override
  String deleteVideoTypeTitle(String typeName) {
    return 'Xóa loại \"$typeName\"?';
  }

  @override
  String memberCurrentRole(String role) {
    return 'Vai trò hiện tại: $role';
  }
}

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
  String get roleManager => 'Quản lý';

  @override
  String get roleStaff => 'Nhân viên';

  @override
  String get planFree => 'Miễn phí';

  @override
  String get planBasic => 'Cơ bản';

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
  String get accountSignOutConfirmTitle => 'Đăng xuất?';

  @override
  String get accountSignOutConfirmMessage =>
      'Bạn sẽ cần đăng nhập lại để tiếp tục sử dụng.';

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
  String get accountEmailLockedHint =>
      'Email dùng để đăng nhập, không thể thay đổi';

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
  String get quotaSubtitle => 'Theo dõi dung lượng đang dùng';

  @override
  String quotaRemainingAmount(String amount) {
    return '$amount còn lại';
  }

  @override
  String get quotaStorage => 'Lưu trữ';

  @override
  String get quotaUpgradePlan => 'Nâng cấp gói';

  @override
  String get quotaUpgradeShort => 'Nâng cấp';

  @override
  String get quotaOwnerOnlyNote => 'Chỉ chủ tài khoản mới đổi được gói cước';

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
  String get quotaPaymentHistory => 'Lịch sử thanh toán';

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
  String get detailPlayVideo => 'Phát video';

  @override
  String get detailDownloadVideo => 'Tải video về máy';

  @override
  String get detailDownloadNote =>
      'Chỉ Chủ/QL shop · dùng khi sàn yêu cầu file gốc';

  @override
  String get detailDownloadPhoto => 'Tải ảnh về máy';

  @override
  String get attachPhotoToOrder => 'Đính kèm ảnh vào đơn';

  @override
  String get deleteVideoAction => 'Xóa video';

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
    return '$count bằng chứng chưa upload · link hồ sơ sẽ thiếu';
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
  String get pausedUpload => 'Đã tạm dừng';

  @override
  String get queuePauseAction => 'Tạm dừng';

  @override
  String get queueResumeAction => 'Tiếp tục';

  @override
  String get queueDeleteAction => 'Xóa';

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
  String get registerPhone => 'Số điện thoại';

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
  String get shopManageAddCta => 'Thêm shop mới (tên + sàn)';

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
  String clipDurationSubtitle(String minutes, String platform) {
    return 'Chạm mốc này là tự chốt; $minutes phút vẫn đính thẳng lên $platform được';
  }

  @override
  String clipDurationOptionRecommended(String minutes) {
    return '$minutes phút (đề xuất)';
  }

  @override
  String clipDurationPlanCap(String minutes) {
    return 'Gói của bạn cho tối đa $minutes phút';
  }

  @override
  String clipDurationChanged(String minutes) {
    return 'Thời lượng/video: $minutes phút';
  }

  @override
  String imageOverPlatformLimit(
    String megabytes,
    String platform,
    String limit,
  ) {
    return 'Ảnh $megabytes MB — vượt giới hạn $limit MB của $platform. Vẫn lưu nguyên vẹn; khi khiếu nại hãy gửi bằng link hồ sơ.';
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
  String get accountEndQrNote =>
      'In tờ này dán ở bàn đóng hàng. Đang quay mà quét vào là chốt video ngay. Mã dùng chung cho mọi máy.';

  @override
  String get languageChangeScopeNote =>
      'Toàn bộ nhãn, thông báo và hồ sơ\nsẽ đổi sang ngôn ngữ bạn chọn.';

  @override
  String get manualEntryEmptyError => 'Vui lòng nhập mã vận đơn trước khi quay';
}

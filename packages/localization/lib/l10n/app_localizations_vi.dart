// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'StampMail';

  @override
  String get loginAppBarTitle => 'Đăng nhập';

  @override
  String get loginHeadline => 'Chào mừng trở lại';

  @override
  String get loginSubtitle => 'Đăng nhập để sắp xếp không gian số của bạn.';

  @override
  String get loginUsernameLabel => 'Địa chỉ email';

  @override
  String get loginUsernameHint => 'hello@example.com';

  @override
  String get loginPasswordLabel => 'Mật khẩu';

  @override
  String get loginPasswordHint => '••••••••';

  @override
  String get loginShowPassword => 'Hiện mật khẩu';

  @override
  String get loginHidePassword => 'Ẩn mật khẩu';

  @override
  String get loginForgotPassword => 'Quên?';

  @override
  String get loginSubmit => 'Đăng nhập';

  @override
  String get loginDividerLabel => 'HOẶC TIẾP TỤC VỚI';

  @override
  String get loginGoogle => 'Google';

  @override
  String get loginApple => 'Apple';

  @override
  String get loginRegisterPrompt => 'Mới dùng Flutter Starter? ';

  @override
  String get loginNavigateToRegister => 'Tạo tài khoản';

  @override
  String get loginPasswordRecoveryUnavailable =>
      'Khôi phục mật khẩu chưa được cấu hình.';

  @override
  String get loginSocialUnavailable =>
      'Đăng nhập mạng xã hội chưa được cấu hình.';

  @override
  String get registerAppBarTitle => 'Đăng ký';

  @override
  String get registerHeadline => 'Tham gia Flutter Starter';

  @override
  String get registerSubtitle =>
      'Tạo tài khoản để bắt đầu sắp xếp cuộc sống số của bạn thật rõ ràng và dễ dàng.';

  @override
  String get registerEmailLabel => 'Địa chỉ email';

  @override
  String get registerEmailHint => 'jane@example.com';

  @override
  String get registerInvalidEmail => 'Nhập địa chỉ email hợp lệ.';

  @override
  String get registerUsernameLabel => 'Tên đăng nhập';

  @override
  String get registerPasswordLabel => 'Mật khẩu';

  @override
  String get registerPasswordHint => '••••••••';

  @override
  String get registerPasswordHelp => 'Mật khẩu phải có ít nhất 8 ký tự.';

  @override
  String get registerPasswordMinLengthError =>
      'Mật khẩu cần có ít nhất 8 ký tự.';

  @override
  String get registerShowPassword => 'Hiện mật khẩu';

  @override
  String get registerHidePassword => 'Ẩn mật khẩu';

  @override
  String get registerConfirmPasswordLabel => 'Xác nhận mật khẩu';

  @override
  String get registerSubmit => 'Tham gia Flutter Starter';

  @override
  String get registerLoginPrompt => 'Bạn đã có tài khoản? ';

  @override
  String get registerNavigateToLogin => 'Đăng nhập';

  @override
  String get errorPasswordsDoNotMatch => 'Mật khẩu không khớp.';

  @override
  String get fieldRequired => 'Bắt buộc';

  @override
  String get errorInvalidCredentials =>
      'Vui lòng nhập tên đăng nhập và mật khẩu.';

  @override
  String get errorInvalidInput => 'Dữ liệu không hợp lệ.';

  @override
  String get errorUnknown => 'Đã xảy ra lỗi.';

  @override
  String get commonCancel => 'Hủy';

  @override
  String get commonCreate => 'Tạo';

  @override
  String get commonDelete => 'Xóa';

  @override
  String get commonEdit => 'Chỉnh sửa';

  @override
  String get commonImageLoadFailed => 'Không tải được hình ảnh';

  @override
  String get commonLoading => 'Đang tải…';

  @override
  String get commonRetry => 'Thử lại';

  @override
  String get commonSave => 'Lưu';

  @override
  String get commonShare => 'Chia sẻ';

  @override
  String get commonSignOut => 'Đăng xuất';

  @override
  String get homeAppBarTitle => 'Trang chủ';

  @override
  String get homeViewAllBookmarks => 'Xem tất cả';

  @override
  String get homeNoDescription => 'Không có mô tả';

  @override
  String get homeRecentBookmarks => 'Bookmark gần đây';

  @override
  String get homeNoBookmarks => 'Chưa có bookmark nào. Nhấn + để thêm.';

  @override
  String get homeSearchTitle => 'Tìm kiếm';

  @override
  String get homeSearchSubtitle =>
      'Tìm nhanh bài viết, công cụ và nguồn cảm hứng đã lưu.';

  @override
  String get homeSearchHint => 'Tìm bookmark...';

  @override
  String get homeQuickAdd => 'Thêm liên kết';

  @override
  String get homeQuickLibrary => 'Thư viện';

  @override
  String get homeQuickTags => 'Thẻ';

  @override
  String get homeFilterAll => 'Tất cả';

  @override
  String get homeFilterDesign => 'Thiết kế';

  @override
  String get homeFilterArticles => 'Bài viết';

  @override
  String get homeFilterInspiration => 'Cảm hứng';

  @override
  String get homeFilterTools => 'Công cụ';

  @override
  String get homeSuggestedTitle => 'Gợi ý cho bạn';

  @override
  String get homeFeaturedCollections => 'Bộ sưu tập nổi bật';

  @override
  String get homeWeeklyDigestTitle => 'Tóm tắt tuần';

  @override
  String get homeWeeklyDigestEyebrow => 'Đọc nhiều nhất';

  @override
  String get homeWeeklyDigestHeadline => 'Điểm lại kho tri thức đã lưu';

  @override
  String homeWeeklyDigestBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Gần đây bạn đã lưu $count bookmark. Xem lại các điểm nổi bật để tiếp tục mạch đọc.',
      zero:
          'Gần đây bạn chưa lưu bookmark nào. Hãy quay lại khi có nội dung mới.',
    );
    return '$_temp0';
  }

  @override
  String get homeReadDigest => 'Đọc tóm tắt';

  @override
  String get homeNoMatches => 'Không có bookmark nào khớp với chế độ xem này.';

  @override
  String get homeBookmarkVisualFallback => 'Gần đây';

  @override
  String get profileAppBarTitle => 'Hồ sơ';

  @override
  String get profileSectionAppearance => 'Giao diện';

  @override
  String get profileSectionAccount => 'Tài khoản';

  @override
  String get profileChangePassword => 'Đổi mật khẩu';

  @override
  String get profileDeleteAccount => 'Xóa tài khoản';

  @override
  String get profileDeleteAccountDialogTitle => 'Xóa tài khoản?';

  @override
  String get profileDeleteAccountDialogMessage =>
      'Thao tác này sẽ xóa vĩnh viễn tài khoản và toàn bộ dữ liệu của bạn. Không thể hoàn tác.';

  @override
  String profileDeleteAccountConfirmLabel(String username) {
    return 'Nhập \"$username\" để xác nhận';
  }

  @override
  String get profileDeleteAccountSuccess => 'Tài khoản của bạn đã được xóa.';

  @override
  String get profileDeleteAccountError =>
      'Không thể xóa tài khoản. Vui lòng thử lại.';

  @override
  String get changePasswordAppBarTitle => 'Đổi mật khẩu';

  @override
  String get changePasswordCurrentLabel => 'Mật khẩu hiện tại';

  @override
  String get changePasswordNewLabel => 'Mật khẩu mới';

  @override
  String get changePasswordConfirmLabel => 'Xác nhận mật khẩu mới';

  @override
  String get changePasswordSubmit => 'Cập nhật mật khẩu';

  @override
  String get changePasswordSuccessMessage => 'Cập nhật mật khẩu thành công.';

  @override
  String get changePasswordMismatchError => 'Mật khẩu mới không khớp.';

  @override
  String get profileSectionAbout => 'Giới thiệu';

  @override
  String get profileUserIdCopied => 'Đã sao chép ID người dùng';

  @override
  String get profileAppearanceThemeLabel => 'Chủ đề';

  @override
  String get profileAppearanceColorLabel => 'Màu nhấn';

  @override
  String get profileThemeSystemDefault => 'Mặc định hệ thống';

  @override
  String get profileThemeLight => 'Sáng';

  @override
  String get profileThemeDark => 'Tối';

  @override
  String profileAppVersionBuild(String version, String buildNumber) {
    return 'Phiên bản $version (bản dựng $buildNumber)';
  }

  @override
  String get profileSignOutConfirmMessage =>
      'Bạn có chắc muốn đăng xuất không?';

  @override
  String get bookmarksAppBarTitle => 'Bookmarks';

  @override
  String get bookmarksSearchHint => 'Tìm tiêu đề, URL hoặc thẻ';

  @override
  String get bookmarksNoMatchesTitle => 'Không có kết quả';

  @override
  String get bookmarksNoMatchesMessage =>
      'Không có bookmark nào khớp với tìm kiếm.';

  @override
  String get bookmarksEmptyTitle => 'Chưa có bookmark nào';

  @override
  String get bookmarksEmptyMessage => 'Nhấn + để thêm bookmark đầu tiên.';

  @override
  String get bookmarksNotYetSynced => 'Chưa đồng bộ';

  @override
  String get bookmarksSyncFailedRetryTooltip =>
      'Đồng bộ thất bại - nhấn để thử lại';

  @override
  String get bookmarksAddTooltip => 'Thêm bookmark';

  @override
  String get bookmarksSearchClear => 'Xóa tìm kiếm';

  @override
  String get bookmarksSortTooltip => 'Sắp xếp bookmark';

  @override
  String get bookmarksSortMenuLabel => 'Menu sắp xếp';

  @override
  String get bookmarksSortNewest => 'Mới nhất trước';

  @override
  String get bookmarksSortOldest => 'Cũ nhất trước';

  @override
  String get bookmarksSortTitleAz => 'Tiêu đề (A–Z)';

  @override
  String get bookmarksTabAll => 'Tất cả';

  @override
  String get bookmarksTabRecent => 'Gần đây';

  @override
  String get bookmarksTabCollections => 'Bộ sưu tập';

  @override
  String get bookmarksRecentEmptyTitle => 'Chưa có gì gần đây';

  @override
  String get bookmarksRecentEmptyMessage =>
      'Các dấu trang bạn thêm trong tuần này sẽ xuất hiện ở đây.';

  @override
  String get bookmarksCollectionsComingSoonTitle => 'Bộ sưu tập sắp ra mắt';

  @override
  String get bookmarksCollectionsComingSoonMessage =>
      'Nhóm các dấu trang liên quan vào bộ sưu tập trong bản cập nhật sắp tới.';

  @override
  String get bookmarkMoreActions => 'Thêm thao tác';

  @override
  String get bookmarkAppBarTitle => 'Chi tiết Bookmark';

  @override
  String get bookmarkSourceLabel => 'Nguồn';

  @override
  String get bookmarkVisitWebsite => 'Mở trang web';

  @override
  String get bookmarkDetailsLabel => 'Chi tiết';

  @override
  String get bookmarkDateCreatedLabel => 'Ngày tạo';

  @override
  String get bookmarkLastModifiedLabel => 'Cập nhật lần cuối';

  @override
  String get bookmarkMediaLabel => 'Phương tiện';

  @override
  String get bookmarkOpenInBrowser => 'Mở trong trình duyệt';

  @override
  String get bookmarkNotFound => 'Không tìm thấy bookmark.';

  @override
  String get bookmarkDeleteDialogTitle => 'Xóa bookmark?';

  @override
  String get bookmarkDeleteDialogBody =>
      'Không thể hoàn tác hành động này.\nBookmark sẽ bị xóa vĩnh viễn khỏi bộ sưu tập của bạn.';

  @override
  String bookmarkDeleteDialogMessage(String title) {
    return '\"$title\" sẽ bị xóa.';
  }

  @override
  String get bookmarkOpenUrl => 'Mở URL';

  @override
  String get bookmarkAttachedVideo => 'Video đính kèm';

  @override
  String get bookmarkInvalidUrl => 'URL không hợp lệ';

  @override
  String get bookmarkCouldNotOpenUrl => 'Không thể mở URL';

  @override
  String get bookmarkFormEditTitle => 'Chỉnh sửa bookmark';

  @override
  String get bookmarkFormNewTitle => 'Bookmark mới';

  @override
  String get bookmarkFormLoadFailed => 'Không tải được bookmark.';

  @override
  String get bookmarkTitleLabel => 'Tiêu đề';

  @override
  String get bookmarkUrlLabel => 'URL';

  @override
  String get bookmarkDescriptionLabel => 'Mô tả (tùy chọn)';

  @override
  String get bookmarkTagsLabel => 'Thẻ';

  @override
  String get bookmarkTagsHint => 'các, giá trị, phân tách, bằng, dấu phẩy';

  @override
  String get bookmarkPreviewLabel => 'Bookmark';

  @override
  String get bookmarkTitleRequired => 'Bắt buộc nhập tiêu đề';

  @override
  String get bookmarkUrlRequired => 'Bắt buộc nhập URL';

  @override
  String get bookmarkUrlInvalid => 'Nhập URL hợp lệ (https://…)';

  @override
  String get errorPermissionDenied => 'Quyền truy cập bị từ chối.';

  @override
  String get errorGalleryPermissionRequired =>
      'Cần có quyền truy cập thư viện ảnh để đính kèm hình ảnh.';

  @override
  String get errorCameraPermissionRequired =>
      'Cần có quyền truy cập máy ảnh để chụp ảnh.';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navBookmarks => 'Bookmark';

  @override
  String get navLetters => 'Hộp thư';

  @override
  String get navAlbum => 'Album';

  @override
  String get navProfile => 'Cá nhân';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get settingsAppBarTitle => 'Cài đặt';

  @override
  String get bookmarksDetailPlaceholder => 'Chọn một bookmark để xem chi tiết';

  @override
  String bookmarkImageLabel(String title) {
    return 'Hình ảnh của $title';
  }

  @override
  String get bookmarkAttachedImageLabel => 'Hình ảnh đính kèm';

  @override
  String get bookmarkRemoveImageLabel => 'Xóa hình ảnh';

  @override
  String get navNotifications => 'Thông báo';

  @override
  String get notificationsAppBarTitle => 'Thông báo';

  @override
  String get notificationsActivitySection => 'Hoạt động của bạn';

  @override
  String get notificationsSection => 'Thông báo';

  @override
  String get notificationsSectionNew => 'Mới';

  @override
  String get notificationsSectionEarlier => 'Trước đó';

  @override
  String get notificationsEmptyTitle => 'Chưa có gì ở đây';

  @override
  String get notificationsEmptyMessage =>
      'Thông báo và hoạt động gần đây của bạn sẽ hiển thị ở đây.';

  @override
  String get notificationsNoNotifications => 'Chưa có thông báo nào.';

  @override
  String get notificationsLoadError =>
      'Không tải được thông báo. Hãy kéo để làm mới hoặc thử lại.';

  @override
  String notificationsUnreadCount(int count) {
    return '$count chưa đọc';
  }

  @override
  String get timeJustNow => 'Vừa xong';

  @override
  String timeMinutesAgo(int minutes) {
    return '$minutes phút trước';
  }

  @override
  String timeHoursAgo(int hours) {
    return '$hours giờ trước';
  }

  @override
  String timeDaysAgo(int days) {
    return '$days ngày trước';
  }

  @override
  String get collectionsTitle => 'Bộ sưu tập';

  @override
  String get collectionsEmptyTitle => 'Chưa có bộ sưu tập';

  @override
  String get collectionsEmptyMessage =>
      'Nhóm các dấu trang liên quan vào bộ sưu tập.';

  @override
  String get collectionsLoadError =>
      'Không tải được bộ sưu tập. Kéo để làm mới hoặc thử lại.';

  @override
  String get collectionsCreate => 'Bộ sưu tập mới';

  @override
  String get collectionsCreateTitle => 'Bộ sưu tập mới';

  @override
  String get collectionsEditTitle => 'Sửa bộ sưu tập';

  @override
  String get collectionNameLabel => 'Tên';

  @override
  String get collectionNameHint => 'ví dụ: Cảm hứng thiết kế';

  @override
  String get collectionNameRequired => 'Vui lòng nhập tên';

  @override
  String get collectionAppearanceLabel => 'Biểu tượng & màu sắc';

  @override
  String get collectionSave => 'Lưu';

  @override
  String get collectionDeleteAction => 'Xóa bộ sưu tập';

  @override
  String get collectionDeleteDialogTitle => 'Xóa bộ sưu tập?';

  @override
  String collectionDeleteDialogMessage(String name) {
    return '\"$name\" sẽ bị xóa. Các dấu trang của bạn vẫn được giữ lại.';
  }

  @override
  String get collectionNotFound => 'Không tìm thấy bộ sưu tập.';

  @override
  String collectionItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dấu trang',
      one: '1 dấu trang',
      zero: 'Chưa có dấu trang',
    );
    return '$_temp0';
  }

  @override
  String get collectionAddBookmarks => 'Thêm dấu trang';

  @override
  String get collectionRemoveBookmark => 'Xóa khỏi bộ sưu tập';

  @override
  String get collectionEmptyBookmarks =>
      'Bộ sưu tập này chưa có dấu trang nào.';

  @override
  String get collectionPickerEmpty =>
      'Tất cả dấu trang đã có trong bộ sưu tập này.';

  @override
  String collectionPickerAddCount(int count) {
    return 'Thêm $count';
  }

  @override
  String get addToCollectionTitle => 'Thêm vào bộ sưu tập';

  @override
  String get addToCollectionEmpty => 'Bạn chưa tạo bộ sưu tập nào.';

  @override
  String get homeCreateCollection => 'Tạo bộ sưu tập';

  @override
  String get smLoginTitle => 'Chào mừng trở lại! 👋';

  @override
  String get smLoginSubtitle =>
      'Đăng nhập để tiếp tục hành trình viết thư và sưu tầm tem.';

  @override
  String get smLoginIdentifierHint => 'Email hoặc tên người dùng';

  @override
  String get smLoginPasswordHint => 'Mật khẩu';

  @override
  String get smLoginForgot => 'Quên mật khẩu?';

  @override
  String get smLoginSubmit => 'Đăng nhập';

  @override
  String get smLoginDivider => 'hoặc đăng nhập với';

  @override
  String get smLoginNoAccount => 'Chưa có tài khoản? ';

  @override
  String get smLoginRegisterCta => 'Đăng ký';

  @override
  String get smRegisterChoiceTitle => 'Chọn cách đăng ký';

  @override
  String get smRegisterChoiceSubtitle => 'Tiếp tục nhanh với tài khoản của bạn';

  @override
  String get smLoginLockedMessage =>
      'Tài khoản đang bị khóa tạm thời do nhập sai mật khẩu quá nhiều lần.';

  @override
  String smLoginRetryIn(String time) {
    return 'Thử lại sau $time';
  }

  @override
  String smLoginAttemptsLeft(int count) {
    return 'Sai mật khẩu. Còn $count lần thử.';
  }

  @override
  String get smContinueApple => 'Tiếp tục với Apple';

  @override
  String get smContinueGoogle => 'Tiếp tục với Google';

  @override
  String get smContinueFacebook => 'Tiếp tục với Facebook';

  @override
  String get smRegisterTitle => 'Tạo tài khoản mới ✨';

  @override
  String get smRegisterSubtitle => 'Tham gia StampMail ngay!';

  @override
  String get smRegisterEmailHint => 'Email';

  @override
  String get smRegisterConfirmHint => 'Xác nhận mật khẩu';

  @override
  String get smRegisterSubmit => 'Tạo tài khoản';

  @override
  String get smRegisterDivider => 'hoặc đăng ký với';

  @override
  String get smRegisterHaveAccount => 'Đã có tài khoản? ';

  @override
  String get smRegisterLoginCta => 'Đăng nhập';

  @override
  String get smRegisterAgePrefix =>
      'Tôi xác nhận mình từ 13 tuổi trở lên và đồng ý với ';

  @override
  String get smRegisterTerms => 'Điều khoản sử dụng';

  @override
  String get smRegisterAnd => ' và ';

  @override
  String get smRegisterPrivacy => 'Chính sách bảo mật';

  @override
  String get smRegisterAgeRequired =>
      'Bạn phải xác nhận đủ 13 tuổi để tiếp tục.';

  @override
  String get smRegisterEmailExists => 'Email này đã có tài khoản';

  @override
  String get smValEmailRequired => 'Vui lòng nhập email';

  @override
  String get smValEmailInvalid => 'Email không hợp lệ';

  @override
  String get smValPasswordRequired => 'Vui lòng nhập mật khẩu';

  @override
  String get smValPasswordMin => 'Mật khẩu phải có ít nhất 6 ký tự';

  @override
  String get smValConfirmRequired => 'Vui lòng xác nhận mật khẩu';

  @override
  String get smValConfirmMismatch => 'Mật khẩu không khớp';

  @override
  String get smErrWrongCredentials =>
      'Đăng nhập không thành công. Sai email hoặc mật khẩu.';

  @override
  String get smErrGeneric => 'Đăng nhập không thành công. Vui lòng thử lại.';

  @override
  String get smErrOffline => 'Không có kết nối. Vui lòng thử lại khi có mạng.';

  @override
  String smErrWrongMethod(String provider) {
    return 'Tài khoản này không liên kết với $provider';
  }

  @override
  String get smForgotTitle => 'Quên mật khẩu ✨';

  @override
  String get smForgotSubtitle =>
      'Nhập email của bạn và chúng tôi sẽ gửi link đặt lại mật khẩu.';

  @override
  String get smForgotEmailHint => 'Email';

  @override
  String get smForgotSubmit => 'Gửi link đặt lại';

  @override
  String get smForgotBackToLogin => 'Quay lại đăng nhập';

  @override
  String get smForgotCodeTitle => 'Kiểm tra email của bạn ✨';

  @override
  String get smForgotCodeSubtitle =>
      'Chúng tôi đã gửi link đặt lại mật khẩu đến địa chỉ';

  @override
  String get smForgotCodeContinue => 'Tiếp tục';

  @override
  String get smResetTitle => 'Đặt lại mật khẩu ✨';

  @override
  String get smResetSubtitle =>
      'Vui lòng tạo mật khẩu mới cho tài khoản của bạn.';

  @override
  String get smResetNewHint => 'Mật khẩu mới';

  @override
  String get smResetConfirmHint => 'Xác nhận mật khẩu';

  @override
  String get smResetHintMin => 'Tối thiểu 6 ký tự';

  @override
  String get smResetSubmit => 'Lưu mật khẩu mới';

  @override
  String get smResetSuccessTitle => 'Đặt lại thành công ✨';

  @override
  String get smResetSuccessSubtitle =>
      'Mật khẩu của bạn đã được cập nhật.\nGiờ đây, bạn có thể đăng nhập bằng\nmật khẩu mới để tiếp tục gửi yêu thương.';

  @override
  String get smResetSuccessCta => 'Đăng nhập ngay';

  @override
  String get smResetSuccessBack => 'Về trang đăng nhập';

  @override
  String get smVerifyTitle => 'Xác thực email ✉️';

  @override
  String smVerifySubtitle(String email) {
    return 'Chúng tôi đã gửi link xác nhận đến địa chỉ $email. Hãy mở email và bấm vào link để xác nhận.';
  }

  @override
  String smVerifyExpiresIn(String time) {
    return 'Link sẽ hết hạn sau $time';
  }

  @override
  String get smVerifyResend => 'Gửi lại email';

  @override
  String smVerifyResendIn(String time) {
    return 'Gửi lại email ($time)';
  }

  @override
  String get smVerifyInvalidCode =>
      'Email chưa được xác nhận. Hãy bấm vào link trong email trước.';

  @override
  String get smVerifyCheckCta => 'Tôi đã xác nhận';

  @override
  String get smUsernameTitle => 'Chọn tên người dùng ✨';

  @override
  String get smUsernameSubtitle =>
      'Đây là tên hiển thị của bạn trên StampMail.';

  @override
  String get smUsernameLabel => 'Tên người dùng';

  @override
  String get smUsernameHint => 'ten.cua.ban';

  @override
  String get smUsernameTaken => 'Tên người dùng này đã được sử dụng';

  @override
  String get smUsernameTooShort => 'Tên người dùng phải có ít nhất 3 ký tự';

  @override
  String get smUsernameTooLong => 'Tên người dùng không quá 30 ký tự';

  @override
  String get smUsernameSuggestions => 'Gợi ý cho bạn';

  @override
  String get smUsernameContinue => 'Tiếp tục';

  @override
  String get splashTagline => 'Gửi cảm xúc,\nnhận yêu thương.';

  @override
  String get smOnboardingSkip => 'Bỏ qua';

  @override
  String get smOnboardingNext => 'Tiếp theo';

  @override
  String get smOnboardingStart => 'Bắt đầu';

  @override
  String get smOnboard1Title => 'Biến ảnh thành con tem đáng yêu';

  @override
  String get smOnboard1Body =>
      'Chọn ảnh bạn thích, thêm bộ lọc và trang trí để tạo tem thư mang dấu ấn riêng.';

  @override
  String get smOnboard2Title => 'Viết những lá thư đẹp';

  @override
  String get smOnboard2Body =>
      'Chọn mẫu thư, đính tem của bạn và gửi những lá thư đầy cảm xúc đến người thân yêu.';

  @override
  String get smOnboard3Title => 'Sưu tầm và chia sẻ kỷ niệm';

  @override
  String get smOnboard3Body =>
      'Xây dựng album tem của riêng bạn và chia sẻ tác phẩm với bạn bè trên mạng xã hội.';

  @override
  String get smAvatarTitle => 'Thêm ảnh đại diện';

  @override
  String get smAvatarSubtitle =>
      'Giúp bạn bè dễ nhận ra bạn hơn trên StampMail.';

  @override
  String get smAvatarFromLibrary => 'Chọn từ thư viện';

  @override
  String get smAvatarTakePhoto => 'Chụp ảnh';

  @override
  String get smAvatarContinue => 'Tiếp tục';

  @override
  String get smAvatarSkip => 'Bỏ qua';

  @override
  String get smHomeEmptyTitle => 'Chưa có tem nào';

  @override
  String get smHomeEmptyBody =>
      'Tạo con tem đầu tiên từ tấm ảnh yêu thích và bắt đầu bộ sưu tập của bạn.';

  @override
  String get smHomeCreateStamp => 'Tạo tem';
}

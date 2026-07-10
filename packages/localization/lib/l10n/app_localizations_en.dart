// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'StampMail';

  @override
  String get loginAppBarTitle => 'Sign in';

  @override
  String get loginHeadline => 'Welcome Back';

  @override
  String get loginSubtitle => 'Sign in to organize your digital space.';

  @override
  String get loginUsernameLabel => 'Email Address';

  @override
  String get loginUsernameHint => 'hello@example.com';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordHint => '••••••••';

  @override
  String get loginShowPassword => 'Show password';

  @override
  String get loginHidePassword => 'Hide password';

  @override
  String get loginForgotPassword => 'Forgot?';

  @override
  String get loginSubmit => 'Log In';

  @override
  String get loginDividerLabel => 'OR CONTINUE WITH';

  @override
  String get loginGoogle => 'Google';

  @override
  String get loginApple => 'Apple';

  @override
  String get loginRegisterPrompt => 'New to Flutter Starter? ';

  @override
  String get loginNavigateToRegister => 'Create an account';

  @override
  String get loginPasswordRecoveryUnavailable =>
      'Password recovery isn\'t configured yet.';

  @override
  String get loginSocialUnavailable => 'Social sign-in isn\'t configured yet.';

  @override
  String get registerAppBarTitle => 'Register';

  @override
  String get registerHeadline => 'Join Flutter Starter';

  @override
  String get registerSubtitle =>
      'Create an account to start organizing your digital life with clarity and ease.';

  @override
  String get registerEmailLabel => 'Email Address';

  @override
  String get registerEmailHint => 'jane@example.com';

  @override
  String get registerInvalidEmail => 'Enter a valid email address.';

  @override
  String get registerUsernameLabel => 'Username';

  @override
  String get registerPasswordLabel => 'Password';

  @override
  String get registerPasswordHint => '••••••••';

  @override
  String get registerPasswordHelp => 'Must be at least 8 characters.';

  @override
  String get registerPasswordMinLengthError =>
      'Password must be at least 8 characters.';

  @override
  String get registerShowPassword => 'Show password';

  @override
  String get registerHidePassword => 'Hide password';

  @override
  String get registerConfirmPasswordLabel => 'Confirm Password';

  @override
  String get registerSubmit => 'Join Flutter Starter';

  @override
  String get registerLoginPrompt => 'Already have an account? ';

  @override
  String get registerNavigateToLogin => 'Log in';

  @override
  String get errorPasswordsDoNotMatch => 'Passwords do not match.';

  @override
  String get fieldRequired => 'Required';

  @override
  String get errorInvalidCredentials => 'Please enter a username and password.';

  @override
  String get errorInvalidInput => 'Invalid input.';

  @override
  String get errorUnknown => 'Something went wrong.';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonCreate => 'Create';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonImageLoadFailed => 'Failed to load image';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonSave => 'Save';

  @override
  String get commonShare => 'Share';

  @override
  String get commonSignOut => 'Sign out';

  @override
  String get homeAppBarTitle => 'Home';

  @override
  String get homeViewAllBookmarks => 'View all';

  @override
  String get homeNoDescription => 'No description';

  @override
  String get homeRecentBookmarks => 'Recent Bookmarks';

  @override
  String get homeNoBookmarks => 'No bookmarks yet. Tap + to add one.';

  @override
  String get homeSearchTitle => 'Search';

  @override
  String get homeSearchSubtitle =>
      'Find your saved articles, tools, and inspirations instantly.';

  @override
  String get homeSearchHint => 'Search bookmarks...';

  @override
  String get homeQuickAdd => 'Add Link';

  @override
  String get homeQuickLibrary => 'Library';

  @override
  String get homeQuickTags => 'Tags';

  @override
  String get homeFilterAll => 'All';

  @override
  String get homeFilterDesign => 'Design';

  @override
  String get homeFilterArticles => 'Articles';

  @override
  String get homeFilterInspiration => 'Inspiration';

  @override
  String get homeFilterTools => 'Tools';

  @override
  String get homeSuggestedTitle => 'Suggested for You';

  @override
  String get homeFeaturedCollections => 'Featured Collections';

  @override
  String get homeWeeklyDigestTitle => 'Weekly Digest';

  @override
  String get homeWeeklyDigestEyebrow => 'Most Read';

  @override
  String get homeWeeklyDigestHeadline => 'Your saved knowledge catch-up';

  @override
  String homeWeeklyDigestBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'You saved $count bookmarks recently. Review the highlights and keep your reading flow moving.',
      one:
          'You saved 1 bookmark recently. Review the highlight and keep your reading flow moving.',
      zero:
          'You have no recent bookmarks. Review saved highlights when you add one.',
    );
    return '$_temp0';
  }

  @override
  String get homeReadDigest => 'Read Digest';

  @override
  String get homeNoMatches => 'No bookmarks match this view.';

  @override
  String get homeBookmarkVisualFallback => 'Recent';

  @override
  String get profileAppBarTitle => 'Profile';

  @override
  String get profileSectionAppearance => 'Appearance';

  @override
  String get profileSectionAccount => 'Account';

  @override
  String get profileChangePassword => 'Change Password';

  @override
  String get profileDeleteAccount => 'Delete Account';

  @override
  String get profileDeleteAccountDialogTitle => 'Delete account?';

  @override
  String get profileDeleteAccountDialogMessage =>
      'This permanently removes your account and all of its data. This action cannot be undone.';

  @override
  String profileDeleteAccountConfirmLabel(String username) {
    return 'Type \"$username\" to confirm';
  }

  @override
  String get profileDeleteAccountSuccess => 'Your account has been deleted.';

  @override
  String get profileDeleteAccountError =>
      'Couldn\'t delete your account. Please try again.';

  @override
  String get changePasswordAppBarTitle => 'Change Password';

  @override
  String get changePasswordCurrentLabel => 'Current Password';

  @override
  String get changePasswordNewLabel => 'New Password';

  @override
  String get changePasswordConfirmLabel => 'Confirm New Password';

  @override
  String get changePasswordSubmit => 'Update Password';

  @override
  String get changePasswordSuccessMessage => 'Password updated successfully.';

  @override
  String get changePasswordMismatchError => 'New passwords do not match.';

  @override
  String get profileSectionAbout => 'About';

  @override
  String get profileUserIdCopied => 'User ID copied';

  @override
  String get profileAppearanceThemeLabel => 'Theme';

  @override
  String get profileAppearanceColorLabel => 'Accent color';

  @override
  String get profileThemeSystemDefault => 'System default';

  @override
  String get profileThemeLight => 'Light';

  @override
  String get profileThemeDark => 'Dark';

  @override
  String profileAppVersionBuild(String version, String buildNumber) {
    return 'Version $version (build $buildNumber)';
  }

  @override
  String get profileSignOutConfirmMessage =>
      'Are you sure you want to sign out?';

  @override
  String get bookmarksAppBarTitle => 'Bookmarks';

  @override
  String get bookmarksSearchHint => 'Search title, URL, or tag';

  @override
  String get bookmarksNoMatchesTitle => 'No matches';

  @override
  String get bookmarksNoMatchesMessage => 'No bookmarks match your search.';

  @override
  String get bookmarksEmptyTitle => 'No bookmarks yet';

  @override
  String get bookmarksEmptyMessage => 'Tap + to add your first bookmark.';

  @override
  String get bookmarksNotYetSynced => 'Not yet synced';

  @override
  String get bookmarksSyncFailedRetryTooltip => 'Sync failed - tap to retry';

  @override
  String get bookmarksAddTooltip => 'Add bookmark';

  @override
  String get bookmarksSearchClear => 'Clear search';

  @override
  String get bookmarksSortTooltip => 'Sort bookmarks';

  @override
  String get bookmarksSortMenuLabel => 'Sort Menu';

  @override
  String get bookmarksSortNewest => 'Newest first';

  @override
  String get bookmarksSortOldest => 'Oldest first';

  @override
  String get bookmarksSortTitleAz => 'Title (A–Z)';

  @override
  String get bookmarksTabAll => 'All';

  @override
  String get bookmarksTabRecent => 'Recent';

  @override
  String get bookmarksTabCollections => 'Collections';

  @override
  String get bookmarksRecentEmptyTitle => 'Nothing recent';

  @override
  String get bookmarksRecentEmptyMessage =>
      'Bookmarks you add this week show up here.';

  @override
  String get bookmarksCollectionsComingSoonTitle => 'Collections coming soon';

  @override
  String get bookmarksCollectionsComingSoonMessage =>
      'Group related bookmarks into collections in a future update.';

  @override
  String get bookmarkMoreActions => 'More actions';

  @override
  String get bookmarkAppBarTitle => 'Bookmark Details';

  @override
  String get bookmarkSourceLabel => 'Source';

  @override
  String get bookmarkVisitWebsite => 'Visit Website';

  @override
  String get bookmarkDetailsLabel => 'Details';

  @override
  String get bookmarkDateCreatedLabel => 'Date Created';

  @override
  String get bookmarkLastModifiedLabel => 'Last Modified';

  @override
  String get bookmarkMediaLabel => 'Media';

  @override
  String get bookmarkOpenInBrowser => 'Open in Browser';

  @override
  String get bookmarkNotFound => 'Bookmark not found.';

  @override
  String get bookmarkDeleteDialogTitle => 'Delete bookmark?';

  @override
  String get bookmarkDeleteDialogBody =>
      'This action cannot be undone.\nThe bookmark will be permanently removed from your collection.';

  @override
  String bookmarkDeleteDialogMessage(String title) {
    return '\"$title\" will be removed.';
  }

  @override
  String get bookmarkOpenUrl => 'Open URL';

  @override
  String get bookmarkAttachedVideo => 'Attached video';

  @override
  String get bookmarkInvalidUrl => 'Invalid URL';

  @override
  String get bookmarkCouldNotOpenUrl => 'Could not open URL';

  @override
  String get bookmarkFormEditTitle => 'Edit bookmark';

  @override
  String get bookmarkFormNewTitle => 'New bookmark';

  @override
  String get bookmarkFormLoadFailed => 'Failed to load bookmark.';

  @override
  String get bookmarkTitleLabel => 'Title';

  @override
  String get bookmarkUrlLabel => 'URL';

  @override
  String get bookmarkDescriptionLabel => 'Description (optional)';

  @override
  String get bookmarkTagsLabel => 'Tags';

  @override
  String get bookmarkTagsHint => 'comma, separated, values';

  @override
  String get bookmarkPreviewLabel => 'Bookmark';

  @override
  String get bookmarkTitleRequired => 'Title is required';

  @override
  String get bookmarkUrlRequired => 'URL is required';

  @override
  String get bookmarkUrlInvalid => 'Enter a valid URL (https://…)';

  @override
  String get errorPermissionDenied => 'Permission denied.';

  @override
  String get errorGalleryPermissionRequired =>
      'Photo gallery access is required to attach images.';

  @override
  String get errorCameraPermissionRequired =>
      'Camera access is required to take photos.';

  @override
  String get navHome => 'Home';

  @override
  String get navBookmarks => 'Bookmarks';

  @override
  String get navProfile => 'Profile';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsAppBarTitle => 'Settings';

  @override
  String get bookmarksDetailPlaceholder =>
      'Select a bookmark to view its details';

  @override
  String bookmarkImageLabel(String title) {
    return 'Image for $title';
  }

  @override
  String get bookmarkAttachedImageLabel => 'Attached image';

  @override
  String get bookmarkRemoveImageLabel => 'Remove image';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get notificationsAppBarTitle => 'Notifications';

  @override
  String get notificationsActivitySection => 'Your activity';

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get notificationsSectionNew => 'New';

  @override
  String get notificationsSectionEarlier => 'Earlier';

  @override
  String get notificationsEmptyTitle => 'Nothing here yet';

  @override
  String get notificationsEmptyMessage =>
      'Your notifications and recent activity will appear here.';

  @override
  String get notificationsNoNotifications => 'No notifications yet.';

  @override
  String get notificationsLoadError =>
      'Couldn\'t load your notifications. Pull to refresh or try again.';

  @override
  String notificationsUnreadCount(int count) {
    return '$count unread';
  }

  @override
  String get timeJustNow => 'Just now';

  @override
  String timeMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String timeHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String timeDaysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String get collectionsTitle => 'Collections';

  @override
  String get collectionsEmptyTitle => 'No collections yet';

  @override
  String get collectionsEmptyMessage =>
      'Group related bookmarks into collections.';

  @override
  String get collectionsLoadError =>
      'Couldn\'t load your collections. Pull to refresh or try again.';

  @override
  String get collectionsCreate => 'New collection';

  @override
  String get collectionsCreateTitle => 'New collection';

  @override
  String get collectionsEditTitle => 'Edit collection';

  @override
  String get collectionNameLabel => 'Name';

  @override
  String get collectionNameHint => 'e.g. Design inspiration';

  @override
  String get collectionNameRequired => 'Name is required';

  @override
  String get collectionAppearanceLabel => 'Icon & color';

  @override
  String get collectionSave => 'Save';

  @override
  String get collectionDeleteAction => 'Delete collection';

  @override
  String get collectionDeleteDialogTitle => 'Delete collection?';

  @override
  String collectionDeleteDialogMessage(String name) {
    return '\"$name\" will be removed. Your bookmarks stay.';
  }

  @override
  String get collectionNotFound => 'Collection not found.';

  @override
  String collectionItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bookmarks',
      one: '1 bookmark',
      zero: 'No bookmarks',
    );
    return '$_temp0';
  }

  @override
  String get collectionAddBookmarks => 'Add bookmarks';

  @override
  String get collectionRemoveBookmark => 'Remove from collection';

  @override
  String get collectionEmptyBookmarks => 'No bookmarks in this collection yet.';

  @override
  String get collectionPickerEmpty =>
      'All your bookmarks are already in this collection.';

  @override
  String collectionPickerAddCount(int count) {
    return 'Add $count';
  }

  @override
  String get addToCollectionTitle => 'Add to collection';

  @override
  String get addToCollectionEmpty =>
      'You haven\'t created any collections yet.';

  @override
  String get homeCreateCollection => 'Create collection';

  @override
  String get smLoginTitle => 'Welcome back! 👋';

  @override
  String get smLoginSubtitle =>
      'Sign in to continue your journey of writing letters and collecting stamps.';

  @override
  String get smLoginIdentifierHint => 'Email or username';

  @override
  String get smLoginPasswordHint => 'Password';

  @override
  String get smLoginForgot => 'Forgot password?';

  @override
  String get smLoginSubmit => 'Sign in';

  @override
  String get smLoginDivider => 'or sign in with';

  @override
  String get smLoginNoAccount => 'Don\'t have an account? ';

  @override
  String get smLoginRegisterCta => 'Register';

  @override
  String get smLoginLockedMessage =>
      'Your account is temporarily locked after too many failed sign-in attempts.';

  @override
  String smLoginRetryIn(String time) {
    return 'Try again in $time';
  }

  @override
  String smLoginAttemptsLeft(int count) {
    return 'Wrong password. $count attempts left.';
  }

  @override
  String get smContinueApple => 'Continue with Apple';

  @override
  String get smContinueGoogle => 'Continue with Google';

  @override
  String get smContinueFacebook => 'Continue with Facebook';

  @override
  String get smRegisterTitle => 'Create a new account ✨';

  @override
  String get smRegisterSubtitle => 'Join StampMail now!';

  @override
  String get smRegisterEmailHint => 'Email';

  @override
  String get smRegisterConfirmHint => 'Confirm password';

  @override
  String get smRegisterSubmit => 'Create account';

  @override
  String get smRegisterDivider => 'or sign up with';

  @override
  String get smRegisterHaveAccount => 'Already have an account? ';

  @override
  String get smRegisterLoginCta => 'Sign in';

  @override
  String get smRegisterAgePrefix =>
      'I confirm I am 13 years or older and agree to the ';

  @override
  String get smRegisterTerms => 'Terms of Service';

  @override
  String get smRegisterAnd => ' and ';

  @override
  String get smRegisterPrivacy => 'Privacy Policy';

  @override
  String get smRegisterAgeRequired =>
      'You must confirm you are 13 or older to continue.';

  @override
  String get smRegisterEmailExists => 'This email already has an account';

  @override
  String get smValEmailRequired => 'Please enter your email';

  @override
  String get smValEmailInvalid => 'Invalid email';

  @override
  String get smValPasswordRequired => 'Please enter your password';

  @override
  String get smValPasswordMin => 'Password must be at least 6 characters';

  @override
  String get smValConfirmRequired => 'Please confirm your password';

  @override
  String get smValConfirmMismatch => 'Passwords don\'t match';

  @override
  String get smErrWrongCredentials =>
      'Sign-in failed. Wrong email or password.';

  @override
  String get smErrGeneric => 'Sign-in failed. Please try again.';

  @override
  String get smErrOffline =>
      'No connection. Please try again when you\'re online.';

  @override
  String smErrWrongMethod(String provider) {
    return 'This account isn\'t linked with $provider';
  }

  @override
  String get smForgotTitle => 'Forgot password';

  @override
  String get smForgotSubtitle =>
      'Enter your email and we\'ll send a 6-digit code to reset your password.';

  @override
  String get smForgotEmailHint => 'Email';

  @override
  String get smForgotSubmit => 'Send verification code';

  @override
  String get smForgotBackToLogin => 'Back to sign in';

  @override
  String get smVerifyTitle => 'Verify email ✉️';

  @override
  String smVerifySubtitle(String email) {
    return 'We sent a 6-digit verification code to $email';
  }

  @override
  String smVerifyExpiresIn(String time) {
    return 'Code expires in $time';
  }

  @override
  String get smVerifyResend => 'Resend code';

  @override
  String smVerifyResendIn(String time) {
    return 'Resend code ($time)';
  }

  @override
  String get smVerifyInvalidCode => 'The code is incorrect or has expired.';

  @override
  String get smUsernameTitle => 'Choose a username ✨';

  @override
  String get smUsernameSubtitle => 'This is your display name on StampMail.';

  @override
  String get smUsernameLabel => 'Username';

  @override
  String get smUsernameHint => 'your.name';

  @override
  String get smUsernameTaken => 'This username is already taken';

  @override
  String get smUsernameTooShort => 'Username must be at least 3 characters';

  @override
  String get smUsernameTooLong => 'Username must be 30 characters or fewer';

  @override
  String get smUsernameSuggestions => 'Suggestions for you';

  @override
  String get smUsernameContinue => 'Continue';

  @override
  String get splashTagline => 'Send emotions,\nreceive love.';

  @override
  String get smOnboardingSkip => 'Skip';

  @override
  String get smOnboardingNext => 'Next';

  @override
  String get smOnboardingStart => 'Get started';

  @override
  String get smOnboard1Title => 'Turn photos into lovely stamps';

  @override
  String get smOnboard1Body =>
      'Pick a photo you love, add filters and decorations to craft stamps with your own signature.';

  @override
  String get smOnboard2Title => 'Write beautiful digital letters';

  @override
  String get smOnboard2Body =>
      'Choose a template, attach your stamps, and send heartfelt letters to the people you care about.';

  @override
  String get smOnboard3Title => 'Collect and share memories';

  @override
  String get smOnboard3Body =>
      'Build your own stamp album and share your creations with friends across social media.';

  @override
  String get smAvatarTitle => 'Add a profile photo';

  @override
  String get smAvatarSubtitle =>
      'Help friends recognize you more easily on StampMail.';

  @override
  String get smAvatarFromLibrary => 'Choose from library';

  @override
  String get smAvatarTakePhoto => 'Take a photo';

  @override
  String get smAvatarContinue => 'Continue';

  @override
  String get smAvatarSkip => 'Skip';

  @override
  String get smHomeEmptyTitle => 'No stamps yet';

  @override
  String get smHomeEmptyBody =>
      'Create your first stamp from a favorite photo and start your collection.';

  @override
  String get smHomeCreateStamp => 'Create a stamp';
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get bundleBackendPending => 'Waiting on a backend endpoint for this';

  @override
  String get bundleCreate => 'Create';

  @override
  String get bundleCreateClaim => 'Create claim dossier';

  @override
  String get accountClaims => 'Claim dossiers';

  @override
  String get claimsTitle => 'Claim dossiers';

  @override
  String get claimsLocalOnlyNote =>
      'This list is stored on this device. Uninstalling the app or switching devices loses it.';

  @override
  String get claimsEmpty =>
      'No dossiers yet. Open the Orders tab, tap the plus button and pick the evidence to build one.';

  @override
  String claimsSummary(int orders, int evidence) {
    return '$orders orders · $evidence evidence';
  }

  @override
  String get claimsCopied => 'Dossier contents copied';

  @override
  String get claimsCreated => 'Claim dossier created';

  @override
  String get claimsPickNothing => 'No evidence selected';

  @override
  String get claimsDelete => 'Delete dossier';

  @override
  String get claimsDeleteConfirm =>
      'Delete this dossier? The evidence on the orders themselves is untouched.';

  @override
  String get claimsDeleted => 'Dossier deleted';

  @override
  String get claimsPhotoAdded =>
      'Photo added to the dossier and queued onto the order';

  @override
  String get claimsAddedLater => 'added later';

  @override
  String get claimsCreateTitle => 'New claim dossier';

  @override
  String get claimsCreateSearchHint => 'Type or scan a tracking code';

  @override
  String get claimsCreateStart =>
      'Type a tracking code, or tap scan, to find the order you are claiming for.';

  @override
  String get claimsCreateNoOrder =>
      'No order with that tracking code in the selected shop.';

  @override
  String get claimsRemoveItemTitle => 'Remove from dossier';

  @override
  String get claimsRemoveItemConfirm =>
      'Remove this evidence from the claim dossier? The video/photo on the order itself is untouched.';

  @override
  String get claimsItemRemoved => 'Removed from the dossier';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonDelete => 'Delete';

  @override
  String get settingDefaultSuffix => 'default';

  @override
  String get shopDetailClipLength => 'Video length';

  @override
  String get shopDeleteTitle => 'Delete shop';

  @override
  String get shopDeleteConfirm =>
      'Delete this shop? All of its orders, videos and photos go with it, and can\'t be recovered.';

  @override
  String get shopDeleteBlockedTitle => 'The shop still has members';

  @override
  String shopDeleteBlockedBody(int count) {
    return 'Remove every member from the shop before deleting it. $count still remain.';
  }

  @override
  String get shopDeleted => 'Shop deleted.';

  @override
  String bundleSelected(int count) {
    return '$count selected';
  }

  @override
  String get bundleUploadDrive => 'Upload to Drive';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonClose => 'Close';

  @override
  String get toastChangeLanguage => 'Change language';

  @override
  String get toastTermsPolicy => 'Terms & Policy';

  @override
  String get toastInfoSaved => 'Info saved';

  @override
  String get toastPasswordCreated => 'Password created';

  @override
  String get toastPasswordChanged => 'Password changed';

  @override
  String get toastPendingDossierConfirm =>
      'You still have an open claim dossier, please confirm again';

  @override
  String get toastCopiedShareLink => 'Share link copied';

  @override
  String get toastShareFailed => 'Couldn\'t share, try again later';

  @override
  String get toastDownloadingVideo => 'Downloading video';

  @override
  String get toastVideoDownloadedCopied => 'Video downloaded and path copied';

  @override
  String get toastVideoSavedToGallery => 'Video saved to your device gallery';

  @override
  String get toastVideoDownloadFailed =>
      'Couldn\'t download video, try again later';

  @override
  String get toastVideoDeleteUnavailable => 'This video can\'t be deleted';

  @override
  String get toastDownloadingPhoto => 'Downloading photo';

  @override
  String get toastPhotoSavedToGallery => 'Photo saved to your device gallery';

  @override
  String get toastPhotoDownloadedCopied => 'Photo downloaded and path copied';

  @override
  String get toastPhotoDownloadFailed =>
      'Couldn\'t download photo, try again later';

  @override
  String get toastPhotoNoDownloadLink => 'Photo has no download link yet';

  @override
  String get toastPhotoQueued => 'Photo attached — added to the upload queue';

  @override
  String imageOverFixedCap(String megabytes, String limit) {
    return 'Photo is $megabytes MB — over the $limit MB cap, not attached. Pick a smaller image.';
  }

  @override
  String get toastInvitePending => 'Waiting for a shop invitation';

  @override
  String get toastInviteSent => 'Invitation sent';

  @override
  String get toastMemberAdded => 'Member added';

  @override
  String get toastVideoPlayFailed => 'Couldn\'t play video';

  @override
  String get toastShopCreated => 'New shop created';

  @override
  String get toastVideoQueued => 'Video saved — added to the upload queue';

  @override
  String get toastVideoNoPlayLink => 'Video has no playback link yet';

  @override
  String get toastVideoNoDownloadLink => 'Video has no download link yet';

  @override
  String get toastVideoDeleted => 'Video deleted';

  @override
  String get toastVideoTypeSaved => 'Video type saved';

  @override
  String get toastVideoTypeDeleted => 'Video type deleted';

  @override
  String get toastNoVideoTypeToDelete => 'No video type to delete';

  @override
  String get toastNoMemberToUpdate => 'No member to update';

  @override
  String get toastMemberRemoved =>
      'Removed from shop (recorded videos still finish uploading)';

  @override
  String get toastInviteRevoked =>
      'Invitation deleted — the emailed link no longer works';

  @override
  String copiedLabel(String label) {
    return 'Copied $label';
  }

  @override
  String get labelTrackingCode => 'tracking code';

  @override
  String resolutionChanged(String value) {
    return 'Resolution: $value';
  }

  @override
  String get accountNoName => 'No name yet';

  @override
  String get accountNoShop => 'No shop selected';

  @override
  String get accountCreatePassword => 'Create password';

  @override
  String get accountChangePassword => 'Change password';

  @override
  String accountLinkedMethods(int count) {
    return '$count linked';
  }

  @override
  String get roleOwner => 'Owner';

  @override
  String get roleStaff => 'Staff';

  @override
  String memberInviteSent(String role) {
    return '$role · invite sent';
  }

  @override
  String memberInviteAccepted(String role) {
    return '$role · invite accepted';
  }

  @override
  String get planFree => 'Free';

  @override
  String get planBasic => 'Basic';

  @override
  String get planSaver => 'Saver';

  @override
  String get planPremium => 'Premium';

  @override
  String get roleOther => 'Other';

  @override
  String get roleUnknown => 'Unknown';

  @override
  String get memberFallbackName => 'Member';

  @override
  String get uploadStatusDone => 'Uploaded';

  @override
  String get uploadStatusPending => 'Waiting to upload';

  @override
  String get uploadStatusQuotaHold => 'On hold (quota)';

  @override
  String get uploadStatusDeleted => 'Deleted';

  @override
  String get uploadStatusError => 'Server-side processing error';

  @override
  String get uploadStatusExpired => 'Storage retention expired';

  @override
  String expiredOnDate(String date) {
    return 'Storage retention expired on $date';
  }

  @override
  String get kindPhoto => 'Attached photo';

  @override
  String get kindVideo => 'Video';

  @override
  String get recordedByFallback => 'Current account';

  @override
  String get deviceUnknown => 'Unknown device';

  @override
  String get orderNoEvidence => 'No evidence yet';

  @override
  String get timelineEmpty => 'This shipment has no video or photo yet';

  @override
  String get errorGenericRetry => 'Something went wrong, please try again.';

  @override
  String get errorPendingDossier =>
      'You still have an open claim dossier, please handle it before continuing.';

  @override
  String get errorSessionExpired =>
      'Your session has expired, please sign in again.';

  @override
  String get errorNoNetwork => 'No network connection, please try again.';

  @override
  String get errorNoPermission =>
      'You don\'t have permission to perform this action.';

  @override
  String get errorServerBusy => 'The system is busy, please try again later.';

  @override
  String get errorSessionInvalid => 'Invalid session, please sign in again.';

  @override
  String get errorVideoTypeInUse =>
      'Can\'t delete a video type that already has videos. Please review the videos using this type first.';

  @override
  String get errorBuiltinVideoTypeLocked =>
      'The 3 built-in video types can\'t be edited or deleted.';

  @override
  String get errorVideoTypeNameExists =>
      'That video type name already exists in the shop.';

  @override
  String get errorCheckNetwork => 'Check your network or try again later.';

  @override
  String get errorLoadShopList => 'Couldn\'t load the shop list';

  @override
  String get errorLoadShopMgmt => 'Couldn\'t load shop management';

  @override
  String get errorLoadShopDetail => 'Couldn\'t load shop details';

  @override
  String get errorLoadMembers => 'Couldn\'t load the member list';

  @override
  String get membersRestricted => 'Only the shop owner can see the member list';

  @override
  String get errorLoadOrders => 'Couldn\'t load orders';

  @override
  String get errorLoadOrderDetail => 'Couldn\'t load order details';

  @override
  String get noShopSelectedOrdersDetail =>
      'Please choose a shop before viewing orders.';

  @override
  String get noShopSelectedRecordDetail =>
      'Please choose a shop before recording.';

  @override
  String get noShopSelectedManageDetail => 'Please choose a shop to manage.';

  @override
  String get noOrdersTitle => 'No orders yet';

  @override
  String get noOrdersDetail => 'Please choose an order from the list.';

  @override
  String get noVideoDataTitle => 'No video data';

  @override
  String get cannotOpenVideoTitle => 'Couldn\'t open video';

  @override
  String get cannotOpenVideoDetail => 'Video has no playback link yet.';

  @override
  String get createOrderDialogTitle => 'Create a new order?';

  @override
  String createOrderDialogBody(String code) {
    return '$code doesn\'t match any tracking code in the current shop. Re-check the code or confirm creating a new order.';
  }

  @override
  String get createOrderConfirm => 'Create new order';

  @override
  String get statOrdersToday => 'Orders';

  @override
  String get statVideosRecorded => 'Videos recorded';

  @override
  String get statPendingUpload => 'Pending upload';

  @override
  String get accountPlanQuota => 'Storage';

  @override
  String get accountSectionApp => 'PLAN & APP';

  @override
  String get accountLanguage => 'Language';

  @override
  String get accountSectionSecurity => 'SECURITY & SIGN-IN';

  @override
  String get accountLoginMethods => 'Sign-in method';

  @override
  String get accountSignOut => 'Sign out';

  @override
  String get accountSignOutConfirmTitle => 'Sign out?';

  @override
  String get accountSignOutConfirmMessage =>
      'You\'ll need to sign in again to keep using the app.';

  @override
  String get accountDeleteAccount => 'Delete account';

  @override
  String accountVersion(String version) {
    return 'Version $version';
  }

  @override
  String get accountShopMgmtHint =>
      'Manage shop/members: tap back on the header to return to the Shop layer';

  @override
  String get accountInfoTitle => 'Account info';

  @override
  String get accountFullName => 'Full name';

  @override
  String get accountFullNameHint => 'Enter your full name';

  @override
  String get accountFullNameRequired => 'Please enter your full name';

  @override
  String get phoneOptionalLabel => 'Phone number (optional)';

  @override
  String get phoneOptionalHint => 'Optional — for account support only';

  @override
  String get phoneInvalid => 'Invalid phone number';

  @override
  String get accountSaveChanges => 'Save changes';

  @override
  String get accountEmailLockedHint =>
      'Email used to sign in — cannot be changed';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonLater => 'Later';

  @override
  String get cameraPermissionRationaleTitle => 'Camera access needed';

  @override
  String get cameraPermissionRationaleBody =>
      'ZenPack needs the camera to record packing-evidence videos for your orders.';

  @override
  String get cameraPermissionDeniedTitle => 'Can\'t record yet';

  @override
  String get cameraPermissionDeniedBody =>
      'ZenPack can\'t record video because camera access hasn\'t been granted. You can still browse, search and manage your orders.';

  @override
  String get cameraPermissionOpenSettings => 'Open Settings';

  @override
  String get languageNameVietnamese => 'Vietnamese';

  @override
  String get languageNameEnglish => 'English';

  @override
  String get languageChangeAppliesNote =>
      'Changes apply instantly across the whole app';

  @override
  String get linkLinked => 'Linked';

  @override
  String get linkNotLinked => 'Not linked';

  @override
  String get loginMethodsEmailNote =>
      'Email is your account identifier — it can\'t be removed. Link Google/Apple to sign in quickly with the same account.';

  @override
  String get loginMethodIdentity => 'Identifier';

  @override
  String get linkAction => 'Link';

  @override
  String get linkUnlink => 'Unlink';

  @override
  String get quotaScreenTitle => 'Reports & Quota';

  @override
  String get quotaRemainingThisMonth => 'Remaining this month';

  @override
  String get quotaSubtitle => 'Track the storage you are using';

  @override
  String quotaRemainingAmount(String amount) {
    return '$amount remaining';
  }

  @override
  String get quotaStorage => 'Storage';

  @override
  String get deleteAccountTitleStep1 => 'Delete account?';

  @override
  String get deleteAccountTitleStep2 => 'Confirm permanent deletion?';

  @override
  String get deleteAccountBodyStep1 =>
      'All your videos, shipments and dossiers will be permanently deleted. This action cannot be undone.';

  @override
  String get deleteAccountBodyStep2 =>
      'This is the final confirmation step. After deletion, you\'ll be signed out of the app immediately.';

  @override
  String get deleteConfirmPermanent => 'Delete permanently';

  @override
  String get deleteStep1Hint => 'Step 1/2 — will ask for confirmation again';

  @override
  String get deleteStep2Hint => 'Step 2/2 — this action cannot be undone';

  @override
  String get passwordCurrentLabel => 'Current password';

  @override
  String get passwordCurrentRequired => 'Please enter your current password';

  @override
  String get passwordNewLabel => 'New password';

  @override
  String get passwordMinHint => 'At least 8 characters';

  @override
  String get passwordNewRequired => 'Please enter a new password';

  @override
  String get passwordMin8Error => 'Password must be at least 8 characters';

  @override
  String get passwordNeedsLetterDigit =>
      'Password needs both letters and numbers';

  @override
  String get passwordTooCommon =>
      'That password is too easy to guess — pick another';

  @override
  String get passwordConfirmLabel => 'Re-enter new password';

  @override
  String get passwordMismatch => 'Passwords don\'t match';

  @override
  String get passwordSave => 'Save password';

  @override
  String get passwordChangeLogoutNote =>
      'You\'ll be signed out of other devices after changing';

  @override
  String get navOrders => 'Orders';

  @override
  String get navRecord => 'Record';

  @override
  String get navAccount => 'Account';

  @override
  String get navClaims => 'Claims';

  @override
  String get changeAvatar => 'Change profile photo';

  @override
  String quotaVideosRatio(int remaining, int total) {
    return '$remaining / $total videos';
  }

  @override
  String quotaUsedPercent(int percent) {
    return 'Used $percent%';
  }

  @override
  String quotaRetentionDays(int days) {
    return '$days days';
  }

  @override
  String quotaUsedRatio(String used, String cap, int percent) {
    return 'Used $used / $cap · $percent%';
  }

  @override
  String get quotaVideosStored => 'Videos stored';

  @override
  String quotaVideosStoredCount(int count) {
    return '$count videos';
  }

  @override
  String get quotaByType => 'Storage by type';

  @override
  String quotaByTypeVideosCount(int count) {
    return '$count videos stored';
  }

  @override
  String quotaRefundNote(int days) {
    return 'Storage is freed once a video passes its $days-day retention window';
  }

  @override
  String deletePendingProfilesWarning(int count) {
    return 'You still have $count dossiers “sent to the platform” — their share links will stop working';
  }

  @override
  String get detailRecordedTime => 'Recording time';

  @override
  String get detailDuration => 'Duration';

  @override
  String get detailRecordedBy => 'Recorded by';

  @override
  String get detailCapturedTime => 'Capture time';

  @override
  String get detailCapturedBy => 'Captured by';

  @override
  String get detailDevice => 'Device';

  @override
  String get detailSize => 'Size';

  @override
  String get detailUploadStatus => 'Upload status';

  @override
  String get detailSeal => 'Seal';

  @override
  String sealSealed(String at) {
    return 'Locked · $at';
  }

  @override
  String get sealWorking => 'Stamping the timestamp…';

  @override
  String get sealWorkingHint =>
      'The stored copy has no timestamp burned in yet, so playback and download wait for it. Usually a few seconds.';

  @override
  String get sealNone => 'Recorded before sealing existed';

  @override
  String get sealFailed => 'Sealing failed — the video still plays';

  @override
  String get sealMismatch => 'Fingerprint mismatch — re-record this clip';

  @override
  String get sealTimeDrift =>
      'The camera clock drifted from the server, so the burned-in stamp also carries the time the server received the clip.';

  @override
  String get detailSealAnchor => 'Independent proof';

  @override
  String sealAnchorConfirmed(String block) {
    return 'Yes · entry #$block';
  }

  @override
  String get sealAnchorConfirmedNoBlock => 'Yes';

  @override
  String get sealAnchorPending =>
      'Being written to the public ledger (a few hours)';

  @override
  String get sealAnchorNone => 'None';

  @override
  String get sealVerifyOpen => 'Open verification page';

  @override
  String get sealVerifyHint =>
      'Send this link to the marketplace — they can verify it themselves, without trusting ZenPack.';

  @override
  String get sealVerifyFailed => 'Couldn\'t open the verification page.';

  @override
  String get detailPlayVideo => 'Play video';

  @override
  String get detailCopyAssetLink => 'Copy link';

  @override
  String get assetLinkTitle => 'Evidence link';

  @override
  String get detailDownloadVideo => 'Download video';

  @override
  String get detailDownloadNote =>
      'Owner/manager only · for when the marketplace asks for the original file';

  @override
  String get detailDownloadPhoto => 'Download photo';

  @override
  String get attachPhotoToOrder => 'Attach photo to order';

  @override
  String get deleteVideoAction => 'Delete video';

  @override
  String get deletePhotoAction => 'Delete photo';

  @override
  String get deleteVideoNote =>
      'Owner/manager only · locked while a dossier is open · two-step confirm';

  @override
  String get deleteVideoConfirmTitle => 'Final confirmation';

  @override
  String get deleteVideoConfirmBody =>
      'This evidence will be permanently deleted and cannot be recovered — delete anyway?';

  @override
  String get deleteVideoConfirmAction => 'Delete permanently';

  @override
  String ordersErrorCount(int count) {
    return '· $count errors';
  }

  @override
  String ordersPendingCount(int count) {
    return '· $count pending';
  }

  @override
  String ordersPendingEvidenceWarning(int count) {
    return '$count evidence not uploaded · no copyable link yet';
  }

  @override
  String get captureFramePrompt => 'Scan the tracking code';

  @override
  String get captureCameraDownHint => 'Place the bill in the frame';

  @override
  String get cutoverSavedVideo => 'Video saved';

  @override
  String get cutoverPreparingNext => 'Getting ready for the next one';

  @override
  String get cutoverNextOrder => 'Next order';

  @override
  String get lowStorageTitle => 'Storage almost full';

  @override
  String get lowStorageBody =>
      'This device is low on storage — an in-progress recording may not save fully. Free up some space before continuing to record.';

  @override
  String get lowStorageAction => 'Got it';

  @override
  String cutoverClosedSummary(String code, String duration) {
    return 'Closed tracking code $code ($duration)';
  }

  @override
  String get cutoverSignalText => 'Sound + vibration on order handoff';

  @override
  String get tooltipBack => 'Back';

  @override
  String get tooltipSwitchCamera => 'Switch camera';

  @override
  String get tooltipEnterTracking => 'Enter tracking code';

  @override
  String get tooltipZoomIn => 'Zoom in';

  @override
  String get tooltipZoomOut => 'Zoom out';

  @override
  String get captureResolution => 'Resolution';

  @override
  String get stopRecording => 'Stop recording';

  @override
  String get videoTypeSettings => 'Video type settings';

  @override
  String get uploadQueueTitle => 'Upload queue';

  @override
  String get quotaExhaustedNote =>
      'Monthly allowance used up. Recording still works, but these clips are ON THIS PHONE and not protected yet — they upload by themselves once the allowance is raised.';

  @override
  String get queueEmpty => 'No videos in the queue yet';

  @override
  String get queueAutoUploadNote =>
      'Upload happens automatically when you\'re online';

  @override
  String get waitingUpload => 'Waiting to upload';

  @override
  String get uploaded => 'Uploaded';

  @override
  String get waitingQuota => 'Waiting for allowance · still on device';

  @override
  String get pausedUpload => 'Paused';

  @override
  String get queuePauseAction => 'Pause';

  @override
  String get queueResumeAction => 'Resume';

  @override
  String get queueDeleteAction => 'Remove';

  @override
  String get queueDeleteConfirmTitle => 'Remove from queue?';

  @override
  String get queueDeleteConfirmBody =>
      'This clip hasn\'t been uploaded yet — removing it deletes it from your device permanently.';

  @override
  String get toastQueueItemDeleted => 'Removed from the upload queue';

  @override
  String get manualTrackingTitle => 'Enter tracking code';

  @override
  String get manualTrackingNote => 'Type it in or scan the code again';

  @override
  String get commonDone => 'Done';

  @override
  String get startRecording => 'Start recording';

  @override
  String get returnCodeMismatch => 'Return code doesn\'t match';

  @override
  String get enterCodeManually => 'Enter code manually';

  @override
  String get videoTypeLabel => 'Video type';

  @override
  String get videoTypeSelectNote =>
      'Pick the right type — add/edit/delete in Shop details';

  @override
  String get videoTypeSheetTitle => 'Choose a video type';

  @override
  String get videoTypeGroupDefault => 'Default types (required)';

  @override
  String get videoTypeGroupCustom => 'Shop\'s custom types';

  @override
  String get manageVideoTypesNote => 'Manage video types — open Shop details';

  @override
  String queueFilterAll(int count) {
    return 'All ($count)';
  }

  @override
  String queueFilterUploading(int count) {
    return 'Uploading ($count)';
  }

  @override
  String queueFilterErrored(int count) {
    return 'Errors ($count)';
  }

  @override
  String queueFilterQuotaWait(int count) {
    return 'Waiting for allowance ($count)';
  }

  @override
  String queueSummary(int pending, int uploading, int errored) {
    return '$pending videos waiting · $uploading uploading · $errored failed';
  }

  @override
  String uploadingProgress(int percent) {
    return 'Uploading $percent%';
  }

  @override
  String errorRetryCount(int count) {
    return 'Error · Retry ($count)';
  }

  @override
  String returnCodeMismatchBody(String returnCode, String shopName) {
    return '$returnCode doesn\'t match any order in $shopName. Re-check the code, enter it manually, or confirm creating a new order.';
  }

  @override
  String get onboardingSubtitle =>
      'Record packing-evidence videos for e-commerce sellers';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authChooseMethod => 'Choose a sign-in method';

  @override
  String get authEmailRequired => 'Please enter your email';

  @override
  String get authEmailInvalid => 'Invalid email';

  @override
  String get authPassword => 'Password';

  @override
  String get authPasswordRequired => 'Please enter your password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get registerWithGoogle => 'Sign up with Google';

  @override
  String get registerWithApple => 'Sign up with Apple';

  @override
  String get authSignInGoogle => 'Sign in with Google';

  @override
  String get authSignInApple => 'Sign in with Apple';

  @override
  String get authNoAccountPrompt => 'Don\'t have an account? ';

  @override
  String get authRegister => 'Register';

  @override
  String get authOr => 'or';

  @override
  String get registerTitle => 'Create a new account';

  @override
  String get registerConfirmPassword => 'Re-enter password';

  @override
  String get registerAgreePolicy => 'I agree to the policy ';

  @override
  String get registerViewPolicy => 'View policy';

  @override
  String get registerCreateAccount => 'Create account';

  @override
  String get registerSameEmailNote =>
      'The same email will automatically link to one account';

  @override
  String get registerHaveAccountPrompt => 'Already have an account? ';

  @override
  String get registerSuccessTitle => 'Account created';

  @override
  String registerSuccessVerifyMessage(String email) {
    return 'We sent a verification email to $email. Check your inbox (including spam), then sign in.';
  }

  @override
  String get registerSuccessMessage =>
      'Your account is ready. Sign in with the email and password you just registered.';

  @override
  String get registerSuccessAction => 'Sign in';

  @override
  String get loginNotVerifiedTitle => 'Email not verified';

  @override
  String loginNotVerifiedMessage(String email) {
    return 'Open the verification email sent to $email (check spam too), follow the link, then sign in again.';
  }

  @override
  String get loginResendVerification => 'Resend email';

  @override
  String get loginVerificationResent => 'Verification email sent again';

  @override
  String get forgotPasswordTitle => 'Forgot password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email to receive a password reset link';

  @override
  String get forgotPasswordSubmit => 'Send reset link';

  @override
  String get forgotPasswordSent => 'Sent — check your inbox (including spam)';

  @override
  String get forgotPasswordRememberPrompt => 'Remember your password? ';

  @override
  String get shopYourShops => 'Your shops';

  @override
  String get shopTapToClockIn => 'Tap a shop to clock in · manage right here';

  @override
  String get shopLastOpenedNote =>
      'The most recently opened shop will open directly next time';

  @override
  String get shopManageStore => 'Manage store';

  @override
  String get shopManageVisibilityNote =>
      'Only visible to the account owner / shop manager';

  @override
  String get shopEmpty => 'No shops yet';

  @override
  String get shopEmptyBody =>
      'Your account doesn\'t belong to any shop yet. Create a new shop to get started, or wait for an invitation from a shop owner.';

  @override
  String get shopCreateNew => 'Create new shop (name + platform)';

  @override
  String get shopInvitesHere => 'Shop invitations will appear here';

  @override
  String get shopCreateTitle => 'Create shop';

  @override
  String get shopNameLabel => 'Shop name';

  @override
  String get shopNameRequired => 'Please enter a shop name';

  @override
  String get shopPlatform => 'Marketplace';

  @override
  String get shopCreateOwnerNote =>
      'You\'ll be the shop owner — add members later in Manage store';

  @override
  String get shopMgmtVisibilityNote =>
      'Staff don\'t see this screen · shop managers only see shops they manage';

  @override
  String get shopAddNew => 'Add a new shop';

  @override
  String get sectionMembers => 'MEMBERS';

  @override
  String get sectionShopSettings => 'SHOP SETTINGS';

  @override
  String get sectionVideoTypes => 'VIDEO TYPES';

  @override
  String get videoTypesLockedNote =>
      '3 built-in types are locked — can\'t be edited/deleted';

  @override
  String get addMemberByContact => 'Add member by email/phone';

  @override
  String get recordResolution => 'Recording resolution';

  @override
  String get addVideoType => 'Add type (enter name)';

  @override
  String get createVideoTypeTitle => 'Create video type';

  @override
  String get videoTypeName => 'Video type name';

  @override
  String get videoTypeNameHint => 'e.g. Weighing';

  @override
  String get createVideoType => 'Create type';

  @override
  String get deleteVideoTypeBody =>
      'Can only be deleted while this type has no videos. If it has videos, the system blocks deletion to avoid disrupting evidence filters and stats.';

  @override
  String get deleteVideoTypeConfirm => 'Delete type';

  @override
  String get deleteVideoTypeNote =>
      '(Only deletable while the type has no videos)';

  @override
  String get addMemberTitle => 'Add member';

  @override
  String get addMemberBody =>
      'Enter the email of a registered ZenPack account. They get an invitation and must confirm it to join the shop.';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailRequired => 'Enter an email address.';

  @override
  String get emailInvalid => 'Enter one valid email address.';

  @override
  String get errorInviteAccountNotFound =>
      'This email has no ZenPack account yet. Ask them to sign up first, then invite again.';

  @override
  String get errorInviteAlreadyMember =>
      'They are already a member of this shop.';

  @override
  String get errorInviteMemberLimit =>
      'This plan\'s member limit is full. Pending invites count toward it — revoke one to free a slot.';

  @override
  String get errorInviteAlreadyOwner =>
      'That is the shop owner — no invite needed.';

  @override
  String get errorInviteInvalidRequest =>
      'That email isn\'t valid. Check it and send again.';

  @override
  String get addMemberSubmit => 'Add';

  @override
  String get memberOwnerLocked =>
      'The owner cannot be re-roled or removed here — ownership belongs to the shop, not to a membership row.';

  @override
  String get removeFromShop => 'Remove from shop';

  @override
  String get revokeInvite => 'Delete invitation';

  @override
  String get resolutionAppliesNote =>
      'Applies to the shop\'s newly recorded videos';

  @override
  String get resolutionDefaultOption => '720p (default)';

  @override
  String get ordersSearchHint => 'Enter tracking code';

  @override
  String get ordersEmpty => 'This shop has no orders yet';

  @override
  String recordAutoStopIn(String time) {
    return 'Auto-stops in $time';
  }

  @override
  String get ordersNotFound => 'No orders found';

  @override
  String get ordersNotFoundHint =>
      'Double-check the tracking code and try again';

  @override
  String ordersPageRange(int first, int last, int total) {
    return '$first–$last of $total orders';
  }

  @override
  String get ordersPagePrevious => 'Previous page';

  @override
  String get ordersPageNext => 'Next page';

  @override
  String ordersPageNumber(int page) {
    return 'Page $page';
  }

  @override
  String get filterStatusLabel => 'Status';

  @override
  String get filterStatusAll => 'All';

  @override
  String get filterStatusPending => 'Awaiting upload';

  @override
  String get filterStatusError => 'Upload errors';

  @override
  String get filterStatusDone => 'Fully uploaded';

  @override
  String get filterTimeLabel => 'Time';

  @override
  String get filterTimeAll => 'Any time';

  @override
  String get filterTimeToday => 'Today';

  @override
  String get filterTimeYesterday => 'Yesterday';

  @override
  String get filterTime7d => 'Last 7 days';

  @override
  String get filterTime30d => 'Last 30 days';

  @override
  String get filterTimePickDate => 'Pick a date…';

  @override
  String get filterTypeLabel => 'Video type';

  @override
  String get filterTypeAll => 'Video type';

  @override
  String deleteVideoTypeTitle(String typeName) {
    return 'Delete type \"$typeName\"?';
  }

  @override
  String memberCurrentRole(String role) {
    return 'Current role: $role';
  }

  @override
  String get stopCodeTitle => 'Stop-recording QR code';

  @override
  String get stopCodeInstructions =>
      'Print this and stick it at the packing table. Show it to the camera while recording to stop automatically.';

  @override
  String get scannedCodeNotFound => 'No order matches the scanned code';

  @override
  String get onboardingTaglineOne => 'Every parcel.';

  @override
  String get onboardingTaglineTwo => 'One proof.';

  @override
  String get onboardingTaglineThree => 'Protecting your revenue.';

  @override
  String get authEmailPlaceholder => 'Enter your email';

  @override
  String get authPasswordPlaceholder => 'Enter your password';

  @override
  String get registerCreateAccountSubtitle => 'Create a new account';

  @override
  String get registerFullName => 'Full name';

  @override
  String get registerFullNameRequired => 'Please enter your full name';

  @override
  String get registerAgreePrefix => 'I agree to the';

  @override
  String get registerTermsOfUse => 'Terms of Use';

  @override
  String get shopChooseTitle => 'Choose a shop';

  @override
  String get shopChooseSubtitle => 'Pick a shop to continue';

  @override
  String get shopManageTitle => 'Manage shops';

  @override
  String get shopManageOwnerOnly => 'Visible to shop owners and managers only';

  @override
  String get noShopTitle => 'No shops yet';

  @override
  String get noShopLineOne => 'Your account does not belong to a shop yet.';

  @override
  String get noShopLineTwo => 'Create a shop to get started,';

  @override
  String get noShopLineThree => 'or wait for an invite from a shop owner.';

  @override
  String get noShopCreateCta => 'Create a shop (name + marketplace)';

  @override
  String get noShopInviteHint => 'Shop invites will appear here';

  @override
  String get createShopTitle => 'Create shop';

  @override
  String get createShopNameLabel => 'Shop name';

  @override
  String get createShopNameHint => 'e.g. Shop ABC';

  @override
  String get createShopPlatformLabel => 'Marketplace';

  @override
  String get createShopOwnerNote =>
      'You will be the shop owner — add members later under Manage shops';

  @override
  String get createShopSubmit => 'Create shop';

  @override
  String get shopManageDescription =>
      'View and manage the shops you administer.';

  @override
  String get shopManageAddCta => 'Add a shop';

  @override
  String get shopManageStaffNote =>
      'Staff cannot see this screen — owners and shop managers only.';

  @override
  String get shopDetailTitle => 'Shop detail';

  @override
  String get shopDetailResolution => 'Recording resolution';

  @override
  String get shopDetailClipDuration => 'Max length/video';

  @override
  String clipDurationValue(String minutes) {
    return '$minutes min';
  }

  @override
  String clipRecommendedHint(
    String minutes,
    String platform,
    String megabytes,
    String resolution,
  ) {
    return 'Recommended $minutes min — for $platform ($megabytes MB/video) + $resolution';
  }

  @override
  String clipRecommendedHintUnverified(String minutes, String platform) {
    return 'Recommended $minutes min — $platform limits unconfirmed, using the safest known values';
  }

  @override
  String clipOverRecommendedWarning(
    String minutes,
    String platform,
    String chosen,
    String megabytes,
  ) {
    return 'Over the $minutes-min recommendation for $platform — a $chosen-min video is ~$megabytes MB, so it has to be sent as a dossier link instead of attached to the complaint form.';
  }

  @override
  String get clipDurationTitle => 'Max length per video';

  @override
  String get clipDurationSubtitle => 'Auto-closes at this length';

  @override
  String clipDurationPlanCap(String minutes) {
    return 'Your plan allows up to $minutes min';
  }

  @override
  String clipDurationChanged(String minutes) {
    return 'Max length/video: $minutes min';
  }

  @override
  String get shopDetailImageSize => 'Image size';

  @override
  String get shopDetailVideoSize => 'Video size';

  @override
  String get shopDetailUploadSize => 'Max size/file';

  @override
  String uploadSizeValue(String megabytes) {
    return '$megabytes MB';
  }

  @override
  String uploadRecommendedHint(String megabytes, String platform) {
    return 'Recommended $megabytes MB — $platform\'s attachment limit';
  }

  @override
  String uploadOverRecommendedWarning(
    String megabytes,
    String platform,
    String chosen,
  ) {
    return 'Over the $megabytes MB recommendation for $platform — a file up to $chosen MB is still stored in full, but has to be sent as a dossier link instead of attached to the complaint form.';
  }

  @override
  String get uploadSizeValueUnlimited => 'No limit';

  @override
  String get uploadSizeTitle => 'Max size per file';

  @override
  String uploadSizeSubtitle(String megabytes, String platform) {
    return 'Files over the cap are not attached; $megabytes MB still attaches directly to $platform';
  }

  @override
  String uploadSizeOptionRecommended(String megabytes) {
    return '$megabytes MB (recommended)';
  }

  @override
  String uploadSizeChanged(String megabytes) {
    return 'Size per file: $megabytes';
  }

  @override
  String avatarTooLarge(String megabytes, String limit) {
    return 'Name and phone saved. The $megabytes MB profile photo is over the $limit MB cap, so it didn\'t reach the server — pick a smaller image.';
  }

  @override
  String avatarUploadFailed(String reason) {
    return 'Name and phone saved. The profile photo didn\'t reach the server: $reason';
  }

  @override
  String nearClipLimitWarning(String minutes) {
    return 'Nearing the $minutes-min cap — the video will close itself';
  }

  @override
  String get shopDetailAddType => 'Add a type (enter a name)';

  @override
  String get inviteMemberTitle => 'Invite a member';

  @override
  String get inviteRoleFixedNote =>
      'They join as a staff member: record videos and review their own.';

  @override
  String get inviteMemberHint => '(no account yet → send an invite)';

  @override
  String get videoTypeIcon => 'Icon';

  @override
  String get videoTypeColor => 'Colour';

  @override
  String get createVideoTypeSubmit => 'Create type';

  @override
  String get deleteVideoTypeSafeNote => 'No evidence is lost';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String orderErrorCount(int count) {
    return '$count failed';
  }

  @override
  String get videoDetailSheetTitle => 'Video detail';

  @override
  String get tooltipStopRecording => 'Stop recording';

  @override
  String get dossierLinkTitle => 'Dispute dossier link';

  @override
  String get accountEndQr => 'Stop-recording code';

  @override
  String get accountEndQrTitle => 'Stop-recording code';

  @override
  String get accountEndQrShare => 'Share code';

  @override
  String get accountEndQrSave => 'Save to photo library';

  @override
  String get recordInterruptedTitle => 'Recording paused';

  @override
  String get recordInterruptedBody =>
      'Recording paused because something interrupted it. Continue recording?';

  @override
  String get recordInterruptedResume => 'Continue';

  @override
  String get recordInterruptedFinish => 'Finish';

  @override
  String get commonApply => 'Apply';

  @override
  String get unitMinutes => 'min';

  @override
  String get clipDurationCustomLabel =>
      'Or enter the number of minutes you want';

  @override
  String get supportOpenFailed => 'Couldn’t open — check the app is installed';

  @override
  String get feedbackThanksTitle => 'Thank you!';

  @override
  String get feedbackThanksBody => 'Your feedback helps make ZenPack better.';

  @override
  String get feedbackTitle => 'What would you like to share with us?';

  @override
  String get feedbackHint => 'Type your feedback...';

  @override
  String get feedbackSend => 'Send feedback';

  @override
  String get feedbackThanks => 'Thanks for your feedback';

  @override
  String get accountSectionAbout => 'ABOUT';

  @override
  String get accountFeedback => 'Send us feedback';

  @override
  String get accountFeedbackNote =>
      'Share your thoughts to make ZenPack better';

  @override
  String get accountRateApp => 'Rate the app';

  @override
  String get accountRateAppNote => 'Support ZenPack development';

  @override
  String get supportFacebook => 'Message on Facebook';

  @override
  String get supportZalo => 'Message on Zalo';

  @override
  String get supportCall => 'Call support';

  @override
  String sheetCustomMin(String min, String unit) {
    return 'Enter $min $unit or more';
  }

  @override
  String sheetCustomRange(String min, String max, String unit) {
    return 'Enter between $min and $max $unit';
  }

  @override
  String get accountEndQrNote =>
      'Print this and stick it on the packing table. Scanning it while recording closes the clip. The same code works on every device.';

  @override
  String get languageChangeScopeNote =>
      'Every label, notification and dossier\nswitches to the language you pick.';

  @override
  String get manualEntryEmptyError => 'Enter a tracking code before recording';

  @override
  String get appUpdateTitle => 'A new version is available';

  @override
  String get appUpdateMessage =>
      'Update ZenPack for the latest fixes and features.';

  @override
  String get appUpdateNow => 'Update';

  @override
  String get appUpdateLater => 'Later';

  @override
  String get quotaVideosThisMonth => 'Videos this month';

  @override
  String get quotaSubtitleVideos =>
      'Track how many videos you recorded this month';

  @override
  String get quotaBlockedTitle => 'Video allowance exhausted';

  @override
  String get quotaBlockedNote =>
      'Recording still works, but clips cannot upload yet — they are sitting on this phone, unprotected. They upload by themselves once the allowance is raised.';

  @override
  String get quotaBlockedOwnerNote =>
      'Ask the account owner to raise the allowance.';

  @override
  String get quotaTopupCredits => 'Top-up credits';

  @override
  String get quotaOverCap => 'Over plan allowance';

  @override
  String quotaBlockAt(int n) {
    return 'New recordings blocked at $n videos';
  }

  @override
  String get quotaResetMonthly =>
      'Resets at the start of next month; nothing carries over';

  @override
  String get storageOwnTitle => 'Your own storage';

  @override
  String storageOwnPending(int count) {
    return '$count videos waiting to be pushed to your storage';
  }

  @override
  String storageOwnProblem(int count) {
    return '$count videos in your storage have problems';
  }

  @override
  String get quotaExhaustedWarn =>
      'Don\'t uninstall the app or clear its data until they have uploaded.';

  @override
  String quotaStrandedTitle(int count) {
    return '$count videos waiting on this phone';
  }

  @override
  String get quotaStrandedNote =>
      'These videos exist only on this phone. Losing it, uninstalling the app or clearing its data loses them.';

  @override
  String get storageTitle => 'Video storage';

  @override
  String get storageSystemName => 'System storage';

  @override
  String get storageS3Name => 'Your own storage (S3)';

  @override
  String get storageDriveName => 'Your Google Drive';

  @override
  String get storageSystemDesc =>
      'The default; nothing to configure. It is the only place where every evidence commitment holds.';

  @override
  String get storageOwnDesc =>
      'New videos go straight to your storage. Older ones stay where they are until their retention ends.';

  @override
  String get storageNoPresign =>
      'This storage cannot sign download links, so videos must be relayed through the server — whoever opens your link will find it slower.';

  @override
  String get storageNoObjectLock =>
      'This storage has no object lock. You cannot promise a marketplace that the evidence is undeletable.';

  @override
  String get storageNotInPlan =>
      'Your plan does not include custom storage yet. Upgrade on the web to use it.';

  @override
  String get storageHealthTitle => 'Storage health';

  @override
  String get storageHealthTotal => 'Total videos';

  @override
  String get storageHealthIntact => 'Intact';

  @override
  String get storageHealthUnreachable => 'Unreachable';

  @override
  String get storageHealthMismatched => 'Mismatched against the seal';

  @override
  String get storageHealthPendingRelay => 'Waiting in the relay area';

  @override
  String get storageProblemsNote =>
      'Some videos have problems in your storage. Check the access permissions on the provider side.';

  @override
  String get storageTest => 'Re-test the connection';

  @override
  String get storageDisconnect => 'Stop using custom storage';

  @override
  String get storageDisconnectConfirm =>
      'Videos recorded from now on go to system storage. Older ones stay in your storage and the system loses its route to them.';

  @override
  String get storageConnectS3 => 'Connect S3 storage';

  @override
  String get storageConnectDrive => 'Connect Google Drive';

  @override
  String get storageConnectHint =>
      'Grant read/write/delete on the prefix below only — no permission on the whole bucket is needed.';

  @override
  String get storageConnectSubmit => 'Test and save';

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
      'Sub-folder inside the bucket. Leave the default if unsure.';

  @override
  String get storageConnected => 'Custom storage connected.';

  @override
  String get storageDisconnected => 'Custom storage disconnected.';

  @override
  String get storageTestOk => 'Connection is healthy.';

  @override
  String get storageOwnerOnly => 'Only the shop owner can change storage.';

  @override
  String get dangerZone => 'Danger zone';

  @override
  String get shopDelete => 'Delete shop';

  @override
  String get shopDeleteDesc =>
      'Permanently deletes orders, evidence, stored files and members. This cannot be undone.';

  @override
  String get shopDeleteConfirmTitle => 'Delete this shop?';

  @override
  String shopDeleteConfirmBody(int orders, int videos, int members) {
    return '$orders orders · $videos videos · $members members will be permanently deleted.';
  }

  @override
  String shopDeleteOpenDossiers(int n) {
    return '$n claim dossiers are still open. Links already sent to marketplaces die the moment you delete.';
  }

  @override
  String get shopDeleteForce => 'Delete anyway';

  @override
  String get shopDeleteFailed => 'Couldn\'t delete the shop.';

  @override
  String get claimsCreatedLocalOnly =>
      'Dossier saved on this phone. It could not be uploaded, so there is no share link yet — reopen it when you are back online.';

  @override
  String get claimsLinkCopied =>
      'Dossier link copied. Paste it into the marketplace claim channel.';

  @override
  String get shopRenameTitle => 'Rename shop';

  @override
  String get shopRenameHint => 'Shop name';

  @override
  String get shopRenamed => 'Shop renamed';

  @override
  String get commonSave => 'Save';

  @override
  String get inviteJoinRow => 'I have an invite';

  @override
  String inviteJoinedShop(String shop) {
    return 'Joined $shop';
  }

  @override
  String inviteAlreadyJoined(String shop) {
    return 'You are already in $shop';
  }

  @override
  String get inviteBadLink =>
      'That link is not valid. Paste the whole link from the email.';

  @override
  String get inviteNotFound => 'The invite does not exist or was revoked';

  @override
  String get inviteTaken => 'Someone else already accepted this invite';

  @override
  String get inviteExpired =>
      'The invite has expired. Ask the shop owner to resend it.';

  @override
  String get inviteQrRow => 'QR code';

  @override
  String get inviteScanTitle => 'Scan invite code';

  @override
  String get inviteScanDetail =>
      'Ask the shop owner to show the invite QR code, then scan it here.';

  @override
  String get commonShare => 'Share';

  @override
  String get inviteQrSaved => 'QR code saved to your gallery';

  @override
  String get inviteQrSaveFailed => 'Could not save the QR code';
}

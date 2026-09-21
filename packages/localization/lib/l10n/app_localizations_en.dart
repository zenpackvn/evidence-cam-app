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
      'Some dossiers have not been uploaded yet, so they exist only on this device.';

  @override
  String get claimsOfflineNote =>
      'Cannot reach the server, so this is the copy stored on this device. Reopen when online to see everything.';

  @override
  String get claimsEmpty =>
      'No dossiers yet. Open the Orders tab, tap the plus button and pick the evidence to build one.';

  @override
  String claimsSummary(int orders, int evidence) {
    return '$orders orders · $evidence evidence';
  }

  @override
  String claimsEvidenceOnly(int evidence) {
    return '$evidence items';
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
  String get claimsDeleteConfirmLink =>
      'Delete this dossier? Its public link dies immediately — anyone you already sent it to gets an empty page. The evidence on the orders themselves is untouched.';

  @override
  String get claimsRevokeFailed =>
      'Could not revoke the link, so the dossier is left as is. The link is still open — try again on a better connection, or ask the shop owner to revoke it.';

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
  String get claimsCreateNameHint => 'e.g. Return claim 12/08';

  @override
  String get claimsCreateNameLabel => 'Dossier name';

  @override
  String get claimInfoTitle => 'Dossier details';

  @override
  String get claimTrackingLabel => 'Tracking code';

  @override
  String get claimShopLabel => 'Shop';

  @override
  String get claimChannelLabel => 'Channel';

  @override
  String get claimOrderCreatedAt => 'Order date';

  @override
  String get claimEvidenceLabel => 'Evidence';

  @override
  String claimEvidenceCount(int videos, int photos) {
    return '$videos videos · $photos photos';
  }

  @override
  String get claimCreatedAtLabel => 'Dossier created';

  @override
  String get claimCopyLink => 'Copy link';

  @override
  String get claimsRevokeNoLink =>
      'This dossier is not on the server yet, so there is no link to revoke.';

  @override
  String get claimPageFailed =>
      'Could not open the dossier page. Check your connection and try again.';

  @override
  String get claimLinkLabel => 'Dossier link';

  @override
  String get claimLinkHint =>
      'Anyone with the link can view it, no sign-in needed. It stays live until you revoke it.';

  @override
  String get claimRevokedBadge => 'Revoked';

  @override
  String get claimRevokedHint =>
      'The link is dead. The data is untouched — create a new dossier to share again.';

  @override
  String get claimRevoke => 'Revoke';

  @override
  String get claimUntitled => 'Untitled dossier';

  @override
  String get claimRevokeConfirmTitle => 'Revoke this dossier?';

  @override
  String get claimRevokeConfirmBody =>
      'The link dies immediately for anyone holding it, including the marketplace. The data and per-order links are unaffected.';

  @override
  String get claimRevoked => 'Dossier revoked. The link no longer opens.';

  @override
  String get claimRevokeFailed =>
      'Could not revoke. Try again when you are online.';

  @override
  String get claimNotUploaded =>
      'This dossier has not been uploaded yet, so it has no link. Reopen it when you are online.';

  @override
  String get claimDetailLoadFailed =>
      'Could not load the dossier. Check your connection and reopen it.';

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
  String get claimsItemAdded => 'Added to the dossier';

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
  String memberInvitePending(String role) {
    return '$role · awaiting confirmation';
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
  String get planPro => 'Pro';

  @override
  String get planEnterprise => 'Enterprise';

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
  String get uploadStatusError =>
      'Upload unfinished — the clip is still on the device that recorded it';

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
  String get accountPlanQuota => 'Plan & storage';

  @override
  String get accountChangePlan => 'Change plan';

  @override
  String get accountSectionApp => 'PLAN & APP';

  @override
  String get avatarCropTitle => 'Adjust photo';

  @override
  String get avatarCropHint =>
      'Drag and pinch to choose the part you want. Only what is inside the circle is saved.';

  @override
  String get avatarCropConfirm => 'Use this photo';

  @override
  String get avatarCropFailed =>
      'Could not process the photo. Pick another one.';

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
  String get phoneInvalid => 'Phone number must be 8-15 digits.';

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
  String get storageFieldEndpointHint =>
      'Must start with https:// and be the provider public domain — plain http would leak your keys in transit.';

  @override
  String get storageProbeStepPut => 'Write a file';

  @override
  String get storageProbeStepHead => 'Read file info';

  @override
  String get storageProbeStepGet => 'Download the file';

  @override
  String get storageProbeStepDelete => 'Delete the file';

  @override
  String storageErrorCode(String code) {
    return 'Error code: $code';
  }

  @override
  String get detailStorage => 'Storage';

  @override
  String get storageNameCloud => 'ZenPack Cloud';

  @override
  String get storageNameDrive => 'Google Drive';

  @override
  String get storageNameS3 => 'Your own cloud storage (S3-compatible)';

  @override
  String get storageNameRelayPending => 'Moving to your own storage';

  @override
  String get storageNameRelayFailed => 'Could not move to your own storage';

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
      'The stored copy has no timestamp burned in yet, so the share link and download wait for it. Usually a few seconds.';

  @override
  String get playLocalCopyNote =>
      'Temporary copy on this device — no timestamp on the frames yet';

  @override
  String get sealNone => 'Recorded before sealing existed';

  @override
  String get sealFailed =>
      'No timestamp stamped yet · the video still plays and downloads';

  @override
  String get sealMismatch => 'Fingerprint mismatch — re-record this clip';

  @override
  String get sealLate => 'Late seal — the video is intact; the fault was ours';

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
  String get detailTrimVideo => 'Trim a short clip to send';

  @override
  String get detailTrimNote =>
      'The full clip stays untouched · the trimmed one keeps its timestamp';

  @override
  String get trimSave => 'Save';

  @override
  String get trimEstimatedSize => 'About';

  @override
  String get trimFailed =>
      'Could not trim the video. The full clip is still there.';

  @override
  String get trimPreparing => 'Downloading the full clip…';

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
  String deleteVideoInDossier(String dossier) {
    return 'This evidence is in claim dossier $dossier — remove it from the dossier first, then delete.';
  }

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
  String get scanPickImage => 'Pick a photo';

  @override
  String get scanNoCodeInImage => 'No tracking code in this photo';

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
  String get queueUploading => 'Uploading';

  @override
  String get queueQuotaShort => 'Waiting on quota';

  @override
  String get queueUploadFailed => 'Upload unfinished';

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
  String get queueClearAction => 'Clear';

  @override
  String get queueClearConfirmTitle => 'Clear the whole queue?';

  @override
  String get queueClearConfirmBody =>
      'Clips that have not uploaded live only on this phone. Clearing removes them for good.';

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
  String get filterTypeAll => 'All';

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
  String get registerFullNamePlaceholder => 'e.g. Jane Doe';

  @override
  String get registerFullNameTooShort =>
      'Full name needs at least 2 characters.';

  @override
  String get phonePlaceholder => 'e.g. 0912 345 678';

  @override
  String get registerConfirmPasswordPlaceholder =>
      'Type the same password again';

  @override
  String get termsLoadFailed =>
      'Could not open the terms page. Check your connection and try again.';

  @override
  String get termsOpenInBrowser => 'Open in browser';

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
  String get shopDetailAddType => 'Add a video type';

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
  String get quotaUpgrade => 'Upgrade plan';

  @override
  String get quotaBlockedTitle => 'Video allowance exhausted';

  @override
  String get quotaBlockedNote =>
      'Recording still works, but clips cannot upload yet — they are sitting on this phone, unprotected. They upload by themselves once the allowance is raised.';

  @override
  String get quotaBlockedOwnerNote =>
      'This shop’s allowance is set by the account owner — ask them to raise it. A plan you buy applies to your own account only.';

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
  String get storageSave => 'Save storage choice';

  @override
  String get storageSystemName => 'System storage';

  @override
  String get storageS3Name => 'Your own storage (S3)';

  @override
  String get storageDriveName => 'Your Google Drive';

  @override
  String get storageSystemDesc =>
      'Videos are kept for 30 days. Videos attached to a claim dossier are kept for 15 days longer.';

  @override
  String get storageOwnDesc =>
      'New videos go straight to your storage. Older ones stay where they are until their retention ends.';

  @override
  String get storageNoPresign =>
      'This storage cannot sign download links, so videos must be relayed through the server — whoever opens your link will find it slower.';

  @override
  String get storageErrNoRead =>
      'This key can write but cannot read back. The server uploads the video, then reads it back to verify — and is denied, so it will not treat the file as safely stored.\n\nGrant s3:GetObject and s3:ListBucket to this key (or open them in the bucket policy if the bucket belongs to another account).';

  @override
  String get storageErrNoWrite =>
      'This key cannot write to the bucket. Grant s3:PutObject for the bucket and prefix you configured.';

  @override
  String get storageErrSizeMismatch =>
      'The video was written but read back short, so the server kept the temporary copy and will retry. Usually a bucket rule or a concurrent overwrite.';

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
  String get storageInUse => 'In use';

  @override
  String storageLastCheckAt(String time) {
    return 'Last audit: $time';
  }

  @override
  String get storageNeverChecked => 'Never audited yet.';

  @override
  String storageDriveCurrentAccount(String email) {
    return 'Currently connected: $email. Sign in with that address to keep the same Drive, or pick another to switch.';
  }

  @override
  String get storageDriveAccount => 'Drive account';

  @override
  String get storageDriveSwitchAccount => 'Switch account';

  @override
  String get storageDriveLogout => 'Sign out of Drive';

  @override
  String get storageDriveLoggedOut => 'Signed out of Drive.';

  @override
  String get storageDriveLogoutConfirm =>
      'The Google account will be removed from this shop and new videos go to system storage. Older videos stay in your Drive, but the system loses its path to them. Reconnecting means granting access again.';

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
  String get storageDriveFailed =>
      'Could not connect Google Drive: the server\'s connection to Google is not configured yet. That is system-side setup, not a permission the app can ask you for — tell your technical contact.';

  @override
  String get storageConnected => 'Custom storage connected.';

  @override
  String get storageDisconnected => 'Custom storage disconnected.';

  @override
  String get storageSwitchedToSystem =>
      'Saved. New videos go to Cloud Zenpack; your own-storage account is kept.';

  @override
  String get storageResumed => 'Saved. Using your connected storage again.';

  @override
  String get storageTestOk => 'Connection is healthy.';

  @override
  String get storageServerOutdated =>
      'The server does not support switching storage yet. Your videos stay where they are — tell your admin to update the server.';

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
  String get inviteQrTitle => 'Shop invite code';

  @override
  String get inviteQrNote =>
      'Show this screen to the person you want to invite. The code is single-use — it changes once someone joins.';

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

  @override
  String get voiceRecordingStarted => 'Recording started';

  @override
  String get voiceRecordingStopped => 'Recording stopped';

  @override
  String get voiceWrongCode => 'Wrong code';

  @override
  String get voiceCapSoon => 'The clip will close soon';

  @override
  String voiceCapNear(int minutes) {
    return 'Approaching the $minutes-minute limit, the clip will close itself';
  }

  @override
  String get voiceInterrupted => 'Recording was interrupted';

  @override
  String get videoTypePacking => 'Packing';

  @override
  String get videoTypeCarrier => 'Carrier handover';

  @override
  String get videoTypeReturn => 'Return';

  @override
  String get storageIntro =>
      'Where the shop’s videos live. Wherever they sit, the seal record stays with the system — changing storage never weakens the evidence.';

  @override
  String get storageS3Title => 'Your own cloud storage (S3-compatible)';

  @override
  String get storageS3Desc =>
      'AWS S3, Cloudflare R2, MinIO, Wasabi… The videos sit in your bucket, and their durability is on you.';

  @override
  String get storageDriveTitle => 'Google Drive';

  @override
  String get storageDriveDesc =>
      'Connect with one permission grant, no keys to paste. A free account only has 15 GB shared with Gmail.';

  @override
  String get storageNeedProPlan =>
      'Connecting your own storage needs the Professional plan or higher.';

  @override
  String get attachCodeToOrder => 'Scan another code into this order';

  @override
  String get attachedCodes => 'Attached codes';

  @override
  String get codeAttached => 'Code attached to this order';

  @override
  String get codeBelongsToAnotherOrder =>
      'This code already belongs to another order — cannot merge.';

  @override
  String get codeAttachFailed => 'Could not attach the code. Try again.';

  @override
  String get storageEditCta => 'Change settings';

  @override
  String get storageValidateOk =>
      'This account can connect. Press Save to use this storage.';

  @override
  String get storageValidateFailed => 'This account cannot connect.';

  @override
  String get storageTestOnlyCta => 'Test';

  @override
  String shopOwnerLine(String name) {
    return 'Shop owner: $name';
  }

  @override
  String get storageConnectNote =>
      'We write–read–delete a tiny test object before saving. Note: periodic audits download ~1% of videos weekly to verify them — some providers charge egress. If your storage loses data, the video cannot be recovered from anywhere.';

  @override
  String get storageNotConfigured =>
      'This shop has no storage of its own connected, so there is nothing to switch on or off. Reload this screen and try again.';

  @override
  String get storageDriveAccountUnknown => 'Google account not read yet';

  @override
  String get storageSystemSaveNote =>
      'Save removes your own storage: new videos go to system storage.';

  @override
  String get storageDriveSaveNote =>
      'No account connected yet. Tap this card to pick a Google account.';

  @override
  String get storageDriveNoConsent =>
      'Google did not grant long-lived access this time. Open your Google Account → Third-party apps, remove Zenpack, then connect again.';

  @override
  String get storageDriveRejected =>
      'Google refused the grant. Try again; if it keeps failing, tell your admin.';

  @override
  String get authSignInPhone => 'Sign in with phone number';

  @override
  String get phoneLoginTitle => 'Sign in with phone number';

  @override
  String get phoneLoginSubtitle =>
      'Enter your phone number and we will send a 6-digit code.';

  @override
  String get phoneLoginNumberLabel => 'Phone number';

  @override
  String get phoneLoginNumberHint => '09xx xxx xxx';

  @override
  String get phoneLoginInvalid => 'Invalid phone number';

  @override
  String get phoneLoginViaZalo => 'Send code via Zalo';

  @override
  String get phoneLoginViaSms => 'Send code via SMS';

  @override
  String get otpTitle => 'Enter the code';

  @override
  String otpSentTo(String phone) {
    return 'We sent a 6-digit code to $phone.';
  }

  @override
  String get otpLabel => 'Verification code';

  @override
  String get otpConfirm => 'Confirm';

  @override
  String get otpResend => 'Resend code';

  @override
  String otpResendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get otpChangePhone => 'Use another number';

  @override
  String get otpWrong => 'Wrong code. Check the message again.';

  @override
  String get otpExpired => 'The code expired. Request a new one.';

  @override
  String get otpUsedUp => 'That code can no longer be used. Request a new one.';

  @override
  String get otpTooSoon => 'Just sent. Wait a moment before trying again.';

  @override
  String get otpRateLimited => 'Too many requests. Try again in a few minutes.';

  @override
  String get otpSendFailed => 'Could not send the code. Try the other channel.';

  @override
  String get otpNotConfigured =>
      'Code delivery is not available right now. Please use another method.';

  @override
  String otpFromOa(String oa) {
    return 'The message comes from the Zalo Official Account $oa — look for that name.';
  }

  @override
  String get hdDaHieu => 'Got it';

  @override
  String get hdDong => 'Close tips';

  @override
  String get hdXemLai => 'Show tips again';

  @override
  String get hdDaMoLai => 'Tips will show again as you visit each screen.';

  @override
  String get hdHomeTitle => 'Overview screen';

  @override
  String get hdHome1 =>
      'A quick read on orders, storage used and what needs attention today.';

  @override
  String get hdHome2 =>
      'Each status card jumps straight to the orders in that state.';

  @override
  String get hdHome3 => 'Reopen these tips any time from the support button.';

  @override
  String get hdRecordTitle => 'Recording screen';

  @override
  String get hdRecord1 =>
      'Pick the goods camera and the receipt camera in Settings before recording.';

  @override
  String get hdRecord2 =>
      'Scan the tracking code, then record — the video attaches to that order.';

  @override
  String get hdRecord3 =>
      'IP cameras are for filming goods only, never for the receipt camera.';

  @override
  String get hdOrderTitle => 'Order detail';

  @override
  String get hdOrder1 =>
      'Every clip and photo for one tracking code, newest first.';

  @override
  String get hdOrder2 =>
      'A sealed clip is the final version — usable in a marketplace claim.';

  @override
  String get hdOrder3 =>
      'Deleting here only hides it from your list; the original is kept.';

  @override
  String get hdClaimsTitle => 'Claim dossiers';

  @override
  String get hdClaims1 =>
      'Bundle evidence from several orders into one dossier for the marketplace.';

  @override
  String get hdClaims2 =>
      'Each dossier gets its own link; the recipient needs no account.';

  @override
  String get hdClaims3 =>
      'Videos in a dossier are kept 15 extra days after it closes.';

  @override
  String get hdClaimDetailTitle => 'Dossier detail';

  @override
  String get hdClaimDetail1 =>
      'Add or remove orders before you send the dossier.';

  @override
  String get hdClaimDetail2 =>
      'Copy the dossier link to paste into the marketplace claim.';

  @override
  String get hdClaimDetail3 =>
      'Close it when done — the videos still last another 15 days.';

  @override
  String get hdShopsTitle => 'Shops';

  @override
  String get hdShops1 => 'Each shop has its own storage, plan and staff.';

  @override
  String get hdShops2 =>
      'Invite staff into a shop and set what each person may do.';

  @override
  String get hdShops3 =>
      'Switch the shop you are working in at the top of the page.';

  @override
  String get hdQuotaTitle => 'Plan';

  @override
  String get hdQuota1 =>
      'The plan sets your storage size and how long videos are kept.';

  @override
  String get hdQuota2 => 'Storage is counted per shop, not per user.';

  @override
  String get hdQuota3 =>
      'You are warned before storage fills up — nothing is deleted silently.';

  @override
  String get hdQueueTitle => 'Upload queue';

  @override
  String get hdQueue1 =>
      'Clips already recorded but not yet in storage wait here.';

  @override
  String get hdQueue2 =>
      'On a weak connection just leave them — the app retries when signal returns.';

  @override
  String get hdQueue3 =>
      'Do not uninstall while clips are waiting; they exist only on this phone.';

  @override
  String get gtBoQua => 'Skip';

  @override
  String get gtTiep => 'Next';

  @override
  String get gtBatDau => 'Start now';

  @override
  String get gt1Title => 'Film while you pack';

  @override
  String get gt1Body =>
      'One video per order: what went in, how it was packed, which label went on. Record and you are done.';

  @override
  String get gt2Title => 'Tied to the tracking code';

  @override
  String get gt2Body =>
      'Scan the label and the video attaches itself to that order. Later, one code brings up every clip for it.';

  @override
  String get gt3Title => 'Proof when a claim arrives';

  @override
  String get gt3Body =>
      'Bundle clips from several orders into one dossier and send the link to the marketplace. No account needed to view it.';

  @override
  String get deletePwTitle => 'Enter your password';

  @override
  String get deletePwBody =>
      'This cannot be undone, so please re-enter your password before the account is deleted.';

  @override
  String get deletePwOk => 'Confirm';

  @override
  String get hdNoShopTitle => 'Start with a shop';

  @override
  String get hdNoShop1 =>
      'Every video and piece of evidence belongs to a shop, so create one first.';

  @override
  String get hdNoShop2 =>
      'Then pick the marketplaces you sell on and invite your staff.';

  @override
  String get hdNoShop3 =>
      'If someone invited you, use “Join with an invite” instead of creating one.';

  @override
  String get cdNoShopTaoTitle => 'Create a shop first';

  @override
  String get cdNoShopTaoBody =>
      'Every video and piece of evidence belongs to a shop. Tap here to create one and pick your marketplaces.';

  @override
  String get cdNoShopMoiTitle => 'Invited? Start here';

  @override
  String get cdNoShopMoiBody =>
      'If an owner invited you, tap here and enter the invite code — no need to create a shop.';

  @override
  String get cdNoShopTkTitle => 'Your profile';

  @override
  String get cdNoShopTkBody =>
      'Name, language, sign-in methods and account deletion all live here.';

  @override
  String get cdTaoShopTenTitle => 'Name your shop';

  @override
  String get cdTaoShopTenBody =>
      'Only you and your staff see this name; it tells shops apart when you have several. You can change it later.';

  @override
  String get cdTaoShopNutTitle => 'Pick a marketplace, then create';

  @override
  String get cdTaoShopNutBody =>
      'Choose where you sell above, then tap here. Once the shop exists you can start recording.';

  @override
  String get cdHome1T => 'Find one order fast';

  @override
  String get cdHome1B =>
      'Type a tracking code here to jump straight to its evidence.';

  @override
  String get cdHome2T => 'Filter by state';

  @override
  String get cdHome2B =>
      'See only orders still uploading, already done, or failed.';

  @override
  String get cdQueue1T => 'Clips waiting to upload';

  @override
  String get cdQueue1B =>
      'Weak signal? Clips wait here and retry when the connection returns.';

  @override
  String get cdQueue2T => 'Clear the queue';

  @override
  String get cdQueue2B =>
      'Only removes clips not yet uploaded. They are gone for good — the server has no copy.';

  @override
  String get cdClaims1T => 'Bundle evidence for the marketplace';

  @override
  String get cdClaims1B =>
      'Several orders become one dossier you send as a single link.';

  @override
  String get cdRec1T => 'Scan the tracking code';

  @override
  String get cdRec1B =>
      'Hold the label in the frame. The app reads it and attaches the video to that order.';

  @override
  String get cdOrder1T => 'Evidence for this order';

  @override
  String get cdOrder1B =>
      'Every clip and photo for this tracking code, newest on top.';

  @override
  String get cdClaimD1T => 'Link to send the marketplace';

  @override
  String get cdClaimD1B =>
      'Copy this link into your claim. The recipient needs no account to view it.';

  @override
  String get cdShops1T => 'Switch shop';

  @override
  String get cdShops1B =>
      'Each shop has its own storage, plan and staff. Tap to change.';

  @override
  String get cdQuota1T => 'Storage used';

  @override
  String get cdQuota1B =>
      'Your plan sets video count and retention. You are warned before it fills — nothing is deleted silently.';

  @override
  String get cdAcc1T => 'Your plan';

  @override
  String get cdAcc1B =>
      'See videos left, how long they are kept, and upgrade here.';

  @override
  String get cdAcc2T => 'Sign-in methods';

  @override
  String get cdAcc2B =>
      'Add Google or Apple for faster sign-in — no password to remember.';

  @override
  String get cdShopD1T => 'Video types';

  @override
  String get cdShopD1B =>
      'Name the kinds of video you record — packing, returns — so they are easy to find later.';

  @override
  String get cdShopD2T => 'Invite staff';

  @override
  String get cdShopD2B =>
      'Invite people to work with you and set what each may do.';

  @override
  String get cdRec2T => 'Blurred label? Type it';

  @override
  String get cdRec2B =>
      'If the label is smudged or torn, tap here to enter the code by hand.';

  @override
  String get notifRow => 'Notifications';

  @override
  String get notifOn => 'On';

  @override
  String get notifOff => 'Off';

  @override
  String get notifAskTitle => 'Turn on notifications?';

  @override
  String get notifAskBody =>
      'ZenPack will tell you when your plan is about to expire, when videos are about to be deleted, when someone joins your shop — and remind you to record while packing.';

  @override
  String get notifAskYes => 'Turn on';

  @override
  String get notifAskNo => 'Not now';

  @override
  String get notifDenied =>
      'You declined earlier. Open your device Settings to turn it back on.';

  @override
  String get themeRow => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get tzRow => 'Time zone';

  @override
  String get tzAuto => 'Device';

  @override
  String get tzNote => 'Only changes the times shown on screen.';

  @override
  String get capTitle => 'Recording settings';

  @override
  String get capHint =>
      'Applies to EVERY device recording for this shop, not just yours.';

  @override
  String get capFps => 'Frame rate';

  @override
  String get capFpsHint =>
      'Devices that cannot hit this fall back to the nearest supported rate.';

  @override
  String get capAuto => 'Automatic';

  @override
  String get capScanKind => 'Code types';

  @override
  String get capScanHint => 'Which codes the scanner accepts.';

  @override
  String get capScanQr => 'QR only';

  @override
  String get capScanBar => 'Barcodes only';

  @override
  String get capScanBoth => 'Both';

  @override
  String get capEndDelay => 'Wait before a code can end the clip';

  @override
  String get capEndDelayHint =>
      'After a clip opens, wait this long before a code may end it.';

  @override
  String get capRearm => 'Wait before scanning a new code';

  @override
  String get capRearmHint =>
      'Stops the bill still lying in frame from reopening a clip for the same order.';

  @override
  String get capTail => 'Keep recording after the end code';

  @override
  String get capTailHint =>
      'After the end code is scanned, record this many more seconds.';

  @override
  String get capAudio => 'Record audio';

  @override
  String get capAudioHint =>
      'Packing tables have people talking — turning this on records that too.';

  @override
  String get capStatusSound => 'Status sounds';

  @override
  String get capStatusSoundHint =>
      'Spoken and beeped status, so the operator need not watch the screen.';

  @override
  String get capAutoConfig => 'Auto video config';

  @override
  String get capAutoConfigHint =>
      'Drops one resolution step when the device is low on space.';

  @override
  String get capBattery => 'Battery saver';

  @override
  String get capBatteryHint =>
      'Slows scanning. Trade-off: bills take longer to be picked up.';

  @override
  String get capWifi => 'Upload on Wi-Fi only';

  @override
  String get capWifiHint =>
      'Devices on mobile data STOP uploading; clips pile up until Wi-Fi is back.';

  @override
  String get capEndOther => 'End the clip with another QR';

  @override
  String get capEndOtherHint =>
      'Seeing another order\'s bill closes this clip and opens a new one.';

  @override
  String get capManualStop => 'Never stop automatically';

  @override
  String get capManualStopHint =>
      'No code can stop a clip; only the button does. This overrides the row above.';

  @override
  String get capSecond => 'seconds';

  @override
  String get capMs => 'ms';

  @override
  String get capOwnerOnly => 'Only the shop owner can change these.';

  @override
  String get capCustom => 'Other number…';

  @override
  String get capCustomTitle => 'Enter a value';

  @override
  String get capOff => 'Off';

  @override
  String get capDefaultSuffix => '(default)';

  @override
  String get invTitle => 'Invoice details';

  @override
  String get invHint =>
      'Fill this in once; the ZenPack team uses it when issuing invoices for your payments.';

  @override
  String get invKind => 'Buyer type';

  @override
  String get invKindCompany => 'Company / Household business';

  @override
  String get invKindPerson => 'Individual';

  @override
  String get invName => 'Company name';

  @override
  String get invNamePerson => 'Full name';

  @override
  String get invNamePh => 'e.g. ABC Co., Ltd';

  @override
  String get invNamePersonPh => 'e.g. Nguyen Van A';

  @override
  String get invTax => 'Tax code';

  @override
  String get invTaxPh => 'e.g. 0312345678';

  @override
  String get invTaxOptional => 'Tax code (if any)';

  @override
  String get invAddress => 'Address';

  @override
  String get invAddressPh => 'e.g. 123 Le Loi, D.1, HCMC';

  @override
  String get invEmail => 'Email for invoices';

  @override
  String get invEmailPh => 'e.g. billing@company.com';

  @override
  String get invNote => 'Note';

  @override
  String get invNotePh => 'Anything else (optional)';

  @override
  String get invSave => 'Save details';

  @override
  String get invNameRequired => 'Please enter a name.';

  @override
  String get invTaxRequired =>
      'A company or household business needs a tax code.';

  @override
  String get invTaxInvalid =>
      'A tax code is 10 digits, optionally with a 3-digit branch suffix.';

  @override
  String get invEmailInvalid => 'That email is not valid.';

  @override
  String get invNotSet => 'Not set';

  @override
  String get detailSignature => 'Digital signature';

  @override
  String sealSignature(String key) {
    return 'ZenPack signature · key $key';
  }

  @override
  String get sealCopyVerifyLink => 'Copy verification link';

  @override
  String get sealVerifyLinkTitle => 'Verification link';

  @override
  String get claimSignedLabel => 'Signed';

  @override
  String claimSignedCount(int sealed, int videos, int anchored) {
    return '$sealed/$videos videos · $anchored with independent proof';
  }

  @override
  String claimUnsignedHint(int n) {
    return '$n videos have no stamp — the marketplace may reject them. The dossier can still be sent; stamped videos still prove themselves.';
  }

  @override
  String get claimsSubtitle => 'Track and handle order dispute dossiers';

  @override
  String get claimsEmptyTitle => 'No dossiers yet';

  @override
  String get claimsEmptyBody =>
      'Tap the plus in the corner and pick the evidence of the order in dispute to create a dossier.';

  @override
  String get claimsEmptyTip =>
      'Tip: clear photos and videos help the marketplace decide faster.';

  @override
  String get timelineEnd => 'No more activity';

  @override
  String timelineEntryCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n entries',
      one: '1 entry',
    );
    return '$_temp0';
  }

  @override
  String get attachCodeToOrderHint =>
      'Attach a return code or a second tracking code to this order';

  @override
  String get attachPhotoToOrderHint =>
      'Pick a photo from this device to keep with this order';

  @override
  String get shopDetailClipLengthHint => 'Maximum recording time per video';

  @override
  String get shopDetailImageSizeHint => 'Maximum size per photo';

  @override
  String get storageRowHint => 'Where videos and photos are kept';

  @override
  String get capRowHint => 'Camera and display options';

  @override
  String get inviteQrLabel => 'Invite code';

  @override
  String get orderStatusRecorded => 'Recorded';

  @override
  String get orderStatusNone => 'Not recorded';

  @override
  String get accountTagline =>
      'Manage with ease, sell with confidence — ZenPack';

  @override
  String get videoTypeHintPacking => 'Film the packing process';

  @override
  String get videoTypeHintCarrier => 'Film the hand-over to the carrier';

  @override
  String get videoTypeHintReturn => 'Film the return as it arrives';

  @override
  String get statPendingSub => 'In the queue';

  @override
  String shopPulseToday(int orders, int videos) {
    String _temp0 = intl.Intl.pluralLogic(
      orders,
      locale: localeName,
      other: '$orders orders',
      one: '1 order',
    );
    String _temp1 = intl.Intl.pluralLogic(
      videos,
      locale: localeName,
      other: '$videos videos',
      one: '1 video',
    );
    return 'Today · $_temp0 · $_temp1';
  }
}

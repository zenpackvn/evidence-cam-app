import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @toastChangeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get toastChangeLanguage;

  /// No description provided for @toastTermsPolicy.
  ///
  /// In en, this message translates to:
  /// **'Terms & Policy'**
  String get toastTermsPolicy;

  /// No description provided for @toastInfoSaved.
  ///
  /// In en, this message translates to:
  /// **'Info saved'**
  String get toastInfoSaved;

  /// No description provided for @toastPasswordCreated.
  ///
  /// In en, this message translates to:
  /// **'Password created'**
  String get toastPasswordCreated;

  /// No description provided for @toastPasswordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get toastPasswordChanged;

  /// No description provided for @toastUpgradeComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Plan upgrade — coming soon'**
  String get toastUpgradeComingSoon;

  /// No description provided for @toastPendingDossierConfirm.
  ///
  /// In en, this message translates to:
  /// **'You still have an open claim dossier, please confirm again'**
  String get toastPendingDossierConfirm;

  /// No description provided for @toastCopiedShareLink.
  ///
  /// In en, this message translates to:
  /// **'Share link copied'**
  String get toastCopiedShareLink;

  /// No description provided for @toastShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t share, try again later'**
  String get toastShareFailed;

  /// No description provided for @toastDownloadingVideo.
  ///
  /// In en, this message translates to:
  /// **'Downloading video'**
  String get toastDownloadingVideo;

  /// No description provided for @toastVideoDownloadedCopied.
  ///
  /// In en, this message translates to:
  /// **'Video downloaded and path copied'**
  String get toastVideoDownloadedCopied;

  /// No description provided for @toastVideoSavedToGallery.
  ///
  /// In en, this message translates to:
  /// **'Video saved to your device gallery'**
  String get toastVideoSavedToGallery;

  /// No description provided for @toastVideoDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t download video, try again later'**
  String get toastVideoDownloadFailed;

  /// No description provided for @toastVideoDeleteUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This video can\'t be deleted'**
  String get toastVideoDeleteUnavailable;

  /// No description provided for @toastDownloadingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Downloading photo'**
  String get toastDownloadingPhoto;

  /// No description provided for @toastPhotoSavedToGallery.
  ///
  /// In en, this message translates to:
  /// **'Photo saved to your device gallery'**
  String get toastPhotoSavedToGallery;

  /// No description provided for @toastPhotoDownloadedCopied.
  ///
  /// In en, this message translates to:
  /// **'Photo downloaded and path copied'**
  String get toastPhotoDownloadedCopied;

  /// No description provided for @toastPhotoDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t download photo, try again later'**
  String get toastPhotoDownloadFailed;

  /// No description provided for @toastPhotoNoDownloadLink.
  ///
  /// In en, this message translates to:
  /// **'Photo has no download link yet'**
  String get toastPhotoNoDownloadLink;

  /// No description provided for @toastPhotoQueued.
  ///
  /// In en, this message translates to:
  /// **'Photo attached — added to the upload queue'**
  String get toastPhotoQueued;

  /// No description provided for @toastInvitePending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for a shop invitation'**
  String get toastInvitePending;

  /// No description provided for @toastInviteSent.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent'**
  String get toastInviteSent;

  /// No description provided for @toastMemberAdded.
  ///
  /// In en, this message translates to:
  /// **'Member added'**
  String get toastMemberAdded;

  /// No description provided for @toastDossierLinkCreated.
  ///
  /// In en, this message translates to:
  /// **'Dossier link created'**
  String get toastDossierLinkCreated;

  /// No description provided for @toastDossierLinkRevoked.
  ///
  /// In en, this message translates to:
  /// **'Dossier link revoked'**
  String get toastDossierLinkRevoked;

  /// No description provided for @toastVideoPlayFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t play video'**
  String get toastVideoPlayFailed;

  /// No description provided for @toastShopCreated.
  ///
  /// In en, this message translates to:
  /// **'New shop created'**
  String get toastShopCreated;

  /// No description provided for @toastVideoQueued.
  ///
  /// In en, this message translates to:
  /// **'Video saved — added to the upload queue'**
  String get toastVideoQueued;

  /// No description provided for @toastVideoNoPlayLink.
  ///
  /// In en, this message translates to:
  /// **'Video has no playback link yet'**
  String get toastVideoNoPlayLink;

  /// No description provided for @toastVideoNoDownloadLink.
  ///
  /// In en, this message translates to:
  /// **'Video has no download link yet'**
  String get toastVideoNoDownloadLink;

  /// No description provided for @toastVideoDeleted.
  ///
  /// In en, this message translates to:
  /// **'Video deleted'**
  String get toastVideoDeleted;

  /// No description provided for @toastVideoTypeSaved.
  ///
  /// In en, this message translates to:
  /// **'Video type saved'**
  String get toastVideoTypeSaved;

  /// No description provided for @toastVideoTypeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Video type deleted'**
  String get toastVideoTypeDeleted;

  /// No description provided for @toastNoVideoTypeToDelete.
  ///
  /// In en, this message translates to:
  /// **'No video type to delete'**
  String get toastNoVideoTypeToDelete;

  /// No description provided for @toastRoleChangedManager.
  ///
  /// In en, this message translates to:
  /// **'Role changed: Shop manager'**
  String get toastRoleChangedManager;

  /// No description provided for @toastRoleChangedStaff.
  ///
  /// In en, this message translates to:
  /// **'Role changed: Staff'**
  String get toastRoleChangedStaff;

  /// No description provided for @toastNoMemberToUpdate.
  ///
  /// In en, this message translates to:
  /// **'No member to update'**
  String get toastNoMemberToUpdate;

  /// No description provided for @toastMemberRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from shop (recorded videos still finish uploading)'**
  String get toastMemberRemoved;

  /// No description provided for @copiedLabel.
  ///
  /// In en, this message translates to:
  /// **'Copied {label}'**
  String copiedLabel(String label);

  /// No description provided for @labelTrackingCode.
  ///
  /// In en, this message translates to:
  /// **'tracking code'**
  String get labelTrackingCode;

  /// No description provided for @labelDossierLink.
  ///
  /// In en, this message translates to:
  /// **'dossier link'**
  String get labelDossierLink;

  /// No description provided for @resolutionChanged.
  ///
  /// In en, this message translates to:
  /// **'Resolution: {value}'**
  String resolutionChanged(String value);

  /// No description provided for @dossierShareText.
  ///
  /// In en, this message translates to:
  /// **'Complaint dossier {tracking}'**
  String dossierShareText(String tracking);

  /// No description provided for @accountNoName.
  ///
  /// In en, this message translates to:
  /// **'No name yet'**
  String get accountNoName;

  /// No description provided for @accountNoShop.
  ///
  /// In en, this message translates to:
  /// **'No shop selected'**
  String get accountNoShop;

  /// No description provided for @accountCreatePassword.
  ///
  /// In en, this message translates to:
  /// **'Create password'**
  String get accountCreatePassword;

  /// No description provided for @accountChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get accountChangePassword;

  /// No description provided for @accountLinkedMethods.
  ///
  /// In en, this message translates to:
  /// **'{count} linked'**
  String accountLinkedMethods(int count);

  /// No description provided for @roleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get roleOwner;

  /// No description provided for @roleManager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get roleManager;

  /// No description provided for @roleStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get roleStaff;

  /// No description provided for @planFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get planFree;

  /// No description provided for @planBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get planBasic;

  /// No description provided for @roleOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get roleOther;

  /// No description provided for @roleUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get roleUnknown;

  /// No description provided for @memberFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get memberFallbackName;

  /// No description provided for @uploadStatusDone.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get uploadStatusDone;

  /// No description provided for @uploadStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting to upload'**
  String get uploadStatusPending;

  /// No description provided for @uploadStatusQuotaHold.
  ///
  /// In en, this message translates to:
  /// **'On hold (quota)'**
  String get uploadStatusQuotaHold;

  /// No description provided for @uploadStatusDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get uploadStatusDeleted;

  /// No description provided for @uploadStatusError.
  ///
  /// In en, this message translates to:
  /// **'Server-side processing error'**
  String get uploadStatusError;

  /// No description provided for @kindPhoto.
  ///
  /// In en, this message translates to:
  /// **'Attached photo'**
  String get kindPhoto;

  /// No description provided for @kindVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get kindVideo;

  /// No description provided for @recordedByFallback.
  ///
  /// In en, this message translates to:
  /// **'Current account'**
  String get recordedByFallback;

  /// No description provided for @deviceUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown device'**
  String get deviceUnknown;

  /// No description provided for @orderNoEvidence.
  ///
  /// In en, this message translates to:
  /// **'No evidence yet'**
  String get orderNoEvidence;

  /// No description provided for @errorGenericRetry.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong, please try again.'**
  String get errorGenericRetry;

  /// No description provided for @errorPendingDossier.
  ///
  /// In en, this message translates to:
  /// **'You still have an open claim dossier, please handle it before continuing.'**
  String get errorPendingDossier;

  /// No description provided for @errorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired, please sign in again.'**
  String get errorSessionExpired;

  /// No description provided for @errorNoNetwork.
  ///
  /// In en, this message translates to:
  /// **'No network connection, please try again.'**
  String get errorNoNetwork;

  /// No description provided for @errorNoPermission.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to perform this action.'**
  String get errorNoPermission;

  /// No description provided for @errorServerBusy.
  ///
  /// In en, this message translates to:
  /// **'The system is busy, please try again later.'**
  String get errorServerBusy;

  /// No description provided for @errorSessionInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid session, please sign in again.'**
  String get errorSessionInvalid;

  /// No description provided for @errorVideoTypeInUse.
  ///
  /// In en, this message translates to:
  /// **'Can\'t delete a video type that already has videos. Please review the videos using this type first.'**
  String get errorVideoTypeInUse;

  /// No description provided for @errorBuiltinVideoTypeLocked.
  ///
  /// In en, this message translates to:
  /// **'The 3 built-in video types can\'t be edited or deleted.'**
  String get errorBuiltinVideoTypeLocked;

  /// No description provided for @errorVideoTypeNameExists.
  ///
  /// In en, this message translates to:
  /// **'That video type name already exists in the shop.'**
  String get errorVideoTypeNameExists;

  /// No description provided for @errorCheckNetwork.
  ///
  /// In en, this message translates to:
  /// **'Check your network or try again later.'**
  String get errorCheckNetwork;

  /// No description provided for @errorLoadShopList.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the shop list'**
  String get errorLoadShopList;

  /// No description provided for @errorLoadShopMgmt.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load shop management'**
  String get errorLoadShopMgmt;

  /// No description provided for @errorLoadShopDetail.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load shop details'**
  String get errorLoadShopDetail;

  /// No description provided for @errorLoadOrders.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load orders'**
  String get errorLoadOrders;

  /// No description provided for @errorLoadOrderDetail.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load order details'**
  String get errorLoadOrderDetail;

  /// No description provided for @noShopSelectedOrdersDetail.
  ///
  /// In en, this message translates to:
  /// **'Please choose a shop before viewing orders.'**
  String get noShopSelectedOrdersDetail;

  /// No description provided for @noShopSelectedRecordDetail.
  ///
  /// In en, this message translates to:
  /// **'Please choose a shop before recording.'**
  String get noShopSelectedRecordDetail;

  /// No description provided for @noShopSelectedManageDetail.
  ///
  /// In en, this message translates to:
  /// **'Please choose a shop to manage.'**
  String get noShopSelectedManageDetail;

  /// No description provided for @noOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrdersTitle;

  /// No description provided for @noOrdersDetail.
  ///
  /// In en, this message translates to:
  /// **'Please choose an order from the list.'**
  String get noOrdersDetail;

  /// No description provided for @noVideoDataTitle.
  ///
  /// In en, this message translates to:
  /// **'No video data'**
  String get noVideoDataTitle;

  /// No description provided for @cannotOpenVideoTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open video'**
  String get cannotOpenVideoTitle;

  /// No description provided for @cannotOpenVideoDetail.
  ///
  /// In en, this message translates to:
  /// **'Video has no playback link yet.'**
  String get cannotOpenVideoDetail;

  /// No description provided for @createOrderDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new order?'**
  String get createOrderDialogTitle;

  /// No description provided for @createOrderDialogBody.
  ///
  /// In en, this message translates to:
  /// **'{code} doesn\'t match any tracking code in the current shop. Re-check the code or confirm creating a new order.'**
  String createOrderDialogBody(String code);

  /// No description provided for @createOrderConfirm.
  ///
  /// In en, this message translates to:
  /// **'Create new order'**
  String get createOrderConfirm;

  /// No description provided for @statOrdersToday.
  ///
  /// In en, this message translates to:
  /// **'Orders today'**
  String get statOrdersToday;

  /// No description provided for @statVideosRecorded.
  ///
  /// In en, this message translates to:
  /// **'Videos recorded'**
  String get statVideosRecorded;

  /// No description provided for @statPendingUpload.
  ///
  /// In en, this message translates to:
  /// **'Pending upload'**
  String get statPendingUpload;

  /// No description provided for @accountPlanQuota.
  ///
  /// In en, this message translates to:
  /// **'Plan & Quota'**
  String get accountPlanQuota;

  /// No description provided for @accountSectionApp.
  ///
  /// In en, this message translates to:
  /// **'PLAN & APP'**
  String get accountSectionApp;

  /// No description provided for @accountLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get accountLanguage;

  /// No description provided for @accountSectionSecurity.
  ///
  /// In en, this message translates to:
  /// **'SECURITY & SIGN-IN'**
  String get accountSectionSecurity;

  /// No description provided for @accountLoginMethods.
  ///
  /// In en, this message translates to:
  /// **'Sign-in method'**
  String get accountLoginMethods;

  /// No description provided for @accountSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get accountSignOut;

  /// No description provided for @accountDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get accountDeleteAccount;

  /// No description provided for @accountShopMgmtHint.
  ///
  /// In en, this message translates to:
  /// **'Manage shop/members: tap back on the header to return to the Shop layer'**
  String get accountShopMgmtHint;

  /// No description provided for @accountInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Account info'**
  String get accountInfoTitle;

  /// No description provided for @accountFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get accountFullName;

  /// No description provided for @accountFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get accountFullNameHint;

  /// No description provided for @accountFullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get accountFullNameRequired;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get phoneHint;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get phoneRequired;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get phoneInvalid;

  /// No description provided for @accountSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get accountSaveChanges;

  /// No description provided for @phoneAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add phone number'**
  String get phoneAddTitle;

  /// No description provided for @phoneAddBody.
  ///
  /// In en, this message translates to:
  /// **'Your Apple/Google account has no phone number yet. Please enter a phone number to continue.'**
  String get phoneAddBody;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @languageNameVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get languageNameVietnamese;

  /// No description provided for @languageNameEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageNameEnglish;

  /// No description provided for @languageChangeAppliesNote.
  ///
  /// In en, this message translates to:
  /// **'Changes apply instantly across the whole app'**
  String get languageChangeAppliesNote;

  /// No description provided for @linkLinked.
  ///
  /// In en, this message translates to:
  /// **'Linked'**
  String get linkLinked;

  /// No description provided for @linkNotLinked.
  ///
  /// In en, this message translates to:
  /// **'Not linked'**
  String get linkNotLinked;

  /// No description provided for @loginMethodsEmailNote.
  ///
  /// In en, this message translates to:
  /// **'Email is your account identifier — it can\'t be removed. Link Google/Apple to sign in quickly with the same account.'**
  String get loginMethodsEmailNote;

  /// No description provided for @loginMethodIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identifier'**
  String get loginMethodIdentity;

  /// No description provided for @linkAction.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get linkAction;

  /// No description provided for @linkUnlink.
  ///
  /// In en, this message translates to:
  /// **'Unlink'**
  String get linkUnlink;

  /// No description provided for @quotaScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports & Quota'**
  String get quotaScreenTitle;

  /// No description provided for @quotaCurrentPlan.
  ///
  /// In en, this message translates to:
  /// **'Current plan'**
  String get quotaCurrentPlan;

  /// No description provided for @quotaRemainingThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Remaining this month'**
  String get quotaRemainingThisMonth;

  /// No description provided for @quotaStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get quotaStorage;

  /// No description provided for @quotaUpgradePlan.
  ///
  /// In en, this message translates to:
  /// **'Upgrade plan'**
  String get quotaUpgradePlan;

  /// No description provided for @deleteAccountTitleStep1.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountTitleStep1;

  /// No description provided for @deleteAccountTitleStep2.
  ///
  /// In en, this message translates to:
  /// **'Confirm permanent deletion?'**
  String get deleteAccountTitleStep2;

  /// No description provided for @deleteAccountBodyStep1.
  ///
  /// In en, this message translates to:
  /// **'All your videos, orders and dossiers will be permanently deleted. This action cannot be undone.'**
  String get deleteAccountBodyStep1;

  /// No description provided for @deleteAccountBodyStep2.
  ///
  /// In en, this message translates to:
  /// **'This is the final confirmation step. After deletion, you\'ll be signed out of the app immediately.'**
  String get deleteAccountBodyStep2;

  /// No description provided for @deleteConfirmPermanent.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deleteConfirmPermanent;

  /// No description provided for @deleteStep1Hint.
  ///
  /// In en, this message translates to:
  /// **'Step 1/2 — will ask for confirmation again · then sign out'**
  String get deleteStep1Hint;

  /// No description provided for @deleteStep2Hint.
  ///
  /// In en, this message translates to:
  /// **'Step 2/2 — this action cannot be undone'**
  String get deleteStep2Hint;

  /// No description provided for @passwordCurrentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get passwordCurrentLabel;

  /// No description provided for @passwordCurrentRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your current password'**
  String get passwordCurrentRequired;

  /// No description provided for @passwordNewLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get passwordNewLabel;

  /// No description provided for @passwordMinHint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters, with letters and numbers'**
  String get passwordMinHint;

  /// No description provided for @passwordNewRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get passwordNewRequired;

  /// No description provided for @passwordMin8Error.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMin8Error;

  /// No description provided for @passwordNeedsLetterDigit.
  ///
  /// In en, this message translates to:
  /// **'Password needs both letters and numbers'**
  String get passwordNeedsLetterDigit;

  /// No description provided for @passwordTooCommon.
  ///
  /// In en, this message translates to:
  /// **'That password is too easy to guess — pick another'**
  String get passwordTooCommon;

  /// No description provided for @passwordConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Re-enter new password'**
  String get passwordConfirmLabel;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordMismatch;

  /// No description provided for @passwordSave.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get passwordSave;

  /// No description provided for @passwordChangeLogoutNote.
  ///
  /// In en, this message translates to:
  /// **'(You\'ll be signed out of other devices after changing)'**
  String get passwordChangeLogoutNote;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// No description provided for @navRecord.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get navRecord;

  /// No description provided for @navAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get navAccount;

  /// No description provided for @changeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get changeAvatar;

  /// No description provided for @quotaVideosRatio.
  ///
  /// In en, this message translates to:
  /// **'{remaining} / {total} videos'**
  String quotaVideosRatio(int remaining, int total);

  /// No description provided for @quotaUsedPercent.
  ///
  /// In en, this message translates to:
  /// **'Used {percent}%'**
  String quotaUsedPercent(int percent);

  /// No description provided for @quotaRetentionDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String quotaRetentionDays(int days);

  /// No description provided for @deletePendingProfilesWarning.
  ///
  /// In en, this message translates to:
  /// **'You still have {count} open claim dossiers — their share links will stop working'**
  String deletePendingProfilesWarning(int count);

  /// No description provided for @detailRecordedTime.
  ///
  /// In en, this message translates to:
  /// **'Recording time'**
  String get detailRecordedTime;

  /// No description provided for @detailRecordedBy.
  ///
  /// In en, this message translates to:
  /// **'Recorded by'**
  String get detailRecordedBy;

  /// No description provided for @detailCapturedTime.
  ///
  /// In en, this message translates to:
  /// **'Capture time'**
  String get detailCapturedTime;

  /// No description provided for @detailCapturedBy.
  ///
  /// In en, this message translates to:
  /// **'Captured by'**
  String get detailCapturedBy;

  /// No description provided for @detailDevice.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get detailDevice;

  /// No description provided for @detailSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get detailSize;

  /// No description provided for @detailUploadStatus.
  ///
  /// In en, this message translates to:
  /// **'Upload status'**
  String get detailUploadStatus;

  /// No description provided for @detailPlayVideo.
  ///
  /// In en, this message translates to:
  /// **'Play video'**
  String get detailPlayVideo;

  /// No description provided for @detailDownloadVideo.
  ///
  /// In en, this message translates to:
  /// **'Download video'**
  String get detailDownloadVideo;

  /// No description provided for @detailDownloadNote.
  ///
  /// In en, this message translates to:
  /// **'Account owner / shop manager only — to attach a marketplace complaint form'**
  String get detailDownloadNote;

  /// No description provided for @detailDownloadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Download photo'**
  String get detailDownloadPhoto;

  /// No description provided for @attachPhotoToOrder.
  ///
  /// In en, this message translates to:
  /// **'Attach photo to order'**
  String get attachPhotoToOrder;

  /// No description provided for @createDossierLink.
  ///
  /// In en, this message translates to:
  /// **'Create complaint dossier link'**
  String get createDossierLink;

  /// No description provided for @dossierLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Complaint dossier link'**
  String get dossierLinkLabel;

  /// No description provided for @revoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get revoke;

  /// No description provided for @deleteVideoAction.
  ///
  /// In en, this message translates to:
  /// **'Delete video'**
  String get deleteVideoAction;

  /// No description provided for @deleteVideoNote.
  ///
  /// In en, this message translates to:
  /// **'Account owner / shop manager only · 2-step confirmation · permanent'**
  String get deleteVideoNote;

  /// No description provided for @ordersErrorCount.
  ///
  /// In en, this message translates to:
  /// **'· {count} errors'**
  String ordersErrorCount(int count);

  /// No description provided for @ordersPendingEvidenceWarning.
  ///
  /// In en, this message translates to:
  /// **'{count} evidence not uploaded — the dossier will be incomplete'**
  String ordersPendingEvidenceWarning(int count);

  /// No description provided for @captureFramePrompt.
  ///
  /// In en, this message translates to:
  /// **'Place the bill in the frame to start'**
  String get captureFramePrompt;

  /// No description provided for @captureCameraDownHint.
  ///
  /// In en, this message translates to:
  /// **'Camera facing down at the table'**
  String get captureCameraDownHint;

  /// No description provided for @tooltipBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get tooltipBack;

  /// No description provided for @tooltipSwitchCamera.
  ///
  /// In en, this message translates to:
  /// **'Switch camera'**
  String get tooltipSwitchCamera;

  /// No description provided for @tooltipToggleOrientation.
  ///
  /// In en, this message translates to:
  /// **'Toggle portrait/landscape'**
  String get tooltipToggleOrientation;

  /// No description provided for @tooltipEnterTracking.
  ///
  /// In en, this message translates to:
  /// **'Enter tracking code'**
  String get tooltipEnterTracking;

  /// No description provided for @tooltipZoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get tooltipZoomIn;

  /// No description provided for @tooltipZoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get tooltipZoomOut;

  /// No description provided for @captureResolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get captureResolution;

  /// No description provided for @stopRecording.
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get stopRecording;

  /// No description provided for @videoTypeSettings.
  ///
  /// In en, this message translates to:
  /// **'Video type settings'**
  String get videoTypeSettings;

  /// No description provided for @uploadQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload queue'**
  String get uploadQueueTitle;

  /// No description provided for @quotaExhaustedNote.
  ///
  /// In en, this message translates to:
  /// **'Out of quota this month — videos will wait for quota'**
  String get quotaExhaustedNote;

  /// No description provided for @upgradePlanShort.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgradePlanShort;

  /// No description provided for @queueEmpty.
  ///
  /// In en, this message translates to:
  /// **'No videos in the queue yet'**
  String get queueEmpty;

  /// No description provided for @queueAutoUploadNote.
  ///
  /// In en, this message translates to:
  /// **'Upload happens automatically when you\'re online'**
  String get queueAutoUploadNote;

  /// No description provided for @waitingUpload.
  ///
  /// In en, this message translates to:
  /// **'Waiting to upload'**
  String get waitingUpload;

  /// No description provided for @uploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get uploaded;

  /// No description provided for @waitingQuota.
  ///
  /// In en, this message translates to:
  /// **'Waiting for quota'**
  String get waitingQuota;

  /// No description provided for @pausedUpload.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get pausedUpload;

  /// No description provided for @queuePauseAction.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get queuePauseAction;

  /// No description provided for @queueResumeAction.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get queueResumeAction;

  /// No description provided for @queueDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get queueDeleteAction;

  /// No description provided for @queueDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove from queue?'**
  String get queueDeleteConfirmTitle;

  /// No description provided for @queueDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This clip hasn\'t been uploaded yet — removing it deletes it from your device permanently.'**
  String get queueDeleteConfirmBody;

  /// No description provided for @toastQueueItemDeleted.
  ///
  /// In en, this message translates to:
  /// **'Removed from the upload queue'**
  String get toastQueueItemDeleted;

  /// No description provided for @manualTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter tracking code manually'**
  String get manualTrackingTitle;

  /// No description provided for @manualTrackingNote.
  ///
  /// In en, this message translates to:
  /// **'Use when the bill is blurry — no more than 10 seconds'**
  String get manualTrackingNote;

  /// No description provided for @startRecording.
  ///
  /// In en, this message translates to:
  /// **'Start recording'**
  String get startRecording;

  /// No description provided for @returnCodeMismatch.
  ///
  /// In en, this message translates to:
  /// **'Return code doesn\'t match'**
  String get returnCodeMismatch;

  /// No description provided for @enterCodeManually.
  ///
  /// In en, this message translates to:
  /// **'Enter code manually'**
  String get enterCodeManually;

  /// No description provided for @videoTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Video type'**
  String get videoTypeLabel;

  /// No description provided for @videoTypeSelectNote.
  ///
  /// In en, this message translates to:
  /// **'Choose a type for this recording session — add/edit/delete in Shop details'**
  String get videoTypeSelectNote;

  /// No description provided for @manageVideoTypesNote.
  ///
  /// In en, this message translates to:
  /// **'Manage video types — open Shop details'**
  String get manageVideoTypesNote;

  /// No description provided for @queueFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All · {count}'**
  String queueFilterAll(int count);

  /// No description provided for @queueFilterUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading · {count}'**
  String queueFilterUploading(int count);

  /// No description provided for @queueFilterErrored.
  ///
  /// In en, this message translates to:
  /// **'Errors · {count}'**
  String queueFilterErrored(int count);

  /// No description provided for @uploadingProgress.
  ///
  /// In en, this message translates to:
  /// **'Uploading {percent}%'**
  String uploadingProgress(int percent);

  /// No description provided for @errorRetryCount.
  ///
  /// In en, this message translates to:
  /// **'Error · Retry ({count})'**
  String errorRetryCount(int count);

  /// No description provided for @returnCodeMismatchBody.
  ///
  /// In en, this message translates to:
  /// **'{returnCode} doesn\'t match any order in {shopName}. Re-check the code, enter it manually, or confirm creating a new order.'**
  String returnCodeMismatchBody(String returnCode, String shopName);

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record packing-evidence videos for e-commerce sellers'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingStart;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authChooseMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose a sign-in method'**
  String get authChooseMethod;

  /// No description provided for @authEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get authEmailRequired;

  /// No description provided for @authEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get authEmailInvalid;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get authPasswordRequired;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authSignInGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get authSignInGoogle;

  /// No description provided for @authSignInApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get authSignInApple;

  /// No description provided for @authNoAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get authNoAccountPrompt;

  /// No description provided for @authRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegister;

  /// No description provided for @authOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authOr;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new account'**
  String get registerTitle;

  /// No description provided for @registerConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password'**
  String get registerConfirmPassword;

  /// No description provided for @registerAgreePolicy.
  ///
  /// In en, this message translates to:
  /// **'I agree to the policy '**
  String get registerAgreePolicy;

  /// No description provided for @registerViewPolicy.
  ///
  /// In en, this message translates to:
  /// **'View policy'**
  String get registerViewPolicy;

  /// No description provided for @registerCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerCreateAccount;

  /// No description provided for @registerSameEmailNote.
  ///
  /// In en, this message translates to:
  /// **'The same email will automatically link to one account'**
  String get registerSameEmailNote;

  /// No description provided for @registerHaveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get registerHaveAccountPrompt;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a password reset link'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get forgotPasswordSubmit;

  /// No description provided for @forgotPasswordSent.
  ///
  /// In en, this message translates to:
  /// **'Sent — check your inbox (including spam)'**
  String get forgotPasswordSent;

  /// No description provided for @forgotPasswordRememberPrompt.
  ///
  /// In en, this message translates to:
  /// **'Remember your password? '**
  String get forgotPasswordRememberPrompt;

  /// No description provided for @shopYourShops.
  ///
  /// In en, this message translates to:
  /// **'Your shops'**
  String get shopYourShops;

  /// No description provided for @shopTapToClockIn.
  ///
  /// In en, this message translates to:
  /// **'Tap a shop to clock in · manage right here'**
  String get shopTapToClockIn;

  /// No description provided for @shopLastOpenedNote.
  ///
  /// In en, this message translates to:
  /// **'The most recently opened shop will open directly next time'**
  String get shopLastOpenedNote;

  /// No description provided for @shopManageStore.
  ///
  /// In en, this message translates to:
  /// **'Manage store'**
  String get shopManageStore;

  /// No description provided for @shopManageVisibilityNote.
  ///
  /// In en, this message translates to:
  /// **'Only visible to the account owner / shop manager'**
  String get shopManageVisibilityNote;

  /// No description provided for @shopEmpty.
  ///
  /// In en, this message translates to:
  /// **'No shops yet'**
  String get shopEmpty;

  /// No description provided for @shopEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Your account doesn\'t belong to any shop yet. Create a new shop to get started, or wait for an invitation from a shop owner.'**
  String get shopEmptyBody;

  /// No description provided for @shopCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Create new shop (name + platform)'**
  String get shopCreateNew;

  /// No description provided for @shopInvitesHere.
  ///
  /// In en, this message translates to:
  /// **'Shop invitations will appear here'**
  String get shopInvitesHere;

  /// No description provided for @shopCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create shop'**
  String get shopCreateTitle;

  /// No description provided for @shopNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Shop name'**
  String get shopNameLabel;

  /// No description provided for @shopNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a shop name'**
  String get shopNameRequired;

  /// No description provided for @shopPlatform.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get shopPlatform;

  /// No description provided for @shopCreateOwnerNote.
  ///
  /// In en, this message translates to:
  /// **'You\'ll be the shop owner — add members later in Manage store'**
  String get shopCreateOwnerNote;

  /// No description provided for @shopMgmtVisibilityNote.
  ///
  /// In en, this message translates to:
  /// **'Staff don\'t see this screen · shop managers only see shops they manage'**
  String get shopMgmtVisibilityNote;

  /// No description provided for @shopAddNew.
  ///
  /// In en, this message translates to:
  /// **'Add new shop (name + platform)'**
  String get shopAddNew;

  /// No description provided for @sectionMembers.
  ///
  /// In en, this message translates to:
  /// **'MEMBERS'**
  String get sectionMembers;

  /// No description provided for @sectionShopSettings.
  ///
  /// In en, this message translates to:
  /// **'SHOP SETTINGS'**
  String get sectionShopSettings;

  /// No description provided for @sectionVideoTypes.
  ///
  /// In en, this message translates to:
  /// **'VIDEO TYPES'**
  String get sectionVideoTypes;

  /// No description provided for @videoTypesLockedNote.
  ///
  /// In en, this message translates to:
  /// **'3 built-in types are locked — can\'t be edited/deleted'**
  String get videoTypesLockedNote;

  /// No description provided for @addMemberByContact.
  ///
  /// In en, this message translates to:
  /// **'Add member by email/phone'**
  String get addMemberByContact;

  /// No description provided for @recordResolution.
  ///
  /// In en, this message translates to:
  /// **'Recording resolution'**
  String get recordResolution;

  /// No description provided for @addVideoType.
  ///
  /// In en, this message translates to:
  /// **'Add type (enter name)'**
  String get addVideoType;

  /// No description provided for @createVideoTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Create video type'**
  String get createVideoTypeTitle;

  /// No description provided for @videoTypeName.
  ///
  /// In en, this message translates to:
  /// **'Video type name'**
  String get videoTypeName;

  /// No description provided for @videoTypeNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Weighing'**
  String get videoTypeNameHint;

  /// No description provided for @createVideoType.
  ///
  /// In en, this message translates to:
  /// **'Create type'**
  String get createVideoType;

  /// No description provided for @deleteVideoTypeBody.
  ///
  /// In en, this message translates to:
  /// **'Can only be deleted while this type has no videos. If it has videos, the system blocks deletion to avoid disrupting evidence filters and stats.'**
  String get deleteVideoTypeBody;

  /// No description provided for @deleteVideoTypeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete type'**
  String get deleteVideoTypeConfirm;

  /// No description provided for @deleteVideoTypeNote.
  ///
  /// In en, this message translates to:
  /// **'(Only deletable while the type has no videos)'**
  String get deleteVideoTypeNote;

  /// No description provided for @addMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Add member'**
  String get addMemberTitle;

  /// No description provided for @addMemberBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the email or phone number of a registered account to add them to the shop.'**
  String get addMemberBody;

  /// No description provided for @emailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email or phone number'**
  String get emailOrPhone;

  /// No description provided for @addMemberSubmit.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addMemberSubmit;

  /// No description provided for @setAsManager.
  ///
  /// In en, this message translates to:
  /// **'Set as shop manager'**
  String get setAsManager;

  /// No description provided for @setAsStaff.
  ///
  /// In en, this message translates to:
  /// **'Set as staff'**
  String get setAsStaff;

  /// No description provided for @removeFromShop.
  ///
  /// In en, this message translates to:
  /// **'Remove from shop'**
  String get removeFromShop;

  /// No description provided for @resolutionAppliesNote.
  ///
  /// In en, this message translates to:
  /// **'Applies to the shop\'s newly recorded videos'**
  String get resolutionAppliesNote;

  /// No description provided for @resolutionDefaultOption.
  ///
  /// In en, this message translates to:
  /// **'720p (default)'**
  String get resolutionDefaultOption;

  /// No description provided for @ordersNotFound.
  ///
  /// In en, this message translates to:
  /// **'No orders found'**
  String get ordersNotFound;

  /// No description provided for @filterStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Upload status'**
  String get filterStatusLabel;

  /// No description provided for @filterStatusAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterStatusAll;

  /// No description provided for @filterStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Awaiting upload'**
  String get filterStatusPending;

  /// No description provided for @filterStatusError.
  ///
  /// In en, this message translates to:
  /// **'Upload errors'**
  String get filterStatusError;

  /// No description provided for @filterStatusDone.
  ///
  /// In en, this message translates to:
  /// **'Fully uploaded'**
  String get filterStatusDone;

  /// No description provided for @filterTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get filterTimeLabel;

  /// No description provided for @filterTimeAll.
  ///
  /// In en, this message translates to:
  /// **'Any time'**
  String get filterTimeAll;

  /// No description provided for @filterTimeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get filterTimeToday;

  /// No description provided for @filterTime7d.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get filterTime7d;

  /// No description provided for @filterTime30d.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get filterTime30d;

  /// No description provided for @filterTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Video type'**
  String get filterTypeLabel;

  /// No description provided for @filterTypeAll.
  ///
  /// In en, this message translates to:
  /// **'Video type'**
  String get filterTypeAll;

  /// No description provided for @deleteVideoTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete type \"{typeName}\"?'**
  String deleteVideoTypeTitle(String typeName);

  /// No description provided for @memberCurrentRole.
  ///
  /// In en, this message translates to:
  /// **'Current role: {role}'**
  String memberCurrentRole(String role);

  /// No description provided for @stopCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop-recording QR code'**
  String get stopCodeTitle;

  /// No description provided for @stopCodeInstructions.
  ///
  /// In en, this message translates to:
  /// **'Print this and stick it at the packing table. Show it to the camera while recording to stop automatically.'**
  String get stopCodeInstructions;

  /// No description provided for @scannedCodeNotFound.
  ///
  /// In en, this message translates to:
  /// **'No order matches the scanned code'**
  String get scannedCodeNotFound;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

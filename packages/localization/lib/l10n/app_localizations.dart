import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fil.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_th.dart';
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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fil'),
    Locale('fr'),
    Locale('id'),
    Locale('it'),
    Locale('ms'),
    Locale('th'),
    Locale('vi'),
  ];

  /// No description provided for @bundleBackendPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting on a backend endpoint for this'**
  String get bundleBackendPending;

  /// No description provided for @bundleCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get bundleCreate;

  /// No description provided for @bundleCreateClaim.
  ///
  /// In en, this message translates to:
  /// **'Create claim dossier'**
  String get bundleCreateClaim;

  /// No description provided for @accountClaims.
  ///
  /// In en, this message translates to:
  /// **'Claim dossiers'**
  String get accountClaims;

  /// No description provided for @claimsTitle.
  ///
  /// In en, this message translates to:
  /// **'Claim dossiers'**
  String get claimsTitle;

  /// No description provided for @claimsLocalOnlyNote.
  ///
  /// In en, this message translates to:
  /// **'Some dossiers have not been uploaded yet, so they exist only on this device.'**
  String get claimsLocalOnlyNote;

  /// No description provided for @claimsOfflineNote.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the server, so this is the copy stored on this device. Reopen when online to see everything.'**
  String get claimsOfflineNote;

  /// No description provided for @claimsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No dossiers yet. Open the Orders tab, tap the plus button and pick the evidence to build one.'**
  String get claimsEmpty;

  /// Summary line for one dossier in the list screen.
  ///
  /// In en, this message translates to:
  /// **'{orders} orders · {evidence} evidence'**
  String claimsSummary(int orders, int evidence);

  /// No description provided for @claimsEvidenceOnly.
  ///
  /// In en, this message translates to:
  /// **'{evidence} items'**
  String claimsEvidenceOnly(int evidence);

  /// No description provided for @claimsCopied.
  ///
  /// In en, this message translates to:
  /// **'Dossier contents copied'**
  String get claimsCopied;

  /// No description provided for @claimsCreated.
  ///
  /// In en, this message translates to:
  /// **'Claim dossier created'**
  String get claimsCreated;

  /// No description provided for @claimsPickNothing.
  ///
  /// In en, this message translates to:
  /// **'No evidence selected'**
  String get claimsPickNothing;

  /// No description provided for @claimsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete dossier'**
  String get claimsDelete;

  /// Delete confirmation for a dossier that never reached the server, so there is no public link to kill.
  ///
  /// In en, this message translates to:
  /// **'Delete this dossier? The evidence on the orders themselves is untouched.'**
  String get claimsDeleteConfirm;

  /// Delete confirmation for a dossier that has a live public link. Says the link dies, because that link may already be sitting in a marketplace claim form.
  ///
  /// In en, this message translates to:
  /// **'Delete this dossier? Its public link dies immediately — anyone you already sent it to gets an empty page. The evidence on the orders themselves is untouched.'**
  String get claimsDeleteConfirmLink;

  /// Shown when revoking on the server fails: no network, or the member is not the owner/manager. The local dossier is deliberately kept so the link can still be revoked later.
  ///
  /// In en, this message translates to:
  /// **'Could not revoke the link, so the dossier is left as is. The link is still open — try again on a better connection, or ask the shop owner to revoke it.'**
  String get claimsRevokeFailed;

  /// No description provided for @claimsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Dossier deleted'**
  String get claimsDeleted;

  /// No description provided for @claimsPhotoAdded.
  ///
  /// In en, this message translates to:
  /// **'Photo added to the dossier and queued onto the order'**
  String get claimsPhotoAdded;

  /// No description provided for @claimsAddedLater.
  ///
  /// In en, this message translates to:
  /// **'added later'**
  String get claimsAddedLater;

  /// No description provided for @claimsCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New claim dossier'**
  String get claimsCreateTitle;

  /// No description provided for @claimsCreateSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Type or scan a tracking code'**
  String get claimsCreateSearchHint;

  /// Placeholder for the claim dossier name field; prefilled with the first tracking code.
  ///
  /// In en, this message translates to:
  /// **'e.g. Return claim 12/08'**
  String get claimsCreateNameHint;

  /// No description provided for @claimsCreateNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Dossier name'**
  String get claimsCreateNameLabel;

  /// No description provided for @claimInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Dossier details'**
  String get claimInfoTitle;

  /// No description provided for @claimTrackingLabel.
  ///
  /// In en, this message translates to:
  /// **'Tracking code'**
  String get claimTrackingLabel;

  /// No description provided for @claimShopLabel.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get claimShopLabel;

  /// No description provided for @claimChannelLabel.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get claimChannelLabel;

  /// No description provided for @claimOrderCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Order date'**
  String get claimOrderCreatedAt;

  /// No description provided for @claimEvidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Evidence'**
  String get claimEvidenceLabel;

  /// No description provided for @claimEvidenceCount.
  ///
  /// In en, this message translates to:
  /// **'{videos} videos · {photos} photos'**
  String claimEvidenceCount(int videos, int photos);

  /// No description provided for @claimCreatedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Dossier created'**
  String get claimCreatedAtLabel;

  /// No description provided for @claimCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get claimCopyLink;

  /// No description provided for @claimsRevokeNoLink.
  ///
  /// In en, this message translates to:
  /// **'This dossier is not on the server yet, so there is no link to revoke.'**
  String get claimsRevokeNoLink;

  /// No description provided for @claimPageFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the dossier page. Check your connection and try again.'**
  String get claimPageFailed;

  /// No description provided for @claimLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Dossier link'**
  String get claimLinkLabel;

  /// No description provided for @claimLinkHint.
  ///
  /// In en, this message translates to:
  /// **'Anyone with the link can view it, no sign-in needed. It stays live until you revoke it.'**
  String get claimLinkHint;

  /// No description provided for @claimRevokedBadge.
  ///
  /// In en, this message translates to:
  /// **'Revoked'**
  String get claimRevokedBadge;

  /// No description provided for @claimRevokedHint.
  ///
  /// In en, this message translates to:
  /// **'The link is dead. The data is untouched — create a new dossier to share again.'**
  String get claimRevokedHint;

  /// No description provided for @claimRevoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get claimRevoke;

  /// No description provided for @claimUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled dossier'**
  String get claimUntitled;

  /// No description provided for @claimRevokeConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Revoke this dossier?'**
  String get claimRevokeConfirmTitle;

  /// No description provided for @claimRevokeConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The link dies immediately for anyone holding it, including the marketplace. The data and per-order links are unaffected.'**
  String get claimRevokeConfirmBody;

  /// No description provided for @claimRevoked.
  ///
  /// In en, this message translates to:
  /// **'Dossier revoked. The link no longer opens.'**
  String get claimRevoked;

  /// No description provided for @claimRevokeFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not revoke. Try again when you are online.'**
  String get claimRevokeFailed;

  /// No description provided for @claimNotUploaded.
  ///
  /// In en, this message translates to:
  /// **'This dossier has not been uploaded yet, so it has no link. Reopen it when you are online.'**
  String get claimNotUploaded;

  /// No description provided for @claimDetailLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the dossier. Check your connection and reopen it.'**
  String get claimDetailLoadFailed;

  /// No description provided for @claimsCreateStart.
  ///
  /// In en, this message translates to:
  /// **'Type a tracking code, or tap scan, to find the order you are claiming for.'**
  String get claimsCreateStart;

  /// No description provided for @claimsCreateNoOrder.
  ///
  /// In en, this message translates to:
  /// **'No order with that tracking code in the selected shop.'**
  String get claimsCreateNoOrder;

  /// No description provided for @claimsRemoveItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove from dossier'**
  String get claimsRemoveItemTitle;

  /// No description provided for @claimsRemoveItemConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this evidence from the claim dossier? The video/photo on the order itself is untouched.'**
  String get claimsRemoveItemConfirm;

  /// No description provided for @claimsItemRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from the dossier'**
  String get claimsItemRemoved;

  /// No description provided for @claimsItemAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to the dossier'**
  String get claimsItemAdded;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @settingDefaultSuffix.
  ///
  /// In en, this message translates to:
  /// **'default'**
  String get settingDefaultSuffix;

  /// No description provided for @shopDetailClipLength.
  ///
  /// In en, this message translates to:
  /// **'Video length'**
  String get shopDetailClipLength;

  /// No description provided for @shopDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete shop'**
  String get shopDeleteTitle;

  /// No description provided for @shopDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this shop? All of its orders, videos and photos go with it, and can\'t be recovered.'**
  String get shopDeleteConfirm;

  /// No description provided for @shopDeleteBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'The shop still has members'**
  String get shopDeleteBlockedTitle;

  /// Shown when delete-shop is blocked by remaining members.
  ///
  /// In en, this message translates to:
  /// **'Remove every member from the shop before deleting it. {count} still remain.'**
  String shopDeleteBlockedBody(int count);

  /// No description provided for @shopDeleted.
  ///
  /// In en, this message translates to:
  /// **'Shop deleted.'**
  String get shopDeleted;

  /// No description provided for @bundleSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String bundleSelected(int count);

  /// No description provided for @bundleUploadDrive.
  ///
  /// In en, this message translates to:
  /// **'Upload to Drive'**
  String get bundleUploadDrive;

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

  /// Ảnh vượt trần 5 MB cố định.
  ///
  /// In en, this message translates to:
  /// **'Photo is {megabytes} MB — over the {limit} MB cap, not attached. Pick a smaller image.'**
  String imageOverFixedCap(String megabytes, String limit);

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

  /// No description provided for @toastInviteRevoked.
  ///
  /// In en, this message translates to:
  /// **'Invitation deleted — the emailed link no longer works'**
  String get toastInviteRevoked;

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

  /// No description provided for @resolutionChanged.
  ///
  /// In en, this message translates to:
  /// **'Resolution: {value}'**
  String resolutionChanged(String value);

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

  /// No description provided for @roleStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get roleStaff;

  /// Role line for an invite that has been emailed but not redeemed.
  ///
  /// In en, this message translates to:
  /// **'{role} · invite sent'**
  String memberInviteSent(String role);

  /// Role line for an invite that has been emailed but not redeemed.
  ///
  /// In en, this message translates to:
  /// **'{role} · awaiting confirmation'**
  String memberInvitePending(String role);

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

  /// No description provided for @planSaver.
  ///
  /// In en, this message translates to:
  /// **'Saver'**
  String get planSaver;

  /// No description provided for @planPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get planPremium;

  /// No description provided for @planPro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get planPro;

  /// No description provided for @planEnterprise.
  ///
  /// In en, this message translates to:
  /// **'Enterprise'**
  String get planEnterprise;

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

  /// No description provided for @uploadStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Storage retention expired'**
  String get uploadStatusExpired;

  /// No description provided for @expiredOnDate.
  ///
  /// In en, this message translates to:
  /// **'Storage retention expired on {date}'**
  String expiredOnDate(String date);

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

  /// No description provided for @timelineEmpty.
  ///
  /// In en, this message translates to:
  /// **'This shipment has no video or photo yet'**
  String get timelineEmpty;

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

  /// No description provided for @errorLoadMembers.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the member list'**
  String get errorLoadMembers;

  /// No description provided for @membersRestricted.
  ///
  /// In en, this message translates to:
  /// **'Only the shop owner can see the member list'**
  String get membersRestricted;

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
  /// **'Orders'**
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
  /// **'Plan & storage'**
  String get accountPlanQuota;

  /// No description provided for @accountChangePlan.
  ///
  /// In en, this message translates to:
  /// **'Change plan'**
  String get accountChangePlan;

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

  /// No description provided for @accountSignOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get accountSignOutConfirmTitle;

  /// No description provided for @accountSignOutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to sign in again to keep using the app.'**
  String get accountSignOutConfirmMessage;

  /// No description provided for @accountDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get accountDeleteAccount;

  /// App version line in the Account tab footer (F4-01).
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String accountVersion(String version);

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

  /// No description provided for @phoneOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number (optional)'**
  String get phoneOptionalLabel;

  /// No description provided for @phoneOptionalHint.
  ///
  /// In en, this message translates to:
  /// **'Optional — for account support only'**
  String get phoneOptionalHint;

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

  /// No description provided for @accountEmailLockedHint.
  ///
  /// In en, this message translates to:
  /// **'Email used to sign in — cannot be changed'**
  String get accountEmailLockedHint;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get commonLater;

  /// No description provided for @cameraPermissionRationaleTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera access needed'**
  String get cameraPermissionRationaleTitle;

  /// No description provided for @cameraPermissionRationaleBody.
  ///
  /// In en, this message translates to:
  /// **'ZenPack needs the camera to record packing-evidence videos for your orders.'**
  String get cameraPermissionRationaleBody;

  /// No description provided for @cameraPermissionDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Can\'t record yet'**
  String get cameraPermissionDeniedTitle;

  /// No description provided for @cameraPermissionDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'ZenPack can\'t record video because camera access hasn\'t been granted. You can still browse, search and manage your orders.'**
  String get cameraPermissionDeniedBody;

  /// No description provided for @cameraPermissionOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get cameraPermissionOpenSettings;

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

  /// No description provided for @quotaRemainingThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Remaining this month'**
  String get quotaRemainingThisMonth;

  /// No description provided for @quotaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track the storage you are using'**
  String get quotaSubtitle;

  /// No description provided for @quotaRemainingAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} remaining'**
  String quotaRemainingAmount(String amount);

  /// No description provided for @quotaStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get quotaStorage;

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
  /// **'All your videos, shipments and dossiers will be permanently deleted. This action cannot be undone.'**
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
  /// **'Step 1/2 — will ask for confirmation again'**
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
  /// **'At least 8 characters'**
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
  /// **'You\'ll be signed out of other devices after changing'**
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

  /// No description provided for @navClaims.
  ///
  /// In en, this message translates to:
  /// **'Claims'**
  String get navClaims;

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

  /// No description provided for @quotaUsedRatio.
  ///
  /// In en, this message translates to:
  /// **'Used {used} / {cap} · {percent}%'**
  String quotaUsedRatio(String used, String cap, int percent);

  /// No description provided for @quotaVideosStored.
  ///
  /// In en, this message translates to:
  /// **'Videos stored'**
  String get quotaVideosStored;

  /// No description provided for @quotaVideosStoredCount.
  ///
  /// In en, this message translates to:
  /// **'{count} videos'**
  String quotaVideosStoredCount(int count);

  /// No description provided for @quotaByType.
  ///
  /// In en, this message translates to:
  /// **'Storage by type'**
  String get quotaByType;

  /// No description provided for @quotaByTypeVideosCount.
  ///
  /// In en, this message translates to:
  /// **'{count} videos stored'**
  String quotaByTypeVideosCount(int count);

  /// No description provided for @quotaRefundNote.
  ///
  /// In en, this message translates to:
  /// **'Storage is freed once a video passes its {days}-day retention window'**
  String quotaRefundNote(int days);

  /// No description provided for @deletePendingProfilesWarning.
  ///
  /// In en, this message translates to:
  /// **'You still have {count} dossiers “sent to the platform” — their share links will stop working'**
  String deletePendingProfilesWarning(int count);

  /// No description provided for @detailRecordedTime.
  ///
  /// In en, this message translates to:
  /// **'Recording time'**
  String get detailRecordedTime;

  /// No description provided for @detailDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get detailDuration;

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

  /// No description provided for @detailSeal.
  ///
  /// In en, this message translates to:
  /// **'Seal'**
  String get detailSeal;

  /// Says the outcome ("locked") rather than the mechanism ("sealed"): a seller buys tamper-evidence, not vocabulary.
  ///
  /// In en, this message translates to:
  /// **'Locked · {at}'**
  String sealSealed(String at);

  /// No description provided for @sealWorking.
  ///
  /// In en, this message translates to:
  /// **'Stamping the timestamp…'**
  String get sealWorking;

  /// No description provided for @sealWorkingHint.
  ///
  /// In en, this message translates to:
  /// **'The stored copy has no timestamp burned in yet, so the share link and download wait for it. Usually a few seconds.'**
  String get sealWorkingHint;

  /// No description provided for @playLocalCopyNote.
  ///
  /// In en, this message translates to:
  /// **'Temporary copy on this device — no timestamp on the frames yet'**
  String get playLocalCopyNote;

  /// No description provided for @sealNone.
  ///
  /// In en, this message translates to:
  /// **'Recorded before sealing existed'**
  String get sealNone;

  /// No description provided for @sealFailed.
  ///
  /// In en, this message translates to:
  /// **'No timestamp stamped yet · the video still plays and downloads'**
  String get sealFailed;

  /// No description provided for @sealMismatch.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint mismatch — re-record this clip'**
  String get sealMismatch;

  /// No description provided for @sealTimeDrift.
  ///
  /// In en, this message translates to:
  /// **'The camera clock drifted from the server, so the burned-in stamp also carries the time the server received the clip.'**
  String get sealTimeDrift;

  /// No description provided for @detailSealAnchor.
  ///
  /// In en, this message translates to:
  /// **'Independent proof'**
  String get detailSealAnchor;

  /// Never says blockchain/Bitcoin on the seller's screen; the terminology lives on the verification page, whose reader is a marketplace agent who chose to open the details.
  ///
  /// In en, this message translates to:
  /// **'Yes · entry #{block}'**
  String sealAnchorConfirmed(String block);

  /// No description provided for @sealAnchorConfirmedNoBlock.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get sealAnchorConfirmedNoBlock;

  /// No description provided for @sealAnchorPending.
  ///
  /// In en, this message translates to:
  /// **'Being written to the public ledger (a few hours)'**
  String get sealAnchorPending;

  /// No description provided for @sealAnchorNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get sealAnchorNone;

  /// No description provided for @sealVerifyOpen.
  ///
  /// In en, this message translates to:
  /// **'Open verification page'**
  String get sealVerifyOpen;

  /// No description provided for @sealVerifyHint.
  ///
  /// In en, this message translates to:
  /// **'Send this link to the marketplace — they can verify it themselves, without trusting ZenPack.'**
  String get sealVerifyHint;

  /// No description provided for @sealVerifyFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the verification page.'**
  String get sealVerifyFailed;

  /// No description provided for @detailPlayVideo.
  ///
  /// In en, this message translates to:
  /// **'Play video'**
  String get detailPlayVideo;

  /// No description provided for @detailCopyAssetLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get detailCopyAssetLink;

  /// No description provided for @assetLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Evidence link'**
  String get assetLinkTitle;

  /// No description provided for @detailDownloadVideo.
  ///
  /// In en, this message translates to:
  /// **'Download video'**
  String get detailDownloadVideo;

  /// No description provided for @detailDownloadNote.
  ///
  /// In en, this message translates to:
  /// **'Owner/manager only · for when the marketplace asks for the original file'**
  String get detailDownloadNote;

  /// No description provided for @detailTrimVideo.
  ///
  /// In en, this message translates to:
  /// **'Trim a short clip to send'**
  String get detailTrimVideo;

  /// No description provided for @detailTrimNote.
  ///
  /// In en, this message translates to:
  /// **'The full clip stays untouched · the trimmed one keeps its timestamp'**
  String get detailTrimNote;

  /// No description provided for @trimSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get trimSave;

  /// No description provided for @trimEstimatedSize.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get trimEstimatedSize;

  /// No description provided for @trimFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not trim the video. The full clip is still there.'**
  String get trimFailed;

  /// No description provided for @trimPreparing.
  ///
  /// In en, this message translates to:
  /// **'Downloading the full clip…'**
  String get trimPreparing;

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

  /// No description provided for @deleteVideoAction.
  ///
  /// In en, this message translates to:
  /// **'Delete video'**
  String get deleteVideoAction;

  /// No description provided for @deletePhotoAction.
  ///
  /// In en, this message translates to:
  /// **'Delete photo'**
  String get deletePhotoAction;

  /// No description provided for @deleteVideoNote.
  ///
  /// In en, this message translates to:
  /// **'Owner/manager only · locked while a dossier is open · two-step confirm'**
  String get deleteVideoNote;

  /// No description provided for @deleteVideoConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Final confirmation'**
  String get deleteVideoConfirmTitle;

  /// No description provided for @deleteVideoConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This evidence will be permanently deleted and cannot be recovered — delete anyway?'**
  String get deleteVideoConfirmBody;

  /// No description provided for @deleteVideoConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deleteVideoConfirmAction;

  /// No description provided for @ordersErrorCount.
  ///
  /// In en, this message translates to:
  /// **'· {count} errors'**
  String ordersErrorCount(int count);

  /// No description provided for @ordersPendingCount.
  ///
  /// In en, this message translates to:
  /// **'· {count} pending'**
  String ordersPendingCount(int count);

  /// No description provided for @ordersPendingEvidenceWarning.
  ///
  /// In en, this message translates to:
  /// **'{count} evidence not uploaded · no copyable link yet'**
  String ordersPendingEvidenceWarning(int count);

  /// No description provided for @captureFramePrompt.
  ///
  /// In en, this message translates to:
  /// **'Scan the tracking code'**
  String get captureFramePrompt;

  /// No description provided for @captureCameraDownHint.
  ///
  /// In en, this message translates to:
  /// **'Place the bill in the frame'**
  String get captureCameraDownHint;

  /// No description provided for @cutoverSavedVideo.
  ///
  /// In en, this message translates to:
  /// **'Video saved'**
  String get cutoverSavedVideo;

  /// No description provided for @cutoverPreparingNext.
  ///
  /// In en, this message translates to:
  /// **'Getting ready for the next one'**
  String get cutoverPreparingNext;

  /// No description provided for @cutoverNextOrder.
  ///
  /// In en, this message translates to:
  /// **'Next order'**
  String get cutoverNextOrder;

  /// No description provided for @lowStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage almost full'**
  String get lowStorageTitle;

  /// No description provided for @lowStorageBody.
  ///
  /// In en, this message translates to:
  /// **'This device is low on storage — an in-progress recording may not save fully. Free up some space before continuing to record.'**
  String get lowStorageBody;

  /// No description provided for @lowStorageAction.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get lowStorageAction;

  /// No description provided for @cutoverClosedSummary.
  ///
  /// In en, this message translates to:
  /// **'Closed tracking code {code} ({duration})'**
  String cutoverClosedSummary(String code, String duration);

  /// No description provided for @cutoverSignalText.
  ///
  /// In en, this message translates to:
  /// **'Sound + vibration on order handoff'**
  String get cutoverSignalText;

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
  /// **'Monthly allowance used up. Recording still works, but these clips are ON THIS PHONE and not protected yet — they upload by themselves once the allowance is raised.'**
  String get quotaExhaustedNote;

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
  /// **'Waiting for allowance · still on device'**
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

  /// No description provided for @queueClearAction.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get queueClearAction;

  /// No description provided for @queueClearConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear the whole queue?'**
  String get queueClearConfirmTitle;

  /// No description provided for @queueClearConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Clips that have not uploaded live only on this phone. Clearing removes them for good.'**
  String get queueClearConfirmBody;

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
  /// **'Enter tracking code'**
  String get manualTrackingTitle;

  /// No description provided for @manualTrackingNote.
  ///
  /// In en, this message translates to:
  /// **'Type it in or scan the code again'**
  String get manualTrackingNote;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

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
  /// **'Pick the right type — add/edit/delete in Shop details'**
  String get videoTypeSelectNote;

  /// No description provided for @videoTypeSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a video type'**
  String get videoTypeSheetTitle;

  /// No description provided for @videoTypeGroupDefault.
  ///
  /// In en, this message translates to:
  /// **'Default types (required)'**
  String get videoTypeGroupDefault;

  /// No description provided for @videoTypeGroupCustom.
  ///
  /// In en, this message translates to:
  /// **'Shop\'s custom types'**
  String get videoTypeGroupCustom;

  /// No description provided for @manageVideoTypesNote.
  ///
  /// In en, this message translates to:
  /// **'Manage video types — open Shop details'**
  String get manageVideoTypesNote;

  /// No description provided for @queueFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All ({count})'**
  String queueFilterAll(int count);

  /// No description provided for @queueFilterUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading ({count})'**
  String queueFilterUploading(int count);

  /// No description provided for @queueFilterErrored.
  ///
  /// In en, this message translates to:
  /// **'Errors ({count})'**
  String queueFilterErrored(int count);

  /// No description provided for @queueFilterQuotaWait.
  ///
  /// In en, this message translates to:
  /// **'Waiting for allowance ({count})'**
  String queueFilterQuotaWait(int count);

  /// No description provided for @queueSummary.
  ///
  /// In en, this message translates to:
  /// **'{pending} videos waiting · {uploading} uploading · {errored} failed'**
  String queueSummary(int pending, int uploading, int errored);

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

  /// No description provided for @registerWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get registerWithGoogle;

  /// No description provided for @registerWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Apple'**
  String get registerWithApple;

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

  /// No description provided for @registerSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Account created'**
  String get registerSuccessTitle;

  /// No description provided for @registerSuccessVerifyMessage.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification email to {email}. Check your inbox (including spam), then sign in.'**
  String registerSuccessVerifyMessage(String email);

  /// No description provided for @registerSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account is ready. Sign in with the email and password you just registered.'**
  String get registerSuccessMessage;

  /// No description provided for @registerSuccessAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get registerSuccessAction;

  /// No description provided for @loginNotVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Email not verified'**
  String get loginNotVerifiedTitle;

  /// No description provided for @loginNotVerifiedMessage.
  ///
  /// In en, this message translates to:
  /// **'Open the verification email sent to {email} (check spam too), follow the link, then sign in again.'**
  String loginNotVerifiedMessage(String email);

  /// No description provided for @loginResendVerification.
  ///
  /// In en, this message translates to:
  /// **'Resend email'**
  String get loginResendVerification;

  /// No description provided for @loginVerificationResent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent again'**
  String get loginVerificationResent;

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
  /// **'Add a new shop'**
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
  /// **'Enter the email of a registered ZenPack account. They get an invitation and must confirm it to join the shop.'**
  String get addMemberBody;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an email address.'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter one valid email address.'**
  String get emailInvalid;

  /// No description provided for @errorInviteAccountNotFound.
  ///
  /// In en, this message translates to:
  /// **'This email has no ZenPack account yet. Ask them to sign up first, then invite again.'**
  String get errorInviteAccountNotFound;

  /// No description provided for @errorInviteAlreadyMember.
  ///
  /// In en, this message translates to:
  /// **'They are already a member of this shop.'**
  String get errorInviteAlreadyMember;

  /// No description provided for @errorInviteMemberLimit.
  ///
  /// In en, this message translates to:
  /// **'This plan\'s member limit is full. Pending invites count toward it — revoke one to free a slot.'**
  String get errorInviteMemberLimit;

  /// No description provided for @errorInviteAlreadyOwner.
  ///
  /// In en, this message translates to:
  /// **'That is the shop owner — no invite needed.'**
  String get errorInviteAlreadyOwner;

  /// No description provided for @errorInviteInvalidRequest.
  ///
  /// In en, this message translates to:
  /// **'That email isn\'t valid. Check it and send again.'**
  String get errorInviteInvalidRequest;

  /// No description provided for @addMemberSubmit.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addMemberSubmit;

  /// No description provided for @memberOwnerLocked.
  ///
  /// In en, this message translates to:
  /// **'The owner cannot be re-roled or removed here — ownership belongs to the shop, not to a membership row.'**
  String get memberOwnerLocked;

  /// No description provided for @removeFromShop.
  ///
  /// In en, this message translates to:
  /// **'Remove from shop'**
  String get removeFromShop;

  /// No description provided for @revokeInvite.
  ///
  /// In en, this message translates to:
  /// **'Delete invitation'**
  String get revokeInvite;

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

  /// No description provided for @ordersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Enter tracking code'**
  String get ordersSearchHint;

  /// No description provided for @ordersEmpty.
  ///
  /// In en, this message translates to:
  /// **'This shop has no orders yet'**
  String get ordersEmpty;

  /// No description provided for @recordAutoStopIn.
  ///
  /// In en, this message translates to:
  /// **'Auto-stops in {time}'**
  String recordAutoStopIn(String time);

  /// No description provided for @ordersNotFound.
  ///
  /// In en, this message translates to:
  /// **'No orders found'**
  String get ordersNotFound;

  /// No description provided for @ordersNotFoundHint.
  ///
  /// In en, this message translates to:
  /// **'Double-check the tracking code and try again'**
  String get ordersNotFoundHint;

  /// Orders list pagination footer (F2-01).
  ///
  /// In en, this message translates to:
  /// **'{first}–{last} of {total} orders'**
  String ordersPageRange(int first, int last, int total);

  /// No description provided for @ordersPagePrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get ordersPagePrevious;

  /// No description provided for @ordersPageNext.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get ordersPageNext;

  /// No description provided for @ordersPageNumber.
  ///
  /// In en, this message translates to:
  /// **'Page {page}'**
  String ordersPageNumber(int page);

  /// No description provided for @filterStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
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

  /// No description provided for @filterTimeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get filterTimeYesterday;

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

  /// No description provided for @filterTimePickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date…'**
  String get filterTimePickDate;

  /// No description provided for @filterTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Video type'**
  String get filterTypeLabel;

  /// No description provided for @filterTypeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
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

  /// Splash tagline, line 1 of 3.
  ///
  /// In en, this message translates to:
  /// **'Every parcel.'**
  String get onboardingTaglineOne;

  /// Splash tagline, line 2 of 3.
  ///
  /// In en, this message translates to:
  /// **'One proof.'**
  String get onboardingTaglineTwo;

  /// Splash tagline, line 3 of 3.
  ///
  /// In en, this message translates to:
  /// **'Protecting your revenue.'**
  String get onboardingTaglineThree;

  /// Placeholder inside the email field.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get authEmailPlaceholder;

  /// Placeholder inside the password field.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authPasswordPlaceholder;

  /// Register screen: registerCreateAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new account'**
  String get registerCreateAccountSubtitle;

  /// Register screen: registerFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get registerFullName;

  /// Register screen: registerFullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get registerFullNameRequired;

  /// Register screen: registerAgreePrefix.
  ///
  /// In en, this message translates to:
  /// **'I agree to the'**
  String get registerAgreePrefix;

  /// Register screen: registerTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get registerTermsOfUse;

  /// Shop layer: shopChooseTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a shop'**
  String get shopChooseTitle;

  /// Shop layer: shopChooseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a shop to continue'**
  String get shopChooseSubtitle;

  /// Shop layer: shopManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage shops'**
  String get shopManageTitle;

  /// Shop layer: shopManageOwnerOnly.
  ///
  /// In en, this message translates to:
  /// **'Visible to shop owners and managers only'**
  String get shopManageOwnerOnly;

  /// Shop layer: noShopTitle.
  ///
  /// In en, this message translates to:
  /// **'No shops yet'**
  String get noShopTitle;

  /// Shop layer: noShopLineOne.
  ///
  /// In en, this message translates to:
  /// **'Your account does not belong to a shop yet.'**
  String get noShopLineOne;

  /// Shop layer: noShopLineTwo.
  ///
  /// In en, this message translates to:
  /// **'Create a shop to get started,'**
  String get noShopLineTwo;

  /// Shop layer: noShopLineThree.
  ///
  /// In en, this message translates to:
  /// **'or wait for an invite from a shop owner.'**
  String get noShopLineThree;

  /// Shop layer: noShopCreateCta.
  ///
  /// In en, this message translates to:
  /// **'Create a shop (name + marketplace)'**
  String get noShopCreateCta;

  /// Shop layer: noShopInviteHint.
  ///
  /// In en, this message translates to:
  /// **'Shop invites will appear here'**
  String get noShopInviteHint;

  /// Create-shop screen: createShopTitle.
  ///
  /// In en, this message translates to:
  /// **'Create shop'**
  String get createShopTitle;

  /// Create-shop screen: createShopNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Shop name'**
  String get createShopNameLabel;

  /// Create-shop screen: createShopNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Shop ABC'**
  String get createShopNameHint;

  /// Create-shop screen: createShopPlatformLabel.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get createShopPlatformLabel;

  /// Create-shop screen: createShopOwnerNote.
  ///
  /// In en, this message translates to:
  /// **'You will be the shop owner — add members later under Manage shops'**
  String get createShopOwnerNote;

  /// Create-shop screen: createShopSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create shop'**
  String get createShopSubmit;

  /// Shop management: shopManageDescription.
  ///
  /// In en, this message translates to:
  /// **'View and manage the shops you administer.'**
  String get shopManageDescription;

  /// Shop management: shopManageAddCta.
  ///
  /// In en, this message translates to:
  /// **'Add a shop'**
  String get shopManageAddCta;

  /// Shop management: shopManageStaffNote.
  ///
  /// In en, this message translates to:
  /// **'Staff cannot see this screen — owners and shop managers only.'**
  String get shopManageStaffNote;

  /// Shop detail: shopDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop detail'**
  String get shopDetailTitle;

  /// Shop detail: shopDetailResolution.
  ///
  /// In en, this message translates to:
  /// **'Recording resolution'**
  String get shopDetailResolution;

  /// Shop detail / clip budget (FR-17..FR-20).
  ///
  /// In en, this message translates to:
  /// **'Max length/video'**
  String get shopDetailClipDuration;

  /// Shop detail / clip budget (FR-17..FR-20).
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String clipDurationValue(String minutes);

  /// Shop detail / clip budget (FR-17..FR-20).
  ///
  /// In en, this message translates to:
  /// **'Recommended {minutes} min — for {platform} ({megabytes} MB/video) + {resolution}'**
  String clipRecommendedHint(
    String minutes,
    String platform,
    String megabytes,
    String resolution,
  );

  /// Shop detail / clip budget (FR-17..FR-20).
  ///
  /// In en, this message translates to:
  /// **'Recommended {minutes} min — {platform} limits unconfirmed, using the safest known values'**
  String clipRecommendedHintUnverified(String minutes, String platform);

  /// Shop detail / clip budget (FR-17..FR-20).
  ///
  /// In en, this message translates to:
  /// **'Over the {minutes}-min recommendation for {platform} — a {chosen}-min video is ~{megabytes} MB, so it has to be sent as a dossier link instead of attached to the complaint form.'**
  String clipOverRecommendedWarning(
    String minutes,
    String platform,
    String chosen,
    String megabytes,
  );

  /// Shop detail / clip budget (FR-17..FR-20).
  ///
  /// In en, this message translates to:
  /// **'Max length per video'**
  String get clipDurationTitle;

  /// Shop detail / clip budget (FR-17..FR-20).
  ///
  /// In en, this message translates to:
  /// **'Auto-closes at this length'**
  String get clipDurationSubtitle;

  /// Shop detail / clip budget (FR-17..FR-20).
  ///
  /// In en, this message translates to:
  /// **'Your plan allows up to {minutes} min'**
  String clipDurationPlanCap(String minutes);

  /// Shop detail / clip budget (FR-17..FR-20).
  ///
  /// In en, this message translates to:
  /// **'Max length/video: {minutes} min'**
  String clipDurationChanged(String minutes);

  /// No description provided for @shopDetailImageSize.
  ///
  /// In en, this message translates to:
  /// **'Image size'**
  String get shopDetailImageSize;

  /// No description provided for @shopDetailVideoSize.
  ///
  /// In en, this message translates to:
  /// **'Video size'**
  String get shopDetailVideoSize;

  /// Shop detail / upload size cap (FR-21).
  ///
  /// In en, this message translates to:
  /// **'Max size/file'**
  String get shopDetailUploadSize;

  /// Shop detail / upload size cap (FR-21).
  ///
  /// In en, this message translates to:
  /// **'{megabytes} MB'**
  String uploadSizeValue(String megabytes);

  /// Shop detail / upload size cap (FR-21).
  ///
  /// In en, this message translates to:
  /// **'Recommended {megabytes} MB — {platform}\'s attachment limit'**
  String uploadRecommendedHint(String megabytes, String platform);

  /// Shop detail / upload size cap (FR-21).
  ///
  /// In en, this message translates to:
  /// **'Over the {megabytes} MB recommendation for {platform} — a file up to {chosen} MB is still stored in full, but has to be sent as a dossier link instead of attached to the complaint form.'**
  String uploadOverRecommendedWarning(
    String megabytes,
    String platform,
    String chosen,
  );

  /// No description provided for @uploadSizeValueUnlimited.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get uploadSizeValueUnlimited;

  /// Shop detail / upload size cap (FR-21).
  ///
  /// In en, this message translates to:
  /// **'Max size per file'**
  String get uploadSizeTitle;

  /// Shop detail / upload size cap (FR-21).
  ///
  /// In en, this message translates to:
  /// **'Files over the cap are not attached; {megabytes} MB still attaches directly to {platform}'**
  String uploadSizeSubtitle(String megabytes, String platform);

  /// Shop detail / upload size cap (FR-21).
  ///
  /// In en, this message translates to:
  /// **'{megabytes} MB (recommended)'**
  String uploadSizeOptionRecommended(String megabytes);

  /// Shop detail / upload size cap (FR-21).
  ///
  /// In en, this message translates to:
  /// **'Size per file: {megabytes}'**
  String uploadSizeChanged(String megabytes);

  /// Avatar file exceeds the backend's size cap.
  ///
  /// In en, this message translates to:
  /// **'Name and phone saved. The {megabytes} MB profile photo is over the {limit} MB cap, so it didn\'t reach the server — pick a smaller image.'**
  String avatarTooLarge(String megabytes, String limit);

  /// Avatar upload failed for another reason; profile still saved.
  ///
  /// In en, this message translates to:
  /// **'Name and phone saved. The profile photo didn\'t reach the server: {reason}'**
  String avatarUploadFailed(String reason);

  /// Recording: near-cap warning banner (FR-01).
  ///
  /// In en, this message translates to:
  /// **'Nearing the {minutes}-min cap — the video will close itself'**
  String nearClipLimitWarning(String minutes);

  /// Shop detail: shopDetailAddType.
  ///
  /// In en, this message translates to:
  /// **'Add a type (enter a name)'**
  String get shopDetailAddType;

  /// Shop detail: inviteMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite a member'**
  String get inviteMemberTitle;

  /// No description provided for @inviteRoleFixedNote.
  ///
  /// In en, this message translates to:
  /// **'They join as a staff member: record videos and review their own.'**
  String get inviteRoleFixedNote;

  /// Shop detail: inviteMemberHint.
  ///
  /// In en, this message translates to:
  /// **'(no account yet → send an invite)'**
  String get inviteMemberHint;

  /// Video type dialogs: videoTypeIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get videoTypeIcon;

  /// Video type dialogs: videoTypeColor.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get videoTypeColor;

  /// Video type dialogs: createVideoTypeSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create type'**
  String get createVideoTypeSubmit;

  /// Video type dialogs: deleteVideoTypeSafeNote.
  ///
  /// In en, this message translates to:
  /// **'No evidence is lost'**
  String get deleteVideoTypeSafeNote;

  /// Generic confirm action.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// Badge on an order row whose uploads failed.
  ///
  /// In en, this message translates to:
  /// **'{count} failed'**
  String orderErrorCount(int count);

  /// Title of the video-detail sheet.
  ///
  /// In en, this message translates to:
  /// **'Video detail'**
  String get videoDetailSheetTitle;

  /// Shutter button label while recording.
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get tooltipStopRecording;

  /// Shareable dossier link card.
  ///
  /// In en, this message translates to:
  /// **'Dispute dossier link'**
  String get dossierLinkTitle;

  /// No description provided for @accountEndQr.
  ///
  /// In en, this message translates to:
  /// **'Stop-recording code'**
  String get accountEndQr;

  /// No description provided for @accountEndQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop-recording code'**
  String get accountEndQrTitle;

  /// No description provided for @accountEndQrShare.
  ///
  /// In en, this message translates to:
  /// **'Share code'**
  String get accountEndQrShare;

  /// No description provided for @accountEndQrSave.
  ///
  /// In en, this message translates to:
  /// **'Save to photo library'**
  String get accountEndQrSave;

  /// No description provided for @recordInterruptedTitle.
  ///
  /// In en, this message translates to:
  /// **'Recording paused'**
  String get recordInterruptedTitle;

  /// No description provided for @recordInterruptedBody.
  ///
  /// In en, this message translates to:
  /// **'Recording paused because something interrupted it. Continue recording?'**
  String get recordInterruptedBody;

  /// No description provided for @recordInterruptedResume.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get recordInterruptedResume;

  /// No description provided for @recordInterruptedFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get recordInterruptedFinish;

  /// No description provided for @commonApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get commonApply;

  /// No description provided for @unitMinutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get unitMinutes;

  /// No description provided for @clipDurationCustomLabel.
  ///
  /// In en, this message translates to:
  /// **'Or enter the number of minutes you want'**
  String get clipDurationCustomLabel;

  /// No description provided for @supportOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t open — check the app is installed'**
  String get supportOpenFailed;

  /// No description provided for @feedbackThanksTitle.
  ///
  /// In en, this message translates to:
  /// **'Thank you!'**
  String get feedbackThanksTitle;

  /// No description provided for @feedbackThanksBody.
  ///
  /// In en, this message translates to:
  /// **'Your feedback helps make ZenPack better.'**
  String get feedbackThanksBody;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'What would you like to share with us?'**
  String get feedbackTitle;

  /// No description provided for @feedbackHint.
  ///
  /// In en, this message translates to:
  /// **'Type your feedback...'**
  String get feedbackHint;

  /// No description provided for @feedbackSend.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get feedbackSend;

  /// No description provided for @feedbackThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your feedback'**
  String get feedbackThanks;

  /// No description provided for @accountSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get accountSectionAbout;

  /// No description provided for @accountFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send us feedback'**
  String get accountFeedback;

  /// No description provided for @accountFeedbackNote.
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts to make ZenPack better'**
  String get accountFeedbackNote;

  /// No description provided for @accountRateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate the app'**
  String get accountRateApp;

  /// No description provided for @accountRateAppNote.
  ///
  /// In en, this message translates to:
  /// **'Support ZenPack development'**
  String get accountRateAppNote;

  /// No description provided for @supportFacebook.
  ///
  /// In en, this message translates to:
  /// **'Message on Facebook'**
  String get supportFacebook;

  /// No description provided for @supportZalo.
  ///
  /// In en, this message translates to:
  /// **'Message on Zalo'**
  String get supportZalo;

  /// No description provided for @supportCall.
  ///
  /// In en, this message translates to:
  /// **'Call support'**
  String get supportCall;

  /// No description provided for @sheetCustomMin.
  ///
  /// In en, this message translates to:
  /// **'Enter {min} {unit} or more'**
  String sheetCustomMin(String min, String unit);

  /// No description provided for @sheetCustomRange.
  ///
  /// In en, this message translates to:
  /// **'Enter between {min} and {max} {unit}'**
  String sheetCustomRange(String min, String max, String unit);

  /// No description provided for @accountEndQrNote.
  ///
  /// In en, this message translates to:
  /// **'Print this and stick it on the packing table. Scanning it while recording closes the clip. The same code works on every device.'**
  String get accountEndQrNote;

  /// Caption under the language screen illustration.
  ///
  /// In en, this message translates to:
  /// **'Every label, notification and dossier\nswitches to the language you pick.'**
  String get languageChangeScopeNote;

  /// Inline error when Bắt đầu quay is tapped with an empty tracking-code field.
  ///
  /// In en, this message translates to:
  /// **'Enter a tracking code before recording'**
  String get manualEntryEmptyError;

  /// Fallback title of the update dialog when Remote Config supplies none.
  ///
  /// In en, this message translates to:
  /// **'A new version is available'**
  String get appUpdateTitle;

  /// Fallback body of the update dialog when Remote Config supplies none.
  ///
  /// In en, this message translates to:
  /// **'Update ZenPack for the latest fixes and features.'**
  String get appUpdateMessage;

  /// No description provided for @appUpdateNow.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get appUpdateNow;

  /// No description provided for @appUpdateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get appUpdateLater;

  /// No description provided for @quotaVideosThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Videos this month'**
  String get quotaVideosThisMonth;

  /// No description provided for @quotaSubtitleVideos.
  ///
  /// In en, this message translates to:
  /// **'Track how many videos you recorded this month'**
  String get quotaSubtitleVideos;

  /// No description provided for @quotaUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade plan'**
  String get quotaUpgrade;

  /// No description provided for @quotaBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Video allowance exhausted'**
  String get quotaBlockedTitle;

  /// No description provided for @quotaBlockedNote.
  ///
  /// In en, this message translates to:
  /// **'Recording still works, but clips cannot upload yet — they are sitting on this phone, unprotected. They upload by themselves once the allowance is raised.'**
  String get quotaBlockedNote;

  /// No description provided for @quotaBlockedOwnerNote.
  ///
  /// In en, this message translates to:
  /// **'This shop’s allowance is set by the account owner — ask them to raise it. A plan you buy applies to your own account only.'**
  String get quotaBlockedOwnerNote;

  /// No description provided for @quotaTopupCredits.
  ///
  /// In en, this message translates to:
  /// **'Top-up credits'**
  String get quotaTopupCredits;

  /// No description provided for @quotaOverCap.
  ///
  /// In en, this message translates to:
  /// **'Over plan allowance'**
  String get quotaOverCap;

  /// No description provided for @quotaBlockAt.
  ///
  /// In en, this message translates to:
  /// **'New recordings blocked at {n} videos'**
  String quotaBlockAt(int n);

  /// No description provided for @quotaResetMonthly.
  ///
  /// In en, this message translates to:
  /// **'Resets at the start of next month; nothing carries over'**
  String get quotaResetMonthly;

  /// No description provided for @storageOwnTitle.
  ///
  /// In en, this message translates to:
  /// **'Your own storage'**
  String get storageOwnTitle;

  /// No description provided for @storageOwnPending.
  ///
  /// In en, this message translates to:
  /// **'{count} videos waiting to be pushed to your storage'**
  String storageOwnPending(int count);

  /// No description provided for @storageOwnProblem.
  ///
  /// In en, this message translates to:
  /// **'{count} videos in your storage have problems'**
  String storageOwnProblem(int count);

  /// No description provided for @quotaExhaustedWarn.
  ///
  /// In en, this message translates to:
  /// **'Don\'t uninstall the app or clear its data until they have uploaded.'**
  String get quotaExhaustedWarn;

  /// No description provided for @quotaStrandedTitle.
  ///
  /// In en, this message translates to:
  /// **'{count} videos waiting on this phone'**
  String quotaStrandedTitle(int count);

  /// No description provided for @quotaStrandedNote.
  ///
  /// In en, this message translates to:
  /// **'These videos exist only on this phone. Losing it, uninstalling the app or clearing its data loses them.'**
  String get quotaStrandedNote;

  /// No description provided for @storageTitle.
  ///
  /// In en, this message translates to:
  /// **'Video storage'**
  String get storageTitle;

  /// No description provided for @storageSave.
  ///
  /// In en, this message translates to:
  /// **'Save storage choice'**
  String get storageSave;

  /// No description provided for @storageSystemName.
  ///
  /// In en, this message translates to:
  /// **'System storage'**
  String get storageSystemName;

  /// No description provided for @storageS3Name.
  ///
  /// In en, this message translates to:
  /// **'Your own storage (S3)'**
  String get storageS3Name;

  /// No description provided for @storageDriveName.
  ///
  /// In en, this message translates to:
  /// **'Your Google Drive'**
  String get storageDriveName;

  /// No description provided for @storageSystemDesc.
  ///
  /// In en, this message translates to:
  /// **'The default; nothing to configure. It is the only place where every evidence commitment holds.'**
  String get storageSystemDesc;

  /// No description provided for @storageOwnDesc.
  ///
  /// In en, this message translates to:
  /// **'New videos go straight to your storage. Older ones stay where they are until their retention ends.'**
  String get storageOwnDesc;

  /// No description provided for @storageNoPresign.
  ///
  /// In en, this message translates to:
  /// **'This storage cannot sign download links, so videos must be relayed through the server — whoever opens your link will find it slower.'**
  String get storageNoPresign;

  /// No description provided for @storageNoObjectLock.
  ///
  /// In en, this message translates to:
  /// **'This storage has no object lock. You cannot promise a marketplace that the evidence is undeletable.'**
  String get storageNoObjectLock;

  /// No description provided for @storageNotInPlan.
  ///
  /// In en, this message translates to:
  /// **'Your plan does not include custom storage yet. Upgrade on the web to use it.'**
  String get storageNotInPlan;

  /// No description provided for @storageHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage health'**
  String get storageHealthTitle;

  /// No description provided for @storageHealthTotal.
  ///
  /// In en, this message translates to:
  /// **'Total videos'**
  String get storageHealthTotal;

  /// No description provided for @storageHealthIntact.
  ///
  /// In en, this message translates to:
  /// **'Intact'**
  String get storageHealthIntact;

  /// No description provided for @storageHealthUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Unreachable'**
  String get storageHealthUnreachable;

  /// No description provided for @storageHealthMismatched.
  ///
  /// In en, this message translates to:
  /// **'Mismatched against the seal'**
  String get storageHealthMismatched;

  /// No description provided for @storageHealthPendingRelay.
  ///
  /// In en, this message translates to:
  /// **'Waiting in the relay area'**
  String get storageHealthPendingRelay;

  /// No description provided for @storageProblemsNote.
  ///
  /// In en, this message translates to:
  /// **'Some videos have problems in your storage. Check the access permissions on the provider side.'**
  String get storageProblemsNote;

  /// No description provided for @storageTest.
  ///
  /// In en, this message translates to:
  /// **'Re-test the connection'**
  String get storageTest;

  /// Nhan tren the kho dang thuc su dung.
  ///
  /// In en, this message translates to:
  /// **'In use'**
  String get storageInUse;

  /// Moc ra soat kho gan nhat.
  ///
  /// In en, this message translates to:
  /// **'Last audit: {time}'**
  String storageLastCheckAt(String time);

  /// Kho chua he duoc ra soat.
  ///
  /// In en, this message translates to:
  /// **'Never audited yet.'**
  String get storageNeverChecked;

  /// Nhan tai khoan Google Drive.
  ///
  /// In en, this message translates to:
  /// **'Drive account'**
  String get storageDriveAccount;

  /// No description provided for @storageDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Stop using custom storage'**
  String get storageDisconnect;

  /// No description provided for @storageDisconnectConfirm.
  ///
  /// In en, this message translates to:
  /// **'Videos recorded from now on go to system storage. Older ones stay in your storage and the system loses its route to them.'**
  String get storageDisconnectConfirm;

  /// No description provided for @storageConnectS3.
  ///
  /// In en, this message translates to:
  /// **'Connect S3 storage'**
  String get storageConnectS3;

  /// No description provided for @storageConnectDrive.
  ///
  /// In en, this message translates to:
  /// **'Connect Google Drive'**
  String get storageConnectDrive;

  /// No description provided for @storageConnectHint.
  ///
  /// In en, this message translates to:
  /// **'Grant read/write/delete on the prefix below only — no permission on the whole bucket is needed.'**
  String get storageConnectHint;

  /// No description provided for @storageConnectSubmit.
  ///
  /// In en, this message translates to:
  /// **'Test and save'**
  String get storageConnectSubmit;

  /// No description provided for @storageFieldEndpoint.
  ///
  /// In en, this message translates to:
  /// **'Endpoint'**
  String get storageFieldEndpoint;

  /// No description provided for @storageFieldBucket.
  ///
  /// In en, this message translates to:
  /// **'Bucket'**
  String get storageFieldBucket;

  /// No description provided for @storageFieldAccessKey.
  ///
  /// In en, this message translates to:
  /// **'Access key ID'**
  String get storageFieldAccessKey;

  /// No description provided for @storageFieldSecretKey.
  ///
  /// In en, this message translates to:
  /// **'Secret access key'**
  String get storageFieldSecretKey;

  /// No description provided for @storageFieldRegion.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get storageFieldRegion;

  /// No description provided for @storageFieldPrefix.
  ///
  /// In en, this message translates to:
  /// **'Prefix'**
  String get storageFieldPrefix;

  /// No description provided for @storageFieldPrefixHint.
  ///
  /// In en, this message translates to:
  /// **'Sub-folder inside the bucket. Leave the default if unsure.'**
  String get storageFieldPrefixHint;

  /// No description provided for @storageConnected.
  ///
  /// In en, this message translates to:
  /// **'Custom storage connected.'**
  String get storageConnected;

  /// No description provided for @storageDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Custom storage disconnected.'**
  String get storageDisconnected;

  /// No description provided for @storageTestOk.
  ///
  /// In en, this message translates to:
  /// **'Connection is healthy.'**
  String get storageTestOk;

  /// No description provided for @storageOwnerOnly.
  ///
  /// In en, this message translates to:
  /// **'Only the shop owner can change storage.'**
  String get storageOwnerOnly;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get dangerZone;

  /// No description provided for @shopDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete shop'**
  String get shopDelete;

  /// No description provided for @shopDeleteDesc.
  ///
  /// In en, this message translates to:
  /// **'Permanently deletes orders, evidence, stored files and members. This cannot be undone.'**
  String get shopDeleteDesc;

  /// No description provided for @shopDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this shop?'**
  String get shopDeleteConfirmTitle;

  /// No description provided for @shopDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'{orders} orders · {videos} videos · {members} members will be permanently deleted.'**
  String shopDeleteConfirmBody(int orders, int videos, int members);

  /// No description provided for @shopDeleteOpenDossiers.
  ///
  /// In en, this message translates to:
  /// **'{n} claim dossiers are still open. Links already sent to marketplaces die the moment you delete.'**
  String shopDeleteOpenDossiers(int n);

  /// No description provided for @shopDeleteForce.
  ///
  /// In en, this message translates to:
  /// **'Delete anyway'**
  String get shopDeleteForce;

  /// No description provided for @shopDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the shop.'**
  String get shopDeleteFailed;

  /// No description provided for @claimsCreatedLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Dossier saved on this phone. It could not be uploaded, so there is no share link yet — reopen it when you are back online.'**
  String get claimsCreatedLocalOnly;

  /// No description provided for @claimsLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Dossier link copied. Paste it into the marketplace claim channel.'**
  String get claimsLinkCopied;

  /// No description provided for @shopRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename shop'**
  String get shopRenameTitle;

  /// No description provided for @shopRenameHint.
  ///
  /// In en, this message translates to:
  /// **'Shop name'**
  String get shopRenameHint;

  /// No description provided for @shopRenamed.
  ///
  /// In en, this message translates to:
  /// **'Shop renamed'**
  String get shopRenamed;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @inviteJoinRow.
  ///
  /// In en, this message translates to:
  /// **'I have an invite'**
  String get inviteJoinRow;

  /// No description provided for @inviteJoinedShop.
  ///
  /// In en, this message translates to:
  /// **'Joined {shop}'**
  String inviteJoinedShop(String shop);

  /// No description provided for @inviteAlreadyJoined.
  ///
  /// In en, this message translates to:
  /// **'You are already in {shop}'**
  String inviteAlreadyJoined(String shop);

  /// No description provided for @inviteBadLink.
  ///
  /// In en, this message translates to:
  /// **'That link is not valid. Paste the whole link from the email.'**
  String get inviteBadLink;

  /// No description provided for @inviteNotFound.
  ///
  /// In en, this message translates to:
  /// **'The invite does not exist or was revoked'**
  String get inviteNotFound;

  /// No description provided for @inviteTaken.
  ///
  /// In en, this message translates to:
  /// **'Someone else already accepted this invite'**
  String get inviteTaken;

  /// No description provided for @inviteExpired.
  ///
  /// In en, this message translates to:
  /// **'The invite has expired. Ask the shop owner to resend it.'**
  String get inviteExpired;

  /// No description provided for @inviteQrRow.
  ///
  /// In en, this message translates to:
  /// **'QR code'**
  String get inviteQrRow;

  /// No description provided for @inviteQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop invite code'**
  String get inviteQrTitle;

  /// No description provided for @inviteQrNote.
  ///
  /// In en, this message translates to:
  /// **'Show this screen to the person you want to invite. The code is single-use — it changes once someone joins.'**
  String get inviteQrNote;

  /// No description provided for @inviteScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan invite code'**
  String get inviteScanTitle;

  /// No description provided for @inviteScanDetail.
  ///
  /// In en, this message translates to:
  /// **'Ask the shop owner to show the invite QR code, then scan it here.'**
  String get inviteScanDetail;

  /// No description provided for @commonShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShare;

  /// No description provided for @inviteQrSaved.
  ///
  /// In en, this message translates to:
  /// **'QR code saved to your gallery'**
  String get inviteQrSaved;

  /// No description provided for @inviteQrSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the QR code'**
  String get inviteQrSaveFailed;

  /// No description provided for @voiceRecordingStarted.
  ///
  /// In en, this message translates to:
  /// **'Recording started'**
  String get voiceRecordingStarted;

  /// No description provided for @voiceRecordingStopped.
  ///
  /// In en, this message translates to:
  /// **'Recording stopped'**
  String get voiceRecordingStopped;

  /// No description provided for @voiceWrongCode.
  ///
  /// In en, this message translates to:
  /// **'Wrong code'**
  String get voiceWrongCode;

  /// No description provided for @voiceCapSoon.
  ///
  /// In en, this message translates to:
  /// **'The clip will close soon'**
  String get voiceCapSoon;

  /// No description provided for @voiceCapNear.
  ///
  /// In en, this message translates to:
  /// **'Approaching the {minutes}-minute limit, the clip will close itself'**
  String voiceCapNear(int minutes);

  /// No description provided for @voiceInterrupted.
  ///
  /// In en, this message translates to:
  /// **'Recording was interrupted'**
  String get voiceInterrupted;

  /// No description provided for @videoTypePacking.
  ///
  /// In en, this message translates to:
  /// **'Packing'**
  String get videoTypePacking;

  /// No description provided for @videoTypeCarrier.
  ///
  /// In en, this message translates to:
  /// **'Carrier handover'**
  String get videoTypeCarrier;

  /// No description provided for @videoTypeReturn.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get videoTypeReturn;

  /// No description provided for @storageIntro.
  ///
  /// In en, this message translates to:
  /// **'Where the shop’s videos live. Wherever they sit, the seal record stays with the system — changing storage never weakens the evidence.'**
  String get storageIntro;

  /// No description provided for @storageS3Title.
  ///
  /// In en, this message translates to:
  /// **'Your own cloud storage (S3-compatible)'**
  String get storageS3Title;

  /// No description provided for @storageS3Desc.
  ///
  /// In en, this message translates to:
  /// **'AWS S3, Cloudflare R2, MinIO, Wasabi… The videos sit in your bucket, and their durability is on you.'**
  String get storageS3Desc;

  /// No description provided for @storageDriveTitle.
  ///
  /// In en, this message translates to:
  /// **'Google Drive'**
  String get storageDriveTitle;

  /// No description provided for @storageDriveDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect with one permission grant, no keys to paste. A free account only has 15 GB shared with Gmail.'**
  String get storageDriveDesc;

  /// No description provided for @storageNeedProPlan.
  ///
  /// In en, this message translates to:
  /// **'Connecting your own storage needs the Professional plan or higher.'**
  String get storageNeedProPlan;

  /// No description provided for @attachCodeToOrder.
  ///
  /// In en, this message translates to:
  /// **'Scan another code into this order'**
  String get attachCodeToOrder;

  /// No description provided for @attachedCodes.
  ///
  /// In en, this message translates to:
  /// **'Attached codes'**
  String get attachedCodes;

  /// No description provided for @codeAttached.
  ///
  /// In en, this message translates to:
  /// **'Code attached to this order'**
  String get codeAttached;

  /// No description provided for @codeBelongsToAnotherOrder.
  ///
  /// In en, this message translates to:
  /// **'This code already belongs to another order — cannot merge.'**
  String get codeBelongsToAnotherOrder;

  /// No description provided for @codeAttachFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not attach the code. Try again.'**
  String get codeAttachFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fil',
    'fr',
    'id',
    'it',
    'ms',
    'th',
    'vi',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fil':
      return AppLocalizationsFil();
    case 'fr':
      return AppLocalizationsFr();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ms':
      return AppLocalizationsMs();
    case 'th':
      return AppLocalizationsTh();
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

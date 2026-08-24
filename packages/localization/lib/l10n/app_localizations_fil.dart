// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Filipino Pilipino (`fil`).
class AppLocalizationsFil extends AppLocalizations {
  AppLocalizationsFil([String locale = 'fil']) : super(locale);

  @override
  String get bundleBackendPending =>
      'Naghihintay ng backend endpoint para dito';

  @override
  String get bundleCreate => 'Gumawa';

  @override
  String get bundleCreateClaim => 'Gumawa ng claim dossier';

  @override
  String get accountClaims => 'Mga claim dossier';

  @override
  String get claimsTitle => 'Mga claim dossier';

  @override
  String get claimsLocalOnlyNote =>
      'May mga dossier na hindi pa naipapadala, kaya nasa device na ito lang.';

  @override
  String get claimsOfflineNote =>
      'Hindi maabot ang server, kaya ito ang kopyang nasa device. Buksang muli kapag may internet.';

  @override
  String get claimsEmpty =>
      'Wala pang dossier. Buksan ang tab na Mga order, pindutin ang plus at pumili ng ebidensiya.';

  @override
  String claimsSummary(int orders, int evidence) {
    return '$orders order · $evidence ebidensiya';
  }

  @override
  String claimsEvidenceOnly(int evidence) {
    return '$evidence ebidensya';
  }

  @override
  String get claimsCopied => 'Nakopya ang laman ng dossier';

  @override
  String get claimsCreated => 'Nagawa na ang claim dossier';

  @override
  String get claimsPickNothing => 'Walang napiling ebidensiya';

  @override
  String get claimsDelete => 'Burahin ang dossier';

  @override
  String get claimsDeleteConfirm =>
      'Burahin ang dossier na ito? Hindi maaapektuhan ang ebidensiya sa mga order mismo.';

  @override
  String get claimsDeleteConfirmLink =>
      'Burahin ang dossier na ito? Mamamatay agad ang pampublikong link nito — sinumang napadalhan mo na ay makakakita ng blangkong pahina. Hindi maaapektuhan ang ebidensiya sa mga order mismo.';

  @override
  String get claimsRevokeFailed =>
      'Hindi mabawi ang link, kaya iniwan ang dossier sa dati. Bukas pa rin ang link — subukan ulit sa mas maayos na koneksyon, o pakiusapan ang may-ari ng shop na bawiin ito.';

  @override
  String get claimsDeleted => 'Nabura ang dossier';

  @override
  String get claimsPhotoAdded =>
      'Naidagdag ang larawan sa dossier at napila sa order';

  @override
  String get claimsAddedLater => 'idinagdag mamaya';

  @override
  String get claimsCreateTitle => 'Bagong claim dossier';

  @override
  String get claimsCreateSearchHint => 'I-type o i-scan ang tracking code';

  @override
  String get claimsCreateNameHint => 'hal. Reklamo sa return 12/08';

  @override
  String get claimsCreateNameLabel => 'Pangalan ng dossier';

  @override
  String get claimInfoTitle => 'Detalye ng dossier';

  @override
  String get claimTrackingLabel => 'Tracking code';

  @override
  String get claimShopLabel => 'Tindahan';

  @override
  String get claimChannelLabel => 'Channel';

  @override
  String get claimOrderCreatedAt => 'Petsa ng order';

  @override
  String get claimEvidenceLabel => 'Ebidensya';

  @override
  String claimEvidenceCount(int videos, int photos) {
    return '$videos video · $photos larawan';
  }

  @override
  String get claimCreatedAtLabel => 'Ginawa ang dossier';

  @override
  String get claimCopyLink => 'Copy link';

  @override
  String get claimsRevokeNoLink =>
      'This dossier is not on the server yet, so there is no link to revoke.';

  @override
  String get claimPageFailed =>
      'Could not open the dossier page. Check your connection and try again.';

  @override
  String get claimLinkLabel => 'Link ng dossier';

  @override
  String get claimLinkHint =>
      'Kahit sino na may link ay makakatingin, walang sign-in. Buhay ito hangga’t hindi mo binabawi.';

  @override
  String get claimRevokedBadge => 'Binawi';

  @override
  String get claimRevokedHint =>
      'Patay na ang link. Buo pa rin ang data — gumawa ng bagong dossier para maibahagi ulit.';

  @override
  String get claimRevoke => 'Bawiin';

  @override
  String get claimUntitled => 'Dossier na walang pangalan';

  @override
  String get claimRevokeConfirmTitle => 'Bawiin ang dossier na ito?';

  @override
  String get claimRevokeConfirmBody =>
      'Mamamatay agad ang link para sa sinumang may hawak nito, pati sa marketplace. Hindi maaapektuhan ang data at mga link kada order.';

  @override
  String get claimRevoked => 'Nabawi ang dossier. Hindi na bumubukas ang link.';

  @override
  String get claimRevokeFailed => 'Hindi mabawi. Subukan ulit kapag online.';

  @override
  String get claimNotUploaded =>
      'Hindi pa na-upload ang dossier na ito kaya wala pang link. Buksan ulit kapag online.';

  @override
  String get claimDetailLoadFailed =>
      'Hindi ma-load ang dossier. Suriin ang koneksyon at buksan ulit.';

  @override
  String get claimsCreateStart =>
      'I-type ang tracking code, o pindutin ang scan, para hanapin ang order na ikinaklaim mo.';

  @override
  String get claimsCreateNoOrder =>
      'Walang order na may ganoong tracking code sa napiling shop.';

  @override
  String get claimsRemoveItemTitle => 'Alisin sa dossier';

  @override
  String get claimsRemoveItemConfirm =>
      'Alisin ang ebidensiyang ito sa claim dossier? Hindi maaapektuhan ang video/larawan sa order mismo.';

  @override
  String get claimsItemRemoved => 'Naalis sa dossier';

  @override
  String get claimsItemAdded => 'Naidagdag sa dossier';

  @override
  String get commonRemove => 'Alisin';

  @override
  String get commonDelete => 'Burahin';

  @override
  String get settingDefaultSuffix => 'default';

  @override
  String get shopDetailClipLength => 'Haba ng video';

  @override
  String get shopDeleteTitle => 'Burahin ang shop';

  @override
  String get shopDeleteConfirm =>
      'Burahin ang shop na ito? Kasama nitong mabubura ang lahat ng order, video at larawan, at hindi na mababawi.';

  @override
  String get shopDeleteBlockedTitle => 'May mga miyembro pa ang shop';

  @override
  String shopDeleteBlockedBody(int count) {
    return 'Alisin ang lahat ng miyembro bago burahin ang shop. May $count pa.';
  }

  @override
  String get shopDeleted => 'Nabura ang shop.';

  @override
  String bundleSelected(int count) {
    return '$count napili';
  }

  @override
  String get bundleUploadDrive => 'I-upload sa Drive';

  @override
  String get commonCancel => 'Kanselahin';

  @override
  String get commonRetry => 'Subukan ulit';

  @override
  String get commonClose => 'Isara';

  @override
  String get toastChangeLanguage => 'Palitan ang wika';

  @override
  String get toastTermsPolicy => 'Mga Tuntunin at Patakaran';

  @override
  String get toastInfoSaved => 'Na-save ang impormasyon';

  @override
  String get toastPasswordCreated => 'Nagawa ang password';

  @override
  String get toastPasswordChanged => 'Napalitan ang password';

  @override
  String get toastPendingDossierConfirm =>
      'May bukas ka pang claim dossier, pakikumpirma ulit';

  @override
  String get toastCopiedShareLink => 'Nakopya ang share link';

  @override
  String get toastShareFailed => 'Hindi ma-share, subukan mamaya';

  @override
  String get toastDownloadingVideo => 'Dina-download ang video';

  @override
  String get toastVideoDownloadedCopied =>
      'Na-download ang video at nakopya ang path';

  @override
  String get toastVideoSavedToGallery =>
      'Na-save ang video sa gallery ng device mo';

  @override
  String get toastVideoDownloadFailed =>
      'Hindi ma-download ang video, subukan mamaya';

  @override
  String get toastVideoDeleteUnavailable => 'Hindi mabubura ang video na ito';

  @override
  String get toastDownloadingPhoto => 'Dina-download ang larawan';

  @override
  String get toastPhotoSavedToGallery =>
      'Na-save ang larawan sa gallery ng device mo';

  @override
  String get toastPhotoDownloadedCopied =>
      'Na-download ang larawan at nakopya ang path';

  @override
  String get toastPhotoDownloadFailed =>
      'Hindi ma-download ang larawan, subukan mamaya';

  @override
  String get toastPhotoNoDownloadLink => 'Wala pang download link ang larawan';

  @override
  String get toastPhotoQueued =>
      'Naikabit ang larawan — napila na sa pag-upload';

  @override
  String imageOverFixedCap(String megabytes, String limit) {
    return '$megabytes MB ang larawan — lampas sa $limit MB na limitasyon, hindi naikabit. Pumili ng mas maliit.';
  }

  @override
  String get toastInvitePending => 'Naghihintay ng imbitasyon sa shop';

  @override
  String get toastInviteSent => 'Naipadala ang imbitasyon';

  @override
  String get toastMemberAdded => 'Naidagdag ang miyembro';

  @override
  String get toastVideoPlayFailed => 'Hindi ma-play ang video';

  @override
  String get toastShopCreated => 'Nagawa ang bagong shop';

  @override
  String get toastVideoQueued => 'Na-save ang video — napila na sa pag-upload';

  @override
  String get toastVideoNoPlayLink => 'Wala pang playback link ang video';

  @override
  String get toastVideoNoDownloadLink => 'Wala pang download link ang video';

  @override
  String get toastVideoDeleted => 'Nabura ang video';

  @override
  String get toastVideoTypeSaved => 'Na-save ang uri ng video';

  @override
  String get toastVideoTypeDeleted => 'Nabura ang uri ng video';

  @override
  String get toastNoVideoTypeToDelete => 'Walang uri ng video na buburahin';

  @override
  String get toastNoMemberToUpdate => 'Walang miyembrong ia-update';

  @override
  String get toastMemberRemoved =>
      'Naalis sa shop (matatapos pa ring mag-upload ang mga naitalang video)';

  @override
  String get toastInviteRevoked =>
      'Nabura ang imbitasyon — hindi na gumagana ang link sa email';

  @override
  String copiedLabel(String label) {
    return 'Nakopya ang $label';
  }

  @override
  String get labelTrackingCode => 'tracking code';

  @override
  String resolutionChanged(String value) {
    return 'Resolution: $value';
  }

  @override
  String get accountNoName => 'Wala pang pangalan';

  @override
  String get accountNoShop => 'Walang napiling shop';

  @override
  String get accountCreatePassword => 'Gumawa ng password';

  @override
  String get accountChangePassword => 'Palitan ang password';

  @override
  String accountLinkedMethods(int count) {
    return '$count naka-link';
  }

  @override
  String get roleOwner => 'May-ari';

  @override
  String get roleStaff => 'Staff';

  @override
  String memberInviteSent(String role) {
    return '$role · naipadala ang imbitasyon';
  }

  @override
  String memberInvitePending(String role) {
    return '$role · naghihintay ng kumpirmasyon';
  }

  @override
  String get planFree => 'Libre';

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
  String get roleOther => 'Iba pa';

  @override
  String get roleUnknown => 'Hindi alam';

  @override
  String get memberFallbackName => 'Miyembro';

  @override
  String get uploadStatusDone => 'Na-upload';

  @override
  String get uploadStatusPending => 'Naghihintay mag-upload';

  @override
  String get uploadStatusQuotaHold => 'Naka-hold (quota)';

  @override
  String get uploadStatusDeleted => 'Nabura';

  @override
  String get uploadStatusError =>
      'Hindi natapos ang upload — nasa device pa rin na kumuha ang clip';

  @override
  String get uploadStatusExpired => 'Tapos na ang panahon ng imbakan';

  @override
  String expiredOnDate(String date) {
    return 'Natapos ang panahon ng imbakan noong $date';
  }

  @override
  String get kindPhoto => 'Nakakabit na larawan';

  @override
  String get kindVideo => 'Video';

  @override
  String get recordedByFallback => 'Kasalukuyang account';

  @override
  String get deviceUnknown => 'Hindi kilalang device';

  @override
  String get orderNoEvidence => 'Wala pang ebidensiya';

  @override
  String get timelineEmpty => 'Wala pang video o larawan ang padalang ito';

  @override
  String get errorGenericRetry => 'May naging problema, pakisubukan ulit.';

  @override
  String get errorPendingDossier =>
      'May bukas ka pang claim dossier, asikasuhin muna bago magpatuloy.';

  @override
  String get errorSessionExpired =>
      'Nag-expire na ang session mo, mag-sign in ulit.';

  @override
  String get errorNoNetwork => 'Walang koneksyon sa network, pakisubukan ulit.';

  @override
  String get errorNoPermission => 'Wala kang pahintulot para sa aksyong ito.';

  @override
  String get errorServerBusy => 'Abala ang sistema, pakisubukan mamaya.';

  @override
  String get errorSessionInvalid => 'Hindi wastong session, mag-sign in ulit.';

  @override
  String get errorVideoTypeInUse =>
      'Hindi mabubura ang uri ng video na may mga video na. Suriin muna ang mga video na gumagamit nito.';

  @override
  String get errorBuiltinVideoTypeLocked =>
      'Hindi mababago o mabubura ang 3 built-in na uri ng video.';

  @override
  String get errorVideoTypeNameExists =>
      'May ganitong pangalan nang uri ng video sa shop.';

  @override
  String get errorCheckNetwork => 'Suriin ang network mo o subukan mamaya.';

  @override
  String get errorLoadShopList => 'Hindi ma-load ang listahan ng shop';

  @override
  String get errorLoadShopMgmt => 'Hindi ma-load ang pamamahala ng shop';

  @override
  String get errorLoadShopDetail => 'Hindi ma-load ang detalye ng shop';

  @override
  String get errorLoadMembers => 'Hindi ma-load ang listahan ng miyembro';

  @override
  String get membersRestricted =>
      'May-ari lang ng shop ang makakakita ng listahan ng miyembro';

  @override
  String get errorLoadOrders => 'Hindi ma-load ang mga order';

  @override
  String get errorLoadOrderDetail => 'Hindi ma-load ang detalye ng order';

  @override
  String get noShopSelectedOrdersDetail =>
      'Pumili muna ng shop bago tingnan ang mga order.';

  @override
  String get noShopSelectedRecordDetail =>
      'Pumili muna ng shop bago mag-record.';

  @override
  String get noShopSelectedManageDetail => 'Pumili ng shop na pamamahalaan.';

  @override
  String get noOrdersTitle => 'Wala pang order';

  @override
  String get noOrdersDetail => 'Pumili ng isang order sa listahan.';

  @override
  String get noVideoDataTitle => 'Walang data ng video';

  @override
  String get cannotOpenVideoTitle => 'Hindi mabuksan ang video';

  @override
  String get cannotOpenVideoDetail => 'Wala pang playback link ang video.';

  @override
  String get createOrderDialogTitle => 'Gumawa ng bagong order?';

  @override
  String createOrderDialogBody(String code) {
    return 'Walang tugmang tracking code ang $code sa shop na ito. Suriin ulit ang code o kumpirmahin ang paggawa ng bagong order.';
  }

  @override
  String get createOrderConfirm => 'Gumawa ng bagong order';

  @override
  String get statOrdersToday => 'Mga order';

  @override
  String get statVideosRecorded => 'Naitalang video';

  @override
  String get statPendingUpload => 'Nakabinbing upload';

  @override
  String get accountPlanQuota => 'Imbakan';

  @override
  String get accountChangePlan => 'Palitan ang plan';

  @override
  String get accountSectionApp => 'PLAN AT APP';

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
  String get accountLanguage => 'Wika';

  @override
  String get accountSectionSecurity => 'SEGURIDAD AT PAG-SIGN IN';

  @override
  String get accountLoginMethods => 'Paraan ng pag-sign in';

  @override
  String get accountSignOut => 'Mag-sign out';

  @override
  String get accountSignOutConfirmTitle => 'Mag-sign out?';

  @override
  String get accountSignOutConfirmMessage =>
      'Kailangan mong mag-sign in ulit para magpatuloy sa app.';

  @override
  String get accountDeleteAccount => 'Burahin ang account';

  @override
  String accountVersion(String version) {
    return 'Bersyon $version';
  }

  @override
  String get accountShopMgmtHint =>
      'Pamahalaan ang shop/miyembro: pindutin ang back sa header para bumalik sa Shop';

  @override
  String get accountInfoTitle => 'Impormasyon ng account';

  @override
  String get accountFullName => 'Buong pangalan';

  @override
  String get accountFullNameHint => 'Ilagay ang buong pangalan mo';

  @override
  String get accountFullNameRequired => 'Pakilagay ang buong pangalan mo';

  @override
  String get phoneOptionalLabel => 'Numero ng telepono (opsyonal)';

  @override
  String get phoneOptionalHint => 'Opsyonal — para lang sa suporta sa account';

  @override
  String get phoneInvalid => 'Hindi wastong numero ng telepono';

  @override
  String get accountSaveChanges => 'I-save ang mga pagbabago';

  @override
  String get accountEmailLockedHint =>
      'Email na ginagamit sa pag-sign in — hindi mapapalitan';

  @override
  String get commonContinue => 'Magpatuloy';

  @override
  String get commonLater => 'Mamaya';

  @override
  String get cameraPermissionRationaleTitle => 'Kailangan ng access sa camera';

  @override
  String get cameraPermissionRationaleBody =>
      'Kailangan ng ZenPack ang camera para mag-record ng video na ebidensiya ng packing para sa mga order mo.';

  @override
  String get cameraPermissionDeniedTitle => 'Hindi pa makapag-record';

  @override
  String get cameraPermissionDeniedBody =>
      'Hindi makapag-record ng video ang ZenPack dahil hindi pa binibigyan ng access sa camera. Puwede ka pa ring maghanap at mamahala ng mga order.';

  @override
  String get cameraPermissionOpenSettings => 'Buksan ang Settings';

  @override
  String get languageNameVietnamese => 'Vietnamese';

  @override
  String get languageNameEnglish => 'Ingles';

  @override
  String get languageChangeAppliesNote =>
      'Agad na epektibo ang pagbabago sa buong app';

  @override
  String get linkLinked => 'Naka-link';

  @override
  String get linkNotLinked => 'Hindi naka-link';

  @override
  String get loginMethodsEmailNote =>
      'Ang email ang identifier ng account mo — hindi ito maaalis. I-link ang Google/Apple para mabilis mag-sign in sa parehong account.';

  @override
  String get loginMethodIdentity => 'Identifier';

  @override
  String get linkAction => 'I-link';

  @override
  String get linkUnlink => 'Alisin ang link';

  @override
  String get quotaScreenTitle => 'Mga ulat at Quota';

  @override
  String get quotaRemainingThisMonth => 'Natitira ngayong buwan';

  @override
  String get quotaSubtitle => 'Subaybayan ang imbakang ginagamit mo';

  @override
  String quotaRemainingAmount(String amount) {
    return '$amount ang natitira';
  }

  @override
  String get quotaStorage => 'Imbakan';

  @override
  String get deleteAccountTitleStep1 => 'Burahin ang account?';

  @override
  String get deleteAccountTitleStep2 => 'Kumpirmahin ang permanenteng pagbura?';

  @override
  String get deleteAccountBodyStep1 =>
      'Permanenteng mabubura ang lahat ng video, padala at dossier mo. Hindi na ito mababawi.';

  @override
  String get deleteAccountBodyStep2 =>
      'Ito ang huling hakbang ng kumpirmasyon. Pagkatapos, agad kang mala-log out sa app.';

  @override
  String get deleteConfirmPermanent => 'Burahin nang permanente';

  @override
  String get deleteStep1Hint => 'Hakbang 1/2 — hihingi ulit ng kumpirmasyon';

  @override
  String get deleteStep2Hint => 'Hakbang 2/2 — hindi na ito mababawi';

  @override
  String get passwordCurrentLabel => 'Kasalukuyang password';

  @override
  String get passwordCurrentRequired => 'Ilagay ang kasalukuyang password mo';

  @override
  String get passwordNewLabel => 'Bagong password';

  @override
  String get passwordMinHint => 'Hindi bababa sa 8 karakter';

  @override
  String get passwordNewRequired => 'Maglagay ng bagong password';

  @override
  String get passwordMin8Error =>
      'Dapat hindi bababa sa 8 karakter ang password';

  @override
  String get passwordNeedsLetterDigit =>
      'Kailangang may letra at numero ang password';

  @override
  String get passwordTooCommon =>
      'Masyadong madaling hulaan ang password na iyan — pumili ng iba';

  @override
  String get passwordConfirmLabel => 'Ulitin ang bagong password';

  @override
  String get passwordMismatch => 'Hindi magkatugma ang password';

  @override
  String get passwordSave => 'I-save ang password';

  @override
  String get passwordChangeLogoutNote =>
      'Mala-log out ka sa ibang device pagkatapos magpalit';

  @override
  String get navOrders => 'Mga order';

  @override
  String get navRecord => 'Mag-record';

  @override
  String get navAccount => 'Account';

  @override
  String get navClaims => 'Mga claim';

  @override
  String get changeAvatar => 'Palitan ang larawan sa profile';

  @override
  String quotaVideosRatio(int remaining, int total) {
    return '$remaining / $total video';
  }

  @override
  String quotaUsedPercent(int percent) {
    return 'Nagamit $percent%';
  }

  @override
  String quotaRetentionDays(int days) {
    return '$days araw';
  }

  @override
  String quotaUsedRatio(String used, String cap, int percent) {
    return 'Nagamit $used / $cap · $percent%';
  }

  @override
  String get quotaVideosStored => 'Nakaimbak na video';

  @override
  String quotaVideosStoredCount(int count) {
    return '$count video';
  }

  @override
  String get quotaByType => 'Imbakan ayon sa uri';

  @override
  String quotaByTypeVideosCount(int count) {
    return '$count video ang nakaimbak';
  }

  @override
  String quotaRefundNote(int days) {
    return 'Mababakante ang imbakan kapag lumampas ang video sa $days araw na panahon ng imbakan';
  }

  @override
  String deletePendingProfilesWarning(int count) {
    return 'May $count dossier ka pang “naipadala sa platform” — hihinto sa paggana ang mga share link nila';
  }

  @override
  String get detailRecordedTime => 'Oras ng pag-record';

  @override
  String get detailDuration => 'Tagal';

  @override
  String get detailRecordedBy => 'Ni-record ni';

  @override
  String get detailCapturedTime => 'Oras ng pagkuha';

  @override
  String get detailCapturedBy => 'Kinuha ni';

  @override
  String get detailDevice => 'Device';

  @override
  String get detailSize => 'Laki';

  @override
  String get detailUploadStatus => 'Katayuan ng upload';

  @override
  String get detailSeal => 'Selyo';

  @override
  String sealSealed(String at) {
    return 'Naka-lock · $at';
  }

  @override
  String get sealWorking => 'Isinasama ang timestamp…';

  @override
  String get sealWorkingHint =>
      'Wala pang nakasunog na timestamp ang nakaimbak na kopya, kaya naghihintay muna ang share link at download. Karaniwang ilang segundo lang.';

  @override
  String get playLocalCopyNote =>
      'Pansamantalang kopya sa device na ito — wala pang timestamp sa mga frame';

  @override
  String get sealNone => 'Ni-record bago pa umiral ang pag-seselyo';

  @override
  String get sealFailed =>
      'Wala pang nakasunog na timestamp · nape-play at nada-download pa rin ang video';

  @override
  String get sealMismatch =>
      'Hindi tugma ang fingerprint — i-record ulit ang clip na ito';

  @override
  String get sealTimeDrift =>
      'Lumihis ang orasan ng camera sa server, kaya dala rin ng nakasunog na selyo ang oras ng pagtanggap ng server sa clip.';

  @override
  String get detailSealAnchor => 'Malayang patunay';

  @override
  String sealAnchorConfirmed(String block) {
    return 'Oo · entry #$block';
  }

  @override
  String get sealAnchorConfirmedNoBlock => 'Oo';

  @override
  String get sealAnchorPending =>
      'Isinusulat sa pampublikong ledger (ilang oras)';

  @override
  String get sealAnchorNone => 'Wala';

  @override
  String get sealVerifyOpen => 'Buksan ang verification page';

  @override
  String get sealVerifyHint =>
      'Ipadala ang link na ito sa marketplace — kaya nilang beripikahin mismo, hindi kailangang magtiwala sa ZenPack.';

  @override
  String get sealVerifyFailed => 'Hindi mabuksan ang verification page.';

  @override
  String get detailPlayVideo => 'I-play ang video';

  @override
  String get detailCopyAssetLink => 'Kopyahin ang link';

  @override
  String get assetLinkTitle => 'Link ng ebidensiya';

  @override
  String get detailDownloadVideo => 'I-download ang video';

  @override
  String get detailDownloadNote =>
      'May-ari/manager lang · para kapag humingi ang marketplace ng orihinal na file';

  @override
  String get detailTrimVideo => 'Gumupit ng maikling clip para ipadala';

  @override
  String get detailTrimNote =>
      'Buo pa rin ang orihinal · may timestamp pa rin ang ginupit';

  @override
  String get trimSave => 'I-save';

  @override
  String get trimEstimatedSize => 'Humigit-kumulang';

  @override
  String get trimFailed =>
      'Hindi magupit ang video. Nandiyan pa rin ang buong clip.';

  @override
  String get trimPreparing => 'Dina-download ang buong clip…';

  @override
  String get detailDownloadPhoto => 'I-download ang larawan';

  @override
  String get attachPhotoToOrder => 'Ikabit ang larawan sa order';

  @override
  String get deleteVideoAction => 'Burahin ang video';

  @override
  String get deletePhotoAction => 'Burahin ang larawan';

  @override
  String get deleteVideoNote =>
      'May-ari/manager lang · naka-lock habang may bukas na dossier · dalawang hakbang na kumpirmasyon';

  @override
  String deleteVideoInDossier(String dossier) {
    return 'This evidence is in claim dossier $dossier — remove it from the dossier first, then delete.';
  }

  @override
  String get deleteVideoConfirmTitle => 'Huling kumpirmasyon';

  @override
  String get deleteVideoConfirmBody =>
      'Permanenteng mabubura ang ebidensiyang ito at hindi na mababawi — burahin pa rin?';

  @override
  String get deleteVideoConfirmAction => 'Burahin nang permanente';

  @override
  String ordersErrorCount(int count) {
    return '· $count error';
  }

  @override
  String ordersPendingCount(int count) {
    return '· $count nakabinbin';
  }

  @override
  String ordersPendingEvidenceWarning(int count) {
    return '$count ebidensiya ang hindi pa na-upload · wala pang makokopyang link';
  }

  @override
  String get captureFramePrompt => 'I-scan ang tracking code';

  @override
  String get captureCameraDownHint => 'Ilagay ang bill sa loob ng frame';

  @override
  String get cutoverSavedVideo => 'Na-save ang video';

  @override
  String get cutoverPreparingNext => 'Naghahanda para sa susunod';

  @override
  String get cutoverNextOrder => 'Susunod na order';

  @override
  String get lowStorageTitle => 'Halos puno na ang imbakan';

  @override
  String get lowStorageBody =>
      'Kaunti na lang ang imbakan ng device — baka hindi ma-save nang buo ang kasalukuyang recording. Magbakante muna bago magpatuloy.';

  @override
  String get lowStorageAction => 'Naintindihan';

  @override
  String cutoverClosedSummary(String code, String duration) {
    return 'Isinara ang tracking code na $code ($duration)';
  }

  @override
  String get cutoverSignalText => 'Tunog + vibration sa paglipat ng order';

  @override
  String get tooltipBack => 'Bumalik';

  @override
  String get tooltipSwitchCamera => 'Palitan ang camera';

  @override
  String get tooltipEnterTracking => 'Ilagay ang tracking code';

  @override
  String get tooltipZoomIn => 'Mag-zoom in';

  @override
  String get tooltipZoomOut => 'Mag-zoom out';

  @override
  String get captureResolution => 'Resolution';

  @override
  String get stopRecording => 'Itigil ang pag-record';

  @override
  String get videoTypeSettings => 'Setting ng uri ng video';

  @override
  String get uploadQueueTitle => 'Pila ng upload';

  @override
  String get quotaExhaustedNote =>
      'Naubos na ang buwanang allowance. Gumagana pa ang pag-record, pero NASA TELEPONO PA ang mga clip na ito at hindi pa protektado — kusa silang mag-a-upload kapag naitaas ang allowance.';

  @override
  String get queueEmpty => 'Wala pang video sa pila';

  @override
  String get queueAutoUploadNote => 'Kusang nag-a-upload kapag online ka';

  @override
  String get waitingUpload => 'Naghihintay mag-upload';

  @override
  String get queueUploading => 'Ina-upload';

  @override
  String get queueQuotaShort => 'Naghihintay ng quota';

  @override
  String get queueUploadFailed => 'Hindi natapos ang upload';

  @override
  String get uploaded => 'Na-upload';

  @override
  String get waitingQuota => 'Naghihintay ng allowance · nasa device pa';

  @override
  String get pausedUpload => 'Naka-pause';

  @override
  String get queuePauseAction => 'I-pause';

  @override
  String get queueResumeAction => 'Ituloy';

  @override
  String get queueDeleteAction => 'Alisin';

  @override
  String get queueClearAction => 'I-clear';

  @override
  String get queueClearConfirmTitle => 'I-clear ang buong pila?';

  @override
  String get queueClearConfirmBody =>
      'Ang mga clip na hindi pa na-upload ay nasa telepono lang na ito. Mawawala sila nang tuluyan.';

  @override
  String get queueDeleteConfirmTitle => 'Alisin sa pila?';

  @override
  String get queueDeleteConfirmBody =>
      'Hindi pa na-upload ang clip na ito — kapag inalis, permanenteng mabubura ito sa device mo.';

  @override
  String get toastQueueItemDeleted => 'Naalis sa pila ng upload';

  @override
  String get manualTrackingTitle => 'Ilagay ang tracking code';

  @override
  String get manualTrackingNote => 'I-type ito o i-scan ulit ang code';

  @override
  String get commonDone => 'Tapos';

  @override
  String get startRecording => 'Simulan ang pag-record';

  @override
  String get returnCodeMismatch => 'Hindi tugma ang return code';

  @override
  String get enterCodeManually => 'Ilagay ang code nang manu-mano';

  @override
  String get videoTypeLabel => 'Uri ng video';

  @override
  String get videoTypeSelectNote =>
      'Piliin ang tamang uri — magdagdag/mag-edit/magbura sa Detalye ng shop';

  @override
  String get videoTypeSheetTitle => 'Pumili ng uri ng video';

  @override
  String get videoTypeGroupDefault => 'Mga default na uri (kailangan)';

  @override
  String get videoTypeGroupCustom => 'Sariling uri ng shop';

  @override
  String get manageVideoTypesNote =>
      'Pamahalaan ang uri ng video — buksan ang Detalye ng shop';

  @override
  String queueFilterAll(int count) {
    return 'Lahat ($count)';
  }

  @override
  String queueFilterUploading(int count) {
    return 'Ina-upload ($count)';
  }

  @override
  String queueFilterErrored(int count) {
    return 'Mga error ($count)';
  }

  @override
  String queueFilterQuotaWait(int count) {
    return 'Naghihintay ng allowance ($count)';
  }

  @override
  String queueSummary(int pending, int uploading, int errored) {
    return '$pending video ang naghihintay · $uploading ina-upload · $errored nabigo';
  }

  @override
  String uploadingProgress(int percent) {
    return 'Ina-upload $percent%';
  }

  @override
  String errorRetryCount(int count) {
    return 'Error · Subukan ulit ($count)';
  }

  @override
  String returnCodeMismatchBody(String returnCode, String shopName) {
    return 'Walang tugmang order ang $returnCode sa $shopName. Suriin ulit ang code, ilagay nang manu-mano, o kumpirmahin ang paggawa ng bagong order.';
  }

  @override
  String get onboardingSubtitle =>
      'Mag-record ng video na ebidensiya ng packing para sa mga e-commerce seller';

  @override
  String get onboardingStart => 'Magsimula';

  @override
  String get authSignIn => 'Mag-sign in';

  @override
  String get authChooseMethod => 'Pumili ng paraan ng pag-sign in';

  @override
  String get authEmailRequired => 'Ilagay ang email mo';

  @override
  String get authEmailInvalid => 'Hindi wastong email';

  @override
  String get authPassword => 'Password';

  @override
  String get authPasswordRequired => 'Ilagay ang password mo';

  @override
  String get authForgotPassword => 'Nakalimutan ang password?';

  @override
  String get registerWithGoogle => 'Mag-sign up gamit ang Google';

  @override
  String get registerWithApple => 'Mag-sign up gamit ang Apple';

  @override
  String get authSignInGoogle => 'Mag-sign in gamit ang Google';

  @override
  String get authSignInApple => 'Mag-sign in gamit ang Apple';

  @override
  String get authNoAccountPrompt => 'Wala ka pang account? ';

  @override
  String get authRegister => 'Magrehistro';

  @override
  String get authOr => 'o';

  @override
  String get registerTitle => 'Gumawa ng bagong account';

  @override
  String get registerConfirmPassword => 'Ulitin ang password';

  @override
  String get registerAgreePolicy => 'Sumasang-ayon ako sa patakaran ';

  @override
  String get registerViewPolicy => 'Tingnan ang patakaran';

  @override
  String get registerCreateAccount => 'Gumawa ng account';

  @override
  String get registerSameEmailNote =>
      'Awtomatikong maiuugnay sa isang account ang parehong email';

  @override
  String get registerHaveAccountPrompt => 'May account ka na? ';

  @override
  String get registerSuccessTitle => 'Nagawa ang account';

  @override
  String registerSuccessVerifyMessage(String email) {
    return 'Nagpadala kami ng verification email sa $email. Tingnan ang inbox (pati spam), tapos mag-sign in.';
  }

  @override
  String get registerSuccessMessage =>
      'Handa na ang account mo. Mag-sign in gamit ang email at password na ibinigay mo.';

  @override
  String get registerSuccessAction => 'Mag-sign in';

  @override
  String get loginNotVerifiedTitle => 'Hindi pa na-verify ang email';

  @override
  String loginNotVerifiedMessage(String email) {
    return 'Buksan ang verification email na ipinadala sa $email (tingnan din ang spam), sundan ang link, tapos mag-sign in ulit.';
  }

  @override
  String get loginResendVerification => 'Ipadala ulit ang email';

  @override
  String get loginVerificationResent => 'Naipadala ulit ang verification email';

  @override
  String get forgotPasswordTitle => 'Nakalimutan ang password';

  @override
  String get forgotPasswordSubtitle =>
      'Ilagay ang email mo para makatanggap ng link sa pag-reset ng password';

  @override
  String get forgotPasswordSubmit => 'Ipadala ang reset link';

  @override
  String get forgotPasswordSent => 'Naipadala — tingnan ang inbox (pati spam)';

  @override
  String get forgotPasswordRememberPrompt => 'Naalala mo na ang password? ';

  @override
  String get shopYourShops => 'Mga shop mo';

  @override
  String get shopTapToClockIn =>
      'Pindutin ang shop para mag-clock in · pamahalaan din dito';

  @override
  String get shopLastOpenedNote =>
      'Ang huling binuksang shop ang direktang bubukas sa susunod';

  @override
  String get shopManageStore => 'Pamahalaan ang tindahan';

  @override
  String get shopManageVisibilityNote =>
      'Nakikita lang ng may-ari ng account / manager ng shop';

  @override
  String get shopEmpty => 'Wala pang shop';

  @override
  String get shopEmptyBody =>
      'Wala pang shop ang account mo. Gumawa ng bagong shop para magsimula, o maghintay ng imbitasyon mula sa may-ari ng shop.';

  @override
  String get shopCreateNew => 'Gumawa ng bagong shop (pangalan + platform)';

  @override
  String get shopInvitesHere => 'Lalabas dito ang mga imbitasyon sa shop';

  @override
  String get shopCreateTitle => 'Gumawa ng shop';

  @override
  String get shopNameLabel => 'Pangalan ng shop';

  @override
  String get shopNameRequired => 'Ilagay ang pangalan ng shop';

  @override
  String get shopPlatform => 'Marketplace';

  @override
  String get shopCreateOwnerNote =>
      'Ikaw ang magiging may-ari — magdagdag ng miyembro mamaya sa Pamahalaan ang tindahan';

  @override
  String get shopMgmtVisibilityNote =>
      'Hindi nakikita ng staff ang screen na ito · nakikita lang ng manager ang mga shop na pinamamahalaan niya';

  @override
  String get shopAddNew => 'Magdagdag ng bagong shop';

  @override
  String get sectionMembers => 'MGA MIYEMBRO';

  @override
  String get sectionShopSettings => 'SETTING NG SHOP';

  @override
  String get sectionVideoTypes => 'URI NG VIDEO';

  @override
  String get videoTypesLockedNote =>
      'Naka-lock ang 3 built-in na uri — hindi mae-edit/mabubura';

  @override
  String get addMemberByContact => 'Magdagdag ng miyembro sa email/telepono';

  @override
  String get recordResolution => 'Resolution ng pag-record';

  @override
  String get addVideoType => 'Magdagdag ng uri (ilagay ang pangalan)';

  @override
  String get createVideoTypeTitle => 'Gumawa ng uri ng video';

  @override
  String get videoTypeName => 'Pangalan ng uri ng video';

  @override
  String get videoTypeNameHint => 'hal. Pagtimbang';

  @override
  String get createVideoType => 'Gumawa ng uri';

  @override
  String get deleteVideoTypeBody =>
      'Mabubura lang habang walang video ang uring ito. Kung may video na, hinaharangan ng sistema ang pagbura para hindi masira ang mga filter at estadistika ng ebidensiya.';

  @override
  String get deleteVideoTypeConfirm => 'Burahin ang uri';

  @override
  String get deleteVideoTypeNote =>
      '(Mabubura lang habang walang video ang uri)';

  @override
  String get addMemberTitle => 'Magdagdag ng miyembro';

  @override
  String get addMemberBody =>
      'Ilagay ang email ng rehistradong ZenPack account. Makakatanggap sila ng imbitasyon at kailangan nilang kumpirmahin para sumali sa shop.';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailRequired => 'Maglagay ng email address.';

  @override
  String get emailInvalid => 'Maglagay ng isang wastong email address.';

  @override
  String get errorInviteAccountNotFound =>
      'Wala pang ZenPack account ang email na ito. Pasabihan silang magrehistro muna, tapos mag-imbita ulit.';

  @override
  String get errorInviteAlreadyMember => 'Miyembro na siya ng shop na ito.';

  @override
  String get errorInviteMemberLimit =>
      'Puno na ang limitasyon ng miyembro sa plan na ito. Kasama sa bilang ang mga nakabinbing imbitasyon — bawiin ang isa para makabakante.';

  @override
  String get errorInviteAlreadyOwner =>
      'Siya ang may-ari ng shop — hindi na kailangan ng imbitasyon.';

  @override
  String get errorInviteInvalidRequest =>
      'Hindi wasto ang email na iyan. Suriin at ipadala ulit.';

  @override
  String get addMemberSubmit => 'Idagdag';

  @override
  String get memberOwnerLocked =>
      'Hindi mababago ang papel o maaalis dito ang may-ari — sa shop nakalagay ang pagmamay-ari, hindi sa isang hilera ng membership.';

  @override
  String get removeFromShop => 'Alisin sa shop';

  @override
  String get revokeInvite => 'Burahin ang imbitasyon';

  @override
  String get resolutionAppliesNote =>
      'Para sa mga bagong itatalang video ng shop';

  @override
  String get resolutionDefaultOption => '720p (default)';

  @override
  String get ordersSearchHint => 'Ilagay ang tracking code';

  @override
  String get ordersEmpty => 'Wala pang order ang shop na ito';

  @override
  String recordAutoStopIn(String time) {
    return 'Awtomatikong hihinto sa $time';
  }

  @override
  String get ordersNotFound => 'Walang nakitang order';

  @override
  String get ordersNotFoundHint =>
      'Suriin ulit ang tracking code at subukan muli';

  @override
  String ordersPageRange(int first, int last, int total) {
    return '$first–$last sa $total order';
  }

  @override
  String get ordersPagePrevious => 'Naunang pahina';

  @override
  String get ordersPageNext => 'Susunod na pahina';

  @override
  String ordersPageNumber(int page) {
    return 'Pahina $page';
  }

  @override
  String get filterStatusLabel => 'Katayuan';

  @override
  String get filterStatusAll => 'Lahat';

  @override
  String get filterStatusPending => 'Naghihintay mag-upload';

  @override
  String get filterStatusError => 'Mga error sa upload';

  @override
  String get filterStatusDone => 'Buong na-upload';

  @override
  String get filterTimeLabel => 'Oras';

  @override
  String get filterTimeAll => 'Anumang oras';

  @override
  String get filterTimeToday => 'Ngayon';

  @override
  String get filterTimeYesterday => 'Kahapon';

  @override
  String get filterTime7d => 'Huling 7 araw';

  @override
  String get filterTime30d => 'Huling 30 araw';

  @override
  String get filterTimePickDate => 'Pumili ng petsa…';

  @override
  String get filterTypeLabel => 'Uri ng video';

  @override
  String get filterTypeAll => 'Lahat';

  @override
  String deleteVideoTypeTitle(String typeName) {
    return 'Burahin ang uring \"$typeName\"?';
  }

  @override
  String memberCurrentRole(String role) {
    return 'Kasalukuyang papel: $role';
  }

  @override
  String get stopCodeTitle => 'QR code para itigil ang pag-record';

  @override
  String get stopCodeInstructions =>
      'I-print ito at idikit sa packing table. Ipakita sa camera habang nagre-record para awtomatikong huminto.';

  @override
  String get scannedCodeNotFound =>
      'Walang order na tumutugma sa na-scan na code';

  @override
  String get onboardingTaglineOne => 'Bawat parcel.';

  @override
  String get onboardingTaglineTwo => 'Isang patunay.';

  @override
  String get onboardingTaglineThree => 'Pinoprotektahan ang kita mo.';

  @override
  String get authEmailPlaceholder => 'Ilagay ang email mo';

  @override
  String get authPasswordPlaceholder => 'Ilagay ang password mo';

  @override
  String get registerCreateAccountSubtitle => 'Gumawa ng bagong account';

  @override
  String get registerFullName => 'Buong pangalan';

  @override
  String get registerFullNameRequired => 'Pakilagay ang buong pangalan mo';

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
  String get registerAgreePrefix => 'Sumasang-ayon ako sa';

  @override
  String get registerTermsOfUse => 'Mga Tuntunin ng Paggamit';

  @override
  String get shopChooseTitle => 'Pumili ng shop';

  @override
  String get shopChooseSubtitle => 'Pumili ng shop para magpatuloy';

  @override
  String get shopManageTitle => 'Pamahalaan ang mga shop';

  @override
  String get shopManageOwnerOnly =>
      'Nakikita lang ng may-ari at manager ng shop';

  @override
  String get noShopTitle => 'Wala pang shop';

  @override
  String get noShopLineOne => 'Wala pang shop ang account mo.';

  @override
  String get noShopLineTwo => 'Gumawa ng shop para magsimula,';

  @override
  String get noShopLineThree =>
      'o maghintay ng imbitasyon mula sa may-ari ng shop.';

  @override
  String get noShopCreateCta => 'Gumawa ng shop (pangalan + marketplace)';

  @override
  String get noShopInviteHint => 'Lalabas dito ang mga imbitasyon sa shop';

  @override
  String get createShopTitle => 'Gumawa ng shop';

  @override
  String get createShopNameLabel => 'Pangalan ng shop';

  @override
  String get createShopNameHint => 'hal. Shop ABC';

  @override
  String get createShopPlatformLabel => 'Marketplace';

  @override
  String get createShopOwnerNote =>
      'Ikaw ang magiging may-ari — magdagdag ng miyembro mamaya sa Pamahalaan ang mga shop';

  @override
  String get createShopSubmit => 'Gumawa ng shop';

  @override
  String get shopManageDescription =>
      'Tingnan at pamahalaan ang mga shop na inaadministra mo.';

  @override
  String get shopManageAddCta => 'Magdagdag ng shop';

  @override
  String get shopManageStaffNote =>
      'Hindi ito nakikita ng staff — may-ari at manager lang ng shop.';

  @override
  String get shopDetailTitle => 'Detalye ng shop';

  @override
  String get shopDetailResolution => 'Resolution ng pag-record';

  @override
  String get shopDetailClipDuration => 'Pinakamahabang haba/video';

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
    return 'Inirerekomenda $minutes min — para sa $platform ($megabytes MB/video) + $resolution';
  }

  @override
  String clipRecommendedHintUnverified(String minutes, String platform) {
    return 'Inirerekomenda $minutes min — hindi pa nakumpirma ang limitasyon ng $platform, ginagamit ang pinakaligtas na alam';
  }

  @override
  String clipOverRecommendedWarning(
    String minutes,
    String platform,
    String chosen,
    String megabytes,
  ) {
    return 'Lampas sa rekomendang $minutes min para sa $platform — humigit-kumulang $megabytes MB ang video na $chosen min, kaya kailangang ipadala bilang dossier link imbes na ikabit sa reklamo.';
  }

  @override
  String get clipDurationTitle => 'Pinakamahabang haba kada video';

  @override
  String get clipDurationSubtitle => 'Awtomatikong nagsasara sa habang ito';

  @override
  String clipDurationPlanCap(String minutes) {
    return 'Hanggang $minutes min ang pinapayagan ng plan mo';
  }

  @override
  String clipDurationChanged(String minutes) {
    return 'Pinakamahabang haba/video: $minutes min';
  }

  @override
  String get shopDetailImageSize => 'Laki ng larawan';

  @override
  String get shopDetailVideoSize => 'Laki ng video';

  @override
  String get shopDetailUploadSize => 'Pinakamalaking laki/file';

  @override
  String uploadSizeValue(String megabytes) {
    return '$megabytes MB';
  }

  @override
  String uploadRecommendedHint(String megabytes, String platform) {
    return 'Inirerekomenda $megabytes MB — limitasyon sa attachment ng $platform';
  }

  @override
  String uploadOverRecommendedWarning(
    String megabytes,
    String platform,
    String chosen,
  ) {
    return 'Lampas sa rekomendang $megabytes MB para sa $platform — buong naiimbak pa rin ang file hanggang $chosen MB, pero kailangang ipadala bilang dossier link imbes na ikabit sa reklamo.';
  }

  @override
  String get uploadSizeValueUnlimited => 'Walang limitasyon';

  @override
  String get uploadSizeTitle => 'Pinakamalaking laki kada file';

  @override
  String uploadSizeSubtitle(String megabytes, String platform) {
    return 'Hindi naikakabit ang file na lampas sa limitasyon; $megabytes MB ay direktang naikakabit pa rin sa $platform';
  }

  @override
  String uploadSizeOptionRecommended(String megabytes) {
    return '$megabytes MB (inirerekomenda)';
  }

  @override
  String uploadSizeChanged(String megabytes) {
    return 'Laki kada file: $megabytes';
  }

  @override
  String avatarTooLarge(String megabytes, String limit) {
    return 'Na-save ang pangalan at telepono. Ang $megabytes MB na profile photo ay lampas sa $limit MB na limitasyon, kaya hindi umabot sa server — pumili ng mas maliit.';
  }

  @override
  String avatarUploadFailed(String reason) {
    return 'Na-save ang pangalan at telepono. Hindi umabot sa server ang profile photo: $reason';
  }

  @override
  String nearClipLimitWarning(String minutes) {
    return 'Malapit na sa $minutes min na limitasyon — kusang magsasara ang video';
  }

  @override
  String get shopDetailAddType => 'Magdagdag ng uri (ilagay ang pangalan)';

  @override
  String get inviteMemberTitle => 'Mag-imbita ng miyembro';

  @override
  String get inviteRoleFixedNote =>
      'Sasali siya bilang staff: makakapag-record ng video at makikita ang sarili niyang mga video.';

  @override
  String get inviteMemberHint =>
      '(wala pang account → magpadala ng imbitasyon)';

  @override
  String get videoTypeIcon => 'Icon';

  @override
  String get videoTypeColor => 'Kulay';

  @override
  String get createVideoTypeSubmit => 'Gumawa ng uri';

  @override
  String get deleteVideoTypeSafeNote => 'Walang mawawalang ebidensiya';

  @override
  String get commonConfirm => 'Kumpirmahin';

  @override
  String orderErrorCount(int count) {
    return '$count nabigo';
  }

  @override
  String get videoDetailSheetTitle => 'Detalye ng video';

  @override
  String get tooltipStopRecording => 'Itigil ang pag-record';

  @override
  String get dossierLinkTitle => 'Link ng dossier ng reklamo';

  @override
  String get accountEndQr => 'Code para itigil ang pag-record';

  @override
  String get accountEndQrTitle => 'Code para itigil ang pag-record';

  @override
  String get accountEndQrShare => 'Ibahagi ang code';

  @override
  String get accountEndQrSave => 'I-save sa photo library';

  @override
  String get recordInterruptedTitle => 'Naka-pause ang pag-record';

  @override
  String get recordInterruptedBody =>
      'Naka-pause ang pag-record dahil may nakaabala. Ituloy ang pag-record?';

  @override
  String get recordInterruptedResume => 'Ituloy';

  @override
  String get recordInterruptedFinish => 'Tapusin';

  @override
  String get commonApply => 'Ilapat';

  @override
  String get unitMinutes => 'min';

  @override
  String get clipDurationCustomLabel =>
      'O ilagay ang bilang ng minutong gusto mo';

  @override
  String get supportOpenFailed =>
      'Hindi mabuksan — tiyaking naka-install ang app';

  @override
  String get feedbackThanksTitle => 'Salamat!';

  @override
  String get feedbackThanksBody =>
      'Nakakatulong ang feedback mo para gumanda ang ZenPack.';

  @override
  String get feedbackTitle => 'Ano ang gusto mong ibahagi sa amin?';

  @override
  String get feedbackHint => 'I-type ang feedback mo...';

  @override
  String get feedbackSend => 'Ipadala ang feedback';

  @override
  String get feedbackThanks => 'Salamat sa feedback mo';

  @override
  String get accountSectionAbout => 'TUNGKOL SA';

  @override
  String get accountFeedback => 'Magpadala ng feedback';

  @override
  String get accountFeedbackNote =>
      'Ibahagi ang saloobin mo para gumanda ang ZenPack';

  @override
  String get accountRateApp => 'I-rate ang app';

  @override
  String get accountRateAppNote => 'Suportahan ang pagbuo ng ZenPack';

  @override
  String get supportFacebook => 'Mag-message sa Facebook';

  @override
  String get supportZalo => 'Mag-message sa Zalo';

  @override
  String get supportCall => 'Tumawag sa suporta';

  @override
  String sheetCustomMin(String min, String unit) {
    return 'Maglagay ng $min $unit o higit pa';
  }

  @override
  String sheetCustomRange(String min, String max, String unit) {
    return 'Maglagay ng $min hanggang $max $unit';
  }

  @override
  String get accountEndQrNote =>
      'I-print ito at idikit sa packing table. Kapag na-scan habang nagre-record, magsasara ang clip. Gumagana ang parehong code sa lahat ng device.';

  @override
  String get languageChangeScopeNote =>
      'Lahat ng label, notipikasyon at dossier\nay lilipat sa wikang pipiliin mo.';

  @override
  String get manualEntryEmptyError =>
      'Maglagay ng tracking code bago mag-record';

  @override
  String get appUpdateTitle => 'May bagong bersyon';

  @override
  String get appUpdateMessage =>
      'I-update ang ZenPack para sa pinakabagong ayos at feature.';

  @override
  String get appUpdateNow => 'I-update';

  @override
  String get appUpdateLater => 'Mamaya';

  @override
  String get quotaVideosThisMonth => 'Mga video ngayong buwan';

  @override
  String get quotaSubtitleVideos =>
      'Subaybayan kung ilang video ang naitala mo ngayong buwan';

  @override
  String get quotaUpgrade => 'Mag-upgrade ng plan';

  @override
  String get quotaBlockedTitle => 'Naubos ang allowance ng video';

  @override
  String get quotaBlockedNote =>
      'Gumagana pa ang pag-record, pero hindi pa maka-upload ang mga clip — nasa teleponong ito sila, hindi protektado. Kusa silang mag-a-upload kapag naitaas ang allowance.';

  @override
  String get quotaBlockedOwnerNote =>
      'Ang limitasyon ng tindahang ito ay itinatakda ng may-ari ng account — hilingin sa kanila na taasan ito. Ang planong binili mo ay para lang sa sarili mong account.';

  @override
  String get quotaTopupCredits => 'Mag-top up ng credit';

  @override
  String get quotaOverCap => 'Lampas sa allowance ng plan';

  @override
  String quotaBlockAt(int n) {
    return 'Naharang ang bagong pag-record sa $n video';
  }

  @override
  String get quotaResetMonthly =>
      'Nagre-reset sa simula ng susunod na buwan; walang dala-dala';

  @override
  String get storageOwnTitle => 'Sarili mong imbakan';

  @override
  String storageOwnPending(int count) {
    return '$count video ang naghihintay ipadala sa imbakan mo';
  }

  @override
  String storageOwnProblem(int count) {
    return '$count video sa imbakan mo ang may problema';
  }

  @override
  String get quotaExhaustedWarn =>
      'Huwag alisin ang app o burahin ang data nito hangga\'t hindi pa sila na-upload.';

  @override
  String quotaStrandedTitle(int count) {
    return '$count video ang naghihintay sa teleponong ito';
  }

  @override
  String get quotaStrandedNote =>
      'Nasa teleponong ito lang ang mga video na ito. Kapag nawala ito, inalis ang app o binura ang data, mawawala rin sila.';

  @override
  String get storageTitle => 'Imbakan ng video';

  @override
  String get storageSave => 'I-save ang piniling storage';

  @override
  String get storageSystemName => 'Imbakan ng sistema';

  @override
  String get storageS3Name => 'Sarili mong imbakan (S3)';

  @override
  String get storageDriveName => 'Google Drive mo';

  @override
  String get storageSystemDesc =>
      'Ito ang default; walang kailangang i-set up. Dito lang tumatagal ang lahat ng pangako sa ebidensiya.';

  @override
  String get storageOwnDesc =>
      'Diretso sa imbakan mo ang mga bagong video. Mananatili sa kinalalagyan ang mga luma hanggang matapos ang panahon ng imbakan.';

  @override
  String get storageNoPresign =>
      'Hindi makakapag-sign ng download link ang imbakang ito, kaya kailangang dumaan sa server ang video — mas mabagal para sa sinumang magbubukas ng link mo.';

  @override
  String get storageNoObjectLock =>
      'Walang object lock ang imbakang ito. Hindi mo maipapangako sa marketplace na hindi mabubura ang ebidensiya.';

  @override
  String get storageNotInPlan =>
      'Hindi pa kasama sa plan mo ang sariling imbakan. Mag-upgrade sa web para magamit ito.';

  @override
  String get storageHealthTitle => 'Kalusugan ng imbakan';

  @override
  String get storageHealthTotal => 'Kabuuang video';

  @override
  String get storageHealthIntact => 'Buo';

  @override
  String get storageHealthUnreachable => 'Hindi maabot';

  @override
  String get storageHealthMismatched => 'Hindi tugma sa selyo';

  @override
  String get storageHealthPendingRelay => 'Naghihintay sa relay area';

  @override
  String get storageProblemsNote =>
      'May problema ang ilang video sa imbakan mo. Suriin ang access permission sa panig ng provider.';

  @override
  String get storageTest => 'Subukan ulit ang koneksyon';

  @override
  String get storageInUse => 'Ginagamit';

  @override
  String storageLastCheckAt(String time) {
    return 'Huling audit: $time';
  }

  @override
  String get storageNeverChecked => 'Hindi pa naa-audit.';

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
  String get storageDisconnect => 'Itigil ang paggamit ng sariling imbakan';

  @override
  String get storageDisconnectConfirm =>
      'Ang mga video mula ngayon ay mapupunta sa imbakan ng sistema. Mananatili sa imbakan mo ang mga luma at mawawalan ng ruta ang sistema papunta sa kanila.';

  @override
  String get storageConnectS3 => 'Ikonekta ang S3 storage';

  @override
  String get storageConnectDrive => 'Ikonekta ang Google Drive';

  @override
  String get storageConnectHint =>
      'Magbigay ng read/write/delete sa prefix sa ibaba lang — hindi kailangan ng pahintulot sa buong bucket.';

  @override
  String get storageConnectSubmit => 'Subukan at i-save';

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
      'Sub-folder sa loob ng bucket. Iwan ang default kung hindi sigurado.';

  @override
  String get storageDriveFailed =>
      'Could not connect Google Drive: the server\'s connection to Google is not configured yet. That is system-side setup, not a permission the app can ask you for — tell your technical contact.';

  @override
  String get storageConnected => 'Nakakonekta ang sariling imbakan.';

  @override
  String get storageDisconnected => 'Naputol ang sariling imbakan.';

  @override
  String get storageSwitchedToSystem =>
      'Saved. New videos go to Cloud Zenpack; your own-storage account is kept.';

  @override
  String get storageResumed => 'Saved. Using your connected storage again.';

  @override
  String get storageTestOk => 'Maayos ang koneksyon.';

  @override
  String get storageServerOutdated =>
      'The server does not support switching storage yet. Your videos stay where they are — tell your admin to update the server.';

  @override
  String get storageOwnerOnly =>
      'May-ari lang ng shop ang makakapagpalit ng imbakan.';

  @override
  String get dangerZone => 'Mapanganib na bahagi';

  @override
  String get shopDelete => 'Burahin ang shop';

  @override
  String get shopDeleteDesc =>
      'Permanenteng buburahin ang mga order, ebidensiya, nakaimbak na file at miyembro. Hindi na ito mababawi.';

  @override
  String get shopDeleteConfirmTitle => 'Burahin ang shop na ito?';

  @override
  String shopDeleteConfirmBody(int orders, int videos, int members) {
    return '$orders order · $videos video · $members miyembro ang permanenteng mabubura.';
  }

  @override
  String shopDeleteOpenDossiers(int n) {
    return 'May $n claim dossier pang bukas. Mamamatay agad ang mga link na naipadala na sa marketplace pagkabura mo.';
  }

  @override
  String get shopDeleteForce => 'Burahin pa rin';

  @override
  String get shopDeleteFailed => 'Hindi mabura ang shop.';

  @override
  String get claimsCreatedLocalOnly =>
      'Naka-save ang dossier sa teleponong ito. Hindi ito na-upload kaya wala pang share link — buksan ulit kapag online ka na.';

  @override
  String get claimsLinkCopied =>
      'Nakopya ang dossier link. I-paste sa claim channel ng marketplace.';

  @override
  String get shopRenameTitle => 'Palitan ang pangalan ng shop';

  @override
  String get shopRenameHint => 'Pangalan ng shop';

  @override
  String get shopRenamed => 'Napalitan ang pangalan ng shop';

  @override
  String get commonSave => 'I-save';

  @override
  String get inviteJoinRow => 'May imbitasyon ako';

  @override
  String inviteJoinedShop(String shop) {
    return 'Sumali sa $shop';
  }

  @override
  String inviteAlreadyJoined(String shop) {
    return 'Nasa $shop ka na';
  }

  @override
  String get inviteBadLink =>
      'Hindi wasto ang link na iyan. I-paste ang buong link mula sa email.';

  @override
  String get inviteNotFound => 'Wala ang imbitasyon o binawi na ito';

  @override
  String get inviteTaken => 'May ibang tumanggap na sa imbitasyong ito';

  @override
  String get inviteExpired =>
      'Nag-expire na ang imbitasyon. Pakiusapan ang may-ari ng shop na ipadala ulit.';

  @override
  String get inviteQrRow => 'QR code';

  @override
  String get inviteQrTitle => 'Invite code ng shop';

  @override
  String get inviteQrNote =>
      'Ipakita ang screen na ito sa taong gusto mong imbitahan. Isang beses lang magagamit ang code — magbabago ito kapag may sumali.';

  @override
  String get inviteScanTitle => 'I-scan ang invite code';

  @override
  String get inviteScanDetail =>
      'Pakiusapan ang may-ari ng shop na ipakita ang invite QR code, tapos i-scan dito.';

  @override
  String get commonShare => 'Ibahagi';

  @override
  String get inviteQrSaved => 'Na-save ang QR code sa gallery mo';

  @override
  String get inviteQrSaveFailed => 'Hindi ma-save ang QR code';

  @override
  String get voiceRecordingStarted => 'Nagsimula na ang pag-record';

  @override
  String get voiceRecordingStopped => 'Tapos na ang pag-record';

  @override
  String get voiceWrongCode => 'Maling code';

  @override
  String get voiceCapSoon => 'Malapit nang matapos ang video';

  @override
  String voiceCapNear(int minutes) {
    return 'Malapit na sa limitasyong $minutes minuto, awtomatikong matatapos ang video';
  }

  @override
  String get voiceInterrupted => 'Naantala ang pag-record';

  @override
  String get videoTypePacking => 'Pag-pack';

  @override
  String get videoTypeCarrier => 'Pagturn-over sa courier';

  @override
  String get videoTypeReturn => 'Return';

  @override
  String get storageIntro =>
      'Kung saan nakatira ang mga video ng shop. Saan man ito, nasa sistema pa rin ang rekord ng selyo — hindi pinahihina ng paglipat ng imbakan ang ebidensiya.';

  @override
  String get storageS3Title => 'Sarili mong cloud storage (S3-compatible)';

  @override
  String get storageS3Desc =>
      'AWS S3, Cloudflare R2, MinIO, Wasabi… Nasa bucket mo ang mga video, at ikaw ang may pananagutan sa tibay nito.';

  @override
  String get storageDriveTitle => 'Google Drive';

  @override
  String get storageDriveDesc =>
      'Ikonekta sa isang pagbibigay ng pahintulot, walang key na idi-paste. Ang libreng account ay may 15 GB lang na kabahagi ng Gmail.';

  @override
  String get storageNeedProPlan =>
      'Kailangan ng plan na Professional pataas para ikonekta ang sariling imbakan.';

  @override
  String get attachCodeToOrder => 'Mag-scan ng isa pang code sa order na ito';

  @override
  String get attachedCodes => 'Mga nakakabit na code';

  @override
  String get codeAttached => 'Nakakabit na ang code';

  @override
  String get codeBelongsToAnotherOrder =>
      'Nasa ibang order na ang code na ito.';

  @override
  String get codeAttachFailed => 'Hindi maikabit ang code.';

  @override
  String get storageEditCta => 'Change settings';

  @override
  String get storageValidateOk =>
      'The config works. Press Save to switch to this storage.';

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
}

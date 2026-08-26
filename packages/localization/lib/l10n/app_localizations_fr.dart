// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get bundleBackendPending =>
      'En attente d\'un point d\'accès serveur pour cela';

  @override
  String get bundleCreate => 'Créer';

  @override
  String get bundleCreateClaim => 'Créer un dossier de réclamation';

  @override
  String get accountClaims => 'Dossiers de réclamation';

  @override
  String get claimsTitle => 'Dossiers de réclamation';

  @override
  String get claimsLocalOnlyNote =>
      'Certains dossiers n\'ont pas encore été envoyés et n\'existent que sur cet appareil.';

  @override
  String get claimsOfflineNote =>
      'Serveur injoignable : ceci est la copie locale. Rouvrez une fois connecté pour tout voir.';

  @override
  String get claimsEmpty =>
      'Aucun dossier pour l\'instant. Ouvrez l\'onglet Commandes, appuyez sur le bouton plus et choisissez les preuves.';

  @override
  String claimsSummary(int orders, int evidence) {
    return '$orders commandes · $evidence preuves';
  }

  @override
  String claimsEvidenceOnly(int evidence) {
    return '$evidence preuves';
  }

  @override
  String get claimsCopied => 'Contenu du dossier copié';

  @override
  String get claimsCreated => 'Dossier de réclamation créé';

  @override
  String get claimsPickNothing => 'Aucune preuve sélectionnée';

  @override
  String get claimsDelete => 'Supprimer le dossier';

  @override
  String get claimsDeleteConfirm =>
      'Supprimer ce dossier ? Les preuves dans les commandes ne sont pas touchées.';

  @override
  String get claimsDeleteConfirmLink =>
      'Supprimer ce dossier ? Son lien public meurt immédiatement — toute personne à qui vous l’avez déjà envoyé verra une page vide. Les preuves dans les commandes ne sont pas touchées.';

  @override
  String get claimsRevokeFailed =>
      'Le lien n’a pas pu être révoqué, le dossier reste donc tel quel. Le lien est toujours actif — réessayez avec une meilleure connexion, ou demandez au propriétaire de la boutique de le révoquer.';

  @override
  String get claimsDeleted => 'Dossier supprimé';

  @override
  String get claimsPhotoAdded =>
      'Photo ajoutée au dossier et mise en file d\'attente sur la commande';

  @override
  String get claimsAddedLater => 'ajoutée plus tard';

  @override
  String get claimsCreateTitle => 'Nouveau dossier de réclamation';

  @override
  String get claimsCreateSearchHint =>
      'Saisissez ou scannez le numéro de suivi';

  @override
  String get claimsCreateNameHint => 'ex. Réclamation retour 12/08';

  @override
  String get claimsCreateNameLabel => 'Nom du dossier';

  @override
  String get claimInfoTitle => 'Détails du dossier';

  @override
  String get claimTrackingLabel => 'Numéro de suivi';

  @override
  String get claimShopLabel => 'Boutique';

  @override
  String get claimChannelLabel => 'Canal de vente';

  @override
  String get claimOrderCreatedAt => 'Date de commande';

  @override
  String get claimEvidenceLabel => 'Preuves';

  @override
  String claimEvidenceCount(int videos, int photos) {
    return '$videos vidéos · $photos photos';
  }

  @override
  String get claimCreatedAtLabel => 'Dossier créé';

  @override
  String get claimCopyLink => 'Copy link';

  @override
  String get claimsRevokeNoLink =>
      'This dossier is not on the server yet, so there is no link to revoke.';

  @override
  String get claimPageFailed =>
      'Could not open the dossier page. Check your connection and try again.';

  @override
  String get claimLinkLabel => 'Lien du dossier';

  @override
  String get claimLinkHint =>
      'Toute personne disposant du lien peut le consulter, sans connexion. Il reste actif jusqu’à révocation.';

  @override
  String get claimRevokedBadge => 'Révoqué';

  @override
  String get claimRevokedHint =>
      'Le lien est mort. Les données sont intactes — créez un nouveau dossier pour le partager à nouveau.';

  @override
  String get claimRevoke => 'Révoquer';

  @override
  String get claimUntitled => 'Dossier sans titre';

  @override
  String get claimRevokeConfirmTitle => 'Révoquer ce dossier ?';

  @override
  String get claimRevokeConfirmBody =>
      'Le lien meurt immédiatement pour quiconque le détient, y compris la marketplace. Les données et les liens par commande ne sont pas affectés.';

  @override
  String get claimRevoked => 'Dossier révoqué. Le lien ne s’ouvre plus.';

  @override
  String get claimRevokeFailed =>
      'Révocation impossible. Réessayez une fois en ligne.';

  @override
  String get claimNotUploaded =>
      'Ce dossier n’a pas encore été envoyé, il n’a donc pas de lien. Rouvrez-le une fois en ligne.';

  @override
  String get claimDetailLoadFailed =>
      'Impossible de charger le dossier. Vérifiez la connexion et rouvrez-le.';

  @override
  String get claimsCreateStart =>
      'Saisissez le numéro de suivi, ou appuyez sur scanner, pour trouver la commande concernée.';

  @override
  String get claimsCreateNoOrder =>
      'Aucune commande avec ce numéro de suivi dans la boutique sélectionnée.';

  @override
  String get claimsRemoveItemTitle => 'Retirer du dossier';

  @override
  String get claimsRemoveItemConfirm =>
      'Retirer cette preuve du dossier de réclamation ? La vidéo/photo de la commande n\'est pas touchée.';

  @override
  String get claimsItemRemoved => 'Retirée du dossier';

  @override
  String get claimsItemAdded => 'Ajouté au dossier';

  @override
  String get commonRemove => 'Retirer';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get settingDefaultSuffix => 'par défaut';

  @override
  String get shopDetailClipLength => 'Durée de la vidéo';

  @override
  String get shopDeleteTitle => 'Supprimer la boutique';

  @override
  String get shopDeleteConfirm =>
      'Supprimer cette boutique ? Toutes ses commandes, vidéos et photos disparaissent avec elle, sans récupération possible.';

  @override
  String get shopDeleteBlockedTitle => 'La boutique a encore des membres';

  @override
  String shopDeleteBlockedBody(int count) {
    return 'Retirez tous les membres avant de supprimer la boutique. Il en reste $count.';
  }

  @override
  String get shopDeleted => 'Boutique supprimée.';

  @override
  String bundleSelected(int count) {
    return '$count sélectionnés';
  }

  @override
  String get bundleUploadDrive => 'Envoyer sur Drive';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonClose => 'Fermer';

  @override
  String get toastChangeLanguage => 'Changer de langue';

  @override
  String get toastTermsPolicy => 'Conditions et politique';

  @override
  String get toastInfoSaved => 'Informations enregistrées';

  @override
  String get toastPasswordCreated => 'Mot de passe créé';

  @override
  String get toastPasswordChanged => 'Mot de passe modifié';

  @override
  String get toastPendingDossierConfirm =>
      'Vous avez encore un dossier de réclamation ouvert, veuillez confirmer à nouveau';

  @override
  String get toastCopiedShareLink => 'Lien de partage copié';

  @override
  String get toastShareFailed => 'Partage impossible, réessayez plus tard';

  @override
  String get toastDownloadingVideo => 'Téléchargement de la vidéo';

  @override
  String get toastVideoDownloadedCopied => 'Vidéo téléchargée et chemin copié';

  @override
  String get toastVideoSavedToGallery =>
      'Vidéo enregistrée dans la galerie de votre appareil';

  @override
  String get toastVideoDownloadFailed =>
      'Téléchargement de la vidéo impossible, réessayez plus tard';

  @override
  String get toastVideoDeleteUnavailable =>
      'Cette vidéo ne peut pas être supprimée';

  @override
  String get toastDownloadingPhoto => 'Téléchargement de la photo';

  @override
  String get toastPhotoSavedToGallery =>
      'Photo enregistrée dans la galerie de votre appareil';

  @override
  String get toastPhotoDownloadedCopied => 'Photo téléchargée et chemin copié';

  @override
  String get toastPhotoDownloadFailed =>
      'Téléchargement de la photo impossible, réessayez plus tard';

  @override
  String get toastPhotoNoDownloadLink =>
      'La photo n\'a pas encore de lien de téléchargement';

  @override
  String get toastPhotoQueued =>
      'Photo jointe — mise en file d\'attente d\'envoi';

  @override
  String imageOverFixedCap(String megabytes, String limit) {
    return 'La photo fait $megabytes Mo — au-dessus de la limite de $limit Mo, elle n\'a pas été jointe. Choisissez une image plus petite.';
  }

  @override
  String get toastInvitePending =>
      'En attente d\'une invitation à une boutique';

  @override
  String get toastInviteSent => 'Invitation envoyée';

  @override
  String get toastMemberAdded => 'Membre ajouté';

  @override
  String get toastVideoPlayFailed => 'Lecture de la vidéo impossible';

  @override
  String get toastShopCreated => 'Nouvelle boutique créée';

  @override
  String get toastVideoQueued =>
      'Vidéo enregistrée — mise en file d\'attente d\'envoi';

  @override
  String get toastVideoNoPlayLink =>
      'La vidéo n\'a pas encore de lien de lecture';

  @override
  String get toastVideoNoDownloadLink =>
      'La vidéo n\'a pas encore de lien de téléchargement';

  @override
  String get toastVideoDeleted => 'Vidéo supprimée';

  @override
  String get toastVideoTypeSaved => 'Type de vidéo enregistré';

  @override
  String get toastVideoTypeDeleted => 'Type de vidéo supprimé';

  @override
  String get toastNoVideoTypeToDelete => 'Aucun type de vidéo à supprimer';

  @override
  String get toastNoMemberToUpdate => 'Aucun membre à mettre à jour';

  @override
  String get toastMemberRemoved =>
      'Retiré de la boutique (les vidéos déjà enregistrées finissent leur envoi)';

  @override
  String get toastInviteRevoked =>
      'Invitation supprimée — le lien envoyé par e-mail ne fonctionne plus';

  @override
  String copiedLabel(String label) {
    return '$label copié';
  }

  @override
  String get labelTrackingCode => 'numéro de suivi';

  @override
  String resolutionChanged(String value) {
    return 'Résolution : $value';
  }

  @override
  String get accountNoName => 'Pas encore de nom';

  @override
  String get accountNoShop => 'Aucune boutique sélectionnée';

  @override
  String get accountCreatePassword => 'Créer un mot de passe';

  @override
  String get accountChangePassword => 'Changer le mot de passe';

  @override
  String accountLinkedMethods(int count) {
    return '$count liés';
  }

  @override
  String get roleOwner => 'Propriétaire';

  @override
  String get roleStaff => 'Employé';

  @override
  String memberInviteSent(String role) {
    return '$role · invitation envoyée';
  }

  @override
  String memberInvitePending(String role) {
    return '$role · en attente de confirmation';
  }

  @override
  String get planFree => 'Gratuit';

  @override
  String get planBasic => 'Basic';

  @override
  String get planSaver => 'Saver';

  @override
  String get planPremium => 'Premium';

  @override
  String get planPro => 'Pro';

  @override
  String get planEnterprise => 'Entreprise';

  @override
  String get roleOther => 'Autre';

  @override
  String get roleUnknown => 'Inconnu';

  @override
  String get memberFallbackName => 'Membre';

  @override
  String get uploadStatusDone => 'Envoyée';

  @override
  String get uploadStatusPending => 'En attente d\'envoi';

  @override
  String get uploadStatusQuotaHold => 'En attente (quota)';

  @override
  String get uploadStatusDeleted => 'Supprimée';

  @override
  String get uploadStatusError =>
      'Envoi inachevé — le clip est encore sur l\'appareil qui l\'a filmé';

  @override
  String get uploadStatusExpired => 'Durée de conservation expirée';

  @override
  String expiredOnDate(String date) {
    return 'Durée de conservation expirée le $date';
  }

  @override
  String get kindPhoto => 'Photo jointe';

  @override
  String get kindVideo => 'Vidéo';

  @override
  String get recordedByFallback => 'Compte actuel';

  @override
  String get deviceUnknown => 'Appareil inconnu';

  @override
  String get orderNoEvidence => 'Pas encore de preuve';

  @override
  String get timelineEmpty => 'Cet envoi n\'a encore ni vidéo ni photo';

  @override
  String get errorGenericRetry =>
      'Un problème est survenu, veuillez réessayer.';

  @override
  String get errorPendingDossier =>
      'Vous avez encore un dossier de réclamation ouvert, traitez-le avant de continuer.';

  @override
  String get errorSessionExpired =>
      'Votre session a expiré, veuillez vous reconnecter.';

  @override
  String get errorNoNetwork => 'Pas de connexion réseau, veuillez réessayer.';

  @override
  String get errorNoPermission =>
      'Vous n\'avez pas la permission pour cette action.';

  @override
  String get errorServerBusy => 'Le système est occupé, réessayez plus tard.';

  @override
  String get errorSessionInvalid =>
      'Session invalide, veuillez vous reconnecter.';

  @override
  String get errorVideoTypeInUse =>
      'Impossible de supprimer un type de vidéo qui a déjà des vidéos. Vérifiez d\'abord les vidéos de ce type.';

  @override
  String get errorBuiltinVideoTypeLocked =>
      'Les 3 types de vidéo intégrés ne peuvent être ni modifiés ni supprimés.';

  @override
  String get errorVideoTypeNameExists =>
      'Ce nom de type de vidéo existe déjà dans la boutique.';

  @override
  String get errorCheckNetwork =>
      'Vérifiez votre réseau ou réessayez plus tard.';

  @override
  String get errorLoadShopList =>
      'Impossible de charger la liste des boutiques';

  @override
  String get errorLoadShopMgmt =>
      'Impossible de charger la gestion de la boutique';

  @override
  String get errorLoadShopDetail =>
      'Impossible de charger les détails de la boutique';

  @override
  String get errorLoadMembers => 'Impossible de charger la liste des membres';

  @override
  String get membersRestricted =>
      'Seul le propriétaire de la boutique voit la liste des membres';

  @override
  String get errorLoadOrders => 'Impossible de charger les commandes';

  @override
  String get errorLoadOrderDetail =>
      'Impossible de charger les détails de la commande';

  @override
  String get noShopSelectedOrdersDetail =>
      'Choisissez d\'abord une boutique pour voir les commandes.';

  @override
  String get noShopSelectedRecordDetail =>
      'Choisissez d\'abord une boutique avant d\'enregistrer.';

  @override
  String get noShopSelectedManageDetail => 'Choisissez une boutique à gérer.';

  @override
  String get noOrdersTitle => 'Pas encore de commandes';

  @override
  String get noOrdersDetail => 'Choisissez une commande dans la liste.';

  @override
  String get noVideoDataTitle => 'Aucune donnée vidéo';

  @override
  String get cannotOpenVideoTitle => 'Impossible d\'ouvrir la vidéo';

  @override
  String get cannotOpenVideoDetail =>
      'La vidéo n\'a pas encore de lien de lecture.';

  @override
  String get createOrderDialogTitle => 'Créer une nouvelle commande ?';

  @override
  String createOrderDialogBody(String code) {
    return '$code ne correspond à aucun numéro de suivi de cette boutique. Vérifiez le code ou confirmez la création d\'une nouvelle commande.';
  }

  @override
  String get createOrderConfirm => 'Créer une nouvelle commande';

  @override
  String get statOrdersToday => 'Commandes';

  @override
  String get statVideosRecorded => 'Vidéos enregistrées';

  @override
  String get statPendingUpload => 'Envoi en attente';

  @override
  String get accountPlanQuota => 'Stockage';

  @override
  String get accountChangePlan => 'Changer de forfait';

  @override
  String get accountSectionApp => 'FORFAIT ET APPLI';

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
  String get accountLanguage => 'Langue';

  @override
  String get accountSectionSecurity => 'SÉCURITÉ ET CONNEXION';

  @override
  String get accountLoginMethods => 'Méthode de connexion';

  @override
  String get accountSignOut => 'Se déconnecter';

  @override
  String get accountSignOutConfirmTitle => 'Se déconnecter ?';

  @override
  String get accountSignOutConfirmMessage =>
      'Vous devrez vous reconnecter pour continuer à utiliser l\'application.';

  @override
  String get accountDeleteAccount => 'Supprimer le compte';

  @override
  String accountVersion(String version) {
    return 'Version $version';
  }

  @override
  String get accountShopMgmtHint =>
      'Gérer boutique/membres : appuyez sur retour dans l\'en-tête pour revenir au niveau Boutique';

  @override
  String get accountInfoTitle => 'Informations du compte';

  @override
  String get accountFullName => 'Nom complet';

  @override
  String get accountFullNameHint => 'Saisissez votre nom complet';

  @override
  String get accountFullNameRequired => 'Veuillez saisir votre nom complet';

  @override
  String get phoneOptionalLabel => 'Numéro de téléphone (facultatif)';

  @override
  String get phoneOptionalHint =>
      'Facultatif — uniquement pour l\'assistance du compte';

  @override
  String get phoneInvalid => 'Numéro de téléphone invalide';

  @override
  String get accountSaveChanges => 'Enregistrer les modifications';

  @override
  String get accountEmailLockedHint =>
      'E-mail utilisé pour la connexion — non modifiable';

  @override
  String get commonContinue => 'Continuer';

  @override
  String get commonLater => 'Plus tard';

  @override
  String get cameraPermissionRationaleTitle => 'Accès à la caméra requis';

  @override
  String get cameraPermissionRationaleBody =>
      'ZenPack a besoin de la caméra pour enregistrer les vidéos de preuve d\'emballage de vos commandes.';

  @override
  String get cameraPermissionDeniedTitle =>
      'Enregistrement impossible pour l\'instant';

  @override
  String get cameraPermissionDeniedBody =>
      'ZenPack ne peut pas enregistrer de vidéo car l\'accès à la caméra n\'a pas été accordé. Vous pouvez toujours consulter, chercher et gérer vos commandes.';

  @override
  String get cameraPermissionOpenSettings => 'Ouvrir les réglages';

  @override
  String get languageNameVietnamese => 'Vietnamien';

  @override
  String get languageNameEnglish => 'Anglais';

  @override
  String get languageChangeAppliesNote =>
      'Les changements s\'appliquent immédiatement dans toute l\'application';

  @override
  String get linkLinked => 'Lié';

  @override
  String get linkNotLinked => 'Non lié';

  @override
  String get loginMethodsEmailNote =>
      'L\'e-mail est l\'identifiant de votre compte — il ne peut pas être retiré. Liez Google/Apple pour vous connecter vite avec le même compte.';

  @override
  String get loginMethodIdentity => 'Identifiant';

  @override
  String get linkAction => 'Lier';

  @override
  String get linkUnlink => 'Délier';

  @override
  String get quotaScreenTitle => 'Rapports et quota';

  @override
  String get quotaRemainingThisMonth => 'Restant ce mois-ci';

  @override
  String get quotaSubtitle => 'Suivez le stockage que vous utilisez';

  @override
  String quotaRemainingAmount(String amount) {
    return '$amount restants';
  }

  @override
  String get quotaStorage => 'Stockage';

  @override
  String get deleteAccountTitleStep1 => 'Supprimer le compte ?';

  @override
  String get deleteAccountTitleStep2 => 'Confirmer la suppression définitive ?';

  @override
  String get deleteAccountBodyStep1 =>
      'Toutes vos vidéos, expéditions et dossiers seront définitivement supprimés. Cette action est irréversible.';

  @override
  String get deleteAccountBodyStep2 =>
      'C\'est la dernière étape de confirmation. Après la suppression, vous serez déconnecté immédiatement.';

  @override
  String get deleteConfirmPermanent => 'Supprimer définitivement';

  @override
  String get deleteStep1Hint => 'Étape 1/2 — une confirmation sera redemandée';

  @override
  String get deleteStep2Hint => 'Étape 2/2 — cette action est irréversible';

  @override
  String get passwordCurrentLabel => 'Mot de passe actuel';

  @override
  String get passwordCurrentRequired =>
      'Veuillez saisir votre mot de passe actuel';

  @override
  String get passwordNewLabel => 'Nouveau mot de passe';

  @override
  String get passwordMinHint => 'Au moins 8 caractères';

  @override
  String get passwordNewRequired => 'Veuillez saisir un nouveau mot de passe';

  @override
  String get passwordMin8Error =>
      'Le mot de passe doit contenir au moins 8 caractères';

  @override
  String get passwordNeedsLetterDigit =>
      'Le mot de passe doit contenir des lettres et des chiffres';

  @override
  String get passwordTooCommon =>
      'Ce mot de passe est trop facile à deviner — choisissez-en un autre';

  @override
  String get passwordConfirmLabel => 'Ressaisissez le nouveau mot de passe';

  @override
  String get passwordMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get passwordSave => 'Enregistrer le mot de passe';

  @override
  String get passwordChangeLogoutNote =>
      'Vous serez déconnecté des autres appareils après le changement';

  @override
  String get navOrders => 'Commandes';

  @override
  String get navRecord => 'Enregistrer';

  @override
  String get navAccount => 'Compte';

  @override
  String get navClaims => 'Réclamations';

  @override
  String get changeAvatar => 'Changer la photo de profil';

  @override
  String quotaVideosRatio(int remaining, int total) {
    return '$remaining / $total vidéos';
  }

  @override
  String quotaUsedPercent(int percent) {
    return '$percent% utilisés';
  }

  @override
  String quotaRetentionDays(int days) {
    return '$days jours';
  }

  @override
  String quotaUsedRatio(String used, String cap, int percent) {
    return '$used / $cap utilisés · $percent%';
  }

  @override
  String get quotaVideosStored => 'Vidéos stockées';

  @override
  String quotaVideosStoredCount(int count) {
    return '$count vidéos';
  }

  @override
  String get quotaByType => 'Stockage par type';

  @override
  String quotaByTypeVideosCount(int count) {
    return '$count vidéos stockées';
  }

  @override
  String quotaRefundNote(int days) {
    return 'Le stockage se libère dès qu\'une vidéo dépasse sa durée de conservation de $days jours';
  }

  @override
  String deletePendingProfilesWarning(int count) {
    return 'Vous avez encore $count dossiers « envoyés à la plateforme » — leurs liens de partage cesseront de fonctionner';
  }

  @override
  String get detailRecordedTime => 'Heure d\'enregistrement';

  @override
  String get detailDuration => 'Durée';

  @override
  String get detailRecordedBy => 'Enregistrée par';

  @override
  String get detailCapturedTime => 'Heure de capture';

  @override
  String get detailCapturedBy => 'Capturée par';

  @override
  String get detailDevice => 'Appareil';

  @override
  String get detailSize => 'Taille';

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
  String get detailUploadStatus => 'Statut d\'envoi';

  @override
  String get detailSeal => 'Scellé';

  @override
  String sealSealed(String at) {
    return 'Verrouillé · $at';
  }

  @override
  String get sealWorking => 'Incrustation de l\'horodatage…';

  @override
  String get sealWorkingHint =>
      'La copie stockée n\'a pas encore d\'horodatage incrusté, le lien de partage et le téléchargement attendent donc. Quelques secondes en général.';

  @override
  String get playLocalCopyNote =>
      'Copie temporaire sur cet appareil — pas encore d\'horodatage sur les images';

  @override
  String get sealNone => 'Enregistrée avant l\'existence du scellé';

  @override
  String get sealFailed =>
      'Pas encore d\'horodatage incrusté · la vidéo se lit et se télécharge quand même';

  @override
  String get sealMismatch =>
      'Empreinte non concordante — réenregistrez ce clip';

  @override
  String get sealTimeDrift =>
      'L\'horloge de la caméra s\'est décalée du serveur, le tampon incrusté porte donc aussi l\'heure de réception par le serveur.';

  @override
  String get detailSealAnchor => 'Preuve indépendante';

  @override
  String sealAnchorConfirmed(String block) {
    return 'Oui · entrée n°$block';
  }

  @override
  String get sealAnchorConfirmedNoBlock => 'Oui';

  @override
  String get sealAnchorPending =>
      'En cours d\'inscription au registre public (quelques heures)';

  @override
  String get sealAnchorNone => 'Aucune';

  @override
  String get sealVerifyOpen => 'Ouvrir la page de vérification';

  @override
  String get sealVerifyHint =>
      'Envoyez ce lien à la marketplace — elle peut vérifier elle-même, sans faire confiance à ZenPack.';

  @override
  String get sealVerifyFailed =>
      'Impossible d\'ouvrir la page de vérification.';

  @override
  String get detailPlayVideo => 'Lire la vidéo';

  @override
  String get detailCopyAssetLink => 'Copier le lien';

  @override
  String get assetLinkTitle => 'Lien de la preuve';

  @override
  String get detailDownloadVideo => 'Télécharger la vidéo';

  @override
  String get detailDownloadNote =>
      'Propriétaire/gérant uniquement · pour quand la marketplace réclame le fichier original';

  @override
  String get detailTrimVideo => 'Découper un extrait court à envoyer';

  @override
  String get detailTrimNote =>
      'Le clip complet reste intact · l\'extrait garde son horodatage';

  @override
  String get trimSave => 'Enregistrer';

  @override
  String get trimEstimatedSize => 'Environ';

  @override
  String get trimFailed =>
      'Impossible de découper la vidéo. Le clip complet est toujours là.';

  @override
  String get trimPreparing => 'Téléchargement du clip complet…';

  @override
  String get detailDownloadPhoto => 'Télécharger la photo';

  @override
  String get attachPhotoToOrder => 'Joindre une photo à la commande';

  @override
  String get deleteVideoAction => 'Supprimer la vidéo';

  @override
  String get deletePhotoAction => 'Supprimer la photo';

  @override
  String get deleteVideoNote =>
      'Propriétaire/gérant uniquement · verrouillé tant qu\'un dossier est ouvert · confirmation en deux étapes';

  @override
  String deleteVideoInDossier(String dossier) {
    return 'This evidence is in claim dossier $dossier — remove it from the dossier first, then delete.';
  }

  @override
  String get deleteVideoConfirmTitle => 'Confirmation finale';

  @override
  String get deleteVideoConfirmBody =>
      'Cette preuve sera définitivement supprimée et irrécupérable — supprimer quand même ?';

  @override
  String get deleteVideoConfirmAction => 'Supprimer définitivement';

  @override
  String ordersErrorCount(int count) {
    return '· $count erreurs';
  }

  @override
  String ordersPendingCount(int count) {
    return '· $count en attente';
  }

  @override
  String ordersPendingEvidenceWarning(int count) {
    return '$count preuves non envoyées · pas encore de lien copiable';
  }

  @override
  String get captureFramePrompt => 'Scannez le numéro de suivi';

  @override
  String get captureCameraDownHint => 'Placez l\'étiquette dans le cadre';

  @override
  String get cutoverSavedVideo => 'Vidéo enregistrée';

  @override
  String get cutoverPreparingNext => 'Préparation de la suivante';

  @override
  String get cutoverNextOrder => 'Commande suivante';

  @override
  String get lowStorageTitle => 'Stockage presque plein';

  @override
  String get lowStorageBody =>
      'Le stockage de cet appareil est faible — un enregistrement en cours pourrait ne pas être sauvegardé entièrement. Libérez de l\'espace avant de continuer.';

  @override
  String get lowStorageAction => 'Compris';

  @override
  String cutoverClosedSummary(String code, String duration) {
    return 'Numéro de suivi $code clôturé ($duration)';
  }

  @override
  String get cutoverSignalText =>
      'Son + vibration au passage à la commande suivante';

  @override
  String get tooltipBack => 'Retour';

  @override
  String get tooltipSwitchCamera => 'Changer de caméra';

  @override
  String get tooltipEnterTracking => 'Saisir le numéro de suivi';

  @override
  String get tooltipZoomIn => 'Zoom avant';

  @override
  String get tooltipZoomOut => 'Zoom arrière';

  @override
  String get captureResolution => 'Résolution';

  @override
  String get stopRecording => 'Arrêter l\'enregistrement';

  @override
  String get videoTypeSettings => 'Réglages des types de vidéo';

  @override
  String get uploadQueueTitle => 'File d\'envoi';

  @override
  String get quotaExhaustedNote =>
      'Le quota mensuel est épuisé. L\'enregistrement fonctionne toujours, mais ces clips sont SUR CE TÉLÉPHONE et pas encore protégés — ils s\'enverront tout seuls dès que le quota sera relevé.';

  @override
  String get queueEmpty => 'Aucune vidéo dans la file pour l\'instant';

  @override
  String get queueAutoUploadNote =>
      'L\'envoi se fait automatiquement dès que vous êtes en ligne';

  @override
  String get waitingUpload => 'En attente d\'envoi';

  @override
  String get queueUploading => 'Envoi en cours';

  @override
  String get queueQuotaShort => 'En attente de quota';

  @override
  String get queueUploadFailed => 'Envoi inachevé';

  @override
  String get uploaded => 'Envoyée';

  @override
  String get waitingQuota => 'En attente de quota · encore sur l\'appareil';

  @override
  String get pausedUpload => 'En pause';

  @override
  String get queuePauseAction => 'Pause';

  @override
  String get queueResumeAction => 'Reprendre';

  @override
  String get queueDeleteAction => 'Retirer';

  @override
  String get queueClearAction => 'Vider';

  @override
  String get queueClearConfirmTitle => 'Vider toute la file ?';

  @override
  String get queueClearConfirmBody =>
      'Les clips non envoyés n\'existent que sur ce téléphone. Les vider les supprime définitivement.';

  @override
  String get queueDeleteConfirmTitle => 'Retirer de la file ?';

  @override
  String get queueDeleteConfirmBody =>
      'Ce clip n\'a pas encore été envoyé — le retirer le supprime définitivement de votre appareil.';

  @override
  String get toastQueueItemDeleted => 'Retiré de la file d\'envoi';

  @override
  String get manualTrackingTitle => 'Saisir le numéro de suivi';

  @override
  String get manualTrackingNote => 'Tapez-le ou scannez à nouveau le code';

  @override
  String get commonDone => 'Terminé';

  @override
  String get startRecording => 'Démarrer l\'enregistrement';

  @override
  String get returnCodeMismatch => 'Le code de retour ne correspond pas';

  @override
  String get enterCodeManually => 'Saisir le code manuellement';

  @override
  String get videoTypeLabel => 'Type de vidéo';

  @override
  String get videoTypeSelectNote =>
      'Choisissez le bon type — ajout/modification/suppression dans Détails de la boutique';

  @override
  String get videoTypeSheetTitle => 'Choisir un type de vidéo';

  @override
  String get videoTypeGroupDefault => 'Types par défaut (obligatoires)';

  @override
  String get videoTypeGroupCustom => 'Types propres à la boutique';

  @override
  String get manageVideoTypesNote =>
      'Gérer les types de vidéo — ouvrir Détails de la boutique';

  @override
  String queueFilterAll(int count) {
    return 'Tous ($count)';
  }

  @override
  String queueFilterUploading(int count) {
    return 'Envoi en cours ($count)';
  }

  @override
  String queueFilterErrored(int count) {
    return 'Erreurs ($count)';
  }

  @override
  String queueFilterQuotaWait(int count) {
    return 'En attente de quota ($count)';
  }

  @override
  String queueSummary(int pending, int uploading, int errored) {
    return '$pending vidéos en attente · $uploading en cours d\'envoi · $errored en échec';
  }

  @override
  String uploadingProgress(int percent) {
    return 'Envoi $percent%';
  }

  @override
  String errorRetryCount(int count) {
    return 'Erreur · Réessayer ($count)';
  }

  @override
  String returnCodeMismatchBody(String returnCode, String shopName) {
    return '$returnCode ne correspond à aucune commande de $shopName. Vérifiez le code, saisissez-le manuellement, ou confirmez la création d\'une nouvelle commande.';
  }

  @override
  String get onboardingSubtitle =>
      'Enregistrez des vidéos de preuve d\'emballage pour les vendeurs en ligne';

  @override
  String get onboardingStart => 'Commencer';

  @override
  String get authSignIn => 'Se connecter';

  @override
  String get authChooseMethod => 'Choisissez une méthode de connexion';

  @override
  String get authEmailRequired => 'Veuillez saisir votre e-mail';

  @override
  String get authEmailInvalid => 'E-mail invalide';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get authPasswordRequired => 'Veuillez saisir votre mot de passe';

  @override
  String get authForgotPassword => 'Mot de passe oublié ?';

  @override
  String get registerWithGoogle => 'S\'inscrire avec Google';

  @override
  String get registerWithApple => 'S\'inscrire avec Apple';

  @override
  String get authSignInGoogle => 'Se connecter avec Google';

  @override
  String get authSignInApple => 'Se connecter avec Apple';

  @override
  String get authNoAccountPrompt => 'Pas encore de compte ? ';

  @override
  String get authRegister => 'S\'inscrire';

  @override
  String get authOr => 'ou';

  @override
  String get registerTitle => 'Créer un nouveau compte';

  @override
  String get registerConfirmPassword => 'Ressaisissez le mot de passe';

  @override
  String get registerAgreePolicy => 'J\'accepte la politique ';

  @override
  String get registerViewPolicy => 'Voir la politique';

  @override
  String get registerCreateAccount => 'Créer un compte';

  @override
  String get registerSameEmailNote =>
      'La même adresse e-mail sera automatiquement liée à un seul compte';

  @override
  String get registerHaveAccountPrompt => 'Vous avez déjà un compte ? ';

  @override
  String get registerSuccessTitle => 'Compte créé';

  @override
  String registerSuccessVerifyMessage(String email) {
    return 'Nous avons envoyé un e-mail de vérification à $email. Vérifiez votre boîte de réception (et les spams), puis connectez-vous.';
  }

  @override
  String get registerSuccessMessage =>
      'Votre compte est prêt. Connectez-vous avec l\'e-mail et le mot de passe que vous venez d\'enregistrer.';

  @override
  String get registerSuccessAction => 'Se connecter';

  @override
  String get loginNotVerifiedTitle => 'E-mail non vérifié';

  @override
  String loginNotVerifiedMessage(String email) {
    return 'Ouvrez l\'e-mail de vérification envoyé à $email (vérifiez aussi les spams), suivez le lien, puis reconnectez-vous.';
  }

  @override
  String get loginResendVerification => 'Renvoyer l\'e-mail';

  @override
  String get loginVerificationResent => 'E-mail de vérification renvoyé';

  @override
  String get forgotPasswordTitle => 'Mot de passe oublié';

  @override
  String get forgotPasswordSubtitle =>
      'Saisissez votre e-mail pour recevoir un lien de réinitialisation';

  @override
  String get forgotPasswordSubmit => 'Envoyer le lien';

  @override
  String get forgotPasswordSent =>
      'Envoyé — vérifiez votre boîte de réception (et les spams)';

  @override
  String get forgotPasswordRememberPrompt =>
      'Vous vous souvenez de votre mot de passe ? ';

  @override
  String get shopYourShops => 'Vos boutiques';

  @override
  String get shopTapToClockIn =>
      'Appuyez sur une boutique pour prendre votre service · gérez-la ici même';

  @override
  String get shopLastOpenedNote =>
      'La boutique ouverte en dernier s\'ouvrira directement la prochaine fois';

  @override
  String get shopManageStore => 'Gérer la boutique';

  @override
  String get shopManageVisibilityNote =>
      'Visible uniquement par le titulaire du compte / le gérant';

  @override
  String get shopEmpty => 'Pas encore de boutique';

  @override
  String get shopEmptyBody =>
      'Votre compte n\'appartient encore à aucune boutique. Créez-en une pour démarrer, ou attendez l\'invitation d\'un propriétaire.';

  @override
  String get shopCreateNew => 'Créer une boutique (nom + plateforme)';

  @override
  String get shopInvitesHere => 'Les invitations apparaîtront ici';

  @override
  String get shopCreateTitle => 'Créer la boutique';

  @override
  String get shopNameLabel => 'Nom de la boutique';

  @override
  String get shopNameRequired => 'Veuillez saisir un nom de boutique';

  @override
  String get shopPlatform => 'Marketplace';

  @override
  String get shopCreateOwnerNote =>
      'Vous serez le propriétaire — ajoutez des membres plus tard dans Gérer la boutique';

  @override
  String get shopMgmtVisibilityNote =>
      'Les employés ne voient pas cet écran · les gérants ne voient que les boutiques qu\'ils gèrent';

  @override
  String get shopAddNew => 'Ajouter une boutique';

  @override
  String get sectionMembers => 'MEMBRES';

  @override
  String get sectionShopSettings => 'RÉGLAGES DE LA BOUTIQUE';

  @override
  String get sectionVideoTypes => 'TYPES DE VIDÉO';

  @override
  String get videoTypesLockedNote =>
      'Les 3 types intégrés sont verrouillés — ni modifiables ni supprimables';

  @override
  String get addMemberByContact => 'Ajouter un membre par e-mail/téléphone';

  @override
  String get recordResolution => 'Résolution d\'enregistrement';

  @override
  String get addVideoType => 'Ajouter un type (saisir un nom)';

  @override
  String get createVideoTypeTitle => 'Créer un type de vidéo';

  @override
  String get videoTypeName => 'Nom du type de vidéo';

  @override
  String get videoTypeNameHint => 'p. ex. Pesée';

  @override
  String get createVideoType => 'Créer le type';

  @override
  String get deleteVideoTypeBody =>
      'Supprimable uniquement tant que ce type n\'a aucune vidéo. S\'il en a, le système bloque la suppression pour ne pas casser les filtres de preuves et les statistiques.';

  @override
  String get deleteVideoTypeConfirm => 'Supprimer le type';

  @override
  String get deleteVideoTypeNote =>
      '(Supprimable uniquement tant que le type n\'a aucune vidéo)';

  @override
  String get addMemberTitle => 'Ajouter un membre';

  @override
  String get addMemberBody =>
      'Saisissez l\'e-mail d\'un compte ZenPack déjà inscrit. La personne reçoit une invitation et doit la confirmer pour rejoindre la boutique.';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get emailRequired => 'Saisissez une adresse e-mail.';

  @override
  String get emailInvalid => 'Saisissez une seule adresse e-mail valide.';

  @override
  String get errorInviteAccountNotFound =>
      'Cet e-mail n\'a pas encore de compte ZenPack. Demandez-lui de s\'inscrire, puis réinvitez.';

  @override
  String get errorInviteAlreadyMember =>
      'Cette personne est déjà membre de la boutique.';

  @override
  String get errorInviteMemberLimit =>
      'La limite de membres de ce forfait est atteinte. Les invitations en attente comptent — révoquez-en une pour libérer une place.';

  @override
  String get errorInviteAlreadyOwner =>
      'C\'est le propriétaire de la boutique — aucune invitation nécessaire.';

  @override
  String get errorInviteInvalidRequest =>
      'Cet e-mail n\'est pas valide. Vérifiez-le et renvoyez.';

  @override
  String get addMemberSubmit => 'Ajouter';

  @override
  String get memberOwnerLocked =>
      'Le propriétaire ne peut être ni changé de rôle ni retiré ici — la propriété appartient à la boutique, pas à une ligne d\'adhésion.';

  @override
  String get removeFromShop => 'Retirer de la boutique';

  @override
  String get revokeInvite => 'Supprimer l\'invitation';

  @override
  String get resolutionAppliesNote =>
      'S\'applique aux nouvelles vidéos enregistrées de la boutique';

  @override
  String get resolutionDefaultOption => '720p (par défaut)';

  @override
  String get ordersSearchHint => 'Saisir le numéro de suivi';

  @override
  String get ordersEmpty => 'Cette boutique n\'a pas encore de commandes';

  @override
  String recordAutoStopIn(String time) {
    return 'Arrêt automatique dans $time';
  }

  @override
  String get ordersNotFound => 'Aucune commande trouvée';

  @override
  String get ordersNotFoundHint => 'Vérifiez le numéro de suivi et réessayez';

  @override
  String ordersPageRange(int first, int last, int total) {
    return '$first–$last sur $total commandes';
  }

  @override
  String get ordersPagePrevious => 'Page précédente';

  @override
  String get ordersPageNext => 'Page suivante';

  @override
  String ordersPageNumber(int page) {
    return 'Page $page';
  }

  @override
  String get filterStatusLabel => 'Statut';

  @override
  String get filterStatusAll => 'Toutes';

  @override
  String get filterStatusPending => 'En attente d\'envoi';

  @override
  String get filterStatusError => 'Erreurs d\'envoi';

  @override
  String get filterStatusDone => 'Entièrement envoyées';

  @override
  String get filterTimeLabel => 'Période';

  @override
  String get filterTimeAll => 'N\'importe quand';

  @override
  String get filterTimeToday => 'Aujourd\'hui';

  @override
  String get filterTimeYesterday => 'Hier';

  @override
  String get filterTime7d => '7 derniers jours';

  @override
  String get filterTime30d => '30 derniers jours';

  @override
  String get filterTimePickDate => 'Choisir une date…';

  @override
  String get filterTypeLabel => 'Type de vidéo';

  @override
  String get filterTypeAll => 'Tous';

  @override
  String deleteVideoTypeTitle(String typeName) {
    return 'Supprimer le type \"$typeName\" ?';
  }

  @override
  String memberCurrentRole(String role) {
    return 'Rôle actuel : $role';
  }

  @override
  String get stopCodeTitle => 'QR code d\'arrêt d\'enregistrement';

  @override
  String get stopCodeInstructions =>
      'Imprimez-le et collez-le sur la table d\'emballage. Montrez-le à la caméra pendant l\'enregistrement pour l\'arrêter automatiquement.';

  @override
  String get scannedCodeNotFound =>
      'Aucune commande ne correspond au code scanné';

  @override
  String get onboardingTaglineOne => 'Chaque colis.';

  @override
  String get onboardingTaglineTwo => 'Une preuve.';

  @override
  String get onboardingTaglineThree => 'Protège votre chiffre d\'affaires.';

  @override
  String get authEmailPlaceholder => 'Saisissez votre e-mail';

  @override
  String get authPasswordPlaceholder => 'Saisissez votre mot de passe';

  @override
  String get registerCreateAccountSubtitle => 'Créer un nouveau compte';

  @override
  String get registerFullName => 'Nom complet';

  @override
  String get registerFullNameRequired => 'Veuillez saisir votre nom complet';

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
  String get registerAgreePrefix => 'J\'accepte les';

  @override
  String get registerTermsOfUse => 'Conditions d\'utilisation';

  @override
  String get shopChooseTitle => 'Choisir une boutique';

  @override
  String get shopChooseSubtitle => 'Choisissez une boutique pour continuer';

  @override
  String get shopManageTitle => 'Gérer les boutiques';

  @override
  String get shopManageOwnerOnly =>
      'Visible uniquement par les propriétaires et gérants';

  @override
  String get noShopTitle => 'Pas encore de boutique';

  @override
  String get noShopLineOne =>
      'Votre compte n\'appartient encore à aucune boutique.';

  @override
  String get noShopLineTwo => 'Créez une boutique pour démarrer,';

  @override
  String get noShopLineThree => 'ou attendez l\'invitation d\'un propriétaire.';

  @override
  String get noShopCreateCta => 'Créer une boutique (nom + marketplace)';

  @override
  String get noShopInviteHint => 'Les invitations apparaîtront ici';

  @override
  String get createShopTitle => 'Créer la boutique';

  @override
  String get createShopNameLabel => 'Nom de la boutique';

  @override
  String get createShopNameHint => 'p. ex. Boutique ABC';

  @override
  String get createShopPlatformLabel => 'Marketplace';

  @override
  String get createShopOwnerNote =>
      'Vous serez le propriétaire — ajoutez des membres plus tard dans Gérer les boutiques';

  @override
  String get createShopSubmit => 'Créer la boutique';

  @override
  String get shopManageDescription =>
      'Consultez et gérez les boutiques que vous administrez.';

  @override
  String get shopManageAddCta => 'Ajouter une boutique';

  @override
  String get shopManageStaffNote =>
      'Les employés ne voient pas cet écran — propriétaires et gérants uniquement.';

  @override
  String get shopDetailTitle => 'Détails de la boutique';

  @override
  String get shopDetailResolution => 'Résolution d\'enregistrement';

  @override
  String get shopDetailClipDuration => 'Durée max/vidéo';

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
    return 'Recommandé $minutes min — pour $platform ($megabytes Mo/vidéo) + $resolution';
  }

  @override
  String clipRecommendedHintUnverified(String minutes, String platform) {
    return 'Recommandé $minutes min — les limites de $platform ne sont pas confirmées, on prend les valeurs connues les plus sûres';
  }

  @override
  String clipOverRecommendedWarning(
    String minutes,
    String platform,
    String chosen,
    String megabytes,
  ) {
    return 'Au-dessus de la recommandation de $minutes min pour $platform — une vidéo de $chosen min pèse environ $megabytes Mo, elle doit donc être envoyée en lien de dossier plutôt qu\'en pièce jointe du formulaire de réclamation.';
  }

  @override
  String get clipDurationTitle => 'Durée maximale par vidéo';

  @override
  String get clipDurationSubtitle => 'Se clôture automatiquement à cette durée';

  @override
  String clipDurationPlanCap(String minutes) {
    return 'Votre forfait autorise jusqu\'à $minutes min';
  }

  @override
  String clipDurationChanged(String minutes) {
    return 'Durée max/vidéo : $minutes min';
  }

  @override
  String get shopDetailImageSize => 'Taille d\'image';

  @override
  String get shopDetailVideoSize => 'Taille de vidéo';

  @override
  String get shopDetailUploadSize => 'Taille max/fichier';

  @override
  String uploadSizeValue(String megabytes) {
    return '$megabytes Mo';
  }

  @override
  String uploadRecommendedHint(String megabytes, String platform) {
    return 'Recommandé $megabytes Mo — limite de pièce jointe de $platform';
  }

  @override
  String uploadOverRecommendedWarning(
    String megabytes,
    String platform,
    String chosen,
  ) {
    return 'Au-dessus de la recommandation de $megabytes Mo pour $platform — un fichier jusqu\'à $chosen Mo reste stocké en entier, mais doit être envoyé en lien de dossier plutôt qu\'en pièce jointe du formulaire de réclamation.';
  }

  @override
  String get uploadSizeValueUnlimited => 'Sans limite';

  @override
  String get uploadSizeTitle => 'Taille maximale par fichier';

  @override
  String uploadSizeSubtitle(String megabytes, String platform) {
    return 'Les fichiers au-dessus de la limite ne sont pas joints ; $megabytes Mo se joignent encore directement à $platform';
  }

  @override
  String uploadSizeOptionRecommended(String megabytes) {
    return '$megabytes Mo (recommandé)';
  }

  @override
  String uploadSizeChanged(String megabytes) {
    return 'Taille par fichier : $megabytes';
  }

  @override
  String avatarTooLarge(String megabytes, String limit) {
    return 'Nom et téléphone enregistrés. La photo de profil de $megabytes Mo dépasse la limite de $limit Mo et n\'a pas atteint le serveur — choisissez une image plus petite.';
  }

  @override
  String avatarUploadFailed(String reason) {
    return 'Nom et téléphone enregistrés. La photo de profil n\'a pas atteint le serveur : $reason';
  }

  @override
  String nearClipLimitWarning(String minutes) {
    return 'Proche de la limite de $minutes min — la vidéo va se clôturer d\'elle-même';
  }

  @override
  String get shopDetailAddType => 'Ajouter un type (saisir un nom)';

  @override
  String get inviteMemberTitle => 'Inviter un membre';

  @override
  String get inviteRoleFixedNote =>
      'La personne rejoint comme employé : elle enregistre des vidéos et consulte les siennes.';

  @override
  String get inviteMemberHint =>
      '(pas encore de compte → envoyer une invitation)';

  @override
  String get videoTypeIcon => 'Icône';

  @override
  String get videoTypeColor => 'Couleur';

  @override
  String get createVideoTypeSubmit => 'Créer le type';

  @override
  String get deleteVideoTypeSafeNote => 'Aucune preuve n\'est perdue';

  @override
  String get commonConfirm => 'Confirmer';

  @override
  String orderErrorCount(int count) {
    return '$count en échec';
  }

  @override
  String get videoDetailSheetTitle => 'Détail de la vidéo';

  @override
  String get tooltipStopRecording => 'Arrêter l\'enregistrement';

  @override
  String get dossierLinkTitle => 'Lien du dossier de litige';

  @override
  String get accountEndQr => 'Code d\'arrêt d\'enregistrement';

  @override
  String get accountEndQrTitle => 'Code d\'arrêt d\'enregistrement';

  @override
  String get accountEndQrShare => 'Partager le code';

  @override
  String get accountEndQrSave => 'Enregistrer dans la photothèque';

  @override
  String get recordInterruptedTitle => 'Enregistrement en pause';

  @override
  String get recordInterruptedBody =>
      'L\'enregistrement a été interrompu par quelque chose. Continuer l\'enregistrement ?';

  @override
  String get recordInterruptedResume => 'Continuer';

  @override
  String get recordInterruptedFinish => 'Terminer';

  @override
  String get commonApply => 'Appliquer';

  @override
  String get unitMinutes => 'min';

  @override
  String get clipDurationCustomLabel =>
      'Ou saisissez le nombre de minutes souhaité';

  @override
  String get supportOpenFailed =>
      'Ouverture impossible — vérifiez que l\'application est installée';

  @override
  String get feedbackThanksTitle => 'Merci !';

  @override
  String get feedbackThanksBody => 'Vos retours aident à améliorer ZenPack.';

  @override
  String get feedbackTitle => 'Que souhaitez-vous nous dire ?';

  @override
  String get feedbackHint => 'Écrivez votre retour...';

  @override
  String get feedbackSend => 'Envoyer le retour';

  @override
  String get feedbackThanks => 'Merci pour votre retour';

  @override
  String get accountSectionAbout => 'À PROPOS';

  @override
  String get accountFeedback => 'Envoyez-nous un retour';

  @override
  String get accountFeedbackNote =>
      'Partagez votre avis pour améliorer ZenPack';

  @override
  String get accountRateApp => 'Noter l\'application';

  @override
  String get accountRateAppNote => 'Soutenir le développement de ZenPack';

  @override
  String get supportFacebook => 'Écrire sur Facebook';

  @override
  String get supportZalo => 'Écrire sur Zalo';

  @override
  String get supportCall => 'Appeler le support';

  @override
  String sheetCustomMin(String min, String unit) {
    return 'Saisissez $min $unit ou plus';
  }

  @override
  String sheetCustomRange(String min, String max, String unit) {
    return 'Saisissez entre $min et $max $unit';
  }

  @override
  String get accountEndQrNote =>
      'Imprimez-le et collez-le sur la table d\'emballage. Le scanner pendant l\'enregistrement clôture le clip. Le même code fonctionne sur tous les appareils.';

  @override
  String get languageChangeScopeNote =>
      'Chaque libellé, notification et dossier\npasse dans la langue que vous choisissez.';

  @override
  String get manualEntryEmptyError =>
      'Saisissez un numéro de suivi avant d\'enregistrer';

  @override
  String get appUpdateTitle => 'Une nouvelle version est disponible';

  @override
  String get appUpdateMessage =>
      'Mettez ZenPack à jour pour les derniers correctifs et fonctionnalités.';

  @override
  String get appUpdateNow => 'Mettre à jour';

  @override
  String get appUpdateLater => 'Plus tard';

  @override
  String get quotaVideosThisMonth => 'Vidéos ce mois-ci';

  @override
  String get quotaSubtitleVideos =>
      'Suivez combien de vidéos vous avez enregistrées ce mois-ci';

  @override
  String get quotaUpgrade => 'Passer à un forfait supérieur';

  @override
  String get quotaBlockedTitle => 'Quota de vidéos épuisé';

  @override
  String get quotaBlockedNote =>
      'L\'enregistrement fonctionne toujours, mais les clips ne peuvent pas encore s\'envoyer — ils sont sur ce téléphone, sans protection. Ils s\'enverront tout seuls dès que le quota sera relevé.';

  @override
  String get quotaBlockedOwnerNote =>
      'Le quota de cette boutique est défini par le titulaire du compte — demandez-lui de l’augmenter. Un forfait que vous achetez ne s’applique qu’à votre propre compte.';

  @override
  String get quotaTopupCredits => 'Recharger des crédits';

  @override
  String get quotaOverCap => 'Au-dessus du quota du forfait';

  @override
  String quotaBlockAt(int n) {
    return 'Nouveaux enregistrements bloqués à $n vidéos';
  }

  @override
  String get quotaResetMonthly =>
      'Se réinitialise au début du mois prochain ; rien n\'est reporté';

  @override
  String get storageOwnTitle => 'Votre propre stockage';

  @override
  String storageOwnPending(int count) {
    return '$count vidéos attendent d\'être poussées vers votre stockage';
  }

  @override
  String storageOwnProblem(int count) {
    return '$count vidéos de votre stockage ont des problèmes';
  }

  @override
  String get quotaExhaustedWarn =>
      'Ne désinstallez pas l\'application et n\'effacez pas ses données tant qu\'elles ne sont pas envoyées.';

  @override
  String quotaStrandedTitle(int count) {
    return '$count vidéos en attente sur ce téléphone';
  }

  @override
  String get quotaStrandedNote =>
      'Ces vidéos n\'existent que sur ce téléphone. Le perdre, désinstaller l\'application ou effacer ses données les fait disparaître.';

  @override
  String get storageTitle => 'Stockage vidéo';

  @override
  String get storageSave => 'Enregistrer le choix de stockage';

  @override
  String get storageSystemName => 'Stockage système';

  @override
  String get storageS3Name => 'Votre propre stockage (S3)';

  @override
  String get storageDriveName => 'Votre Google Drive';

  @override
  String get storageSystemDesc =>
      'L\'option par défaut ; rien à configurer. C\'est le seul endroit où tous les engagements sur la preuve tiennent.';

  @override
  String get storageOwnDesc =>
      'Les nouvelles vidéos vont directement dans votre stockage. Les anciennes restent où elles sont jusqu\'à la fin de leur conservation.';

  @override
  String get storageNoPresign =>
      'Ce stockage ne peut pas signer de liens de téléchargement, les vidéos doivent donc transiter par le serveur — celui qui ouvre votre lien trouvera cela plus lent.';

  @override
  String get storageNoObjectLock =>
      'Ce stockage n\'a pas de verrouillage d\'objet. Vous ne pouvez pas promettre à une marketplace que la preuve est indestructible.';

  @override
  String get storageNotInPlan =>
      'Votre forfait n\'inclut pas encore de stockage personnel. Passez à un forfait supérieur sur le web pour l\'utiliser.';

  @override
  String get storageHealthTitle => 'État du stockage';

  @override
  String get storageHealthTotal => 'Total des vidéos';

  @override
  String get storageHealthIntact => 'Intactes';

  @override
  String get storageHealthUnreachable => 'Inaccessibles';

  @override
  String get storageHealthMismatched => 'Non concordantes avec le scellé';

  @override
  String get storageHealthPendingRelay => 'En attente dans la zone de relais';

  @override
  String get storageProblemsNote =>
      'Certaines vidéos ont des problèmes dans votre stockage. Vérifiez les droits d\'accès côté fournisseur.';

  @override
  String get storageTest => 'Retester la connexion';

  @override
  String get storageInUse => 'Utilisé';

  @override
  String storageLastCheckAt(String time) {
    return 'Dernier audit : $time';
  }

  @override
  String get storageNeverChecked => 'Jamais audité.';

  @override
  String storageDriveCurrentAccount(String email) {
    return 'Currently connected: $email. Sign in with that address to keep the same Drive, or pick another to switch.';
  }

  @override
  String get storageDriveAccount => 'Compte Drive';

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
  String get storageDisconnect => 'Cesser d\'utiliser le stockage personnel';

  @override
  String get storageDisconnectConfirm =>
      'Les vidéos enregistrées à partir de maintenant vont dans le stockage système. Les anciennes restent dans le vôtre et le système perd la route vers elles.';

  @override
  String get storageConnectS3 => 'Connecter un stockage S3';

  @override
  String get storageConnectDrive => 'Connecter Google Drive';

  @override
  String get storageConnectHint =>
      'Accordez lecture/écriture/suppression uniquement sur le préfixe ci-dessous — aucun droit sur tout le bucket n\'est nécessaire.';

  @override
  String get storageConnectSubmit => 'Tester et enregistrer';

  @override
  String get storageFieldEndpoint => 'Point d\'accès';

  @override
  String get storageFieldBucket => 'Bucket';

  @override
  String get storageFieldAccessKey => 'Access key ID';

  @override
  String get storageFieldSecretKey => 'Secret access key';

  @override
  String get storageFieldRegion => 'Région';

  @override
  String get storageFieldPrefix => 'Préfixe';

  @override
  String get storageFieldPrefixHint =>
      'Sous-dossier dans le bucket. Laissez la valeur par défaut en cas de doute.';

  @override
  String get storageDriveFailed =>
      'Could not connect Google Drive: the server\'s connection to Google is not configured yet. That is system-side setup, not a permission the app can ask you for — tell your technical contact.';

  @override
  String get storageConnected => 'Stockage personnel connecté.';

  @override
  String get storageDisconnected => 'Stockage personnel déconnecté.';

  @override
  String get storageSwitchedToSystem =>
      'Saved. New videos go to Cloud Zenpack; your own-storage account is kept.';

  @override
  String get storageResumed => 'Saved. Using your connected storage again.';

  @override
  String get storageTestOk => 'La connexion est saine.';

  @override
  String get storageServerOutdated =>
      'The server does not support switching storage yet. Your videos stay where they are — tell your admin to update the server.';

  @override
  String get storageOwnerOnly =>
      'Seul le propriétaire de la boutique peut changer le stockage.';

  @override
  String get dangerZone => 'Zone dangereuse';

  @override
  String get shopDelete => 'Supprimer la boutique';

  @override
  String get shopDeleteDesc =>
      'Supprime définitivement commandes, preuves, fichiers stockés et membres. Irréversible.';

  @override
  String get shopDeleteConfirmTitle => 'Supprimer cette boutique ?';

  @override
  String shopDeleteConfirmBody(int orders, int videos, int members) {
    return '$orders commandes · $videos vidéos · $members membres seront définitivement supprimés.';
  }

  @override
  String shopDeleteOpenDossiers(int n) {
    return '$n dossiers de réclamation sont encore ouverts. Les liens déjà envoyés aux marketplaces meurent au moment où vous supprimez.';
  }

  @override
  String get shopDeleteForce => 'Supprimer quand même';

  @override
  String get shopDeleteFailed => 'Impossible de supprimer la boutique.';

  @override
  String get claimsCreatedLocalOnly =>
      'Dossier enregistré sur ce téléphone. Il n\'a pas pu être envoyé, donc pas encore de lien de partage — rouvrez-le une fois en ligne.';

  @override
  String get claimsLinkCopied =>
      'Lien du dossier copié. Collez-le dans le canal de réclamation de la marketplace.';

  @override
  String get shopRenameTitle => 'Renommer la boutique';

  @override
  String get shopRenameHint => 'Nom de la boutique';

  @override
  String get shopRenamed => 'Boutique renommée';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get inviteJoinRow => 'J\'ai une invitation';

  @override
  String inviteJoinedShop(String shop) {
    return 'Vous avez rejoint $shop';
  }

  @override
  String inviteAlreadyJoined(String shop) {
    return 'Vous êtes déjà dans $shop';
  }

  @override
  String get inviteBadLink =>
      'Ce lien n\'est pas valide. Collez le lien entier depuis l\'e-mail.';

  @override
  String get inviteNotFound => 'L\'invitation n\'existe pas ou a été révoquée';

  @override
  String get inviteTaken =>
      'Quelqu\'un d\'autre a déjà accepté cette invitation';

  @override
  String get inviteExpired =>
      'L\'invitation a expiré. Demandez au propriétaire de la renvoyer.';

  @override
  String get inviteQrRow => 'QR code';

  @override
  String get inviteQrTitle => 'Code d\'invitation à la boutique';

  @override
  String get inviteQrNote =>
      'Montrez cet écran à la personne que vous voulez inviter. Le code est à usage unique : il change dès que quelqu\'un rejoint.';

  @override
  String get inviteScanTitle => 'Scanner le code d\'invitation';

  @override
  String get inviteScanDetail =>
      'Demandez au propriétaire d\'afficher le QR code d\'invitation, puis scannez-le ici.';

  @override
  String get commonShare => 'Partager';

  @override
  String get inviteQrSaved => 'QR code enregistré dans votre galerie';

  @override
  String get inviteQrSaveFailed => 'Impossible d\'enregistrer le QR code';

  @override
  String get voiceRecordingStarted => 'Enregistrement démarré';

  @override
  String get voiceRecordingStopped => 'Enregistrement arrêté';

  @override
  String get voiceWrongCode => 'Code incorrect';

  @override
  String get voiceCapSoon => 'La vidéo va bientôt se terminer';

  @override
  String voiceCapNear(int minutes) {
    return 'La limite de $minutes minutes approche, la vidéo se terminera automatiquement';
  }

  @override
  String get voiceInterrupted => 'L\'enregistrement a été interrompu';

  @override
  String get videoTypePacking => 'Emballage';

  @override
  String get videoTypeCarrier => 'Remise au transporteur';

  @override
  String get videoTypeReturn => 'Retour';

  @override
  String get storageIntro =>
      'Où sont stockées les vidéos de la boutique. Où qu’elles soient, le registre du scellé reste chez le système — changer de stockage n’affaiblit jamais la preuve.';

  @override
  String get storageS3Title => 'Votre propre stockage cloud (compatible S3)';

  @override
  String get storageS3Desc =>
      'AWS S3, Cloudflare R2, MinIO, Wasabi… Les vidéos sont dans votre bucket, leur durabilité vous incombe.';

  @override
  String get storageDriveTitle => 'Google Drive';

  @override
  String get storageDriveDesc =>
      'Connexion en une seule autorisation, aucune clé à coller. Un compte gratuit n’a que 15 Go partagés avec Gmail.';

  @override
  String get storageNeedProPlan =>
      'Connecter votre propre stockage nécessite le forfait Professionnel ou supérieur.';

  @override
  String get attachCodeToOrder => 'Scanner un autre code dans cette commande';

  @override
  String get attachedCodes => 'Codes attachés';

  @override
  String get codeAttached => 'Code rattaché à cette commande';

  @override
  String get codeBelongsToAnotherOrder =>
      'Ce code appartient déjà à une autre commande.';

  @override
  String get codeAttachFailed => 'Impossible de rattacher le code.';

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
}

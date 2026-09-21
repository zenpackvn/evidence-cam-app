// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get bundleBackendPending => 'Wartet auf einen Backend-Endpunkt dafür';

  @override
  String get bundleCreate => 'Erstellen';

  @override
  String get bundleCreateClaim => 'Reklamationsakte erstellen';

  @override
  String get accountClaims => 'Reklamationsakten';

  @override
  String get claimsTitle => 'Reklamationsakten';

  @override
  String get claimsLocalOnlyNote =>
      'Einige Dossiers wurden noch nicht hochgeladen und liegen nur auf diesem Gerät.';

  @override
  String get claimsOfflineNote =>
      'Der Server ist nicht erreichbar; dies ist die lokale Kopie. Bei Verbindung erneut öffnen.';

  @override
  String get claimsEmpty =>
      'Noch keine Akte. Öffne den Tab Bestellungen, tippe auf Plus und wähle die Nachweise aus.';

  @override
  String claimsSummary(int orders, int evidence) {
    return '$orders Bestellungen · $evidence Nachweise';
  }

  @override
  String claimsEvidenceOnly(int evidence) {
    return '$evidence Nachweise';
  }

  @override
  String get claimsCopied => 'Akteninhalt kopiert';

  @override
  String get claimsCreated => 'Reklamationsakte erstellt';

  @override
  String get claimsPickNothing => 'Keine Nachweise ausgewählt';

  @override
  String get claimsDelete => 'Akte löschen';

  @override
  String get claimsDeleteConfirm =>
      'Diese Akte löschen? Die Nachweise in den Bestellungen bleiben unberührt.';

  @override
  String get claimsDeleteConfirmLink =>
      'Diese Akte löschen? Ihr öffentlicher Link stirbt sofort — wer ihn schon bekommen hat, sieht eine leere Seite. Die Nachweise in den Bestellungen bleiben unberührt.';

  @override
  String get claimsRevokeFailed =>
      'Der Link ließ sich nicht widerrufen, deshalb bleibt die Akte unverändert. Der Link ist weiterhin offen — versuche es bei besserer Verbindung erneut, oder bitte den Shop-Inhaber, ihn zu widerrufen.';

  @override
  String get claimsDeleted => 'Akte gelöscht';

  @override
  String get claimsPhotoAdded =>
      'Foto zur Akte hinzugefügt und der Bestellung in die Warteschlange gestellt';

  @override
  String get claimsAddedLater => 'später hinzugefügt';

  @override
  String get claimsCreateTitle => 'Neue Reklamationsakte';

  @override
  String get claimsCreateSearchHint => 'Sendungsnummer eingeben oder scannen';

  @override
  String get claimsCreateNameHint => 'z. B. Rücksendung 12.08.';

  @override
  String get claimsCreateNameLabel => 'Name des Vorgangs';

  @override
  String get claimInfoTitle => 'Vorgangsdetails';

  @override
  String get claimTrackingLabel => 'Sendungsnummer';

  @override
  String get claimShopLabel => 'Shop';

  @override
  String get claimChannelLabel => 'Verkaufskanal';

  @override
  String get claimOrderCreatedAt => 'Bestelldatum';

  @override
  String get claimEvidenceLabel => 'Nachweise';

  @override
  String claimEvidenceCount(int videos, int photos) {
    return '$videos Videos · $photos Fotos';
  }

  @override
  String get claimCreatedAtLabel => 'Vorgang erstellt';

  @override
  String get claimCopyLink => 'Copy link';

  @override
  String get claimsRevokeNoLink =>
      'This dossier is not on the server yet, so there is no link to revoke.';

  @override
  String get claimPageFailed =>
      'Could not open the dossier page. Check your connection and try again.';

  @override
  String get claimLinkLabel => 'Vorgangs-Link';

  @override
  String get claimLinkHint =>
      'Jeder mit dem Link kann ihn ansehen, ohne Anmeldung. Er bleibt aktiv, bis du ihn widerrufst.';

  @override
  String get claimRevokedBadge => 'Widerrufen';

  @override
  String get claimRevokedHint =>
      'Der Link ist tot. Die Daten bleiben erhalten — erstelle einen neuen Vorgang zum Teilen.';

  @override
  String get claimRevoke => 'Widerrufen';

  @override
  String get claimUntitled => 'Vorgang ohne Titel';

  @override
  String get claimRevokeConfirmTitle => 'Diesen Vorgang widerrufen?';

  @override
  String get claimRevokeConfirmBody =>
      'Der Link stirbt sofort für alle, die ihn haben — auch für den Marktplatz. Daten und Links je Bestellung bleiben unberührt.';

  @override
  String get claimRevoked => 'Vorgang widerrufen. Der Link öffnet nicht mehr.';

  @override
  String get claimRevokeFailed =>
      'Widerruf fehlgeschlagen. Versuche es erneut, wenn du online bist.';

  @override
  String get claimNotUploaded =>
      'Dieser Vorgang wurde noch nicht hochgeladen und hat daher keinen Link. Öffne ihn erneut, wenn du online bist.';

  @override
  String get claimDetailLoadFailed =>
      'Vorgang konnte nicht geladen werden. Prüfe die Verbindung und öffne ihn erneut.';

  @override
  String get claimsCreateStart =>
      'Gib die Sendungsnummer ein oder tippe auf Scannen, um die Bestellung zu finden.';

  @override
  String get claimsCreateNoOrder =>
      'Keine Bestellung mit dieser Sendungsnummer im gewählten Shop.';

  @override
  String get claimsRemoveItemTitle => 'Aus der Akte entfernen';

  @override
  String get claimsRemoveItemConfirm =>
      'Diesen Nachweis aus der Akte entfernen? Das Video/Foto in der Bestellung bleibt unberührt.';

  @override
  String get claimsItemRemoved => 'Aus der Akte entfernt';

  @override
  String get claimsItemAdded => 'Zur Akte hinzugefügt';

  @override
  String get commonRemove => 'Entfernen';

  @override
  String get commonDelete => 'Löschen';

  @override
  String get settingDefaultSuffix => 'Standard';

  @override
  String get shopDetailClipLength => 'Videolänge';

  @override
  String get shopDeleteTitle => 'Shop löschen';

  @override
  String get shopDeleteConfirm =>
      'Diesen Shop löschen? Alle Bestellungen, Videos und Fotos verschwinden mit und lassen sich nicht wiederherstellen.';

  @override
  String get shopDeleteBlockedTitle => 'Der Shop hat noch Mitglieder';

  @override
  String shopDeleteBlockedBody(int count) {
    return 'Entferne alle Mitglieder, bevor du den Shop löschst. Es sind noch $count übrig.';
  }

  @override
  String get shopDeleted => 'Shop gelöscht.';

  @override
  String bundleSelected(int count) {
    return '$count ausgewählt';
  }

  @override
  String get bundleUploadDrive => 'Auf Drive hochladen';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonRetry => 'Erneut versuchen';

  @override
  String get commonClose => 'Schließen';

  @override
  String get toastChangeLanguage => 'Sprache ändern';

  @override
  String get toastTermsPolicy => 'Nutzungsbedingungen & Richtlinie';

  @override
  String get toastInfoSaved => 'Angaben gespeichert';

  @override
  String get toastPasswordCreated => 'Passwort erstellt';

  @override
  String get toastPasswordChanged => 'Passwort geändert';

  @override
  String get toastPendingDossierConfirm =>
      'Du hast noch eine offene Reklamationsakte, bitte erneut bestätigen';

  @override
  String get toastCopiedShareLink => 'Freigabelink kopiert';

  @override
  String get toastShareFailed => 'Teilen nicht möglich, versuche es später';

  @override
  String get toastDownloadingVideo => 'Video wird heruntergeladen';

  @override
  String get toastVideoDownloadedCopied =>
      'Video heruntergeladen und Pfad kopiert';

  @override
  String get toastVideoSavedToGallery =>
      'Video in der Galerie deines Geräts gespeichert';

  @override
  String get toastVideoDownloadFailed =>
      'Video konnte nicht heruntergeladen werden, versuche es später';

  @override
  String get toastVideoDeleteUnavailable =>
      'Dieses Video lässt sich nicht löschen';

  @override
  String get toastDownloadingPhoto => 'Foto wird heruntergeladen';

  @override
  String get toastPhotoSavedToGallery =>
      'Foto in der Galerie deines Geräts gespeichert';

  @override
  String get toastPhotoDownloadedCopied =>
      'Foto heruntergeladen und Pfad kopiert';

  @override
  String get toastPhotoDownloadFailed =>
      'Foto konnte nicht heruntergeladen werden, versuche es später';

  @override
  String get toastPhotoNoDownloadLink =>
      'Das Foto hat noch keinen Download-Link';

  @override
  String get toastPhotoQueued =>
      'Foto angehängt — in die Upload-Warteschlange gestellt';

  @override
  String imageOverFixedCap(String megabytes, String limit) {
    return 'Das Foto ist $megabytes MB groß — über dem Limit von $limit MB, deshalb nicht angehängt. Wähle ein kleineres Bild.';
  }

  @override
  String get toastInvitePending => 'Wartet auf eine Shop-Einladung';

  @override
  String get toastInviteSent => 'Einladung gesendet';

  @override
  String get toastMemberAdded => 'Mitglied hinzugefügt';

  @override
  String get toastVideoPlayFailed => 'Video konnte nicht abgespielt werden';

  @override
  String get toastShopCreated => 'Neuer Shop erstellt';

  @override
  String get toastVideoQueued =>
      'Video gespeichert — in die Upload-Warteschlange gestellt';

  @override
  String get toastVideoNoPlayLink => 'Das Video hat noch keinen Wiedergabelink';

  @override
  String get toastVideoNoDownloadLink =>
      'Das Video hat noch keinen Download-Link';

  @override
  String get toastVideoDeleted => 'Video gelöscht';

  @override
  String get toastVideoTypeSaved => 'Videotyp gespeichert';

  @override
  String get toastVideoTypeDeleted => 'Videotyp gelöscht';

  @override
  String get toastNoVideoTypeToDelete => 'Kein Videotyp zum Löschen';

  @override
  String get toastNoMemberToUpdate => 'Kein Mitglied zum Aktualisieren';

  @override
  String get toastMemberRemoved =>
      'Aus dem Shop entfernt (aufgenommene Videos werden noch fertig hochgeladen)';

  @override
  String get toastInviteRevoked =>
      'Einladung gelöscht — der Link in der E-Mail funktioniert nicht mehr';

  @override
  String copiedLabel(String label) {
    return '$label kopiert';
  }

  @override
  String get labelTrackingCode => 'Sendungsnummer';

  @override
  String resolutionChanged(String value) {
    return 'Auflösung: $value';
  }

  @override
  String get accountNoName => 'Noch kein Name';

  @override
  String get accountNoShop => 'Kein Shop ausgewählt';

  @override
  String get accountCreatePassword => 'Passwort erstellen';

  @override
  String get accountChangePassword => 'Passwort ändern';

  @override
  String accountLinkedMethods(int count) {
    return '$count verknüpft';
  }

  @override
  String get roleOwner => 'Inhaber';

  @override
  String get roleStaff => 'Mitarbeiter';

  @override
  String memberInviteSent(String role) {
    return '$role · Einladung gesendet';
  }

  @override
  String memberInvitePending(String role) {
    return '$role · wartet auf Bestätigung';
  }

  @override
  String get planFree => 'Kostenlos';

  @override
  String get planBasic => 'Basic';

  @override
  String get planSaver => 'Saver';

  @override
  String get planPremium => 'Premium';

  @override
  String get planPro => 'Pro';

  @override
  String get planEnterprise => 'Unternehmen';

  @override
  String get roleOther => 'Sonstige';

  @override
  String get roleUnknown => 'Unbekannt';

  @override
  String get memberFallbackName => 'Mitglied';

  @override
  String get uploadStatusDone => 'Hochgeladen';

  @override
  String get uploadStatusPending => 'Wartet auf Upload';

  @override
  String get uploadStatusQuotaHold => 'Zurückgestellt (Kontingent)';

  @override
  String get uploadStatusDeleted => 'Gelöscht';

  @override
  String get uploadStatusError =>
      'Upload unvollständig — der Clip liegt noch auf dem Aufnahmegerät';

  @override
  String get uploadStatusExpired => 'Aufbewahrungsfrist abgelaufen';

  @override
  String expiredOnDate(String date) {
    return 'Aufbewahrungsfrist am $date abgelaufen';
  }

  @override
  String get kindPhoto => 'Angehängtes Foto';

  @override
  String get kindVideo => 'Video';

  @override
  String get recordedByFallback => 'Aktuelles Konto';

  @override
  String get deviceUnknown => 'Unbekanntes Gerät';

  @override
  String get orderNoEvidence => 'Noch keine Nachweise';

  @override
  String get timelineEmpty =>
      'Zu dieser Sendung gibt es noch kein Video und kein Foto';

  @override
  String get errorGenericRetry =>
      'Etwas ist schiefgelaufen, bitte versuche es erneut.';

  @override
  String get errorPendingDossier =>
      'Du hast noch eine offene Reklamationsakte, bitte kläre sie zuerst.';

  @override
  String get errorSessionExpired =>
      'Deine Sitzung ist abgelaufen, bitte melde dich erneut an.';

  @override
  String get errorNoNetwork =>
      'Keine Netzwerkverbindung, bitte versuche es erneut.';

  @override
  String get errorNoPermission =>
      'Du hast keine Berechtigung für diese Aktion.';

  @override
  String get errorServerBusy =>
      'Das System ist ausgelastet, bitte versuche es später.';

  @override
  String get errorSessionInvalid =>
      'Ungültige Sitzung, bitte melde dich erneut an.';

  @override
  String get errorVideoTypeInUse =>
      'Ein Videotyp mit vorhandenen Videos lässt sich nicht löschen. Prüfe zuerst die Videos dieses Typs.';

  @override
  String get errorBuiltinVideoTypeLocked =>
      'Die 3 eingebauten Videotypen lassen sich weder ändern noch löschen.';

  @override
  String get errorVideoTypeNameExists =>
      'Diesen Videotyp-Namen gibt es im Shop bereits.';

  @override
  String get errorCheckNetwork =>
      'Prüfe dein Netzwerk oder versuche es später.';

  @override
  String get errorLoadShopList => 'Shop-Liste konnte nicht geladen werden';

  @override
  String get errorLoadShopMgmt => 'Shop-Verwaltung konnte nicht geladen werden';

  @override
  String get errorLoadShopDetail => 'Shop-Details konnten nicht geladen werden';

  @override
  String get errorLoadMembers => 'Mitgliederliste konnte nicht geladen werden';

  @override
  String get membersRestricted =>
      'Nur der Shop-Inhaber sieht die Mitgliederliste';

  @override
  String get errorLoadOrders => 'Bestellungen konnten nicht geladen werden';

  @override
  String get errorLoadOrderDetail =>
      'Bestelldetails konnten nicht geladen werden';

  @override
  String get noShopSelectedOrdersDetail =>
      'Bitte wähle zuerst einen Shop, um Bestellungen zu sehen.';

  @override
  String get noShopSelectedRecordDetail =>
      'Bitte wähle zuerst einen Shop, bevor du aufnimmst.';

  @override
  String get noShopSelectedManageDetail =>
      'Bitte wähle einen Shop zum Verwalten.';

  @override
  String get noOrdersTitle => 'Noch keine Bestellungen';

  @override
  String get noOrdersDetail => 'Bitte wähle eine Bestellung aus der Liste.';

  @override
  String get noVideoDataTitle => 'Keine Videodaten';

  @override
  String get cannotOpenVideoTitle => 'Video konnte nicht geöffnet werden';

  @override
  String get cannotOpenVideoDetail =>
      'Das Video hat noch keinen Wiedergabelink.';

  @override
  String get createOrderDialogTitle => 'Neue Bestellung anlegen?';

  @override
  String createOrderDialogBody(String code) {
    return '$code passt zu keiner Sendungsnummer in diesem Shop. Prüfe den Code oder bestätige das Anlegen einer neuen Bestellung.';
  }

  @override
  String get createOrderConfirm => 'Neue Bestellung anlegen';

  @override
  String get statOrdersToday => 'Bestellungen';

  @override
  String get statVideosRecorded => 'Aufgenommene Videos';

  @override
  String get statPendingUpload => 'Ausstehender Upload';

  @override
  String get accountPlanQuota => 'Speicher';

  @override
  String get accountChangePlan => 'Tarif wechseln';

  @override
  String get accountSectionApp => 'TARIF & APP';

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
  String get accountLanguage => 'Sprache';

  @override
  String get accountSectionSecurity => 'SICHERHEIT & ANMELDUNG';

  @override
  String get accountLoginMethods => 'Anmeldemethode';

  @override
  String get accountSignOut => 'Abmelden';

  @override
  String get accountSignOutConfirmTitle => 'Abmelden?';

  @override
  String get accountSignOutConfirmMessage =>
      'Du musst dich erneut anmelden, um die App weiter zu nutzen.';

  @override
  String get accountDeleteAccount => 'Konto löschen';

  @override
  String accountVersion(String version) {
    return 'Version $version';
  }

  @override
  String get accountShopMgmtHint =>
      'Shop/Mitglieder verwalten: Tippe im Kopfbereich auf Zurück, um zur Shop-Ebene zu gelangen';

  @override
  String get accountInfoTitle => 'Kontoinformationen';

  @override
  String get accountFullName => 'Vollständiger Name';

  @override
  String get accountFullNameHint => 'Gib deinen vollständigen Namen ein';

  @override
  String get accountFullNameRequired =>
      'Bitte gib deinen vollständigen Namen ein';

  @override
  String get phoneOptionalLabel => 'Telefonnummer (optional)';

  @override
  String get phoneOptionalHint => 'Optional — nur für den Konto-Support';

  @override
  String get phoneInvalid => 'Ungültige Telefonnummer';

  @override
  String get accountSaveChanges => 'Änderungen speichern';

  @override
  String get accountEmailLockedHint =>
      'E-Mail für die Anmeldung — nicht änderbar';

  @override
  String get commonContinue => 'Weiter';

  @override
  String get commonLater => 'Später';

  @override
  String get cameraPermissionRationaleTitle => 'Kamerazugriff erforderlich';

  @override
  String get cameraPermissionRationaleBody =>
      'ZenPack braucht die Kamera, um Verpackungsnachweise für deine Bestellungen aufzunehmen.';

  @override
  String get cameraPermissionDeniedTitle => 'Aufnahme noch nicht möglich';

  @override
  String get cameraPermissionDeniedBody =>
      'ZenPack kann kein Video aufnehmen, weil der Kamerazugriff fehlt. Bestellungen ansehen, suchen und verwalten geht weiterhin.';

  @override
  String get cameraPermissionOpenSettings => 'Einstellungen öffnen';

  @override
  String get languageNameVietnamese => 'Vietnamesisch';

  @override
  String get languageNameEnglish => 'Englisch';

  @override
  String get languageChangeAppliesNote =>
      'Änderungen gelten sofort in der ganzen App';

  @override
  String get linkLinked => 'Verknüpft';

  @override
  String get linkNotLinked => 'Nicht verknüpft';

  @override
  String get loginMethodsEmailNote =>
      'Die E-Mail ist die Kennung deines Kontos — sie lässt sich nicht entfernen. Verknüpfe Google/Apple, um dich schnell mit demselben Konto anzumelden.';

  @override
  String get loginMethodIdentity => 'Kennung';

  @override
  String get linkAction => 'Verknüpfen';

  @override
  String get linkUnlink => 'Verknüpfung lösen';

  @override
  String get quotaScreenTitle => 'Berichte & Kontingent';

  @override
  String get quotaRemainingThisMonth => 'Diesen Monat übrig';

  @override
  String get quotaSubtitle => 'Behalte den genutzten Speicher im Blick';

  @override
  String quotaRemainingAmount(String amount) {
    return '$amount übrig';
  }

  @override
  String get quotaStorage => 'Speicher';

  @override
  String get deleteAccountTitleStep1 => 'Konto löschen?';

  @override
  String get deleteAccountTitleStep2 => 'Endgültiges Löschen bestätigen?';

  @override
  String get deleteAccountBodyStep1 =>
      'Alle deine Videos, Sendungen und Akten werden endgültig gelöscht. Das lässt sich nicht rückgängig machen.';

  @override
  String get deleteAccountBodyStep2 =>
      'Das ist der letzte Bestätigungsschritt. Nach dem Löschen wirst du sofort abgemeldet.';

  @override
  String get deleteConfirmPermanent => 'Endgültig löschen';

  @override
  String get deleteStep1Hint =>
      'Schritt 1/2 — es folgt eine weitere Bestätigung';

  @override
  String get deleteStep2Hint =>
      'Schritt 2/2 — das lässt sich nicht rückgängig machen';

  @override
  String get passwordCurrentLabel => 'Aktuelles Passwort';

  @override
  String get passwordCurrentRequired => 'Bitte gib dein aktuelles Passwort ein';

  @override
  String get passwordNewLabel => 'Neues Passwort';

  @override
  String get passwordMinHint => 'Mindestens 8 Zeichen';

  @override
  String get passwordNewRequired => 'Bitte gib ein neues Passwort ein';

  @override
  String get passwordMin8Error => 'Das Passwort braucht mindestens 8 Zeichen';

  @override
  String get passwordNeedsLetterDigit =>
      'Das Passwort braucht Buchstaben und Zahlen';

  @override
  String get passwordTooCommon =>
      'Dieses Passwort ist zu leicht zu erraten — nimm ein anderes';

  @override
  String get passwordConfirmLabel => 'Neues Passwort wiederholen';

  @override
  String get passwordMismatch => 'Die Passwörter stimmen nicht überein';

  @override
  String get passwordSave => 'Passwort speichern';

  @override
  String get passwordChangeLogoutNote =>
      'Nach der Änderung wirst du auf anderen Geräten abgemeldet';

  @override
  String get navOrders => 'Bestellungen';

  @override
  String get navRecord => 'Aufnehmen';

  @override
  String get navAccount => 'Konto';

  @override
  String get navClaims => 'Reklamationen';

  @override
  String get changeAvatar => 'Profilbild ändern';

  @override
  String quotaVideosRatio(int remaining, int total) {
    return '$remaining / $total Videos';
  }

  @override
  String quotaUsedPercent(int percent) {
    return '$percent% genutzt';
  }

  @override
  String quotaRetentionDays(int days) {
    return '$days Tage';
  }

  @override
  String quotaUsedRatio(String used, String cap, int percent) {
    return '$used / $cap genutzt · $percent%';
  }

  @override
  String get quotaVideosStored => 'Gespeicherte Videos';

  @override
  String quotaVideosStoredCount(int count) {
    return '$count Videos';
  }

  @override
  String get quotaByType => 'Speicher nach Typ';

  @override
  String quotaByTypeVideosCount(int count) {
    return '$count Videos gespeichert';
  }

  @override
  String quotaRefundNote(int days) {
    return 'Speicher wird frei, sobald ein Video seine Aufbewahrungsfrist von $days Tagen überschreitet';
  }

  @override
  String deletePendingProfilesWarning(int count) {
    return 'Du hast noch $count Akten „an die Plattform gesendet“ — deren Freigabelinks hören auf zu funktionieren';
  }

  @override
  String get detailRecordedTime => 'Aufnahmezeit';

  @override
  String get detailDuration => 'Dauer';

  @override
  String get detailRecordedBy => 'Aufgenommen von';

  @override
  String get detailCapturedTime => 'Aufnahmezeitpunkt';

  @override
  String get detailCapturedBy => 'Erfasst von';

  @override
  String get detailDevice => 'Gerät';

  @override
  String get detailSize => 'Größe';

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
  String get detailUploadStatus => 'Upload-Status';

  @override
  String get detailSeal => 'Siegel';

  @override
  String sealSealed(String at) {
    return 'Gesperrt · $at';
  }

  @override
  String get sealWorking => 'Zeitstempel wird eingebrannt…';

  @override
  String get sealWorkingHint =>
      'In der gespeicherten Kopie ist noch kein Zeitstempel eingebrannt, deshalb warten Freigabelink und Download noch. Meist ein paar Sekunden.';

  @override
  String get playLocalCopyNote =>
      'Temporäre Kopie auf diesem Gerät — noch ohne Zeitstempel im Bild';

  @override
  String get sealNone => 'Aufgenommen, bevor es die Versiegelung gab';

  @override
  String get sealFailed =>
      'Noch kein Zeitstempel eingebrannt · das Video lässt sich weiterhin abspielen und herunterladen';

  @override
  String get sealMismatch =>
      'Fingerabdruck stimmt nicht — nimm diesen Clip neu auf';

  @override
  String get sealLate =>
      'Nachträgliches Siegel — das Video ist intakt; der Fehler lag bei uns';

  @override
  String get sealTimeDrift =>
      'Die Kamerauhr wich vom Server ab, deshalb trägt der eingebrannte Stempel auch die Empfangszeit des Servers.';

  @override
  String get detailSealAnchor => 'Unabhängiger Nachweis';

  @override
  String sealAnchorConfirmed(String block) {
    return 'Ja · Eintrag #$block';
  }

  @override
  String get sealAnchorConfirmedNoBlock => 'Ja';

  @override
  String get sealAnchorPending =>
      'Wird in das öffentliche Register geschrieben (einige Stunden)';

  @override
  String get sealAnchorNone => 'Keiner';

  @override
  String get sealVerifyOpen => 'Prüfseite öffnen';

  @override
  String get sealVerifyHint =>
      'Schick diesen Link an die Plattform — sie kann ihn selbst prüfen, ohne ZenPack vertrauen zu müssen.';

  @override
  String get sealVerifyFailed => 'Die Prüfseite ließ sich nicht öffnen.';

  @override
  String get detailPlayVideo => 'Video abspielen';

  @override
  String get detailCopyAssetLink => 'Link kopieren';

  @override
  String get assetLinkTitle => 'Nachweis-Link';

  @override
  String get detailDownloadVideo => 'Video herunterladen';

  @override
  String get detailDownloadNote =>
      'Nur Inhaber/Manager · für den Fall, dass die Plattform die Originaldatei verlangt';

  @override
  String get detailTrimVideo => 'Kurzen Ausschnitt zum Senden schneiden';

  @override
  String get detailTrimNote =>
      'Der vollständige Clip bleibt unberührt · der Ausschnitt behält seinen Zeitstempel';

  @override
  String get trimSave => 'Speichern';

  @override
  String get trimEstimatedSize => 'Etwa';

  @override
  String get trimFailed =>
      'Das Video ließ sich nicht schneiden. Der vollständige Clip ist noch da.';

  @override
  String get trimPreparing => 'Vollständiger Clip wird heruntergeladen…';

  @override
  String get detailDownloadPhoto => 'Foto herunterladen';

  @override
  String get attachPhotoToOrder => 'Foto an Bestellung anhängen';

  @override
  String get deleteVideoAction => 'Video löschen';

  @override
  String get deletePhotoAction => 'Foto löschen';

  @override
  String get deleteVideoNote =>
      'Nur Inhaber/Manager · gesperrt, solange eine Akte offen ist · zweistufige Bestätigung';

  @override
  String deleteVideoInDossier(String dossier) {
    return 'This evidence is in claim dossier $dossier — remove it from the dossier first, then delete.';
  }

  @override
  String get deleteVideoConfirmTitle => 'Letzte Bestätigung';

  @override
  String get deleteVideoConfirmBody =>
      'Dieser Nachweis wird endgültig gelöscht und lässt sich nicht wiederherstellen — trotzdem löschen?';

  @override
  String get deleteVideoConfirmAction => 'Endgültig löschen';

  @override
  String ordersErrorCount(int count) {
    return '· $count Fehler';
  }

  @override
  String ordersPendingCount(int count) {
    return '· $count ausstehend';
  }

  @override
  String ordersPendingEvidenceWarning(int count) {
    return '$count Nachweise noch nicht hochgeladen · noch kein kopierbarer Link';
  }

  @override
  String get captureFramePrompt => 'Sendungsnummer scannen';

  @override
  String get captureCameraDownHint => 'Leg den Beleg in den Rahmen';

  @override
  String get cutoverSavedVideo => 'Video gespeichert';

  @override
  String get cutoverPreparingNext => 'Bereit für das nächste';

  @override
  String get cutoverNextOrder => 'Nächste Bestellung';

  @override
  String get lowStorageTitle => 'Speicher fast voll';

  @override
  String get lowStorageBody =>
      'Auf diesem Gerät wird der Speicher knapp — eine laufende Aufnahme wird vielleicht nicht vollständig gespeichert. Schaffe Platz, bevor du weiter aufnimmst.';

  @override
  String get lowStorageAction => 'Verstanden';

  @override
  String cutoverClosedSummary(String code, String duration) {
    return 'Sendungsnummer $code abgeschlossen ($duration)';
  }

  @override
  String get cutoverSignalText => 'Ton + Vibration beim Wechsel der Bestellung';

  @override
  String get tooltipBack => 'Zurück';

  @override
  String get tooltipSwitchCamera => 'Kamera wechseln';

  @override
  String get tooltipEnterTracking => 'Sendungsnummer eingeben';

  @override
  String get scanPickImage => 'Foto auswählen';

  @override
  String get scanNoCodeInImage => 'Keine Sendungsnummer in diesem Foto';

  @override
  String get tooltipZoomIn => 'Vergrößern';

  @override
  String get tooltipZoomOut => 'Verkleinern';

  @override
  String get captureResolution => 'Auflösung';

  @override
  String get stopRecording => 'Aufnahme stoppen';

  @override
  String get videoTypeSettings => 'Einstellungen für Videotypen';

  @override
  String get uploadQueueTitle => 'Upload-Warteschlange';

  @override
  String get quotaExhaustedNote =>
      'Das Monatskontingent ist aufgebraucht. Aufnehmen geht weiter, aber diese Clips liegen AUF DIESEM HANDY und sind noch nicht geschützt — sie laden von selbst hoch, sobald das Kontingent erhöht wird.';

  @override
  String get queueEmpty => 'Noch keine Videos in der Warteschlange';

  @override
  String get queueAutoUploadNote =>
      'Der Upload läuft automatisch, sobald du online bist';

  @override
  String get waitingUpload => 'Wartet auf Upload';

  @override
  String get queueUploading => 'Wird hochgeladen';

  @override
  String get queueQuotaShort => 'Wartet auf Kontingent';

  @override
  String get queueUploadFailed => 'Upload unvollständig';

  @override
  String get uploaded => 'Hochgeladen';

  @override
  String get waitingQuota => 'Wartet auf Kontingent · noch auf dem Gerät';

  @override
  String get pausedUpload => 'Pausiert';

  @override
  String get queuePauseAction => 'Pausieren';

  @override
  String get queueResumeAction => 'Fortsetzen';

  @override
  String get queueDeleteAction => 'Entfernen';

  @override
  String get queueClearAction => 'Leeren';

  @override
  String get queueClearConfirmTitle => 'Gesamte Warteschlange leeren?';

  @override
  String get queueClearConfirmBody =>
      'Noch nicht hochgeladene Clips liegen nur auf diesem Telefon. Leeren löscht sie endgültig.';

  @override
  String get queueDeleteConfirmTitle => 'Aus der Warteschlange entfernen?';

  @override
  String get queueDeleteConfirmBody =>
      'Dieser Clip ist noch nicht hochgeladen — beim Entfernen wird er endgültig von deinem Gerät gelöscht.';

  @override
  String get toastQueueItemDeleted => 'Aus der Upload-Warteschlange entfernt';

  @override
  String get manualTrackingTitle => 'Sendungsnummer eingeben';

  @override
  String get manualTrackingNote => 'Tippe sie ein oder scanne den Code erneut';

  @override
  String get commonDone => 'Fertig';

  @override
  String get startRecording => 'Aufnahme starten';

  @override
  String get returnCodeMismatch => 'Rücksendecode passt nicht';

  @override
  String get enterCodeManually => 'Code manuell eingeben';

  @override
  String get videoTypeLabel => 'Videotyp';

  @override
  String get videoTypeSelectNote =>
      'Wähle den passenden Typ — hinzufügen/ändern/löschen in den Shop-Details';

  @override
  String get videoTypeSheetTitle => 'Videotyp wählen';

  @override
  String get videoTypeGroupDefault => 'Standardtypen (erforderlich)';

  @override
  String get videoTypeGroupCustom => 'Eigene Typen des Shops';

  @override
  String get manageVideoTypesNote =>
      'Videotypen verwalten — Shop-Details öffnen';

  @override
  String queueFilterAll(int count) {
    return 'Alle ($count)';
  }

  @override
  String queueFilterUploading(int count) {
    return 'Wird hochgeladen ($count)';
  }

  @override
  String queueFilterErrored(int count) {
    return 'Fehler ($count)';
  }

  @override
  String queueFilterQuotaWait(int count) {
    return 'Warten auf Kontingent ($count)';
  }

  @override
  String queueSummary(int pending, int uploading, int errored) {
    return '$pending Videos warten · $uploading werden hochgeladen · $errored fehlgeschlagen';
  }

  @override
  String uploadingProgress(int percent) {
    return '$percent% hochgeladen';
  }

  @override
  String errorRetryCount(int count) {
    return 'Fehler · Erneut versuchen ($count)';
  }

  @override
  String returnCodeMismatchBody(String returnCode, String shopName) {
    return '$returnCode passt zu keiner Bestellung in $shopName. Prüfe den Code, gib ihn manuell ein oder bestätige das Anlegen einer neuen Bestellung.';
  }

  @override
  String get onboardingSubtitle =>
      'Verpackungsnachweise für Online-Händler aufnehmen';

  @override
  String get onboardingStart => 'Loslegen';

  @override
  String get authSignIn => 'Anmelden';

  @override
  String get authChooseMethod => 'Anmeldemethode wählen';

  @override
  String get authEmailRequired => 'Bitte gib deine E-Mail ein';

  @override
  String get authEmailInvalid => 'Ungültige E-Mail';

  @override
  String get authPassword => 'Passwort';

  @override
  String get authPasswordRequired => 'Bitte gib dein Passwort ein';

  @override
  String get authForgotPassword => 'Passwort vergessen?';

  @override
  String get registerWithGoogle => 'Mit Google registrieren';

  @override
  String get registerWithApple => 'Mit Apple registrieren';

  @override
  String get authSignInGoogle => 'Mit Google anmelden';

  @override
  String get authSignInApple => 'Mit Apple anmelden';

  @override
  String get authNoAccountPrompt => 'Noch kein Konto? ';

  @override
  String get authRegister => 'Registrieren';

  @override
  String get authOr => 'oder';

  @override
  String get registerTitle => 'Neues Konto erstellen';

  @override
  String get registerConfirmPassword => 'Passwort wiederholen';

  @override
  String get registerAgreePolicy => 'Ich stimme der Richtlinie zu ';

  @override
  String get registerViewPolicy => 'Richtlinie ansehen';

  @override
  String get registerCreateAccount => 'Konto erstellen';

  @override
  String get registerSameEmailNote =>
      'Dieselbe E-Mail wird automatisch mit einem Konto verknüpft';

  @override
  String get registerHaveAccountPrompt => 'Schon ein Konto? ';

  @override
  String get registerSuccessTitle => 'Konto erstellt';

  @override
  String registerSuccessVerifyMessage(String email) {
    return 'Wir haben eine Bestätigungsmail an $email geschickt. Prüfe den Posteingang (auch Spam) und melde dich dann an.';
  }

  @override
  String get registerSuccessMessage =>
      'Dein Konto ist bereit. Melde dich mit der eben registrierten E-Mail und dem Passwort an.';

  @override
  String get registerSuccessAction => 'Anmelden';

  @override
  String get loginNotVerifiedTitle => 'E-Mail nicht bestätigt';

  @override
  String loginNotVerifiedMessage(String email) {
    return 'Öffne die Bestätigungsmail an $email (auch im Spam), folge dem Link und melde dich erneut an.';
  }

  @override
  String get loginResendVerification => 'E-Mail erneut senden';

  @override
  String get loginVerificationResent => 'Bestätigungsmail erneut gesendet';

  @override
  String get forgotPasswordTitle => 'Passwort vergessen';

  @override
  String get forgotPasswordSubtitle =>
      'Gib deine E-Mail ein, um einen Link zum Zurücksetzen zu erhalten';

  @override
  String get forgotPasswordSubmit => 'Link zum Zurücksetzen senden';

  @override
  String get forgotPasswordSent =>
      'Gesendet — prüfe den Posteingang (auch Spam)';

  @override
  String get forgotPasswordRememberPrompt => 'Passwort wieder eingefallen? ';

  @override
  String get shopYourShops => 'Deine Shops';

  @override
  String get shopTapToClockIn =>
      'Tippe auf einen Shop, um die Schicht zu starten · verwalte ihn gleich hier';

  @override
  String get shopLastOpenedNote =>
      'Beim nächsten Mal öffnet sich der zuletzt geöffnete Shop direkt';

  @override
  String get shopManageStore => 'Shop verwalten';

  @override
  String get shopManageVisibilityNote =>
      'Nur für Kontoinhaber / Shop-Manager sichtbar';

  @override
  String get shopEmpty => 'Noch keine Shops';

  @override
  String get shopEmptyBody =>
      'Dein Konto gehört noch zu keinem Shop. Erstelle einen neuen Shop oder warte auf eine Einladung eines Shop-Inhabers.';

  @override
  String get shopCreateNew => 'Neuen Shop erstellen (Name + Plattform)';

  @override
  String get shopInvitesHere => 'Shop-Einladungen erscheinen hier';

  @override
  String get shopCreateTitle => 'Shop erstellen';

  @override
  String get shopNameLabel => 'Shop-Name';

  @override
  String get shopNameRequired => 'Bitte gib einen Shop-Namen ein';

  @override
  String get shopPlatform => 'Marktplatz';

  @override
  String get shopCreateOwnerNote =>
      'Du wirst Shop-Inhaber — Mitglieder fügst du später unter Shop verwalten hinzu';

  @override
  String get shopMgmtVisibilityNote =>
      'Mitarbeiter sehen diesen Bildschirm nicht · Manager sehen nur die Shops, die sie betreuen';

  @override
  String get shopAddNew => 'Neuen Shop hinzufügen';

  @override
  String get sectionMembers => 'MITGLIEDER';

  @override
  String get sectionShopSettings => 'SHOP-EINSTELLUNGEN';

  @override
  String get sectionVideoTypes => 'VIDEOTYPEN';

  @override
  String get videoTypesLockedNote =>
      '3 eingebaute Typen sind gesperrt — nicht änderbar/löschbar';

  @override
  String get addMemberByContact => 'Mitglied per E-Mail/Telefon hinzufügen';

  @override
  String get recordResolution => 'Aufnahmeauflösung';

  @override
  String get addVideoType => 'Typ hinzufügen (Namen eingeben)';

  @override
  String get createVideoTypeTitle => 'Videotyp erstellen';

  @override
  String get videoTypeName => 'Name des Videotyps';

  @override
  String get videoTypeNameHint => 'z. B. Wiegen';

  @override
  String get createVideoType => 'Typ erstellen';

  @override
  String get deleteVideoTypeBody =>
      'Löschbar nur, solange dieser Typ keine Videos hat. Gibt es Videos, blockiert das System das Löschen, damit Nachweisfilter und Statistiken heil bleiben.';

  @override
  String get deleteVideoTypeConfirm => 'Typ löschen';

  @override
  String get deleteVideoTypeNote =>
      '(Nur löschbar, solange der Typ keine Videos hat)';

  @override
  String get addMemberTitle => 'Mitglied hinzufügen';

  @override
  String get addMemberBody =>
      'Gib die E-Mail eines registrierten ZenPack-Kontos ein. Die Person erhält eine Einladung und muss sie bestätigen, um dem Shop beizutreten.';

  @override
  String get emailLabel => 'E-Mail';

  @override
  String get emailRequired => 'Gib eine E-Mail-Adresse ein.';

  @override
  String get emailInvalid => 'Gib genau eine gültige E-Mail-Adresse ein.';

  @override
  String get errorInviteAccountNotFound =>
      'Zu dieser E-Mail gibt es noch kein ZenPack-Konto. Bitte die Person, sich zuerst zu registrieren, und lade sie dann erneut ein.';

  @override
  String get errorInviteAlreadyMember =>
      'Die Person ist bereits Mitglied dieses Shops.';

  @override
  String get errorInviteMemberLimit =>
      'Das Mitgliederlimit dieses Tarifs ist voll. Offene Einladungen zählen mit — widerrufe eine, um Platz zu schaffen.';

  @override
  String get errorInviteAlreadyOwner =>
      'Das ist der Shop-Inhaber — keine Einladung nötig.';

  @override
  String get errorInviteInvalidRequest =>
      'Diese E-Mail ist ungültig. Prüfe sie und sende erneut.';

  @override
  String get addMemberSubmit => 'Hinzufügen';

  @override
  String get memberOwnerLocked =>
      'Der Inhaber lässt sich hier weder umstufen noch entfernen — die Inhaberschaft hängt am Shop, nicht an einer Mitgliedszeile.';

  @override
  String get removeFromShop => 'Aus dem Shop entfernen';

  @override
  String get revokeInvite => 'Einladung löschen';

  @override
  String get resolutionAppliesNote =>
      'Gilt für neu aufgenommene Videos des Shops';

  @override
  String get resolutionDefaultOption => '720p (Standard)';

  @override
  String get ordersSearchHint => 'Sendungsnummer eingeben';

  @override
  String get ordersEmpty => 'Dieser Shop hat noch keine Bestellungen';

  @override
  String recordAutoStopIn(String time) {
    return 'Stoppt automatisch in $time';
  }

  @override
  String get ordersNotFound => 'Keine Bestellungen gefunden';

  @override
  String get ordersNotFoundHint =>
      'Prüfe die Sendungsnummer und versuche es erneut';

  @override
  String ordersPageRange(int first, int last, int total) {
    return '$first–$last von $total Bestellungen';
  }

  @override
  String get ordersPagePrevious => 'Vorherige Seite';

  @override
  String get ordersPageNext => 'Nächste Seite';

  @override
  String ordersPageNumber(int page) {
    return 'Seite $page';
  }

  @override
  String get filterStatusLabel => 'Status';

  @override
  String get filterStatusAll => 'Alle';

  @override
  String get filterStatusPending => 'Wartet auf Upload';

  @override
  String get filterStatusError => 'Upload-Fehler';

  @override
  String get filterStatusDone => 'Vollständig hochgeladen';

  @override
  String get filterTimeLabel => 'Zeit';

  @override
  String get filterTimeAll => 'Beliebige Zeit';

  @override
  String get filterTimeToday => 'Heute';

  @override
  String get filterTimeYesterday => 'Gestern';

  @override
  String get filterTime7d => 'Letzte 7 Tage';

  @override
  String get filterTime30d => 'Letzte 30 Tage';

  @override
  String get filterTimePickDate => 'Datum wählen…';

  @override
  String get filterTypeLabel => 'Videotyp';

  @override
  String get filterTypeAll => 'Alle';

  @override
  String deleteVideoTypeTitle(String typeName) {
    return 'Typ \"$typeName\" löschen?';
  }

  @override
  String memberCurrentRole(String role) {
    return 'Aktuelle Rolle: $role';
  }

  @override
  String get stopCodeTitle => 'QR-Code zum Stoppen der Aufnahme';

  @override
  String get stopCodeInstructions =>
      'Drucke das aus und klebe es an den Packtisch. Halte es während der Aufnahme in die Kamera, um automatisch zu stoppen.';

  @override
  String get scannedCodeNotFound =>
      'Keine Bestellung passt zum gescannten Code';

  @override
  String get onboardingTaglineOne => 'Jedes Paket.';

  @override
  String get onboardingTaglineTwo => 'Ein Nachweis.';

  @override
  String get onboardingTaglineThree => 'Schützt deinen Umsatz.';

  @override
  String get authEmailPlaceholder => 'Gib deine E-Mail ein';

  @override
  String get authPasswordPlaceholder => 'Gib dein Passwort ein';

  @override
  String get registerCreateAccountSubtitle => 'Neues Konto erstellen';

  @override
  String get registerFullName => 'Vollständiger Name';

  @override
  String get registerFullNameRequired =>
      'Bitte gib deinen vollständigen Namen ein';

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
  String get registerAgreePrefix => 'Ich stimme zu den';

  @override
  String get registerTermsOfUse => 'Nutzungsbedingungen';

  @override
  String get shopChooseTitle => 'Shop wählen';

  @override
  String get shopChooseSubtitle => 'Wähle einen Shop, um fortzufahren';

  @override
  String get shopManageTitle => 'Shops verwalten';

  @override
  String get shopManageOwnerOnly => 'Nur für Shop-Inhaber und Manager sichtbar';

  @override
  String get noShopTitle => 'Noch keine Shops';

  @override
  String get noShopLineOne => 'Dein Konto gehört noch zu keinem Shop.';

  @override
  String get noShopLineTwo => 'Erstelle einen Shop, um zu starten,';

  @override
  String get noShopLineThree =>
      'oder warte auf eine Einladung eines Shop-Inhabers.';

  @override
  String get noShopCreateCta => 'Shop erstellen (Name + Marktplatz)';

  @override
  String get noShopInviteHint => 'Shop-Einladungen erscheinen hier';

  @override
  String get createShopTitle => 'Shop erstellen';

  @override
  String get createShopNameLabel => 'Shop-Name';

  @override
  String get createShopNameHint => 'z. B. Shop ABC';

  @override
  String get createShopPlatformLabel => 'Marktplatz';

  @override
  String get createShopOwnerNote =>
      'Du wirst Shop-Inhaber — Mitglieder fügst du später unter Shops verwalten hinzu';

  @override
  String get createShopSubmit => 'Shop erstellen';

  @override
  String get shopManageDescription =>
      'Sieh dir die von dir verwalteten Shops an und verwalte sie.';

  @override
  String get shopManageAddCta => 'Shop hinzufügen';

  @override
  String get shopManageStaffNote =>
      'Mitarbeiter sehen diesen Bildschirm nicht — nur Inhaber und Shop-Manager.';

  @override
  String get shopDetailTitle => 'Shop-Details';

  @override
  String get shopDetailResolution => 'Aufnahmeauflösung';

  @override
  String get shopDetailClipDuration => 'Max. Länge/Video';

  @override
  String clipDurationValue(String minutes) {
    return '$minutes Min';
  }

  @override
  String clipRecommendedHint(
    String minutes,
    String platform,
    String megabytes,
    String resolution,
  ) {
    return 'Empfohlen $minutes Min — für $platform ($megabytes MB/Video) + $resolution';
  }

  @override
  String clipRecommendedHintUnverified(String minutes, String platform) {
    return 'Empfohlen $minutes Min — die Limits von $platform sind unbestätigt, es gelten die sichersten bekannten Werte';
  }

  @override
  String clipOverRecommendedWarning(
    String minutes,
    String platform,
    String chosen,
    String megabytes,
  ) {
    return 'Über der Empfehlung von $minutes Min für $platform — ein Video von $chosen Min hat rund $megabytes MB und muss daher als Aktenlink geschickt statt am Beschwerdeformular angehängt werden.';
  }

  @override
  String get clipDurationTitle => 'Maximale Länge pro Video';

  @override
  String get clipDurationSubtitle => 'Schließt bei dieser Länge automatisch';

  @override
  String clipDurationPlanCap(String minutes) {
    return 'Dein Tarif erlaubt bis zu $minutes Min';
  }

  @override
  String clipDurationChanged(String minutes) {
    return 'Max. Länge/Video: $minutes Min';
  }

  @override
  String get shopDetailImageSize => 'Bildgröße';

  @override
  String get shopDetailVideoSize => 'Videogröße';

  @override
  String get shopDetailUploadSize => 'Max. Größe/Datei';

  @override
  String uploadSizeValue(String megabytes) {
    return '$megabytes MB';
  }

  @override
  String uploadRecommendedHint(String megabytes, String platform) {
    return 'Empfohlen $megabytes MB — Anhanglimit von $platform';
  }

  @override
  String uploadOverRecommendedWarning(
    String megabytes,
    String platform,
    String chosen,
  ) {
    return 'Über der Empfehlung von $megabytes MB für $platform — eine Datei bis $chosen MB wird weiterhin vollständig gespeichert, muss aber als Aktenlink geschickt statt am Beschwerdeformular angehängt werden.';
  }

  @override
  String get uploadSizeValueUnlimited => 'Kein Limit';

  @override
  String get uploadSizeTitle => 'Maximale Größe pro Datei';

  @override
  String uploadSizeSubtitle(String megabytes, String platform) {
    return 'Dateien über dem Limit werden nicht angehängt; $megabytes MB lassen sich weiterhin direkt an $platform anhängen';
  }

  @override
  String uploadSizeOptionRecommended(String megabytes) {
    return '$megabytes MB (empfohlen)';
  }

  @override
  String uploadSizeChanged(String megabytes) {
    return 'Größe pro Datei: $megabytes';
  }

  @override
  String avatarTooLarge(String megabytes, String limit) {
    return 'Name und Telefon gespeichert. Das Profilbild mit $megabytes MB liegt über dem Limit von $limit MB und hat den Server nicht erreicht — wähle ein kleineres Bild.';
  }

  @override
  String avatarUploadFailed(String reason) {
    return 'Name und Telefon gespeichert. Das Profilbild hat den Server nicht erreicht: $reason';
  }

  @override
  String nearClipLimitWarning(String minutes) {
    return 'Kurz vor dem Limit von $minutes Min — das Video schließt sich von selbst';
  }

  @override
  String get shopDetailAddType => 'Typ hinzufügen (Namen eingeben)';

  @override
  String get inviteMemberTitle => 'Mitglied einladen';

  @override
  String get inviteRoleFixedNote =>
      'Die Person tritt als Mitarbeiter bei: Videos aufnehmen und die eigenen ansehen.';

  @override
  String get inviteMemberHint => '(noch kein Konto → Einladung senden)';

  @override
  String get videoTypeIcon => 'Symbol';

  @override
  String get videoTypeColor => 'Farbe';

  @override
  String get createVideoTypeSubmit => 'Typ erstellen';

  @override
  String get deleteVideoTypeSafeNote => 'Es geht kein Nachweis verloren';

  @override
  String get commonConfirm => 'Bestätigen';

  @override
  String orderErrorCount(int count) {
    return '$count fehlgeschlagen';
  }

  @override
  String get videoDetailSheetTitle => 'Videodetails';

  @override
  String get tooltipStopRecording => 'Aufnahme stoppen';

  @override
  String get dossierLinkTitle => 'Link zur Streitakte';

  @override
  String get accountEndQr => 'Code zum Stoppen der Aufnahme';

  @override
  String get accountEndQrTitle => 'Code zum Stoppen der Aufnahme';

  @override
  String get accountEndQrShare => 'Code teilen';

  @override
  String get accountEndQrSave => 'In der Fotomediathek speichern';

  @override
  String get recordInterruptedTitle => 'Aufnahme pausiert';

  @override
  String get recordInterruptedBody =>
      'Die Aufnahme wurde von etwas unterbrochen. Weiter aufnehmen?';

  @override
  String get recordInterruptedResume => 'Fortsetzen';

  @override
  String get recordInterruptedFinish => 'Beenden';

  @override
  String get commonApply => 'Übernehmen';

  @override
  String get unitMinutes => 'Min';

  @override
  String get clipDurationCustomLabel =>
      'Oder gib die gewünschte Anzahl Minuten ein';

  @override
  String get supportOpenFailed =>
      'Ließ sich nicht öffnen — prüfe, ob die App installiert ist';

  @override
  String get feedbackThanksTitle => 'Danke!';

  @override
  String get feedbackThanksBody => 'Dein Feedback macht ZenPack besser.';

  @override
  String get feedbackTitle => 'Was möchtest du uns mitteilen?';

  @override
  String get feedbackHint => 'Schreib dein Feedback...';

  @override
  String get feedbackSend => 'Feedback senden';

  @override
  String get feedbackThanks => 'Danke für dein Feedback';

  @override
  String get accountSectionAbout => 'ÜBER';

  @override
  String get accountFeedback => 'Feedback senden';

  @override
  String get accountFeedbackNote =>
      'Teile deine Gedanken, um ZenPack besser zu machen';

  @override
  String get accountRateApp => 'App bewerten';

  @override
  String get accountRateAppNote => 'Die Entwicklung von ZenPack unterstützen';

  @override
  String sheetCustomMin(String min, String unit) {
    return 'Gib $min $unit oder mehr ein';
  }

  @override
  String sheetCustomRange(String min, String max, String unit) {
    return 'Gib zwischen $min und $max $unit ein';
  }

  @override
  String get accountEndQrNote =>
      'Drucke das aus und klebe es an den Packtisch. Wird es während der Aufnahme gescannt, schließt der Clip. Derselbe Code funktioniert auf jedem Gerät.';

  @override
  String get languageChangeScopeNote =>
      'Jede Beschriftung, Benachrichtigung und Akte\nwechselt in die von dir gewählte Sprache.';

  @override
  String get manualEntryEmptyError =>
      'Gib vor der Aufnahme eine Sendungsnummer ein';

  @override
  String get appUpdateTitle => 'Eine neue Version ist verfügbar';

  @override
  String get appUpdateMessage =>
      'Aktualisiere ZenPack für die neuesten Korrekturen und Funktionen.';

  @override
  String get appUpdateNow => 'Aktualisieren';

  @override
  String get appUpdateLater => 'Später';

  @override
  String get quotaVideosThisMonth => 'Videos diesen Monat';

  @override
  String get quotaSubtitleVideos =>
      'Behalte im Blick, wie viele Videos du diesen Monat aufgenommen hast';

  @override
  String get quotaUpgrade => 'Tarif upgraden';

  @override
  String get quotaBlockedTitle => 'Videokontingent aufgebraucht';

  @override
  String get quotaBlockedNote =>
      'Aufnehmen geht weiter, aber die Clips können noch nicht hochladen — sie liegen ungeschützt auf diesem Handy. Sie laden von selbst hoch, sobald das Kontingent erhöht wird.';

  @override
  String get quotaBlockedOwnerNote =>
      'Das Kontingent dieses Shops legt der Kontoinhaber fest — bitte ihn um eine Erhöhung. Ein selbst gekaufter Tarif gilt nur für dein eigenes Konto.';

  @override
  String get quotaTopupCredits => 'Guthaben aufladen';

  @override
  String get quotaOverCap => 'Über dem Tarifkontingent';

  @override
  String quotaBlockAt(int n) {
    return 'Neue Aufnahmen ab $n Videos blockiert';
  }

  @override
  String get quotaResetMonthly =>
      'Setzt sich zu Beginn des nächsten Monats zurück; nichts wird übertragen';

  @override
  String get storageOwnTitle => 'Dein eigener Speicher';

  @override
  String storageOwnPending(int count) {
    return '$count Videos warten darauf, in deinen Speicher geschoben zu werden';
  }

  @override
  String storageOwnProblem(int count) {
    return '$count Videos in deinem Speicher haben Probleme';
  }

  @override
  String get quotaExhaustedWarn =>
      'Deinstalliere die App nicht und lösche ihre Daten nicht, bis alles hochgeladen ist.';

  @override
  String quotaStrandedTitle(int count) {
    return '$count Videos warten auf diesem Handy';
  }

  @override
  String get quotaStrandedNote =>
      'Diese Videos gibt es nur auf diesem Handy. Verlust des Geräts, Deinstallation oder Löschen der Daten bedeutet, sie sind weg.';

  @override
  String get storageTitle => 'Videospeicher';

  @override
  String get storageSave => 'Speicherauswahl sichern';

  @override
  String get storageSystemName => 'Systemspeicher';

  @override
  String get storageS3Name => 'Dein eigener Speicher (S3)';

  @override
  String get storageDriveName => 'Dein Google Drive';

  @override
  String get storageSystemDesc =>
      'Die Voreinstellung; nichts einzurichten. Nur hier gelten alle Zusagen zum Nachweis vollständig.';

  @override
  String get storageOwnDesc =>
      'Neue Videos gehen direkt in deinen Speicher. Ältere bleiben, wo sie sind, bis ihre Aufbewahrungsfrist endet.';

  @override
  String get storageNoPresign =>
      'Dieser Speicher kann keine Download-Links signieren, deshalb müssen Videos über den Server laufen — wer deinen Link öffnet, merkt es an der Langsamkeit.';

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
      'Dieser Speicher hat keine Objektsperre. Du kannst einer Plattform nicht zusagen, dass der Nachweis unlöschbar ist.';

  @override
  String get storageNotInPlan =>
      'Dein Tarif enthält noch keinen eigenen Speicher. Führe im Web ein Upgrade durch, um ihn zu nutzen.';

  @override
  String get storageHealthTitle => 'Zustand des Speichers';

  @override
  String get storageHealthTotal => 'Videos gesamt';

  @override
  String get storageHealthIntact => 'Intakt';

  @override
  String get storageHealthUnreachable => 'Nicht erreichbar';

  @override
  String get storageHealthMismatched => 'Passt nicht zum Siegel';

  @override
  String get storageHealthPendingRelay => 'Wartet im Zwischenbereich';

  @override
  String get storageProblemsNote =>
      'Einige Videos in deinem Speicher haben Probleme. Prüfe die Zugriffsrechte beim Anbieter.';

  @override
  String get storageTest => 'Verbindung erneut testen';

  @override
  String get storageInUse => 'In Verwendung';

  @override
  String storageLastCheckAt(String time) {
    return 'Letzte Prüfung: $time';
  }

  @override
  String get storageNeverChecked => 'Noch nie geprüft.';

  @override
  String storageDriveCurrentAccount(String email) {
    return 'Currently connected: $email. Sign in with that address to keep the same Drive, or pick another to switch.';
  }

  @override
  String get storageDriveAccount => 'Drive-Konto';

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
  String get storageDisconnect => 'Eigenen Speicher nicht mehr verwenden';

  @override
  String get storageDisconnectConfirm =>
      'Ab jetzt aufgenommene Videos gehen in den Systemspeicher. Ältere bleiben in deinem Speicher, und das System verliert den Weg dorthin.';

  @override
  String get storageConnectS3 => 'S3-Speicher verbinden';

  @override
  String get storageConnectDrive => 'Google Drive verbinden';

  @override
  String get storageConnectHint =>
      'Erteile Lese-/Schreib-/Löschrechte nur für den Prefix unten — Rechte auf den ganzen Bucket sind nicht nötig.';

  @override
  String get storageConnectSubmit => 'Testen und speichern';

  @override
  String get storageFieldEndpoint => 'Endpunkt';

  @override
  String get storageFieldBucket => 'Bucket';

  @override
  String get storageFieldAccessKey => 'Access Key ID';

  @override
  String get storageFieldSecretKey => 'Secret Access Key';

  @override
  String get storageFieldRegion => 'Region';

  @override
  String get storageFieldPrefix => 'Prefix';

  @override
  String get storageFieldPrefixHint =>
      'Unterordner im Bucket. Lass die Voreinstellung, wenn du unsicher bist.';

  @override
  String get storageDriveFailed =>
      'Could not connect Google Drive: the server\'s connection to Google is not configured yet. That is system-side setup, not a permission the app can ask you for — tell your technical contact.';

  @override
  String get storageConnected => 'Eigener Speicher verbunden.';

  @override
  String get storageDisconnected => 'Eigener Speicher getrennt.';

  @override
  String get storageSwitchedToSystem =>
      'Saved. New videos go to Cloud Zenpack; your own-storage account is kept.';

  @override
  String get storageResumed => 'Saved. Using your connected storage again.';

  @override
  String get storageTestOk => 'Die Verbindung ist in Ordnung.';

  @override
  String get storageServerOutdated =>
      'The server does not support switching storage yet. Your videos stay where they are — tell your admin to update the server.';

  @override
  String get storageOwnerOnly =>
      'Nur der Shop-Inhaber kann den Speicher ändern.';

  @override
  String get dangerZone => 'Gefahrenbereich';

  @override
  String get shopDelete => 'Shop löschen';

  @override
  String get shopDeleteDesc =>
      'Löscht Bestellungen, Nachweise, gespeicherte Dateien und Mitglieder endgültig. Das lässt sich nicht rückgängig machen.';

  @override
  String get shopDeleteConfirmTitle => 'Diesen Shop löschen?';

  @override
  String shopDeleteConfirmBody(int orders, int videos, int members) {
    return '$orders Bestellungen · $videos Videos · $members Mitglieder werden endgültig gelöscht.';
  }

  @override
  String shopDeleteOpenDossiers(int n) {
    return '$n Reklamationsakten sind noch offen. Bereits an Plattformen geschickte Links sterben in dem Moment, in dem du löschst.';
  }

  @override
  String get shopDeleteForce => 'Trotzdem löschen';

  @override
  String get shopDeleteFailed => 'Der Shop ließ sich nicht löschen.';

  @override
  String get claimsCreatedLocalOnly =>
      'Akte auf diesem Handy gespeichert. Sie ließ sich nicht hochladen, deshalb gibt es noch keinen Freigabelink — öffne sie erneut, sobald du online bist.';

  @override
  String get claimsLinkCopied =>
      'Aktenlink kopiert. Füge ihn im Reklamationskanal der Plattform ein.';

  @override
  String get shopRenameTitle => 'Shop umbenennen';

  @override
  String get shopRenameHint => 'Shop-Name';

  @override
  String get shopRenamed => 'Shop umbenannt';

  @override
  String get commonSave => 'Speichern';

  @override
  String get inviteJoinRow => 'Ich habe eine Einladung';

  @override
  String inviteJoinedShop(String shop) {
    return '$shop beigetreten';
  }

  @override
  String inviteAlreadyJoined(String shop) {
    return 'Du bist bereits in $shop';
  }

  @override
  String get inviteBadLink =>
      'Dieser Link ist ungültig. Füge den ganzen Link aus der E-Mail ein.';

  @override
  String get inviteNotFound =>
      'Die Einladung existiert nicht oder wurde widerrufen';

  @override
  String get inviteTaken =>
      'Jemand anderes hat diese Einladung bereits angenommen';

  @override
  String get inviteExpired =>
      'Die Einladung ist abgelaufen. Bitte den Shop-Inhaber, sie erneut zu senden.';

  @override
  String get inviteQrRow => 'QR-Code';

  @override
  String get inviteQrTitle => 'Einladungscode für den Shop';

  @override
  String get inviteQrNote =>
      'Zeigen Sie diesen Bildschirm der Person, die Sie einladen möchten. Der Code gilt einmalig und ändert sich, sobald jemand beitritt.';

  @override
  String get inviteScanTitle => 'Einladungscode scannen';

  @override
  String get inviteScanDetail =>
      'Bitte den Shop-Inhaber, den Einladungs-QR-Code zu zeigen, und scanne ihn hier.';

  @override
  String get commonShare => 'Teilen';

  @override
  String get inviteQrSaved => 'QR-Code in deiner Galerie gespeichert';

  @override
  String get inviteQrSaveFailed => 'Der QR-Code ließ sich nicht speichern';

  @override
  String get voiceRecordingStarted => 'Aufnahme gestartet';

  @override
  String get voiceRecordingStopped => 'Aufnahme gestoppt';

  @override
  String get voiceWrongCode => 'Falscher Code';

  @override
  String get voiceCapSoon => 'Das Video wird gleich beendet';

  @override
  String voiceCapNear(int minutes) {
    return 'Das $minutes-Minuten-Limit ist fast erreicht, das Video endet automatisch';
  }

  @override
  String get voiceInterrupted => 'Die Aufnahme wurde unterbrochen';

  @override
  String get videoTypePacking => 'Verpacken';

  @override
  String get videoTypeCarrier => 'Übergabe an Versanddienst';

  @override
  String get videoTypeReturn => 'Rücksendung';

  @override
  String get storageIntro =>
      'Wo die Videos des Shops liegen. Wo auch immer sie liegen, der Siegel-Nachweis bleibt beim System — ein Speicherwechsel schwächt die Beweise nie.';

  @override
  String get storageS3Title => 'Eigener Cloud-Speicher (S3-kompatibel)';

  @override
  String get storageS3Desc =>
      'AWS S3, Cloudflare R2, MinIO, Wasabi… Die Videos liegen in deinem Bucket, ihre Haltbarkeit liegt bei dir.';

  @override
  String get storageDriveTitle => 'Google Drive';

  @override
  String get storageDriveDesc =>
      'Mit einer einzigen Freigabe verbinden, keine Schlüssel einzufügen. Ein kostenloses Konto hat nur 15 GB, geteilt mit Gmail.';

  @override
  String get storageNeedProPlan =>
      'Eigenen Speicher zu verbinden erfordert mindestens den Professional-Tarif.';

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
  String get authSignInPhone => 'Mit Telefonnummer anmelden';

  @override
  String get phoneLoginTitle => 'Mit Telefonnummer anmelden';

  @override
  String get phoneLoginSubtitle =>
      'Gib deine Telefonnummer ein, wir senden einen 6-stelligen Code.';

  @override
  String get phoneLoginNumberLabel => 'Telefonnummer';

  @override
  String get phoneLoginNumberHint => '01xx xxxxxxx';

  @override
  String get phoneLoginInvalid => 'Ungültige Telefonnummer';

  @override
  String get phoneLoginViaZalo => 'Code per Zalo senden';

  @override
  String get phoneLoginViaSms => 'Code per SMS senden';

  @override
  String get otpTitle => 'Code eingeben';

  @override
  String otpSentTo(String phone) {
    return 'Wir haben einen 6-stelligen Code an $phone gesendet.';
  }

  @override
  String get otpLabel => 'Bestätigungscode';

  @override
  String get otpConfirm => 'Bestätigen';

  @override
  String get otpResend => 'Code erneut senden';

  @override
  String otpResendIn(int seconds) {
    return 'Erneut senden in $seconds s';
  }

  @override
  String get otpChangePhone => 'Andere Nummer verwenden';

  @override
  String get otpWrong => 'Falscher Code. Prüfe die Nachricht noch einmal.';

  @override
  String get otpExpired => 'Der Code ist abgelaufen. Fordere einen neuen an.';

  @override
  String get otpUsedUp =>
      'Dieser Code kann nicht mehr verwendet werden. Fordere einen neuen an.';

  @override
  String get otpTooSoon => 'Gerade gesendet. Warte einen Moment.';

  @override
  String get otpRateLimited =>
      'Zu viele Anfragen. Versuche es in ein paar Minuten erneut.';

  @override
  String get otpSendFailed =>
      'Code konnte nicht gesendet werden. Versuche den anderen Kanal.';

  @override
  String get otpNotConfigured =>
      'Codeversand ist derzeit nicht verfügbar. Bitte nutze eine andere Methode.';

  @override
  String otpFromOa(String oa) {
    return 'Die Nachricht kommt vom Zalo Official Account $oa — achte auf diesen Namen.';
  }

  @override
  String get hdDaHieu => 'Verstanden';

  @override
  String get hdDong => 'Tipps schließen';

  @override
  String get hdXemLai => 'Tipps erneut anzeigen';

  @override
  String get hdDaMoLai =>
      'Die Tipps erscheinen wieder, wenn du die Bildschirme öffnest.';

  @override
  String get hdHomeTitle => 'Startbildschirm';

  @override
  String get hdHome1 =>
      'Ein schneller Blick auf Aufträge, belegten Speicher und heutige Aufgaben.';

  @override
  String get hdHome2 =>
      'Jede Statuskarte führt direkt zu den Aufträgen in diesem Zustand.';

  @override
  String get hdHome3 => 'Diese Tipps lassen sich jederzeit erneut öffnen.';

  @override
  String get hdRecordTitle => 'Aufnahmebildschirm';

  @override
  String get hdRecord1 =>
      'Wähle vor dem Filmen in den Einstellungen Waren- und Belegkamera.';

  @override
  String get hdRecord2 =>
      'Sendungsnummer scannen, dann aufnehmen — das Video hängt sich an den Auftrag.';

  @override
  String get hdRecord3 => 'IP-Kameras filmen nur Ware, nie als Belegkamera.';

  @override
  String get hdOrderTitle => 'Auftragsdetails';

  @override
  String get hdOrder1 =>
      'Alle Clips und Fotos einer Sendungsnummer, neueste zuerst.';

  @override
  String get hdOrder2 =>
      'Ein versiegelter Clip ist die Endfassung und taugt für eine Reklamation.';

  @override
  String get hdOrder3 =>
      'Löschen blendet nur aus deiner Liste aus; das Original bleibt erhalten.';

  @override
  String get hdClaimsTitle => 'Reklamationsakten';

  @override
  String get hdClaims1 =>
      'Bündle Belege mehrerer Aufträge in einer Akte für die Plattform.';

  @override
  String get hdClaims2 =>
      'Jede Akte hat einen eigenen Link; der Empfänger braucht kein Konto.';

  @override
  String get hdClaims3 =>
      'Videos einer Akte bleiben nach dem Schließen weitere 15 Tage erhalten.';

  @override
  String get hdClaimDetailTitle => 'Aktendetails';

  @override
  String get hdClaimDetail1 =>
      'Aufträge hinzufügen oder entfernen, bevor du die Akte sendest.';

  @override
  String get hdClaimDetail2 =>
      'Kopiere den Akten-Link für die Reklamation auf der Plattform.';

  @override
  String get hdClaimDetail3 =>
      'Nach Abschluss schließen — die Videos bleiben noch 15 Tage.';

  @override
  String get hdShopsTitle => 'Shops';

  @override
  String get hdShops1 =>
      'Jeder Shop hat eigenen Speicher, eigenen Tarif und eigenes Personal.';

  @override
  String get hdShops2 =>
      'Lade Personal in den Shop ein und lege fest, was jede Person darf.';

  @override
  String get hdShops3 => 'Wechsle oben den Shop, in dem du gerade arbeitest.';

  @override
  String get hdQuotaTitle => 'Tarif';

  @override
  String get hdQuota1 =>
      'Der Tarif bestimmt Speichergröße und Aufbewahrungsdauer der Videos.';

  @override
  String get hdQuota2 => 'Speicher zählt pro Shop, nicht pro Nutzer.';

  @override
  String get hdQuota3 =>
      'Du wirst vor vollem Speicher gewarnt — nichts wird still gelöscht.';

  @override
  String get hdQueueTitle => 'Upload-Warteschlange';

  @override
  String get hdQueue1 =>
      'Bereits aufgenommene, noch nicht hochgeladene Clips warten hier.';

  @override
  String get hdQueue2 =>
      'Bei schwachem Empfang einfach liegen lassen — die App versucht es erneut.';

  @override
  String get hdQueue3 =>
      'Deinstalliere die App nicht, solange Clips warten; sie liegen nur auf diesem Gerät.';

  @override
  String get gtBoQua => 'Überspringen';

  @override
  String get gtTiep => 'Weiter';

  @override
  String get gtBatDau => 'Jetzt loslegen';

  @override
  String get gt1Title => 'Beim Packen filmen';

  @override
  String get gt1Body =>
      'Ein Video pro Auftrag: was hineinkam, wie gepackt wurde, welches Etikett draufkam. Aufnehmen und fertig.';

  @override
  String get gt2Title => 'Fest mit der Sendungsnummer verbunden';

  @override
  String get gt2Body =>
      'Etikett scannen, und das Video hängt sich an den Auftrag. Später zeigt eine Nummer alle Clips dazu.';

  @override
  String get gt3Title => 'Beweise, wenn reklamiert wird';

  @override
  String get gt3Body =>
      'Clips mehrerer Aufträge zu einer Akte bündeln und den Link an die Plattform schicken. Kein Konto nötig.';

  @override
  String get deletePwTitle => 'Passwort eingeben';

  @override
  String get deletePwBody =>
      'Das lässt sich nicht rückgängig machen — gib dein Passwort erneut ein, bevor das Konto gelöscht wird.';

  @override
  String get deletePwOk => 'Bestätigen';

  @override
  String get hdNoShopTitle => 'Beginne mit einem Shop';

  @override
  String get hdNoShop1 =>
      'Jedes Video und jeder Beleg gehört zu einem Shop — lege also zuerst einen an.';

  @override
  String get hdNoShop2 =>
      'Danach wählst du deine Marktplätze und lädst dein Personal ein.';

  @override
  String get hdNoShop3 =>
      'Wurdest du eingeladen, nutze „Mit Einladung beitreten“ statt neu anzulegen.';

  @override
  String get cdNoShopTaoTitle => 'Zuerst einen Shop anlegen';

  @override
  String get cdNoShopTaoBody =>
      'Jedes Video und jeder Beleg gehört zu einem Shop. Tippe hier, um einen anzulegen.';

  @override
  String get cdNoShopMoiTitle => 'Eingeladen? Hier entlang';

  @override
  String get cdNoShopMoiBody =>
      'Hat dich ein Inhaber eingeladen, tippe hier und gib den Einladungscode ein.';

  @override
  String get cdNoShopTkTitle => 'Dein Profil';

  @override
  String get cdNoShopTkBody =>
      'Name, Sprache, Anmeldemethoden und Kontolöschung findest du hier.';

  @override
  String get cdTaoShopTenTitle => 'Benenne deinen Shop';

  @override
  String get cdTaoShopTenBody =>
      'Nur du und dein Personal seht diesen Namen; er unterscheidet mehrere Shops. Später änderbar.';

  @override
  String get cdTaoShopNutTitle => 'Marktplatz wählen, dann anlegen';

  @override
  String get cdTaoShopNutBody =>
      'Wähle oben, wo du verkaufst, und tippe hier. Sobald der Shop steht, kannst du aufnehmen.';

  @override
  String get cdHome1T => 'Auftrag schnell finden';

  @override
  String get cdHome1B =>
      'Tippe hier eine Sendungsnummer ein, um direkt zu ihren Belegen zu springen.';

  @override
  String get cdHome2T => 'Nach Status filtern';

  @override
  String get cdHome2B =>
      'Zeige nur Aufträge beim Hochladen, fertige oder fehlgeschlagene.';

  @override
  String get cdQueue1T => 'Clips warten aufs Hochladen';

  @override
  String get cdQueue1B =>
      'Schwacher Empfang? Clips warten hier und werden später erneut gesendet.';

  @override
  String get cdQueue2T => 'Warteschlange leeren';

  @override
  String get cdQueue2B =>
      'Entfernt nur noch nicht hochgeladene Clips. Sie sind dann endgültig weg.';

  @override
  String get cdClaims1T => 'Belege für die Plattform bündeln';

  @override
  String get cdClaims1B =>
      'Mehrere Aufträge werden zu einer Akte mit einem einzigen Link.';

  @override
  String get cdRec1T => 'Sendungsnummer scannen';

  @override
  String get cdRec1B =>
      'Halte das Etikett in den Rahmen. Die App liest es und hängt das Video an den Auftrag.';

  @override
  String get cdOrder1T => 'Belege dieses Auftrags';

  @override
  String get cdOrder1B =>
      'Alle Clips und Fotos zu dieser Sendungsnummer, neueste oben.';

  @override
  String get cdClaimD1T => 'Link für die Plattform';

  @override
  String get cdClaimD1B =>
      'Kopiere diesen Link in deine Reklamation. Der Empfänger braucht kein Konto.';

  @override
  String get cdShops1T => 'Shop wechseln';

  @override
  String get cdShops1B =>
      'Jeder Shop hat eigenen Speicher, Tarif und Personal. Tippe zum Wechseln.';

  @override
  String get cdQuota1T => 'Belegter Speicher';

  @override
  String get cdQuota1B =>
      'Der Tarif bestimmt Videoanzahl und Aufbewahrung. Du wirst vor vollem Speicher gewarnt.';

  @override
  String get cdAcc1T => 'Dein Tarif';

  @override
  String get cdAcc1B =>
      'Sieh verbleibende Videos, Aufbewahrungsdauer und erweitere hier.';

  @override
  String get cdAcc2T => 'Anmeldemethoden';

  @override
  String get cdAcc2B =>
      'Füge Google oder Apple hinzu — schneller anmelden ohne Passwort.';

  @override
  String get cdShopD1T => 'Videotypen';

  @override
  String get cdShopD1B =>
      'Benenne die Videoarten, die du oft aufnimmst, damit du sie später leicht findest.';

  @override
  String get cdShopD2T => 'Personal einladen';

  @override
  String get cdShopD2B => 'Lade Leute ein und lege fest, was jeder darf.';

  @override
  String get cdRec2T => 'Etikett unleserlich? Tippen';

  @override
  String get cdRec2B =>
      'Ist das Etikett verschmiert oder zerrissen, tippe hier und gib die Nummer ein.';

  @override
  String get notifRow => 'Mitteilungen';

  @override
  String get notifOn => 'An';

  @override
  String get notifOff => 'Aus';

  @override
  String get notifAskTitle => 'Mitteilungen aktivieren?';

  @override
  String get notifAskBody =>
      'ZenPack meldet sich, wenn dein Tarif bald abläuft, Videos bald gelöscht werden, jemand deinem Shop beitritt — und erinnert dich ans Aufnehmen beim Packen.';

  @override
  String get notifAskYes => 'Aktivieren';

  @override
  String get notifAskNo => 'Später';

  @override
  String get notifDenied =>
      'Du hast zuvor abgelehnt. Öffne die Geräteeinstellungen, um sie wieder zu aktivieren.';

  @override
  String get themeRow => 'Darstellung';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get tzRow => 'Zeitzone';

  @override
  String get tzAuto => 'Gerät';

  @override
  String get tzNote => 'Ändert nur die angezeigten Uhrzeiten.';

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
  String get detailSignature => 'Digitale Signatur';

  @override
  String sealSignature(String key) {
    return 'ZenPack-Signatur · Schlüssel $key';
  }

  @override
  String get sealCopyVerifyLink => 'Prüflink kopieren';

  @override
  String get sealVerifyLinkTitle => 'Prüflink';

  @override
  String get claimSignedLabel => 'Signiert';

  @override
  String claimSignedCount(int sealed, int videos, int anchored) {
    return '$sealed/$videos Videos · $anchored mit unabhängigem Nachweis';
  }

  @override
  String claimUnsignedHint(int n) {
    return '$n Videos ohne Stempel — der Marktplatz könnte sie ablehnen. Die Akte kann trotzdem gesendet werden; gestempelte Videos beweisen sich weiterhin selbst.';
  }

  @override
  String get claimsSubtitle =>
      'Reklamationsakten zu Bestellungen verfolgen und bearbeiten';

  @override
  String get claimsEmptyTitle => 'Noch keine Akte';

  @override
  String get claimsEmptyBody =>
      'Tippe oben auf das Plus und wähle die Beweise der reklamierten Bestellung, um eine Akte anzulegen.';

  @override
  String get claimsEmptyTip =>
      'Tipp: klare Fotos und Videos beschleunigen die Entscheidung des Marktplatzes.';

  @override
  String get timelineEnd => 'Keine weitere Aktivität';

  @override
  String timelineEntryCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Einträge',
      one: '1 Eintrag',
    );
    return '$_temp0';
  }

  @override
  String get attachCodeToOrderHint =>
      'Retourencode oder zweite Sendungsnummer an diese Bestellung hängen';

  @override
  String get attachPhotoToOrderHint =>
      'Foto vom Gerät wählen und bei dieser Bestellung ablegen';

  @override
  String get shopDetailClipLengthHint => 'Maximale Aufnahmedauer pro Video';

  @override
  String get shopDetailImageSizeHint => 'Maximale Größe pro Foto';

  @override
  String get storageRowHint => 'Wo Videos und Fotos liegen';

  @override
  String get capRowHint => 'Kamera- und Anzeigeoptionen';

  @override
  String get inviteQrLabel => 'Einladungscode';

  @override
  String get orderStatusRecorded => 'Aufgenommen';

  @override
  String get orderStatusNone => 'Nicht aufgenommen';

  @override
  String get accountTagline => 'Einfach verwalten, sicher verkaufen — ZenPack';

  @override
  String get videoTypeHintPacking => 'Das Verpacken filmen';

  @override
  String get videoTypeHintCarrier => 'Die Übergabe an den Versender filmen';

  @override
  String get videoTypeHintReturn => 'Die eingehende Retoure filmen';

  @override
  String get statPendingSub => 'In der Warteschlange';

  @override
  String shopPulseToday(int orders, int videos) {
    String _temp0 = intl.Intl.pluralLogic(
      orders,
      locale: localeName,
      other: '$orders Bestellungen',
      one: '1 Bestellung',
    );
    String _temp1 = intl.Intl.pluralLogic(
      videos,
      locale: localeName,
      other: '$videos Videos',
      one: '1 Video',
    );
    return 'Heute · $_temp0 · $_temp1';
  }
}

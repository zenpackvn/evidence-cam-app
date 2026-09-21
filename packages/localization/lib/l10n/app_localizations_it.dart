// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get bundleBackendPending =>
      'In attesa di un endpoint backend per questo';

  @override
  String get bundleCreate => 'Crea';

  @override
  String get bundleCreateClaim => 'Crea fascicolo di reclamo';

  @override
  String get accountClaims => 'Fascicoli di reclamo';

  @override
  String get claimsTitle => 'Fascicoli di reclamo';

  @override
  String get claimsLocalOnlyNote =>
      'Alcuni fascicoli non sono ancora stati caricati e si trovano solo su questo dispositivo.';

  @override
  String get claimsOfflineNote =>
      'Server non raggiungibile: questa è la copia locale. Riapri quando sei online per vedere tutto.';

  @override
  String get claimsEmpty =>
      'Ancora nessun fascicolo. Apri la scheda Ordini, tocca il pulsante più e scegli le prove.';

  @override
  String claimsSummary(int orders, int evidence) {
    return '$orders ordini · $evidence prove';
  }

  @override
  String claimsEvidenceOnly(int evidence) {
    return '$evidence prove';
  }

  @override
  String get claimsCopied => 'Contenuto del fascicolo copiato';

  @override
  String get claimsCreated => 'Fascicolo di reclamo creato';

  @override
  String get claimsPickNothing => 'Nessuna prova selezionata';

  @override
  String get claimsDelete => 'Elimina fascicolo';

  @override
  String get claimsDeleteConfirm =>
      'Eliminare questo fascicolo? Le prove sugli ordini restano intatte.';

  @override
  String get claimsDeleteConfirmLink =>
      'Eliminare questo fascicolo? Il suo link pubblico muore subito — chi lo ha già ricevuto vedrà una pagina vuota. Le prove sugli ordini restano intatte.';

  @override
  String get claimsRevokeFailed =>
      'Non è stato possibile revocare il link, quindi il fascicolo resta com’è. Il link è ancora aperto — riprova con una connessione migliore, o chiedi al titolare del negozio di revocarlo.';

  @override
  String get claimsDeleted => 'Fascicolo eliminato';

  @override
  String get claimsPhotoAdded =>
      'Foto aggiunta al fascicolo e messa in coda sull\'ordine';

  @override
  String get claimsAddedLater => 'aggiunta dopo';

  @override
  String get claimsCreateTitle => 'Nuovo fascicolo di reclamo';

  @override
  String get claimsCreateSearchHint =>
      'Digita o scansiona il codice di tracciamento';

  @override
  String get claimsCreateNameHint => 'es. Reclamo reso 12/08';

  @override
  String get claimsCreateNameLabel => 'Nome del fascicolo';

  @override
  String get claimInfoTitle => 'Dettagli del fascicolo';

  @override
  String get claimTrackingLabel => 'Codice di tracciamento';

  @override
  String get claimShopLabel => 'Negozio';

  @override
  String get claimChannelLabel => 'Canale di vendita';

  @override
  String get claimOrderCreatedAt => 'Data dell’ordine';

  @override
  String get claimEvidenceLabel => 'Prove';

  @override
  String claimEvidenceCount(int videos, int photos) {
    return '$videos video · $photos foto';
  }

  @override
  String get claimCreatedAtLabel => 'Fascicolo creato';

  @override
  String get claimCopyLink => 'Copy link';

  @override
  String get claimsRevokeNoLink =>
      'This dossier is not on the server yet, so there is no link to revoke.';

  @override
  String get claimPageFailed =>
      'Could not open the dossier page. Check your connection and try again.';

  @override
  String get claimLinkLabel => 'Link del fascicolo';

  @override
  String get claimLinkHint =>
      'Chiunque abbia il link può vederlo, senza accedere. Resta attivo finché non lo revochi.';

  @override
  String get claimRevokedBadge => 'Revocato';

  @override
  String get claimRevokedHint =>
      'Il link è morto. I dati restano intatti: crea un nuovo fascicolo per condividerlo di nuovo.';

  @override
  String get claimRevoke => 'Revoca';

  @override
  String get claimUntitled => 'Fascicolo senza titolo';

  @override
  String get claimRevokeConfirmTitle => 'Revocare questo fascicolo?';

  @override
  String get claimRevokeConfirmBody =>
      'Il link muore subito per chiunque lo possieda, marketplace incluso. I dati e i link per singolo ordine non sono interessati.';

  @override
  String get claimRevoked => 'Fascicolo revocato. Il link non si apre più.';

  @override
  String get claimRevokeFailed =>
      'Revoca non riuscita. Riprova quando sei online.';

  @override
  String get claimNotUploaded =>
      'Questo fascicolo non è ancora stato caricato, quindi non ha un link. Riaprilo quando sei online.';

  @override
  String get claimDetailLoadFailed =>
      'Impossibile caricare il fascicolo. Controlla la connessione e riaprilo.';

  @override
  String get claimsCreateStart =>
      'Digita il codice di tracciamento, o tocca scansiona, per trovare l\'ordine del reclamo.';

  @override
  String get claimsCreateNoOrder =>
      'Nessun ordine con quel codice di tracciamento nel negozio selezionato.';

  @override
  String get claimsRemoveItemTitle => 'Rimuovi dal fascicolo';

  @override
  String get claimsRemoveItemConfirm =>
      'Rimuovere questa prova dal fascicolo? Il video/la foto sull\'ordine resta intatto.';

  @override
  String get claimsItemRemoved => 'Rimossa dal fascicolo';

  @override
  String get claimsItemAdded => 'Aggiunto al fascicolo';

  @override
  String get commonRemove => 'Rimuovi';

  @override
  String get commonDelete => 'Elimina';

  @override
  String get settingDefaultSuffix => 'predefinito';

  @override
  String get shopDetailClipLength => 'Durata del video';

  @override
  String get shopDeleteTitle => 'Elimina negozio';

  @override
  String get shopDeleteConfirm =>
      'Eliminare questo negozio? Tutti i suoi ordini, video e foto spariscono con lui e non si possono recuperare.';

  @override
  String get shopDeleteBlockedTitle => 'Il negozio ha ancora membri';

  @override
  String shopDeleteBlockedBody(int count) {
    return 'Rimuovi tutti i membri prima di eliminare il negozio. Ne restano $count.';
  }

  @override
  String get shopDeleted => 'Negozio eliminato.';

  @override
  String bundleSelected(int count) {
    return '$count selezionati';
  }

  @override
  String get bundleUploadDrive => 'Carica su Drive';

  @override
  String get commonCancel => 'Annulla';

  @override
  String get commonRetry => 'Riprova';

  @override
  String get commonClose => 'Chiudi';

  @override
  String get toastChangeLanguage => 'Cambia lingua';

  @override
  String get toastTermsPolicy => 'Termini e informativa';

  @override
  String get toastInfoSaved => 'Informazioni salvate';

  @override
  String get toastPasswordCreated => 'Password creata';

  @override
  String get toastPasswordChanged => 'Password modificata';

  @override
  String get toastPendingDossierConfirm =>
      'Hai ancora un fascicolo di reclamo aperto, conferma di nuovo';

  @override
  String get toastCopiedShareLink => 'Link di condivisione copiato';

  @override
  String get toastShareFailed => 'Impossibile condividere, riprova più tardi';

  @override
  String get toastDownloadingVideo => 'Download del video in corso';

  @override
  String get toastVideoDownloadedCopied => 'Video scaricato e percorso copiato';

  @override
  String get toastVideoSavedToGallery =>
      'Video salvato nella galleria del dispositivo';

  @override
  String get toastVideoDownloadFailed =>
      'Impossibile scaricare il video, riprova più tardi';

  @override
  String get toastVideoDeleteUnavailable => 'Questo video non si può eliminare';

  @override
  String get toastDownloadingPhoto => 'Download della foto in corso';

  @override
  String get toastPhotoSavedToGallery =>
      'Foto salvata nella galleria del dispositivo';

  @override
  String get toastPhotoDownloadedCopied => 'Foto scaricata e percorso copiato';

  @override
  String get toastPhotoDownloadFailed =>
      'Impossibile scaricare la foto, riprova più tardi';

  @override
  String get toastPhotoNoDownloadLink =>
      'La foto non ha ancora un link di download';

  @override
  String get toastPhotoQueued =>
      'Foto allegata — messa in coda per il caricamento';

  @override
  String imageOverFixedCap(String megabytes, String limit) {
    return 'La foto è di $megabytes MB — oltre il limite di $limit MB, non è stata allegata. Scegli un\'immagine più piccola.';
  }

  @override
  String get toastInvitePending => 'In attesa di un invito a un negozio';

  @override
  String get toastInviteSent => 'Invito inviato';

  @override
  String get toastMemberAdded => 'Membro aggiunto';

  @override
  String get toastVideoPlayFailed => 'Impossibile riprodurre il video';

  @override
  String get toastShopCreated => 'Nuovo negozio creato';

  @override
  String get toastVideoQueued =>
      'Video salvato — messo in coda per il caricamento';

  @override
  String get toastVideoNoPlayLink =>
      'Il video non ha ancora un link di riproduzione';

  @override
  String get toastVideoNoDownloadLink =>
      'Il video non ha ancora un link di download';

  @override
  String get toastVideoDeleted => 'Video eliminato';

  @override
  String get toastVideoTypeSaved => 'Tipo di video salvato';

  @override
  String get toastVideoTypeDeleted => 'Tipo di video eliminato';

  @override
  String get toastNoVideoTypeToDelete => 'Nessun tipo di video da eliminare';

  @override
  String get toastNoMemberToUpdate => 'Nessun membro da aggiornare';

  @override
  String get toastMemberRemoved =>
      'Rimosso dal negozio (i video registrati completano comunque il caricamento)';

  @override
  String get toastInviteRevoked =>
      'Invito eliminato — il link nell\'e-mail non funziona più';

  @override
  String copiedLabel(String label) {
    return '$label copiato';
  }

  @override
  String get labelTrackingCode => 'codice di tracciamento';

  @override
  String resolutionChanged(String value) {
    return 'Risoluzione: $value';
  }

  @override
  String get accountNoName => 'Ancora nessun nome';

  @override
  String get accountNoShop => 'Nessun negozio selezionato';

  @override
  String get accountCreatePassword => 'Crea password';

  @override
  String get accountChangePassword => 'Cambia password';

  @override
  String accountLinkedMethods(int count) {
    return '$count collegati';
  }

  @override
  String get roleOwner => 'Titolare';

  @override
  String get roleStaff => 'Dipendente';

  @override
  String memberInviteSent(String role) {
    return '$role · invito inviato';
  }

  @override
  String memberInvitePending(String role) {
    return '$role · in attesa di conferma';
  }

  @override
  String get planFree => 'Gratis';

  @override
  String get planBasic => 'Basic';

  @override
  String get planSaver => 'Saver';

  @override
  String get planPremium => 'Premium';

  @override
  String get planPro => 'Pro';

  @override
  String get planEnterprise => 'Azienda';

  @override
  String get roleOther => 'Altro';

  @override
  String get roleUnknown => 'Sconosciuto';

  @override
  String get memberFallbackName => 'Membro';

  @override
  String get uploadStatusDone => 'Caricato';

  @override
  String get uploadStatusPending => 'In attesa di caricamento';

  @override
  String get uploadStatusQuotaHold => 'In sospeso (quota)';

  @override
  String get uploadStatusDeleted => 'Eliminato';

  @override
  String get uploadStatusError =>
      'Caricamento non completato — il video è ancora sul dispositivo che lo ha registrato';

  @override
  String get uploadStatusExpired => 'Periodo di conservazione scaduto';

  @override
  String expiredOnDate(String date) {
    return 'Periodo di conservazione scaduto il $date';
  }

  @override
  String get kindPhoto => 'Foto allegata';

  @override
  String get kindVideo => 'Video';

  @override
  String get recordedByFallback => 'Account attuale';

  @override
  String get deviceUnknown => 'Dispositivo sconosciuto';

  @override
  String get orderNoEvidence => 'Ancora nessuna prova';

  @override
  String get timelineEmpty => 'Questa spedizione non ha ancora video né foto';

  @override
  String get errorGenericRetry => 'Qualcosa è andato storto, riprova.';

  @override
  String get errorPendingDossier =>
      'Hai ancora un fascicolo di reclamo aperto, gestiscilo prima di continuare.';

  @override
  String get errorSessionExpired => 'La sessione è scaduta, accedi di nuovo.';

  @override
  String get errorNoNetwork => 'Nessuna connessione di rete, riprova.';

  @override
  String get errorNoPermission => 'Non hai i permessi per questa azione.';

  @override
  String get errorServerBusy => 'Il sistema è occupato, riprova più tardi.';

  @override
  String get errorSessionInvalid => 'Sessione non valida, accedi di nuovo.';

  @override
  String get errorVideoTypeInUse =>
      'Non si può eliminare un tipo di video che ha già dei video. Controlla prima i video che usano questo tipo.';

  @override
  String get errorBuiltinVideoTypeLocked =>
      'I 3 tipi di video integrati non si possono modificare né eliminare.';

  @override
  String get errorVideoTypeNameExists =>
      'Quel nome di tipo di video esiste già nel negozio.';

  @override
  String get errorCheckNetwork => 'Controlla la rete o riprova più tardi.';

  @override
  String get errorLoadShopList => 'Impossibile caricare l\'elenco dei negozi';

  @override
  String get errorLoadShopMgmt =>
      'Impossibile caricare la gestione del negozio';

  @override
  String get errorLoadShopDetail =>
      'Impossibile caricare i dettagli del negozio';

  @override
  String get errorLoadMembers => 'Impossibile caricare l\'elenco dei membri';

  @override
  String get membersRestricted =>
      'Solo il titolare del negozio vede l\'elenco dei membri';

  @override
  String get errorLoadOrders => 'Impossibile caricare gli ordini';

  @override
  String get errorLoadOrderDetail =>
      'Impossibile caricare i dettagli dell\'ordine';

  @override
  String get noShopSelectedOrdersDetail =>
      'Scegli prima un negozio per vedere gli ordini.';

  @override
  String get noShopSelectedRecordDetail =>
      'Scegli prima un negozio per registrare.';

  @override
  String get noShopSelectedManageDetail => 'Scegli un negozio da gestire.';

  @override
  String get noOrdersTitle => 'Ancora nessun ordine';

  @override
  String get noOrdersDetail => 'Scegli un ordine dall\'elenco.';

  @override
  String get noVideoDataTitle => 'Nessun dato video';

  @override
  String get cannotOpenVideoTitle => 'Impossibile aprire il video';

  @override
  String get cannotOpenVideoDetail =>
      'Il video non ha ancora un link di riproduzione.';

  @override
  String get createOrderDialogTitle => 'Creare un nuovo ordine?';

  @override
  String createOrderDialogBody(String code) {
    return '$code non corrisponde a nessun codice di tracciamento in questo negozio. Ricontrolla il codice o conferma la creazione di un nuovo ordine.';
  }

  @override
  String get createOrderConfirm => 'Crea nuovo ordine';

  @override
  String get statOrdersToday => 'Ordini';

  @override
  String get statVideosRecorded => 'Video registrati';

  @override
  String get statPendingUpload => 'Caricamento in sospeso';

  @override
  String get accountPlanQuota => 'Archiviazione';

  @override
  String get accountChangePlan => 'Cambia piano';

  @override
  String get accountSectionApp => 'PIANO E APP';

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
  String get accountLanguage => 'Lingua';

  @override
  String get accountSectionSecurity => 'SICUREZZA E ACCESSO';

  @override
  String get accountLoginMethods => 'Metodo di accesso';

  @override
  String get accountSignOut => 'Esci';

  @override
  String get accountSignOutConfirmTitle => 'Uscire?';

  @override
  String get accountSignOutConfirmMessage =>
      'Dovrai accedere di nuovo per continuare a usare l\'app.';

  @override
  String get accountDeleteAccount => 'Elimina account';

  @override
  String accountVersion(String version) {
    return 'Versione $version';
  }

  @override
  String get accountShopMgmtHint =>
      'Gestisci negozio/membri: tocca indietro nell\'intestazione per tornare al livello Negozio';

  @override
  String get accountInfoTitle => 'Informazioni account';

  @override
  String get accountFullName => 'Nome completo';

  @override
  String get accountFullNameHint => 'Inserisci il tuo nome completo';

  @override
  String get accountFullNameRequired => 'Inserisci il tuo nome completo';

  @override
  String get phoneOptionalLabel => 'Numero di telefono (facoltativo)';

  @override
  String get phoneOptionalHint =>
      'Facoltativo — solo per l\'assistenza sull\'account';

  @override
  String get phoneInvalid => 'Numero di telefono non valido';

  @override
  String get accountSaveChanges => 'Salva modifiche';

  @override
  String get accountEmailLockedHint =>
      'E-mail usata per l\'accesso — non modificabile';

  @override
  String get commonContinue => 'Continua';

  @override
  String get commonLater => 'Più tardi';

  @override
  String get cameraPermissionRationaleTitle =>
      'Serve l\'accesso alla fotocamera';

  @override
  String get cameraPermissionRationaleBody =>
      'ZenPack ha bisogno della fotocamera per registrare i video di prova dell\'imballaggio dei tuoi ordini.';

  @override
  String get cameraPermissionDeniedTitle => 'Non si può ancora registrare';

  @override
  String get cameraPermissionDeniedBody =>
      'ZenPack non può registrare video perché manca l\'accesso alla fotocamera. Puoi comunque consultare, cercare e gestire gli ordini.';

  @override
  String get cameraPermissionOpenSettings => 'Apri Impostazioni';

  @override
  String get languageNameVietnamese => 'Vietnamita';

  @override
  String get languageNameEnglish => 'Inglese';

  @override
  String get languageChangeAppliesNote =>
      'Le modifiche valgono subito in tutta l\'app';

  @override
  String get linkLinked => 'Collegato';

  @override
  String get linkNotLinked => 'Non collegato';

  @override
  String get loginMethodsEmailNote =>
      'L\'e-mail è l\'identificativo del tuo account — non si può rimuovere. Collega Google/Apple per accedere velocemente con lo stesso account.';

  @override
  String get loginMethodIdentity => 'Identificativo';

  @override
  String get linkAction => 'Collega';

  @override
  String get linkUnlink => 'Scollega';

  @override
  String get quotaScreenTitle => 'Report e quota';

  @override
  String get quotaRemainingThisMonth => 'Rimanenti questo mese';

  @override
  String get quotaSubtitle => 'Tieni d\'occhio l\'archiviazione che usi';

  @override
  String quotaRemainingAmount(String amount) {
    return '$amount rimanenti';
  }

  @override
  String get quotaStorage => 'Archiviazione';

  @override
  String get deleteAccountTitleStep1 => 'Eliminare l\'account?';

  @override
  String get deleteAccountTitleStep2 => 'Confermi l\'eliminazione definitiva?';

  @override
  String get deleteAccountBodyStep1 =>
      'Tutti i tuoi video, spedizioni e fascicoli saranno eliminati definitivamente. L\'azione non è reversibile.';

  @override
  String get deleteAccountBodyStep2 =>
      'Questo è l\'ultimo passaggio di conferma. Dopo l\'eliminazione uscirai subito dall\'app.';

  @override
  String get deleteConfirmPermanent => 'Elimina definitivamente';

  @override
  String get deleteStep1Hint => 'Passo 1/2 — chiederà di nuovo conferma';

  @override
  String get deleteStep2Hint => 'Passo 2/2 — l\'azione non è reversibile';

  @override
  String get passwordCurrentLabel => 'Password attuale';

  @override
  String get passwordCurrentRequired => 'Inserisci la password attuale';

  @override
  String get passwordNewLabel => 'Nuova password';

  @override
  String get passwordMinHint => 'Almeno 8 caratteri';

  @override
  String get passwordNewRequired => 'Inserisci una nuova password';

  @override
  String get passwordMin8Error => 'La password deve avere almeno 8 caratteri';

  @override
  String get passwordNeedsLetterDigit =>
      'La password deve contenere lettere e numeri';

  @override
  String get passwordTooCommon =>
      'Quella password è troppo facile da indovinare — scegline un\'altra';

  @override
  String get passwordConfirmLabel => 'Reinserisci la nuova password';

  @override
  String get passwordMismatch => 'Le password non coincidono';

  @override
  String get passwordSave => 'Salva password';

  @override
  String get passwordChangeLogoutNote =>
      'Dopo la modifica uscirai dagli altri dispositivi';

  @override
  String get navOrders => 'Ordini';

  @override
  String get navRecord => 'Registra';

  @override
  String get navAccount => 'Account';

  @override
  String get navClaims => 'Reclami';

  @override
  String get changeAvatar => 'Cambia foto profilo';

  @override
  String quotaVideosRatio(int remaining, int total) {
    return '$remaining / $total video';
  }

  @override
  String quotaUsedPercent(int percent) {
    return 'Usato $percent%';
  }

  @override
  String quotaRetentionDays(int days) {
    return '$days giorni';
  }

  @override
  String quotaUsedRatio(String used, String cap, int percent) {
    return 'Usati $used / $cap · $percent%';
  }

  @override
  String get quotaVideosStored => 'Video archiviati';

  @override
  String quotaVideosStoredCount(int count) {
    return '$count video';
  }

  @override
  String get quotaByType => 'Archiviazione per tipo';

  @override
  String quotaByTypeVideosCount(int count) {
    return '$count video archiviati';
  }

  @override
  String quotaRefundNote(int days) {
    return 'L\'archiviazione si libera quando un video supera i $days giorni di conservazione';
  }

  @override
  String deletePendingProfilesWarning(int count) {
    return 'Hai ancora $count fascicoli “inviati alla piattaforma” — i loro link di condivisione smetteranno di funzionare';
  }

  @override
  String get detailRecordedTime => 'Ora di registrazione';

  @override
  String get detailDuration => 'Durata';

  @override
  String get detailRecordedBy => 'Registrato da';

  @override
  String get detailCapturedTime => 'Ora di acquisizione';

  @override
  String get detailCapturedBy => 'Acquisito da';

  @override
  String get detailDevice => 'Dispositivo';

  @override
  String get detailSize => 'Dimensione';

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
  String get detailUploadStatus => 'Stato del caricamento';

  @override
  String get detailSeal => 'Sigillo';

  @override
  String sealSealed(String at) {
    return 'Bloccato · $at';
  }

  @override
  String get sealWorking => 'Impressione della marca temporale…';

  @override
  String get sealWorkingHint =>
      'La copia archiviata non ha ancora la marca temporale impressa, perciò link di condivisione e download aspettano. Di solito pochi secondi.';

  @override
  String get playLocalCopyNote =>
      'Copia temporanea su questo dispositivo — ancora senza marca temporale sulle immagini';

  @override
  String get sealNone => 'Registrato prima che esistesse il sigillo';

  @override
  String get sealFailed =>
      'Marca temporale non ancora impressa · il video si riproduce e si scarica lo stesso';

  @override
  String get sealMismatch =>
      'Impronta non corrispondente — registra di nuovo questa clip';

  @override
  String get sealLate =>
      'Sigillo tardivo — il video è integro; l\'errore è stato nostro';

  @override
  String get sealTimeDrift =>
      'L\'orologio della fotocamera si è scostato dal server, perciò il timbro impresso riporta anche l\'ora in cui il server ha ricevuto la clip.';

  @override
  String get detailSealAnchor => 'Prova indipendente';

  @override
  String sealAnchorConfirmed(String block) {
    return 'Sì · voce n. $block';
  }

  @override
  String get sealAnchorConfirmedNoBlock => 'Sì';

  @override
  String get sealAnchorPending =>
      'In scrittura sul registro pubblico (qualche ora)';

  @override
  String get sealAnchorNone => 'Nessuna';

  @override
  String get sealVerifyOpen => 'Apri la pagina di verifica';

  @override
  String get sealVerifyHint =>
      'Invia questo link alla piattaforma — può verificarlo da sola, senza fidarsi di ZenPack.';

  @override
  String get sealVerifyFailed => 'Impossibile aprire la pagina di verifica.';

  @override
  String get detailPlayVideo => 'Riproduci il video';

  @override
  String get detailCopyAssetLink => 'Copia il link';

  @override
  String get assetLinkTitle => 'Link della prova';

  @override
  String get detailDownloadVideo => 'Scarica il video';

  @override
  String get detailDownloadNote =>
      'Solo titolare/responsabile · per quando la piattaforma chiede il file originale';

  @override
  String get detailTrimVideo => 'Taglia una clip breve da inviare';

  @override
  String get detailTrimNote =>
      'La clip completa resta intatta · quella tagliata mantiene la marca temporale';

  @override
  String get trimSave => 'Salva';

  @override
  String get trimEstimatedSize => 'Circa';

  @override
  String get trimFailed =>
      'Impossibile tagliare il video. La clip completa è ancora lì.';

  @override
  String get trimPreparing => 'Download della clip completa…';

  @override
  String get detailDownloadPhoto => 'Scarica la foto';

  @override
  String get attachPhotoToOrder => 'Allega foto all\'ordine';

  @override
  String get deleteVideoAction => 'Elimina video';

  @override
  String get deletePhotoAction => 'Elimina foto';

  @override
  String get deleteVideoNote =>
      'Solo titolare/responsabile · bloccato finché un fascicolo è aperto · conferma in due passaggi';

  @override
  String deleteVideoInDossier(String dossier) {
    return 'This evidence is in claim dossier $dossier — remove it from the dossier first, then delete.';
  }

  @override
  String get deleteVideoConfirmTitle => 'Conferma finale';

  @override
  String get deleteVideoConfirmBody =>
      'Questa prova sarà eliminata definitivamente e non sarà recuperabile — eliminare comunque?';

  @override
  String get deleteVideoConfirmAction => 'Elimina definitivamente';

  @override
  String ordersErrorCount(int count) {
    return '· $count errori';
  }

  @override
  String ordersPendingCount(int count) {
    return '· $count in sospeso';
  }

  @override
  String ordersPendingEvidenceWarning(int count) {
    return '$count prove non caricate · ancora nessun link copiabile';
  }

  @override
  String get captureFramePrompt => 'Scansiona il codice di tracciamento';

  @override
  String get captureCameraDownHint => 'Metti l\'etichetta nel riquadro';

  @override
  String get cutoverSavedVideo => 'Video salvato';

  @override
  String get cutoverPreparingNext => 'Preparazione per il prossimo';

  @override
  String get cutoverNextOrder => 'Ordine successivo';

  @override
  String get lowStorageTitle => 'Archiviazione quasi piena';

  @override
  String get lowStorageBody =>
      'Lo spazio su questo dispositivo sta finendo — una registrazione in corso potrebbe non salvarsi per intero. Libera spazio prima di continuare.';

  @override
  String get lowStorageAction => 'Ho capito';

  @override
  String cutoverClosedSummary(String code, String duration) {
    return 'Codice di tracciamento $code chiuso ($duration)';
  }

  @override
  String get cutoverSignalText => 'Suono + vibrazione al passaggio di ordine';

  @override
  String get tooltipBack => 'Indietro';

  @override
  String get tooltipSwitchCamera => 'Cambia fotocamera';

  @override
  String get tooltipEnterTracking => 'Inserisci il codice di tracciamento';

  @override
  String get scanPickImage => 'Scegli una foto';

  @override
  String get scanNoCodeInImage =>
      'Nessun codice di tracciamento in questa foto';

  @override
  String get tooltipZoomIn => 'Ingrandisci';

  @override
  String get tooltipZoomOut => 'Riduci';

  @override
  String get captureResolution => 'Risoluzione';

  @override
  String get stopRecording => 'Interrompi la registrazione';

  @override
  String get videoTypeSettings => 'Impostazioni dei tipi di video';

  @override
  String get uploadQueueTitle => 'Coda di caricamento';

  @override
  String get quotaExhaustedNote =>
      'La quota mensile è esaurita. La registrazione funziona ancora, ma queste clip sono SU QUESTO TELEFONO e non ancora protette — si caricheranno da sole appena la quota verrà alzata.';

  @override
  String get queueEmpty => 'Ancora nessun video in coda';

  @override
  String get queueAutoUploadNote =>
      'Il caricamento avviene automaticamente quando sei online';

  @override
  String get waitingUpload => 'In attesa di caricamento';

  @override
  String get queueUploading => 'In caricamento';

  @override
  String get queueQuotaShort => 'In attesa di quota';

  @override
  String get queueUploadFailed => 'Caricamento non completato';

  @override
  String get uploaded => 'Caricato';

  @override
  String get waitingQuota => 'In attesa di quota · ancora sul dispositivo';

  @override
  String get pausedUpload => 'In pausa';

  @override
  String get queuePauseAction => 'Pausa';

  @override
  String get queueResumeAction => 'Riprendi';

  @override
  String get queueDeleteAction => 'Rimuovi';

  @override
  String get queueClearAction => 'Svuota';

  @override
  String get queueClearConfirmTitle => 'Svuotare l\'intera coda?';

  @override
  String get queueClearConfirmBody =>
      'I clip non caricati esistono solo su questo telefono. Svuotare li elimina per sempre.';

  @override
  String get queueDeleteConfirmTitle => 'Rimuovere dalla coda?';

  @override
  String get queueDeleteConfirmBody =>
      'Questa clip non è ancora stata caricata — rimuoverla la elimina definitivamente dal dispositivo.';

  @override
  String get toastQueueItemDeleted => 'Rimossa dalla coda di caricamento';

  @override
  String get manualTrackingTitle => 'Inserisci il codice di tracciamento';

  @override
  String get manualTrackingNote => 'Digitalo o scansiona di nuovo il codice';

  @override
  String get commonDone => 'Fatto';

  @override
  String get startRecording => 'Avvia la registrazione';

  @override
  String get returnCodeMismatch => 'Il codice di reso non corrisponde';

  @override
  String get enterCodeManually => 'Inserisci il codice manualmente';

  @override
  String get videoTypeLabel => 'Tipo di video';

  @override
  String get videoTypeSelectNote =>
      'Scegli il tipo giusto — aggiungi/modifica/elimina nei Dettagli del negozio';

  @override
  String get videoTypeSheetTitle => 'Scegli un tipo di video';

  @override
  String get videoTypeGroupDefault => 'Tipi predefiniti (obbligatori)';

  @override
  String get videoTypeGroupCustom => 'Tipi personalizzati del negozio';

  @override
  String get manageVideoTypesNote =>
      'Gestisci i tipi di video — apri i Dettagli del negozio';

  @override
  String queueFilterAll(int count) {
    return 'Tutti ($count)';
  }

  @override
  String queueFilterUploading(int count) {
    return 'In caricamento ($count)';
  }

  @override
  String queueFilterErrored(int count) {
    return 'Errori ($count)';
  }

  @override
  String queueFilterQuotaWait(int count) {
    return 'In attesa di quota ($count)';
  }

  @override
  String queueSummary(int pending, int uploading, int errored) {
    return '$pending video in attesa · $uploading in caricamento · $errored falliti';
  }

  @override
  String uploadingProgress(int percent) {
    return 'Caricamento $percent%';
  }

  @override
  String errorRetryCount(int count) {
    return 'Errore · Riprova ($count)';
  }

  @override
  String returnCodeMismatchBody(String returnCode, String shopName) {
    return '$returnCode non corrisponde a nessun ordine in $shopName. Ricontrolla il codice, inseriscilo manualmente o conferma la creazione di un nuovo ordine.';
  }

  @override
  String get onboardingSubtitle =>
      'Registra video di prova dell\'imballaggio per i venditori online';

  @override
  String get onboardingStart => 'Inizia';

  @override
  String get authSignIn => 'Accedi';

  @override
  String get authChooseMethod => 'Scegli un metodo di accesso';

  @override
  String get authEmailRequired => 'Inserisci la tua e-mail';

  @override
  String get authEmailInvalid => 'E-mail non valida';

  @override
  String get authPassword => 'Password';

  @override
  String get authPasswordRequired => 'Inserisci la tua password';

  @override
  String get authForgotPassword => 'Password dimenticata?';

  @override
  String get registerWithGoogle => 'Registrati con Google';

  @override
  String get registerWithApple => 'Registrati con Apple';

  @override
  String get authSignInGoogle => 'Accedi con Google';

  @override
  String get authSignInApple => 'Accedi con Apple';

  @override
  String get authNoAccountPrompt => 'Non hai un account? ';

  @override
  String get authRegister => 'Registrati';

  @override
  String get authOr => 'oppure';

  @override
  String get registerTitle => 'Crea un nuovo account';

  @override
  String get registerConfirmPassword => 'Reinserisci la password';

  @override
  String get registerAgreePolicy => 'Accetto l\'informativa ';

  @override
  String get registerViewPolicy => 'Vedi l\'informativa';

  @override
  String get registerCreateAccount => 'Crea account';

  @override
  String get registerSameEmailNote =>
      'La stessa e-mail verrà collegata automaticamente a un solo account';

  @override
  String get registerHaveAccountPrompt => 'Hai già un account? ';

  @override
  String get registerSuccessTitle => 'Account creato';

  @override
  String registerSuccessVerifyMessage(String email) {
    return 'Abbiamo inviato un\'e-mail di verifica a $email. Controlla la posta in arrivo (anche lo spam), poi accedi.';
  }

  @override
  String get registerSuccessMessage =>
      'Il tuo account è pronto. Accedi con l\'e-mail e la password appena registrate.';

  @override
  String get registerSuccessAction => 'Accedi';

  @override
  String get loginNotVerifiedTitle => 'E-mail non verificata';

  @override
  String loginNotVerifiedMessage(String email) {
    return 'Apri l\'e-mail di verifica inviata a $email (controlla anche lo spam), segui il link, poi accedi di nuovo.';
  }

  @override
  String get loginResendVerification => 'Invia di nuovo l\'e-mail';

  @override
  String get loginVerificationResent => 'E-mail di verifica inviata di nuovo';

  @override
  String get forgotPasswordTitle => 'Password dimenticata';

  @override
  String get forgotPasswordSubtitle =>
      'Inserisci la tua e-mail per ricevere un link di reimpostazione';

  @override
  String get forgotPasswordSubmit => 'Invia il link';

  @override
  String get forgotPasswordSent =>
      'Inviato — controlla la posta in arrivo (anche lo spam)';

  @override
  String get forgotPasswordRememberPrompt => 'Ti sei ricordato la password? ';

  @override
  String get shopYourShops => 'I tuoi negozi';

  @override
  String get shopTapToClockIn =>
      'Tocca un negozio per iniziare il turno · gestiscilo proprio qui';

  @override
  String get shopLastOpenedNote =>
      'La prossima volta si aprirà direttamente l\'ultimo negozio usato';

  @override
  String get shopManageStore => 'Gestisci negozio';

  @override
  String get shopManageVisibilityNote =>
      'Visibile solo al titolare dell\'account / responsabile del negozio';

  @override
  String get shopEmpty => 'Ancora nessun negozio';

  @override
  String get shopEmptyBody =>
      'Il tuo account non appartiene ancora a nessun negozio. Creane uno per iniziare, o aspetta l\'invito di un titolare.';

  @override
  String get shopCreateNew => 'Crea un nuovo negozio (nome + piattaforma)';

  @override
  String get shopInvitesHere => 'Gli inviti ai negozi compariranno qui';

  @override
  String get shopCreateTitle => 'Crea negozio';

  @override
  String get shopNameLabel => 'Nome del negozio';

  @override
  String get shopNameRequired => 'Inserisci un nome per il negozio';

  @override
  String get shopPlatform => 'Marketplace';

  @override
  String get shopCreateOwnerNote =>
      'Sarai il titolare del negozio — aggiungi membri più tardi in Gestisci negozio';

  @override
  String get shopMgmtVisibilityNote =>
      'I dipendenti non vedono questa schermata · i responsabili vedono solo i negozi che gestiscono';

  @override
  String get shopAddNew => 'Aggiungi un nuovo negozio';

  @override
  String get sectionMembers => 'MEMBRI';

  @override
  String get sectionShopSettings => 'IMPOSTAZIONI DEL NEGOZIO';

  @override
  String get sectionVideoTypes => 'TIPI DI VIDEO';

  @override
  String get videoTypesLockedNote =>
      'I 3 tipi integrati sono bloccati — non modificabili/eliminabili';

  @override
  String get addMemberByContact => 'Aggiungi membro via e-mail/telefono';

  @override
  String get recordResolution => 'Risoluzione di registrazione';

  @override
  String get addVideoType => 'Aggiungi tipo (inserisci un nome)';

  @override
  String get createVideoTypeTitle => 'Crea tipo di video';

  @override
  String get videoTypeName => 'Nome del tipo di video';

  @override
  String get videoTypeNameHint => 'es. Pesatura';

  @override
  String get createVideoType => 'Crea tipo';

  @override
  String get deleteVideoTypeBody =>
      'Eliminabile solo finché questo tipo non ha video. Se ne ha, il sistema blocca l\'eliminazione per non rovinare filtri delle prove e statistiche.';

  @override
  String get deleteVideoTypeConfirm => 'Elimina tipo';

  @override
  String get deleteVideoTypeNote =>
      '(Eliminabile solo finché il tipo non ha video)';

  @override
  String get addMemberTitle => 'Aggiungi membro';

  @override
  String get addMemberBody =>
      'Inserisci l\'e-mail di un account ZenPack già registrato. Riceverà un invito e dovrà confermarlo per entrare nel negozio.';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get emailRequired => 'Inserisci un indirizzo e-mail.';

  @override
  String get emailInvalid => 'Inserisci un solo indirizzo e-mail valido.';

  @override
  String get errorInviteAccountNotFound =>
      'Questa e-mail non ha ancora un account ZenPack. Chiedi di registrarsi prima, poi invita di nuovo.';

  @override
  String get errorInviteAlreadyMember => 'È già membro di questo negozio.';

  @override
  String get errorInviteMemberLimit =>
      'Il limite di membri di questo piano è pieno. Gli inviti in sospeso contano — revocane uno per liberare un posto.';

  @override
  String get errorInviteAlreadyOwner =>
      'Quello è il titolare del negozio — nessun invito necessario.';

  @override
  String get errorInviteInvalidRequest =>
      'Quell\'e-mail non è valida. Controllala e invia di nuovo.';

  @override
  String get addMemberSubmit => 'Aggiungi';

  @override
  String get memberOwnerLocked =>
      'Il titolare non può cambiare ruolo né essere rimosso qui — la proprietà appartiene al negozio, non a una riga di appartenenza.';

  @override
  String get removeFromShop => 'Rimuovi dal negozio';

  @override
  String get revokeInvite => 'Elimina invito';

  @override
  String get resolutionAppliesNote =>
      'Vale per i nuovi video registrati del negozio';

  @override
  String get resolutionDefaultOption => '720p (predefinita)';

  @override
  String get ordersSearchHint => 'Inserisci il codice di tracciamento';

  @override
  String get ordersEmpty => 'Questo negozio non ha ancora ordini';

  @override
  String recordAutoStopIn(String time) {
    return 'Si ferma da solo tra $time';
  }

  @override
  String get ordersNotFound => 'Nessun ordine trovato';

  @override
  String get ordersNotFoundHint =>
      'Ricontrolla il codice di tracciamento e riprova';

  @override
  String ordersPageRange(int first, int last, int total) {
    return '$first–$last di $total ordini';
  }

  @override
  String get ordersPagePrevious => 'Pagina precedente';

  @override
  String get ordersPageNext => 'Pagina successiva';

  @override
  String ordersPageNumber(int page) {
    return 'Pagina $page';
  }

  @override
  String get filterStatusLabel => 'Stato';

  @override
  String get filterStatusAll => 'Tutti';

  @override
  String get filterStatusPending => 'In attesa di caricamento';

  @override
  String get filterStatusError => 'Errori di caricamento';

  @override
  String get filterStatusDone => 'Caricati completamente';

  @override
  String get filterTimeLabel => 'Periodo';

  @override
  String get filterTimeAll => 'Qualsiasi periodo';

  @override
  String get filterTimeToday => 'Oggi';

  @override
  String get filterTimeYesterday => 'Ieri';

  @override
  String get filterTime7d => 'Ultimi 7 giorni';

  @override
  String get filterTime30d => 'Ultimi 30 giorni';

  @override
  String get filterTimePickDate => 'Scegli una data…';

  @override
  String get filterTypeLabel => 'Tipo di video';

  @override
  String get filterTypeAll => 'Tutti';

  @override
  String deleteVideoTypeTitle(String typeName) {
    return 'Eliminare il tipo \"$typeName\"?';
  }

  @override
  String memberCurrentRole(String role) {
    return 'Ruolo attuale: $role';
  }

  @override
  String get stopCodeTitle => 'Codice QR per fermare la registrazione';

  @override
  String get stopCodeInstructions =>
      'Stampalo e attaccalo al tavolo di imballaggio. Mostralo alla fotocamera durante la registrazione per fermarla automaticamente.';

  @override
  String get scannedCodeNotFound =>
      'Nessun ordine corrisponde al codice scansionato';

  @override
  String get onboardingTaglineOne => 'Ogni pacco.';

  @override
  String get onboardingTaglineTwo => 'Una prova.';

  @override
  String get onboardingTaglineThree => 'Protegge il tuo fatturato.';

  @override
  String get authEmailPlaceholder => 'Inserisci la tua e-mail';

  @override
  String get authPasswordPlaceholder => 'Inserisci la tua password';

  @override
  String get registerCreateAccountSubtitle => 'Crea un nuovo account';

  @override
  String get registerFullName => 'Nome completo';

  @override
  String get registerFullNameRequired => 'Inserisci il tuo nome completo';

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
  String get registerAgreePrefix => 'Accetto i';

  @override
  String get registerTermsOfUse => 'Termini di utilizzo';

  @override
  String get shopChooseTitle => 'Scegli un negozio';

  @override
  String get shopChooseSubtitle => 'Scegli un negozio per continuare';

  @override
  String get shopManageTitle => 'Gestisci i negozi';

  @override
  String get shopManageOwnerOnly => 'Visibile solo a titolari e responsabili';

  @override
  String get noShopTitle => 'Ancora nessun negozio';

  @override
  String get noShopLineOne =>
      'Il tuo account non appartiene ancora a nessun negozio.';

  @override
  String get noShopLineTwo => 'Crea un negozio per iniziare,';

  @override
  String get noShopLineThree => 'o aspetta l\'invito di un titolare.';

  @override
  String get noShopCreateCta => 'Crea un negozio (nome + marketplace)';

  @override
  String get noShopInviteHint => 'Gli inviti ai negozi compariranno qui';

  @override
  String get createShopTitle => 'Crea negozio';

  @override
  String get createShopNameLabel => 'Nome del negozio';

  @override
  String get createShopNameHint => 'es. Negozio ABC';

  @override
  String get createShopPlatformLabel => 'Marketplace';

  @override
  String get createShopOwnerNote =>
      'Sarai il titolare del negozio — aggiungi membri più tardi in Gestisci i negozi';

  @override
  String get createShopSubmit => 'Crea negozio';

  @override
  String get shopManageDescription =>
      'Vedi e gestisci i negozi che amministri.';

  @override
  String get shopManageAddCta => 'Aggiungi un negozio';

  @override
  String get shopManageStaffNote =>
      'I dipendenti non vedono questa schermata — solo titolari e responsabili.';

  @override
  String get shopDetailTitle => 'Dettagli del negozio';

  @override
  String get shopDetailResolution => 'Risoluzione di registrazione';

  @override
  String get shopDetailClipDuration => 'Durata max/video';

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
    return 'Consigliato $minutes min — per $platform ($megabytes MB/video) + $resolution';
  }

  @override
  String clipRecommendedHintUnverified(String minutes, String platform) {
    return 'Consigliato $minutes min — i limiti di $platform non sono confermati, si usano i valori noti più sicuri';
  }

  @override
  String clipOverRecommendedWarning(
    String minutes,
    String platform,
    String chosen,
    String megabytes,
  ) {
    return 'Oltre il consiglio di $minutes min per $platform — un video di $chosen min pesa circa $megabytes MB, quindi va inviato come link al fascicolo invece che allegato al modulo di reclamo.';
  }

  @override
  String get clipDurationTitle => 'Durata massima per video';

  @override
  String get clipDurationSubtitle => 'Si chiude da solo a questa durata';

  @override
  String clipDurationPlanCap(String minutes) {
    return 'Il tuo piano consente fino a $minutes min';
  }

  @override
  String clipDurationChanged(String minutes) {
    return 'Durata max/video: $minutes min';
  }

  @override
  String get shopDetailImageSize => 'Dimensione immagine';

  @override
  String get shopDetailVideoSize => 'Dimensione video';

  @override
  String get shopDetailUploadSize => 'Dimensione max/file';

  @override
  String uploadSizeValue(String megabytes) {
    return '$megabytes MB';
  }

  @override
  String uploadRecommendedHint(String megabytes, String platform) {
    return 'Consigliato $megabytes MB — limite di allegato di $platform';
  }

  @override
  String uploadOverRecommendedWarning(
    String megabytes,
    String platform,
    String chosen,
  ) {
    return 'Oltre il consiglio di $megabytes MB per $platform — un file fino a $chosen MB resta archiviato per intero, ma va inviato come link al fascicolo invece che allegato al modulo di reclamo.';
  }

  @override
  String get uploadSizeValueUnlimited => 'Nessun limite';

  @override
  String get uploadSizeTitle => 'Dimensione massima per file';

  @override
  String uploadSizeSubtitle(String megabytes, String platform) {
    return 'I file oltre il limite non vengono allegati; $megabytes MB si allegano ancora direttamente a $platform';
  }

  @override
  String uploadSizeOptionRecommended(String megabytes) {
    return '$megabytes MB (consigliato)';
  }

  @override
  String uploadSizeChanged(String megabytes) {
    return 'Dimensione per file: $megabytes';
  }

  @override
  String avatarTooLarge(String megabytes, String limit) {
    return 'Nome e telefono salvati. La foto profilo da $megabytes MB supera il limite di $limit MB e non è arrivata al server — scegli un\'immagine più piccola.';
  }

  @override
  String avatarUploadFailed(String reason) {
    return 'Nome e telefono salvati. La foto profilo non è arrivata al server: $reason';
  }

  @override
  String nearClipLimitWarning(String minutes) {
    return 'Vicino al limite di $minutes min — il video si chiuderà da solo';
  }

  @override
  String get shopDetailAddType => 'Aggiungi un tipo (inserisci un nome)';

  @override
  String get inviteMemberTitle => 'Invita un membro';

  @override
  String get inviteRoleFixedNote =>
      'Entra come dipendente: registra video e rivede i propri.';

  @override
  String get inviteMemberHint => '(nessun account ancora → invia un invito)';

  @override
  String get videoTypeIcon => 'Icona';

  @override
  String get videoTypeColor => 'Colore';

  @override
  String get createVideoTypeSubmit => 'Crea tipo';

  @override
  String get deleteVideoTypeSafeNote => 'Nessuna prova va persa';

  @override
  String get commonConfirm => 'Conferma';

  @override
  String orderErrorCount(int count) {
    return '$count falliti';
  }

  @override
  String get videoDetailSheetTitle => 'Dettaglio video';

  @override
  String get tooltipStopRecording => 'Interrompi la registrazione';

  @override
  String get dossierLinkTitle => 'Link del fascicolo di contestazione';

  @override
  String get accountEndQr => 'Codice per fermare la registrazione';

  @override
  String get accountEndQrTitle => 'Codice per fermare la registrazione';

  @override
  String get accountEndQrShare => 'Condividi il codice';

  @override
  String get accountEndQrSave => 'Salva nella libreria foto';

  @override
  String get recordInterruptedTitle => 'Registrazione in pausa';

  @override
  String get recordInterruptedBody =>
      'La registrazione è in pausa perché qualcosa l\'ha interrotta. Continuare?';

  @override
  String get recordInterruptedResume => 'Continua';

  @override
  String get recordInterruptedFinish => 'Termina';

  @override
  String get commonApply => 'Applica';

  @override
  String get unitMinutes => 'min';

  @override
  String get clipDurationCustomLabel =>
      'Oppure inserisci il numero di minuti che vuoi';

  @override
  String get supportOpenFailed =>
      'Impossibile aprire — verifica che l\'app sia installata';

  @override
  String get feedbackThanksTitle => 'Grazie!';

  @override
  String get feedbackThanksBody =>
      'Il tuo riscontro aiuta a migliorare ZenPack.';

  @override
  String get feedbackTitle => 'Cosa vuoi dirci?';

  @override
  String get feedbackHint => 'Scrivi il tuo riscontro...';

  @override
  String get feedbackSend => 'Invia riscontro';

  @override
  String get feedbackThanks => 'Grazie per il riscontro';

  @override
  String get accountSectionAbout => 'INFORMAZIONI';

  @override
  String get accountFeedback => 'Inviaci un riscontro';

  @override
  String get accountFeedbackNote =>
      'Condividi la tua opinione per migliorare ZenPack';

  @override
  String get accountRateApp => 'Valuta l\'app';

  @override
  String get accountRateAppNote => 'Sostieni lo sviluppo di ZenPack';

  @override
  String sheetCustomMin(String min, String unit) {
    return 'Inserisci $min $unit o più';
  }

  @override
  String sheetCustomRange(String min, String max, String unit) {
    return 'Inserisci tra $min e $max $unit';
  }

  @override
  String get accountEndQrNote =>
      'Stampalo e attaccalo al tavolo di imballaggio. Scansionarlo durante la registrazione chiude la clip. Lo stesso codice funziona su ogni dispositivo.';

  @override
  String get languageChangeScopeNote =>
      'Ogni etichetta, notifica e fascicolo\npassa alla lingua che scegli.';

  @override
  String get manualEntryEmptyError =>
      'Inserisci un codice di tracciamento prima di registrare';

  @override
  String get appUpdateTitle => 'È disponibile una nuova versione';

  @override
  String get appUpdateMessage =>
      'Aggiorna ZenPack per le ultime correzioni e novità.';

  @override
  String get appUpdateNow => 'Aggiorna';

  @override
  String get appUpdateLater => 'Più tardi';

  @override
  String get quotaVideosThisMonth => 'Video questo mese';

  @override
  String get quotaSubtitleVideos =>
      'Tieni d\'occhio quanti video hai registrato questo mese';

  @override
  String get quotaUpgrade => 'Passa a un piano superiore';

  @override
  String get quotaBlockedTitle => 'Quota video esaurita';

  @override
  String get quotaBlockedNote =>
      'La registrazione funziona ancora, ma le clip non possono ancora caricarsi — sono su questo telefono, senza protezione. Si caricheranno da sole appena la quota verrà alzata.';

  @override
  String get quotaBlockedOwnerNote =>
      'Il limite di questo negozio è impostato dal titolare dell’account: chiedigli di aumentarlo. Un piano che acquisti vale solo per il tuo account.';

  @override
  String get quotaTopupCredits => 'Ricarica crediti';

  @override
  String get quotaOverCap => 'Oltre la quota del piano';

  @override
  String quotaBlockAt(int n) {
    return 'Nuove registrazioni bloccate a $n video';
  }

  @override
  String get quotaResetMonthly =>
      'Si azzera all\'inizio del mese prossimo; nulla viene riportato';

  @override
  String get storageOwnTitle => 'Il tuo archivio';

  @override
  String storageOwnPending(int count) {
    return '$count video in attesa di essere spinti nel tuo archivio';
  }

  @override
  String storageOwnProblem(int count) {
    return '$count video nel tuo archivio hanno problemi';
  }

  @override
  String get quotaExhaustedWarn =>
      'Non disinstallare l\'app e non cancellarne i dati finché non sono stati caricati.';

  @override
  String quotaStrandedTitle(int count) {
    return '$count video in attesa su questo telefono';
  }

  @override
  String get quotaStrandedNote =>
      'Questi video esistono solo su questo telefono. Perderlo, disinstallare l\'app o cancellarne i dati li fa sparire.';

  @override
  String get storageTitle => 'Archivio video';

  @override
  String get storageSave => 'Salva la scelta di archiviazione';

  @override
  String get storageSystemName => 'Archivio di sistema';

  @override
  String get storageS3Name => 'Il tuo archivio (S3)';

  @override
  String get storageDriveName => 'Il tuo Google Drive';

  @override
  String get storageSystemDesc =>
      'L\'impostazione predefinita; niente da configurare. È l\'unico posto dove tutti gli impegni sulla prova restano validi.';

  @override
  String get storageOwnDesc =>
      'I nuovi video vanno direttamente nel tuo archivio. I più vecchi restano dove sono fino alla fine della conservazione.';

  @override
  String get storageNoPresign =>
      'Questo archivio non può firmare i link di download, quindi i video devono passare dal server — chi apre il tuo link lo troverà più lento.';

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
      'Questo archivio non ha il blocco degli oggetti. Non puoi promettere a una piattaforma che la prova sia incancellabile.';

  @override
  String get storageNotInPlan =>
      'Il tuo piano non include ancora l\'archivio personale. Passa a un piano superiore sul web per usarlo.';

  @override
  String get storageHealthTitle => 'Salute dell\'archivio';

  @override
  String get storageHealthTotal => 'Video totali';

  @override
  String get storageHealthIntact => 'Integri';

  @override
  String get storageHealthUnreachable => 'Irraggiungibili';

  @override
  String get storageHealthMismatched => 'Non corrispondenti al sigillo';

  @override
  String get storageHealthPendingRelay => 'In attesa nell\'area di transito';

  @override
  String get storageProblemsNote =>
      'Alcuni video hanno problemi nel tuo archivio. Controlla i permessi di accesso lato provider.';

  @override
  String get storageTest => 'Riprova la connessione';

  @override
  String get storageInUse => 'In uso';

  @override
  String storageLastCheckAt(String time) {
    return 'Ultimo controllo: $time';
  }

  @override
  String get storageNeverChecked => 'Mai controllato.';

  @override
  String storageDriveCurrentAccount(String email) {
    return 'Currently connected: $email. Sign in with that address to keep the same Drive, or pick another to switch.';
  }

  @override
  String get storageDriveAccount => 'Account Drive';

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
  String get storageDisconnect => 'Smetti di usare l\'archivio personale';

  @override
  String get storageDisconnectConfirm =>
      'I video registrati d\'ora in poi vanno nell\'archivio di sistema. I più vecchi restano nel tuo e il sistema perde la strada per raggiungerli.';

  @override
  String get storageConnectS3 => 'Collega archivio S3';

  @override
  String get storageConnectDrive => 'Collega Google Drive';

  @override
  String get storageConnectHint =>
      'Concedi lettura/scrittura/eliminazione solo sul prefisso qui sotto — non serve alcun permesso sull\'intero bucket.';

  @override
  String get storageConnectSubmit => 'Prova e salva';

  @override
  String get storageFieldEndpoint => 'Endpoint';

  @override
  String get storageFieldBucket => 'Bucket';

  @override
  String get storageFieldAccessKey => 'Access key ID';

  @override
  String get storageFieldSecretKey => 'Secret access key';

  @override
  String get storageFieldRegion => 'Regione';

  @override
  String get storageFieldPrefix => 'Prefisso';

  @override
  String get storageFieldPrefixHint =>
      'Sottocartella dentro il bucket. Lascia il valore predefinito se non sei sicuro.';

  @override
  String get storageDriveFailed =>
      'Could not connect Google Drive: the server\'s connection to Google is not configured yet. That is system-side setup, not a permission the app can ask you for — tell your technical contact.';

  @override
  String get storageConnected => 'Archivio personale collegato.';

  @override
  String get storageDisconnected => 'Archivio personale scollegato.';

  @override
  String get storageSwitchedToSystem =>
      'Saved. New videos go to Cloud Zenpack; your own-storage account is kept.';

  @override
  String get storageResumed => 'Saved. Using your connected storage again.';

  @override
  String get storageTestOk => 'La connessione è sana.';

  @override
  String get storageServerOutdated =>
      'The server does not support switching storage yet. Your videos stay where they are — tell your admin to update the server.';

  @override
  String get storageOwnerOnly =>
      'Solo il titolare del negozio può cambiare l\'archivio.';

  @override
  String get dangerZone => 'Zona pericolosa';

  @override
  String get shopDelete => 'Elimina negozio';

  @override
  String get shopDeleteDesc =>
      'Elimina definitivamente ordini, prove, file archiviati e membri. Non è reversibile.';

  @override
  String get shopDeleteConfirmTitle => 'Eliminare questo negozio?';

  @override
  String shopDeleteConfirmBody(int orders, int videos, int members) {
    return '$orders ordini · $videos video · $members membri saranno eliminati definitivamente.';
  }

  @override
  String shopDeleteOpenDossiers(int n) {
    return '$n fascicoli di reclamo sono ancora aperti. I link già inviati alle piattaforme muoiono nel momento in cui elimini.';
  }

  @override
  String get shopDeleteForce => 'Elimina comunque';

  @override
  String get shopDeleteFailed => 'Impossibile eliminare il negozio.';

  @override
  String get claimsCreatedLocalOnly =>
      'Fascicolo salvato su questo telefono. Non è stato possibile caricarlo, quindi non c\'è ancora un link di condivisione — riaprilo quando sarai online.';

  @override
  String get claimsLinkCopied =>
      'Link del fascicolo copiato. Incollalo nel canale di reclamo della piattaforma.';

  @override
  String get shopRenameTitle => 'Rinomina negozio';

  @override
  String get shopRenameHint => 'Nome del negozio';

  @override
  String get shopRenamed => 'Negozio rinominato';

  @override
  String get commonSave => 'Salva';

  @override
  String get inviteJoinRow => 'Ho un invito';

  @override
  String inviteJoinedShop(String shop) {
    return 'Sei entrato in $shop';
  }

  @override
  String inviteAlreadyJoined(String shop) {
    return 'Sei già in $shop';
  }

  @override
  String get inviteBadLink =>
      'Quel link non è valido. Incolla il link intero dall\'e-mail.';

  @override
  String get inviteNotFound => 'L\'invito non esiste o è stato revocato';

  @override
  String get inviteTaken => 'Qualcun altro ha già accettato questo invito';

  @override
  String get inviteExpired =>
      'L\'invito è scaduto. Chiedi al titolare del negozio di inviarlo di nuovo.';

  @override
  String get inviteQrRow => 'Codice QR';

  @override
  String get inviteQrTitle => 'Codice di invito al negozio';

  @override
  String get inviteQrNote =>
      'Mostra questa schermata alla persona che vuoi invitare. Il codice è monouso: cambia appena qualcuno entra.';

  @override
  String get inviteScanTitle => 'Scansiona il codice di invito';

  @override
  String get inviteScanDetail =>
      'Chiedi al titolare del negozio di mostrare il codice QR di invito, poi scansionalo qui.';

  @override
  String get commonShare => 'Condividi';

  @override
  String get inviteQrSaved => 'Codice QR salvato nella tua galleria';

  @override
  String get inviteQrSaveFailed => 'Impossibile salvare il codice QR';

  @override
  String get voiceRecordingStarted => 'Registrazione avviata';

  @override
  String get voiceRecordingStopped => 'Registrazione interrotta';

  @override
  String get voiceWrongCode => 'Codice errato';

  @override
  String get voiceCapSoon => 'Il video sta per chiudersi';

  @override
  String voiceCapNear(int minutes) {
    return 'Limite di $minutes minuti quasi raggiunto, il video si chiuderà da solo';
  }

  @override
  String get voiceInterrupted => 'La registrazione è stata interrotta';

  @override
  String get videoTypePacking => 'Imballaggio';

  @override
  String get videoTypeCarrier => 'Consegna al corriere';

  @override
  String get videoTypeReturn => 'Reso';

  @override
  String get storageIntro =>
      'Dove vivono i video del negozio. Ovunque siano, il registro del sigillo resta nel sistema — cambiare archivio non indebolisce mai la prova.';

  @override
  String get storageS3Title => 'Il tuo cloud (compatibile S3)';

  @override
  String get storageS3Desc =>
      'AWS S3, Cloudflare R2, MinIO, Wasabi… I video stanno nel tuo bucket e la loro durata è responsabilità tua.';

  @override
  String get storageDriveTitle => 'Google Drive';

  @override
  String get storageDriveDesc =>
      'Colleghi con una sola autorizzazione, nessuna chiave da incollare. Un account gratuito ha solo 15 GB condivisi con Gmail.';

  @override
  String get storageNeedProPlan =>
      'Collegare il proprio archivio richiede il piano Professional o superiore.';

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
  String get authSignInPhone => 'Accedi con numero di telefono';

  @override
  String get phoneLoginTitle => 'Accedi con numero di telefono';

  @override
  String get phoneLoginSubtitle =>
      'Inserisci il numero, invieremo un codice a 6 cifre.';

  @override
  String get phoneLoginNumberLabel => 'Numero di telefono';

  @override
  String get phoneLoginNumberHint => '3xx xxx xxxx';

  @override
  String get phoneLoginInvalid => 'Numero di telefono non valido';

  @override
  String get phoneLoginViaZalo => 'Invia il codice via Zalo';

  @override
  String get phoneLoginViaSms => 'Invia il codice via SMS';

  @override
  String get otpTitle => 'Inserisci il codice';

  @override
  String otpSentTo(String phone) {
    return 'Abbiamo inviato un codice a 6 cifre a $phone.';
  }

  @override
  String get otpLabel => 'Codice di verifica';

  @override
  String get otpConfirm => 'Conferma';

  @override
  String get otpResend => 'Invia di nuovo il codice';

  @override
  String otpResendIn(int seconds) {
    return 'Reinvia tra $seconds s';
  }

  @override
  String get otpChangePhone => 'Usa un altro numero';

  @override
  String get otpWrong => 'Codice errato. Controlla di nuovo il messaggio.';

  @override
  String get otpExpired => 'Il codice è scaduto. Richiedine uno nuovo.';

  @override
  String get otpUsedUp =>
      'Questo codice non è più utilizzabile. Richiedine uno nuovo.';

  @override
  String get otpTooSoon => 'Appena inviato. Attendi un momento.';

  @override
  String get otpRateLimited => 'Troppe richieste. Riprova tra qualche minuto.';

  @override
  String get otpSendFailed =>
      'Impossibile inviare il codice. Prova l’altro canale.';

  @override
  String get otpNotConfigured =>
      'L’invio del codice non è disponibile. Usa un altro metodo.';

  @override
  String otpFromOa(String oa) {
    return 'Il messaggio arriva dall’account ufficiale Zalo $oa — cerca quel nome.';
  }

  @override
  String get hdDaHieu => 'Ho capito';

  @override
  String get hdDong => 'Chiudi i suggerimenti';

  @override
  String get hdXemLai => 'Mostra di nuovo i suggerimenti';

  @override
  String get hdDaMoLai =>
      'I suggerimenti torneranno quando entrerai in ogni schermata.';

  @override
  String get hdHomeTitle => 'Schermata iniziale';

  @override
  String get hdHome1 =>
      'Uno sguardo rapido a ordini, spazio usato e cosa serve oggi.';

  @override
  String get hdHome2 =>
      'Ogni scheda di stato porta subito agli ordini in quello stato.';

  @override
  String get hdHome3 => 'Puoi riaprire questi suggerimenti quando vuoi.';

  @override
  String get hdRecordTitle => 'Schermata di registrazione';

  @override
  String get hdRecord1 =>
      'Scegli la fotocamera merce e quella scontrino nelle Impostazioni prima di registrare.';

  @override
  String get hdRecord2 =>
      'Scansiona il codice e registra: il video si lega a quell’ordine.';

  @override
  String get hdRecord3 =>
      'Le telecamere IP riprendono solo la merce, mai come fotocamera scontrino.';

  @override
  String get hdOrderTitle => 'Dettaglio ordine';

  @override
  String get hdOrder1 =>
      'Tutti i clip e le foto di un codice di spedizione, i più recenti in alto.';

  @override
  String get hdOrder2 =>
      'Un clip sigillato è la versione definitiva, utile per un reclamo.';

  @override
  String get hdOrder3 =>
      'Eliminare qui lo nasconde solo dalla tua lista; l’originale resta.';

  @override
  String get hdClaimsTitle => 'Fascicoli di reclamo';

  @override
  String get hdClaims1 =>
      'Raccogli le prove di più ordini in un fascicolo per il marketplace.';

  @override
  String get hdClaims2 =>
      'Ogni fascicolo ha il suo link; chi lo riceve non ha bisogno di un account.';

  @override
  String get hdClaims3 =>
      'I video del fascicolo restano altri 15 giorni dopo la chiusura.';

  @override
  String get hdClaimDetailTitle => 'Dettaglio fascicolo';

  @override
  String get hdClaimDetail1 =>
      'Aggiungi o togli ordini prima di inviare il fascicolo.';

  @override
  String get hdClaimDetail2 =>
      'Copia il link del fascicolo da incollare nel reclamo.';

  @override
  String get hdClaimDetail3 =>
      'Chiudilo quando hai finito: i video durano ancora 15 giorni.';

  @override
  String get hdShopsTitle => 'Negozi';

  @override
  String get hdShops1 =>
      'Ogni negozio ha il proprio spazio, il proprio piano e il proprio personale.';

  @override
  String get hdShops2 =>
      'Invita il personale e stabilisci cosa può fare ciascuno.';

  @override
  String get hdShops3 => 'Cambia in alto il negozio su cui stai lavorando.';

  @override
  String get hdQuotaTitle => 'Piano';

  @override
  String get hdQuota1 =>
      'Il piano fissa la dimensione dello spazio e per quanto restano i video.';

  @override
  String get hdQuota2 => 'Lo spazio si conta per negozio, non per utente.';

  @override
  String get hdQuota3 =>
      'Vieni avvisato prima che si riempia: nulla viene cancellato in silenzio.';

  @override
  String get hdQueueTitle => 'Coda di caricamento';

  @override
  String get hdQueue1 =>
      'Qui restano i clip già registrati ma non ancora caricati.';

  @override
  String get hdQueue2 =>
      'Con segnale debole lasciali stare: l’app riprova quando torna la rete.';

  @override
  String get hdQueue3 =>
      'Non disinstallare l’app finché ci sono clip in attesa; esistono solo su questo telefono.';

  @override
  String get gtBoQua => 'Salta';

  @override
  String get gtTiep => 'Avanti';

  @override
  String get gtBatDau => 'Inizia ora';

  @override
  String get gt1Title => 'Riprendi mentre imballi';

  @override
  String get gt1Body =>
      'Un video per ordine: cosa conteneva, come è stato imballato, quale etichetta. Registri e hai finito.';

  @override
  String get gt2Title => 'Legato al codice di spedizione';

  @override
  String get gt2Body =>
      'Scansiona l’etichetta e il video si lega da solo a quell’ordine. Poi un codice mostra tutti i suoi clip.';

  @override
  String get gt3Title => 'Prove quando arriva un reclamo';

  @override
  String get gt3Body =>
      'Unisci i clip di più ordini in un fascicolo e invia il link al marketplace. Non serve alcun account.';

  @override
  String get deletePwTitle => 'Inserisci la password';

  @override
  String get deletePwBody =>
      'L’operazione è irreversibile: reinserisci la password prima di eliminare l’account.';

  @override
  String get deletePwOk => 'Conferma';

  @override
  String get hdNoShopTitle => 'Inizia da un negozio';

  @override
  String get hdNoShop1 =>
      'Ogni video e prova appartiene a un negozio, quindi creane uno prima.';

  @override
  String get hdNoShop2 =>
      'Poi scegli i marketplace su cui vendi e invita il tuo personale.';

  @override
  String get hdNoShop3 =>
      'Se ti hanno invitato, usa “Unisciti con un invito” invece di crearne uno.';

  @override
  String get cdNoShopTaoTitle => 'Crea prima un negozio';

  @override
  String get cdNoShopTaoBody =>
      'Ogni video e prova appartiene a un negozio. Tocca qui per crearne uno.';

  @override
  String get cdNoShopMoiTitle => 'Invitato? Inizia qui';

  @override
  String get cdNoShopMoiBody =>
      'Se un titolare ti ha invitato, tocca qui e inserisci il codice invito.';

  @override
  String get cdNoShopTkTitle => 'Il tuo profilo';

  @override
  String get cdNoShopTkBody =>
      'Nome, lingua, metodi di accesso ed eliminazione account sono qui.';

  @override
  String get cdTaoShopTenTitle => 'Dai un nome al negozio';

  @override
  String get cdTaoShopTenBody =>
      'Solo tu e il tuo personale vedete questo nome; distingue i negozi. Modificabile in seguito.';

  @override
  String get cdTaoShopNutTitle => 'Scegli il marketplace e crea';

  @override
  String get cdTaoShopNutBody =>
      'Scegli sopra dove vendi, poi tocca qui. Creato il negozio, puoi registrare.';

  @override
  String get cdHome1T => 'Trova un ordine in fretta';

  @override
  String get cdHome1B =>
      'Digita qui un codice di spedizione per aprire subito le sue prove.';

  @override
  String get cdHome2T => 'Filtra per stato';

  @override
  String get cdHome2B =>
      'Vedi solo gli ordini in caricamento, completati o con errore.';

  @override
  String get cdQueue1T => 'Clip in attesa di invio';

  @override
  String get cdQueue1B =>
      'Segnale debole? I clip restano qui e riprovano al ritorno della rete.';

  @override
  String get cdQueue2T => 'Svuota la coda';

  @override
  String get cdQueue2B =>
      'Rimuove solo i clip non ancora caricati. Vanno persi: il server non ha copia.';

  @override
  String get cdClaims1T => 'Raccogli le prove per il marketplace';

  @override
  String get cdClaims1B =>
      'Più ordini diventano un fascicolo inviato con un solo link.';

  @override
  String get cdRec1T => 'Scansiona il codice';

  @override
  String get cdRec1B =>
      'Metti l’etichetta nel riquadro. L’app la legge e lega il video a quell’ordine.';

  @override
  String get cdOrder1T => 'Prove di questo ordine';

  @override
  String get cdOrder1B =>
      'Tutti i clip e le foto di questo codice, i più recenti in alto.';

  @override
  String get cdClaimD1T => 'Link da inviare al marketplace';

  @override
  String get cdClaimD1B =>
      'Copia questo link nel reclamo. Chi lo riceve non ha bisogno di un account.';

  @override
  String get cdShops1T => 'Cambia negozio';

  @override
  String get cdShops1B =>
      'Ogni negozio ha spazio, piano e personale propri. Tocca per cambiare.';

  @override
  String get cdQuota1T => 'Spazio usato';

  @override
  String get cdQuota1B =>
      'Il piano fissa numero di video e durata. Vieni avvisato prima che si riempia.';

  @override
  String get cdAcc1T => 'Il tuo piano';

  @override
  String get cdAcc1B =>
      'Vedi i video rimasti, per quanto restano, e migliora il piano qui.';

  @override
  String get cdAcc2T => 'Metodi di accesso';

  @override
  String get cdAcc2B =>
      'Aggiungi Google o Apple per entrare più in fretta, senza password.';

  @override
  String get cdShopD1T => 'Tipi di video';

  @override
  String get cdShopD1B =>
      'Dai un nome ai tipi che registri spesso, così li ritrovi facilmente.';

  @override
  String get cdShopD2T => 'Invita il personale';

  @override
  String get cdShopD2B => 'Invita persone e stabilisci cosa può fare ciascuna.';

  @override
  String get cdRec2T => 'Etichetta illeggibile? Scrivila';

  @override
  String get cdRec2B =>
      'Se è macchiata o strappata, tocca qui per digitare il codice.';

  @override
  String get notifRow => 'Notifiche';

  @override
  String get notifOn => 'Attive';

  @override
  String get notifOff => 'Disattive';

  @override
  String get notifAskTitle => 'Attivare le notifiche?';

  @override
  String get notifAskBody =>
      'ZenPack ti avviserà quando il piano sta per scadere, quando i video stanno per essere eliminati, quando qualcuno entra nel tuo negozio — e ti ricorderà di registrare durante l’imballaggio.';

  @override
  String get notifAskYes => 'Attiva';

  @override
  String get notifAskNo => 'Più tardi';

  @override
  String get notifDenied =>
      'In precedenza hai rifiutato. Apri le Impostazioni del dispositivo per riattivarle.';

  @override
  String get themeRow => 'Aspetto';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get tzRow => 'Fuso orario';

  @override
  String get tzAuto => 'Dispositivo';

  @override
  String get tzNote => 'Cambia solo gli orari mostrati sullo schermo.';

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
  String get detailSignature => 'Firma digitale';

  @override
  String sealSignature(String key) {
    return 'Firma ZenPack · chiave $key';
  }

  @override
  String get sealCopyVerifyLink => 'Copia link di verifica';

  @override
  String get sealVerifyLinkTitle => 'Link di verifica';

  @override
  String get claimSignedLabel => 'Firmati';

  @override
  String claimSignedCount(int sealed, int videos, int anchored) {
    return '$sealed/$videos video · $anchored con prova indipendente';
  }

  @override
  String claimUnsignedHint(int n) {
    return '$n video senza timbro — il marketplace potrebbe rifiutarli. Il fascicolo può comunque essere inviato; i video timbrati continuano a provarsi da soli.';
  }

  @override
  String get claimsSubtitle =>
      'Segui e gestisci i fascicoli di reclamo degli ordini';

  @override
  String get claimsEmptyTitle => 'Nessun fascicolo';

  @override
  String get claimsEmptyBody =>
      'Tocca il più in alto e scegli le prove dell\'ordine contestato per creare un fascicolo.';

  @override
  String get claimsEmptyTip =>
      'Consiglio: foto e video nitidi aiutano il marketplace a decidere prima.';

  @override
  String get timelineEnd => 'Nessun\'altra attività';

  @override
  String timelineEntryCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n voci',
      one: '1 voce',
    );
    return '$_temp0';
  }

  @override
  String get attachCodeToOrderHint =>
      'Aggiungi un codice reso o un secondo codice di spedizione a questo ordine';

  @override
  String get attachPhotoToOrderHint =>
      'Scegli una foto dal dispositivo da tenere con questo ordine';

  @override
  String get shopDetailClipLengthHint =>
      'Durata massima di registrazione per video';

  @override
  String get shopDetailImageSizeHint => 'Dimensione massima per foto';

  @override
  String get storageRowHint => 'Dove sono conservati video e foto';

  @override
  String get capRowHint => 'Opzioni fotocamera e schermo';

  @override
  String get inviteQrLabel => 'Codice invito';

  @override
  String get orderStatusRecorded => 'Registrato';

  @override
  String get orderStatusNone => 'Non registrato';

  @override
  String get accountTagline =>
      'Gestisci con facilità, vendi con fiducia — ZenPack';

  @override
  String get videoTypeHintPacking => 'Filma l\'imballaggio';

  @override
  String get videoTypeHintCarrier => 'Filma la consegna al corriere';

  @override
  String get videoTypeHintReturn => 'Filma il reso all\'arrivo';

  @override
  String get statPendingSub => 'In coda';

  @override
  String shopPulseToday(int orders, int videos) {
    String _temp0 = intl.Intl.pluralLogic(
      orders,
      locale: localeName,
      other: '$orders ordini',
      one: '1 ordine',
    );
    String _temp1 = intl.Intl.pluralLogic(
      videos,
      locale: localeName,
      other: '$videos video',
      one: '1 video',
    );
    return 'Oggi · $_temp0 · $_temp1';
  }
}

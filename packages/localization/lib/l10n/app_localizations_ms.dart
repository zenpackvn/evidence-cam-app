// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get bundleBackendPending => 'Menunggu endpoint backend untuk ini';

  @override
  String get bundleCreate => 'Cipta';

  @override
  String get bundleCreateClaim => 'Cipta fail tuntutan';

  @override
  String get accountClaims => 'Fail tuntutan';

  @override
  String get claimsTitle => 'Fail tuntutan';

  @override
  String get claimsLocalOnlyNote =>
      'Senarai ini disimpan dalam peranti ini. Menyahpasang apl atau bertukar peranti akan menghilangkannya.';

  @override
  String get claimsEmpty =>
      'Belum ada fail. Buka tab Pesanan, ketik butang tambah dan pilih bukti untuk membinanya.';

  @override
  String claimsSummary(int orders, int evidence) {
    return '$orders pesanan · $evidence bukti';
  }

  @override
  String claimsEvidenceOnly(int evidence) {
    return '$evidence bukti';
  }

  @override
  String get claimsCopied => 'Kandungan fail disalin';

  @override
  String get claimsCreated => 'Fail tuntutan dicipta';

  @override
  String get claimsPickNothing => 'Tiada bukti dipilih';

  @override
  String get claimsDelete => 'Padam fail';

  @override
  String get claimsDeleteConfirm =>
      'Padam fail ini? Bukti pada pesanan itu sendiri tidak terjejas.';

  @override
  String get claimsDeleteConfirmLink =>
      'Padam fail ini? Pautan awamnya mati serta-merta — sesiapa yang sudah anda hantar akan melihat halaman kosong. Bukti pada pesanan itu sendiri tidak terjejas.';

  @override
  String get claimsRevokeFailed =>
      'Pautan tidak dapat dibatalkan, jadi fail dibiarkan seperti sedia ada. Pautan masih terbuka — cuba lagi dengan sambungan lebih baik, atau minta pemilik kedai membatalkannya.';

  @override
  String get claimsDeleted => 'Fail dipadam';

  @override
  String get claimsPhotoAdded =>
      'Gambar ditambah ke fail dan dibaris gilirkan ke pesanan';

  @override
  String get claimsAddedLater => 'ditambah kemudian';

  @override
  String get claimsCreateTitle => 'Fail tuntutan baharu';

  @override
  String get claimsCreateSearchHint => 'Taip atau imbas nombor penjejakan';

  @override
  String get claimsCreateNameHint => 'cth. Tuntutan pemulangan 12/08';

  @override
  String get claimsCreateNameLabel => 'Nama fail';

  @override
  String get claimInfoTitle => 'Butiran fail';

  @override
  String get claimTrackingLabel => 'Kod penjejakan';

  @override
  String get claimShopLabel => 'Kedai';

  @override
  String get claimChannelLabel => 'Saluran jualan';

  @override
  String get claimOrderCreatedAt => 'Tarikh pesanan';

  @override
  String get claimEvidenceLabel => 'Bukti';

  @override
  String claimEvidenceCount(int videos, int photos) {
    return '$videos video · $photos foto';
  }

  @override
  String get claimCreatedAtLabel => 'Fail dicipta';

  @override
  String get claimCopyLink => 'Copy link';

  @override
  String get claimsRevokeNoLink =>
      'This dossier is not on the server yet, so there is no link to revoke.';

  @override
  String get claimPageFailed =>
      'Could not open the dossier page. Check your connection and try again.';

  @override
  String get claimLinkLabel => 'Pautan fail';

  @override
  String get claimLinkHint =>
      'Sesiapa yang ada pautan boleh melihatnya, tanpa log masuk. Ia kekal aktif sehingga anda batalkan.';

  @override
  String get claimRevokedBadge => 'Dibatalkan';

  @override
  String get claimRevokedHint =>
      'Pautan sudah mati. Data kekal utuh — cipta fail baharu untuk berkongsi semula.';

  @override
  String get claimRevoke => 'Batalkan';

  @override
  String get claimUntitled => 'Fail tanpa nama';

  @override
  String get claimRevokeConfirmTitle => 'Batalkan fail ini?';

  @override
  String get claimRevokeConfirmBody =>
      'Pautan mati serta-merta bagi sesiapa yang memegangnya, termasuk pasaran. Data dan pautan setiap pesanan tidak terjejas.';

  @override
  String get claimRevoked => 'Fail dibatalkan. Pautan tidak lagi boleh dibuka.';

  @override
  String get claimRevokeFailed =>
      'Gagal membatalkan. Cuba lagi apabila dalam talian.';

  @override
  String get claimNotUploaded =>
      'Fail ini belum dimuat naik jadi belum ada pautan. Buka semula apabila dalam talian.';

  @override
  String get claimDetailLoadFailed =>
      'Gagal memuatkan fail. Semak sambungan dan buka semula.';

  @override
  String get claimsCreateStart =>
      'Taip nombor penjejakan, atau ketik imbas, untuk mencari pesanan yang dituntut.';

  @override
  String get claimsCreateNoOrder =>
      'Tiada pesanan dengan nombor penjejakan itu dalam kedai yang dipilih.';

  @override
  String get claimsRemoveItemTitle => 'Keluarkan dari fail';

  @override
  String get claimsRemoveItemConfirm =>
      'Keluarkan bukti ini dari fail tuntutan? Video/gambar pada pesanan itu sendiri tidak terjejas.';

  @override
  String get claimsItemRemoved => 'Dikeluarkan dari fail';

  @override
  String get claimsItemAdded => 'Ditambah ke fail';

  @override
  String get commonRemove => 'Keluarkan';

  @override
  String get commonDelete => 'Padam';

  @override
  String get settingDefaultSuffix => 'lalai';

  @override
  String get shopDetailClipLength => 'Panjang video';

  @override
  String get shopDeleteTitle => 'Padam kedai';

  @override
  String get shopDeleteConfirm =>
      'Padam kedai ini? Semua pesanan, video dan gambar ikut dipadam, dan tidak boleh dipulihkan.';

  @override
  String get shopDeleteBlockedTitle => 'Kedai masih ada ahli';

  @override
  String shopDeleteBlockedBody(int count) {
    return 'Keluarkan semua ahli sebelum memadam kedai. Masih ada $count.';
  }

  @override
  String get shopDeleted => 'Kedai dipadam.';

  @override
  String bundleSelected(int count) {
    return '$count dipilih';
  }

  @override
  String get bundleUploadDrive => 'Muat naik ke Drive';

  @override
  String get commonCancel => 'Batal';

  @override
  String get commonRetry => 'Cuba lagi';

  @override
  String get commonClose => 'Tutup';

  @override
  String get toastChangeLanguage => 'Tukar bahasa';

  @override
  String get toastTermsPolicy => 'Terma & Dasar';

  @override
  String get toastInfoSaved => 'Maklumat disimpan';

  @override
  String get toastPasswordCreated => 'Kata laluan dicipta';

  @override
  String get toastPasswordChanged => 'Kata laluan ditukar';

  @override
  String get toastPendingDossierConfirm =>
      'Anda masih ada fail tuntutan terbuka, sila sahkan sekali lagi';

  @override
  String get toastCopiedShareLink => 'Pautan kongsi disalin';

  @override
  String get toastShareFailed => 'Tidak dapat berkongsi, cuba lagi nanti';

  @override
  String get toastDownloadingVideo => 'Memuat turun video';

  @override
  String get toastVideoDownloadedCopied =>
      'Video dimuat turun dan lokasinya disalin';

  @override
  String get toastVideoSavedToGallery =>
      'Video disimpan ke galeri peranti anda';

  @override
  String get toastVideoDownloadFailed =>
      'Tidak dapat memuat turun video, cuba lagi nanti';

  @override
  String get toastVideoDeleteUnavailable => 'Video ini tidak boleh dipadam';

  @override
  String get toastDownloadingPhoto => 'Memuat turun gambar';

  @override
  String get toastPhotoSavedToGallery =>
      'Gambar disimpan ke galeri peranti anda';

  @override
  String get toastPhotoDownloadedCopied =>
      'Gambar dimuat turun dan lokasinya disalin';

  @override
  String get toastPhotoDownloadFailed =>
      'Tidak dapat memuat turun gambar, cuba lagi nanti';

  @override
  String get toastPhotoNoDownloadLink => 'Gambar belum ada pautan muat turun';

  @override
  String get toastPhotoQueued =>
      'Gambar dilampirkan — masuk baris gilir muat naik';

  @override
  String imageOverFixedCap(String megabytes, String limit) {
    return 'Gambar bersaiz $megabytes MB — melebihi had $limit MB, tidak dilampirkan. Pilih imej lebih kecil.';
  }

  @override
  String get toastInvitePending => 'Menunggu jemputan kedai';

  @override
  String get toastInviteSent => 'Jemputan dihantar';

  @override
  String get toastMemberAdded => 'Ahli ditambah';

  @override
  String get toastVideoPlayFailed => 'Tidak dapat memainkan video';

  @override
  String get toastShopCreated => 'Kedai baharu dicipta';

  @override
  String get toastVideoQueued => 'Video disimpan — masuk baris gilir muat naik';

  @override
  String get toastVideoNoPlayLink => 'Video belum ada pautan main balik';

  @override
  String get toastVideoNoDownloadLink => 'Video belum ada pautan muat turun';

  @override
  String get toastVideoDeleted => 'Video dipadam';

  @override
  String get toastVideoTypeSaved => 'Jenis video disimpan';

  @override
  String get toastVideoTypeDeleted => 'Jenis video dipadam';

  @override
  String get toastNoVideoTypeToDelete => 'Tiada jenis video untuk dipadam';

  @override
  String get toastNoMemberToUpdate => 'Tiada ahli untuk dikemas kini';

  @override
  String get toastMemberRemoved =>
      'Dikeluarkan dari kedai (video yang dirakam tetap selesai dimuat naik)';

  @override
  String get toastInviteRevoked =>
      'Jemputan dipadam — pautan dalam e-mel tidak lagi berfungsi';

  @override
  String copiedLabel(String label) {
    return '$label disalin';
  }

  @override
  String get labelTrackingCode => 'nombor penjejakan';

  @override
  String resolutionChanged(String value) {
    return 'Resolusi: $value';
  }

  @override
  String get accountNoName => 'Belum ada nama';

  @override
  String get accountNoShop => 'Tiada kedai dipilih';

  @override
  String get accountCreatePassword => 'Cipta kata laluan';

  @override
  String get accountChangePassword => 'Tukar kata laluan';

  @override
  String accountLinkedMethods(int count) {
    return '$count dipautkan';
  }

  @override
  String get roleOwner => 'Pemilik';

  @override
  String get roleStaff => 'Kakitangan';

  @override
  String memberInviteSent(String role) {
    return '$role · jemputan dihantar';
  }

  @override
  String memberInviteAccepted(String role) {
    return '$role · jemputan diterima';
  }

  @override
  String get planFree => 'Percuma';

  @override
  String get planBasic => 'Basic';

  @override
  String get planSaver => 'Saver';

  @override
  String get planPremium => 'Premium';

  @override
  String get planPro => 'Pro';

  @override
  String get planEnterprise => 'Perusahaan';

  @override
  String get roleOther => 'Lain-lain';

  @override
  String get roleUnknown => 'Tidak diketahui';

  @override
  String get memberFallbackName => 'Ahli';

  @override
  String get uploadStatusDone => 'Dimuat naik';

  @override
  String get uploadStatusPending => 'Menunggu dimuat naik';

  @override
  String get uploadStatusQuotaHold => 'Ditahan (kuota)';

  @override
  String get uploadStatusDeleted => 'Dipadam';

  @override
  String get uploadStatusError => 'Ralat pemprosesan di pelayan';

  @override
  String get uploadStatusExpired => 'Tempoh simpanan tamat';

  @override
  String expiredOnDate(String date) {
    return 'Tempoh simpanan tamat pada $date';
  }

  @override
  String get kindPhoto => 'Gambar dilampirkan';

  @override
  String get kindVideo => 'Video';

  @override
  String get recordedByFallback => 'Akaun semasa';

  @override
  String get deviceUnknown => 'Peranti tidak dikenali';

  @override
  String get orderNoEvidence => 'Belum ada bukti';

  @override
  String get timelineEmpty => 'Penghantaran ini belum ada video atau gambar';

  @override
  String get errorGenericRetry => 'Ada masalah berlaku, sila cuba lagi.';

  @override
  String get errorPendingDossier =>
      'Anda masih ada fail tuntutan terbuka, selesaikannya dahulu sebelum meneruskan.';

  @override
  String get errorSessionExpired =>
      'Sesi anda telah tamat, sila log masuk semula.';

  @override
  String get errorNoNetwork => 'Tiada sambungan rangkaian, sila cuba lagi.';

  @override
  String get errorNoPermission => 'Anda tiada kebenaran untuk tindakan ini.';

  @override
  String get errorServerBusy => 'Sistem sedang sibuk, sila cuba lagi nanti.';

  @override
  String get errorSessionInvalid => 'Sesi tidak sah, sila log masuk semula.';

  @override
  String get errorVideoTypeInUse =>
      'Tidak boleh memadam jenis video yang sudah ada video. Semak dahulu video yang menggunakan jenis ini.';

  @override
  String get errorBuiltinVideoTypeLocked =>
      '3 jenis video terbina dalam tidak boleh diubah atau dipadam.';

  @override
  String get errorVideoTypeNameExists =>
      'Nama jenis video itu sudah wujud dalam kedai.';

  @override
  String get errorCheckNetwork => 'Semak rangkaian anda atau cuba lagi nanti.';

  @override
  String get errorLoadShopList => 'Tidak dapat memuatkan senarai kedai';

  @override
  String get errorLoadShopMgmt => 'Tidak dapat memuatkan pengurusan kedai';

  @override
  String get errorLoadShopDetail => 'Tidak dapat memuatkan butiran kedai';

  @override
  String get errorLoadMembers => 'Tidak dapat memuatkan senarai ahli';

  @override
  String get membersRestricted =>
      'Hanya pemilik kedai boleh melihat senarai ahli';

  @override
  String get errorLoadOrders => 'Tidak dapat memuatkan pesanan';

  @override
  String get errorLoadOrderDetail => 'Tidak dapat memuatkan butiran pesanan';

  @override
  String get noShopSelectedOrdersDetail =>
      'Sila pilih kedai sebelum melihat pesanan.';

  @override
  String get noShopSelectedRecordDetail => 'Sila pilih kedai sebelum merakam.';

  @override
  String get noShopSelectedManageDetail => 'Sila pilih kedai untuk diurus.';

  @override
  String get noOrdersTitle => 'Belum ada pesanan';

  @override
  String get noOrdersDetail => 'Sila pilih satu pesanan dari senarai.';

  @override
  String get noVideoDataTitle => 'Tiada data video';

  @override
  String get cannotOpenVideoTitle => 'Tidak dapat membuka video';

  @override
  String get cannotOpenVideoDetail => 'Video belum ada pautan main balik.';

  @override
  String get createOrderDialogTitle => 'Cipta pesanan baharu?';

  @override
  String createOrderDialogBody(String code) {
    return '$code tidak sepadan dengan mana-mana nombor penjejakan dalam kedai ini. Semak semula nombor itu atau sahkan untuk mencipta pesanan baharu.';
  }

  @override
  String get createOrderConfirm => 'Cipta pesanan baharu';

  @override
  String get statOrdersToday => 'Pesanan';

  @override
  String get statVideosRecorded => 'Video dirakam';

  @override
  String get statPendingUpload => 'Menunggu muat naik';

  @override
  String get accountPlanQuota => 'Storan';

  @override
  String get accountChangePlan => 'Tukar pelan';

  @override
  String get accountSectionApp => 'PELAN & APL';

  @override
  String get accountLanguage => 'Bahasa';

  @override
  String get accountSectionSecurity => 'KESELAMATAN & LOG MASUK';

  @override
  String get accountLoginMethods => 'Cara log masuk';

  @override
  String get accountSignOut => 'Log keluar';

  @override
  String get accountSignOutConfirmTitle => 'Log keluar?';

  @override
  String get accountSignOutConfirmMessage =>
      'Anda perlu log masuk semula untuk terus menggunakan apl.';

  @override
  String get accountDeleteAccount => 'Padam akaun';

  @override
  String accountVersion(String version) {
    return 'Versi $version';
  }

  @override
  String get accountShopMgmtHint =>
      'Urus kedai/ahli: ketik kembali di pengepala untuk kembali ke lapisan Kedai';

  @override
  String get accountInfoTitle => 'Maklumat akaun';

  @override
  String get accountFullName => 'Nama penuh';

  @override
  String get accountFullNameHint => 'Masukkan nama penuh anda';

  @override
  String get accountFullNameRequired => 'Sila masukkan nama penuh anda';

  @override
  String get phoneOptionalLabel => 'Nombor telefon (pilihan)';

  @override
  String get phoneOptionalHint => 'Pilihan — untuk sokongan akaun sahaja';

  @override
  String get phoneInvalid => 'Nombor telefon tidak sah';

  @override
  String get accountSaveChanges => 'Simpan perubahan';

  @override
  String get accountEmailLockedHint =>
      'E-mel untuk log masuk — tidak boleh ditukar';

  @override
  String get commonContinue => 'Teruskan';

  @override
  String get commonLater => 'Nanti';

  @override
  String get cameraPermissionRationaleTitle => 'Perlukan akses kamera';

  @override
  String get cameraPermissionRationaleBody =>
      'ZenPack memerlukan kamera untuk merakam video bukti pembungkusan pesanan anda.';

  @override
  String get cameraPermissionDeniedTitle => 'Belum boleh merakam';

  @override
  String get cameraPermissionDeniedBody =>
      'ZenPack tidak boleh merakam video kerana akses kamera belum diberikan. Anda masih boleh melihat, mencari dan mengurus pesanan.';

  @override
  String get cameraPermissionOpenSettings => 'Buka Tetapan';

  @override
  String get languageNameVietnamese => 'Vietnam';

  @override
  String get languageNameEnglish => 'Inggeris';

  @override
  String get languageChangeAppliesNote =>
      'Perubahan berkuat kuasa serta-merta di seluruh apl';

  @override
  String get linkLinked => 'Dipautkan';

  @override
  String get linkNotLinked => 'Belum dipautkan';

  @override
  String get loginMethodsEmailNote =>
      'E-mel ialah pengenal akaun anda — ia tidak boleh dibuang. Pautkan Google/Apple untuk log masuk pantas dengan akaun yang sama.';

  @override
  String get loginMethodIdentity => 'Pengenal';

  @override
  String get linkAction => 'Pautkan';

  @override
  String get linkUnlink => 'Nyahpaut';

  @override
  String get quotaScreenTitle => 'Laporan & Kuota';

  @override
  String get quotaRemainingThisMonth => 'Baki bulan ini';

  @override
  String get quotaSubtitle => 'Pantau storan yang anda guna';

  @override
  String quotaRemainingAmount(String amount) {
    return 'baki $amount';
  }

  @override
  String get quotaStorage => 'Storan';

  @override
  String get deleteAccountTitleStep1 => 'Padam akaun?';

  @override
  String get deleteAccountTitleStep2 => 'Sahkan pemadaman kekal?';

  @override
  String get deleteAccountBodyStep1 =>
      'Semua video, penghantaran dan fail anda akan dipadam kekal. Tindakan ini tidak boleh dibatalkan.';

  @override
  String get deleteAccountBodyStep2 =>
      'Ini langkah pengesahan terakhir. Selepas dipadam, anda akan dilog keluar serta-merta.';

  @override
  String get deleteConfirmPermanent => 'Padam kekal';

  @override
  String get deleteStep1Hint =>
      'Langkah 1/2 — akan minta pengesahan sekali lagi';

  @override
  String get deleteStep2Hint =>
      'Langkah 2/2 — tindakan ini tidak boleh dibatalkan';

  @override
  String get passwordCurrentLabel => 'Kata laluan semasa';

  @override
  String get passwordCurrentRequired => 'Sila masukkan kata laluan semasa anda';

  @override
  String get passwordNewLabel => 'Kata laluan baharu';

  @override
  String get passwordMinHint => 'Sekurang-kurangnya 8 aksara';

  @override
  String get passwordNewRequired => 'Sila masukkan kata laluan baharu';

  @override
  String get passwordMin8Error =>
      'Kata laluan mesti sekurang-kurangnya 8 aksara';

  @override
  String get passwordNeedsLetterDigit =>
      'Kata laluan perlu ada huruf dan nombor';

  @override
  String get passwordTooCommon =>
      'Kata laluan itu terlalu mudah diteka — pilih yang lain';

  @override
  String get passwordConfirmLabel => 'Masukkan semula kata laluan baharu';

  @override
  String get passwordMismatch => 'Kata laluan tidak sepadan';

  @override
  String get passwordSave => 'Simpan kata laluan';

  @override
  String get passwordChangeLogoutNote =>
      'Anda akan dilog keluar dari peranti lain selepas menukarnya';

  @override
  String get navOrders => 'Pesanan';

  @override
  String get navRecord => 'Rakam';

  @override
  String get navAccount => 'Akaun';

  @override
  String get navClaims => 'Tuntutan';

  @override
  String get changeAvatar => 'Tukar gambar profil';

  @override
  String quotaVideosRatio(int remaining, int total) {
    return '$remaining / $total video';
  }

  @override
  String quotaUsedPercent(int percent) {
    return 'Digunakan $percent%';
  }

  @override
  String quotaRetentionDays(int days) {
    return '$days hari';
  }

  @override
  String quotaUsedRatio(String used, String cap, int percent) {
    return 'Digunakan $used / $cap · $percent%';
  }

  @override
  String get quotaVideosStored => 'Video disimpan';

  @override
  String quotaVideosStoredCount(int count) {
    return '$count video';
  }

  @override
  String get quotaByType => 'Storan mengikut jenis';

  @override
  String quotaByTypeVideosCount(int count) {
    return '$count video disimpan';
  }

  @override
  String quotaRefundNote(int days) {
    return 'Storan dibebaskan apabila video melepasi tempoh simpanan $days hari';
  }

  @override
  String deletePendingProfilesWarning(int count) {
    return 'Anda masih ada $count fail “dihantar ke platform” — pautan kongsinya akan berhenti berfungsi';
  }

  @override
  String get detailRecordedTime => 'Masa rakaman';

  @override
  String get detailDuration => 'Tempoh';

  @override
  String get detailRecordedBy => 'Dirakam oleh';

  @override
  String get detailCapturedTime => 'Masa tangkapan';

  @override
  String get detailCapturedBy => 'Ditangkap oleh';

  @override
  String get detailDevice => 'Peranti';

  @override
  String get detailSize => 'Saiz';

  @override
  String get detailUploadStatus => 'Status muat naik';

  @override
  String get detailSeal => 'Meterai';

  @override
  String sealSealed(String at) {
    return 'Dikunci · $at';
  }

  @override
  String get sealWorking => 'Menerapkan cap masa…';

  @override
  String get sealWorkingHint =>
      'Salinan tersimpan belum ada cap masa pada gambarnya, jadi pautan kongsi dan muat turun menunggu dahulu. Biasanya beberapa saat.';

  @override
  String get playLocalCopyNote =>
      'Salinan sementara pada peranti ini — gambarnya belum bercap masa';

  @override
  String get sealNone => 'Dirakam sebelum ciri meterai wujud';

  @override
  String get sealFailed =>
      'Cap masa belum diterapkan · video masih boleh dimainkan dan dimuat turun';

  @override
  String get sealMismatch => 'Cap jari tidak sepadan — rakam semula klip ini';

  @override
  String get sealTimeDrift =>
      'Jam kamera terpesong daripada pelayan, jadi cap yang diterapkan turut membawa masa pelayan menerima klip.';

  @override
  String get detailSealAnchor => 'Bukti bebas';

  @override
  String sealAnchorConfirmed(String block) {
    return 'Ya · entri #$block';
  }

  @override
  String get sealAnchorConfirmedNoBlock => 'Ya';

  @override
  String get sealAnchorPending => 'Sedang ditulis ke lejar awam (beberapa jam)';

  @override
  String get sealAnchorNone => 'Tiada';

  @override
  String get sealVerifyOpen => 'Buka halaman pengesahan';

  @override
  String get sealVerifyHint =>
      'Hantar pautan ini kepada platform — mereka boleh mengesahkannya sendiri, tanpa perlu percaya ZenPack.';

  @override
  String get sealVerifyFailed => 'Tidak dapat membuka halaman pengesahan.';

  @override
  String get detailPlayVideo => 'Main video';

  @override
  String get detailCopyAssetLink => 'Salin pautan';

  @override
  String get assetLinkTitle => 'Pautan bukti';

  @override
  String get detailDownloadVideo => 'Muat turun video';

  @override
  String get detailDownloadNote =>
      'Pemilik/pengurus sahaja · untuk apabila platform meminta fail asal';

  @override
  String get detailTrimVideo => 'Potong klip pendek untuk dihantar';

  @override
  String get detailTrimNote =>
      'Klip penuh kekal utuh · klip yang dipotong masih bercap masa';

  @override
  String get trimSave => 'Simpan';

  @override
  String get trimEstimatedSize => 'Lebih kurang';

  @override
  String get trimFailed => 'Tidak dapat memotong video. Klip penuh masih ada.';

  @override
  String get trimPreparing => 'Memuat turun klip penuh…';

  @override
  String get detailDownloadPhoto => 'Muat turun gambar';

  @override
  String get attachPhotoToOrder => 'Lampirkan gambar ke pesanan';

  @override
  String get deleteVideoAction => 'Padam video';

  @override
  String get deletePhotoAction => 'Padam gambar';

  @override
  String get deleteVideoNote =>
      'Pemilik/pengurus sahaja · dikunci semasa ada fail terbuka · pengesahan dua langkah';

  @override
  String get deleteVideoConfirmTitle => 'Pengesahan akhir';

  @override
  String get deleteVideoConfirmBody =>
      'Bukti ini akan dipadam kekal dan tidak boleh dipulihkan — tetap padam?';

  @override
  String get deleteVideoConfirmAction => 'Padam kekal';

  @override
  String ordersErrorCount(int count) {
    return '· $count ralat';
  }

  @override
  String ordersPendingCount(int count) {
    return '· $count menunggu';
  }

  @override
  String ordersPendingEvidenceWarning(int count) {
    return '$count bukti belum dimuat naik · belum ada pautan untuk disalin';
  }

  @override
  String get captureFramePrompt => 'Imbas nombor penjejakan';

  @override
  String get captureCameraDownHint => 'Letakkan resit dalam bingkai';

  @override
  String get cutoverSavedVideo => 'Video disimpan';

  @override
  String get cutoverPreparingNext => 'Bersedia untuk yang seterusnya';

  @override
  String get cutoverNextOrder => 'Pesanan seterusnya';

  @override
  String get lowStorageTitle => 'Storan hampir penuh';

  @override
  String get lowStorageBody =>
      'Storan peranti ini hampir habis — rakaman yang sedang berjalan mungkin tidak tersimpan sepenuhnya. Kosongkan ruang sebelum meneruskan.';

  @override
  String get lowStorageAction => 'Faham';

  @override
  String cutoverClosedSummary(String code, String duration) {
    return 'Nombor penjejakan $code ditutup ($duration)';
  }

  @override
  String get cutoverSignalText => 'Bunyi + getaran semasa bertukar pesanan';

  @override
  String get tooltipBack => 'Kembali';

  @override
  String get tooltipSwitchCamera => 'Tukar kamera';

  @override
  String get tooltipEnterTracking => 'Masukkan nombor penjejakan';

  @override
  String get tooltipZoomIn => 'Zum masuk';

  @override
  String get tooltipZoomOut => 'Zum keluar';

  @override
  String get captureResolution => 'Resolusi';

  @override
  String get stopRecording => 'Berhenti merakam';

  @override
  String get videoTypeSettings => 'Tetapan jenis video';

  @override
  String get uploadQueueTitle => 'Baris gilir muat naik';

  @override
  String get quotaExhaustedNote =>
      'Elaun bulanan sudah habis. Rakaman masih berfungsi, tetapi klip ini ADA DALAM TELEFON INI dan belum dilindungi — ia akan dimuat naik sendiri sebaik elaun dinaikkan.';

  @override
  String get queueEmpty => 'Belum ada video dalam baris gilir';

  @override
  String get queueAutoUploadNote =>
      'Muat naik berlaku automatik apabila anda dalam talian';

  @override
  String get waitingUpload => 'Menunggu dimuat naik';

  @override
  String get uploaded => 'Dimuat naik';

  @override
  String get waitingQuota => 'Menunggu elaun · masih dalam peranti';

  @override
  String get pausedUpload => 'Dijeda';

  @override
  String get queuePauseAction => 'Jeda';

  @override
  String get queueResumeAction => 'Sambung';

  @override
  String get queueDeleteAction => 'Keluarkan';

  @override
  String get queueClearAction => 'Kosongkan';

  @override
  String get queueClearConfirmTitle => 'Kosongkan seluruh baris gilir?';

  @override
  String get queueClearConfirmBody =>
      'Klip yang belum dimuat naik hanya ada pada telefon ini. Mengosongkan akan menghilangkannya terus.';

  @override
  String get queueDeleteConfirmTitle => 'Keluarkan dari baris gilir?';

  @override
  String get queueDeleteConfirmBody =>
      'Klip ini belum dimuat naik — mengeluarkannya akan memadamnya dari peranti anda secara kekal.';

  @override
  String get toastQueueItemDeleted => 'Dikeluarkan dari baris gilir muat naik';

  @override
  String get manualTrackingTitle => 'Masukkan nombor penjejakan';

  @override
  String get manualTrackingNote => 'Taip sendiri atau imbas kod itu semula';

  @override
  String get commonDone => 'Selesai';

  @override
  String get startRecording => 'Mula merakam';

  @override
  String get returnCodeMismatch => 'Kod pemulangan tidak sepadan';

  @override
  String get enterCodeManually => 'Masukkan kod secara manual';

  @override
  String get videoTypeLabel => 'Jenis video';

  @override
  String get videoTypeSelectNote =>
      'Pilih jenis yang betul — tambah/ubah/padam dalam Butiran kedai';

  @override
  String get videoTypeSheetTitle => 'Pilih jenis video';

  @override
  String get videoTypeGroupDefault => 'Jenis lalai (wajib)';

  @override
  String get videoTypeGroupCustom => 'Jenis khas kedai';

  @override
  String get manageVideoTypesNote => 'Urus jenis video — buka Butiran kedai';

  @override
  String queueFilterAll(int count) {
    return 'Semua ($count)';
  }

  @override
  String queueFilterUploading(int count) {
    return 'Memuat naik ($count)';
  }

  @override
  String queueFilterErrored(int count) {
    return 'Ralat ($count)';
  }

  @override
  String queueFilterQuotaWait(int count) {
    return 'Menunggu elaun ($count)';
  }

  @override
  String queueSummary(int pending, int uploading, int errored) {
    return '$pending video menunggu · $uploading dimuat naik · $errored gagal';
  }

  @override
  String uploadingProgress(int percent) {
    return 'Memuat naik $percent%';
  }

  @override
  String errorRetryCount(int count) {
    return 'Ralat · Cuba lagi ($count)';
  }

  @override
  String returnCodeMismatchBody(String returnCode, String shopName) {
    return '$returnCode tidak sepadan dengan mana-mana pesanan dalam $shopName. Semak semula kod itu, masukkan secara manual, atau sahkan untuk mencipta pesanan baharu.';
  }

  @override
  String get onboardingSubtitle =>
      'Rakam video bukti pembungkusan untuk penjual e-dagang';

  @override
  String get onboardingStart => 'Mula';

  @override
  String get authSignIn => 'Log masuk';

  @override
  String get authChooseMethod => 'Pilih cara log masuk';

  @override
  String get authEmailRequired => 'Sila masukkan e-mel anda';

  @override
  String get authEmailInvalid => 'E-mel tidak sah';

  @override
  String get authPassword => 'Kata laluan';

  @override
  String get authPasswordRequired => 'Sila masukkan kata laluan anda';

  @override
  String get authForgotPassword => 'Lupa kata laluan?';

  @override
  String get registerWithGoogle => 'Daftar dengan Google';

  @override
  String get registerWithApple => 'Daftar dengan Apple';

  @override
  String get authSignInGoogle => 'Log masuk dengan Google';

  @override
  String get authSignInApple => 'Log masuk dengan Apple';

  @override
  String get authNoAccountPrompt => 'Belum ada akaun? ';

  @override
  String get authRegister => 'Daftar';

  @override
  String get authOr => 'atau';

  @override
  String get registerTitle => 'Cipta akaun baharu';

  @override
  String get registerConfirmPassword => 'Masukkan semula kata laluan';

  @override
  String get registerAgreePolicy => 'Saya bersetuju dengan dasar ';

  @override
  String get registerViewPolicy => 'Lihat dasar';

  @override
  String get registerCreateAccount => 'Cipta akaun';

  @override
  String get registerSameEmailNote =>
      'E-mel yang sama akan dipautkan automatik ke satu akaun';

  @override
  String get registerHaveAccountPrompt => 'Sudah ada akaun? ';

  @override
  String get registerSuccessTitle => 'Akaun dicipta';

  @override
  String registerSuccessVerifyMessage(String email) {
    return 'Kami menghantar e-mel pengesahan ke $email. Semak peti masuk (termasuk spam), kemudian log masuk.';
  }

  @override
  String get registerSuccessMessage =>
      'Akaun anda sudah sedia. Log masuk dengan e-mel dan kata laluan yang baru didaftarkan.';

  @override
  String get registerSuccessAction => 'Log masuk';

  @override
  String get loginNotVerifiedTitle => 'E-mel belum disahkan';

  @override
  String loginNotVerifiedMessage(String email) {
    return 'Buka e-mel pengesahan yang dihantar ke $email (semak spam juga), ikut pautannya, kemudian log masuk semula.';
  }

  @override
  String get loginResendVerification => 'Hantar semula e-mel';

  @override
  String get loginVerificationResent => 'E-mel pengesahan dihantar semula';

  @override
  String get forgotPasswordTitle => 'Lupa kata laluan';

  @override
  String get forgotPasswordSubtitle =>
      'Masukkan e-mel anda untuk menerima pautan set semula kata laluan';

  @override
  String get forgotPasswordSubmit => 'Hantar pautan set semula';

  @override
  String get forgotPasswordSent =>
      'Dihantar — semak peti masuk (termasuk spam)';

  @override
  String get forgotPasswordRememberPrompt => 'Ingat kata laluan anda? ';

  @override
  String get shopYourShops => 'Kedai anda';

  @override
  String get shopTapToClockIn =>
      'Ketik kedai untuk mula syif · urus di sini juga';

  @override
  String get shopLastOpenedNote =>
      'Kedai yang terakhir dibuka akan terus dibuka pada kali seterusnya';

  @override
  String get shopManageStore => 'Urus kedai';

  @override
  String get shopManageVisibilityNote =>
      'Hanya kelihatan kepada pemilik akaun / pengurus kedai';

  @override
  String get shopEmpty => 'Belum ada kedai';

  @override
  String get shopEmptyBody =>
      'Akaun anda belum tergolong dalam mana-mana kedai. Cipta kedai baharu untuk bermula, atau tunggu jemputan daripada pemilik kedai.';

  @override
  String get shopCreateNew => 'Cipta kedai baharu (nama + platform)';

  @override
  String get shopInvitesHere => 'Jemputan kedai akan muncul di sini';

  @override
  String get shopCreateTitle => 'Cipta kedai';

  @override
  String get shopNameLabel => 'Nama kedai';

  @override
  String get shopNameRequired => 'Sila masukkan nama kedai';

  @override
  String get shopPlatform => 'Platform';

  @override
  String get shopCreateOwnerNote =>
      'Anda akan menjadi pemilik kedai — tambah ahli kemudian dalam Urus kedai';

  @override
  String get shopMgmtVisibilityNote =>
      'Kakitangan tidak melihat skrin ini · pengurus hanya melihat kedai yang diuruskannya';

  @override
  String get shopAddNew => 'Tambah kedai baharu';

  @override
  String get sectionMembers => 'AHLI';

  @override
  String get sectionShopSettings => 'TETAPAN KEDAI';

  @override
  String get sectionVideoTypes => 'JENIS VIDEO';

  @override
  String get videoTypesLockedNote =>
      '3 jenis terbina dalam dikunci — tidak boleh diubah/dipadam';

  @override
  String get addMemberByContact => 'Tambah ahli melalui e-mel/telefon';

  @override
  String get recordResolution => 'Resolusi rakaman';

  @override
  String get addVideoType => 'Tambah jenis (masukkan nama)';

  @override
  String get createVideoTypeTitle => 'Cipta jenis video';

  @override
  String get videoTypeName => 'Nama jenis video';

  @override
  String get videoTypeNameHint => 'cth. Penimbangan';

  @override
  String get createVideoType => 'Cipta jenis';

  @override
  String get deleteVideoTypeBody =>
      'Hanya boleh dipadam selagi jenis ini belum ada video. Jika sudah ada video, sistem menghalang pemadaman supaya penapis bukti dan statistik tidak terganggu.';

  @override
  String get deleteVideoTypeConfirm => 'Padam jenis';

  @override
  String get deleteVideoTypeNote =>
      '(Hanya boleh dipadam selagi jenis ini belum ada video)';

  @override
  String get addMemberTitle => 'Tambah ahli';

  @override
  String get addMemberBody =>
      'Masukkan e-mel akaun ZenPack yang sudah berdaftar. Mereka akan menerima jemputan dan perlu mengesahkannya untuk menyertai kedai.';

  @override
  String get emailLabel => 'E-mel';

  @override
  String get emailRequired => 'Masukkan alamat e-mel.';

  @override
  String get emailInvalid => 'Masukkan satu alamat e-mel yang sah.';

  @override
  String get errorInviteAccountNotFound =>
      'E-mel ini belum ada akaun ZenPack. Minta mereka mendaftar dahulu, kemudian jemput semula.';

  @override
  String get errorInviteAlreadyMember => 'Dia sudah menjadi ahli kedai ini.';

  @override
  String get errorInviteMemberLimit =>
      'Had ahli pelan ini sudah penuh. Jemputan yang belum dijawab turut dikira — batalkan satu untuk mengosongkan slot.';

  @override
  String get errorInviteAlreadyOwner =>
      'Itu pemilik kedai — tidak perlu dijemput.';

  @override
  String get errorInviteInvalidRequest =>
      'E-mel itu tidak sah. Semak dan hantar semula.';

  @override
  String get addMemberSubmit => 'Tambah';

  @override
  String get memberOwnerLocked =>
      'Pemilik tidak boleh ditukar peranan atau dikeluarkan di sini — pemilikan melekat pada kedai, bukan pada baris keahlian.';

  @override
  String get removeFromShop => 'Keluarkan dari kedai';

  @override
  String get revokeInvite => 'Padam jemputan';

  @override
  String get resolutionAppliesNote =>
      'Terpakai untuk video kedai yang dirakam selepas ini';

  @override
  String get resolutionDefaultOption => '720p (lalai)';

  @override
  String get ordersSearchHint => 'Masukkan nombor penjejakan';

  @override
  String get ordersEmpty => 'Kedai ini belum ada pesanan';

  @override
  String recordAutoStopIn(String time) {
    return 'Berhenti automatik dalam $time';
  }

  @override
  String get ordersNotFound => 'Tiada pesanan dijumpai';

  @override
  String get ordersNotFoundHint =>
      'Semak semula nombor penjejakan dan cuba lagi';

  @override
  String ordersPageRange(int first, int last, int total) {
    return '$first–$last daripada $total pesanan';
  }

  @override
  String get ordersPagePrevious => 'Halaman sebelumnya';

  @override
  String get ordersPageNext => 'Halaman seterusnya';

  @override
  String ordersPageNumber(int page) {
    return 'Halaman $page';
  }

  @override
  String get filterStatusLabel => 'Status';

  @override
  String get filterStatusAll => 'Semua';

  @override
  String get filterStatusPending => 'Menunggu muat naik';

  @override
  String get filterStatusError => 'Ralat muat naik';

  @override
  String get filterStatusDone => 'Dimuat naik sepenuhnya';

  @override
  String get filterTimeLabel => 'Masa';

  @override
  String get filterTimeAll => 'Bila-bila masa';

  @override
  String get filterTimeToday => 'Hari ini';

  @override
  String get filterTimeYesterday => 'Semalam';

  @override
  String get filterTime7d => '7 hari lepas';

  @override
  String get filterTime30d => '30 hari lepas';

  @override
  String get filterTimePickDate => 'Pilih tarikh…';

  @override
  String get filterTypeLabel => 'Jenis video';

  @override
  String get filterTypeAll => 'Semua';

  @override
  String deleteVideoTypeTitle(String typeName) {
    return 'Padam jenis \"$typeName\"?';
  }

  @override
  String memberCurrentRole(String role) {
    return 'Peranan semasa: $role';
  }

  @override
  String get stopCodeTitle => 'Kod QR henti rakam';

  @override
  String get stopCodeInstructions =>
      'Cetak ini dan tampal di meja pembungkusan. Tunjukkan kepada kamera semasa merakam untuk berhenti automatik.';

  @override
  String get scannedCodeNotFound =>
      'Tiada pesanan sepadan dengan kod yang diimbas';

  @override
  String get onboardingTaglineOne => 'Setiap bungkusan.';

  @override
  String get onboardingTaglineTwo => 'Satu bukti.';

  @override
  String get onboardingTaglineThree => 'Melindungi pendapatan anda.';

  @override
  String get authEmailPlaceholder => 'Masukkan e-mel anda';

  @override
  String get authPasswordPlaceholder => 'Masukkan kata laluan anda';

  @override
  String get registerCreateAccountSubtitle => 'Cipta akaun baharu';

  @override
  String get registerFullName => 'Nama penuh';

  @override
  String get registerFullNameRequired => 'Sila masukkan nama penuh anda';

  @override
  String get registerAgreePrefix => 'Saya bersetuju dengan';

  @override
  String get registerTermsOfUse => 'Terma Penggunaan';

  @override
  String get shopChooseTitle => 'Pilih kedai';

  @override
  String get shopChooseSubtitle => 'Pilih kedai untuk meneruskan';

  @override
  String get shopManageTitle => 'Urus kedai';

  @override
  String get shopManageOwnerOnly =>
      'Hanya kelihatan kepada pemilik dan pengurus kedai';

  @override
  String get noShopTitle => 'Belum ada kedai';

  @override
  String get noShopLineOne =>
      'Akaun anda belum tergolong dalam mana-mana kedai.';

  @override
  String get noShopLineTwo => 'Cipta kedai untuk bermula,';

  @override
  String get noShopLineThree => 'atau tunggu jemputan daripada pemilik kedai.';

  @override
  String get noShopCreateCta => 'Cipta kedai (nama + platform)';

  @override
  String get noShopInviteHint => 'Jemputan kedai akan muncul di sini';

  @override
  String get createShopTitle => 'Cipta kedai';

  @override
  String get createShopNameLabel => 'Nama kedai';

  @override
  String get createShopNameHint => 'cth. Kedai ABC';

  @override
  String get createShopPlatformLabel => 'Platform';

  @override
  String get createShopOwnerNote =>
      'Anda akan menjadi pemilik kedai — tambah ahli kemudian dalam Urus kedai';

  @override
  String get createShopSubmit => 'Cipta kedai';

  @override
  String get shopManageDescription => 'Lihat dan urus kedai yang anda tadbir.';

  @override
  String get shopManageAddCta => 'Tambah kedai';

  @override
  String get shopManageStaffNote =>
      'Kakitangan tidak boleh melihat skrin ini — pemilik dan pengurus kedai sahaja.';

  @override
  String get shopDetailTitle => 'Butiran kedai';

  @override
  String get shopDetailResolution => 'Resolusi rakaman';

  @override
  String get shopDetailClipDuration => 'Panjang maks/video';

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
    return 'Disyorkan $minutes min — untuk $platform ($megabytes MB/video) + $resolution';
  }

  @override
  String clipRecommendedHintUnverified(String minutes, String platform) {
    return 'Disyorkan $minutes min — had $platform belum disahkan, menggunakan nilai paling selamat yang diketahui';
  }

  @override
  String clipOverRecommendedWarning(
    String minutes,
    String platform,
    String chosen,
    String megabytes,
  ) {
    return 'Melebihi syor $minutes min untuk $platform — video $chosen min lebih kurang $megabytes MB, jadi ia perlu dihantar sebagai pautan fail dan bukan dilampirkan pada borang aduan.';
  }

  @override
  String get clipDurationTitle => 'Panjang maksimum setiap video';

  @override
  String get clipDurationSubtitle => 'Ditutup automatik pada panjang ini';

  @override
  String clipDurationPlanCap(String minutes) {
    return 'Pelan anda membenarkan sehingga $minutes min';
  }

  @override
  String clipDurationChanged(String minutes) {
    return 'Panjang maks/video: $minutes min';
  }

  @override
  String get shopDetailImageSize => 'Saiz imej';

  @override
  String get shopDetailVideoSize => 'Saiz video';

  @override
  String get shopDetailUploadSize => 'Saiz maks/fail';

  @override
  String uploadSizeValue(String megabytes) {
    return '$megabytes MB';
  }

  @override
  String uploadRecommendedHint(String megabytes, String platform) {
    return 'Disyorkan $megabytes MB — had lampiran $platform';
  }

  @override
  String uploadOverRecommendedWarning(
    String megabytes,
    String platform,
    String chosen,
  ) {
    return 'Melebihi syor $megabytes MB untuk $platform — fail sehingga $chosen MB tetap disimpan penuh, tetapi perlu dihantar sebagai pautan fail dan bukan dilampirkan pada borang aduan.';
  }

  @override
  String get uploadSizeValueUnlimited => 'Tiada had';

  @override
  String get uploadSizeTitle => 'Saiz maksimum setiap fail';

  @override
  String uploadSizeSubtitle(String megabytes, String platform) {
    return 'Fail melebihi had tidak dilampirkan; $megabytes MB masih boleh dilampirkan terus ke $platform';
  }

  @override
  String uploadSizeOptionRecommended(String megabytes) {
    return '$megabytes MB (disyorkan)';
  }

  @override
  String uploadSizeChanged(String megabytes) {
    return 'Saiz setiap fail: $megabytes';
  }

  @override
  String avatarTooLarge(String megabytes, String limit) {
    return 'Nama dan telefon disimpan. Gambar profil $megabytes MB melebihi had $limit MB, jadi ia tidak sampai ke pelayan — pilih imej lebih kecil.';
  }

  @override
  String avatarUploadFailed(String reason) {
    return 'Nama dan telefon disimpan. Gambar profil tidak sampai ke pelayan: $reason';
  }

  @override
  String nearClipLimitWarning(String minutes) {
    return 'Menghampiri had $minutes min — video akan ditutup sendiri';
  }

  @override
  String get shopDetailAddType => 'Tambah jenis (masukkan nama)';

  @override
  String get inviteMemberTitle => 'Jemput ahli';

  @override
  String get inviteRoleFixedNote =>
      'Dia menyertai sebagai kakitangan: merakam video dan menyemak video sendiri.';

  @override
  String get inviteMemberHint => '(belum ada akaun → hantar jemputan)';

  @override
  String get videoTypeIcon => 'Ikon';

  @override
  String get videoTypeColor => 'Warna';

  @override
  String get createVideoTypeSubmit => 'Cipta jenis';

  @override
  String get deleteVideoTypeSafeNote => 'Tiada bukti yang hilang';

  @override
  String get commonConfirm => 'Sahkan';

  @override
  String orderErrorCount(int count) {
    return '$count gagal';
  }

  @override
  String get videoDetailSheetTitle => 'Butiran video';

  @override
  String get tooltipStopRecording => 'Berhenti merakam';

  @override
  String get dossierLinkTitle => 'Pautan fail pertikaian';

  @override
  String get accountEndQr => 'Kod henti rakam';

  @override
  String get accountEndQrTitle => 'Kod henti rakam';

  @override
  String get accountEndQrShare => 'Kongsi kod';

  @override
  String get accountEndQrSave => 'Simpan ke pustaka foto';

  @override
  String get recordInterruptedTitle => 'Rakaman dijeda';

  @override
  String get recordInterruptedBody =>
      'Rakaman dijeda kerana ada gangguan. Sambung merakam?';

  @override
  String get recordInterruptedResume => 'Sambung';

  @override
  String get recordInterruptedFinish => 'Selesai';

  @override
  String get commonApply => 'Guna';

  @override
  String get unitMinutes => 'min';

  @override
  String get clipDurationCustomLabel =>
      'Atau masukkan bilangan minit yang anda mahu';

  @override
  String get supportOpenFailed =>
      'Tidak dapat dibuka — pastikan apl sudah dipasang';

  @override
  String get feedbackThanksTitle => 'Terima kasih!';

  @override
  String get feedbackThanksBody =>
      'Maklum balas anda membantu ZenPack menjadi lebih baik.';

  @override
  String get feedbackTitle => 'Apa yang ingin anda kongsikan dengan kami?';

  @override
  String get feedbackHint => 'Taip maklum balas anda...';

  @override
  String get feedbackSend => 'Hantar maklum balas';

  @override
  String get feedbackThanks => 'Terima kasih atas maklum balas anda';

  @override
  String get accountSectionAbout => 'TENTANG';

  @override
  String get accountFeedback => 'Hantar maklum balas';

  @override
  String get accountFeedbackNote =>
      'Kongsi pandangan anda untuk menjadikan ZenPack lebih baik';

  @override
  String get accountRateApp => 'Nilai apl';

  @override
  String get accountRateAppNote => 'Sokong pembangunan ZenPack';

  @override
  String get supportFacebook => 'Hantar mesej di Facebook';

  @override
  String get supportZalo => 'Hantar mesej di Zalo';

  @override
  String get supportCall => 'Hubungi sokongan';

  @override
  String sheetCustomMin(String min, String unit) {
    return 'Masukkan $min $unit atau lebih';
  }

  @override
  String sheetCustomRange(String min, String max, String unit) {
    return 'Masukkan antara $min dan $max $unit';
  }

  @override
  String get accountEndQrNote =>
      'Cetak ini dan tampal di meja pembungkusan. Mengimbasnya semasa merakam akan menutup klip. Kod yang sama berfungsi pada semua peranti.';

  @override
  String get languageChangeScopeNote =>
      'Setiap label, pemberitahuan dan fail\nbertukar kepada bahasa yang anda pilih.';

  @override
  String get manualEntryEmptyError =>
      'Masukkan nombor penjejakan sebelum merakam';

  @override
  String get appUpdateTitle => 'Versi baharu tersedia';

  @override
  String get appUpdateMessage =>
      'Kemas kini ZenPack untuk pembetulan dan ciri terkini.';

  @override
  String get appUpdateNow => 'Kemas kini';

  @override
  String get appUpdateLater => 'Nanti';

  @override
  String get quotaVideosThisMonth => 'Video bulan ini';

  @override
  String get quotaSubtitleVideos =>
      'Pantau berapa banyak video yang anda rakam bulan ini';

  @override
  String get quotaUpgrade => 'Naik taraf pelan';

  @override
  String get quotaBlockedTitle => 'Elaun video sudah habis';

  @override
  String get quotaBlockedNote =>
      'Rakaman masih berfungsi, tetapi klip belum boleh dimuat naik — ia berada dalam telefon ini, tidak dilindungi. Ia akan dimuat naik sendiri sebaik elaun dinaikkan.';

  @override
  String get quotaBlockedOwnerNote =>
      'Kuota kedai ini ditetapkan oleh pemilik akaun — minta mereka menaikkannya. Pelan yang anda beli hanya terpakai untuk akaun anda sendiri.';

  @override
  String get quotaTopupCredits => 'Tambah nilai kredit';

  @override
  String get quotaOverCap => 'Melebihi elaun pelan';

  @override
  String quotaBlockAt(int n) {
    return 'Rakaman baharu disekat pada $n video';
  }

  @override
  String get quotaResetMonthly =>
      'Ditetapkan semula pada awal bulan depan; tiada baki dibawa';

  @override
  String get storageOwnTitle => 'Storan anda sendiri';

  @override
  String storageOwnPending(int count) {
    return '$count video menunggu untuk dihantar ke storan anda';
  }

  @override
  String storageOwnProblem(int count) {
    return '$count video dalam storan anda bermasalah';
  }

  @override
  String get quotaExhaustedWarn =>
      'Jangan nyahpasang apl atau kosongkan datanya sehingga semuanya selesai dimuat naik.';

  @override
  String quotaStrandedTitle(int count) {
    return '$count video menunggu dalam telefon ini';
  }

  @override
  String get quotaStrandedNote =>
      'Video ini hanya wujud dalam telefon ini. Kehilangan telefon, menyahpasang apl atau mengosongkan datanya akan menghilangkannya.';

  @override
  String get storageTitle => 'Storan video';

  @override
  String get storageSystemName => 'Storan sistem';

  @override
  String get storageS3Name => 'Storan anda sendiri (S3)';

  @override
  String get storageDriveName => 'Google Drive anda';

  @override
  String get storageSystemDesc =>
      'Pilihan lalai; tiada apa perlu disediakan. Hanya di sini semua jaminan bukti kekal terpakai.';

  @override
  String get storageOwnDesc =>
      'Video baharu terus masuk ke storan anda. Yang lama kekal di tempatnya sehingga tempoh simpanannya tamat.';

  @override
  String get storageNoPresign =>
      'Storan ini tidak boleh menandatangani pautan muat turun, jadi video perlu melalui pelayan — sesiapa yang membuka pautan anda akan merasa lebih perlahan.';

  @override
  String get storageNoObjectLock =>
      'Storan ini tiada kunci objek. Anda tidak boleh menjanjikan kepada platform bahawa bukti tidak boleh dipadam.';

  @override
  String get storageNotInPlan =>
      'Pelan anda belum termasuk storan sendiri. Naik taraf di web untuk menggunakannya.';

  @override
  String get storageHealthTitle => 'Kesihatan storan';

  @override
  String get storageHealthTotal => 'Jumlah video';

  @override
  String get storageHealthIntact => 'Utuh';

  @override
  String get storageHealthUnreachable => 'Tidak dapat dicapai';

  @override
  String get storageHealthMismatched => 'Tidak sepadan dengan meterai';

  @override
  String get storageHealthPendingRelay => 'Menunggu di kawasan geganti';

  @override
  String get storageProblemsNote =>
      'Sesetengah video bermasalah dalam storan anda. Semak kebenaran akses di pihak penyedia.';

  @override
  String get storageTest => 'Uji semula sambungan';

  @override
  String get storageInUse => 'Sedang digunakan';

  @override
  String storageLastCheckAt(String time) {
    return 'Audit terakhir: $time';
  }

  @override
  String get storageNeverChecked => 'Belum pernah diaudit.';

  @override
  String get storageDriveAccount => 'Akaun Drive';

  @override
  String get storageDisconnect => 'Berhenti menggunakan storan sendiri';

  @override
  String get storageDisconnectConfirm =>
      'Video yang dirakam mulai sekarang akan masuk ke storan sistem. Yang lama kekal dalam storan anda dan sistem kehilangan laluan kepadanya.';

  @override
  String get storageConnectS3 => 'Sambung storan S3';

  @override
  String get storageConnectDrive => 'Sambung Google Drive';

  @override
  String get storageConnectHint =>
      'Berikan kebenaran baca/tulis/padam pada prefix di bawah sahaja — tidak perlu kebenaran untuk seluruh bucket.';

  @override
  String get storageConnectSubmit => 'Uji dan simpan';

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
      'Sub-folder dalam bucket. Biarkan lalai jika tidak pasti.';

  @override
  String get storageConnected => 'Storan sendiri disambungkan.';

  @override
  String get storageDisconnected => 'Storan sendiri diputuskan.';

  @override
  String get storageTestOk => 'Sambungan sihat.';

  @override
  String get storageOwnerOnly => 'Hanya pemilik kedai boleh menukar storan.';

  @override
  String get dangerZone => 'Zon bahaya';

  @override
  String get shopDelete => 'Padam kedai';

  @override
  String get shopDeleteDesc =>
      'Memadam kekal pesanan, bukti, fail tersimpan dan ahli. Ini tidak boleh dibatalkan.';

  @override
  String get shopDeleteConfirmTitle => 'Padam kedai ini?';

  @override
  String shopDeleteConfirmBody(int orders, int videos, int members) {
    return '$orders pesanan · $videos video · $members ahli akan dipadam kekal.';
  }

  @override
  String shopDeleteOpenDossiers(int n) {
    return '$n fail tuntutan masih terbuka. Pautan yang sudah dihantar ke platform akan mati sebaik anda memadam.';
  }

  @override
  String get shopDeleteForce => 'Tetap padam';

  @override
  String get shopDeleteFailed => 'Tidak dapat memadam kedai.';

  @override
  String get claimsCreatedLocalOnly =>
      'Fail disimpan dalam telefon ini. Ia belum dapat dimuat naik, jadi belum ada pautan kongsi — buka semula apabila anda dalam talian.';

  @override
  String get claimsLinkCopied =>
      'Pautan fail disalin. Tampal ke saluran tuntutan platform.';

  @override
  String get shopRenameTitle => 'Tukar nama kedai';

  @override
  String get shopRenameHint => 'Nama kedai';

  @override
  String get shopRenamed => 'Nama kedai ditukar';

  @override
  String get commonSave => 'Simpan';

  @override
  String get inviteJoinRow => 'Saya ada jemputan';

  @override
  String inviteJoinedShop(String shop) {
    return 'Menyertai $shop';
  }

  @override
  String inviteAlreadyJoined(String shop) {
    return 'Anda sudah berada dalam $shop';
  }

  @override
  String get inviteBadLink =>
      'Pautan itu tidak sah. Tampal keseluruhan pautan dari e-mel.';

  @override
  String get inviteNotFound => 'Jemputan tidak wujud atau telah dibatalkan';

  @override
  String get inviteTaken => 'Orang lain sudah menerima jemputan ini';

  @override
  String get inviteExpired =>
      'Jemputan telah tamat tempoh. Minta pemilik kedai menghantarnya semula.';

  @override
  String get inviteQrRow => 'Kod QR';

  @override
  String get inviteScanTitle => 'Imbas kod jemputan';

  @override
  String get inviteScanDetail =>
      'Minta pemilik kedai menunjukkan kod QR jemputan, kemudian imbas di sini.';

  @override
  String get commonShare => 'Kongsi';

  @override
  String get inviteQrSaved => 'Kod QR disimpan ke galeri anda';

  @override
  String get inviteQrSaveFailed => 'Tidak dapat menyimpan kod QR';

  @override
  String get voiceRecordingStarted => 'Rakaman bermula';

  @override
  String get voiceRecordingStopped => 'Rakaman dihentikan';

  @override
  String get voiceWrongCode => 'Kod salah';

  @override
  String get voiceCapSoon => 'Video akan ditutup sebentar lagi';

  @override
  String voiceCapNear(int minutes) {
    return 'Menghampiri had $minutes minit, video akan ditutup sendiri';
  }

  @override
  String get voiceInterrupted => 'Rakaman terganggu';

  @override
  String get videoTypePacking => 'Pembungkusan';

  @override
  String get videoTypeCarrier => 'Serahan kurier';

  @override
  String get videoTypeReturn => 'Pemulangan';

  @override
  String get storageIntro =>
      'Di mana video kedai disimpan. Di mana pun ia berada, rekod meterai kekal di sistem — menukar storan tidak melemahkan bukti.';

  @override
  String get storageS3Title => 'Storan awan sendiri (serasi S3)';

  @override
  String get storageS3Desc =>
      'AWS S3, Cloudflare R2, MinIO, Wasabi… Video berada dalam bucket anda, dan ketahanannya tanggungjawab anda.';

  @override
  String get storageDriveTitle => 'Google Drive';

  @override
  String get storageDriveDesc =>
      'Sambung dengan satu kali pemberian kebenaran, tanpa perlu tampal kunci. Akaun percuma hanya ada 15 GB dikongsi dengan Gmail.';

  @override
  String get storageNeedProPlan =>
      'Menyambung storan sendiri memerlukan pelan Professional atau lebih tinggi.';

  @override
  String get attachCodeToOrder => 'Imbas kod lain ke pesanan ini';

  @override
  String get attachedCodes => 'Kod dilampirkan';

  @override
  String get codeAttached => 'Kod dilampirkan pada pesanan ini';

  @override
  String get codeBelongsToAnotherOrder =>
      'Kod ini milik pesanan lain — tidak boleh digabung.';

  @override
  String get codeAttachFailed => 'Tidak dapat melampirkan kod.';
}

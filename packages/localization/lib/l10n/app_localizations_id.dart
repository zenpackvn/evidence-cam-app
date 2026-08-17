// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get bundleBackendPending => 'Menunggu endpoint backend untuk ini';

  @override
  String get bundleCreate => 'Buat';

  @override
  String get bundleCreateClaim => 'Buat berkas klaim';

  @override
  String get accountClaims => 'Berkas klaim';

  @override
  String get claimsTitle => 'Berkas klaim';

  @override
  String get claimsLocalOnlyNote =>
      'Beberapa berkas belum terkirim sehingga hanya ada di perangkat ini.';

  @override
  String get claimsOfflineNote =>
      'Tidak dapat terhubung ke server, ini salinan di perangkat. Buka lagi saat online untuk melihat semua.';

  @override
  String get claimsEmpty =>
      'Belum ada berkas. Buka tab Pesanan, ketuk tombol plus dan pilih bukti untuk membuatnya.';

  @override
  String claimsSummary(int orders, int evidence) {
    return '$orders pesanan · $evidence bukti';
  }

  @override
  String claimsEvidenceOnly(int evidence) {
    return '$evidence bukti';
  }

  @override
  String get claimsCopied => 'Isi berkas disalin';

  @override
  String get claimsCreated => 'Berkas klaim dibuat';

  @override
  String get claimsPickNothing => 'Tidak ada bukti yang dipilih';

  @override
  String get claimsDelete => 'Hapus berkas';

  @override
  String get claimsDeleteConfirm =>
      'Hapus berkas ini? Bukti pada pesanan itu sendiri tidak terpengaruh.';

  @override
  String get claimsDeleteConfirmLink =>
      'Hapus berkas ini? Tautan publiknya mati seketika — siapa pun yang sudah menerimanya akan melihat halaman kosong. Bukti pada pesanan itu sendiri tidak terpengaruh.';

  @override
  String get claimsRevokeFailed =>
      'Tautan tidak bisa dicabut, jadi berkas dibiarkan apa adanya. Tautan masih terbuka — coba lagi dengan koneksi yang lebih baik, atau minta pemilik toko mencabutnya.';

  @override
  String get claimsDeleted => 'Berkas dihapus';

  @override
  String get claimsPhotoAdded =>
      'Foto ditambahkan ke berkas dan diantrekan ke pesanan';

  @override
  String get claimsAddedLater => 'ditambahkan kemudian';

  @override
  String get claimsCreateTitle => 'Berkas klaim baru';

  @override
  String get claimsCreateSearchHint => 'Ketik atau pindai nomor resi';

  @override
  String get claimsCreateNameHint => 'mis. Klaim retur 12/08';

  @override
  String get claimsCreateNameLabel => 'Nama berkas';

  @override
  String get claimInfoTitle => 'Detail berkas';

  @override
  String get claimTrackingLabel => 'Kode resi';

  @override
  String get claimShopLabel => 'Toko';

  @override
  String get claimChannelLabel => 'Kanal penjualan';

  @override
  String get claimOrderCreatedAt => 'Tanggal pesanan';

  @override
  String get claimEvidenceLabel => 'Bukti';

  @override
  String claimEvidenceCount(int videos, int photos) {
    return '$videos video · $photos foto';
  }

  @override
  String get claimCreatedAtLabel => 'Berkas dibuat';

  @override
  String get claimCopyLink => 'Copy link';

  @override
  String get claimsRevokeNoLink =>
      'This dossier is not on the server yet, so there is no link to revoke.';

  @override
  String get claimPageFailed =>
      'Could not open the dossier page. Check your connection and try again.';

  @override
  String get claimLinkLabel => 'Tautan berkas';

  @override
  String get claimLinkHint =>
      'Siapa pun yang punya tautan bisa melihatnya, tanpa masuk. Tetap aktif sampai Anda mencabutnya.';

  @override
  String get claimRevokedBadge => 'Dicabut';

  @override
  String get claimRevokedHint =>
      'Tautan sudah mati. Datanya utuh — buat berkas baru untuk membagikannya lagi.';

  @override
  String get claimRevoke => 'Cabut';

  @override
  String get claimUntitled => 'Berkas tanpa nama';

  @override
  String get claimRevokeConfirmTitle => 'Cabut berkas ini?';

  @override
  String get claimRevokeConfirmBody =>
      'Tautan langsung mati bagi siapa pun yang memegangnya, termasuk marketplace. Data dan tautan per pesanan tidak terpengaruh.';

  @override
  String get claimRevoked => 'Berkas dicabut. Tautan tidak dapat dibuka lagi.';

  @override
  String get claimRevokeFailed => 'Gagal mencabut. Coba lagi saat online.';

  @override
  String get claimNotUploaded =>
      'Berkas ini belum terunggah sehingga belum ada tautan. Buka lagi saat online.';

  @override
  String get claimDetailLoadFailed =>
      'Gagal memuat berkas. Periksa koneksi lalu buka lagi.';

  @override
  String get claimsCreateStart =>
      'Ketik nomor resi, atau ketuk pindai, untuk menemukan pesanan yang diklaim.';

  @override
  String get claimsCreateNoOrder =>
      'Tidak ada pesanan dengan nomor resi itu di toko yang dipilih.';

  @override
  String get claimsRemoveItemTitle => 'Keluarkan dari berkas';

  @override
  String get claimsRemoveItemConfirm =>
      'Keluarkan bukti ini dari berkas klaim? Video/foto pada pesanan itu sendiri tidak terpengaruh.';

  @override
  String get claimsItemRemoved => 'Dikeluarkan dari berkas';

  @override
  String get claimsItemAdded => 'Ditambahkan ke berkas';

  @override
  String get commonRemove => 'Keluarkan';

  @override
  String get commonDelete => 'Hapus';

  @override
  String get settingDefaultSuffix => 'bawaan';

  @override
  String get shopDetailClipLength => 'Durasi video';

  @override
  String get shopDeleteTitle => 'Hapus toko';

  @override
  String get shopDeleteConfirm =>
      'Hapus toko ini? Semua pesanan, video dan foto ikut terhapus, dan tidak bisa dipulihkan.';

  @override
  String get shopDeleteBlockedTitle => 'Toko masih punya anggota';

  @override
  String shopDeleteBlockedBody(int count) {
    return 'Keluarkan semua anggota dari toko sebelum menghapusnya. Masih ada $count.';
  }

  @override
  String get shopDeleted => 'Toko dihapus.';

  @override
  String bundleSelected(int count) {
    return '$count dipilih';
  }

  @override
  String get bundleUploadDrive => 'Unggah ke Drive';

  @override
  String get commonCancel => 'Batal';

  @override
  String get commonRetry => 'Coba lagi';

  @override
  String get commonClose => 'Tutup';

  @override
  String get toastChangeLanguage => 'Ganti bahasa';

  @override
  String get toastTermsPolicy => 'Ketentuan & Kebijakan';

  @override
  String get toastInfoSaved => 'Info disimpan';

  @override
  String get toastPasswordCreated => 'Kata sandi dibuat';

  @override
  String get toastPasswordChanged => 'Kata sandi diubah';

  @override
  String get toastPendingDossierConfirm =>
      'Anda masih punya berkas klaim yang terbuka, mohon konfirmasi lagi';

  @override
  String get toastCopiedShareLink => 'Tautan berbagi disalin';

  @override
  String get toastShareFailed => 'Tidak bisa berbagi, coba lagi nanti';

  @override
  String get toastDownloadingVideo => 'Mengunduh video';

  @override
  String get toastVideoDownloadedCopied =>
      'Video diunduh dan lokasinya disalin';

  @override
  String get toastVideoSavedToGallery => 'Video disimpan ke galeri perangkat';

  @override
  String get toastVideoDownloadFailed =>
      'Tidak bisa mengunduh video, coba lagi nanti';

  @override
  String get toastVideoDeleteUnavailable => 'Video ini tidak bisa dihapus';

  @override
  String get toastDownloadingPhoto => 'Mengunduh foto';

  @override
  String get toastPhotoSavedToGallery => 'Foto disimpan ke galeri perangkat';

  @override
  String get toastPhotoDownloadedCopied => 'Foto diunduh dan lokasinya disalin';

  @override
  String get toastPhotoDownloadFailed =>
      'Tidak bisa mengunduh foto, coba lagi nanti';

  @override
  String get toastPhotoNoDownloadLink => 'Foto belum punya tautan unduh';

  @override
  String get toastPhotoQueued => 'Foto dilampirkan — masuk ke antrean unggah';

  @override
  String imageOverFixedCap(String megabytes, String limit) {
    return 'Foto berukuran $megabytes MB — melebihi batas $limit MB, tidak dilampirkan. Pilih gambar yang lebih kecil.';
  }

  @override
  String get toastInvitePending => 'Menunggu undangan toko';

  @override
  String get toastInviteSent => 'Undangan dikirim';

  @override
  String get toastMemberAdded => 'Anggota ditambahkan';

  @override
  String get toastVideoPlayFailed => 'Tidak bisa memutar video';

  @override
  String get toastShopCreated => 'Toko baru dibuat';

  @override
  String get toastVideoQueued => 'Video disimpan — masuk ke antrean unggah';

  @override
  String get toastVideoNoPlayLink => 'Video belum punya tautan pemutaran';

  @override
  String get toastVideoNoDownloadLink => 'Video belum punya tautan unduh';

  @override
  String get toastVideoDeleted => 'Video dihapus';

  @override
  String get toastVideoTypeSaved => 'Jenis video disimpan';

  @override
  String get toastVideoTypeDeleted => 'Jenis video dihapus';

  @override
  String get toastNoVideoTypeToDelete => 'Tidak ada jenis video untuk dihapus';

  @override
  String get toastNoMemberToUpdate => 'Tidak ada anggota untuk diperbarui';

  @override
  String get toastMemberRemoved =>
      'Dikeluarkan dari toko (video yang sudah direkam tetap selesai diunggah)';

  @override
  String get toastInviteRevoked =>
      'Undangan dihapus — tautan di email tidak berlaku lagi';

  @override
  String copiedLabel(String label) {
    return '$label disalin';
  }

  @override
  String get labelTrackingCode => 'nomor resi';

  @override
  String resolutionChanged(String value) {
    return 'Resolusi: $value';
  }

  @override
  String get accountNoName => 'Belum ada nama';

  @override
  String get accountNoShop => 'Belum ada toko dipilih';

  @override
  String get accountCreatePassword => 'Buat kata sandi';

  @override
  String get accountChangePassword => 'Ubah kata sandi';

  @override
  String accountLinkedMethods(int count) {
    return '$count tertaut';
  }

  @override
  String get roleOwner => 'Pemilik';

  @override
  String get roleStaff => 'Karyawan';

  @override
  String memberInviteSent(String role) {
    return '$role · undangan terkirim';
  }

  @override
  String memberInviteAccepted(String role) {
    return '$role · undangan diterima';
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
  String get planEnterprise => 'Perusahaan';

  @override
  String get roleOther => 'Lainnya';

  @override
  String get roleUnknown => 'Tidak diketahui';

  @override
  String get memberFallbackName => 'Anggota';

  @override
  String get uploadStatusDone => 'Terunggah';

  @override
  String get uploadStatusPending => 'Menunggu diunggah';

  @override
  String get uploadStatusQuotaHold => 'Ditahan (kuota)';

  @override
  String get uploadStatusDeleted => 'Dihapus';

  @override
  String get uploadStatusError => 'Kesalahan pemrosesan di server';

  @override
  String get uploadStatusExpired => 'Masa simpan berakhir';

  @override
  String expiredOnDate(String date) {
    return 'Masa simpan berakhir pada $date';
  }

  @override
  String get kindPhoto => 'Foto terlampir';

  @override
  String get kindVideo => 'Video';

  @override
  String get recordedByFallback => 'Akun saat ini';

  @override
  String get deviceUnknown => 'Perangkat tidak dikenal';

  @override
  String get orderNoEvidence => 'Belum ada bukti';

  @override
  String get timelineEmpty => 'Kiriman ini belum punya video atau foto';

  @override
  String get errorGenericRetry => 'Terjadi kesalahan, silakan coba lagi.';

  @override
  String get errorPendingDossier =>
      'Anda masih punya berkas klaim yang terbuka, selesaikan dulu sebelum melanjutkan.';

  @override
  String get errorSessionExpired => 'Sesi Anda berakhir, silakan masuk lagi.';

  @override
  String get errorNoNetwork => 'Tidak ada koneksi jaringan, silakan coba lagi.';

  @override
  String get errorNoPermission => 'Anda tidak punya izin untuk tindakan ini.';

  @override
  String get errorServerBusy => 'Sistem sedang sibuk, silakan coba lagi nanti.';

  @override
  String get errorSessionInvalid => 'Sesi tidak valid, silakan masuk lagi.';

  @override
  String get errorVideoTypeInUse =>
      'Tidak bisa menghapus jenis video yang sudah punya video. Periksa dulu video yang memakai jenis ini.';

  @override
  String get errorBuiltinVideoTypeLocked =>
      '3 jenis video bawaan tidak bisa diubah atau dihapus.';

  @override
  String get errorVideoTypeNameExists =>
      'Nama jenis video itu sudah ada di toko.';

  @override
  String get errorCheckNetwork => 'Periksa jaringan Anda atau coba lagi nanti.';

  @override
  String get errorLoadShopList => 'Tidak bisa memuat daftar toko';

  @override
  String get errorLoadShopMgmt => 'Tidak bisa memuat pengelolaan toko';

  @override
  String get errorLoadShopDetail => 'Tidak bisa memuat detail toko';

  @override
  String get errorLoadMembers => 'Tidak bisa memuat daftar anggota';

  @override
  String get membersRestricted =>
      'Hanya pemilik toko yang bisa melihat daftar anggota';

  @override
  String get errorLoadOrders => 'Tidak bisa memuat pesanan';

  @override
  String get errorLoadOrderDetail => 'Tidak bisa memuat detail pesanan';

  @override
  String get noShopSelectedOrdersDetail =>
      'Pilih toko dulu sebelum melihat pesanan.';

  @override
  String get noShopSelectedRecordDetail => 'Pilih toko dulu sebelum merekam.';

  @override
  String get noShopSelectedManageDetail => 'Pilih toko yang ingin dikelola.';

  @override
  String get noOrdersTitle => 'Belum ada pesanan';

  @override
  String get noOrdersDetail => 'Pilih satu pesanan dari daftar.';

  @override
  String get noVideoDataTitle => 'Tidak ada data video';

  @override
  String get cannotOpenVideoTitle => 'Tidak bisa membuka video';

  @override
  String get cannotOpenVideoDetail => 'Video belum punya tautan pemutaran.';

  @override
  String get createOrderDialogTitle => 'Buat pesanan baru?';

  @override
  String createOrderDialogBody(String code) {
    return '$code tidak cocok dengan nomor resi mana pun di toko ini. Periksa lagi nomornya atau konfirmasi untuk membuat pesanan baru.';
  }

  @override
  String get createOrderConfirm => 'Buat pesanan baru';

  @override
  String get statOrdersToday => 'Pesanan';

  @override
  String get statVideosRecorded => 'Video terekam';

  @override
  String get statPendingUpload => 'Menunggu unggah';

  @override
  String get accountPlanQuota => 'Penyimpanan';

  @override
  String get accountChangePlan => 'Ganti paket';

  @override
  String get accountSectionApp => 'PAKET & APLIKASI';

  @override
  String get accountLanguage => 'Bahasa';

  @override
  String get accountSectionSecurity => 'KEAMANAN & MASUK';

  @override
  String get accountLoginMethods => 'Metode masuk';

  @override
  String get accountSignOut => 'Keluar';

  @override
  String get accountSignOutConfirmTitle => 'Keluar?';

  @override
  String get accountSignOutConfirmMessage =>
      'Anda harus masuk lagi untuk terus memakai aplikasi.';

  @override
  String get accountDeleteAccount => 'Hapus akun';

  @override
  String accountVersion(String version) {
    return 'Versi $version';
  }

  @override
  String get accountShopMgmtHint =>
      'Kelola toko/anggota: ketuk kembali di header untuk kembali ke lapisan Toko';

  @override
  String get accountInfoTitle => 'Info akun';

  @override
  String get accountFullName => 'Nama lengkap';

  @override
  String get accountFullNameHint => 'Masukkan nama lengkap Anda';

  @override
  String get accountFullNameRequired => 'Masukkan nama lengkap Anda';

  @override
  String get phoneOptionalLabel => 'Nomor telepon (opsional)';

  @override
  String get phoneOptionalHint => 'Opsional — hanya untuk dukungan akun';

  @override
  String get phoneInvalid => 'Nomor telepon tidak valid';

  @override
  String get accountSaveChanges => 'Simpan perubahan';

  @override
  String get accountEmailLockedHint => 'Email untuk masuk — tidak bisa diubah';

  @override
  String get commonContinue => 'Lanjutkan';

  @override
  String get commonLater => 'Nanti';

  @override
  String get cameraPermissionRationaleTitle => 'Perlu akses kamera';

  @override
  String get cameraPermissionRationaleBody =>
      'ZenPack perlu kamera untuk merekam video bukti pengemasan pesanan Anda.';

  @override
  String get cameraPermissionDeniedTitle => 'Belum bisa merekam';

  @override
  String get cameraPermissionDeniedBody =>
      'ZenPack tidak bisa merekam video karena akses kamera belum diberikan. Anda tetap bisa menelusuri, mencari dan mengelola pesanan.';

  @override
  String get cameraPermissionOpenSettings => 'Buka Pengaturan';

  @override
  String get languageNameVietnamese => 'Vietnam';

  @override
  String get languageNameEnglish => 'Inggris';

  @override
  String get languageChangeAppliesNote =>
      'Perubahan langsung berlaku di seluruh aplikasi';

  @override
  String get linkLinked => 'Tertaut';

  @override
  String get linkNotLinked => 'Belum tertaut';

  @override
  String get loginMethodsEmailNote =>
      'Email adalah identitas akun Anda — tidak bisa dihapus. Tautkan Google/Apple untuk masuk cepat dengan akun yang sama.';

  @override
  String get loginMethodIdentity => 'Identitas';

  @override
  String get linkAction => 'Tautkan';

  @override
  String get linkUnlink => 'Lepas tautan';

  @override
  String get quotaScreenTitle => 'Laporan & Kuota';

  @override
  String get quotaRemainingThisMonth => 'Sisa bulan ini';

  @override
  String get quotaSubtitle => 'Pantau penyimpanan yang Anda pakai';

  @override
  String quotaRemainingAmount(String amount) {
    return 'sisa $amount';
  }

  @override
  String get quotaStorage => 'Penyimpanan';

  @override
  String get deleteAccountTitleStep1 => 'Hapus akun?';

  @override
  String get deleteAccountTitleStep2 => 'Konfirmasi penghapusan permanen?';

  @override
  String get deleteAccountBodyStep1 =>
      'Semua video, kiriman dan berkas Anda akan dihapus permanen. Tindakan ini tidak bisa dibatalkan.';

  @override
  String get deleteAccountBodyStep2 =>
      'Ini langkah konfirmasi terakhir. Setelah dihapus, Anda langsung keluar dari aplikasi.';

  @override
  String get deleteConfirmPermanent => 'Hapus permanen';

  @override
  String get deleteStep1Hint => 'Langkah 1/2 — akan diminta konfirmasi lagi';

  @override
  String get deleteStep2Hint =>
      'Langkah 2/2 — tindakan ini tidak bisa dibatalkan';

  @override
  String get passwordCurrentLabel => 'Kata sandi saat ini';

  @override
  String get passwordCurrentRequired => 'Masukkan kata sandi Anda saat ini';

  @override
  String get passwordNewLabel => 'Kata sandi baru';

  @override
  String get passwordMinHint => 'Minimal 8 karakter';

  @override
  String get passwordNewRequired => 'Masukkan kata sandi baru';

  @override
  String get passwordMin8Error => 'Kata sandi minimal 8 karakter';

  @override
  String get passwordNeedsLetterDigit =>
      'Kata sandi harus berisi huruf dan angka';

  @override
  String get passwordTooCommon =>
      'Kata sandi itu terlalu mudah ditebak — pilih yang lain';

  @override
  String get passwordConfirmLabel => 'Ulangi kata sandi baru';

  @override
  String get passwordMismatch => 'Kata sandi tidak cocok';

  @override
  String get passwordSave => 'Simpan kata sandi';

  @override
  String get passwordChangeLogoutNote =>
      'Anda akan keluar dari perangkat lain setelah mengubahnya';

  @override
  String get navOrders => 'Pesanan';

  @override
  String get navRecord => 'Rekam';

  @override
  String get navAccount => 'Akun';

  @override
  String get navClaims => 'Klaim';

  @override
  String get changeAvatar => 'Ganti foto profil';

  @override
  String quotaVideosRatio(int remaining, int total) {
    return '$remaining / $total video';
  }

  @override
  String quotaUsedPercent(int percent) {
    return 'Terpakai $percent%';
  }

  @override
  String quotaRetentionDays(int days) {
    return '$days hari';
  }

  @override
  String quotaUsedRatio(String used, String cap, int percent) {
    return 'Terpakai $used / $cap · $percent%';
  }

  @override
  String get quotaVideosStored => 'Video tersimpan';

  @override
  String quotaVideosStoredCount(int count) {
    return '$count video';
  }

  @override
  String get quotaByType => 'Penyimpanan menurut jenis';

  @override
  String quotaByTypeVideosCount(int count) {
    return '$count video tersimpan';
  }

  @override
  String quotaRefundNote(int days) {
    return 'Penyimpanan dibebaskan setelah video melewati masa simpan $days hari';
  }

  @override
  String deletePendingProfilesWarning(int count) {
    return 'Anda masih punya $count berkas “dikirim ke platform” — tautan berbaginya akan berhenti bekerja';
  }

  @override
  String get detailRecordedTime => 'Waktu perekaman';

  @override
  String get detailDuration => 'Durasi';

  @override
  String get detailRecordedBy => 'Direkam oleh';

  @override
  String get detailCapturedTime => 'Waktu pengambilan';

  @override
  String get detailCapturedBy => 'Diambil oleh';

  @override
  String get detailDevice => 'Perangkat';

  @override
  String get detailSize => 'Ukuran';

  @override
  String get detailUploadStatus => 'Status unggah';

  @override
  String get detailSeal => 'Segel';

  @override
  String sealSealed(String at) {
    return 'Terkunci · $at';
  }

  @override
  String get sealWorking => 'Menyematkan stempel waktu…';

  @override
  String get sealWorkingHint =>
      'Salinan tersimpan belum punya stempel waktu di gambarnya, jadi tautan berbagi dan unduh menunggu dulu. Biasanya beberapa detik.';

  @override
  String get playLocalCopyNote =>
      'Salinan sementara di perangkat ini — gambarnya belum berstempel waktu';

  @override
  String get sealNone => 'Direkam sebelum fitur segel ada';

  @override
  String get sealFailed =>
      'Stempel waktu belum tersemat · video tetap bisa diputar dan diunduh';

  @override
  String get sealMismatch => 'Sidik jari tidak cocok — rekam ulang klip ini';

  @override
  String get sealTimeDrift =>
      'Jam kamera meleset dari server, jadi stempel yang disematkan juga memuat waktu server menerima klip.';

  @override
  String get detailSealAnchor => 'Bukti independen';

  @override
  String sealAnchorConfirmed(String block) {
    return 'Ya · entri #$block';
  }

  @override
  String get sealAnchorConfirmedNoBlock => 'Ya';

  @override
  String get sealAnchorPending =>
      'Sedang ditulis ke buku besar publik (beberapa jam)';

  @override
  String get sealAnchorNone => 'Tidak ada';

  @override
  String get sealVerifyOpen => 'Buka halaman verifikasi';

  @override
  String get sealVerifyHint =>
      'Kirim tautan ini ke marketplace — mereka bisa memverifikasi sendiri, tanpa harus percaya ZenPack.';

  @override
  String get sealVerifyFailed => 'Tidak bisa membuka halaman verifikasi.';

  @override
  String get detailPlayVideo => 'Putar video';

  @override
  String get detailCopyAssetLink => 'Salin tautan';

  @override
  String get assetLinkTitle => 'Tautan bukti';

  @override
  String get detailDownloadVideo => 'Unduh video';

  @override
  String get detailDownloadNote =>
      'Hanya pemilik/pengelola · untuk saat marketplace meminta file asli';

  @override
  String get detailTrimVideo => 'Potong klip pendek untuk dikirim';

  @override
  String get detailTrimNote =>
      'Klip lengkap tetap utuh · potongannya tetap berstempel waktu';

  @override
  String get trimSave => 'Simpan';

  @override
  String get trimEstimatedSize => 'Sekitar';

  @override
  String get trimFailed => 'Tidak bisa memotong video. Klip lengkap masih ada.';

  @override
  String get trimPreparing => 'Mengunduh klip lengkap…';

  @override
  String get detailDownloadPhoto => 'Unduh foto';

  @override
  String get attachPhotoToOrder => 'Lampirkan foto ke pesanan';

  @override
  String get deleteVideoAction => 'Hapus video';

  @override
  String get deletePhotoAction => 'Hapus foto';

  @override
  String get deleteVideoNote =>
      'Hanya pemilik/pengelola · terkunci saat ada berkas terbuka · konfirmasi dua langkah';

  @override
  String get deleteVideoConfirmTitle => 'Konfirmasi akhir';

  @override
  String get deleteVideoConfirmBody =>
      'Bukti ini akan dihapus permanen dan tidak bisa dipulihkan — tetap hapus?';

  @override
  String get deleteVideoConfirmAction => 'Hapus permanen';

  @override
  String ordersErrorCount(int count) {
    return '· $count kesalahan';
  }

  @override
  String ordersPendingCount(int count) {
    return '· $count menunggu';
  }

  @override
  String ordersPendingEvidenceWarning(int count) {
    return '$count bukti belum diunggah · belum ada tautan untuk disalin';
  }

  @override
  String get captureFramePrompt => 'Pindai nomor resi';

  @override
  String get captureCameraDownHint => 'Letakkan resi di dalam bingkai';

  @override
  String get cutoverSavedVideo => 'Video tersimpan';

  @override
  String get cutoverPreparingNext => 'Bersiap untuk yang berikutnya';

  @override
  String get cutoverNextOrder => 'Pesanan berikutnya';

  @override
  String get lowStorageTitle => 'Penyimpanan hampir penuh';

  @override
  String get lowStorageBody =>
      'Penyimpanan perangkat ini menipis — rekaman yang sedang berjalan mungkin tidak tersimpan penuh. Kosongkan ruang sebelum lanjut merekam.';

  @override
  String get lowStorageAction => 'Mengerti';

  @override
  String cutoverClosedSummary(String code, String duration) {
    return 'Nomor resi $code ditutup ($duration)';
  }

  @override
  String get cutoverSignalText => 'Suara + getar saat berpindah pesanan';

  @override
  String get tooltipBack => 'Kembali';

  @override
  String get tooltipSwitchCamera => 'Ganti kamera';

  @override
  String get tooltipEnterTracking => 'Masukkan nomor resi';

  @override
  String get tooltipZoomIn => 'Perbesar';

  @override
  String get tooltipZoomOut => 'Perkecil';

  @override
  String get captureResolution => 'Resolusi';

  @override
  String get stopRecording => 'Berhenti merekam';

  @override
  String get videoTypeSettings => 'Pengaturan jenis video';

  @override
  String get uploadQueueTitle => 'Antrean unggah';

  @override
  String get quotaExhaustedNote =>
      'Jatah bulanan habis. Perekaman tetap jalan, tapi klip ini ADA DI PONSEL INI dan belum terlindungi — klip akan terunggah sendiri begitu jatah dinaikkan.';

  @override
  String get queueEmpty => 'Belum ada video di antrean';

  @override
  String get queueAutoUploadNote =>
      'Unggahan berjalan otomatis saat Anda online';

  @override
  String get waitingUpload => 'Menunggu diunggah';

  @override
  String get uploaded => 'Terunggah';

  @override
  String get waitingQuota => 'Menunggu jatah · masih di perangkat';

  @override
  String get pausedUpload => 'Dijeda';

  @override
  String get queuePauseAction => 'Jeda';

  @override
  String get queueResumeAction => 'Lanjutkan';

  @override
  String get queueDeleteAction => 'Keluarkan';

  @override
  String get queueClearAction => 'Hapus semua';

  @override
  String get queueClearConfirmTitle => 'Hapus seluruh antrean?';

  @override
  String get queueClearConfirmBody =>
      'Klip yang belum diunggah hanya ada di ponsel ini. Menghapusnya berarti hilang selamanya.';

  @override
  String get queueDeleteConfirmTitle => 'Keluarkan dari antrean?';

  @override
  String get queueDeleteConfirmBody =>
      'Klip ini belum diunggah — mengeluarkannya akan menghapusnya dari perangkat secara permanen.';

  @override
  String get toastQueueItemDeleted => 'Dikeluarkan dari antrean unggah';

  @override
  String get manualTrackingTitle => 'Masukkan nomor resi';

  @override
  String get manualTrackingNote => 'Ketik atau pindai kodenya lagi';

  @override
  String get commonDone => 'Selesai';

  @override
  String get startRecording => 'Mulai merekam';

  @override
  String get returnCodeMismatch => 'Kode retur tidak cocok';

  @override
  String get enterCodeManually => 'Masukkan kode manual';

  @override
  String get videoTypeLabel => 'Jenis video';

  @override
  String get videoTypeSelectNote =>
      'Pilih jenis yang tepat — tambah/ubah/hapus di Detail toko';

  @override
  String get videoTypeSheetTitle => 'Pilih jenis video';

  @override
  String get videoTypeGroupDefault => 'Jenis bawaan (wajib)';

  @override
  String get videoTypeGroupCustom => 'Jenis khusus toko';

  @override
  String get manageVideoTypesNote => 'Kelola jenis video — buka Detail toko';

  @override
  String queueFilterAll(int count) {
    return 'Semua ($count)';
  }

  @override
  String queueFilterUploading(int count) {
    return 'Mengunggah ($count)';
  }

  @override
  String queueFilterErrored(int count) {
    return 'Kesalahan ($count)';
  }

  @override
  String queueFilterQuotaWait(int count) {
    return 'Menunggu jatah ($count)';
  }

  @override
  String queueSummary(int pending, int uploading, int errored) {
    return '$pending video menunggu · $uploading diunggah · $errored gagal';
  }

  @override
  String uploadingProgress(int percent) {
    return 'Mengunggah $percent%';
  }

  @override
  String errorRetryCount(int count) {
    return 'Kesalahan · Coba lagi ($count)';
  }

  @override
  String returnCodeMismatchBody(String returnCode, String shopName) {
    return '$returnCode tidak cocok dengan pesanan mana pun di $shopName. Periksa lagi kodenya, masukkan manual, atau konfirmasi untuk membuat pesanan baru.';
  }

  @override
  String get onboardingSubtitle =>
      'Rekam video bukti pengemasan untuk penjual e-commerce';

  @override
  String get onboardingStart => 'Mulai';

  @override
  String get authSignIn => 'Masuk';

  @override
  String get authChooseMethod => 'Pilih metode masuk';

  @override
  String get authEmailRequired => 'Masukkan email Anda';

  @override
  String get authEmailInvalid => 'Email tidak valid';

  @override
  String get authPassword => 'Kata sandi';

  @override
  String get authPasswordRequired => 'Masukkan kata sandi Anda';

  @override
  String get authForgotPassword => 'Lupa kata sandi?';

  @override
  String get registerWithGoogle => 'Daftar dengan Google';

  @override
  String get registerWithApple => 'Daftar dengan Apple';

  @override
  String get authSignInGoogle => 'Masuk dengan Google';

  @override
  String get authSignInApple => 'Masuk dengan Apple';

  @override
  String get authNoAccountPrompt => 'Belum punya akun? ';

  @override
  String get authRegister => 'Daftar';

  @override
  String get authOr => 'atau';

  @override
  String get registerTitle => 'Buat akun baru';

  @override
  String get registerConfirmPassword => 'Ulangi kata sandi';

  @override
  String get registerAgreePolicy => 'Saya setuju dengan kebijakan ';

  @override
  String get registerViewPolicy => 'Lihat kebijakan';

  @override
  String get registerCreateAccount => 'Buat akun';

  @override
  String get registerSameEmailNote =>
      'Email yang sama otomatis tertaut ke satu akun';

  @override
  String get registerHaveAccountPrompt => 'Sudah punya akun? ';

  @override
  String get registerSuccessTitle => 'Akun dibuat';

  @override
  String registerSuccessVerifyMessage(String email) {
    return 'Kami mengirim email verifikasi ke $email. Periksa kotak masuk (termasuk spam), lalu masuk.';
  }

  @override
  String get registerSuccessMessage =>
      'Akun Anda siap. Masuk dengan email dan kata sandi yang baru didaftarkan.';

  @override
  String get registerSuccessAction => 'Masuk';

  @override
  String get loginNotVerifiedTitle => 'Email belum diverifikasi';

  @override
  String loginNotVerifiedMessage(String email) {
    return 'Buka email verifikasi yang dikirim ke $email (periksa spam juga), ikuti tautannya, lalu masuk lagi.';
  }

  @override
  String get loginResendVerification => 'Kirim ulang email';

  @override
  String get loginVerificationResent => 'Email verifikasi dikirim ulang';

  @override
  String get forgotPasswordTitle => 'Lupa kata sandi';

  @override
  String get forgotPasswordSubtitle =>
      'Masukkan email Anda untuk menerima tautan atur ulang kata sandi';

  @override
  String get forgotPasswordSubmit => 'Kirim tautan atur ulang';

  @override
  String get forgotPasswordSent =>
      'Terkirim — periksa kotak masuk (termasuk spam)';

  @override
  String get forgotPasswordRememberPrompt => 'Ingat kata sandi Anda? ';

  @override
  String get shopYourShops => 'Toko Anda';

  @override
  String get shopTapToClockIn =>
      'Ketuk toko untuk mulai kerja · kelola di sini juga';

  @override
  String get shopLastOpenedNote =>
      'Toko yang terakhir dibuka akan langsung terbuka lain kali';

  @override
  String get shopManageStore => 'Kelola toko';

  @override
  String get shopManageVisibilityNote =>
      'Hanya terlihat oleh pemilik akun / pengelola toko';

  @override
  String get shopEmpty => 'Belum ada toko';

  @override
  String get shopEmptyBody =>
      'Akun Anda belum tergabung ke toko mana pun. Buat toko baru untuk memulai, atau tunggu undangan dari pemilik toko.';

  @override
  String get shopCreateNew => 'Buat toko baru (nama + marketplace)';

  @override
  String get shopInvitesHere => 'Undangan toko akan muncul di sini';

  @override
  String get shopCreateTitle => 'Buat toko';

  @override
  String get shopNameLabel => 'Nama toko';

  @override
  String get shopNameRequired => 'Masukkan nama toko';

  @override
  String get shopPlatform => 'Marketplace';

  @override
  String get shopCreateOwnerNote =>
      'Anda akan menjadi pemilik toko — tambahkan anggota nanti di Kelola toko';

  @override
  String get shopMgmtVisibilityNote =>
      'Karyawan tidak melihat layar ini · pengelola toko hanya melihat toko yang dikelolanya';

  @override
  String get shopAddNew => 'Tambah toko baru';

  @override
  String get sectionMembers => 'ANGGOTA';

  @override
  String get sectionShopSettings => 'PENGATURAN TOKO';

  @override
  String get sectionVideoTypes => 'JENIS VIDEO';

  @override
  String get videoTypesLockedNote =>
      '3 jenis bawaan terkunci — tidak bisa diubah/dihapus';

  @override
  String get addMemberByContact => 'Tambah anggota lewat email/telepon';

  @override
  String get recordResolution => 'Resolusi perekaman';

  @override
  String get addVideoType => 'Tambah jenis (isi nama)';

  @override
  String get createVideoTypeTitle => 'Buat jenis video';

  @override
  String get videoTypeName => 'Nama jenis video';

  @override
  String get videoTypeNameHint => 'misalnya Penimbangan';

  @override
  String get createVideoType => 'Buat jenis';

  @override
  String get deleteVideoTypeBody =>
      'Hanya bisa dihapus selama jenis ini belum punya video. Kalau sudah ada videonya, sistem menahan penghapusan agar filter bukti dan statistik tidak kacau.';

  @override
  String get deleteVideoTypeConfirm => 'Hapus jenis';

  @override
  String get deleteVideoTypeNote =>
      '(Hanya bisa dihapus selama jenis ini belum punya video)';

  @override
  String get addMemberTitle => 'Tambah anggota';

  @override
  String get addMemberBody =>
      'Masukkan email akun ZenPack yang sudah terdaftar. Mereka menerima undangan dan harus mengonfirmasi untuk bergabung ke toko.';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailRequired => 'Masukkan alamat email.';

  @override
  String get emailInvalid => 'Masukkan satu alamat email yang valid.';

  @override
  String get errorInviteAccountNotFound =>
      'Email ini belum punya akun ZenPack. Minta mereka mendaftar dulu, lalu undang lagi.';

  @override
  String get errorInviteAlreadyMember => 'Dia sudah menjadi anggota toko ini.';

  @override
  String get errorInviteMemberLimit =>
      'Batas anggota paket ini sudah penuh. Undangan yang belum dijawab ikut terhitung — cabut satu untuk mengosongkan slot.';

  @override
  String get errorInviteAlreadyOwner =>
      'Itu pemilik toko — tidak perlu diundang.';

  @override
  String get errorInviteInvalidRequest =>
      'Email itu tidak valid. Periksa lalu kirim lagi.';

  @override
  String get addMemberSubmit => 'Tambah';

  @override
  String get memberOwnerLocked =>
      'Pemilik tidak bisa diubah perannya atau dikeluarkan di sini — kepemilikan melekat pada toko, bukan pada baris keanggotaan.';

  @override
  String get removeFromShop => 'Keluarkan dari toko';

  @override
  String get revokeInvite => 'Hapus undangan';

  @override
  String get resolutionAppliesNote =>
      'Berlaku untuk video toko yang direkam setelah ini';

  @override
  String get resolutionDefaultOption => '720p (bawaan)';

  @override
  String get ordersSearchHint => 'Masukkan nomor resi';

  @override
  String get ordersEmpty => 'Toko ini belum punya pesanan';

  @override
  String recordAutoStopIn(String time) {
    return 'Berhenti otomatis dalam $time';
  }

  @override
  String get ordersNotFound => 'Pesanan tidak ditemukan';

  @override
  String get ordersNotFoundHint => 'Periksa lagi nomor resinya lalu coba lagi';

  @override
  String ordersPageRange(int first, int last, int total) {
    return '$first–$last dari $total pesanan';
  }

  @override
  String get ordersPagePrevious => 'Halaman sebelumnya';

  @override
  String get ordersPageNext => 'Halaman berikutnya';

  @override
  String ordersPageNumber(int page) {
    return 'Halaman $page';
  }

  @override
  String get filterStatusLabel => 'Status';

  @override
  String get filterStatusAll => 'Semua';

  @override
  String get filterStatusPending => 'Menunggu unggah';

  @override
  String get filterStatusError => 'Kesalahan unggah';

  @override
  String get filterStatusDone => 'Terunggah penuh';

  @override
  String get filterTimeLabel => 'Waktu';

  @override
  String get filterTimeAll => 'Kapan saja';

  @override
  String get filterTimeToday => 'Hari ini';

  @override
  String get filterTimeYesterday => 'Kemarin';

  @override
  String get filterTime7d => '7 hari terakhir';

  @override
  String get filterTime30d => '30 hari terakhir';

  @override
  String get filterTimePickDate => 'Pilih tanggal…';

  @override
  String get filterTypeLabel => 'Jenis video';

  @override
  String get filterTypeAll => 'Semua';

  @override
  String deleteVideoTypeTitle(String typeName) {
    return 'Hapus jenis \"$typeName\"?';
  }

  @override
  String memberCurrentRole(String role) {
    return 'Peran saat ini: $role';
  }

  @override
  String get stopCodeTitle => 'Kode QR berhenti merekam';

  @override
  String get stopCodeInstructions =>
      'Cetak ini dan tempel di meja pengemasan. Tunjukkan ke kamera saat merekam untuk berhenti otomatis.';

  @override
  String get scannedCodeNotFound =>
      'Tidak ada pesanan yang cocok dengan kode yang dipindai';

  @override
  String get onboardingTaglineOne => 'Setiap paket.';

  @override
  String get onboardingTaglineTwo => 'Satu bukti.';

  @override
  String get onboardingTaglineThree => 'Melindungi pendapatan Anda.';

  @override
  String get authEmailPlaceholder => 'Masukkan email Anda';

  @override
  String get authPasswordPlaceholder => 'Masukkan kata sandi Anda';

  @override
  String get registerCreateAccountSubtitle => 'Buat akun baru';

  @override
  String get registerFullName => 'Nama lengkap';

  @override
  String get registerFullNameRequired => 'Masukkan nama lengkap Anda';

  @override
  String get registerAgreePrefix => 'Saya setuju dengan';

  @override
  String get registerTermsOfUse => 'Ketentuan Penggunaan';

  @override
  String get shopChooseTitle => 'Pilih toko';

  @override
  String get shopChooseSubtitle => 'Pilih toko untuk melanjutkan';

  @override
  String get shopManageTitle => 'Kelola toko';

  @override
  String get shopManageOwnerOnly =>
      'Hanya terlihat oleh pemilik dan pengelola toko';

  @override
  String get noShopTitle => 'Belum ada toko';

  @override
  String get noShopLineOne => 'Akun Anda belum tergabung ke toko mana pun.';

  @override
  String get noShopLineTwo => 'Buat toko untuk memulai,';

  @override
  String get noShopLineThree => 'atau tunggu undangan dari pemilik toko.';

  @override
  String get noShopCreateCta => 'Buat toko (nama + marketplace)';

  @override
  String get noShopInviteHint => 'Undangan toko akan muncul di sini';

  @override
  String get createShopTitle => 'Buat toko';

  @override
  String get createShopNameLabel => 'Nama toko';

  @override
  String get createShopNameHint => 'misalnya Toko ABC';

  @override
  String get createShopPlatformLabel => 'Marketplace';

  @override
  String get createShopOwnerNote =>
      'Anda akan menjadi pemilik toko — tambahkan anggota nanti di Kelola toko';

  @override
  String get createShopSubmit => 'Buat toko';

  @override
  String get shopManageDescription =>
      'Lihat dan kelola toko yang Anda administrasikan.';

  @override
  String get shopManageAddCta => 'Tambah toko';

  @override
  String get shopManageStaffNote =>
      'Karyawan tidak bisa melihat layar ini — hanya pemilik dan pengelola toko.';

  @override
  String get shopDetailTitle => 'Detail toko';

  @override
  String get shopDetailResolution => 'Resolusi perekaman';

  @override
  String get shopDetailClipDuration => 'Durasi maks/video';

  @override
  String clipDurationValue(String minutes) {
    return '$minutes mnt';
  }

  @override
  String clipRecommendedHint(
    String minutes,
    String platform,
    String megabytes,
    String resolution,
  ) {
    return 'Disarankan $minutes mnt — untuk $platform ($megabytes MB/video) + $resolution';
  }

  @override
  String clipRecommendedHintUnverified(String minutes, String platform) {
    return 'Disarankan $minutes mnt — batas $platform belum dipastikan, memakai nilai teraman yang diketahui';
  }

  @override
  String clipOverRecommendedWarning(
    String minutes,
    String platform,
    String chosen,
    String megabytes,
  ) {
    return 'Melebihi saran $minutes mnt untuk $platform — video $chosen mnt kira-kira $megabytes MB, jadi harus dikirim sebagai tautan berkas, bukan dilampirkan ke formulir komplain.';
  }

  @override
  String get clipDurationTitle => 'Durasi maksimum per video';

  @override
  String get clipDurationSubtitle => 'Otomatis berhenti pada durasi ini';

  @override
  String clipDurationPlanCap(String minutes) {
    return 'Paket Anda mengizinkan sampai $minutes mnt';
  }

  @override
  String clipDurationChanged(String minutes) {
    return 'Durasi maks/video: $minutes mnt';
  }

  @override
  String get shopDetailImageSize => 'Ukuran gambar';

  @override
  String get shopDetailVideoSize => 'Ukuran video';

  @override
  String get shopDetailUploadSize => 'Ukuran maks/file';

  @override
  String uploadSizeValue(String megabytes) {
    return '$megabytes MB';
  }

  @override
  String uploadRecommendedHint(String megabytes, String platform) {
    return 'Disarankan $megabytes MB — batas lampiran $platform';
  }

  @override
  String uploadOverRecommendedWarning(
    String megabytes,
    String platform,
    String chosen,
  ) {
    return 'Melebihi saran $megabytes MB untuk $platform — file sampai $chosen MB tetap disimpan utuh, tapi harus dikirim sebagai tautan berkas, bukan dilampirkan ke formulir komplain.';
  }

  @override
  String get uploadSizeValueUnlimited => 'Tanpa batas';

  @override
  String get uploadSizeTitle => 'Ukuran maksimum per file';

  @override
  String uploadSizeSubtitle(String megabytes, String platform) {
    return 'File di atas batas tidak dilampirkan; $megabytes MB masih bisa langsung dilampirkan ke $platform';
  }

  @override
  String uploadSizeOptionRecommended(String megabytes) {
    return '$megabytes MB (disarankan)';
  }

  @override
  String uploadSizeChanged(String megabytes) {
    return 'Ukuran per file: $megabytes';
  }

  @override
  String avatarTooLarge(String megabytes, String limit) {
    return 'Nama dan telepon tersimpan. Foto profil $megabytes MB melebihi batas $limit MB, jadi tidak sampai ke server — pilih gambar yang lebih kecil.';
  }

  @override
  String avatarUploadFailed(String reason) {
    return 'Nama dan telepon tersimpan. Foto profil tidak sampai ke server: $reason';
  }

  @override
  String nearClipLimitWarning(String minutes) {
    return 'Mendekati batas $minutes mnt — video akan menutup sendiri';
  }

  @override
  String get shopDetailAddType => 'Tambah jenis (isi nama)';

  @override
  String get inviteMemberTitle => 'Undang anggota';

  @override
  String get inviteRoleFixedNote =>
      'Dia bergabung sebagai karyawan: merekam video dan meninjau miliknya sendiri.';

  @override
  String get inviteMemberHint => '(belum punya akun → kirim undangan)';

  @override
  String get videoTypeIcon => 'Ikon';

  @override
  String get videoTypeColor => 'Warna';

  @override
  String get createVideoTypeSubmit => 'Buat jenis';

  @override
  String get deleteVideoTypeSafeNote => 'Tidak ada bukti yang hilang';

  @override
  String get commonConfirm => 'Konfirmasi';

  @override
  String orderErrorCount(int count) {
    return '$count gagal';
  }

  @override
  String get videoDetailSheetTitle => 'Detail video';

  @override
  String get tooltipStopRecording => 'Berhenti merekam';

  @override
  String get dossierLinkTitle => 'Tautan berkas sengketa';

  @override
  String get accountEndQr => 'Kode berhenti merekam';

  @override
  String get accountEndQrTitle => 'Kode berhenti merekam';

  @override
  String get accountEndQrShare => 'Bagikan kode';

  @override
  String get accountEndQrSave => 'Simpan ke galeri foto';

  @override
  String get recordInterruptedTitle => 'Perekaman dijeda';

  @override
  String get recordInterruptedBody =>
      'Perekaman dijeda karena ada yang menginterupsi. Lanjutkan merekam?';

  @override
  String get recordInterruptedResume => 'Lanjutkan';

  @override
  String get recordInterruptedFinish => 'Selesai';

  @override
  String get commonApply => 'Terapkan';

  @override
  String get unitMinutes => 'mnt';

  @override
  String get clipDurationCustomLabel =>
      'Atau masukkan jumlah menit yang Anda mau';

  @override
  String get supportOpenFailed =>
      'Tidak bisa dibuka — pastikan aplikasinya terpasang';

  @override
  String get feedbackThanksTitle => 'Terima kasih!';

  @override
  String get feedbackThanksBody =>
      'Masukan Anda membantu ZenPack jadi lebih baik.';

  @override
  String get feedbackTitle => 'Apa yang ingin Anda sampaikan?';

  @override
  String get feedbackHint => 'Tulis masukan Anda...';

  @override
  String get feedbackSend => 'Kirim masukan';

  @override
  String get feedbackThanks => 'Terima kasih atas masukan Anda';

  @override
  String get accountSectionAbout => 'TENTANG';

  @override
  String get accountFeedback => 'Kirim masukan';

  @override
  String get accountFeedbackNote =>
      'Bagikan pendapat Anda agar ZenPack jadi lebih baik';

  @override
  String get accountRateApp => 'Beri nilai aplikasi';

  @override
  String get accountRateAppNote => 'Dukung pengembangan ZenPack';

  @override
  String get supportFacebook => 'Kirim pesan di Facebook';

  @override
  String get supportZalo => 'Kirim pesan di Zalo';

  @override
  String get supportCall => 'Telepon dukungan';

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
      'Cetak ini dan tempel di meja pengemasan. Memindainya saat merekam akan menutup klip. Kode yang sama berlaku di semua perangkat.';

  @override
  String get languageChangeScopeNote =>
      'Setiap label, notifikasi dan berkas\nberubah ke bahasa yang Anda pilih.';

  @override
  String get manualEntryEmptyError => 'Masukkan nomor resi sebelum merekam';

  @override
  String get appUpdateTitle => 'Versi baru tersedia';

  @override
  String get appUpdateMessage =>
      'Perbarui ZenPack untuk perbaikan dan fitur terbaru.';

  @override
  String get appUpdateNow => 'Perbarui';

  @override
  String get appUpdateLater => 'Nanti';

  @override
  String get quotaVideosThisMonth => 'Video bulan ini';

  @override
  String get quotaSubtitleVideos =>
      'Pantau berapa video yang Anda rekam bulan ini';

  @override
  String get quotaUpgrade => 'Tingkatkan paket';

  @override
  String get quotaBlockedTitle => 'Jatah video habis';

  @override
  String get quotaBlockedNote =>
      'Perekaman tetap jalan, tapi klip belum bisa diunggah — klip ada di ponsel ini, belum terlindungi. Klip akan terunggah sendiri begitu jatah dinaikkan.';

  @override
  String get quotaBlockedOwnerNote =>
      'Kuota toko ini ditetapkan oleh pemilik akun — mintalah mereka menaikkannya. Paket yang Anda beli hanya berlaku untuk akun Anda sendiri.';

  @override
  String get quotaTopupCredits => 'Isi ulang kredit';

  @override
  String get quotaOverCap => 'Melebihi jatah paket';

  @override
  String quotaBlockAt(int n) {
    return 'Perekaman baru diblokir pada $n video';
  }

  @override
  String get quotaResetMonthly =>
      'Diatur ulang di awal bulan depan; tidak ada sisa yang dibawa';

  @override
  String get storageOwnTitle => 'Penyimpanan milik Anda';

  @override
  String storageOwnPending(int count) {
    return '$count video menunggu dikirim ke penyimpanan Anda';
  }

  @override
  String storageOwnProblem(int count) {
    return '$count video di penyimpanan Anda bermasalah';
  }

  @override
  String get quotaExhaustedWarn =>
      'Jangan hapus aplikasi atau bersihkan datanya sampai semuanya terunggah.';

  @override
  String quotaStrandedTitle(int count) {
    return '$count video menunggu di ponsel ini';
  }

  @override
  String get quotaStrandedNote =>
      'Video ini hanya ada di ponsel ini. Kehilangan ponsel, menghapus aplikasi atau membersihkan datanya akan menghilangkannya.';

  @override
  String get storageTitle => 'Penyimpanan video';

  @override
  String get storageSystemName => 'Penyimpanan sistem';

  @override
  String get storageS3Name => 'Penyimpanan Anda sendiri (S3)';

  @override
  String get storageDriveName => 'Google Drive Anda';

  @override
  String get storageSystemDesc =>
      'Pilihan bawaan; tidak perlu diatur. Hanya di sini semua jaminan bukti tetap berlaku.';

  @override
  String get storageOwnDesc =>
      'Video baru langsung masuk ke penyimpanan Anda. Yang lama tetap di tempatnya sampai masa simpannya berakhir.';

  @override
  String get storageNoPresign =>
      'Penyimpanan ini tidak bisa menandatangani tautan unduh, jadi video harus dilewatkan lewat server — siapa pun yang membuka tautan Anda akan merasa lebih lambat.';

  @override
  String get storageNoObjectLock =>
      'Penyimpanan ini tidak punya penguncian objek. Anda tidak bisa menjanjikan ke marketplace bahwa buktinya tidak bisa dihapus.';

  @override
  String get storageNotInPlan =>
      'Paket Anda belum termasuk penyimpanan sendiri. Tingkatkan paket di web untuk memakainya.';

  @override
  String get storageHealthTitle => 'Kesehatan penyimpanan';

  @override
  String get storageHealthTotal => 'Total video';

  @override
  String get storageHealthIntact => 'Utuh';

  @override
  String get storageHealthUnreachable => 'Tidak terjangkau';

  @override
  String get storageHealthMismatched => 'Tidak cocok dengan segel';

  @override
  String get storageHealthPendingRelay => 'Menunggu di area relay';

  @override
  String get storageProblemsNote =>
      'Beberapa video bermasalah di penyimpanan Anda. Periksa izin akses di sisi penyedia.';

  @override
  String get storageTest => 'Uji ulang koneksi';

  @override
  String get storageInUse => 'Sedang dipakai';

  @override
  String storageLastCheckAt(String time) {
    return 'Audit terakhir: $time';
  }

  @override
  String get storageNeverChecked => 'Belum pernah diaudit.';

  @override
  String get storageDriveAccount => 'Akun Drive';

  @override
  String get storageDisconnect => 'Berhenti memakai penyimpanan sendiri';

  @override
  String get storageDisconnectConfirm =>
      'Video yang direkam mulai sekarang masuk ke penyimpanan sistem. Yang lama tetap di penyimpanan Anda dan sistem kehilangan jalur ke sana.';

  @override
  String get storageConnectS3 => 'Hubungkan penyimpanan S3';

  @override
  String get storageConnectDrive => 'Hubungkan Google Drive';

  @override
  String get storageConnectHint =>
      'Beri izin baca/tulis/hapus hanya pada prefix di bawah — tidak perlu izin untuk seluruh bucket.';

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
      'Sub-folder di dalam bucket. Biarkan bawaan kalau ragu.';

  @override
  String get storageConnected => 'Penyimpanan sendiri terhubung.';

  @override
  String get storageDisconnected => 'Penyimpanan sendiri diputus.';

  @override
  String get storageTestOk => 'Koneksi sehat.';

  @override
  String get storageOwnerOnly =>
      'Hanya pemilik toko yang bisa mengubah penyimpanan.';

  @override
  String get dangerZone => 'Zona berbahaya';

  @override
  String get shopDelete => 'Hapus toko';

  @override
  String get shopDeleteDesc =>
      'Menghapus permanen pesanan, bukti, file tersimpan dan anggota. Ini tidak bisa dibatalkan.';

  @override
  String get shopDeleteConfirmTitle => 'Hapus toko ini?';

  @override
  String shopDeleteConfirmBody(int orders, int videos, int members) {
    return '$orders pesanan · $videos video · $members anggota akan dihapus permanen.';
  }

  @override
  String shopDeleteOpenDossiers(int n) {
    return '$n berkas klaim masih terbuka. Tautan yang sudah dikirim ke marketplace mati begitu Anda menghapus.';
  }

  @override
  String get shopDeleteForce => 'Tetap hapus';

  @override
  String get shopDeleteFailed => 'Tidak bisa menghapus toko.';

  @override
  String get claimsCreatedLocalOnly =>
      'Berkas tersimpan di ponsel ini. Berkas belum bisa diunggah, jadi belum ada tautan berbagi — buka lagi saat Anda kembali online.';

  @override
  String get claimsLinkCopied =>
      'Tautan berkas disalin. Tempel ke kanal klaim marketplace.';

  @override
  String get shopRenameTitle => 'Ubah nama toko';

  @override
  String get shopRenameHint => 'Nama toko';

  @override
  String get shopRenamed => 'Nama toko diubah';

  @override
  String get commonSave => 'Simpan';

  @override
  String get inviteJoinRow => 'Saya punya undangan';

  @override
  String inviteJoinedShop(String shop) {
    return 'Bergabung ke $shop';
  }

  @override
  String inviteAlreadyJoined(String shop) {
    return 'Anda sudah ada di $shop';
  }

  @override
  String get inviteBadLink =>
      'Tautan itu tidak valid. Tempel seluruh tautan dari email.';

  @override
  String get inviteNotFound => 'Undangan tidak ada atau sudah dicabut';

  @override
  String get inviteTaken => 'Orang lain sudah menerima undangan ini';

  @override
  String get inviteExpired =>
      'Undangan sudah kedaluwarsa. Minta pemilik toko mengirim ulang.';

  @override
  String get inviteQrRow => 'Kode QR';

  @override
  String get inviteScanTitle => 'Pindai kode undangan';

  @override
  String get inviteScanDetail =>
      'Minta pemilik toko menunjukkan kode QR undangan, lalu pindai di sini.';

  @override
  String get commonShare => 'Bagikan';

  @override
  String get inviteQrSaved => 'Kode QR disimpan ke galeri Anda';

  @override
  String get inviteQrSaveFailed => 'Tidak bisa menyimpan kode QR';

  @override
  String get voiceRecordingStarted => 'Perekaman dimulai';

  @override
  String get voiceRecordingStopped => 'Perekaman dihentikan';

  @override
  String get voiceWrongCode => 'Kode salah';

  @override
  String get voiceCapSoon => 'Video akan segera ditutup';

  @override
  String voiceCapNear(int minutes) {
    return 'Mendekati batas $minutes menit, video akan ditutup otomatis';
  }

  @override
  String get voiceInterrupted => 'Perekaman terganggu';

  @override
  String get videoTypePacking => 'Pengemasan';

  @override
  String get videoTypeCarrier => 'Serah terima kurir';

  @override
  String get videoTypeReturn => 'Retur';

  @override
  String get storageIntro =>
      'Di mana video toko disimpan. Di mana pun letaknya, catatan segel tetap di sistem — mengganti penyimpanan tidak melemahkan bukti.';

  @override
  String get storageS3Title => 'Penyimpanan awan sendiri (kompatibel S3)';

  @override
  String get storageS3Desc =>
      'AWS S3, Cloudflare R2, MinIO, Wasabi… Video berada di bucket Anda, dan ketahanannya jadi tanggung jawab Anda.';

  @override
  String get storageDriveTitle => 'Google Drive';

  @override
  String get storageDriveDesc =>
      'Hubungkan dengan sekali pemberian izin, tanpa menempel kunci. Akun gratis hanya punya 15 GB yang dibagi dengan Gmail.';

  @override
  String get storageNeedProPlan =>
      'Menghubungkan penyimpanan sendiri butuh paket Profesional atau lebih tinggi.';

  @override
  String get attachCodeToOrder => 'Pindai kode lain ke pesanan ini';

  @override
  String get attachedCodes => 'Kode terlampir';

  @override
  String get codeAttached => 'Kode dilampirkan ke pesanan ini';

  @override
  String get codeBelongsToAnotherOrder =>
      'Kode ini milik pesanan lain — tidak bisa digabung.';

  @override
  String get codeAttachFailed => 'Tidak dapat melampirkan kode.';
}

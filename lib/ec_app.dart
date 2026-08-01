import 'dart:async';
import 'dart:io';

import 'package:analytics/analytics.dart';
import 'package:app_platform/app_platform.dart'
    show
        AppVideoPlayerController,
        CrashReporter,
        GallerySaveService,
        PermissionService,
        WakelockPlus,
        ImagePicker,
        ImageSource,
        ShareService,
        VideoPlayer,
        VideoPlayerService,
        VideoPlayerValue,
        VoiceAnnouncerService;
import 'package:app_ui/app_ui.dart';
import 'package:ec_data/ec_data.dart';
import 'package:ec_ui/ec_ui.dart';
import 'package:feature_account/feature_account.dart';
// feature_capture re-exports Flow 3's screens, which also declare an
// EcVideoType; we use Flow 1's (from feature_shift), so hide this one.
import 'package:feature_capture/feature_capture.dart' hide EcVideoType;
import 'package:feature_capture/feature_capture.dart'
    as capture
    show EcVideoType;
// Flow 1 and Flow 2 both declare EcOrderRow; show only what we use from orders
// so Flow 1's (via feature_shift) is the one in scope.
import 'package:feature_orders/feature_orders.dart'
    show
        EcEvidenceType,
        EcOrderTimelineScreen,
        EcPhotoDetailScreen,
        EcStatusTone,
        EcTimelineDay,
        EcTimelineVideo,
        EcVideoDetail,
        EcVideoDetailScreen;
import 'package:feature_shift/feature_shift.dart';
import 'package:flutter/cupertino.dart'
    show
        CupertinoActivityIndicator,
        CupertinoAlertDialog,
        CupertinoApp,
        CupertinoButton,
        CupertinoDialogAction,
        CupertinoPageScaffold,
        CupertinoSlider,
        CupertinoTextThemeData,
        CupertinoThemeData,
        showCupertinoDialog,
        showCupertinoModalPopup;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';
import 'package:network/network.dart' show Dio, DioException, DioExceptionType;
import 'package:path_provider/path_provider.dart';
import 'package:shared_contracts/shared_contracts.dart' show ClipBudget;
import 'package:storage/storage.dart';

import 'app/di/injection.dart';
import 'data/ec_uploader.dart';
import 'screens/ec_record_route.dart';
import 'screens/ec_scan_route.dart';

const _lastShopIdKey = 'shop.last_id';

typedef PickAvatarPath = Future<String?> Function();

/// EvidenceCam app shell — wires the pixel-perfect screens into the real
/// journey (Vào ca → 3 tab → tài khoản) with go_router and the Workers API.
class EcApp extends StatefulWidget {
  const EcApp({
    this.repo = const FakeEcRepository(),
    this.auth,
    this.evidenceStore,
    this.pickAvatarPath,
    this.shareService,
    this.videoPlayerService,
    this.downloadDio,
    super.key,
  });

  /// Data source — [FakeEcRepository] by default; pass [RemoteEcRepository]
  /// (wrapping the typed API) once the Worker base URL is configured to go live.
  final EcRepository repo;

  /// Auth — [FakeEcAuth] by default; pass `FirebaseEcAuth` once the Firebase
  /// config files are present (FR-15).
  final EcAuth? auth;

  /// Upload-queue persistence. The app binds the ObjectBox store (single source
  /// of truth, FR-08/FR-09); tests leave it null and get an in-memory store.
  final EvidenceClipStore? evidenceStore;

  /// Gallery/avatar picker seam. Production uses ImagePicker; tests can inject
  /// a deterministic path without touching platform channels.
  final PickAvatarPath? pickAvatarPath;

  final ShareService? shareService;
  final VideoPlayerService? videoPlayerService;
  final Dio? downloadDio;

  @override
  State<EcApp> createState() => _EcAppState();
}

class _EcAppState extends State<EcApp> {
  late final EcAuth _auth = widget.auth ?? FakeEcAuth();
  // Single source of truth for the selected interface language. The account tab
  // and language screen read/write this; `CupertinoApp.locale` follows it and
  // `AppLocalizations` renders `context.l10n.*` in the chosen language.
  //
  // Initial value follows the device system language (English → en, anything
  // else → vi, the primary market). The picker overrides it for the session.
  /// Ngôn ngữ đang dùng. Khởi tạo từ lựa chọn đã lưu, rơi về ngôn ngữ máy khi
  /// người dùng chưa chọn bao giờ — trước đây chỉ sống trong phiên nên thoát
  /// app là mất, người dùng phải chọn lại mỗi lần mở.
  late final ValueNotifier<EcAppLanguage> _language = ValueNotifier(
    _savedLanguage() ?? _systemLanguage(),
  )..addListener(_persistLanguage);

  static const _languagePrefKey = 'app.language';

  static EcAppLanguage? _savedLanguage() {
    final saved = _appMemory()?.getString(_languagePrefKey);
    return switch (saved) {
      'en' => EcAppLanguage.en,
      'vi' => EcAppLanguage.vi,
      _ => null,
    };
  }

  void _persistLanguage() {
    final code = _language.value == EcAppLanguage.en ? 'en' : 'vi';
    unawaited(_appMemory()?.setString(_languagePrefKey, code));
  }

  static EcAppLanguage _systemLanguage() =>
      WidgetsBinding.instance.platformDispatcher.locale.languageCode == 'en'
      ? EcAppLanguage.en
      : EcAppLanguage.vi;

  // Offline upload queue for recorded clips. The uploader follows the live
  // presign/R2/complete flow when an API URL is set; otherwise clips persist
  // locally and wait.
  late final EcUploadQueue _queue = EcUploadQueue(
    uploader: _apiUrl.isEmpty
        ? null
        : ApiEvidenceUploader(buildApi(auth: _auth, url: _apiUrl)),
    store: widget.evidenceStore,
    analytics: _analytics(),
    crashReporter: _crashReporter(),
  );

  // Built once for the app's lifetime rather than per record-screen visit —
  // see the doc comment on EcRecordRoute.voiceAnnouncer.
  final VoiceAnnouncerService _voiceAnnouncer = VoiceAnnouncerService();
  static const String _apiUrl = kApiBaseUrl;

  // The shop clocked into at the shop layer (FR-05). Its id drives which orders
  // load, its resolution seeds the camera, and its role gates evidence deletion
  // and shop management. Null until a shop is picked.
  final ValueNotifier<EcShopSummary?> _selectedShop = ValueNotifier(null);
  final ValueNotifier<String> _recordingType = ValueNotifier('Đóng hàng');
  // Whether the "Ghi hình" tab is the one on screen right now — the 3-tab
  // shell keeps every branch mounted, so without this the camera keeps
  // streaming (and hands-free auto-recording on a scanned bill) even while
  // the user is on Vận đơn/Tài khoản. Flipped from the shell's own builder,
  // read by EcRecordRoute to release/reacquire the camera accordingly.
  final ValueNotifier<bool> _isRecordTabActive = ValueNotifier(false);
  final _EvidenceCountOverrides _evidenceCountOverrides =
      _EvidenceCountOverrides();

  late final GoRouter _router = _buildRouter(
    widget.repo,
    _auth,
    _language,
    _queue,
    _selectedShop,
    _recordingType,
    widget.pickAvatarPath ?? _pickImagePath,
    shareService: widget.shareService,
    videoPlayerService: widget.videoPlayerService,
    downloadDio: widget.downloadDio,
    voiceAnnouncer: _voiceAnnouncer,
    isRecordTabActive: _isRecordTabActive,
    evidenceCountOverrides: _evidenceCountOverrides,
  );

  @override
  void initState() {
    super.initState();
    _queue.load();
    // Máy dựng trên bàn đóng hàng, người quay không chạm vào suốt cả ca — để
    // màn tự tắt là camera preview ngủ theo và phiên quay đứt giữa chừng.
    unawaited(WakelockPlus.enable().catchError((_) {}));
  }

  @override
  void dispose() {
    unawaited(WakelockPlus.disable().catchError((_) {}));
    _router.dispose();
    _language
      ..removeListener(_persistLanguage)
      ..dispose();
    _queue.dispose();
    _selectedShop.dispose();
    _recordingType.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<EcAppLanguage>(
      valueListenable: _language,
      builder: (context, language, _) => CupertinoApp.router(
        debugShowCheckedModeBanner: false,
        title: 'ZenPack',
        locale: Locale(language == EcAppLanguage.vi ? 'vi' : 'en'),
        supportedLocales: const [Locale('vi'), Locale('en')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: CupertinoThemeData(
          brightness: Brightness.light,
          primaryColor: BrandColors.dark,
          scaffoldBackgroundColor: BrandColors.bg,
          applyThemeToAll: true,
          // Keep the design's Inter face; everything else is iOS-native.
          textTheme: CupertinoTextThemeData(
            textStyle: GoogleFonts.inter(
              color: BrandColors.ink,
              fontSize: 14,
            ),
          ),
        ),
        routerConfig: _router,
        // Tapping anywhere outside the focused field (e.g. a text field)
        // dismisses the keyboard app-wide.
        builder: (context, child) => PopScope(
          // A back gesture that reaches the root would otherwise close the
          // app outright — which is what happens on the pre-shell screens
          // (splash / login / shop picker), since only the tab shell has its
          // own PopScope. go_router still pops pushed routes normally: this
          // only fires once nothing is left to pop.
          canPop: false,
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            behavior: HitTestBehavior.opaque,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Login route — owns the email/password controllers and drives the auth seam
/// (FR-15). Email/Google/Apple all sign in through [EcAuth] then go to the shop
/// layer; today [FakeEcAuth] succeeds instantly, `FirebaseEcAuth` does it for real.
class _LoginRoute extends StatefulWidget {
  const _LoginRoute({
    required this.auth,
    required this.repo,
    required this.language,
  });

  final EcAuth auth;
  final EcRepository repo;
  final ValueNotifier<EcAppLanguage> language;

  @override
  State<_LoginRoute> createState() => _LoginRouteState();
}

class _LoginRouteState extends State<_LoginRoute> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    _prefillFromMemory();
  }

  // Prefill email + password remembered from the last sign-in / registration
  // (kept in the platform keychain). No-op in tests/pumps that skip DI.
  Future<void> _prefillFromMemory() async {
    final saved = await _credentials()?.read();
    if (saved == null || !mounted) return;
    if (_email.text.isEmpty) _email.text = saved.email;
    if (_password.text.isEmpty) _password.text = saved.password;
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _afterSignIn(Future<void> signIn) async {
    try {
      await signIn;
      await _credentials()?.save(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (mounted) context.go('/shops', extra: 'forward');
    } on Object catch (error) {
      if (mounted) _toast(context, _authErrorText(context.l10n, error));
    }
  }

  @override
  Widget build(BuildContext context) => EcLoginScreen(
    emailController: _email,
    passwordController: _password,
    onLogin: () =>
        _afterSignIn(widget.auth.signInWithEmail(_email.text, _password.text)),
    onRegister: () => context.push('/register'),
    onForgot: () => context.push('/forgot'),
    onGoogle: () => _afterSocialSignIn(
      context,
      widget.repo,
      widget.auth.signInWithGoogle(),
    ),
    onApple: () => _afterSocialSignIn(
      context,
      widget.repo,
      widget.auth.signInWithApple(),
    ),
    onLanguage: () => _toggleLanguage(context, widget.language),
  );
}

/// Registration — owns the field controllers so the screen's inline validators
/// (notably the confirm-password match) have live text to read. Valid submits
/// create the auth user, persist profile fields, then enter the shop layer.
class _RegisterRoute extends StatefulWidget {
  const _RegisterRoute({
    required this.auth,
    required this.repo,
    required this.language,
  });

  final EcAuth auth;
  final EcRepository repo;
  final ValueNotifier<EcAppLanguage> language;

  @override
  State<_RegisterRoute> createState() => _RegisterRouteState();
}

class _RegisterRouteState extends State<_RegisterRoute> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  var _policyAccepted = true;
  var _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await widget.auth.registerWithEmail(
        email: _email.text.trim(),
        password: _password.text,
        name: _name.text.trim(),
      );
      await widget.auth.updateProfile(
        name: _name.text.trim(),
        phone: _phone.text.trim(),
      );
      await widget.repo.updateProfile(
        name: _name.text.trim(),
        phone: _phone.text.trim(),
      );
      // Requirement: land back on Login with the new credentials prefilled.
      // Remember them (keychain), then sign out of the auto-signed-in session
      // so the user completes the deliberate login step.
      await _credentials()?.save(
        email: _email.text.trim(),
        password: _password.text,
      );
      await widget.auth.signOut();
      if (mounted) context.go('/login', extra: 'back');
    } on Object catch (error) {
      if (mounted) _toast(context, _authErrorText(context.l10n, error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => EcRegisterScreen(
    nameController: _name,
    emailController: _email,
    phoneController: _phone,
    passwordController: _password,
    confirmPasswordController: _confirm,
    policyAccepted: _policyAccepted,
    onPolicyChanged: (accepted) => setState(() => _policyAccepted = accepted),
    onBack: () => _back(context, '/login'),
    onLogin: () => _back(context, '/login'),
    onRegister: _policyAccepted && !_saving ? _register : null,
    onGoogle: () => _afterSocialSignIn(
      context,
      widget.repo,
      widget.auth.signInWithGoogle(),
    ),
    onApple: () => _afterSocialSignIn(
      context,
      widget.repo,
      widget.auth.signInWithApple(),
    ),
    onLanguage: () => _toggleLanguage(context, widget.language),
    onViewPolicy: () => _toast(context, context.l10n.toastTermsPolicy),
  );
}

class _ForgotRoute extends StatefulWidget {
  const _ForgotRoute({required this.auth, required this.language});

  final EcAuth auth;
  final ValueNotifier<EcAppLanguage> language;

  @override
  State<_ForgotRoute> createState() => _ForgotRouteState();
}

class _ForgotRouteState extends State<_ForgotRoute> {
  final _email = TextEditingController();
  var _sent = false;
  var _sending = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending) return;
    setState(() => _sending = true);
    try {
      await widget.auth.sendPasswordReset(_email.text.trim());
      if (mounted) setState(() => _sent = true);
    } on Object catch (error) {
      if (mounted) _toast(context, _authErrorText(context.l10n, error));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => EcForgotPasswordScreen(
    emailController: _email,
    sent: _sent,
    onBack: () => _back(context, '/login'),
    onLogin: () => _back(context, '/login'),
    onSend: _sending ? null : _send,
    onLanguage: () => _toggleLanguage(context, widget.language),
  );
}

/// After an Apple/Google sign-in, force phone capture only when the account has
/// no phone on file yet. A returning account whose business phone is already
/// saved (D1, read via [EcRepository.account]) skips straight to shop selection.
Future<void> _afterSocialSignIn(
  BuildContext context,
  EcRepository repo,
  Future<EcUser> signIn,
) async {
  try {
    await signIn;
    if (!context.mounted) return;
    final needsPhone = await _accountNeedsPhone(repo);
    if (!context.mounted) return;
    context.go(needsPhone ? '/phone-setup' : '/shops', extra: 'forward');
  } on EcAuthCancelled {
    // User backed out of the provider sheet — nothing to report.
  } on Object catch (error) {
    if (context.mounted) _toast(context, _authErrorText(context.l10n, error));
  }
}

/// Whether the signed-in account still needs a phone. The business phone lives
/// in D1 (tech-spec §7), not Firebase Auth, so read it through the repository.
/// If the read fails we can't confirm one exists, so ask rather than skip.
Future<bool> _accountNeedsPhone(EcRepository repo) async {
  try {
    final account = await repo.account();
    return (account.phone ?? '').trim().isEmpty;
  } on Object {
    return true;
  }
}

/// Forced phone capture after a social sign-in with no phone on the account.
/// Saves through the seam, then continues to shop selection.
class _PhoneSetupRoute extends StatefulWidget {
  const _PhoneSetupRoute({required this.auth, required this.repo});

  final EcAuth auth;
  final EcRepository repo;

  @override
  State<_PhoneSetupRoute> createState() => _PhoneSetupRouteState();
}

class _PhoneSetupRouteState extends State<_PhoneSetupRoute> {
  final _phone = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // The screen's inline Form guarantees a valid phone before this fires.
    final phone = _phone.text.trim();
    try {
      // ponytail: with FirebaseEcAuth the phone lands in D1, not Firebase Auth
      // (tech-spec §7) — persists once that profile endpoint is wired; today the
      // FakeEcAuth binding keeps it in memory so the gate clears.
      await widget.auth.updateProfile(phone: phone);
      await widget.repo.updateProfile(phone: phone);
      if (!mounted) return;
      context.go('/shops', extra: 'forward');
    } on Object catch (error) {
      if (mounted) _toast(context, _authErrorText(context.l10n, error));
    }
  }

  @override
  Widget build(BuildContext context) =>
      EcPhoneSetupScreen(phoneController: _phone, onContinue: _save);
}

/// Turns an auth/backend failure into a user-facing line. [EcAuthException]
/// carries its own friendly message; a backend [DioException] maps by code or
/// HTTP status; anything else falls back to a clean generic so no action
/// dead-ends and no raw exception string is ever shown.
String _authErrorText(AppLocalizations l10n, Object error) {
  if (error is EcAuthException) return error.message;
  return _apiErrorText(l10n, error) ?? l10n.errorGenericRetry;
}

/// The machine error code a Workers API failure carries as `{ "error": "..." }`,
/// or null when [error] isn't a backend response with one.
String? _apiErrorCode(Object error) {
  if (error is! DioException) return null;
  final data = error.response?.data;
  if (data is Map && data['error'] is String) return data['error'] as String;
  return null;
}

/// Friendly Vietnamese for a backend/network failure, or null if [error] isn't
/// one. Maps the few codes tied to a user action, then falls back by transport
/// and HTTP status so an unknown code never surfaces as a raw string.
String? _apiErrorText(AppLocalizations l10n, Object error) {
  if (error is! DioException) return null;
  switch (_apiErrorCode(error)) {
    case 'open_dossiers_exist':
      return l10n.errorPendingDossier;
    case 'invalid_token':
    case 'missing_bearer_token':
    case 'no_subject':
    case 'account_not_found':
    case 'account_required':
      return l10n.errorSessionExpired;
  }
  final isNetwork =
      error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.connectionError;
  if (isNetwork) return l10n.errorNoNetwork;
  final status = error.response?.statusCode ?? 0;
  if (status == 403) return l10n.errorNoPermission;
  if (status >= 500) return l10n.errorServerBusy;
  return l10n.errorGenericRetry;
}

/// Account tab — reactive to the current user, selected language and quota, and
/// wires every row to the real seam (logout signs out, not just navigates).
class _AccountRoute extends StatefulWidget {
  const _AccountRoute({
    required this.auth,
    required this.repo,
    required this.language,
    required this.selectedShop,
    required this.queue,
  });

  final EcAuth auth;
  final EcRepository repo;
  final ValueNotifier<EcAppLanguage> language;
  final ValueNotifier<EcShopSummary?> selectedShop;
  final EcUploadQueue queue;

  @override
  State<_AccountRoute> createState() => _AccountRouteState();
}

class _AccountRouteState extends State<_AccountRoute> {
  // Fetched once; stored so rebuilds (user/language changes) don't refetch.
  late final Future<QuotaDto> _quota = widget.repo.quota(
    shopId: widget.selectedShop.value?.id,
  );

  Future<void> _logout() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(context.l10n.accountSignOutConfirmTitle),
        content: Text(context.l10n.accountSignOutConfirmMessage),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.commonCancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.accountSignOut),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await widget.auth.signOut();
    if (mounted) context.go('/login', extra: 'back');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.auth.user,
        widget.language,
        widget.selectedShop,
        widget.queue,
      ]),
      builder: (context, _) {
        final user = widget.auth.currentUser;
        final language = widget.language.value;
        final shop = widget.selectedShop.value;
        final linkedCount =
            1 +
            (user?.hasProvider(EcAuthProvider.google) ?? false ? 1 : 0) +
            (user?.hasProvider(EcAuthProvider.apple) ?? false ? 1 : 0);
        return FutureBuilder<QuotaDto>(
          future: _quota,
          builder: (context, snap) => EcAccountTabScreen(
            userName: user?.displayName ?? context.l10n.accountNoName,
            userEmail: user?.email ?? '—',
            shopName: shop?.name ?? context.l10n.accountNoShop,
            planLabel: snap.hasData
                ? _planDisplayName(context.l10n, snap.data!.planCode)
                : '—',
            languageLabel: language == EcAppLanguage.vi
                ? 'Tiếng Việt'
                : 'English',
            loginMethodsLabel: context.l10n.accountLinkedMethods(linkedCount),
            passwordActionLabel: user?.hasPassword == false
                ? context.l10n.accountCreatePassword
                : context.l10n.accountChangePassword,
            avatarPath: _appMemory()?.getString(_avatarPathKey(user?.uid)),
            onBack: () => context.go('/shops', extra: 'back'),
            onNavOrders: () => context.go('/home'),
            onNavCapture: () => context.go('/record'),
            onProfileTap: () async {
              await context.push('/edit-profile');
              if (mounted) setState(() {});
            },
            onQuotaTap: () => context.push('/quota'),
            onLanguageTap: () => context.push('/language'),
            onEndQrTap: () => _showEndSessionQr(context),
            onChangePasswordTap: () => context.push('/change-password'),
            onDeleteAccount: () => context.push('/delete-account'),
            onLoginMethodsTap: () => context.push('/login-methods'),
            onLogout: _logout,
          ),
        );
      },
    );
  }
}

/// Edit-profile — seeds the fields from the current user and persists
/// name/phone/avatar through the seams.
class _EditProfileRoute extends StatefulWidget {
  const _EditProfileRoute({
    required this.auth,
    required this.repo,
    required this.pickAvatarPath,
  });

  final EcAuth auth;
  final EcRepository repo;
  final PickAvatarPath pickAvatarPath;

  @override
  State<_EditProfileRoute> createState() => _EditProfileRouteState();
}

class _EditProfileRouteState extends State<_EditProfileRoute> {
  late final TextEditingController _name = TextEditingController(
    text: widget.auth.currentUser?.displayName ?? '',
  );
  late final TextEditingController _phone = TextEditingController(
    text: widget.auth.currentUser?.phone ?? '',
  );
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _avatarPath = _appMemory()?.getString(
      _avatarPathKey(widget.auth.currentUser?.uid),
    );
    _loadSavedPhone();
  }

  // The business phone lives in D1, not Firebase Auth (see
  // `_accountNeedsPhone` above), so the field seeded from `auth.currentUser`
  // is only a placeholder until this resolves.
  Future<void> _loadSavedPhone() async {
    final seed = _phone.text;
    try {
      final account = await widget.repo.account();
      final phone = account.phone;
      if (!mounted || _phone.text != seed) return;
      if (phone != null && phone.isNotEmpty) _phone.text = phone;
    } on Object {
      // Keep the Firebase-seeded value; the field stays editable either way.
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final path = await widget.pickAvatarPath();
    if (path != null && mounted) setState(() => _avatarPath = path);
  }

  Future<void> _save() async {
    // The screen's inline Form guarantees a non-empty name before this fires.
    final name = _name.text.trim();
    final phone = _phone.text.trim();
    try {
      await widget.auth.updateProfile(name: name, phone: phone);
      var avatarPath = _avatarPath;
      if (avatarPath != null) {
        avatarPath = await _persistAvatarFile(
          avatarPath,
          widget.auth.currentUser?.uid,
        );
      }
      await widget.repo.updateProfile(
        name: name,
        phone: phone,
        avatarUrl: avatarPath,
      );
      if (avatarPath != null) {
        await _appMemory()?.setString(
          _avatarPathKey(widget.auth.currentUser?.uid),
          avatarPath,
        );
      }
      if (!mounted) return;
      context.pop();
      _toast(context, context.l10n.toastInfoSaved);
    } on Object catch (error) {
      if (mounted) _toast(context, _authErrorText(context.l10n, error));
    }
  }

  @override
  Widget build(BuildContext context) => EcEditProfileScreen(
    nameController: _name,
    phoneController: _phone,
    email: widget.auth.currentUser?.email ?? '—',
    avatarPath: _avatarPath,
    onBack: () => _back(context, '/account'),
    onChangeAvatar: _pickAvatar,
    onSave: _save,
  );
}

/// Change-password — validates (current present, new ≥8, confirm matches) then
/// calls the seam, surfacing auth errors (wrong current password, etc.).
class _ChangePasswordRoute extends StatefulWidget {
  const _ChangePasswordRoute({required this.auth});

  final EcAuth auth;

  @override
  State<_ChangePasswordRoute> createState() => _ChangePasswordRouteState();
}

class _ChangePasswordRouteState extends State<_ChangePasswordRoute> {
  final TextEditingController _current = TextEditingController();
  final TextEditingController _next = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  bool get _hasPassword => widget.auth.currentUser?.hasPassword ?? true;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_hasPassword) {
      try {
        await widget.auth.createPassword(newPassword: _next.text);
        if (!mounted) return;
        context.pop();
        _toast(context, context.l10n.toastPasswordCreated);
      } on Object catch (error) {
        if (mounted) _toast(context, _authErrorText(context.l10n, error));
      }
      return;
    }
    // Presence, 8-char minimum and confirm-match are enforced inline by the
    // screen's Form before this fires.
    try {
      await widget.auth.updatePassword(
        currentPassword: _current.text,
        newPassword: _next.text,
      );
      if (!mounted) return;
      context.pop();
      _toast(context, context.l10n.toastPasswordChanged);
    } on Object catch (error) {
      if (mounted) _toast(context, _authErrorText(context.l10n, error));
    }
  }

  @override
  Widget build(BuildContext context) => EcChangePasswordScreen(
    hasExistingPassword: _hasPassword,
    currentPasswordController: _current,
    newPasswordController: _next,
    confirmPasswordController: _confirm,
    onCancel: () => context.pop(),
    onSave: _save,
  );
}

/// Login-methods — reflects the real linked providers and links/unlinks through
/// the seam; the row updates as `auth.user` changes.
class _LoginMethodsRoute extends StatelessWidget {
  const _LoginMethodsRoute({required this.auth});

  final EcAuth auth;

  Future<void> _toggle(
    BuildContext context,
    EcAuthProvider provider,
    bool linked,
  ) async {
    try {
      if (linked) {
        await auth.unlinkProvider(provider);
      } else {
        await auth.linkProvider(provider);
      }
    } on EcAuthCancelled {
      // User backed out of the provider sheet — leave the toggle unchanged.
    } on Object catch (error) {
      if (context.mounted) _toast(context, _authErrorText(context.l10n, error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: auth.user,
      builder: (context, _) {
        final user = auth.currentUser;
        final google = user?.hasProvider(EcAuthProvider.google) ?? false;
        final apple = user?.hasProvider(EcAuthProvider.apple) ?? false;
        return EcLoginMethodsScreen(
          email: user?.email ?? '—',
          googleLinked: google,
          appleLinked: apple,
          onBack: () => _back(context, '/account'),
          onToggleGoogle: () => _toggle(context, EcAuthProvider.google, google),
          onToggleApple: () => _toggle(context, EcAuthProvider.apple, apple),
        );
      },
    );
  }
}

/// Quota — reads the plan's cap/retention from the repository, but computes
/// usage (bytes used, video counts, per-type breakdown) from the clips
/// actually sitting in [queue] so the numbers on screen can never disagree
/// with what's really stored on the device.
class _QuotaRoute extends StatefulWidget {
  const _QuotaRoute({required this.repo, required this.queue, this.shopId});

  final EcRepository repo;
  final EcUploadQueue queue;

  /// Shop đang chọn. Gói cước gắn với tài khoản CHỦ shop, nên phải hỏi theo
  /// shop thì quản lý/nhân viên mới thấy đúng gói đang chi phối ca làm của họ
  /// (và `canManagePlan=false` để ẩn nút nâng gói).
  final String? shopId;

  @override
  State<_QuotaRoute> createState() => _QuotaRouteState();
}

class _QuotaRouteState extends State<_QuotaRoute> {
  late final Future<QuotaDto> _quota = widget.repo.quota(shopId: widget.shopId);

  @override
  void initState() {
    super.initState();
    _analytics()?.trackPaywallViewed();
  }

  /// Groups this shop's clips by [UploadTask.type], summing each clip's
  /// on-disk file size. Sorted largest-first so the breakdown (and its
  /// stacked bar) read biggest-type-first, matching the reference design.
  List<EcQuotaTypeUsage> _localTypeUsage() {
    final byType = <String, (int count, int bytes)>{};
    for (final task in widget.queue.tasks) {
      if (task.shopId != widget.shopId) continue;
      var bytes = 0;
      try {
        bytes = File(task.filePath).lengthSync();
      } on Object {
        // Clip's file was moved/cleaned up since it was queued — still
        // count the video, just not its (now unknown) size.
      }
      final prev = byType[task.type] ?? (0, 0);
      byType[task.type] = (prev.$1 + 1, prev.$2 + bytes);
    }
    final usage = [
      for (final entry in byType.entries)
        EcQuotaTypeUsage(
          type: entry.key,
          videoCount: entry.value.$1,
          bytes: entry.value.$2,
        ),
    ]..sort((a, b) => b.bytes.compareTo(a.bytes));
    return usage;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuotaDto>(
      future: _quota,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const CupertinoPageScaffold(
            backgroundColor: BrandColors.bg,
            child: Center(child: CupertinoActivityIndicator()),
          );
        }
        final quota = snap.data!;
        final typeUsage = _localTypeUsage();
        final videoCount = typeUsage.fold<int>(
          0,
          (total, u) => total + u.videoCount,
        );
        final usedBytes = typeUsage.fold<int>(0, (total, u) => total + u.bytes);
        return EcQuotaScreen(
          planLabel: _planDisplayName(context.l10n, quota.planCode),
          // Computed from the clips actually on this device rather than the
          // API's usedBytes, so this always matches what quotaByType lists
          // below it.
          usedBytes: usedBytes,
          capBytes: quota.capBytes,
          retentionTotalDays: quota.retentionDays,
          videoCount: videoCount,
          typeUsage: typeUsage,
          canManagePlan: quota.canManagePlan,
          onBack: () => _back(context, '/account'),
          onUpgrade: () {
            _analytics()?.trackPurchaseStarted(planCode: quota.planCode);
            _toast(context, context.l10n.toastUpgradeComingSoon);
          },
          onPaymentHistoryTap: () =>
              _toast(context, context.l10n.toastUpgradeComingSoon),
        );
      },
    );
  }
}

class _DeleteAccountRoute extends StatefulWidget {
  const _DeleteAccountRoute({required this.auth, required this.repo});

  final EcAuth auth;
  final EcRepository repo;

  @override
  State<_DeleteAccountRoute> createState() => _DeleteAccountRouteState();
}

class _DeleteAccountRouteState extends State<_DeleteAccountRoute> {
  var _openDossierWarningShown = false;
  var _screenKey = 0;
  var _deleting = false;

  Future<void> _confirmDelete() async {
    if (_deleting) return;
    setState(() => _deleting = true);
    try {
      await widget.repo.deleteAccount(
        force: _openDossierWarningShown,
        dryRun: true,
      );
      await widget.auth.deleteAccount();
      await widget.repo.deleteAccount(force: true);
      // Forget the remembered credentials so the deleted account's password is
      // never prefilled on the login screen we return to.
      await _credentials()?.clear();
      if (mounted) context.go('/login', extra: 'back');
    } on Object catch (error) {
      if (_isOpenDossierConflict(error)) {
        if (!mounted) return;
        setState(() {
          _openDossierWarningShown = true;
          _screenKey++;
        });
        _toast(context, context.l10n.toastPendingDossierConfirm);
      } else if (mounted) {
        _toast(context, _authErrorText(context.l10n, error));
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) => EcDeleteAccountScreen(
    key: ValueKey(_screenKey),
    pendingSharedProfilesCount: _openDossierWarningShown ? 1 : 0,
    onCancel: () => context.pop(),
    onConfirmDelete: _confirmDelete,
  );
}

bool _isOpenDossierConflict(Object error) =>
    _apiErrorCode(error) == 'open_dossiers_exist' ||
    error.toString().contains('open_dossiers_exist');

/// Presents a sheet/dialog screen as a modal OVER the previous screen: the
/// route is transparent (opaque:false) so the screen behind shows through a
/// dim barrier — matching the `.pen` where these screens sit on a dimmed
/// background, not a solid one.
/// Lightweight feedback so no button is a dead end: actions that don't (yet)
/// have a dedicated screen confirm they fired.
void _toast(BuildContext c, String msg) => ecToast(c, msg);

/// Đảm bảo có quyền camera trước khi màn ghi hình khởi tạo thiết bị.
///
/// Chưa hỏi bao giờ thì hỏi. Đã từ chối vĩnh viễn thì hỏi lại cũng vô ích —
/// hệ điều hành không hiện hộp thoại nữa — nên mở thẳng phần Cài đặt của app
/// để người dùng bật tay.
Future<bool> _ensureCameraPermission() async {
  final permissions = _maybeGetIt<PermissionService>();
  if (permissions == null) return true;
  try {
    if (await permissions.hasCameraPermission()) return true;
    if (await permissions.requestCameraPermission()) return true;
    await permissions.openAppSettingsPage();
    return permissions.hasCameraPermission();
  } on Object {
    // Lỗi tầng quyền không được chặn màn hình — để bloc báo trạng thái camera.
    return false;
  }
}

/// Tờ QR "kết thúc phiên" để người dùng in ra dán ở bàn đóng hàng.
///
/// Ảnh là asset tĩnh vì nội dung mã (`kEndSessionQr`) là hằng số ghi cứng dùng
/// chung cho mọi máy — không có gì phải sinh lúc chạy.
void _showEndSessionQr(BuildContext context) {
  final l10n = context.l10n;
  showCupertinoModalPopup<void>(
    context: context,
    builder: (sheetContext) => PenSheet(
      onDismiss: () => Navigator.of(sheetContext).pop(),
      children: [
        const SizedBox(height: 18),
        PenText(
          l10n.accountEndQrTitle,
          size: 22,
          color: PenColors.ink,
          weight: FontWeight.w800,
        ),
        const SizedBox(height: 16),
        Center(
          child: ColoredBox(
            color: PenColors.card,
            child: Image.asset(
              'assets/images/end_session_qr.png',
              width: 220,
              height: 220,
              filterQuality: FilterQuality.none,
              errorBuilder: (_, _, _) => const Icon(
                LucideIcons.qrCode,
                size: 96,
                color: PenColors.mut,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        PenText(
          l10n.accountEndQrNote,
          size: 13,
          color: PenColors.mut,
        ),
        const SizedBox(height: 20),
      ],
    ),
  );
}

T? _maybeGetIt<T extends Object>() =>
    getIt.isRegistered<T>() ? getIt<T>() : null;

AnalyticsService? _analytics() => _maybeGetIt<AnalyticsService>();

CrashReporter? _crashReporter() => _maybeGetIt<CrashReporter>();

/// FR-07: đưa link hồ sơ ra share sheet. Không có [share] (DI vắng, hoặc
/// test) thì chép vào clipboard — im lặng không làm gì mới là thứ không chấp
/// nhận được với một nút đang hiện trên màn.
Future<void> _shareDossierLink(
  BuildContext context,
  ShareService? share,
  String url,
) async {
  final l10n = context.l10n;
  try {
    if (share == null) {
      await Clipboard.setData(ClipboardData(text: url));
      if (context.mounted) _toast(context, l10n.toastCopiedShareLink);
      return;
    }
    await share.share(text: url, subject: l10n.dossierLinkTitle);
  } on Object {
    if (context.mounted) _toast(context, l10n.toastShareFailed);
  }
}

/// Chỉ có hai ngôn ngữ, nên nút quả địa cầu ở màn trước-đăng-nhập lật thẳng
/// chứ không đẩy sang màn `/language` (màn đó back về `/account`, chưa đăng
/// nhập thì không có chỗ mà về).
void _toggleLanguage(
  BuildContext context,
  ValueNotifier<EcAppLanguage> language,
) {
  final next = language.value == EcAppLanguage.vi
      ? EcAppLanguage.en
      : EcAppLanguage.vi;
  language.value = next;
  _toast(
    context,
    next == EcAppLanguage.vi ? 'Đã đổi sang Tiếng Việt' : 'Switched to English',
  );
}

Future<void> _copyText(BuildContext context, String text, String label) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) _toast(context, context.l10n.copiedLabel(label));
}

Future<void> _downloadAndShareVideo(
  BuildContext context,
  Dio dio,
  ShareService? share,
  GallerySaveService? gallery,
  EcVideoDetail video,
) async {
  final url = video.mediaUrl;
  if (url == null) return;
  try {
    _toast(context, context.l10n.toastDownloadingVideo);
    final dir = await getApplicationDocumentsDirectory();
    final filename = _safeFilename('${video.title}.mp4');
    final path = '${dir.path}/$filename';
    await _downloadWithRetry(dio, url, path);
    if (!context.mounted) return;
    // gal's `put*` calls throw if the add-to-gallery permission was never
    // granted — request it first rather than let that surface as a generic
    // "download failed" toast on the very first save.
    if (gallery != null && await gallery.requestAccess()) {
      // "Tải về máy" means the clip should land in the device's own gallery,
      // not the app's private sandbox — save there and clean up the copy.
      await gallery.saveVideo(path);
      unawaited(_deleteQuietly(path));
      if (context.mounted) {
        _toast(context, context.l10n.toastVideoSavedToGallery);
      }
      return;
    }
    if (share == null) {
      await Clipboard.setData(ClipboardData(text: path));
      if (context.mounted) {
        _toast(context, context.l10n.toastVideoDownloadedCopied);
      }
      return;
    }
    await share.shareFiles(paths: [path], subject: video.title);
  } on Object {
    if (context.mounted) _toast(context, context.l10n.toastVideoDownloadFailed);
  }
}

Future<void> _downloadAndSavePhoto(
  BuildContext context,
  Dio dio,
  ShareService? share,
  GallerySaveService? gallery,
  EcVideoDetail photo,
) async {
  final url = photo.mediaUrl;
  if (url == null) {
    _toast(context, context.l10n.toastPhotoNoDownloadLink);
    return;
  }
  try {
    _toast(context, context.l10n.toastDownloadingPhoto);
    final dir = await getApplicationDocumentsDirectory();
    final filename = _safeFilename('${photo.title}.jpg');
    final path = '${dir.path}/$filename';
    await _downloadWithRetry(dio, url, path);
    if (!context.mounted) return;
    if (gallery != null && await gallery.requestAccess()) {
      await gallery.saveImage(path);
      unawaited(_deleteQuietly(path));
      if (context.mounted) {
        _toast(context, context.l10n.toastPhotoSavedToGallery);
      }
      return;
    }
    if (share == null) {
      await Clipboard.setData(ClipboardData(text: path));
      if (context.mounted) {
        _toast(context, context.l10n.toastPhotoDownloadedCopied);
      }
      return;
    }
    await share.shareFiles(paths: [path], subject: photo.title);
  } on Object {
    if (context.mounted) _toast(context, context.l10n.toastPhotoDownloadFailed);
  }
}

/// A clip fetched moments after its own upload finishes can briefly 404 — the
/// backend's order-detail response already has the URL, but the R2
/// object/CDN edge hasn't propagated it yet. A short retry window covers that
/// without the user having to back out and reopen the download sheet.
Future<void> _downloadWithRetry(Dio dio, String url, String path) async {
  const attempts = 3;
  for (var attempt = 1; attempt <= attempts; attempt++) {
    try {
      await dio.download(url, path);
      return;
    } on Object {
      if (attempt == attempts) rethrow;
      await Future<void>.delayed(const Duration(seconds: 2));
    }
  }
}

/// Best-effort cleanup of a downloaded temp file. `unawaited(File.delete())`
/// on its own lets a failure (already gone, permission race) escape as an
/// uncaught zone error, since the throw happens on a microtask after the
/// caller's own try/catch has already returned.
Future<void> _deleteQuietly(String path) async {
  try {
    await File(path).delete();
  } on Object {
    // Nothing left to clean up.
  }
}

String _safeFilename(String value) {
  final cleaned = value.replaceAll(RegExp('[^A-Za-z0-9._-]+'), '_');
  return cleaned.isEmpty ? 'evidence.mp4' : cleaned;
}

/// Back that always works: pop when there's something to pop, otherwise go to
/// a sensible parent. Prevents a dead back button when a screen is entered
/// directly (deep link / EC_START) with an empty history.
void _back(BuildContext c, String fallback) {
  if (c.canPop()) {
    c.pop();
  } else {
    c.go(fallback);
  }
}

/// A page whose slide direction follows the navigation direction, taken from
/// `state.extra` ('back' = slide in from the left / reverse, anything else =
/// slide in from the right / forward). Used for routes that are entered from
/// BOTH directions via `go` (e.g. /login reached forward from splash but
/// backward on logout; /shops reached forward from login but backward from the
/// app), where a static transition can't tell which way it's going.
CustomTransitionPage<void> _directionalPage(GoRouterState s, Widget child) {
  final enter = s.extra == 'back' ? const Offset(-1, 0) : const Offset(1, 0);
  return CustomTransitionPage<void>(
    key: s.pageKey,
    // Page tự dựng không được go_router gán `name` như route dùng `builder:`,
    // mà AnalyticsRouteObserver lấy tên màn từ `settings.name` — thiếu là màn
    // này không bao giờ xuất hiện trong báo cáo.
    name: s.uri.path,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        SlideTransition(
          position: animation.drive(
            Tween(
              begin: enter,
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic)),
          ),
          child: SlideTransition(
            position: secondaryAnimation.drive(
              Tween(
                begin: Offset.zero,
                end: -enter,
              ).chain(CurveTween(curve: Curves.easeInCubic)),
            ),
            child: child,
          ),
        ),
    child: child,
  );
}

CustomTransitionPage<void> _modalPage(
  GoRouterState s,
  Widget child, {
  LocalKey? key,
}) => CustomTransitionPage<void>(
  key: key,
  // Cùng lý do như _directionalPage: page tự dựng phải tự đặt `name`, nếu
  // không AnalyticsRouteObserver bỏ qua và sheet này biến mất khỏi báo cáo.
  name: s.uri.path,
  opaque: false,
  barrierDismissible: true,
  // Each modal screen paints the design's own `Dim` rect (#A6636363) as part
  // of its frame, so the route must not add a second scrim on top of it.
  barrierColor: Colors.transparent,
  transitionDuration: const Duration(milliseconds: 200),
  transitionsBuilder: (context, animation, _, child) =>
      FadeTransition(opacity: animation, child: child),
  child: child,
);

Future<String?> _showTypeSheet(
  BuildContext context, {
  required EcRepository repo,
  required String shopId,
  required String selectedType,
}) {
  return showGeneralDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierLabel: context.l10n.commonClose,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (dialogContext, _, _) => _TypeSheetRoute(
      repo: repo,
      shopId: shopId,
      selectedType: selectedType,
      onManageTypes: () =>
          Navigator.of(dialogContext).pop(_manageVideoTypesResult),
      onSelected: (type) => Navigator.of(dialogContext).pop(type),
    ),
    transitionBuilder: (_, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

const _manageVideoTypesResult = '__manage_video_types__';

/// Index of the `/record` [StatefulShellBranch] within the 3-tab shell
/// (home, record, account) — see `_buildRouter`'s `StatefulShellRoute`.
const _recordBranchIndex = 1;

/// Count of clips still genuinely in flight — the "n chờ/tải" badge shown in
/// the shop header, account tab and orders stats. Done clips are dropped from
/// the queue entirely once uploaded (see `EcUploadQueue._process`), and
/// errored ones are excluded here too: they can't upload without the user
/// retrying/deleting them in the Upload Queue screen, so counting them
/// alongside genuinely-waiting clips in these ambient badges would be
/// misleading — that's the only place they still show up.
int _pendingUploads(EcUploadQueue queue) => queue.tasks
    .where(
      (t) => t.state != EcUploadState.done && t.state != EcUploadState.error,
    )
    .length;

/// The shop clocked into at Flow 1. Direct deep links must handle null
/// explicitly instead of silently using a fake shop.
EcShopSummary? _selected(ValueNotifier<EcShopSummary?> selectedShop) =>
    selectedShop.value;

KeyValueStore? _appMemory() =>
    getIt.isRegistered<KeyValueStore>() ? getIt<KeyValueStore>() : null;

/// Device-local avatar image path, keyed per account since the avatar isn't
/// uploaded/served from the backend yet (see `_EditProfileRouteState`).
String _avatarPathKey(String? uid) => 'profile.avatar_path.${uid ?? ''}';

/// Copies a picked avatar into the app-documents dir, keyed per account, so
/// it survives OS cache purges the same way evidence clips do (see
/// `EcUploadQueue`'s doc comment) — `image_picker`'s own returned path points
/// into a plugin cache/temp location with no such guarantee, which was
/// letting a saved avatar quietly vanish (silently falls back to the
/// placeholder icon — see `_UserRow`/`_AvatarPicker`) once the OS reclaimed it.
Future<String> _persistAvatarFile(String pickedPath, String? uid) async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final avatarsDir = Directory('${dir.path}/avatars');
    if (!avatarsDir.existsSync()) avatarsDir.createSync(recursive: true);
    final stored =
        '${avatarsDir.path}/${uid ?? 'anon'}${_fileExtension(pickedPath)}';
    await File(pickedPath).copy(stored);
    return stored;
  } on Object {
    // Not a copyable local file (e.g. a test double, or the copy failed for
    // some other reason) — fall back to the original value rather than fail
    // the whole save, mirroring EcUploadQueue.enqueue's identical fallback.
    return pickedPath;
  }
}

String _fileExtension(String path) {
  final dot = path.lastIndexOf('.');
  final slash = path.lastIndexOf('/');
  return dot > slash ? path.substring(dot) : '.jpg';
}

/// Keychain-backed store for the remembered login email + password. Null in
/// tests/pumps that skip DI, so every credential read/write there is a no-op.
CredentialStore? _credentials() => getIt.isRegistered<FlutterSecureStorage>()
    ? CredentialStore(getIt<FlutterSecureStorage>())
    : null;

Future<void> _rememberShop(EcShopSummary shop) async {
  if (shop.id.isEmpty) return;
  await _appMemory()?.setString(_lastShopIdKey, shop.id);
}

Future<void> _forgetRememberedShop() async {
  await _appMemory()?.remove(_lastShopIdKey);
}

/// For a "Trả hàng" clip: does [code] match a tracking code the shop already
/// has saved (from an earlier "Đóng hàng" clip)? Unlike manual entry, there is
/// no "create a new order" fallback — a return that doesn't match anything is
/// just wrong, and the user is warned and told to rescan.
Future<bool> _verifyReturnCode(
  BuildContext context,
  EcRepository repo,
  String shopId,
  String shopName,
  String code,
) async {
  final key = normalizeTrackingCode(code);
  try {
    final matches = await repo.searchOrders(shopId, code);
    final exists = matches.any((o) => normalizeTrackingCode(o.tracking) == key);
    if (exists || !context.mounted) return exists;

    // No match: offer the same two ways out as manual entry — retype the
    // code, or confirm creating a new order for it — instead of a dead-end
    // toast the packer has no action to take on.
    final createNew = await showDialog<bool>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (dialogContext) => EcNoMatchScreen(
        returnCode: code,
        shopName: shopName,
        onEnterManually: () => Navigator.of(dialogContext).pop(false),
        onCreateNew: () => Navigator.of(dialogContext).pop(true),
      ),
    );
    if (createNew != true || !context.mounted) return false;
    try {
      await repo.createOrder(shopId, code);
      return true;
    } on Object catch (error) {
      if (context.mounted) _toast(context, _dataErrorText(context.l10n, error));
      return false;
    }
  } on Object catch (error) {
    if (context.mounted) _toast(context, _dataErrorText(context.l10n, error));
    return false;
  }
}

Future<bool> _confirmManualTracking(
  BuildContext context,
  EcRepository repo,
  String shopId,
  String code,
) async {
  final key = normalizeTrackingCode(code);
  try {
    final matches = await repo.searchOrders(shopId, code);
    final exists = matches.any((o) => normalizeTrackingCode(o.tracking) == key);
    if (exists) return true;
  } on Object catch (error) {
    if (context.mounted) _toast(context, _dataErrorText(context.l10n, error));
    return false;
  }

  if (!context.mounted) return false;
  final create = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(context.l10n.createOrderDialogTitle),
      content: Text(context.l10n.createOrderDialogBody(code)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(context.l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(context.l10n.createOrderConfirm),
        ),
      ],
    ),
  );
  if (create != true) return false;
  try {
    await repo.createOrder(shopId, code);
    return true;
  } on Object catch (error) {
    if (context.mounted) _toast(context, _dataErrorText(context.l10n, error));
    return false;
  }
}

ClipBudget _budgetFromDto(ShopDto shop) => ClipBudget(
  seconds: shop.clipSeconds,
  recommendedSeconds: shop.recommendedClipSeconds,
  planMaxSeconds: shop.planMaxClipSeconds,
  maxImageBytes: shop.maxImageBytes,
  maxVideoBytes: shop.maxVideoBytes,
  platformLimitsVerified: shop.platformLimitsVerified,
);

EcShopSummary _shopFromDto(ShopDto shop) => EcShopSummary(
  id: shop.id,
  name: shop.name,
  platform: shop.platform,
  meta: '${_platformDisplayName(shop.platform)} · ${shop.role}',
  role: shop.role,
  resolution: shop.resolution,
  clipBudget: _budgetFromDto(shop),
);

EcShopMgmtEntry _shopMgmtFromDto(
  AppLocalizations l10n,
  ShopDto shop,
) => EcShopMgmtEntry(
  id: shop.id,
  name: shop.name,
  platform: shop.platform,
  resolution: shop.resolution,
  role: shop.role,
  clipBudget: _budgetFromDto(shop),
  meta:
      '${_platformDisplayName(shop.platform)} · ${_roleDisplayName(l10n, shop.role)}',
);

EcShopSummary? _shopFromMgmt(EcShopMgmtEntry shop) {
  final id = shop.id;
  if (id == null) return null;
  return EcShopSummary(
    id: id,
    name: shop.name,
    platform: shop.platform ?? 'other',
    meta: shop.meta,
    role: shop.role ?? 'staff',
    resolution: shop.resolution ?? '720p',
    clipBudget: shop.clipBudget,
  );
}

String _platformDisplayName(String platform) => switch (platform) {
  'shopee' => 'Shopee',
  'tiktok' => 'TikTok Shop',
  'lazada' => 'Lazada',
  'tiki' => 'Tiki',
  _ => 'Khác',
};

String _roleDisplayName(AppLocalizations l10n, String role) => switch (role) {
  'owner' => l10n.roleOwner,
  'manager' => l10n.roleManager,
  'staff' => l10n.roleStaff,
  _ => role,
};

String _planDisplayName(AppLocalizations l10n, String planCode) =>
    switch (planCode) {
      'free' => l10n.planFree,
      'basic' => l10n.planBasic,
      _ => planCode,
    };

/// Picks one image from the gallery; returns its local file path, or null if
/// the user cancelled.
Future<String?> _pickImagePath() async {
  final file = await ImagePicker().pickImage(source: ImageSource.gallery);
  return file?.path;
}

/// Picks a photo and attaches it to [tracking]'s evidence via the upload queue
/// (uploads once the backend is configured). Shows a confirmation, or nothing
/// if the user cancelled.
Future<void> _attachPhoto(
  BuildContext context,
  EcUploadQueue queue,
  String tracking,
  String shopId, {
  ClipBudget? budget,
  String platformLabel = '',
}) async {
  final path = await _pickImagePath();
  if (path == null || !context.mounted) return;
  // Ảnh vượt giới hạn của sàn vẫn lưu NGUYÊN VẸN — không nén, không cắt (FR-20:
  // chuỗi bằng chứng phải nguyên gốc). Chỉ cảnh báo để CSKH biết phải gửi bằng
  // link hồ sơ thay vì đính thẳng lên form khiếu nại.
  final bytes = await File(path).length();
  await queue.enqueue(
    tracking: tracking,
    type: 'Ảnh đính kèm',
    filePath: path,
    shopId: shopId,
  );
  if (!context.mounted) return;
  final limit = budget?.maxImageBytes;
  if (limit != null && bytes > limit) {
    _toast(
      context,
      context.l10n.imageOverPlatformLimit(
        ClipBudget.megabytesLabel(bytes),
        platformLabel,
        ClipBudget.megabytesLabel(limit),
      ),
    );
    return;
  }
  _toast(context, context.l10n.toastPhotoQueued);
}

/// Shop picker backed by the repository. The dev/prod app must choose a real
/// backend shop id before Flow 2 loads orders for that shop.
class _ChooseShopRoute extends StatefulWidget {
  const _ChooseShopRoute({
    required this.repo,
    this.onSelect,
    this.onManage,
    this.onCreateShop,
    this.onLogout,
    this.autoEnter = true,
  });

  final EcRepository repo;
  final ValueChanged<EcShopSummary>? onSelect;
  final VoidCallback? onManage;
  final VoidCallback? onCreateShop;
  final VoidCallback? onLogout;
  final bool autoEnter;

  @override
  State<_ChooseShopRoute> createState() => _ChooseShopRouteState();
}

class _ChooseShopRouteState extends State<_ChooseShopRoute> {
  late Future<List<EcShopSummary>> _shops = _loadShops();
  var _autoSelected = false;

  Future<List<EcShopSummary>> _loadShops() async {
    final shops = await widget.repo.shops();
    return shops.map(_shopFromDto).toList();
  }

  void _retry() => setState(() {
    _shops = _loadShops();
  });

  void _autoSelectIfNeeded(List<EcShopSummary> shops) {
    if (_autoSelected || !widget.autoEnter || widget.onSelect == null) return;
    EcShopSummary? target;
    final rememberedId = _appMemory()?.getString(_lastShopIdKey);
    if (rememberedId != null) {
      for (final shop in shops) {
        if (shop.id == rememberedId) {
          target = shop;
          break;
        }
      }
    }
    target ??= shops.length == 1 ? shops.first : null;
    if (target == null) return;
    final selected = target;
    _autoSelected = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onSelect!(selected);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EcShopSummary>>(
      future: _shops,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const CupertinoPageScaffold(
            backgroundColor: BrandColors.bg,
            child: Center(child: CupertinoActivityIndicator()),
          );
        }
        if (snap.hasError) {
          return _RouteLoadError(
            title: context.l10n.errorLoadShopList,
            detail: _dataErrorText(context.l10n, snap.error!),
            onRetry: _retry,
          );
        }
        final shops = snap.data ?? const [];
        if (shops.isEmpty) {
          return EcNoShopScreen(
            onCreate: widget.onCreateShop ?? widget.onManage,
            onInviteTap: () => _toast(context, context.l10n.toastInvitePending),
            onLogout: widget.onLogout,
          );
        }
        _autoSelectIfNeeded(shops);
        return EcChooseShopScreen(
          shops: shops,
          showManage: shops.any((shop) => shop.role != 'staff'),
          onSelect: widget.onSelect,
          onManage: widget.onManage,
          // Cùng đích với nút "Tạo shop" ở màn chưa-có-shop; thiếu dòng này
          // hàng "Tạo shop mới" vẫn vẽ ra nhưng bấm không ra gì.
          onAddShop: widget.onCreateShop ?? widget.onManage,
          onLogout: widget.onLogout,
        );
      },
    );
  }
}

class _ShopMgmtRoute extends StatefulWidget {
  const _ShopMgmtRoute({
    required this.repo,
    this.onBack,
    this.onAddShop,
    this.onShopTap,
  });

  final EcRepository repo;
  final VoidCallback? onBack;
  final VoidCallback? onAddShop;
  final ValueChanged<EcShopMgmtEntry>? onShopTap;

  @override
  State<_ShopMgmtRoute> createState() => _ShopMgmtRouteState();
}

class _ShopMgmtRouteState extends State<_ShopMgmtRoute> {
  late Future<List<EcShopMgmtEntry>> _shops = _load();

  Future<List<EcShopMgmtEntry>> _load() async {
    final l10n = context.l10n;
    final shops = await widget.repo.shops();
    return shops
        .where((shop) => shop.role != 'staff')
        .map((s) => _shopMgmtFromDto(l10n, s))
        .toList();
  }

  void _retry() => setState(() {
    _shops = _load();
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EcShopMgmtEntry>>(
      future: _shops,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const CupertinoPageScaffold(
            backgroundColor: BrandColors.bg,
            child: Center(child: CupertinoActivityIndicator()),
          );
        }
        if (snap.hasError) {
          return _RouteLoadError(
            title: context.l10n.errorLoadShopMgmt,
            detail: _dataErrorText(context.l10n, snap.error!),
            onRetry: _retry,
          );
        }
        return EcShopMgmtScreen(
          shops: snap.data ?? const [],
          onBack: widget.onBack,
          onAddShop: widget.onAddShop,
          onShopTap: widget.onShopTap,
        );
      },
    );
  }
}

class _CreateShopRoute extends StatefulWidget {
  const _CreateShopRoute({required this.repo, this.onBack, this.onCreated});

  final EcRepository repo;
  final VoidCallback? onBack;
  final ValueChanged<EcShopSummary>? onCreated;

  @override
  State<_CreateShopRoute> createState() => _CreateShopRouteState();
}

class _CreateShopRouteState extends State<_CreateShopRoute> {
  final _name = TextEditingController();
  var _platform = 'shopee';
  var _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final shop = await widget.repo.createShop(
        name: _name.text.trim(),
        platform: _platform,
      );
      if (!mounted) return;
      widget.onCreated?.call(_shopFromDto(shop));
    } on Object catch (error) {
      if (mounted) _toast(context, _dataErrorText(context.l10n, error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return EcCreateShopScreen(
      nameController: _name,
      selectedPlatform: _platform,
      onBack: widget.onBack,
      onPlatformSelected: (platform) => setState(() => _platform = platform),
      onCreate: _saving ? null : _create,
    );
  }
}

class _ShopDetailRoute extends StatefulWidget {
  const _ShopDetailRoute({
    required this.repo,
    required this.shop,
    this.onBack,
    this.onMemberMore,
    this.onInviteMember,
    this.onTapResolution,
    this.onTapClipDuration,
    this.onEditType,
    this.onDeleteType,
    this.onAddType,
  });

  final EcRepository repo;
  final EcShopSummary shop;
  final VoidCallback? onBack;
  final Future<void> Function(EcShopMember member)? onMemberMore;
  final Future<void> Function()? onInviteMember;
  final Future<void> Function()? onTapResolution;
  final Future<void> Function()? onTapClipDuration;
  final Future<void> Function(EcVideoType type)? onEditType;
  final Future<void> Function(EcVideoType type)? onDeleteType;
  final Future<void> Function()? onAddType;

  @override
  State<_ShopDetailRoute> createState() => _ShopDetailRouteState();
}

class _ShopDetailRouteState extends State<_ShopDetailRoute> {
  late Future<_ShopDetailData> _detail = _load();

  Future<_ShopDetailData> _load() async {
    final l10n = context.l10n;
    return _ShopDetailData(
      // Đọc lại shop, không dùng snapshot của route: đổi độ phân giải hay thời
      // lượng xong quay về là mức đề xuất + cảnh báo phải đúng ngay.
      shop: await widget.repo.shop(widget.shop.id),
      members: (await widget.repo.members(
        widget.shop.id,
      )).map((m) => _memberFromDto(l10n, m)).toList(),
      videoTypes: (await widget.repo.videoTypes(
        widget.shop.id,
      )).map(_videoTypeFromDto).toList(),
    );
  }

  void _retry() => setState(() {
    _detail = _load();
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ShopDetailData>(
      future: _detail,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const CupertinoPageScaffold(
            backgroundColor: BrandColors.bg,
            child: Center(child: CupertinoActivityIndicator()),
          );
        }
        if (snap.hasError) {
          return _RouteLoadError(
            title: context.l10n.errorLoadShopDetail,
            detail: _dataErrorText(context.l10n, snap.error!),
            onRetry: _retry,
          );
        }
        final detail = snap.data!;
        return EcShopDetailScreen(
          shopName: detail.shop.name,
          platformLabel: _platformDisplayName(detail.shop.platform),
          resolution: detail.shop.resolution,
          clipBudget: _budgetFromDto(detail.shop),
          members: detail.members,
          videoTypes: detail.videoTypes,
          onBack: widget.onBack,
          onMemberMore: widget.onMemberMore == null
              ? null
              : (member) => widget.onMemberMore!(member).then((_) {
                  if (mounted) _retry();
                }),
          onInviteMember: widget.onInviteMember == null
              ? null
              : () => widget.onInviteMember!().then((_) {
                  if (mounted) _retry();
                }),
          onTapResolution: widget.onTapResolution == null
              ? null
              : () => widget.onTapResolution!().then((_) {
                  if (mounted) _retry();
                }),
          onTapClipDuration: widget.onTapClipDuration == null
              ? null
              : () => widget.onTapClipDuration!().then((_) {
                  if (mounted) _retry();
                }),
          onEditType: widget.onEditType == null
              ? null
              : (type) => widget.onEditType!(type).then((_) {
                  if (mounted) _retry();
                }),
          onDeleteType: widget.onDeleteType == null
              ? null
              : (type) => widget.onDeleteType!(type).then((_) {
                  if (mounted) _retry();
                }),
          onAddType: widget.onAddType == null
              ? null
              : () => widget.onAddType!().then((_) {
                  if (mounted) _retry();
                }),
        );
      },
    );
  }
}

class _ShopDetailData {
  const _ShopDetailData({
    required this.shop,
    required this.members,
    required this.videoTypes,
  });

  final ShopDto shop;

  final List<EcShopMember> members;
  final List<EcVideoType> videoTypes;
}

EcShopMember _memberFromDto(AppLocalizations l10n, MemberDto member) =>
    EcShopMember(
      accountUid: member.accountUid,
      roleCode: member.role,
      name: member.name ?? member.email ?? member.accountUid,
      role: _roleDisplayName(l10n, member.role),
    );

/// Loại tự đặt mang icon người tạo đã chọn; ba loại mặc định (và loại tạo
/// trước khi màn chọn icon được nối dây) rơi về icon suy từ tên.
EcVideoType _videoTypeFromDto(VideoTypeDto type) {
  final pickedIcon = type.icon == null
      ? null
      : EcCreateTypeScreen.iconFor(type.icon!);
  return EcVideoType(
    id: type.id,
    name: type.name,
    locked: type.isDefault,
    iconKey: type.icon,
    colorHex: type.color,
    icon:
        pickedIcon ??
        switch (type.name) {
          'Đóng hàng' => Icons.inventory_2_outlined,
          'Đơn vị vận chuyển' => Icons.local_shipping_outlined,
          'Trả hàng' => Icons.assignment_return_outlined,
          _ => Icons.videocam_outlined,
        },
  );
}

class _CreateTypeRoute extends StatefulWidget {
  const _CreateTypeRoute({
    required this.repo,
    required this.shopId,
    this.type,
    this.onDone,
  });

  final EcRepository repo;
  final String shopId;
  final EcVideoType? type;
  final VoidCallback? onDone;

  @override
  State<_CreateTypeRoute> createState() => _CreateTypeRouteState();
}

class _CreateTypeRouteState extends State<_CreateTypeRoute> {
  late final TextEditingController _name = TextEditingController(
    text: widget.type?.name ?? '',
  );
  var _saving = false;
  late var _icon = EcCreateTypeScreen.iconIndexOf(widget.type?.iconKey);
  late var _color = EcCreateTypeScreen.colorIndexOf(widget.type?.colorHex);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final name = _name.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    final icon = EcCreateTypeScreen.iconKeys[_icon];
    final color = EcCreateTypeScreen.colorHexes[_color];
    try {
      final typeId = widget.type?.id;
      if (typeId == null) {
        await widget.repo.addVideoType(
          widget.shopId,
          name,
          icon: icon,
          color: color,
        );
      } else {
        await widget.repo.renameVideoType(
          widget.shopId,
          typeId,
          name,
          icon: icon,
          color: color,
        );
      }
      if (mounted) widget.onDone?.call();
    } on Object catch (error) {
      if (mounted) _toast(context, _dataErrorText(context.l10n, error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return EcCreateTypeScreen(
      nameController: _name,
      selectedIcon: _icon,
      onIconSelected: (i) => setState(() => _icon = i),
      selectedColor: _color,
      onColorSelected: (i) => setState(() => _color = i),
      onCancel: () => Navigator.of(context).pop(),
      onCreate: _saving ? null : _save,
    );
  }
}

class _TypeSheetRoute extends StatefulWidget {
  const _TypeSheetRoute({
    required this.repo,
    required this.shopId,
    required this.selectedType,
    required this.onManageTypes,
    required this.onSelected,
  });

  final EcRepository repo;
  final String shopId;
  final String selectedType;
  final VoidCallback onManageTypes;
  final ValueChanged<String> onSelected;

  @override
  State<_TypeSheetRoute> createState() => _TypeSheetRouteState();
}

class _TypeSheetRouteState extends State<_TypeSheetRoute> {
  late final Future<List<VideoTypeDto>> _types = widget.repo.videoTypes(
    widget.shopId,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<VideoTypeDto>>(
      future: _types,
      builder: (context, snap) {
        final liveTypes = snap.hasData
            ? snap.data!.map(_captureTypeFromDto).toList()
            : const <capture.EcVideoType>[];
        final types = liveTypes.isEmpty ? ecDefaultVideoTypes : liveTypes;
        return EcTypeSheetScreen(
          types: types,
          selectedType: widget.selectedType,
          onManageTypes: widget.onManageTypes,
          onSelectType: widget.onSelected,
        );
      },
    );
  }
}

capture.EcVideoType _captureTypeFromDto(VideoTypeDto type) =>
    capture.EcVideoType(
      label: type.name,
      locked: type.isDefault,
      icon: switch (type.name) {
        'Đóng hàng' => Icons.inventory_2_outlined,
        'Đơn vị vận chuyển' => Icons.local_shipping_outlined,
        'ĐV vận chuyển' => Icons.local_shipping_outlined,
        'Trả hàng' => Icons.replay,
        _ => Icons.videocam_outlined,
      },
    );

class _InviteMemberRoute extends StatefulWidget {
  const _InviteMemberRoute({required this.repo, required this.shopId});

  final EcRepository repo;
  final String shopId;

  @override
  State<_InviteMemberRoute> createState() => _InviteMemberRouteState();
}

class _InviteMemberRouteState extends State<_InviteMemberRoute> {
  final _contact = TextEditingController();
  var _saving = false;

  @override
  void dispose() {
    _contact.dispose();
    super.dispose();
  }

  String _roleCode(String role) =>
      role.contains('Quản lý') ? 'manager' : 'staff';

  Future<void> _invite(EcMemberInvite invite) async {
    if (_saving || invite.contact.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      final result = await widget.repo.sendShopInvite(
        widget.shopId,
        contact: invite.contact.trim(),
        role: _roleCode(invite.role),
      );
      if (!mounted) return;
      context.pop();
      _toast(
        context,
        result.status == 'pending'
            ? context.l10n.toastInviteSent
            : context.l10n.toastMemberAdded,
      );
    } on Object catch (error) {
      if (mounted) _toast(context, _dataErrorText(context.l10n, error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => EcInviteMemberScreen(
    contactController: _contact,
    onCancel: () => context.pop(),
    onInvite: _saving ? null : _invite,
  );
}

/// Orders tab — loads a page from the repository, supports pull-to-refresh and
/// infinite scroll (20/page), and shows the live upload-queue count in the
/// header. First page shows a full-screen spinner; later pages a trailing one.
class _OrdersRoute extends StatefulWidget {
  const _OrdersRoute({
    required this.repo,
    required this.queue,
    required this.shopId,
    required this.shopName,
    this.evidenceCountOverrides,
    this.onBack,
    this.onNavRecord,
    this.onNavAccount,
    this.onQueueTap,
    this.onOrderTap,
    this.onScan,
  });

  final EcRepository repo;
  final EcUploadQueue queue;
  final String shopId;
  final String shopName;
  final _EvidenceCountOverrides? evidenceCountOverrides;
  final VoidCallback? onBack;
  final VoidCallback? onNavRecord;
  final VoidCallback? onNavAccount;
  final VoidCallback? onQueueTap;
  final Future<void> Function(OrderSummaryDto order)? onOrderTap;
  final Future<String?> Function()? onScan;

  @override
  State<_OrdersRoute> createState() => _OrdersRouteState();
}

class _OrdersRouteState extends State<_OrdersRoute> {
  List<OrderSummaryDto> _orders = const [];
  List<EcVideoTypeOption> _videoTypes = const [];
  bool _loading = true;
  bool _loadingPage = false;
  EcOrderPage _page = const EcOrderPage();
  String _query = '';
  EcOrderFilters _filters = const EcOrderFilters();
  var _searchGeneration = 0;
  Object? _loadError;

  /// Kết quả tìm kiếm không phân trang (backend trả hết một lần), nên phần
  /// hiển thị trang bị dọn sạch để thanh phân trang biến mất.
  static const _unpaged = EcOrderPage();

  EcOrderPage _pageOf(OrderPageDto dto) => EcOrderPage(
    page: dto.page,
    total: dto.total,
    pageSize: dto.pageSize,
    shown: dto.items.length,
  );

  @override
  void initState() {
    super.initState();
    _loadFirst();
    _loadVideoTypes();
  }

  /// Options for the "Loại video" filter. Best-effort: the list still works
  /// without them, that chip just has nothing but its "all types" entry.
  Future<void> _loadVideoTypes() async {
    try {
      final types = await widget.repo.videoTypes(widget.shopId);
      if (!mounted) return;
      setState(() {
        _videoTypes = [
          for (final type in types)
            EcVideoTypeOption(id: type.id, name: type.name),
        ];
      });
    } on Object {
      /* leave the chip with just "all types" */
    }
  }

  /// Re-queries with the new filter set. Filters and search are exclusive on
  /// the backend (a `q` search ignores them), so picking a filter clears the
  /// search box's query rather than silently dropping one of the two.
  Future<void> _applyFilters(EcOrderFilters filters) async {
    _filters = filters;
    await _loadFirst();
  }

  Future<void> _loadFirst({bool showSpinner = false}) async {
    final queryGeneration = ++_searchGeneration;
    _query = '';
    if (showSpinner && mounted) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }
    try {
      final result = await _fetchPage(_page.page);
      if (!mounted || queryGeneration != _searchGeneration) return;
      setState(() {
        _orders = result.items;
        _page = _pageOf(result);
        _loading = false;
        _loadError = null;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _orders = const [];
        _page = _unpaged;
        _loading = false;
        _loadError = error;
      });
    }
  }

  Future<OrderPageDto> _fetchPage(int page) => widget.repo.orders(
    widget.shopId,
    page: page,
    uploadState: _filters.uploadState,
    fromTs: _filters.fromTs,
    videoTypeId: _filters.videoTypeId,
  );

  /// Chuyển trang. Lỗi thì giữ nguyên trang đang xem thay vì bỏ trắng danh
  /// sách — người dùng vẫn còn cái đang đọc và chỉ cần bấm lại.
  Future<void> _goToPage(int page) async {
    if (_loadingPage || page == _page.page) return;
    final queryGeneration = ++_searchGeneration;
    setState(() => _loadingPage = true);
    try {
      final result = await _fetchPage(page);
      if (!mounted || queryGeneration != _searchGeneration) return;
      setState(() {
        _orders = result.items;
        _page = _pageOf(result);
        _loadingPage = false;
        _loadError = null;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _loadingPage = false);
      if (queryGeneration == _searchGeneration) {
        _toast(context, _dataErrorText(context.l10n, error));
      }
    }
  }

  /// Pull-to-refresh — reload the page being viewed (no full-screen spinner).
  Future<void> _refresh() async {
    final trimmed = _query.trim();
    try {
      if (trimmed.isEmpty) {
        final result = await _fetchPage(_page.page);
        if (!mounted) return;
        setState(() {
          _orders = result.items;
          _page = _pageOf(result);
          _loadError = null;
        });
        return;
      }
      final hits = await widget.repo.searchOrders(widget.shopId, trimmed);
      if (!mounted) return;
      setState(() {
        _orders = hits;
        _page = _unpaged;
        _loadError = null;
      });
    } on Object catch (error) {
      if (mounted) _toast(context, _dataErrorText(context.l10n, error));
    }
  }

  /// Gõ tìm kiếm mới thì quay về trang 1: số trang cũ không còn nghĩa gì với
  /// tập kết quả khác.
  Future<void> _search(String query) async {
    final trimmed = query.trim();
    final queryGeneration = ++_searchGeneration;
    _query = trimmed;
    try {
      if (trimmed.isEmpty) {
        final result = await _fetchPage(1);
        if (!mounted || queryGeneration != _searchGeneration) return;
        setState(() {
          _orders = result.items;
          _page = _pageOf(result);
          _loadError = null;
        });
        return;
      }
      final hits = await widget.repo.searchOrders(widget.shopId, trimmed);
      if (!mounted || queryGeneration != _searchGeneration) return;
      setState(() {
        _orders = hits;
        _page = _unpaged;
        _loadError = null;
      });
    } on Object catch (error) {
      if (mounted && queryGeneration == _searchGeneration) {
        _toast(context, _dataErrorText(context.l10n, error));
      }
    }
  }

  /// A scanned barcode/QR is a full, exact tracking code — unlike typed
  /// search (which narrows as the user types and reasonably shows every
  /// partial match), a scan should show exactly the one order it names, not
  /// every order the backend's substring search happens to also match.
  Future<void> _searchScannedCode(String code) async {
    final trimmed = code.trim();
    final queryGeneration = ++_searchGeneration;
    _query = trimmed;
    try {
      final matches = await widget.repo.searchOrders(widget.shopId, trimmed);
      if (!mounted || queryGeneration != _searchGeneration) return;
      final key = normalizeTrackingCode(trimmed);
      final exact = matches
          .where((o) => normalizeTrackingCode(o.tracking) == key)
          .toList();
      setState(() {
        _orders = exact;
        _page = _unpaged;
        _loadError = null;
      });
      if (exact.isEmpty) _toast(context, context.l10n.scannedCodeNotFound);
    } on Object catch (error) {
      if (mounted && queryGeneration == _searchGeneration) {
        _toast(context, _dataErrorText(context.l10n, error));
      }
    }
  }

  /// The server's own count, unless a fresher one is known from actually
  /// having opened this order (see `_EvidenceCountOverrides`).
  int _evidenceCount(OrderSummaryDto o) =>
      widget.evidenceCountOverrides?[o.tracking]?.$1 ?? o.evidenceCount;

  int _errorCount(OrderSummaryDto o) =>
      widget.evidenceCountOverrides?[o.tracking]?.$2 ?? o.errorCount;

  EcOrderRow _toRow(AppLocalizations l10n, OrderSummaryDto o) {
    final capturedAt = o.lastCapturedAt;
    return EcOrderRow(
      code: o.tracking,
      time: capturedAt == null
          ? '—'
          : _hhmm(DateTime.fromMillisecondsSinceEpoch(capturedAt)),
      type: o.latestType ?? l10n.orderNoEvidence,
      videoCount: _evidenceCount(o),
      errorCount: _errorCount(o),
      pendingCount: o.pendingCount,
    );
  }

  List<EcHomeStat> _stats(EcUploadQueue queue) {
    final today = DateTime.now();
    final todayOrders = _orders.where((order) {
      final created = DateTime.fromMillisecondsSinceEpoch(order.createdAt);
      return _sameLocalDate(created, today);
    }).length;
    final evidenceCount = _orders.fold<int>(
      0,
      (total, order) => total + order.evidenceCount,
    );
    // Ba icon là ba glyph khác nhau trong khung F2-01 (package / video /
    // cloud-upload) — bỏ trống thì cả ba cùng ra package.
    return [
      EcHomeStat(value: '$todayOrders', label: context.l10n.statOrdersToday),
      EcHomeStat(
        value: '$evidenceCount',
        label: context.l10n.statVideosRecorded,
        icon: LucideIcons.video,
      ),
      EcHomeStat(
        value: '${_pendingUploads(queue)}',
        label: context.l10n.statPendingUpload,
        icon: LucideIcons.cloudUpload,
        // Header không còn chip mây (design không vẽ), nên thẻ này là lối vào
        // màn hàng đợi upload.
        onTap: widget.onQueueTap,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const CupertinoPageScaffold(
        backgroundColor: BrandColors.bg,
        child: Center(child: CupertinoActivityIndicator()),
      );
    }
    final loadError = _loadError;
    if (loadError != null) {
      return _RouteLoadError(
        title: context.l10n.errorLoadOrders,
        detail: _dataErrorText(context.l10n, loadError),
        onRetry: () => _loadFirst(showSpinner: true),
      );
    }
    // An order every clip has been deleted from is an empty shell — nothing
    // left to review, so it shouldn't linger in the list at all.
    final visibleOrders = _orders.where((o) => _evidenceCount(o) > 0).toList();
    final rows = visibleOrders.map((o) => _toRow(context.l10n, o)).toList();
    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.queue,
        if (widget.evidenceCountOverrides != null)
          widget.evidenceCountOverrides!,
      ]),
      builder: (context, _) => EcHomeOrdersScreen(
        shopName: widget.shopName,
        orders: rows,
        stats: _stats(widget.queue),
        onBack: widget.onBack,
        onNavRecord: widget.onNavRecord,
        onNavAccount: widget.onNavAccount,
        onOrderTap: widget.onOrderTap == null
            ? null
            : (row) {
                final matches = visibleOrders.where(
                  (o) => o.tracking == row.code,
                );
                if (matches.isEmpty) return;
                final order = matches.first;
                // Deleting evidence inside the order detail screen changes
                // its evidence/error count — refresh this list on return so
                // the card shown here doesn't keep showing stale counts (or
                // an order that's now empty doesn't stay listed).
                //
                // `_refresh` chứ không phải `_loadFirst`: người dùng tìm một mã
                // rồi mở nó ra, quay lại mà danh sách nhảy về trang đầu không
                // lọc thì mất cả từ khoá lẫn vị trí đang đọc. `_refresh` nạp
                // lại đúng thứ đang hiển thị — kết quả tìm nếu đang tìm, còn
                // không thì đúng trang hiện tại.
                widget.onOrderTap!(order).then((_) {
                  if (mounted) unawaited(_refresh());
                });
              },
        onNavOrders: () {},
        onScan: widget.onScan,
        onScanResult: _searchScannedCode,
        onSearchChanged: _search,
        videoTypes: _videoTypes,
        onFiltersChanged: _applyFilters,
        onRefresh: _refresh,
        pageInfo: _page,
        onPageChanged: _goToPage,
        isPageLoading: _loadingPage,
      ),
    );
  }
}

class _OrderRoute extends StatefulWidget {
  const _OrderRoute({
    required this.repo,
    required this.queue,
    required this.shop,
    required this.order,
    this.share,
    this.evidenceCountOverrides,
    this.onBack,
    this.onOpenVideo,
  });

  final EcRepository repo;
  final EcUploadQueue queue;
  final EcShopSummary shop;
  final OrderSummaryDto order;

  /// Share sheet của hệ điều hành; `null` (thiếu DI trong test) thì nút chia
  /// sẻ rơi về clipboard.
  final ShareService? share;
  final _EvidenceCountOverrides? evidenceCountOverrides;
  final VoidCallback? onBack;
  final Future<void> Function(_VideoRouteExtra extra)? onOpenVideo;

  @override
  State<_OrderRoute> createState() => _OrderRouteState();
}

class _OrderRouteState extends State<_OrderRoute> {
  late Future<_OrderDetailData> _detail = _load();

  Future<_OrderDetailData> _load() async {
    final detail = await widget.repo.order(widget.shop.id, widget.order.id);
    // The orders list can only show whatever `evidence_count`/`error_count`
    // the server last computed for this order — which, unlike this detail
    // fetch, isn't recalculated when a clip is deleted (see
    // _EvidenceCountOverrides' doc comment). Report the true, live numbers
    // from the data already being fetched here so that list corrects itself
    // without needing its own extra request.
    final live = detail.evidence.where((e) => e.uploadStatus != 'deleted');
    widget.evidenceCountOverrides?.report(
      widget.order.tracking,
      live.length,
      live.where((e) => e.uploadStatus == 'error').length,
    );
    final types = await widget.repo.videoTypes(widget.shop.id);
    // "Người quay" was showing the raw Firebase uid — resolve it to whoever
    // that account actually is (name, else email) so it reads like a person
    // instead of a token. Best-effort: an empty map just falls back to the
    // uid, same as before, rather than failing the whole screen.
    var memberNames = const <String, String>{};
    try {
      final members = await widget.repo.members(widget.shop.id);
      memberNames = {
        for (final m in members)
          if ((m.name ?? m.email) != null) m.accountUid: (m.name ?? m.email)!,
      };
    } on Object {
      // Keep the empty map — evidence still renders, just without names.
    }
    // FR-07: link hồ sơ khiếu nại, nếu web admin đã tạo cho đơn này. Best
    // effort — nhân viên bị 403 ở endpoint này, và không có link thì thẻ chỉ
    // ẩn đi chứ không được làm hỏng cả màn.
    String? dossierUrl;
    try {
      final dossier = await widget.repo.dossier(
        widget.shop.id,
        widget.order.id,
      );
      if (dossier != null && !dossier.revoked) {
        dossierUrl = widget.repo.dossierShareUrl(dossier.shareToken);
      }
    } on Object {
      // Không có quyền hoặc mạng lỗi — coi như chưa có link.
    }
    return _OrderDetailData(
      detail: detail,
      videoTypes: types,
      memberNames: memberNames,
      dossierUrl: dossierUrl,
    );
  }

  void _retry() => setState(() {
    _detail = _load();
  });

  Iterable<UploadTask> get _pendingTasks => widget.queue.tasks.where(
    (t) =>
        t.shopId == widget.shop.id &&
        t.tracking == widget.order.tracking &&
        t.state != EcUploadState.done,
  );

  int get _pendingCount => _pendingTasks.length;

  /// Bằng chứng đã lên server nhưng upload hỏng — R2 không có object, nên hồ
  /// sơ khiếu nại sẽ thiếu đúng những clip này. Hàng chờ local (`_pendingTasks`)
  /// không biết gì về chúng: task đã rời hàng chờ từ lâu, chỉ bản ghi trên
  /// server còn giữ trạng thái lỗi. Cộng cả hai thì banner mới phản ánh đủ số
  /// bằng chứng bị thiếu.
  int _failedCount(OrderDetailDto detail) => detail.evidence
      .where((e) => e.uploadStatus == 'error' || e.uploadStatus == 'quota_hold')
      .length;

  /// "Thử lại" trên banner "còn N bằng chứng chưa upload". Banner nói về hàng
  /// chờ upload, nên nút phải đẩy lại chính những task đó — tải lại chi tiết
  /// đơn không gỡ được cái gì đang kẹt. Đọc chi tiết lại sau để timeline lấy
  /// được trạng thái mới khi upload xong.
  Future<void> _retryPendingUploads() async {
    final stuck = _pendingTasks
        .where((t) => t.state != EcUploadState.uploading)
        .toList();
    if (stuck.isEmpty) return;
    for (final task in stuck) {
      await widget.queue.retry(task.id);
    }
    if (mounted) _retry();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_OrderDetailData>(
      future: _detail,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const CupertinoPageScaffold(
            backgroundColor: BrandColors.bg,
            child: Center(child: CupertinoActivityIndicator()),
          );
        }
        if (snap.hasError) {
          return _RouteLoadError(
            title: context.l10n.errorLoadOrderDetail,
            detail: _dataErrorText(context.l10n, snap.error!),
            onRetry: _retry,
          );
        }
        final data = snap.data!;
        final days = _timelineDays(
          context.l10n,
          data.detail.evidence,
          data.videoTypes,
          data.memberNames,
        );
        return ListenableBuilder(
          listenable: widget.queue,
          builder: (context, _) => EcOrderTimelineScreen(
            orderCode: data.detail.order.tracking,
            days: days,
            pendingUploadCount: _pendingCount + _failedCount(data.detail),
            onBack: widget.onBack,
            onVideoTap: (video) => widget.onOpenVideo
                ?.call(
                  _VideoRouteExtra(
                    shopId: widget.shop.id,
                    orderId: widget.order.id,
                    evidenceId: video.id,
                    canDelete: widget.shop.role != 'staff',
                    video: _videoDetail(context.l10n, video),
                  ),
                )
                .then((_) {
                  if (mounted) _retry();
                }),
            onVideoMenu: (video) => widget.onOpenVideo
                ?.call(
                  _VideoRouteExtra(
                    shopId: widget.shop.id,
                    orderId: widget.order.id,
                    evidenceId: video.id,
                    canDelete: widget.shop.role != 'staff',
                    video: _videoDetail(context.l10n, video),
                  ),
                )
                .then((_) {
                  if (mounted) _retry();
                }),
            onCopyCode: () => _copyText(
              context,
              data.detail.order.tracking,
              context.l10n.labelTrackingCode,
            ),
            onRetryUpload: () => unawaited(_retryPendingUploads()),
            dossierUrl: data.dossierUrl,
            onCopyDossierLink: data.dossierUrl == null
                ? null
                : () => _copyText(
                    context,
                    data.dossierUrl!,
                    context.l10n.dossierLinkTitle,
                  ),
            // Share sheet thật (share_plus đã có sẵn qua app_platform, dùng
            // cho chia sẻ video); thiếu DI thì rơi về clipboard chứ không im
            // lặng không làm gì.
            onShareDossierLink: data.dossierUrl == null
                ? null
                : () => unawaited(
                    _shareDossierLink(context, widget.share, data.dossierUrl!),
                  ),
            onAttachPhoto: () => _attachPhoto(
              context,
              widget.queue,
              data.detail.order.tracking,
              widget.shop.id,
              budget: widget.shop.clipBudget,
              platformLabel: _platformDisplayName(widget.shop.platform),
            ),
          ),
        );
      },
    );
  }
}

class _OrderDetailData {
  const _OrderDetailData({
    required this.detail,
    required this.videoTypes,
    this.memberNames = const {},
    this.dossierUrl,
  });

  final OrderDetailDto detail;
  final List<VideoTypeDto> videoTypes;

  /// Link công khai của hồ sơ khiếu nại, `null` khi đơn chưa có hoặc đã bị
  /// thu hồi — thẻ link chỉ hiện khi có giá trị.
  final String? dossierUrl;

  /// Account uid -> display name (name, else email), for resolving
  /// [EvidenceDto.createdByUid] to something readable.
  final Map<String, String> memberNames;
}

/// Corrects the orders list's evidence/error counts against reality.
///
/// `listOrders`' per-order `evidence_count`/`error_count` are server-computed
/// totals that, as observed live, are never decremented when a clip is
/// deleted (deleteEvidence only removes the row; nothing recomputes the
/// order's own aggregate) — so the list keeps showing however many clips
/// were *ever* recorded, not however many still exist. The order detail
/// screen already fetches the full evidence list to render itself; this
/// captures the true, live count from that same fetch and lets the orders
/// list use it instead, with no extra network calls.
class _EvidenceCountOverrides extends ChangeNotifier {
  final Map<String, (int count, int errorCount)> _byTracking = {};

  void report(String tracking, int count, int errorCount) {
    final current = _byTracking[tracking];
    if (current != null && current.$1 == count && current.$2 == errorCount) {
      return;
    }
    _byTracking[tracking] = (count, errorCount);
    notifyListeners();
  }

  (int count, int errorCount)? operator [](String tracking) =>
      _byTracking[tracking];
}

class _VideoPlayerRoute extends StatefulWidget {
  const _VideoPlayerRoute({
    required this.title,
    required this.recordedAt,
    required this.url,
    required this.service,
    this.onBack,
  });

  final String title;

  /// Recording date + time, e.g. `23/07/2026 · 10:23` — matches what's shown
  /// on the Ghi hình screen while recording and in the evidence detail sheet.
  final String recordedAt;
  final String url;
  final VideoPlayerService service;
  final VoidCallback? onBack;

  @override
  State<_VideoPlayerRoute> createState() => _VideoPlayerRouteState();
}

/// Nhãn mã vận đơn + giờ quay vẽ đè lên khung hình lúc phát.
///
/// Thay cho việc nung chữ vào file lúc quay: nung chữ bắt buộc phải encode lại
/// video, tức là file không còn là chuỗi byte gốc từ cảm biến — đúng thứ FR-07
/// cấm. Vẽ lúc phát giữ file nguyên vẹn mà ảnh chụp màn hình gửi sàn vẫn mang
/// đủ mã và giờ.
///
/// ponytail: chỉ hai dữ kiện. Pin và trạng thái mạng mà bản nung chữ cũ có thì
/// chưa bao giờ được lưu lại, nên không dựng lại được ở đây — muốn có thì phải
/// ghi chúng lúc quay trước đã.
class _PlaybackStamp extends StatelessWidget {
  const _PlaybackStamp({required this.title, required this.recordedAt});

  final String title;
  final String recordedAt;

  static const _style = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    shadows: [
      Shadow(color: Color(0xE6000000), blurRadius: 3, offset: Offset(0, 1)),
    ],
  );

  @override
  Widget build(BuildContext context) => Positioned(
    top: 8,
    left: 8,
    right: 8,
    child: IgnorePointer(
      child: Row(
        children: [
          Flexible(
            child: Text(title, overflow: TextOverflow.ellipsis, style: _style),
          ),
          const Spacer(),
          Text(recordedAt, style: _style),
        ],
      ),
    ),
  );
}

class _VideoPlayerRouteState extends State<_VideoPlayerRoute> {
  late final AppVideoPlayerController _controller = widget.service.network(
    Uri.parse(widget.url),
  );
  late final Future<void> _ready = _initialize();

  // While the user drags the scrubber, show the drag target instead of the
  // controller's real position — seeking is throttled to onChangeEnd, so the
  // real position wouldn't move smoothly with the thumb otherwise.
  Duration? _scrubPosition;

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return hours > 0
        ? '$hours:${two(minutes)}:${two(seconds)}'
        : '${two(minutes)}:${two(seconds)}';
  }

  Future<void> _initialize() async {
    // A clip fetched moments after its own upload finishes can briefly 404 —
    // the backend's order-detail response already has the URL, but the R2
    // object/CDN edge hasn't propagated it yet. A short retry window covers
    // that without needing the user to back out and reopen the sheet.
    const attempts = 3;
    for (var attempt = 1; attempt <= attempts; attempt++) {
      try {
        await _controller.initialize();
        await _controller.play();
        return;
      } on Object {
        if (attempt == attempts) rethrow;
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
    backgroundColor: Colors.black,
    child: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.recordedAt,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<void>(
              future: _ready,
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(
                    child: Text(
                      context.l10n.toastVideoPlayFailed,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CupertinoActivityIndicator());
                }
                final raw = _controller.rawController;
                if (raw == null) {
                  return Center(
                    child: Text(
                      context.l10n.toastVideoPlayFailed,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Center(
                        child: ValueListenableBuilder<VideoPlayerValue>(
                          valueListenable: _controller.valueListenable,
                          builder: (context, value, _) => GestureDetector(
                            onTap: _togglePlayPause,
                            child: AspectRatio(
                              aspectRatio: value.aspectRatio == 0
                                  ? 16 / 9
                                  : value.aspectRatio,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  VideoPlayer(raw),
                                  _PlaybackStamp(
                                    title: widget.title,
                                    recordedAt: widget.recordedAt,
                                  ),
                                  AnimatedOpacity(
                                    opacity: value.isPlaying ? 0 : 1,
                                    duration: const Duration(
                                      milliseconds: 150,
                                    ),
                                    child: const DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: Color(0x66000000),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(14),
                                        child: Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                          size: 36,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ValueListenableBuilder<VideoPlayerValue>(
                      valueListenable: _controller.valueListenable,
                      builder: (context, value, _) {
                        final duration = value.duration;
                        final position = _scrubPosition ?? value.position;
                        final sliderMax = duration.inMilliseconds > 0
                            ? duration.inMilliseconds.toDouble()
                            : 1.0;
                        final sliderValue = position.inMilliseconds
                            .toDouble()
                            .clamp(0.0, sliderMax);
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                          child: Row(
                            children: [
                              Text(
                                _formatDuration(position),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              Expanded(
                                child: CupertinoSlider(
                                  value: sliderValue,
                                  max: sliderMax,
                                  activeColor: Colors.white,
                                  thumbColor: Colors.white,
                                  onChanged: duration.inMilliseconds > 0
                                      ? (v) => setState(() {
                                          _scrubPosition = Duration(
                                            milliseconds: v.round(),
                                          );
                                        })
                                      : null,
                                  onChangeEnd: (v) {
                                    final target = Duration(
                                      milliseconds: v.round(),
                                    );
                                    _controller.seekTo(target);
                                    setState(() => _scrubPosition = null);
                                  },
                                ),
                              ),
                              Text(
                                _formatDuration(duration),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class _VideoRouteExtra {
  const _VideoRouteExtra({
    required this.video,
    required this.shopId,
    required this.orderId,
    required this.canDelete,
    this.evidenceId,
  });

  final EcVideoDetail video;
  final String shopId;
  final String orderId;
  final String? evidenceId;
  final bool canDelete;
}

class _VideoPlayerRouteExtra {
  const _VideoPlayerRouteExtra({
    required this.title,
    required this.recordedAt,
    required this.url,
    required this.videoPlayerService,
  });

  final String title;

  /// Recording date + time, e.g. `23/07/2026 · 10:23` — the same value shown
  /// on the Ghi hình screen while recording and in the evidence detail sheet.
  final String recordedAt;
  final String url;
  final VideoPlayerService videoPlayerService;
}

class _MemberActionExtra {
  const _MemberActionExtra({required this.shopId, required this.member});

  final String shopId;
  final EcShopMember member;
}

List<EcTimelineDay> _timelineDays(
  AppLocalizations l10n,
  List<EvidenceDto> evidence,
  List<VideoTypeDto> videoTypes,
  Map<String, String> memberNames,
) {
  final typeNames = {for (final t in videoTypes) t.id: t.name};
  final groups = <String, List<EcTimelineVideo>>{};
  for (final item in evidence) {
    // A deleted clip should vanish from the list entirely, not linger with a
    // "Đã xóa" badge — deletion already happened server-side (deleteEvidence);
    // showing it here was the actual bug, not a missing status label.
    //
    // 'error' rows are deliberately still shown (not filtered) — a failed
    // upload's evidence row is created server-side as soon as the upload
    // starts, before the clip is actually stored, and a retry never revisits
    // that row (it starts a fresh upload from scratch via ApiEvidenceUploader,
    // which now deletes the failed row itself the moment it gives up — see
    // ec_uploader.dart's _deleteEvidenceQuietly). So a lingering 'error' row
    // here is already the exception, not the rule; leaving it visible (and
    // deletable, like any other clip) is how a seller clears out whatever
    // failed attempts existed before that cleanup was in place.
    if (item.uploadStatus == 'deleted') continue;
    final captured = DateTime.fromMillisecondsSinceEpoch(item.capturedAt);
    final day = _dateLabel(captured);
    groups
        .putIfAbsent(day, () => [])
        .add(
          EcTimelineVideo(
            id: item.id,
            time: _hhmm(captured),
            label: typeNames[item.videoTypeId] ?? _kindLabel(l10n, item.kind),
            type: item.kind == 'photo'
                ? EcEvidenceType.image
                : EcEvidenceType.video,
            // Photos preview themselves; a clip needs its extracted poster.
            thumbUrl: item.kind == 'photo' ? item.url : item.thumbUrl,
            statusText: item.uploadStatus == 'done'
                ? null
                : item.uploadStatus == 'expired'
                ? _expiredLabel(l10n, item.retentionExpiresAt)
                : _uploadStatusLabel(l10n, item.uploadStatus),
            statusTone: switch (item.uploadStatus) {
              'done' => EcStatusTone.done,
              'error' => EcStatusTone.error,
              'quota_hold' => EcStatusTone.quota,
              // Hết hạn lưu trữ / đã xóa là kết thúc, không phải lỗi đang chờ
              // xử lý — khung design không có viên riêng nên dùng xám trung
              // tính thay vì đỏ.
              _ => EcStatusTone.waiting,
            },
            statusIcon: switch (item.uploadStatus) {
              'error' => Icons.refresh,
              'expired' => Icons.history_toggle_off,
              _ => null,
            },
            recordedAt: '${_dateLabel(captured)} · ${_hhmm(captured)}',
            recordedBy:
                (item.createdByUid == null
                    ? null
                    : memberNames[item.createdByUid]) ??
                l10n.recordedByFallback,
            device: item.device ?? l10n.deviceUnknown,
            uploadStatus: _uploadStatusLabel(l10n, item.uploadStatus),
            // The R2 object is gone once expired — nothing left to play/download.
            mediaUrl: item.uploadStatus == 'expired' ? null : item.url,
            durationSeconds: item.durationSeconds,
          ),
        );
  }
  return [
    for (final entry in groups.entries)
      EcTimelineDay(date: entry.key, videos: entry.value),
  ];
}

String _dateLabel(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year}';
}

String _kindLabel(AppLocalizations l10n, String kind) =>
    kind == 'photo' ? l10n.kindPhoto : l10n.kindVideo;

String _uploadStatusLabel(AppLocalizations l10n, String status) =>
    switch (status) {
      'done' => l10n.uploadStatusDone,
      'pending' => l10n.uploadStatusPending,
      'quota_hold' => l10n.uploadStatusQuotaHold,
      'deleted' => l10n.uploadStatusDeleted,
      'error' => l10n.uploadStatusError,
      'expired' => l10n.uploadStatusExpired,
      _ => status,
    };

/// FR-08 placeholder text: "loại video, giờ quay, đã quá hạn lưu trữ ngày X".
/// The label/time are already shown elsewhere in the row — this is just the
/// "ngày X" part. Falls back to the generic label when the retention sweep
/// (`retention.ts`) hasn't recorded a date for some reason.
String _expiredLabel(AppLocalizations l10n, int? retentionExpiresAt) {
  if (retentionExpiresAt == null) return l10n.uploadStatusExpired;
  final expired = DateTime.fromMillisecondsSinceEpoch(retentionExpiresAt);
  return l10n.expiredOnDate(_dateLabel(expired));
}

EcVideoDetail _videoDetail(AppLocalizations l10n, EcTimelineVideo video) =>
    EcVideoDetail(
      title: video.label,
      duration: _durationLabel(video.durationSeconds),
      recordedAt: video.recordedAt ?? video.time,
      recordedBy: video.recordedBy ?? l10n.recordedByFallback,
      device: video.device ?? l10n.deviceUnknown,
      uploadStatus: video.uploadStatus ?? l10n.uploadStatusDone,
      mediaUrl: video.mediaUrl,
      type: video.type,
    );

/// Formats a recorded clip length as `mm:ss`. Photos and evidence captured
/// before this field existed have no duration — falls back to `—`.
String _durationLabel(int? seconds) {
  if (seconds == null) return '—';
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(seconds ~/ 60)}:${two(seconds % 60)}';
}

String _dataErrorText(AppLocalizations l10n, Object error) {
  final text = error.toString();
  if (text.contains('401') || text.contains('403')) {
    return l10n.errorSessionInvalid;
  }
  if (text.contains('type_has_videos')) {
    return l10n.errorVideoTypeInUse;
  }
  if (text.contains('default_type_locked')) {
    return l10n.errorBuiltinVideoTypeLocked;
  }
  if (text.contains('name_taken')) {
    return l10n.errorVideoTypeNameExists;
  }
  return l10n.errorCheckNetwork;
}

class _RouteLoadError extends StatelessWidget {
  const _RouteLoadError({
    required this.title,
    required this.detail,
    required this.onRetry,
  });

  final String title;
  final String detail;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: BrandColors.bg,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 42,
                  color: BrandColors.rec,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: BrandColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  detail,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: BrandColors.mut,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                CupertinoButton.filled(
                  onPressed: onRetry,
                  child: Text(context.l10n.commonRetry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Upload-queue tab ("Hàng đợi upload"), driven live by [EcUploadQueue]: shows
/// the real recorded clips with their upload status, tab filtering, and retry.
class _QueueRoute extends StatefulWidget {
  const _QueueRoute({required this.queue, this.onBack, this.onUpgrade});

  final EcUploadQueue queue;
  final VoidCallback? onBack;
  final VoidCallback? onUpgrade;

  @override
  State<_QueueRoute> createState() => _QueueRouteState();
}

class _QueueRouteState extends State<_QueueRoute> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.queue,
      builder: (context, _) {
        final items = [
          for (final task in widget.queue.tasks) _taskToItem(task),
        ];
        return EcUploadQueueScreen(
          items: items,
          selectedTabIndex: _tab,
          onBack: widget.onBack,
          onUpgrade: widget.onUpgrade,
          onTabSelected: (i) => setState(() => _tab = i),
          onRetry: (item) {
            final id = item.id;
            if (id != null) widget.queue.retry(id);
          },
          onPause: (item) {
            final id = item.id;
            if (id != null) widget.queue.pause(id);
          },
          onResume: (item) {
            final id = item.id;
            if (id != null) widget.queue.resume(id);
          },
          onDelete: (item) =>
              _confirmDeleteQueueItem(context, widget.queue, item),
        );
      },
    );
  }
}

Future<void> _confirmDeleteQueueItem(
  BuildContext context,
  EcUploadQueue queue,
  EcUploadItem item,
) async {
  final id = item.id;
  if (id == null) return;
  final l10n = context.l10n;
  final confirmed = await showCupertinoDialog<bool>(
    context: context,
    builder: (dialogContext) => CupertinoAlertDialog(
      title: Text(l10n.queueDeleteConfirmTitle),
      content: Text(l10n.queueDeleteConfirmBody),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.commonCancel),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.queueDeleteAction),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  await queue.delete(id);
  if (context.mounted) _toast(context, l10n.toastQueueItemDeleted);
}

EcUploadItem _taskToItem(UploadTask task) => EcUploadItem(
  id: task.id,
  code: task.tracking,
  typeLabel: task.type,
  timeRange: _hhmm(task.createdAt),
  status: switch (task.state) {
    EcUploadState.waiting => EcUploadStatus.waiting,
    EcUploadState.uploading => EcUploadStatus.uploading,
    EcUploadState.done => EcUploadStatus.done,
    EcUploadState.error => EcUploadStatus.error,
    EcUploadState.quotaWait => EcUploadStatus.quotaWait,
    EcUploadState.paused => EcUploadStatus.paused,
  },
  progressPercent: (task.progress * 100).round(),
  retryCount: task.retryCount,
  errorMessage: task.errorMessage,
);

String _hhmm(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.hour)}:${two(d.minute)}';
}

bool _sameLocalDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

GoRouter _buildRouter(
  EcRepository repo,
  EcAuth auth,
  ValueNotifier<EcAppLanguage> language,
  EcUploadQueue queue,
  ValueNotifier<EcShopSummary?> selectedShop,
  ValueNotifier<String> recordingType,
  PickAvatarPath pickAvatarPath, {
  ShareService? shareService,
  VideoPlayerService? videoPlayerService,
  Dio? downloadDio,
  VoiceAnnouncerService? voiceAnnouncer,
  ValueNotifier<bool>? isRecordTabActive,
  _EvidenceCountOverrides? evidenceCountOverrides,
}) {
  final share = shareService ?? _maybeGetIt<ShareService>();
  final videoPlayer = videoPlayerService ?? _maybeGetIt<VideoPlayerService>();
  final downloader = downloadDio ?? Dio();
  // Built once for the app's lifetime (see the `voiceAnnouncer` param) rather
  // than per record-screen visit — flutter_tts's engine has a real cold-start
  // cost, and recreating it on every navigation delayed the very first
  // announcement each time.
  final voice = voiceAnnouncer ?? _maybeGetIt<VoiceAnnouncerService>();
  final gallery = _maybeGetIt<GallerySaveService>();
  // screen_view cho GA4/Firebase. Không có nó thì chỉ biết app được mở, không
  // biết người dùng đi tới màn nào hay rơi ở bước nào. Null khi DI chưa dựng
  // (widget test) — lúc đó danh sách rỗng, router vẫn chạy.
  final analyticsObserver = _maybeGetIt<AnalyticsRouteObserver>();
  return GoRouter(
    observers: [?analyticsObserver],
    // Override the start route for screenshot/QA via --dart-define=EC_START=/home.
    initialLocation: const String.fromEnvironment(
      'EC_START',
      defaultValue: '/',
    ),
    routes: [
      GoRoute(
        path: '/',
        // Firebase Auth already persists the session on-device across app
        // restarts — the bug was this screen ignoring that and always
        // routing to /login. A still-signed-in user goes straight to shop
        // selection, same destination a fresh login lands on.
        builder: (c, s) => EcSplashScreen(
          onStart: () => c.go(auth.currentUser != null ? '/shops' : '/login'),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (c, s) => _directionalPage(
          s,
          _LoginRoute(auth: auth, repo: repo, language: language),
        ),
      ),
      GoRoute(
        path: '/register',
        builder: (c, s) =>
            _RegisterRoute(auth: auth, repo: repo, language: language),
      ),
      GoRoute(
        path: '/phone-setup',
        pageBuilder: (c, s) =>
            _directionalPage(s, _PhoneSetupRoute(auth: auth, repo: repo)),
      ),
      GoRoute(
        path: '/forgot',
        builder: (c, s) => _ForgotRoute(auth: auth, language: language),
      ),
      GoRoute(
        path: '/shops',
        // /shops is entered forward from login and backward from the app; its
        // slide direction comes from the navigation's `extra` hint.
        pageBuilder: (c, s) => _directionalPage(
          s,
          _ChooseShopRoute(
            repo: repo,
            autoEnter: s.extra != 'back',
            onSelect: (shop) {
              selectedShop.value = shop;
              _rememberShop(shop);
              c.go('/home');
            },
            onManage: () => c.push('/shop-mgmt'),
            onCreateShop: () => c.push('/create-shop'),
            onLogout: () {
              auth.signOut().then((_) async {
                await _forgetRememberedShop();
                if (c.mounted) c.go('/login', extra: 'back');
              });
            },
          ),
        ),
      ),
      GoRoute(
        path: '/shop-mgmt',
        builder: (c, s) => _ShopMgmtRoute(
          repo: repo,
          onBack: () => _back(c, '/shops'),
          onAddShop: () => c.push('/create-shop'),
          onShopTap: (shop) {
            final selected = _shopFromMgmt(shop);
            if (selected != null) c.push('/shop-detail', extra: selected);
          },
        ),
      ),
      GoRoute(
        path: '/create-shop',
        builder: (c, s) => _CreateShopRoute(
          repo: repo,
          onBack: () => _back(c, '/shop-mgmt'),
          onCreated: (shop) {
            selectedShop.value = shop;
            _rememberShop(shop);
            c.go('/home');
            _toast(c, c.l10n.toastShopCreated);
          },
        ),
      ),
      // --- 3-tab shell: an IndexedStack so switching tabs doesn't slide and each
      // tab keeps its own state. Detail pages stay top-level (below), so they push
      // on the root navigator and slide in over the tabs with the right direction.
      StatefulShellRoute.indexedStack(
        // go_router's back-gesture handling (popRoute) checks the ROOT
        // navigator before the active branch's own navigator, so a PopScope
        // set only inside the /record branch (see EcRecordRoute) never even
        // gets consulted when that branch has nothing left to pop into — the
        // root navigator reports "can't pop" and Android exits the app
        // instead. Blocking pop here, at the root-level shell page, covers
        // every tab: a left-edge back-swipe on any of the 3 tab roots is a
        // no-op rather than exiting the app — pushed routes on top (e.g.
        // /order) still pop normally since they sit above this PopScope.
        builder: (c, s, navigationShell) {
          // Assigned synchronously (not in a post-frame callback) so that
          // when the record branch is built for the first time this same
          // frame, its initState reads the correct up-to-date value instead
          // of a stale one from before the switch.
          isRecordTabActive?.value =
              navigationShell.currentIndex == _recordBranchIndex;
          return PopScope(canPop: false, child: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                // Data-driven: orders come from the repository (fake now, live
                // once the Worker URL is set), with pull-to-refresh + paging.
                builder: (c, s) {
                  final shop = _selected(selectedShop);
                  if (shop == null || shop.id.isEmpty) {
                    return _RouteLoadError(
                      title: c.l10n.accountNoShop,
                      detail: c.l10n.noShopSelectedOrdersDetail,
                      onRetry: () => c.go('/shops'),
                    );
                  }
                  return _OrdersRoute(
                    repo: repo,
                    queue: queue,
                    shopId: shop.id,
                    shopName: shop.name,
                    evidenceCountOverrides: evidenceCountOverrides,
                    onBack: () => c.go('/shops', extra: 'back'),
                    onNavRecord: () => c.go('/record'),
                    onNavAccount: () => c.go('/account'),
                    onQueueTap: () => c.push('/queue'),
                    onOrderTap: (order) => c.push('/order', extra: order),
                    onScan: () => c.push<String>('/scan'),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/record',
                builder: (c, s) => ListenableBuilder(
                  listenable: queue,
                  builder: (context, _) {
                    final shop = _selected(selectedShop);
                    if (shop == null || shop.id.isEmpty) {
                      return _RouteLoadError(
                        title: c.l10n.accountNoShop,
                        detail: c.l10n.noShopSelectedRecordDetail,
                        onRetry: () => c.go('/shops'),
                      );
                    }
                    return EcRecordRoute(
                      shopName: shop.name,
                      ensureCameraPermission: _ensureCameraPermission,
                      queueCount: _pendingUploads(queue),
                      initialType: recordingType.value,
                      initialResolution: shop.resolution,
                      maxRecording: shop.clipBudget.maxRecording,
                      isActive: isRecordTabActive,
                      onBack: () => c.go('/home'),
                      onQueueTap: () => c.push('/queue'),
                      onRequestCode: () => c.push<String>('/manual'),
                      onConfirmManualCode: (code) =>
                          _confirmManualTracking(c, repo, shop.id, code),
                      verifyReturnCode: (code) =>
                          _verifyReturnCode(c, repo, shop.id, shop.name, code),
                      voiceAnnouncer: voice,
                      onRequestType: () async {
                        final router = GoRouter.of(c);
                        final rootNavigator = Navigator.of(
                          c,
                          rootNavigator: true,
                        );
                        final selected = await _showTypeSheet(
                          c,
                          repo: repo,
                          shopId: shop.id,
                          selectedType: recordingType.value,
                        );
                        if (selected == _manageVideoTypesResult) {
                          await rootNavigator.push<void>(
                            MaterialPageRoute(
                              builder: (_) => _ShopDetailRoute(
                                repo: repo,
                                shop: shop,
                                onBack: rootNavigator.maybePop,
                                onMemberMore: (member) => router
                                    .push(
                                      '/member-actions',
                                      extra: _MemberActionExtra(
                                        shopId: shop.id,
                                        member: member,
                                      ),
                                    )
                                    .then((_) {}),
                                onInviteMember: () => router
                                    .push('/invite-member', extra: shop.id)
                                    .then((_) {}),
                                onTapResolution: () =>
                                    router.push('/resolution', extra: shop.id),
                                onEditType: (type) => router
                                    .push(
                                      '/create-type',
                                      extra: (shop.id, type),
                                    )
                                    .then((_) {}),
                                onDeleteType: (type) => router
                                    .push(
                                      '/confirm-delete',
                                      extra: (shop.id, type),
                                    )
                                    .then((_) {}),
                                onAddType: () => router
                                    .push(
                                      '/create-type',
                                      extra: (shop.id, null),
                                    )
                                    .then((_) {}),
                              ),
                            ),
                          );
                          return null;
                        }
                        if (selected != null && selected.isNotEmpty) {
                          recordingType.value = selected;
                        }
                        return selected;
                      },
                      onNavOrders: () => c.go('/home'),
                      onNavAccount: () => c.go('/account'),
                      onSettings: () => c.push('/type-sheet'),
                      onSaved: (path, code, type, durationSeconds) {
                        queue.enqueue(
                          tracking: code,
                          type: type,
                          filePath: path,
                          shopId: shop.id,
                          durationSeconds: durationSeconds,
                        );
                        _analytics()?.trackClipRecorded(recordingType: type);
                        _toast(c, c.l10n.toastVideoQueued);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/account',
                builder: (c, s) => _AccountRoute(
                  auth: auth,
                  repo: repo,
                  language: language,
                  selectedShop: selectedShop,
                  queue: queue,
                ),
              ),
            ],
          ),
        ],
      ),
      // --- order detail + evidence (Flow 2) ---
      GoRoute(
        path: '/order',
        builder: (c, s) {
          final shop = _selected(selectedShop);
          final order = s.extra is OrderSummaryDto
              ? s.extra! as OrderSummaryDto
              : null;
          if (shop == null || order == null) {
            return _RouteLoadError(
              title: c.l10n.noOrdersTitle,
              detail: c.l10n.noOrdersDetail,
              onRetry: () => c.go('/home'),
            );
          }
          return _OrderRoute(
            repo: repo,
            queue: queue,
            share: share,
            shop: shop,
            order: order,
            evidenceCountOverrides: evidenceCountOverrides,
            onBack: () => _back(c, '/home'),
            onOpenVideo: (extra) => c.push(
              extra.video.type == EcEvidenceType.image ? '/photo' : '/video',
              extra: extra,
            ),
          );
        },
      ),
      GoRoute(
        path: '/video',
        pageBuilder: (c, s) {
          final extra = s.extra is _VideoRouteExtra
              ? s.extra! as _VideoRouteExtra
              : null;
          return _modalPage(
            s,
            // showCupertinoDialog needs a context that is a descendant of a
            // Navigator. The `c` this pageBuilder receives sits above the
            // page this builds, so it has no Navigator ancestor yet — a
            // Builder gives onDelete a context from inside the built page.
            Builder(
              builder: (pageContext) => EcVideoDetailScreen(
                video:
                    extra?.video ??
                    EcVideoDetail(
                      title: c.l10n.noVideoDataTitle,
                      duration: '—',
                      recordedAt: '—',
                      recordedBy: '—',
                      device: '—',
                      uploadStatus: '—',
                    ),
                canDelete: extra?.canDelete ?? false,
                onClose: () => c.pop(),
                onPlay: () {
                  final url = extra?.video.mediaUrl;
                  if (url == null || videoPlayer == null) {
                    _toast(pageContext, c.l10n.toastVideoNoPlayLink);
                    return;
                  }
                  c.push(
                    '/video-player',
                    extra: _VideoPlayerRouteExtra(
                      title: extra!.video.title,
                      recordedAt: extra.video.recordedAt,
                      url: url,
                      videoPlayerService: videoPlayer,
                    ),
                  );
                },
                onDownload: () {
                  final video = extra?.video;
                  if (video?.mediaUrl == null) {
                    _toast(pageContext, c.l10n.toastVideoNoDownloadLink);
                    return;
                  }
                  _downloadAndShareVideo(
                    pageContext,
                    downloader,
                    share,
                    gallery,
                    video!,
                  );
                },
                onDelete: () async {
                  final evidenceId = extra?.evidenceId;
                  if (extra == null || evidenceId == null) {
                    _toast(pageContext, c.l10n.toastVideoDeleteUnavailable);
                    return;
                  }
                  final confirmed = await showCupertinoDialog<bool>(
                    context: pageContext,
                    builder: (dialogContext) => CupertinoAlertDialog(
                      title: Text(c.l10n.deleteVideoAction),
                      content: Text(c.l10n.deleteVideoNote),
                      actions: [
                        CupertinoDialogAction(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          child: Text(c.l10n.commonCancel),
                        ),
                        CupertinoDialogAction(
                          isDestructiveAction: true,
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          child: Text(c.l10n.deleteVideoAction),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true || !pageContext.mounted) return;
                  // Step 2 of 2: a distinct final warning, spelling out that
                  // this specific evidence item is gone for good — the first
                  // dialog only confirmed *intent* to delete.
                  final confirmedFinal = await showCupertinoDialog<bool>(
                    context: pageContext,
                    builder: (dialogContext) => CupertinoAlertDialog(
                      title: Text(c.l10n.deleteVideoConfirmTitle),
                      content: Text(c.l10n.deleteVideoConfirmBody),
                      actions: [
                        CupertinoDialogAction(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          child: Text(c.l10n.commonCancel),
                        ),
                        CupertinoDialogAction(
                          isDestructiveAction: true,
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          child: Text(c.l10n.deleteVideoConfirmAction),
                        ),
                      ],
                    ),
                  );
                  if (confirmedFinal != true || !pageContext.mounted) return;
                  unawaited(
                    repo
                        .deleteEvidence(extra.shopId, extra.orderId, evidenceId)
                        .then((_) {
                          // Toast first: it lands in the root Overlay, which
                          // outlives this page, so it must be requested while
                          // pageContext is still mounted — after c.pop() this
                          // page (and pageContext) is already gone.
                          if (pageContext.mounted) {
                            _toast(pageContext, c.l10n.toastVideoDeleted);
                          }
                          if (c.mounted) {
                            c.pop();
                          }
                        })
                        .catchError((Object error) {
                          if (pageContext.mounted) {
                            _toast(pageContext, _dataErrorText(c.l10n, error));
                          }
                        }),
                  );
                },
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: '/photo',
        pageBuilder: (c, s) {
          final extra = s.extra is _VideoRouteExtra
              ? s.extra! as _VideoRouteExtra
              : null;
          return _modalPage(
            s,
            // See the /video route above: onDownload's toasts need a context
            // inside the built page, not the pageBuilder's own `c`.
            Builder(
              builder: (pageContext) => EcPhotoDetailScreen(
                photo:
                    extra?.video ??
                    EcVideoDetail(
                      title: c.l10n.noVideoDataTitle,
                      duration: '—',
                      recordedAt: '—',
                      recordedBy: '—',
                      device: '—',
                      uploadStatus: '—',
                    ),
                onClose: () => c.pop(),
                onDownload: () {
                  final photo = extra?.video;
                  if (photo == null) return;
                  _downloadAndSavePhoto(
                    pageContext,
                    downloader,
                    share,
                    gallery,
                    photo,
                  );
                },
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: '/video-player',
        builder: (c, s) {
          final extra = s.extra is _VideoPlayerRouteExtra
              ? s.extra! as _VideoPlayerRouteExtra
              : null;
          if (extra == null) {
            return _RouteLoadError(
              title: c.l10n.cannotOpenVideoTitle,
              detail: c.l10n.cannotOpenVideoDetail,
              onRetry: () => c.pop(),
            );
          }
          return _VideoPlayerRoute(
            title: extra.title,
            recordedAt: extra.recordedAt,
            url: extra.url,
            service: extra.videoPlayerService,
            onBack: () => c.pop(),
          );
        },
      ),
      // --- recording flow (Flow 3) ---
      GoRoute(
        path: '/queue',
        builder: (c, s) => _QueueRoute(
          queue: queue,
          onBack: () => _back(c, '/home'),
          onUpgrade: () => c.push('/quota'),
        ),
      ),
      GoRoute(
        path: '/type-sheet',
        pageBuilder: (c, s) {
          final shop = _selected(selectedShop);
          final selectedType = s.extra is String
              ? s.extra! as String
              : recordingType.value;
          return _modalPage(
            s,
            _TypeSheetRoute(
              repo: repo,
              shopId: shop?.id ?? '',
              selectedType: selectedType,
              onManageTypes: () {
                c.pop();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (c.mounted) c.push('/shop-detail');
                });
              },
              // Return the chosen type to the record route, which applies it to
              // the current/next recording.
              onSelected: (t) => c.pop(t),
            ),
            key: s.pageKey,
          );
        },
      ),
      GoRoute(
        path: '/manual',
        pageBuilder: (c, s) => _modalPage(
          s,
          EcManualEntryScreen(
            onCancel: () => c.pop(),
            // Return the entered code to the record route, which starts recording
            // that order — connects the "chờ bill" state to the "đang quay" state.
            onManualSubmit: (code) => c.pop(code),
          ),
        ),
      ),
      GoRoute(
        path: '/scan',
        // Barcode scan from the order-search bar (FR-04); returns the scanned code.
        builder: (c, s) => EcBarcodeScanRoute(
          onCancel: () => c.pop(),
          onDetected: (code) => c.pop(code),
        ),
      ),
      // --- remaining shop-config screens (Flow 1) ---
      GoRoute(
        path: '/no-shop',
        builder: (c, s) => EcNoShopScreen(
          onCreate: () => c.push('/create-shop'),
          onInviteTap: () => _toast(c, c.l10n.toastInvitePending),
          onLogout: () {
            auth.signOut().then((_) async {
              await _forgetRememberedShop();
              if (c.mounted) c.go('/login', extra: 'back');
            });
          },
        ),
      ),
      GoRoute(
        path: '/shop-detail',
        builder: (c, s) {
          final shop = s.extra is EcShopSummary
              ? s.extra! as EcShopSummary
              : _selected(selectedShop);
          if (shop == null || shop.id.isEmpty) {
            return _RouteLoadError(
              title: c.l10n.accountNoShop,
              detail: c.l10n.noShopSelectedManageDetail,
              onRetry: () => c.go('/shop-mgmt'),
            );
          }
          return _ShopDetailRoute(
            repo: repo,
            shop: shop,
            onBack: () => _back(c, '/shop-mgmt'),
            onMemberMore: (member) => c
                .push(
                  '/member-actions',
                  extra: _MemberActionExtra(shopId: shop.id, member: member),
                )
                .then((_) {}),
            onInviteMember: () =>
                c.push('/invite-member', extra: shop.id).then((_) {}),
            onTapResolution: () =>
                c.push<void>('/resolution', extra: shop.id).then((_) {}),
            onTapClipDuration: () =>
                c.push<void>('/clip-duration', extra: shop.id).then((_) {}),
            onEditType: (type) =>
                c.push('/create-type', extra: (shop.id, type)).then((_) {}),
            onDeleteType: (type) =>
                c.push('/confirm-delete', extra: (shop.id, type)).then((_) {}),
            onAddType: () =>
                c.push('/create-type', extra: (shop.id, null)).then((_) {}),
          );
        },
      ),
      GoRoute(
        path: '/create-type',
        pageBuilder: (c, s) => _modalPage(
          s,
          _CreateTypeRoute(
            repo: repo,
            shopId: s.extra is (String, EcVideoType?)
                ? (s.extra! as (String, EcVideoType?)).$1
                : '',
            type: s.extra is (String, EcVideoType?)
                ? (s.extra! as (String, EcVideoType?)).$2
                : null,
            onDone: () {
              c.pop();
              _toast(c, c.l10n.toastVideoTypeSaved);
            },
          ),
        ),
      ),
      GoRoute(
        path: '/confirm-delete',
        pageBuilder: (c, s) => _modalPage(
          s,
          EcConfirmDeleteScreen(
            onCancel: () => c.pop(),
            onConfirm: () {
              final extra = s.extra;
              if (extra is (String, EcVideoType) && extra.$2.id != null) {
                repo
                    .deleteVideoType(extra.$1, extra.$2.id!)
                    .then((_) {
                      if (!c.mounted) return;
                      c.pop();
                      _toast(c, c.l10n.toastVideoTypeDeleted);
                    })
                    .catchError((Object error) {
                      if (c.mounted) _toast(c, _dataErrorText(c.l10n, error));
                    });
                return;
              }
              c.pop();
              _toast(c, c.l10n.toastNoVideoTypeToDelete);
            },
          ),
        ),
      ),
      GoRoute(
        path: '/invite-member',
        pageBuilder: (c, s) => _modalPage(
          s,
          _InviteMemberRoute(
            repo: repo,
            shopId: s.extra is String ? s.extra! as String : '',
          ),
        ),
      ),
      GoRoute(
        path: '/member-actions',
        pageBuilder: (c, s) => _modalPage(
          s,
          EcMemberActionsScreen(
            member: s.extra is _MemberActionExtra
                ? (s.extra! as _MemberActionExtra).member
                : EcShopMember(
                    name: c.l10n.memberFallbackName,
                    role: c.l10n.roleUnknown,
                  ),
            onSetManager: () async {
              final extra = s.extra;
              if (extra is _MemberActionExtra &&
                  extra.member.accountUid != null) {
                try {
                  await repo.updateMemberRole(
                    extra.shopId,
                    accountUid: extra.member.accountUid!,
                    role: 'manager',
                  );
                  if (!c.mounted) return;
                  c.pop();
                  _toast(c, c.l10n.toastRoleChangedManager);
                } on Object catch (error) {
                  if (c.mounted) _toast(c, _dataErrorText(c.l10n, error));
                }
                return;
              }
              c.pop();
              _toast(c, c.l10n.toastNoMemberToUpdate);
            },
            onSetStaff: () async {
              final extra = s.extra;
              if (extra is _MemberActionExtra &&
                  extra.member.accountUid != null) {
                try {
                  await repo.updateMemberRole(
                    extra.shopId,
                    accountUid: extra.member.accountUid!,
                    role: 'staff',
                  );
                  if (!c.mounted) return;
                  c.pop();
                  _toast(c, c.l10n.toastRoleChangedStaff);
                } on Object catch (error) {
                  if (c.mounted) _toast(c, _dataErrorText(c.l10n, error));
                }
                return;
              }
              c.pop();
              _toast(c, c.l10n.toastNoMemberToUpdate);
            },
            onRemove: () async {
              final extra = s.extra;
              if (extra is _MemberActionExtra &&
                  extra.member.accountUid != null) {
                try {
                  await repo.removeMember(
                    extra.shopId,
                    extra.member.accountUid!,
                  );
                  if (!c.mounted) return;
                  c.pop();
                  _toast(c, c.l10n.toastMemberRemoved);
                } on Object catch (error) {
                  if (c.mounted) _toast(c, _dataErrorText(c.l10n, error));
                }
                return;
              }
              c.pop();
              _toast(c, c.l10n.toastNoMemberToUpdate);
            },
          ),
        ),
      ),
      GoRoute(
        path: '/resolution',
        pageBuilder: (c, s) => _modalPage(
          s,
          EcResolutionSheetScreen(
            selected: _selected(selectedShop)?.resolution ?? '720p',
            onSelect: (r) {
              final shopId = s.extra is String
                  ? s.extra! as String
                  : _selected(selectedShop)?.id ?? '';
              repo
                  .updateShop(shopId, resolution: r)
                  .then((shop) {
                    if (!c.mounted) return;
                    final current = _selected(selectedShop);
                    if (current?.id == shop.id) {
                      selectedShop.value = _shopFromDto(shop);
                    }
                    c.pop();
                    _toast(c, c.l10n.resolutionChanged(r));
                  })
                  .catchError((Object error) {
                    if (c.mounted) _toast(c, _dataErrorText(c.l10n, error));
                  });
            },
          ),
        ),
      ),
      GoRoute(
        path: '/login-methods',
        builder: (c, s) => _LoginMethodsRoute(auth: auth),
      ),
      // --- account sub-screens (pushed, back via pop) ---
      GoRoute(
        path: '/clip-duration',
        pageBuilder: (c, s) {
          final shop = _selected(selectedShop);
          final shopId = s.extra is String
              ? s.extra! as String
              : shop?.id ?? '';
          return _modalPage(
            s,
            EcClipDurationSheetScreen(
              budget: shop?.clipBudget ?? ClipBudget.fallback,
              platformLabel: _platformDisplayName(shop?.platform ?? 'other'),
              onSelect: (seconds) {
                repo
                    .updateShop(shopId, maxClipSeconds: seconds)
                    .then((updated) {
                      if (!c.mounted) return;
                      final current = _selected(selectedShop);
                      if (current?.id == updated.id) {
                        selectedShop.value = _shopFromDto(updated);
                      }
                      c.pop();
                      _toast(
                        c,
                        c.l10n.clipDurationChanged(
                          '${(updated.clipSeconds / 60).round()}',
                        ),
                      );
                    })
                    .catchError((Object error) {
                      if (c.mounted) _toast(c, _dataErrorText(c.l10n, error));
                    });
              },
            ),
          );
        },
      ),
      GoRoute(
        path: '/quota',
        builder: (c, s) => _QuotaRoute(
          repo: repo,
          queue: queue,
          shopId: _selected(selectedShop)?.id,
        ),
      ),
      GoRoute(
        path: '/language',
        builder: (c, s) => ValueListenableBuilder<EcAppLanguage>(
          valueListenable: language,
          builder: (c, selected, _) => EcLanguageScreen(
            selected: selected,
            onBack: () => _back(c, '/account'),
            onSelect: (choice) {
              language.value = choice;
              _toast(
                c,
                choice == EcAppLanguage.vi
                    ? 'Đã đổi sang Tiếng Việt'
                    : 'Switched to English',
              );
            },
          ),
        ),
      ),
      GoRoute(
        path: '/change-password',
        pageBuilder: (c, s) => _modalPage(s, _ChangePasswordRoute(auth: auth)),
      ),
      GoRoute(
        path: '/stop-code',
        builder: (c, s) => EcStopCodeScreen(onBack: () => c.pop()),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (c, s) => _EditProfileRoute(
          auth: auth,
          repo: repo,
          pickAvatarPath: pickAvatarPath,
        ),
      ),
      GoRoute(
        path: '/delete-account',
        pageBuilder: (c, s) => _modalPage(
          s,
          _DeleteAccountRoute(auth: auth, repo: repo),
        ),
      ),
    ],
  );
}

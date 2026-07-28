import 'package:app_platform/app_platform.dart'
    show
        AppVideoPlayerController,
        ImagePicker,
        ImageSource,
        ShareService,
        VideoPlayer,
        VideoPlayerService,
        VideoPlayerValue;
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
        EcTimelineDay,
        EcTimelineVideo,
        EcVideoDetail,
        EcVideoDetailScreen;
import 'package:feature_shift/feature_shift.dart';
import 'package:flutter/cupertino.dart'
    show
        CupertinoActivityIndicator,
        CupertinoApp,
        CupertinoButton,
        CupertinoPageScaffold,
        CupertinoTextThemeData,
        CupertinoThemeData;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';
import 'package:network/network.dart' show Dio, DioException, DioExceptionType;
import 'package:path_provider/path_provider.dart';
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
  // ponytail: session-only; the unused LocaleBloc in lib/core/locale persists a
  // choice to SharedPreferences — wire it here if the override must survive restart.
  final ValueNotifier<EcAppLanguage> _language = ValueNotifier(
    _systemLanguage(),
  );

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
  );
  static const _apiUrl = String.fromEnvironment(
    'EC_API_URL',
    defaultValue: String.fromEnvironment('API_BASE_URL'),
  );

  // The shop clocked into at the shop layer (FR-05). Its id drives which orders
  // load, its resolution seeds the camera, and its role gates evidence deletion
  // and shop management. Null until a shop is picked.
  final ValueNotifier<EcShopSummary?> _selectedShop = ValueNotifier(null);
  final ValueNotifier<String> _recordingType = ValueNotifier('Đóng hàng');

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
  );

  @override
  void initState() {
    super.initState();
    _queue.load();
  }

  @override
  void dispose() {
    _router.dispose();
    _language.dispose();
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
              fontSize: 15,
            ),
          ),
        ),
        routerConfig: _router,
      ),
    );
  }
}

/// Login route — owns the email/password controllers and drives the auth seam
/// (FR-15). Email/Google/Apple all sign in through [EcAuth] then go to the shop
/// layer; today [FakeEcAuth] succeeds instantly, `FirebaseEcAuth` does it for real.
class _LoginRoute extends StatefulWidget {
  const _LoginRoute({required this.auth, required this.repo});

  final EcAuth auth;
  final EcRepository repo;

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
    onLanguage: () => _toast(context, context.l10n.toastChangeLanguage),
  );
}

/// Registration — owns the field controllers so the screen's inline validators
/// (notably the confirm-password match) have live text to read. Valid submits
/// create the auth user, persist profile fields, then enter the shop layer.
class _RegisterRoute extends StatefulWidget {
  const _RegisterRoute({required this.auth, required this.repo});

  final EcAuth auth;
  final EcRepository repo;

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
    onLanguage: () => _toast(context, context.l10n.toastChangeLanguage),
    onViewPolicy: () => _toast(context, context.l10n.toastTermsPolicy),
  );
}

class _ForgotRoute extends StatefulWidget {
  const _ForgotRoute({required this.auth});

  final EcAuth auth;

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
    onLanguage: () => _toast(context, context.l10n.toastChangeLanguage),
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
  late final Future<QuotaDto> _quota = widget.repo.quota();

  Future<void> _logout() async {
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
            queueCount: _pendingUploads(widget.queue),
            planLabel: snap.hasData ? ecHumanBytes(snap.data!.capBytes) : '—',
            languageLabel: language == EcAppLanguage.vi
                ? 'Tiếng Việt'
                : 'English',
            loginMethodsLabel: context.l10n.accountLinkedMethods(linkedCount),
            passwordActionLabel: user?.hasPassword == false
                ? context.l10n.accountCreatePassword
                : context.l10n.accountChangePassword,
            onBack: () => context.go('/shops', extra: 'back'),
            onNavOrders: () => context.go('/home'),
            onNavCapture: () => context.go('/record'),
            onProfileTap: () => context.push('/edit-profile'),
            onQuotaTap: () => context.push('/quota'),
            onLanguageTap: () => context.push('/language'),
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
    try {
      await widget.auth.updateProfile(name: name, phone: _phone.text.trim());
      await widget.repo.updateProfile(
        name: name,
        phone: _phone.text.trim(),
        avatarUrl: _avatarPath,
      );
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

/// Quota — reads the real per-period figures from the repository.
class _QuotaRoute extends StatefulWidget {
  const _QuotaRoute({required this.repo});

  final EcRepository repo;

  @override
  State<_QuotaRoute> createState() => _QuotaRouteState();
}

class _QuotaRouteState extends State<_QuotaRoute> {
  late final Future<QuotaDto> _quota = widget.repo.quota();

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
        return EcQuotaScreen(
          planLabel: ecHumanBytes(quota.capBytes),
          usedBytes: quota.usedBytes,
          remainingBytes: quota.remainingBytes,
          capBytes: quota.capBytes,
          retentionTotalDays: quota.retentionDays,
          onBack: () => _back(context, '/account'),
          onUpgrade: () => _toast(context, context.l10n.toastUpgradeComingSoon),
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

T? _maybeGetIt<T extends Object>() =>
    getIt.isRegistered<T>() ? getIt<T>() : null;

Future<void> _copyText(BuildContext context, String text, String label) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) _toast(context, context.l10n.copiedLabel(label));
}

Future<void> _shareText(
  BuildContext context,
  ShareService? share,
  String text,
  String subject,
) async {
  try {
    if (share == null) {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) _toast(context, context.l10n.toastCopiedShareLink);
      return;
    }
    await share.share(text: text, subject: subject);
  } on Object {
    if (context.mounted) _toast(context, context.l10n.toastShareFailed);
  }
}

Future<void> _downloadAndShareVideo(
  BuildContext context,
  Dio dio,
  ShareService? share,
  EcVideoDetail video,
) async {
  final url = video.mediaUrl;
  if (url == null) return;
  try {
    _toast(context, context.l10n.toastDownloadingVideo);
    final dir = await getApplicationDocumentsDirectory();
    final filename = _safeFilename('${video.title}.mp4');
    final path = '${dir.path}/$filename';
    await dio.download(url, path);
    if (!context.mounted) return;
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

CustomTransitionPage<void> _modalPage(Widget child, {LocalKey? key}) =>
    CustomTransitionPage<void>(
      key: key,
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.4),
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

/// Count of clips still needing the network — the "n chờ/tải" the record and
/// orders headers show (uploaded clips don't count).
int _pendingUploads(EcUploadQueue queue) =>
    queue.tasks.where((t) => t.state != EcUploadState.done).length;

/// The shop clocked into at Flow 1. Direct deep links must handle null
/// explicitly instead of silently using a fake shop.
EcShopSummary? _selected(ValueNotifier<EcShopSummary?> selectedShop) =>
    selectedShop.value;

KeyValueStore? _appMemory() =>
    getIt.isRegistered<KeyValueStore>() ? getIt<KeyValueStore>() : null;

/// Keychain-backed store for the remembered login email + password. Null in
/// tests/pumps that skip DI, so every credential read/write there is a no-op.
CredentialStore? _credentials() =>
    getIt.isRegistered<FlutterSecureStorage>()
    ? CredentialStore(getIt<FlutterSecureStorage>())
    : null;

Future<void> _rememberShop(EcShopSummary shop) async {
  if (shop.id.isEmpty) return;
  await _appMemory()?.setString(_lastShopIdKey, shop.id);
}

Future<void> _forgetRememberedShop() async {
  await _appMemory()?.remove(_lastShopIdKey);
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

EcShopSummary _shopFromDto(ShopDto shop) => EcShopSummary(
  id: shop.id,
  name: shop.name,
  platform: shop.platform,
  meta: '${_platformDisplayName(shop.platform)} · ${shop.role}',
  role: shop.role,
  resolution: shop.resolution,
);

EcShopMgmtEntry _shopMgmtFromDto(AppLocalizations l10n, ShopDto shop) =>
    EcShopMgmtEntry(
  id: shop.id,
  name: shop.name,
  platform: shop.platform,
  resolution: shop.resolution,
  role: shop.role,
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

String _dossierUrl(String token) {
  const apiUrl = String.fromEnvironment(
    'EC_API_URL',
    defaultValue: String.fromEnvironment('API_BASE_URL'),
  );
  final base = apiUrl.endsWith('/')
      ? apiUrl.substring(0, apiUrl.length - 1)
      : apiUrl;
  return '$base/d/$token';
}

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
  String shopId,
) async {
  final path = await _pickImagePath();
  if (path == null || !context.mounted) return;
  await queue.enqueue(
    tracking: tracking,
    type: 'Ảnh đính kèm',
    filePath: path,
    shopId: shopId,
  );
  if (context.mounted) {
    _toast(context, context.l10n.toastPhotoQueued);
  }
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

  void _retry() => setState(() => _shops = _loadShops());

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
          );
        }
        _autoSelectIfNeeded(shops);
        return EcChooseShopScreen(
          shops: shops,
          showManage: shops.any((shop) => shop.role != 'staff'),
          onSelect: widget.onSelect,
          onManage: widget.onManage,
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

  void _retry() => setState(() => _shops = _load());

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
    this.onEditType,
    this.onDeleteType,
    this.onAddType,
  });

  final EcRepository repo;
  final EcShopSummary shop;
  final VoidCallback? onBack;
  final ValueChanged<EcShopMember>? onMemberMore;
  final VoidCallback? onInviteMember;
  final VoidCallback? onTapResolution;
  final ValueChanged<EcVideoType>? onEditType;
  final ValueChanged<EcVideoType>? onDeleteType;
  final VoidCallback? onAddType;

  @override
  State<_ShopDetailRoute> createState() => _ShopDetailRouteState();
}

class _ShopDetailRouteState extends State<_ShopDetailRoute> {
  late Future<_ShopDetailData> _detail = _load();

  Future<_ShopDetailData> _load() async {
    final l10n = context.l10n;
    return _ShopDetailData(
      members: (await widget.repo.members(
        widget.shop.id,
      )).map((m) => _memberFromDto(l10n, m)).toList(),
      videoTypes: (await widget.repo.videoTypes(
        widget.shop.id,
      )).map(_videoTypeFromDto).toList(),
    );
  }

  void _retry() => setState(() => _detail = _load());

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
          shopName: widget.shop.name,
          platformLabel: _platformDisplayName(widget.shop.platform),
          resolution: widget.shop.resolution,
          members: detail.members,
          videoTypes: detail.videoTypes,
          onBack: widget.onBack,
          onMemberMore: widget.onMemberMore,
          onInviteMember: widget.onInviteMember,
          onTapResolution: widget.onTapResolution,
          onEditType: widget.onEditType,
          onDeleteType: widget.onDeleteType,
          onAddType: widget.onAddType,
        );
      },
    );
  }
}

class _ShopDetailData {
  const _ShopDetailData({required this.members, required this.videoTypes});

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

EcVideoType _videoTypeFromDto(VideoTypeDto type) => EcVideoType(
  id: type.id,
  name: type.name,
  locked: type.isDefault,
  icon: switch (type.name) {
    'Đóng hàng' => Icons.inventory_2_outlined,
    'Đơn vị vận chuyển' => Icons.local_shipping_outlined,
    'Trả hàng' => Icons.assignment_return_outlined,
    _ => Icons.videocam_outlined,
  },
);

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
    try {
      final typeId = widget.type?.id;
      if (typeId == null) {
        await widget.repo.addVideoType(widget.shopId, name);
      } else {
        await widget.repo.renameVideoType(widget.shopId, typeId, name);
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
        result.status == 'pending' ? context.l10n.toastInviteSent : context.l10n.toastMemberAdded,
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
  final VoidCallback? onBack;
  final VoidCallback? onNavRecord;
  final VoidCallback? onNavAccount;
  final VoidCallback? onQueueTap;
  final ValueChanged<OrderSummaryDto>? onOrderTap;
  final Future<String?> Function()? onScan;

  @override
  State<_OrdersRoute> createState() => _OrdersRouteState();
}

class _OrdersRouteState extends State<_OrdersRoute> {
  static const _pageSize = 20;

  List<OrderSummaryDto> _orders = const [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  String _query = '';
  var _searchGeneration = 0;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _loadFirst();
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
      final page = await widget.repo.orders(widget.shopId);
      if (!mounted || queryGeneration != _searchGeneration) return;
      setState(() {
        _orders = page;
        _hasMore = page.length >= _pageSize;
        _loading = false;
        _loadError = null;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _orders = const [];
        _hasMore = false;
        _loading = false;
        _loadError = error;
      });
    }
  }

  /// Pull-to-refresh — reload the first page (no full-screen spinner).
  Future<void> _refresh() async {
    final trimmed = _query.trim();
    try {
      final page = trimmed.isEmpty
          ? await widget.repo.orders(widget.shopId)
          : await widget.repo.searchOrders(widget.shopId, trimmed);
      if (!mounted) return;
      setState(() {
        _orders = page;
        _hasMore = trimmed.isEmpty && page.length >= _pageSize;
        _loadError = null;
      });
    } on Object catch (error) {
      if (mounted) _toast(context, _dataErrorText(context.l10n, error));
    }
  }

  Future<void> _search(String query) async {
    final trimmed = query.trim();
    final queryGeneration = ++_searchGeneration;
    _query = trimmed;
    try {
      final page = trimmed.isEmpty
          ? await widget.repo.orders(widget.shopId)
          : await widget.repo.searchOrders(widget.shopId, trimmed);
      if (!mounted || queryGeneration != _searchGeneration) return;
      setState(() {
        _orders = page;
        _hasMore = trimmed.isEmpty && page.length >= _pageSize;
        _loadError = null;
      });
    } on Object catch (error) {
      if (mounted && queryGeneration == _searchGeneration) {
        _toast(context, _dataErrorText(context.l10n, error));
      }
    }
  }

  Future<void> _loadMore() async {
    if (_query.isNotEmpty || _loadingMore || !_hasMore || _orders.isEmpty) {
      return;
    }
    setState(() => _loadingMore = true);
    try {
      final page = await widget.repo.orders(
        widget.shopId,
        before: _orders.last.createdAt,
      );
      if (!mounted) return;
      setState(() {
        _orders = [..._orders, ...page];
        _hasMore = page.length >= _pageSize;
        _loadingMore = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
      _toast(context, _dataErrorText(context.l10n, error));
    }
  }

  EcOrderRow _toRow(AppLocalizations l10n, OrderSummaryDto o) {
    final capturedAt = o.lastCapturedAt;
    return EcOrderRow(
      code: o.tracking,
      time: capturedAt == null
          ? '—'
          : _hhmm(DateTime.fromMillisecondsSinceEpoch(capturedAt)),
      type: o.latestType ?? l10n.orderNoEvidence,
      videoCount: o.evidenceCount,
      errorCount: o.errorCount,
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
    return [
      EcHomeStat(value: '$todayOrders', label: context.l10n.statOrdersToday),
      EcHomeStat(value: '$evidenceCount', label: context.l10n.statVideosRecorded),
      EcHomeStat(value: '${_pendingUploads(queue)}', label: context.l10n.statPendingUpload),
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
    final rows = _orders.map((o) => _toRow(context.l10n, o)).toList();
    return ListenableBuilder(
      listenable: widget.queue,
      builder: (context, _) => EcHomeOrdersScreen(
        shopName: widget.shopName,
        orders: rows,
        queueCount: _pendingUploads(widget.queue),
        stats: _stats(widget.queue),
        onBack: widget.onBack,
        onNavRecord: widget.onNavRecord,
        onNavAccount: widget.onNavAccount,
        onQueueTap: widget.onQueueTap,
        onOrderTap: widget.onOrderTap == null
            ? null
            : (row) {
                final i = rows.indexWhere((r) => r.code == row.code);
                if (i >= 0) widget.onOrderTap!(_orders[i]);
              },
        onNavOrders: () {},
        onScan: widget.onScan,
        onSearchChanged: _search,
        onRefresh: _refresh,
        onLoadMore: _loadMore,
        isLoadingMore: _loadingMore,
        hasMore: _hasMore,
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
    this.shareService,
    this.onBack,
    this.onOpenVideo,
  });

  final EcRepository repo;
  final EcUploadQueue queue;
  final EcShopSummary shop;
  final OrderSummaryDto order;
  final ShareService? shareService;
  final VoidCallback? onBack;
  final ValueChanged<_VideoRouteExtra>? onOpenVideo;

  @override
  State<_OrderRoute> createState() => _OrderRouteState();
}

class _OrderRouteState extends State<_OrderRoute> {
  late Future<_OrderDetailData> _detail = _load();

  Future<_OrderDetailData> _load() async {
    final detail = await widget.repo.order(widget.shop.id, widget.order.id);
    final types = await widget.repo.videoTypes(widget.shop.id);
    DossierDto? dossier;
    if (widget.shop.role != 'staff') {
      try {
        dossier = await widget.repo.getDossier(
          widget.shop.id,
          widget.order.id,
        );
      } on Object {
        dossier = null;
      }
    }
    return _OrderDetailData(
      detail: detail,
      videoTypes: types,
      dossier: dossier,
    );
  }

  void _retry() => setState(() => _detail = _load());

  void _setDossier(_OrderDetailData data, DossierDto? dossier) {
    setState(() {
      _detail = Future.value(
        _OrderDetailData(
          detail: data.detail,
          videoTypes: data.videoTypes,
          dossier: dossier,
        ),
      );
    });
  }

  Future<void> _createDossier(_OrderDetailData data) async {
    try {
      final dossier = await widget.repo.shareDossier(
        widget.shop.id,
        widget.order.id,
      );
      if (!mounted) return;
      _setDossier(data, dossier);
      _toast(context, context.l10n.toastDossierLinkCreated);
    } on Object catch (error) {
      if (mounted) _toast(context, _dataErrorText(context.l10n, error));
    }
  }

  Future<void> _revokeDossier(_OrderDetailData data) async {
    try {
      await widget.repo.revokeDossier(widget.shop.id, widget.order.id);
      if (!mounted) return;
      _setDossier(data, null);
      _toast(context, context.l10n.toastDossierLinkRevoked);
    } on Object catch (error) {
      if (mounted) _toast(context, _dataErrorText(context.l10n, error));
    }
  }

  int get _pendingCount => widget.queue.tasks
      .where(
        (t) =>
            t.shopId == widget.shop.id &&
            t.tracking == widget.order.tracking &&
            t.state != EcUploadState.done,
      )
      .length;

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
        final days = _timelineDays(context.l10n, data.detail.evidence, data.videoTypes);
        final dossier = data.dossier;
        final dossierUrl = dossier == null || dossier.revoked
            ? null
            : _dossierUrl(dossier.shareToken);
        return ListenableBuilder(
          listenable: widget.queue,
          builder: (context, _) => EcOrderTimelineScreen(
            orderCode: data.detail.order.tracking,
            days: days,
            pendingUploadCount: _pendingCount,
            dossierUrl: dossierUrl,
            onBack: widget.onBack,
            onVideoTap: (video) => widget.onOpenVideo?.call(
              _VideoRouteExtra(
                shopId: widget.shop.id,
                orderId: widget.order.id,
                evidenceId: video.id,
                canDelete: widget.shop.role != 'staff',
                video: _videoDetail(context.l10n, video),
              ),
            ),
            onVideoMenu: (video) => widget.onOpenVideo?.call(
              _VideoRouteExtra(
                shopId: widget.shop.id,
                orderId: widget.order.id,
                evidenceId: video.id,
                canDelete: widget.shop.role != 'staff',
                video: _videoDetail(context.l10n, video),
              ),
            ),
            onCopyCode: () =>
                _copyText(context, data.detail.order.tracking, context.l10n.labelTrackingCode),
            onCopyLink: dossierUrl == null
                ? null
                : () => _copyText(context, dossierUrl, context.l10n.labelDossierLink),
            onShareLink: dossierUrl == null
                ? null
                : () => _shareText(
                    context,
                    widget.shareService,
                    dossierUrl,
                    context.l10n.dossierShareText(data.detail.order.tracking),
                  ),
            onCreateDossier: widget.shop.role == 'staff' || dossierUrl != null
                ? null
                : () => _createDossier(data),
            onRevokeDossier: widget.shop.role == 'staff' || dossierUrl == null
                ? null
                : () => _revokeDossier(data),
            onRetryUpload: _retry,
            onAttachPhoto: () => _attachPhoto(
              context,
              widget.queue,
              data.detail.order.tracking,
              widget.shop.id,
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
    required this.dossier,
  });

  final OrderDetailDto detail;
  final List<VideoTypeDto> videoTypes;
  final DossierDto? dossier;
}

class _VideoPlayerRoute extends StatefulWidget {
  const _VideoPlayerRoute({
    required this.title,
    required this.url,
    required this.service,
    this.onBack,
  });

  final String title;
  final String url;
  final VideoPlayerService service;
  final VoidCallback? onBack;

  @override
  State<_VideoPlayerRoute> createState() => _VideoPlayerRouteState();
}

class _VideoPlayerRouteState extends State<_VideoPlayerRoute> {
  late final AppVideoPlayerController _controller = widget.service.network(
    Uri.parse(widget.url),
  );
  late final Future<void> _ready = _initialize();

  Future<void> _initialize() async {
    await _controller.initialize();
    await _controller.play();
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
                  child: Text(
                    widget.title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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
                return Center(
                  child: ValueListenableBuilder<VideoPlayerValue>(
                    valueListenable: _controller.valueListenable,
                    builder: (context, value, _) => AspectRatio(
                      aspectRatio: value.aspectRatio == 0
                          ? 16 / 9
                          : value.aspectRatio,
                      child: VideoPlayer(raw),
                    ),
                  ),
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
    required this.url,
    required this.videoPlayerService,
  });

  final String title;
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
) {
  final typeNames = {for (final t in videoTypes) t.id: t.name};
  final groups = <String, List<EcTimelineVideo>>{};
  for (final item in evidence) {
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
            statusText: item.uploadStatus == 'done'
                ? null
                : _uploadStatusLabel(l10n, item.uploadStatus),
            statusIcon: item.uploadStatus == 'error' ? Icons.refresh : null,
            recordedAt: '${_dateLabel(captured)} · ${_hhmm(captured)}',
            recordedBy: item.createdByUid ?? l10n.recordedByFallback,
            device: item.device ?? l10n.deviceUnknown,
            uploadStatus: _uploadStatusLabel(l10n, item.uploadStatus),
            mediaUrl: item.url,
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
      _ => status,
    };

EcVideoDetail _videoDetail(AppLocalizations l10n, EcTimelineVideo video) =>
    EcVideoDetail(
  title: video.label,
  duration: '—',
  recordedAt: video.recordedAt ?? video.time,
  recordedBy: video.recordedBy ?? l10n.recordedByFallback,
  device: video.device ?? l10n.deviceUnknown,
  uploadStatus: video.uploadStatus ?? l10n.uploadStatusDone,
  mediaUrl: video.mediaUrl,
  type: video.type,
);

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
        );
      },
    );
  }
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
  },
  progressPercent: (task.progress * 100).round(),
  retryCount: task.retryCount,
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
}) {
  final share = shareService ?? _maybeGetIt<ShareService>();
  final videoPlayer = videoPlayerService ?? _maybeGetIt<VideoPlayerService>();
  final downloader = downloadDio ?? Dio();
  return GoRouter(
    // Override the start route for screenshot/QA via --dart-define=EC_START=/home.
    initialLocation: const String.fromEnvironment(
      'EC_START',
      defaultValue: '/',
    ),
    routes: [
      GoRoute(
        path: '/',
        builder: (c, s) => EcSplashScreen(onStart: () => c.go('/login')),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (c, s) =>
            _directionalPage(s, _LoginRoute(auth: auth, repo: repo)),
      ),
      GoRoute(
        path: '/register',
        builder: (c, s) => _RegisterRoute(auth: auth, repo: repo),
      ),
      GoRoute(
        path: '/phone-setup',
        pageBuilder: (c, s) =>
            _directionalPage(s, _PhoneSetupRoute(auth: auth, repo: repo)),
      ),
      GoRoute(
        path: '/forgot',
        builder: (c, s) => _ForgotRoute(auth: auth),
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
        builder: (c, s, navigationShell) => navigationShell,
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
                      queueCount: _pendingUploads(queue),
                      shopName: shop.name,
                      initialType: recordingType.value,
                      initialResolution: shop.resolution,
                      onBack: () => c.go('/home'),
                      onRequestCode: () => c.push<String>('/manual'),
                      onConfirmManualCode: (code) =>
                          _confirmManualTracking(c, repo, shop.id, code),
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
                                onMemberMore: (member) => router.push(
                                  '/member-actions',
                                  extra: _MemberActionExtra(
                                    shopId: shop.id,
                                    member: member,
                                  ),
                                ),
                                onInviteMember: () => router.push(
                                  '/invite-member',
                                  extra: shop.id,
                                ),
                                onTapResolution: () =>
                                    router.push('/resolution', extra: shop.id),
                                onEditType: (type) => router.push(
                                  '/create-type',
                                  extra: (shop.id, type),
                                ),
                                onDeleteType: (type) => router.push(
                                  '/confirm-delete',
                                  extra: (shop.id, type),
                                ),
                                onAddType: () => router.push(
                                  '/create-type',
                                  extra: (shop.id, null),
                                ),
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
                      onSaved: (path, code, type) {
                        queue.enqueue(
                          tracking: code,
                          type: type,
                          filePath: path,
                          shopId: shop.id,
                        );
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
            shop: shop,
            order: order,
            shareService: share,
            onBack: () => _back(c, '/home'),
            onOpenVideo: (extra) => c.push('/video', extra: extra),
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
            EcVideoDetailScreen(
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
                  _toast(c, c.l10n.toastVideoNoPlayLink);
                  return;
                }
                c.push(
                  '/video-player',
                  extra: _VideoPlayerRouteExtra(
                    title: extra!.video.title,
                    url: url,
                    videoPlayerService: videoPlayer,
                  ),
                );
              },
              onDownload: () {
                final video = extra?.video;
                if (video?.mediaUrl == null) {
                  _toast(c, c.l10n.toastVideoNoDownloadLink);
                  return;
                }
                _downloadAndShareVideo(c, downloader, share, video!);
              },
              onDelete: () {
                final evidenceId = extra?.evidenceId;
                if (extra == null || evidenceId == null) {
                  c.pop();
                  return;
                }
                repo
                    .deleteEvidence(extra.shopId, extra.orderId, evidenceId)
                    .then((_) {
                      if (c.mounted) {
                        c.pop();
                        _toast(c, c.l10n.toastVideoDeleted);
                      }
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
            onMemberMore: (member) => c.push(
              '/member-actions',
              extra: _MemberActionExtra(shopId: shop.id, member: member),
            ),
            onInviteMember: () => c.push('/invite-member', extra: shop.id),
            onTapResolution: () => c.push('/resolution', extra: shop.id),
            onEditType: (type) =>
                c.push('/create-type', extra: (shop.id, type)),
            onDeleteType: (type) =>
                c.push('/confirm-delete', extra: (shop.id, type)),
            onAddType: () => c.push('/create-type', extra: (shop.id, null)),
          );
        },
      ),
      GoRoute(
        path: '/create-type',
        pageBuilder: (c, s) => _modalPage(
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
          _InviteMemberRoute(
            repo: repo,
            shopId: s.extra is String ? s.extra! as String : '',
          ),
        ),
      ),
      GoRoute(
        path: '/member-actions',
        pageBuilder: (c, s) => _modalPage(
          EcMemberActionsScreen(
            member: s.extra is _MemberActionExtra
                ? (s.extra! as _MemberActionExtra).member
                : EcShopMember(name: c.l10n.memberFallbackName, role: c.l10n.roleUnknown),
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
        path: '/quota',
        builder: (c, s) => _QuotaRoute(repo: repo),
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
        pageBuilder: (c, s) => _modalPage(_ChangePasswordRoute(auth: auth)),
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
          _DeleteAccountRoute(auth: auth, repo: repo),
        ),
      ),
    ],
  );
}

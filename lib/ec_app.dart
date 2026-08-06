import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:ui' as ui;

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
        CupertinoPageRoute,
        CupertinoPageScaffold,
        CupertinoSlider,
        CupertinoTextThemeData,
        CupertinoThemeData,
        showCupertinoDialog,
        showCupertinoModalPopup;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';
import 'package:network/network.dart' show Dio, DioException, DioExceptionType;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_contracts/shared_contracts.dart'
    show ClipBudget, EcClaimDossier, EcClaimEvidence, EcClaimOrder;
import 'package:storage/storage.dart';

import 'app/di/injection.dart';
import 'core/data/ec_claim_store.dart';
import 'app/update_gate.dart';
import 'data/ec_uploader.dart';
import 'data/platform_device_conditions.dart';
import 'screens/ec_record_route.dart';
import 'screens/ec_scan_route.dart';

const _lastShopIdKey = 'shop.last_id';

/// `extra` marking the one entry into `/shops` that may skip the picker: the
/// splash resuming a session that is still signed in. Every other entry (a
/// deliberate login, or backing out of the app shell) stops on the picker.
const _resumedSession = 'resume';

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

class _EcAppState extends State<EcApp> with WidgetsBindingObserver {
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
    currentUid: () => _auth.currentUser?.uid,
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

  /// Id máy chủ của loại đang chọn, chốt cùng lúc với [_recordingType].
  ///
  /// Đi cùng clip vào hàng đợi. Null khi chưa mở sheet lần nào (đang dùng loại
  /// mặc định dựng sẵn ở client, thứ chưa có id) — lúc đó bên tải lên lùi về
  /// tra theo tên như cũ.
  final ValueNotifier<String?> _recordingTypeId = ValueNotifier(null);
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
    _recordingTypeId,
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
    WidgetsBinding.instance.addObserver(this);
    _queue.load();
    // Máy dựng trên bàn đóng hàng, người quay không chạm vào suốt cả ca — để
    // màn tự tắt là camera preview ngủ theo và phiên quay đứt giữa chừng.
    unawaited(WakelockPlus.enable().catchError((_) {}));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(WakelockPlus.disable().catchError((_) {}));
    _router.dispose();
    _language
      ..removeListener(_persistLanguage)
      ..dispose();
    _queue.dispose();
    _selectedShop.dispose();
    _recordingType.dispose();
    _recordingTypeId.dispose();
    super.dispose();
  }

  // Vòng đời app KHÔNG còn đưa người dùng về splash.
  //
  // Rời app rồi quay lại (app còn sống) là phải thấy đúng màn đang dở — đó là
  // thao tác đọc một tin nhắn rồi quay lại làm tiếp, không phải bắt đầu ca mới.
  // Bản trước reset về '/' ở đây nên nghe điện thoại xong là mất sạch chỗ đang
  // đứng.
  //
  // Mở lại app từ đầu (đã bị tắt hẳn) thì splash tự lo: đã đăng nhập thì vào
  // thẳng shop gần nhất rồi ra tab Vận đơn, chưa đăng nhập thì về màn đăng
  // nhập. Xem route '/' và '/shops'.

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
            // Above the router so a forced update covers every screen, and
            // inside the localization delegates so its labels are translated.
            child: UpdateGate(child: child ?? const SizedBox.shrink()),
          ),
        ),
      ),
    );
  }
}

/// Whether this build can offer Apple sign-in.
///
/// `FirebaseEcAuth` gets its Apple credential from the native Apple ID sheet,
/// which only exists on Apple platforms — the Android path would need the web
/// OAuth flow (a service ID plus a redirect URL) that this app does not set up.
/// So the option is hidden off-Apple rather than shown and always failing.
final bool _appleSignInAvailable = Platform.isIOS || Platform.isMacOS;

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

  Future<void> _afterSignIn(Future<EcUser> signIn) async {
    try {
      final user = await signIn;
      // Tài khoản email/mật khẩu chưa bấm link xác minh thì không được vào —
      // nếu không thì email xác minh chỉ là thủ tục cho vui.
      if (!user.emailVerified) {
        _analytics()?.trackLoginFailed(errorType: 'chua_xac_minh_email');
        await _blockUnverified(user);
        return;
      }
      // `login` is a reserved Firebase event, so it keeps its English name and
      // goes through `logLogin` — that is what feeds the built-in funnel.
      _analytics()?.logLogin(method: _AuthMethods.email);
      await _credentials()?.save(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (mounted) context.go('/shops', extra: 'forward');
    } on Object catch (error) {
      _analytics()?.trackLoginFailed(errorType: error.runtimeType.toString());
      if (mounted) _toast(context, _authErrorText(context.l10n, error));
    }
  }

  /// Dead end for an unverified account: explain, offer to send the link again
  /// (only possible while still signed in), then drop the session.
  Future<void> _blockUnverified(EcUser user) async {
    final resend = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(context.l10n.loginNotVerifiedTitle),
        content: Text(
          context.l10n.loginNotVerifiedMessage(
            user.email ?? _email.text.trim(),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.commonClose),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.loginResendVerification),
          ),
        ],
      ),
    );
    Object? resendError;
    var resent = false;
    if (resend ?? false) {
      try {
        await widget.auth.sendEmailVerification();
        resent = true;
        _analytics()?.trackEmailVerificationSent();
      } on Object catch (error) {
        resendError = error;
      }
    }
    await _signOutAll(widget.auth);
    if (!mounted) return;
    if (resent) {
      _toast(context, context.l10n.loginVerificationResent);
    } else if (resendError != null) {
      _toast(context, _authErrorText(context.l10n, resendError));
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
      widget.auth.signInWithGoogle(),
      method: _AuthMethods.google,
    ),
    onApple: () => _afterSocialSignIn(
      context,
      widget.auth.signInWithApple(),
      method: _AuthMethods.apple,
    ),
    showApple: _appleSignInAvailable,
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
      final email = _email.text.trim();
      await widget.auth.registerWithEmail(
        email: email,
        password: _password.text,
        name: _name.text.trim(),
      );
      // `sign_up` is reserved, same deal as `login` above.
      _analytics()?.logSignUp(signUpMethod: _AuthMethods.email);
      // The mail goes out first, while the new account is signed in: the
      // profile saves below talk to the Worker and used to take the whole
      // registration down with them, leaving an account nobody could verify.
      final verificationError = await _sendVerificationEmail();
      if (verificationError == null) {
        _analytics()?.trackEmailVerificationSent();
      }
      final profileError = await _saveProfile(
        name: _name.text.trim(),
        phone: _phone.text.trim(),
      );
      // Requirement: land back on Login with the new credentials prefilled.
      // Remember them (keychain), then sign out of the auto-signed-in session
      // so the user completes the deliberate login step.
      await _credentials()?.save(email: email, password: _password.text);
      await _signOutAll(widget.auth);
      if (!mounted) return;
      // Confirm the account exists before bouncing back to Login — otherwise
      // the screen just swaps and the registration looks like it did nothing.
      await _confirmRegistered(
        email: email,
        verificationSent: verificationError == null,
      );
      if (!mounted) return;
      // Say why the mail never left (or the profile never saved) rather than
      // leaving the user waiting for a mail Firebase refused to send.
      final problem = verificationError ?? profileError;
      if (problem != null) {
        _toast(context, _authErrorText(context.l10n, problem));
      }
      context.go('/login', extra: 'back');
    } on Object catch (error) {
      if (mounted) _toast(context, _authErrorText(context.l10n, error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Saves the name/phone through both seams, returning what went wrong or
  /// null. The account already exists at this point, so a failure here is
  /// reported rather than thrown — aborting would not undo the registration.
  Future<Object?> _saveProfile({
    required String name,
    required String phone,
  }) async {
    try {
      await widget.auth.updateProfile(name: name, phone: phone);
      await widget.repo.updateProfile(name: name, phone: phone);
      return null;
    } on Object catch (error) {
      return error;
    }
  }

  /// Sends the address-verification mail and returns what went wrong, or null
  /// when it went out. A failure here (rate limit, offline) must not undo a
  /// successful registration, so it is reported instead of thrown.
  Future<Object?> _sendVerificationEmail() async {
    try {
      await widget.auth.sendEmailVerification();
      return null;
    } on Object catch (error) {
      return error;
    }
  }

  Future<void> _confirmRegistered({
    required String email,
    required bool verificationSent,
  }) => showCupertinoDialog<void>(
    context: context,
    builder: (dialogContext) => CupertinoAlertDialog(
      title: Text(context.l10n.registerSuccessTitle),
      content: Text(
        verificationSent
            ? context.l10n.registerSuccessVerifyMessage(email)
            : context.l10n.registerSuccessMessage,
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(context.l10n.registerSuccessAction),
        ),
      ],
    ),
  );

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
      widget.auth.signInWithGoogle(),
      method: _AuthMethods.google,
    ),
    onApple: () => _afterSocialSignIn(
      context,
      widget.auth.signInWithApple(),
      method: _AuthMethods.apple,
    ),
    showApple: _appleSignInAvailable,
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

/// After an Apple/Google sign-in, go straight to shop selection.
///
/// Email is the identity; the phone is an optional support contact only, so
/// nothing here asks for one — it is edited from Tài khoản → Hồ sơ whenever the
/// user feels like it, and never gates recording, uploading or anything else.
Future<void> _afterSocialSignIn(
  BuildContext context,
  Future<EcUser> signIn, {
  required String method,
}) async {
  try {
    await signIn;
    _analytics()?.logLogin(method: method);
    if (!context.mounted) return;
    context.go('/shops', extra: 'forward');
  } on EcAuthCancelled {
    // User backed out of the provider sheet — nothing to report, and nothing
    // to log either: a cancel is not a failed login.
  } on Object catch (error) {
    _analytics()?.trackLoginFailed(errorType: error.runtimeType.toString());
    if (context.mounted) _toast(context, _authErrorText(context.l10n, error));
  }
}

/// `method` values for Firebase's reserved `login` / `sign_up` events. English
/// on purpose — these are Firebase's own dimension, not one of our labels.
abstract final class _AuthMethods {
  static const email = 'email';
  static const google = 'google';
  static const apple = 'apple';
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
  // Chỉ hỏi lại khi quay về từ trang quota — chỗ duy nhất gói có thể vừa đổi.
  late Future<QuotaDto> _quota = widget.repo.quota(
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
    _analytics()?.trackSignOut();
    await _signOutAll(widget.auth);
    // Same as signing out from the shop picker: drop the remembered shop so the
    // next session starts from a clean pick.
    await _forgetRememberedShop();
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
        final linkedCount =
            1 +
            (user?.hasProvider(EcAuthProvider.google) ?? false ? 1 : 0) +
            (user?.hasProvider(EcAuthProvider.apple) ?? false ? 1 : 0);
        return FutureBuilder<QuotaDto>(
          future: _quota,
          builder: (context, snap) => EcAccountTabScreen(
            userName: user?.displayName ?? context.l10n.accountNoName,
            userEmail: user?.email ?? '—',
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
            // Ưu tiên bản trên máy (hiện ngay, không chờ mạng); chưa có thì
            // dùng URL trên hồ sơ Firebase — đường này phục vụ máy mới hoặc
            // sau khi cài lại app.
            avatarPath: _rememberedAvatar(user?.uid) ?? user?.photoUrl,
            onNavOrders: () => context.go('/home'),
            onNavCapture: () => context.go('/record'),
            onFacebook: () => _openSupport(context, _kSupportFacebook),
            onZalo: () => _openSupport(context, _kSupportZalo),
            onCall: () => _openSupport(context, _kSupportPhone),
            onFeedback: () => _showFeedbackSheet(context),
            onRateApp: () => _openSupport(context, _kStoreListing),
            onProfileTap: () async {
              await context.push('/edit-profile');
              if (mounted) setState(() {});
            },
            onQuotaTap: () async {
              await context.push('/quota');
              if (!mounted) return;
              // Thân khối, KHÔNG phải arrow: closure của setState mà trả về
              // Future thì Flutter ném assertion và bỏ luôn lượt dựng lại.
              setState(() {
                _quota = widget.repo.quota(
                  shopId: widget.selectedShop.value?.id,
                );
              });
            },
            onLanguageTap: () => context.push('/language'),
            onEndQrTap: () => _showEndSessionQr(
              context,
              share: _maybeGetIt<ShareService>(),
              gallery: _maybeGetIt<GallerySaveService>(),
            ),
            onClaimsTap: () => context.push('/claims'),
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
    _avatarPath = _rememberedAvatar(widget.auth.currentUser?.uid);
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
      var avatarPath = _avatarPath;
      if (avatarPath != null) {
        avatarPath = await _persistAvatarFile(
          avatarPath,
          widget.auth.currentUser?.uid,
        );
        // Nhớ bản trên máy TRƯỚC mọi lời gọi mạng: ảnh đã nằm sẵn đó, không lý
        // do gì để một lỗi mạng làm mất lựa chọn của người dùng. Bản này cũng
        // là thứ hiển thị ngay trong lúc chờ tải lên.
        await _rememberAvatar(widget.auth.currentUser?.uid, avatarPath);
      }

      // Tải ảnh lên rồi ghi URL công khai vào hồ sơ Firebase — nhờ vậy ảnh
      // theo tài khoản, đăng nhập máy nào cũng có. Tải hỏng (mất mạng, ảnh quá
      // nặng) thì tên và SĐT vẫn lưu được và ảnh vẫn hiện từ bản trên máy —
      // nhưng PHẢI báo. Bản trước nuốt im lặng, nên suốt thời gian endpoint
      // không tồn tại không ai biết ảnh chưa bao giờ tới máy chủ.
      String? avatarUrl;
      String? avatarError;
      if (avatarPath != null) {
        try {
          avatarUrl = await widget.repo.uploadAvatar(avatarPath);
        } on Object catch (error) {
          avatarUrl = null;
          avatarError = _avatarErrorText(context.l10n, error);
        }
      }
      await widget.auth.updateProfile(
        name: name,
        phone: phone,
        photoUrl: avatarUrl,
      );
      await widget.repo.updateProfile(
        name: name,
        phone: phone,
        avatarUrl: avatarUrl ?? avatarPath,
      );
      if (!mounted) return;
      context.pop();
      _toast(context, avatarError ?? context.l10n.toastInfoSaved);
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
          showApple: _appleSignInAvailable,
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
  late Future<QuotaDto> _quota = widget.repo.quota(shopId: widget.shopId);
  bool _buying = false;

  @override
  void initState() {
    super.initState();
    _analytics()?.trackPaywallViewed();
  }

  /// Chữ ký quyền dùng dựng từ mỗi mã gói, dùng khi backend chưa trả
  /// `entitlement` trong `/api/me`.
  ///
  /// Khuôn phải trùng [EntitlementDto.signature] để hai nguồn so được với nhau
  /// — trộn hai khuôn là lần hỏi đầu tiên đã "khác" và mọi lượt mua đều báo
  /// thành công, kể cả lượt webhook chưa về.
  static String _entitlementSignature(String planCode) => '$planCode|null|null';

  /// Mở paywall RevenueCat rồi chờ backend áp xong giao dịch.
  ///
  /// Cửa hàng báo "đã mua" TRƯỚC khi RevenueCat kịp gọi webhook về backend, nên
  /// không thể đọc lại gói ngay — phải hỏi lại vài giây. Hết thời gian chờ mà
  /// gói chưa đổi thì báo "đang xử lý", KHÔNG báo lỗi: tiền đã trừ thật và
  /// webhook thường về ngay sau đó.
  Future<void> _upgrade(String currentPlanCode) async {
    _analytics()?.trackPurchaseStarted(planCode: currentPlanCode);
    setState(() => _buying = true);
    try {
      final billing = _billing();
      // Gắn phiên mua với tài khoản NGAY TRƯỚC khi mở paywall. RevenueCat gửi
      // uid này lên webhook; nếu mua khi chưa gắn thì giao dịch rơi vào một
      // người dùng ẩn danh và backend không biết cộng ngày cho ai.
      //
      // Cửa hàng vắng mặt (build thiếu khoá RevenueCat, hoặc mạng hỏng) KHÔNG
      // chặn việc mở màn: paywall tự hiện trạng thái "chưa tải được bảng giá".
      // Nút bấm không được dẫn tới ngõ cụt im lặng.
      var offers = const <EcPlanOffer>[];
      // Ảnh chụp quyền dùng TRƯỚC khi mở paywall — mốc để biết webhook đã về
      // hay chưa. Phải đọc ở đây chứ không sau khi mua: đọc sau thì có thể đã
      // là trạng thái mới rồi, và phép so luôn ra "chưa đổi".
      var beforeSignature = _entitlementSignature(currentPlanCode);
      if (billing != null) {
        try {
          // repo.account() có thể ném (mất mạng, token hết hạn). Không được để
          // nó chặn việc mở paywall — nút bấm mà không có gì xảy ra là lỗi tệ
          // hơn việc hiện bảng giá rỗng.
          final account = await widget.repo.account();
          beforeSignature =
              account.entitlement?.signature ??
              _entitlementSignature(currentPlanCode);
          if (await billing.start(account.uid)) {
            offers = await billing.offers();
          }
        } on Object {
          offers = const [];
        }
      }
      if (!mounted) return;
      final outcome = await Navigator.of(context).push<EcPurchaseOutcome>(
        CupertinoPageRoute(
          builder: (_) => _PaywallRoute(billing: billing, offers: offers),
        ),
      );
      if (!mounted ||
          outcome == null ||
          outcome == EcPurchaseOutcome.cancelled) {
        return;
      }
      if (outcome == EcPurchaseOutcome.failed) {
        _toast(context, context.l10n.toastPurchaseFailed);
        return;
      }
      final applied = await EcBilling.waitForEntitlementChange(
        // `/api/me` chứ không phải `/api/quota`: chỉ chỗ này mang ngày hết hạn,
        // thứ duy nhất đổi khi người dùng mua lại đúng gói đang dùng. Web poll
        // đúng endpoint này vì cùng lý do.
        fetchSignature: () async {
          final account = await widget.repo.account();
          return account.entitlement?.signature ??
              _entitlementSignature(
                (await widget.repo.quota(shopId: widget.shopId)).planCode,
              );
        },
        previousSignature: beforeSignature,
      );
      if (!mounted) return;
      // Nạp lại quota TRƯỚC khi mở hộp thoại, để lúc người dùng bấm Đóng thì
      // trang phía sau đã là số liệu của gói mới, không phải gói cũ.
      //
      // Thân khối, KHÔNG phải arrow: closure của setState mà trả về Future thì
      // Flutter ném assertion và bỏ luôn lượt dựng lại — trang đứng im ở gói cũ.
      setState(() {
        _quota = widget.repo.quota(shopId: widget.shopId);
      });
      await showCupertinoDialog<void>(
        context: context,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: Text(context.l10n.purchaseSuccessTitle),
          content: Text(
            applied
                ? context.l10n.toastPurchaseApplied
                : context.l10n.toastPurchasePending,
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.l10n.commonClose),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _buying = false);
    }
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
        // Ưu tiên số liệu của server: bảng này phải mô tả TOÀN BỘ clip của
        // shop, còn hàng đợi trên máy chỉ còn những clip chưa upload xong —
        // upload xong hết là bảng rỗng, đúng thứ đang thấy.
        final typeUsage = quota.byType.isNotEmpty
            ? [
                for (final t in quota.byType)
                  EcQuotaTypeUsage(
                    type: t.type,
                    videoCount: t.videoCount,
                    bytes: t.bytes,
                  ),
              ]
            : _localTypeUsage();
        final videoCount =
            quota.videoCount ??
            typeUsage.fold<int>(0, (total, u) => total + u.videoCount);
        return EcQuotaScreen(
          planLabel: _planDisplayName(context.l10n, quota.planCode),
          // Số của SERVER, không phải tổng các clip còn nằm trên máy.
          //
          // Bản trước cộng kích thước file trong hàng đợi upload để con số này
          // khớp với bảng chia theo loại ngay bên dưới. Nhưng clip upload xong
          // là rời hàng đợi, nên quay thêm bao nhiêu thì con số vẫn đứng yên —
          // trong khi đây đúng là con số người bán đem so với hạn mức gói.
          // Khớp nhau mà sai thì vô dụng hơn là lệch nhau mà đúng.
          usedBytes: quota.usedBytes,
          capBytes: quota.capBytes,
          retentionTotalDays: quota.retentionDays,
          videoCount: videoCount,
          typeUsage: typeUsage,
          canManagePlan: quota.canManagePlan,
          onBack: () => _back(context, '/account'),
          onUpgrade: _buying ? null : () => _upgrade(quota.planCode),
          onPaymentHistoryTap: () => context.push('/payment-history'),
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
      // Xoá DỮ LIỆU trước, tài khoản đăng nhập sau.
      //
      // Thứ tự cũ xoá Firebase trước, nên lời gọi dọn dữ liệu ngay sau đó
      // không còn token và luôn nhận 401: tài khoản biến mất, còn shop, bằng
      // chứng và gói cước ở lại vĩnh viễn — không ai xác thực được nữa để dọn.
      // Web làm đúng thứ tự này.
      //
      // Dọn dữ liệu hỏng thì ném ra ngoài và Firebase vẫn còn, người dùng thử
      // lại được. Ngược lại thì mất hẳn đường vào.
      await widget.repo.deleteAccount(force: true);
      await widget.auth.deleteAccount();
      _analytics()?.trackAccountDeleted();
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

// Kênh hỗ trợ hiện ở góc trái dưới trang Tài khoản.
//
// ponytail: hằng số tạm — chuyển sang Remote Config hoặc endpoint cấu hình khi
// cần đổi số/trang mà không phải phát hành lại app.
const _kSupportFacebook = 'https://facebook.com/zenpack.vn';
const _kSupportZalo = 'https://zalo.me/0383539856';
const _kSupportPhone = 'tel:0383539856';

/// Trang app trên store, mở bằng lược đồ riêng của từng nền tảng để nhảy thẳng
/// vào mục đánh giá thay vì mở trình duyệt.
final _kStoreListing = defaultTargetPlatform == TargetPlatform.iOS
    ? 'https://apps.apple.com/app/id0000000000?action=write-review'
    : 'market://details?id=com.aktechvn.zenpack';

/// Mở sheet góp ý và gửi thẳng lên server.
///
/// Không chuyển sang ứng dụng thư: người dùng vừa gõ xong, đẩy họ sang app
/// khác rồi bắt bấm gửi lần nữa là hai lần công cho một việc — và phần lớn bỏ
/// dở ở bước đó.
void _showFeedbackSheet(BuildContext context) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (sheetContext) => EcFeedbackSheet(
      onClose: () => Navigator.of(sheetContext).pop(),
      onSubmit: (text) {
        Navigator.of(sheetContext).pop();
        // Gửi ở nền và cảm ơn ngay: góp ý không phải giao dịch, bắt người dùng
        // ngồi chờ vòng quay mạng cho một việc họ không nhận lại gì là thừa.
        unawaited(_sendFeedback(text));
        showCupertinoModalPopup<void>(
          context: context,
          builder: (thanksContext) => EcFeedbackThanksSheet(
            onClose: () => Navigator.of(thanksContext).pop(),
          ),
        );
      },
    ),
  );
}

/// Đẩy một góp ý lên Zentam CMS, thử lại một lần khi hỏng tạm thời.
///
/// Người dùng đã được cảm ơn và đóng sheet trước khi hàm này chạy xong, nên
/// mọi lỗi đều nuốt: hiện một thông báo mạng lúc này chỉ gây hoang mang cho
/// việc họ không sửa được. Đổi lại phải thử lại — im lặng đánh rơi góp ý là
/// mất hẳn, không ai biết để gửi lại.
///
/// [EcFeedbackRejected] thì KHÔNG thử lại: CMS chê nội dung, gửi lại y nguyên
/// cũng hỏng y như vậy.
Future<void> _sendFeedback(String message) async {
  final feedback = _maybeGetIt<EcFeedback>();
  if (feedback == null) return;
  final source = EcFeedback.sourceFor(await _appVersion());
  for (var attempt = 0; attempt < 2; attempt++) {
    try {
      await feedback.send(message: message, source: source);
      return;
    } on EcFeedbackRejected catch (error, stackTrace) {
      // Ghi lại: CMS chê nội dung nghĩa là app đang gửi sai hình, và người dùng
      // thì không bao giờ thấy lỗi này để báo lại.
      unawaited(
        _crashReporter()?.recordError(error, stackTrace) ?? Future.value(),
      );
      return;
    } on Object {
      // Lần đầu hỏng thì nghỉ một nhịp rồi thử lại; lần hai hỏng thì thôi.
      if (attempt == 0) await Future<void>.delayed(const Duration(seconds: 3));
    }
  }
}

/// Phiên bản app, rỗng khi không đọc được — góp ý vẫn phải gửi đi được.
Future<String> _appVersion() async {
  try {
    return (await PackageInfo.fromPlatform()).version;
  } on Object {
    return '';
  }
}

/// Mở một kênh hỗ trợ bằng app ngoài (Messenger, Zalo, trình quay số).
///
/// Máy chưa cài app tương ứng thì `launchUrl` ném hoặc trả false — báo toast
/// thay vì im lặng, vì người bấm vào đây đang cần trợ giúp.
Future<void> _openSupport(BuildContext context, String url) async {
  final l10n = context.l10n;
  try {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) _toast(context, l10n.supportOpenFailed);
  } on Object {
    if (context.mounted) _toast(context, l10n.supportOpenFailed);
  }
}

/// Tờ QR "kết thúc phiên" để người dùng in ra dán ở bàn đóng hàng.
///
/// Ảnh là asset tĩnh vì nội dung mã (`kEndSessionQr`) là hằng số ghi cứng dùng
/// chung cho mọi máy — không có gì phải sinh lúc chạy.
/// Đường dẫn asset của tờ QR, dùng chung cho phần hiển thị, chia sẻ và lưu.
const _endQrAsset = 'assets/images/end_session_qr.png';

/// Tờ QR đã ghép dòng thương hiệu, dựng một lần rồi dùng lại.
Uint8List? _endQrPngCache;

/// Vẽ [kEndSessionBrand] xuống dưới tờ QR rồi mã hoá lại thành PNG.
///
/// Phải ghép vào chính file ảnh chứ không chỉ vẽ trên UI: cả chia sẻ lẫn tải
/// về đều gửi đi file, nên dòng chữ chỉ có trên màn hình thì tờ in ra vẫn là
/// mã QR trần. Mã hoá hỏng thì trả lại ảnh gốc — mất dòng chữ còn hơn mất luôn
/// tờ mã.
Future<Uint8List> _endQrPngWithBrand() async {
  final cached = _endQrPngCache;
  if (cached != null) return cached;

  final data = await rootBundle.load(_endQrAsset);
  final assetBytes = data.buffer.asUint8List();
  final codec = await ui.instantiateImageCodec(assetBytes);
  final qr = (await codec.getNextFrame()).image;

  const footerHeight = 200.0;
  final width = qr.width.toDouble();
  final height = qr.height + footerHeight;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  // Nền trắng trước: asset là RGBA có vùng trong suốt, in ra nền đen thì mã
  // không quét được.
  canvas.drawRect(
    Rect.fromLTWH(0, 0, width, height),
    Paint()..color = Colors.white,
  );
  canvas.drawImage(qr, Offset.zero, Paint());

  final label = TextPainter(
    text: const TextSpan(
      text: kEndSessionBrand,
      style: TextStyle(
        color: Color(0xFF161616),
        fontSize: 96,
        fontWeight: FontWeight.w700,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: width);
  label.paint(
    canvas,
    Offset(
      (width - label.width) / 2,
      qr.height + (footerHeight - label.height) / 2,
    ),
  );

  final composed = await recorder.endRecording().toImage(
    width.round(),
    height.round(),
  );
  final png = await composed.toByteData(format: ui.ImageByteFormat.png);
  qr.dispose();
  composed.dispose();
  label.dispose();

  final bytes = png?.buffer.asUint8List() ?? assetBytes;
  _endQrPngCache = bytes;
  return bytes;
}

/// Ghi tờ QR ra file tạm để chia sẻ — `shareFiles` cần đường dẫn thật, còn
/// asset thì nằm trong bundle chứ không phải trên đĩa.
Future<String> _writeEndQrToTemp() async {
  final bytes = await _endQrPngWithBrand();
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/evidencecam_ma_dung_quay.png');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}

Future<void> _shareEndSessionQr(
  BuildContext context,
  ShareService? share,
) async {
  final l10n = context.l10n;
  if (share == null) {
    _toast(context, l10n.toastShareFailed);
    return;
  }
  try {
    final path = await _writeEndQrToTemp();
    await share.shareFiles(paths: [path], subject: l10n.accountEndQrTitle);
  } on Object {
    if (context.mounted) _toast(context, l10n.toastShareFailed);
  }
}

Future<void> _saveEndSessionQr(
  BuildContext context,
  GallerySaveService? gallery,
) async {
  final l10n = context.l10n;
  if (gallery == null) {
    _toast(context, l10n.toastPhotoDownloadFailed);
    return;
  }
  try {
    await gallery.savePng(await _endQrPngWithBrand());
    if (context.mounted) _toast(context, l10n.toastPhotoSavedToGallery);
  } on Object {
    if (context.mounted) _toast(context, l10n.toastPhotoDownloadFailed);
  }
}

void _showEndSessionQr(
  BuildContext context, {
  ShareService? share,
  GallerySaveService? gallery,
}) {
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  _endQrAsset,
                  width: 220,
                  height: 220,
                  filterQuality: FilterQuality.none,
                  errorBuilder: (_, _, _) => const Icon(
                    LucideIcons.qrCode,
                    size: 96,
                    color: PenColors.mut,
                  ),
                ),
                const SizedBox(height: 8),
                const PenText(
                  kEndSessionBrand,
                  size: 18,
                  color: PenColors.ink,
                  weight: FontWeight.w700,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        PenText(
          l10n.accountEndQrNote,
          size: 13,
          color: PenColors.mut,
        ),
        const SizedBox(height: 18),
        PenCard(
          axis: PenAxis.column,
          clip: true,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          children: [
            _EndQrActionRow(
              icon: LucideIcons.share2,
              label: l10n.accountEndQrShare,
              onTap: () => unawaited(_shareEndSessionQr(sheetContext, share)),
            ),
            const PenBox(
              width: double.infinity,
              height: 1,
              fill: PenColors.line,
            ),
            _EndQrActionRow(
              icon: LucideIcons.download,
              label: l10n.accountEndQrSave,
              onTap: () => unawaited(_saveEndSessionQr(sheetContext, gallery)),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    ),
  );
}

/// Một hàng hành động trong sheet mã dừng quay.
class _EndQrActionRow extends StatelessWidget {
  const _EndQrActionRow({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => EcTap(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: PenColors.ink),
          const SizedBox(width: 12),
          Expanded(
            child: PenText(label, size: 15, color: PenColors.ink),
          ),
        ],
      ),
    ),
  );
}

/// Đăng xuất khỏi TẤT CẢ: tài khoản và phiên mua hàng.
///
/// Bỏ [EcBilling.signOut] là để lại một lỗi tiền: RevenueCat vẫn giữ
/// `app_user_id` của người trước trên thiết bị này, nên người đăng nhập sau mà
/// mua gói thì webhook gửi về uid CŨ — tiền của người này, ngày cộng cho người
/// kia. Máy dùng chung ở kho là chuyện bình thường, không phải trường hợp hiếm.
Future<void> _signOutAll(EcAuth auth) async {
  await auth.signOut();
  await _billing()?.signOut();
}

T? _maybeGetIt<T extends Object>() =>
    getIt.isRegistered<T>() ? getIt<T>() : null;

AnalyticsService? _analytics() => _maybeGetIt<AnalyticsService>();

/// Vắng mặt khi build không khai `RC_IOS_API_KEY` (test, bản offline) — mọi
/// đường mua gói phải chịu được `null` chứ không được giả định luôn có.
EcBilling? _billing() => _maybeGetIt<EcBilling>();

/// Giá mẫu khớp bảng giá đã tạo trên App Store Connect (bang-gia.md §4). CHỈ
/// dùng khi cửa hàng không trả về gì — simulator, hoặc sản phẩm chưa được duyệt.
/// Không bao giờ dùng để tính tiền: mua vẫn phải đi qua package thật.
const _sampleOffers = <(String, String, String, double)>[
  ('basic', '1m', '169.000 ₫', 169000),
  ('saver', '1m', '319.000 ₫', 319000),
  ('premium', '1m', '459.000 ₫', 459000),
  ('basic', '6m', '939.000 ₫', 939000),
  ('saver', '6m', '1.749.000 ₫', 1749000),
  ('premium', '6m', '2.549.000 ₫', 2549000),
  ('basic', '12m', '1.799.000 ₫', 1799000),
  ('saver', '12m', '3.390.000 ₫', 3390000),
  ('premium', '12m', '4.849.000 ₫', 4849000),
];

/// Mở paywall trực tiếp qua `--dart-define=EC_START=/paywall`.
class _PaywallPreviewRoute extends StatefulWidget {
  const _PaywallPreviewRoute({required this.billing});

  final EcBilling? billing;

  @override
  State<_PaywallPreviewRoute> createState() => _PaywallPreviewRouteState();
}

class _PaywallPreviewRouteState extends State<_PaywallPreviewRoute> {
  List<EcPlanOffer>? _offers;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final live = await widget.billing?.offers() ?? const <EcPlanOffer>[];
    if (mounted) setState(() => _offers = live);
  }

  @override
  Widget build(BuildContext context) {
    final live = _offers;
    if (live == null) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }
    if (live.isNotEmpty) {
      return _PaywallRoute(billing: widget.billing, offers: live);
    }
    return EcPaywallScreen(
      offers: [
        for (final (plan, term, label, amount) in _sampleOffers)
          EcPaywallOffer(
            planCode: plan,
            termKey: term,
            priceLabel: label,
            priceAmount: amount,
          ),
      ],
      onBack: () => Navigator.of(context).maybePop(),
    );
  }
}

/// Bọc [EcPaywallScreen] với phần gọi cửa hàng. Màn hình thuần hiển thị, không
/// biết gì về SDK — nhờ vậy test được mà không cần cửa hàng thật.
///
/// Đóng route trả về kết quả mua; phía gọi mới là chỗ chờ backend áp giao dịch,
/// vì paywall đã đóng rồi mà vòng chờ vẫn phải chạy tiếp.
class _PaywallRoute extends StatefulWidget {
  const _PaywallRoute({required this.billing, required this.offers});

  /// Null khi build không có khoá RevenueCat — màn vẫn mở, chỉ không mua được.
  final EcBilling? billing;
  final List<EcPlanOffer> offers;

  @override
  State<_PaywallRoute> createState() => _PaywallRouteState();
}

/// Trang điều khoản và chính sách trên web công ty. Apple đòi hai đường dẫn này
/// với tới được từ màn bán hàng; để chúng ở đây thay vì hardcode trong package
/// giao diện, vì đây là chuyện cấu hình sản phẩm chứ không phải chuyện dựng UI.
const _kTermsUrl = 'https://zenpack.vn/terms';
const _kPrivacyUrl = 'https://zenpack.vn/privacy';

class _PaywallRouteState extends State<_PaywallRoute> {
  bool _busy = false;

  /// Nạp lại biên nhận rồi chờ backend áp. Cứu đúng tình huống đã trừ tiền mà
  /// chưa được cộng ngày; backend chống trùng theo mã giao dịch nên bấm nhiều
  /// lần cũng không cộng dư.
  Future<void> _sync() async {
    final billing = widget.billing;
    if (billing == null || _busy) return;
    setState(() => _busy = true);
    final ok = await billing.syncPurchases();
    if (!mounted) return;
    setState(() => _busy = false);
    _toast(
      context,
      ok ? context.l10n.toastPurchasePending : context.l10n.toastPurchaseFailed,
    );
  }

  Future<void> _buy(EcPaywallOffer choice) async {
    final billing = widget.billing;
    if (billing == null) return;
    final offer = widget.offers.firstWhere(
      (o) => o.planCode == choice.planCode && o.termKey == choice.termKey,
    );
    setState(() => _busy = true);
    final outcome = await billing.buy(offer);
    if (!mounted) return;
    setState(() => _busy = false);
    // Huỷ ở hộp thoại cửa hàng thì ở lại paywall — người dùng có thể đổi ý và
    // chọn gói khác, đá họ ra ngoài là bắt bấm lại từ đầu.
    if (outcome == EcPurchaseOutcome.cancelled) return;
    Navigator.of(context).pop(outcome);
  }

  @override
  Widget build(BuildContext context) => EcPaywallScreen(
    busy: _busy,
    offers: [
      for (final o in widget.offers)
        EcPaywallOffer(
          planCode: o.planCode,
          termKey: o.termKey,
          priceLabel: o.priceLabel,
          priceAmount: o.priceAmount,
        ),
    ],
    onBack: () => Navigator.of(context).pop(EcPurchaseOutcome.cancelled),
    onBuy: _buy,
    onTerms: () => _openSupport(context, _kTermsUrl),
    onPrivacy: () => _openSupport(context, _kPrivacyUrl),
    // Chỉ hiện đường đồng bộ khi thật sự mua được — không có cửa hàng thì nút
    // đó không cứu được gì, để lại chỉ tạo thêm một nút chết.
    onSync: widget.billing == null ? null : _sync,
  );
}

CrashReporter? _crashReporter() => _maybeGetIt<CrashReporter>();

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

/// Ba dòng nung vào clip lúc xuất, khớp với lớp chữ của màn ghi hình.
///
/// Dòng giờ ở giữa là dòng chạy: `EcVideoStampService` vẽ sẵn một ô cho mỗi
/// giây rồi để ffmpeg cắt đúng ô theo thời gian, nên clip tải về đọc giống hệt
/// lúc bấm phát trong app. Thiếu thời lượng thì nó tự đứng im ở mốc bắt đầu.
///
/// Thiếu mốc epoch (bằng chứng cũ) thì lùi về chuỗi đã định dạng sẵn, còn hơn
/// giao ra một clip không có giờ nào.
List<String> _stampLines(EcVideoDetail video, String tracking) {
  String two(int n) => n.toString().padLeft(2, '0');
  final at = video.capturedAtMs;
  final code = tracking.isNotEmpty ? tracking : (video.tracking ?? '');
  if (at == null) {
    return [video.recordedAt, if (code.isNotEmpty) code];
  }
  final d = DateTime.fromMillisecondsSinceEpoch(at);
  return [
    '${two(d.day)}/${two(d.month)}/${d.year}',
    '${two(d.hour)}:${two(d.minute)}:${two(d.second)}',
    if (code.isNotEmpty) code,
  ];
}

Future<void> _downloadAndShareVideo(
  BuildContext context,
  Dio dio,
  ShareService? share,
  GallerySaveService? gallery,
  EcVideoDetail video, {
  String tracking = '',
}) async {
  final url = video.mediaUrl;
  if (url == null) return;
  try {
    _toast(context, context.l10n.toastDownloadingVideo);
    final dir = await getApplicationDocumentsDirectory();
    final filename = _safeFilename('${video.title}.mp4');
    var path = '${dir.path}/$filename';
    await _downloadWithRetry(dio, url, path);
    if (!context.mounted) return;
    // Nung đúng ba dòng màn ghi hình đã hiện — ngày, giờ đến giây, mã vận đơn
    // — trước khi giao file ra ngoài: rời khỏi app thì clip chỉ còn là một mp4
    // trần, người nhận không có cách nào biết nó của đơn nào. Hỏng dấu thì
    // `stamp` trả lại bản gốc, người dùng vẫn cầm được file.
    final at = video.capturedAtMs;
    final stamped = await EcVideoStampService().stamp(
      path,
      lines: _stampLines(video, tracking),
      clockStart: at == null ? null : DateTime.fromMillisecondsSinceEpoch(at),
      clockSeconds: video.durationSeconds,
    );
    if (stamped != path) await _deleteQuietly(path);
    path = stamped;
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

/// Mở sheet chọn loại video và trả về loại đã chọn — **cả nhãn lẫn id**.
///
/// Trả nguyên đối tượng chứ không chỉ nhãn vì id phải được chốt vào clip ngay
/// tại đây: đến lúc clip lên tới máy chủ thì loại có thể đã bị đổi tên hoặc
/// xoá, và tra lại theo tên lúc đó là mất loại của clip vĩnh viễn.
Future<capture.EcVideoType?> _showTypeSheet(
  BuildContext context, {
  required EcRepository repo,
  required String shopId,
  required String selectedType,
  bool mandatory = false,
}) {
  return showGeneralDialog<capture.EcVideoType>(
    context: context,
    barrierDismissible: !mandatory,
    barrierLabel: context.l10n.commonClose,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (dialogContext, _, _) => _TypeSheetRoute(
      repo: repo,
      shopId: shopId,
      selectedType: selectedType,
      dismissible: !mandatory,
      onManageTypes: () =>
          Navigator.of(dialogContext).pop(_manageVideoTypesResult),
      onBack: () => Navigator.of(dialogContext).pop(_typeSheetBackResult),
      onSelected: (type) => Navigator.of(dialogContext).pop(type),
    ),
    transitionBuilder: (_, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

/// Người dùng bấm "Quản lý loại video" chứ không chọn loại nào.
const _manageVideoTypesResult = capture.EcVideoType(
  label: '__manage_video_types__',
  icon: Icons.settings,
);

/// Người dùng bấm back trong sheet chọn loại: không quay nữa, sang tab Vận đơn.
const _typeSheetBackResult = capture.EcVideoType(
  label: '__type_sheet_back__',
  icon: Icons.arrow_back,
);

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

/// Kho hồ sơ khiếu nại, dựng một lần cho cả app.
///
/// Một thể duy nhất chứ không mỗi route một cái: hồ sơ tạo ở tab Vận đơn phải
/// hiện ngay ở tab Tài khoản, mà hai tab đó sống song song trong shell ba tab.
/// Hai thể riêng thì chúng có hai bản nhớ trong RAM khác nhau và tab kia chỉ
/// thấy hồ sơ mới sau khi khởi động lại app.
final EcClaimStore _claimStore = EcClaimStore(_appMemory());

/// Device-local avatar image path, keyed per account since the avatar isn't
/// uploaded/served from the backend yet (see `_EditProfileRouteState`).
String _avatarPathKey(String? uid) => 'profile.avatar_path.${uid ?? ''}';

/// Thư mục Documents của app, chụp lại một lần lúc khởi động.
///
/// Cần bản đồng bộ vì ảnh đại diện được đọc ngay trong `build`, mà
/// `getApplicationDocumentsDirectory()` là bất đồng bộ.
String? _documentsPath;

/// Ghi nhớ thư mục Documents; gọi trong bootstrap trước `runApp`.
void ecRememberDocumentsPath(String path) => _documentsPath = path;

/// Đổi giá trị đã lưu thành đường dẫn dùng được ở lần chạy này.
///
/// Trên iOS, thư mục dữ liệu của app nằm dưới một UUID ĐỔI MỖI LẦN CÀI LẠI.
/// Bản trước lưu đường dẫn tuyệt đối nên cài lại xong là nó trỏ vào chỗ không
/// còn tồn tại — file ảnh vẫn nằm nguyên trong Documents, chỉ là không ai tìm
/// ra nó nữa, và màn Tài khoản lặng lẽ quay về icon người.
///
/// Nhận cả giá trị cũ (tuyệt đối) lẫn mới (tương đối) để ảnh người dùng đã lưu
/// từ bản trước không mất.
String? _resolveAvatarPath(String? stored) {
  if (stored == null || stored.isEmpty) return null;
  if (stored.startsWith('http')) return stored;
  final docs = _documentsPath;
  if (!stored.startsWith('/')) {
    return docs == null ? null : '$docs/$stored';
  }
  if (File(stored).existsSync()) return stored;
  // Đường dẫn tuyệt đối đã chết: dựng lại từ phần đuôi sau `/Documents/`.
  final marker = stored.indexOf('/Documents/');
  if (docs == null || marker < 0) return stored;
  return '$docs${stored.substring(marker + '/Documents'.length)}';
}

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
    final name = '${uid ?? 'anon'}${_fileExtension(pickedPath)}';
    await File(pickedPath).copy('${avatarsDir.path}/$name');
    // Trả về đường dẫn TƯƠNG ĐỐI so với Documents — xem `_resolveAvatarPath`.
    return 'avatars/$name';
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
/// Cho phép quay clip "Trả hàng" cho [code], tạo đơn mới nếu shop chưa có.
///
/// Khớp một đơn đã có thì clip trả hàng nằm chung mã vận đơn với clip đóng
/// hàng — mở mã ra thấy đủ cả hai chặng, đó là điểm chính của hồ sơ khiếu nại.
///
/// Không khớp thì **tự tạo đơn mới rồi quay tiếp**, không hỏi. Hàng hoàn nhiều
/// khi chưa từng đi qua app này (khách trả thẳng, đơn đóng ở ca khác), mà cảnh
/// mở kiện thì không quay lại được — dừng lại hỏi là mất bằng chứng ngay lúc
/// cần nhất. Đơn mới vẫn lên hàng chờ upload và hiện ở tab Vận đơn như thường.
Future<bool> _verifyReturnCode(
  BuildContext context,
  EcRepository repo,
  String shopId,
  String code,
) async {
  final key = normalizeTrackingCode(code);
  try {
    final matches = await repo.searchOrders(shopId, code);
    if (matches.any((o) => normalizeTrackingCode(o.tracking) == key)) {
      return true;
    }
    await repo.createOrder(shopId, code);
    return true;
  } on Object catch (error) {
    // Tạo đơn hỏng (mất mạng, trùng mã) thì vẫn cho quay: clip nằm trong hàng
    // chờ và gắn theo mã, lần upload sau server tự khớp hoặc tạo đơn. Chặn ở
    // đây chỉ đổi một lỗi nền thành mất bằng chứng.
    if (context.mounted) _toast(context, _dataErrorText(context.l10n, error));
    return true;
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

/// Khoá lưu trần dung lượng người dùng tự đặt, theo từng shop.
String _sizeKey(String shopId, EcUploadKind kind) =>
    'shop.$shopId.max${kind == EcUploadKind.image ? 'Image' : 'Video'}Bytes';

/// Khoá lưu đơn đang quay dở lúc bị cắt ngang.
///
/// Ghi xuống ĐĨA chứ không giữ trong bộ nhớ: quay video + camera + cuộc gọi là
/// lúc máy tốn RAM nhất, iOS hay giết thẳng app nền. Lúc quay lại là một tiến
/// trình mới, mọi cờ trong bộ nhớ đã mất — chỉ thứ nằm trên đĩa mới nói được
/// rằng còn một đơn đang quay dở.
const ecPendingRecordKey = 'record.interrupted_code';

String? ecPendingRecordCode() => _appMemory()?.getString(ecPendingRecordKey);

Future<void> ecRememberPendingRecord(String? code) =>
    (code == null || code.isEmpty
        ? _appMemory()?.remove(ecPendingRecordKey)
        : _appMemory()?.setString(ecPendingRecordKey, code)) ??
    Future<void>.value();

/// Ảnh đại diện vừa chọn, giữ trong bộ nhớ tiến trình.
///
/// Cùng lý do với [_sizeCapCache]: `KeyValueStore` lấy qua service locator có
/// thể chưa đăng ký, lúc đó `setString` im lặng không làm gì và ảnh vừa chọn
/// biến mất ngay khi trang Tài khoản dựng lại.
final _avatarCache = <String, String>{};

Future<void> _rememberAvatar(String? uid, String path) {
  final key = _avatarPathKey(uid);
  _avatarCache[key] = path;
  return _appMemory()?.setString(key, path) ?? Future<void>.value();
}

String? _rememberedAvatar(String? uid) {
  final key = _avatarPathKey(uid);
  final cached = _avatarCache[key];
  if (cached != null) return _resolveAvatarPath(cached);
  final saved = _appMemory()?.getString(key);
  if (saved != null) _avatarCache[key] = saved;
  return _resolveAvatarPath(saved);
}

/// Trần dung lượng người dùng vừa đặt, giữ trong bộ nhớ tiến trình.
///
/// Có bản nhớ này vì `KeyValueStore` lấy qua service locator có thể chưa đăng
/// ký — lúc đó `setString` im lặng không làm gì và lựa chọn biến mất ngay khi
/// màn cài đặt nạp lại, không một dấu hiệu nào. Map này luôn có mặt nên trong
/// phiên hiện tại con số chắc chắn hiển thị đúng; đĩa chỉ là lớp bền hoá thêm.
final _sizeCapCache = <String, int>{};

/// Ghi nhớ trần vừa đặt.
///
/// `PATCH /api/shops/{id}` hiện chưa nhận `max_image_bytes`/`max_video_bytes`,
/// nên con số gửi lên không quay về trong phản hồi và màn cài đặt lại hiện 0
/// như chưa đặt gì. Nhớ tại chỗ để lựa chọn có hiệu lực ngay; lời gọi API vẫn
/// giữ nguyên nên khi backend mở hai trường đó, server thành nguồn chuẩn.
Future<void> _rememberSizeCap(String shopId, EcUploadKind kind, int bytes) {
  final key = _sizeKey(shopId, kind);
  _sizeCapCache[key] = bytes;
  return _appMemory()?.setString(key, '$bytes') ?? Future<void>.value();
}

int _rememberedSizeCap(String shopId, EcUploadKind kind, int fromServer) {
  // Lựa chọn của người dùng THẮNG giá trị server.
  //
  // Bản trước ưu tiên server, nhưng `max_video_bytes`/`max_image_bytes` mà
  // server trả về là trần của SÀN (30MB, 5MB) chứ không phải mức shop đặt —
  // nó luôn khác 0, nên con số vừa nhập không bao giờ được dùng và màn cài
  // đặt cứ hiện 30 như chưa đổi gì. Khi backend nhận hai trường đó thật thì
  // đảo lại thứ tự này.
  final key = _sizeKey(shopId, kind);
  final cached = _sizeCapCache[key];
  if (cached != null) return cached;
  final saved = _appMemory()?.getString(key);
  final parsed = int.tryParse(saved ?? '');
  if (parsed != null) {
    _sizeCapCache[key] = parsed;
    return parsed;
  }
  // Chưa đặt gì = KHÔNG GIỚI HẠN (0 byte).
  //
  // Mặc định cũ là 30MB cho video, 5MB cho ảnh — tức app tự chặn bằng chứng
  // của shop khi chưa ai yêu cầu. Clip đóng hàng dài quá mức đó bị cắt mất
  // đoạn cuối, đúng đoạn dán tem và niêm phong. Shop nào cần trần thì tự đặt.
  //
  // Con số server trả về vẫn không dùng ở đây: đó là trần của SÀN, không phải
  // mức shop đặt.
  return 0;
}

ClipBudget _budgetFromDto(ShopDto shop) => ClipBudget(
  seconds: shop.clipSeconds,
  recommendedSeconds: shop.recommendedClipSeconds,
  planMaxSeconds: shop.planMaxClipSeconds,
  maxImageBytes: _rememberedSizeCap(
    shop.id,
    EcUploadKind.image,
    shop.maxImageBytes,
  ),
  maxVideoBytes: _rememberedSizeCap(
    shop.id,
    EcUploadKind.video,
    shop.maxVideoBytes,
  ),
  uploadBytes: shop.uploadBytes,
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

/// Nhân viên chỉ được XEM cửa hàng.
///
/// Họ vẫn quay video và tạo đơn bình thường ở luồng chính — đó là việc của họ.
/// Cái bị khoá là sửa cấu hình shop, mời/gỡ người, và mọi thao tác xoá.
bool _shopDetailIsReadOnly(EcShopSummary shop) => shop.role == 'staff';

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
  // Rỗng chứ không phải một vai trò lạ — in ra chuỗi rỗng thì hàng trông như
  // lỗi hiển thị, trong khi sự thật là dữ liệu không nói vai trò là gì.
  '' => l10n.roleUnknown,
  _ => role,
};

String _planDisplayName(AppLocalizations l10n, String planCode) =>
    switch (planCode) {
      'free' => l10n.planFree,
      'basic' => l10n.planBasic,
      'saver' => l10n.planSaver,
      'premium' => l10n.planPremium,
      // Mã lạ thì hiện nguyên mã: sai còn hơn im lặng gọi nhầm tên gói người
      // dùng đang trả tiền. Nhưng 4 mã trên phải khớp PLANS ở backend.
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
///
/// Trả về đường dẫn ảnh đã xếp hàng, hoặc `null` khi người dùng huỷ / ảnh vượt
/// trần. Màn hồ sơ khiếu nại cần đường dẫn đó để hiện ảnh vừa đính ngay lập
/// tức — nó còn phải chờ tải lên xong mới có URL của server.
///
/// [toastOnQueued] tắt được vì màn hồ sơ có thông báo riêng, nói thêm rằng ảnh
/// vào cả hồ sơ lẫn đơn hàng; hai toast chồng nhau thì chỉ thấy cái sau.
Future<String?> _attachPhoto(
  BuildContext context,
  EcUploadQueue queue,
  String tracking,
  String shopId, {
  ClipBudget? budget,
  String platformLabel = '',
  bool toastOnQueued = true,
}) async {
  final path = await _pickImagePath();
  if (path == null || !context.mounted) return null;
  // Ảnh vượt giới hạn của sàn vẫn lưu NGUYÊN VẸN — không nén, không cắt (FR-20:
  // chuỗi bằng chứng phải nguyên gốc). Chỉ cảnh báo để CSKH biết phải gửi bằng
  // link hồ sơ thay vì đính thẳng lên form khiếu nại.
  final bytes = await File(path).length();
  // Trần dung lượng/tệp của shop (FR-21) là chặn cứng, khác cảnh báo của sàn:
  // chặn TRƯỚC khi vào hàng đợi, nếu không một tệp khổng lồ đã kịp đốt quota và
  // dữ liệu di động rồi mới báo. Tệp gốc còn nguyên trong máy — chủ shop nâng
  // trần rồi đính lại, không mất bằng chứng.
  final cap = budget?.uploadBytes;
  if (cap != null && bytes > cap) {
    _toast(
      context,
      context.l10n.fileOverUploadCap(
        ClipBudget.megabytesLabel(bytes),
        ClipBudget.megabytesLabel(cap),
      ),
    );
    return null;
  }
  await queue.enqueue(
    tracking: tracking,
    type: 'Ảnh đính kèm',
    filePath: path,
    shopId: shopId,
  );
  if (!context.mounted) return path;
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
    return path;
  }
  if (toastOnQueued) _toast(context, context.l10n.toastPhotoQueued);
  return path;
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

  /// Whether the screen may skip itself and enter a shop on its own. Only the
  /// splash resuming a live session passes true — after a login the user picks,
  /// even when the account has a single shop.
  final bool autoEnter;

  @override
  State<_ChooseShopRoute> createState() => _ChooseShopRouteState();
}

class _ChooseShopRouteState extends State<_ChooseShopRoute> {
  late Future<List<EcShopSummary>> _shops = _loadShops();
  var _autoSelected = false;

  /// Kết quả tốt gần nhất — giữ màn hình đứng yên trong lúc làm mới ngầm.
  List<EcShopSummary>? _last;

  /// Danh sách shop, có nhận giúp lời mời khi rỗng.
  ///
  /// `GET /api/me` là chỗ backend khớp lời mời treo với email/SĐT của tài khoản
  /// (`claimPendingInvitesForAccount`). Web gọi nó ở mỗi lần đăng nhập; app chỉ
  /// gọi lúc đăng ký và ở màn hồ sơ — nên người **đã có tài khoản từ trước** rồi
  /// mới được mời sẽ đăng nhập vào và mắc kẹt ở màn "chưa có shop" vĩnh viễn.
  ///
  /// Chỉ gọi khi danh sách rỗng: đó đúng là trường hợp hỏng, và người đã có shop
  /// không phải trả thêm một vòng mạng cho mỗi lần mở màn này.
  Future<List<EcShopSummary>> _loadShops() async {
    var shops = await widget.repo.shops();
    if (shops.isEmpty) {
      try {
        await widget.repo.account();
        shops = await widget.repo.shops();
      } on Object {
        // Không nhận được thì vẫn hiện màn "chưa có shop" như cũ.
      }
    }
    return shops.map(_shopFromDto).toList();
  }

  void _retry() => setState(() {
    _shops = _loadShops();
  });

  /// Nạp lại mỗi khi màn này được hiện lại.
  ///
  /// Tạo shop mới, nhận lời mời, đổi vai trò — tất cả đều xảy ra ở màn khác
  /// rồi quay về đây. Không nạp lại thì danh sách vẫn là bản chụp lúc mở app,
  /// và người dùng tưởng thao tác vừa rồi không ăn.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent && _seenOnce) _retry();
    _seenOnce = true;
  }

  bool _seenOnce = false;

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
    return _RefreshingFuture<List<EcShopSummary>>(
      future: _shops,
      last: _last,
      loading: const CupertinoPageScaffold(
        backgroundColor: BrandColors.bg,
        child: Center(child: CupertinoActivityIndicator()),
      ),
      error: (error) => _RouteLoadError(
        title: context.l10n.errorLoadShopList,
        detail: _dataErrorText(context.l10n, error),
        onRetry: _retry,
      ),
      builder: (context, shops) {
        _last = shops;
        if (shops.isEmpty) {
          return EcNoShopScreen(
            onCreate: widget.onCreateShop ?? widget.onManage,
            // Nạp lại thật, không chỉ hiện thông báo: người vừa được mời bấm
            // vào đây là để hỏi "đã vào chưa", mà một câu toast thì không trả
            // lời được câu đó.
            onInviteTap: () {
              _retry();
              _toast(context, context.l10n.toastInvitePending);
            },
            onLogout: widget.onLogout,
          );
        }
        _autoSelectIfNeeded(shops);
        return EcChooseShopScreen(
          shops: shops,
          // Luôn hiện "Quản lý cửa hàng".
          //
          // Trước đây ẩn khi mọi shop đều là vai trò nhân viên, nên tài khoản
          // chỉ đi làm thuê thì lối vào biến mất hẳn — nhìn ra như app mất
          // tính năng. Danh sách bên trong giờ đã hiện đủ mọi shop, nên vào
          // vẫn xem được, chỉ là không sửa được thứ mình không có quyền.
          showManage: true,
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
    // Hiện ĐỦ mọi shop, kể cả shop mình chỉ là nhân viên.
    //
    // Bản trước lọc bỏ chúng, nên danh sách ở đây ít hơn màn chọn cửa hàng —
    // nhìn ra như app làm mất một shop. Không quản lý được thì hàng đó chỉ
    // không bấm vào được (xem chỗ dựng màn), chứ không được giấu đi.
    return shops.map((s) => _shopMgmtFromDto(l10n, s)).toList();
  }

  /// Kết quả tốt gần nhất — giữ màn hình đứng yên trong lúc làm mới ngầm.
  List<EcShopMgmtEntry>? _last;

  void _retry() => setState(() {
    _shops = _load();
  });

  @override
  Widget build(BuildContext context) {
    return _RefreshingFuture<List<EcShopMgmtEntry>>(
      future: _shops,
      last: _last,
      loading: const CupertinoPageScaffold(
        backgroundColor: BrandColors.bg,
        child: Center(child: CupertinoActivityIndicator()),
      ),
      error: (error) => _RouteLoadError(
        title: context.l10n.errorLoadShopMgmt,
        detail: _dataErrorText(context.l10n, error),
        onRetry: _retry,
      ),
      builder: (context, shops) {
        _last = shops;
        return EcShopMgmtScreen(
          shops: shops,
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
    this.onTapImageSize,
    this.onTapVideoSize,
    this.onEditType,
    this.onDeleteType,
    this.onAddType,
    this.readOnly = false,
  });

  final EcRepository repo;
  final EcShopSummary shop;

  /// Ép chế độ chỉ xem kể cả khi vai trò cho phép sửa.
  ///
  /// Vai trò tự nó đã khoá màn này (xem [isReadOnly]) — cờ này chỉ để bên gọi
  /// khoá thêm, không bao giờ để mở khoá. Trước đây chiều ngược lại: mỗi call
  /// site phải nhớ truyền `readOnly`, và chỗ quên là nhân viên đi thẳng vào
  /// Mời thành viên qua sheet chọn loại video.
  final bool readOnly;
  final VoidCallback? onBack;
  final Future<void> Function(EcShopMember member)? onMemberMore;
  final Future<void> Function()? onInviteMember;
  final Future<void> Function()? onTapResolution;
  final Future<void> Function()? onTapClipDuration;
  final Future<void> Function()? onTapImageSize;
  final Future<void> Function()? onTapVideoSize;
  final Future<void> Function(EcVideoType type)? onEditType;
  final Future<void> Function(EcVideoType type)? onDeleteType;
  final Future<void> Function()? onAddType;

  /// Vai trò trên [shop] có bị khoá sửa không.
  ///
  /// Tính ở đây chứ không ở call site: màn này có ba đường vào, quên một chỗ
  /// là mở toang cả trang quản trị cho nhân viên — đúng thứ đã xảy ra với
  /// đường vào từ sheet chọn loại video.
  bool get isReadOnly => readOnly || _shopDetailIsReadOnly(shop);

  @override
  State<_ShopDetailRoute> createState() => _ShopDetailRouteState();
}

class _ShopDetailRouteState extends State<_ShopDetailRoute> {
  late Future<_ShopDetailData> _detail = _load();

  /// Ba lời gọi độc lập nhau, nhưng hỏng thì không được im lặng.
  ///
  /// `await` nối tiếp cả ba (bản đầu) khiến một endpoint hỏng là cả màn chi
  /// tiết thành trang "không tải được". Cho tất cả rơi về rỗng (bản thứ hai)
  /// còn tệ hơn: danh sách thành viên trống đọc ra thành "mất chủ shop" — một
  /// khẳng định sai về quyền sở hữu, chứ không phải một màn thiếu dữ liệu.
  ///
  /// Nên chia theo mức nguy hiểm của việc đoán sai:
  /// - **thành viên** hỏng → ném lên cho màn báo lỗi. Rỗng ở đây là một câu
  ///   trả lời về việc ai sở hữu cửa hàng, không được bịa.
  /// - **thông tin shop** hỏng → lùi về snapshot của màn quản lý; ở đó là tên,
  ///   sàn, độ phân giải thật, không có gì bịa ra.
  /// - **loại video** hỏng → rỗng, đúng như spec, và người dùng nhận ra ngay
  ///   vì màn này có sẵn nút thêm loại.
  ///
  /// Nhân viên thì KHÔNG hỏi thành viên: endpoint đó chỉ mở cho chủ/quản lý,
  /// nên lượt gọi ấy chắc chắn 403. Gọi rồi báo hỏng là dựng ra một khối lỗi
  /// kèm nút "Thử lại" không bao giờ thành công — hỏi là sai, không phải trả
  /// lời sai.
  Future<_ShopDetailData> _load() async {
    final l10n = context.l10n;
    final canReadMembers = !widget.isReadOnly;
    final results = await Future.wait([
      _orLog('shop', () => widget.repo.shop(widget.shop.id)),
      if (canReadMembers)
        _orLog('members', () => widget.repo.members(widget.shop.id)),
      _orLog('video-types', () => widget.repo.videoTypes(widget.shop.id)),
    ]);
    final members = canReadMembers ? results[1] as List<MemberDto>? : null;
    return _ShopDetailData(
      shop: (results[0] as ShopDto?) ?? _snapshotDto(),
      members: (members ?? const [])
          .map((m) => _memberFromDto(l10n, m))
          .toList(),
      membersFailed: canReadMembers && members == null,
      membersRestricted: !canReadMembers,
      videoTypes: ((results.last as List<VideoTypeDto>?) ?? const [])
          .map(_videoTypeFromDto)
          .toList(),
    );
  }

  Future<T?> _orLog<T>(String what, Future<T> Function() run) async {
    try {
      return await run();
    } on Object catch (error, stack) {
      developer.log(
        // Ghi rõ KIỂU lỗi: `TypeError` là app đọc sai dữ liệu trả về, còn
        // `DioException` là endpoint hỏng. Hai thứ đó sửa ở hai nơi khác hẳn
        // nhau, mà nhìn màn báo lỗi thì không phân biệt được.
        'shop detail: $what failed (${error.runtimeType})',
        name: 'zenpack.shop',
        level: 1000,
        error: error,
        stackTrace: stack,
      );
      return null;
    }
  }

  /// Bản shop dựng lại từ snapshot của route, dùng khi đọc lại shop hỏng.
  ///
  /// Ngân sách clip không nằm trong [EcShopSummary] dưới dạng số thô nên các
  /// trường đó về mặc định của DTO — màn hình vẫn dựng được, chỉ là mức đề
  /// xuất hiển thị theo mặc định cho tới lần đọc lại thành công.
  ShopDto _snapshotDto() => ShopDto(
    id: widget.shop.id,
    name: widget.shop.name,
    platform: widget.shop.platform,
    resolution: widget.shop.resolution,
    role: widget.shop.role,
  );

  /// Kết quả tốt gần nhất — giữ màn hình đứng yên trong lúc làm mới ngầm.
  _ShopDetailData? _last;

  void _retry() => setState(() {
    _detail = _load();
  });

  @override
  Widget build(BuildContext context) {
    return _RefreshingFuture<_ShopDetailData>(
      future: _detail,
      last: _last,
      loading: const CupertinoPageScaffold(
        backgroundColor: BrandColors.bg,
        child: Center(child: CupertinoActivityIndicator()),
      ),
      error: (error) => _RouteLoadError(
        title: context.l10n.errorLoadShopDetail,
        detail: _dataErrorText(context.l10n, error),
        onRetry: _retry,
      ),
      builder: (context, detail) {
        _last = detail;
        final locked = widget.isReadOnly || detail.shop.role == 'staff';
        return EcShopDetailScreen(
          readOnly: locked,
          membersError: detail.membersFailed,
          membersUnavailable: detail.membersRestricted,
          onRetryMembers: _retry,
          shopName: detail.shop.name,
          platformLabel: _platformDisplayName(detail.shop.platform),
          resolution: detail.shop.resolution,
          clipBudget: _budgetFromDto(detail.shop),
          members: detail.members,
          videoTypes: detail.videoTypes,
          onBack: widget.onBack,
          onMemberMore: locked || widget.onMemberMore == null
              ? null
              : (member) => widget.onMemberMore!(member).then((_) {
                  if (mounted) _retry();
                }),
          onInviteMember: locked || widget.onInviteMember == null
              ? null
              : () => widget.onInviteMember!().then((_) {
                  if (mounted) _retry();
                }),
          onTapResolution: locked || widget.onTapResolution == null
              ? null
              : () => widget.onTapResolution!().then((_) {
                  if (mounted) _retry();
                }),
          onTapClipDuration: locked || widget.onTapClipDuration == null
              ? null
              : () => widget.onTapClipDuration!().then((_) {
                  if (mounted) _retry();
                }),
          onTapImageSize: locked || widget.onTapImageSize == null
              ? null
              : () => widget.onTapImageSize!().then((_) {
                  if (mounted) _retry();
                }),
          onTapVideoSize: locked || widget.onTapVideoSize == null
              ? null
              : () => widget.onTapVideoSize!().then((_) {
                  if (mounted) _retry();
                }),
          onEditType: locked || widget.onEditType == null
              ? null
              : (type) => widget.onEditType!(type).then((_) {
                  if (mounted) _retry();
                }),
          onDeleteType: locked || widget.onDeleteType == null
              ? null
              : (type) => widget.onDeleteType!(type).then((_) {
                  if (mounted) _retry();
                }),
          onAddType: locked || widget.onAddType == null
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
    this.membersFailed = false,
    this.membersRestricted = false,
  });

  /// Đọc thành viên hỏng — phân biệt với cửa hàng thật sự không có ai, thứ
  /// không tồn tại vì cửa hàng nào cũng có người tạo ra nó.
  final bool membersFailed;

  /// Không hỏi thành viên vì vai trò không được phép — cũng không phải "không
  /// có ai", nhưng khác hẳn [membersFailed]: thử lại không giúp được gì.
  final bool membersRestricted;

  final ShopDto shop;

  final List<EcShopMember> members;
  final List<EcVideoType> videoTypes;
}

/// Hàng `pending` chưa có tài khoản: không uid, không tên, không email — chỉ
/// có địa chỉ đã mời. Nhãn trạng thái lấy theo `invite_status`, không theo
/// `status`: chủ shop và người được thêm thẳng không đi qua lời mời nào, gắn
/// nhãn mời cho họ là nói sai.
EcShopMember _memberFromDto(AppLocalizations l10n, MemberDto member) {
  final role = _roleDisplayName(l10n, member.role);
  return EcShopMember(
    accountUid: member.accountUid,
    inviteId: member.inviteId,
    roleCode: member.role,
    name:
        member.name ??
        member.email ??
        member.inviteContact ??
        member.accountUid ??
        '',
    role: switch (member.inviteStatus) {
      'sent' => l10n.memberInviteSent(role),
      'accepted' => l10n.memberInviteAccepted(role),
      _ => role,
    },
  );
}

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
    required this.onBack,
    this.dismissible = true,
  });

  final EcRepository repo;
  final String shopId;
  final String selectedType;
  final VoidCallback onManageTypes;
  final ValueChanged<capture.EcVideoType> onSelected;
  final VoidCallback onBack;
  final bool dismissible;

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
          onBack: widget.onBack,
          dismissible: widget.dismissible,
        );
      },
    );
  }
}

capture.EcVideoType _captureTypeFromDto(VideoTypeDto type) =>
    capture.EcVideoType(
      label: type.name,
      id: type.id,
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

  Future<void> _invite(EcMemberInvite invite) async {
    if (_saving || invite.contact.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      final result = await widget.repo.sendShopInvite(
        widget.shopId,
        contact: invite.contact.trim(),
        role: invite.role,
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
      if (mounted) _toast(context, _inviteErrorText(context.l10n, error));
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

/// Vì sao ảnh đại diện không lên được máy chủ.
///
/// Tên và SĐT vẫn lưu bình thường, ảnh vẫn hiện từ bản trên máy — nên đây là
/// một lời nhắc, không phải một thất bại. Nhưng phải nói ra: im lặng đúng là
/// cách bản trước giấu việc endpoint không tồn tại suốt nhiều bản phát hành.
String _avatarErrorText(AppLocalizations l10n, Object error) =>
    error is AvatarTooLargeException
    ? l10n.avatarTooLarge(
        ClipBudget.megabytesLabel(error.bytes),
        ClipBudget.megabytesLabel(error.maxBytes),
      )
    : l10n.avatarUploadFailed(_dataErrorText(l10n, error));

/// Lỗi của riêng luồng mời thành viên.
///
/// Bốn mã dưới đây phải chặn TRƯỚC [_dataErrorText]: `account_not_found` ở đó
/// nghĩa là "phiên đăng nhập hỏng, đăng nhập lại" — đúng cho luồng auth, sai
/// hoàn toàn ở đây, nơi nó nghĩa là người được mời chưa có tài khoản. Và kể từ
/// khi mời bắt buộc người nhận đã đăng ký, đó chính là lỗi hay gặp nhất.
String _inviteErrorText(AppLocalizations l10n, Object error) =>
    switch (_apiErrorCode(error)) {
      'account_not_found' => l10n.errorInviteAccountNotFound,
      'already_member' => l10n.errorInviteAlreadyMember,
      'already_owner' => l10n.errorInviteAlreadyOwner,
      'invalid_request' => l10n.errorInviteInvalidRequest,
      _ => _dataErrorText(l10n, error),
    };

/// Orders tab — loads a page from the repository, supports pull-to-refresh and
/// infinite scroll (20/page), and shows the live upload-queue count in the
/// header. First page shows a full-screen spinner; later pages a trailing one.
class _OrdersRoute extends StatefulWidget {
  const _OrdersRoute({
    required this.repo,
    required this.queue,
    required this.shopId,
    required this.shopName,
    this.shopPlatform,
    this.evidenceCountOverrides,
    this.onBack,
    this.onShopTap,
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

  /// Sàn của shop — badge góc ảnh overview mỗi dòng đơn.
  final String? shopPlatform;
  final _EvidenceCountOverrides? evidenceCountOverrides;
  final VoidCallback? onBack;
  final VoidCallback? onShopTap;
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

  /// Chuyển trang từ backend sang mô hình của danh sách.
  ///
  /// Tổng số đơn bị KẸP lại khi trang trả về chưa đầy: một trang thiếu chỗ là
  /// trang cuối, không thể có trang sau. Header `X-Total-Count` đếm theo phạm
  /// vi riêng của backend nên có lúc lớn hơn số đơn thật sự lọc ra — tin thẳng
  /// vào nó là vẽ ra trang 2, trang 3 rỗng cho một danh sách 3 mã.
  EcOrderPage _pageOf(OrderPageDto dto) {
    final shown = dto.items.length;
    final lastIfShort = (dto.page - 1) * dto.pageSize + shown;
    return EcOrderPage(
      page: dto.page,
      total: shown < dto.pageSize ? lastIfShort : dto.total,
      pageSize: dto.pageSize,
      shown: shown,
      totalVideos: dto.totalVideos,
    );
  }

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
    if (!mounted) return;
    // Reported after the reload so the count is the filtered one — which chip
    // returns nothing is the whole point of watching this event.
    _analytics()?.trackOrdersFiltered(
      filter: _filterLabel(filters),
      resultCount: _page.total,
    );
  }

  /// Which chips are active, as a stable name. Never the typed order code —
  /// that is customer data.
  String _filterLabel(EcOrderFilters filters) {
    final active = [
      if (filters.fromTs != null || filters.toTs != null) 'thoi_gian',
      if (filters.videoTypeId != null) 'loai_video',
      if (filters.uploadState != null) 'trang_thai',
    ];
    return active.isEmpty ? 'tat_ca' : active.join('_');
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

  /// Bằng chứng của một mã đơn, cho danh sách tick khi gộp link.
  ///
  /// Danh sách vận đơn chỉ có số đếm, nên phải hỏi thêm chi tiết đơn. Hỏng thì
  /// trả rỗng: hàng bung ra báo "chưa có bằng chứng" chứ không làm vỡ màn.
  /// Gom những gì vừa tick thành một hồ sơ khiếu nại và lưu lại.
  ///
  /// Chụp NGUYÊN nội dung bằng chứng chứ không giữ id rồi tra sau: clip có hạn
  /// lưu trữ, và một hồ sơ khiếu nại phải nói được nó ĐÃ gồm những gì kể cả khi
  /// bằng chứng gốc đã hết hạn. Không có gì gửi lên máy chủ ở bước này — backend
  /// chưa có endpoint gộp; xem `EcClaimStore`.
  Future<void> _createClaim(List<EcClaimOrderPick> picks) async {
    final l10n = context.l10n;
    if (picks.isEmpty) {
      _toast(context, l10n.claimsPickNothing);
      return;
    }
    final now = DateTime.now();
    await _claimStore.add(
      EcClaimDossier(
        id: now.microsecondsSinceEpoch.toString(),
        shopId: widget.shopId,
        createdAt: now,
        orders: [
          for (final pick in picks)
            EcClaimOrder(
              tracking: pick.orderCode,
              orderId: _orders
                  .where((o) => o.tracking == pick.orderCode)
                  .firstOrNull
                  ?.id,
              evidence: [
                for (final e in pick.evidence)
                  EcClaimEvidence(
                    id: e.id,
                    label: e.label,
                    time: e.time,
                    isPhoto: e.isPhoto,
                    url: e.url,
                    thumbUrl: e.thumbUrl,
                  ),
              ],
            ),
        ],
      ),
    );
    if (mounted) _toast(context, l10n.claimsCreated);
  }

  Future<List<EcPickableEvidence>> _pickableEvidence(String code) async {
    final match = _orders.where((o) => o.tracking == code);
    if (match.isEmpty) return const [];
    try {
      final detail = await widget.repo.order(widget.shopId, match.first.id);
      final l10n = context.l10n;
      return [
        for (final e in detail.evidence)
          if (e.uploadStatus != 'deleted')
            EcPickableEvidence(
              id: e.id,
              label: _kindLabel(l10n, e.kind),
              time: _hhmm(DateTime.fromMillisecondsSinceEpoch(e.capturedAt)),
              isPhoto: e.kind == 'photo',
              thumbUrl: e.kind == 'photo' ? e.url : e.thumbUrl,
              url: e.url,
            ),
      ];
    } on Object {
      return const [];
    }
  }

  /// Gửi CẢ khoảng ngày lên server, và phân trang bình thường.
  ///
  /// Bản trước cố ý giữ `from`/`to` lại rồi lọc tại máy theo ngày QUAY, vì
  /// server lọc theo ngày TẠO đơn. Cái giá của nó lớn hơn cái được: web lọc
  /// theo ngày tạo nên cùng một chip "Hôm nay" cho ra hai danh sách khác nhau
  /// trên hai thiết bị, và để lọc được tại máy thì app phải kéo về tới 200 đơn
  /// rồi lặng lẽ bỏ qua phần cũ hơn ở shop đông đơn.
  ///
  /// Nay bám theo web: một trục thời gian duy nhất — ngày TẠO đơn, do server
  /// lọc — và mỗi lần một trang. Nhiều hơn thì bấm sang trang sau.
  Future<OrderPageDto> _fetchPage(int page) => widget.repo.orders(
    widget.shopId,
    page: page,
    uploadState: _filters.uploadState,
    videoTypeId: _filters.videoTypeId,
    fromTs: _filters.fromTs,
    toTs: _filters.toTs,
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
      // Nạp lại ĐÚNG trang đang xem, kể cả khi đang lọc theo ngày — server đã
      // lọc sẵn nên trang đó vẫn là trang đó.
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
  int _videoCount(OrderSummaryDto o) =>
      widget.evidenceCountOverrides?[o.tracking]?.$1 ?? o.videoCount;

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
      videoCount: _videoCount(o),
      // Ưu tiên lần quay gần nhất; đơn chưa có bằng chứng thì lấy lúc tạo đơn.
      // Đây là nhãn ngày của dòng, KHÔNG phải thứ chip thời gian lọc theo —
      // chip lọc `created_at`, và việc đó nay do server làm.
      capturedAtMs: capturedAt ?? o.createdAt,
      errorCount: _errorCount(o),
      pendingCount: o.pendingCount,
      thumbUrl: o.latestThumbUrl,
    );
  }

  List<EcHomeStat> _stats(EcUploadQueue queue) {
    // Hai thẻ đầu nói về CẢ shop (đúng hơn: cả tập đơn khớp bộ lọc), nên phải
    // lấy tổng của server. Cộng `_orders` là cộng đúng một trang — tối đa 10
    // đơn — nên shop có 102 đơn vẫn hiện "10", và số video thì hiện tổng của
    // 10 đơn đó. Đó chính là con số sai người dùng nhìn thấy.
    //
    // Tìm kiếm là ngoại lệ: backend trả hết một lần, không phân trang
    // (`_unpaged` ⇒ `shown == 0`), nên lúc đó cộng tại chỗ mới là đúng.
    final paged = _page.shown > 0;
    final orderCount = paged ? _page.total : _orders.length;
    final videoCount = paged
        ? _page.totalVideos
        : _orders.fold<int>(0, (total, order) => total + order.videoCount);
    // Ba icon là ba glyph khác nhau trong khung F2-01 (package / video /
    // cloud-upload) — bỏ trống thì cả ba cùng ra package.
    return [
      EcHomeStat(value: '$orderCount', label: context.l10n.statOrdersToday),
      EcHomeStat(
        value: '$videoCount',
        label: context.l10n.statVideosRecorded,
        icon: LucideIcons.video,
        accent: PenColors.success,
      ),
      EcHomeStat(
        value: '${_pendingUploads(queue)}',
        label: context.l10n.statPendingUpload,
        icon: LucideIcons.cloudUpload,
        accent: PenColors.warning,
        tintValue: true,
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
    // Mọi đơn server trả về đều được vẽ. Bộ lọc "ẩn đơn không còn bằng chứng"
    // trước đây làm số dòng lệch với "1–10 / N" (thanh phân trang đếm theo
    // server), mà lại chẳng ẩn được đúng thứ nó nói: xoá clip chỉ đổi
    // `upload_status`, bản ghi vẫn còn nên `evidence_count` không hề giảm. Đơn
    // rỗng giờ hiện với 0 video — đó là sự thật, và web cũng cố tình nêu chúng
    // ra ở mục "đơn cần xử lý".
    final rows = _orders.map((o) => _toRow(context.l10n, o)).toList();
    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.queue,
        if (widget.evidenceCountOverrides != null)
          widget.evidenceCountOverrides!,
      ]),
      builder: (context, _) => EcHomeOrdersScreen(
        shopName: widget.shopName,
        platform: widget.shopPlatform,
        orders: rows,
        stats: _stats(widget.queue),
        searchHint: context.l10n.ordersSearchHint,
        emptyText: context.l10n.ordersEmpty,
        onBack: widget.onBack,
        onShopTap: widget.onShopTap,
        onNavRecord: widget.onNavRecord,
        onNavAccount: widget.onNavAccount,
        onOrderTap: widget.onOrderTap == null
            ? null
            : (row) {
                final matches = _orders.where((o) => o.tracking == row.code);
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
        onLoadEvidence: _pickableEvidence,
        onCreateClaim: _createClaim,
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

  /// Mở màn chi tiết bằng chứng; hoàn tất với `true` khi có thay đổi cần nạp
  /// lại danh sách (xoá), `false` khi người dùng chỉ xem rồi đóng.
  final Future<bool> Function(_VideoRouteExtra extra)? onOpenVideo;

  @override
  State<_OrderRoute> createState() => _OrderRouteState();
}

class _OrderRouteState extends State<_OrderRoute> {
  late Future<_OrderDetailData> _detail = _load();

  /// Số clip của đơn này còn nằm trong hàng đợi, lần đọc gần nhất.
  ///
  /// Ảnh vừa đính chỉ có trên máy; server chưa biết gì cho tới khi tải xong.
  /// Theo dõi con số này để nạp lại đúng lúc nó rời hàng đợi — nạp lại ở MỌI
  /// nhịp hàng đợi động đậy thì mỗi phần trăm tiến trình là một lần gọi API.
  Set<String>? _queueIds;

  void _onQueueChanged() {
    // So theo TẬP id của cả hàng đợi, không lọc theo mã đơn: mã lưu trong hàng
    // đợi đã qua chuẩn hoá nên không phải lúc nào cũng bằng `order.tracking`,
    // và lọc trượt thì tập luôn rỗng — không lần nạp lại nào chạy, ảnh vừa
    // đính vẫn phải thoát ra vào lại mới thấy.
    //
    // Chỉ đổi khi có việc VÀO hoặc RA khỏi hàng đợi, nên tiến trình tải chạy
    // từng phần trăm không kéo theo hàng loạt lời gọi API.
    final ids = widget.queue.tasks.map((t) => t.id).toSet();
    if (_queueIds != null &&
        _queueIds!.length == ids.length &&
        _queueIds!.containsAll(ids)) {
      return;
    }
    _queueIds = ids;
    if (mounted) _retry();
  }

  @override
  void initState() {
    super.initState();
    widget.queue.addListener(_onQueueChanged);
  }

  @override
  void dispose() {
    widget.queue.removeListener(_onQueueChanged);
    super.dispose();
  }

  /// Kết quả tốt gần nhất — giữ màn hình đứng yên trong lúc làm mới ngầm.
  _OrderDetailData? _last;

  Future<_OrderDetailData> _load() async {
    final detail = await widget.repo.order(widget.shop.id, widget.order.id);
    // The orders list can only show whatever `evidence_count`/`error_count`
    // the server last computed for this order — which, unlike this detail
    // fetch, isn't recalculated when a clip is deleted (see
    // _EvidenceCountOverrides' doc comment). Report the true, live numbers
    // from the data already being fetched here so that list corrects itself
    // without needing its own extra request.
    // Cùng định nghĩa với `VIDEO_LIVE` của backend (services/orders.ts) — nếu
    // hai bên đếm khác nhau thì mở một đơn ra rồi quay lại là con số trên dòng
    // tự nhảy.
    final liveVideos = detail.evidence.where(
      (e) =>
          e.kind == 'video' &&
          !const {'deleted', 'expired', 'error'}.contains(e.uploadStatus),
    );
    widget.evidenceCountOverrides?.report(
      widget.order.tracking,
      liveVideos.length,
      detail.evidence.where((e) => e.uploadStatus == 'error').length,
    );
    final types = await widget.repo.videoTypes(widget.shop.id);
    // "Người quay" was showing the raw Firebase uid — resolve it to whoever
    // that account actually is (name, else email) so it reads like a person
    // instead of a token. Best-effort: an empty map just falls back to the
    // uid, same as before, rather than failing the whole screen.
    var memberNames = <String, String>{};
    // Tên trên chính tài khoản đang đăng nhập, đặt trước danh sách thành viên.
    //
    // Clip người ta xem lại nhiều nhất là clip của chính mình, mà tên mình thì
    // không cần hỏi cửa hàng mới biết. Quan trọng hơn: `/members` hỏng là cả
    // map rỗng, lúc đó dòng "Người quay" rơi về một nhãn chung chung dù app
    // đang biết thừa người quay là ai.
    try {
      final me = await widget.repo.account();
      final myName = me.name ?? me.email;
      if (myName != null && myName.isNotEmpty) memberNames[me.uid] = myName;
    } on Object {
      // Không đọc được tài khoản thì vẫn còn đường qua danh sách thành viên.
    }
    try {
      final members = await widget.repo.members(widget.shop.id);
      memberNames = {
        ...memberNames,
        for (final m in members)
          if (m.accountUid != null && (m.name ?? m.email) != null)
            m.accountUid!: (m.name ?? m.email)!,
      };
    } on Object {
      // Keep whatever we have — evidence still renders, just without names.
    }
    return _OrderDetailData(
      detail: detail,
      videoTypes: types,
      memberNames: memberNames,
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
    return _RefreshingFuture<_OrderDetailData>(
      future: _detail,
      last: _last,
      loading: const CupertinoPageScaffold(
        backgroundColor: BrandColors.bg,
        child: Center(child: CupertinoActivityIndicator()),
      ),
      error: (error) => _RouteLoadError(
        title: context.l10n.errorLoadOrderDetail,
        detail: _dataErrorText(context.l10n, error),
        onRetry: _retry,
      ),
      builder: (context, data) {
        _last = data;
        final days = _withPendingUploads(
          context.l10n,
          _timelineDays(
            context.l10n,
            data.detail.evidence,
            data.videoTypes,
            data.memberNames,
          ),
          data.detail.order.tracking,
          widget.queue,
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
                    // Mọi vai trò đều xoá được, theo yêu cầu. Backend vẫn là chốt cuối:
                    // không đủ quyền thì lời gọi xoá bị từ chối và màn báo lỗi.
                    // Vai trò THẬT, không phải `true` cho tất cả. Máy chủ cấm
                    // nhân viên xoá bằng chứng, nên mời họ bấm rồi trả lỗi là
                    // app tự mâu thuẫn với chính màn hàng chờ (đã chặn staff).
                    canDelete: widget.shop.role != 'staff',
                    tracking: widget.order.tracking,
                    video: _videoDetail(
                      context.l10n,
                      video,
                      tracking: widget.order.tracking,
                    ),
                  ),
                )
                // Chỉ nạp lại khi chi tiết báo có thay đổi. Kéo sheet xuống
                // để đóng là thao tác xem xong, nạp lại chỉ làm danh sách
                // nhấp nháy và cuộn về đầu vô cớ.
                .then((changed) {
                  if (changed && mounted) _retry();
                }),
            onVideoMenu: (video) => widget.onOpenVideo
                ?.call(
                  _VideoRouteExtra(
                    shopId: widget.shop.id,
                    orderId: widget.order.id,
                    evidenceId: video.id,
                    // Mọi vai trò đều xoá được, theo yêu cầu. Backend vẫn là chốt cuối:
                    // không đủ quyền thì lời gọi xoá bị từ chối và màn báo lỗi.
                    // Vai trò THẬT, không phải `true` cho tất cả. Máy chủ cấm
                    // nhân viên xoá bằng chứng, nên mời họ bấm rồi trả lỗi là
                    // app tự mâu thuẫn với chính màn hàng chờ (đã chặn staff).
                    canDelete: widget.shop.role != 'staff',
                    tracking: widget.order.tracking,
                    video: _videoDetail(
                      context.l10n,
                      video,
                      tracking: widget.order.tracking,
                    ),
                  ),
                )
                // Chỉ nạp lại khi chi tiết báo có thay đổi. Kéo sheet xuống
                // để đóng là thao tác xem xong, nạp lại chỉ làm danh sách
                // nhấp nháy và cuộn về đầu vô cớ.
                .then((changed) {
                  if (changed && mounted) _retry();
                }),
            onCopyCode: () => _copyText(
              context,
              data.detail.order.tracking,
              context.l10n.labelTrackingCode,
            ),
            onRetryUpload: () => unawaited(_retryPendingUploads()),
            // Backend chưa có endpoint gộp bằng chứng thành hồ sơ, nên nút chỉ
            // báo đang chờ. Giữ nguyên như trước khi khối này bị gỡ.
            onCreateLink: (picked) =>
                _toast(context, context.l10n.bundleBackendPending),
            // Nạp lại NGAY sau khi đính: ảnh mới chỉ vào hàng đợi, còn danh
            // sách bằng chứng dựng từ dữ liệu server. Không nạp lại thì phải
            // thoát ra vào lại mới thấy ảnh vừa chọn.
            onAttachPhoto: () => unawaited(
              _attachPhoto(
                context,
                widget.queue,
                data.detail.order.tracking,
                widget.shop.id,
                budget: widget.shop.clipBudget,
                platformLabel: _platformDisplayName(widget.shop.platform),
              ).then((_) {
                if (mounted) _retry();
              }),
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
  });

  final OrderDetailDto detail;
  final List<VideoTypeDto> videoTypes;

  /// Account uid -> display name (name, else email), for resolving
  /// [EvidenceDto.createdByUid] to something readable.
  final Map<String, String> memberNames;
}

/// Corrects the orders list's video/error counts against reality.
///
/// Cần đến nó vì trang danh sách được nạp một lần rồi nằm đó: xoá một clip
/// trong màn chi tiết không làm `video_count`/`error_count` của trang đã tải
/// tự cập nhật. Màn chi tiết dù sao cũng phải tải toàn bộ bằng chứng để vẽ
/// chính nó, nên số đúng được lấy luôn từ lần tải đó — không tốn thêm request.
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
    this.capturedAtMs,
    this.tracking,
    this.onBack,
  });

  final int? capturedAtMs;
  final String? tracking;

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

/// Ngày / giờ / mã vận đơn vẽ đè lên khung hình lúc phát lại.
///
/// Dựng lại đúng khối mà màn ghi hình hiện ở góc phải, trừ nút back và chip
/// tải lên — hai thứ đó là điều khiển của app, không phải thông tin bằng
/// chứng. Xem lại clip phải đọc được y như lúc quay.
///
/// Vẽ lúc phát chứ không nung vào file: nung chữ bắt buộc phải encode lại
/// video, tức là file không còn là chuỗi byte gốc từ cảm biến — đúng thứ FR-07
/// cấm. Bản tải về / gửi đi mới nung, và nung đúng ba dòng này.
class _PlaybackStamp extends StatelessWidget {
  const _PlaybackStamp({
    required this.title,
    required this.recordedAt,
    required this.position,
    this.capturedAtMs,
    this.tracking,
  });

  final String title;
  final String recordedAt;

  /// Vị trí đang phát, cộng vào [capturedAtMs] để đồng hồ chạy theo clip thay
  /// vì đứng im ở giây bấm quay.
  final Duration position;
  final int? capturedAtMs;
  final String? tracking;

  static TextStyle _style(double size, FontWeight weight) => TextStyle(
    color: Colors.white,
    fontSize: size,
    height: 1.25,
    fontWeight: weight,
    shadows: const [
      Shadow(color: Color(0xCC000000), blurRadius: 6),
      Shadow(color: Color(0x99000000), offset: Offset(0, 1)),
    ],
  );

  static String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final startedAt = capturedAtMs;
    // Bằng chứng cũ không lưu mốc epoch — giữ nguyên nhãn một dòng cũ thay vì
    // dựng một đồng hồ bịa từ chuỗi đã định dạng sẵn.
    if (startedAt == null) {
      return Positioned(
        top: 8,
        left: 8,
        right: 8,
        child: IgnorePointer(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: _style(12, FontWeight.w600),
                ),
              ),
              const Spacer(),
              Text(recordedAt, style: _style(12, FontWeight.w600)),
            ],
          ),
        ),
      );
    }
    final now = DateTime.fromMillisecondsSinceEpoch(
      startedAt,
    ).add(position);
    final code = tracking ?? '';
    return Positioned(
      top: 8,
      right: 8,
      child: IgnorePointer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_two(now.day)}/${_two(now.month)}/${now.year}',
              style: _style(15, FontWeight.w500),
              softWrap: false,
            ),
            Text(
              '${_two(now.hour)}:${_two(now.minute)}:${_two(now.second)}',
              style: _style(22, FontWeight.w700),
              softWrap: false,
            ),
            if (code.isNotEmpty)
              Text(
                code,
                style: _style(15, FontWeight.w600),
                softWrap: false,
                overflow: TextOverflow.visible,
              ),
          ],
        ),
      ),
    );
  }
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
                                    capturedAtMs: widget.capturedAtMs,
                                    tracking: widget.tracking,
                                    position: value.position,
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
    this.tracking = '',
    this.evidenceId,
  });

  final EcVideoDetail video;

  /// Mã vận đơn, để đóng dấu lên clip lúc tải về — `EcVideoDetail` chỉ mang
  /// thông tin của riêng clip, không biết nó thuộc đơn nào.
  final String tracking;
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
    this.capturedAtMs,
    this.tracking,
  });

  /// Mốc quay + mã vận đơn, để lớp chữ lúc phát dựng lại đúng cái màn ghi hình
  /// đã hiện.
  final int? capturedAtMs;
  final String? tracking;

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

/// Ghép các bằng chứng CHƯA tải xong của đơn vào danh sách.
///
/// Danh sách dựng từ dữ liệu server, mà ảnh vừa đính mới chỉ nằm trong hàng
/// đợi trên máy — nạp lại bao nhiêu lần server cũng chưa có gì để trả. Không
/// ghép vào thì người dùng đính ảnh xong nhìn thấy y như chưa đính, phải thoát
/// ra vào lại (lúc đó tải đã xong) mới thấy.
///
/// So mã đơn sau khi chuẩn hoá: mã lưu trong hàng đợi đã bỏ dấu cách và viết
/// hoa, không phải lúc nào cũng bằng chuỗi hiển thị.
List<EcTimelineDay> _withPendingUploads(
  AppLocalizations l10n,
  List<EcTimelineDay> days,
  String tracking,
  EcUploadQueue queue,
) {
  final wanted = normalizeTrackingCode(tracking);
  final pending = [
    for (final task in queue.tasks)
      if (normalizeTrackingCode(task.tracking) == wanted)
        EcTimelineVideo(
          time: _hhmm(task.createdAt),
          capturedAtMs: task.createdAt.millisecondsSinceEpoch,
          label: task.type,
          type: task.type.toLowerCase().contains('ảnh')
              ? EcEvidenceType.image
              : EcEvidenceType.video,
          statusText: l10n.uploadStatusPending,
          durationSeconds: task.durationSeconds,
        ),
  ];
  if (pending.isEmpty) return days;
  final today = _dateLabel(DateTime.now());
  final rest = [
    for (final d in days)
      if (d.date != today) d,
  ];
  final todayVideos = [
    for (final d in days)
      if (d.date == today) ...d.videos,
  ];
  return [
    EcTimelineDay(date: today, videos: [...pending, ...todayVideos]),
    ...rest,
  ];
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
            capturedAtMs: item.capturedAt,
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

/// `06/08/2026` — ngày tạo hồ sơ, dạng ngắn nhất mà vẫn không nhập nhằng.
String _dayLabelOf(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year}';
}

/// Lớp cha: danh sách hồ sơ khiếu nại của shop đang chọn.
///
/// Nghe [EcClaimStore] chứ không chụp một lần: hồ sơ có thể được tạo ở tab Vận
/// đơn trong lúc màn này còn nằm trong stack, và người dùng quay lại phải thấy
/// nó ngay chứ không phải sau khi khởi động lại app.
class _ClaimListRoute extends StatelessWidget {
  const _ClaimListRoute({required this.shopId, this.onBack});

  final String shopId;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _claimStore,
    builder: (context, _) {
      final dossiers = _claimStore.forShop(shopId);
      return EcClaimListScreen(
        onBack: onBack,
        entries: [
          for (final d in dossiers)
            EcClaimEntry(
              id: d.id,
              dateLabel: _dayLabelOf(d.createdAt),
              timeLabel: _hhmm(d.createdAt),
              orderCount: d.orders.length,
              evidenceCount: d.evidenceCount,
            ),
        ],
        onOpen: (entry) =>
            context.push('/claim-detail', extra: (shopId, entry.id)),
        onCopy: (entry) {
          final dossier = _claimStore.byId(shopId, entry.id);
          if (dossier == null) return;
          _copyClaimSummary(context, dossier);
        },
      );
    },
  );
}

/// Sao chép nội dung hồ sơ dưới dạng chữ.
///
/// Chưa có link gộp để sao chép — backend chưa mở endpoint — nên thứ đi vào
/// clipboard là chính nội dung hồ sơ. Dán được thẳng vào khung chat CSKH của
/// sàn, và người đọc không cần app nào để mở nó.
void _copyClaimSummary(BuildContext context, EcClaimDossier dossier) {
  final l10n = context.l10n;
  Clipboard.setData(
    ClipboardData(text: ecClaimSummaryText(dossier, title: l10n.claimsTitle)),
  );
  _toast(context, l10n.claimsCopied);
}

/// Lớp con: nội dung một hồ sơ — từng mã vận đơn và bằng chứng của nó, cộng
/// một hàng đính kèm ảnh dưới mỗi mã đơn.
class _ClaimDetailRoute extends StatelessWidget {
  const _ClaimDetailRoute({
    required this.shopId,
    required this.dossierId,
    required this.queue,
    this.budget,
    this.onBack,
  });

  final String shopId;
  final String dossierId;
  final EcUploadQueue queue;
  final ClipBudget? budget;
  final VoidCallback? onBack;

  /// Đính ảnh vào ĐƠN HÀNG trước, rồi mới ghi vào hồ sơ.
  ///
  /// Thứ tự đó là cố ý: ảnh khiếu nại phải sống trên máy chủ, nơi web admin
  /// thấy được và gỡ app không làm mất. Bản ghi trong hồ sơ chỉ là con trỏ tới
  /// nó. Làm ngược lại thì hồ sơ nói có ảnh trong khi ảnh chưa đi đâu cả.
  Future<void> _attach(BuildContext context, String tracking) async {
    final path = await _attachPhoto(
      context,
      queue,
      tracking,
      shopId,
      budget: budget,
      toastOnQueued: false,
    );
    if (path == null || !context.mounted) return;
    final l10n = context.l10n;
    await _claimStore.attachEvidence(
      shopId,
      dossierId,
      tracking,
      EcClaimEvidence(
        // Chưa có id của server (ảnh mới vào hàng đợi), nên dùng chính đường
        // dẫn file làm khoá — đủ để không trùng với bằng chứng nào khác.
        id: path,
        label: l10n.kindPhoto,
        time: _hhmm(DateTime.now()),
        isPhoto: true,
        url: path,
        addedLater: true,
      ),
    );
    if (context.mounted) _toast(context, l10n.claimsPhotoAdded);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(l10n.claimsDelete),
        content: Text(l10n.claimsDeleteConfirm),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await _claimStore.remove(shopId, dossierId);
    if (!context.mounted) return;
    _toast(context, l10n.claimsDeleted);
    onBack?.call();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _claimStore,
    builder: (context, _) {
      final dossier = _claimStore.byId(shopId, dossierId);
      // Hồ sơ vừa bị xoá ở màn này: khung rỗng chỉ tồn tại một nhịp trước khi
      // `onBack` đưa đi, nên không dựng màn báo lỗi cho nó.
      if (dossier == null) {
        return const CupertinoPageScaffold(
          backgroundColor: BrandColors.bg,
          child: SizedBox.shrink(),
        );
      }
      return EcClaimDetailScreen(
        dateLabel: _dayLabelOf(dossier.createdAt),
        timeLabel: _hhmm(dossier.createdAt),
        onBack: onBack,
        onCopy: () => _copyClaimSummary(context, dossier),
        onDelete: () => unawaited(_confirmDelete(context)),
        onAttachPhoto: (tracking) => unawaited(_attach(context, tracking)),
        groups: [
          for (final order in dossier.orders)
            EcClaimOrderGroup(
              tracking: order.tracking,
              items: [
                for (final e in order.evidence)
                  EcClaimItem(
                    label: e.label,
                    time: e.time,
                    isPhoto: e.isPhoto,
                    thumbUrl: e.thumbUrl,
                    addedLater: e.addedLater,
                  ),
              ],
            ),
        ],
      );
    },
  );
}

/// Màn lịch sử thanh toán. Đọc một lần khi mở, có nút thử lại khi mạng hỏng.
///
/// Không cache: người dùng vào đây đúng lúc muốn kiểm tra một giao dịch vừa
/// trả — đọc lại từ server mỗi lần mở là thứ họ mong đợi.
class _PaymentHistoryRoute extends StatefulWidget {
  const _PaymentHistoryRoute({required this.repo});

  final EcRepository repo;

  @override
  State<_PaymentHistoryRoute> createState() => _PaymentHistoryRouteState();
}

class _PaymentHistoryRouteState extends State<_PaymentHistoryRoute> {
  late Future<List<PaymentDto>> _future = widget.repo.payments();

  // Thân khối, KHÔNG phải arrow: closure của setState mà trả về Future thì
  // Flutter ném assertion và bỏ luôn lượt dựng lại — nút "Thử lại" thành nút
  // chết.
  void _retry() {
    setState(() {
      _future = widget.repo.payments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FutureBuilder<List<PaymentDto>>(
      future: _future,
      builder: (context, snap) => EcPaymentHistoryScreen(
        loading: snap.connectionState == ConnectionState.waiting,
        errorMessage: snap.hasError ? _dataErrorText(l10n, snap.error!) : null,
        entries: (snap.data ?? const <PaymentDto>[])
            .map((p) => _paymentEntry(l10n, p))
            .toList(),
        onBack: () => _back(context, '/quota'),
        onRetry: _retry,
      ),
    );
  }
}

EcPaymentEntry _paymentEntry(AppLocalizations l10n, PaymentDto p) {
  final plan = _planDisplayName(l10n, p.planCode);
  final term = _termLabel(l10n, p.term);
  return EcPaymentEntry(
    id: p.id,
    title: term == null ? plan : '$plan · $term',
    status: _paymentStatus(p.status),
    dateLabel: _dateLabel(
      DateTime.fromMillisecondsSinceEpoch(p.createdAt).toLocal(),
    ),
    sourceLabel: switch (p.source) {
      'sepay' => l10n.paymentSourceSepay,
      'appstore' => l10n.paymentSourceAppStore,
      _ => l10n.paymentSourcePayos,
    },
    // Backend trả null khi không biết giá (mua trong ứng dụng). Giữ nguyên
    // null tới tận UI thay vì đổi thành 0 — xem [PaymentDto.amount].
    amountLabel: p.amount == null ? null : _vndLabel(p.amount!),
    sandbox: p.sandbox,
  );
}

/// `1m`/`6m`/`12m` → nhãn đọc được; null giữ nguyên null (SePay và App Store
/// không có thời hạn để hiện).
String? _termLabel(AppLocalizations l10n, String? term) => switch (term) {
  '1m' => l10n.planTerm1m,
  '6m' => l10n.planTerm6m,
  '12m' => l10n.planTerm12m,
  _ => null,
};

EcPaymentStatus _paymentStatus(String raw) => switch (raw) {
  'paid' => EcPaymentStatus.paid,
  'cancelled' => EcPaymentStatus.cancelled,
  'expired' => EcPaymentStatus.expired,
  'refunded' => EcPaymentStatus.refunded,
  _ => EcPaymentStatus.pending,
};

/// `1569000` → `1.569.000 ₫`. Dấu chấm phân nhóm nghìn theo cách viết tiền
/// Việt Nam, không dùng dấu phẩy kiểu Anh–Mỹ.
String _vndLabel(int amount) {
  final digits = amount.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return '${amount < 0 ? '-' : ''}$buffer ₫';
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

EcVideoDetail _videoDetail(
  AppLocalizations l10n,
  EcTimelineVideo video, {
  String tracking = '',
}) => EcVideoDetail(
  capturedAtMs: video.capturedAtMs,
  durationSeconds: video.durationSeconds,
  tracking: tracking,
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
  // Hỏi bộ dịch của API trước: nó đọc mã lỗi thật trong thân phản hồi và phân
  // biệt được 403 với phiên hỏng, `open_dossiers_exist` với lỗi mạng. So chuỗi
  // bên dưới chỉ là lưới đỡ cho những lỗi không phải từ Dio.
  final api = _apiErrorText(l10n, error);
  if (api != null) return api;
  final text = error.toString();
  // 403 ≠ 401. Phiên vẫn tốt, chỉ là không đủ quyền — bảo người dùng đăng nhập
  // lại là đẩy họ vào vòng lặp: đăng xuất, đăng nhập, vẫn hỏng y như cũ.
  if (text.contains('403')) return l10n.errorNoPermission;
  if (text.contains('401')) return l10n.errorSessionInvalid;
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

/// [FutureBuilder] nhưng giữ lại dữ liệu tốt gần nhất trong lúc [future] mới
/// đang chạy.
///
/// `FutureBuilder` thuần quay về `ConnectionState.waiting` mỗi lần được đưa một
/// future khác, nên mỗi lần làm mới sau khi đóng sheet, cả màn hình bị thay
/// bằng spinner rồi dựng lại từ đầu — người dùng thấy màn "nháy"/tải lại dù chỉ
/// vừa đổi một dòng. Ở đây chỉ **lần tải đầu tiên** mới được hiện spinner; các
/// lần sau chạy ngầm và màn hình đổi số liệu tại chỗ khi có kết quả.
///
/// ponytail: refresh ngầm mà lỗi thì giữ nguyên dữ liệu cũ chứ không nuốt màn
/// hình — lỗi của *hành động* vẫn được chính handler của nó toast. Nếu sau này
/// cần báo cả lỗi refresh, thêm một callback `onBackgroundError`.
class _RefreshingFuture<T> extends StatelessWidget {
  const _RefreshingFuture({
    required this.future,
    required this.last,
    required this.loading,
    required this.error,
    required this.builder,
  });

  final Future<T> future;

  /// Kết quả tốt gần nhất, do State giữ. `null` = chưa từng tải xong.
  final T? last;
  final Widget loading;

  /// Chỉ dùng khi chưa có [last] — hỏng ngay từ lần tải đầu.
  final Widget Function(Object error) error;
  final Widget Function(BuildContext context, T data) builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snap) {
        final data = snap.data ?? last;
        if (snap.hasError && data == null) return error(snap.error!);
        if (data == null) return loading;
        return builder(context, data);
      },
    );
  }
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
/// the real recorded clips with their upload status and retry.
class _QueueRoute extends StatelessWidget {
  const _QueueRoute({
    required this.queue,
    required this.canDelete,
    this.onBack,
    this.onUpgrade,
  });

  final EcUploadQueue queue;

  /// FR-02 — Nhân viên không được xóa bằng chứng, kể cả clip **chưa upload**
  /// còn nằm trong hàng đợi trên máy: xóa ở đây là mất vĩnh viễn và backend
  /// chưa có bản sao nào để chặn hộ.
  final bool canDelete;
  final VoidCallback? onBack;
  final VoidCallback? onUpgrade;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: queue,
      builder: (context, _) {
        final items = [
          for (final task in queue.tasks) _taskToItem(task),
        ];
        return EcUploadQueueScreen(
          items: items,
          onBack: onBack,
          onUpgrade: onUpgrade,
          onRetry: (item) {
            final id = item.id;
            if (id != null) queue.retry(id);
          },
          onPause: (item) {
            final id = item.id;
            if (id != null) queue.pause(id);
          },
          onResume: (item) {
            final id = item.id;
            if (id != null) queue.resume(id);
          },
          onDelete: canDelete
              ? (item) => _confirmDeleteQueueItem(context, queue, item)
              : null,
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

GoRouter _buildRouter(
  EcRepository repo,
  EcAuth auth,
  ValueNotifier<EcAppLanguage> language,
  EcUploadQueue queue,
  ValueNotifier<EcShopSummary?> selectedShop,
  ValueNotifier<String> recordingType,
  ValueNotifier<String?> recordingTypeId,
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
          // Đã đăng nhập thì vào thẳng shop gần nhất rồi ra tab Vận đơn;
          // `/shops` tự chọn hộ nhờ `_resumedSession` (xem route '/shops').
          // Chưa đăng nhập mới đi từ màn đăng nhập.
          onStart: () => auth.currentUser != null
              ? c.go('/shops', extra: _resumedSession)
              : c.go('/login'),
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
            // Chỉ phiên còn sống mở lại app mới vào thẳng shop gần nhất (đúng
            // ghi chú trên màn này). Đăng nhập là hành động có chủ đích nên
            // luôn dừng ở đây để người dùng chọn shop.
            autoEnter: s.extra == _resumedSession,
            onSelect: (shop) {
              selectedShop.value = shop;
              _rememberShop(shop);
              _analytics()?.trackShopSelected(platform: shop.platform);
              c.go('/home');
            },
            onManage: () => c.push('/shop-mgmt'),
            onCreateShop: () => c.push('/create-shop'),
            onLogout: () {
              _analytics()?.trackSignOut();
              _signOutAll(auth).then((_) async {
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
            _analytics()?.trackShopCreated(platform: shop.platform);
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
          final onRecordTab =
              navigationShell.currentIndex == _recordBranchIndex;
          // Bước vào tab ghi hình thì loại video về mặc định, để sheet mà
          // EcRecordRoute mở ngay sau đó tick sẵn "Đóng hàng" chứ không phải
          // loại của lượt quay trước. Không ai lắng nghe notifier này nên gán
          // trong build là an toàn (chỉ đọc lúc dựng route và lúc mở sheet).
          if (onRecordTab && !(isRecordTabActive?.value ?? false)) {
            recordingType.value = kEcDefaultVideoType;
            // Id phải về null cùng lúc, nếu không loại mặc định "Đóng hàng"
            // của lượt này mang id của loại đã chọn ở lượt quay trước.
            recordingTypeId.value = null;
          }
          isRecordTabActive?.value = onRecordTab;
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
                    shopPlatform: shop.platform,
                    evidenceCountOverrides: evidenceCountOverrides,
                    onBack: () => c.go('/shops', extra: 'back'),
                    // Tên shop trên header là lối vào Chi tiết cửa hàng —
                    // không thì màn F1-09 chỉ tới được qua đường vòng
                    // Chọn cửa hàng → Quản lý cửa hàng.
                    onShopTap: () => c.push('/shop-detail', extra: shop),
                    onNavRecord: () => c.go('/record'),
                    onNavAccount: () => c.go('/account'),
                    onQueueTap: () => c.push('/queue'),
                    onOrderTap: (order) {
                      _analytics()?.trackOrderOpened(
                        source: AnalyticsSources.list,
                      );
                      return c.push('/order', extra: order);
                    },
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
                      permissions: _maybeGetIt<PermissionService>(),
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
                          _verifyReturnCode(c, repo, shop.id, code),
                      voiceAnnouncer: voice,
                      onRequestType:
                          (
                            BuildContext sheetContext, {
                            bool mandatory = false,
                          }) async {
                            final router = GoRouter.of(c);
                            final rootNavigator = Navigator.of(
                              c,
                              rootNavigator: true,
                            );
                            // Vòng lặp chứ không thoát sau khi quản lý loại: màn
                            // quay hiểu `null` là "bỏ qua, quay với loại mặc
                            // định", nên trả null lúc vừa đi sửa danh sách sẽ
                            // khoá luôn loại cũ mà không hỏi lại.
                            while (true) {
                              final selected = await _showTypeSheet(
                                sheetContext,
                                repo: repo,
                                shopId: shop.id,
                                selectedType: recordingType.value,
                                mandatory: mandatory,
                              );
                              // Bấm back trong sheet: không quay nữa, sang thẳng
                              // tab Vận đơn. Trả `null` để màn quay hiểu là chưa
                              // chọn loại nên đừng dựng camera.
                              //
                              // Tab Vận đơn nằm ở `/home`, KHÔNG phải `/orders` —
                              // `/orders` không tồn tại nên `go` im lặng không đi
                              // đâu cả, đúng triệu chứng "bấm back không ra gì".
                              if (selected == _typeSheetBackResult) {
                                if (c.mounted) c.go('/home');
                                return null;
                              }
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
                                      // Đường vào thứ hai của màn chi tiết cửa
                                      // hàng (từ sheet chọn loại). Thiếu hai
                                      // callback này thì hai hàng dung lượng
                                      // vẫn vẽ ra nhưng bấm không ra gì.
                                      onTapImageSize: () => router
                                          .push<void>(
                                            '/upload-size',
                                            extra: (
                                              shop.id,
                                              EcUploadKind.image,
                                            ),
                                          )
                                          .then((_) {}),
                                      onTapVideoSize: () => router
                                          .push<void>(
                                            '/upload-size',
                                            extra: (
                                              shop.id,
                                              EcUploadKind.video,
                                            ),
                                          )
                                          .then((_) {}),
                                      onInviteMember: () => router
                                          .push(
                                            '/invite-member',
                                            extra: shop.id,
                                          )
                                          .then((_) {}),
                                      onTapResolution: () => router.push(
                                        '/resolution',
                                        extra: shop.id,
                                      ),
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
                                if (!c.mounted) return null;
                                continue;
                              }
                              if (selected != null &&
                                  selected.label.isNotEmpty) {
                                // Nhãn và id chốt CÙNG một lúc, từ cùng một
                                // dòng người dùng vừa bấm. Tách hai lượt đọc là
                                // mở lại đúng khe hở đã sửa: loại đổi tên giữa
                                // chừng thì clip mang id của loại khác.
                                recordingType.value = selected.label;
                                recordingTypeId.value = selected.id;
                              }
                              return selected?.label;
                            }
                          },
                      onNavOrders: () => c.go('/home'),
                      onNavAccount: () => c.go('/account'),
                      onSettings: () => c.push('/type-sheet'),
                      deviceConditions: const PlatformDeviceConditions(),
                      onSaved:
                          (
                            path,
                            code,
                            type,
                            durationSeconds,
                            samples,
                            startedAt,
                          ) {
                            queue.enqueue(
                              tracking: code,
                              type: type,
                              // Chỉ nhận id khi nhãn còn khớp với loại đã chọn
                              // ở sheet. Hai giá trị này đặt cùng lúc nên lệch
                              // nhau là bloc đang báo một loại khác — gửi id cũ
                              // theo là gán nhầm loại cho clip, tệ hơn hẳn việc
                              // để bên tải lên tra lại theo tên.
                              videoTypeId: recordingType.value == type
                                  ? recordingTypeId.value
                                  : null,
                              filePath: path,
                              shopId: shop.id,
                              capturedAt: startedAt,
                              durationSeconds: durationSeconds,
                              samplesJson: samples.isEmpty
                                  ? null
                                  : DeviceSample.encode(samples),
                            );
                            _analytics()?.trackClipRecorded(
                              videoType: type,
                              durationSeconds: durationSeconds,
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
            share: share,
            shop: shop,
            order: order,
            evidenceCountOverrides: evidenceCountOverrides,
            onBack: () => _back(c, '/home'),
            // `push<bool>`: màn chi tiết trả `true` khi thực sự đổi dữ liệu
            // (xoá bằng chứng). Chỉ đóng lại — kéo xuống hay bấm ra ngoài —
            // thì trả null và danh sách khỏi nạp lại.
            onOpenVideo: (extra) async =>
                await c.push<bool>(
                  extra.video.type == EcEvidenceType.image
                      ? '/photo'
                      : '/video',
                  extra: extra,
                ) ??
                false,
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
                onCopyLink: () {
                  final url = extra?.video.mediaUrl;
                  if (url == null) {
                    _toast(pageContext, c.l10n.toastVideoNoPlayLink);
                    return;
                  }
                  _copyText(pageContext, url, c.l10n.assetLinkTitle);
                },
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
                      capturedAtMs: extra.video.capturedAtMs,
                      tracking: extra.tracking,
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
                    tracking: extra?.tracking ?? '',
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
                            c.pop(true);
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
                canDelete: extra?.canDelete ?? false,
                onDelete: extra?.evidenceId == null
                    ? null
                    : () async {
                        final ok = await showCupertinoDialog<bool>(
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
                        if (ok != true || !pageContext.mounted) return;
                        try {
                          await repo.deleteEvidence(
                            extra!.shopId,
                            extra.orderId,
                            extra.evidenceId!,
                          );
                          if (pageContext.mounted) {
                            _toast(pageContext, c.l10n.toastVideoDeleted);
                          }
                          if (c.mounted) c.pop(true);
                        } on Object catch (error) {
                          if (pageContext.mounted) {
                            _toast(pageContext, _dataErrorText(c.l10n, error));
                          }
                        }
                      },
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
                onCopyLink: () {
                  final url = extra?.video.mediaUrl;
                  if (url == null) {
                    _toast(pageContext, c.l10n.toastPhotoNoDownloadLink);
                    return;
                  }
                  _copyText(pageContext, url, c.l10n.assetLinkTitle);
                },
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
            capturedAtMs: extra.capturedAtMs,
            tracking: extra.tracking,
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
          // No shop resolved yet ⇒ treat as staff and hide the delete
          // affordance; evidence is easier to re-record than to un-delete.
          canDelete: (_selected(selectedShop)?.role ?? 'staff') != 'staff',
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
              onBack: () => c.pop(),
              onManageTypes: () {
                c.pop();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (c.mounted) c.push('/shop-detail');
                });
              },
              // Return the chosen type to the record route, which applies it to
              // the current/next recording. Nhãn và id chốt cùng một lúc, như ở
              // sheet mở từ màn quay.
              onSelected: (t) {
                recordingType.value = t.label;
                recordingTypeId.value = t.id;
                c.pop(t.label);
              },
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
            _analytics()?.trackSignOut();
            _signOutAll(auth).then((_) async {
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
          // Nhân viên: bỏ trống mọi callback nên màn chi tiết dựng ra ở dạng
          // chỉ đọc. Máy chủ vốn đã từ chối các thao tác này, nên đây là bịt
          // lối vào chứ không phải hàng rào an ninh — chưa bịt thì người dùng
          // bấm xong mới ăn lỗi, và không hiểu vì sao.
          final readOnly = _shopDetailIsReadOnly(shop);
          return _ShopDetailRoute(
            repo: repo,
            shop: shop,
            readOnly: readOnly,
            onBack: () => _back(c, '/shop-mgmt'),
            onMemberMore: readOnly
                ? null
                : (member) => c
                      .push(
                        '/member-actions',
                        extra: _MemberActionExtra(
                          shopId: shop.id,
                          member: member,
                        ),
                      )
                      .then((_) {}),
            onInviteMember: readOnly
                ? null
                : () => c.push('/invite-member', extra: shop.id).then((_) {}),
            onTapResolution: readOnly
                ? null
                : () =>
                      c.push<void>('/resolution', extra: shop.id).then((_) {}),
            onTapClipDuration: readOnly
                ? null
                : () => c
                      .push<void>('/clip-duration', extra: shop.id)
                      .then((_) {}),
            onTapImageSize: readOnly
                ? null
                : () => c
                      .push<void>(
                        '/upload-size',
                        extra: (shop.id, EcUploadKind.image),
                      )
                      .then((_) {}),
            onTapVideoSize: readOnly
                ? null
                : () => c
                      .push<void>(
                        '/upload-size',
                        extra: (shop.id, EcUploadKind.video),
                      )
                      .then((_) {}),
            onEditType: readOnly
                ? null
                : (type) => c
                      .push('/create-type', extra: (shop.id, type))
                      .then((_) {}),
            // Xoá loại video là thao tác phá dữ liệu — nhân viên không có.
            onDeleteType: readOnly
                ? null
                : (type) => c
                      .push('/confirm-delete', extra: (shop.id, type))
                      .then((_) {}),
            onAddType: readOnly
                ? null
                : () => c
                      .push('/create-type', extra: (shop.id, null))
                      .then((_) {}),
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
            // Lời mời còn treo không có uid — gỡ nó là `DELETE /invites/:id`,
            // thứ cũng làm link trong email chết ngay. Trước đây nhánh này đòi
            // uid nên hàng "đã mời" không xóa nổi, chỉ báo "không có ai để sửa".
            onRemove: () async {
              final extra = s.extra;
              final inviteId = extra is _MemberActionExtra
                  ? extra.member.inviteId
                  : null;
              final uid = extra is _MemberActionExtra
                  ? extra.member.accountUid
                  : null;
              if (extra is _MemberActionExtra &&
                  (inviteId != null || uid != null)) {
                try {
                  if (inviteId != null) {
                    await repo.revokeShopInvite(extra.shopId, inviteId);
                  } else {
                    await repo.removeMember(extra.shopId, uid!);
                  }
                  if (!c.mounted) return;
                  c.pop();
                  _toast(
                    c,
                    inviteId != null
                        ? c.l10n.toastInviteRevoked
                        : c.l10n.toastMemberRemoved,
                  );
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
              // Không còn hộp thoại "máy chủ đã kẹp giá trị": sheet đã kẹp theo
              // `plan_max_clip_seconds` trước khi gửi, nên con số tới đây luôn
              // nằm trong trần và nhánh đó không bao giờ chạy được. Giữ lại chỉ
              // là giữ một lời giải thích cho tình huống không tồn tại.
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
        path: '/upload-size',
        pageBuilder: (c, s) {
          final shop = _selected(selectedShop);
          // `extra` mang theo CẢ id shop lẫn loại bằng chứng.
          //
          // Trước đây chỉ mang loại, còn id lấy từ `selectedShop` — mà màn chi
          // tiết cửa hàng mở được cả khi `selectedShop` chưa đặt, lúc đó id là
          // chuỗi rỗng. Ghi vào khoá `shop..maxVideoBytes` rồi đọc ở khoá
          // `shop.<id thật>.maxVideoBytes`: hai khoá khác nhau nên con số vừa
          // nhập không bao giờ đọc lại được.
          final extra = s.extra;
          final (shopId, kind) = extra is (String, EcUploadKind)
              ? extra
              : (shop?.id ?? '', EcUploadKind.video);
          return _modalPage(
            s,
            EcUploadSizeSheetScreen(
              budget: shop?.clipBudget ?? ClipBudget.fallback,
              platformLabel: _platformDisplayName(shop?.platform ?? 'other'),
              kind: kind,
              // Đọc thẳng từ bản nhớ, không qua `selectedShop`: biến đó không
              // được làm mới sau khi lưu nên sheet mở lại sẽ hiện mức mặc
              // định thay vì con số vừa nhập.
              currentMb: _rememberedSizeCap(shopId, kind, 0) ~/ 1000000,
              onSelect: (bytes) async {
                final id = shopId.isEmpty ? (shop?.id ?? '') : shopId;
                assert(id.isNotEmpty, 'thiếu shopId khi lưu trần dung lượng');
                // Ghi nhớ rồi ĐÓNG NGAY, không chờ server.
                //
                // Bản trước chỉ đóng sheet trong nhánh thành công của
                // `updateShop`. Backend chưa nhận `max_image_bytes` /
                // `max_video_bytes` nên lời gọi ném lỗi, nhánh đó không bao
                // giờ chạy — bấm "Áp dụng" xong sheet đứng im, nhìn y như nút
                // hỏng.
                await _rememberSizeCap(id, kind, bytes);
                if (!c.mounted) return;
                c.pop();
                _toast(
                  c,
                  bytes <= 0
                      ? c.l10n.uploadSizeChanged(
                          c.l10n.uploadSizeValueUnlimited,
                        )
                      : c.l10n.uploadSizeChanged(
                          '${ClipBudget.megabytesLabel(bytes)} MB',
                        ),
                );
                // Đồng bộ ngầm: thành công thì server thành nguồn chuẩn, hỏng
                // thì bản nhớ tại chỗ vẫn giữ lựa chọn của người dùng.
                unawaited(
                  repo
                      .updateShop(
                        id,
                        maxImageBytes: kind == EcUploadKind.image
                            ? bytes
                            : null,
                        maxVideoBytes: kind == EcUploadKind.video
                            ? bytes
                            : null,
                      )
                      .then((updated) {
                        final current = _selected(selectedShop);
                        if (current?.id == updated.id) {
                          selectedShop.value = _shopFromDto(updated);
                        }
                      })
                      .catchError((Object _) {
                        // Xem trên: lựa chọn đã nằm trong bản nhớ tại chỗ.
                      }),
                );
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
        path: '/payment-history',
        builder: (c, s) => _PaymentHistoryRoute(repo: repo),
      ),
      GoRoute(
        path: '/claims',
        builder: (c, s) => _ClaimListRoute(
          shopId: _selected(selectedShop)?.id ?? '',
          onBack: () => _back(c, '/account'),
        ),
      ),
      GoRoute(
        path: '/claim-detail',
        builder: (c, s) {
          final extra = s.extra;
          final (shopId, dossierId) = extra is (String, String)
              ? extra
              : (_selected(selectedShop)?.id ?? '', '');
          return _ClaimDetailRoute(
            shopId: shopId,
            dossierId: dossierId,
            queue: queue,
            budget: _selected(selectedShop)?.clipBudget,
            onBack: () => _back(c, '/claims'),
          );
        },
      ),
      // Paywall mở thẳng, cho QA và cho ảnh chụp nộp App Review.
      //
      // Simulator không có StoreKit thật nên `offers()` trả rỗng và màn hình sẽ
      // hiện "chưa tải được bảng giá" — vô dụng để chụp ảnh. Route này rơi về
      // bảng giá mẫu khi cửa hàng im lặng, nên vẫn xem và chụp được.
      GoRoute(
        path: '/paywall',
        builder: (c, s) => _PaywallPreviewRoute(billing: _billing()),
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

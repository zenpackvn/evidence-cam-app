import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'data/ec_auth.dart';
import 'data/ec_models.dart' show OrderSummaryDto, QuotaDto;
import 'data/ec_repository.dart';
import 'data/ec_upload_queue.dart';
import 'data/ec_uploader.dart';
import 'screens/ec_flow1.dart';
// Show only what we use — ec_flow1 and ec_flow2 both define e.g. EcOrderRow.
import 'screens/ec_flow2.dart'
    show
        EcOrderTimelineScreen,
        EcTimelineDay,
        EcTimelineVideo,
        EcVideoDetail,
        EcVideoDetailScreen;
// ec_flow3 also declares an EcVideoType; we use ec_flow1's for ShopDetail.
import 'screens/ec_flow3.dart' hide EcVideoType;
import 'screens/ec_flow4.dart';
import 'screens/ec_record_route.dart';
import 'screens/ec_screens.dart';

/// EvidenceCam app shell — wires the pixel-perfect screens into the real
/// journey (Vào ca → 3 tab → tài khoản) with go_router. Presentational for now
/// (sample data, no backend); B1 swaps sample data + callbacks for auth/API.
class EcApp extends StatefulWidget {
  const EcApp({this.repo = const FakeEcRepository(), this.auth, super.key});

  /// Data source — [FakeEcRepository] by default; pass [RemoteEcRepository]
  /// (wrapping the typed API) once the Worker base URL is configured to go live.
  final EcRepository repo;

  /// Auth — [FakeEcAuth] by default; pass `FirebaseEcAuth` once the Firebase
  /// config files are present (FR-15).
  final EcAuth? auth;

  @override
  State<EcApp> createState() => _EcAppState();
}

class _EcAppState extends State<EcApp> {
  late final EcAuth _auth = widget.auth ?? FakeEcAuth();
  // Single source of truth for the selected interface language. The account tab
  // and language screen read/write this; `MaterialApp.locale` follows it.
  // ponytail: screen strings are still hardcoded Vietnamese — this switches the
  // locale + labels; full text translation waits on l10n of the flow screens.
  final ValueNotifier<EcAppLanguage> _language = ValueNotifier(EcAppLanguage.vi);

  // Offline upload queue for recorded clips. The uploader is live transport to
  // EC_API_URL when set; without it, clips persist and wait (no backend yet).
  late final EcUploadQueue _queue = EcUploadQueue(
    uploader: _apiUrl.isEmpty ? null : HttpEvidenceUploader(baseUrl: _apiUrl),
  );
  static const _apiUrl = String.fromEnvironment('EC_API_URL');

  late final GoRouter _router = _buildRouter(
    widget.repo,
    _auth,
    _language,
    _queue,
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<EcAppLanguage>(
      valueListenable: _language,
      builder: (context, language, _) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'ZenPack',
        locale: Locale(language == EcAppLanguage.vi ? 'vi' : 'en'),
        theme: AppTheme.light(),
        routerConfig: _router,
      ),
    );
  }
}

const _sampleShops = [
  EcShopSummary(
    name: 'Shop ABC',
    platform: 'shopee',
    meta: 'Shopee · 24 đơn hôm nay',
  ),
  EcShopSummary(
    name: 'Shop XYZ',
    platform: 'tiktok',
    meta: 'TikTok · 8 đơn hôm nay',
  ),
];

const _sampleMgmt = [
  EcShopMgmtEntry(name: 'Shop ABC', meta: 'Shopee · 3 thành viên'),
  EcShopMgmtEntry(name: 'Shop XYZ', meta: 'TikTok · 1 thành viên'),
];

const _sampleTimeline = [
  EcTimelineDay(
    date: 'Hôm nay, 24 Th7',
    videos: [
      EcTimelineVideo(
        time: '10:23',
        label: 'Đóng hàng đi',
        statusText: 'Đang tải 72%',
      ),
      EcTimelineVideo(time: '10:21', label: 'Đóng hàng đi'),
    ],
  ),
  EcTimelineDay(
    date: 'Hôm qua, 23 Th7',
    videos: [
      EcTimelineVideo(time: '16:40', label: 'Trả hàng'),
    ],
  ),
];

const _sampleVideoDetail = EcVideoDetail(
  title: 'Video đóng hàng',
  duration: '00:42',
  recordedAt: '24 Th7 · 10:23',
  recordedBy: 'Nguyễn Văn A',
  device: 'iPhone 13',
  uploadStatus: 'Đã tải lên',
);

const _sampleMembers = [
  EcShopMember(name: 'Nguyễn Văn A', role: 'Chủ tài khoản'),
  EcShopMember(name: 'Trần Thị B', role: 'Nhân viên'),
];

const _sampleShopVideoTypes = [
  EcVideoType(
    name: 'Đóng hàng',
    locked: true,
    icon: Icons.inventory_2_outlined,
  ),
  EcVideoType(
    name: 'Đơn vị vận chuyển',
    locked: true,
    icon: Icons.local_shipping_outlined,
  ),
  EcVideoType(
    name: 'Trả hàng',
    locked: true,
    icon: Icons.assignment_return_outlined,
  ),
  EcVideoType(name: 'Cân hàng', locked: false, icon: Icons.scale_outlined),
];

/// Login route — owns the email/password controllers and drives the auth seam
/// (FR-15). Email/Google/Apple all sign in through [EcAuth] then go to the shop
/// layer; today [FakeEcAuth] succeeds instantly, `FirebaseEcAuth` does it for real.
class _LoginRoute extends StatefulWidget {
  const _LoginRoute({required this.auth});

  final EcAuth auth;

  @override
  State<_LoginRoute> createState() => _LoginRouteState();
}

class _LoginRouteState extends State<_LoginRoute> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _afterSignIn(Future<void> signIn) {
    signIn.then((_) {
      if (mounted) context.go('/shops', extra: 'forward');
    });
  }

  @override
  Widget build(BuildContext context) => EcLoginScreen(
    emailController: _email,
    passwordController: _password,
    onLogin: () =>
        _afterSignIn(widget.auth.signInWithEmail(_email.text, _password.text)),
    onRegister: () => context.push('/register'),
    onForgot: () => context.push('/forgot'),
    onGoogle: () => _afterSignIn(widget.auth.signInWithGoogle()),
    onApple: () => _afterSignIn(widget.auth.signInWithApple()),
    onLanguage: () => _toast(context, 'Đổi ngôn ngữ'),
  );
}

/// Turns an auth failure into a user-facing line. [EcAuthException] carries its
/// own message; anything else (e.g. `FirebaseAuthException`) falls back to a
/// generic prefix so no action dead-ends silently.
String _authErrorText(Object error) {
  if (error is EcAuthException) return error.message;
  final message = error is Exception ? error.toString() : '$error';
  return 'Không thực hiện được: $message';
}

/// Account tab — reactive to the current user, selected language and quota, and
/// wires every row to the real seam (logout signs out, not just navigates).
class _AccountRoute extends StatefulWidget {
  const _AccountRoute({
    required this.auth,
    required this.repo,
    required this.language,
  });

  final EcAuth auth;
  final EcRepository repo;
  final ValueNotifier<EcAppLanguage> language;

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
      listenable: Listenable.merge([widget.auth.user, widget.language]),
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
            userName: user?.displayName ?? 'Chưa đặt tên',
            userEmail: user?.email ?? '—',
            planLabel: snap.hasData ? 'Pro ${snap.data!.cap}' : '—',
            languageLabel: language == EcAppLanguage.vi
                ? 'Tiếng Việt'
                : 'English',
            loginMethodsLabel: '$linkedCount liên kết',
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

/// Edit-profile — seeds the fields from the current user and persists name/phone
/// through the seam.
class _EditProfileRoute extends StatefulWidget {
  const _EditProfileRoute({required this.auth});

  final EcAuth auth;

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

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      _toast(context, 'Vui lòng nhập họ tên');
      return;
    }
    try {
      await widget.auth.updateProfile(name: name, phone: _phone.text.trim());
      if (!mounted) return;
      context.pop();
      _toast(context, 'Đã lưu thông tin');
    } on Object catch (error) {
      if (mounted) _toast(context, _authErrorText(error));
    }
  }

  @override
  Widget build(BuildContext context) => EcEditProfileScreen(
    nameController: _name,
    phoneController: _phone,
    email: widget.auth.currentUser?.email ?? '—',
    onBack: () => _back(context, '/account'),
    // ponytail: avatar upload needs image_picker + storage — wire when it lands.
    onChangeAvatar: () => _toast(context, 'Đổi ảnh đại diện — sắp ra mắt'),
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
      // ponytail: accounts without a password need a link/set-password flow
      // (linkWithCredential on an EmailAuthProvider) — not yet in the seam.
      _toast(context, 'Tài khoản Google/Apple — tạo mật khẩu sắp ra mắt');
      return;
    }
    if (_current.text.isEmpty) {
      _toast(context, 'Nhập mật khẩu hiện tại');
      return;
    }
    if (_next.text.length < 8) {
      _toast(context, 'Mật khẩu mới tối thiểu 8 ký tự');
      return;
    }
    if (_next.text != _confirm.text) {
      _toast(context, 'Mật khẩu nhập lại không khớp');
      return;
    }
    try {
      await widget.auth.updatePassword(
        currentPassword: _current.text,
        newPassword: _next.text,
      );
      if (!mounted) return;
      context.pop();
      _toast(context, 'Đã đổi mật khẩu');
    } on Object catch (error) {
      if (mounted) _toast(context, _authErrorText(error));
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
    } on Object catch (error) {
      if (context.mounted) _toast(context, _authErrorText(error));
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
          return const Scaffold(
            backgroundColor: BrandColors.bg,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final quota = snap.data!;
        return EcQuotaScreen(
          planLabel: 'Pro ${quota.cap}',
          usedVideos: quota.used,
          totalVideos: quota.cap,
          // ponytail: retention isn't in QuotaDto yet — keep the screen default
          // until the quota endpoint returns the plan's retention window.
          onBack: () => _back(context, '/account'),
          onUpgrade: () => _toast(context, 'Nâng cấp gói — sắp ra mắt'),
        );
      },
    );
  }
}

/// Presents a sheet/dialog screen as a modal OVER the previous screen: the
/// route is transparent (opaque:false) so the screen behind shows through a
/// dim barrier — matching the `.pen` where these screens sit on a dimmed
/// background, not a solid one.
/// Lightweight feedback so no button is a dead end: actions that don't (yet)
/// have a dedicated screen confirm they fired.
void _toast(BuildContext c, String msg) {
  ScaffoldMessenger.of(c)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(milliseconds: 1400),
      ),
    );
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

CustomTransitionPage<void> _modalPage(Widget child) =>
    CustomTransitionPage<void>(
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
      child: child,
    );

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
  },
  progressPercent: (task.progress * 100).round(),
  retryCount: task.retryCount,
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
) => GoRouter(
  // Override the start route for screenshot/QA via --dart-define=EC_START=/home.
  initialLocation: const String.fromEnvironment('EC_START', defaultValue: '/'),
  routes: [
    GoRoute(
      path: '/',
      builder: (c, s) => EcSplashScreen(onStart: () => c.go('/login')),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (c, s) => _directionalPage(s, _LoginRoute(auth: auth)),
    ),
    GoRoute(
      path: '/register',
      builder: (c, s) => EcRegisterScreen(
        onBack: () => _back(c, '/login'),
        onLogin: () => _back(c, '/login'),
        onRegister: () => c.go('/shops', extra: 'forward'),
        onGoogle: () => auth.signInWithGoogle().then((_) {
          if (c.mounted) c.go('/shops', extra: 'forward');
        }),
        onApple: () => auth.signInWithApple().then((_) {
          if (c.mounted) c.go('/shops', extra: 'forward');
        }),
        onLanguage: () => _toast(c, 'Đổi ngôn ngữ'),
        onViewPolicy: () => _toast(c, 'Điều khoản & Chính sách'),
      ),
    ),
    GoRoute(
      path: '/forgot',
      builder: (c, s) => EcForgotPasswordScreen(
        onBack: () => _back(c, '/login'),
        onLogin: () => _back(c, '/login'),
        onSend: () => _toast(c, 'Đã gửi link đặt lại mật khẩu'),
        onLanguage: () => _toast(c, 'Đổi ngôn ngữ'),
      ),
    ),
    GoRoute(
      path: '/shops',
      // /shops is entered forward from login and backward from the app; its
      // slide direction comes from the navigation's `extra` hint.
      pageBuilder: (c, s) => _directionalPage(
        s,
        EcChooseShopScreen(
          shops: _sampleShops,
          onSelect: (_) => c.go('/home'),
          onManage: () => c.push('/shop-mgmt'),
          onLogout: () => c.go('/login', extra: 'back'),
        ),
      ),
    ),
    GoRoute(
      path: '/shop-mgmt',
      builder: (c, s) => EcShopMgmtScreen(
        shops: _sampleMgmt,
        onBack: () => _back(c, '/shops'),
        onAddShop: () => c.push('/create-shop'),
        onShopTap: (_) => c.push('/shop-detail'),
      ),
    ),
    GoRoute(
      path: '/create-shop',
      builder: (c, s) => EcCreateShopScreen(
        onBack: () => _back(c, '/shop-mgmt'),
        // After creating a shop, return to the shop-management list.
        onCreate: () {
          _back(c, '/shop-mgmt');
          _toast(c, 'Đã tạo shop mới');
        },
        onPlatformSelected: (p) => _toast(c, 'Sàn: $p'),
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
              // once the Worker URL is set).
              builder: (c, s) => FutureBuilder<List<OrderSummaryDto>>(
                future: repo.orders('s1'),
                builder: (ctx, snap) {
                  if (!snap.hasData) {
                    return const Scaffold(
                      backgroundColor: BrandColors.bg,
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final orders = snap.data!
                      .map(
                        (o) => EcOrderRow(
                          code: o.tracking,
                          time: '—',
                          type: 'Đóng hàng',
                          videoCount: o.evidenceCount,
                        ),
                      )
                      .toList();
                  return EcHomeOrdersScreen(
                    shopName: 'Shop ABC',
                    orders: orders,
                    queueCount: 4,
                    onBack: () => c.go('/shops', extra: 'back'),
                    onNavRecord: () => c.go('/record'),
                    onNavAccount: () => c.go('/account'),
                    onQueueTap: () => c.push('/queue'),
                    onOrderTap: (_) => c.push('/order'),
                    onNavOrders: () {},
                    onScan: () => _toast(c, 'Quét mã vận đơn'),
                  );
                },
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/record',
              builder: (c, s) => EcRecordRoute(
                onBack: () => c.go('/home'),
                onRequestCode: () => c.push<String>('/manual'),
                onRequestType: () => c.push<String>('/type-sheet'),
                onNavOrders: () => c.go('/home'),
                onNavAccount: () => c.go('/account'),
                onSettings: () => c.push('/type-sheet'),
                onSaved: (path, code, type) {
                  queue.enqueue(tracking: code, type: type, filePath: path);
                  _toast(c, 'Đã lưu video — đưa vào hàng chờ tải');
                },
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/account',
              builder: (c, s) =>
                  _AccountRoute(auth: auth, repo: repo, language: language),
            ),
          ],
        ),
      ],
    ),
    // --- order detail + evidence (Flow 2) ---
    GoRoute(
      path: '/order',
      builder: (c, s) => EcOrderTimelineScreen(
        orderCode: 'SPXVN024567890',
        days: _sampleTimeline,
        pendingUploadCount: 1,
        dossierUrl: 'https://cdn.evidencecam.app/d/demo-token',
        onBack: () => _back(c, '/home'),
        onVideoTap: (_) => c.push('/video'),
        onVideoMenu: (_) => c.push('/video'),
        onCopyCode: () => _toast(c, 'Đã sao chép mã vận đơn'),
        onCopyLink: () => _toast(c, 'Đã sao chép link hồ sơ'),
        onShareLink: () => _toast(c, 'Chia sẻ link hồ sơ'),
        onRetryUpload: () => _toast(c, 'Đang thử tải lại…'),
        onAttachPhoto: () => _toast(c, 'Đính kèm ảnh vào đơn'),
      ),
    ),
    GoRoute(
      path: '/video',
      pageBuilder: (c, s) => _modalPage(
        EcVideoDetailScreen(
          video: _sampleVideoDetail,
          onClose: () => c.pop(),
          onPlay: () => _toast(c, 'Phát video'),
          onDownload: () => _toast(c, 'Đang tải video về máy'),
          onDelete: () {
            c.pop();
            _toast(c, 'Đã xóa video');
          },
        ),
      ),
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
      pageBuilder: (c, s) => _modalPage(
        EcTypeSheetScreen(
          onManageTypes: () => c.pop(),
          // Return the chosen type to the record route, which applies it to the
          // current/next recording.
          onSelectType: (t) => c.pop(t),
        ),
      ),
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
      path: '/recording',
      builder: (c, s) => EcRecording2Screen(
        onBack: () => c.go('/home'),
        onStop: () => c.go('/home'),
        onPickType: () => c.push('/type-sheet'),
        onSettings: () => c.push('/type-sheet'),
        onManualEntry: () => c.push('/manual'),
        onZoomIn: () => _toast(c, 'Phóng to'),
        onZoomOut: () => _toast(c, 'Thu nhỏ'),
        onFlipCamera: () => _toast(c, 'Đổi camera trước / sau'),
      ),
    ),
    GoRoute(
      path: '/near-limit',
      builder: (c, s) => EcNearLimitScreen(
        onBack: () => c.go('/home'),
        onStop: () => c.go('/home'),
        onPickType: () => c.push('/type-sheet'),
        onSettings: () => c.push('/type-sheet'),
        onManualEntry: () => c.push('/manual'),
        onZoomIn: () => _toast(c, 'Phóng to'),
        onZoomOut: () => _toast(c, 'Thu nhỏ'),
        onFlipCamera: () => _toast(c, 'Đổi camera trước / sau'),
      ),
    ),
    GoRoute(
      path: '/return-rec',
      builder: (c, s) => EcReturnRecScreen(
        onBack: () => c.go('/home'),
        onStop: () => c.go('/home'),
        onPickType: () => c.push('/type-sheet'),
        onSettings: () => c.push('/type-sheet'),
        onManualEntry: () => c.push('/manual'),
        onZoomIn: () => _toast(c, 'Phóng to'),
        onZoomOut: () => _toast(c, 'Thu nhỏ'),
        onFlipCamera: () => _toast(c, 'Đổi camera trước / sau'),
      ),
    ),
    GoRoute(
      path: '/cutover',
      builder: (c, s) => EcCutoverBScreen(
        onBack: () => c.go('/home'),
        onStop: () => c.go('/home'),
        onPickType: () => c.push('/type-sheet'),
        onSettings: () => c.push('/type-sheet'),
        onManualEntry: () => c.push('/manual'),
        onZoomIn: () => _toast(c, 'Phóng to'),
        onZoomOut: () => _toast(c, 'Thu nhỏ'),
        onFlipCamera: () => _toast(c, 'Đổi camera trước / sau'),
      ),
    ),
    GoRoute(
      path: '/no-match',
      pageBuilder: (c, s) => _modalPage(
        EcNoMatchScreen(
          onEnterManually: () => c.pop(),
          onCreateNew: () {
            c.pop();
            _toast(c, 'Tạo đơn mới từ mã hoàn');
          },
        ),
      ),
    ),
    // --- remaining shop-config screens (Flow 1) ---
    GoRoute(
      path: '/no-shop',
      builder: (c, s) => EcNoShopScreen(
        onCreate: () => c.push('/create-shop'),
        onInviteTap: () => _toast(c, 'Chờ lời mời vào shop'),
      ),
    ),
    GoRoute(
      path: '/shop-detail',
      builder: (c, s) => EcShopDetailScreen(
        shopName: 'Shop ABC',
        platformLabel: 'Shopee',
        members: _sampleMembers,
        videoTypes: _sampleShopVideoTypes,
        onBack: () => _back(c, '/shop-mgmt'),
        onMemberMore: (m) => c.push('/member-actions', extra: m),
        onInviteMember: () => c.push('/invite-member'),
        onTapResolution: () => c.push('/resolution'),
        onEditType: (_) => c.push('/create-type'),
        onDeleteType: (_) => c.push('/confirm-delete'),
        onAddType: () => c.push('/create-type'),
      ),
    ),
    GoRoute(
      path: '/create-type',
      pageBuilder: (c, s) => _modalPage(
        EcCreateTypeScreen(
          onCancel: () => c.pop(),
          onCreate: () {
            c.pop();
            _toast(c, 'Đã thêm loại video');
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
            c.pop();
            _toast(c, 'Đã xóa');
          },
        ),
      ),
    ),
    GoRoute(
      path: '/invite-member',
      pageBuilder: (c, s) => _modalPage(
        EcInviteMemberScreen(
          onCancel: () => c.pop(),
          onInvite: (role) {
            c.pop();
            _toast(c, 'Đã gửi lời mời ($role)');
          },
        ),
      ),
    ),
    GoRoute(
      path: '/member-actions',
      pageBuilder: (c, s) => _modalPage(
        EcMemberActionsScreen(
          member: s.extra is EcShopMember
              ? s.extra! as EcShopMember
              : _sampleMembers.first,
          onSetManager: () {
            c.pop();
            _toast(c, 'Đã đổi vai trò: Quản lý shop');
          },
          onSetStaff: () {
            c.pop();
            _toast(c, 'Đã đổi vai trò: Nhân viên');
          },
          onRemove: () {
            c.pop();
            _toast(c, 'Đã gỡ khỏi shop (video đã quay vẫn upload nốt)');
          },
        ),
      ),
    ),
    GoRoute(
      path: '/resolution',
      pageBuilder: (c, s) => _modalPage(
        EcResolutionSheetScreen(
          onSelect: (r) {
            c.pop();
            _toast(c, 'Độ phân giải: $r');
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
      builder: (c, s) => _EditProfileRoute(auth: auth),
    ),
    GoRoute(
      path: '/delete-account',
      pageBuilder: (c, s) => _modalPage(
        EcDeleteAccountScreen(
          // ponytail: pending shared-profile count needs a dossier endpoint —
          // 0 until it lands (was a hardcoded 2 in the mock warning).
          pendingSharedProfilesCount: 0,
          onCancel: () => c.pop(),
          onConfirmDelete: () async {
            try {
              await auth.deleteAccount();
              if (c.mounted) c.go('/login', extra: 'back');
            } on Object catch (error) {
              if (c.mounted) _toast(c, _authErrorText(error));
            }
          },
        ),
      ),
    ),
  ],
);

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math' as math;
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
import 'package:config/config.dart' show EnvConfig;
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
        EcSealLine,
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
        CupertinoTextField,
        CupertinoTextThemeData,
        CupertinoThemeData,
        showCupertinoDialog,
        showCupertinoModalPopup;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, ValueListenable, defaultTargetPlatform;
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';
import 'package:network/network.dart' show Dio, DioException, DioExceptionType;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sync_connectivity_plus/sync_connectivity_plus.dart';
import 'package:shared_contracts/shared_contracts.dart'
    show
        ClipBudget,
        kFixedImageBytes,
        EcClaimDossier,
        EcClaimEvidence,
        EcClaimOrder,
        kFixedClipSeconds;
import 'package:storage/storage.dart';

import 'app/di/injection.dart';
import 'core/data/ec_claim_store.dart';
import 'app/update_gate.dart';
import 'data/ec_purchases.dart';
import 'data/ec_uploader.dart';
import 'data/platform_device_conditions.dart';
import 'screens/ec_record_route.dart';
import 'screens/ec_scan_route.dart';
import 'screens/ec_trim_route.dart';

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
    required this.repo,
    required this.auth,
    this.evidenceStore,
    this.pickAvatarPath,
    this.shareService,
    this.videoPlayerService,
    this.downloadDio,
    super.key,
  });

  /// Data source — [RemoteEcRepository] in the app (see `buildRepository`);
  /// tests pass their own double. No default: the shell must never invent one.
  final EcRepository repo;

  /// Auth — `FirebaseEcAuth` in the app (FR-15); tests pass their own double.
  final EcAuth auth;

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
  late final EcAuth _auth = widget.auth;
  // Single source of truth for the selected interface language. The account tab
  // and language screen read/write this; `CupertinoApp.locale` follows it and
  // `AppLocalizations` renders `context.l10n.*` in the chosen language.
  //
  // Initial value follows the device system language (English → en, anything
  // else → vi, the primary market). The picker overrides it for the session.
  /// Ngôn ngữ đang dùng. Khởi tạo từ lựa chọn đã lưu, rơi về ngôn ngữ máy khi
  /// người dùng chưa chọn bao giờ — trước đây chỉ sống trong phiên nên thoát
  /// app là mất, người dùng phải chọn lại mỗi lần mở.
  late final ValueNotifier<EcAppLanguage> _language =
      ValueNotifier(_savedLanguage() ?? _systemLanguage())
        ..addListener(_persistLanguage)
        // Đổi ngôn ngữ giao diện là đổi luôn giọng đọc. Để lệch nhau thì màn
        // hình một thứ tiếng còn cái loa nói thứ tiếng khác.
        ..addListener(_applyVoiceLanguage);

  static const _languagePrefKey = 'app.language';

  static EcAppLanguage? _savedLanguage() {
    final saved = _appMemory()?.getString(_languagePrefKey);
    return saved == null ? null : EcAppLanguage.byCode(saved);
  }

  void _persistLanguage() => unawaited(
    _appMemory()?.setString(_languagePrefKey, _language.value.code),
  );

  void _applyVoiceLanguage() =>
      unawaited(_voiceAnnouncer.useLanguage(_language.value.voiceTag));

  /// Ngôn ngữ máy, nếu app có bản dịch cho nó — không thì tiếng Việt.
  ///
  /// Rơi về tiếng Việt chứ không phải tiếng Anh: thị trường đầu tiên là Việt
  /// Nam, và người bán ở đây mở app lần đầu mà thấy tiếng Anh là một rào cản
  /// không cần thiết.
  static EcAppLanguage _systemLanguage() =>
      EcAppLanguage.byCode(
        WidgetsBinding.instance.platformDispatcher.locale.languageCode,
      ) ??
      EcAppLanguage.vi;

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
    // Hàng đợi đổi → khai lại số clip đang kẹt trên máy này. Có giãn cách bên
    // trong [_reportQueueDepth]: mỗi phần trăm tiến độ upload cũng bắn một lượt
    // notify, và bắn một request theo từng phần trăm là điên rồ.
    _queue.addListener(_onQueueChangedForReporting);
    // Phiên mua hàng bám theo người đang đăng nhập. Nghe ở MỘT chỗ thay vì vá
    // từng lối đăng nhập/đăng xuất: thiếu sót một lối là người sau mua gói lại
    // được cộng ngày cho tài khoản trước — RevenueCat vẫn giữ app_user_id cũ.
    _auth.user.addListener(_syncPurchaseIdentity);
    _syncPurchaseIdentity();
    // Paywall của RevenueCat đọc ngôn ngữ MÁY chứ không đọc ngôn ngữ app. Nghe
    // ở một chỗ vì cùng lý do với dòng trên: có hai lối đổi ngôn ngữ (nút gạt ở
    // màn tài khoản và màn /language), vá từng lối là sớm muộn sót một lối.
    _language.addListener(_syncPurchaseLocale);
    _syncPurchaseLocale();
    // Máy dựng trên bàn đóng hàng, người quay không chạm vào suốt cả ca — để
    // màn tự tắt là camera preview ngủ theo và phiên quay đứt giữa chừng.
    unawaited(WakelockPlus.enable().catchError((_) {}));
    // Giọng đọc theo ngôn ngữ đã lưu, ngay từ lần mở app đầu tiên chứ không
    // phải chỉ khi người dùng đổi ngôn ngữ.
    _applyVoiceLanguage();
    _listenForNetwork();
  }

  StreamSubscription<List<ConnectivityResult>>? _networkWatch;

  /// Có mạng trở lại thì chạy lại hàng đợi upload.
  ///
  /// Hàng đợi không tự biết lúc nào có mạng: nó chỉ chạy khi mở app, khi có
  /// clip mới, hoặc khi người dùng bấm thử lại. Mất sóng giữa ca rồi có lại mà
  /// người bán đã ngừng quay thì clip nằm im tới lần mở app sau — trong khi
  /// chúng chỉ tồn tại trên đúng cái điện thoại đó.
  ///
  /// Nuốt lỗi: máy không trả lời sự kiện mạng thì rơi về hành vi cũ, không
  /// được làm hỏng lúc khởi động.
  void _listenForNetwork() {
    try {
      _networkWatch = Connectivity().onConnectivityChanged.listen((results) {
        final online =
            results.isNotEmpty &&
            results.any((r) => r != ConnectivityResult.none);
        if (online) unawaited(_queue.kick());
      });
    } on Object {
      // Không nghe được thì thôi.
    }
  }

  /// Gắn/gỡ phiên RevenueCat theo tài khoản đang đăng nhập.
  ///
  /// `app_user_id` phải bằng Firebase uid — backend tra tài khoản bằng đúng giá
  /// trị đó khi webhook tới, và uid lạ thì event bị bỏ qua, tức người dùng trả
  /// tiền mà không ai được cộng ngày.
  void _syncPurchaseIdentity() {
    final uid = _auth.user.value?.uid;
    unawaited(
      (uid == null ? EcPurchases.logOut() : EcPurchases.logIn(uid)).catchError(
        (_) {},
      ),
    );
  }

  void _syncPurchaseLocale() {
    unawaited(
      EcPurchases.setUiLocale(
        _language.value == EcAppLanguage.en ? 'en' : 'vi',
      ).catchError((_) {}),
    );
  }

  /// App quay lại foreground.
  ///
  /// Hai việc, cùng một lý do: trong lúc app ngủ, chủ shop có thể đã mua thêm
  /// lượt trên web, hoặc đã sang tháng mới. Không có tín hiệu nào từ máy chủ
  /// báo cho máy này biết, nên đây là dịp tự nhiên nhất để thử lại những clip
  /// đang đỗ vì hết hạn mức — và để khai lại con số cho chủ shop.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state != AppLifecycleState.resumed) return;
    unawaited(_queue.retryQuotaWaiting());
    _reportQueueDepth(force: true);
  }

  DateTime? _lastDepthReport;
  int? _lastDepthReported;

  void _onQueueChangedForReporting() => _reportQueueDepth();

  /// Khai số clip còn kẹt lên máy chủ.
  ///
  /// Giãn cách 30 giây VÀ chỉ gửi khi con số thật sự đổi: hàng đợi bắn notify
  /// theo từng phần trăm tiến độ upload, nên gửi theo mỗi lần notify là hàng
  /// trăm request cho một clip.
  ///
  /// Số 0 vẫn phải gửi — đó là cách chủ shop biết cảnh báo đã tắt.
  void _reportQueueDepth({bool force = false}) {
    final shopId = _selectedShop.value?.id;
    if (shopId == null || shopId.isEmpty) return;
    final pending = _queue.strandedCount;
    final now = DateTime.now();
    final last = _lastDepthReport;
    final unchanged = _lastDepthReported == pending;
    final tooSoon = last != null && now.difference(last).inSeconds < 30;
    if (!force && (unchanged || tooSoon)) return;
    _lastDepthReport = now;
    _lastDepthReported = pending;
    unawaited(
      widget.repo.reportQueueDepth(
        shopId,
        pending: pending,
        pendingBytes: _queue.strandedBytes,
        oldestAt: _queue.strandedOldestAt?.millisecondsSinceEpoch,
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_networkWatch?.cancel());
    WidgetsBinding.instance.removeObserver(this);
    _queue.removeListener(_onQueueChangedForReporting);
    _auth.user.removeListener(_syncPurchaseIdentity);
    unawaited(WakelockPlus.disable().catchError((_) {}));
    _router.dispose();
    _language
      ..removeListener(_persistLanguage)
      ..removeListener(_syncPurchaseLocale)
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
        locale: Locale(language.code),
        supportedLocales: [
          for (final language in EcAppLanguage.values) Locale(language.code),
        ],
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
            // Chỉ ĐẶT kiểu chữ NỀN thôi là chưa đủ trên Android.
            //
            // Mọi `Text` không khai kiểu riêng đều thừa hưởng dòng trên nên ra
            // Inter ở cả hai nền. Nhưng các ô còn lại của bộ chữ Cupertino —
            // tiêu đề thanh điều hướng, nút trong hộp thoại — giữ mặc định của
            // Flutter, và mặc định ấy là mặt chữ hệ thống của Apple: iOS ra SF
            // Pro, Android không có nên rơi về Roboto. Roboto rộng hơn và thấp
            // hơn Inter, nên nguyên hàng nút "Huỷ / Đồng ý" trong ~14 hộp thoại
            // của app nhìn lệch hẳn so với phần còn lại của màn.
            //
            // Ép Inter cho những ô ấy, CHỈ trên Android: trên iOS mặc định
            // đang đúng và không có lý do đụng vào. Cỡ và độ đậm chép nguyên
            // của Cupertino để chỉ mặt chữ đổi, không đổi gì khác.
            navTitleTextStyle: _androidOnly(
              GoogleFonts.inter(
                color: BrandColors.ink,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            navLargeTitleTextStyle: _androidOnly(
              GoogleFonts.inter(
                color: BrandColors.ink,
                fontSize: 34,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.41,
              ),
            ),
            navActionTextStyle: _androidOnly(
              GoogleFonts.inter(color: BrandColors.dark, fontSize: 17),
            ),
            actionTextStyle: _androidOnly(
              GoogleFonts.inter(color: BrandColors.dark, fontSize: 17),
            ),
            tabLabelTextStyle: _androidOnly(
              GoogleFonts.inter(fontSize: 10, letterSpacing: -0.24),
            ),
          ),
        ),
        routerConfig: _router,
        // Chạm ra ngoài ô đang nhập là ẩn bàn phím, ở mọi màn.
        //
        // Cỡ chữ CỐ ĐỊNH, không theo cài đặt phóng chữ của hệ điều hành.
        //
        // Mọi cỡ trong bộ giao diện là số tuyệt đối, và hàng nào cũng
        // `softWrap: false` + ellipsis — phóng lên là chữ bị cắt chứ không
        // xuống dòng, nên "to hơn" không đọc được nhiều hơn. Android cho
        // phóng tới 1.8x còn iOS dừng sớm hơn, nên để mặc kệ thì cùng một màn
        // hiện ra hai kiểu trên hai máy.
        builder: (context, child) => MediaQuery.withNoTextScaling(
          child: _AndroidSafeAreaFloor(
            child: PopScope(
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
                // inside the localization delegates so its labels are
                // translated.
                child: UpdateGate(child: child ?? const SizedBox.shrink()),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// [style] trên Android, `null` ở nơi khác — `null` nghĩa là "giữ mặc định".
///
/// Dùng để vá riêng Android trong bộ chữ Cupertino mà không đổi một pixel nào
/// trên iOS.
TextStyle? _androidOnly(TextStyle style) => Platform.isAndroid ? style : null;

/// Sàn lề an toàn cho Android, để bố cục thở giống iOS.
///
/// App ẩn hẳn thanh trạng thái lẫn thanh điều hướng trên Android
/// (`immersiveSticky`, xem `main.dart`), nên `MediaQuery.padding` tụt về gần 0.
/// iPhone thì luôn còn lề của tai thỏ và thanh home dù có ẩn gì đi nữa — mà bộ
/// giao diện lấy đúng hai con số ấy để dựng chiều cao header (`PenBox`) và đáy
/// sheet. Cùng một màn vì thế ra hai kiểu: iOS thoáng, Android dính sát mép.
///
/// Đặt SÀN chứ không cộng thêm: máy Android nào có lề thật lớn hơn (tai thỏ
/// rộng, thanh điều hướng luôn hiện) thì giữ nguyên lề thật của nó. Trên iOS
/// widget này trả thẳng `child`, không đụng gì.
class _AndroidSafeAreaFloor extends StatelessWidget {
  const _AndroidSafeAreaFloor({required this.child});

  /// Lề an toàn của iPhone có tai thỏ — mốc mà bộ giao diện được vẽ theo.
  static const _top = 47.0;

  /// Đáy lấy ÍT hơn iPhone, cố ý.
  ///
  /// 34 điểm của iPhone là chỗ dành cho thanh home indicator — một vạch có
  /// thật, luôn nằm đó. Android ở đây ẩn hết thanh hệ thống nên khoảng ấy trống
  /// trơn, và thanh tab bị đẩy lên cao đọc ra như lửng lơ giữa màn. 16 đủ để
  /// nhãn không dính mép dưới mà không chừa ra một dải trống vô nghĩa.
  static const _bottom = 16.0;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) return child;
    final data = MediaQuery.of(context);
    return MediaQuery(
      data: data.copyWith(
        padding: data.padding.copyWith(
          top: math.max(data.padding.top, _top),
          bottom: math.max(data.padding.bottom, _bottom),
        ),
        // `viewPadding` phải đi cùng: đáy sheet đo bằng nó, không bằng
        // `padding` (xem `_bottomInset` trong pen_kit).
        viewPadding: data.viewPadding.copyWith(
          top: math.max(data.viewPadding.top, _top),
          bottom: math.max(data.viewPadding.bottom, _bottom),
        ),
      ),
      child: child,
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
/// layer; `FirebaseEcAuth` is what the app binds, tests bind their own double.
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
  // Hỏi lại khi: quay về từ trang quota (gói có thể vừa đổi) HOẶC vừa có clip
  // lên máy chủ xong (số video đã dùng vừa tăng).
  //
  // Vế thứ hai là thứ bị thiếu tới 2026-08-08: `_quota` chụp một lần lúc dựng
  // màn, nên quay xong 20 clip mà con số trên màn vẫn y nguyên cả phiên — đúng
  // cái người dùng mô tả là "dùng rồi mà không trừ".
  late Future<QuotaDto> _quota = _fetchQuota();

  Future<QuotaDto> _fetchQuota() =>
      widget.repo.quota(shopId: widget.selectedShop.value?.id);

  /// Tên + ảnh đại diện đọc từ D1 (`GET /api/me`), KHÔNG từ hồ sơ Firebase:
  /// bảng điều khiển web chỉ ghi vào D1, nên đọc Firebase là màn này đứng yên
  /// trong khi người dùng đã đổi tên trên web từ đời nào.
  AccountDto? _account;

  Future<void> _loadAccount() async {
    try {
      final account = await widget.repo.account();
      if (mounted) setState(() => _account = account);
    } on Object {
      // Mất mạng thì giữ nguyên giá trị Firebase đang hiện — màn Tài khoản
      // không được trắng chỉ vì một lời gọi hỏng.
    }
  }

  void _refreshQuota() {
    if (!mounted) return;
    // Thân KHỐI, không phải mũi tên: `() => _quota = _fetchQuota()` trả về
    // chính giá trị vừa gán — một `Future` — và `setState` có assertion chặn
    // đúng trường hợp đó ("callback argument returned a Future"), vì một
    // callback async thì thân nó chạy SAU khi khung đã dựng xong.
    //
    // Ở đây việc gán là đồng bộ, chỉ có kiểu trả về là sai. Nhưng assertion vẫn
    // bật và làm hỏng màn Tài khoản mỗi lần quota được làm mới.
    setState(() {
      _quota = _fetchQuota();
    });
  }

  /// Mở paywall IAP thẳng từ màn cài đặt — giống hệt nút ở màn Quota.
  ///
  /// Tách khỏi màn Quota vì đó là màn BÁO CÁO: người muốn đổi gói không nên
  /// phải đi qua một bảng số liệu mới thấy chỗ mua.
  ///
  /// Mua xong KHÔNG tự bật gói: biên nhận trên máy có thể bị giả hoặc phát
  /// lại, hạn dùng do webhook RevenueCat → backend chốt. Hàng đợi cũng được đá
  /// một cái vì clip đang đỗ do hết hạn mức phải tự đi tiếp.
  Future<void> _openPaywall() async {
    final purchased = await EcPurchases.presentPaywall();
    if (!purchased || !mounted) return;
    unawaited(widget.queue.retryQuotaWaiting());
    _refreshQuota();
  }

  @override
  void initState() {
    super.initState();
    widget.queue.uploadsCompleted.addListener(_refreshQuota);
    unawaited(_loadAccount());
  }

  @override
  void dispose() {
    widget.queue.uploadsCompleted.removeListener(_refreshQuota);
    super.dispose();
  }

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
            userName:
                _account?.name ??
                user?.displayName ??
                context.l10n.accountNoName,
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
            // Bản trên máy CHỈ còn khi ảnh chưa tải lên được (xem
            // `_forgetAvatar`), nên nó không thể che mất ảnh mới đổi từ web.
            // Tải lên xong thì URL trong D1 là nguồn duy nhất cho cả hai bên.
            avatarPath:
                _rememberedAvatar(user?.uid) ??
                _account?.avatarUrl ??
                user?.photoUrl,
            onBack: () => _back(context, '/shops'),
            onFacebook: () => _openSupport(context, _kSupportFacebook),
            onZalo: () => _openSupport(context, _kSupportZalo),
            onCall: () => _openSupport(context, _kSupportPhone),
            onFeedback: () => _showFeedbackSheet(context),
            onRateApp: () => _openSupport(context, _kStoreListing),
            onProfileTap: () async {
              await context.push('/edit-profile');
              if (mounted) await _loadAccount();
            },
            onQuotaTap: () async {
              await context.push('/quota');
              if (!mounted) return;
              // Thân khối, KHÔNG phải arrow: closure của setState mà trả về
              // Future thì Flutter ném assertion và bỏ luôn lượt dựng lại.
              _refreshQuota();
            },
            // Không có khoá RevenueCat, hoặc không phải chủ shop → `null` →
            // hàng "Đổi gói" không hiện. Nút bấm vào không mở được gì còn tệ
            // hơn là không có nút.
            onChangePlanTap:
                EcPurchases.isAvailable && (snap.data?.canManagePlan ?? false)
                ? _openPaywall
                : null,
            onLanguageTap: () => context.push('/language'),
            onEndQrTap: () => _showEndSessionQr(
              context,
              share: _maybeGetIt<ShareService>(),
              gallery: _maybeGetIt<GallerySaveService>(),
            ),
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

  /// Ảnh đại diện đang nằm trên máy chủ (`accounts.avatar_url`) — chung với
  /// web. Chỉ dùng để hiện khi chưa có ảnh mới chọn.
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _avatarPath = _rememberedAvatar(widget.auth.currentUser?.uid);
    unawaited(_loadProfile());
  }

  // Hồ sơ thật nằm ở D1 — web sửa tên/ảnh chỉ ghi vào đó, còn SĐT thì Firebase
  // Auth không giữ (xem `_accountNeedsPhone` ở trên). Giá trị seed từ
  // `auth.currentUser` chỉ là chỗ đứng tạm cho tới khi lời gọi này về.
  Future<void> _loadProfile() async {
    final nameSeed = _name.text;
    final phoneSeed = _phone.text;
    try {
      final account = await widget.repo.account();
      if (!mounted) return;
      final name = account.name;
      // Người dùng gõ trong lúc chờ thì bản họ gõ thắng — đừng giật chữ khỏi
      // tay họ.
      if (name != null && name.isNotEmpty && _name.text == nameSeed) {
        _name.text = name;
      }
      final phone = account.phone;
      if (phone != null && phone.isNotEmpty && _phone.text == phoneSeed) {
        _phone.text = phone;
      }
      // Giữ RIÊNG khỏi `_avatarPath`: đường dẫn tệp là thứ phải tải lên, còn
      // URL này là thứ đã ở trên máy chủ rồi. Trộn hai thứ vào một biến là lại
      // đi tải lên chính cái ảnh vừa tải về.
      setState(() => _avatarUrl = account.avatarUrl);
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

      // Tải ảnh lên rồi ghi URL công khai vào hồ sơ — nhờ vậy ảnh theo tài
      // khoản, đăng nhập máy nào (kể cả web) cũng có. Tải hỏng (mất mạng, ảnh
      // quá nặng) thì tên và SĐT vẫn lưu được và ảnh vẫn hiện từ bản trên máy —
      // nhưng PHẢI báo. Bản trước nuốt im lặng, nên suốt thời gian endpoint
      // không tồn tại không ai biết ảnh chưa bao giờ tới máy chủ.
      String? avatarUrl;
      String? avatarError;
      if (avatarPath != null) {
        try {
          avatarUrl = await widget.repo.uploadAvatar(avatarPath);
          // Máy chủ đã có ảnh → quên bản trên máy, nếu không nó sẽ che mất ảnh
          // mà người dùng đổi ở bên web (bản trên máy được ưu tiên khi hiện).
          await _forgetAvatar(widget.auth.currentUser?.uid);
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
      // CHỈ ghi URL công khai. Bản trước rơi về `avatarPath` khi tải hỏng, tức
      // ghi một đường dẫn tệp trên máy vào hồ sơ dùng chung — web đọc phải nó
      // thì hiện ảnh vỡ.
      await widget.repo.updateProfile(
        name: name,
        phone: phone,
        avatarUrl: avatarUrl,
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
    avatarPath: _avatarPath ?? _avatarUrl,
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
///
/// **Mua được, nhưng chỉ bằng IAP.** Nút "Nâng cấp gói" mở paywall dựng sẵn của
/// RevenueCat, tức đi qua cửa hàng Apple/Google — đúng cách mà Guideline 3.1.1
/// yêu cầu với nội dung số.
///
/// Ranh giới KHÔNG đổi: app vẫn tuyệt đối không nói mua ở đâu khác. Không một
/// dòng chữ, không một đường dẫn sang zenpack.vn. Cấm dẫn ra ngoài vẫn nguyên
/// giá trị kể cả khi bên cạnh đã có nút IAP hợp lệ.
///
/// Mua xong màn này KHÔNG tự bật gói — nó hỏi lại backend. Biên nhận trên máy
/// có thể bị giả hoặc phát lại; hạn dùng do webhook RevenueCat → backend chốt.
class _QuotaRoute extends StatefulWidget {
  const _QuotaRoute({required this.repo, required this.queue, this.shopId});

  final EcRepository repo;
  final EcUploadQueue queue;

  /// Shop đang chọn. Gói cước gắn với tài khoản CHỦ shop, nên phải hỏi theo
  /// shop thì quản lý/nhân viên mới thấy đúng gói đang chi phối ca làm của họ.
  final String? shopId;

  @override
  State<_QuotaRoute> createState() => _QuotaRouteState();
}

class _QuotaRouteState extends State<_QuotaRoute> {
  late Future<QuotaDto> _quota = widget.repo.quota(shopId: widget.shopId);

  // Màn này mở suốt trong lúc hàng đợi vẫn đang đẩy clip lên — số trên màn
  // phải chạy theo, không thì nó chỉ đúng ở đúng giây vừa mở.
  @override
  void initState() {
    super.initState();
    widget.queue.uploadsCompleted.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.queue.uploadsCompleted.removeListener(_refresh);
    super.dispose();
  }

  /// Mở paywall IAP, rồi hỏi lại backend.
  ///
  /// Chỉ `_refresh()` khi paywall báo đã mua — nhưng KHÔNG tin con số ngay lập
  /// tức: webhook RevenueCat → backend chạy bất đồng bộ, nên lần hỏi đầu có thể
  /// vẫn ra gói cũ. Hàng đợi cũng được đá một cái: clip đang đỗ vì hết hạn mức
  /// phải tự đi tiếp khi vừa có thêm chỗ, đó là lý do người dùng vừa trả tiền.
  Future<void> _openPaywall() async {
    final purchased = await EcPurchases.presentPaywall();
    if (!purchased || !mounted) return;
    unawaited(widget.queue.retryQuotaWaiting());
    _refresh();
  }

  void _refresh() {
    if (!mounted) return;
    setState(() => _quota = widget.repo.quota(shopId: widget.shopId));
  }

  /// Groups this shop's clips by [UploadTask.type], summing each clip's
  /// on-disk file size. Sorted largest-first so the breakdown (and its
  /// stacked bar) read biggest-type-first, matching the reference design.
  List<EcQuotaTypeUsage> _localTypeUsage() {
    final byType = <String, int>{};
    for (final task in widget.queue.tasks) {
      if (task.shopId != widget.shopId) continue;
      byType[task.type] = (byType[task.type] ?? 0) + 1;
    }
    final usage = [
      for (final entry in byType.entries)
        EcQuotaTypeUsage(type: entry.key, videoCount: entry.value),
    ]..sort((a, b) => b.videoCount.compareTo(a.videoCount));
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
                  EcQuotaTypeUsage(type: t.type, videoCount: t.videoCount),
              ]
            : _localTypeUsage();
        return EcQuotaScreen(
          planLabel: _planDisplayName(context.l10n, quota.planCode),
          // Số của SERVER, không phải tổng các clip còn nằm trên máy: hàng
          // đợi chỉ còn clip CHƯA upload xong, nên cộng nó lại thì quay thêm
          // bao nhiêu con số vẫn đứng yên — trong khi đây đúng là con số người
          // bán đem so với hạn mức gói.
          usedVideos: quota.usedVideos,
          capVideos: quota.capVideos,
          remainingVideos: quota.remainingVideos,
          topupVideos: quota.topupVideos,
          blockAtVideos: quota.blockAtVideos,
          blocked: quota.blocked,
          retentionTotalDays: quota.retentionDays,
          typeUsage: typeUsage,
          // `canManagePlan` gác nút mua (chỉ chủ shop) VÀ quyết định câu giải
          // thích khi hết hạn mức — nhân viên được bảo đi hỏi chủ shop.
          canManagePlan: quota.canManagePlan,
          // Không có khoá RevenueCat trong build này → `null` → không hiện nút.
          onUpgrade: EcPurchases.isAvailable ? _openPaywall : null,
          onBack: () => _back(context, '/account'),
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

/// Màn "Kho lưu trữ": đọc trạng thái, rồi cho chủ shop kiểm tra lại / gỡ kho.
///
/// Cắm kho mới đi qua một màn riêng (`/storage-connect`) vì nó là một form năm
/// ô — nhét vào đây thì màn này vừa là bảng tình trạng vừa là biểu mẫu, và mỗi
/// lần đọc lại trạng thái là mất chữ người dùng đang gõ dở.
class _StorageRoute extends StatefulWidget {
  const _StorageRoute({
    required this.repo,
    required this.shopId,
    this.canManage = false,
    this.onBack,
  });

  final EcRepository repo;
  final String shopId;

  /// Actor có phải chủ shop không. Quyết định có chào nút đổi kho hay không —
  /// máy chủ vẫn là hàng rào thật (`owner_only`), đây chỉ là không mời bấm vào
  /// một cái nút chắc chắn 403.
  final bool canManage;
  final VoidCallback? onBack;

  @override
  State<_StorageRoute> createState() => _StorageRouteState();
}

class _StorageRouteState extends State<_StorageRoute>
    with WidgetsBindingObserver {
  late Future<StorageStateDto> _state = widget.repo.storage(widget.shopId);
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Cấp quyền Google Drive xảy ra Ở TRÌNH DUYỆT, ngoài app — và `launchUrl`
  /// trả về ngay khi trình duyệt mở, KHÔNG đợi người dùng bấm xong. Nên "app
  /// sáng lại" là tín hiệu duy nhất có thật để đọc lại trạng thái.
  ///
  /// Thiếu nó thì cắm kho thành công mà màn hình vẫn ghi "kho hệ thống" cho tới
  /// khi người dùng tự thoát ra vào lại — trông y hệt một lần cắm thất bại, và
  /// người ta sẽ bấm cắm lại.
  ///
  /// Đọc lại ở MỌI lần sáng chứ không chỉ sau khi bấm cắm: kho còn đổi được từ
  /// web, và một lượt đọc thừa rẻ hơn nhiều so với một bảng tình trạng nói dối.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && mounted) _reload();
  }

  /// Thân hàm có NGOẶC, không phải mũi tên: `setState(() => _state = future)`
  /// trả về chính cái Future đó, và Flutter chặn cứng "setState() callback
  /// argument returned a Future". Lỗi này nằm sẵn ở đây từ trước, chỉ chưa ai
  /// gọi `_reload()` trong test nên nó chưa bao giờ nổ.
  void _reload() {
    setState(() {
      _state = widget.repo.storage(widget.shopId);
    });
  }

  /// Chạy một thao tác mạng, khoá nút trong lúc chạy, rồi đọc lại trạng thái.
  ///
  /// Đọc lại ở `finally` chứ không chỉ khi thành công: một lượt "kiểm tra lại"
  /// hỏng cũng đổi `last_error` phía máy chủ, và đó chính là câu người dùng
  /// cần đọc.
  Future<void> _run(Future<void> Function() action, String okMessage) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) _toast(context, okMessage);
    } on Object catch (error) {
      if (mounted) _toast(context, _dataErrorText(context.l10n, error));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        _reload();
      }
    }
  }

  Future<void> _disconnect() async {
    final l10n = context.l10n;
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(l10n.storageDisconnect),
        content: Text(l10n.storageDisconnectConfirm),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.storageDisconnect),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _run(
      () => widget.repo.disconnectStorage(widget.shopId),
      l10n.storageDisconnected,
    );
  }

  /// Google Drive cắm qua OAuth nên phải rời app sang trình duyệt.
  ///
  /// KHÔNG đọc lại trạng thái ở đây: `launchUrl` trả về ngay lúc trình duyệt
  /// mở, tức lúc người dùng còn chưa kịp chọn tài khoản Google. Việc đọc lại
  /// thuộc về [didChangeAppLifecycleState].
  Future<void> _connectDrive() async {
    try {
      final url = await widget.repo.gdriveAuthUrl(widget.shopId);
      if (!mounted) return;
      if (url.isEmpty) {
        _toast(context, context.l10n.supportOpenFailed);
        return;
      }
      await _openSupport(context, url);
    } on Object catch (error) {
      if (mounted) _toast(context, _dataErrorText(context.l10n, error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StorageStateDto>(
      future: _state,
      builder: (context, snap) {
        if (snap.hasError) {
          return _RouteLoadError(
            title: context.l10n.storageTitle,
            detail: _dataErrorText(context.l10n, snap.error!),
            onRetry: _reload,
          );
        }
        if (!snap.hasData) {
          return const CupertinoPageScaffold(
            backgroundColor: BrandColors.bg,
            child: Center(child: CupertinoActivityIndicator()),
          );
        }
        final dto = snap.data!;
        final view = dto.storage;
        // Máy chủ vừa nói kho thật là gì; nếu nó đổi so với lần đọc trước thì
        // lựa chọn đã nhớ bám theo. Chạy ở nền, không chặn lượt dựng này.
        unawaited(_syncStoragePick(widget.shopId, dto.kind));
        final displayed = _displayedStorageKind(widget.shopId, dto.kind);
        return EcStorageScreen(
          busy: _busy,
          onBack: widget.onBack,
          onPick: (kind) => unawaited(
            _rememberStoragePick(widget.shopId, switch (kind) {
              EcStorageKind.system => StorageKind.system,
              EcStorageKind.s3 => StorageKind.s3,
              EcStorageKind.gdrive => StorageKind.gdrive,
            }),
          ),
          state: EcStorageState(
            // Dấu tích đặt theo lựa chọn đã nhớ, không theo kho thật: người
            // dùng bấm chọn xong, thoát ra vào lại thì phải thấy đúng thứ
            // mình đã chọn.
            kind: switch (displayed) {
              StorageKind.system => EcStorageKind.system,
              StorageKind.s3 => EcStorageKind.s3,
              StorageKind.gdrive => EcStorageKind.gdrive,
            },
            label: view?.label ?? '',
            ok: view?.ok ?? true,
            lastError: view?.lastError,
            // Cờ thử nghiệm mở hai thẻ kho riêng để đi được vào luồng cắm kho.
            // Máy chủ vẫn chặn lượt LƯU nếu gói thật chưa mở — xem [_kForcedPlan].
            byosAllowed: dto.byosAllowed || _planOverrideOn,
            // `byos_allowed` nói về GÓI, không nói về vai trò. Chủ shop là
            // người duy nhất đổi được kho, và máy chủ trả `owner_only` cho mọi
            // ai khác — nên nút chỉ hiện khi cả hai điều kiện đều đúng.
            canManage: widget.canManage,
            presignedDownload: view?.capabilities?.presignedDownload ?? true,
            objectLock: view?.capabilities?.objectLock ?? false,
            health: EcStorageHealth(
              total: dto.health.total,
              intact: dto.health.intact,
              unreachable: dto.health.unreachable,
              mismatched: dto.health.mismatched,
              pendingRelay: dto.health.pendingRelay,
            ),
          ),
          onTest: () => _run(
            () => widget.repo.testStorage(widget.shopId),
            context.l10n.storageTestOk,
          ),
          onDisconnect: _disconnect,
          onConnectDrive: _connectDrive,
          onConnectS3: () => context
              .push<bool>('/storage-connect', extra: widget.shopId)
              .then((saved) {
                if (saved == true && mounted) _reload();
              }),
        );
      },
    );
  }
}

/// Form cắm kho S3. Đóng lại với `true` khi máy chủ đã lưu xong.
class _StorageConnectRoute extends StatefulWidget {
  const _StorageConnectRoute({required this.repo, required this.shopId});

  final EcRepository repo;
  final String shopId;

  @override
  State<_StorageConnectRoute> createState() => _StorageConnectRouteState();
}

class _StorageConnectRouteState extends State<_StorageConnectRoute> {
  bool _busy = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return EcStorageConnectScreen(
      busy: _busy,
      errorText: _error,
      onBack: () => context.pop(false),
      onSubmit:
          ({
            required endpoint,
            required bucket,
            required accessKeyId,
            required secretAccessKey,
            required region,
            required prefix,
          }) async {
            if (_busy) return;
            setState(() {
              _busy = true;
              _error = null;
            });
            try {
              final result = await widget.repo.saveS3Storage(
                widget.shopId,
                endpoint: endpoint,
                bucket: bucket,
                accessKeyId: accessKeyId,
                secretAccessKey: secretAccessKey,
                region: region,
                prefix: prefix.isEmpty ? 'evidencecam' : prefix,
              );
              if (!context.mounted) return;
              if (result.ok) {
                _toast(context, context.l10n.storageConnected);
                context.pop(true);
                return;
              }
              // `ok == false` = máy chủ CHƯA lưu gì. Hiện nguyên `hint` — đó là
              // câu duy nhất nói được khách thiếu quyền nào bên nhà cung cấp.
              setState(() {
                _busy = false;
                _error = result.hint ?? context.l10n.errorLoadShopDetail;
              });
            } on Object catch (error) {
              if (!mounted) return;
              setState(() {
                _busy = false;
                _error = _dataErrorText(context.l10n, error);
              });
            }
          },
    );
  }
}

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

/// Đăng xuất.
///
/// Trước đây hàm này còn phải gỡ phiên mua hàng RevenueCat khỏi thiết bị, nếu
/// không thì người đăng nhập sau mua gói lại cộng ngày cho tài khoản trước.
/// Không còn cửa hàng nào trong app nên lỗi đó cũng không còn chỗ để xảy ra.
Future<void> _signOutAll(EcAuth auth) => auth.signOut();

T? _maybeGetIt<T extends Object>() =>
    getIt.isRegistered<T>() ? getIt<T>() : null;

AnalyticsService? _analytics() => _maybeGetIt<AnalyticsService>();

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

/// Tải clip về rồi giao ra ngoài app — KHÔNG đóng dấu lại.
///
/// Bản nằm trên cloud đã mang dấu sẵn, nên nung thêm lần nữa ở đây là chồng
/// hai khối chữ lên cùng một góc. Nặng hơn: nung là ghi lại file, nên bản
/// người dùng cầm sẽ không còn khớp `sha256` server đã lưu — mất luôn khả
/// năng kiểm chứng đúng lúc cần nó nhất. Byte nào server trả về thì giao
/// nguyên byte đó.
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

/// Tải bản ĐÃ NUNG về máy, mở màn cắt, rồi giao đoạn cắt ra cho người dùng.
///
/// Bằng chứng trên máy chủ không bị đụng tới — cắt chỉ xảy ra trên bản tải về.
/// Và vì bản tải về là bản đã nung, đoạn cắt ra vẫn mang dấu giờ + mã vận đơn
/// trên hình, tức vẫn dùng gửi cho sàn được.
///
/// Bản đầy đủ vừa tải bị xoá sau khi rời màn cắt: nó chỉ là nguyên liệu, giữ
/// lại là chiếm chỗ máy cho một thứ tải lại được bất cứ lúc nào.
Future<void> _trimAndShareVideo(
  BuildContext context,
  Dio dio,
  ShareService? share,
  GallerySaveService? gallery,
  VideoPlayerService player,
  EcVideoDetail? video,
  String tracking,
) async {
  final url = video?.mediaUrl;
  if (url == null) {
    _toast(context, context.l10n.toastVideoNoDownloadLink);
    return;
  }
  var sourcePath = '';
  try {
    _toast(context, context.l10n.trimPreparing);
    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now().microsecondsSinceEpoch;
    sourcePath = '${dir.path}/${evidenceTrimPrefix}src_$stamp.mp4';
    await _downloadWithRetry(dio, url, sourcePath);
    if (!context.mounted) return;
    final trimmed = await Navigator.of(context, rootNavigator: true)
        .push<String>(
          CupertinoPageRoute(
            builder: (_) => EcTrimRoute(
              sourcePath: sourcePath,
              tracking: tracking.isEmpty ? video!.title : tracking,
              player: player,
            ),
          ),
        );
    unawaited(_deleteQuietly(sourcePath));
    if (trimmed == null || !context.mounted) return;
    // Cùng lối ra với nút Tải về: vào thư viện máy nếu được phép, không thì
    // đẩy sang bảng chia sẻ. Người bán gửi cho sàn qua chat của sàn, nên tệp
    // phải tới được bảng chia sẻ của hệ điều hành.
    if (gallery != null && await gallery.requestAccess()) {
      await gallery.saveVideo(trimmed);
      unawaited(_deleteQuietly(trimmed));
      if (context.mounted) {
        _toast(context, context.l10n.toastVideoSavedToGallery);
      }
      return;
    }
    if (share == null) {
      await Clipboard.setData(ClipboardData(text: trimmed));
      if (context.mounted) {
        _toast(context, context.l10n.toastVideoDownloadedCopied);
      }
      return;
    }
    await share.shareFiles(paths: [trimmed], subject: tracking);
  } on Object {
    unawaited(_deleteQuietly(sourcePath));
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
/// Số clip trên thẻ "Chờ tải" ở header shop.
///
/// Đếm ĐÚNG những dòng trang Hàng đợi đang hiện — trang đó vẽ mọi task còn
/// trong hàng đợi, kể cả task lỗi. Trước đây thẻ này bỏ qua task lỗi, nên
/// người bán thấy "Chờ tải 0" trong khi mở hàng đợi ra vẫn còn clip nằm đó:
/// con số ngoài cửa nói một đằng, thứ bên trong một nẻo, và thứ nằm lại là
/// clip chưa hề được máy chủ giữ.
/// Số clip CÒN PHẢI LÊN — chip ☁ ở màn quay nói về việc chưa xong, nên lịch sử
/// đã lên xong nằm chung danh sách không được tính vào đây.
int _pendingUploads(EcUploadQueue queue) => queue.pendingCount;

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
/// `KeyValueStore` lấy qua service locator có
/// thể chưa đăng ký, lúc đó `setString` im lặng không làm gì và ảnh vừa chọn
/// biến mất ngay khi trang Tài khoản dựng lại.
final _avatarCache = <String, String>{};

Future<void> _rememberAvatar(String? uid, String path) {
  final key = _avatarPathKey(uid);
  _avatarCache[key] = path;
  return _appMemory()?.setString(key, path) ?? Future<void>.value();
}

/// Xoá bản trên máy sau khi ảnh đã lên máy chủ: từ lúc đó `accounts.avatar_url`
/// là nguồn duy nhất, chung cho app và web.
Future<void> _forgetAvatar(String? uid) {
  final key = _avatarPathKey(uid);
  _avatarCache.remove(key);
  return _appMemory()?.remove(key) ?? Future<void>.value();
}

String? _rememberedAvatar(String? uid) {
  final key = _avatarPathKey(uid);
  final cached = _avatarCache[key];
  if (cached != null) return _resolveAvatarPath(cached);
  final saved = _appMemory()?.getString(key);
  if (saved != null) _avatarCache[key] = saved;
  return _resolveAvatarPath(saved);
}

/// Thời lượng clip CỐ ĐỊNH ở phía app ([kFixedClipSeconds]), không lấy theo
/// shop nữa — cùng hằng số màn cài đặt in ra, nên dòng chữ trên màn không thể
/// lệch với thứ máy quay thật sự làm.
///
/// Mọi trần dung lượng đã bỏ 2026-08-07: gói cước tính theo số video, nên
/// không còn con số byte nào để mang từ server về.
ClipBudget _budgetFromDto(ShopDto shop) => ClipBudget(
  seconds: kFixedClipSeconds,
  planMaxSeconds: shop.planMaxClipSeconds,
);

/// [l10n] chỉ để dịch vai trò trong dòng meta.
///
/// Bản trước nhét thẳng `shop.role` vào — tức mã thô `owner`/`staff` — nên màn
/// Chọn cửa hàng hiện tiếng Anh giữa một app tiếng Việt.
EcShopSummary _shopFromDto(AppLocalizations l10n, ShopDto shop) =>
    EcShopSummary(
      id: shop.id,
      name: shop.name,
      platform: shop.platform,
      meta:
          '${_platformDisplayName(shop.platform)} · '
          '${_roleDisplayName(l10n, shop.role)}',
      role: shop.role,
      resolution: shop.resolution,
      clipBudget: _budgetFromDto(shop),
    );

/// Nhân viên chỉ được XEM cửa hàng.
///
/// Họ vẫn quay video và tạo đơn bình thường ở luồng chính — đó là việc của họ.
/// Cái bị khoá là sửa cấu hình shop, mời/gỡ người, và mọi thao tác xoá.
bool _shopDetailIsReadOnly(EcShopSummary shop) => shop.role == 'staff';

String _platformDisplayName(String platform) => switch (platform) {
  'shopee' => 'Shopee',
  'tiktok' => 'TikTok Shop',
  'lazada' => 'Lazada',
  'tiki' => 'Tiki',
  _ => 'Khác',
};

String _roleDisplayName(AppLocalizations l10n, String role) => switch (role) {
  'owner' => l10n.roleOwner,
  // `manager` là mã CŨ. Hai cấp (2026-08-07) không còn vai trò đó, và backend
  // hạ mọi hàng còn sót về `staff`; hiện nó là "Quản lý" thì màn hình hứa một
  // quyền hạn mà máy chủ đã không còn công nhận.
  'manager' || 'staff' => l10n.roleStaff,
  // Rỗng chứ không phải một vai trò lạ — in ra chuỗi rỗng thì hàng trông như
  // lỗi hiển thị, trong khi sự thật là dữ liệu không nói vai trò là gì.
  '' => l10n.roleUnknown,
  _ => role,
};

/// Ép gói, CHỈ để thử giao diện. Truyền lúc build:
/// `--dart-define=FORCE_PLAN=enterprise`.
///
/// Chỉ đổi được thứ APP tự quyết: tên gói hiển thị, và cờ mở hai thẻ kho riêng.
/// Mọi cánh cửa THẬT — lưu kho S3, hạn mức video, số người dùng — do máy chủ
/// giữ, nên máy chủ vẫn từ chối nếu tài khoản chưa thật sự lên gói. Đây là cờ
/// để đi thử luồng màn hình, không phải cách cấp gói.
const _kForcedPlan = String.fromEnvironment('FORCE_PLAN');

/// Chặn hai lớp: bản phát hành không truyền cờ này (fastlane chỉ truyền
/// `env/<flavor>.json`), và kể cả lỡ tay truyền thì flavor `prod` vẫn bỏ qua.
bool get _planOverrideOn =>
    _kForcedPlan.isNotEmpty && const EnvConfig().flavor != 'prod';

String _planDisplayName(AppLocalizations l10n, String planCode) =>
    switch (_planOverrideOn ? _kForcedPlan : planCode) {
      'free' => l10n.planFree,
      'basic' => l10n.planBasic,
      'pro' => l10n.planPro,
      'enterprise' => l10n.planEnterprise,
      // `saver`/`premium` là hai mã của thế hệ gói trước. Khách mua từ hồi đó
      // vẫn đang dùng chúng, nên xoá là họ đọc thấy mã thô trên màn Tài khoản.
      'saver' => l10n.planSaver,
      'premium' => l10n.planPremium,
      // Mã lạ thì hiện nguyên mã: sai còn hơn im lặng gọi nhầm tên gói người
      // dùng đang trả tiền. Nhưng các mã trên phải khớp PLANS ở backend
      // (`tool/ec_plans.mjs`).
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
  // Trần 5 MB cho MỘT tấm ảnh — đúng con số màn Chi tiết cửa hàng in ra.
  //
  // Đây không phải quota (quota tính theo SỐ VIDEO, một tấm ảnh nặng bao nhiêu
  // cũng không tốn suất nào). Đây là chặn một tệp đơn lẻ, để ảnh máy ảnh 40MB
  // không đi qua đường đính kèm. Ảnh trong trần thì lưu NGUYÊN VẸN — không nén,
  // không cắt (FR-20: chuỗi bằng chứng phải nguyên gốc).
  //
  // Đọc cùng hằng số màn cài đặt dùng: hai chỗ hai nguồn là dòng chữ nói dối.
  final bytes = await File(path).length();
  if (bytes > kFixedImageBytes) {
    if (context.mounted) {
      _toast(
        context,
        context.l10n.imageOverFixedCap(
          '${(bytes / 1000000).toStringAsFixed(1)}',
          '${kFixedImageBytes ~/ 1000000}',
        ),
      );
    }
    return null;
  }
  await queue.enqueue(
    tracking: tracking,
    type: 'Ảnh đính kèm',
    filePath: path,
    shopId: shopId,
  );
  if (!context.mounted) return path;
  if (toastOnQueued) _toast(context, context.l10n.toastPhotoQueued);
  return path;
}

/// Shop picker backed by the repository. The dev/prod app must choose a real
/// backend shop id before Flow 2 loads orders for that shop.
class _ChooseShopRoute extends StatefulWidget {
  const _ChooseShopRoute({
    required this.repo,
    this.onSelect,
    this.onAccount,
    this.onCreateShop,
    this.onLogout,
    this.autoEnter = true,
  });

  final EcRepository repo;
  final ValueChanged<EcShopSummary>? onSelect;

  /// Mở màn Tài khoản. Nó rời khỏi thanh tab để nhường ô thứ ba cho Hồ sơ
  /// khiếu nại, và về đây — màn người dùng đi qua mỗi lần vào ca.
  final VoidCallback? onAccount;
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
  /// Chỉ liệt kê. KHÔNG có bước nào ở đây nhận được lời mời treo: máy chủ
  /// đòi token trong link email (xem [_joinByInvite]), nên nạp lại màn này
  /// bao nhiêu lần cũng không làm shop được mời hiện ra.
  Future<List<EcShopSummary>> _loadShops() async {
    final shops = await widget.repo.shops();
    final l10n = context.l10n;
    return [for (final shop in shops) _shopFromDto(l10n, shop)];
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
            onCreate: widget.onCreateShop,
            onJoinByInvite: () async {
              if (await _joinByInvite(context, widget.repo)) _retry();
            },
            // Nạp lại thật, không chỉ hiện thông báo: người vừa được mời bấm
            // vào đây là để hỏi "đã vào chưa", mà một câu toast thì không trả
            // lời được câu đó.
            onInviteTap: () async {
              if (await _joinByInvite(context, widget.repo)) _retry();
            },
            onLogout: widget.onLogout,
          );
        }
        _autoSelectIfNeeded(shops);
        return EcChooseShopScreen(
          shops: shops,
          onAccountTap: widget.onAccount,
          onSelect: widget.onSelect,
          // Cùng đích với nút "Tạo shop" ở màn chưa-có-shop.
          onAddShop: widget.onCreateShop,
          onJoinByInvite: () async {
            if (await _joinByInvite(context, widget.repo)) _retry();
          },
          onLogout: widget.onLogout,
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
      widget.onCreated?.call(_shopFromDto(context.l10n, shop));
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
    this.onShopQr,
    this.onEditType,
    this.onDeleteType,
    this.onAddType,
    this.onTapStorage,
    this.onDeleteShop,
    this.onRenameShop,
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

  /// Mở mã QR vào cửa hàng. `null` với nhân viên.
  final Future<void> Function()? onShopQr;
  final Future<void> Function(EcVideoType type)? onEditType;
  final Future<void> Function(EcVideoType type)? onDeleteType;
  final Future<void> Function()? onAddType;

  /// Kho lưu trữ. Mở cho mọi vai trò, khác các callback quản trị khác.
  final Future<void> Function()? onTapStorage;

  /// Xoá hẳn cửa hàng. Rào chắn "phải gỡ hết người trước" nằm ở router, nơi
  /// biết danh sách thành viên vừa đọc về.
  final Future<void> Function()? onDeleteShop;

  /// Đổi tên cửa hàng. `null` với nhân viên.
  final Future<void> Function()? onRenameShop;

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
  /// Nhân viên KHÔNG hỏi danh sách thành viên: endpoint đó chỉ mở cho chủ shop
  /// nên lượt gọi ấy chắc chắn 403. Nhưng thay vì bỏ trống phần đó, hỏi
  /// `/api/me` rồi dựng đúng MỘT dòng — chính họ.
  ///
  /// Một khối trống hoặc một câu "bạn không có quyền xem" không trả lời được
  /// câu người nhân viên thật sự hỏi khi mở màn này: mình đang ở shop nào, với
  /// vai trò gì. Còn danh sách đồng nghiệp thì đúng là việc của chủ shop.
  Future<_ShopDetailData> _load() async {
    final l10n = context.l10n;
    final canReadMembers = !widget.isReadOnly;
    final results = await Future.wait([
      _orLog('shop', () => widget.repo.shop(widget.shop.id)),
      if (canReadMembers)
        _orLog('members', () => widget.repo.members(widget.shop.id))
      else
        _orLog('self', () => widget.repo.account()),
      _orLog('video-types', () => widget.repo.videoTypes(widget.shop.id)),
      // Kho chỉ để hiện một dòng tóm tắt, nên hỏng thì rơi về "kho hệ thống"
      // chứ không làm hỏng cả màn — người dùng vẫn mở được màn kho và thấy
      // lỗi thật ở đó.
      _orLog('storage', () => widget.repo.storage(widget.shop.id)),
    ]);
    final members = canReadMembers ? results[1] as List<MemberDto>? : null;
    final self = canReadMembers ? null : results[1] as AccountDto?;
    return _ShopDetailData(
      shop: (results[0] as ShopDto?) ?? _snapshotDto(),
      members: canReadMembers
          ? (members ?? const []).map((m) => _memberFromDto(l10n, m)).toList()
          : [
              if (self != null)
                EcShopMember(
                  accountUid: self.uid,
                  roleCode: widget.shop.role,
                  name: self.name?.isNotEmpty ?? false
                      ? self.name!
                      : self.email ?? l10n.memberFallbackName,
                  role: _roleDisplayName(l10n, widget.shop.role),
                ),
            ],
      // Đọc `/api/me` hỏng cũng là "không tải được", y như đọc danh sách hỏng —
      // cả hai đều để lại phần thành viên trống mà không nói vì sao.
      membersFailed: canReadMembers ? members == null : self == null,
      membersRestricted: false,
      storageKind:
          (results.last as StorageStateDto?)?.kind ?? StorageKind.system,
      videoTypes: ((results[2] as List<VideoTypeDto>?) ?? const [])
          .map((type) => _videoTypeFromDto(type, l10n))
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
          // KHÔNG nạp lại sau khi đóng mã QR: người quét vào shop ở máy khác,
          // và một lượt nạp ngay lúc đóng thì gần như luôn chạy trước khi họ
          // kịp quét — nạp xong vẫn không thấy ai, chỉ tốn một lượt gọi.
          onShopQr: locked || widget.onShopQr == null
              ? null
              : () => unawaited(widget.onShopQr!()),
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
          // Kho KHÔNG khoá theo `locked`: nhân viên phải xem được kho đang ra
          // sao. Máy chủ mở `GET` cho mọi vai trò và chỉ chặn phần ĐỔI kho.
          onTapStorage: widget.onTapStorage == null
              ? null
              : () => widget.onTapStorage!().then((_) {
                  if (mounted) _retry();
                }),
          // Hiện thứ chủ shop đã CHỌN trong màn Kho lưu trữ. Xem
          // [_storagePickKey] về chỗ lệch giữa lựa chọn và kho thật.
          storageLabel: _storageLabel(
            context,
            _displayedStorageKind(widget.shop.id, detail.storageKind),
          ),
          onDeleteShop: locked || widget.onDeleteShop == null
              ? null
              : () => unawaited(widget.onDeleteShop!()),
          // Nạp lại sau khi đổi tên: tên trên màn này đến từ `_load()`, nên
          // không nạp lại thì người vừa sửa xong vẫn đọc thấy tên cũ.
          onRenameShop: locked || widget.onRenameShop == null
              ? null
              : () => unawaited(widget.onRenameShop!().then((_) => _retry())),
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
    this.storageKind = StorageKind.system,
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

  /// Chỉ để hiện tóm tắt trên hàng "Kho lưu trữ". Đọc hỏng → kho hệ thống, và
  /// màn kho sẽ nói ra lỗi thật khi người dùng mở nó.
  final StorageKind storageKind;
}

/// Kho người dùng vừa BẤM CHỌN trong màn Kho lưu trữ, nhớ ngay trên máy theo
/// từng shop.
///
/// Máy chủ chỉ ghi nhận kho khi luồng cắm chạy xong — nhập đủ khoá S3, hoặc
/// cấp quyền Google ở trình duyệt. Không có việc nào tên là "đặt kiểu kho".
/// Chủ shop muốn lựa chọn của mình được giữ ngay lúc bấm, nên nhớ thêm ở đây
/// và ưu tiên nó khi hiển thị.
///
/// Đây là LỰA CHỌN, không phải nơi video đang nằm. Hai thứ lệch nhau khi kho
/// chưa cắm được thật, và [_syncStoragePick] là chỗ kéo chúng về lại với nhau
/// mỗi khi máy chủ báo kho đã đổi thật.
String _storagePickKey(String shopId) => 'storage_pick_$shopId';

/// Kho máy chủ báo ở lần đọc gần nhất — để nhận ra lúc kho đổi THẬT.
String _storageServerKey(String shopId) => 'storage_server_$shopId';

StorageKind? _parseStorageKind(String? raw) => switch (raw) {
  'system' => StorageKind.system,
  's3' => StorageKind.s3,
  'gdrive' => StorageKind.gdrive,
  _ => null,
};

String _storageKindName(StorageKind kind) => switch (kind) {
  StorageKind.system => 'system',
  StorageKind.s3 => 's3',
  StorageKind.gdrive => 'gdrive',
};

/// Kho để HIỂN THỊ: lựa chọn đã nhớ, hoặc kho thật khi chưa nhớ gì.
StorageKind _displayedStorageKind(String shopId, StorageKind server) =>
    _parseStorageKind(_appMemory()?.getString(_storagePickKey(shopId))) ??
    server;

Future<void> _rememberStoragePick(String shopId, StorageKind kind) async =>
    _appMemory()?.setString(_storagePickKey(shopId), _storageKindName(kind));

/// Kéo lựa chọn đã nhớ về khớp với máy chủ khi kho đổi THẬT.
///
/// So với kho lần đọc trước chứ không so với chính lựa chọn: nếu so với lựa
/// chọn thì mỗi lượt đọc lại sẽ xoá ngay thứ người dùng vừa bấm mà chưa cắm
/// xong. Kho chỉ đổi thật khi máy chủ trả về một giá trị khác lần trước — kể
/// cả khi đổi từ web, và lúc ấy lựa chọn cũ đã hết nghĩa.
Future<void> _syncStoragePick(String shopId, StorageKind server) async {
  final memory = _appMemory();
  if (memory == null) return;
  final seen = _parseStorageKind(memory.getString(_storageServerKey(shopId)));
  await memory.setString(_storageServerKey(shopId), _storageKindName(server));
  if (seen == server) return;
  await memory.setString(_storagePickKey(shopId), _storageKindName(server));
}

/// Tên kho hiện ở hàng ngoài, lấy ĐÚNG chuỗi của thẻ trong màn Kho lưu trữ.
///
/// Trước đây hàng ngoài dùng một bộ tên riêng ("Kho riêng của bạn (S3)",
/// "Google Drive của bạn") khác tên trên thẻ người dùng vừa bấm ("Kho đám mây
/// riêng (chuẩn S3)", "Google Drive"). Cùng một kho mà hai màn gọi hai tên thì
/// người dùng phải tự đoán xem có phải một thứ không — với màn nói về NƠI CẤT
/// BẰNG CHỨNG thì đó là chỗ không được phép để họ đoán.
String _storageLabel(BuildContext context, StorageKind kind) => switch (kind) {
  StorageKind.system => context.l10n.storageSystemName,
  StorageKind.s3 => context.l10n.storageS3Title,
  StorageKind.gdrive => context.l10n.storageDriveTitle,
};

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

/// Nhãn hiển thị của một loại video.
///
/// Ba loại mặc định do MÁY CHỦ tạo và tên chúng nằm trong cơ sở dữ liệu bằng
/// tiếng Việt, nên đổi ngôn ngữ giao diện không đụng tới chúng — người bán
/// Thái vẫn thấy "Đóng hàng" giữa một màn hình tiếng Thái. Dịch ở đây, ngay
/// lúc vẽ, và CHỈ để hiển thị: giá trị gửi lên máy chủ lẫn giá trị đem so
/// trong luồng quay (`state.typeLabel == 'Trả hàng'`) vẫn là chuỗi gốc.
///
/// Loại do shop tự đặt thì giữ nguyên: đó là chữ của người dùng, không phải
/// của app.
String _videoTypeLabel(AppLocalizations l10n, String name) => switch (name) {
  'Đóng hàng' => l10n.videoTypePacking,
  'Đơn vị vận chuyển' => l10n.videoTypeCarrier,
  'Trả hàng' => l10n.videoTypeReturn,
  _ => name,
};

/// Loại tự đặt mang icon người tạo đã chọn; ba loại mặc định (và loại tạo
/// trước khi màn chọn icon được nối dây) rơi về icon suy từ tên.
EcVideoType _videoTypeFromDto(VideoTypeDto type, AppLocalizations l10n) {
  final pickedIcon = type.icon == null
      ? null
      : EcCreateTypeScreen.iconFor(type.icon!);
  return EcVideoType(
    id: type.id,
    name: _videoTypeLabel(l10n, type.name),
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
            ? snap.data!
                  .map((type) => _captureTypeFromDto(type, context.l10n))
                  .toList()
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

capture.EcVideoType _captureTypeFromDto(
  VideoTypeDto type,
  AppLocalizations l10n,
) => capture.EcVideoType(
  // Nhãn gốc đi tiếp vào clip và vào phép so trong luồng quay; bản đã dịch
  // chỉ để vẽ ra màn.
  label: type.name,
  displayLabel: _videoTypeLabel(l10n, type.name),
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
      // `POST /invites` luôn trả `pending`: người được mời phải tự bấm link
      // xác nhận mới vào shop. Nhánh "đã thêm thành viên" ở đây là di tích của
      // thời tự-vào-shop, không có đường nào chạy tới nữa.
      assert(result.status == 'pending', 'lời mời mới phải là pending');
      await _showInviteQr(context, result.inviteToken);
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

/// Mã QR vào cửa hàng — đường mời thứ hai, cho người ĐÃ có tài khoản.
///
/// Mời qua email tồn tại vì người được mời có thể chưa có tài khoản: cái duy
/// nhất biết về họ là địa chỉ hộp thư. Nhưng khi họ đã có tài khoản rồi thì
/// bắt chủ shop gõ đúng email của họ là một bước thừa — họ đứng ngay đó, quét
/// một cái là xong.
///
/// Token dùng một lần, nên cứ một người vào là mã tự đổi; mở lại màn này là
/// xin mã mới.
Future<void> _showShopJoinQr(
  BuildContext context,
  EcRepository repo,
  String shopId,
) async {
  final l10n = context.l10n;
  try {
    final invite = await repo.createQrInvite(shopId);
    if (!context.mounted) return;
    await _showInviteQr(context, invite.token);
  } on DioException catch (error) {
    if (!context.mounted) return;
    // Đi qua `_inviteErrorText` thay vì đoán theo mã HTTP. 400 ở đây HÔM NAY
    // chỉ có một nghĩa — shop đã đủ người theo gói của chủ shop, và mã QR đang
    // treo cũng chiếm một suất — nhưng đoán theo status thì thêm một mã 400 mới
    // ở máy chủ là câu chữ lặng lẽ sai. Đọc thẳng mã lỗi thì không.
    _toast(context, _inviteErrorText(l10n, error));
  } on Object catch (error) {
    if (context.mounted) _toast(context, _dataErrorText(l10n, error));
  }
}

/// Sau khi mời xong: chìa MÃ QR của lời mời ra, không chỉ báo "đã gửi".
///
/// Link trong email là thứ duy nhất đưa người được mời vào shop, mà email thì
/// hay không tới — vào thư rác, gõ nhầm địa chỉ, hoặc đơn giản là chậm. Trước
/// đây app cầm sẵn token trong tay rồi vứt đi và toast "đã gửi lời mời", nên
/// khi email không tới thì không ai — kể cả chủ shop — còn cách nào lấy lại
/// được nó.
///
/// Hiện thành QR chứ không chỉ chữ: hai người đang đứng cạnh nhau thì chìa
/// màn hình ra cho quét là xong, không phải đọc từng ký tự token cho nhau.
Future<void> _showInviteQr(BuildContext context, String token) async {
  final link = 'https://zenpack.vn/invite/$token';
  // Bấm ra ngoài là đóng. Mã này được chìa ra giữa chừng một việc khác — hỏi
  // email, xem danh sách thành viên — nên đường thoát phải là thứ tay đã biết
  // sẵn, không phải một nút nữa phải tìm.
  await showCupertinoDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => _InviteQrDialog(link: link),
  );
}

/// Mã QR mời, chiếm trọn sự chú ý: chỉ mã, và hai việc làm được với nó.
///
/// Không tiêu đề, không đoạn giải thích, không nút Đóng. Người mở nó ra đang
/// chìa màn hình cho người khác quét — mọi chữ thêm vào đều là thứ che mất
/// phần duy nhất có việc phải làm.
class _InviteQrDialog extends StatefulWidget {
  const _InviteQrDialog({required this.link});

  final String link;

  @override
  State<_InviteQrDialog> createState() => _InviteQrDialogState();
}

class _InviteQrDialogState extends State<_InviteQrDialog> {
  /// Neo để chụp đúng phần mã thành ảnh — lưu và chia sẻ đều cần một tấm PNG,
  /// và chụp lại chính widget đang hiện thì thứ người ta nhận được giống hệt
  /// thứ họ vừa nhìn.
  final _qrKey = GlobalKey();
  var _busy = false;

  Future<Uint8List?> _pngBytes() async {
    final object = _qrKey.currentContext?.findRenderObject();
    if (object is! RenderRepaintBoundary) return null;
    // 3x: mã in ra hay bị quét từ ảnh chụp màn hình rồi phóng to, và một mã
    // vỡ nét thì máy quét chịu.
    final image = await object.toImage(pixelRatio: 3);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data?.buffer.asUint8List();
  }

  Future<void> _save() async {
    if (_busy) return;
    setState(() => _busy = true);
    final l10n = context.l10n;
    final gallery = _maybeGetIt<GallerySaveService>();
    try {
      final bytes = await _pngBytes();
      if (bytes == null || gallery == null) throw StateError('no-image');
      if (!await gallery.requestAccess()) throw StateError('no-access');
      await gallery.savePng(bytes);
      if (!mounted) return;
      Navigator.of(context).pop();
      _toast(context, l10n.inviteQrSaved);
    } on Object {
      if (mounted) _toast(context, l10n.inviteQrSaveFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share() async {
    if (_busy) return;
    setState(() => _busy = true);
    final l10n = context.l10n;
    final share = _maybeGetIt<ShareService>();
    try {
      final bytes = await _pngBytes();
      if (bytes == null || share == null) throw StateError('no-image');
      // Gửi kèm CẢ ảnh lẫn link: người nhận qua Zalo quét ảnh không được thì
      // vẫn bấm được link, và ngược lại.
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/zenpack-invite-qr.png');
      await file.writeAsBytes(bytes);
      await share.shareFiles(paths: [file.path], text: widget.link);
      if (mounted) Navigator.of(context).pop();
    } on Object {
      if (mounted) _toast(context, l10n.errorGenericRetry);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RepaintBoundary(
            key: _qrKey,
            child: PenQrCard(data: widget.link, size: 260),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _InviteQrAction(
                icon: LucideIcons.download,
                label: l10n.commonSave,
                onTap: _busy ? null : _save,
              ),
              const SizedBox(width: 12),
              _InviteQrAction(
                icon: LucideIcons.share2,
                label: l10n.commonShare,
                onTap: _busy ? null : _share,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Một trong hai việc làm được với mã: viên thuốc trắng trên nền tối.
class _InviteQrAction extends StatelessWidget {
  const _InviteQrAction({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => CupertinoButton(
    onPressed: onTap,
    padding: EdgeInsets.zero,
    minimumSize: Size.zero,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: PenColors.ink),
            const SizedBox(width: 8),
            PenText(
              label,
              size: 15,
              color: PenColors.ink,
              weight: FontWeight.w700,
              softWrap: false,
            ),
          ],
        ),
      ),
    ),
  );
}

/// Nhận một lời mời bằng cách QUÉT mã QR của nó.
///
/// Máy chủ KHÔNG tự ghép lời mời treo với tài khoản lúc đăng nhập — token
/// trong link mới là bằng chứng sở hữu hộp thư (`POST /api/invites/:token/
/// accept`). Trước đây app chỉ có một nút "đã được mời" chạy nạp lại danh
/// sách rồi báo "chờ chút"; nạp bao nhiêu lần cũng vô ích vì chưa ai gọi
/// accept cả, nên người được mời ngồi bấm mãi mà shop không bao giờ hiện.
///
/// Quét thay vì dán: người được mời thường đứng ngay cạnh chủ shop, và cái
/// họ có trong tay là màn hình của người kia chứ không phải một hộp thư.
///
/// Trả `true` khi danh sách shop cần nạp lại.
Future<bool> _joinByInvite(BuildContext context, EcRepository repo) async {
  final l10n = context.l10n;
  final raw = await context.push<String>('/scan');
  if (raw == null || raw.isEmpty || !context.mounted) return false;
  final token = ecInviteTokenOf(raw);
  if (token == null) {
    _toast(context, l10n.inviteBadLink);
    return false;
  }
  try {
    final joined = await repo.acceptInvite(token);
    if (!context.mounted) return true;
    _toast(
      context,
      joined.newlyJoined
          ? l10n.inviteJoinedShop(joined.shopName)
          : l10n.inviteAlreadyJoined(joined.shopName),
    );
    return true;
  } on DioException catch (error) {
    if (!context.mounted) return false;
    // Ba lý do hỏng khác nhau, ba việc phải làm khác nhau: xin link mới, thôi
    // khỏi thử, hay nhờ gửi lại. Một câu "có lỗi" gộp cả ba thì không câu nào
    // dùng được.
    _toast(context, switch (error.response?.statusCode) {
      404 => l10n.inviteNotFound,
      409 => l10n.inviteTaken,
      410 => l10n.inviteExpired,
      _ => _dataErrorText(l10n, error),
    });
    return false;
  } on Object catch (error) {
    if (context.mounted) _toast(context, _dataErrorText(l10n, error));
    return false;
  }
}

/// Tách token khỏi thứ quét được (hoặc dán vào).
///
/// Chấp cả link thật (`https://zenpack.vn/invite/<token>`), link đã qua
/// redirect (`.../app#/invite/<token>`), lẫn token trần — mã QR mang link
/// đầy đủ, còn người sao chép tay từ email thì kiểu gì cũng có.
String? ecInviteTokenOf(String raw) {
  final match = RegExp(r'invite/([A-Za-z0-9._~-]+)').firstMatch(raw);
  if (match != null) return match.group(1);
  // Token trần: không có khoảng trắng, không phải một URL nào khác.
  if (!raw.contains(RegExp(r'[\s/]')) && raw.length >= 8) return raw;
  return null;
}

/// Đổi tên cửa hàng.
///
/// Tên mới áp vào MỌI nơi cùng lúc: header trang Vận đơn, màn Chọn cửa hàng,
/// và màn này. Nó là một trường trên `shops`, không phải nhãn cục bộ — nhân
/// viên mở app lên cũng thấy tên mới, không cần làm gì thêm.
Future<void> _renameShop(
  BuildContext context,
  EcRepository repo,
  EcShopSummary shop,
  ValueNotifier<EcShopSummary?> selectedShop,
) async {
  final l10n = context.l10n;
  final controller = TextEditingController(text: shop.name);
  final name = await showCupertinoDialog<String>(
    context: context,
    builder: (dialogContext) => CupertinoAlertDialog(
      title: Text(l10n.shopRenameTitle),
      content: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: CupertinoTextField(
          controller: controller,
          placeholder: l10n.shopRenameHint,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(l10n.commonCancel),
        ),
        CupertinoDialogAction(
          onPressed: () =>
              Navigator.of(dialogContext).pop(controller.text.trim()),
          child: Text(l10n.commonSave),
        ),
      ],
    ),
  );
  controller.dispose();
  // Tên rỗng hoặc không đổi thì không gọi mạng: một shop không tên đọc ra như
  // dữ liệu hỏng, và gọi API cho một thay đổi bằng không là tốn công vô ích.
  if (name == null || name.isEmpty || name == shop.name) return;
  if (!context.mounted) return;
  try {
    final updated = await repo.updateShop(shop.id, name: name);
    if (!context.mounted) return;
    // Cập nhật shop đang chọn để header trang Vận đơn đổi theo ngay, không
    // phải thoát ca ra vào lại.
    if (selectedShop.value?.id == updated.id) {
      selectedShop.value = _shopFromDto(context.l10n, updated);
    }
    _toast(context, l10n.shopRenamed);
  } on Object catch (error) {
    if (context.mounted) _toast(context, _dataErrorText(l10n, error));
  }
}

/// Xoá cửa hàng — sau khi kiểm tra shop đã sạch người và hỏi lại một lần.
///
/// Rào chắn đọc lại danh sách thành viên NGAY LÚC BẤM chứ không tin vào bản đã
/// vẽ trên màn: người dùng có thể mở màn này, đi mời thêm một quản lý ở tab
/// khác, rồi quay lại bấm xoá. Danh sách cũ sẽ nói "sạch rồi" trong khi shop
/// vừa có thêm người.
///
/// Chủ shop luôn nằm trong danh sách và không tự gỡ mình được, nên phép đếm bỏ
/// qua vai trò `owner` — đếm cả owner thì rào chắn không bao giờ mở ra.
Future<void> _confirmDeleteShop(
  BuildContext context,
  EcRepository repo,
  EcShopSummary shop,
) async {
  final l10n = context.l10n;
  List<MemberDto> members;
  try {
    members = await repo.members(shop.id);
  } on Object catch (error) {
    // Không đọc được danh sách thì KHÔNG xoá. Đoán bừa là sạch rồi xoá nhầm
    // một shop còn người là hỏng không lấy lại được.
    if (context.mounted) _toast(context, _dataErrorText(l10n, error));
    return;
  }
  if (!context.mounted) return;
  final others = members.where((m) => m.role != 'owner').length;
  if (others > 0) {
    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(l10n.shopDeleteBlockedTitle),
        content: Text(l10n.shopDeleteBlockedBody(others)),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.commonClose),
          ),
        ],
      ),
    );
    return;
  }
  final confirmed = await showCupertinoDialog<bool>(
    context: context,
    builder: (dialogContext) => CupertinoAlertDialog(
      title: Text(l10n.shopDeleteTitle),
      content: Text(l10n.shopDeleteConfirm),
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
  try {
    await repo.deleteShop(shop.id);
  } on Object catch (error) {
    // `DELETE /api/shops/:id` backend CHƯA mở — hiện trả 404, và
    // `_dataErrorText` dịch nó thành một câu chung chung. Thà vậy còn hơn nuốt
    // im lặng rồi đưa người dùng về màn danh sách như thể đã xoá xong.
    if (context.mounted) _toast(context, _dataErrorText(l10n, error));
    return;
  }
  if (!context.mounted) return;
  _toast(context, l10n.shopDeleted);
  // Shop vừa bị xoá nên không quay về chi tiết của nó được nữa.
  context.go('/shops');
}

/// Vì sao ảnh đại diện không lên được máy chủ.
///
/// Tên và SĐT vẫn lưu bình thường, ảnh vẫn hiện từ bản trên máy — nên đây là
/// một lời nhắc, không phải một thất bại. Nhưng phải nói ra: im lặng đúng là
/// cách bản trước giấu việc endpoint không tồn tại suốt nhiều bản phát hành.
String _avatarErrorText(AppLocalizations l10n, Object error) =>
    error is AvatarTooLargeException
    ? l10n.avatarTooLarge(_mbLabel(error.bytes), _mbLabel(error.maxBytes))
    : l10n.avatarUploadFailed(_dataErrorText(l10n, error));

/// MB thập phân, cho đúng MỘT chỗ còn lại có trần dung lượng: ảnh đại diện.
///
/// Đó là chốt chặn kỹ thuật của một tấm ảnh hồ sơ, không phải hạn mức gói —
/// mọi trần dung lượng của bằng chứng đã bỏ 2026-08-07. Trước đây dùng
/// `ClipBudget.megabytesLabel`, nay `ClipBudget` không còn biết gì về byte.
String _mbLabel(int bytes) {
  final mb = bytes / 1000000;
  return mb >= 10 ? mb.round().toString() : mb.toStringAsFixed(1);
}

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
      // Trần người dùng của gói. Không có dòng này thì nó rơi xuống
      // `_dataErrorText` và ra một câu chung — đúng lúc người dùng cần biết
      // rằng shop hết chỗ chứ không phải mạng hỏng.
      'member_limit_reached' => l10n.errorInviteMemberLimit,
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
    this.onSettings,
    this.onNavRecord,
    this.onNavClaims,
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

  /// Bánh răng góc phải header — mở Quản lý cửa hàng.
  final VoidCallback? onSettings;
  final VoidCallback? onNavRecord;

  /// Tab thứ ba: Hồ sơ khiếu nại.
  final VoidCallback? onNavClaims;
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
    _loadFirst().then((_) => _reconcilePreviews());
    _loadVideoTypes();
  }

  /// Xoá bản xem tạm của những clip máy chủ đã đóng dấu xong.
  ///
  /// Chỗ dọn kia (`_OrderDetailRoute._load`) chỉ chạy khi người bán MỞ đúng đơn
  /// đó ra xem. Ai quay xong rồi đi tiếp, không mở lại, thì bản tạm nằm trên
  /// máy tới khi hết hạn tuổi — trong khi máy chủ đã có bản thật từ lâu. Lượt
  /// này chạy ngay ở danh sách nên không cần vào đơn nữa.
  ///
  /// Chạy nền, nuốt lỗi, và chỉ hỏi những đơn thật sự còn bản tạm (tối đa 5 đơn
  /// mỗi lượt) — mở danh sách không được biến thành một tràng request.
  Future<void> _reconcilePreviews() async {
    if (!mounted) return;
    final orders = [for (final o in _orders) (o.tracking, o.id)];
    if (orders.isEmpty) return;
    await ecReconcilePreviews(orders, (orderId) async {
      final detail = await widget.repo.order(widget.shopId, orderId);
      return [for (final e in detail.evidence) (e.id, e.isSealing)];
    });
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
            EcVideoTypeOption(
              id: type.id,
              name: _videoTypeLabel(context.l10n, type.name),
            ),
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
    // Kéo để làm mới là đúng lúc hỏi lại "clip nào đóng dấu xong rồi" — cùng
    // một cử chỉ, cùng một câu hỏi.
    await _reconcilePreviews();
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
        onSettings: widget.onSettings,
        onNavRecord: widget.onNavRecord,
        onNavClaims: widget.onNavClaims,
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

  /// Bản chi tiết của clip đang mở trong sheet, cập nhật sau mỗi lần nạp lại.
  ///
  /// Sheet là một route riêng, `extra` của nó đông cứng ở thời điểm bấm. Mà
  /// link phát thì máy chủ CỐ TÌNH giấu trong lúc còn đóng dấu
  /// (`services/evidence_url.ts`: `seal_status` pending/rendering ⇒ `url` null).
  /// Mở sheet sớm một nhịp là ôm cái ảnh chụp thiếu link đó mãi mãi — đúng cái
  /// cảnh phải thoát ra vào lại mới thấy link.
  final ValueNotifier<EcVideoDetail?> _openDetail = ValueNotifier(null);
  String? _openEvidenceId;

  /// Nhịp hỏi lại trong lúc còn clip đang được đóng dấu.
  ///
  /// Màn này chỉ có đúng một mồi nạp lại — hàng đợi upload vơi đi — mà mồi đó
  /// nổ TRƯỚC khi renderer chạy xong, nên không hỏi lại là đứng im.
  ///
  /// ponytail: hẹn giờ cố định, dừng khi hết clip dở dang hoặc hết
  /// [_maxSealPolls] lượt. Có trần vì niêm phong hỏng thì `seal_status` nằm lại
  /// ở `pending` vĩnh viễn — không chặn thì màn này gọi API tới hết pin.
  /// Nhanh ở đầu rồi thưa dần: phần lớn lượt đóng dấu xong trong vài chục
  /// giây, nên mười hai lượt đầu cách nhau 5 giây để bắt đúng khoảnh khắc đổi.
  /// Lượt chậm thì đo được tới 51 phút trên prod, mà giữ nhịp 5 giây suốt ngần
  /// ấy là gọi API tới hết pin — nên sau đó giãn ra 20 giây.
  Duration get _sealPollInterval => _sealPolls < 12
      ? const Duration(seconds: 5)
      : const Duration(seconds: 20);

  /// 12 lượt 5 giây + 48 lượt 20 giây ≈ 17 phút bám theo. Vẫn có trần vì
  /// niêm phong hỏng thì `seal_status` nằm lại ở `pending` vĩnh viễn — không
  /// chặn thì màn này hỏi mãi. Hết trần thì mở lại đơn là hỏi tiếp.
  static const _maxSealPolls = 60;
  Timer? _sealPoll;
  int _sealPolls = 0;

  @override
  void initState() {
    super.initState();
    widget.queue.addListener(_onQueueChanged);
  }

  @override
  void dispose() {
    _sealPoll?.cancel();
    _openDetail.dispose();
    widget.queue.removeListener(_onQueueChanged);
    super.dispose();
  }

  /// Mở sheet chi tiết cho một dòng bằng chứng.
  ///
  /// Sheet đọc [_openDetail] chứ không đọc bản chụp lúc bấm, nên lượt nạp lại
  /// nào xong trong lúc nó đang mở cũng chảy thẳng vào màn hình.
  void _openVideoDetail(EcTimelineVideo video) {
    _openEvidenceId = video.id;
    _openDetail.value = _videoDetail(
      context.l10n,
      video,
      tracking: widget.order.tracking,
    );
    unawaited(
      widget.onOpenVideo
          ?.call(
            _VideoRouteExtra(
              shopId: widget.shop.id,
              orderId: widget.order.id,
              evidenceId: video.id,
              // Vai trò THẬT, không phải `true` cho tất cả. Máy chủ cấm nhân
              // viên xoá bằng chứng, nên mời họ bấm rồi trả lỗi là app tự mâu
              // thuẫn với chính màn hàng chờ (đã chặn staff).
              canDelete: widget.shop.role != 'staff',
              tracking: widget.order.tracking,
              video: _openDetail,
            ),
          )
          // Chỉ nạp lại khi chi tiết báo có thay đổi. Kéo sheet xuống để đóng
          // là thao tác xem xong, nạp lại chỉ làm danh sách nhấp nháy và cuộn
          // về đầu vô cớ.
          .then((changed) {
            _openEvidenceId = null;
            if (changed && mounted) _retry();
          }),
    );
  }

  /// Đẩy dữ liệu vừa nạp vào sheet đang mở, rồi hẹn lượt hỏi tiếp nếu cần.
  void _afterLoad(_OrderDetailData data) {
    if (!mounted) return;
    final l10n = context.l10n;
    final id = _openEvidenceId;
    if (id != null) {
      final fresh = _timelineDays(
        l10n,
        data.detail.evidence,
        data.videoTypes,
        data.memberNames,
        data.previews,
      ).expand((d) => d.videos).where((v) => v.id == id).firstOrNull;
      if (fresh != null) {
        _openDetail.value = _videoDetail(
          l10n,
          fresh,
          tracking: widget.order.tracking,
        );
      }
    }
    _sealPoll?.cancel();
    if (!data.detail.evidence.any((e) => e.isSealing)) {
      _sealPolls = 0;
      return;
    }
    if (_sealPolls >= _maxSealPolls) return;
    _sealPolls++;
    _sealPoll = Timer(_sealPollInterval, () {
      if (mounted) _retry();
    });
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
    // Bản tạm còn trên máy, dùng cho những clip máy chủ chưa đóng dấu xong.
    //
    // Clip nào máy chủ đã phát được thì bản tạm hết việc — xoá ngay tại đây
    // thay vì đợi lượt quét theo tuổi, để một ca đóng hàng vài trăm clip không
    // tích lại vài GB trên máy.
    final previews = await ecPreviews();
    for (final item in detail.evidence) {
      if (previews.containsKey(item.id) && !item.isSealing) {
        previews.remove(item.id);
        unawaited(ecDropPreview(item.id));
      }
    }
    final data = _OrderDetailData(
      detail: detail,
      videoTypes: types,
      memberNames: memberNames,
      previews: previews,
    );
    _afterLoad(data);
    return data;
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
        // Danh sách trong đơn CHỈ gồm clip máy chủ đã thật sự giữ.
        //
        // Trước đây các clip còn nằm trong hàng đợi cũng được ghép vào đây,
        // kèm nhãn "Đang chờ tải". Nhìn thì tiện, nhưng nó đặt cạnh nhau hai
        // thứ khác hẳn nhau về giá trị: một bên là bằng chứng đã có vân tay
        // và dấu giờ trên máy chủ, một bên là tệp mới chỉ nằm trên đúng cái
        // điện thoại này — mất máy là mất. Clip chưa lên ở nguyên trang Hàng
        // đợi cho tới khi lên thật.
        final days = _timelineDays(
          context.l10n,
          data.detail.evidence,
          data.videoTypes,
          data.memberNames,
          data.previews,
        );
        return ListenableBuilder(
          listenable: widget.queue,
          builder: (context, _) => EcOrderTimelineScreen(
            orderCode: data.detail.order.tracking,
            days: days,
            pendingUploadCount: _pendingCount + _failedCount(data.detail),
            onBack: widget.onBack,
            onVideoTap: _openVideoDetail,
            onVideoMenu: _openVideoDetail,
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
    this.previews = const {},
  });

  final OrderDetailDto detail;
  final List<VideoTypeDto> videoTypes;

  /// Account uid -> display name (name, else email), for resolving
  /// [EvidenceDto.createdByUid] to something readable.
  final Map<String, String> memberNames;

  /// `evidence_id` -> đường dẫn bản tạm còn trên máy. Xem `ec_preview_store`.
  final Map<String, String> previews;
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
    required this.url,
    required this.service,
    this.onBack,
    this.isLocalFile = false,
  });

  final String title;
  final String url;

  /// Xem [_VideoPlayerRouteExtra.isLocalFile].
  final bool isLocalFile;
  final VideoPlayerService service;
  final VoidCallback? onBack;

  @override
  State<_VideoPlayerRoute> createState() => _VideoPlayerRouteState();
}

class _VideoPlayerRouteState extends State<_VideoPlayerRoute> {
  late final AppVideoPlayerController _controller = widget.isLocalFile
      ? widget.service.file(File(widget.url))
      : widget.service.network(Uri.parse(widget.url));
  late final Future<void> _ready = _initialize();

  // Trong lúc kéo, hiện mốc ngón tay đang chỉ chứ không hiện vị trí thật của
  // trình phát: lệnh tua đi qua nền tảng nên vị trí thật luôn về sau ngón tay
  // một nhịp, và thanh kéo sẽ giật ngược.
  //
  // Là `ValueNotifier` chứ KHÔNG phải trường + `setState`: thanh kéo bắn mỗi
  // khung hình, mà `setState` ở đây dựng lại cả màn — `FutureBuilder`,
  // `AspectRatio`, `VideoPlayer`, tất cả — sáu chục lần mỗi giây. Đó là chỗ
  // sinh ra cảm giác đơ khi kéo. Nay chỉ hàng chứa thanh kéo dựng lại.
  final ValueNotifier<Duration?> _scrubPosition = ValueNotifier(null);

  /// Lượt tua gần nhất còn đang chạy, để không bắn chồng lệnh.
  bool _seeking = false;

  /// Mốc mới nhất ngón tay chỉ tới trong lúc lượt tua trước chưa xong.
  Duration? _pendingSeek;

  /// Ngón tay đã rời thanh kéo, còn chờ lệnh tua cuối đáp xuống.
  bool _scrubEnded = false;

  /// Ảnh xem trước rải đều clip, trích ngầm sau khi màn đã mở.
  ///
  /// Vì sao cần: mỗi lệnh tua của trình phát phải giải mã thật, với clip phát
  /// thẳng từ máy chủ còn phải chờ mạng — vài trăm mili giây một lần, tức kéo
  /// cả một đoạn mới thấy hình nhảy một nấc. Bộ ảnh này nằm sẵn trên máy nên
  /// đổi tức thì: kéo đi kéo lại vẫn bám theo ngón tay.
  final ValueNotifier<List<EcFilmstripFrame>> _frames = ValueNotifier(const []);
  EcVideoTrimService? _thumbnailer;
  bool _disposed = false;

  /// Ảnh gần [at] nhất, hoặc `null` khi chưa trích được ảnh nào.
  EcFilmstripFrame? _frameAt(Duration at) {
    final frames = _frames.value;
    if (frames.isEmpty) return null;
    var best = frames.first;
    for (final frame in frames) {
      final closer = (frame.at - at).abs() < (best.at - at).abs();
      if (closer) best = frame;
    }
    return best;
  }

  /// Trích ảnh xem trước ở nền, sau khi clip đã mở được.
  ///
  /// Chạy sau `_ready` chứ không song song: trước đó chưa biết clip dài bao
  /// nhiêu, mà cũng không nên giành băng thông với chính lượt phát đầu tiên.
  Future<void> _loadThumbnails() async {
    try {
      await _ready;
      final total = _controller.value.duration;
      if (_disposed || total <= Duration.zero) return;
      final service = _thumbnailer ??= EcVideoTrimService();
      await service.sparseFilmstrip(
        input: widget.url,
        duration: total,
        cancelled: () => _disposed,
        onFrame: (frames) {
          if (!_disposed) _frames.value = frames;
        },
      );
    } on Object {
      // Không có ảnh thì thanh kéo chạy y như trước — mất một thứ cho mượt
      // tay, không mất chức năng nào.
    }
  }

  /// Tua theo ngón tay, nhưng mỗi lúc chỉ một lệnh.
  ///
  /// `CupertinoSlider` bắn `onChanged` mỗi khung hình; gửi thẳng ngần ấy lệnh
  /// tua xuống nền tảng là xếp hàng cả trăm lệnh, hình đứng hình và thả tay
  /// rồi video vẫn còn chạy đuổi. Giữ đúng MỘT lệnh đang bay, mốc tới sau đè
  /// lên mốc chờ — thứ người dùng cần là vị trí CUỐI CÙNG của ngón tay.
  Future<void> _seekWhileScrubbing(Duration target) async {
    if (_seeking) {
      _pendingSeek = target;
      return;
    }
    _seeking = true;
    var next = target;
    while (true) {
      await _controller.seekTo(next);
      final queued = _pendingSeek;
      if (queued == null) break;
      _pendingSeek = null;
      next = queued;
    }
    _seeking = false;
    // Chỉ khi hàng tua đã cạn mới trả thanh kéo về bám vị trí thật. Trả sớm
    // hơn thì trình phát còn đang chạy tới mốc cuối, và thanh kéo nhảy ngược
    // về chỗ cũ ngay trước mắt người vừa thả tay.
    if (_scrubEnded) {
      _scrubEnded = false;
      _scrubPosition.value = null;
    }
  }

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
  void initState() {
    super.initState();
    unawaited(_loadThumbnails());
  }

  @override
  void dispose() {
    _disposed = true;
    _frames.dispose();
    _scrubPosition.dispose();
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
                // Chỉ tên loại clip, KHÔNG kèm dòng ngày/giờ: giờ thật do máy
                // chủ nung vào khung hình lúc niêm phong, còn dòng ở đây dựng
                // lại từ `captured_at` nên lệch vài phút với dấu nung.
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
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Center(
                        child: ValueListenableBuilder<VideoPlayerValue>(
                          valueListenable: _controller.valueListenable,
                          // Dựng MỘT lần rồi truyền xuống: trình phát bắn giá
                          // trị mới mỗi khung hình, mà dựng lại `VideoPlayer`
                          // ngần ấy lần là bắt Flutter dựng lại cả kết cấu ảnh.
                          child: VideoPlayer(raw),
                          builder: (context, value, videoChild) => GestureDetector(
                            onTap: _togglePlayPause,
                            child: AspectRatio(
                              aspectRatio: value.aspectRatio == 0
                                  ? 16 / 9
                                  : value.aspectRatio,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Không vẽ lớp ngày/giờ/mã vận đơn ở đây:
                                  // đóng dấu là việc của máy chủ, làm một lần
                                  // lúc niêm phong (`render/server.mjs`) với
                                  // giờ đã trừ lệch đồng hồ máy. App vẽ thêm
                                  // thì chỉ dựng lại từ `captured_at` — hai
                                  // đồng hồ trên cùng một khung là thứ đối
                                  // phương chỉ vào đầu tiên.
                                  videoChild!,
                                  // Trong lúc kéo thì đắp ảnh xem trước lên
                                  // trên: nó nằm sẵn trên máy nên đổi ngay
                                  // theo ngón tay, còn khung hình thật của
                                  // trình phát phải chờ lệnh tua giải mã xong
                                  // — kéo đi kéo lại thì nó chỉ kịp hiện ở
                                  // chỗ dừng cuối cùng.
                                  ValueListenableBuilder<Duration?>(
                                    valueListenable: _scrubPosition,
                                    builder: (context, scrub, _) {
                                      if (scrub == null) {
                                        return const SizedBox.shrink();
                                      }
                                      return ValueListenableBuilder<
                                        List<EcFilmstripFrame>
                                      >(
                                        valueListenable: _frames,
                                        builder: (context, _, __) {
                                          final frame = _frameAt(scrub);
                                          if (frame == null) {
                                            return const SizedBox.shrink();
                                          }
                                          return Positioned.fill(
                                            child: Image.file(
                                              frame.file,
                                              fit: BoxFit.contain,
                                              gaplessPlayback: true,
                                            ),
                                          );
                                        },
                                      );
                                    },
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
                      builder: (context, value, _) => ValueListenableBuilder<Duration?>(
                        valueListenable: _scrubPosition,
                        builder: (context, scrub, _) {
                          final duration = value.duration;
                          final position = scrub ?? value.position;
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
                                    // Nhảy NGAY theo ngón tay, không đợi thả.
                                    //
                                    // Trước đây chỉ tua lúc thả tay, nên kéo tới
                                    // đâu cũng chỉ thấy một con số đổi còn hình
                                    // thì đứng im — không dò được cảnh mình cần.
                                    // Nay hình chạy theo ngón, đúng như thanh
                                    // kéo ở màn cắt.
                                    onChanged: duration.inMilliseconds > 0
                                        ? (v) {
                                            final target = Duration(
                                              milliseconds: v.round(),
                                            );
                                            _scrubPosition.value = target;
                                            unawaited(
                                              _seekWhileScrubbing(target),
                                            );
                                          }
                                        : null,
                                    // Đi qua đúng hàng đợi như lúc đang kéo.
                                    // Gọi thẳng `seekTo` ở đây là chen ngang một
                                    // lệnh chưa đáp, và hai lệnh về không đúng
                                    // thứ tự làm hình nhảy ngược một nhịp.
                                    onChangeEnd: (v) {
                                      final target = Duration(
                                        milliseconds: v.round(),
                                      );
                                      _scrubPosition.value = target;
                                      _scrubEnded = true;
                                      unawaited(_seekWhileScrubbing(target));
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

/// Chỗ dựa khi route chi tiết mở ra mà không có `extra` (deep link, khôi phục
/// state) — sheet rơi về khối "không có dữ liệu" thay vì nổ.
///
/// Là `ValueListenable` rỗng chứ không phải `ValueNotifier`: hằng số này sống
/// suốt đời tiến trình, không ai gọi `dispose` cho nó được.
class _NoVideoDetail implements ValueListenable<EcVideoDetail?> {
  const _NoVideoDetail();

  @override
  EcVideoDetail? get value => null;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}

class _VideoRouteExtra {
  const _VideoRouteExtra({
    required this.video,
    required this.shopId,
    required this.orderId,
    required this.canDelete,
    this.tracking = '',
    this.evidenceId,
    this.fromClaim = false,
  });

  /// Nguồn SỐNG, không phải ảnh chụp lúc bấm: màn đơn hàng ghi đè giá trị này
  /// sau mỗi lần nạp lại, nên sheet thấy link phát ngay khi máy chủ đóng dấu
  /// xong thay vì phải đóng sheet, thoát đơn rồi vào lại.
  final ValueListenable<EcVideoDetail?> video;

  /// Mã vận đơn, để đóng dấu lên clip lúc tải về — `EcVideoDetail` chỉ mang
  /// thông tin của riêng clip, không biết nó thuộc đơn nào.
  final String tracking;
  final String shopId;
  final String orderId;
  final String? evidenceId;
  final bool canDelete;

  /// Sheet mở từ hồ sơ khiếu nại. Hồ sơ chỉ TRỎ tới bằng chứng của đơn, nên ba
  /// hàng bị tắt: người quay (không phải chuyện của bên nhận), cắt đoạn (đẻ ra
  /// tệp không thuộc hồ sơ nào) và xoá video (phá bằng chứng gốc của đơn).
  final bool fromClaim;
}

class _VideoPlayerRouteExtra {
  const _VideoPlayerRouteExtra({
    required this.title,
    required this.url,
    required this.videoPlayerService,
    this.isLocalFile = false,
  });

  final String title;

  /// URL của máy chủ, hoặc đường dẫn tệp trên máy khi [isLocalFile].
  final String url;

  /// Phát bản tạm còn trên máy thay vì tải từ máy chủ. Xem
  /// [EcVideoDetail.localPath] — bản này chưa có dấu giờ trên hình.
  final bool isLocalFile;
  final VideoPlayerService videoPlayerService;
}

class _MemberActionExtra {
  const _MemberActionExtra({required this.shopId, required this.member});

  final String shopId;
  final EcShopMember member;
}

/// Ghép các bằng chứng CHƯA tải xong của đơn vào danh sách.
///
List<EcTimelineDay> _timelineDays(
  AppLocalizations l10n,
  List<EvidenceDto> evidence,
  List<VideoTypeDto> videoTypes,
  Map<String, String> memberNames,
  Map<String, String> previews,
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
            label: switch (typeNames[item.videoTypeId]) {
              final name? => _videoTypeLabel(l10n, name),
              _ => _kindLabel(l10n, item.kind),
            },
            type: item.kind == 'photo'
                ? EcEvidenceType.image
                : EcEvidenceType.video,
            // Photos preview themselves; a clip needs its extracted poster.
            thumbUrl: item.kind == 'photo' ? item.url : item.thumbUrl,
            seal: _sealLine(l10n, item),
            timeDrift: item.timeCheck == 'TIME_DRIFT',
            // Tải lên xong KHÔNG phải là xong: máy chủ còn đóng dấu giờ lên
            // hình rồi niêm phong. Bỏ trống ô trạng thái ở giai đoạn đó khiến
            // người bán tưởng đã có bằng chứng hoàn chỉnh và đem link đi khiếu
            // nại một bản chưa có dấu.
            statusText: item.uploadStatus == 'done'
                ? (item.isSealing ? l10n.sealWorking : null)
                : item.uploadStatus == 'expired'
                ? _expiredLabel(l10n, item.retentionExpiresAt)
                : _uploadStatusLabel(l10n, item.uploadStatus),
            statusTone: item.isSealing
                ? EcStatusTone.waiting
                : switch (item.uploadStatus) {
                    'done' => EcStatusTone.done,
                    'error' => EcStatusTone.error,
                    'quota_hold' => EcStatusTone.quota,
                    // Hết hạn lưu trữ / đã xóa là kết thúc, không phải lỗi đang
                    // chờ xử lý — khung design không có viên riêng nên dùng xám
                    // trung tính thay vì đỏ.
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
            // Chỉ gắn khi máy chủ CHƯA phát được. Có link thật rồi mà vẫn trỏ
            // về bản tạm là cố tình phát bản không dấu trong khi bản có dấu đã
            // nằm sẵn ở kho.
            localPath: item.url == null ? previews[item.id] : null,
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
  const _ClaimListRoute({
    required this.shopId,
    this.onNavOrders,
    this.onNavRecord,
    this.onCreate,
  });

  final String shopId;
  final VoidCallback? onNavOrders;
  final VoidCallback? onNavRecord;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _claimStore,
    builder: (context, _) {
      final dossiers = _claimStore.forShop(shopId);
      return EcClaimListScreen(
        onNavOrders: onNavOrders,
        onNavRecord: onNavRecord,
        onCreate: onCreate,
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

/// Màn tạo hồ sơ khiếu nại: tra một mã đơn rồi tick bằng chứng của nó.
///
/// Tra bằng `searchOrders` chứ không lọc danh sách đã nạp: người bán vào đây
/// với một mã cụ thể trong tay, mà mã đó thường là đơn cũ đã trôi khỏi trang
/// đầu. Lọc tại chỗ thì gõ đúng mã vẫn ra rỗng.
class _CreateClaimRoute extends StatelessWidget {
  const _CreateClaimRoute({
    required this.repo,
    required this.shopId,
    this.onScan,
    this.onBack,
  });

  final EcRepository repo;
  final String shopId;
  final Future<String?> Function()? onScan;
  final VoidCallback? onBack;

  /// `null` = không có đơn nào mang mã đó; danh sách rỗng = đơn có thật nhưng
  /// chưa có bằng chứng. Hai thứ khác nhau nên màn hình nói hai câu khác nhau.
  Future<List<EcClaimPickable>?> _search(
    BuildContext context,
    String code,
  ) async {
    final l10n = context.l10n;
    try {
      final hits = await repo.searchOrders(shopId, code);
      final match = hits.where(
        (o) => o.tracking.toLowerCase() == code.toLowerCase(),
      );
      if (match.isEmpty) return null;
      final detail = await repo.order(shopId, match.first.id);
      // Tên loại video, không phải chữ "Video" chung chung.
      //
      // Cả đơn đều là "Video" thì danh sách không nói được cái nào là đóng
      // hàng, cái nào là trả hàng — mà đó chính là thứ quyết định người bán
      // tick cái nào để đi khiếu nại. Hỏng thì rơi về nhãn chung.
      final typeNames = <String, String>{};
      try {
        for (final t in await repo.videoTypes(shopId)) {
          typeNames[t.id] = t.name;
        }
      } on Object {
        // Danh sách loại chỉ làm nhãn đẹp hơn, không chặn việc chọn.
      }
      return [
        for (final e in detail.evidence)
          if (e.uploadStatus != 'deleted')
            EcClaimPickable(
              id: e.id,
              orderId: match.first.id,
              label: typeNames[e.videoTypeId] ?? _kindLabel(l10n, e.kind),
              time: _hhmm(DateTime.fromMillisecondsSinceEpoch(e.capturedAt)),
              isPhoto: e.kind == 'photo',
              capturedAt: e.capturedAt,
              day: _dayLabelOf(
                DateTime.fromMillisecondsSinceEpoch(e.capturedAt),
              ),
              // Ảnh TỰ làm ảnh xem trước; chỉ video mới cần poster trích ra.
              // Dùng `thumbUrl` cho cả hai thì mọi hàng ảnh đều trống chỗ đó.
              thumbUrl: e.kind == 'photo' ? e.url : e.thumbUrl,
            ),
      ];
    } on Object {
      // Mạng hỏng đọc ra y như "không tìm thấy mã" — cùng một màn hình rỗng.
      // Chấp nhận được vì bước sau của người dùng giống nhau: thử lại.
      return null;
    }
  }

  Future<void> _create(
    BuildContext context,
    List<EcClaimOrderPicks> batch,
  ) async {
    final l10n = context.l10n;
    final now = DateTime.now();
    final claim = await _publish(batch);
    // Chụp lại NGUYÊN nội dung chứ không giữ id rồi tra sau: clip có hạn lưu
    // trữ, mà hồ sơ khiếu nại phải nói được nó ĐÃ gồm những gì.
    await _claimStore.add(
      EcClaimDossier(
        id: now.microsecondsSinceEpoch.toString(),
        shopId: shopId,
        createdAt: now,
        // Giữ id của máy chủ chứ không chỉ link: đây là thứ duy nhất thu hồi
        // được về sau. Chỉ lưu link thì nút xoá chỉ xoá được bản trên máy.
        claimId: claim?.id,
        shareUrl: claim?.url,
        orders: [
          for (final order in batch)
            EcClaimOrder(
              tracking: order.orderCode,
              // Id của đơn trên máy chủ. Thiếu nó thì màn hồ sơ không đọc được
              // chi tiết bằng chứng về sau, và những dòng như thời lượng hay
              // thiết bị quay đứng trống mãi.
              orderId: order.picked
                  .map((e) => e.orderId)
                  .firstWhere((id) => id != null, orElse: () => null),
              evidence: [
                for (final e in order.picked)
                  EcClaimEvidence(
                    id: e.id,
                    label: e.label,
                    time: e.time,
                    isPhoto: e.isPhoto,
                    capturedAt: e.capturedAt,
                    thumbUrl: e.thumbUrl,
                  ),
              ],
            ),
        ],
      ),
    );
    if (!context.mounted) return;
    _toast(
      context,
      claim == null ? l10n.claimsCreatedLocalOnly : l10n.claimsCreated,
    );
    onBack?.call();
  }

  /// Đẩy hồ sơ lên máy chủ để nó có một địa chỉ công khai gửi được cho sàn.
  ///
  /// Trả `null` khi không gửi được — và khi đó hồ sơ VẪN được lưu trên máy.
  /// Người bán vừa tick xong một danh sách đơn; bắt họ làm lại vì mất mạng là
  /// trừng phạt họ vì lỗi của mạng. Đổi lại, màn hình phải nói thẳng là chưa
  /// có link, chứ không để họ tưởng bằng chứng đã chia sẻ được.
  Future<ClaimDto?> _publish(List<EcClaimOrderPicks> batch) async {
    try {
      // Mã vận đơn → id đơn. `_search` đã tra ra id này lúc người dùng gõ mã,
      // nhưng màn là StatelessWidget nên không giữ lại được; tra lại một lượt
      // song song vẫn rẻ hơn nhiều so với dựng thêm một tầng trạng thái.
      final ids = await Future.wait(
        batch.map((order) async {
          final hits = await repo.searchOrders(shopId, order.orderCode);
          final match = hits.where(
            (o) => o.tracking.toLowerCase() == order.orderCode.toLowerCase(),
          );
          return match.isEmpty ? null : match.first.id;
        }),
      );
      final resolved = <String>[];
      // Những clip người bán ĐÃ TICK. Thiếu danh sách này thì trang công khai
      // hiện đủ mọi bằng chứng của đơn — người bán chọn 2 trong 5 clip, gửi
      // link cho sàn, sàn xem cả 5. Chỉ gom của những đơn tra ra được id: đơn
      // hỏng thì id clip của nó cũng vô nghĩa.
      final picked = <String>[];
      for (var i = 0; i < batch.length; i++) {
        final id = ids[i];
        if (id == null) continue;
        resolved.add(id);
        picked.addAll(batch[i].picked.map((e) => e.id));
      }
      if (resolved.isEmpty) return null;
      // `await`, KHÔNG `return` trần: trả thẳng Future ra là nó hỏng SAU khi
      // hàm đã rời khối `try`, nên `catch` bên dưới không bao giờ thấy. Lúc đó
      // lời hứa "gửi hỏng thì trả null và vẫn lưu trên máy" ngay trên kia bị
      // thủng — máy chủ trả lỗi là chết cả lượt tạo hồ sơ.
      return await repo.createClaim(
        shopId,
        resolved,
        evidenceIds: picked.isEmpty ? null : picked,
      );
    } on Object catch (error, stack) {
      developer.log(
        'claims: không gửi được hồ sơ lên máy chủ (${error.runtimeType})',
        name: 'zenpack.claims',
        level: 1000,
        error: error,
        stackTrace: stack,
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) => EcCreateClaimScreen(
    onBack: onBack,
    onScan: onScan,
    onSearch: (code) => _search(context, code),
    // Bọc bắt lỗi: `_create` chạy ngoài luồng dựng UI, nên một ngoại lệ ở
    // giữa chừng (mạng chết lúc đẩy hồ sơ, ghi đĩa hỏng) sẽ biến mất không
    // dấu vết — người dùng bấm nút và KHÔNG có gì xảy ra, không cả báo lỗi.
    onCreate: (batch) => unawaited(
      _create(context, batch).catchError((Object error, StackTrace stack) {
        developer.log(
          'claims: tạo hồ sơ hỏng (${error.runtimeType})',
          name: 'zenpack.claims',
          level: 1000,
          error: error,
          stackTrace: stack,
        );
        if (context.mounted) {
          _toast(context, _dataErrorText(context.l10n, error));
        }
      }),
    ),
  );
}

/// Ngày và giờ của bằng chứng MỚI NHẤT trong một mã đơn, cho dòng tiêu đề của
/// lớp con.
///
/// Lấy cái mới nhất chứ không cái đầu: một đơn quay nhiều lần thì mốc đáng nhớ
/// là lần cuối. `null` khi không bằng chứng nào có mốc thời gian — hồ sơ tạo
/// trước khi trường đó được lưu — và lúc đó dòng chỉ hiện mã, không bịa ngày.
(String, String)? _claimOrderStamp(EcClaimOrder order) {
  int? newest;
  for (final e in order.evidence) {
    final at = e.capturedAt;
    if (at != null && (newest == null || at > newest)) newest = at;
  }
  if (newest == null) return null;
  final at = DateTime.fromMillisecondsSinceEpoch(newest);
  return (_dayLabelOf(at), _hhmm(at));
}

/// Sao chép link hồ sơ, hoặc nội dung hồ sơ khi chưa có link.
///
/// Bản chữ là đường lùi cho hồ sơ tạo lúc mất mạng: dán thẳng vào khung chat
/// CSKH của sàn, người đọc không cần app nào để mở.
void _copyClaimSummary(BuildContext context, EcClaimDossier dossier) {
  final l10n = context.l10n;
  final url = dossier.shareUrl;
  final hasLink = url != null && url.isNotEmpty;
  // Ưu tiên LINK: một dòng, mở ra là người kiểm duyệt xem được cả vụ với đủ
  // video, mốc giờ và mã vận đơn — thứ một khối chữ dán vào ô chat không làm
  // được. Chưa có link thì lùi về bản chữ, vẫn dán được vào bất cứ đâu.
  Clipboard.setData(
    ClipboardData(
      text: hasLink
          ? url
          : ecClaimSummaryText(dossier, title: l10n.claimsTitle),
    ),
  );
  _toast(context, hasLink ? l10n.claimsLinkCopied : l10n.claimsCopied);
}

/// Lớp con: nội dung một hồ sơ — từng mã vận đơn và bằng chứng của nó, cộng
/// một hàng đính kèm ảnh dưới mỗi mã đơn.
class _ClaimDetailRoute extends StatelessWidget {
  const _ClaimDetailRoute({
    required this.repo,
    required this.shopId,
    required this.dossierId,
    required this.queue,
    this.budget,
    this.onBack,
    this.videoPlayer,
    this.downloader,
    this.share,
    this.gallery,
  });

  final EcRepository repo;
  final String shopId;
  final String dossierId;
  final EcUploadQueue queue;
  final ClipBudget? budget;
  final VoidCallback? onBack;

  /// Để mở, phát và tải một bằng chứng ngay trong hồ sơ. Thiếu cái nào thì
  /// hàng tương ứng tự ẩn, không dựng nút bấm vào không chạy.
  final VideoPlayerService? videoPlayer;
  final Dio? downloader;
  final ShareService? share;
  final GallerySaveService? gallery;

  /// Mở chi tiết một bằng chứng ngay trong hồ sơ, dùng ĐÚNG sheet của màn Vận
  /// đơn để hai nơi nhìn giống nhau.
  ///
  /// Ba hàng bị tắt, và mỗi hàng một lý do khác nhau:
  /// - **Người quay**: hồ sơ là thứ đem đi làm việc với sàn, ai trong shop bấm
  ///   nút quay không phải chuyện của bên nhận.
  /// - **Cắt đoạn ngắn** và **Xoá video**: hồ sơ chỉ TRỎ tới bằng chứng của
  ///   đơn. Cắt ở đây đẻ ra một tệp không thuộc hồ sơ nào, còn xoá thì phá
  ///   bằng chứng gốc của đơn — cả hai đều thuộc màn Vận đơn.
  ///
  /// Thời lượng và thiết bị KHÔNG có trong hồ sơ — hồ sơ chỉ giữ nhãn, giờ,
  /// link và ảnh thu nhỏ. Nên đọc thẳng chi tiết đơn theo `orderId` để lấy đủ.
  /// Đọc hỏng, hoặc hồ sơ cũ chưa lưu `orderId`, thì rơi về những gì hồ sơ có
  /// và hai dòng đó ghi `—`: để trống vẫn hơn bịa ra một giá trị.
  Future<void> _openClaimEvidence(
    BuildContext context,
    EcClaimDossier dossier,
    String tracking,
    String evidenceId,
  ) async {
    final order = dossier.orders
        .where((o) => o.tracking == tracking)
        .firstOrNull;
    final item = order?.evidence.where((e) => e.id == evidenceId).firstOrNull;
    if (item == null) return;
    final l10n = context.l10n;
    final url = item.url;

    EvidenceDto? full;
    final orderId = order?.orderId;
    if (orderId != null && orderId.isNotEmpty) {
      try {
        final detail = await repo.order(shopId, orderId);
        full = detail.evidence.where((e) => e.id == evidenceId).firstOrNull;
      } on Object catch (error, stack) {
        developer.log(
          'claims: không đọc được chi tiết bằng chứng (${error.runtimeType})',
          name: 'zenpack.claims',
          level: 900,
          error: error,
          stackTrace: stack,
        );
      }
    }
    // Hồ sơ bằng chứng chỉ có `created_by_uid`, không có tên. Tra danh sách
    // thành viên để đổi uid thành tên người — hỏng thì rơi về chuỗi mặc định,
    // vì một cái uid dài loằng ngoằng còn khó hiểu hơn là không nói tên.
    var recordedBy = item.addedBy ?? l10n.recordedByFallback;
    final uid = item.addedBy != null ? null : full?.createdByUid;
    if (uid != null && uid.isNotEmpty) {
      try {
        final members = await repo.members(shopId);
        final hit = members.where((m) => m.accountUid == uid).firstOrNull;
        final name = hit?.name ?? hit?.email;
        if (name != null && name.isNotEmpty) recordedBy = name;
      } on Object {
        // Đọc thành viên hỏng chỉ mất cái tên, không chặn mở chi tiết.
      }
    }
    if (!context.mounted) return;

    final captured = full == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(full.capturedAt);
    // Mở ĐÚNG sheet chi tiết của màn Vận đơn qua route `/video`, không dựng
    // bản rút gọn riêng: bản riêng luôn thiếu hàng (cắt đoạn, xoá, tải về) và
    // mỗi lần phát hiện thiếu lại phải vá thêm. Hồ sơ có sẵn `orderId` và
    // `evidenceId` nên đủ dữ liệu cho mọi hành động của sheet đó.
    final detail = ValueNotifier<EcVideoDetail?>(
      EcVideoDetail(
        title: item.label,
        capturedAtMs: full?.capturedAt,
        durationSeconds: full?.durationSeconds,
        duration: _durationLabel(full?.durationSeconds),
        recordedAt: captured == null
            ? item.time
            : '${_dateLabel(captured)}  ${_hhmm(captured)}',
        recordedBy: recordedBy,
        device: full?.device ?? l10n.deviceUnknown,
        uploadStatus: l10n.uploaded,
        seal: full == null || item.isPhoto ? null : _sealLine(l10n, full),
        tracking: tracking,
        mediaUrl: url ?? full?.url,
        type: item.isPhoto ? EcEvidenceType.image : EcEvidenceType.video,
      ),
    );
    unawaited(
      GoRouter.of(context).push(
        '/video',
        extra: _VideoRouteExtra(
          video: detail,
          shopId: shopId,
          orderId: order?.orderId ?? '',
          evidenceId: evidenceId,
          tracking: tracking,
          canDelete: false,
          fromClaim: true,
        ),
      ),
    );
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
      // Dùng CHÍNH màn dòng thời gian của mã vận đơn, không dựng bản sao.
      //
      // Bản trước chép lại hình dạng của hàng sang màn khiếu nại, nên nó giống
      // mà không bằng: thiếu huy hiệu trạng thái, thiếu menu ⋮, giờ và ảnh lệch
      // nhau — và mỗi lần phát hiện một chỗ lệch lại phải vá thêm một miếng.
      // Dùng chung widget thì về sau sửa màn Vận đơn là màn này đổi theo.
      //
      // Những việc không thuộc về hồ sơ (đính kèm ảnh, gộp link, thử lại
      // upload) truyền `null` — màn đó tự ẩn hàng khi callback rỗng.
      final days = <EcTimelineDay>[];
      for (final order in dossier.orders) {
        days.add(
          EcTimelineDay(
            date: order.tracking,
            videos: [
              for (final e in order.evidence)
                EcTimelineVideo(
                  id: e.id,
                  time: e.time,
                  label: e.label,
                  type: e.isPhoto ? EcEvidenceType.image : EcEvidenceType.video,
                  thumbUrl: e.thumbUrl ?? e.url,
                  mediaUrl: e.url,
                  capturedAtMs: e.capturedAt,
                ),
            ],
          ),
        );
      }
      return EcOrderTimelineScreen(
        orderCode:
            '${_dayLabelOf(dossier.createdAt)}  '
            '${_hhmm(dossier.createdAt)}',
        days: days,
        onBack: onBack,
        onCopyCode: () => _copyClaimSummary(context, dossier),
        onVideoTap: (video) => unawaited(
          _openClaimEvidence(
            context,
            dossier,
            _trackingOf(dossier, video.id) ?? '',
            video.id ?? '',
          ),
        ),
      );
    },
  );
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

/// Mã vận đơn chứa bằng chứng [evidenceId] trong hồ sơ, hoặc `null`.
String? _trackingOf(EcClaimDossier dossier, String? evidenceId) {
  if (evidenceId == null) return null;
  for (final o in dossier.orders) {
    if (o.evidence.any((e) => e.id == evidenceId)) return o.tracking;
  }
  return null;
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
  localPath: video.localPath,
  type: video.type,
  seal: video.seal,
  timeDrift: video.timeDrift,
);

/// Turns `seal_status` into the one line the detail sheet shows.
///
/// Photos never enter the chain, so they get no row at all rather than a row
/// saying "no". And `null` is deliberately NOT worded like `pending`: clips
/// recorded before the sealing stage exists will sit at `null` forever, so
/// calling that "in progress" leaves the user waiting for something that is
/// never coming.
EcSealLine? _sealLine(AppLocalizations l10n, EvidenceDto item) {
  if (item.kind == 'photo') return null;
  return switch (item.sealStatus) {
    // `sealed` ⇒ renderer đã ghi đè bản thô ở R2 bằng bản có dấu giờ + mã vận
    // đơn nung vào khung hình (services/render.ts ký PUT lên đúng `r2_key`).
    'sealed' => EcSealLine(
      label: l10n.sealSealed(_sealedAtLabel(item.sealedAt)),
    ),
    'pending' || 'rendering' => EcSealLine(
      label: l10n.sealWorking,
      inProgress: true,
    ),
    'render_failed' => EcSealLine(label: l10n.sealFailed),
    'hash_mismatch' => EcSealLine(label: l10n.sealMismatch),
    _ => EcSealLine(label: l10n.sealNone),
  };
}

String _sealedAtLabel(int? sealedAt) {
  if (sealedAt == null) return '';
  final at = DateTime.fromMillisecondsSinceEpoch(sealedAt);
  return '${_dateLabel(at)} · ${_hhmm(at)}';
}

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
  });

  final EcUploadQueue queue;

  /// FR-02 — Nhân viên không được xóa bằng chứng, kể cả clip **chưa upload**
  /// còn nằm trong hàng đợi trên máy: xóa ở đây là mất vĩnh viễn và backend
  /// chưa có bản sao nào để chặn hộ.
  final bool canDelete;
  final VoidCallback? onBack;

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
          onClear: () => _confirmClearQueue(context, queue),
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

/// Mở hàng đợi ngay tại màn quay, dạng sheet kéo lên nửa màn.
///
/// Không đẩy sang màn khác: người đang đóng gói liếc xem "clip vừa quay lên
/// chưa" rồi quay tiếp, mà rời hẳn màn quay là mất khung ngắm và mất luôn cả
/// mã vận đơn đang chọn. Nửa màn để phần trên vẫn thấy được chỗ mình vừa đứng.
Future<void> _showQueueSheet(BuildContext context, EcUploadQueue queue) =>
    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => _QueueSheet(queue: queue),
    );

class _QueueSheet extends StatelessWidget {
  const _QueueSheet({required this.queue});

  final EcUploadQueue queue;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.5,
      decoration: const BoxDecoration(
        color: BrandColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        children: [
          // Không vẽ tay nắm và không có nút đóng: bấm ra ngoài tấm này là về
          // thẳng màn quay, mà nền phía sau chiếm nửa màn nên chỗ bấm rất rộng.
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.uploadQueueTitle,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: BrandColors.ink,
                    ),
                  ),
                ),
                // Xoá CẢ hàng đợi. Có hỏi lại, khác hẳn dấu × của từng hàng:
                // một hàng bấm nhầm thì quay lại một clip, còn cả hàng đợi bấm
                // nhầm là mất mọi clip chưa kịp lên — thứ chỉ tồn tại trên
                // chính cái máy này.
                //
                // Hiện cho MỌI vai trò, không khoá theo `canDelete`.
                //
                // FR-02 cấm nhân viên xoá bằng chứng, và bản trước khoá nút này
                // theo đúng quy tắc đó. Chủ sản phẩm chọn ngược lại: người cầm
                // máy phải tự dọn được hàng đợi trên máy mình. Thứ bị xoá ở đây
                // là bản CHƯA lên máy chủ, nên hộp xác nhận nói thẳng "xoá là
                // mất hẳn" — đó là hàng rào duy nhất còn lại.
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  onPressed: () => _confirmClearQueue(context, queue),
                  child: Text(
                    l10n.queueClearAction,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: BrandColors.rec,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: queue,
              builder: (context, _) => EcUploadQueueList(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                items: [for (final task in queue.tasks) _taskToItem(task)],
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
                // Xoá THẲNG, không hỏi lại: ở màn quay người dùng đang dọn một
                // hàng bấm nhầm giữa lúc đóng gói, và mỗi hộp thoại là một lần
                // họ phải rời mắt khỏi thùng hàng. Lượt xoá cả hàng đợi mới là
                // chỗ cần hỏi. Cũng không khoá theo vai trò, cùng lý do với nút
                // Xoá hết ở trên.
                onDelete: (item) {
                  final id = item.id;
                  if (id != null) unawaited(queue.delete(id));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Hỏi lại rồi xoá SẠCH hàng đợi.
///
/// Có hỏi, khác hẳn dấu × của từng hàng: bấm nhầm một hàng thì mất một clip,
/// bấm nhầm ở đây là mất mọi clip chưa kịp lên — thứ chỉ tồn tại trên đúng cái
/// máy đang cầm.
Future<void> _confirmClearQueue(
  BuildContext context,
  EcUploadQueue queue,
) async {
  final l10n = context.l10n;
  final confirmed = await showCupertinoDialog<bool>(
    context: context,
    builder: (dialogContext) => CupertinoAlertDialog(
      title: Text(l10n.queueClearConfirmTitle),
      content: Text(l10n.queueClearConfirmBody),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.commonCancel),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.queueClearAction),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  await queue.clearAll();
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
            onAccount: () => c.push('/account'),
            onSelect: (shop) {
              selectedShop.value = shop;
              _rememberShop(shop);
              _analytics()?.trackShopSelected(platform: shop.platform);
              c.go('/home');
            },
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
        path: '/create-shop',
        builder: (c, s) => _CreateShopRoute(
          repo: repo,
          onBack: () => _back(c, '/shops'),
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
                    // Bánh răng vào THẲNG chi tiết cửa hàng của shop đang mở.
                    //
                    // Trước nó qua màn Quản lý cửa hàng — một danh sách shop,
                    // mà người dùng đã ở trong đúng một shop rồi: bắt họ chọn
                    // lại chính cái đang mở là một bước thừa. Màn đó đã bỏ.
                    onSettings: () => c.push('/shop-detail', extra: shop),
                    onNavRecord: () => c.go('/record'),
                    onNavClaims: () => c.go('/claims'),
                    // Vận đơn giữ màn hàng đợi ĐẦY ĐỦ: ở đây người dùng
                    // đang ngồi rà soát, không phải đang cầm máy quay.
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
                      onQueueTap: () => _showQueueSheet(c, queue),
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
                                  // Cupertino chứ không Material: app chạy
                                  // trong `CupertinoApp`, nên mọi route khác
                                  // trượt ngang kiểu iOS. `MaterialPageRoute`
                                  // không có Material theme để tra, nên nó rơi
                                  // về mặc định của TỪNG NỀN — trượt ngang
                                  // trên iOS, phóng to trên Android. Đúng một
                                  // đường vào màn này lại mở kiểu khác hẳn,
                                  // và chỉ trên một nền.
                                  CupertinoPageRoute(
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
                                          .push(
                                            '/invite-member',
                                            extra: shop.id,
                                          )
                                          .then((_) {}),
                                      onShopQr: () =>
                                          _showShopJoinQr(c, repo, shop.id),
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
                      onNavClaims: () => c.go('/claims'),
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
          // Tab thứ ba nay là Hồ sơ khiếu nại. Tài khoản rời khỏi shell và
          // thành một route đẩy từ màn Chọn cửa hàng — nó là thứ mỗi ca chạm
          // một lần, không đáng chiếm ô tab của việc làm hằng giờ.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/claims',
                builder: (c, s) => _ClaimListRoute(
                  shopId: _selected(selectedShop)?.id ?? '',
                  onNavOrders: () => c.go('/home'),
                  onNavRecord: () => c.go('/record'),
                  onCreate: () => c.push('/create-claim'),
                ),
              ),
            ],
          ),
        ],
      ),
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
                  extra.video.value?.type == EcEvidenceType.image
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
              builder: (pageContext) => ValueListenableBuilder<EcVideoDetail?>(
                valueListenable: extra?.video ?? const _NoVideoDetail(),
                builder: (context, live, _) => EcVideoDetailScreen(
                  video:
                      live ??
                      EcVideoDetail(
                        title: c.l10n.noVideoDataTitle,
                        duration: '—',
                        recordedAt: '—',
                        recordedBy: '—',
                        device: '—',
                        uploadStatus: '—',
                      ),
                  canDelete: extra?.canDelete ?? false,
                  showRecordedBy: !(extra?.fromClaim ?? false),
                  onClose: () => c.pop(),
                  onCopyLink: () {
                    final url = live?.mediaUrl;
                    if (url == null) {
                      _toast(pageContext, c.l10n.toastVideoNoPlayLink);
                      return;
                    }
                    _copyText(pageContext, url, c.l10n.assetLinkTitle);
                  },
                  onPlay: () {
                    // Bản của máy chủ trước; chưa có thì rơi về bản tạm còn
                    // trên máy. Thứ tự này quan trọng: có bản đã đóng dấu rồi
                    // thì phát nó, không phát bản thô.
                    final url = live?.mediaUrl ?? live?.localPath;
                    if (url == null || videoPlayer == null) {
                      _toast(pageContext, c.l10n.toastVideoNoPlayLink);
                      return;
                    }
                    c.push(
                      '/video-player',
                      extra: _VideoPlayerRouteExtra(
                        title: live!.title,
                        url: url,
                        isLocalFile: live.mediaUrl == null,
                        videoPlayerService: videoPlayer,
                      ),
                    );
                  },
                  onDownload: () {
                    if (live?.mediaUrl == null) {
                      _toast(pageContext, c.l10n.toastVideoNoDownloadLink);
                      return;
                    }
                    _downloadAndShareVideo(
                      pageContext,
                      downloader,
                      share,
                      gallery,
                      live!,
                    );
                  },
                  onTrim: videoPlayer == null || (extra?.fromClaim ?? false)
                      ? null
                      : () => _trimAndShareVideo(
                          pageContext,
                          downloader,
                          share,
                          gallery,
                          videoPlayer,
                          live,
                          extra?.tracking ?? live?.tracking ?? '',
                        ),
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
                          .deleteEvidence(
                            extra.shopId,
                            extra.orderId,
                            evidenceId,
                          )
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
                              _toast(
                                pageContext,
                                _dataErrorText(c.l10n, error),
                              );
                            }
                          }),
                    );
                  },
                ),
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
              builder: (pageContext) => ValueListenableBuilder<EcVideoDetail?>(
                valueListenable: extra?.video ?? const _NoVideoDetail(),
                builder: (context, live, _) => EcPhotoDetailScreen(
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
                              _toast(
                                pageContext,
                                _dataErrorText(c.l10n, error),
                              );
                            }
                          }
                        },
                  photo:
                      live ??
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
                    final url = live?.mediaUrl;
                    if (url == null) {
                      _toast(pageContext, c.l10n.toastPhotoNoDownloadLink);
                      return;
                    }
                    _copyText(pageContext, url, c.l10n.assetLinkTitle);
                  },
                  onDownload: () {
                    if (live == null) return;
                    _downloadAndSavePhoto(
                      pageContext,
                      downloader,
                      share,
                      gallery,
                      live,
                    );
                  },
                ),
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
            url: extra.url,
            isLocalFile: extra.isLocalFile,
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
              onRetry: () => c.go('/shops'),
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
            onBack: () => _back(c, '/home'),
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
            onShopQr: readOnly
                ? null
                : () async => _showShopJoinQr(c, repo, shop.id),
            // Kho lưu trữ KHÔNG khoá theo `readOnly`: nhân viên phải xem
            // được kho đang ra sao — máy chủ mở `GET` cho mọi vai trò.
            onTapStorage: () => c
                .push<void>('/storage', extra: (shop.id, shop.role == 'owner'))
                .then((_) {}),
            onDeleteShop: readOnly
                ? null
                : () => _confirmDeleteShop(c, repo, shop),
            onRenameShop: readOnly
                ? null
                : () async => _renameShop(c, repo, shop, selectedShop),
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
                      selectedShop.value = _shopFromDto(c.l10n, shop);
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
        path: '/storage',
        builder: (c, s) {
          // `(shopId, canManage)`: vai trò đi kèm chứ không đọc lại — màn này
          // mở cho mọi vai trò, chỉ chủ shop mới thấy nút đổi kho.
          final (shopId, canManage) = s.extra is (String, bool)
              ? s.extra! as (String, bool)
              : (_selected(selectedShop)?.id ?? '', false);
          return _StorageRoute(
            repo: repo,
            shopId: shopId,
            canManage: canManage,
            onBack: () => _back(c, '/shop-detail'),
          );
        },
      ),
      GoRoute(
        path: '/storage-connect',
        builder: (c, s) => _StorageConnectRoute(
          repo: repo,
          shopId: s.extra is String ? s.extra! as String : '',
        ),
      ),
      GoRoute(
        path: '/login-methods',
        builder: (c, s) => _LoginMethodsRoute(auth: auth),
      ),
      // --- account sub-screens (pushed, back via pop) ---
      GoRoute(
        path: '/quota',
        builder: (c, s) => _QuotaRoute(
          repo: repo,
          queue: queue,
          shopId: _selected(selectedShop)?.id,
        ),
      ),
      GoRoute(
        path: '/create-claim',
        builder: (c, s) => _CreateClaimRoute(
          repo: repo,
          shopId: _selected(selectedShop)?.id ?? '',
          onScan: () => c.push<String>('/scan'),
          onBack: () => _back(c, '/claims'),
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
            repo: repo,
            shopId: shopId,
            dossierId: dossierId,
            queue: queue,
            budget: _selected(selectedShop)?.clipBudget,
            onBack: () => _back(c, '/claims'),
          );
        },
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

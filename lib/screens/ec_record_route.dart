/// Live camera recording route (FR-01) — a thin view over
/// [RecordingSessionBloc].
///
/// Hands-free: a bill auto-starts recording; a *different* bill mid-clip cuts
/// over to the next order seamlessly (SC-2); the printed end-QR closes the
/// session; a 15' hard cap auto-closes a forgotten clip. Backgrounding finalizes
/// the in-progress clip before releasing the camera (FR-08/FR-09). All of that
/// logic lives in [RecordingSessionBloc]; this widget only renders state and
/// forwards taps/lifecycle as events.
library;

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'dart:ui' as ui;

import 'package:analytics/analytics.dart';
import 'package:app_platform/app_platform.dart';
import 'package:ec_ui/ec_ui.dart'
    show
        LucideIcons,
        PenColors,
        PenOutlineButton,
        PenPrimaryButton,
        PenScreen,
        PenText;
import 'package:feature_capture/feature_capture.dart';
import 'package:flutter/cupertino.dart'
    show
        CupertinoActivityIndicator,
        CupertinoAlertDialog,
        CupertinoDialogAction,
        showCupertinoDialog;
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show EventChannel;
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';

import '../app/di/injection.dart';
import '../ec_app.dart' show ecPendingRecordCode, ecRememberPendingRecord;

/// The recording route mounted at `/record`. Callbacks stay routing-agnostic so
/// the app shell owns navigation; [onRequestCode] returns the tracking code the
/// user entered (or `null` if they cancelled).
class EcRecordRoute extends StatefulWidget {
  const EcRecordRoute({
    this.onBack,
    this.onQueueTap,
    this.onRequestCode,
    this.onConfirmManualCode,
    this.onRequestType,
    this.onNavOrders,
    this.onNavClaims,
    this.onSettings,
    this.onSaved,
    this.deviceConditions,
    this.verifyReturnCode,
    this.voiceAnnouncer,
    this.permissions,
    this.initialType = kEcDefaultVideoType,
    this.queueCount = 0,
    this.initialResolution = '720p',
    this.maxRecording = const Duration(minutes: 2),
    this.camera,
    this.isActive,
    super.key,
  });

  /// Tầng quyền của hệ điều hành. Null (test, nền tảng không có quyền) nghĩa là
  /// coi như đã được cấp và dựng camera thẳng.
  ///
  /// Quyền camera chỉ được hỏi ở đây — lúc người dùng thực sự vào màn quay —
  /// và chỉ sau khi họ bấm "Tiếp tục" ở phần giải thích. Từ chối thì màn hình
  /// nói rõ lý do và ở lại trong app; app không bao giờ tự mở Cài đặt.
  final PermissionService? permissions;

  /// Called when the header back chevron is tapped.
  final VoidCallback? onBack;

  /// Called when the header upload chip is tapped — opens the upload-queue
  /// screen. Đang quay thì chốt clip trước khi rời màn, y như nút back.
  final VoidCallback? onQueueTap;

  /// Asks for a tracking code (opens the manual-entry sheet); starting a
  /// recording is gated on a non-empty result.
  final Future<String?> Function()? onRequestCode;

  /// Confirms that a manually typed code may start recording. The app shell
  /// uses this to find an existing shipment or ask before creating a new one.
  final Future<bool> Function(String code)? onConfirmManualCode;

  /// Called when the "Vận đơn" tab is tapped.
  final VoidCallback? onNavOrders;

  /// Called when the "Tài khoản" tab is tapped.
  final VoidCallback? onNavClaims;

  /// Asks for a video type (opens the type sheet); the chosen label is applied
  /// to the current/next recording. Returns `null` if dismissed.
  /// Mở sheet chọn loại. `mandatory` bật ở lần mở tự động lúc vừa vào màn:
  /// lúc đó chọn loại là bắt buộc nên sheet không cho vuốt xuống hay chạm nền
  /// để bỏ qua — chỉ chọn, hoặc bấm back để sang tab Vận đơn.
  final Future<String?> Function(BuildContext, {bool mandatory})? onRequestType;

  /// Called when the settings icon is tapped.
  final VoidCallback? onSettings;

  /// Called after a recording stops with the saved clip's path, the order
  /// tracking code and video type it belongs to, its recorded length in
  /// seconds, and the device conditions sampled while it recorded.
  final void Function(
    String path,
    String tracking,
    String type,
    int durationSeconds,
    List<DeviceSample> samples,
    DateTime startedAt,
  )?
  onSaved;

  /// Reads battery + network kind while recording. Null in tests and wherever
  /// the composition root has not wired a real source — the clip still records
  /// and uploads, its later burned-in render just carries time and tracking
  /// code only.
  final DeviceConditionSource? deviceConditions;

  /// For a "Trả hàng" clip, checks a scanned code against the shop's saved
  /// orders before recording starts. Returns `false` to reject the code (the
  /// user is warned and stays on the scan screen) — unlike manual entry,
  /// there's no "create a new order" fallback for a return.
  final Future<bool> Function(String code)? verifyReturnCode;

  /// Speaks recording start/stop/wrong-code announcements. Built once for the
  /// app's lifetime by the caller — flutter_tts's engine has a real
  /// cold-start cost, so a fresh instance per visit delayed the very first
  /// announcement each time.
  final VoiceAnnouncerService? voiceAnnouncer;

  /// Video type shown before the user picks one.
  final String initialType;

  /// Pending upload count shown in the header (☁ n) — fed live from the queue.
  final int queueCount;

  /// Recording resolution from the shop's setting (`240p` / `480p` / `720p`);
  /// the rail pill cycles it while idle.
  final String initialResolution;

  /// Trần thời lượng một clip — của **shop**, không phải số cứng (FR-18).
  /// Chạm trần thì phiên tự chốt và nhân viên được báo.
  final Duration maxRecording;

  /// Camera wrapper. Injectable so tests can drive recording and lifecycle
  /// without real hardware; production leaves it null and uses [CameraService].
  @visibleForTesting
  final CameraService? camera;

  /// Whether the "Ghi hình" tab is the one currently on screen.
  ///
  /// The 3-tab shell keeps every branch mounted (an `IndexedStack`, so
  /// switching tabs doesn't lose state), which otherwise leaves this screen's
  /// camera streaming frames — and hands-free auto-starting a recording on a
  /// scanned bill — even while the user is looking at Vận đơn or Tài khoản.
  /// The app shell flips this to reflect the active tab; a `false` releases
  /// the camera the same way backgrounding the app does, and a `true` brings
  /// it back.
  final ValueListenable<bool>? isActive;

  @override
  State<EcRecordRoute> createState() => _EcRecordRouteState();
}

class _EcRecordRouteState extends State<EcRecordRoute>
    with WidgetsBindingObserver {
  // Tuned so a full pinch (roughly 0.5x-2x scale) sweeps a comfortable
  // fraction of the camera's zoom range rather than snapping to the limits.
  static const _pinchZoomSensitivity = 6.0;

  bool _leaving = false;
  double _pinchLastScale = 1;

  late final RecordingSessionBloc _bloc = RecordingSessionBloc(
    camera: widget.camera ?? CameraService(),
    scanner: BillScanner(),
    onClipSaved: (path, tracking, type, durationSeconds, samples, startedAt) =>
        widget.onSaved?.call(
          path,
          tracking,
          type,
          durationSeconds,
          samples,
          startedAt,
        ),
    deviceConditions: widget.deviceConditions,
    verifyReturnCode: widget.verifyReturnCode,
    voiceAnnouncer: widget.voiceAnnouncer,
    initialType: widget.initialType,
    initialResolution: widget.initialResolution,
    maxRecording: widget.maxRecording,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.isActive?.addListener(_onActiveChanged);
    _listenForCalls();
    // The phone sits propped up looking down at the packing table for this
    // flow — it isn't handheld — so free rotation just lets the orientation
    // sensor flicker to landscape at that near-flat resting angle (observed
    // right as recording starts, with the phone never actually moved).
    // Stay on the app-wide portrait lock set in main.dart.
    if (widget.isActive?.value ?? true) {
      // Sau frame đầu — sheet cần một Navigator đã dựng xong.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => unawaited(_startRecordingFlow()),
      );
    }
  }

  /// Vào màn quay = chuẩn bị quay: xin quyền camera trước, rồi chọn loại video,
  /// rồi mới dựng camera.
  ///
  /// Thứ tự này là cố ý. Quyền hỏi ở đây chứ không lúc mở app, để hộp thoại của
  /// iOS rơi đúng lúc người dùng đang định quay. Và sheet chọn loại chỉ mở sau
  /// khi có quyền — hỏi loại video cho một cái camera chưa được phép bật thì vô
  /// nghĩa. Camera lên sau cùng: dựng trước thì máy quét chạy ngay và bill trong
  /// khung bị gán loại mặc định trong khi sheet còn đang mở.
  Future<void> _startRecordingFlow() {
    // Gộp về một lần chạy: hai nguồn (postFrame của initState và vòng đời tab)
    // có thể gọi cùng nhịp, nhưng cả hai đều phải thấy camera lên khi xong.
    return _cameraStart ??= _runRecordingFlow().whenComplete(() {
      _cameraStart = null;
    });
  }

  /// Hỏi loại video cho tới khi người quay chọn thật, rồi mới dựng camera.
  ///
  /// Bỏ qua sheet KHÔNG được coi là đồng ý loại mặc định: loại quyết định clip
  /// nằm ở mục nào trong hồ sơ khiếu nại, gán nhầm thì phải quay lại cả đơn.
  /// Nên chưa chọn thì chưa quay được — hỏi lại.
  Future<void> _runRecordingFlow() async {
    // Chờ khung hình hiện tại vẽ xong rồi mới đẩy sheet lên navigator. Gọi
    // giữa nhịp chuyển tab thì navigator đang khoá và `push` ném
    // `!_debugLocked` — lỗi lặp liên tục vì mỗi lượt hỏng lại kéo theo một
    // lượt thử mới.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    if (!await _ensureCameraAccess()) return;
    // Dựng camera TRONG LÚC sheet chọn loại còn trên màn, không đợi chọn xong.
    //
    // Dựng camera chặn luồng nền tảng vài trăm mili giây (AVCaptureSession lần
    // đầu là nặng nhất). Làm việc đó ngay sau khi người quay bấm chọn loại thì
    // cú bấm của họ đổi lấy một màn hình đứng hình — đó là cái lag họ thấy.
    // Đẩy nó vào quãng người quay đang ĐỌC danh sách loại: lúc ấy không có
    // hoạt ảnh nào chạy và không ai chờ ngón tay mình, nên vài trăm ms đó
    // không ai nhìn thấy. Bấm xong là khung ngắm đã sẵn.
    //
    // Đợi hết lượt mờ hiện sheet (200ms, xem `_showTypeSheet`) rồi mới bắn:
    // chồng vào giữa hoạt ảnh là đổi chỗ khựng chứ không bỏ được nó.
    //
    // An toàn vì máy quét vẫn câm suốt lúc sheet mở (`scanSuspended` bật trong
    // `_pickType`) và chỉ mở lại khi đã chọn loại thật — camera sống sớm hơn
    // KHÔNG kéo theo chuyện tự mở clip cho một bill lọt vào khung.
    final sheetShown = !_typeAsked;
    if (sheetShown) {
      final chosen = _ensureTypeChosen();
      await Future<void>.delayed(_typeSheetFade);
      if (mounted) _bloc.add(const RecordingInitRequested());
      await chosen;
    } else {
      await _ensureTypeChosen();
    }
    // Chưa chọn thì KHÔNG dựng camera và cũng KHÔNG hỏi lại ngay: hỏi vòng
    // tròn thì người dùng bị nhốt trong sheet, không bấm back ra được. Màn
    // chờ vẫn hiện với nút back và ô chọn loại ở thanh dưới — muốn quay thì
    // chọn, không muốn thì thoát.
    if (!mounted || !_typePicked) return;
    // Chốt thứ hai cho cùng một lỗi: mỗi lần dựng camera là một lượt quay mới,
    // không có lý do gì máy quét còn bị treo từ lượt trước.
    _bloc.scanSuspended = false;
    if (!sheetShown) _bloc.add(const RecordingInitRequested());
    await _offerPendingRecord();
  }

  /// Hỏi quay tiếp đơn còn dở từ lượt trước, kể cả sau khi app bị iOS giết.
  ///
  /// Đọc từ đĩa nên sống qua cả lần khởi động lại. Người quay nghe điện thoại
  /// xong mở lại app là được hỏi ngay, không phải nhớ mình đang dở đơn nào rồi
  /// đi quét lại mã.
  Future<void> _offerPendingRecord() async {
    // Hộp thoại cuộc gọi còn trên màn thì nó đã lo rồi — mở chồng cái thứ hai
    // hỏi đúng câu đó là loạn.
    if (_callDialogOpen) return;
    final code = ecPendingRecordCode();
    if (code == null || code.isEmpty || !mounted) return;
    if (_bloc.state.isRecording) return;
    unawaited(ecRememberPendingRecord(null));
    _interruptedCode = code;
    _cutByBackground = true;
    await _askResumeInterrupted();
  }

  /// Trạng thái quyền camera hiện tại, quyết định màn hình nào được vẽ.
  _CameraAccess _access = _CameraAccess.granted;

  /// Có hiện nút "Mở Cài đặt" trên màn từ chối hay không.
  ///
  /// Chỉ bật khi người dùng **chủ động quay lại** màn quay và hệ điều hành cho
  /// biết quyền đã bị từ chối vĩnh viễn. Ngay sau cú bấm "Don't Allow" thì
  /// không: đẩy người ta sang Cài đặt lúc đó là không tôn trọng câu trả lời họ
  /// vừa đưa ra (và là thứ Apple bắt lỗi).
  bool _offerSettings = false;

  /// Đọc trạng thái quyền, trả `true` khi được phép dựng camera.
  ///
  /// Không tự xin ở đây: chưa có quyền thì chỉ chuyển màn hình sang phần giải
  /// thích, hộp thoại của hệ điều hành chờ người dùng bấm "Tiếp tục".
  Future<bool> _ensureCameraAccess() async {
    final permissions = widget.permissions;
    if (permissions == null) return true;
    final bool granted;
    final bool permanentlyDenied;
    try {
      granted = await permissions.hasCameraPermission();
      permanentlyDenied =
          !granted && await permissions.isCameraPermanentlyDenied();
    } on Object {
      // Tầng quyền hỏng không được chặn màn hình — để bloc báo lỗi camera.
      return true;
    }
    if (!mounted) return false;
    if (granted) {
      _setAccess(_CameraAccess.granted);
      return true;
    }
    // Đã từ chối vĩnh viễn thì hỏi lại chỉ là lệnh rỗng — hệ điều hành không
    // hiện hộp thoại nữa — nên bỏ qua phần giải thích và mở lối vào Cài đặt.
    _setAccess(
      permanentlyDenied ? _CameraAccess.blocked : _CameraAccess.rationale,
      offerSettings: permanentlyDenied,
    );
    return false;
  }

  /// Người dùng bấm "Tiếp tục" ở phần giải thích → giờ mới hỏi hệ điều hành.
  Future<void> _requestCameraAccess() async {
    final permissions = widget.permissions;
    if (permissions == null) return;
    var granted = false;
    try {
      granted = await permissions.requestCameraPermission();
    } on Object {
      granted = false;
    }
    if (!mounted) return;
    if (!granted) {
      // Tôn trọng "Don't Allow": ở lại trong app, nói rõ hệ quả, không tự mở
      // Cài đặt và chưa mời họ sang đó.
      _setAccess(_CameraAccess.blocked);
      return;
    }
    _setAccess(_CameraAccess.granted);
    await _startRecordingFlow();
  }

  /// Chỉ chạy từ cú chạm vào nút "Mở Cài đặt" — không đường nào khác gọi nó.
  void _openAppSettings() =>
      unawaited(widget.permissions?.openAppSettingsPage() ?? Future.value());

  void _setAccess(_CameraAccess access, {bool offerSettings = false}) {
    if (_access == access && _offerSettings == offerSettings) return;
    setState(() {
      _access = access;
      _offerSettings = offerSettings;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.isActive?.removeListener(_onActiveChanged);
    unawaited(_callSub?.cancel());
    unawaited(_bloc.close());
    super.dispose();
  }

  /// Mirrors [didChangeAppLifecycleState]'s backgrounding/resume handling,
  /// but keyed off tab visibility instead of the whole app's lifecycle.
  void _onActiveChanged() {
    if (!widget.isActive!.value) {
      // Không tự đóng sheet ở đây: sheet bắt buộc có nền chắn nên người dùng
      // không bấm được thanh tab khi nó đang mở — tab không thể đổi lúc đó.
      // Bản trước gọi `pop()` mù lên navigator gốc, chạy đua với chính luồng
      // đang đóng sheet và có nhịp pop nhầm route khác, để lại cờ kẹt khiến ô
      // chọn loại bấm không ăn.
      // Xoá CẢ HAI cờ ngay khi rời màn, không đợi lúc quay lại: như vậy lượt
      // vào sau chắc chắn phải chọn loại, bất kể sự kiện nào tới trước —
      // `_onActiveChanged` hay chốt trong `build`.
      _typeAsked = false;
      _typePicked = false;
      // Lưới an toàn: cờ này chỉ để chặn mở chồng sheet. Nếu vì lý do nào đó
      // nó còn kẹt (sheet treo trên navigator đã chết), rời màn giải phóng
      // luôn — kẹt cờ làm hỏng hẳn tính năng, còn thả sớm cùng lắm cho mở
      // thêm một sheet.
      _typeSheetOpen = false;
      _bloc.scanSuspended = false;
      _bloc.add(const RecordingBackgrounded());
      return;
    }
    // Mỗi lần vào tab là một lượt quay mới: xoá cả "đã hỏi" lẫn "đã chọn" nên
    // luôn phải chọn lại loại. Giữ nguyên loại của lần trước là cách clip bị
    // gán sai loại nhiều nhất — người quay chuyển tab, quay tiếp, và không ai
    // để ý ô loại ở thanh dưới vẫn là loại cũ. Kể cả khi lượt trước đang quay
    // dở: rời tab đã chốt clip, quay lại là bắt đầu từ đầu.
    //
    // Nằm NGOÀI điều kiện trạng thái camera: trước đây nó lồng trong nhánh
    // "camera cần dựng lại", nên vào tab mà bloc còn `idle` (camera vẫn sống)
    // thì không hỏi gì — bấm Ghi hình không thấy sheet đâu, mãi tới lượt sau
    // mới bật ra.
    _typeAsked = false;
    _typePicked = false;
    // Đây là ĐƯỜNG DUY NHẤT mở sheet tự động. Từng có thêm một chốt trong
    // `build`, nhưng nó đẩy route ngay giữa nhịp dựng khung hình nên navigator
    // đang khoá — `!_debugLocked` ném liên tục, mỗi lượt hỏng lại kéo theo một
    // lượt thử mới.
    unawaited(_startRecordingFlow());
  }

  /// Đã nhả camera vì app bị đẩy xuống nền (cuộc gọi đến, kéo trung tâm thông
  /// báo, chuyển app) và chưa dựng lại.
  ///
  /// Cần cờ riêng vì `RecordingBackgrounded` chốt clip xong thì trạng thái về
  /// `idle` — trùng với `idle` lúc đang rảnh mà camera vẫn sống. Bản trước chỉ
  /// dựng lại khi trạng thái *khác* `idle`, nên sau cuộc gọi camera không bao
  /// giờ quay lại: người dùng thấy màn đen và tưởng app treo.
  bool _releasedForBackground = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    developer.log(
      'LIFECYCLE $state status=${_bloc.state.status} '
      'cut=$_cutByBackground code=${_interruptedCode ?? "-"}',
      name: 'zenpack.call',
    );
    // Hai mức, vì hai mức đó khác nhau về chuyện mất hay không mất bằng chứng.
    //
    // `inactive` = có thứ gì đó che lên app nhưng app CHƯA bị treo: chuông
    // cuộc gọi đang reo, banner tin nhắn, trung tâm điều khiển. Phiên ghi vẫn
    // sống, nên chỉ TẠM DỪNG — file còn mở, quay tiếp được vào chính nó.
    //
    // `paused` = app bị đẩy xuống nền thật (nghe máy, chuyển app). iOS thu hồi
    // phiên ghi, nên phải CHỐT VÀ LƯU ngay tại đây. Giữ file mở qua mốc này là
    // mất trắng cả clip chứ không phải mất phần đuôi — FR-08/FR-09.
    if (state == AppLifecycleState.inactive) {
      if (_bloc.state.isRecording) _bloc.add(const RecordingInterrupted());
    } else if (state == AppLifecycleState.paused) {
      _releasedForBackground = true;
      // Nhớ đơn đang quay TRƯỚC khi clip bị chốt và `code` bị xoá khỏi state.
      if (_bloc.state.code.isNotEmpty &&
          (_bloc.state.isRecording ||
              _bloc.state.status == RecordingStatus.interrupted)) {
        _interruptedCode = _bloc.state.code;
        _cutByBackground = true;
        // Và ghi xuống đĩa: iOS hay giết hẳn app đang giữ camera khi có cuộc
        // gọi. Lúc quay lại là tiến trình mới, cờ trong bộ nhớ đã mất sạch.
        unawaited(ecRememberPendingRecord(_bloc.state.code));
      }
      _bloc.add(const RecordingBackgrounded());
    } else if (state == AppLifecycleState.resumed) {
      // Cuộc gọi tắt phiên âm thanh của app và iOS không tự bật lại. Khai lại
      // ngay khi trở về, trước mọi tiếng tút hay câu nói sau đó.
      unawaited(_bloc.restoreAudio());
      final needsCamera =
          _releasedForBackground ||
          (_bloc.state.status != RecordingStatus.idle &&
              _bloc.state.status != RecordingStatus.recording);
      _releasedForBackground = false;
      // Tab khác đang hiển thị thì để `_onActiveChanged` lo — dựng camera ở
      // đây sẽ bật nó lên trong lúc người dùng đang xem Vận đơn.
      // Clip vẫn đang mở (chỉ tạm dừng, app không hề bị treo) thì quay tiếp
      // NGAY vào chính nó, không hỏi han gì: một banner tin nhắn lướt qua thì
      // người quay không cần biết, và cũng không nên bị chặn lại bằng một hộp
      // thoại. KHÔNG dựng lại camera — dựng lại là vứt phiên ghi.
      if (_bloc.state.status == RecordingStatus.interrupted) {
        unawaited(_resumeOrAsk());
        return;
      }
      if (needsCamera && (widget.isActive?.value ?? true)) {
        unawaited(_startRecordingFlow().then((_) => _askResumeInterrupted()));
      }
    }
  }

  /// Đơn đang quay dở lúc bị cuộc gọi cắt ngang, chờ hỏi lại.
  String? _interruptedCode;

  /// Cuộc gọi đến, do hệ điều hành báo qua CallKit.
  ///
  /// Vòng đời app KHÔNG trả lời được câu "có cuộc gọi đang reo không": chuông
  /// reo và banner tin nhắn cùng đẩy app sang `inactive`, còn cuộc gọi VoIP
  /// không ai bắt máy thì chẳng bao giờ đẩy app xuống nền — đúng trường hợp
  /// gọi Zalo mà nhìn như không có gì xảy ra. CallKit báo mọi cuộc gọi máy
  /// biết, gồm cả Zalo/Messenger/WhatsApp.
  static const _callChannel = EventChannel('zenpack/calls');
  StreamSubscription<dynamic>? _callSub;

  void _listenForCalls() {
    if (!Platform.isIOS) return;
    _callSub = _callChannel.receiveBroadcastStream().listen(
      (event) {
        developer.log(
          'CALL event=$event mounted=$mounted '
          'status=${_bloc.state.status}',
          name: 'zenpack.call',
        );
        if (event != 'incoming' || !mounted) return;
        if (!_bloc.state.isRecording || _bloc.state.code.isEmpty) return;
        _interruptedCode = _bloc.state.code;
        // Đọc to ngay lúc này, không đợi lúc quay lại app: người quay đang cúi
        // xuống thùng hàng, đây là giây họ cần biết có chuyện xảy ra.
        unawaited(_bloc.announceInterrupted());
        unawaited(_showCallDialog());
      },
      onError: (Object _) {
        // Kênh không dựng được (bản build cũ, thiết bị lạ) — vòng đời app vẫn
        // là lưới đỡ như trước.
      },
    );
  }

  /// Clip đã bị CHỐT vì app xuống nền thật, không phải chỉ tạm dừng.
  ///
  /// Phân biệt hai đường ở lúc quay lại: tạm dừng thì quay tiếp vào file cũ và
  /// không hỏi gì; bị chốt rồi thì phải hỏi, và "Tiếp tục" chỉ có thể mở clip
  /// mới cho cùng đơn.
  bool _cutByBackground = false;

  /// Đang mở hộp thoại cuộc gọi — chặn mở chồng khi có cuộc thứ hai gọi tới.
  bool _callDialogOpen = false;

  /// Tạm dừng clip rồi hỏi, ngay lúc chuông reo.
  ///
  /// TẠM DỪNG, không chốt: file vẫn mở nên "Tiếp tục" nối thẳng vào chính clip
  /// đó, không sinh ra file thứ hai. Và không quay tiếp trong lúc chuông reo —
  /// đoạn người quay ngẩng lên nhìn điện thoại chẳng là bằng chứng của gì.
  ///
  /// "Kết thúc" mới chốt clip.
  Future<void> _showCallDialog() async {
    if (_callDialogOpen || !mounted) return;
    _callDialogOpen = true;
    _bloc.add(const RecordingInterrupted());
    final l10n = context.l10n;
    try {
      final keepRecording = await showCupertinoDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: Text(l10n.recordInterruptedTitle),
          content: Text(l10n.recordInterruptedBody),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.recordInterruptedFinish),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.recordInterruptedResume),
            ),
          ],
        ),
      );
      if (!mounted) return;
      final code = _interruptedCode;
      final stillOpen = _bloc.state.status == RecordingStatus.interrupted;
      if (!(keepRecording ?? true)) {
        // "Kết thúc": chốt clip nếu nó còn mở. Nghe máy xong thì iOS đã chốt
        // hộ rồi, lúc đó không còn gì phải làm.
        if (stillOpen) _bloc.add(const RecordingStopRequested());
      } else if (stillOpen) {
        // Chưa ai nghe máy — nối thẳng vào chính clip đó.
        await _resumeOrAsk();
        return;
      } else if (!_bloc.state.isRecording && code != null && code.isNotEmpty) {
        // Đã nghe máy: iOS thu hồi phiên ghi và clip bị chốt trong lúc app ở
        // nền. "Tiếp tục" giờ nghĩa là mở clip mới cho ĐÚNG đơn đó — không
        // bắt quét lại mã. Thiếu nhánh này thì nút bấm không ra gì, và nhìn
        // ra đúng như "phải quay lại từ đầu".
        await _startRecordingFlow();
        if (!mounted) return;
        _bloc.add(RecordingManualCodeSubmitted(code));
      }
      _interruptedCode = null;
      _cutByBackground = false;
      unawaited(ecRememberPendingRecord(null));
    } finally {
      _callDialogOpen = false;
    }
  }

  /// Quay tiếp vào clip đang mở; nối không được thì mới hỏi.
  ///
  /// KHÔNG xoá [_interruptedCode]/[_cutByBackground] trước khi biết kết quả.
  /// Bản trước xoá ngay rồi mới thử nối — nối hỏng (iOS thu hồi phiên ghi khi
  /// có cuộc gọi) là bloc chốt clip về nghỉ, mà lúc đó chẳng còn gì để hỏi
  /// người quay. Nhìn ra đúng như "có cuộc gọi là dừng quay, không báo gì".
  Future<void> _resumeOrAsk() async {
    final code = _interruptedCode;
    _bloc.add(const RecordingResumeRequested());
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    if (_bloc.state.status == RecordingStatus.recording) {
      // Nối được thật — clip liền một mạch, không cần làm phiền ai.
      _interruptedCode = null;
      _cutByBackground = false;
      return;
    }
    // Nối không được (iOS đã thu hồi phiên ghi). Phần đã quay được bloc chốt
    // và lưu, giờ dựng lại camera.
    await _startRecordingFlow();
    if (!mounted) return;
    // Chưa hỏi lần nào thì hỏi. Còn nếu người quay vừa bấm "Tiếp tục" ở hộp
    // thoại cuộc gọi thì họ đã trả lời rồi — hỏi lại đúng câu đó là phiền, cứ
    // mở thẳng clip mới cho đơn đang dở.
    if (_cutByBackground) {
      await _askResumeInterrupted();
      return;
    }
    _interruptedCode = null;
    if (code != null && code.isNotEmpty) {
      _bloc.add(RecordingManualCodeSubmitted(code));
    }
  }

  /// Hỏi quay tiếp hay kết thúc, sau khi app trở lại từ cuộc gọi.
  ///
  /// Hiện tự động, không cần thao tác nào: người quay vừa nghe máy xong, việc
  /// đầu tiên họ cần biết là máy còn đang ghi hay không.
  ///
  /// Hỏi thay vì tự quay tiếp: người quay có thể đã rời bàn, tự động ghi hình
  /// trần nhà cả phút là vô nghĩa và tốn quota.
  Future<void> _askResumeInterrupted() async {
    developer.log(
      'ASK code=${_interruptedCode ?? "-"} cut=$_cutByBackground '
      'status=${_bloc.state.status}',
      name: 'zenpack.call',
    );
    final code = _interruptedCode;
    final wasCut = _cutByBackground;
    _interruptedCode = null;
    _cutByBackground = false;
    unawaited(ecRememberPendingRecord(null));
    if (code == null || !wasCut || !mounted) return;
    final l10n = context.l10n;
    final paused = _bloc.state.status == RecordingStatus.interrupted;
    // Nói trước khi vẽ hộp thoại: người quay có thể còn đang cầm máy áp tai,
    // mắt chưa nhìn màn hình.
    unawaited(_bloc.announceInterrupted());
    final resume = await showCupertinoDialog<bool>(
      context: context,
      // Không cho bấm ra ngoài để đóng: bỏ lửng câu hỏi này là clip treo giữa
      // chừng, không ai biết nó còn mở hay đã chốt.
      barrierDismissible: false,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(l10n.recordInterruptedTitle),
        content: Text(l10n.recordInterruptedBody),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.recordInterruptedFinish),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.recordInterruptedResume),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (!(resume ?? false)) {
      // Kết thúc: chốt clip đang mở. Trạng thái `interrupted` nghĩa là file
      // chưa đóng, nên phải đi qua đường dừng bình thường.
      if (paused) _bloc.add(const RecordingStopRequested());
      return;
    }
    if (!paused) {
      // Clip đã bị chốt từ trước (iOS thu hồi phiên ghi) — chỉ còn cách mở
      // clip mới cho cùng đơn.
      _bloc.add(RecordingManualCodeSubmitted(code));
      return;
    }
    _bloc.add(const RecordingResumeRequested());
    // Nối lại hỏng thì bloc tự chốt clip và về `idle`; lúc đó mở clip mới cho
    // đúng đơn đó, chứ không bỏ người quay đứng trước màn hình đã tắt ghi.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    if (_bloc.state.status == RecordingStatus.idle) {
      _bloc.add(RecordingManualCodeSubmitted(code));
    }
  }

  /// Manual fallback: ask for a code (opens the sheet), then record it.
  Future<void> _manualEntry() async {
    final code = (await widget.onRequestCode?.call())?.trim();
    if (code != null && code.isNotEmpty) {
      final allowed = await widget.onConfirmManualCode?.call(code) ?? true;
      if (!allowed) return;
      _bloc.add(RecordingManualCodeSubmitted(code));
    }
  }

  /// True sau khi sheet chọn loại đã được hỏi một lần trong phiên — dù người
  /// Đã MỞ sheet chọn loại lần nào chưa.
  ///
  /// Bật ngay lúc BẮT ĐẦU hỏi, không phải lúc sheet đóng. Chốt theo thời điểm
  /// đóng thì trong suốt lúc sheet đang mở cờ vẫn `false`, và lời gọi thứ hai
  /// (vòng đời tab bắn cùng nhịp với `initState`) mở thêm một sheet nữa chồng
  /// lên — đóng cái trên xong vẫn còn cái dưới chặn hết thao tác, đúng triệu
  /// chứng "bấm gì cũng không ăn" thi thoảng gặp.
  ///
  /// Bỏ qua sheet = đồng ý với loại mặc định, vẫn tính là đã hỏi nên camera
  /// lên bình thường và không hỏi lại trong lượt đó.
  bool _typeAsked = false;

  /// Lời gọi dựng camera đang chạy. Lời gọi sau chờ chung future này thay vì
  /// bỏ đi — bỏ đi thì có nhịp camera không bao giờ được dựng và màn đứng im.
  Future<void>? _cameraStart;

  /// Sheet chọn loại đang mở. Chỉ dùng để chặn mở chồng hai sheet — bấm ô loại
  /// ở thanh dưới trong lúc sheet tự động còn mở.
  bool _typeSheetOpen = false;

  /// Khớp với `transitionDuration` của `_showTypeSheet` — đổi bên đó thì đổi ở
  /// đây, nếu không lượt dựng camera lại rơi vào giữa hoạt ảnh.
  static const _typeSheetFade = Duration(milliseconds: 200);

  /// True khi người quay đã CHỌN THẬT một loại trong lượt này.
  ///
  /// Khác [_typeAsked] (chỉ ghi nhận đã mở sheet): camera chỉ lên khi cờ này
  /// bật, nên bỏ qua sheet không có nghĩa là đồng ý một loại mặc định nào.
  bool _typePicked = false;

  Future<void> _pickType({bool mandatory = false}) async {
    // Một sheet tại một thời điểm: bấm ô loại ở thanh dưới trong lúc sheet tự
    // động còn đang mở sẽ chồng thêm cái nữa, đóng cái trên vẫn còn cái dưới
    // chặn hết thao tác.
    if (_typeSheetOpen) return;
    // Máy quét phải im trong lúc sheet che khung ngắm: người quay đang chọn
    // loại, không canh bill — bill lọt vào khung lúc đó mà máy tự mở clip là
    // sai đơn, và họ chỉ phát hiện sau khi đã quay xong.
    _bloc.scanSuspended = true;
    _typeSheetOpen = true;
    try {
      await _pickTypeInner(mandatory: mandatory);
    } finally {
      _typeSheetOpen = false;
      // Trả cờ ngay tại đây, không kèm `mounted`: chỉ cần một nhịp widget bị
      // gỡ đúng lúc sheet đóng là cờ kẹt ở `true` vĩnh viễn, máy quét câm, và
      // triệu chứng là "chọn loại nào cũng không quay được" — không có gì trên
      // màn hình chỉ ra nguyên nhân. Gán vào bloc đã đóng thì vô hại.
      //
      // Điều kiện duy nhất là ĐÃ chọn loại thật. Camera nay lên từ lúc sheet
      // còn mở, nên đóng sheet mà chưa chọn rồi mở luôn máy quét là để nó tự
      // mở clip cho một bill lọt vào khung với loại mặc định — đúng thứ lượt
      // hỏi loại sinh ra để chặn. Người quay còn ô chọn loại ở thanh dưới:
      // chọn xong là máy quét mở lại.
      _bloc.scanSuspended = !_typePicked;
    }
  }

  Future<void> _pickTypeInner({bool mandatory = false}) async {
    // Truyền context SỐNG của màn quay, không để bên gọi tự giữ context của
    // route lúc dựng router: context cũ trỏ vào navigator không còn hiển thị,
    // sheet mở ra không ai thấy và cũng không ai đóng được — `await` treo mãi,
    // cờ `_typeSheetOpen` kẹt `true`, và từ đó cả sheet tự động lẫn ô chọn
    // loại ở thanh dưới đều bấm không ăn.
    if (!mounted) return;
    final type = await widget.onRequestType?.call(
      context,
      mandatory: mandatory,
    );
    if (type != null && type.isNotEmpty) {
      _typePicked = true;
      _bloc.add(RecordingTypeChanged(type));
    }
  }

  /// Mở sheet chọn loại ngay khi vào màn quay, nếu chưa chọn lần nào. Chặn ở
  /// đây thay vì lúc quét mã: luồng quét là rảnh tay, dừng lại giữa chừng để
  /// hỏi thì bill đã qua khung hình mất rồi.
  Future<void> _ensureTypeChosen() async {
    // Kiểm tra `isActive` ngay tại đây chứ không chỉ lúc lên lịch: sheet đi qua
    // navigator gốc nên nó hiện đè lên BẤT KỲ tab nào đang mở — mở nhầm lúc
    // người dùng còn ở Vận đơn thì họ thấy hộp chọn loại quay bật ra vô cớ.
    if (_typeAsked || !mounted || !(widget.isActive?.value ?? true)) return;
    _typeAsked = true;
    // Lần mở tự động lúc vào màn là bắt buộc; bấm ô loại ở thanh dưới thì
    // không, vì lúc đó người quay đã chọn xong và chỉ muốn đổi.
    await _pickType(mandatory: true);
  }

  Future<void> _leaveAfterFinalizing(VoidCallback? action) async {
    if (_leaving) return;
    _leaving = true;
    try {
      if (_bloc.state.isRecording) {
        final stopped = _bloc.stream.firstWhere((s) => !s.isRecording);
        _bloc.add(const RecordingStopRequested());
        await stopped.timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            return _bloc.state;
          },
        );
      }
      action?.call();
      // Rời màn cũng là hết lượt: vào lại phải chọn loại từ đầu. `isActive`
      // không đổi khi thoát bằng nút back (shell vẫn giữ nhánh này), nên nếu
      // chỉ dựa vào `_onActiveChanged` thì lượt sau không ai hỏi.
      _typePicked = false;
      _typeAsked = false;
    } finally {
      _leaving = false;
    }
  }

  Widget _buildPreview(RecordingSessionState state) {
    final error = state.errorMessage;
    if (error != null) {
      return _PreviewMessage(icon: Icons.videocam_off_outlined, message: error);
    }
    final controller = _bloc.previewController;
    if (state.status == RecordingStatus.initializing ||
        controller == null ||
        !controller.value.isInitialized) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: CupertinoActivityIndicator(color: Colors.white70),
        ),
      );
    }
    return GestureDetector(
      onScaleStart: (_) => _pinchLastScale = 1,
      onScaleUpdate: (details) {
        final stepDelta =
            (details.scale - _pinchLastScale) * _pinchZoomSensitivity;
        _pinchLastScale = details.scale;
        if (stepDelta != 0) _bloc.add(RecordingZoomAdjusted(stepDelta));
      },
      child: _CoverPreview(
        controller: controller,
        transitioning: _bloc.previewTransitioning,
      ),
    );
  }

  String _formatElapsed(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes)}:${two(d.inSeconds % 60)}';
  }

  /// Giờ treo tường `HH:mm` cho dòng phụ của thẻ "Đơn tiếp theo".
  String _formatClock(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}';
  }

  Future<void> _showLowStorageWarning(BuildContext context) async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(context.l10n.lowStorageTitle),
        content: Text(context.l10n.lowStorageBody),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.l10n.lowStorageAction),
          ),
        ],
      ),
    );
    if (mounted) _bloc.add(const RecordingLowStorageDismissed());
  }

  @override
  Widget build(BuildContext context) {
    // The system back gesture (left-edge swipe on Android) would otherwise
    // pop this route out from under an in-progress recording — the header's
    // back chevron is the only way out, since it finalizes the clip first
    // via _leaveAfterFinalizing.
    return PopScope(
      canPop: false,
      child: BlocListener<RecordingSessionBloc, RecordingSessionState>(
        bloc: _bloc,
        // Everything here is edge-triggered off the session state. Reporting
        // from `build` instead would re-fire on every camera frame.
        listenWhen: (previous, current) =>
            (!previous.lowStorageWarning && current.lowStorageWarning) ||
            (!previous.isRecording && current.isRecording) ||
            (previous.cutoverFromCode == null &&
                current.cutoverFromCode != null) ||
            (previous.elapsed < _bloc.nearLimitAt &&
                current.elapsed >= _bloc.nearLimitAt),
        listener: _onSessionEdge,
        child: BlocBuilder<RecordingSessionBloc, RecordingSessionState>(
          bloc: _bloc,
          builder: (context, state) => _buildScreen(state),
        ),
      ),
    );
  }

  /// One listener for every session transition worth reporting. [listenWhen]
  /// above decides *whether* we are called; this decides *which* edge it was,
  /// so each branch re-checks the condition that let it through.
  void _onSessionEdge(BuildContext context, RecordingSessionState state) {
    final analytics = getIt.isRegistered<AnalyticsService>()
        ? getIt<AnalyticsService>()
        : null;
    if (state.lowStorageWarning) {
      unawaited(_showLowStorageWarning(context));
    }
    if (state.cutoverFromCode != null) {
      analytics?.trackOrderCutover();
    } else if (state.isRecording) {
      analytics?.trackRecordingStarted(videoType: state.typeLabel);
    }
    if (state.elapsed >= _bloc.nearLimitAt) {
      analytics?.trackNearClipLimit();
    }
  }

  Widget _buildScreen(RecordingSessionState state) {
    if (_access != _CameraAccess.granted) {
      return _CameraPermissionScreen(
        access: _access,
        offerSettings: _offerSettings,
        onContinue: _requestCameraAccess,
        onLater: widget.onNavOrders ?? widget.onBack,
        onOpenSettings: _openAppSettings,
      );
    }
    final preview = _buildPreview(state);
    final closedCode = state.cutoverFromCode;

    if (state.isRecording && closedCode != null) {
      return EcCutoverBScreen(
        queueCount: widget.queueCount,
        closedCode: closedCode,
        newCode: state.code,
        newMeta: '${state.typeLabel} • ${_formatClock(DateTime.now())}',
        typeLabel: state.typeLabel,
        resolutionLabel: state.resolutionLabel,
        preview: preview,
        onBack: () => unawaited(_leaveAfterFinalizing(widget.onBack)),
        onQueueTap: () => unawaited(_leaveAfterFinalizing(widget.onQueueTap)),
        onStop: () => _bloc.add(const RecordingStopRequested()),
      );
    }

    if (state.isRecording) {
      if (state.elapsed >= _bloc.nearLimitAt) {
        final remaining = _bloc.maxRecording - state.elapsed;
        return EcNearLimitScreen(
          queueCount: widget.queueCount,
          warningText: context.l10n.nearClipLimitWarning(
            '${(widget.maxRecording.inSeconds / 60).round()}',
          ),
          code: state.code,
          duration: _formatElapsed(state.elapsed),
          countdownText: context.l10n.recordAutoStopIn(
            _formatElapsed(remaining.isNegative ? Duration.zero : remaining),
          ),
          typeLabel: state.typeLabel,
          resolutionLabel: state.resolutionLabel,
          preview: preview,
          onBack: () => unawaited(_leaveAfterFinalizing(widget.onBack)),
          onQueueTap: () => unawaited(_leaveAfterFinalizing(widget.onQueueTap)),
          onPickType: null,
          onSettings: null,
          onNavOrders: () =>
              unawaited(_leaveAfterFinalizing(widget.onNavOrders)),
          onNavClaims: () =>
              unawaited(_leaveAfterFinalizing(widget.onNavClaims)),
          onStop: () => _bloc.add(const RecordingStopRequested()),
        );
      }
      if (state.typeLabel == 'Trả hàng') {
        return EcReturnRecScreen(
          queueCount: widget.queueCount,
          code: state.code,
          duration: _formatElapsed(state.elapsed),
          typeLabel: state.typeLabel,
          resolutionLabel: state.resolutionLabel,
          preview: preview,
          onBack: () => unawaited(_leaveAfterFinalizing(widget.onBack)),
          onQueueTap: () => unawaited(_leaveAfterFinalizing(widget.onQueueTap)),
          onStop: () => _bloc.add(const RecordingStopRequested()),
        );
      }
      return EcRecording2Screen(
        queueCount: widget.queueCount,
        code: state.code,
        elapsed: _formatElapsed(state.elapsed),
        typeLabel: state.typeLabel,
        resolutionLabel: state.resolutionLabel,
        preview: preview,
        onBack: () => unawaited(_leaveAfterFinalizing(widget.onBack)),
        onQueueTap: () => unawaited(_leaveAfterFinalizing(widget.onQueueTap)),
        onPickType: null,
        onSettings: null,
        onNavOrders: () => unawaited(_leaveAfterFinalizing(widget.onNavOrders)),
        onNavClaims: () => unawaited(_leaveAfterFinalizing(widget.onNavClaims)),
        onStop: () => _bloc.add(const RecordingStopRequested()),
      );
    }

    return EcWaitBill2Screen(
      queueCount: widget.queueCount,
      typeLabel: state.typeLabel,
      resolutionLabel: state.resolutionLabel,
      preview: preview,
      onBack: widget.onBack,
      onQueueTap: widget.onQueueTap,
      onPickType: _pickType,
      onSettings: _pickType,
      onResolution: () => _bloc.add(const RecordingResolutionCycled()),
      onFlipCamera: state.hasMultipleCameras
          ? () => _bloc.add(const RecordingCameraFlipped())
          : null,
      onManualEntry: _manualEntry,
      onNavOrders: widget.onNavOrders,
      onNavClaims: widget.onNavClaims,
    );
  }
}

/// Fills the black camera area with [controller]'s preview, cover-cropped so it
/// bleeds edge-to-edge without distortion.
class _CoverPreview extends StatefulWidget {
  const _CoverPreview({required this.controller, required this.transitioning});

  final CameraController controller;

  /// True suốt lời gọi native bắt đầu/dừng quay, bloc bật TRƯỚC khi await.
  ///
  /// Không còn dùng để che preview — nay pipeline không đổi giữa hai nhịp ấy
  /// nên chẳng có gì để che. Chỉ còn dùng để hoãn cú `toImage` định kỳ, thứ
  /// đồng bộ với GPU và không nên chen vào đúng nhịp camera bận nhất.
  final ValueListenable<bool> transitioning;

  @override
  State<_CoverPreview> createState() => _CoverPreviewState();
}

class _CoverPreviewState extends State<_CoverPreview> {
  /// Số phần tư vòng xoay áp cho texture camera. Hỏi nền tảng MỘT LẦN cho mỗi
  /// controller rồi chốt — không đổi theo cảm biến, đó vẫn là điểm chính.
  ///
  /// Từng là hằng số `0`, và hằng số ấy chỉ đúng với một nửa số máy: máy nào có
  /// surface producer tự nắn khung thì texture giao ra đã đứng, máy nào không
  /// thì giao nguyên khung theo cảm biến và preview nằm ngang ĐỀU — Galaxy M14
  /// nằm ở nửa sau. Không có con số nào đúng cho cả hai, nên đây là câu hỏi
  /// phải hỏi máy chứ không phải hằng số phải đoán; xem [ecPreviewQuarterTurns].
  ///
  /// `null` = chưa có câu trả lời. Lúc ấy vẽ khung đứng thay vì đoán bừa một
  /// góc: đoán sai thì người quay thấy preview loé lên nằm ngang rồi mới bật
  /// đúng, và đó đúng là lỗi đang sửa.
  int? _previewQuarterTurns;

  /// Trạng thái quay của lần hỏi góc gần nhất, để biết khi nào phải hỏi lại.
  bool _askedWhileRecording = false;

  // Khung đứng gần nhất được làm mới bao lâu một lần. Chỉ còn dùng cho lúc
  // controller biến mất (lật camera, đổi độ phân giải, app xuống nền), nên
  // không cần dày.
  //
  // 250ms là quá dày: mỗi lượt là một cú `toImage`, tức đọc ngược toàn bộ
  // khung từ GPU về CPU, và ở đây nó chạy suốt thời gian màn quay mở. Bốn lượt
  // mỗi giây ở tỉ lệ điểm ảnh thật (3x trên iPhone) là đủ để cả màn hình gợn —
  // rõ nhất ở quãng từ tiếng tút tới câu "Đã bắt đầu quay", quãng duy nhất
  // không nằm trong cờ `transitioning` nên không được miễn.
  static const _refreshInterval = Duration(seconds: 1);

  /// Tỉ lệ điểm ảnh của khung đứng, so với màn hình thật.
  ///
  /// Ảnh này chỉ để lấp chỗ trong lúc luồng camera sống không vẽ được, và nó
  /// bị kéo giãn phủ khung ngắm — không ai soi từng điểm ảnh của nó. Chụp ở
  /// một phần ba độ nét là bớt khoảng chín phần mười số điểm ảnh phải đọc về
  /// mỗi lượt, đổi lại một chỗ lấp hơi mềm mà mắt không kịp nhận ra.
  static const _frozenFrameScale = 1 / 3;

  final GlobalKey _boundaryKey = GlobalKey();
  ui.Image? _lastGoodFrame;
  Timer? _refreshTimer;
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      // Không chụp lại đúng lúc đang bắt đầu/dừng quay: `toImage` là một cú
      // đồng bộ với GPU, và chèn nó vào đúng nhịp bận nhất của camera là tự
      // tạo ra cái khựng mà lớp che sinh ra để giấu.
      if (widget.transitioning.value) return;
      // Đang quay cũng không chụp. Khung đứng chỉ cần cho lúc controller biến
      // mất — lật camera, đổi độ phân giải — mà giữa một clip thì không có
      // thao tác nào làm được chuyện đó. Chụp tiếp chỉ là lấy GPU của đúng
      // việc đang quan trọng nhất trong cả app.
      if (widget.controller.value.isRecordingVideo) return;
      unawaited(_refreshLastGoodFrame());
    });
    unawaited(_resolveQuarterTurns());
  }

  @override
  void didUpdateWidget(covariant _CoverPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Controller mới = camera khác (lật mặt trước/sau) hoặc độ phân giải khác,
    // và góc cần xoay đi theo góc cảm biến của camera ĐANG bật. Hỏi lại thay vì
    // giữ số cũ: camera trước và camera sau lệch nhau đúng nửa vòng.
    if (!identical(oldWidget.controller, widget.controller)) {
      unawaited(_resolveQuarterTurns());
    }
  }

  /// Hỏi lại góc xoay, đọc từ trạng thái THẬT của pipeline camera.
  ///
  /// Gọi lúc dựng, lúc đổi controller, và mỗi lần trạng thái quay đổi. Nhịp
  /// cuối chỉ còn cần cho máy không cho gắn sẵn `VideoCapture` (xem
  /// [ecPreviewQuarterTurns]); máy gắn được thì câu trả lời giống nhau ở mọi
  /// nhịp và `setState` dưới đây không bao giờ chạy.
  Future<void> _resolveQuarterTurns() async {
    _askedWhileRecording = widget.controller.value.isRecordingVideo;
    final turns = await ecPreviewQuarterTurns(widget.controller.description);
    if (!mounted || turns == _previewQuarterTurns) return;
    setState(() => _previewQuarterTurns = turns);
  }

  Future<void> _refreshLastGoodFrame() async {
    if (_capturing) return;
    _capturing = true;
    try {
      final boundary =
          _boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(
        pixelRatio: MediaQuery.devicePixelRatioOf(context) * _frozenFrameScale,
      );
      if (!mounted || widget.transitioning.value) {
        image.dispose();
        return;
      }
      final old = _lastGoodFrame;
      setState(() => _lastGoodFrame = image);
      old?.dispose();
    } on Object {
      // Best effort — the live feed underneath still covers a missed frame.
    } finally {
      _capturing = false;
    }
  }

  /// Khung đứng gần nhất, dùng mỗi khi luồng camera sống không vẽ được.
  ///
  /// Đen tuyền chỉ khi chưa từng bắt được khung nào — người quay thấy cảnh
  /// đứng hình dễ chịu hơn nhiều so với màn tối chớp một nhịp.
  Widget _frozenFrame() {
    final frame = _lastGoodFrame;
    if (frame == null) return const ColoredBox(color: Colors.black);
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: frame.width.toDouble(),
        height: frame.height.toDouble(),
        child: RawImage(image: frame),
      ),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _lastGoodFrame?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return ColoredBox(
      color: Colors.black,
      // Nghe thẳng controller chứ không chờ bloc phát trạng thái: góc xoay đổi
      // đúng lúc `isRecordingVideo` đổi, và một nhịp rebuild trễ ở đây là một
      // nhịp preview nằm ngang trên màn.
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => LayoutBuilder(
          builder: (context, constraints) {
            // KHÔNG còn lớp khung đứng che lúc bắt đầu/dừng quay. Lớp ấy sinh
            // ra để giấu cú ngoặt ngang khi camerax dựng lại capture session —
            // nay `VideoCapture` gắn sẵn từ lúc dựng camera nên chẳng có cú
            // dựng lại nào nữa, và preview chạy liên tục xuyên qua cả hai nhịp.
            // Giữ lớp che lại thì nó không còn giấu gì, chỉ còn đông cứng hình
            // hơn một giây mỗi lần bấm: đúng cái khựng người quay thấy.
            //
            // Controller đã dispose (đổi độ phân giải, lật camera, app xuống
            // nền, hoặc màn quay chờ người dùng chọn loại video) thì texture bên
            // dưới đã bị huỷ. Khung đứng gần nhất là đủ — controller mới lên là
            // widget rebuild và preview trở lại.
            if (!controller.value.isInitialized) return _frozenFrame();
            // Trạng thái quay vừa đổi = pipeline có thể vừa đổi hình dạng. Hỏi
            // lại góc ngay trong nhịp này thay vì tin con số cũ.
            if (controller.value.isRecordingVideo != _askedWhileRecording) {
              unawaited(_resolveQuarterTurns());
            }
            final quarterTurns = _previewQuarterTurns;
            if (quarterTurns == null) return _frozenFrame();
            // Texture TRẦN, xoay bằng MỘT hằng số — không ai xoay động nữa.
            //
            // Đã đi hết ba đường. `CameraPreview` bọc thêm `RotatedBox` quanh
            // cái texture vốn đã tự xoay, và góc lớp bọc đổi NGUỒN giữa chừng
            // (`deviceOrientation` lúc nghỉ → `recordingOrientation` lúc quay):
            // nhảy 90° ngay khoảnh khắc bấm. `buildPreview()` bỏ được lớp ngoài
            // nhưng vẫn giữ `RotatedPreviewDelegate` bên trong, thứ nghe
            // `onDeviceOrientationChanged` và xoay lại mỗi lần camerax rebind
            // use case — vẫn nhảy, chỉ ít hơn. Che bằng khung đứng thì giấu được
            // cú nhảy, nhưng đổi nó lấy hai giây đứng hình mỗi lần chuyển đơn.
            //
            // Cả ba đều sai ở cùng một chỗ: để hướng preview phụ thuộc cảm biến.
            // Màn này không có lý do nào để làm thế — cửa sổ app khoá dọc
            // (`main.dart`), khung quay khoá `portraitUp`
            // (`lockCaptureOrientation`), và máy thì chống xuống bàn nhìn xuống,
            // đúng tư thế làm cảm biến đọc nhầm thành landscape.
            //
            // Texture trần thì không widget nào xoay nó theo cảm biến, nên nó
            // KHÔNG THỂ nhảy giữa chừng. Cái giá là phải tự chốt góc —
            // [_previewQuarterTurns], đọc từ trạng thái thật của pipeline. Với
            // `VideoCapture` gắn sẵn từ lúc dựng camera, pipeline chỉ có một
            // hình dạng duy nhất nên con số ấy cũng chỉ có một.
            final livePreview = Texture(textureId: controller.cameraId);
            return ClipRect(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxWidth * controller.value.aspectRatio,
                  child: RepaintBoundary(
                    key: _boundaryKey,
                    child: RotatedBox(
                      quarterTurns: quarterTurns,
                      child: livePreview,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Trạng thái quyền camera của màn quay.
enum _CameraAccess {
  /// Có quyền — vẽ màn quay như thường.
  granted,

  /// Chưa hỏi bao giờ: giải thích ngắn rồi mới hỏi khi người dùng đồng ý.
  rationale,

  /// Đã từ chối: nói rõ hệ quả, cho lối đi tiếp, và ở lại trong app.
  blocked,
}

/// Màn hình thay cho khung ngắm khi chưa có quyền camera.
///
/// Hai vai: giải thích *trước* khi hỏi (Apple yêu cầu người dùng biết mình
/// đang đồng ý cho cái gì), và báo hệ quả *sau* khi từ chối mà không ép buộc —
/// nút "Để sau" đưa họ về danh sách vận đơn, phần còn lại của app vẫn dùng
/// được bình thường.
class _CameraPermissionScreen extends StatelessWidget {
  const _CameraPermissionScreen({
    required this.access,
    required this.offerSettings,
    required this.onContinue,
    required this.onLater,
    required this.onOpenSettings,
  });

  final _CameraAccess access;
  final bool offerSettings;
  final VoidCallback onContinue;
  final VoidCallback? onLater;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final blocked = access == _CameraAccess.blocked;
    return PenScreen(
      scrollable: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 24, 26, 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Icon(
              blocked ? LucideIcons.videoOff : LucideIcons.video,
              size: 44,
              color: PenColors.mut,
            ),
            const SizedBox(height: 16),
            PenText(
              blocked
                  ? l10n.cameraPermissionDeniedTitle
                  : l10n.cameraPermissionRationaleTitle,
              size: 22,
              weight: FontWeight.w700,
              color: PenColors.ink,
              align: TextAlign.center,
            ),
            const SizedBox(height: 10),
            PenText(
              blocked
                  ? l10n.cameraPermissionDeniedBody
                  : l10n.cameraPermissionRationaleBody,
              size: 15,
              color: PenColors.mut,
              align: TextAlign.center,
            ),
            const Spacer(),
            if (!blocked)
              PenPrimaryButton(
                label: l10n.commonContinue,
                onPressed: onContinue,
              )
            else ...[
              // Nút mở Cài đặt chỉ có mặt khi người dùng quay lại màn quay sau
              // lần từ chối, không phải ngay sau cú bấm "Don't Allow".
              if (offerSettings) ...[
                PenPrimaryButton(
                  label: l10n.cameraPermissionOpenSettings,
                  onPressed: onOpenSettings,
                ),
                const SizedBox(height: 12),
              ],
              PenOutlineButton(label: l10n.commonLater, onPressed: onLater),
            ],
          ],
        ),
      ),
    );
  }
}

/// A black preview panel with a centered message — shown when the camera can't
/// open (no hardware / permission denied) or while initializing failed.
class _PreviewMessage extends StatelessWidget {
  const _PreviewMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Align(
        alignment: const Alignment(0, 0.55),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 30, color: Colors.white70),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

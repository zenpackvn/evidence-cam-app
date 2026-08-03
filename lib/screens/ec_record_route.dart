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
import 'dart:ui' as ui;

import 'package:analytics/analytics.dart';
import 'package:app_platform/app_platform.dart';
import 'package:feature_capture/feature_capture.dart';
import 'package:flutter/cupertino.dart'
    show
        CupertinoActivityIndicator,
        CupertinoAlertDialog,
        CupertinoDialogAction,
        showCupertinoDialog;
import 'package:flutter/foundation.dart'
    show TargetPlatform, ValueListenable, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';

import '../app/di/injection.dart';

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
    this.onNavAccount,
    this.onSettings,
    this.onSaved,
    this.deviceConditions,
    this.verifyReturnCode,
    this.voiceAnnouncer,
    this.ensureCameraPermission,
    this.initialType = kEcDefaultVideoType,
    this.queueCount = 0,
    this.initialResolution = '720p',
    this.maxRecording = const Duration(minutes: 2),
    this.camera,
    this.isActive,
    super.key,
  });

  /// Xin quyền camera nếu chưa có, trả về `true` khi đã được cấp.
  ///
  /// Bắt buộc chạy trước khi khởi tạo camera: người dùng từ chối ở lần trước
  /// thì plugin `camera` không tự hỏi lại, màn hình chỉ đứng im ở preview đen
  /// mà không nói lý do.
  final Future<bool> Function()? ensureCameraPermission;

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
  final VoidCallback? onNavAccount;

  /// Asks for a video type (opens the type sheet); the chosen label is applied
  /// to the current/next recording. Returns `null` if dismissed.
  /// Mở sheet chọn loại. `mandatory` bật ở lần mở tự động lúc vừa vào màn:
  /// lúc đó chọn loại là bắt buộc nên sheet không cho vuốt xuống hay chạm nền
  /// để bỏ qua — chỉ chọn, hoặc bấm back để sang tab Vận đơn.
  final Future<String?> Function(BuildContext, {bool mandatory})?
  onRequestType;

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
    onClipSaved: (path, tracking, type, durationSeconds, samples) =>
        widget.onSaved?.call(path, tracking, type, durationSeconds, samples),
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
    // The phone sits propped up looking down at the packing table for this
    // flow — it isn't handheld — so free rotation just lets the orientation
    // sensor flicker to landscape at that near-flat resting angle (observed
    // right as recording starts, with the phone never actually moved).
    // Stay on the app-wide portrait lock set in main.dart.
    if (widget.isActive?.value ?? true) {
      // Sau frame đầu — sheet cần một Navigator đã dựng xong.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => unawaited(_startAfterTypeChosen()),
      );
    }
  }

  /// Chọn loại video **xong** rồi mới dựng camera.
  ///
  /// Dựng camera trước thì máy quét chạy ngay và bill trong khung được nhận
  /// luôn — clip đầu ca bị gán loại mặc định trong khi sheet chọn loại còn
  /// đang mở. Sheet đóng lại (chọn loại, hoặc gạt xuống để giữ loại mặc định)
  /// thì camera mới lên.
  /// Hỏi loại video cho tới khi người quay chọn thật, rồi mới dựng camera.
  ///
  /// Bỏ qua sheet KHÔNG còn được coi là đồng ý loại mặc định: loại quyết định
  /// clip nằm ở mục nào trong hồ sơ khiếu nại, gán nhầm thì phải quay lại cả
  /// đơn. Nên chưa chọn thì chưa quay được — hỏi lại.
  ///
  /// Vòng lặp thoát khi rời tab hoặc widget bị gỡ, nên không có đường nào kẹt
  /// người dùng trong một sheet không đóng được.
  Future<void> _startAfterTypeChosen() async {
    // Chờ khung hình hiện tại vẽ xong rồi mới đẩy sheet lên navigator. Gọi
    // giữa nhịp chuyển tab thì navigator đang khoá và `push` ném
    // `!_debugLocked` — lỗi lặp liên tục vì mỗi lượt hỏng lại kéo theo một
    // lượt thử mới.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    await _ensureTypeChosen();
    // Chưa chọn thì KHÔNG dựng camera và cũng KHÔNG hỏi lại ngay: hỏi vòng
    // tròn thì người dùng bị nhốt trong sheet, không bấm back ra được. Màn
    // chờ vẫn hiện với nút back và ô chọn loại ở thanh dưới — muốn quay thì
    // chọn, không muốn thì thoát.
    if (!mounted || !_typePicked) return;
    await _initWithPermission();
  }

  /// Xin quyền rồi mới khởi tạo camera. Không có callback (test, hoặc nền tảng
  /// không cần quyền) thì khởi tạo thẳng như trước.
  Future<void> _initWithPermission() {
    // Gộp về một lần chạy: hai nguồn (postFrame của initState và vòng đời tab)
    // có thể gọi cùng nhịp, nhưng cả hai đều phải thấy camera lên khi xong.
    return _cameraStart ??= _startCamera().whenComplete(() {
      _cameraStart = null;
    });
  }

  Future<void> _startCamera() async {
    // Chốt thứ hai cho cùng một lỗi: mỗi lần dựng camera là một lượt quay mới,
    // không có lý do gì máy quét còn bị treo từ lượt trước.
    _bloc.scanSuspended = false;
    final ensure = widget.ensureCameraPermission;
    if (ensure != null) {
      try {
        await ensure();
      } on Object {
        // Từ chối hay lỗi đều để bloc báo trạng thái camera như thường.
      }
      if (!mounted) return;
    }
    _bloc.add(const RecordingInitRequested());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.isActive?.removeListener(_onActiveChanged);
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
    unawaited(_startAfterTypeChosen());
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
    if (state == AppLifecycleState.inactive) {
      _releasedForBackground = true;
      // Nhớ đơn đang quay TRƯỚC khi `RecordingBackgrounded` chốt clip và xoá
      // `code` khỏi state — đây là thứ duy nhất còn lại để hỏi người quay có
      // muốn quay tiếp đơn đó không sau khi nghe máy xong.
      if (_bloc.state.isRecording && _bloc.state.code.isNotEmpty) {
        _interruptedCode = _bloc.state.code;
      }
      _bloc.add(const RecordingBackgrounded());
    } else if (state == AppLifecycleState.resumed) {
      final needsCamera =
          _releasedForBackground ||
          (_bloc.state.status != RecordingStatus.idle &&
              _bloc.state.status != RecordingStatus.recording);
      _releasedForBackground = false;
      // Tab khác đang hiển thị thì để `_onActiveChanged` lo — dựng camera ở
      // đây sẽ bật nó lên trong lúc người dùng đang xem Vận đơn.
      if (needsCamera && (widget.isActive?.value ?? true)) {
        unawaited(_initWithPermission().then((_) => _askResumeInterrupted()));
      }
    }
  }

  /// Đơn đang quay dở lúc bị cuộc gọi/thông báo cắt ngang, chờ hỏi lại.
  String? _interruptedCode;

  /// Hỏi quay tiếp đơn dở hay kết thúc, sau khi app trở lại từ cuộc gọi.
  ///
  /// Clip dở đã được chốt và lưu lúc bị cắt ngang — không mất gì. Câu hỏi này
  /// chỉ quyết định có mở clip MỚI cho cùng đơn đó hay về trạng thái nghỉ.
  /// Hỏi thay vì tự quay tiếp: người quay có thể đã rời bàn, tự động ghi hình
  /// trần nhà cả phút là vô nghĩa và tốn quota.
  Future<void> _askResumeInterrupted() async {
    final code = _interruptedCode;
    _interruptedCode = null;
    if (code == null || !mounted) return;
    final l10n = context.l10n;
    final resume = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(l10n.recordInterruptedTitle),
        content: Text(l10n.recordInterruptedBody(code)),
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
    if (resume ?? false) {
      if (!mounted) return;
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
      // Trả cờ VÔ ĐIỀU KIỆN, không kèm `mounted`: chỉ cần một nhịp widget bị
      // gỡ đúng lúc sheet đóng là cờ kẹt ở `true` vĩnh viễn, máy quét câm, và
      // triệu chứng là "chọn loại nào cũng không quay được" — không có gì trên
      // màn hình chỉ ra nguyên nhân. Gán vào bloc đã đóng thì vô hại.
      _bloc.scanSuspended = false;
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
          onNavAccount: () =>
              unawaited(_leaveAfterFinalizing(widget.onNavAccount)),
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
        onNavAccount: () =>
            unawaited(_leaveAfterFinalizing(widget.onNavAccount)),
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
      onNavAccount: widget.onNavAccount,
    );
  }
}

/// Fills the black camera area with [controller]'s preview, cover-cropped so it
/// bleeds edge-to-edge without distortion.
class _CoverPreview extends StatefulWidget {
  const _CoverPreview({required this.controller, required this.transitioning});

  final CameraController controller;

  /// True for the entire native start/stop-recording call, set by the bloc
  /// *before* it awaits that call — unlike reacting to [CameraController]'s
  /// own state, this covers the camera-pipeline rebind from its first frame,
  /// not just whatever's left once the Dart await already returned.
  final ValueListenable<bool> transitioning;

  @override
  State<_CoverPreview> createState() => _CoverPreviewState();
}

class _CoverPreviewState extends State<_CoverPreview> {
  // CameraX's own rebind keeps visibly settling for close to a second even
  // after the native call has returned to Dart, so the freeze outlasts it by
  // a comfortable margin rather than trimming it close. 1200ms still let the
  // landscape rebind glitch peek through on a real mid-range device
  // (Samsung SM-M146B) — mid-range camera HALs rebind slower than the
  // emulator/flagship hardware this was first tuned against.
  /// Thời gian giữ khung hình đông cứng sau khi camera rebind xong, để giấu
  /// cú giật xoay hình mà plugin gây ra ở vài khung đầu.
  ///
  /// Từng để 2200ms — an toàn tuyệt đối nhưng người quay thấy màn hình đứng
  /// hình gần hai giây rưỡi mỗi lần chuyển đơn, tưởng app treo. 700ms vẫn phủ
  /// hết giai đoạn giật trong thử nghiệm mà không còn cảm giác khựng. Nếu thấy
  /// preview loé lên bị xoay/xé hình lúc chuyển đơn thì nâng lại con số này.
  static const _settleBuffer = Duration(milliseconds: 700);
  // How often a known-good frame is refreshed while live — frequent enough
  // that the frame on hand the instant a transition starts is always recent.
  static const _refreshInterval = Duration(milliseconds: 250);

  final GlobalKey _boundaryKey = GlobalKey();
  bool _masking = false;
  ui.Image? _lastGoodFrame;
  Timer? _unmaskTimer;
  Timer? _refreshTimer;
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    _masking = widget.transitioning.value;
    widget.transitioning.addListener(_onTransitioningChanged);
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      if (!_masking) unawaited(_refreshLastGoodFrame());
    });
  }

  @override
  void didUpdateWidget(covariant _CoverPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.transitioning, widget.transitioning)) {
      oldWidget.transitioning.removeListener(_onTransitioningChanged);
      widget.transitioning.addListener(_onTransitioningChanged);
    }
  }

  void _onTransitioningChanged() {
    _unmaskTimer?.cancel();
    if (widget.transitioning.value) {
      // Switch to the frame already captured moments ago — grabbing a fresh
      // one *now* would race the rebind-triggered rotation glitch, which can
      // start rendering before this listener even runs.
      setState(() => _masking = true);
    } else {
      _unmaskTimer = Timer(_settleBuffer, () {
        if (mounted) setState(() => _masking = false);
      });
    }
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
        pixelRatio: MediaQuery.devicePixelRatioOf(context),
      );
      if (!mounted || _masking) {
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

  @override
  void dispose() {
    _unmaskTimer?.cancel();
    _refreshTimer?.cancel();
    widget.transitioning.removeListener(_onTransitioningChanged);
    _lastGoodFrame?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return ColoredBox(
      color: Colors.black,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // While masking, the live layer isn't built at all — not even
          // underneath an overlay — so there's no frame in which the
          // rebind-triggered rotation glitch could paint before a cover
          // frame lands on top of it. The periodic refresh below only
          // touches the live layer while unmasked anyway, so nothing is
          // lost by skipping it entirely here.
          if (_masking) {
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
          // Controller đã dispose (đổi độ phân giải, lật camera, app xuống nền,
          // hoặc màn quay chờ người dùng chọn loại video) thì `buildPreview`
          // ném CameraException ngay giữa lúc build. Một khung đen là đủ —
          // controller mới lên là widget rebuild và preview trở lại.
          if (!controller.value.isInitialized) {
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
          // Only the live preview's rotation is affected by the
          // recording-start rebind, not the recorded file — so the correction
          // is scoped to isRecordingVideo, and to Android: package:camera
          // wraps the preview in a RotatedBox *only there*
          // (camera_preview.dart, `_wrapInRotatedBox`), so counter-rotating on
          // iOS just turns an upright preview on its side.
          final recordingTurns =
              controller.value.isRecordingVideo &&
                  defaultTargetPlatform == TargetPlatform.android
              ? 3
              : 0;
          return ClipRect(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxWidth * controller.value.aspectRatio,
                child: RepaintBoundary(
                  key: _boundaryKey,
                  child: RotatedBox(
                    quarterTurns: recordingTurns,
                    // ponytail: iOS dùng thẳng texture thay cho CameraPreview —
                    // CameraPreview lật AspectRatio sang ngang khi
                    // recordingOrientation bị đọc là landscape (điện thoại nằm
                    // gần phẳng trên bàn), làm preview méo/quay dù file quay ra
                    // vẫn đúng. SizedBox trên đã dựng sẵn khung 9:16 đúng rồi.
                    child: defaultTargetPlatform == TargetPlatform.android
                        ? CameraPreview(controller)
                        : controller.buildPreview(),
                  ),
                ),
              ),
            ),
          );
        },
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

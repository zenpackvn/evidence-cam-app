/// Recording-session state machine (FR-01).
///
/// Replaces the old imperative bool flags (`_recording` / `_starting` /
/// `_transitioning` / `_initializing`) with an explicit [RecordingStatus] and a
/// [RecordingSessionBloc] that owns the [CameraService] + [BillScanner] and
/// serializes every camera-mutating operation, so overlapping frames/taps can no
/// longer double-start, double-save, or cut over twice. The presentation lives
/// in `ec_record_route.dart`, which is now a thin view over this bloc.
library;

// The constructor binds public named params to private fields, which
// prefer_initializing_formals can't express (named params can't be private).
// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:io';

import 'package:app_platform/app_platform.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show DeviceOrientation;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'device_samples.dart';
import 'ec_bill_scanner.dart';
import 'ec_video_faststart.dart';
import 'ec_video_stamp.dart';

/// Content of the printed "kết thúc phiên" QR placed on the packing table.
///
/// ponytail: single fixed sentinel — promote to a per-shop setting if shops
/// ever need distinct end codes. Kept deliberately unlike any tracking number.
const kEndSessionQr = 'EVIDENCECAM:END';

/// Dòng thương hiệu in kèm dưới tờ mã dừng quay.
///
/// Tờ này được in ra dán ở bàn đóng hàng và được chia sẻ/tải về dưới dạng file
/// ảnh, nên chữ phải nằm trong chính tấm ảnh — vẽ trên UI thôi thì file gửi đi
/// vẫn là mã QR trần, người nhận không biết nó của đâu ra.
const kEndSessionBrand = 'ZenPack.vn';

/// Cửa sổ hiện màn xác nhận chuyển đơn (A→B) trước khi rơi về màn quay thường.
///
/// Công khai vì màn hình vẽ vòng đếm ngược theo đúng con số này — vòng đếm mà
/// lệch với thời gian thật thì nó chỉ là trang trí.
const kCutoverDisplaySeconds = 2;

const _resolutions = ['240p', '480p', '720p'];

/// What a scanned code means for a clip currently recording an order.
enum RecordingFrameAction {
  /// Same bill still framed, noise, or nothing — keep recording.
  ignore,

  /// A different order's bill appeared — close the current clip, start the new.
  cutover,

  /// The end-QR was shown — finalize the clip and return to idle.
  endSession,
}

/// Pure decision for a frame scanned while recording — the seam that makes the
/// hands-free A→B / end-QR behaviour testable without a camera.
RecordingFrameAction recordingFrameAction(
  String? code,
  String current, {
  String endQr = kEndSessionQr,
}) {
  if (code == null || code.isEmpty) return RecordingFrameAction.ignore;
  if (code == endQr) return RecordingFrameAction.endSession;
  if (normalizeTrackingCode(code) != normalizeTrackingCode(current)) {
    return RecordingFrameAction.cutover;
  }
  return RecordingFrameAction.ignore;
}

/// FR-01.7: tracking-code comparison key shared by scan and manual flows.
String normalizeTrackingCode(String raw) =>
    raw.trim().replaceAll(RegExp(r'\s+'), '').toLowerCase();

/// Whether an idle-scanned [code] may auto-start a clip, given the order whose
/// clip closed most recently ([justClosedCode], already normalized) and the
/// instant its block lapses ([blockedUntil]).
///
/// The seam that makes the "don't immediately re-record the bill that just
/// finished" rule testable without a camera. A parcel normally stays on the
/// packing table after its clip closes, so the idle scan that resumes right
/// after a stop would otherwise re-detect the very same code within one scan
/// cooldown and record it all over again — which is what made the 15' cap
/// announce "đã dừng quay" and then visibly keep recording.
bool idleScanMayStart(
  String code, {
  required String? justClosedCode,
  required DateTime? blockedUntil,
  required DateTime now,
}) {
  if (justClosedCode == null || blockedUntil == null) return true;
  if (!now.isBefore(blockedUntil)) return true;
  return normalizeTrackingCode(code) != justClosedCode;
}

/// Explicit recording-session status. Illegal flag combinations that the old
/// bools allowed (e.g. starting && recording) are now unrepresentable.
/// [interrupted] = clip vẫn ĐANG MỞ, chỉ tạm dừng ghi.
///
/// Khác hẳn `idle`: file chưa chốt, `resumeVideoRecording` nối tiếp được vào
/// đúng clip đó. Phải là trạng thái riêng vì màn hình cần biết để hỏi người
/// quay, và vì mọi thao tác đụng camera đều phải tránh trong lúc này.
enum RecordingStatus { initializing, idle, recording, interrupted, error }

@immutable
class RecordingSessionState {
  const RecordingSessionState({
    this.status = RecordingStatus.initializing,
    this.code = '',
    this.typeLabel = '',
    this.resolutionLabel = '720p',
    this.elapsed = Duration.zero,
    this.zoom = 1,
    this.minZoom = 1,
    this.maxZoom = 1,
    this.cameraCount = 0,
    this.cameraGeneration = 0,
    this.errorMessage,
    this.cutoverFromCode,
    this.cutoverFromDuration,
    this.lowStorageWarning = false,
  });

  final RecordingStatus status;
  final String code;
  final String typeLabel;
  final String resolutionLabel;
  final Duration elapsed;
  final double zoom;
  final double minZoom;
  final double maxZoom;
  final int cameraCount;

  /// Bumped on every (re)initialize so the view rebuilds its camera preview
  /// even when [status] is unchanged (resolution cycle / camera flip).
  final int cameraGeneration;
  final String? errorMessage;

  /// The just-closed order's code and final duration, set for a few seconds
  /// right after an A→B cutover so the view can show a confirmation moment
  /// before settling into the new clip's normal recording screen. Null
  /// otherwise.
  final String? cutoverFromCode;
  final Duration? cutoverFromDuration;

  /// True once, right after init, when free device storage was below
  /// [kLowStorageThresholdMb] — cleared by [RecordingLowStorageDismissed]
  /// once the seller has acknowledged it. FR-09: warn before recording, not
  /// mid-clip.
  final bool lowStorageWarning;

  bool get isRecording => status == RecordingStatus.recording;
  bool get hasMultipleCameras => cameraCount > 1;

  RecordingSessionState copyWith({
    RecordingStatus? status,
    String? code,
    String? typeLabel,
    String? resolutionLabel,
    Duration? elapsed,
    double? zoom,
    double? minZoom,
    double? maxZoom,
    int? cameraCount,
    int? cameraGeneration,
    String? errorMessage,
    bool clearError = false,
    String? cutoverFromCode,
    Duration? cutoverFromDuration,
    bool clearCutover = false,
    bool? lowStorageWarning,
  }) {
    return RecordingSessionState(
      status: status ?? this.status,
      code: code ?? this.code,
      typeLabel: typeLabel ?? this.typeLabel,
      resolutionLabel: resolutionLabel ?? this.resolutionLabel,
      elapsed: elapsed ?? this.elapsed,
      zoom: zoom ?? this.zoom,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
      cameraCount: cameraCount ?? this.cameraCount,
      cameraGeneration: cameraGeneration ?? this.cameraGeneration,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      cutoverFromCode: clearCutover
          ? null
          : (cutoverFromCode ?? this.cutoverFromCode),
      cutoverFromDuration: clearCutover
          ? null
          : (cutoverFromDuration ?? this.cutoverFromDuration),
      lowStorageWarning: lowStorageWarning ?? this.lowStorageWarning,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is RecordingSessionState &&
      other.status == status &&
      other.code == code &&
      other.typeLabel == typeLabel &&
      other.resolutionLabel == resolutionLabel &&
      other.elapsed == elapsed &&
      other.zoom == zoom &&
      other.minZoom == minZoom &&
      other.maxZoom == maxZoom &&
      other.cameraCount == cameraCount &&
      other.cameraGeneration == cameraGeneration &&
      other.errorMessage == errorMessage &&
      other.cutoverFromCode == cutoverFromCode &&
      other.cutoverFromDuration == cutoverFromDuration &&
      other.lowStorageWarning == lowStorageWarning;

  @override
  int get hashCode => Object.hash(
    status,
    code,
    typeLabel,
    resolutionLabel,
    elapsed,
    zoom,
    minZoom,
    maxZoom,
    cameraCount,
    cameraGeneration,
    errorMessage,
    cutoverFromCode,
    cutoverFromDuration,
    lowStorageWarning,
  );
}

@immutable
sealed class RecordingSessionEvent {
  const RecordingSessionEvent();
}

/// Open (or re-open, on resume) the camera and start hands-free scanning.
class RecordingInitRequested extends RecordingSessionEvent {
  const RecordingInitRequested();
}

/// Manual entry: the user typed a tracking code.
class RecordingManualCodeSubmitted extends RecordingSessionEvent {
  const RecordingManualCodeSubmitted(this.code);
  final String code;
}

/// A tracking-code bill was scanned while idle (hands-free scan-to-start).
class RecordingCodeScanned extends RecordingSessionEvent {
  const RecordingCodeScanned(this.code);
  final String code;
}

/// A code was scanned while a clip is recording (hands-free A→B / end-QR).
class RecordingFrameScanned extends RecordingSessionEvent {
  const RecordingFrameScanned(this.code);
  final String code;
}

/// Stop button, or the 15' hard cap firing.
class RecordingStopRequested extends RecordingSessionEvent {
  const RecordingStopRequested();
}

class RecordingTicked extends RecordingSessionEvent {
  const RecordingTicked();
}

/// Fired once the A→B cutover confirmation moment has been on screen long
/// enough; clears [RecordingSessionState.cutoverFromCode].
class RecordingCutoverExpired extends RecordingSessionEvent {
  const RecordingCutoverExpired();
}

/// The seller acknowledged the low-storage warning shown after init.
class RecordingLowStorageDismissed extends RecordingSessionEvent {
  const RecordingLowStorageDismissed();
}

/// App backgrounded: finalize any in-progress clip, then release the camera.
class RecordingBackgrounded extends RecordingSessionEvent {
  const RecordingBackgrounded();
}

/// Có tác động từ bên ngoài (thông báo, trung tâm điều khiển, cuộc gọi đến)
/// khiến việc quay phải dừng lại giữa chừng.
class RecordingInterrupted extends RecordingSessionEvent {
  const RecordingInterrupted();
}

/// Quay tiếp vào đúng clip đang mở sau khi bị gián đoạn.
class RecordingResumeRequested extends RecordingSessionEvent {
  const RecordingResumeRequested();
}

class RecordingResolutionCycled extends RecordingSessionEvent {
  const RecordingResolutionCycled();
}

class RecordingCameraFlipped extends RecordingSessionEvent {
  const RecordingCameraFlipped();
}

class RecordingZoomAdjusted extends RecordingSessionEvent {
  const RecordingZoomAdjusted(this.delta);
  final double delta;
}

class RecordingTypeChanged extends RecordingSessionEvent {
  const RecordingTypeChanged(this.type);
  final String type;
}

/// Owns the camera + scanner and drives the recording session. Every
/// camera-mutating operation runs through [_serialized], so cross-event races
/// (a stop landing mid-cut-over, two frames both starting a clip) can't happen.
class RecordingSessionBloc
    extends Bloc<RecordingSessionEvent, RecordingSessionState> {
  RecordingSessionBloc({
    required CameraService camera,
    required BillScanner scanner,
    required void Function(
      String path,
      String tracking,
      String type,
      int durationSeconds,
      List<DeviceSample> samples,
      DateTime startedAt,
    )
    onClipSaved,
    DeviceConditionSource? deviceConditions,
    VoiceAnnouncerService? voiceAnnouncer,
    CaptureToneService? captureTone,
    EcVideoFaststartService? faststart,
    EcVideoStampService? stamper,
    Future<bool> Function(String code)? verifyReturnCode,
    Future<double?> Function()? checkFreeDiskSpaceMb,
    String initialType = 'Đóng hàng',
    String initialResolution = '720p',
    String endQr = kEndSessionQr,
    Duration maxRecording = const Duration(minutes: 2),
  }) : _camera = camera,
       _scanner = scanner,
       _onClipSaved = onClipSaved,
       _deviceConditions = deviceConditions,
       _voice = voiceAnnouncer ?? VoiceAnnouncerService(),
       _tone = captureTone ?? CaptureToneService(),
       _ownsTone = captureTone == null,
       _faststart = faststart ?? EcVideoFaststartService(),
       _stamper = stamper ?? EcVideoStampService(),
       _verifyReturnCode = verifyReturnCode,
       _checkFreeDiskSpaceMb = checkFreeDiskSpaceMb ?? getFreeDiskSpaceMb,
       _endQr = endQr,
       _maxRecording = maxRecording,
       super(
         RecordingSessionState(
           typeLabel: initialType,
           resolutionLabel: _resolutions.contains(initialResolution)
               ? initialResolution
               : '720p',
         ),
       ) {
    on<RecordingInitRequested>(_onInit);
    on<RecordingManualCodeSubmitted>(_onManualCodeSubmitted);
    on<RecordingCodeScanned>(_onCodeScanned, transformer: droppable());
    on<RecordingFrameScanned>(_onFrameScanned, transformer: droppable());
    on<RecordingStopRequested>(_onStopRequested);
    on<RecordingTicked>(_onTicked);
    on<RecordingCutoverExpired>(_onCutoverExpired);
    on<RecordingBackgrounded>(_onBackgrounded);
    on<RecordingInterrupted>(_onInterrupted);
    on<RecordingResumeRequested>(_onResumeRequested);
    on<RecordingResolutionCycled>(_onResolutionCycled);
    on<RecordingCameraFlipped>(_onCameraFlipped);
    on<RecordingZoomAdjusted>(_onZoomAdjusted);
    on<RecordingTypeChanged>(_onTypeChanged);
    on<RecordingLowStorageDismissed>(_onLowStorageDismissed);
  }

  final CameraService _camera;
  final BillScanner _scanner;

  /// `(đường dẫn, mã đơn, loại, thời lượng, mẫu thiết bị, MỐC BẤM QUAY)`.
  final void Function(
    String,
    String,
    String,
    int,
    List<DeviceSample>,
    DateTime,
  )
  _onClipSaved;

  /// Null = không lấy mẫu điều kiện thiết bị (test widget, và mọi luồng chưa
  /// nối nguồn thật ở composition root). Clip khi đó vẫn quay và vẫn upload
  /// bình thường, chỉ là bản render sau này chỉ có giờ + mã vận đơn.
  final DeviceConditionSource? _deviceConditions;
  final VoiceAnnouncerService _voice;
  final CaptureToneService _tone;

  /// Bỏ qua mọi mã quét được, kể cả mã bắt đầu quay lẫn mã cutover.
  ///
  /// Bật khi có tấm che phủ lên khung ngắm mà người quay đang thao tác —
  /// hiện là sheet chọn loại video. Camera vẫn chạy để preview không giật,
  /// nhưng bill lọt vào khung lúc đó là ngoài ý muốn: người quay đang nhìn
  /// sheet chứ không canh bill, mà máy lại lẳng lặng mở clip cho mã đó.
  bool scanSuspended = false;

  /// True when this bloc built its own [CaptureToneService] and must therefore
  /// release the underlying player on close. A caller-supplied one is shared
  /// (app-lifetime, like the voice announcer) and is not ours to dispose.
  final bool _ownsTone;
  final EcVideoFaststartService _faststart;
  final EcVideoStampService _stamper;

  /// Mốc bấm quay của clip đang mở.
  ///
  /// Dùng làm gốc cho đồng hồ nung vào khung hình. Lấy `now - thời lượng` lúc
  /// quay xong thì lệch một nhịp so với `capturedAt` backend ghi, và hai con
  /// số chênh nhau trên cùng một bằng chứng là thứ không giải thích được với
  /// người đi khiếu nại.
  DateTime? _clipStartedAt;
  final Future<double?> Function() _checkFreeDiskSpaceMb;
  final Future<bool> Function(String code)? _verifyReturnCode;
  final String _endQr;
  final Duration _maxRecording;

  List<CameraDescription> _cameras = const [];
  int _cameraIndex = 0;
  bool _liveScan = true;
  Timer? _timer;
  Timer? _cutoverTimer;

  /// Đồng hồ đơn điệu của clip đang quay — nguồn `t_ms` của [_samples].
  /// KHÔNG dùng giờ tường: đổi giờ máy giữa lúc quay không được phép làm xô
  /// lệch timeline mẫu.
  final Stopwatch _clipClock = Stopwatch();
  List<DeviceSample> _samples = [];
  bool _samplingBusy = false;

  bool _idleScanBusy = false;
  bool _recScanBusy = false;
  DateTime? _lastRecScanAt;
  DateTime? _lastIdleScanAt;
  String? _lastRejectedReturnCode;

  /// True from the moment the near-cap warning has been spoken for the clip
  /// currently recording, so the 60-second heads-up is announced once per clip
  /// rather than on every tick past the threshold.
  bool _nearLimitWarned = false;

  /// True once this clip's hard cap has already queued its stop. Without it the
  /// 1s tick keeps firing (and re-requesting a stop) for as long as
  /// [_finalize] is still awaiting the camera, which announced "đã dừng quay"
  /// several times over for a single cap.
  bool _capRequested = false;

  /// The tracking code of the clip that just closed, plus how long it stays
  /// blocked from auto-starting a new one. See [_onIdleFrame].
  String? _suppressedCode;
  DateTime? _suppressedUntil;

  // ML Kit's per-frame scan is expensive enough to visibly stutter the video
  // encoder if run on every delivered frame, and instant recognition isn't
  // how scanner apps normally behave anyway — recognition settles over a
  // few seconds rather than firing on the very first frame a code appears
  // in. One shared cooldown covers both idle (waiting for a bill) and
  // in-recording (watching for the end-QR) scanning.
  static const _scanCooldown = Duration(seconds: 2);

  // Async mutex chaining all camera-mutating ops. ponytail: a single global
  // lock — fine here because there's exactly one camera; nothing to parallelize.
  Future<void> _camLock = Future<void>.value();

  /// How long a single clip may run before it is auto-closed (FR-01, 15').
  Duration get maxRecording => _maxRecording;

  /// Elapsed time at which the clip enters its final minute: the view swaps to
  /// the cap-warning screen with a countdown and the warning is spoken once.
  ///
  /// The cap is the shop's setting and can be as short as a minute (FR-18), so
  /// short caps fall back to half the clip — a warning that fires at second 0
  /// is no warning at all.
  Duration get nearLimitAt => _maxRecording > const Duration(minutes: 2)
      ? _maxRecording - _nearLimitLead
      : _maxRecording * 0.5;

  /// How long before the cap the warning fires.
  static const _nearLimitLead = Duration(minutes: 1);

  /// Câu cảnh báo gần trần, đọc trần **thật của shop** thay vì con số cứng —
  /// `maxRecording` đến từ `shop.clipBudget`, nên shop đặt 10 phút mà vẫn nghe
  /// "mười lăm phút" là sai. Trần lẻ giây thì bỏ phần phút đi cho khỏi phải
  /// đọc "hai phút ba mươi giây" giữa lúc đang đóng hàng.
  String get _nearLimitSpeech {
    final minutes = _maxRecording.inMinutes;
    if (minutes < 1) return 'Video sắp tự chốt';
    return 'Sắp chạm trần $minutes phút, video sẽ tự chốt';
  }

  /// How long the just-closed order's code stays blocked from auto-starting a
  /// new clip, measured from the last frame it was seen in. The bill normally
  /// stays on the packing table for a while after its clip closes, so without
  /// this the idle scan that resumes right after [_finalize] re-detects the
  /// same code within one cooldown and records it all over again — which is
  /// what made the 15' cap announce "đã dừng quay" and then keep recording.
  static const _reArmDelay = Duration(seconds: 5);

  /// The live controller for the preview widget. The bloc can't hide it — a
  /// `CameraPreview` needs the actual controller — so the view reads it here and
  /// rebuilds when [RecordingSessionState.cameraGeneration] changes.
  CameraController? get previewController => _camera.controller;

  /// True while starting/stopping a recording is rebinding the camera's
  /// capture pipeline (adding or dropping the video-capture use case) — a
  /// window in which the live preview's rotation visibly flails on some
  /// devices (a camera_android_camerax quirk unrelated to the saved file's
  /// rotation). The view masks the preview for this signal rather than
  /// trying to track exactly when the native side has settled.
  final ValueNotifier<bool> previewTransitioning = ValueNotifier<bool>(false);

  Future<void> _serialized(Future<void> Function() op) {
    final next = _camLock.then((_) => op());
    _camLock = next.catchError((_) {});
    return next;
  }

  ResolutionPreset _presetFor(String label) => switch (label) {
    '240p' => ResolutionPreset.low,
    '480p' => ResolutionPreset.medium,
    _ => ResolutionPreset.high,
  };

  Future<void> _onInit(
    RecordingInitRequested event,
    Emitter<RecordingSessionState> emit,
  ) async {
    emit(
      state.copyWith(status: RecordingStatus.initializing, clearError: true),
    );
    try {
      await _serialized(() async {
        final cameras = await _camera.getAvailableCameras();
        if (cameras.isEmpty) {
          if (!isClosed) {
            emit(
              state.copyWith(
                status: RecordingStatus.error,
                errorMessage:
                    'Thiết bị không có camera. iOS Simulator không hỗ trợ '
                    'camera — hãy chạy trên máy thật.',
              ),
            );
          }
          return;
        }
        var index = cameras.indexWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
        );
        if (index < 0) index = 0;
        _cameras = cameras;
        _cameraIndex = index;
        final (minZoom, maxZoom) = await _initCamera();
        if (isClosed) return;
        // Best-effort: a platform that can't report free space (or a transient
        // channel error) should never block opening the session — silence, not
        // a false alarm, is the safe default (see [getFreeDiskSpaceMb]).
        double? freeMb;
        try {
          freeMb = await _checkFreeDiskSpaceMb();
        } on Object {
          freeMb = null;
        }
        if (isClosed) return;
        emit(
          state.copyWith(
            status: RecordingStatus.idle,
            cameraCount: cameras.length,
            cameraGeneration: state.cameraGeneration + 1,
            zoom: minZoom,
            minZoom: minZoom,
            maxZoom: maxZoom,
            clearError: true,
            lowStorageWarning:
                freeMb != null && freeMb < kLowStorageThresholdMb,
          ),
        );
      });
      if (state.status == RecordingStatus.idle) await _startIdleScan();
    } on Object catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: RecordingStatus.error,
            errorMessage: 'Không mở được camera: $e',
          ),
        );
      }
    }
  }

  Future<(double, double)> _initCamera() async {
    await _camera.initialize(
      description: _cameras[_cameraIndex],
      resolutionPreset: _presetFor(state.resolutionLabel),
      imageFormatGroup: BillScanner.imageFormatGroup,
      // Bằng chứng đóng gói nằm ở hình, không ở tiếng: mic chỉ thu tạp âm kho
      // và câu chuyện riêng của nhân viên. Tắt từ gốc thì clip không có luồng
      // âm thanh nào — xem lại trong app, tải về máy hay gửi qua hồ sơ đều im,
      // khỏi phải tắt tiếng ở từng chỗ. Cũng bớt dung lượng mỗi clip.
      enableAudio: false,
    );
    try {
      // The phone sits propped up looking down at the packing table for this
      // flow — it isn't handheld — so the orientation sensor can misread a
      // near-flat resting angle as landscape right at the instant recording
      // starts. Locking here removes the sensor from that decision (see
      // CameraService.lockCaptureOrientation). Re-applied across
      // resolution/lens changes, which re-run this same init.
      await _camera.lockCaptureOrientation(DeviceOrientation.portraitUp);
    } on Object {
      // Best-effort — unsupported on some hardware/platforms; the app-wide
      // portrait lock still keeps the window itself from rotating.
    }
    final minZoom = await _camera.getMinZoomLevel();
    final maxZoom = await _camera.getMaxZoomLevel();
    return (minZoom, maxZoom);
  }

  /// Streams idle frames to the scanner; a detected tracking code scan-starts.
  Future<void> _startIdleScan() async {
    if (!_camera.isInitialized ||
        state.isRecording ||
        _camera.isStreamingImages) {
      return;
    }
    try {
      await _camera.startImageStream(_onIdleFrame);
    } on Object {
      // Image streaming unsupported (e.g. web) — manual entry still works.
    }
  }

  Future<void> _onIdleFrame(CameraImage image) async {
    // `scanSuspended` chặn ngay từ khung hình, trước cả khi chạy nhận dạng:
    // chặn ở tầng sự kiện thì máy vẫn giải mã từng khung rồi mới vứt kết quả —
    // tốn pin vô ích, và chỉ cần một nhánh nào đó quên kiểm tra là mã lại lọt.
    if (scanSuspended ||
        state.status != RecordingStatus.idle ||
        _idleScanBusy ||
        _cameras.isEmpty) {
      return;
    }
    final lastScan = _lastIdleScanAt;
    if (lastScan != null &&
        DateTime.now().difference(lastScan) < _scanCooldown) {
      return;
    }
    _idleScanBusy = true;
    _lastIdleScanAt = DateTime.now();
    try {
      final code = await _scanner.scan(
        image,
        _cameras[_cameraIndex],
        deviceOrientation:
            _camera.controller?.value.deviceOrientation ??
            DeviceOrientation.portraitUp,
      );
      // An end-QR left on the table means nothing while idle — don't record it.
      if (code != null &&
          code.isNotEmpty &&
          code != _endQr &&
          _mayAutoStart(code) &&
          state.status == RecordingStatus.idle &&
          !isClosed) {
        add(RecordingCodeScanned(code));
      }
    } finally {
      _idleScanBusy = false;
    }
  }

  /// Applies [idleScanMayStart] to [code].
  ///
  /// Cửa sổ chặn chạy **cố định** từ lúc clip đóng, không gia hạn theo từng
  /// khung hình còn thấy bill. Bản trước gia hạn liên tục, nên kiện hàng nằm
  /// yên trên bàn bị chặn vĩnh viễn — quay lỗi muốn quay lại chính đơn đó thì
  /// không cách nào bắt đầu được, phải nhấc kiện ra khỏi khung rồi đưa lại.
  /// Nay hết [_reArmDelay] là mã cũ được nhận lại như mọi mã khác, đúng nhu cầu
  /// quay lại khi lỡ quay hỏng; đổi lại, kiện bị bỏ quên trên bàn có thể tự
  /// quay tiếp sau ngần ấy giây. Manual entry vẫn bỏ qua chặn hoàn toàn — gõ
  /// tay là yêu cầu quay rõ ràng.
  /// Tút báo "bắt đầu từ đây", rồi trả quyền điều khiển ngay để camera lăn.
  ///
  /// Chỉ chờ tiếng tút (120ms) — nó là mốc bắt đầu quay nên phải dứt trước
  /// khung hình đầu. Câu "Đã bắt đầu quay" phát sau, chồng lên đoạn đầu clip;
  /// đoạn đó được [EcVideoFaststartService] làm câm khi remux, nên người xem
  /// lại không nghe thấy mà người quay vẫn được báo ngay.
  ///
  /// Best-effort như mọi thông báo khác: engine TTS hỏng hoặc thiếu asset thì
  /// bỏ qua chứ không chặn việc ghi hình.
  Future<void> _announceStart() async {
    try {
      await _tone.beep().timeout(const Duration(seconds: 2));
    } on Object {
      // Kệ — quay quan trọng hơn thông báo.
    }
    try {
      // CHỜ câu nói dứt, không bắn rồi bỏ đó.
      //
      // Bắn kiểu `unawaited` thì camera lăn ngay sau đó, mà khởi động camera
      // giành lại phiên âm thanh của hệ điều hành — câu nói đang phát dở bị
      // cắt ngang, phần lớn trường hợp là chưa kịp ra tiếng nào. Người quay
      // chỉ nghe tút rồi im, tưởng máy chưa nhận.
      //
      // Trần 2.5 giây để một engine TTS treo không giữ luôn việc ghi hình.
      await _voice
          .speak('Đã bắt đầu quay')
          .timeout(const Duration(milliseconds: 2500));
    } on Object {
      // Kệ — quay quan trọng hơn thông báo.
    }
  }

  bool _mayAutoStart(String code) {
    final mayStart = idleScanMayStart(
      code,
      justClosedCode: _suppressedCode,
      blockedUntil: _suppressedUntil,
      now: DateTime.now(),
    );
    if (mayStart) {
      _suppressedCode = null;
      _suppressedUntil = null;
    }
    return mayStart;
  }

  Future<void> _onManualCodeSubmitted(
    RecordingManualCodeSubmitted event,
    Emitter<RecordingSessionState> emit,
  ) => _beginRecording(event.code.trim(), emit);

  Future<void> _onCodeScanned(
    RecordingCodeScanned event,
    Emitter<RecordingSessionState> emit,
  ) async {
    if (scanSuspended) return;
    final code = event.code.trim();
    // A return clip's tracking code is checked against the shop's saved
    // orders first. [_verifyReturnCode] itself decides what "not found" means
    // to the user — today that's a dialog offering manual entry or confirming
    // a new order (mirrors the manual-entry find-or-create flow) — this bloc
    // only needs to know whether recording may proceed for [code].
    if (state.typeLabel == 'Trả hàng' && _verifyReturnCode != null) {
      // Mã lạ chỉ được **báo tiếng**, không còn chặn quay. Hàng hoàn nhiều khi
      // chưa có đơn trong hệ thống (khách trả thẳng, đơn tạo sau), mà chặn thì
      // mất luôn bằng chứng mở kiện — thứ duy nhất không quay lại được. Người
      // quay nghe "Sai mã" là biết phải đối chiếu sau, clip vẫn được lưu.
      //
      // Vẫn nhớ mã vừa cảnh báo để bill nằm trong khung không làm câu thông
      // báo lặp lại mỗi nhịp quét.
      if (_lastRejectedReturnCode != code) {
        final known = await _verifyReturnCode(code);
        if (!known) {
          _lastRejectedReturnCode = code;
          unawaited(_voice.speak('Sai mã'));
        } else {
          _lastRejectedReturnCode = null;
        }
      }
    }
    await _beginRecording(code, emit);
  }

  Future<void> _beginRecording(
    String code,
    Emitter<RecordingSessionState> emit,
  ) async {
    if (state.isRecording) return;
    _suppressedCode = null;
    _suppressedUntil = null;
    try {
      await _serialized(() async {
        if (!_camera.isInitialized || _camera.isRecordingVideo) return;
        // Thông báo phát XONG rồi mới lăn camera. Trước đây bắn kiểu
        // `unawaited` cho nhanh, nhưng loa và mic cùng một máy: camera khởi
        // động chồng lên lúc tiếng tút/câu nói còn đang phát, nên chúng bị thu
        // thẳng vào clip và người xem lại nghe "đã bắt đầu quay" trong video.
        // Chờ ở đây tốn hơn một giây trước khung hình đầu — chấp nhận được vì
        // người quay vừa mới quét mã, chưa kịp thao tác gì.
        await _announceStart();
        previewTransitioning.value = true;
        try {
          if (_camera.isStreamingImages) await _camera.stopImageStream();
          await _startVideoWithScan();
        } finally {
          previewTransitioning.value = false;
        }
        _nearLimitWarned = false;
        _capRequested = false;
        if (isClosed) return;
        emit(
          state.copyWith(
            status: RecordingStatus.recording,
            code: code,
            elapsed: Duration.zero,
            clearError: true,
          ),
        );
        _startTimer();
      });
    } on Object catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: RecordingStatus.idle,
            errorMessage: 'Không bắt đầu quay được: $e',
          ),
        );
      }
    }
  }

  /// Records with the hands-free scan stream; if the hardware rejects concurrent
  /// stream+record, records without it and disables live cut-over for good.
  Future<void> _startVideoWithScan() async {
    _clipStartedAt = DateTime.now();
    if (_liveScan) {
      try {
        await _camera.startVideoRecording(onAvailable: _onRecordingFrame);
        return;
      } on Object {
        _liveScan = false;
        if (_camera.isRecordingVideo) return;
      }
    }
    await _camera.startVideoRecording();
  }

  /// Watches for the end-QR or a different order's bill while a clip records.
  ///
  /// Hardware that can't analyse and record at once simply never delivers
  /// frames here (see [_startVideoWithScan]) — live cut-over quietly goes away
  /// on those devices while the clip itself still records and the manual stop
  /// button still works.
  Future<void> _onRecordingFrame(CameraImage image) async {
    // Cùng lý do như `_onIdleFrame`: chặn từ khung hình, đừng giải mã rồi vứt.
    if (scanSuspended ||
        state.status != RecordingStatus.recording ||
        _recScanBusy ||
        _cameras.isEmpty) {
      return;
    }
    final lastScan = _lastRecScanAt;
    if (lastScan != null &&
        DateTime.now().difference(lastScan) < _scanCooldown) {
      return;
    }
    _recScanBusy = true;
    _lastRecScanAt = DateTime.now();
    try {
      final code = await _scanner.scan(
        image,
        _cameras[_cameraIndex],
        deviceOrientation:
            _camera.controller?.value.deviceOrientation ??
            DeviceOrientation.portraitUp,
      );
      if (code != null && code.isNotEmpty && !isClosed) {
        add(RecordingFrameScanned(code));
      }
    } finally {
      _recScanBusy = false;
    }
  }

  Future<void> _onFrameScanned(
    RecordingFrameScanned event,
    Emitter<RecordingSessionState> emit,
  ) async {
    if (scanSuspended) return;
    if (state.status != RecordingStatus.recording) return;
    switch (recordingFrameAction(event.code, state.code, endQr: _endQr)) {
      case RecordingFrameAction.endSession:
        await _finalize(emit, next: null);
      case RecordingFrameAction.cutover:
        await _finalize(emit, next: event.code.trim());
      case RecordingFrameAction.ignore:
        break;
    }
  }

  Future<void> _onStopRequested(
    RecordingStopRequested event,
    Emitter<RecordingSessionState> emit,
  ) => _finalize(emit, next: null);

  /// Closes the current clip (handing it to the `onClipSaved` sink) and either
  /// returns to idle scanning ([next] null) or immediately opens the next
  /// order's clip without dropping to the idle screen (SC-2 seamless hand-off).
  Future<void> _finalize(
    Emitter<RecordingSessionState> emit, {
    required String? next,
  }) async {
    // Captured before any emit overwrites them — [EcCutoverBScreen] needs to
    // show what just closed alongside what's now recording.
    final closedCode = state.code;
    final closedElapsed = state.elapsed;
    // Blocks the bill that just closed from immediately auto-starting the next
    // clip while it is still sitting in frame (see [_reArmDelay]).
    if (closedCode.isNotEmpty) {
      _suppressedCode = normalizeTrackingCode(closedCode);
      _suppressedUntil = DateTime.now().add(_reArmDelay);
    }
    try {
      await _serialized(() async {
        _cancelTimer();
        _nearLimitWarned = false;
        _capRequested = false;
        previewTransitioning.value = true;
        try {
          if (_camera.isRecordingVideo) {
            final file = await _camera.stopVideoRecording();
            // Remuxing is fast but still I/O — done in the background so it
            // never delays the hands-free cutover to the next order or the
            // return to idle scanning below.
            unawaited(
              _prepareAndSave(
                file.path,
                state.code,
                state.typeLabel,
                closedElapsed.inSeconds,
              ),
            );
          }
          // Thông báo nằm giữa hai clip — sau khi clip cũ đã chốt, trước khi
          // clip mới lăn — nên không lọt vào clip nào. Phát trước lúc dừng thì
          // mic còn mở và tiếng tút bị thu vào cuối clip vừa quay.
          //
          // Cutover chỉ kêu tút, không đọc tiếng: người quay đóng hàng liên
          // tục, nghe lại nguyên câu ở mỗi đơn thành ồn hơn là hữu ích. Chỉ
          // lần bắt đầu từ trạng thái nghỉ (`_beginRecording`) mới đọc cả câu.
          if (next != null) {
            // Tút bắn song song, KHÔNG chờ: chờ nó dứt là chèn thêm hơn trăm
            // mili giây chết giữa hai clip, đúng cái khựng người quay thấy khi
            // chuyển đơn. Tút lọt sang đầu clip mới cũng không sao — 2.5 giây
            // đầu mỗi clip đã được làm câm lúc remux.
            unawaited(_tone.beep());
            await _startVideoWithScan();
          } else {
            // Về nghỉ thì không còn gì đang ghi, nên khỏi chờ câu nói.
            unawaited(_voice.speak('Đã dừng quay'));
          }
        } finally {
          previewTransitioning.value = false;
        }
        if (next != null) {
          if (isClosed) return;
          // Không còn màn "Chuẩn bị ghi hình tiếp theo": clip mới đã lăn từ
          // `_startVideoWithScan()` phía trên, nên chèn thêm 2 giây màn xác
          // nhận chỉ che mất khung hình người quay đang cần nhìn. Tiếng tút đã
          // báo máy nhận mã mới, vào thẳng màn quay là đủ.
          emit(
            state.copyWith(
              status: RecordingStatus.recording,
              code: next,
              elapsed: Duration.zero,
              clearCutover: true,
            ),
          );
          _startTimer();
        } else if (!isClosed) {
          emit(state.copyWith(status: RecordingStatus.idle));
        }
      });
      if (state.status == RecordingStatus.idle) await _startIdleScan();
    } on Object catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: RecordingStatus.idle,
            errorMessage: 'Lưu video lỗi: $e',
          ),
        );
      }
    }
  }

  /// Makes [path] streamable (moov atom to the front) before handing it to
  /// [_onClipSaved] — best-effort, since [EcVideoFaststartService.prepare]
  /// falls back to the original file on any failure.
  ///
  /// Remux cho phát được ngay, rồi nung ngày / giờ / mã vận đơn vào khung hình.
  ///
  /// Nung ở đây nghĩa là BẢN ĐẨY LÊN CLOUD cũng mang dấu, không riêng bản tải
  /// về qua app. Chủ đích, theo yêu cầu: người nhận link hồ sơ tải clip thẳng
  /// từ cloud phải đọc được clip của đơn nào, quay lúc nào — đó đúng là người
  /// cần thông tin đó nhất.
  ///
  /// Đánh đổi đã biết: nung là encode lại, nên clip lưu trữ không còn là chuỗi
  /// byte gốc từ cảm biến như FR-07 mô tả, và mỗi clip tốn thêm một lượt encode
  /// ngay sau khi quay. Fail-safe: nung hỏng thì `stamp` trả lại bản chưa nung,
  /// clip vẫn lên cloud đủ.
  Future<void> _prepareAndSave(
    String path,
    String code,
    String typeLabel,
    int durationSeconds,
  ) async {
    final streamable = await _faststart.prepare(path);
    final startedAt =
        _clipStartedAt ??
        DateTime.now().subtract(Duration(seconds: durationSeconds));
    _clipStartedAt = null;
    String two(int n) => n.toString().padLeft(2, '0');
    final stamped = await _stamper.stamp(
      streamable,
      lines: [
        '${two(startedAt.day)}/${two(startedAt.month)}/${startedAt.year}',
        '${two(startedAt.hour)}:${two(startedAt.minute)}:'
            '${two(startedAt.second)}',
        if (code.isNotEmpty) code,
      ],
      clockStart: startedAt,
      clockSeconds: durationSeconds,
      // Bitrate encode lại đi theo đúng độ phân giải shop đã chọn. Thiếu tham
      // số này thì hạ xuống 240p/480p không làm tệp nhẹ đi chút nào — đó đúng
      // là cách nó hỏng trước 2026-08-08.
      resolution: state.resolutionLabel,
    );
    if (stamped != streamable) await _deleteQuietly(streamable);
    _onClipSaved(
      stamped,
      code,
      typeLabel,
      durationSeconds,
      _samples,
      startedAt,
    );
  }

  Future<void> _deleteQuietly(String path) async {
    try {
      await File(path).delete();
    } on Object {
      // Đã biến mất, hoặc không phải của mình — không có gì để dọn.
    }
  }

  void _onTicked(RecordingTicked event, Emitter<RecordingSessionState> emit) {
    if (state.status != RecordingStatus.recording) return;
    final elapsed = state.elapsed + const Duration(seconds: 1);
    emit(state.copyWith(elapsed: elapsed));
    if (elapsed.inSeconds % kSampleInterval.inSeconds == 0) {
      unawaited(_sampleDeviceCondition());
    }
    // Heads-up a minute out: the seller is packing with both hands and isn't
    // looking at the countdown the view now shows, so the cap is spoken too.
    if (!_nearLimitWarned && elapsed >= nearLimitAt) {
      _nearLimitWarned = true;
      unawaited(_voice.speak(_nearLimitSpeech));
    }
    // Hard cap: auto-close the clip at 15' so a forgotten session finalizes.
    if (!_capRequested && elapsed >= _maxRecording) {
      _capRequested = true;
      add(const RecordingStopRequested());
    }
  }

  Future<void> _onBackgrounded(
    RecordingBackgrounded event,
    Emitter<RecordingSessionState> emit,
  ) async {
    // Finalize an in-progress clip BEFORE releasing the camera, so backgrounding
    // never loses the seller's evidence (FR-08/FR-09). Keyed off the camera's
    // own recording state so it fires even if the OS interrupts us mid-frame.
    // Skips the faststart remux (unlike _finalize) — the OS can kill this
    // process shortly after backgrounding, and losing the clip entirely while
    // ffmpeg is mid-remux would be worse than saving one that merely buffers
    // badly on playback.
    final elapsedAtBackground = state.elapsed;
    await _serialized(() async {
      _cancelTimer();
      if (_camera.isRecordingVideo) {
        try {
          final file = await _camera.stopVideoRecording();
          _onClipSaved(
            file.path,
            state.code,
            state.typeLabel,
            elapsedAtBackground.inSeconds,
            _samples,
            _clipStartedAt ?? DateTime.now().subtract(elapsedAtBackground),
          );
        } on Object {
          // OS already tore the camera down mid-record; nothing recoverable.
        }
      }
      await _camera.dispose();
      if (!isClosed) emit(state.copyWith(status: RecordingStatus.initializing));
    });
  }

  /// Tạm dừng ghi mà KHÔNG chốt clip.
  ///
  /// Giữ file đang mở để `resumeVideoRecording` nối tiếp vào chính nó — đó là
  /// điều kiện để "quay tiếp" nghĩa là cùng một video, chứ không phải mở clip
  /// mới cùng mã. Camera cũng không dispose, vì dispose là mất luôn phiên ghi.
  ///
  /// Nói to ra loa: người quay đang ôm thùng hàng, mắt không nhìn màn hình.
  /// Không nói thì họ gói xong cả đơn rồi mới biết máy đã ngừng ghi từ lâu.
  Future<void> _onInterrupted(
    RecordingInterrupted event,
    Emitter<RecordingSessionState> emit,
  ) async {
    if (state.status != RecordingStatus.recording) return;
    await _serialized(() async {
      if (!_camera.isRecordingVideo) return;
      try {
        await _camera.pauseVideoRecording();
      } on Object {
        // Máy không cho tạm dừng — để nguyên trạng thái đang quay, đường
        // `RecordingBackgrounded` vẫn chốt được clip như trước.
        return;
      }
      _cancelTimer();
      _clipClock.stop();
      if (!isClosed) {
        emit(state.copyWith(status: RecordingStatus.interrupted));
      }
    });
  }

  /// Khai báo lại phiên âm thanh sau khi cuộc gọi thu hồi nó.
  ///
  /// Gọi lúc app quay về từ nền. Không gọi thì nghe máy xong là app câm hẳn:
  /// mất cả tiếng tút lẫn mọi câu thông báo, cho tới khi khởi động lại app.
  Future<void> restoreAudio() => _voice.reactivate();

  /// Nói to là việc quay đã bị cắt ngang.
  ///
  /// Gọi lúc app ĐÃ trở lại, không phải lúc bị đẩy xuống nền: dưới nền thì loa
  /// không phát được, câu nói rơi vào hư không đúng lúc cần nhất.
  Future<void> announceInterrupted() => _voice.speak(_interruptedSpeech);

  /// Câu nói khi việc quay bị cắt ngang.
  static const _interruptedSpeech = 'Quá trình quay bị gián đoạn';

  /// Quay tiếp vào đúng clip đang mở.
  ///
  /// Nối lại hỏng (hay gặp sau cuộc gọi đã nghe: iOS thu hồi phiên ghi khi app
  /// xuống nền thật) thì CHỐT clip đang có rồi báo về `idle`, chứ không im
  /// lặng. Màn hình dựa vào đó để mở clip mới cho cùng đơn — chia làm hai file
  /// nhưng không mất giây nào đã quay.
  Future<void> _onResumeRequested(
    RecordingResumeRequested event,
    Emitter<RecordingSessionState> emit,
  ) async {
    if (state.status != RecordingStatus.interrupted) return;
    await _serialized(() async {
      try {
        await _camera.resumeVideoRecording();
      } on Object {
        await _finalizeInterrupted(emit);
        return;
      }
      _clipClock.start();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!isClosed) add(const RecordingTicked());
      });
      if (!isClosed) emit(state.copyWith(status: RecordingStatus.recording));
    });
  }

  /// Chốt clip đang tạm dừng và về `idle`, giữ nguyên những gì đã quay.
  Future<void> _finalizeInterrupted(
    Emitter<RecordingSessionState> emit,
  ) async {
    _cancelTimer();
    if (_camera.isRecordingVideo) {
      try {
        final file = await _camera.stopVideoRecording();
        await _prepareAndSave(
          file.path,
          state.code,
          state.typeLabel,
          state.elapsed.inSeconds,
        );
      } on Object {
        // Phiên ghi đã bị hệ điều hành thu hồi — không còn gì lấy lại được.
      }
    }
    if (!isClosed) {
      emit(
        state.copyWith(
          status: RecordingStatus.idle,
          elapsed: Duration.zero,
          code: '',
        ),
      );
    }
  }

  Future<void> _onResolutionCycled(
    RecordingResolutionCycled event,
    Emitter<RecordingSessionState> emit,
  ) async {
    if (state.isRecording || _cameras.isEmpty) return;
    final next =
        _resolutions[(_resolutions.indexOf(state.resolutionLabel) + 1) %
            _resolutions.length];
    await _reinitialize(emit, resolutionLabel: next);
  }

  Future<void> _onCameraFlipped(
    RecordingCameraFlipped event,
    Emitter<RecordingSessionState> emit,
  ) async {
    if (state.isRecording || _cameras.length < 2) return;
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _reinitialize(emit, resolutionLabel: state.resolutionLabel);
  }

  /// Re-opens the camera (new resolution and/or lens) while idle, then resumes
  /// scanning. Bumps [RecordingSessionState.cameraGeneration] so the preview
  /// rebuilds against the new controller.
  Future<void> _reinitialize(
    Emitter<RecordingSessionState> emit, {
    required String resolutionLabel,
  }) async {
    try {
      await _serialized(() async {
        // Switches the view away from CameraPreview (see _buildPreview)
        // before _initCamera disposes the old controller below — otherwise
        // the still-mounted preview can get one more rebuild against the
        // now-disposed controller and throw (a benign race; see
        // installGlobalErrorHandlers for why it's harmless when it does).
        if (!isClosed) {
          emit(
            state.copyWith(
              status: RecordingStatus.initializing,
              resolutionLabel: resolutionLabel,
            ),
          );
        }
        final (minZoom, maxZoom) = await _initCamera();
        if (isClosed) return;
        emit(
          state.copyWith(
            status: RecordingStatus.idle,
            cameraGeneration: state.cameraGeneration + 1,
            zoom: minZoom,
            minZoom: minZoom,
            maxZoom: maxZoom,
          ),
        );
      });
      await _startIdleScan();
    } on Object catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: RecordingStatus.idle,
            errorMessage: 'Đổi camera lỗi: $e',
          ),
        );
      }
    }
  }

  Future<void> _onZoomAdjusted(
    RecordingZoomAdjusted event,
    Emitter<RecordingSessionState> emit,
  ) async {
    if (!_camera.isInitialized) return;
    final next = (state.zoom + event.delta).clamp(state.minZoom, state.maxZoom);
    if (next == state.zoom) return;
    try {
      await _camera.setZoomLevel(next);
      if (!isClosed) emit(state.copyWith(zoom: next));
    } on Object catch (_) {
      // Zoom is best-effort; ignore unsupported levels.
    }
  }

  void _onTypeChanged(
    RecordingTypeChanged event,
    Emitter<RecordingSessionState> emit,
  ) {
    if (state.isRecording || event.type.isEmpty) return;
    emit(state.copyWith(typeLabel: event.type));
  }

  void _onCutoverExpired(
    RecordingCutoverExpired event,
    Emitter<RecordingSessionState> emit,
  ) {
    if (!isClosed) emit(state.copyWith(clearCutover: true));
  }

  void _onLowStorageDismissed(
    RecordingLowStorageDismissed event,
    Emitter<RecordingSessionState> emit,
  ) {
    if (!isClosed) emit(state.copyWith(lowStorageWarning: false));
  }

  /// Gọi đúng tại thời điểm bắt đầu mỗi clip, nên cũng là chỗ duy nhất cần
  /// reset đồng hồ và bộ mẫu của clip.
  void _startTimer() {
    _cancelTimer();
    _samples = [];
    _clipClock
      ..reset()
      ..start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isClosed) add(const RecordingTicked());
    });
  }

  /// Đọc pin + loại mạng một lần, gắn vào timeline của clip.
  ///
  /// Chạy ngoài luồng tick (không `await` trong handler) vì đọc pin là lời gọi
  /// qua platform channel — chặn tick là đồng hồ đếm ngược trên màn quay giật.
  /// Lỡ một mẫu không sao; bộ mẫu thưa vẫn thật, còn tick trễ thì người đang
  /// ôm thùng hàng nhìn thấy ngay.
  Future<void> _sampleDeviceCondition() async {
    final source = _deviceConditions;
    if (source == null || _samplingBusy) return;
    _samplingBusy = true;
    try {
      final tMs = _clipClock.elapsedMilliseconds;
      final reading = await source.read();
      // Máy chủ đòi t_ms tăng nghiêm ngặt — mẫu về trễ, chậm hơn mẫu đã ghi,
      // thì bỏ chứ không chèn vào giữa.
      if (_samples.isNotEmpty && tMs <= _samples.last.tMs) return;
      _samples.add(
        DeviceSample(
          tMs: tMs,
          battery: reading.battery,
          charging: reading.charging,
          net: reading.net,
        ),
      );
    } on Object {
      // Nền tảng không đọc được thì bỏ mẫu này. Thiếu một mẫu là dữ kiện thật;
      // bịa một con số thay vào mới là thứ phá giá trị của cả bộ.
    } finally {
      _samplingBusy = false;
    }
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> close() async {
    _cancelTimer();
    previewTransitioning.dispose();
    _cutoverTimer?.cancel();
    await _scanner.dispose();
    await _camera.dispose();
    if (_ownsTone) await _tone.dispose();
    return super.close();
  }
}

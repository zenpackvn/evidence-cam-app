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

import 'package:app_platform/app_platform.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'ec_bill_scanner.dart';

/// Content of the printed "kết thúc phiên" QR placed on the packing table.
///
/// ponytail: single fixed sentinel — promote to a per-shop setting if shops
/// ever need distinct end codes. Kept deliberately unlike any tracking number.
const kEndSessionQr = 'EVIDENCECAM:END';

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
  if (code != current) return RecordingFrameAction.cutover;
  return RecordingFrameAction.ignore;
}

/// Explicit recording-session status. Illegal flag combinations that the old
/// bools allowed (e.g. starting && recording) are now unrepresentable.
enum RecordingStatus { initializing, idle, recording, error }

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
      other.errorMessage == errorMessage;

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

/// App backgrounded: finalize any in-progress clip, then release the camera.
class RecordingBackgrounded extends RecordingSessionEvent {
  const RecordingBackgrounded();
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
    required void Function(String path, String tracking, String type)
    onClipSaved,
    String initialType = 'Đóng hàng',
    String initialResolution = '720p',
    String endQr = kEndSessionQr,
    Duration maxRecording = const Duration(minutes: 15),
  }) : _camera = camera,
       _scanner = scanner,
       _onClipSaved = onClipSaved,
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
    on<RecordingBackgrounded>(_onBackgrounded);
    on<RecordingResolutionCycled>(_onResolutionCycled);
    on<RecordingCameraFlipped>(_onCameraFlipped);
    on<RecordingZoomAdjusted>(_onZoomAdjusted);
    on<RecordingTypeChanged>(_onTypeChanged);
  }

  final CameraService _camera;
  final BillScanner _scanner;
  final void Function(String, String, String) _onClipSaved;
  final String _endQr;
  final Duration _maxRecording;

  List<CameraDescription> _cameras = const [];
  int _cameraIndex = 0;
  bool _liveScan = true;
  Timer? _timer;
  bool _idleScanBusy = false;
  bool _recScanBusy = false;

  // Async mutex chaining all camera-mutating ops. ponytail: a single global
  // lock — fine here because there's exactly one camera; nothing to parallelize.
  Future<void> _camLock = Future<void>.value();

  /// The live controller for the preview widget. The bloc can't hide it — a
  /// `CameraPreview` needs the actual controller — so the view reads it here and
  /// rebuilds when [RecordingSessionState.cameraGeneration] changes.
  CameraController? get previewController => _camera.controller;

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
    emit(state.copyWith(status: RecordingStatus.initializing, clearError: true));
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
        emit(
          state.copyWith(
            status: RecordingStatus.idle,
            cameraCount: cameras.length,
            cameraGeneration: state.cameraGeneration + 1,
            zoom: minZoom,
            minZoom: minZoom,
            maxZoom: maxZoom,
            clearError: true,
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
    );
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
    if (state.status != RecordingStatus.idle ||
        _idleScanBusy ||
        _cameras.isEmpty) {
      return;
    }
    _idleScanBusy = true;
    try {
      final code = await _scanner.scan(image, _cameras[_cameraIndex]);
      // An end-QR left on the table means nothing while idle — don't record it.
      if (code != null &&
          code.isNotEmpty &&
          code != _endQr &&
          state.status == RecordingStatus.idle &&
          !isClosed) {
        add(RecordingCodeScanned(code));
      }
    } finally {
      _idleScanBusy = false;
    }
  }

  Future<void> _onManualCodeSubmitted(
    RecordingManualCodeSubmitted event,
    Emitter<RecordingSessionState> emit,
  ) => _beginRecording(event.code, emit);

  Future<void> _onCodeScanned(
    RecordingCodeScanned event,
    Emitter<RecordingSessionState> emit,
  ) => _beginRecording(event.code, emit);

  Future<void> _beginRecording(
    String code,
    Emitter<RecordingSessionState> emit,
  ) async {
    if (state.isRecording) return;
    try {
      await _serialized(() async {
        if (!_camera.isInitialized || _camera.isRecordingVideo) return;
        if (_camera.isStreamingImages) await _camera.stopImageStream();
        await _startVideoWithScan();
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

  Future<void> _onRecordingFrame(CameraImage image) async {
    if (state.status != RecordingStatus.recording ||
        _recScanBusy ||
        _cameras.isEmpty) {
      return;
    }
    _recScanBusy = true;
    try {
      final code = await _scanner.scan(image, _cameras[_cameraIndex]);
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
    if (state.status != RecordingStatus.recording) return;
    switch (recordingFrameAction(event.code, state.code, endQr: _endQr)) {
      case RecordingFrameAction.endSession:
        await _finalize(emit, next: null);
      case RecordingFrameAction.cutover:
        await _finalize(emit, next: event.code);
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
    try {
      await _serialized(() async {
        _cancelTimer();
        if (_camera.isRecordingVideo) {
          final file = await _camera.stopVideoRecording();
          _onClipSaved(file.path, state.code, state.typeLabel);
        }
        if (next != null) {
          await _startVideoWithScan();
          if (isClosed) return;
          emit(
            state.copyWith(
              status: RecordingStatus.recording,
              code: next,
              elapsed: Duration.zero,
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

  void _onTicked(RecordingTicked event, Emitter<RecordingSessionState> emit) {
    if (state.status != RecordingStatus.recording) return;
    final elapsed = state.elapsed + const Duration(seconds: 1);
    emit(state.copyWith(elapsed: elapsed));
    // Hard cap: auto-close the clip at 15' so a forgotten session finalizes.
    if (elapsed >= _maxRecording) add(const RecordingStopRequested());
  }

  Future<void> _onBackgrounded(
    RecordingBackgrounded event,
    Emitter<RecordingSessionState> emit,
  ) async {
    // Finalize an in-progress clip BEFORE releasing the camera, so backgrounding
    // never loses the seller's evidence (FR-08/FR-09). Keyed off the camera's
    // own recording state so it fires even if the OS interrupts us mid-frame.
    await _serialized(() async {
      _cancelTimer();
      if (_camera.isRecordingVideo) {
        try {
          final file = await _camera.stopVideoRecording();
          _onClipSaved(file.path, state.code, state.typeLabel);
        } on Object {
          // OS already tore the camera down mid-record; nothing recoverable.
        }
      }
      await _camera.dispose();
      if (!isClosed) emit(state.copyWith(status: RecordingStatus.initializing));
    });
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
        // The new resolution must be in state before _initCamera reads it.
        if (!isClosed) emit(state.copyWith(resolutionLabel: resolutionLabel));
        final (minZoom, maxZoom) = await _initCamera();
        if (isClosed) return;
        emit(
          state.copyWith(
            cameraGeneration: state.cameraGeneration + 1,
            zoom: minZoom,
            minZoom: minZoom,
            maxZoom: maxZoom,
          ),
        );
      });
      await _startIdleScan();
    } on Object catch (e) {
      if (!isClosed) emit(state.copyWith(errorMessage: 'Đổi camera lỗi: $e'));
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
    if (event.type.isEmpty) return;
    emit(state.copyWith(typeLabel: event.type));
  }

  void _startTimer() {
    _cancelTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isClosed) add(const RecordingTicked());
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> close() async {
    _cancelTimer();
    await _scanner.dispose();
    await _camera.dispose();
    return super.close();
  }
}

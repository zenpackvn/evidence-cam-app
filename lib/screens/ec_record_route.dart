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

import 'package:app_platform/app_platform.dart';
import 'package:feature_capture/feature_capture.dart';
import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter_bloc/flutter_bloc.dart';

/// In the final minute, the cap-warning screen replaces the recording screen
/// (auto-close at 15').
const _warnAt = Duration(minutes: 14);

/// The recording route mounted at `/record`. Callbacks stay routing-agnostic so
/// the app shell owns navigation; [onRequestCode] returns the tracking code the
/// user entered (or `null` if they cancelled).
class EcRecordRoute extends StatefulWidget {
  const EcRecordRoute({
    this.onBack,
    this.onRequestCode,
    this.onConfirmManualCode,
    this.onRequestType,
    this.onNavOrders,
    this.onNavAccount,
    this.onSettings,
    this.onSaved,
    this.verifyReturnCode,
    this.voiceAnnouncer,
    this.initialType = 'Đóng hàng',
    this.queueCount = 0,
    this.shopName = 'Shop',
    this.initialResolution = '720p',
    this.camera,
    this.isActive,
    super.key,
  });

  /// Called when the header back chevron is tapped.
  final VoidCallback? onBack;

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
  final Future<String?> Function()? onRequestType;

  /// Called when the settings icon is tapped.
  final VoidCallback? onSettings;

  /// Called after a recording stops with the saved clip's path plus the order
  /// tracking code and video type it belongs to.
  final void Function(String path, String tracking, String type)? onSaved;

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

  /// Shop currently clocked into at the app layer.
  final String shopName;

  /// Recording resolution from the shop's setting (`240p` / `480p` / `720p`);
  /// the rail pill cycles it while idle.
  final String initialResolution;

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
  bool _leaving = false;

  late final RecordingSessionBloc _bloc = RecordingSessionBloc(
    camera: widget.camera ?? CameraService(),
    scanner: BillScanner(),
    onClipSaved: (path, tracking, type) =>
        widget.onSaved?.call(path, tracking, type),
    verifyReturnCode: widget.verifyReturnCode,
    voiceAnnouncer: widget.voiceAnnouncer,
    initialType: widget.initialType,
    initialResolution: widget.initialResolution,
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
      _bloc.add(const RecordingInitRequested());
    }
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
    if (widget.isActive!.value) {
      if (_bloc.state.status != RecordingStatus.idle &&
          _bloc.state.status != RecordingStatus.recording) {
        _bloc.add(const RecordingInitRequested());
      }
    } else {
      _bloc.add(const RecordingBackgrounded());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _bloc.add(const RecordingBackgrounded());
    } else if (state == AppLifecycleState.resumed &&
        _bloc.state.status != RecordingStatus.idle &&
        _bloc.state.status != RecordingStatus.recording) {
      _bloc.add(const RecordingInitRequested());
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

  Future<void> _pickType() async {
    final type = await widget.onRequestType?.call();
    if (type != null && type.isNotEmpty) _bloc.add(RecordingTypeChanged(type));
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
    return _CoverPreview(
      controller: controller,
      transitioning: _bloc.previewTransitioning,
    );
  }

  String _formatElapsed(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes)}:${two(d.inSeconds % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    // The system back gesture (left-edge swipe on Android) would otherwise
    // pop this route out from under an in-progress recording — the header's
    // back chevron is the only way out, since it finalizes the clip first
    // via _leaveAfterFinalizing.
    return PopScope(
      canPop: false,
      child: BlocBuilder<RecordingSessionBloc, RecordingSessionState>(
        bloc: _bloc,
        builder: (context, state) {
          final preview = _buildPreview(state);
          final zoomLabel = '${state.zoom.toStringAsFixed(1)}x';

          if (state.isRecording) {
            if (state.elapsed >= _warnAt) {
              return EcNearLimitScreen(
                shopName: widget.shopName,
                queueCount: widget.queueCount,
                code: state.code,
                duration: _formatElapsed(state.elapsed),
                typeLabel: state.typeLabel,
                zoomLabel: zoomLabel,
                resolutionLabel: state.resolutionLabel,
                preview: preview,
                onBack: () => unawaited(_leaveAfterFinalizing(widget.onBack)),
                onPickType: null,
                onSettings: null,
                onZoomIn: () => _bloc.add(const RecordingZoomAdjusted(0.5)),
                onZoomOut: () => _bloc.add(const RecordingZoomAdjusted(-0.5)),
                onNavOrders: () =>
                    unawaited(_leaveAfterFinalizing(widget.onNavOrders)),
                onNavAccount: () =>
                    unawaited(_leaveAfterFinalizing(widget.onNavAccount)),
                onStop: () => _bloc.add(const RecordingStopRequested()),
              );
            }
            return EcRecording2Screen(
              shopName: widget.shopName,
              queueCount: widget.queueCount,
              code: state.code,
              duration: _formatElapsed(state.elapsed),
              typeLabel: state.typeLabel,
              zoomLabel: zoomLabel,
              resolutionLabel: state.resolutionLabel,
              preview: preview,
              onBack: () => unawaited(_leaveAfterFinalizing(widget.onBack)),
              onPickType: null,
              onSettings: null,
              onZoomIn: () => _bloc.add(const RecordingZoomAdjusted(0.5)),
              onZoomOut: () => _bloc.add(const RecordingZoomAdjusted(-0.5)),
              onNavOrders: () =>
                  unawaited(_leaveAfterFinalizing(widget.onNavOrders)),
              onNavAccount: () =>
                  unawaited(_leaveAfterFinalizing(widget.onNavAccount)),
              onStop: () => _bloc.add(const RecordingStopRequested()),
            );
          }

          return EcWaitBill2Screen(
            shopName: widget.shopName,
            queueCount: widget.queueCount,
            typeLabel: state.typeLabel,
            zoomLabel: zoomLabel,
            resolutionLabel: state.resolutionLabel,
            preview: preview,
            onBack: widget.onBack,
            onPickType: _pickType,
            onSettings: _pickType,
            onZoomIn: () => _bloc.add(const RecordingZoomAdjusted(0.5)),
            onZoomOut: () => _bloc.add(const RecordingZoomAdjusted(-0.5)),
            onResolution: () => _bloc.add(const RecordingResolutionCycled()),
            onFlipCamera: state.hasMultipleCameras
                ? () => _bloc.add(const RecordingCameraFlipped())
                : null,
            onManualEntry: _manualEntry,
            onNavOrders: widget.onNavOrders,
            onNavAccount: widget.onNavAccount,
          );
        },
      ),
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
  // a comfortable margin rather than trimming it close.
  static const _settleBuffer = Duration(milliseconds: 1200);
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
    final frame = _lastGoodFrame;
    return ColoredBox(
      color: Colors.black,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // See didUpdateWidget: only the live preview's rotation is
          // affected by the recording-start rebind, not the recorded file,
          // so the correction is scoped to isRecordingVideo. The live layer
          // keeps rendering underneath even while masked, so the next
          // known-good frame is ready the moment masking lifts.
          final recordingTurns = controller.value.isRecordingVideo ? 3 : 0;
          final liveLayer = ClipRect(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxWidth * controller.value.aspectRatio,
                child: RepaintBoundary(
                  key: _boundaryKey,
                  child: RotatedBox(
                    quarterTurns: recordingTurns,
                    child: CameraPreview(controller),
                  ),
                ),
              ),
            ),
          );
          if (!_masking || frame == null) return liveLayer;
          return Stack(
            fit: StackFit.expand,
            children: [
              liveLayer,
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: frame.width.toDouble(),
                  height: frame.height.toDouble(),
                  child: RawImage(image: frame),
                ),
              ),
            ],
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
                  fontSize: 13,
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

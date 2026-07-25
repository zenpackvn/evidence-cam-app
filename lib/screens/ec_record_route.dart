/// Live camera recording route (FR-01, first slice).
///
/// Owns a [CameraService] and drives the presentational Flow 3 camera screens
/// with a real preview: enter a tracking code (manual entry) to start
/// recording, tap stop to save the clip. Hands-free bill auto-close and cloud
/// upload are deferred — this is the "camera actually works" slice.
library;

import 'dart:async';

import 'package:app_platform/app_platform.dart';
import 'package:flutter/material.dart';

import 'ec_bill_scanner.dart';
import 'ec_flow3.dart';

/// The recording route mounted at `/record`. Callbacks stay routing-agnostic so
/// the app shell owns navigation; [onRequestCode] returns the tracking code the
/// user entered (or `null` if they cancelled).
class EcRecordRoute extends StatefulWidget {
  const EcRecordRoute({
    this.onBack,
    this.onRequestCode,
    this.onRequestType,
    this.onNavOrders,
    this.onNavAccount,
    this.onSettings,
    this.onSaved,
    this.initialType = 'Đóng hàng',
    super.key,
  });

  /// Called when the header back chevron is tapped.
  final VoidCallback? onBack;

  /// Asks for a tracking code (opens the manual-entry sheet); starting a
  /// recording is gated on a non-empty result.
  final Future<String?> Function()? onRequestCode;

  /// Called when the "Đơn hàng" tab is tapped.
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

  /// Video type shown before the user picks one.
  final String initialType;

  @override
  State<EcRecordRoute> createState() => _EcRecordRouteState();
}

class _EcRecordRouteState extends State<EcRecordRoute>
    with WidgetsBindingObserver {
  final CameraService _camera = CameraService();
  final BillScanner _scanner = BillScanner();

  bool _initializing = true;
  String? _error;
  bool _recording = false;

  /// Guards the window between detecting a bill and `_recording` flipping true,
  /// so rapid frames don't start recording twice.
  bool _starting = false;
  String _code = '';
  late String _typeLabel = widget.initialType;
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  double _zoom = 1;
  double _minZoom = 1;
  double _maxZoom = 1;

  List<CameraDescription> _cameras = const [];
  int _cameraIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setup();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_scanner.dispose());
    unawaited(_camera.dispose());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ponytail: release the camera on background and re-open on resume. An
    // in-progress recording is dropped (not saved) — add pause/resume-recording
    // if losing the background clip ever matters.
    if (state == AppLifecycleState.inactive) {
      _timer?.cancel();
      unawaited(_camera.dispose());
      if (mounted) setState(() => _recording = false);
    } else if (state == AppLifecycleState.resumed && !_camera.isInitialized) {
      _setup();
    }
  }

  Future<void> _setup() async {
    if (mounted) setState(() => _initializing = true);
    try {
      final cameras = await _camera.getAvailableCameras();
      if (cameras.isEmpty) {
        _fail(
          'Thiết bị không có camera. iOS Simulator không hỗ trợ camera — '
          'hãy chạy trên máy thật.',
        );
        return;
      }
      var index = cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      if (index < 0) index = 0;
      await _initCamera(cameras[index]);
      if (!mounted) {
        unawaited(_camera.dispose());
        return;
      }
      setState(() {
        _cameras = cameras;
        _cameraIndex = index;
        _initializing = false;
        _error = null;
      });
      unawaited(_startScanning());
    } on Object catch (e) {
      _fail('Không mở được camera: $e');
    }
  }

  Future<void> _initCamera(CameraDescription description) async {
    await _camera.initialize(
      description: description,
      resolutionPreset: ResolutionPreset.high,
      imageFormatGroup: BillScanner.imageFormatGroup,
    );
    _minZoom = await _camera.getMinZoomLevel();
    _maxZoom = await _camera.getMaxZoomLevel();
    _zoom = _minZoom;
  }

  /// Streams frames to the bill scanner while idle. Detecting a tracking-code
  /// barcode auto-starts recording that order (hands-free scan-to-start).
  Future<void> _startScanning() async {
    final controller = _camera.controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        _recording ||
        _starting ||
        controller.value.isStreamingImages) {
      return;
    }
    try {
      await controller.startImageStream(_onFrame);
    } on Object {
      // Image streaming unsupported (e.g. web) — manual entry still works.
    }
  }

  Future<void> _onFrame(CameraImage image) async {
    if (_recording || _starting || _cameras.isEmpty) return;
    final code = await _scanner.scan(image, _cameras[_cameraIndex]);
    if (code == null || !mounted || _recording || _starting) return;
    await _beginRecording(code);
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _error = message;
      _initializing = false;
    });
  }

  Future<void> _flip() async {
    if (_recording || _cameras.length < 2) return;
    final next = (_cameraIndex + 1) % _cameras.length;
    try {
      await _initCamera(_cameras[next]);
      if (!mounted) return;
      setState(() => _cameraIndex = next);
      unawaited(_startScanning());
    } on Object catch (e) {
      _fail('Đổi camera lỗi: $e');
    }
  }

  Future<void> _zoomBy(double delta) async {
    if (!_camera.isInitialized) return;
    final next = (_zoom + delta).clamp(_minZoom, _maxZoom);
    if (next == _zoom) return;
    try {
      await _camera.setZoomLevel(next);
      if (!mounted) return;
      setState(() => _zoom = next);
    } on Object catch (_) {
      // Zoom is best-effort; ignore unsupported levels.
    }
  }

  /// Manual fallback: ask for a code (opens the sheet), then record it.
  Future<void> _startRecording() async {
    final code = (await widget.onRequestCode?.call())?.trim();
    if (code == null || code.isEmpty) return;
    await _beginRecording(code);
  }

  /// Starts recording [code], stopping the scan image stream first (the camera
  /// plugin forbids streaming and recording at the same time).
  Future<void> _beginRecording(String code) async {
    final controller = _camera.controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        _starting ||
        _camera.isRecordingVideo) {
      return;
    }
    _starting = true;
    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
      await _camera.startVideoRecording();
      if (!mounted) return;
      setState(() {
        _code = code;
        _recording = true;
        _elapsed = Duration.zero;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _elapsed += const Duration(seconds: 1));
      });
    } on Object catch (e) {
      _fail('Không bắt đầu quay được: $e');
    } finally {
      _starting = false;
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    _timer = null;
    if (!_camera.isRecordingVideo) {
      if (mounted) setState(() => _recording = false);
      await _startScanning();
      return;
    }
    try {
      final file = await _camera.stopVideoRecording();
      if (!mounted) return;
      setState(() => _recording = false);
      widget.onSaved?.call(file.path, _code, _typeLabel);
    } on Object catch (e) {
      if (mounted) setState(() => _recording = false);
      _fail('Lưu video lỗi: $e');
    }
    // Back to idle — resume hands-free scanning for the next bill.
    await _startScanning();
  }

  Future<void> _pickType() async {
    final type = await widget.onRequestType?.call();
    if (type == null || type.isEmpty || !mounted) return;
    setState(() => _typeLabel = type);
  }

  String _formatElapsed(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes)}:${two(d.inSeconds % 60)}';
  }

  Widget _buildPreview() {
    final error = _error;
    if (error != null) {
      return _PreviewMessage(icon: Icons.videocam_off_outlined, message: error);
    }
    final controller = _camera.controller;
    if (_initializing ||
        controller == null ||
        !controller.value.isInitialized) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(color: Colors.white70),
        ),
      );
    }
    return _CoverPreview(controller: controller);
  }

  @override
  Widget build(BuildContext context) {
    final preview = _buildPreview();
    final zoomLabel = '${_zoom.toStringAsFixed(1)}x';

    if (_recording) {
      return EcRecording2Screen(
        code: _code,
        duration: _formatElapsed(_elapsed),
        typeLabel: _typeLabel,
        zoomLabel: zoomLabel,
        preview: preview,
        onBack: widget.onBack,
        onPickType: _pickType,
        onSettings: widget.onSettings,
        onZoomIn: () => _zoomBy(0.5),
        onZoomOut: () => _zoomBy(-0.5),
        onNavOrders: widget.onNavOrders,
        onNavAccount: widget.onNavAccount,
        onStop: _stopRecording,
      );
    }

    return EcWaitBill2Screen(
      typeLabel: _typeLabel,
      zoomLabel: zoomLabel,
      preview: preview,
      onBack: widget.onBack,
      onPickType: _pickType,
      onSettings: widget.onSettings,
      onZoomIn: () => _zoomBy(0.5),
      onZoomOut: () => _zoomBy(-0.5),
      onFlipCamera: _flip,
      onManualEntry: _startRecording,
      onNavOrders: widget.onNavOrders,
      onNavAccount: widget.onNavAccount,
    );
  }
}

/// Fills the black camera area with [controller]'s preview, cover-cropped so it
/// bleeds edge-to-edge without distortion.
class _CoverPreview extends StatelessWidget {
  const _CoverPreview({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ClipRect(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxWidth * controller.value.aspectRatio,
                child: CameraPreview(controller),
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

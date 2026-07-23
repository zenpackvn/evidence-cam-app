import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:app_platform/app_platform.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show HapticFeedback, MethodChannel, SystemSound, SystemSoundType;

import '../widgets/stamp_frame_overlay.dart';

/// The tem viewfinder rect for a full-screen preview of [screen], at pinch
/// [scale]. Shared by the overlay and the capture crop so they line up.
Rect cameraTemWindow(Size screen, double scale) {
  final maxW = screen.width * 0.86;
  final maxH = screen.height * 0.62;
  var w = maxW;
  var h = w / kStampAspect;
  if (h > maxH) {
    h = maxH;
    w = h * kStampAspect;
  }
  w *= scale;
  h *= scale;
  return Rect.fromCenter(
    center: Offset(screen.width / 2, screen.height * 0.44),
    width: w,
    height: h,
  );
}

/// SM-005 — the in-app camera for "Chụp ảnh mới": a full-screen live preview
/// with a square stamp viewfinder in the middle (the stamp is 1:1), so the user
/// frames the shot inside the tem before capturing. The border style is
/// swipeable (or tap a chip) so different tastes get different tem edges. On
/// capture the photo path is handed back via [onCaptured] to continue the
/// wizard (→ "Xem trước ảnh").
class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({
    required this.camera,
    required this.onCaptured,
    this.onClose,
    super.key,
  });

  /// The app's camera wrapper (owns the [CameraController] lifecycle).
  final CameraService camera;

  /// Called with the captured photo's file path and the stamp frame style the
  /// user framed it with, so the preview shows the same tem.
  final void Function(String path, StampFrameStyle frame) onCaptured;

  /// Optional explicit close; defaults to popping the route.
  final VoidCallback? onClose;

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

/// Plays the native Android camera shutter ("tạch") — an OS-level sound that
/// isn't muted by the camera controller's audio-off setting. Other platforms
/// fall back to the system click.
const _shutterChannel = MethodChannel('stampmail/shutter');

enum _CamState { loading, ready, denied, error }

class _CameraCaptureScreenState extends State<CameraCaptureScreen>
    with WidgetsBindingObserver {
  _CamState _state = _CamState.loading;
  bool _capturing = false;
  CameraDescription? _description;
  List<CameraDescription> _cameras = const [];
  CameraLensDirection _lens = CameraLensDirection.back;
  StampFrameStyle _frame = StampFrameStyle.perforated;

  /// How big the stamp window is, as a fraction of its default size — the user
  /// pinches to zoom the tem frame in/out. Clamped so it stays usable.
  double _frameScale = 1;
  double _baseScale = 1;
  int _gesturePointers = 0;

  static const _minFrameScale = 0.55;
  static const _maxFrameScale = 1.25;

  void _cycleFrame(int delta) {
    const values = StampFrameStyle.values;
    final next = (_frame.index + delta + values.length) % values.length;
    setState(() => _frame = values[next]);
  }

  void _onScaleStart(ScaleStartDetails d) {
    _baseScale = _frameScale;
    _gesturePointers = d.pointerCount;
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    _gesturePointers = d.pointerCount;
    // Two fingers → pinch-zoom the tem frame. One finger is left for the swipe
    // (handled on end) so both gestures can share this recognizer.
    if (d.pointerCount >= 2) {
      setState(() {
        _frameScale = (_baseScale * d.scale).clamp(
          _minFrameScale,
          _maxFrameScale,
        );
      });
    }
  }

  // A one-finger swipe (horizontal or vertical) moves to the next/previous
  // frame; a pinch is a zoom, not a swipe.
  void _onScaleEnd(ScaleEndDetails d) {
    if (_gesturePointers >= 2) return;
    final v = d.velocity.pixelsPerSecond;
    if (v.distance < 120) return;
    final horizontal = v.dx.abs() >= v.dy.abs();
    final forward = horizontal ? v.dx < 0 : v.dy < 0;
    _cycleFrame(forward ? 1 : -1);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setup();
  }

  Future<void> _setup() async {
    // The stamp camera needs the CAMERA permission (declared in the manifest).
    final granted = await Permission.camera.request();
    if (!granted.isGranted) {
      if (mounted) setState(() => _state = _CamState.denied);
      return;
    }
    try {
      final cameras = await widget.camera.getAvailableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _state = _CamState.error);
        return;
      }
      _cameras = cameras;
      // Prefer the back camera for framing a subject; keep the last-chosen lens
      // across a background/resume.
      await _open(_lens);
    } on Object {
      if (mounted) setState(() => _state = _CamState.error);
    }
  }

  Future<void> _open(CameraLensDirection lens) async {
    final cam = _cameras.firstWhere(
      (c) => c.lensDirection == lens,
      orElse: () => _cameras.first,
    );
    _description = cam;
    _lens = cam.lensDirection;
    await widget.camera.initialize(
      description: cam,
      resolutionPreset: ResolutionPreset.high,
      enableAudio: false,
    );
    if (mounted) setState(() => _state = _CamState.ready);
  }

  /// Whether the device has both a front and a back camera to flip between.
  bool get _canFlip =>
      _cameras.any((c) => c.lensDirection == CameraLensDirection.back) &&
      _cameras.any((c) => c.lensDirection == CameraLensDirection.front);

  Future<void> _flip() async {
    if (_capturing || !_canFlip) return;
    final next = _lens == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    setState(() => _state = _CamState.loading);
    try {
      await widget.camera.dispose();
      await _open(next);
    } on Object {
      if (mounted) setState(() => _state = _CamState.error);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Release the camera when backgrounded, re-acquire on resume — the OS may
    // revoke the hardware to another app otherwise.
    if (_description == null) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      unawaited(widget.camera.dispose());
    } else if (state == AppLifecycleState.resumed &&
        !widget.camera.isInitialized) {
      unawaited(_setup());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(widget.camera.dispose());
    super.dispose();
  }

  void _close() {
    final onClose = widget.onClose;
    if (onClose != null) {
      onClose();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  /// The shutter "tạch": the native Android shutter sound, falling back to the
  /// system click where the channel isn't wired (iOS/tests). Always a light
  /// haptic too.
  Future<void> _playShutter() async {
    unawaited(HapticFeedback.mediumImpact());
    try {
      await _shutterChannel.invokeMethod<void>('play');
    } on Object {
      unawaited(SystemSound.play(SystemSoundType.click));
    }
  }

  Future<void> _capture() async {
    if (_capturing || !widget.camera.isInitialized) return;
    final screen = MediaQuery.of(context).size;
    final window = cameraTemWindow(screen, _frameScale);
    setState(() => _capturing = true);
    unawaited(_playShutter());
    try {
      final file = await widget.camera.takePicture();
      // Crop the shot to exactly the tem window (esp. when it was pinched
      // smaller), so we keep only what was inside the frame.
      final cropped = await _cropToWindow(file.path, screen, window);
      if (!mounted) return;
      widget.onCaptured(cropped, _frame);
    } on Object {
      if (mounted) {
        setState(() => _capturing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không chụp được ảnh. Thử lại nhé.')),
        );
      }
    }
  }

  /// Crops the captured photo to the tem [window] (screen coordinates), undoing
  /// the camera's sensor rotation / front-camera mirror and the preview's
  /// cover-fit. Returns the original path on any failure.
  Future<String> _cropToWindow(String path, Size screen, Rect window) async {
    final desc = _description;
    if (desc == null) return path;
    try {
      final bytes = await File(path).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frameInfo = await codec.getNextFrame();
      final src = frameInfo.image;

      // 1. Make sure the photo is upright. Many devices already return the
      // image in display orientation — only rotate when it disagrees with the
      // (portrait) screen, so we never turn an already-correct shot sideways.
      final portraitScreen = screen.height >= screen.width;
      final portraitImg = src.height >= src.width;
      final ui.Image upright;
      final bool rotatedNew;
      if (portraitScreen == portraitImg) {
        upright = src;
        rotatedNew = false;
      } else {
        final orientation = desc.sensorOrientation;
        final mirror = desc.lensDirection == CameraLensDirection.front;
        final uw = src.height;
        final uh = src.width;
        final rec = ui.PictureRecorder();
        final rc = Canvas(rec);
        rc.translate(uw / 2, uh / 2);
        if (mirror) rc.scale(-1, 1);
        rc.rotate(orientation * math.pi / 180);
        rc.translate(-src.width / 2, -src.height / 2);
        rc.drawImage(
          src,
          Offset.zero,
          Paint()..filterQuality = FilterQuality.high,
        );
        upright = await rec.endRecording().toImage(uw, uh);
        rotatedNew = true;
      }
      final uw = upright.width;
      final uh = upright.height;

      // Crop to the picture area *inside* the frame border (not the whole tem),
      // so we keep only what the user framed — no extra beyond the window.
      final crop = window.deflate(window.shortestSide * 0.11);

      // 2. Map the on-screen crop rect into the upright image via the cover-fit.
      final coverScale = math.max(screen.width / uw, screen.height / uh);
      final scaledW = uw * coverScale;
      final scaledH = uh * coverScale;
      final offX = (scaledW - screen.width) / 2;
      final offY = (scaledH - screen.height) / 2;
      double clampD(double v, double hi) => v < 0 ? 0 : (v > hi ? hi : v);
      final srcRect = Rect.fromLTRB(
        clampD((crop.left + offX) / coverScale, uw.toDouble()),
        clampD((crop.top + offY) / coverScale, uh.toDouble()),
        clampD((crop.right + offX) / coverScale, uw.toDouble()),
        clampD((crop.bottom + offY) / coverScale, uh.toDouble()),
      );
      if (srcRect.width < 1 || srcRect.height < 1) {
        src.dispose();
        if (rotatedNew) upright.dispose();
        return path;
      }

      // 3. Render the crop to a PNG matching the picture area's shape.
      const outH = 1024;
      final outW = (outH * (crop.width / crop.height)).round();
      final rec2 = ui.PictureRecorder();
      Canvas(rec2).drawImageRect(
        upright,
        srcRect,
        Rect.fromLTWH(0, 0, outW.toDouble(), outH.toDouble()),
        Paint()..filterQuality = FilterQuality.high,
      );
      final out = await rec2.endRecording().toImage(outW, outH);
      final data = await out.toByteData(format: ui.ImageByteFormat.png);
      src.dispose();
      if (rotatedNew) upright.dispose();
      out.dispose();
      if (data == null) return path;
      final outPath =
          '${File(path).parent.path}/sm_cam_'
          '${DateTime.now().microsecondsSinceEpoch}.png';
      await File(outPath).writeAsBytes(data.buffer.asUint8List());
      return outPath;
    } on Object {
      return path;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          switch (_state) {
            _CamState.ready => _CoverPreview(
              controller: widget.camera.controller!,
            ),
            _CamState.loading => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            _CamState.denied => const _Message(
              icon: Icons.no_photography_outlined,
              text: 'Cần quyền camera để chụp ảnh.\nMở cài đặt để cấp quyền.',
              actionLabel: 'Mở cài đặt',
              onAction: openAppSettings,
            ),
            _CamState.error => const _Message(
              icon: Icons.error_outline,
              text: 'Không mở được camera trên thiết bị này.',
            ),
          },
          // Pinch anywhere to zoom the tem frame; one-finger swipe changes its
          // edge style.
          if (_state == _CamState.ready)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onScaleStart: _onScaleStart,
                onScaleUpdate: _onScaleUpdate,
                onScaleEnd: _onScaleEnd,
              ),
            ),
          // The square stamp viewfinder — only over a live preview.
          if (_state == _CamState.ready)
            Positioned.fill(
              child: IgnorePointer(
                child: _StampViewfinder(style: _frame, scale: _frameScale),
              ),
            ),
          // Close (top-left).
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: _RoundIconButton(icon: Icons.close, onTap: _close),
              ),
            ),
          ),
          // Flip front/back camera (top-right) — only when both exist.
          if (_state == _CamState.ready && _canFlip)
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: _RoundIconButton(
                    icon: Icons.cameraswitch_outlined,
                    onTap: _flip,
                  ),
                ),
              ),
            ),
          // Shutter (bottom) — only when the camera is live. No text/chips:
          // swipe to change the tem edge, pinch to zoom.
          if (_state == _CamState.ready)
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: _ShutterButton(busy: _capturing, onTap: _capture),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The camera preview scaled to cover the whole screen (BoxFit.cover) so there
/// are no black bars behind the viewfinder.
class _CoverPreview extends StatelessWidget {
  const _CoverPreview({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final preview = controller.value.previewSize;
    if (preview == null) return CameraPreview(controller);
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          // previewSize is reported landscape; swap for the portrait screen.
          width: preview.height,
          height: preview.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}

/// Dims everything outside a centred square and draws a perforated stamp edge
/// around it, plus a hint line — the "ô vuông tem" the user frames inside.
class _StampViewfinder extends StatelessWidget {
  const _StampViewfinder({required this.style, this.scale = 1});

  final StampFrameStyle style;

  /// Fraction of the default window size — the pinch-to-zoom factor.
  final double scale;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final window = cameraTemWindow(
          Size(constraints.maxWidth, constraints.maxHeight),
          scale,
        );
        return CustomPaint(
          painter: StampFramePainter(window: window, style: style),
        );
      },
    );
  }
}

class _ShutterButton extends StatelessWidget {
  const _ShutterButton({required this.busy, required this.onTap});

  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white24,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: busy
                ? const Padding(
                    padding: EdgeInsets.all(18),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Color(0xFFF35B43),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black38,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 56),
            const SizedBox(height: AppSpacing.lg),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

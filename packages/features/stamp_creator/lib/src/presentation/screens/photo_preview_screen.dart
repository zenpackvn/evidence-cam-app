import 'dart:io';
import 'dart:ui' as ui;

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;

import '../widgets/creator_theme.dart';
import '../widgets/stamp_frame_overlay.dart';

/// SM-005 — "Xem trước ảnh" (F02-S03): after picking or shooting a photo the
/// user sees it inside the stamp tem and can **swipe to change the tem edge**
/// (same as the in-app camera). "Xác nhận" advances to the filter step with the
/// chosen frame; "Hủy" goes back to the source picker.
class PhotoPreviewScreen extends StatefulWidget {
  const PhotoPreviewScreen({
    required this.imagePath,
    required this.onConfirm,
    required this.onCancel,
    this.frameStyle,
    super.key,
  });

  final String imagePath;

  /// Called with the tem edge the user settled on and the image path to use —
  /// the framed/cropped photo when the user zoomed/positioned it, else the
  /// original.
  final void Function(StampFrameStyle frame, String imagePath) onConfirm;
  final VoidCallback onCancel;

  /// The tem edge chosen while shooting; null for a gallery photo (defaults to
  /// perforated, then swipeable here).
  final StampFrameStyle? frameStyle;

  @override
  State<PhotoPreviewScreen> createState() => _PhotoPreviewScreenState();
}

class _PhotoPreviewScreenState extends State<PhotoPreviewScreen> {
  // The tem edge is picked later in the wizard ("viền tem"), so here we keep a
  // plain crop frame and just pass a default style through.
  final StampFrameStyle _frame = StampFrameStyle.none;
  final _photoKey = GlobalKey<_FramedZoomablePhotoState>();
  bool _confirming = false;

  Future<void> _confirm() async {
    if (_confirming) return;
    setState(() => _confirming = true);
    // Crop the photo to exactly what's framed, so the wizard (bộ lọc màu…)
    // works on that view — not the whole original image.
    final cropped = await _photoKey.currentState?.cropToSquareFile();
    if (!mounted) return;
    widget.onConfirm(_frame, cropped ?? widget.imagePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CreatorColors.ground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xxl),
              Expanded(
                child: Center(
                  child: _FramedZoomablePhoto(
                    key: _photoKey,
                    imagePath: widget.imagePath,
                    background: CreatorColors.ground,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: _PillButton.secondary(
                      label: 'Hủy',
                      onTap: widget.onCancel,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xxl),
                  Expanded(
                    child: _PillButton.primary(
                      label: _confirming ? 'Đang xử lý…' : 'Xác nhận',
                      onTap: _confirm,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

/// The picked photo inside a plain crop frame: pinch to zoom, drag to move the
/// photo within it. The tem edge is chosen later in the wizard, so no edge
/// style is picked here.
class _FramedZoomablePhoto extends StatefulWidget {
  const _FramedZoomablePhoto({
    required this.imagePath,
    required this.background,
    super.key,
  });

  final String imagePath;
  final Color background;

  @override
  State<_FramedZoomablePhoto> createState() => _FramedZoomablePhotoState();
}

class _FramedZoomablePhotoState extends State<_FramedZoomablePhoto> {
  final _controller = TransformationController();
  ImageStream? _stream;
  ImageStreamListener? _listener;
  Size? _imgSize;
  bool _centered = false;
  final GlobalKey _captureKey = GlobalKey();

  /// Captures exactly what's shown in the picture area (WYSIWYG: the photo as
  /// contained / zoomed / positioned, with the paper behind any letterbox) to a
  /// PNG. Null on failure — the caller falls back to the original image.
  Future<String?> cropToSquareFile() async {
    try {
      final ro = _captureKey.currentContext?.findRenderObject();
      if (ro is! RenderRepaintBoundary) return null;
      final img = await ro.toImage(pixelRatio: 3);
      final data = await img.toByteData(format: ui.ImageByteFormat.png);
      img.dispose();
      if (data == null) return null;
      final file = File(widget.imagePath);
      final path =
          '${file.parent.path}/sm_crop_'
          '${DateTime.now().microsecondsSinceEpoch}.png';
      await File(path).writeAsBytes(data.buffer.asUint8List());
      return path;
    } on Object {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _resolveImage();
  }

  @override
  void didUpdateWidget(_FramedZoomablePhoto old) {
    super.didUpdateWidget(old);
    if (old.imagePath != widget.imagePath) {
      _imgSize = null;
      _centered = false;
      _resolveImage();
    }
  }

  // Measure the photo's pixel size so it can be laid out just big enough to
  // cover the tem window (then zoomed/panned inside it).
  void _resolveImage() {
    final file = File(widget.imagePath);
    if (!file.existsSync()) return;
    _removeListener();
    final stream = FileImage(file).resolve(ImageConfiguration.empty);
    final listener = ImageStreamListener((info, _) {
      if (!mounted) return;
      setState(
        () => _imgSize = Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ),
      );
    });
    _stream = stream..addListener(listener);
    _listener = listener;
  }

  void _removeListener() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
    _stream = null;
    _listener = null;
  }

  @override
  void dispose() {
    _removeListener();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: kStampAspect,
      child: LayoutBuilder(
        builder: (context, c) {
          final inset =
              (c.maxWidth < c.maxHeight ? c.maxWidth : c.maxHeight) * 0.06;
          final window = Rect.fromLTWH(
            inset,
            inset,
            c.maxWidth - inset * 2,
            c.maxHeight - inset * 2,
          );
          final radius = window.shortestSide * 0.05;
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fromRect(
                rect: window,
                // Capture exactly the framed picture, WYSIWYG.
                child: RepaintBoundary(
                  key: _captureKey,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius),
                    child: _viewer(window.width, window.height),
                  ),
                ),
              ),
              // A plain crop frame: dim outside the window + a soft white border.
              IgnorePointer(
                child: CustomPaint(
                  painter: _PlainFramePainter(
                    window: window,
                    radius: radius,
                    scrimColor: widget.background,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _viewer(double vw, double vh) {
    final file = File(widget.imagePath);
    if (!file.existsSync()) {
      return ColoredBox(
        color: context.colorScheme.secondaryContainer,
        child: const Center(child: Icon(Icons.image_outlined)),
      );
    }
    final size = _imgSize;
    if (size == null) {
      return Image.file(file, fit: BoxFit.cover, width: vw, height: vh);
    }
    // Cover: the photo fills the frame so its edges line up with the frame's —
    // never smaller (minScale 1), only zoomed in and panned; the pan is clamped
    // so an edge can't be pulled inside the frame (no blank border).
    final imgAspect = size.width / size.height;
    final vAspect = vw / vh;
    final double w;
    final double h;
    if (imgAspect >= vAspect) {
      h = vh;
      w = vh * imgAspect;
    } else {
      w = vw;
      h = vw / imgAspect;
    }
    if (!_centered) {
      _centered = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _controller.value = Matrix4.identity()
          ..translateByDouble(-(w - vw) / 2, -(h - vh) / 2, 0, 1);
      });
    }
    return InteractiveViewer(
      transformationController: _controller,
      constrained: false,
      minScale: 1,
      maxScale: 6,
      boundaryMargin: EdgeInsets.zero,
      child: SizedBox(
        width: w,
        height: h,
        child: Image.file(file, fit: BoxFit.fill),
      ),
    );
  }
}

/// A plain crop frame: dims everything outside [window] and draws a soft white
/// rounded border around it (no tem edge — that's chosen later in the wizard).
class _PlainFramePainter extends CustomPainter {
  _PlainFramePainter({
    required this.window,
    required this.radius,
    required this.scrimColor,
  });

  final Rect window;
  final double radius;
  final Color scrimColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(window, Radius.circular(radius));
    // Soft shadow so the frame reads on a light ground.
    canvas.drawShadow(
      Path()..addRRect(rrect),
      const Color(0xFF4A3A2E),
      6,
      false,
    );
    // Dim outside the window.
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(Offset.zero & size, Paint()..color = scrimColor);
    canvas.drawRRect(rrect, Paint()..blendMode = BlendMode.clear);
    canvas.restore();
    // White frame border.
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  @override
  bool shouldRepaint(_PlainFramePainter old) =>
      old.window != window ||
      old.radius != radius ||
      old.scrimColor != scrimColor;
}

class _PillButton extends StatelessWidget {
  const _PillButton.primary({required this.label, required this.onTap})
    : _primary = true;
  const _PillButton.secondary({required this.label, required this.onTap})
    : _primary = false;

  final String label;
  final VoidCallback onTap;
  final bool _primary;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final bg = _primary ? scheme.primary : scheme.surfaceContainerLowest;
    final fg = _primary ? scheme.onPrimary : scheme.onSurface;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1424211F),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            style: context.textTheme.titleMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

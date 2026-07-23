import 'dart:io';
import 'dart:ui' as ui;

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

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
  late StampFrameStyle _frame = widget.frameStyle ?? StampFrameStyle.perforated;
  final _photoKey = GlobalKey<_FramedZoomablePhotoState>();
  bool _confirming = false;

  void _cycleFrame(int delta) {
    const values = StampFrameStyle.values;
    final next = (_frame.index + delta + values.length) % values.length;
    setState(() => _frame = values[next]);
  }

  // A swipe anywhere on the screen (outside the tem window and its buttons)
  // changes the frame style — sideways or up/down.
  void _onScreenSwipe(DragEndDetails d) {
    final v = d.velocity.pixelsPerSecond;
    if (v.distance < 120) return;
    final horizontal = v.dx.abs() >= v.dy.abs();
    final forward = horizontal ? v.dx < 0 : v.dy < 0;
    _cycleFrame(forward ? 1 : -1);
  }

  Future<void> _confirm() async {
    if (_confirming) return;
    setState(() => _confirming = true);
    // Crop the photo to exactly what's framed in the tem window, so the wizard
    // (bộ lọc màu…) works on that view — not the whole original image.
    final cropped = await _photoKey.currentState?.cropToSquareFile();
    if (!mounted) return;
    widget.onConfirm(_frame, cropped ?? widget.imagePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CreatorColors.ground,
      body: Stack(
        children: [
          // Full-screen swipe catcher (behind the content); the tem window and
          // buttons on top handle their own gestures.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: _onScreenSwipe,
              onVerticalDragEnd: _onScreenSwipe,
            ),
          ),
          SafeArea(
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
                        style: _frame,
                        background: CreatorColors.ground,
                        // A quick sideways flick changes the tem edge; a slow drag
                        // just moves the photo.
                        onSwipe: _cycleFrame,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _FramePips(
                    count: StampFrameStyle.values.length,
                    active: _frame.index,
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
        ],
      ),
    );
  }
}

/// The picked photo inside the stamp tem: pinch to zoom, drag to move the photo
/// within the [style] frame. The frame paints on top (dimming outside the tem
/// window) so the user positions the picture inside it.
class _FramedZoomablePhoto extends StatefulWidget {
  const _FramedZoomablePhoto({
    required this.imagePath,
    required this.style,
    required this.background,
    required this.onSwipe,
    super.key,
  });

  final String imagePath;
  final StampFrameStyle style;
  final Color background;

  /// A quick sideways flick: +1 next edge, -1 previous.
  final ValueChanged<int> onSwipe;

  @override
  State<_FramedZoomablePhoto> createState() => _FramedZoomablePhotoState();
}

class _FramedZoomablePhotoState extends State<_FramedZoomablePhoto> {
  final _controller = TransformationController();
  ImageStream? _stream;
  ImageStreamListener? _listener;
  Size? _imgSize;
  int _maxPointers = 0;
  bool _centered = false;

  // Last laid-out geometry (viewport window size + the photo's layout size), so
  // the crop can map the visible window back to source pixels.
  double _winW = 0;
  double _winH = 0;
  double _w = 0;
  double _h = 0;

  /// Renders exactly what's inside the tem window to a rectangular PNG on disk
  /// and returns its path — the crop the wizard should work on. Null if the
  /// image isn't ready (the caller falls back to the original).
  Future<String?> cropToSquareFile() async {
    final size = _imgSize;
    final file = File(widget.imagePath);
    if (size == null ||
        _winW <= 0 ||
        _winH <= 0 ||
        _w <= 0 ||
        _h <= 0 ||
        !file.existsSync()) {
      return null;
    }
    try {
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frameInfo = await codec.getNextFrame();
      final src = frameInfo.image;

      // The visible window (0,0)-(winW,winH) in viewport space → child (layout)
      // space via the inverse transform → source-pixel space by the layout↔px
      // ratio.
      final inv = Matrix4.inverted(_controller.value);
      final tl = MatrixUtils.transformPoint(inv, Offset.zero);
      final br = MatrixUtils.transformPoint(inv, Offset(_winW, _winH));
      final sx = src.width / _w;
      final sy = src.height / _h;
      double clampD(double v, double hi) => v < 0 ? 0 : (v > hi ? hi : v);
      final srcRect = Rect.fromLTRB(
        clampD(tl.dx * sx, src.width.toDouble()),
        clampD(tl.dy * sy, src.height.toDouble()),
        clampD(br.dx * sx, src.width.toDouble()),
        clampD(br.dy * sy, src.height.toDouble()),
      );
      if (srcRect.width < 1 || srcRect.height < 1) return null;

      const outH = 1024;
      final outW = (outH * (_winW / _winH)).round();
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawImageRect(
        src,
        srcRect,
        Rect.fromLTWH(0, 0, outW.toDouble(), outH.toDouble()),
        Paint()..filterQuality = FilterQuality.high,
      );
      final picture = recorder.endRecording();
      final outImg = await picture.toImage(outW, outH);
      final data = await outImg.toByteData(format: ui.ImageByteFormat.png);
      src.dispose();
      picture.dispose();
      outImg.dispose();
      if (data == null) return null;
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

  void _onEnd(ScaleEndDetails d) {
    final v = d.velocity.pixelsPerSecond;
    // Inside the tem window a one-finger, clearly-horizontal flick changes the
    // frame; pinch or a vertical/slow drag zooms/moves the photo.
    if (_maxPointers <= 1 &&
        v.dx.abs() > 500 &&
        v.dx.abs() > v.dy.abs() * 1.5) {
      widget.onSwipe(v.dx < 0 ? 1 : -1);
    }
    _maxPointers = 0;
  }

  // Outside the tem window there's no photo to pan, so any swipe (sideways or
  // up/down) changes the frame style.
  void _onOutsideSwipe(DragEndDetails d) {
    final v = d.velocity.pixelsPerSecond;
    if (v.distance < 120) return;
    final horizontal = v.dx.abs() >= v.dy.abs();
    final forward = horizontal ? v.dx < 0 : v.dy < 0;
    widget.onSwipe(forward ? 1 : -1);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: kStampAspect,
      child: LayoutBuilder(
        builder: (context, c) {
          final inset =
              (c.maxWidth < c.maxHeight ? c.maxWidth : c.maxHeight) * 0.09;
          final winW = c.maxWidth - inset * 2;
          final winH = c.maxHeight - inset * 2;
          final window = Rect.fromLTWH(inset, inset, winW, winH);
          return Stack(
            fit: StackFit.expand,
            children: [
              // Bottom layer: catches swipes on the margin *outside* the tem
              // (the photo viewer on top handles gestures inside the window).
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragEnd: _onOutsideSwipe,
                onVerticalDragEnd: _onOutsideSwipe,
              ),
              Padding(
                padding: EdgeInsets.all(inset),
                child: ClipRect(child: _viewer(winW, winH)),
              ),
              IgnorePointer(
                child: CustomPaint(
                  painter: StampFramePainter(
                    window: window,
                    style: widget.style,
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

  Widget _viewer(double winW, double winH) {
    final file = File(widget.imagePath);
    if (!file.existsSync()) {
      return ColoredBox(
        color: context.colorScheme.secondaryContainer,
        child: const Center(child: Icon(Icons.image_outlined)),
      );
    }
    final size = _imgSize;
    if (size == null) {
      return Image.file(file, fit: BoxFit.cover, width: winW, height: winH);
    }
    // Lay the photo out just big enough to cover the window at 1× — so it can
    // never be shrunk below covering it (minScale 1), only zoomed in and panned.
    final imgAspect = size.width / size.height;
    final winAspect = winW / winH;
    final double w;
    final double h;
    if (imgAspect >= winAspect) {
      h = winH;
      w = winH * imgAspect;
    } else {
      w = winW;
      h = winW / imgAspect;
    }
    _winW = winW;
    _winH = winH;
    _w = w;
    _h = h;
    if (!_centered) {
      _centered = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _controller.value = Matrix4.identity()
          ..translateByDouble(-(w - winW) / 2, -(h - winH) / 2, 0, 1);
      });
    }
    return InteractiveViewer(
      transformationController: _controller,
      constrained: false,
      minScale: 1,
      maxScale: 5,
      // Zero margin clamps the pan so an edge of the photo can't be dragged
      // inside the window — it always stays covered (no blank border).
      boundaryMargin: EdgeInsets.zero,
      onInteractionStart: (d) => _maxPointers = d.pointerCount,
      onInteractionUpdate: (d) {
        if (d.pointerCount > _maxPointers) _maxPointers = d.pointerCount;
      },
      onInteractionEnd: _onEnd,
      child: SizedBox(
        width: w,
        height: h,
        child: Image.file(file, fit: BoxFit.fill),
      ),
    );
  }
}

/// Little dots under the preview showing which tem edge (of N) is selected.
class _FramePips extends StatelessWidget {
  const _FramePips({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == active ? 18 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: i == active
                  ? scheme.primary
                  : scheme.onSurfaceVariant.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
      ],
    );
  }
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

import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../widgets/creator_theme.dart';

/// SM-005 — "Xem trước ảnh" (F02-S03): after picking a photo the user can
/// pinch/double-tap to zoom and pan it before continuing. "Xác nhận" advances to
/// the filter step; "Hủy" goes back to the source picker.
class PhotoPreviewScreen extends StatefulWidget {
  const PhotoPreviewScreen({
    required this.imagePath,
    required this.onConfirm,
    required this.onCancel,
    super.key,
  });

  final String imagePath;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  State<PhotoPreviewScreen> createState() => _PhotoPreviewScreenState();
}

class _PhotoPreviewScreenState extends State<PhotoPreviewScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TransformationController();
  late final AnimationController _anim;
  Animation<Matrix4>? _zoomAnim;
  TapDownDetails? _doubleTapDetails;
  double _scale = 1;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTransform);
    _anim =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 220),
        )..addListener(() {
          if (_zoomAnim != null) _controller.value = _zoomAnim!.value;
        });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTransform);
    _controller.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _onTransform() {
    final s = _controller.value.getMaxScaleOnAxis();
    if ((s - _scale).abs() > 0.01) setState(() => _scale = s);
  }

  void _animateTo(Matrix4 target) {
    _zoomAnim = Matrix4Tween(begin: _controller.value, end: target).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeOut),
    );
    _anim.forward(from: 0);
  }

  // Double-tap zooms toward the tapped point, or resets if already zoomed in.
  void _handleDoubleTap() {
    if (_scale > 1.05) {
      _animateTo(Matrix4.identity());
      return;
    }
    final position = _doubleTapDetails?.localPosition;
    if (position == null) return;
    const zoom = 2.5;
    final target = Matrix4.identity()
      ..translateByDouble(
        -position.dx * (zoom - 1),
        -position.dy * (zoom - 1),
        0,
        1,
      )
      ..scaleByDouble(zoom, zoom, 1, 1);
    _animateTo(target);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Scaffold(
      backgroundColor: CreatorColors.ground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'Xem trước ảnh',
                textAlign: TextAlign.center,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Phóng to, thu nhỏ để xem ảnh rõ hơn\ntrước khi tiếp tục.',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.47,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 258 / 402,
                    child: _PhotoCard(
                      imagePath: widget.imagePath,
                      controller: _controller,
                      scale: _scale,
                      onDoubleTapDown: (d) => _doubleTapDetails = d,
                      onDoubleTap: _handleDoubleTap,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Icon(
                Icons.touch_app_outlined,
                size: 26,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Chạm hai lần để phóng to vùng đó\n'
                'Chụm hoặc mở hai ngón tay để zoom',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.47,
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
                      label: 'Xác nhận',
                      onTap: widget.onConfirm,
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

/// The zoomable photo card (F02-S03 `photoCard`): the picked photo in a rounded,
/// shadowed card with a live zoom badge; pinch/pan via [InteractiveViewer].
class _PhotoCard extends StatelessWidget {
  const _PhotoCard({
    required this.imagePath,
    required this.controller,
    required this.scale,
    required this.onDoubleTapDown,
    required this.onDoubleTap,
  });

  final String imagePath;
  final TransformationController controller;
  final double scale;
  final ValueChanged<TapDownDetails> onDoubleTapDown;
  final VoidCallback onDoubleTap;

  @override
  Widget build(BuildContext context) {
    final file = File(imagePath);
    final photo = file.existsSync()
        ? Image.file(file, fit: BoxFit.cover) as Widget
        : ColoredBox(
            color: context.colorScheme.secondaryContainer,
            child: const Center(child: Icon(Icons.image_outlined, size: 40)),
          );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onDoubleTapDown: onDoubleTapDown,
              onDoubleTap: onDoubleTap,
              child: InteractiveViewer(
                transformationController: controller,
                minScale: 1,
                maxScale: 4,
                child: photo,
              ),
            ),
            Positioned(
              top: AppSpacing.md,
              left: AppSpacing.md,
              child: Container(
                height: 30,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0x66000000),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${scale.toStringAsFixed(1)}x',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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

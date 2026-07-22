import 'package:app_ui/app_ui.dart';
import 'package:feature_album/feature_album.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/letter_content.dart';
import '../bloc/composer_state.dart';
import 'letter_paper.dart';

/// The composed letter rendered read-only with the attached stamps laid on top
/// at their [placements] (SM-014/SM-015). One widget shared by "Đính tem"
/// (interactive — [onMove]/[onRotate] wired) and "Xem trước thư" (static), so
/// the stamps sit in exactly the same spot on both screens.
class StampedLetterPreview extends StatelessWidget {
  const StampedLetterPreview({
    required this.content,
    required this.stamps,
    required this.stampIds,
    required this.placements,
    this.onMove,
    this.onRotate,
    super.key,
  });

  final LetterContent content;
  final List<Stamp> stamps;
  final List<String> stampIds;
  final Map<String, StampPlacement> placements;

  /// When both are null the stamps are static (preview); otherwise they can be
  /// dragged / double-tapped to rotate (the attach screen).
  final void Function(String id, double dx, double dy)? onMove;
  final ValueChanged<String>? onRotate;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = c.maxHeight.isFinite ? c.maxHeight : w;
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Stack(
            children: [
              // The top of the actual letter, clipped to the box. Always inert:
              // only the stamps on top respond to gestures (drag / rotate).
              Positioned.fill(
                child: OverflowBox(
                  alignment: Alignment.topCenter,
                  minHeight: 0,
                  maxHeight: double.infinity,
                  child: AbsorbPointer(
                    child: ReadOnlyLetterPaper(content: content),
                  ),
                ),
              ),
              for (final id in stampIds)
                if (_stampById(id) case final stamp?)
                  _PlacedStamp(
                    stamp: stamp,
                    placement: placements[id] ?? (dx: 0.5, dy: 0.6, rot: 0),
                    width: w,
                    height: h,
                    onMove: onMove == null
                        ? null
                        : (dx, dy) => onMove!(id, dx, dy),
                    onRotate: onRotate == null ? null : () => onRotate!(id),
                  ),
            ],
          ),
        );
      },
    );
  }

  Stamp? _stampById(String id) {
    for (final s in stamps) {
      if (s.id == id) return s;
    }
    return null;
  }
}

/// A stamp on the letter at [placement]. Draggable / rotatable when [onMove] /
/// [onRotate] are provided, otherwise a static postage stamp.
class _PlacedStamp extends StatelessWidget {
  const _PlacedStamp({
    required this.stamp,
    required this.placement,
    required this.width,
    required this.height,
    this.onMove,
    this.onRotate,
  });

  static const _size = 52.0;

  final Stamp stamp;
  final StampPlacement placement;
  final double width;
  final double height;
  final void Function(double dx, double dy)? onMove;
  final VoidCallback? onRotate;

  @override
  Widget build(BuildContext context) {
    final stampBox = Transform.rotate(
      angle: placement.rot,
      child: Container(
        width: _size,
        height: _size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: AppNetworkImage(
          imageUrl: stamp.thumbUrl ?? stamp.imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );

    return Positioned(
      left: placement.dx * width - _size / 2,
      top: placement.dy * height - _size / 2,
      child: (onMove == null && onRotate == null)
          ? stampBox
          : GestureDetector(
              onDoubleTap: onRotate,
              onPanUpdate: onMove == null
                  ? null
                  : (d) {
                      final nx = ((placement.dx * width + d.delta.dx) / width)
                          .clamp(0.0, 1.0);
                      final ny = ((placement.dy * height + d.delta.dy) / height)
                          .clamp(0.0, 1.0);
                      onMove!(nx, ny);
                    },
              child: stampBox,
            ),
    );
  }
}

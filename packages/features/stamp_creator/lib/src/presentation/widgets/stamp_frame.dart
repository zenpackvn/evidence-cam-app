import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/filters.dart';
import '../../domain/stamp_draft.dart';

/// Renders the composed stamp: the source photo with its color filter applied,
/// inside a classic perforated stamp frame, with placed stickers on top. This is
/// the shared canvas used by the decorate (SM-008/009) and preview (SM-010)
/// steps, and it is what gets captured to PNG on save (SM-011).
class StampFrame extends StatelessWidget {
  const StampFrame({
    required this.draft,
    this.interactive = false,
    this.onStickerMoved,
    super.key,
  });

  final StampDraft draft;

  /// When true, stickers can be dragged (decorate step). When false the stamp is
  /// a static composite (preview / capture).
  final bool interactive;

  /// Called while a sticker is dragged, with its index and new normalized
  /// center. Only wired on the decorate step (interactive).
  final void Function(int index, double dx, double dy)? onStickerMoved;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: CustomPaint(
        // SM-009 "Nền" paper colour + "Viền tem" edge style.
        painter: _PerforationPainter(
          color: Color(draft.paperColor ?? 0xFFFFFFFF),
          borderId: draft.borderId,
        ),
        child: Padding(
          // The perforated white margin around the photo.
          padding: const EdgeInsets.all(14),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: _FilteredPhoto(draft: draft),
                  ),
                  // SM-009: the premium borders add a coloured inner frame.
                  if (_borderAccent(draft.borderId) case final accent?)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: accent, width: 2),
                        ),
                      ),
                    ),
                  for (final (i, sticker) in draft.stickers.indexed)
                    Positioned(
                      left: sticker.dx * constraints.maxWidth - 18,
                      top: sticker.dy * constraints.maxHeight - 18,
                      child: GestureDetector(
                        onPanUpdate: interactive && onStickerMoved != null
                            ? (details) {
                                final nx =
                                    (sticker.dx * constraints.maxWidth +
                                        details.delta.dx) /
                                    constraints.maxWidth;
                                final ny =
                                    (sticker.dy * constraints.maxHeight +
                                        details.delta.dy) /
                                    constraints.maxHeight;
                                onStickerMoved!(i, nx, ny);
                              }
                            : null,
                        child: Transform.rotate(
                          angle: sticker.rotation,
                          child: Transform.scale(
                            scale: sticker.scale,
                            child: Text(
                              sticker.glyph,
                              style: const TextStyle(fontSize: 36),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FilteredPhoto extends StatelessWidget {
  const _FilteredPhoto({required this.draft});

  final StampDraft draft;

  @override
  Widget build(BuildContext context) {
    final file = File(draft.imagePath);
    final image = file.existsSync()
        ? Image.file(file, fit: BoxFit.cover)
        : ColoredBox(
            color: context.colorScheme.secondaryContainer,
            child: const Center(child: Icon(Icons.image_outlined, size: 40)),
          );
    final filter = effectiveColorFilter(draft);
    if (filter == null) return image;
    return ColorFiltered(colorFilter: filter, child: image);
  }
}

/// The coloured inner frame the premium borders add over the photo (SM-009 D6);
/// null for the plain free borders (classic / rounded / scalloped).
Color? _borderAccent(String borderId) => switch (borderId) {
  'gold' => const Color(0xFFD4A537),
  'ornate' => const Color(0xFF8B5E3C),
  'floral' => const Color(0xFFE8618C),
  'deco' => const Color(0xFF3A322C),
  _ => null,
};

/// Paints the stamp paper base and its edge (SM-009 "Viền tem"): perforated for
/// most styles, larger scallops for 'scalloped', and a smooth rounded edge for
/// 'rounded'.
class _PerforationPainter extends CustomPainter {
  _PerforationPainter({required this.color, required this.borderId});

  final Color color;
  final String borderId;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final radius = borderId == 'rounded' ? 44.0 : 8.0;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    // 'rounded' has a clean, strongly-rounded edge — no perforations.
    if (borderId == 'rounded') {
      canvas.drawRRect(rrect, paint);
      return;
    }

    // Much larger teeth read as bold scallops; the rest keep the classic
    // fine perforation.
    final teeth = borderId == 'scalloped' ? 34.0 : 12.0;
    final stepX = size.width / (size.width / teeth).round();
    final stepY = size.height / (size.height / teeth).round();
    final punch = Paint()
      ..color = color
      ..blendMode = BlendMode.clear;
    // Scallops punch nearly the full step so the arcs touch into a wave; the
    // classic perforation leaves paper between each tooth.
    final r = borderId == 'scalloped' ? teeth / 2 : teeth / 2.4;

    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRRect(rrect, paint);
    for (var x = stepX / 2; x < size.width; x += stepX) {
      canvas.drawCircle(Offset(x, 0), r, punch);
      canvas.drawCircle(Offset(x, size.height), r, punch);
    }
    for (var y = stepY / 2; y < size.height; y += stepY) {
      canvas.drawCircle(Offset(0, y), r, punch);
      canvas.drawCircle(Offset(size.width, y), r, punch);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PerforationPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.borderId != borderId;
}

extension on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}

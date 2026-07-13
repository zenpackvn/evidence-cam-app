import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/filters.dart';
import '../../domain/stamp_draft.dart';

/// Renders the composed stamp: the source photo with its color filter applied,
/// inside a classic perforated stamp frame, with placed stickers on top. This is
/// the shared canvas used by the decorate (SM-008/009) and preview (SM-010)
/// steps, and it is what gets captured to PNG on save (SM-011).
class StampFrame extends StatelessWidget {
  const StampFrame({required this.draft, this.interactive = false, super.key});

  final StampDraft draft;

  /// When true, stickers can be dragged (decorate step). When false the stamp is
  /// a static composite (preview / capture).
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: CustomPaint(
        painter: _PerforationPainter(color: Colors.white),
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
                  for (final sticker in draft.stickers)
                    Positioned(
                      left: sticker.dx * constraints.maxWidth - 18,
                      top: sticker.dy * constraints.maxHeight - 18,
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

/// Paints the white stamp base plus the semicircular perforations along all four
/// edges — the iconic "stamp" silhouette, drawn rather than shipped as an asset.
class _PerforationPainter extends CustomPainter {
  _PerforationPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(8),
    );
    canvas.drawRRect(rrect, paint);

    // Punch semicircles out along each edge for the perforation effect.
    const teeth = 12.0;
    final stepX = size.width / (size.width / teeth).round();
    final stepY = size.height / (size.height / teeth).round();
    final punch = Paint()
      ..color = color
      ..blendMode = BlendMode.clear;
    const r = teeth / 2.4;

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
      oldDelegate.color != color;
}

extension on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}

import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/filters.dart';
import '../../domain/stamp_draft.dart';
import 'stamp_frame_overlay.dart';

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
    // A landscape rectangle — the same tem the camera framed, so every wizard
    // step matches "Xem trước ảnh" (SM-005/SM-009).
    return AspectRatio(
      aspectRatio: kStampAspect,
      child: LayoutBuilder(
        builder: (context, cons) {
          final inset = cons.maxHeight * 0.09;
          final window = Rect.fromLTWH(
            inset,
            inset,
            cons.maxWidth - inset * 2,
            cons.maxHeight - inset * 2,
          );
          // The picture sits inside the black key-line (the paper margin is 16).
          final photo = window.deflate(16);
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fromRect(
                rect: photo,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: _FilteredPhoto(draft: draft),
                ),
              ),
              // SM-009: the premium borders add a coloured inner frame.
              if (_borderAccent(draft.borderId) case final accent?)
                Positioned.fromRect(
                  rect: photo,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: accent, width: 2),
                    ),
                  ),
                ),
              for (final (i, sticker) in draft.stickers.indexed)
                Positioned(
                  left: photo.left + sticker.dx * photo.width - 18,
                  top: photo.top + sticker.dy * photo.height - 18,
                  child: GestureDetector(
                    onPanUpdate: interactive && onStickerMoved != null
                        ? (details) {
                            final nx =
                                (sticker.dx * photo.width + details.delta.dx) /
                                photo.width;
                            final ny =
                                (sticker.dy * photo.height + details.delta.dy) /
                                photo.height;
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
              // The tem frame (paper + perforation + key-line) — transparent
              // outside the paper; IgnorePointer keeps stickers draggable.
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: StampFramePainter(
                      window: window,
                      style: draft.frameStyle,
                      scrimColor: Colors.transparent,
                      paperColor: Color(draft.paperColor ?? 0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A warm rounded backdrop behind a stamp so the white tem stands out from the
/// cream wizard ground (the stamp paper is white too). Display-only — not part
/// of the captured stamp.
class StampBackdrop extends StatelessWidget {
  const StampBackdrop({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEADFCB),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(12), child: child),
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

extension on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}

import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/stamp_draft.dart';

// The frame style lives in the domain (on StampDraft); re-export it so callers
// of this overlay (camera, photo preview) get the enum from one place.
export '../../domain/stamp_draft.dart'
    show StampFrameStyle, StampFrameStyleLabel;

/// The stamp's shape: a portrait rectangle (width : height), like a classic
/// upright postage stamp. Used everywhere the tem is framed/cropped so it stays
/// consistent across the camera, preview, wizard and the saved image.
const kStampAspect = 0.72;

/// Draws the vintage stamp frame around [window]: a white perforated/toothed
/// paper edge, a white margin, and the black key-line around the picture.
/// Everything outside the paper is filled with [scrimColor] — a translucent
/// dim over the live camera, or the screen's ground colour on the preview.
class StampFramePainter extends CustomPainter {
  StampFramePainter({
    required this.window,
    required this.style,
    this.scrimColor = const Color(0x99000000),
    this.paperColor = Colors.white,
  });

  final Rect window;
  final StampFrameStyle style;
  final Color scrimColor;

  /// The stamp paper colour (SM-009 "Nền"); the white margin between the
  /// perforation and the picture.
  final Color paperColor;

  // Classic vintage-stamp palette (matches the reference): a near-black navy
  // border the perforations reveal, and warm cream paper.
  static const _navy = Color(0xFF142743);
  static const _cream = Color(0xFFF2E7D0);

  /// A rounded/pointed toothed outline around [w] — the cream paper's edge, its
  /// teeth poking [depth] out into the dark border so the perforations read.
  Path _edge(
    Rect w, {
    required bool rounded,
    required double len,
    required double depth,
  }) {
    final path = Path()..moveTo(w.left, w.top);
    void edge(Offset a, Offset b, Offset normal) {
      final length = (b - a).distance;
      final dir = (b - a) / length;
      final teeth = (length / len).round().clamp(1, 999);
      final step = length / teeth;
      for (var i = 0; i < teeth; i++) {
        final apex = a + dir * (step * i + step / 2) + normal * depth;
        final baseEnd = a + dir * (step * (i + 1));
        if (rounded) {
          path.quadraticBezierTo(apex.dx, apex.dy, baseEnd.dx, baseEnd.dy);
        } else {
          path
            ..lineTo(apex.dx, apex.dy)
            ..lineTo(baseEnd.dx, baseEnd.dy);
        }
      }
    }

    edge(w.topLeft, w.topRight, const Offset(0, -1));
    edge(w.topRight, w.bottomRight, const Offset(1, 0));
    edge(w.bottomRight, w.bottomLeft, const Offset(0, 1));
    edge(w.bottomLeft, w.topLeft, const Offset(-1, 0));
    return path..close();
  }

  Path _paperPath(Rect r, double d) => switch (style) {
    StampFrameStyle.perforated => _edge(r, rounded: true, len: d * 2, depth: d),
    StampFrameStyle.sawtooth => _edge(
      r,
      rounded: false,
      len: d * 2.2,
      depth: d * 1.1,
    ),
    StampFrameStyle.scalloped => _edge(
      r,
      rounded: true,
      len: d * 3.4,
      depth: d * 1.3,
    ),
    // classic / dashed: a plain cream rounded rectangle (a thin flat border).
    _ =>
      Path()..addRRect(
        RRect.fromRectAndRadius(r.inflate(d * 0.5), Radius.circular(d)),
      ),
  };

  @override
  void paint(Canvas canvas, Size size) {
    final short = window.shortestSide;

    // "Không viền": show the photo plainly with just a thin border — no tem edge
    // until the user picks one on the decorate step.
    if (style == StampFrameStyle.none) {
      final photoRRect = RRect.fromRectAndRadius(
        window.deflate(16),
        const Radius.circular(4),
      );
      if (scrimColor.a < 0.25) {
        canvas.drawShadow(
          Path()..addRRect(photoRRect),
          const Color(0xFF4A3A2E),
          4,
          false,
        );
      }
      canvas.drawRRect(
        photoRRect,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
      return;
    }

    final perfDepth = short * 0.04;
    final creamMargin = short * 0.07;
    final outerR = short * 0.06;

    final cream = paperColor == const Color(0xFFFFFFFF) ? _cream : paperColor;

    final creamRect = window.deflate(perfDepth);
    final hole = creamRect.deflate(creamMargin);
    final holeRRect = RRect.fromRectAndRadius(
      hole,
      Radius.circular(short * 0.03),
    );
    final outerRRect = RRect.fromRectAndRadius(
      window,
      Radius.circular(outerR),
    );

    // Soft shadow so the stamp reads on a light ground; the camera dims instead.
    if (scrimColor.a < 0.25) {
      canvas.drawShadow(
        Path()..addRRect(outerRRect),
        const Color(0xFF4A3A2E),
        6,
        false,
      );
    }

    canvas.saveLayer(Offset.zero & size, Paint());
    // Dim outside the tem.
    canvas.drawRect(Offset.zero & size, Paint()..color = scrimColor);
    // The dark border the perforations reveal between the cream teeth.
    canvas.drawRRect(outerRRect, Paint()..color = _navy);
    // Cream paper with the perforated / scalloped edge.
    canvas.drawPath(_paperPath(creamRect, perfDepth), Paint()..color = cream);
    // Cut the picture hole so the photo shows through.
    canvas.drawRRect(holeRRect, Paint()..blendMode = BlendMode.clear);
    canvas.restore();

    // The inner navy frame around the picture (the reference's banded border),
    // with a thin cream key-line just inside it.
    final borderRect = hole.inflate(creamMargin * 0.45);
    final borderRRect = RRect.fromRectAndRadius(
      borderRect,
      Radius.circular(short * 0.04),
    );
    final navyStroke = Paint()
      ..color = _navy
      ..style = PaintingStyle.stroke
      ..strokeWidth = short * 0.02;
    if (style == StampFrameStyle.dashed) {
      _drawDashed(canvas, Path()..addRRect(borderRRect), navyStroke);
    } else {
      canvas.drawRRect(borderRRect, navyStroke);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          borderRect.deflate(short * 0.02),
          Radius.circular(short * 0.03),
        ),
        Paint()
          ..color = cream
          ..style = PaintingStyle.stroke
          ..strokeWidth = short * 0.006,
      );
    }
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    const dash = 9.0;
    const gap = 6.0;
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        final next = (dist + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(StampFramePainter old) =>
      old.window != window ||
      old.style != style ||
      old.scrimColor != scrimColor ||
      old.paperColor != paperColor;
}

/// A photo shown inside the stamp frame [style] — the picture cropped to the
/// square tem window, with the frame around it. Used on "Xem trước ảnh" so the
/// preview shows exactly what was framed while shooting.
class StampFramedPhoto extends StatelessWidget {
  const StampFramedPhoto({
    required this.imagePath,
    required this.style,
    this.background = const Color(0xFFFBF5EC),
    super.key,
  });

  final String imagePath;
  final StampFrameStyle style;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final file = File(imagePath);
    return AspectRatio(
      aspectRatio: kStampAspect,
      child: LayoutBuilder(
        builder: (context, c) {
          final inset =
              (c.maxWidth < c.maxHeight ? c.maxWidth : c.maxHeight) * 0.09;
          final window = Rect.fromLTWH(
            inset,
            inset,
            c.maxWidth - inset * 2,
            c.maxHeight - inset * 2,
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              if (file.existsSync())
                Image.file(file, fit: BoxFit.cover)
              else
                ColoredBox(
                  color: context.colorScheme.secondaryContainer,
                  child: const Center(child: Icon(Icons.image_outlined)),
                ),
              CustomPaint(
                painter: StampFramePainter(
                  window: window,
                  style: style,
                  scrimColor: background,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

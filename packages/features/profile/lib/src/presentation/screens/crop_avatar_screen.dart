import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../widgets/profile_sub_scaffold.dart';

/// F07-S04 — crop avatar: a 1:1 crop canvas over the picked photo with a
/// "Chọn ảnh khác | Xoay" action bar and a "Lưu" header action.
///
/// The user pans/zooms/rotates the photo inside a fixed 1:1 frame; "Lưu"
/// captures exactly that frame to a PNG via a [RepaintBoundary] — the same
/// capture the stamp wizard uses — so [onSave] hands back the cropped bytes,
/// ready for the avatar uploader.
class CropAvatarScreen extends StatefulWidget {
  const CropAvatarScreen({
    required this.imagePath,
    required this.onSave,
    this.onPickAnother,
    super.key,
  });

  final String imagePath;

  /// Receives the cropped 1:1 PNG bytes when the user taps "Lưu".
  final ValueChanged<Uint8List> onSave;
  final VoidCallback? onPickAnother;

  @override
  State<CropAvatarScreen> createState() => _CropAvatarScreenState();
}

class _CropAvatarScreenState extends State<CropAvatarScreen> {
  int _quarterTurns = 0;

  /// The image card. The visible crop square is inset [_cropInset] inside it, so
  /// only that inner square is saved.
  final GlobalKey _cropKey = GlobalKey();

  /// How far the crop square sits inside the image card, matching the demo's
  /// framed-in-the-photo look (F07-S04).
  static const _cropInset = 24.0;

  /// Guards against a double-tap firing two captures.
  bool _saving = false;

  /// Captures the card at 3×, then crops to the inset guide square so the saved
  /// avatar is exactly what the crop frame shows.
  Future<void> _save() async {
    if (_saving) return;
    _saving = true;
    try {
      final boundary =
          _cropKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final full = await boundary.toImage(pixelRatio: 3);
      final scale = full.width / boundary.size.width;
      final inset = (_cropInset * scale).round();
      final side = full.width - inset * 2;

      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder).drawImageRect(
        full,
        ui.Rect.fromLTWH(
          inset.toDouble(),
          inset.toDouble(),
          side.toDouble(),
          side.toDouble(),
        ),
        ui.Rect.fromLTWH(0, 0, side.toDouble(), side.toDouble()),
        ui.Paint(),
      );
      final cropped = await recorder.endRecording().toImage(side, side);
      final data = await cropped.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) return;
      widget.onSave(data.buffer.asUint8List());
    } on Object {
      // Never crash on a capture hiccup — tell the user and let them retry.
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Không cắt được ảnh. Vui lòng thử lại.'),
            ),
          );
      }
    } finally {
      _saving = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return ProfileSubScaffold(
      title: 'Cắt ảnh đại diện',
      trailing: TextButton(
        onPressed: _save,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: scheme.primary,
          textStyle: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        child: const Text('Lưu'),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xxxxl),
            // The captured region: a 1:1 frame. Only what sits inside the
            // RepaintBoundary ends up in the avatar — the crop grid overlay
            // sits on top of it (IgnorePointer) so it guides the eye without
            // being baked into the saved PNG.
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  RepaintBoundary(
                    key: _cropKey,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: InteractiveViewer(
                        child: RotatedBox(
                          quarterTurns: _quarterTurns,
                          child: Image.file(
                            File(widget.imagePath),
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => ColoredBox(
                              color: scheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.image_outlined,
                                size: 64,
                                color: scheme.outline,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _CropOverlayPainter(
                          inset: _cropInset,
                          handleColor: scheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, size: 15, color: scheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Cắt ảnh theo tỉ lệ 1:1',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: context.brand.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _BarAction(
                      icon: Icons.photo_library_outlined,
                      label: 'Chọn ảnh khác',
                      onTap: widget.onPickAnother,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: scheme.outlineVariant,
                  ),
                  Expanded(
                    child: _BarAction(
                      icon: Icons.rotate_right,
                      label: 'Xoay',
                      onTap: () => setState(
                        () => _quarterTurns = (_quarterTurns + 1) % 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Draws the 1:1 crop guide over the photo (F07-S04): the area outside the
/// (inset) crop square is dimmed, the square gets a white border, a
/// rule-of-thirds grid, and coral corner handles. Purely visual — painted on
/// top so it never lands in the saved avatar.
class _CropOverlayPainter extends CustomPainter {
  const _CropOverlayPainter({required this.inset, required this.handleColor});

  final double inset;
  final Color handleColor;

  @override
  void paint(Canvas canvas, Size size) {
    final card = Offset.zero & size;
    final square = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );

    // Dim everything outside the crop square.
    final scrim = Paint()..color = Colors.black.withValues(alpha: 0.35);
    final outside = Path.combine(
      PathOperation.difference,
      Path()..addRRect(RRect.fromRectAndRadius(card, const Radius.circular(6))),
      Path()..addRect(square),
    );
    canvas.drawPath(outside, scrim);

    // The white crop border.
    final border = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(square, border);

    // Rule-of-thirds grid inside the square.
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    for (var i = 1; i < 3; i++) {
      final dx = square.left + square.width * i / 3;
      final dy = square.top + square.height * i / 3;
      canvas.drawLine(Offset(dx, square.top), Offset(dx, square.bottom), grid);
      canvas.drawLine(Offset(square.left, dy), Offset(square.right, dy), grid);
    }

    // Coral corner handles on the square.
    final handle = Paint()..color = handleColor;
    final ring = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    const r = 7.0;
    for (final corner in [
      square.topLeft,
      square.topRight,
      square.bottomLeft,
      square.bottomRight,
    ]) {
      canvas
        ..drawCircle(corner, r, handle)
        ..drawCircle(corner, r, ring);
    }
  }

  @override
  bool shouldRepaint(_CropOverlayPainter old) =>
      old.inset != inset || old.handleColor != handleColor;
}

class _BarAction extends StatelessWidget {
  const _BarAction({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: context.colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

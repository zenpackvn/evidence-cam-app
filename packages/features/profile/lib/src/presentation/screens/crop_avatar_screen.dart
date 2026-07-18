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

  /// The 1:1 crop frame. What is captured is exactly what sits inside it.
  final GlobalKey _cropKey = GlobalKey();

  /// Guards against a double-tap firing two captures.
  bool _saving = false;

  /// Captures the crop frame to PNG at 3× for a crisp avatar (matches the stamp
  /// wizard's capture ratio), then hands the bytes to the widget's onSave.
  Future<void> _save() async {
    if (_saving) return;
    _saving = true;
    try {
      final boundary =
          _cropKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) return;
      widget.onSave(data.buffer.asUint8List());
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
            // The captured region: a 1:1 frame. Only what sits inside it ends
            // up in the avatar, so the boundary is the frame itself.
            RepaintBoundary(
              key: _cropKey,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: InteractiveViewer(
                    child: RotatedBox(
                      quarterTurns: _quarterTurns,
                      child: Image.file(
                        File(widget.imagePath),
                        fit: BoxFit.cover,
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
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.crop_square, size: 15, color: scheme.primary),
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

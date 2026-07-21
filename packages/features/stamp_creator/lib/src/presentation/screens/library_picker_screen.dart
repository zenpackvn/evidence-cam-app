import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// F02-S11 — "Nguồn ảnh · No-camera": the in-app library picker shown when the
/// device has no camera. A disabled camera segment, a 3-column photo grid with
/// a coral selection ring, and a pill "Chọn ảnh" CTA.
///
/// UI-only: [photos] is supplied by the host (device photos later via a
/// gallery permission flow; the preview feeds sample images).
// ponytail: copy is inline Vietnamese for now, same as the other wizard
// screens; swapped to l10n keys when the wizard's strings settle.
class LibraryPickerScreen extends StatefulWidget {
  const LibraryPickerScreen({
    required this.photos,
    required this.onPick,
    this.title = 'Không có camera',
    this.subtitle = 'Chọn một ảnh từ thư viện để bắt đầu tạo tem.',
    this.onCamera,
    super.key,
  });

  /// Candidate photos, newest first.
  final List<ImageProvider> photos;

  /// Called with the selected index when the CTA is pressed.
  final ValueChanged<int> onPick;

  /// Screen title / subtitle — defaults to the no-camera copy; the library-pick
  /// flow overrides them ("Chọn từ thư viện").
  final String title;
  final String subtitle;

  /// When set, the "Máy ảnh" segment is tappable (switch to camera); when null
  /// it renders disabled, which is the no-camera state.
  final VoidCallback? onCamera;

  @override
  State<LibraryPickerScreen> createState() => _LibraryPickerScreenState();
}

class _LibraryPickerScreenState extends State<LibraryPickerScreen> {
  static const _ground = Color(0xFFFBF5EC);
  static const _segmentGround = Color(0xFFF1E8DC);

  int? _selected;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Scaffold(
      backgroundColor: _ground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xxl),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: context.textTheme.displayMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            _Segmented(onCamera: widget.onCamera),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(26, 0, 26, 76),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  mainAxisExtent: 162,
                ),
                itemCount: widget.photos.length,
                itemBuilder: (context, index) => _LibraryCell(
                  image: widget.photos[index],
                  selected: _selected == index,
                  onTap: () => setState(() => _selected = index),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        color: _ground,
        padding: const EdgeInsets.fromLTRB(42, 0, 42, AppSpacing.xxl),
        width: double.infinity,
        child: SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: _selected == null
                ? null
                : () => widget.onPick(_selected!),
            style: FilledButton.styleFrom(
              backgroundColor: scheme.primary,
              shape: const StadiumBorder(),
              textStyle: context.textTheme.titleMedium,
            ),
            child: const Text('Chọn ảnh'),
          ),
        ),
      ),
    );
  }
}

/// The camera/library segmented pill; the camera side is permanently disabled
/// on this screen (that's the point of the no-camera state).
class _Segmented extends StatelessWidget {
  const _Segmented({this.onCamera});

  /// When set the camera segment is tappable; null renders it disabled.
  final VoidCallback? onCamera;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final camColor = onCamera == null ? scheme.outline : scheme.onSurface;
    return Container(
      width: 299,
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: _LibraryPickerScreenState._segmentGround,
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onCamera,
              borderRadius: const BorderRadius.all(Radius.circular(999)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_camera_outlined,
                    size: 20,
                    color: camColor,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Máy ảnh',
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: camColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.brand.surfaceElevated,
                borderRadius: const BorderRadius.all(Radius.circular(999)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 20,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Thư viện',
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryCell extends StatelessWidget {
  const _LibraryCell({
    required this.image,
    required this.selected,
    required this.onTap,
  });

  final ImageProvider image;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: selected
              ? Border.all(color: scheme.primary, width: 2.5)
              : null,
          image: DecorationImage(image: image, fit: BoxFit.cover),
        ),
        child: selected
            ? Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Center(
                      child: Icon(Icons.check, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

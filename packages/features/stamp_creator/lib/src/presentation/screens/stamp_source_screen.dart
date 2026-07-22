import 'package:app_platform/app_platform.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../widgets/creator_theme.dart';
import '../widgets/source_card.dart';

/// SM-005 — "Chọn cách lấy ảnh": the entry step of the create-a-stamp wizard.
/// The user picks a photo source (camera or gallery); the chosen photo is
/// handed to [onPicked] to advance to the filter step.
///
/// Pixel-matched to the F02-S02 frame in `pencil-new.pen` (cream ground, coral
/// display title, two hero cards, a soft-peach tip panel).
///
// ponytail: copy is inline Vietnamese for now. Add l10n keys (smCreateSource*)
// and swap to context.l10n once the wizard's screens settle.
class StampSourceScreen extends StatelessWidget {
  const StampSourceScreen({
    required this.onPicked,
    this.onBrowseLibrary,
    this.onCapture,
    this.picker,
    super.key,
  });

  /// Called with the picked photo file path when the user chooses a source and
  /// the OS picker returns an image.
  final ValueChanged<String> onPicked;

  /// Called when the user taps "Chọn từ thư viện" — opens the in-app library
  /// grid (SM-005 F02-S11). When null the card falls back to the OS picker.
  final VoidCallback? onBrowseLibrary;

  /// Called when the user taps "Chụp ảnh mới" — opens the in-app full-screen
  /// camera with the square stamp viewfinder. When null the card falls back to
  /// the OS camera picker.
  final VoidCallback? onCapture;

  /// Injected in the app; tests pass a fake. When null the screen resolves it
  /// from the widget tree's DI at tap time (kept out of the const constructor).
  final ImagePickerService? picker;

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final service = picker;
    if (service == null) return;
    final file = await service.pickImage(source: source);
    if (file != null) onPicked(file.path);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Scaffold(
      backgroundColor: CreatorColors.ground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxxl,
            AppSpacing.xxxl,
            AppSpacing.xxxl,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: _BackButton(
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _Title(),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Bắt đầu bằng một bức ảnh thật đẹp\nđể tạo nên con tem của bạn.',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.47,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SourceCard(
                icon: Icons.photo_camera_outlined,
                label: 'Chụp ảnh mới',
                heroHeight: 183,
                hero: const _HeroImage('source-camera.png'),
                onTap: onCapture ?? () => _pick(context, ImageSource.camera),
              ),
              const SizedBox(height: AppSpacing.md + AppSpacing.xxs),
              SourceCard(
                icon: Icons.image_outlined,
                label: 'Chọn từ thư viện',
                heroHeight: 130,
                hero: const _HeroImage('source-gallery.png'),
                onTap:
                    onBrowseLibrary ??
                    () => _pick(context, ImageSource.gallery),
              ),
              const SizedBox(height: AppSpacing.lg),
              const _TipPanel(),
            ],
          ),
        ),
      ),
    );
  }
}

/// A circular "back" affordance (top-left), so the screen can be left by tap as
/// well as the system back gesture / edge swipe. Matches the create/compose
/// flow's circular buttons.
class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.surfaceContainerLowest,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.arrow_back,
            size: 22,
            color: context.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final base = context.textTheme.displaySmall?.copyWith(
      fontWeight: FontWeight.w700,
      height: 1.21,
    );
    return RichText(
      text: TextSpan(
        style: base,
        children: [
          TextSpan(
            text: 'Chọn ',
            style: TextStyle(color: context.colorScheme.onSurface),
          ),
          TextSpan(
            text: 'cách lấy ảnh',
            style: TextStyle(color: context.colorScheme.primary),
          ),
        ],
      ),
    );
  }
}

/// The hero illustration filling the top of a source card (F02-S02 `photo`
/// frames). The design uses image fill mode "fill", so the photo covers the box
/// and crops overflow — [BoxFit.cover].
class _HeroImage extends StatelessWidget {
  const _HeroImage(this.asset);

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/illustrations/$asset',
      package: 'feature_stamp_creator',
      fit: BoxFit.cover,
    );
  }
}

class _TipPanel extends StatelessWidget {
  const _TipPanel();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: CreatorColors.tip,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 22)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: context.textTheme.bodySmall?.copyWith(height: 1.38),
                children: [
                  TextSpan(
                    text: 'Mẹo: ',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: 'Ảnh rõ nét sẽ cho ra con tem đẹp hơn nhé!',
                    style: TextStyle(color: colorScheme.onSurface),
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

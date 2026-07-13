import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../widgets/creator_theme.dart';

/// SM-011 success — "Đã lưu vào Album!" (F02-S09): a celebratory confirmation
/// with the saved stamp and two actions (view album / create another).
class SaveSuccessScreen extends StatelessWidget {
  const SaveSuccessScreen({
    required this.onViewAlbum,
    required this.onCreateAnother,
    this.stampName = 'Con tem mới',
    super.key,
  });

  final VoidCallback onViewAlbum;
  final VoidCallback onCreateAnother;
  final String stampName;

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
              const Spacer(flex: 2),
              Icon(Icons.celebration_outlined, size: 64, color: scheme.primary),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'Đã lưu vào Album!',
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Con tem của bạn đã được lưu thành công\nvào bộ sưu tập.',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.47,
                ),
              ),
              const Spacer(flex: 3),
              _PrimaryButton(label: 'Xem Album', onTap: onViewAlbum),
              const SizedBox(height: AppSpacing.md),
              _SecondaryButton(label: 'Tạo tem mới', onTap: onCreateAnother),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 52,
            alignment: Alignment.center,
            child: Text(
              label,
              style: context.textTheme.titleMedium?.copyWith(
                color: scheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 52,
            alignment: Alignment.center,
            child: Text(
              label,
              style: context.textTheme.titleMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

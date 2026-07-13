import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import 'auth_social_buttons.dart';

/// The social sign-up chooser per the .pen `Pattern/BottomSheet/SocialChoice`
/// (F01-S07): warm sheet (radius 28 top), 44×5 drag handle, Baloo title,
/// the three provider buttons, and a coral "Huỷ" dismiss.
///
/// Returns the picked [AuthProvider], or `null` when dismissed.
Future<AuthProvider?> showSocialChoiceSheet(
  BuildContext context, {
  required String title,
  required String subtitle,
  required String cancelLabel,
  required String Function(AuthProvider provider) labelFor,
}) {
  // .pen `surface-dim` scrim.
  const barrier = Color(0xB34A342C);
  return showModalBottomSheet<AuthProvider>(
    context: context,
    barrierColor: barrier,
    backgroundColor: context.colorScheme.surfaceContainerLow,
    showDragHandle: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => _SocialChoiceSheet(
      title: title,
      subtitle: subtitle,
      cancelLabel: cancelLabel,
      labelFor: labelFor,
    ),
  );
}

class _SocialChoiceSheet extends StatelessWidget {
  const _SocialChoiceSheet({
    required this.title,
    required this.subtitle,
    required this.cancelLabel,
    required this.labelFor,
  });

  final String title;
  final String subtitle;
  final String cancelLabel;
  final String Function(AuthProvider provider) labelFor;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxxxl,
          10,
          AppSpacing.xxxxl,
          AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: scheme.outlineVariant,
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: context.textTheme.displayMedium?.copyWith(fontSize: 26),
            ),
            const SizedBox(height: 14),
            Text(
              subtitle,
              style: context.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final (index, provider) in AuthProvider.values.indexed) ...[
              if (index > 0) const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: AuthSocialButton(
                  label: labelFor(provider),
                  provider: provider,
                  onPressed: () => Navigator.of(context).pop(provider),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: scheme.primary,
                textStyle: context.textTheme.titleMedium,
              ),
              child: Text(cancelLabel),
            ),
          ],
        ),
      ),
    );
  }
}

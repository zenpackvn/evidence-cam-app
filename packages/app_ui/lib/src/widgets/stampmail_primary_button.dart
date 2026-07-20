import 'package:flutter/material.dart';

import '../../app_ui.dart';

/// The canonical StampMail primary CTA — the `.pen` `Button/Primary` component,
/// shared by every flow (auth, onboarding, …) so the coral pill is defined once.
///
/// Layout matches the design: a centered label with a small decorative sparkle
/// tucked against the right edge. [isLoading] swaps in a centered spinner;
/// [locked] renders `Button/Primary/Disabled` (the `state-disabled` fill with a
/// lock glyph before the label, F01-S05).
class StampMailPrimaryButton extends StatelessWidget {
  const StampMailPrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.locked = false,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool locked;

  /// `.pen` `state-disabled` (light); the branded flows are pinned to light.
  static const _disabledFill = Color(0xFFD8D2CC);

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    // .pen Button/Primary: h52, radius-16, label 17/22 w600, lucide `sparkles`
    // 20px in warm gold (#FFE1A8) inset 20px from the right edge.
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: isLoading || locked ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: locked ? _disabledFill : colorScheme.primary,
          disabledForegroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: context.textTheme.titleMedium,
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: colorScheme.onPrimary,
                ),
              )
            : locked
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Text(label),
                ],
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  Text(label),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: AppSpacing.xl),
                      // .pen: lucide `sparkles` 20px, warm gold. Material
                      // auto_awesome is the faithful double-sparkle.
                      child: Icon(
                        Icons.auto_awesome,
                        size: 20,
                        color: Color(0xFFFFE1A8),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

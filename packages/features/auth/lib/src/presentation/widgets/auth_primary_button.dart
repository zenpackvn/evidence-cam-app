import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// The full-width coral CTA used across the auth screens.
///
/// Matches the design: the label is centered, with a small decorative sparkle
/// tucked against the right edge (unlike [AppButton], which leads with its
/// icon). Shows a centered spinner while [isLoading]. With [locked] the
/// button renders the design's disabled state (`Button/Primary/Disabled`):
/// `state-disabled` fill with a lock glyph before the label (F01-S05).
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
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

  /// .pen `state-disabled` (light); auth is pinned to the light theme.
  static const _disabledFill = Color(0xFFD8D2CC);

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    // .pen Button/Primary: h52, radius-16, label 17/22 w600, sparkle 20px in
    // warm gold (#FFE1A8) inset 20px from the right edge.
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
                  const FaIcon(FontAwesomeIcons.lock, size: 18),
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
                      child: FaIcon(
                        FontAwesomeIcons.wandMagicSparkles,
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

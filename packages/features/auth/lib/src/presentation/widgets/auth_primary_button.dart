import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// The full-width coral CTA used across the auth screens.
///
/// Matches the design: the label is centered, with a small decorative sparkle
/// tucked against the right edge (unlike [AppButton], which leads with its
/// icon). Shows a centered spinner while [isLoading].
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return SizedBox(
      height: 56,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
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
            : Stack(
                alignment: Alignment.center,
                children: [
                  Text(label),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.lg),
                      child: FaIcon(
                        FontAwesomeIcons.wandMagicSparkles,
                        size: 18,
                        color: colorScheme.onPrimary.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

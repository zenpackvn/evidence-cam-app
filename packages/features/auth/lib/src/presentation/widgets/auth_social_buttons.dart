import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// The three third-party sign-in providers StampMail supports.
enum AuthProvider { apple, google, facebook }

/// The "or continue with" divider plus the Apple / Google / Facebook buttons.
///
/// Each button reports taps through [onPressed] and shows an independent
/// spinner via [loading] (BR-24 / AC-32): pressing Google spins only Google,
/// leaving the others tappable. Passing a non-null [loading] provider disables
/// every button while that one resolves.
class AuthSocialButtons extends StatelessWidget {
  const AuthSocialButtons({
    required this.dividerLabel,
    required this.labelFor,
    required this.onPressed,
    this.loading,
    this.topGap = 14,
    this.itemGap = AppSpacing.md,
    super.key,
  });

  final String dividerLabel;
  final String Function(AuthProvider provider) labelFor;
  final void Function(AuthProvider provider) onPressed;

  /// The provider currently authenticating, or `null` if idle.
  final AuthProvider? loading;

  /// Divider→first-button and button→button gaps (.pen: login 14/12,
  /// register 12/10).
  final double topGap;
  final double itemGap;

  @override
  Widget build(BuildContext context) {
    final busy = loading != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Divider(label: dividerLabel),
        SizedBox(height: topGap),
        for (final (index, provider) in AuthProvider.values.indexed) ...[
          if (index > 0) SizedBox(height: itemGap),
          AuthSocialButton(
            label: labelFor(provider),
            provider: provider,
            isLoading: loading == provider,
            onPressed: busy ? null : () => onPressed(provider),
          ).animateSlideUp(delay: (400 + index * 50).ms),
        ],
      ],
    );
  }
}

/// One provider row per the .pen `Auth/SocialButton/*` components. Public so
/// the social-choice bottom sheet (F01-S07) reuses the exact same look.
class AuthSocialButton extends StatelessWidget {
  const AuthSocialButton({
    required this.label,
    required this.provider,
    this.isLoading = false,
    required this.onPressed,
    super.key,
  });

  final String label;
  final AuthProvider provider;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    // .pen Auth/SocialButton: h48, radius-16, surface-elevated fill with the
    // hairline border-subtle stroke, label 17 w600.
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: context.brand.surfaceElevated,
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: context.brand.borderSubtle),
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
                  strokeWidth: 2.4,
                  color: colorScheme.primary,
                ),
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.lg),
                      child: _ProviderIcon(provider),
                    ),
                  ),
                  Text(label),
                ],
              ),
      ),
    );
  }
}

class _ProviderIcon extends StatelessWidget {
  const _ProviderIcon(this.provider);

  final AuthProvider provider;

  @override
  Widget build(BuildContext context) {
    return switch (provider) {
      AuthProvider.apple => FaIcon(
        FontAwesomeIcons.apple,
        size: 20,
        color: context.isDark ? Colors.white : const Color(0xFF111111),
      ),
      // Google's multicolor 'G'. FontAwesome renders it monochrome, so tint it
      // the brand blue for a recognizable, tasteful mark.
      AuthProvider.google => const FaIcon(
        FontAwesomeIcons.google,
        size: 20,
        color: Color(0xFF4285F4),
      ),
      AuthProvider.facebook => const FaIcon(
        FontAwesomeIcons.facebook,
        size: 22,
        color: Color(0xFF1877F2),
      ),
    };
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    // .pen Divider/Label: 1.5px border-default lines at 90% opacity with a
    // body-md (15px) label, 12px gaps.
    final line = Expanded(
      child: Divider(
        color: colorScheme.outlineVariant.withValues(alpha: 0.9),
        thickness: 1.5,
      ),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        line,
      ],
    );
  }
}

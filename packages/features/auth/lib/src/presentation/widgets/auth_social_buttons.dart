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
    super.key,
  });

  final String dividerLabel;
  final String Function(AuthProvider provider) labelFor;
  final void Function(AuthProvider provider) onPressed;

  /// The provider currently authenticating, or `null` if idle.
  final AuthProvider? loading;

  @override
  Widget build(BuildContext context) {
    final busy = loading != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Divider(label: dividerLabel),
        const SizedBox(height: AppSpacing.xl),
        for (final (index, provider) in AuthProvider.values.indexed) ...[
          if (index > 0) const SizedBox(height: AppSpacing.md),
          _SocialButton(
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

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.provider,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final AuthProvider provider;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: colorScheme.surfaceContainerLowest,
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outlineVariant),
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
        size: 22,
        color: context.isDark ? Colors.white : Colors.black,
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
    return Row(
      children: [
        Expanded(child: Divider(color: colorScheme.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Divider(color: colorScheme.outlineVariant)),
      ],
    );
  }
}

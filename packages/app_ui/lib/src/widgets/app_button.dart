import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../app_ui.dart';

enum AppButtonVariant { primary, tonal, outlined, text }

enum AppButtonSize { small, medium, large }

/// A single themed button that supports four visual variants, three sizes,
/// optional leading icon, and an in-place loading spinner.
///
/// Disable the button by passing `onPressed: null` or `isLoading: true`.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final FaIconData? icon;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading
        ? null
        : onPressed != null
        ? () {
            HapticFeedback.lightImpact();
            onPressed!();
          }
        : null;
    final child = isLoading
        ? SizedBox(
            width: _spinnerSize,
            height: _spinnerSize,
            // A loading button drops its text label, so name the spinner for
            // screen readers — otherwise the control is announced as unlabelled.
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _spinnerColor(context),
              semanticsLabel: label,
            ),
          )
        : Text(label);

    final button = switch (variant) {
      AppButtonVariant.primary =>
        icon == null || isLoading
            ? FilledButton(
                onPressed: effectiveOnPressed,
                style: _style(),
                child: child,
              )
            : FilledButton.icon(
                onPressed: effectiveOnPressed,
                style: _style(),
                icon: FaIcon(icon),
                label: Text(label),
              ),
      AppButtonVariant.tonal =>
        icon == null || isLoading
            ? FilledButton.tonal(
                onPressed: effectiveOnPressed,
                style: _style(),
                child: child,
              )
            : FilledButton.tonalIcon(
                onPressed: effectiveOnPressed,
                style: _style(),
                icon: FaIcon(icon),
                label: Text(label),
              ),
      AppButtonVariant.outlined =>
        icon == null || isLoading
            ? OutlinedButton(
                onPressed: effectiveOnPressed,
                style: _style(),
                child: child,
              )
            : OutlinedButton.icon(
                onPressed: effectiveOnPressed,
                style: _style(),
                icon: FaIcon(icon),
                label: Text(label),
              ),
      AppButtonVariant.text =>
        icon == null || isLoading
            ? TextButton(
                onPressed: effectiveOnPressed,
                style: _style(),
                child: child,
              )
            : TextButton.icon(
                onPressed: effectiveOnPressed,
                style: _style(),
                icon: FaIcon(icon),
                label: Text(label),
              ),
    };

    final pressable = _PressScale(
      enabled: effectiveOnPressed != null,
      child: button,
    );

    return expand
        ? SizedBox(width: double.infinity, child: pressable)
        : pressable;
  }

  double get _spinnerSize => switch (size) {
    AppButtonSize.small => 14,
    AppButtonSize.medium => 18,
    AppButtonSize.large => 20,
  };

  ButtonStyle _style() {
    // Vertical padding stays 0 so `minimumSize` alone fixes the exact design
    // heights (content centers within it).
    final padding = switch (size) {
      AppButtonSize.small => const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
      ),
      AppButtonSize.medium => const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
      ),
      AppButtonSize.large => const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
      ),
    };

    // .pen button specimens: Button/Primary = h52 / radius-16 / 17 w600,
    // Button/Secondary = h44 / radius-12 / 15 w600. `small` is an app-only
    // dense size kept on the same scale.
    final radius = switch (size) {
      AppButtonSize.small => 10.0,
      AppButtonSize.medium => AppRadius.md,
      AppButtonSize.large => AppRadius.lg,
    };

    final fontSize = switch (size) {
      AppButtonSize.small => 13.0,
      AppButtonSize.medium => 15.0,
      AppButtonSize.large => 17.0,
    };

    return ButtonStyle(
      padding: WidgetStatePropertyAll(padding),
      minimumSize: WidgetStatePropertyAll(
        Size(0, switch (size) {
          AppButtonSize.small => 36,
          AppButtonSize.medium => 44,
          AppButtonSize.large => 52,
        }),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      elevation: WidgetStatePropertyAll(
        variant == AppButtonVariant.primary ? 2 : 0,
      ),
      textStyle: WidgetStatePropertyAll(
        TextStyle(
          fontSize: fontSize,
          height: 22 / fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _spinnerColor(BuildContext context) {
    return switch (variant) {
      AppButtonVariant.primary => context.colorScheme.onPrimary,
      AppButtonVariant.tonal => context.colorScheme.onSecondaryContainer,
      AppButtonVariant.outlined ||
      AppButtonVariant.text => context.colorScheme.primary,
    };
  }
}

/// Scales [child] down slightly while pressed, springing back on release.
///
/// Wraps the themed button in a [Listener] so the micro-interaction is purely
/// visual — it does not intercept taps, leaving the button's own gesture and
/// haptic handling untouched. Disabled when [enabled] is `false` so non-
/// interactive buttons stay static.
class _PressScale extends StatefulWidget {
  const _PressScale({required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  static const _pressedScale = 0.97;

  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: widget.enabled ? (_) => _setPressed(true) : null,
      onPointerUp: widget.enabled ? (_) => _setPressed(false) : null,
      onPointerCancel: widget.enabled ? (_) => _setPressed(false) : null,
      child: AnimatedScale(
        scale: _pressed ? _pressedScale : 1,
        duration: AppDurations.xfast,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// The full-width coral CTA used across the auth screens — a named alias for the
/// shared [StampMailPrimaryButton] (`.pen` Button/Primary) so auth call sites
/// read intently while the pill itself is defined once in the design system.
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

  /// Renders the design's disabled/locked state (F01-S05).
  final bool locked;

  @override
  Widget build(BuildContext context) => StampMailPrimaryButton(
    label: label,
    onPressed: onPressed,
    isLoading: isLoading,
    locked: locked,
  );
}

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// A rounded, filled text field matching the StampMail auth design: an optional
/// label row above (with an optional trailing action such as "Forgot
/// password?"), a leading icon, and per-field error text rendered beneath.
///
/// Validation errors surface through the standard [validator] so they appear
/// directly under the field (BR-22), while form-level errors are rendered
/// separately by the screen.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.label,
    this.trailingLabel,
    this.suffix,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final String hint;
  final FaIconData icon;
  final String? label;
  final Widget? trailingLabel;
  final Widget? suffix;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final iconColor = colorScheme.outline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label!,
                    style: context.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ?trailingLabel,
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          enabled: enabled,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          validator: validator,
          onFieldSubmitted: onSubmitted,
          style: context.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: context.textTheme.bodyLarge?.copyWith(color: iconColor),
            prefixIcon: Center(
              widthFactor: 1,
              child: FaIcon(icon, color: iconColor, size: 20),
            ),
            suffixIcon: suffix,
            filled: true,
            fillColor: colorScheme.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            constraints: const BoxConstraints(minHeight: 56),
            border: _border(colorScheme.outlineVariant),
            enabledBorder: _border(colorScheme.outlineVariant),
            focusedBorder: _border(colorScheme.primary, width: 2),
            errorBorder: _border(colorScheme.error),
            focusedErrorBorder: _border(colorScheme.error, width: 2),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

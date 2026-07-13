import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Form-level feedback banner per the .pen `Feedback/Banner` component:
/// a tinted `state-error` card (radius-16, 14/16 padding) with a 24px icon and
/// body-md text, both in `text-error`. Used for the login failure and
/// account-locked states (F01-S04 / F01-S05).
class AuthFormBanner extends StatelessWidget {
  const AuthFormBanner({
    required this.message,
    this.icon = FontAwesomeIcons.circleExclamation,
    super.key,
  });

  final String message;
  final FaIconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          FaIcon(icon, size: 24, color: scheme.error),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              message,
              style: context.textTheme.bodyMedium?.copyWith(
                color: scheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

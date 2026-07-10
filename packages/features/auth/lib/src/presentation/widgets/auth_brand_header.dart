import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

/// The StampMail wordmark shown at the top of every auth screen: the stamp
/// logo followed by the app name in the brand coral.
class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/illustrations/logo-stamp.png',
          package: 'feature_auth',
          width: 76,
          height: 76,
          excludeFromSemantics: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          context.l10n.appTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.displayMedium?.copyWith(
            color: context.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// The centered title + subtitle block below [AuthBrandHeader].
class AuthHeading extends StatelessWidget {
  const AuthHeading({required this.title, this.subtitle, super.key});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: context.textTheme.displaySmall?.copyWith(
            color: context.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

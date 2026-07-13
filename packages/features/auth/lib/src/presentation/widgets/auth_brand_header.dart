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
          width: 65,
          height: 71,
          excludeFromSemantics: true,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          context.l10n.appTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          // .pen Brand/AuthLogo wordmark: Baloo 2, 30px, w700, coral.
          style: context.textTheme.displayMedium?.copyWith(
            color: context.colorScheme.primary,
            fontSize: 30,
            height: 1.21,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// The centered title + subtitle block below [AuthBrandHeader].
class AuthHeading extends StatelessWidget {
  const AuthHeading({
    required this.title,
    this.subtitle,
    this.subtitleGap = AppSpacing.sm,
    super.key,
  });

  final String title;
  final String? subtitle;

  /// Title→subtitle gap (login uses 8, register 6 per the .pen frames).
  final double subtitleGap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          // .pen auth headings: Baloo 2, 28px, w700 (display-md).
          style: context.textTheme.displayMedium?.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: subtitleGap),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

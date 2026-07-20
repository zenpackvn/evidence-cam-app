import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// The StampMail brand lockup at the top of every auth screen — the shared
/// [StampMailBrandmark] (`.pen` Brand/AuthLogo), aliased so auth call sites read
/// intently while the lockup itself lives once in the design system.
class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({super.key});

  @override
  Widget build(BuildContext context) => const StampMailBrandmark();
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

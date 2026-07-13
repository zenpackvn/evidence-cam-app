import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import 'creator_theme.dart';
import 'wizard_actions.dart' show WizardActions;

/// The shared chrome for every wizard step (SM-006/008/009/010): the cream
/// ground, a centered display title whose tail is coral-highlighted, an optional
/// subtitle, an optional Premium crown badge in the top-right, the step body,
/// and a pinned bottom action bar. Matches the F02-S04/S05/S07 frames.
class WizardScaffold extends StatelessWidget {
  const WizardScaffold({
    required this.titleLead,
    required this.titleAccent,
    required this.body,
    required this.actions,
    this.subtitle,
    this.showCrown = false,
    super.key,
  });

  /// Title split into a plain lead ("Chọn ") and a coral accent ("bộ lọc màu").
  final String titleLead;
  final String titleAccent;
  final String? subtitle;

  /// Whether to show the gold Premium crown badge (top-right).
  final bool showCrown;

  /// The step-specific content, laid out under the header.
  final Widget body;

  /// The bottom action bar (typically a [WizardActions]).
  final Widget actions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Scaffold(
      backgroundColor: CreatorColors.ground,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: AppSpacing.xxl),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxxl,
                  ),
                  child: Column(
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: context.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.21,
                          ),
                          children: [
                            TextSpan(
                              text: titleLead,
                              style: TextStyle(color: colorScheme.onSurface),
                            ),
                            TextSpan(
                              text: titleAccent,
                              style: TextStyle(color: colorScheme.primary),
                            ),
                          ],
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          subtitle!,
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.47,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: body,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxxl,
                    AppSpacing.md,
                    AppSpacing.xxxl,
                    AppSpacing.xl,
                  ),
                  child: actions,
                ),
              ],
            ),
            if (showCrown)
              const Positioned(top: 8, right: AppSpacing.xxl, child: _Crown()),
          ],
        ),
      ),
    );
  }
}

/// The gold Premium indicator badge (44px circle, gold ring) shown top-right on
/// steps that expose Premium-gated options.
class _Crown extends StatelessWidget {
  const _Crown();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFFEF6E3),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF5BC58), width: 1.5),
      ),
      child: const Icon(
        Icons.workspace_premium_outlined,
        size: 20,
        color: Color(0xFFF5BC58),
      ),
    );
  }
}

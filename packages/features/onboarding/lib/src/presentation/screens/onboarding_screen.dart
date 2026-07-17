import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

import '../widgets/onboarding_step.dart';

/// First-launch intro: a swipeable set of pages with progress dots and
/// Skip / Next / Get started controls, on the warm StampMail cream ground.
///
/// The screen is navigation-agnostic: it calls [onDone] when the user finishes
/// or skips, and the app shell decides where to go next (and persists the
/// "seen" flag via `OnboardingStore`).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    required this.onDone,
    this.steps,
    this.initialStep = 0,
    this.onStepChanged,
    super.key,
  });

  /// Invoked when the user skips or completes the flow.
  final VoidCallback onDone;

  /// Override the default copy (primarily for tests).
  final List<OnboardingStepData>? steps;

  /// The page to open on (0-based). Lets the app shell resume an interrupted
  /// flow at the last-viewed slide (SM-003 §5); defaults to the first slide.
  final int initialStep;

  /// Invoked whenever the visible page changes, so the app shell can persist the
  /// resume position. Not called for the initial page.
  final ValueChanged<int>? onStepChanged;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _controller;
  late int _page;

  @override
  void initState() {
    super.initState();
    // Clamp so a stale/out-of-range saved step can never open on a missing page.
    final count = widget.steps?.length ?? 3;
    _page = widget.initialStep.clamp(0, count - 1);
    _controller = PageController(initialPage: _page);
  }

  List<OnboardingStepData> _steps(AppLocalizations l10n) =>
      widget.steps ??
      [
        OnboardingStepData(
          title: l10n.smOnboard1Title,
          description: l10n.smOnboard1Body,
          heroAsset: 'onb-hero.png',
          showFilters: true,
        ),
        OnboardingStepData(
          title: l10n.smOnboard2Title,
          description: l10n.smOnboard2Body,
          heroAsset: 'onb-hero.png',
        ),
        OnboardingStepData(
          title: l10n.smOnboard3Title,
          description: l10n.smOnboard3Body,
          heroAsset: 'onb-hero.png',
        ),
      ];

  bool _isLast(int count) => _page == count - 1;

  void _next(int count) {
    if (_isLast(count)) {
      widget.onDone();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Onboarding, like auth, is pinned to the light StampMail theme.
    return Theme(data: AppTheme.light(), child: Builder(builder: _build));
  }

  Widget _build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final steps = _steps(l10n);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/illustrations/corner-left-flowers.png',
              package: 'feature_onboarding',
              width: 88,
              excludeFromSemantics: true,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(
              'assets/illustrations/corner-right-stamp.png',
              package: 'feature_onboarding',
              width: 105,
              excludeFromSemantics: true,
            ),
          ),
          Positioned(
            bottom: 88,
            left: 0,
            child: IgnorePointer(
              child: Image.asset(
                'assets/illustrations/onb-bottom-left.png',
                package: 'feature_onboarding',
                width: 132,
                excludeFromSemantics: true,
              ),
            ),
          ),
          Positioned(
            bottom: 88,
            right: 0,
            child: IgnorePointer(
              child: Image.asset(
                'assets/illustrations/onb-bottom-right.png',
                package: 'feature_onboarding',
                width: 124,
                excludeFromSemantics: true,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.sm,
                      right: AppSpacing.lg,
                    ),
                    child: TextButton(
                      onPressed: widget.onDone,
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.onSurfaceVariant,
                        textStyle: context.textTheme.titleSmall,
                      ),
                      child: Text(l10n.smOnboardingSkip),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (i) {
                      setState(() => _page = i);
                      widget.onStepChanged?.call(i);
                    },
                    itemCount: steps.length,
                    itemBuilder: (_, i) => OnboardingStep(data: steps[i]),
                  ),
                ),
                _Dots(count: steps.length, current: _page),
                const SizedBox(height: AppSpacing.xl),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.xxl,
                  ),
                  child: _OnboardingCta(
                    label: _isLast(steps.length)
                        ? l10n.smOnboardingStart
                        : l10n.smOnboardingNext,
                    onPressed: () => _next(steps.length),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The full-width coral CTA with a right-aligned sparkle (matches the auth CTA).
class _OnboardingCta extends StatelessWidget {
  const _OnboardingCta({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

/// Animated page-position indicator: the active dot widens.
class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: active ? 24 : 8,
          decoration: BoxDecoration(
            color: active
                ? scheme.primary
                : scheme.primary.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

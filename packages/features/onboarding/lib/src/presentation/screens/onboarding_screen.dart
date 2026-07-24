import 'package:flutter/material.dart';

import '../widgets/onboarding_step.dart';

/// First-launch intro: a swipeable set of pages with progress dots and
/// Skip / Next / Get started controls.
///
/// The screen is navigation-agnostic: it calls [onDone] when the user finishes
/// or skips, and the app shell decides where to go next (and persists the
/// "seen" flag via `OnboardingStore`). This keeps the feature free of router or
/// DI coupling, matching how `SplashScreen` takes an `onRestored` callback.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({required this.onDone, this.steps, super.key});

  /// Invoked when the user skips or completes the flow.
  final VoidCallback onDone;

  /// Override the default copy (primarily for tests).
  final List<OnboardingStepData>? steps;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _defaultSteps = [
    OnboardingStepData(
      title: 'Welcome',
      description:
          'A production-ready Flutter base with offline-first sync, '
          'auth, and a modular package architecture.',
      icon: Icons.rocket_launch_outlined,
    ),
    OnboardingStepData(
      title: 'Works offline',
      description:
          'Your data is cached locally and syncs in the background, so the '
          'app stays usable on a flaky connection.',
      icon: Icons.cloud_off_outlined,
    ),
    OnboardingStepData(
      title: 'Ready to build',
      description:
          'Copy this template, swap in your features, and ship. The hard '
          'infrastructure is already done.',
      icon: Icons.check_circle_outline,
    ),
  ];

  final _controller = PageController();
  int _page = 0;

  List<OnboardingStepData> get _steps => widget.steps ?? _defaultSteps;

  bool get _isLast => _page == _steps.length - 1;

  void _next() {
    if (_isLast) {
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: widget.onDone,
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _steps.length,
                itemBuilder: (_, i) => OnboardingStep(data: _steps[i]),
              ),
            ),
            _Dots(count: _steps.length, current: _page),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(_isLast ? 'Get started' : 'Next'),
                ),
              ),
            ),
          ],
        ),
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
    final scheme = Theme.of(context).colorScheme;
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
                : scheme.onSurface.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

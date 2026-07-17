import 'package:feature_onboarding/feature_onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';

final _steps = [
  const OnboardingStepData(
    title: 'Step 1',
    description: 'Desc 1',
    heroAsset: 'onb-hero.png',
  ),
  const OnboardingStepData(
    title: 'Step 2',
    description: 'Desc 2',
    heroAsset: 'onb-hero.png',
  ),
];

// The screen reads Skip/Next/Get started from l10n; pin the locale to English so
// the assertions match those literals. The screen supplies its own theme.
Widget _wrap(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

// Pump the screen on a tall phone-sized surface so the vertically-centered
// hero + copy column lays out without overflowing the default 800px test view.
Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(_wrap(child));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows first step on launch', (tester) async {
    await _pump(tester, OnboardingScreen(onDone: () {}, steps: _steps));
    expect(find.text('Step 1'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('Next button advances to next step', (tester) async {
    await _pump(tester, OnboardingScreen(onDone: () {}, steps: _steps));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Step 2'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });

  testWidgets('Skip calls onDone', (tester) async {
    var called = false;
    await _pump(
      tester,
      OnboardingScreen(onDone: () => called = true, steps: _steps),
    );
    await tester.tap(find.text('Skip'));
    expect(called, isTrue);
  });

  testWidgets('Get started on last step calls onDone', (tester) async {
    var called = false;
    await _pump(
      tester,
      OnboardingScreen(onDone: () => called = true, steps: _steps),
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get started'));
    expect(called, isTrue);
  });

  testWidgets('resumes at initialStep (SM-003 mid-flow exit)', (tester) async {
    await _pump(
      tester,
      OnboardingScreen(onDone: () {}, steps: _steps, initialStep: 1),
    );
    // Opens directly on the second (last) page, so the CTA is "Get started".
    expect(find.text('Step 2'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });

  testWidgets('clamps an out-of-range initialStep to the last page', (
    tester,
  ) async {
    await _pump(
      tester,
      OnboardingScreen(onDone: () {}, steps: _steps, initialStep: 99),
    );
    expect(find.text('Step 2'), findsOneWidget);
  });

  testWidgets('onStepChanged fires when the page advances', (tester) async {
    final seen = <int>[];
    await _pump(
      tester,
      OnboardingScreen(
        onDone: () {},
        steps: _steps,
        onStepChanged: seen.add,
      ),
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(seen, contains(1));
  });
}

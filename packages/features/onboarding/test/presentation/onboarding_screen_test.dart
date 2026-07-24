import 'package:feature_onboarding/feature_onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _steps = [
  const OnboardingStepData(
    title: 'Step 1',
    description: 'Desc 1',
    icon: Icons.star,
  ),
  const OnboardingStepData(
    title: 'Step 2',
    description: 'Desc 2',
    icon: Icons.favorite,
  ),
];

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  testWidgets('shows first step on launch', (tester) async {
    await tester.pumpWidget(
      _wrap(OnboardingScreen(onDone: () {}, steps: _steps)),
    );
    expect(find.text('Step 1'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('Next button advances to next step', (tester) async {
    await tester.pumpWidget(
      _wrap(OnboardingScreen(onDone: () {}, steps: _steps)),
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Step 2'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });

  testWidgets('Skip calls onDone', (tester) async {
    var called = false;
    await tester.pumpWidget(
      _wrap(OnboardingScreen(onDone: () => called = true, steps: _steps)),
    );
    await tester.tap(find.text('Skip'));
    expect(called, isTrue);
  });

  testWidgets('Get started on last step calls onDone', (tester) async {
    var called = false;
    await tester.pumpWidget(
      _wrap(OnboardingScreen(onDone: () => called = true, steps: _steps)),
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get started'));
    expect(called, isTrue);
  });
}

# Testing — Feature Flags

## Fake for Tests (reuse `LocalFeatureFlagService`)

```dart
// In tests, use LocalFeatureFlagService directly — it's already a perfect fake.

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:app/src/core/feature_flags/feature_flag.dart';
import 'package:app/src/core/feature_flags/feature_flag_service.dart';
import 'package:app/src/core/feature_flags/local_feature_flag_service.dart';

void main() {
  late LocalFeatureFlagService fakeFlags;

  setUp(() {
    fakeFlags = LocalFeatureFlagService();
    GetIt.I.registerSingleton<FeatureFlagService>(fakeFlags);
  });

  tearDown(() => GetIt.I.reset());

  test('flag defaults to false', () {
    expect(fakeFlags.isEnabled(FeatureFlag.newOnboarding), isFalse);
  });

  test('setFlag enables flag', () {
    fakeFlags.setFlag(FeatureFlag.newOnboarding, true);
    expect(fakeFlags.isEnabled(FeatureFlag.newOnboarding), isTrue);
  });

  test('clearFlag reverts to default', () {
    fakeFlags.setFlag(FeatureFlag.newOnboarding, true);
    fakeFlags.clearFlag(FeatureFlag.newOnboarding);
    expect(fakeFlags.isEnabled(FeatureFlag.newOnboarding), isFalse);
  });

  test('string flag returns variant', () {
    fakeFlags.setFlag(FeatureFlag.checkoutLayout, 'single_page');
    expect(
      fakeFlags.getString(FeatureFlag.checkoutLayout),
      'single_page',
    );
  });

  test('listener fires on setFlag', () {
    var called = false;
    fakeFlags.addListener(() => called = true);
    fakeFlags.setFlag(FeatureFlag.offlineMode, true);
    expect(called, isTrue);
  });
}
```

## Cubit Test with Feature Flag

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/src/core/feature_flags/feature_flag.dart';
import 'package:app/src/core/feature_flags/local_feature_flag_service.dart';
import 'package:app/src/features/checkout/cubit/checkout_cubit.dart';
import 'fakes/fake_analytics_service.dart';

void main() {
  late LocalFeatureFlagService fakeFlags;
  late FakeAnalyticsService fakeAnalytics;

  setUp(() {
    fakeFlags = LocalFeatureFlagService();
    fakeAnalytics = FakeAnalyticsService();
  });

  blocTest<CheckoutCubit, CheckoutState>(
    'emits control variant by default',
    build: () => CheckoutCubit(
      featureFlags: fakeFlags,
      analytics: fakeAnalytics,
    ),
    act: (cubit) => cubit.init(),
    expect: () => [
      isA<CheckoutReady>()
          .having((s) => s.variant, 'variant', CheckoutVariant.control),
    ],
  );

  blocTest<CheckoutCubit, CheckoutState>(
    'emits single_page variant when flag is set',
    setUp: () {
      fakeFlags.setFlag(FeatureFlag.checkoutLayout, 'singlePage');
    },
    build: () => CheckoutCubit(
      featureFlags: fakeFlags,
      analytics: fakeAnalytics,
    ),
    act: (cubit) => cubit.init(),
    expect: () => [
      isA<CheckoutReady>()
          .having((s) => s.variant, 'variant', CheckoutVariant.singlePage),
    ],
  );

  blocTest<CheckoutCubit, CheckoutState>(
    'tracks experiment exposure on init',
    build: () => CheckoutCubit(
      featureFlags: fakeFlags,
      analytics: fakeAnalytics,
    ),
    act: (cubit) => cubit.init(),
    verify: (_) {
      expect(
        fakeAnalytics.events,
        contains(isA<AnalyticsEvent>()
            .having((e) => e.name, 'name', 'experiment_exposure')),
      );
    },
  );
}
```

## Widget Test with FeatureGate

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:app/src/core/feature_flags/feature_flag.dart';
import 'package:app/src/core/feature_flags/feature_flag_service.dart';
import 'package:app/src/core/feature_flags/local_feature_flag_service.dart';
import 'package:app/src/core/feature_flags/feature_gate.dart';

void main() {
  late LocalFeatureFlagService fakeFlags;

  setUp(() {
    fakeFlags = LocalFeatureFlagService();
    GetIt.I.registerSingleton<FeatureFlagService>(fakeFlags);
  });

  tearDown(() => GetIt.I.reset());

  testWidgets('FeatureGate shows child when flag enabled', (tester) async {
    fakeFlags.setFlag(FeatureFlag.newOnboarding, true);

    await tester.pumpWidget(
      MaterialApp(
        home: FeatureGate(
          flag: FeatureFlag.newOnboarding,
          child: const Text('New'),
          fallback: const Text('Old'),
        ),
      ),
    );

    expect(find.text('New'), findsOneWidget);
    expect(find.text('Old'), findsNothing);
  });

  testWidgets('FeatureGate shows fallback when flag disabled', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FeatureGate(
          flag: FeatureFlag.newOnboarding,
          child: const Text('New'),
          fallback: const Text('Old'),
        ),
      ),
    );

    expect(find.text('Old'), findsOneWidget);
    expect(find.text('New'), findsNothing);
  });
}
```

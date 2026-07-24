# A/B Testing Pattern

## Variant Enum

```dart
/// Checkout layout experiment variants.
/// Must match Remote Config values exactly.
enum CheckoutVariant {
  control,
  singlePage;

  static CheckoutVariant fromString(String value) =>
      CheckoutVariant.values.firstWhere(
        (v) => v.name == value,
        orElse: () => CheckoutVariant.control,
      );
}
```

## Variant Resolution in Cubit

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/feature_flags/feature_flag.dart';
import '../../core/feature_flags/feature_flag_service.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit({
    required FeatureFlagService featureFlags,
    required AnalyticsService analytics,
  })  : _featureFlags = featureFlags,
        _analytics = analytics,
        super(const CheckoutInitial());

  final FeatureFlagService _featureFlags;
  final AnalyticsService _analytics;

  void init() {
    final variant = CheckoutVariant.fromString(
      _featureFlags.getString(FeatureFlag.checkoutLayout),
    );

    // Track experiment exposure for analytics.
    _analytics.trackEvent('experiment_exposure', properties: {
      'experiment': FeatureFlag.checkoutLayout.key,
      'variant': variant.name,
    });

    emit(CheckoutReady(variant: variant));
  }
}
```

## Variant-Driven UI

```dart
@override
Widget build(BuildContext context) {
  return BlocBuilder<CheckoutCubit, CheckoutState>(
    builder: (context, state) {
      if (state is! CheckoutReady) return const SizedBox.shrink();

      return switch (state.variant) {
        CheckoutVariant.control => const ClassicCheckoutView(),
        CheckoutVariant.singlePage => const SinglePageCheckoutView(),
      };
    },
  );
}
```

## Track Experiment Outcome

```dart
// When the user completes checkout, track the conversion.
_analytics.trackEvent('checkout_completed', properties: {
  'experiment': FeatureFlag.checkoutLayout.key,
  'variant': _currentVariant.name,
  'total_amount': order.total,
});
```

## Gradual Rollout Pattern

```dart
/// Server-side approach (recommended):
/// Remote Config's "Conditions" handle percentage rollout.
/// The client just reads isEnabled() — no local percentage logic needed.
///
/// If you need client-side rollout (offline, no server):
class RolloutHelper {
  RolloutHelper({required this.userId});

  final String userId;

  /// Deterministic: same user always gets the same result for a given flag.
  bool isInRollout(FeatureFlag flag, {required double percentage}) {
    final hash = userId.hashCode ^ flag.key.hashCode;
    final bucket = (hash.abs() % 100).toDouble();
    return bucket < percentage;
  }
}
```

## Key Rules

- **Track experiment exposure**: When a user sees an A/B variant, fire an analytics event immediately. Without exposure tracking, experiment results are meaningless.
- **Track experiment outcome**: Include the variant in the conversion analytics event.
- **Resolve flags in cubit, not widgets**: Cubit resolves the flag once and emits a state; widget renders from state (pure).
- **Clean up stale flags**: When a flag is fully rolled out or experiment concludes, remove from the enum and delete the old code path.

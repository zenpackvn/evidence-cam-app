# Animation Constants — `AppAnimations`

Centralized duration, curve, and offset constants. Same pattern as `AppColors`, `AppSpacing`, `AppTypography`. No runtime dependencies — pure Dart constants.

## Folder structure

```text
lib/src/core/
  animations/
    app_animations.dart              ← Duration & curve constants (abstract final class)
    app_animate.dart                 ← AppAnimatePresets interface + AppAnimateX extension + initAppAnimatePresets
    app_animate_impl.dart            ← Wraps flutter_animate (only import)
    app_lottie.dart                  ← AppLottie abstract widget + LottieAssets path constants
    app_lottie_impl.dart             ← Wraps lottie (only import)
    animated_list_wrapper.dart       ← Typed add/remove with transitions
    animations.dart                  ← Barrel export
  di/
    animations_module.dart           ← registerAnimationsModule(GetIt)

assets/
  animations/                        ← Lottie JSON files
    onboarding_welcome.json
    success_payment.json
    error_generic.json
    empty_search.json
    loading_skeleton.json
```

## pubspec.yaml additions

```yaml
dependencies:
  flutter_animate: 4.5.2
  lottie: 3.1.3

flutter:
  assets:
    - assets/animations/
```

---

## `lib/src/core/animations/app_animations.dart`

```dart
/// Centralized animation constants — durations, curves, delays.
/// Same pattern as AppColors, AppSpacing, AppTypography.
abstract final class AppAnimations {
  // ── Durations ──
  static const durationFast = Duration(milliseconds: 150);
  static const durationMedium = Duration(milliseconds: 300);
  static const durationSlow = Duration(milliseconds: 500);
  static const durationPage = Duration(milliseconds: 350);

  // ── Stagger ──
  static const staggerDelay = Duration(milliseconds: 50);

  // ── Curves ──
  static const curveStandard = Curves.easeInOut;
  static const curveDecelerate = Curves.decelerate;
  static const curveAccelerate = Curves.easeIn;
  static const curveSharp = Curves.easeOutCubic;
  static const curveBounce = Curves.elasticOut;

  // ── Offsets ──
  static const slideUpOffset = Offset(0, 0.1);
  static const slideDownOffset = Offset(0, -0.1);
  static const slideLeftOffset = Offset(-0.1, 0);
  static const slideRightOffset = Offset(0.1, 0);
}
```

---

## `lib/src/core/animations/animations.dart` (barrel)

```dart
export 'animated_list_wrapper.dart';
export 'app_animate.dart';
export 'app_animate_impl.dart';
export 'app_animations.dart';
export 'app_lottie.dart';
export 'app_lottie_impl.dart';
```

---

## Rules

- **Centralize durations and curves** — Use `AppAnimations` constants everywhere. No inline `Duration(milliseconds: 300)` or `Curves.easeInOut` in widgets.
- **Keep animations short** — Standard: 200–300ms. Page transitions: 300–400ms. Never exceed 600ms. Animations clarify state changes, they don't decorate.

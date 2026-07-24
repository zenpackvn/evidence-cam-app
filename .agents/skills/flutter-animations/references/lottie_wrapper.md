# Lottie Wrapper

App-owned widget + asset constants wrapping `package:lottie`. Only `app_lottie_impl.dart` imports the third-party package.

## `lib/src/core/animations/app_lottie.dart`

```dart
import 'package:flutter/widgets.dart';

/// App-owned Lottie animation widget.
/// No lottie package import leaks past this boundary.
abstract class AppLottie extends StatelessWidget {
  const AppLottie({
    super.key,
    required this.asset,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.repeat = true,
    this.animate = true,
    this.onComplete,
  });

  /// Asset path relative to `assets/animations/`.
  final String asset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool repeat;
  final bool animate;
  final VoidCallback? onComplete;

  /// Factory constructor — returns the implementation.
  /// Registered via DI; use `getIt<AppLottie>()` factory or this static.
  static AppLottie create({
    Key? key,
    required String asset,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    bool repeat = true,
    bool animate = true,
    VoidCallback? onComplete,
  }) {
    return AppLottieImpl(
      key: key,
      asset: asset,
      width: width,
      height: height,
      fit: fit,
      repeat: repeat,
      animate: animate,
      onComplete: onComplete,
    );
  }
}
```

---

## `lib/src/core/animations/app_lottie_impl.dart`

```dart
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart'; // ← ONLY file that imports this

import 'app_lottie.dart';

/// Wraps [Lottie] behind the app-owned [AppLottie] interface.
class AppLottieImpl extends AppLottie {
  const AppLottieImpl({
    super.key,
    required super.asset,
    super.width,
    super.height,
    super.fit,
    super.repeat,
    super.animate,
    super.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animations/$asset',
      width: width,
      height: height,
      fit: fit,
      repeat: repeat,
      animate: animate,
      onLoaded: (composition) {
        if (!repeat && onComplete != null) {
          Future.delayed(composition.duration, onComplete);
        }
      },
      errorBuilder: (context, error, stackTrace) {
        // Graceful fallback — don't crash if animation asset is missing.
        return SizedBox(width: width, height: height);
      },
    );
  }
}
```

---

## Lottie with AnimationController (fine-grained control)

Place in `app_lottie_controlled_impl.dart`:

```dart
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart'; // ← in app_lottie_controlled_impl.dart

class AppLottieControlledImpl extends StatefulWidget {
  const AppLottieControlledImpl({
    super.key,
    required this.asset,
    this.width,
    this.height,
    this.onComplete,
  });

  final String asset;
  final double? width;
  final double? height;
  final VoidCallback? onComplete;

  @override
  State<AppLottieControlledImpl> createState() => _AppLottieControlledImplState();
}

class _AppLottieControlledImplState extends State<AppLottieControlledImpl>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animations/${widget.asset}',
      controller: _controller,
      width: widget.width,
      height: widget.height,
      onLoaded: (composition) {
        _controller
          ..duration = composition.duration
          ..forward();
      },
    );
  }
}
```

---

## Lottie asset management

### Asset naming convention

```text
assets/animations/
  onboarding_welcome.json       ← screen_action.json
  onboarding_features.json
  success_payment.json
  success_order.json
  error_generic.json
  error_network.json
  empty_orders.json
  empty_search.json
  loading_skeleton.json
  splash_logo.json
```

### Asset constants — `LottieAssets`

```dart
/// Centralized Lottie asset paths — single source of truth.
abstract final class LottieAssets {
  static const onboardingWelcome = 'onboarding_welcome.json';
  static const onboardingFeatures = 'onboarding_features.json';
  static const successPayment = 'success_payment.json';
  static const successOrder = 'success_order.json';
  static const errorGeneric = 'error_generic.json';
  static const errorNetwork = 'error_network.json';
  static const emptyOrders = 'empty_orders.json';
  static const emptySearch = 'empty_search.json';
  static const loadingSkeleton = 'loading_skeleton.json';
  static const splashLogo = 'splash_logo.json';
}
```

---

## Usage examples

### Lottie — success state

```dart
class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppLottie.create(
              asset: 'success.json',
              width: 200,
              height: 200,
              repeat: false,
              onComplete: () {
                // Navigate away after animation.
                context.go('/home');
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Payment Successful!',
              style: Theme.of(context).textTheme.headlineSmall,
            ).appFadeIn(delay: AppAnimations.durationSlow),
          ],
        ),
      ),
    );
  }
}
```

### Lottie — empty state

```dart
class EmptyOrdersView extends StatelessWidget {
  const EmptyOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppLottie.create(
          asset: 'empty_state.json',
          width: 250,
          height: 250,
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.noOrdersYet,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
```

### Lottie — onboarding page

```dart
class OnboardingStep extends StatelessWidget {
  const OnboardingStep({
    super.key,
    required this.animationAsset,
    required this.title,
    required this.subtitle,
  });

  final String animationAsset;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: AppLottie.create(
              asset: animationAsset,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 32),
          Text(title,
            style: Theme.of(context).textTheme.headlineMedium,
          ).appEntrance(),
          const SizedBox(height: 12),
          Text(subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ).appFadeIn(delay: AppAnimations.staggerDelay * 2),
          const Spacer(),
        ],
      ),
    );
  }
}
```

---

## Anti-patterns

### DON'T — Import Lottie directly in a page

```dart
// BAD: page depends on third-party package
import 'package:lottie/lottie.dart';

class SuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Lottie.asset('assets/animations/success.json');
  }
}
```

### DO — Use the app-owned AppLottie wrapper

```dart
// GOOD: no package import, consistent API
class SuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppLottie.create(
      asset: LottieAssets.successPayment,
      width: 200,
      height: 200,
      repeat: false,
    );
  }
}
```

---

## Rules

- **Wrapper rule** — Only `app_lottie_impl.dart` imports `package:lottie`. All other files use app-owned interfaces.
- **Lottie asset constants** — Define all asset paths in `LottieAssets`. No hardcoded strings in widgets.
- **Graceful Lottie fallback** — Always provide `errorBuilder` in Lottie. A missing animation asset should show a fallback, not crash.
- **Use Lottie for designer-driven animations** — Onboarding, success/error/empty states, splash. Keep Lottie files under `assets/animations/` with consistent naming.
- **Dispose controllers** — If using raw `AnimationController` (e.g., Lottie controlled mode), always dispose in `dispose()`. Use `SingleTickerProviderStateMixin`.

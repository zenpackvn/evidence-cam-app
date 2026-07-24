# flutter_animate Wrapper

App-owned interface + extension + implementation wrapping `package:flutter_animate`. Only `app_animate_impl.dart` imports the third-party package.

## `lib/src/core/animations/app_animate.dart`

```dart
import 'package:flutter/widgets.dart';

/// App-owned animation effect applied to widgets.
/// No flutter_animate import leaks past this boundary.
///
/// Usage:
///   child.appFadeIn()
///   child.appSlideUp()
///   child.appScaleIn()
///   child.appEntrance()         // combined fade + slide
///   child.appStaggeredItem(index) // for list items
abstract interface class AppAnimateEffect {
  /// Wrap a widget with the configured animation.
  Widget apply(Widget child);
}

/// Registry of predefined animation presets.
/// Implemented by AppAnimatePresetsImpl which imports flutter_animate.
abstract interface class AppAnimatePresets {
  // ── Entrance effects ──

  /// Fade in from transparent.
  Widget fadeIn(Widget child, {Duration? duration, Duration? delay});

  /// Slide up from below + fade in.
  Widget slideUp(Widget child, {Duration? duration, Duration? delay});

  /// Slide down from above + fade in.
  Widget slideDown(Widget child, {Duration? duration, Duration? delay});

  /// Scale in from smaller + fade in.
  Widget scaleIn(Widget child, {Duration? duration, Duration? delay});

  /// Combined fade + slide up (standard entrance).
  Widget entrance(Widget child, {Duration? duration, Duration? delay});

  // ── Exit effects ──

  /// Fade out to transparent.
  Widget fadeOut(Widget child, {Duration? duration, Duration? delay});

  // ── Attention effects ──

  /// Horizontal shake (error feedback).
  Widget shakeX(Widget child, {Duration? duration});

  /// Vertical shake.
  Widget shakeY(Widget child, {Duration? duration});

  // ── List effects ──

  /// Staggered entrance for list items. Pass the item index.
  Widget staggeredItem(Widget child, {required int index});

  // ── State transitions ──

  /// Crossfade swap between two widgets based on a value change.
  Widget swap({
    required Widget child,
    required Duration duration,
  });
}
```

---

## `lib/src/core/animations/app_animate_impl.dart`

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart'; // ← ONLY file that imports this

import 'app_animate.dart';
import 'app_animations.dart';

/// Implements [AppAnimatePresets] using flutter_animate.
class AppAnimatePresetsImpl implements AppAnimatePresets {
  const AppAnimatePresetsImpl();

  // ── Entrance effects ──

  @override
  Widget fadeIn(Widget child, {Duration? duration, Duration? delay}) {
    return child
        .animate(delay: delay)
        .fadeIn(
          duration: duration ?? AppAnimations.durationMedium,
          curve: AppAnimations.curveStandard,
        );
  }

  @override
  Widget slideUp(Widget child, {Duration? duration, Duration? delay}) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: duration ?? AppAnimations.durationMedium)
        .slideY(
          begin: 0.1,
          end: 0,
          duration: duration ?? AppAnimations.durationMedium,
          curve: AppAnimations.curveSharp,
        );
  }

  @override
  Widget slideDown(Widget child, {Duration? duration, Duration? delay}) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: duration ?? AppAnimations.durationMedium)
        .slideY(
          begin: -0.1,
          end: 0,
          duration: duration ?? AppAnimations.durationMedium,
          curve: AppAnimations.curveSharp,
        );
  }

  @override
  Widget scaleIn(Widget child, {Duration? duration, Duration? delay}) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: duration ?? AppAnimations.durationMedium)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: duration ?? AppAnimations.durationMedium,
          curve: AppAnimations.curveSharp,
        );
  }

  @override
  Widget entrance(Widget child, {Duration? duration, Duration? delay}) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: duration ?? AppAnimations.durationMedium)
        .slideY(
          begin: 0.05,
          end: 0,
          duration: duration ?? AppAnimations.durationMedium,
          curve: AppAnimations.curveStandard,
        );
  }

  // ── Exit effects ──

  @override
  Widget fadeOut(Widget child, {Duration? duration, Duration? delay}) {
    return child
        .animate(delay: delay)
        .fadeOut(
          duration: duration ?? AppAnimations.durationMedium,
          curve: AppAnimations.curveStandard,
        );
  }

  // ── Attention effects ──

  @override
  Widget shakeX(Widget child, {Duration? duration}) {
    return child
        .animate(autoPlay: true)
        .shakeX(
          hz: 4,
          amount: 6,
          duration: duration ?? AppAnimations.durationMedium,
        );
  }

  @override
  Widget shakeY(Widget child, {Duration? duration}) {
    return child
        .animate(autoPlay: true)
        .shakeY(
          hz: 4,
          amount: 6,
          duration: duration ?? AppAnimations.durationMedium,
        );
  }

  // ── List effects ──

  @override
  Widget staggeredItem(Widget child, {required int index}) {
    return child
        .animate(delay: AppAnimations.staggerDelay * index)
        .fadeIn(duration: AppAnimations.durationMedium)
        .slideY(
          begin: 0.1,
          end: 0,
          duration: AppAnimations.durationMedium,
          curve: AppAnimations.curveSharp,
        );
  }

  // ── State transitions ──

  @override
  Widget swap({required Widget child, required Duration duration}) {
    return AnimatedSwitcher(
      duration: duration,
      child: child,
    );
  }
}
```

---

## Convenience extension — `AppAnimateX`

Add to `app_animate.dart` (no additional imports required):

```dart
/// Extension on Widget for quick access to app animation presets.
/// Usage: myWidget.appFadeIn() or myWidget.appEntrance()
///
/// Requires AppAnimatePresets to be registered in DI.
/// Import this file in pages that need animations.
extension AppAnimateX on Widget {
  Widget appFadeIn({Duration? duration, Duration? delay}) =>
      _presets.fadeIn(this, duration: duration, delay: delay);

  Widget appSlideUp({Duration? duration, Duration? delay}) =>
      _presets.slideUp(this, duration: duration, delay: delay);

  Widget appSlideDown({Duration? duration, Duration? delay}) =>
      _presets.slideDown(this, duration: duration, delay: delay);

  Widget appScaleIn({Duration? duration, Duration? delay}) =>
      _presets.scaleIn(this, duration: duration, delay: delay);

  Widget appEntrance({Duration? duration, Duration? delay}) =>
      _presets.entrance(this, duration: duration, delay: delay);

  Widget appFadeOut({Duration? duration, Duration? delay}) =>
      _presets.fadeOut(this, duration: duration, delay: delay);

  Widget appShakeX({Duration? duration}) =>
      _presets.shakeX(this, duration: duration);

  Widget appShakeY({Duration? duration}) =>
      _presets.shakeY(this, duration: duration);

  Widget appStaggeredItem({required int index}) =>
      _presets.staggeredItem(this, index: index);
}

/// Singleton presets instance — set during DI initialization.
late AppAnimatePresets _presets;

/// Called from the DI composition root to wire the presets.
void initAppAnimatePresets(AppAnimatePresets presets) {
  _presets = presets;
}
```

---

## DI Registration — `lib/src/core/di/animations_module.dart`

```dart
import 'package:get_it/get_it.dart';

import '../animations/app_animate.dart';
import '../animations/app_animate_impl.dart';

void registerAnimationsModule(GetIt di) {
  di.registerLazySingleton<AppAnimatePresets>(
    () => const AppAnimatePresetsImpl(),
  );

  // Initialize the convenience extension.
  initAppAnimatePresets(di<AppAnimatePresets>());
}
```

---

## Usage examples

### Entrance animation on a page

```dart
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Avatar scales in.
          const CircleAvatar(radius: 48).appScaleIn(),
          const SizedBox(height: 16),
          // Name fades in with slight delay.
          Text('John Doe',
            style: Theme.of(context).textTheme.headlineMedium,
          ).appFadeIn(delay: AppAnimations.staggerDelay * 2),
          const SizedBox(height: 8),
          // Bio slides up with more delay.
          const Text('Flutter developer').appSlideUp(
            delay: AppAnimations.staggerDelay * 3,
          ),
        ],
      ),
    );
  }
}
```

### Staggered list items

```dart
class NotificationListView extends StatelessWidget {
  const NotificationListView({super.key, required this.items});
  final List<NotificationItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return NotificationCard(item: items[index])
            .appStaggeredItem(index: index);
      },
    );
  }
}
```

### Error shake feedback

```dart
BlocListener<LoginCubit, LoginState>(
  listenWhen: (prev, curr) =>
      curr is LoginForm && curr.serverError != null,
  listener: (context, state) {
    // Shake the form on server error.
    _formKey.currentState?.shakeForm();
  },
  child: Form(
    key: _formKey,
    child: Column(
      children: [
        // The submit button shakes on error.
        if (state.serverError != null)
          ElevatedButton(
            onPressed: cubit.submit,
            child: const Text('Login'),
          ).appShakeX(),
      ],
    ),
  ),
)
```

---

## Anti-patterns

### DON'T — Write manual AnimationController boilerplate

```dart
// BAD: verbose, error-prone, no consistency
class _MyWidgetState extends State<MyWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }
  // ... 30 more lines ...
}
```

### DO — Use the declarative chain API

```dart
// GOOD: one line, consistent, maintainable
const Text('Hello').appEntrance()
```

### DON'T — Hardcode durations and curves

```dart
// BAD: inconsistent timings scattered across app
AnimatedContainer(
  duration: const Duration(milliseconds: 250),
  curve: Curves.easeIn,
  // ...
)
```

### DO — Use AppAnimations constants

```dart
// GOOD: consistent, easy to tune globally
AnimatedContainer(
  duration: AppAnimations.durationMedium,
  curve: AppAnimations.curveStandard,
  // ...
)
```

### DON'T — Animate the entire tree

```dart
// BAD: entire Column re-animates
Column(
  children: [header, body, footer],
).appFadeIn()
```

### DO — Animate only the changing element

```dart
// GOOD: only the body animates, header/footer are static
Column(
  children: [
    header,
    body.appEntrance(),
    footer,
  ],
)
```

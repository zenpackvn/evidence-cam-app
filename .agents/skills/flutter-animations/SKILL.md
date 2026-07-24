---
name: flutter-animations
description: Use this skill when implementing Flutter animations — flutter_animate, Lottie animations, hero animations, page transitions, staggered list animations, animated list, AnimatedSwitcher, AnimatedContainer, entrance animations, loading animations, micro-interactions, or any motion/transition in a Flutter app.
---

# Flutter Animations

Full reference: [`template.md`](references/template.md)

## Key rules

- `AppAnimations` defines all duration and curve constants — never hardcode `Duration(milliseconds: 300)` or `Curves.easeInOut` inline.
- **Never import `package:flutter_animate`** or **`package:lottie`** directly in feature code. Use the app-owned wrappers:
  - `AppAnimateX` extension methods (from `app_animate.dart`) for widget animations
  - `AppLottie` widget (from `app_lottie.dart`) for Lottie files
- Staggered lists: use `.appStaggeredItem(index: i)` inside `itemBuilder` — handles delay calculation automatically.
- Hero transitions: `Hero(tag: 'task-${task.id}', child: ...)` on both source and destination. Tag must be unique per item.
- Prefer declarative animations (`AppAnimateX` extensions) over imperative (`AnimationController`) unless fine-grained control is required.
- Motion must not impede usability — respect `MediaQuery.disableAnimations`.

## `AppAnimateX` extension methods

All available on any `Widget` via import of `app_animate.dart`:

```dart
child.appFadeIn({Duration? duration, Duration? delay})
child.appSlideUp({Duration? duration, Duration? delay})
child.appSlideDown({Duration? duration, Duration? delay})
child.appScaleIn({Duration? duration, Duration? delay})
child.appEntrance({Duration? duration, Duration? delay})   // fade + slide up
child.appFadeOut({Duration? duration, Duration? delay})
child.appShakeX({Duration? duration})   // horizontal shake — error feedback
child.appShakeY({Duration? duration})
child.appStaggeredItem({required int index})   // staggered list entrance
```

## Usage examples

```dart
// Single widget entrance
Text('Hello').appFadeIn(delay: AppAnimations.staggerDelay * 2)

// Staggered list
itemBuilder: (context, task, i) => TaskListTile(task: task)
    .appStaggeredItem(index: i)

// Banner fade in
Container(...).appFadeIn()

// Scale in on load
Icon(Icons.task_alt).appScaleIn()
```

## Files

```
lib/src/core/animations/
  app_animations.dart      ← duration + curve constants (fast, medium, slow, staggerDelay)
  app_animate.dart         ← AppAnimateX extension + AppAnimatePresets interface
  app_lottie.dart          ← AppLottie widget (only import of package:lottie)
assets/animations/         ← .json Lottie files
```

## Co-load with

- `flutter-theme` — animation constants follow design tokens
- `flutter-performance` — animations must not cause jank

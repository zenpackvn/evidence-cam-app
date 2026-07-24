# AppKeyboardDismisser

Wraps any widget tree so touching outside a focused text field (or swiping) dismisses the keyboard. Wrap `Scaffold` — not individual fields.

## `pubspec.yaml` addition

```yaml
dependencies:
  keyboard_dismisser: 3.0.0    # exact version, never ^
```

## File

`lib/src/core/widgets/common/app_keyboard_dismisser.dart`

```dart
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

/// Wraps [child] so that touching outside any focused text field
/// (or performing any of [gestures]) dismisses the keyboard.
///
/// Usage:
/// ```dart
/// AppKeyboardDismisser(
///   child: Scaffold(...),
/// )
/// ```
///
/// By default dismisses on tap. Pass [gestures] to add swipe-down etc.
class AppKeyboardDismisser extends StatelessWidget {
  const AppKeyboardDismisser({
    super.key,
    required this.child,
    this.gestures = const [GestureType.onTap],
  });

  final Widget child;
  final List<GestureType> gestures;

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      gestures: gestures,
      child: child,
    );
  }
}
```

## Usage

```dart
// Default — dismiss on tap:
return AppKeyboardDismisser(
  child: Scaffold(
    body: SingleChildScrollView(
      child: Column(children: [
        AppTextField(label: 'Email', ...),
        AppTextField(label: 'Password', ...),
      ]),
    ),
  ),
);

// With swipe-down support:
return AppKeyboardDismisser(
  gestures: const [GestureType.onTap, GestureType.onVerticalDragDown],
  child: Scaffold(...),
);
```

## Rules

- Always wrap at the `Scaffold` (or page root) level — never wrap individual `TextField`s or `Column`s.
- Only `app_keyboard_dismisser.dart` imports `keyboard_dismisser`. Wrapper rule applies.

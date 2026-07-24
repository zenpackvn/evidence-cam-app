# Localization — RTL Support

## Directionality-Aware Layouts

```dart
// DON'T — hardcode left/right
Padding(padding: EdgeInsets.only(left: 16))

// DO — use directional-aware insets
Padding(padding: EdgeInsetsDirectional.only(start: 16))
```

```dart
// DON'T — hardcode alignment
Align(alignment: Alignment.centerLeft)

// DO — use directional alignment
Align(alignment: AlignmentDirectional.centerStart)
```

```dart
// DON'T — hardcode Row order for icons (breaks in RTL)
Row(children: [icon, Expanded(child: text)])

// DO — Row already respects textDirection automatically.
// For manual control, pass the direction explicitly:
Row(
  textDirection: Directionality.of(context),
  children: [icon, Expanded(child: text)],
)
```

---

## RTL-Aware Widget Helper

```dart
import 'package:flutter/widgets.dart';
import '../../core/di/service_locator.dart';
import '../../core/localization/localization_service.dart';

extension RtlContext on BuildContext {
  bool get isRtl => getIt<LocalizationService>().isRtl;

  /// Flip a value for RTL. Returns [ltr] in LTR mode, [rtl] in RTL mode.
  T directional<T>({required T ltr, required T rtl}) => isRtl ? rtl : ltr;
}
```

---

## Icon Flipping for RTL

Icons that indicate direction (arrows, back buttons) should flip in RTL.

```dart
Transform.flip(
  flipX: context.isRtl,
  child: const Icon(Icons.arrow_forward),
)
```

---

## Rules

- Always use `EdgeInsetsDirectional` instead of `EdgeInsets.only(left/right)`.
- Always use `AlignmentDirectional` instead of `Alignment.centerLeft/Right`.
- If the app supports any RTL language, run the app in that locale and verify layout doesn't break.
- `LocalizationService.isRtl` checks `{'ar', 'he', 'fa', 'ur', 'ps', 'ku', 'yi'}` — add additional RTL languages as needed.

# Loading — AppLoadingIndicator

The **only file** that imports `flutter_spinkit`. All other code depends on this widget. To change the spinner style globally, edit only this file.

## `pubspec.yaml` addition

```yaml
dependencies:
  flutter_spinkit: 5.2.1    # exact version, never ^
```

## `lib/src/core/widgets/loading/app_loading_indicator.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

enum AppLoadingSize {
  small(24.0),
  medium(40.0),
  large(56.0);

  const AppLoadingSize(this.value);
  final double value;
}

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({
    super.key,
    this.size = AppLoadingSize.medium,
    this.color,
  });

  final AppLoadingSize size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? Theme.of(context).colorScheme.primary;

    return SpinKitFadingCircle(
      color: effectiveColor,
      size: size.value,
    );
  }
}
```

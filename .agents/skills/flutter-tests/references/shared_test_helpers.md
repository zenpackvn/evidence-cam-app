# Shared Test Helpers

## Folder structure

```text
test/
  app_smoke_test.dart                    ← Minimal smoke test: renders home
  helpers/
    test_helpers.dart                    ← Shared test utilities
    pump_app.dart                        ← pumpApp wrapper with theme, router, DI
    fakes.dart                           ← Shared fakes (NoopLogger, etc.)
    golden_config.dart                   ← Golden test file comparator setup
  features/
    home/
      home_cubit_test.dart
      home_page_test.dart
    post/
      post_list_cubit_test.dart
      post_list_page_test.dart
  goldens/
    home_page_loaded.png
    post_list_page_loaded.png
integration_test/
  app_test.dart
```

## `pubspec.yaml` dev_dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: 5.0.0
  build_runner: 2.4.13
  retrofit_generator: 9.1.5
  json_serializable: 6.8.0
  bloc_test: 9.1.7
  mocktail: 1.0.4
  integration_test:
    sdk: flutter
```

## `test/helpers/fakes.dart`

Reusable fakes shared across tests. Define once, import everywhere.

```dart
import 'package:app/src/core/logging/app_logger.dart';
import 'package:app/src/core/widgets/dialog/app_dialog.dart';
import 'package:flutter/widgets.dart';

class NoopLogger implements AppLogger {
  @override
  void debug(String m, {Object? error, StackTrace? stackTrace}) {}
  @override
  void info(String m, {Object? error, StackTrace? stackTrace}) {}
  @override
  void warn(String m, {Object? error, StackTrace? stackTrace}) {}
  @override
  void error(String m, {Object? error, StackTrace? stackTrace}) {}
}

class FakeDialog implements AppDialog {
  final List<String> calls = [];
  bool confirmResult = true;

  @override
  void showToast(String message, {dynamic position, Duration? displayTime}) =>
      calls.add('toast:$message');

  @override
  void showNotification({required String message, dynamic type, Duration? displayTime}) =>
      calls.add('notify:$message');

  @override
  Future<bool> showConfirm({
    required String title,
    String? message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDangerousAction = false,
  }) async {
    calls.add('confirm:$title');
    return confirmResult;
  }

  @override
  Future<T?> showCustom<T>({
    required Widget Function(BuildContext) builder,
    bool clickMaskDismiss = true,
    bool usePenetrate = false,
    Alignment alignment = Alignment.center,
    String? tag,
  }) async {
    calls.add('custom:${tag ?? 'no-tag'}');
    return null;
  }

  @override
  void showLoading({String? message}) => calls.add('loading:${message ?? ''}');

  @override
  void dismissLoading() => calls.add('dismissLoading');

  @override
  Future<T?> showAttached<T>({
    required BuildContext targetContext,
    required Widget Function(BuildContext) builder,
    Alignment targetAlignment = Alignment.bottomCenter,
    Alignment followerAlignment = Alignment.topCenter,
    bool clickMaskDismiss = true,
    String? tag,
  }) async {
    calls.add('attached:${tag ?? 'no-tag'}');
    return null;
  }

  @override
  void dismissAll() => calls.add('dismissAll');

  @override
  void dismiss({String? tag}) => calls.add('dismiss:${tag ?? ''}');
}
```

## `test/helpers/pump_app.dart`

Wraps widget in `MaterialApp` with theme and DI — avoids boilerplate in every test.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/src/app/theme/app_theme.dart';

extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget widget) async {
    await pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: widget,
      ),
    );
  }

  Future<void> pumpAppAndSettle(Widget widget) async {
    await pumpApp(widget);
    await pumpAndSettle();
  }
}
```

## DI Test Pattern

Every test file that touches DI follows this shape:

```dart
setUp(() async {
  await getIt.reset();               // clean slate
  getIt.registerSingleton<Dep>(fake); // register fakes
  getIt.registerFactory<Cubit>(...);  // register subject
});
```

**Prefer passing fakes directly** to the cubit constructor instead of resolving from `getIt`:

```dart
blocTest<MyCubit, MyState>(
  'description',
  build: () => MyCubit(FakeRepo()),   // no getIt needed
  act: (c) => c.doThing(),
  expect: () => [...],
);
```

Use `getIt` in tests only when testing DI wiring, widget tests with `BlocProvider(create: (_) => getIt<Cubit>())`, or smoke tests that need the full DI graph.

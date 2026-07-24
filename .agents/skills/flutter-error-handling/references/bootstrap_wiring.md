# Bootstrap — Complete Error Wiring

## `app_bootstrap.dart`

```dart
// lib/src/app/bootstrap/app_bootstrap.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../core/analytics/crash_reporter.dart';
import '../../core/config/env.dart';
import '../../core/di/service_locator.dart';
import '../../core/error/error_handler.dart';
import '../../core/error/app_error_widget.dart';
import '../../core/logging/app_logger.dart';

Future<void> bootstrap(Env env) async {
  // 1. Wire DI (registers Logger, CrashReporter, ErrorHandler, etc.)
  await configureDependencies(env);

  // 2. Init crash reporter early — before runApp — so startup crashes are caught.
  final crashReporter = getIt<CrashReporter>();
  await crashReporter.init();

  // 3. Get the centralized error handler.
  final errorHandler = getIt<ErrorHandler>();

  // 4. Flutter framework errors (build, layout, painting).
  FlutterError.onError = errorHandler.handleFlutterError;

  // 5. Platform errors (isolate-level uncaught exceptions).
  PlatformDispatcher.instance.onError = errorHandler.handlePlatformError;

  // 6. Custom error widget for release builds.
  if (kReleaseMode) {
    ErrorWidget.builder = (details) => AppErrorWidget(details: details);
  }
}

/// Entry point that wraps `runApp` in a guarded zone.
/// Call this from `main()` instead of `runApp()` directly.
Future<void> guardedMain(Env env, Widget app) async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await bootstrap(env);
      runApp(app);
    },
    (error, stackTrace) {
      // Zone errors — unawaited futures, timer callbacks, etc.
      // After bootstrap, ErrorHandler is available.
      if (GetIt.I.isRegistered<ErrorHandler>()) {
        getIt<ErrorHandler>().handleZoneError(error, stackTrace);
      } else {
        // Fallback if error happens before DI is ready.
        debugPrint('PRE-DI ZONE ERROR: $error\n$stackTrace');
      }
    },
  );
}
```

## Entry Points

```dart
// lib/main_dev.dart

import 'src/app/app.dart';
import 'src/app/bootstrap/app_bootstrap.dart';
import 'src/core/config/env.dart';

void main() => guardedMain(Env.dev, const App());
```

```dart
// lib/main_prod.dart

import 'src/app/app.dart';
import 'src/app/bootstrap/app_bootstrap.dart';
import 'src/core/config/env.dart';

void main() => guardedMain(Env.prod, const App());
```

## BlocObserver Wiring

```dart
// Add to bootstrap(), after DI is configured:

Bloc.observer = AppBlocObserver(
  logger: getIt<AppLogger>(),
  errorHandler: getIt<ErrorHandler>(),
);
```

## Key Rules

- **Always use `guardedMain()`**: Every `main_*.dart` entry point calls `guardedMain()`, never raw `runApp()`. This ensures the zone guard catches unawaited future errors.
- **Init crash reporter before `runApp`**: Startup crashes must be captured. `CrashReporter.init()` runs inside `bootstrap()`, before `runApp()`.
- **Custom error UI in release only**: Set `ErrorWidget.builder` only when `kReleaseMode` is true. Keep the red error screen in debug for visibility.
- **Pre-DI fallback**: The zone error handler must check `GetIt.I.isRegistered<ErrorHandler>()` before using DI, since errors can occur before DI is ready.

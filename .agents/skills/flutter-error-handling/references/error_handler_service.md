# Error Handler Service — `error_handler.dart`

Centralized error handler. Coordinates logging (local) and crash reporting (remote). Registered as a singleton in DI — all error layers delegate here.

```dart
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../logging/app_logger.dart';
import '../analytics/crash_reporter.dart';

/// Centralized error handler.
/// Coordinates logging (local) and crash reporting (remote).
/// Registered as a singleton in DI — all error layers delegate here.
abstract interface class ErrorHandler {
  /// Handle a caught error with context about where it happened.
  void handleError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
    bool fatal,
  });

  /// Handle a Flutter framework error (widget build, layout, painting).
  void handleFlutterError(FlutterErrorDetails details);

  /// Handle an error from a platform dispatcher (isolate-level).
  bool handlePlatformError(Object error, StackTrace stackTrace);

  /// Handle a zone error (unawaited async gaps).
  void handleZoneError(Object error, StackTrace stackTrace);
}

class ErrorHandlerImpl implements ErrorHandler {
  ErrorHandlerImpl({
    required AppLogger logger,
    required CrashReporter crashReporter,
  })  : _logger = logger,
        _crashReporter = crashReporter;

  final AppLogger _logger;
  final CrashReporter _crashReporter;

  @override
  void handleError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
    bool fatal = false,
  }) {
    final tag = reason ?? 'Unhandled error';

    _logger.error(tag, error: error, stackTrace: stackTrace);
    _crashReporter.recordError(
      error,
      stackTrace,
      reason: tag,
      fatal: fatal,
    );
  }

  @override
  void handleFlutterError(FlutterErrorDetails details) {
    _logger.error(
      'FlutterError',
      error: details.exception,
      stackTrace: details.stack,
    );

    _crashReporter
      ..addBreadcrumb(
        'FlutterError in ${details.library ?? 'unknown'}',
        category: 'flutter',
      )
      ..recordError(
        details.exception,
        details.stack ?? StackTrace.current,
        reason: 'FlutterError.onError: ${details.library}',
        fatal: false,
      );
  }

  @override
  bool handlePlatformError(Object error, StackTrace stackTrace) {
    _logger.error('PlatformDispatcher', error: error, stackTrace: stackTrace);
    _crashReporter.recordError(
      error,
      stackTrace,
      reason: 'PlatformDispatcher.onError',
      fatal: true,
    );
    // Return true = error handled, don't terminate the app.
    return true;
  }

  @override
  void handleZoneError(Object error, StackTrace stackTrace) {
    _logger.error('ZoneError', error: error, stackTrace: stackTrace);
    _crashReporter.recordError(
      error,
      stackTrace,
      reason: 'runZonedGuarded zone error',
      fatal: true,
    );
  }
}
```

## DI Registration

```dart
// lib/src/core/di/service_locator.dart

import '../error/error_handler.dart';
import '../logging/app_logger.dart';
import '../analytics/crash_reporter.dart';

// Inside configureDependencies(Env env):

// Register after Logger and CrashReporter
getIt.registerSingleton<ErrorHandler>(
  ErrorHandlerImpl(
    logger: getIt<AppLogger>(),
    crashReporter: getIt<CrashReporter>(),
  ),
);
```

**Registration order**: Logger → CrashReporter → ErrorHandler → BlocObserver → everything else.

## Key Rules

- `ErrorHandlerImpl` depends on `AppLogger` and `CrashReporter` interfaces, never on concrete packages (wrapper rule).
- Widget build errors are non-fatal (app continues). Zone errors and platform errors are fatal (app may be in an inconsistent state).

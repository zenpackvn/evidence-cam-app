# Error Flow Overview & Folder Structure

## Error Flow Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        Error Sources                            │
├──────────┬──────────┬──────────┬──────────┬────────────────────┤
│  Widget  │  Async   │  Bloc/   │ Platform │  Dart isolate      │
│  build() │  gaps    │  Cubit   │  channel │  (compute, spawn)  │
└────┬─────┴────┬─────┴────┬─────┴────┬─────┴──────┬─────────────┘
     │          │          │          │             │
     ▼          ▼          ▼          ▼             ▼
┌──────────────────────────────────────────────────────────────────┐
│                     Catch Layers (in priority)                   │
│                                                                  │
│  1. try/catch in cubit/repo    → Failure hierarchy               │
│  2. BlocObserver.onError       → log + report                    │
│  3. FlutterError.onError       → render errors (widget build)    │
│  4. PlatformDispatcher.onError → isolate-level uncaught           │
│  5. runZonedGuarded            → async gaps (unawaited futures)  │
└────────────────────┬─────────────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────────────┐
│                   Error Handler Service                          │
│                                                                  │
│  AppLogger.error(...)          → local log (dev console)         │
│  CrashReporter.recordError(…) → remote report (Sentry/Firebase)  │
│  ErrorWidget.builder           → graceful error UI (release)     │
└──────────────────────────────────────────────────────────────────┘
```

## Folder Structure

```
lib/src/
  core/
    error/
      error_handler.dart             ← App-owned error handler service
      error_boundary_widget.dart     ← Widget-level error boundary
      app_error_widget.dart          ← Custom error UI for release builds
    logging/
      app_logger.dart                ← (from template-logging.md)
    analytics/
      crash_reporter.dart            ← (from template-analytics.md)
  app/
    bootstrap/
      app_bootstrap.dart             ← Wires all error layers
```

## Where Each Layer Catches

| Error type | Caught by | Action |
|---|---|---|
| `DioException` | Repository → maps to `Failure` | Cubit emits error state → UI shows message |
| `FailureException` | Cubit `try/catch` | Emits error state with typed `Failure` |
| Widget `build()` throw | `FlutterError.onError` | Log + report + show `AppErrorWidget` (release) |
| Unawaited `Future` throw | `runZonedGuarded` | Log + report |
| Platform channel error | `PlatformDispatcher.onError` | Log + report |
| Bloc/Cubit `addError()` | `BlocObserver.onError` | Log + report |

## Expected vs Unexpected Errors

The typed `Failure` hierarchy from [template-network.md](template-network.md) handles **expected** errors (network, auth, validation). The error boundary system handles **unexpected** errors (widget build crashes, unawaited futures, platform errors).

```
Expected errors (Failure):       Unexpected errors (ErrorHandler):
├── NetworkFailure               ├── Widget build/layout/paint errors
├── TimeoutFailure               ├── Unawaited future exceptions
├── UnauthorizedFailure          ├── Platform channel errors
├── NotFoundFailure              ├── Isolate-level crashes
├── ServerFailure                └── Any uncaught throw
├── CacheFailure
└── ValidationFailure

Caught in: cubit try/catch       Caught in: zone / FlutterError /
Shown as: UI error state                    PlatformDispatcher
```

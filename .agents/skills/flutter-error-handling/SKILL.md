---
name: flutter-error-handling
description: Use this skill when implementing Flutter error handling — ErrorHandler service, zone error guard, FlutterError.onError, PlatformDispatcher.onError, ErrorBoundary widget, global exception handling, unhandled exception catching, crash recovery UI, error boundary, or wiring error handling infrastructure.
---

# Flutter Error Handling

Full reference: [`template.md`](references/template.md)

## Key rules

- `ErrorHandler` is the central service. Wire it to three sources in `appBootstrap()`:
  1. `FlutterError.onError` — Flutter framework errors (layout overflow, widget errors).
  2. `PlatformDispatcher.instance.onError` — platform-level uncaught errors.
  3. `runZonedGuarded` — Dart zone errors (async exceptions not caught elsewhere).
- `ErrorHandler` forwards to `AppLogger.error()` + `CrashReporter.recordError()`.
- `ErrorBoundary` widget wraps subtrees that might throw during build. On error, renders a fallback `AppErrorState`. Place at feature boundaries, not globally.
- In dev/uat: show error details in `ErrorBoundary` fallback. In prod: show generic message only.
- `FailureException` is expected — it represents a known domain error. Do not forward to `CrashReporter`. Log at `warn` level only.
- Unknown exceptions (not `FailureException`) are unexpected — always forward to `CrashReporter`.

## Files

```
lib/src/core/error/
  failure.dart            ← sealed Failure + FailureException
  error_handler.dart      ← interface + impl (wires zone guard, FlutterError, PlatformDispatcher)
  error_boundary.dart     ← widget (wraps subtree, catches build errors)
```

## Co-load with

- `flutter-logging` — `ErrorHandler` calls `AppLogger.error()`
- `flutter-analytics` — forward unexpected errors to `CrashReporter`
- `flutter-di` — `ErrorHandler` registered as singleton, called in bootstrap
- `flutter-flavors` — error detail visibility depends on env

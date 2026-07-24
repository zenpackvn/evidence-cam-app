---
name: flutter-logging
description: Use this skill when working on Flutter logging — AppLogger interface, logger wrapper, debug/info/warn/error log levels, structured logging, LoggerImpl, observability, log output formatting, BlocObserver, routing observer, or integrating logging with crash reporting.
---

# Flutter Logging

Full reference: [`template.md`](references/template.md)

## Key rules

- `AppLogger` is the app-owned interface. **Never import `package:logger/logger.dart`** outside `logger_impl.dart`.
- Four log levels: `debug`, `info`, `warn`, `error`. All accept optional `error` and `stackTrace` params.
- `LoggerImpl` wraps the `logger` package. Configured with `PrettyPrinter` in dev/uat, `SimplePrinter` in prod.
- Logging is enabled based on `AppConfig.enableLogging`. Prod builds log only errors.
- Wire `AppLogger` into `BlocObserver` to log state transitions and errors automatically.
- Route observer (`RouteObserver`) logs page pushes/pops for screen tracking.
- Pass `AppLogger` via constructor injection — never resolve via `getIt` inside business logic.

## `AppBlocObserver` pattern

Set in bootstrap — logs every cubit state change and routes all bloc errors to `ErrorHandler`:

```dart
class AppBlocObserver extends BlocObserver {
  AppBlocObserver({required AppLogger logger, required ErrorHandler errorHandler})
      : _logger = logger, _errorHandler = errorHandler;
  final AppLogger _logger;
  final ErrorHandler _errorHandler;

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    _errorHandler.handleError(error, stackTrace, reason: '${bloc.runtimeType} error');
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    _logger.debug('${bloc.runtimeType}: state → ${change.nextState.runtimeType}');
  }
}
```

Bootstrap wiring:

```dart
Bloc.observer = AppBlocObserver(
  logger: getIt<AppLogger>(),
  errorHandler: getIt<ErrorHandler>(),
);
```

## Route observer

`AppRouteObserver` extends `NavigatorObserver` — logs screen pushes/pops. Wire into GoRouter `observers`:

```dart
final router = GoRouter(
  observers: [AppRouteObserver(logger: getIt<AppLogger>())],
);
```

## Files

```
lib/src/core/logging/
  app_logger.dart          ← interface (debug / info / warn / error)
  logger_impl.dart         ← only file that imports package:logger
lib/src/core/bloc/
  app_bloc_observer.dart   ← logs BLoC state changes + routes errors to ErrorHandler
  app_route_observer.dart  ← logs screen push/pop via NavigatorObserver
```

## Co-load with

- `flutter-di` — register `AppLogger` as singleton
- `flutter-flavors` — `AppConfig.enableLogging` controls verbosity
- `flutter-analytics` — error logs forwarded to crash reporter

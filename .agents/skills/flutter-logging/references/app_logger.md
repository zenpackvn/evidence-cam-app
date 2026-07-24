# Logging — AppLogger Interface and Implementation

Only `logger_impl.dart` imports `package:logger`. Every other file depends on the `AppLogger` interface.

## `lib/src/core/logging/app_logger.dart`

```dart
abstract interface class AppLogger {
  void debug(String message, {Object? error, StackTrace? stackTrace});
  void info(String message, {Object? error, StackTrace? stackTrace});
  void warn(String message, {Object? error, StackTrace? stackTrace});
  void error(String message, {Object? error, StackTrace? stackTrace});
}
```

---

## `lib/src/core/logging/logger_impl.dart`

```dart
import 'package:logger/logger.dart' as pkg;
import 'app_logger.dart';

class LoggerImpl implements AppLogger {
  LoggerImpl({pkg.Logger? delegate})
      : _delegate = delegate ??
            pkg.Logger(
              printer: pkg.PrettyPrinter(
                methodCount: 0,
                errorMethodCount: 5,
                lineLength: 100,
                colors: true,
                printEmojis: false,
              ),
            );

  final pkg.Logger _delegate;

  @override
  void debug(String m, {Object? error, StackTrace? stackTrace}) =>
      _delegate.d(m, error: error, stackTrace: stackTrace);

  @override
  void info(String m, {Object? error, StackTrace? stackTrace}) =>
      _delegate.i(m, error: error, stackTrace: stackTrace);

  @override
  void warn(String m, {Object? error, StackTrace? stackTrace}) =>
      _delegate.w(m, error: error, stackTrace: stackTrace);

  @override
  void error(String m, {Object? error, StackTrace? stackTrace}) =>
      _delegate.e(m, error: error, stackTrace: stackTrace);
}
```

---

## DI registration

```dart
getIt.registerLazySingleton<AppLogger>(LoggerImpl.new);
```

For environment-aware log filtering (verbose in dev, warnings only in prod):

```dart
getIt.registerLazySingleton<AppLogger>(
  () => LoggerImpl(verbose: getIt<AppConfig>().enableLogging),
);
```

Configure `LoggerImpl` to use `pkg.DevelopmentFilter()` when verbose, `pkg.ProductionFilter()` otherwise.

---

## Test fake

```dart
class FakeLogger implements AppLogger {
  @override void debug(String m, {Object? error, StackTrace? stackTrace}) {}
  @override void info(String m, {Object? error, StackTrace? stackTrace}) {}
  @override void warn(String m, {Object? error, StackTrace? stackTrace}) {}
  @override void error(String m, {Object? error, StackTrace? stackTrace}) {}
}
```

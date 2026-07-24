# DI Registration & Bootstrap Integration

## DI registration

Add to `configureDependencies()` in `service_locator.dart`, after Logger and before Network:

```dart
import '../analytics/analytics_service.dart';
import '../analytics/analytics_service_impl.dart';
import '../analytics/analytics_observer.dart';
import '../analytics/crash_reporter.dart';
import '../analytics/crash_reporter_impl.dart';
import '../analytics/no_op_analytics_service.dart';   // if in separate file
import '../analytics/no_op_crash_reporter.dart';       // if in separate file

Future<void> configureDependencies(Env env) async {
  // 1. Config
  final config = AppConfig.fromEnv(env);
  getIt.registerSingleton<AppConfig>(config);

  // 2. Logging
  getIt.registerLazySingleton<AppLogger>(LoggerImpl.new);

  // 3. Analytics — no-op for tests, real for all other envs
  getIt.registerLazySingleton<AnalyticsService>(AnalyticsServiceImpl.new);

  // 4. Crash reporting — no-op for dev, real for uat/prod
  if (config.env.isDev) {
    getIt.registerLazySingleton<CrashReporter>(NoOpCrashReporter.new);
  } else {
    getIt.registerLazySingleton<CrashReporter>(CrashReporterImpl.new);
  }

  // 5. Analytics observer (used by GoRouter)
  getIt.registerLazySingleton<AnalyticsObserver>(
    () => AnalyticsObserver(analyticsService: getIt<AnalyticsService>()),
  );

  // 6. Storage ...
  // 7. Network ...
  // 8. Feature modules ...
}
```

### Registration order

| Order | Registration | Lifetime |
|-------|-------------|----------|
| 1 | `AppConfig` | singleton |
| 2 | `AppLogger` | lazy singleton |
| 3 | `AnalyticsService` | lazy singleton |
| 4 | `CrashReporter` | lazy singleton |
| 5 | `AnalyticsObserver` | lazy singleton |
| 6 | Storage | lazy singleton |
| 7 | Network (interceptors, Dio, ApiClient) | lazy singleton |
| 8 | Feature modules | lazy singletons + factories |

---

## Bootstrap integration — `lib/src/app/bootstrap/app_bootstrap.dart`

Init crash reporting **before** `runApp` so startup crashes are caught:

```dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../../core/analytics/analytics_bloc_observer.dart';
import '../../core/analytics/analytics_service.dart';
import '../../core/analytics/crash_reporter.dart';
import '../../core/config/app_config.dart';
import '../../core/config/env.dart';
import '../../core/di/service_locator.dart';
import '../../core/logging/app_logger.dart';

Future<void> bootstrap(Env env) async {
  // 1. Wire DI (registers AppConfig, Logger, Analytics, CrashReporter, etc.)
  await configureDependencies(env);

  // 2. Init crash reporter early — before runApp — so startup crashes are caught.
  final crashReporter = getIt<CrashReporter>();
  await crashReporter.init();

  // 3. Localization
  await FlutterLocalization.instance.ensureInitialized();

  final logger = getIt<AppLogger>();

  // 4. Global Flutter error handler — logs AND reports.
  FlutterError.onError = (details) {
    logger.error(
      'FlutterError',
      error: details.exception,
      stackTrace: details.stack,
    );
    crashReporter.recordError(
      details.exception,
      details.stack ?? StackTrace.current,
      fatal: false,
      reason: 'FlutterError.onError',
    );
  };

  // 5. Platform errors (isolate-level).
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.error('PlatformDispatcher', error: error, stackTrace: stack);
    crashReporter.recordError(
      error,
      stack,
      fatal: true,
      reason: 'PlatformDispatcher.onError',
    );
    return true;
  };

  // 6. Optional: Bloc observer for dev/debug builds.
  final config = getIt<AppConfig>();
  if (!config.isProduction) {
    Bloc.observer = AnalyticsBlocObserver(
      analyticsService: getIt<AnalyticsService>(),
      logger: logger,
    );
  }
}
```

---

## No-op implementations

### `NoOpAnalyticsService`

```dart
/// No-op analytics for tests and dev builds where tracking is disabled.
class NoOpAnalyticsService implements AnalyticsService {
  @override
  Future<void> trackEvent(String name, {Map<String, Object>? params}) async {}

  @override
  Future<void> trackScreen(String name, {Map<String, Object>? params}) async {}

  @override
  Future<void> setUserId(String? id) async {}

  @override
  Future<void> setUserProperty({
    required String key,
    required String value,
  }) async {}

  @override
  Future<void> reset() async {}
}
```

### `NoOpCrashReporter`

```dart
/// No-op crash reporter for dev builds where Crashlytics is disabled.
class NoOpCrashReporter implements CrashReporter {
  const NoOpCrashReporter();

  @override
  Future<void> init() async {}

  @override
  void recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
    String? reason,
  }) {}

  @override
  void addBreadcrumb(String message, {String? category}) {}

  @override
  void setUserId(String? userId) {}
}
```

Place both in the same `analytics/` folder alongside their interfaces. They have no third-party imports.

---

## Conditional initialization summary

| Environment | AnalyticsService | CrashReporter |
|-------------|-----------------|---------------|
| `dev` | `AnalyticsServiceImpl` (tracks to Firebase debug) | `NoOpCrashReporter` |
| `uat` | `AnalyticsServiceImpl` | `CrashReporterImpl` (Crashlytics) |
| `prod` | `AnalyticsServiceImpl` | `CrashReporterImpl` (Crashlytics) |
| Tests | `FakeAnalyticsService` or `NoOpAnalyticsService` | `FakeCrashReporter` or `NoOpCrashReporter` |

# Logging — Rules and Anti-Patterns

## Rules

1. **Never import `package:logger` directly outside `logger_impl.dart`.** All other files depend on the `AppLogger` interface only.
2. **Register `AppLogger` as a lazy singleton in the composition root.** See the DI template for registration order and lifetime rules.
3. **Filter log levels per environment:** verbose in dev, warning+ in prod. Wire this through `AppConfig.enableLogging` from the flavors template.
4. **Use `AppLogger` in interceptors, cubits, and services — never `print()` or `debugPrint()`.** Unstructured console output is a defect in production code.
5. **Feed logger output to CrashReporter breadcrumbs** when crash reporting is enabled. See the analytics template for `CrashReporter` integration.
6. **Keep log messages structured** (include context like `userId`, `screen`, `action`) **but never log PII** (tokens, passwords, emails, phone numbers).

## Observability Patterns

- Centralize analytics and crash reporting behind focused service interfaces, wrapped and DI-registered the same way.
- Prefer structured logs with context over ad hoc `print`. `print()` in production code is a defect.
- Record non-fatal errors with enough context to debug, but avoid sensitive payloads and secrets.
- Keep analytics event names stable and defined near the product boundary — not raw strings scattered through widgets.
- Add breadcrumbs or tracing around critical flows (auth, checkout, upload, sync) when using an observability platform.

---

## Anti-Patterns

### 1. Using print() or debugPrint() directly instead of AppLogger

```dart
// DON'T — unstructured, no log levels, impossible to filter or route to crash reporting
print('fetching user profile...');
debugPrint('Error: $e');

// DO — use AppLogger for structured, level-aware logging
logger.info('Fetching user profile');
logger.error('Profile fetch failed', error: e, stackTrace: s);
```

### 2. Logging sensitive user data (tokens, passwords, PII)

```dart
// DON'T — tokens and PII in logs end up in crash reports and log aggregators
logger.info('Login with token=$token, email=$email, password=$password');

// DO — log event context without sensitive payloads
logger.info('Login succeeded for userId=${user.id}');
logger.warn('Token refresh failed', error: e, stackTrace: s);
```

### 3. Not filtering log levels per environment

```dart
// DON'T — verbose debug logs ship to production (noise and potential data leak)

// DO — configure log level based on EnvConfig
LoggerImpl({
  pkg.Logger? delegate,
  bool verbose = true,
}) : _delegate = delegate ??
         pkg.Logger(
           filter: verbose ? pkg.DevelopmentFilter() : pkg.ProductionFilter(),
         );

// In DI:
getIt.registerLazySingleton<AppLogger>(
  () => LoggerImpl(verbose: getIt<AppConfig>().enableLogging),
);
```

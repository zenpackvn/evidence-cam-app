# Phase 1: Foundation (4–6 PRs)

## PR 1.1 — Create the composition root

Create `lib/src/core/di/service_locator.dart` even if you already use `get_it`. The goal is a single file where all registrations live.

**Before** (scattered):

```dart
// lib/main.dart
void main() {
  GetIt.I.registerSingleton(AuthService());
  GetIt.I.registerSingleton(Logger());
  runApp(const App());
}

// lib/features/posts/post_module.dart
void registerPostDeps() {
  GetIt.I.registerFactory(() => PostCubit(GetIt.I()));
}
```

**After** (centralized):

```dart
// lib/src/core/di/service_locator.dart
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies(Env env) async {
  // ── 1. Config ──
  // (will be filled as we migrate)

  // ── 2. Infrastructure ──
  // Logger, network, storage — migrated in later PRs

  // ── 3. Repositories ──

  // ── 4. Features ──
  // Move existing registrations here

  // TEMPORARY: existing registrations moved from scattered locations
  getIt.registerSingleton(AuthService());
  getIt.registerSingleton(Logger());
  getIt.registerFactory(() => PostCubit(getIt()));
}
```

```dart
// lib/main.dart
import 'src/core/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies(Env.dev);
  runApp(const App());
}
```

**Verify**: `flutter analyze` + `flutter test`. No behavior change — just moved registrations.

---

## PR 1.2 — Wrap the logger

Logger is usually the safest first wrap because it has no return values that affect logic.

**Step 1**: Create the interface.

```dart
// lib/src/core/logging/app_logger.dart

abstract interface class AppLogger {
  void debug(String message, {Object? error, StackTrace? stackTrace});
  void info(String message, {Object? error, StackTrace? stackTrace});
  void warning(String message, {Object? error, StackTrace? stackTrace});
  void error(String message, {Object? error, StackTrace? stackTrace});
}
```

**Step 2**: Create the implementation wrapping your existing logger.

```dart
// lib/src/core/logging/logger_impl.dart

import 'package:logger/logger.dart' as pkg;
import 'app_logger.dart';

class LoggerImpl implements AppLogger {
  final _logger = pkg.Logger(/* your existing config */);

  @override
  void debug(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.d(message, error: error, stackTrace: stackTrace);

  @override
  void info(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.i(message, error: error, stackTrace: stackTrace);

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.w(message, error: error, stackTrace: stackTrace);

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
```

**Step 3**: Register in the composition root.

```dart
// In configureDependencies():
getIt.registerLazySingleton<AppLogger>(LoggerImpl.new);
```

**Step 4**: Find-and-replace all logger usage.

```dart
// Before (12 files):
import 'package:logger/logger.dart';
final _logger = Logger();
_logger.d('Loading posts');

// After:
import '../../core/logging/app_logger.dart';
// Injected via constructor:
final AppLogger _logger;
_logger.debug('Loading posts');
```

**Verify**: `flutter analyze` + `flutter test`. Grep for `package:logger` — should only appear in `logger_impl.dart`.

---

## PR 1.3 — Wrap HTTP / networking

Usually the second-biggest blast radius.

```dart
// Before: 14 files import package:dio directly
import 'package:dio/dio.dart';
final response = await Dio().get('/posts');

// After: only DioClient wrapper imports Dio
// See template-network.md for full DioClient, ApiClient, Failure hierarchy
```

Follow [template-network.md](template-network.md) for the full pattern. The key steps:

1. Create `Failure` sealed hierarchy.
2. Create `DioClient` wrapper (the only file that imports `package:dio`).
3. Create `ApiClient` interface + Retrofit implementation.
4. Register in composition root.
5. Update repositories to accept `ApiClient` via constructor injection.
6. Remove all direct `Dio()` usage.

---

## PR 1.4 — Wrap storage

```dart
// Before: SharedPreferences.getInstance() called everywhere
final prefs = await SharedPreferences.getInstance();
prefs.setString('key', value);

// After: KeyValueStore interface, SharedPreferencesStore impl
// See template-storage.md for full pattern
```

---

## PR 1.5 — Wrap remaining infrastructure

One PR per package, in order of import count:
- Analytics (`package:firebase_analytics`)
- Crash reporting (`package:sentry_flutter`)
- Secure storage (`package:flutter_secure_storage`)
- Any other widely-imported package

---

## Foundation Checkpoint

After Phase 1, run the audit commands again:

```bash
# Should return ZERO results outside *_impl.dart files:
grep -r "^import 'package:dio" lib/src/ | grep -v "_impl.dart"
grep -r "^import 'package:logger" lib/src/ | grep -v "_impl.dart"
grep -r "^import 'package:shared_preferences" lib/src/ | grep -v "_impl.dart"

# All registrations should be in core/di/ or features/*/di/:
grep -rn "register\(Singleton\|Factory\|LazySingleton\)" lib/ \
  | grep -v "core/di/" | grep -v "features/.*/di/"
```

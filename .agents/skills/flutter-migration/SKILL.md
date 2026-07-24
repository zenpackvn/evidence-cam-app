---
name: flutter-migration
description: Use this skill when adopting the flutter-app-builder architecture in an existing Flutter app — migration audit, phased wrapping, centralizing DI, wrapping third-party dependencies, feature-by-feature migration, legacy code migration, brownfield app, introducing clean architecture to an existing project, or verifying migration compliance.
---

# Flutter Migration

Full reference: [`template.md`](references/template.md)

## Key rules

- **Audit first**: run `grep -r "import 'package:" lib/` — every direct third-party import outside a wrapper is a violation to fix.
- **Wrapper rule**: each third-party package gets one `*_impl.dart` wrapper. All app code imports the interface, not the package.
- **Phase 1 — DI centralization**: introduce `service_locator.dart` and register existing singletons there. Don't change behavior yet.
- **Phase 2 — Wrap dependencies**: wrap logging, networking, storage, analytics one-by-one. Each wrapper is independently testable.
- **Phase 3 — Feature migration**: migrate one feature at a time to clean architecture (entity → use case → cubit → page). Don't big-bang rewrite.
- **Verification script**: `scripts/check_wrapper_rule.sh` — run after each phase. Checks: (1) no direct third-party imports outside `*_impl.dart`, (2) no DI registrations outside `core/di/` or `features/*/di/`, (3) no `getIt<T>()` calls outside composition boundaries. Target ≥ 85% before next phase.
- Keep old code paths alive during transition — use feature flags to switch between old and new implementations.
- Never break tests during migration — existing tests are a safety net, not a migration blocker.
- **State management agnostic**: wrapper rule works with BLoC, Riverpod, or Provider. Don't switch state management during migration — wrap dependencies first, change state management later (if ever).

## Quick-start checklist

```markdown
- [ ] Phase 0: Run audit (`grep -r "import 'package:" lib/`) — document all violations
- [ ] Phase 1 PR1: Create `service_locator.dart` — move all scattered registrations
- [ ] Phase 1 PR2: Wrap logger — `AppLogger` interface + `LoggerImpl`
- [ ] Phase 1 PR3: Wrap HTTP — `DioClient` + `ApiClient` interface
- [ ] Phase 1 PR4: Wrap storage — `KeyValueStore` + `SecureStorage` interfaces
- [ ] Phase 1: Run `check_wrapper_rule.sh` — verify ≥ 85% compliance
- [ ] Phase 2: Migrate features one-by-one (simplest first, auth last)
- [ ] Phase 3: Add `ErrorHandler` + zone guard + test fakes + coverage baseline
- [ ] Add `check_wrapper_rule.sh` to CI — prevent regression
```

## Migration order

1. Logging → Analytics → Error handling (low risk, pure add)
2. Network (Dio client) → Auth (token refresh)
3. Storage (secure + key-value + database)
4. Feature cubits + use cases (highest ROI for testability)
5. Routing (last — most disruptive)

## Before / after per phase

**Phase 1 — DI centralization:**

```dart
// BEFORE: scattered registrations
// lib/main.dart
GetIt.I.registerSingleton(AuthService());
// lib/features/posts/post_module.dart
GetIt.I.registerFactory(() => PostCubit(GetIt.I()));

// AFTER: one composition root
// lib/src/core/di/service_locator.dart
Future<void> configureDependencies(Env env) async {
  getIt
    ..registerSingleton(AuthService())
    ..registerFactory(() => PostCubit(getIt()));
}
```

**Phase 2 — Wrap a dependency:**

```dart
// BEFORE: 14 files import package:dio directly
import 'package:dio/dio.dart';
final response = await Dio().get('/posts');

// AFTER: only DioClient wrapper imports Dio
import '../core/network/api_client.dart';
final posts = await _apiClient.getPosts(page: 1);
```

**Phase 3 — Feature migration:**

```dart
// BEFORE: cubit uses getIt in constructor body
class PostCubit extends Cubit<PostState> {
  PostCubit() : super(const PostInitial()) {
    _repo = getIt<PostRepository>(); // violation
  }
}

// AFTER: constructor injection + use case
class PostListCubit extends BaseCubit<PostListState> {
  PostListCubit({required GetPostsUseCase getPostsUseCase, required super.logger})
      : _getPostsUseCase = getPostsUseCase;
}
```

## Verification script

```bash
#!/bin/bash
# scripts/check_wrapper_rule.sh — run after each PR

# 1. Check no direct third-party imports outside *_impl.dart
WRAPPED=("package:dio" "package:logger" "package:shared_preferences"
         "package:flutter_secure_storage" "package:firebase_analytics"
         "package:sentry_flutter" "package:permission_handler")
for pkg in "${WRAPPED[@]}"; do
  grep -rn "import '$pkg" lib/src/ | grep -v "_impl.dart" | grep -v "core/di/"
done

# 2. Check all registrations in core/di/ or features/*/di/
grep -rn "register.*Singleton\|registerFactory" lib/ \
  | grep -v "core/di/" | grep -v "features/.*/di/" | grep -v "_test.dart"

# 3. Check no getIt<T>() in cubits, repositories, or widgets
grep -rn "getIt<" lib/src/ \
  | grep -v "core/di/" | grep -v "features/.*/di/" | grep -v "BlocProvider"
```

Full script with 15+ packages in [template.md](references/template.md). Add to CI after Phase 1.

## Riverpod / Provider compatibility

The wrapper rule is DI-framework agnostic:

```dart
// Riverpod — same interface + impl, different wiring
final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepositoryImpl(apiClient: ref.read(apiClientProvider));
});

// Provider — same principle
MultiProvider(providers: [
  Provider<PostRepository>(create: (_) => PostRepositoryImpl(apiClient: getIt())),
]);
```

Don't adopt `get_it` unless you want to. Wrap dependencies around your existing state management.

## Files

```
lib/
  src/
    core/
      di/
        service_locator.dart   ← introduce first
      logging/
        app_logger.dart        ← wrap existing logger
      network/
        dio_client.dart        ← wrap existing http calls
scripts/
  verify_migration.sh          ← wrapper-rule + DI compliance check
```

## Co-load with

- `flutter-di` — composition-root rule is the migration target
- `flutter-architecture` — clean layers to migrate toward
- `flutter-base-classes` — BaseCubit, BaseRepository for migrated features
- `flutter-error-handling` — Phase 3: add ErrorHandler, zone guard, AppErrorWidget
- `flutter-tests` — Phase 3: test fakes for all wrapped services + coverage baseline

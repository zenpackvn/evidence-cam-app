---
name: flutter-di
description: Use this skill when working on Flutter dependency injection — get_it, service_locator.dart, registering dependencies, singleton vs factory vs lazySingleton, wrapper rule (no direct third-party imports outside wrapper files), composition root, feature DI modules, injection order, test overrides, or wiring any service, repository, cubit, use case, or data source into the DI graph.
---

# Flutter DI

Full reference: [`template.md`](references/template.md)

## Key rules

### Wrapper rule (non-negotiable)
Every third-party package is wrapped behind an **app-owned interface**. The interface lives in `core/`. The implementation (`*_impl.dart`) is the **only** file that imports the third-party package. Everything else depends on the interface.

```
core/logging/app_logger.dart          ← interface
core/logging/logger_impl.dart         ← only file that imports `package:logger/logger.dart`
```

### Composition-root rule
`getIt` registrations happen **only** in:
- `lib/src/core/di/service_locator.dart` (app-level)
- `lib/src/features/<feature>/di/<feature>_module.dart` (feature-level)

Never call `getIt.register*` inside a widget, page, cubit, or repository.

### Registration order (service_locator.dart)
1. Config (`AppConfig`)
2. Logging (`AppLogger`)
3. Storage (`SecureStorage`, `KeyValueStore`)
4. Network (`DioClient`, `ApiClient`)
5. Database (`AppDatabase`, DAOs)
6. Core services (Auth, Connectivity, Sync, Push, Permissions, Analytics…)
7. Repositories
8. Use cases
9. Cubits / BLoCs (`registerFactory` — never singleton)
10. Theme + Localization

### Lifetimes
- `registerLazySingleton` — services, repositories, data sources, API clients
- `registerFactory` — cubits, BLoCs (new instance per page)
- `registerSingleton` — early-init objects (logger, config)

### Test override
```dart
getIt.allowReassignment = true;
getIt.registerSingleton<MyService>(FakeMyService());
```

## Co-load with
- Every other skill (DI binds to every file written)

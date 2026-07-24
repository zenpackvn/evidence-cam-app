# The Two Rules

## Rule 1 — Wrap every third-party boundary

Every third-party library that crosses the app boundary is hidden behind an **app-owned interface**. The concrete third-party call sits in exactly one implementation class, which is the only file allowed to `import` the third-party package.

Apply to (non-exhaustive):

- `logger` — `AppLogger` + `LoggerImpl` (see [template-logging.md](template-logging.md))
- `dio` — `DioClient` wrapper (see [template-network.md](template-network.md))
- `flutter_secure_storage` — `SecureStorage` + `SecureStorageImpl` (see [template-storage.md](template-storage.md))
- `shared_preferences` — `KeyValueStore` + `SharedPreferencesStore` (see [template-storage.md](template-storage.md))
- `firebase_messaging` — `PushNotificationService` interface
- `firebase_crashlytics` / `sentry_flutter` — `CrashReporter` interface
- `firebase_analytics` / `mixpanel_flutter` — `AnalyticsService` interface
- `image_picker`, `file_picker`, `permission_handler`, `connectivity_plus`, `device_info_plus`, `package_info_plus` — each gets an app-owned service interface

Why: swap, fake in tests, prevent transitive API leaks, keep domain vocabulary clean, make upgrades a one-file change.

**Enforcement signal:** grep the repo for `import 'package:logger/` or `import 'package:dio/` outside `lib/src/core/**`. Any match is a defect.

## Rule 2 — One composition root

All `getIt.register...` calls live under `lib/src/core/di/`:

- `lib/src/core/di/service_locator.dart` — exposes `final getIt = GetIt.instance;` and `Future<void> configureDependencies(Env env)`.
- `lib/src/core/di/modules/` — optional per-concern module files (`network_module.dart`, `storage_module.dart`, etc.) called from `configureDependencies()`.
- `lib/src/features/<feature>/di/<feature>_module.dart` — optional per-feature module called from `configureDependencies()` once, never from the feature itself.

Consumers access DI **only** at composition boundaries:

- `MaterialApp` setup in `app.dart`.
- `GoRouter` route builders.
- `BlocProvider(create: (_) => getIt<FooCubit>())` at route/page entry.

**Forbidden:**

- `getIt<T>()` inside a widget `build()` body (except the `BlocProvider.create` idiom above).
- `getIt<T>()` inside any bloc, cubit, use case, repository, or data source.
- `GetIt.I.register...` outside `lib/src/core/di/` or `lib/src/features/<feature>/di/`.

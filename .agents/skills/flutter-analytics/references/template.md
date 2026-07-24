# Template — Analytics & Crash Reporting

Event tracking, screen tracking, and crash reporting — all wrapped behind app-owned interfaces. Only `analytics_service_impl.dart` imports `package:firebase_analytics`. Only `crash_reporter_impl.dart` imports `package:firebase_crashlytics`. The wrapper rule applies.

## Reference Files

Load only the file(s) relevant to the task.

| Topic | File |
|---|---|
| `AnalyticsService` interface, `AnalyticsServiceImpl` (Firebase), usage, anti-patterns | [analytics_service.md](analytics_service.md) |
| `CrashReporter` interface, `CrashReporterImpl` (Crashlytics), usage in catch/BlocListener | [crash_reporter.md](crash_reporter.md) |
| `AnalyticsObserver` (auto screen tracking), `AnalyticsBlocObserver`, GoRouter wiring | [observers.md](observers.md) |
| DI registration order, bootstrap integration, no-op implementations, env matrix | [di_and_bootstrap.md](di_and_bootstrap.md) |
| `FakeAnalyticsService`, `FakeCrashReporter`, test setup with `getIt.reset()` | [test_fakes.md](test_fakes.md) |

---

## ⚠️ Common Mistakes

> These are the most frequent analytics & crash reporting bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **Direct Firebase Analytics import in a feature file** | Grep finds `import 'package:firebase_analytics'` outside `analytics_service_impl.dart`; wrapper rule violated | Move all Firebase calls into `analytics_service_impl.dart`; inject `AnalyticsService` via constructor everywhere else |
| 2 | **Direct Crashlytics import in a feature file** | Grep finds `import 'package:firebase_crashlytics'` outside `crash_reporter_impl.dart`; wrapper rule violated | Move all Crashlytics calls into `crash_reporter_impl.dart`; inject `CrashReporter` via DI |
| 3 | **`CrashReporter.init()` called after `runApp`** | Startup crashes (before first frame) are silently swallowed and never appear in Crashlytics | Call `await crashReporter.init()` inside `bootstrap()`, before `runApp()`, and wire `FlutterError.onError` + `PlatformDispatcher.instance.onError` immediately after |
| 4 | **User identity not cleared on logout** | Events after logout are attributed to the previous user's ID; analytics data is polluted | Call `await analyticsService.reset()` and `crashReporter.setUserId(null)` together in the logout flow |
| 5 | **PII in analytics event parameters** | Email, phone, or password data sent to Firebase; GDPR / App Store policy violation | Pass only opaque user IDs via `setUserId()`; use `auth_method`, `referral_source`, and other non-identifying attributes in `trackEvent()` params |
| 6 | **Manual `trackScreen()` call in every page** | Screens are missed or double-tracked when pages are refactored; inconsistent coverage | Wire `AnalyticsObserver` into `GoRouter(observers: [getIt<AnalyticsObserver>()])` for automatic tracking; use manual `trackScreen()` only for tab switches that do not push a route |
| 7 | **`CrashReporterImpl` registered in dev builds** | Crashlytics fills the dev project with noise; dev errors obscure real production crashes | Register `NoOpCrashReporter` for `Env.dev` and `CrashReporterImpl` for `Env.uat` / `Env.prod` via the env-conditional block in `configureDependencies()` |
| 8 | **`AnalyticsBlocObserver` enabled in production** | Every bloc transition is sent as an analytics event; cardinality explodes and Firebase quota is hit | Guard with `if (!config.isProduction) Bloc.observer = AnalyticsBlocObserver(...)` in bootstrap |

---

## Quick Summary

- **Wrapper rule** — only `analytics_service_impl.dart` imports `package:firebase_analytics`; only `crash_reporter_impl.dart` imports `package:firebase_crashlytics`. Grep any other import as a defect.
- **Init `CrashReporter` before `runApp`** — wire `FlutterError.onError` and `PlatformDispatcher.instance.onError` in bootstrap so startup crashes are caught.
- **Set user identity on login, clear on logout** — update both `AnalyticsService` and `CrashReporter` together.
- **Wire `AnalyticsObserver` into GoRouter** — automatic screen tracking with zero per-page code; use manual `trackScreen()` only for tab switches and non-route screens.
- **Never log PII** — no passwords, tokens, or full emails in analytics or crash reports; use opaque user IDs only.
- **Use breadcrumbs for debugging context** — not as analytics events; breadcrumbs are cheap, event volume has cardinality costs.
- **Disable Crashlytics in dev** — register `NoOpCrashReporter` for dev builds; use `FakeCrashReporter` or `NoOpAnalyticsService` in tests.

## Cross-references

- [flutter-di](../../flutter-di/references/template.md) — `AnalyticsService` and `CrashReporter` registered as singletons in `configureDependencies()`; wrapper rule and composition-root rule apply
- [flutter-logging](../../flutter-logging/references/template.md) — `AppLogger.error()` called alongside `CrashReporter.recordError()` in error handlers and catch blocks
- [flutter-flavors](../../flutter-flavors/references/template.md) — `NoOpCrashReporter` and `NoOpAnalyticsService` registered for `Env.dev`; real impls registered for `Env.uat`/`Env.prod`
- [flutter-routing](../../flutter-routing/references/template.md) — `AnalyticsObserver` wired into `GoRouter(observers: [...])` for automatic screen tracking

---
name: flutter-analytics
description: Use this skill when integrating Flutter analytics or crash reporting — AnalyticsService, CrashReporter, Firebase Analytics, Sentry, event tracking, screen tracking, user properties, crash reporting, error logging to crash reporter, automatic BLoC state tracking, automatic route tracking, or any observability/monitoring feature.
---

# Flutter Analytics

Full reference: [`template.md`](references/template.md)

## Key rules

- Two interfaces: `AnalyticsService` (events, screen views, user properties) and `CrashReporter` (exceptions, breadcrumbs).
- **Never import** `firebase_analytics`, `firebase_crashlytics`, or `sentry_flutter` outside their `*_impl.dart` files.
- Auto screen tracking: wire a `NavigatorObserver` (or GoRouter `observers`) that calls `analyticsService.trackScreen()` on route change.
- Auto state tracking: in `AppBlocObserver.onTransition()`, call `analyticsService.trackEvent('state_change', ...)`.
- Forward `AppBlocObserver.onError()` to `crashReporter.recordError()`.
- Enable analytics in prod only — guard with `AppConfig.env.isProd` (or enable in uat for QA).
- Call `analyticsService.setUserId(id)` when the user's identity becomes available (e.g., after profile fetch). Call `analyticsService.reset()` on logout — this clears user ID, properties, and session.

## `AnalyticsService` interface

```dart
abstract interface class AnalyticsService {
  Future<void> trackEvent(String name, {Map<String, Object>? params});
  Future<void> trackScreen(String name, {Map<String, Object>? params});
  Future<void> setUserId(String? id);
  Future<void> setUserProperty({required String key, required String value});
  Future<void> reset();
}
```

## Lifecycle wiring pattern

```dart
// In AuthCubit — called when auth status changes
case AuthStatus.authenticated:
  analyticsService.trackEvent('user_signed_in');
  // setUserId called separately from ProfileCubit once user data is loaded

case AuthStatus.unauthenticated:
  analyticsService.reset(); // clears userId + properties

// In feature cubits — after key user actions
analyticsService.trackEvent('task_created', params: {'title': title});
```

## Files

```
lib/src/core/analytics/
  analytics_service.dart         ← interface (trackEvent, trackScreen, setUserId, setUserProperty, reset)
  analytics_service_impl.dart    ← Firebase Analytics impl
  crash_reporter.dart            ← interface (recordError, addBreadcrumb)
  crash_reporter_impl.dart       ← Firebase Crashlytics impl
```

## Co-load with

- `flutter-di` — register both services as singletons
- `flutter-logging` — errors also go to `AppLogger.error()`
- `flutter-flavors` — enable/disable per environment

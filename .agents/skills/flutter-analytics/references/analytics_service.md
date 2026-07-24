# AnalyticsService — Interface & Firebase Implementation

App-owned analytics interface with Firebase Analytics implementation. Only `analytics_service_impl.dart` imports the third-party package.

## Folder structure

```text
lib/src/core/
  analytics/
    analytics_service.dart           <- App-owned analytics interface
    analytics_service_impl.dart      <- Wraps Firebase Analytics (only import)
    crash_reporter.dart              <- App-owned crash reporting interface
    crash_reporter_impl.dart         <- Wraps Firebase Crashlytics (only import)
    analytics_observer.dart          <- NavigatorObserver for auto screen tracking
    analytics_bloc_observer.dart     <- BlocObserver for auto state tracking
```

## pubspec.yaml additions

```yaml
dependencies:
  firebase_analytics: 11.4.0
  firebase_core: 3.8.0
  firebase_crashlytics: 5.2.0
```

---

## `lib/src/core/analytics/analytics_service.dart`

```dart
/// App-owned analytics interface.
///
/// Only [AnalyticsServiceImpl] imports the analytics package.
/// All feature code depends on this interface via DI.
abstract interface class AnalyticsService {
  /// Track a named event with optional parameters.
  Future<void> trackEvent(String name, {Map<String, Object>? params});

  /// Track a screen view. Prefer [AnalyticsObserver] for automatic tracking;
  /// use this for screens that don't correspond to a route push.
  Future<void> trackScreen(String name, {Map<String, Object>? params});

  /// Associate all future events with a user. Call on login.
  Future<void> setUserId(String? id);

  /// Attach a custom property to the user profile.
  Future<void> setUserProperty({required String key, required String value});

  /// Clear user identity and properties. Call on logout.
  Future<void> reset();
}
```

## `lib/src/core/analytics/analytics_service_impl.dart`

```dart
import 'package:firebase_analytics/firebase_analytics.dart' as pkg;

import 'analytics_service.dart';

/// Firebase Analytics implementation. The only file that imports
/// `package:firebase_analytics`.
class AnalyticsServiceImpl implements AnalyticsService {
  AnalyticsServiceImpl({pkg.FirebaseAnalytics? delegate})
      : _delegate = delegate ?? pkg.FirebaseAnalytics.instance;

  final pkg.FirebaseAnalytics _delegate;

  @override
  Future<void> trackEvent(
    String name, {
    Map<String, Object>? params,
  }) =>
      _delegate.logEvent(name: name, parameters: params);

  @override
  Future<void> trackScreen(
    String name, {
    Map<String, Object>? params,
  }) =>
      _delegate.logScreenView(
        screenName: name,
        parameters: params,
      );

  @override
  Future<void> setUserId(String? id) => _delegate.setUserId(id: id);

  @override
  Future<void> setUserProperty({
    required String key,
    required String value,
  }) =>
      _delegate.setUserProperty(name: key, value: value);

  @override
  Future<void> reset() async {
    await _delegate.setUserId(id: null);
    await _delegate.resetAnalyticsData();
  }
}
```

---

## Usage in feature code

### Track event

```dart
// Inside a repository, use case, or cubit (injected via constructor):
await analyticsService.trackEvent(
  'post_liked',
  params: {'post_id': '42'},
);

// At a composition boundary (route builder, BlocProvider.create):
getIt<AnalyticsService>().trackEvent('post_liked', params: {'post_id': '42'});
```

### Track screen manually

```dart
// For screens that aren't triggered by a route push (e.g. tab switches):
getIt<AnalyticsService>().trackScreen('post_detail');
```

### Set user on login / clear on logout

```dart
// On login success
final user = authResult.user;
await getIt<AnalyticsService>().setUserId(user.id);
getIt<CrashReporter>().setUserId(user.id);  // sync — no await needed

// On logout
await getIt<AnalyticsService>().reset();
getIt<CrashReporter>().setUserId(null);  // pass null to clear
```

---

## Anti-patterns

### DON'T — Import Firebase Analytics directly in features

```dart
// BAD: direct Firebase import in a feature file
import 'package:firebase_analytics/firebase_analytics.dart';

class PostRepository {
  Future<void> likePost(String id) async {
    await _api.likePost(id);
    await FirebaseAnalytics.instance.logEvent(
      name: 'post_liked',
      parameters: {'post_id': id},
    );
  }
}
```

### DO — Depend on the app-owned interface via DI

```dart
// GOOD: feature depends on app-owned interface
class PostRepository {
  PostRepository(this._api, this._analytics);
  final ApiClient _api;
  final AnalyticsService _analytics;

  Future<void> likePost(String id) async {
    await _api.likePost(id);
    await _analytics.trackEvent('post_liked', params: {'post_id': id});
  }
}
```

### DON'T — Log PII in analytics events

```dart
// BAD: PII in analytics event parameters
await analyticsService.trackEvent(
  'user_signed_up',
  params: {
    'email': user.email,           // PII
    'phone': user.phoneNumber,     // PII
    'password_length': '${user.password.length}', // sensitive
  },
);
```

### DO — Track only anonymised identifiers

```dart
// GOOD: no PII — use opaque IDs and safe attributes
await analyticsService.trackEvent(
  'user_signed_up',
  params: {
    'auth_method': 'email',
    'referral_source': user.referralSource,
  },
);
// Associate user identity separately via setUserId (opaque ID only)
await analyticsService.setUserId(user.id);
```

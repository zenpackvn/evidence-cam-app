# CrashReporter — Interface & Firebase Crashlytics Implementation

App-owned crash reporting interface with Firebase Crashlytics implementation. Only `crash_reporter_impl.dart` imports the third-party package.

## `lib/src/core/analytics/crash_reporter.dart`

```dart
/// App-owned crash reporting interface.
///
/// Only [CrashReporterImpl] imports the crash reporting package.
/// All feature code depends on this interface via DI.
///
/// [recordError] and [addBreadcrumb] are sync — implementations use
/// `unawaited()` internally so callers don't need to await crash reporting.
abstract interface class CrashReporter {
  /// Initialize the crash reporter. Must be called before [runApp].
  Future<void> init();

  /// Record an error. Set [fatal] to true for unrecoverable errors.
  void recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
    String? reason,
  });

  /// Add a breadcrumb (navigation event, user action) for context.
  void addBreadcrumb(String message, {String? category});

  /// Set a user identifier for grouping crash reports. Pass null to clear.
  void setUserId(String? userId);
}
```

## `lib/src/core/analytics/crash_reporter_impl.dart`

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart' as pkg;

import 'crash_reporter.dart';

/// Firebase Crashlytics implementation. The only file that imports
/// `package:firebase_crashlytics`.
class CrashReporterImpl implements CrashReporter {
  CrashReporterImpl({pkg.FirebaseCrashlytics? instance})
      : _crashlytics = instance ?? pkg.FirebaseCrashlytics.instance;

  final pkg.FirebaseCrashlytics _crashlytics;

  @override
  Future<void> init() async {
    await _crashlytics.setCrashlyticsCollectionEnabled(true);
  }

  @override
  void recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
    String? reason,
  }) {
    _crashlytics.recordError(
      error,
      stackTrace,
      reason: reason,
      fatal: fatal,
    );
  }

  @override
  void addBreadcrumb(String message, {String? category}) {
    _crashlytics.log(
      category != null ? '[$category] $message' : message,
    );
  }

  @override
  void setUserId(String? userId) {
    _crashlytics.setUserIdentifier(userId ?? '');
  }
}
```

---

## Usage

### Report error in a catch block

```dart
try {
  await repository.loadPosts();
} catch (e, s) {
  getIt<CrashReporter>().recordError(e, s, reason: 'Failed to load posts');
}
```

### Usage in BlocListener

```dart
BlocListener<PostsCubit, PostsState>(
  listenWhen: (prev, curr) => curr is PostsError,
  listener: (context, state) {
    if (state is PostsError) {
      // Report to crash reporting with breadcrumb context
      getIt<CrashReporter>()
        ..addBreadcrumb('PostsCubit emitted error state', category: 'cubit')
        ..recordError(
          state.failure,
          StackTrace.current,
          reason: 'PostsCubit error: ${state.failure}',
        );

      // Show user-facing error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.failure.userMessage)),
      );
    }
  },
  child: /* ... */,
)
```

---

## Rules

- **Init crash reporting BEFORE `runApp`** so startup crashes are caught.
- **Use breadcrumbs for debugging context, not as analytics events.** Breadcrumbs are cheap; analytics events have volume and cardinality costs.
- **Never log PII** (passwords, tokens, full email) in crash reports. User ID and display name are acceptable. Tokens and credentials are not.
- **Set user on login, clear on logout** — both `AnalyticsService` and `CrashReporter` must be updated together.

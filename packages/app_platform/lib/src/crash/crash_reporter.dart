import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Routes uncaught errors to a crash-reporting backend and records errors on
/// demand.
///
/// [install] must run once the backend is ready (for Firebase, after
/// `Firebase.initializeApp()`).
abstract class CrashReporter {
  /// Prepares the backend for collection (e.g. toggles Crashlytics collection).
  /// A no-op for reporters with no backend.
  ///
  /// The *global* Flutter-framework and platform-dispatcher error handlers are
  /// installed separately by [installGlobalErrorHandlers], which is always
  /// called (routing through this reporter's [recordError]) so error handling
  /// is wired even when crash reporting is disabled.
  Future<void> install();

  /// Records an [error] (with its [stack]); [fatal] marks it as a crash.
  Future<void> recordError(
    Object error,
    StackTrace stack, {
    String? reason,
    bool fatal = false,
  });
}

/// A [CrashReporter] that records nothing.
///
/// The default binding when crash reporting is disabled (e.g. a project
/// scaffolded with `fst create --no-firebase`). To enable it, point the
/// `// fst:crash-impl` binding in `crash_module.dart` at a real adapter.
class NoOpCrashReporter implements CrashReporter {
  const NoOpCrashReporter();

  @override
  Future<void> install() async {}

  @override
  Future<void> recordError(
    Object error,
    StackTrace stack, {
    String? reason,
    bool fatal = false,
  }) async {}
}

/// A [CrashReporter] backed by Firebase Crashlytics.
class FirebaseCrashReporter implements CrashReporter {
  @override
  Future<void> install() async {
    // Keep dev/debug crashes out of production Crashlytics. Release builds
    // collect; debug builds only log locally. The global error handlers
    // themselves are wired by [installGlobalErrorHandlers].
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      !kDebugMode,
    );
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace stack, {
    String? reason,
    bool fatal = false,
  }) {
    return FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }
}

/// Installs the process-wide Flutter-framework and platform-dispatcher error
/// handlers, routing every uncaught error through [reporter].
///
/// Unlike the previous design (where the Firebase reporter wired these inside
/// its own `install()`), this is called unconditionally from the app bootstrap
/// against whichever [CrashReporter] is registered. With [NoOpCrashReporter]
/// the handlers are still installed and simply record nothing, so behaviour is
/// consistent whether or not crash reporting is enabled — and there is a single
/// seam to also forward errors to a logger later.
///
/// Pair this with a `runZonedGuarded` around `runApp` in `main()` to also catch
/// errors escaping asynchronous callbacks that bypass [PlatformDispatcher].
void installGlobalErrorHandlers(CrashReporter reporter) {
  FlutterError.onError = (errorDetails) {
    FlutterError.presentError(errorDetails);
    reporter.recordError(
      errorDetails.exception,
      errorDetails.stack ?? StackTrace.current,
      reason: errorDetails.context?.toString(),
      fatal: true,
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    reporter.recordError(error, stack, fatal: true);
    return true;
  };
}

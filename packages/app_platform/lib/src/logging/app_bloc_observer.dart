import 'package:bloc/bloc.dart';

import '../crash/crash_reporter.dart';
import 'app_logger.dart';

/// A [BlocObserver] that gives every bloc/cubit uniform observability:
/// state changes are logged at debug level, and uncaught bloc errors are logged
/// at error level and forwarded to the [CrashReporter] so they show up in crash
/// reports (a class of error the global `FlutterError`/`PlatformDispatcher`
/// handlers don't see, since bloc swallows them into `onError`).
///
/// Install once in bootstrap: `Bloc.observer = AppBlocObserver(...)`.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver(
    this._logger, {
    CrashReporter? crashReporter,
    this.logStateChanges = true,
  }) : _crash = crashReporter;

  final AppLogger _logger;
  final CrashReporter? _crash;

  /// Whether to emit a debug line on every state change. Noisy; keep it on in
  /// dev and off (via the logger's min-level) in release.
  final bool logStateChanges;

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (logStateChanges) {
      _logger.debug(
        '${bloc.runtimeType}: ${change.currentState.runtimeType} '
        '-> ${change.nextState.runtimeType}',
        name: 'bloc',
      );
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _logger.error(
      '${bloc.runtimeType} error',
      name: 'bloc',
      error: error,
      stackTrace: stackTrace,
    );
    _crash?.recordError(
      error,
      stackTrace,
      reason: '${bloc.runtimeType} error',
    );
    super.onError(bloc, error, stackTrace);
  }
}

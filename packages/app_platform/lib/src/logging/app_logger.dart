import 'dart:developer' as developer;

/// Severity of a log record, ordered from most to least verbose.
enum LogLevel {
  debug(500),
  info(800),
  warn(900),
  error(1000);

  const LogLevel(this.developerLevel);

  /// The `dart:developer` numeric level this maps to.
  final int developerLevel;
}

/// App-wide structured logging seam.
///
/// Gives the app a single interface for logging instead of scattered
/// `dart:developer` `log(...)` calls with hand-rolled `name:`/`level:` tags.
/// The concrete [DeveloperAppLogger] routes through `dart:developer` (so it
/// integrates with DevTools and never hits the release console via `print`),
/// gated by a minimum [LogLevel]; swap in another implementation to forward
/// records elsewhere (e.g. crash-reporter breadcrumbs) without touching call
/// sites.
abstract class AppLogger {
  void debug(String message, {String? name, Object? error, StackTrace? stackTrace});
  void info(String message, {String? name, Object? error, StackTrace? stackTrace});
  void warn(String message, {String? name, Object? error, StackTrace? stackTrace});
  void error(String message, {String? name, Object? error, StackTrace? stackTrace});
}

/// An [AppLogger] backed by `dart:developer`, filtering out records below
/// [minLevel].
///
/// Configure [minLevel] per flavor — e.g. [LogLevel.debug] in dev and
/// [LogLevel.warn] in release — so production logging stays quiet without
/// stripping call sites.
class DeveloperAppLogger implements AppLogger {
  const DeveloperAppLogger({
    this.minLevel = LogLevel.debug,
    this.defaultName = 'app',
  });

  final LogLevel minLevel;
  final String defaultName;

  void _log(
    LogLevel level,
    String message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.index < minLevel.index) return;
    developer.log(
      message,
      name: name ?? defaultName,
      level: level.developerLevel,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void debug(String message, {String? name, Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.debug, message, name: name, error: error, stackTrace: stackTrace);

  @override
  void info(String message, {String? name, Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.info, message, name: name, error: error, stackTrace: stackTrace);

  @override
  void warn(String message, {String? name, Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.warn, message, name: name, error: error, stackTrace: stackTrace);

  @override
  void error(String message, {String? name, Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.error, message, name: name, error: error, stackTrace: stackTrace);
}

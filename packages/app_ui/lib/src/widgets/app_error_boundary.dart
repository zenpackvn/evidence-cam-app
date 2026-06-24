import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import 'app_error_view.dart';

/// Replaces Flutter's red error screen with a friendly fallback when a widget
/// throws during build.
///
/// Flutter renders any widget that throws in its build method via the global
/// [ErrorWidget.builder]. In release that is a grey box; in debug it is the red
/// screen — neither is acceptable in front of a user. Mounting one
/// [AppErrorBoundary] high in the tree swaps that for an [AppErrorView] (or a
/// custom fallback) and routes the error to [onError] (wire it to Crashlytics)
/// so a single broken widget degrades gracefully instead of painting red.
///
/// Scope: this covers synchronous **build** errors. It does not catch errors
/// from futures, streams, or callbacks — those never reach [ErrorWidget.builder]
/// and must be handled where they occur (return a `Result`/`Failure`, or set
/// `FlutterError.onError` in `main` for app-wide reporting). Because
/// [ErrorWidget.builder] is global, install this once near the app root rather
/// than around every subtree.
class AppErrorBoundary extends StatefulWidget {
  const AppErrorBoundary({
    required this.child,
    this.fallbackBuilder,
    this.onError,
    super.key,
  });

  final Widget child;

  /// Builds the replacement widget for a throwing build. Defaults to a full
  /// [AppErrorView]. Receives the captured details so callers can show specifics
  /// in debug while staying generic in release.
  final Widget Function(FlutterErrorDetails details)? fallbackBuilder;

  /// Side-effect hook for every captured error (e.g. report to Crashlytics).
  final void Function(FlutterErrorDetails details)? onError;

  @override
  State<AppErrorBoundary> createState() => _AppErrorBoundaryState();
}

class _AppErrorBoundaryState extends State<AppErrorBoundary> {
  ErrorWidgetBuilder? _previousBuilder;

  @override
  void initState() {
    super.initState();
    _previousBuilder = ErrorWidget.builder;
    ErrorWidget.builder = _build;
  }

  @override
  void dispose() {
    // Restore whatever builder was in place before, so nesting/teardown is safe.
    ErrorWidget.builder = _previousBuilder ?? ErrorWidget.builder;
    super.dispose();
  }

  Widget _build(FlutterErrorDetails details) {
    developer.log(
      'AppErrorBoundary caught a build error',
      name: 'app_ui',
      error: details.exception,
      stackTrace: details.stack,
    );
    widget.onError?.call(details);
    if (widget.fallbackBuilder != null) return widget.fallbackBuilder!(details);
    return const AppErrorView(
      title: 'Something went wrong',
      message: 'An unexpected error occurred.',
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

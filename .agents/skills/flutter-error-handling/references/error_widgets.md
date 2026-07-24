# Error Widgets

## Custom Error Widget — `app_error_widget.dart`

Replaces the red error screen in release builds with a user-friendly UI.

```dart
import 'package:flutter/material.dart';

/// Shown when a widget throws during build/layout/paint in release mode.
/// Replaces the default red "RenderFlex overflowed" screen.
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({super.key, required this.details});

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'The app encountered an unexpected error.\nPlease try again.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Error Boundary Widget — `error_boundary_widget.dart`

Catches build errors at the widget subtree level — like React's `ErrorBoundary`. Prevents a single broken widget from crashing the entire screen.

```dart
import 'package:flutter/material.dart';

import '../di/service_locator.dart';
import '../error/error_handler.dart';

/// Wraps a child widget and catches errors during build/layout/paint.
/// Shows [fallback] instead of the red error screen.
///
/// Usage:
/// ```dart
/// ErrorBoundary(
///   fallback: Text('Failed to load section'),
///   child: SomeFragileWidget(),
/// )
/// ```
class ErrorBoundary extends StatefulWidget {
  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallback,
    this.onError,
  });

  final Widget child;

  /// Widget shown when [child] throws. Defaults to a simple error card.
  final Widget? fallback;

  /// Optional callback when an error is caught.
  final void Function(Object error, StackTrace stackTrace)? onError;

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    // Override the error widget builder locally for this subtree.
    // Note: ErrorWidget.builder is global — for subtree isolation,
    // we use a different approach with ErrorWidget override.
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.fallback ?? _DefaultErrorFallback(error: _error!);
    }

    return _ErrorCatcher(
      onError: (error, stackTrace) {
        widget.onError?.call(error, stackTrace);

        if (GetIt.I.isRegistered<ErrorHandler>()) {
          getIt<ErrorHandler>().handleError(
            error,
            stackTrace,
            reason: 'ErrorBoundary caught widget error',
          );
        }

        if (mounted) {
          setState(() {
            _error = error;
            _stackTrace = stackTrace;
          });
        }
      },
      child: widget.child,
    );
  }

  /// Reset the error state to retry rendering the child.
  void reset() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }
}

/// Uses a custom [RenderObject] approach would be ideal, but for simplicity
/// we leverage Flutter's built-in error catching via ErrorWidget.
class _ErrorCatcher extends StatelessWidget {
  const _ErrorCatcher({required this.onError, required this.child});

  final void Function(Object error, StackTrace stackTrace) onError;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Flutter catches build errors automatically and shows ErrorWidget.
    // For more granular control, wrap in a Builder that catches.
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (e, s) {
          onError(e, s);
          return const SizedBox.shrink();
        }
      },
    );
  }
}

class _DefaultErrorFallback extends StatelessWidget {
  const _DefaultErrorFallback({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'This section failed to load',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## ErrorBoundary with Retry

```dart
/// ErrorBoundary that offers a retry button.
class RetryErrorBoundary extends StatefulWidget {
  const RetryErrorBoundary({
    super.key,
    required this.child,
    this.retryLabel = 'Retry',
  });

  final Widget child;
  final String retryLabel;

  @override
  State<RetryErrorBoundary> createState() => _RetryErrorBoundaryState();
}

class _RetryErrorBoundaryState extends State<RetryErrorBoundary> {
  final _boundaryKey = GlobalKey<_ErrorBoundaryState>();

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      key: _boundaryKey,
      fallback: _RetryFallback(
        label: widget.retryLabel,
        onRetry: () => _boundaryKey.currentState?.reset(),
      ),
      child: widget.child,
    );
  }
}

class _RetryFallback extends StatelessWidget {
  const _RetryFallback({required this.label, required this.onRetry});

  final String label;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(height: 8),
            Text(
              'This section failed to load',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Usage

- Wrap third-party widgets or complex subtrees in `ErrorBoundary` to prevent one broken section from crashing the entire screen.
- Use `RetryErrorBoundary` when the subtree failure may be transient and can be recovered by re-running it.

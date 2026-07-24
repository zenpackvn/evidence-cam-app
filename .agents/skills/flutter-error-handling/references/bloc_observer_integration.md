# BlocObserver Error Integration

## `app_bloc_observer.dart`

```dart
// lib/src/core/bloc/app_bloc_observer.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../error/error_handler.dart';
import '../logging/app_logger.dart';

class AppBlocObserver extends BlocObserver {
  AppBlocObserver({
    required AppLogger logger,
    required ErrorHandler errorHandler,
  })  : _logger = logger,
        _errorHandler = errorHandler;

  final AppLogger _logger;
  final ErrorHandler _errorHandler;

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    _errorHandler.handleError(
      error,
      stackTrace,
      reason: '${bloc.runtimeType} error',
    );
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    _logger.debug('${bloc.runtimeType}: ${transition.event.runtimeType}');
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    _logger.debug('${bloc.runtimeType}: state changed');
  }
}
```

## Wiring BlocObserver in Bootstrap

```dart
// Add to bootstrap(), after DI is configured:

Bloc.observer = AppBlocObserver(
  logger: getIt<AppLogger>(),
  errorHandler: getIt<ErrorHandler>(),
);
```

## Notes

- `BlocObserver.onError` catches errors that escape cubit methods via `addError()` or unhandled throws.
- The observer delegates to `ErrorHandler` — no direct logging or crash reporting in the observer itself.

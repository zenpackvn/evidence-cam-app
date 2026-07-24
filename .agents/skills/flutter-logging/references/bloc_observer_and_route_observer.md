# Logging — BlocObserver and RouteObserver

## `lib/src/core/bloc/app_bloc_observer.dart`

Wire `AppBlocObserver` into the BLoC runtime to automatically log every state transition and route cubit/bloc errors through `ErrorHandler`.

```dart
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
    _logger.debug('${bloc.runtimeType}: state → ${change.nextState.runtimeType}');
  }
}
```

### Bootstrap wiring

Set `Bloc.observer` in `appBootstrap()` before `runApp`:

```dart
// lib/src/app/bootstrap/app_bootstrap.dart
Future<void> appBootstrap() async {
  // ... DI, Firebase, etc.

  Bloc.observer = AppBlocObserver(
    logger: getIt<AppLogger>(),
    errorHandler: getIt<ErrorHandler>(),
  );

  runApp(const App());
}
```

`AppBlocObserver` is not registered in DI — it's wired once in bootstrap. `ErrorHandler` must be registered before bootstrap runs.

---

## `lib/src/core/bloc/app_route_observer.dart`

Automatic screen logging on route changes via `NavigatorObserver`:

```dart
import 'package:flutter/widgets.dart';
import '../logging/app_logger.dart';

class AppRouteObserver extends NavigatorObserver {
  AppRouteObserver({required AppLogger logger}) : _logger = logger;
  final AppLogger _logger;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final name = route.settings.name;
    if (name != null) _logger.info('Screen push: $name');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    final name = previousRoute?.settings.name;
    if (name != null) _logger.info('Screen pop → $name');
  }
}
```

### GoRouter wiring

```dart
final router = GoRouter(
  observers: [
    AppRouteObserver(logger: getIt<AppLogger>()),
  ],
  // ...routes
);
```

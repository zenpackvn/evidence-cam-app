# Analytics Observers

Auto-tracking via `NavigatorObserver` and `BlocObserver` — zero per-page boilerplate.

## `lib/src/core/analytics/analytics_observer.dart`

```dart
import 'package:flutter/widgets.dart';

import 'analytics_service.dart';

/// [NavigatorObserver] that auto-tracks screen views on route changes.
///
/// Add to GoRouter's `observers` list:
/// ```dart
/// GoRouter(observers: [getIt<AnalyticsObserver>()])
/// ```
class AnalyticsObserver extends NavigatorObserver {
  AnalyticsObserver({required AnalyticsService analyticsService})
      : _analyticsService = analyticsService;

  final AnalyticsService _analyticsService;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackScreen(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) _trackScreen(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) _trackScreen(previousRoute);
  }

  void _trackScreen(Route<dynamic> route) {
    final name = route.settings.name;
    if (name != null && name.isNotEmpty) {
      _analyticsService.trackScreen(name);
    }
  }
}
```

## Wiring into GoRouter

```dart
// lib/src/app/router/app_router.dart
import '../../core/di/service_locator.dart';
import '../../core/analytics/analytics_observer.dart';

final appRouter = GoRouter(
  routes: [ /* ... */ ],
  observers: [getIt<AnalyticsObserver>()],
);
```

Every route push, pop, and replace now auto-tracks screen views through `AnalyticsObserver` without any per-screen code.

---

## `lib/src/core/analytics/analytics_bloc_observer.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../logging/app_logger.dart';
import 'analytics_service.dart';

/// [BlocObserver] that logs state transitions as analytics events.
///
/// Optional — enable in bootstrap for dev/debug builds only.
/// ```dart
/// if (!config.isProduction) {
///   Bloc.observer = AnalyticsBlocObserver(
///     analyticsService: getIt<AnalyticsService>(),
///     logger: getIt<AppLogger>(),
///   );
/// }
/// ```
class AnalyticsBlocObserver extends BlocObserver {
  AnalyticsBlocObserver({
    required AnalyticsService analyticsService,
    required AppLogger logger,
  })  : _analyticsService = analyticsService,
        _logger = logger;

  final AnalyticsService _analyticsService;
  final AppLogger _logger;

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    _analyticsService.trackEvent(
      'bloc_transition',
      params: {
        'bloc': bloc.runtimeType.toString(),
        'from': transition.currentState.runtimeType.toString(),
        'to': transition.nextState.runtimeType.toString(),
      },
    );
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    _logger.debug(
      '${bloc.runtimeType} | ${change.currentState.runtimeType} -> '
      '${change.nextState.runtimeType}',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    _logger.error(
      '${bloc.runtimeType} error',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
```

---

## Anti-pattern — manual tracking in every page

```dart
// BAD: manual tracking in every page — easy to forget, incomplete coverage
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Must remember to add this to every single page
    getIt<AnalyticsService>().trackScreen('home');
    return const HomeView();
  }
}
```

```dart
// GOOD: automatic tracking via NavigatorObserver — zero per-page boilerplate
final appRouter = GoRouter(
  routes: [ /* ... */ ],
  observers: [getIt<AnalyticsObserver>()],
);

// Manual call only for screens that don't trigger a route push
void onTabChanged(int index) {
  final tabName = ['home', 'search', 'profile'][index];
  getIt<AnalyticsService>().trackScreen(tabName);
}
```

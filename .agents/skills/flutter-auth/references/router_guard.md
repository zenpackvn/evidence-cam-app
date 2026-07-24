# Auth — GoRouter Guard & AuthNotifier

Replace the simple token-check guard from [template-routing.md](template-routing.md) with an `AuthCubit`-driven redirect. The router listens to `AuthCubit` state changes via `refreshListenable`.

## `lib/src/app/router/app_router.dart` (updated)

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/service_locator.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_cubit_state.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import 'auth_notifier.dart';
import 'main_shell.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter instance = GoRouter(
    initialLocation: RoutePaths.home,
    debugLogDiagnostics: true,
    refreshListenable: AuthNotifier(getIt<AuthCubit>()),
    redirect: _guard,
    errorBuilder: (context, state) => _NotFoundPage(uri: state.uri),
    routes: [
      // ── Auth (outside shell — no bottom nav) ──
      GoRoute(
        name: RouteNames.signIn,
        path: RoutePaths.signIn,
        builder: (context, state) => const SignInPage(),
      ),

      // ── Main shell (bottom nav) ──
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            name: RouteNames.home,
            path: RoutePaths.home,
            builder: (context, state) => const HomePage(),
          ),
          // ... other routes
        ],
      ),
    ],
  );

  static String? _guard(BuildContext context, GoRouterState state) {
    final authCubit = getIt<AuthCubit>();
    final authState = authCubit.state;
    final isOnSignIn = state.matchedLocation == RoutePaths.signIn;

    // Still loading — don't redirect yet.
    if (authState is AuthUnknown) return null;

    final isAuthenticated = authState is AuthAuthenticated;

    if (!isAuthenticated && !isOnSignIn) return RoutePaths.signIn;
    if (isAuthenticated && isOnSignIn) return RoutePaths.home;
    return null; // no redirect
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage({required this.uri});
  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not Found')),
      body: Center(child: Text('Page not found: $uri')),
    );
  }
}
```

---

## `lib/src/app/router/auth_notifier.dart`

Bridges `AuthCubit` stream to `ChangeNotifier` for `GoRouter.refreshListenable`.

```dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_cubit_state.dart';

class AuthNotifier extends ChangeNotifier {
  AuthNotifier(this._authCubit) {
    _subscription = _authCubit.stream.listen((_) => notifyListeners());
  }

  final AuthCubit _authCubit;
  late final StreamSubscription<AuthCubitState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
```

---

## App-level `BlocProvider` for `AuthCubit`

Wrap `MaterialApp.router` so every descendant can access auth state:

```dart
// lib/src/app/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/service_locator.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>.value(
      value: getIt<AuthCubit>(),
      child: MaterialApp.router(
        title: 'App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        routerConfig: AppRouter.instance,
      ),
    );
  }
}
```

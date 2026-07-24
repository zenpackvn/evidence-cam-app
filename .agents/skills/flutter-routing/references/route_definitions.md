# Route Definitions

## `lib/src/app/router/route_names.dart`

```dart
/// Centralized route paths and names — no magic strings in navigation calls.
abstract final class RoutePaths {
  static const String home = '/';
  static const String signIn = '/sign-in';
  static const String postList = '/posts';
  static const String postDetail = '/posts/:id';
  static const String profile = '/profile';
  static const String settings = '/settings';
}

abstract final class RouteNames {
  static const String home = 'home';
  static const String signIn = 'sign-in';
  static const String postList = 'post-list';
  static const String postDetail = 'post-detail';
  static const String profile = 'profile';
  static const String settings = 'settings';
}
```

## `lib/src/app/router/app_router.dart`

The **only file** that builds the `GoRouter` instance and defines the route tree.

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/service_locator.dart';
import '../../core/storage/secure_storage.dart';
import '../../features/home/presentation/pages/home_page.dart';
import 'main_shell.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter instance = GoRouter(
    initialLocation: RoutePaths.home,
    debugLogDiagnostics: true,
    redirect: _guard,
    errorBuilder: (context, state) => _NotFoundPage(uri: state.uri),
    routes: [
      // ── Auth (outside shell — no bottom nav) ──
      GoRoute(
        name: RouteNames.signIn,
        path: RoutePaths.signIn,
        builder: (context, state) => const SignInPage(),
      ),

      // ── Main shell (bottom nav, stateful branches preserve tab state) ──
      // StatefulShellRoute.indexedStack keeps each branch alive in an
      // IndexedStack — switching tabs never destroys/rebuilds pages.
      // Use ShellRoute only when tabs do NOT need to preserve state.
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              name: RouteNames.home,
              path: RoutePaths.home,
              builder: (context, state) => const HomePage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              name: RouteNames.postList,
              path: RoutePaths.postList,
              builder: (context, state) => const PostListPage(),
              routes: [
                GoRoute(
                  name: RouteNames.postDetail,
                  path: ':id',
                  builder: (context, state) {
                    final postId = int.parse(state.pathParameters['id']!);
                    return PostDetailPage(postId: postId);
                  },
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              name: RouteNames.profile,
              path: RoutePaths.profile,
              builder: (context, state) => const ProfilePage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              name: RouteNames.settings,
              path: RoutePaths.settings,
              builder: (context, state) => const SettingsPage(),
            ),
          ]),
        ],
      ),
    ],
  );

  /// Auth guard — redirect unauthenticated users to sign-in.
  static Future<String?> _guard(
    BuildContext context,
    GoRouterState state,
  ) async {
    final storage = getIt<SecureStorage>();
    final token = await storage.read('auth_token');
    final isLoggedIn = token != null && token.isNotEmpty;
    final isOnSignIn = state.matchedLocation == RoutePaths.signIn;

    if (!isLoggedIn && !isOnSignIn) return RoutePaths.signIn;
    if (isLoggedIn && isOnSignIn) return RoutePaths.home;
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
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text('Page not found: $uri'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(RoutePaths.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Rules

- `app_router.dart` is the only file that builds `GoRouter` and defines routes.
- Route builders are thin — just parse parameters and return the page widget. No business logic.
- Use `RoutePaths` and `RouteNames` constants — no magic strings.
- Use `StatefulShellRoute.indexedStack` for bottom nav — tabs keep their state and scroll position. Use `ShellRoute` only for persistent chrome wrapping a single stateless child.
- Auth guard checks token existence only; feature-level conditions live in cubits or dedicated redirects.

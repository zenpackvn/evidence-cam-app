# Routing Patterns and Anti-Patterns

## Wrapper Rule

- **`AppNavigator`** is the app-owned interface. Feature code depends on it.
- **`AppNavigatorImpl`** is the only bridge to `package:go_router` navigation extensions.
- **`app_router.dart`** is the only file that builds `GoRouter` and defines routes.
- **`main_shell.dart`** can import `go_router` since it lives under `app/router/` (router infrastructure, not feature code).
- **Feature pages, cubits, repositories, widgets NEVER import `package:go_router`.**
- **Enforcement:** grep for `import 'package:go_router/` outside `lib/src/app/router/` — any match is a defect.

## Auth Guard

- Keep the guard reactive to auth state changes. When the user logs out, the router should redirect to sign-in without manual navigation.
- Check token existence in guard, not in every page widget.
- Allow public routes (sign-in, onboarding, terms) to bypass the guard.

## Route Organization

- Use `StatefulShellRoute.indexedStack` for bottom nav — tabs keep their state and scroll position across switches. `ShellRoute` destroys and rebuilds the page on every tab switch.
- Use `ShellRoute` only for persistent chrome that wraps a single, stateless child.
- Keep route tree flat when possible — deeply nested routes are hard to reason about.
- Use `RoutePaths` and `RouteNames` constants — no magic strings.
- Keep route builders thin — just parse parameters and return the page widget. No business logic.

## Navigation Rules

- **Pages are pure widgets.** They receive parameters via constructor.
- **Navigation calls live in widgets or BlocListeners**, never inside blocs, cubits, or repositories.
- **Use `go()` for replacing** (tab switches, auth redirects). **Use `push()` for stacking** (detail pages, modals).
- **Use `pop()` with result** when a page needs to return data to the caller.
- **`extra` is convenient but not deep-link safe.** Always have a fallback path/query parameter for routes that need deep linking.
- **Keep redirects centralized** in the router's `redirect` callback.

## Anti-Patterns

### 1. Navigating with hardcoded path strings scattered everywhere

```dart
// DON'T — magic strings duplicated across features
context.go('/posts');
context.push('/posts/42');
context.go('/sign-in');

// DO — use RoutePaths constants via AppNavigator
navigator(context).goPostList();
navigator(context).pushPostDetail(42);
navigator(context).goSignIn();
```

### 2. Putting business logic in route redirect guards

```dart
// DON'T — guard does data fetching, profile checks, onboarding status
static Future<String?> _guard(BuildContext context, GoRouterState state) async {
  final user = await getIt<UserRepository>().fetchProfile();
  if (!user.hasCompletedOnboarding) return '/onboarding';
  if (user.subscription.isExpired) return '/paywall';
  // ...complex branching
}

// DO — guard checks only auth status; feature-level conditions live in cubits or dedicated redirects
static Future<String?> _guard(BuildContext context, GoRouterState state) async {
  final token = await getIt<SecureStorage>().read('auth_token');
  final isLoggedIn = token != null && token.isNotEmpty;
  final isOnSignIn = state.matchedLocation == RoutePaths.signIn;
  if (!isLoggedIn && !isOnSignIn) return RoutePaths.signIn;
  if (isLoggedIn && isOnSignIn) return RoutePaths.home;
  return null;
}
```

### 3. Nested GoRouters instead of ShellRoute

```dart
// DON'T — creating a separate GoRouter per tab
class PostsTab extends StatelessWidget {
  final _router = GoRouter(routes: [/* post routes */]);

  @override
  Widget build(BuildContext context) => MaterialApp.router(routerConfig: _router);
}

// DO — use ShellRoute or StatefulShellRoute for tabs within one GoRouter
StatefulShellRoute.indexedStack(
  branches: [
    StatefulShellBranch(routes: [/* home routes */]),
    StatefulShellBranch(routes: [/* post routes */]),
  ],
)
```

### 4. Not handling deep link edge cases (unauthenticated deep links)

```dart
// DON'T — unauthenticated user opens deep link, gets redirected to sign-in, loses intended destination
if (!isLoggedIn) return RoutePaths.signIn; // original deep link is lost

// DO — save the intended destination and redirect after sign-in
if (!isLoggedIn && !isOnSignIn) {
  getIt<DeepLinkStore>().pendingPath = state.uri.toString();
  return RoutePaths.signIn;
}
// After successful sign-in, check for pending deep link and navigate there
```

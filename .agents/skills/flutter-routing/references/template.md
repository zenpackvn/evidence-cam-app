# Template — Routing

GoRouter-based routing wrapped behind an app-owned `AppNavigator` interface. Feature pages are pure widgets — they receive an `AppNavigator` via DI or callback, never import `go_router` directly. Only files under `lib/src/app/router/` import `package:go_router`.

## Topics

| Topic | File |
|---|---|
| Route definitions, GoRouter instance, auth guard | [route_definitions.md](route_definitions.md) |
| AppNavigator interface, impl, DI, usage patterns | [app_navigator.md](app_navigator.md) |
| MainShell, StatefulShellRoute, tab refresh, transitions | [main_shell_and_tabs.md](main_shell_and_tabs.md) |
| Deep linking (Universal Links, App Links, DeepLinkStore, testing) | [deep_linking.md](deep_linking.md) |
| Patterns, anti-patterns, wrapper rule enforcement | [routing_patterns_and_antipatterns.md](routing_patterns_and_antipatterns.md) |

## ⚠️ Common Mistakes

> These are the most frequent routing bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **Feature code imports `package:go_router` directly** | A page or cubit has `import 'package:go_router/go_router.dart'` — breaks the wrapper rule and couples feature code to the router library | Only files under `lib/src/app/router/` may import `go_router`; feature pages navigate via `AppNavigator` injected through DI or passed as a callback |
| 2 | **Using magic path strings instead of `RoutePaths` constants** | `context.go('/posts/42')` scattered across files; a path rename breaks navigation silently at runtime | Always use `RoutePaths.*` constants and `AppNavigator` methods (e.g., `navigator(context).pushPostDetail(42)`); grep for raw string literals starting with `/` in feature code |
| 3 | **Using `ShellRoute` instead of `StatefulShellRoute.indexedStack` for bottom nav** | Switching tabs destroys and rebuilds the page widget every time; scroll position and local state are lost | Use `StatefulShellRoute.indexedStack` for all bottom-nav shells; each branch is kept alive in an `IndexedStack` across tab switches |
| 4 | **Business logic in the auth guard** | Guard fetches user profile, checks onboarding status, or evaluates subscription state — guard runs on every navigation event | Guard checks only token existence (`SecureStorage.read('auth_token')`); feature-level conditions (onboarding, paywall) belong in cubits or dedicated redirects |
| 5 | **Losing the deep link intent after auth redirect** | Unauthenticated user taps a deep link, gets sent to sign-in, then lands on home after login instead of the intended screen | Save the pending path in `DeepLinkStore` before redirecting (`getIt<DeepLinkStore>().pendingPath = state.uri.toString()`); after successful sign-in, read and navigate to the pending path |
| 6 | **Calling navigation from inside cubits or repositories** | `navigator.goHome()` called inside a cubit method — couples business logic to navigation, breaks testability | Navigation calls belong exclusively in widgets or `BlocListener` callbacks; cubits emit state, listeners react and navigate |
| 7 | **Using `extra` for data that must survive deep links** | Route passes a domain object via `state.extra`; deep link from a push notification has no `extra`, causing a null crash | Use path/query parameters for all deep-link-safe routes; `extra` is only acceptable for in-app-only navigation where a fallback is defined |
| 8 | **Nested `GoRouter` instances per tab** | Each tab creates its own `MaterialApp.router` with a separate `GoRouter`; deep links, back stack, and auth guard all break | Define the entire route tree in a single `GoRouter` instance in `app_router.dart`; use `StatefulShellBranch` routes for per-tab route trees |

## Quick Summary

- **Feature code never imports `package:go_router`** — only files under `lib/src/app/router/` may. Grep for violations on every PR.
- **`AppNavigator`** is the app-owned interface. `AppNavigatorImpl` is the sole bridge to GoRouter extensions. `app_router.dart` is the sole builder of the `GoRouter` instance.
- **Use `StatefulShellRoute.indexedStack`** for bottom nav — tabs preserve state and scroll across switches. `ShellRoute` destroys pages on every tab switch.
- **Auth guard checks only token existence** — business-logic conditions (onboarding, paywall) belong in cubits, not the guard.
- **Save the deep link intent before redirecting** — use `DeepLinkStore` to restore after auth, otherwise the user lands on home instead of the intended screen.
- **Navigation calls belong in widgets or BlocListeners**, never inside blocs, cubits, or repositories.
- **Use `RoutePaths`/`RouteNames` constants** — no magic strings anywhere in the codebase.

## Folder structure

```text
lib/src/app/
  router/
    app_navigator.dart             ← App-owned navigation interface (no go_router import)
    app_navigator_impl.dart        ← GoRouter implementation (only file features touch indirectly)
    app_router.dart                ← GoRouter instance, route tree, guards, redirects
    route_names.dart               ← Named route constants (avoid magic strings)
    main_shell.dart                ← Bottom navigation shell
    tab_refresh_notifier.dart      ← Double-tap tab reload via ValueNotifier
lib/src/core/
  routing/
    deep_link_store.dart           ← Preserves pending deep link path through auth redirect
```

## Cross-references

- [flutter-di](../../../flutter-di/references/template.md) — `GoRouter` is registered as a `lazySingleton`; `AppNavigator` is injected into feature code via the service locator
- [flutter-auth](../../../flutter-auth/references/template.md) — auth guard reads `AuthService.currentStatus` to redirect unauthenticated users; `DeepLinkStore` restores the pending path after sign-in

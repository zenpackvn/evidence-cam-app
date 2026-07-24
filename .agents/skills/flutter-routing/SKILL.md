---
name: flutter-routing
description: Use this skill when working on Flutter navigation — GoRouter, routes, route tree, ShellRoute, StatefulShellRoute, bottom navigation bar tabs, nested navigation, auth guard, redirect, deep linking, push notification navigation, route constants, named routes, path parameters, query parameters, page transitions, navigation patterns, or go_router setup.
---

# Flutter Routing

Full reference: [`template.md`](references/template.md)

## Key rules

- `go_router` is the only routing package. Configured once in `core/router/app_router.dart` (or `router/` feature folder).
- Use `ShellRoute` for bottom-nav tabs (shared scaffold). Use `StatefulShellRoute.indexedStack` for persistent tab stacks.
- Auth guard: `redirect` callback reads `AuthService.currentStatus`. Unauthenticated → `/login`. Authenticated on login page → `/home`.
- Route constants in a single `AppRoutes` class (`static const String home = '/home'`). No hardcoded path strings elsewhere.
- Deep links: configure `AndroidManifest.xml` intent filter + iOS `Info.plist` associated domains. Test with `adb shell am start` / `xcrun simctl openurl`.
- `context.go()` for tab-level navigation (replaces history). `context.push()` for stack navigation (back button returns).
- Page transitions: `CustomTransitionPage` for custom animations. `NoTransitionPage` for tab switches.
- Never use `Navigator.push/pop` in feature code — always `context.go/push/pop`.
- `GoRouter` registered as `lazySingleton` in DI.

## Files

```
lib/src/app/router/
  app_router.dart          ← GoRouter instance, route tree, auth guard
  app_routes.dart          ← route path constants
  tab_refresh_notifier.dart ← optional: notifies tabs to refresh on re-tap
```

## Co-load with

- `flutter-di` — router registration
- `flutter-auth` — auth guard redirect logic

# State Restoration Setup

## The Problem

Android kills backgrounded apps under memory pressure. When the user returns, the OS recreates the activity but all in-memory state is gone. Without restoration:

- Form fields are empty — user loses typed data.
- Scroll position resets to top.
- Tab selection resets to first tab.
- Navigation stack collapses to the initial route.
- BLoC/Cubit state is lost — user sees loading screen for already-loaded data.

iOS has the same behavior but triggers it less frequently.

## How Flutter Restoration Works

```
┌──────────────────────────────────────────────────┐
│                    App running                   │
│  RestorationScope (root)                          │
│    ├── RestorableInt (tab index)                  │
│    ├── RestorableDouble (scroll offset)           │
│    ├── RestorableTextEditingController (form)     │
│    └── RestorableString (custom serialized state) │
└────────────────┬─────────────────────────────────┘
                 │ OS kills app
                 ▼
┌──────────────────────────────────────────────────┐
│            Restoration data (OS-managed)           │
│  Serialized bucket tree saved by the framework    │
└────────────────┬─────────────────────────────────┘
                 │ User returns to app
                 ▼
┌──────────────────────────────────────────────────┐
│              App recreated by OS                   │
│  RestorationScope reads buckets → restores state  │
│  Widget tree rebuilds with preserved values        │
└──────────────────────────────────────────────────┘
```

## Enable Restoration in MaterialApp

```dart
// lib/src/app/app.dart

import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // Enable state restoration
      restorationScopeId: 'app',
      title: 'App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: AppRouter.instance,
      supportedLocales: l10n.supportedLocales,
      localizationsDelegates: l10n.delegates,
      builder: FlutterSmartDialog.init(),
    );
  }
}
```

## Enable Restoration in GoRouter

```dart
// lib/src/app/router/app_router.dart

final router = GoRouter(
  restorationScopeId: 'router',
  initialLocation: RoutePaths.home,
  routes: [/* ... */],
  redirect: _authGuard,
);
```

This preserves the navigation stack across process death.

## Folder Structure

```
lib/src/core/
  restoration/
    restorable_cubit_state.dart      ← Mixin for cubit-level persistence
    restorable_enum.dart             ← RestorableEnum<T> for any enum
    restorable_date_time.dart        ← RestorableDateTime
```

## DI Registration

```yaml
# pubspec.yaml (add if using hydrated_bloc)
dependencies:
  hydrated_bloc: 9.1.5
  path_provider: 2.1.4
```

```dart
// In bootstrap(), BEFORE configureDependencies:
final storage = await HydratedStorage.build(
  storageDirectory: await getApplicationDocumentsDirectory(),
);
HydratedBloc.storage = storage;
```

No DI registration needed for `RestorableEnum`, `RestorableDateTime`, or `RestorationMixin` — they are widget-level.

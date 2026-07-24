---
name: flutter-state-restoration
description: Use this skill when implementing Flutter state restoration — process death survival, HydratedCubit, hydrated_bloc, RestorationMixin, restorable properties, form state restoration, scroll position restoration, tab index restoration, RestorableInt, RestorableString, or keeping UI state across app restarts and process death.
---

# Flutter State Restoration

Full reference: [`template.md`](references/template.md)

## Key rules

- `HydratedCubit` (from `hydrated_bloc`) automatically serializes/deserializes state to disk. Implement `fromJson()`/`toJson()` in every `HydratedCubit`.
- `fromJson()` must be **defensive** — return a valid default state if JSON is null, malformed, or from an incompatible version.
- `toJson()` returns `null` to skip persistence (e.g., for error states or states with sensitive data).
- `HydratedBloc.storage` must be initialized before `runApp()`: `HydratedBloc.storage = await HydratedStorage.build(storageDirectory: dir)`.
- `RestorationMixin` + `RootRestorationScope` → for scroll, text, tab, and page state that doesn't go through a cubit.
- Assign `restorationScopeId` to `MaterialApp.router`, `GoRouter`, `Scaffold`, and any restorable widget.
- Form restoration: `HydratedCubit` for field values. `RestorationMixin` for scroll position.
- Never persist sensitive data (tokens, PII) via `HydratedCubit` — use `SecureStorage` for those.

## Files

```
lib/src/core/di/service_locator.dart   ← initializes HydratedBloc.storage
lib/src/app/app_bootstrap.dart         ← path_provider for storage directory
```

Each `HydratedCubit` is in its feature's `presentation/cubit/` folder.

## Co-load with

- `flutter-forms` — form cubits use `HydratedCubit` for persistence
- `flutter-storage` — `path_provider` for storage directory
- `flutter-di` — storage init in bootstrap

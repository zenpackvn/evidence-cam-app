# Template — State Restoration

Survive Android process death and iOS app termination without losing user progress. Covers Flutter's `RestorationMixin`, restorable properties, HydratedCubit, form/scroll/tab restoration, and testing.

## Topics

| Topic | File |
|---|---|
| Problem overview, how restoration works, setup (MaterialApp + GoRouter) | [restoration_setup.md](restoration_setup.md) |
| Form, scroll, tab restoration; custom restorable types | [restorable_widgets.md](restorable_widgets.md) |
| HydratedCubit, manual cubit persistence mixin, restore-vs-refetch guide | [cubit_state_restoration.md](cubit_state_restoration.md) |
| Testing process death (adb, Developer Options, Xcode, widget tests) | [restoration_testing.md](restoration_testing.md) |

## ⚠️ Common Mistakes

> These are the most frequent state restoration bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **`restorationScopeId` missing from `MaterialApp.router`** | Nothing restores after process death; the entire restoration system is silently disabled | Set `restorationScopeId: 'app'` on `MaterialApp.router` — this is the top-level enable switch without which no widget restoration occurs |
| 2 | **`restorationScopeId` missing from `GoRouter`** | Navigation stack collapses to `initialLocation` after process death; user loses their place | Set `restorationScopeId: 'router'` on the `GoRouter` instance to preserve the navigation stack |
| 3 | **Duplicate `restorationId` within the same scope** | One widget's state overwrites another's; silent data corruption on restore | Use a unique string per widget — convention is the page/widget class name (e.g. `'checkout_page'`, `'post_list_page'`) |
| 4 | **`Restorable*` properties not disposed** | Memory leak reported by `LeakTracker`; `ChangeNotifier` not cleaned up | Override `dispose()` and call `.dispose()` on every `RestorableTextEditingController`, `RestorableBool`, `RestorableInt`, etc., before `super.dispose()` |
| 5 | **Full API response serialized into restoration state** | Restoration bucket exceeds OS size limit; stale cached data shown after restore | Restore only user input and navigation state (filter selection, scroll offset, tab index); re-fetch server data after restore |
| 6 | **`fromJson`/`fromPrimitives` throws on corrupt data** | App crashes on first launch after an upgrade that changed the state schema | Wrap `fromJson` and `fromPrimitives` in `try/catch`; log the error and return `null` or defaults so `HydratedCubit` falls back gracefully |
| 7 | **Sensitive data (tokens, PII) stored via `RestorationMixin`** | Credentials readable from unencrypted restoration buckets on the device | Store tokens, passwords, and PII in `SecureStorage` only; restoration buckets are not encrypted |
| 8 | **`HydratedBloc.storage` initialised after `configureDependencies()`** | `HydratedCubit` throws `StateError: storage is not initialised` on startup | Call `HydratedStorage.build()` and assign `HydratedBloc.storage` in `bootstrap()` before `configureDependencies()` is called |

## Quick Summary

- **Set `restorationScopeId: 'app'` on `MaterialApp.router`** — this is the top-level enable switch. Without it, nothing restores.
- **Set `restorationScopeId: 'router'` on `GoRouter`** — preserves the navigation stack across process death.
- **Every `RestorationMixin` needs a unique `restorationId`** within its parent scope. Use the page/widget class name.
- **Restore user input, re-fetch server data** — never serialize full API responses into restoration state (size limits, stale data). Restore the filter selection; re-run the query.
- **Use `BaseHydratedCubit` for cubit state** — `HydratedCubit` writes to disk and survives both process death and cold starts. `RestorationMixin` only survives process death.
- **`fromJson`/`fromPrimitives` must never throw** — always fall back to defaults; log the error.
- **Dispose all `Restorable*` properties** — they are `ChangeNotifier` subclasses and leak if not disposed.
- **Never restore sensitive data via `RestorationMixin`** — restoration buckets are not encrypted. Tokens, passwords, and PII belong in `SecureStorage`.
- **Test with "Don't keep activities"** — enables aggressive process death during development, exposing bugs immediately.

## Cross-references

- [flutter-forms](../../flutter-forms/references/template.md) — form cubits use `HydratedCubit` for input persistence across process death
- [flutter-storage](../../flutter-storage/references/template.md) — `path_provider` storage directory is required to initialise `HydratedBloc.storage`
- [flutter-di](../../flutter-di/references/template.md) — `HydratedStorage.build()` must be called in bootstrap before `configureDependencies()`
- [flutter-routing](../../flutter-routing/references/template.md) — `restorationScopeId: 'router'` on GoRouter preserves the navigation stack after process death
- [flutter-security](../../flutter-security/references/template.md) — restoration buckets are unencrypted; tokens and PII must go to `SecureStorage` instead
- [flutter-base-classes](../../flutter-base-classes/references/template.md) — `BaseHydratedCubit` is the recommended base for cubit state that survives process death

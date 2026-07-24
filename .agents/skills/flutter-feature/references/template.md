# Template — Feature Example (Home)

End-to-end feature wiring: DI module, repository, cubit, state, and page. Demonstrates the clean architecture slice pattern applied to a concrete "Home" feature.

## Topics

| Topic | File |
|---|---|
| Domain repository interface + data implementation | [domain_and_data.md](domain_and_data.md) |
| Sealed state class + cubit | [cubit_and_state.md](cubit_and_state.md) |
| DI module + page widget | [di_and_page.md](di_and_page.md) |
| Cubit vs BLoC decision, state modeling, widget usage, async safety, anti-patterns | [bloc_cubit_patterns.md](bloc_cubit_patterns.md) |
| Widget architecture, composition, forms and validation | [widget_patterns.md](widget_patterns.md) |
| Async patterns, null safety, `mounted` guard, `safeEmit` | [async_and_null_safety.md](async_and_null_safety.md) |

## ⚠️ Common Mistakes

> These are the most frequent feature-wiring bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **Calling raw `emit()` after an `await` without checking `isClosed`** | `Bad state: emit was called after the cubit was closed` crash when navigating away mid-request | Extend `BaseCubit` and use `safeEmit()` everywhere — `SafeEmitMixin` guards every emit against a closed cubit |
| 2 | **Business logic or API calls inside a widget's `build()` or `FutureBuilder`** | Logic runs on every rebuild; state is not testable; filters/transforms scatter across the widget tree | Move all async orchestration into the cubit's methods; the widget only calls cubit methods and renders state via `BlocBuilder` |
| 3 | **State class missing `Equatable` `props` override** | `BlocBuilder` rebuilds on every emit even when data is identical; tests using `emitsInOrder` fail | All state classes must extend `Equatable` and list every field in `get props => [...]` |
| 4 | **Navigation or dialogs emitted as sticky state fields** | Dialogs re-appear on hot restart, back-navigation, or screen rotation because the state persists | Treat side-effects (navigation, toasts, dialogs) as `BlocListener` concerns; emit a one-shot event state and clear it immediately |
| 5 | **Repository registered as a `factory` instead of `lazySingleton`** | A new repository instance (and its network client) is created for every cubit — memory and connection overhead | Register repository as `registerLazySingleton<HomeRepository>(...)`; register cubit as `registerFactory<HomeCubit>(...)` |
| 6 | **Cubit depends on the repository implementation, not the interface** | Swapping data sources (e.g., local cache vs remote) requires changing cubit code; unit tests can't inject a fake | Cubit constructor takes `HomeRepository` (the `domain/` interface); only `home_module.dart` wires in `HomeRepositoryImpl` |
| 7 | **`BuildContext` passed into or captured by a cubit** | `setState after dispose` errors; cubit holds a stale context reference after the widget is unmounted | Cubits must never hold or use `BuildContext`; emit state and let `BlocListener`/`BlocBuilder` in the widget react |
| 8 | **Using `setState` for async/shared state instead of a cubit** | Loading and error booleans duplicated across widgets; state is not observable from other parts of the feature | Use `Cubit` for any async or shared state; reserve `setState` for purely local, synchronous UI concerns (e.g., toggle focus) |

## Quick Summary

- **Repository interface in `domain/`** — data impl in `data/`; cubit only depends on the interface.
- **Sealed state hierarchy** with `initial`, `loading`, `empty`, `loaded`, `error` variants; all extend `Equatable` with `props`.
- **`BaseCubit` + `safeEmit()`** — never call raw `emit()` after an `await`; `BaseCubit` handles the lifecycle guard.
- **One DI module per feature** — `registerXxxModule(GetIt getIt)` registers repository (lazy singleton) and cubit (factory).
- **Cubits own async orchestration** — no `FutureBuilder`, no business logic in widgets.
- **Side-effects via `BlocListener`** — navigation and dialogs are listener concerns, not sticky state.
- **Keep `BuildContext` out of cubits** — cubits emit state; widgets react.

## Cross-references

- [flutter-base-classes](../../flutter-base-classes/references/template.md) — `BaseCubit`, `BasePaginatedCubit`, `BaseRepository`, and `UseCase` base classes that every feature layer extends
- [flutter-architecture](../../flutter-architecture/references/template.md) — full clean-architecture layer boundaries, SOLID rules, and where domain logic lives
- [flutter-di](../../flutter-di/references/template.md) — feature module registration pattern (`registerFactory` for cubits, `registerLazySingleton` for repositories)
- [flutter-loading](../../flutter-loading/references/template.md) — `SuperListView` for paginated list pages with shimmer, error, and empty states
- [flutter-common-widgets](../../flutter-common-widgets/references/template.md) — app bars, buttons, fields, and cards used in the UI layer of each feature

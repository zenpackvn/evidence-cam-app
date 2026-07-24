# Template — Clean Architecture

Full clean-architecture feature with all layers: presentation → domain → data. Use this when a feature is complex enough to justify explicit boundaries. For simple features, use the lighter [template-feature-example.md](template-feature-example.md) instead. Part of the [DI template](template-di.md).

## Reference Files

Load only the file(s) relevant to the task.

| Topic | File |
|---|---|
| Layer diagram & folder structure | [layer_overview.md](layer_overview.md) |
| Domain layer (entities, repository contract, use cases) | [domain_layer.md](domain_layer.md) |
| Data layer (DTOs, data source, repository impl) | [data_layer.md](data_layer.md) |
| Presentation layer (cubits, states, pages, widgets) | [presentation_layer.md](presentation_layer.md) |
| DI module & route wiring | [di_and_routing.md](di_and_routing.md) |
| Tests (fake repo, cubit tests) | [tests.md](tests.md) |
| When to use full vs simple architecture + Feature Blueprint | [when_to_use.md](when_to_use.md) |
| Rules, anti-patterns, SOLID, DRY | [rules_and_antipatterns.md](rules_and_antipatterns.md) |

---

## ⚠️ Common Mistakes

> These are the most frequent architecture violations found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **Cubit depends on repository directly** | Use case layer bypassed — business rules have no home, testing requires mocking the full repo | Cubit constructor takes `UseCase`, not `Repository`. Every feature action must have a `UseCase` class |
| 2 | **Presentation imports a DTO** | Data-layer type leaks into UI — swap the network lib and the UI breaks | Pages and cubits import only domain entities. DTOs never leave `data/` |
| 3 | **Domain entity imports a third-party package** | Domain is no longer pure — can't run domain tests without the full stack | Domain imports `equatable` only. No `json_annotation`, no `dio`, no anything else |
| 4 | **Repository impl throws `DioException`** | Cubit must know about network internals — layer boundary violated | Repository catches all exceptions and re-throws as `FailureException(ServerFailure(...))`. Cubit catches only `FailureException` |
| 5 | **`toEntity()` mapping done in the cubit** | Cubit knows about DTOs — presentation depends on data layer | `toEntity()` lives on the DTO class. Repository returns domain entities; cubit receives entities |
| 6 | **Cubit registered as `registerLazySingleton`** | State leaks across screen navigations | All cubits are `registerFactory`. Only app-lifetime singletons (e.g., `AuthCubit`) are `registerLazySingleton` |
| 7 | **`*_impl.dart` imported outside the DI module** | Concrete type exposed beyond the composition root | Only `di/<feature>_module.dart` imports `*_impl.dart`. Everything else imports the abstract interface |
| 8 | **Forgot to run `build_runner` after changing a DTO** | Stale `.g.dart` → compile errors or silent wrong JSON parsing | Always run `dart run build_runner build --delete-conflicting-outputs` after any `@JsonSerializable` change |

---

## Quick Summary

### Import Rules

| Layer | May import | May NOT import |
|---|---|---|
| Domain | `equatable` only | `data/`, `presentation/`, any third-party |
| Data | `domain/` | `presentation/` |
| Presentation | `domain/` (entities, use cases) | `data/` (DTOs, sources, `*_impl`) |
| DI module | Everything | — |

### Key Rules (full list in [rules_and_antipatterns.md](rules_and_antipatterns.md))

- Domain has **zero** imports from data or presentation.
- DTOs stay in data — `toEntity()` maps to domain entities.
- Repository impl catches raw exceptions → throws `FailureException`.
- **Use cases are required** — cubits depend on use cases, never on repositories directly.
- Cubits are **always `registerFactory`**, never `registerLazySingleton`.
- After changing DTOs: `dart run build_runner build --delete-conflicting-outputs`.

## Cross-references

- [flutter-base-classes](../../flutter-base-classes/references/template.md) — BaseEntity, BaseCubit, UseCase, BaseRepository base classes used at every layer
- [flutter-di](../../flutter-di/references/template.md) — feature DI module pattern and composition-root registration order
- [flutter-network](../../flutter-network/references/template.md) — DioClient, ApiClient, and Failure hierarchy for the data layer
- [flutter-feature](../../flutter-feature/references/template.md) — end-to-end vertical slice example using all layers

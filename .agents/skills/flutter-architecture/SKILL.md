---
name: flutter-architecture
description: Use this skill when implementing Flutter clean architecture — feature folder structure, domain layer, data layer, presentation layer, entities, DTOs, data sources (remote/local), repository interface and implementation, use cases, clean architecture layers, feature blueprint, or end-to-end feature wiring across all clean arch layers.
---

# Flutter Architecture

Full reference: [`template.md`](references/template.md)

## Feature folder structure

```
lib/src/features/<feature>/
  domain/
    entities/          ← pure Dart, Equatable, immutable
    repositories/      ← abstract interface (contract)
    usecases/          ← one class per use case, extends UseCase<T, Params>
  data/
    dtos/              ← @JsonSerializable, toEntity(), fromJson()
    data_sources/      ← interface + impl (remote wraps ApiClient, local wraps DAO)
    repositories/      ← implements domain interface, uses BaseRepository mixin
  presentation/
    cubit/             ← extends BaseCubit, depends on use cases only
    pages/             ← BasePage, BlocProvider at page level
    widgets/           ← feature-private widgets
  di/
    <feature>_module.dart  ← registers this feature's deps into getIt
```

## Key rules

- **Domain layer has zero Flutter/third-party imports.** Only pure Dart + `equatable`.
- **Cubits never import repositories** — only use cases.
- **Data sources are the only layer that knows about network/DB.** Remote data source imports `ApiClient`. Local imports DAO.
- **Repository impl** uses `BaseRepository.safeCall` to wrap errors. Maps DTOs → entities.
- **Use cases are thin** — one `call()` method, delegates to repository. No business logic in the use case itself.
- Features must not import other features' `domain/` or `data/` layers. Cross-feature communication goes through `core/`.

## Layer dependency direction

```
presentation → domain ← data
presentation: cubit → use case → repository interface
data: repository impl → data source → ApiClient/DAO
```

## SOLID in Flutter clean architecture

| Principle | How it maps |
|---|---|
| **S** — Single Responsibility | One use case per class. One cubit per feature screen. Data source only talks to network/DB; repository only maps and guards errors. |
| **O** — Open/Closed | Add behaviour by adding new use cases or repository methods, never by modifying existing ones. Extend `BaseRepository`, `BaseCubit` — don't patch them. |
| **L** — Liskov Substitution | `RepositoryImpl` must be a drop-in for its interface. `MockRepository` in tests must honour the same contract. Any impl that changes observable behaviour (throws when interface says it won't) is a violation. |
| **I** — Interface Segregation | Repository interfaces expose only what the feature needs — split `TaskReadRepository` / `TaskWriteRepository` rather than one fat interface when cubits only read or only write. Data sources have separate `RemoteDataSource` and `LocalDataSource` interfaces. |
| **D** — Dependency Inversion | Cubits depend on `UseCase`, not `RepositoryImpl`. Use cases depend on repository *interfaces*, not impls. DI module wires the concrete impl — nothing else knows about it. |

### Violation checklist

- Cubit imports a repository impl directly → **D violation**
- Use case contains conditional logic beyond delegation → **S violation**
- Adding a new screen forces editing an existing use case → **O violation**
- Test mock returns values the real impl never would → **L violation**
- Cubit receives a repository with 10 methods but uses 1 → **I violation**

## DRY in Flutter clean architecture

DRY (Don't Repeat Yourself) — every piece of knowledge has a single authoritative source. Duplication is not just copy-pasted code; it is duplicated *logic*, *structure*, or *decision*.

| Where duplication appears | DRY fix |
|---|---|
| Same API parsing in multiple data sources | Extract to `BaseDto.fromJson()` or a shared mapper |
| Same error-wrapping try/catch in every repository method | Use `BaseRepository.safeCall()` — one place owns error mapping |
| Same validation rule in multiple form cubits | Extract to `FormValidator` composable in `core/forms/` |
| Same loading/error/empty state handling per cubit | `BaseCubit` + `BaseState` — not repeated per feature |
| Same paginated fetch logic in every list cubit | `BasePaginatedCubit` handles page/offset bookkeeping once |
| Same network request boilerplate in every data source | `ApiClient` owns headers, base URL, interceptors — data sources only supply the path |
| Feature A re-implementing Feature B's entity | Cross-feature entity lives in `core/` or Feature B's domain — Feature A imports it, never copies it |
| Same offline remote→local fallback block in multiple repository methods | Extract a private `_withLocalFallback()` helper — one place owns the pattern |

### Violation checklist

- Two data sources contain identical JSON parsing for the same shape → extract shared DTO
- Two cubits have identical `isLoading` / `hasError` fields → use `BaseState` sealed classes
- Two repository impls have identical `try { … } on DioException { … }` blocks → `safeCall` is missing
- Two validators repeat the same regex or length check → missing composable validator in `core/forms/`
- A DTO is copy-pasted into a second feature with minor field changes → wrong, share or extend
- Two repository methods repeat the same try/catch+warn+fallback block → extract `_withLocalFallback()` helper

### What is NOT a DRY violation

- Two use cases that call the same repository method with different params — that is composition, not duplication.
- Two widgets that look similar but respond to different state shapes — coincidental similarity, not shared knowledge.

## Co-load with

- `flutter-base-classes` — BaseEntity, BaseCubit, UseCase, BaseRepository
- `flutter-di` — feature DI module pattern
- `flutter-network` — data source → ApiClient
- `flutter-feature` — end-to-end example

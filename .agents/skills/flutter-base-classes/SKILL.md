---
name: flutter-base-classes
description: Use this skill when implementing Flutter base classes — BaseEntity, BaseDto, BaseCubit, BaseState, BasePaginatedCubit, SafeEmitMixin, BaseHydratedCubit, EnumHydratedCubit, hydrated state persistence, BasePage, BaseStatefulPage, BaseRepository, UseCase, StreamUseCase, NoParams, safeEmit vs emit, sealed states with Equatable, or reducing boilerplate across features.
---

# Flutter Base Classes

Full reference: [`template.md`](references/template.md)

## Key rules

### Cubit
- All cubits extend `BaseCubit<State>` or use `SafeEmitMixin`. **Never call raw `emit()`** — always `safeEmit()` (guards against closed-cubit errors).
- `BaseHydratedCubit<S>` — extends `HydratedCubit<S> with SafeEmitMixin<S>`. Use when state must survive process death. Only `base_hydrated_cubit.dart` imports `hydrated_bloc`.
- `EnumHydratedCubit<E extends Enum>` — extends `BaseHydratedCubit<E>`. Eliminates duplicated `fromJson`/`toJson` for enum-based settings (theme, language). Subclass declares `values`, `jsonKey`, `defaultValue`.
- States are `sealed` classes extending `Equatable`. No boolean flags in state — use separate state subclasses.
- Cubits depend on **use cases**, never on repositories directly.

### Use cases
- Extend `UseCase<Return, Params>` or `StreamUseCase<Return, Params>`.
- Use `NoParams` for no-argument use cases. Use a record typedef (`typedef FooParams = ({String x, int y})`) for multi-param.
- File: `*_usecase.dart`. Class: `*UseCase`.

### Repository
- Use `BaseRepository` mixin. It provides `safeCall<T>()` (catches `FailureException` → rethrows; catches others → wraps as `UnknownFailure`) and `mapToEntities<D,E>()`.
- `AppLogger` injected via constructor, exposed as `AppLogger get logger`.

### Entity / DTO
- Entities: extend `BaseEntity` (or just `Equatable`), immutable, no `fromJson`. Live in `domain/entities/`.
- DTOs: extend `BaseDto`, annotated `@JsonSerializable()`, expose `toEntity()`. Live in `data/dtos/`.

### Paginated cubit
- Use `BasePaginatedCubit<Item>` for lists with load-more. States: `PaginatedInitial`, `PaginatedLoading`, `PaginatedLoaded`, `PaginatedEmpty`, `PaginatedError`.

## Co-load with

- `flutter-architecture` — how base classes fit into clean-arch layers
- `flutter-di` — cubits as `registerFactory`
- `flutter-network` — `BaseRepository.safeCall` catches `FailureException`

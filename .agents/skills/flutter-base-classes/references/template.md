# Template — Base Classes

Foundational abstract classes that all features inherit from: base entity, base DTO, base cubit, base state, base page, base repository, and use case. Eliminates repetitive boilerplate while enforcing consistent patterns across every feature. Part of the project layout in [template-app-shell.md](template-app-shell.md).

No third-party packages beyond `equatable` (already in stack) and `flutter_bloc` (already in stack). The wrapper rule is trivially satisfied — these are pure Dart/Flutter classes.

## Class Reference Files

Each base class has its own file. Load only the file(s) relevant to the task.

| Class(es) | File | Purpose |
|---|---|---|
| `BaseEntity`, `Identifiable` | [base_entity.md](base_entity.md) | Domain entities with ID + timestamps |
| `BaseDto<E>` | [base_dto.md](base_dto.md) | DTO with `toEntity()` contract |
| `SafeEmitMixin` | [safe_emit_mixin.md](safe_emit_mixin.md) | Guarded `emit` for mutation cubits |
| `BaseCubit<T>` | [base_cubit.md](base_cubit.md) | Fetch-data lifecycle cubit |
| `BasePaginatedCubit<T>` | [base_paginated_cubit.md](base_paginated_cubit.md) | Paginated list cubit |
| `BaseHydratedCubit<S>` | [base_hydrated_cubit.md](base_hydrated_cubit.md) | Persisted state cubit |
| `EnumHydratedCubit<E>` | [enum_hydrated_cubit.md](enum_hydrated_cubit.md) | Enum settings cubit (no serialization boilerplate) |
| `BaseState<T>`, `PaginatedState<T>` | [base_state.md](base_state.md) | Sealed state variants |
| `BaseRepository` | [base_repository.md](base_repository.md) | `safeCall()` + `mapToEntities()` mixin |
| `BasePage<C, T>` | [base_page.md](base_page.md) | StatelessWidget with state→UI mapping |
| `BaseStatefulPage<C, S>` | [base_stateful_page.md](base_stateful_page.md) | StatefulWidget with lifecycle hooks |
| `UseCase<T, P>`, `StreamUseCase<T, P>`, `NoParams` | [use_case.md](use_case.md) | Use case base classes |
| Barrel export (`base.dart`) | [base_barrel.md](base_barrel.md) | `export` all base classes |

## Folder structure

```text
lib/src/core/
  base/
    base_entity.dart
    base_dto.dart
    base_cubit.dart
    safe_emit_mixin.dart
    base_hydrated_cubit.dart
    enum_hydrated_cubit.dart
    base_paginated_cubit.dart
    base_state.dart
    base_page.dart
    base_stateful_page.dart
    base_repository.dart
    use_case.dart
    base.dart                        ← Barrel export
```

## When to use which cubit base

| Scenario | Use |
|---|---|
| Fetch and display data | `BaseCubit<T>` |
| Mutations, form submissions, settings | `Cubit<S> with SafeEmitMixin<S>` |
| State that must survive process death | `BaseHydratedCubit<S>` |
| Single enum setting, persisted | `EnumHydratedCubit<E>` |
| Paginated list | `BasePaginatedCubit<T>` |
| Complex state machine (auth, onboarding) | Custom sealed states — skip base classes |
| Simple toggle / local state | Plain `Cubit` is fine |

## When to use which entity base

| Scenario | Use |
|---|---|
| API/database entity with ID + timestamps | `BaseEntity` |
| Lightweight tag/category (ID only) | `Identifiable` |
| Value object (Address, Money) | `Equatable` directly |

## When to use which page base

| Scenario | Use |
|---|---|
| Standard load/display flow, no controllers | `BasePage<C, T>` |
| Needs scroll/text/focus controllers | `BaseStatefulPage<C, S>` |

---

## ⚠️ Common Mistakes

> These are the most frequent base class bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **Raw `emit()` instead of `safeEmit()`** | `StateError: Bad state: Cannot emit new states after calling close` thrown in tests or after fast navigation | Use `safeEmit()` (inherited from `SafeEmitMixin`) everywhere; never call raw `emit()` in any cubit that extends a base class or uses the mixin |
| 2 | **Cubit depends directly on a repository instead of a use case** | Architecture layer violation caught in review; impossible to unit-test the cubit without mocking a full repository | Cubits must inject and call `UseCase<T, P>` subclasses; only use cases may hold a repository reference |
| 3 | **Repository method has its own try/catch instead of `safeCall()`** | Repeated error-handling boilerplate; error types are inconsistent across methods; `FailureException` may be double-wrapped | Replace every try/catch in a repository method with `return safeCall(() async => ..., tag: 'methodName')` from `BaseRepository` |
| 4 | **`BaseRepository` used as an abstract class instead of a mixin** | Compile error: impl cannot extend `BaseRepository` and also `implements` the domain interface | Declare as `class UserRepositoryImpl implements UserRepository with BaseRepository` — `with`, not `extends` |
| 5 | **Page duplicates loading/error/empty branches in `BlocBuilder`** | Boilerplate repeated in every page; custom error and empty views diverge over time | Extend `BasePage<C, T>` and override only `buildSuccess()`; override `buildEmpty()` and `buildError()` only when the default UI is insufficient |
| 6 | **`BaseHydratedCubit` used for a fetch-only cubit** | Unnecessary JSON serialization overhead; `fromJson`/`toJson` written but never meaningfully tested | Use `BaseCubit<T>` for standard fetch flows; reserve `BaseHydratedCubit<S>` only for state that must survive process death |
| 7 | **Value object extending `BaseEntity` instead of `Equatable`** | Unnecessary `id`, `createdAt`, `updatedAt` fields on types like `Money` or `Address` that have no server identity | Extend `Equatable` directly for value objects; use `BaseEntity` only for server-backed objects with an ID and timestamps |
| 8 | **Inheritance chain deeper than two levels** | `PremiumUser extends User extends BaseEntity` — third layer; fragile coupling; overriding `props` is error-prone | Keep inheritance at one level: `MyEntity extends BaseEntity`. Add behaviour via composition or mixins, not deeper subclasses |

## Quick Summary

- **`safeEmit()`, never `emit()`** — prevents `StateError` after cubit close; `SafeEmitMixin` provides it; raw `emit()` is banned in any cubit that uses a base class.
- **Cubits depend on use cases, not repositories** — `BaseCubit` injects a `UseCase`; only the use case holds the repository reference. This is non-negotiable.
- **`BaseRepository` is a mixin** — declare `class MyRepoImpl implements MyRepo with BaseRepository`; use `safeCall()` to eliminate per-method try/catch boilerplate.
- **`BasePage` eliminates branch boilerplate** — override `buildSuccess()` only; `buildLoading()`, `buildError()`, and `buildEmpty()` have sensible defaults.
- **Pick the right cubit base**: `BaseCubit` for fetch, `SafeEmitMixin` for mutations, `BasePaginatedCubit` for lists, `BaseHydratedCubit` for persisted state, `EnumHydratedCubit` for single-enum settings.
- **`BaseEntity` for server objects, `Equatable` for value objects** — `BaseEntity` implies an `id` and timestamps; don't add those to `Money`, `Address`, or other value types.
- **Max one level of inheritance** — `MyEntity extends BaseEntity` is the limit; add behaviour via composition or mixins, not deeper subclass chains.
- **Test base classes once** — feature cubits extending `BaseCubit` only need to test `fetchData()` and custom actions; the base lifecycle is already tested.

---

## Complete feature example

All base classes working together in an Order Detail feature — see individual files for full code. Summary:

| Layer | File | Base class |
|---|---|---|
| Entity | `order.dart` | `BaseEntity` |
| DTO | `order_dto.dart` | `BaseDto<Order>` |
| Repository | `order_repository_impl.dart` | `with BaseRepository` |
| Cubit | `order_detail_cubit.dart` | `BaseCubit<Order>` |
| Page | `order_detail_page.dart` | `BasePage<OrderDetailCubit, Order>` |

5 files, ~30 lines of feature code — all boilerplate is in the base classes.

---

## Rules

1. **Extend, don't force** — base classes are defaults, not mandates. Skip when the feature needs custom state shape.
2. **`BaseEntity` for server objects** — entities with an API/database ID and timestamps extend `BaseEntity`. Value objects extend `Equatable` directly.
3. **`BaseDto<E>` enforces `toEntity()`** — every DTO must convert to its domain entity. Compile-time guarantee.
4. **`BaseCubit<T>` for standard flows** — override `fetchData()` only. Use `safeEmit()` for custom actions.
5. **`BasePaginatedCubit<T>` for lists** — override `fetchPage()` only.
6. **`BaseRepository` mixin, not abstract class** — `with BaseRepository` so the impl can still `implements` the domain interface.
7. **`BasePage` for state → UI mapping** — override `buildSuccess()`, optionally `buildEmpty()`, `buildError()`, `buildLoading()`.
8. **Equality by ID** — `BaseEntity` and `Identifiable` use `[id]` as `props`. Subclasses add their own via `[...super.props, ...]`.
9. **Don't nest base classes deeply** — `User extends BaseEntity` is fine. `PremiumUser extends User extends BaseEntity` is the maximum.
10. **Test base classes once, features lightly** — feature cubits using `BaseCubit` only test `fetchData()` and custom actions.
11. **`UseCase<T, Params>` for every feature action** — cubits depend on use cases, **never on repositories directly**. Naming: file `<action>_<entity>_use_case.dart`, class `<Action><Entity>UseCase`.

---

## Anti-patterns

### DON'T — Repeat try/catch in every repository method

```dart
// BAD
@override
Future<User> getUser(String id) async {
  try {
    final dto = await remoteSource.getUser(id);
    return dto.toEntity();
  } catch (e, s) {
    logger.error('getUser failed', error: e, stackTrace: s);
    throw const FailureException(ServerFailure('Failed'));
  }
}

// DO — one line
@override
Future<User> getUser(String id) => safeCall(
      () async => (await remoteSource.getUser(id)).toEntity(),
      tag: 'getUser($id)',
    );
```

### DON'T — Duplicate loading/error/empty handling in every page

```dart
// BAD
BlocBuilder<UserCubit, UserState>(
  builder: (context, state) {
    if (state is UserLoading) return const CircularProgressIndicator();
    if (state is UserError) return Text(state.failure.message);
    if (state is UserLoaded) return UserContent(user: state.user);
    return const SizedBox.shrink();
  },
)

// DO
class UserPage extends BasePage<UserCubit, User> {
  @override
  Widget buildSuccess(BuildContext context, User user) => UserContent(user: user);
}
```

### DON'T — Emit after cubit is closed

```dart
// BAD — can throw StateError
emit(BaseSuccess(data));

// DO — no-op if already closed
safeEmit(BaseSuccess(data));
```

---

## Cross-references

- [template-architecture.md](template-architecture.md) — clean architecture layers. Base classes standardize each layer.
- [template-di.md](template-di.md) — feature DI modules register concrete cubits/repos that extend base classes.
- [template-network.md](template-network.md) — `Failure` hierarchy and `FailureException`. `BaseRepository.safeCall()` wraps errors into this hierarchy.
- [template-loading.md](template-loading.md) — `SuperListView` works with `BasePaginatedCubit` states.
- [template-tests.md](template-tests.md) — `bloc_test` patterns for testing cubits that extend `BaseCubit`.

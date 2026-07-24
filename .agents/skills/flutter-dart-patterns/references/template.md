# Template — Dart 3 Patterns

Modern Dart 3 language features used throughout the Flutter app stack: records, sealed classes, pattern matching, extension methods, mixins, and typedefs — with real examples from the architecture.

## Topics

| Topic | File |
|---|---|
| Records — anonymous value types, multi-value returns, destructuring | [records.md](records.md) |
| Sealed Classes — closed type hierarchies, exhaustive switch, failure/state hierarchies | [sealed_classes.md](sealed_classes.md) |
| Extension Methods — `BuildContext`, `String`, `DateTime`, nullable extensions | [extension_methods.md](extension_methods.md) |
| Mixins — `SafeEmitMixin`, `BaseRepository`, combining mixins | [mixins.md](mixins.md) |
| Pattern Matching — destructuring, guard clauses, `if-case`, list/map patterns | [pattern_matching.md](pattern_matching.md) |
| Typedefs and Use Case Base Class — record typedefs, callback typedefs, `UseCase<O,I>` | [typedefs_and_use_cases.md](typedefs_and_use_cases.md) |
| Anti-Patterns | [anti_patterns.md](anti_patterns.md) |

## ⚠️ Common Mistakes

> These are the most frequent Dart 3 patterns bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **Creating a dedicated 2–3 field result class instead of a record typedef** | Boilerplate data class with no methods or validation; forces callers to import an extra file | Use a named record typedef: `typedef TaskPage = ({List<Task> tasks, bool hasMore, int totalCount})` and destructure at the call site with `final (:tasks, :hasMore, :totalCount) = result` |
| 2 | **`if (state is X) / else if (state is Y)` chains on sealed classes** | New state subtype added later compiles silently but is never handled — falls through to an implicit else branch | Use an exhaustive `switch` expression on the sealed type; the compiler enforces all variants are covered when a new subtype is added |
| 3 | **Wildcard `_` default in a sealed-type switch** | A new sealed variant added later silently falls into the wildcard; the missing case goes undetected until runtime | Name every variant explicitly in the switch arms; remove the `_` catch-all so the compiler reports unhandled cases |
| 4 | **Raw `emit()` in a cubit without `SafeEmitMixin`** | `Bad state: emit was called after close` exception during widget tests or after navigation when async calls complete after the cubit is disposed | Extend cubits with `SafeEmitMixin<S> on Cubit<S>` and call `safeEmit(state)` instead of `emit(state)` |
| 5 | **Static utility file (`string_utils.dart`, `date_utils.dart`) instead of extension methods** | Callers write `StringUtils.capitalize(value)` instead of `value.capitalize()`; utilities are disconnected from the type they operate on | Define `extension StringX on String` in `lib/src/core/extensions/` and call the method directly on the value |
| 6 | **Raw `Map<String, dynamic>` type repeated in every method signature** | Verbose, inconsistent signatures; easy to pass the wrong map type silently | Declare `typedef JsonMap = Map<String, dynamic>` once and use `JsonMap` throughout — one grep shows every usage |
| 7 | **Use-case class with no `UseCase<Output, Input>` base** | No contract enforcing `call()` signature; callers must read each class to discover its API | Implement `UseCase<O, I>` on every use case: `final class GetTasksUseCase extends UseCase<TaskPage, PageParams>` |
| 8 | **Mixin without an `on` constraint** | Mixin can be applied to any class, including ones that lack the required state or lifecycle; silent misuse at compile time | Add `on` constraint: `mixin SafeEmitMixin<S> on Cubit<S>` so the compiler rejects incorrect application |

## Quick Summary

- **Records for multi-value returns** — use named records (`({String name, int age})`) with typedefs (`typedef TaskPage = ({...})`). Never create a dedicated result class for 2–3 fields.
- **Sealed classes for state and failures** — mark subtypes `final`; use exhaustive `switch` expressions, never `if (state is X)` chains.
- **Extensions over utility files** — attach behavior to the type it belongs to (`extension StringX on String`), not a static `utils.dart`.
- **Mixins with `on` constraints** — `SafeEmitMixin<S> on Cubit<S>` prevents raw `emit()` calls; `BaseRepository` converts all exceptions to typed `AppFailure`.
- **Pattern matching with `when` guards** — use `switch` expressions on sealed types; use `if-case` for single-pattern checks.
- **Typedefs for all complex types** — `typedef JsonMap = Map<String, dynamic>`, `typedef OnTaskSelected = void Function(Task)`.
- **Every use case implements `UseCase<Output, Input>`** — no bare classes with ad-hoc `execute()` methods.

## Cross-references

- [flutter-base-classes](../../flutter-base-classes/references/template.md) — `BaseCubit`, `BaseRepository`, and `SafeEmitMixin` are the primary consumers of these Dart 3 patterns
- [flutter-architecture](../../flutter-architecture/references/template.md) — sealed `Failure` hierarchy and use case record return types rely on these patterns
- [flutter-feature](../../flutter-feature/references/template.md) — cubit sealed state classes and `switch` in `BlocBuilder` apply these patterns end-to-end
- [flutter-error-handling](../../flutter-error-handling/references/template.md) — sealed `AppFailure` hierarchy uses sealed classes and exhaustive switch expressions

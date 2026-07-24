# Template — Tests

Unit tests, widget tests, golden tests, integration tests, coverage enforcement, and review checklist. Part of the project layout in [template-app-shell.md](template-app-shell.md).

## Topics

| Topic | File |
|---|---|
| Folder structure, pubspec, shared fakes, pumpApp helper, DI test pattern | [shared_test_helpers.md](shared_test_helpers.md) |
| Bloc tests (bloc_test, verify, seed), widget tests, repository tests | [bloc_and_widget_tests.md](bloc_and_widget_tests.md) |
| Golden tests, integration tests, smoke test | [golden_and_integration_tests.md](golden_and_integration_tests.md) |
| Coverage threshold script, review checklist, anti-patterns | [coverage_and_review.md](coverage_and_review.md) |

## ⚠️ Common Mistakes

> These are the most frequent testing bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **`when(repo.method)` instead of `when(() => repo.method())`** | `MissingStubError` at runtime; test fails with "no stub found" even though `when` was called | Use the closure syntax mandatory for mocktail: `when(() => repo.fetchPosts())` — the bare method reference form is not supported |
| 2 | **`getIt.reset()` skipped in `setUp`** | Tests pass in isolation but fail when run as a suite; `getIt` throws "already registered" or returns a stale fake | Call `await getIt.reset()` as the first line of every `setUp` that touches DI to guarantee a clean slate between tests |
| 3 | **Real `ApiClient`/`Dio` used in unit tests** | Tests make actual HTTP calls; CI fails without network or returns unexpected data | Mock `ApiClient` (the app-owned interface), never `Dio` directly; inject `MockApiClient` into the repository under test |
| 4 | **`tester.pump()` used when `tester.pumpAndSettle()` is needed** | Widget test asserts run before async operations complete; `find.byType(X)` returns nothing | Use `tester.pumpAndSettle()` after interactions that trigger animations or async state changes; use `tester.pump(duration)` only when `pumpAndSettle` would time out on infinite animations |
| 5 | **Missing error and empty state tests for cubits** | Error-handling paths are untested; regressions introduced silently | Every `blocTest` group must include at minimum: success, empty list, and `FailureException` error cases — not just the happy path |
| 6 | **`blocTest` missing `setUp` for stub registration** | `MissingStubError` because `when` is called outside the `blocTest` lifecycle | Put all `when(...)` stub registrations inside the `blocTest` `setUp` parameter, not in the outer `group` `setUp` |
| 7 | **Golden files committed without reviewing the diff** | Incorrect UI silently becomes the new baseline; visual regressions go undetected | Run `flutter test --update-goldens` locally, open the regenerated PNG files, and review the visual diff before committing |
| 8 | **`getIt<Cubit>()` resolved inside `blocTest` `build`** | Test uses the DI-registered instance, bypassing injected fakes; stubs have no effect | Pass fakes directly to the cubit constructor in `build: () => MyCubit(fakeRepo)` — resolve from `getIt` only when testing DI wiring explicitly |

## Quick Summary

- **Every cubit/bloc gets a `bloc_test`** — test all state transitions: success, empty, error, edge cases.
- **Every page gets a widget test** — test rendering for each state (loading, loaded, empty, error) and key interactions (tap, submit).
- **Golden tests for visual regression** — capture key states, review diffs before committing updates with `--update-goldens`.
- **Integration tests for critical flows** — sign in, main navigation, core feature happy path.
- **Coverage threshold at 80%** — enforced in CI. Exclude generated files (`*.g.dart`, `*.freezed.dart`).
- **Prefer fakes over mocks** — implement the interface directly for simple cases. Use `mocktail` mocks when you need `when()`/`verify()`.
- **mocktail closure syntax is mandatory** — use `when(() => repo.method())`, never `when(repo.method)`.
- **Always `getIt.reset()` in setUp** — skipping it causes state leaks between tests and flaky failures.
- **Test behavior, not implementation** — assert on states and visible output, not internal method calls.

## Cross-references

- [flutter-ci](../../flutter-ci/references/template.md) — coverage gate and test job run in CI; `check_coverage.sh` lives here
- [flutter-base-classes](../../flutter-base-classes/references/template.md) — `BaseCubit` and `safeEmit` behavior that unit tests verify

---
name: flutter-tests
description: Use this skill when writing Flutter tests — unit tests, bloc_test, BLoC tests, cubit tests, widget tests, golden tests, integration tests, mocktail mocks, test coverage, coverage gate, writing test cases for use cases, repositories, cubits, pages, or setting up the test infrastructure for a Flutter project.
---

# Flutter Tests

Full reference: [`template.md`](references/template.md)

## Key rules

### Cubit / BLoC tests
- Use `bloc_test` (`blocTest<C, S>(...)`) for all cubit tests. Never test cubits with `pump()` in widget tests.
- Mock dependencies with `mocktail`. Register fallback values in `setUpAll` for any custom type used with `any()`.
- Use `InMemoryStorage` for `HydratedCubit` tests — never real disk.
- Test state sequence exactly: `expect: () => [isA<Loading>(), isA<Loaded>()]`.

### Use case / Repository tests
- Use cases are thin wrappers — verify delegation (correct method called, correct params, result passed through).
- Repository tests: mock data sources, test online/offline paths, error wrapping (`FailureException` rethrown, generic → `UnknownFailure`).

### Widget tests
- `pumpApp(widget)` helper sets up `MaterialApp`, theme, localization, and test DI.
- Test user interactions with `tester.tap(find.byKey(...))` + `tester.pump()`.
- `BlocProvider` wraps the widget with a pre-configured mock cubit.

### Golden tests
- One golden per component state. Run `flutter test --update-goldens` for intentional visual changes.
- `GoldenToolkit` / `MatchesGoldenFile` for multi-device golden comparison.

### Coverage gate
- `scripts/check_coverage.sh <threshold>` enforces coverage on presentation+core layers.
- Exclude: generated files (`*.g.dart`), data sources, DI modules, platform wrappers.
- Target: ≥ 80% on cubit + state + core layers.

## Co-load with

- `flutter-ci` — coverage gate runs in CI
- `flutter-base-classes` — `BaseCubit`, `safeEmit` behavior to test

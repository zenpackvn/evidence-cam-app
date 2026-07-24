# Template — DI Composition Root

`service_locator.dart` wires the entire dependency graph using `get_it`. Every third-party package is hidden behind an app-owned interface; all registrations flow from a single composition root.

## Topics

| Topic | File |
|---|---|
| `service_locator.dart` — full composition root with registration order | [service_locator.md](service_locator.md) |
| The Two Rules — wrapper rule + one composition root | [two_rules.md](two_rules.md) |
| Lifetime rules — singleton vs lazy singleton vs factory | [lifetime_rules.md](lifetime_rules.md) |
| Feature modules — splitting large registration sets | [feature_modules.md](feature_modules.md) |
| Test override pattern — `getIt.reset()` + fake registration | [test_override.md](test_override.md) |
| Anti-patterns and review signals | [di_anti_patterns.md](di_anti_patterns.md) |

## ⚠️ Common Mistakes

> These are the most frequent DI bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **Cubit registered as `registerLazySingleton`** | State from screen A leaks into screen B when navigating back and forward | All cubits and blocs must use `registerFactory` — every `BlocProvider.create` gets a fresh instance |
| 2 | **`getIt<T>()` called inside `build()`** | New instance resolved on every rebuild; potential null if container is mid-reset | Resolve only at the router/page boundary: `BlocProvider(create: (_) => getIt<MyCubit>())` |
| 3 | **`getIt<T>()` called inside a cubit, use case, or repository** | Hidden service locator coupling — impossible to test without a live container | Inject all dependencies via constructor; `getIt` is only for the composition root |
| 4 | **Third-party package imported directly outside `*_impl.dart`** | Wrapper rule violated — swap requires touching every file that imports the package | All vendor imports stay in the single `*_impl.dart` file; everything else imports the interface |
| 5 | **Registration order wrong (e.g., `AuthInterceptor` before `TokenManager`)** | `ArgumentError`/null at startup — dependency not yet in container when resolved | Follow bottom-up order: Config → Logger → Storage → Network → Auth → AuthInterceptor → Features |
| 6 | **Feature module not called from `configureDependencies()`** | Feature cubits/repos return `StateError: Object not registered` at runtime | Every `register*Module(getIt)` call must appear in `service_locator.dart` |
| 7 | **Tests sharing a global `getIt` container between test cases** | State from test A bleeds into test B; flaky ordering-dependent tests | Call `await getIt.reset()` in `setUp`; prefer constructor injection in bloc tests to skip the container entirely |
| 8 | **Circular dependency resolved by reordering calls** | Works by accident; breaks when registration order changes | Break cycles with a shared lower-level module or interface, not by relying on call order |

---

## Quick Summary

- **Wrapper rule**: every third-party package is hidden behind one app-owned interface. Only `*_impl.dart` imports the vendor package. Grep for direct third-party imports outside `lib/src/core/**` — any match is a defect.
- **One composition root**: all `getIt.register...` calls live in `lib/src/core/di/service_locator.dart` or per-feature `<feature>/di/<feature>_module.dart`. Registrations scattered elsewhere are forbidden.
- **Blocs and cubits are always `registerFactory`** — never `registerLazySingleton`. Singleton cubits leak state across screens.
- **Inject via constructor, resolve at boundary** — `getIt<T>()` is only called at the router/page entry point (`BlocProvider.create`) or the outer page widget. Never inside `build()`, cubit, use case, or repository bodies.
- **Register bottom-up**: Config → Logger → Storage → Network → Auth → AuthInterceptor → Feature modules.
- **Break circular dependencies** with a shared lower-level module, not by reorganizing call order.
- **Tests reset the container**: `await getIt.reset()` in `setUp`, then register fakes explicitly. Prefer constructor injection in bloc tests to avoid the container entirely.

## Cross-references

- [flutter-app-shell](../../flutter-app-shell/references/template.md) — project layout and `service_locator.dart` entry point where the composition root lives
- [flutter-feature](../../flutter-feature/references/template.md) — per-feature DI modules (`<feature>_module.dart`) registered from the composition root
- [flutter-network](../../flutter-network/references/template.md) — `DioClient` and `ApiClient` registration order in the composition root
- [flutter-auth](../../flutter-auth/references/template.md) — `AuthService`, `TokenManager`, and `AuthInterceptor` registration and lifetime rules
- [flutter-base-classes](../../flutter-base-classes/references/template.md) — `BaseRepository` and `UseCase` base classes wired through DI constructor injection

# Template — App Shell

Entry point, bootstrap, root widget, config, `pubspec.yaml`, project layout, opinionated stack, and localization setup. This is the starting point for all greenfield Flutter projects.

## Reference Files

Load only the file(s) relevant to the task.

| Topic | File |
|---|---|
| Full project tree (all folders and files) | [folder_structure.md](folder_structure.md) |
| SDK version compatibility table + pubspec.yaml | [sdk_and_pubspec.md](sdk_and_pubspec.md) |
| Entry points (main_*.dart), bootstrap, app.dart | [entry_points_and_bootstrap.md](entry_points_and_bootstrap.md) |
| AppConfig, EnvConfig, flavor run commands | [config_and_flavors.md](config_and_flavors.md) |
| Opinionated stack table + optional add-ons | [opinionated_stack.md](opinionated_stack.md) |
| Index of all per-concern templates | [code_templates_index.md](code_templates_index.md) |
| Localization setup rules and pointers | [localization_setup.md](localization_setup.md) |
| Step-by-step greenfield bootstrap + architecture notes | [bootstrap_workflow.md](bootstrap_workflow.md) |

---

## ⚠️ Common Mistakes

> These are the most frequent app shell bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **Caret versions (`^`) in pubspec.yaml** | `flutter pub get` on a different machine resolves a newer breaking version; CI breaks unexpectedly | Use exact versions for every dependency (e.g., `flutter_bloc: 8.1.6`), never caret syntax |
| 2 | **Single `main.dart` entry point with no flavor separation** | Dev and prod share the same config; debug secrets leak into the release build | Create three entry points — `main_dev.dart`, `main_uat.dart`, `main_prod.dart` — each calling `bootstrap(Env.x)` |
| 3 | **Third-party package imported directly in a feature file** | Coupling to a specific package; changing the package requires touching every feature; wrapper rule violated | Only `*_impl.dart` files import third-party packages; feature files depend on app-owned interfaces registered in DI |
| 4 | **DI registrations scattered across multiple init functions outside `service_locator.dart`** | Dependencies registered in different orders depending on call site; `getIt` lookup throws `StateError` at runtime | All registrations go in `configureDependencies()` inside `service_locator.dart` — the single composition root |
| 5 | **Bloc/cubit registered as a singleton in `service_locator.dart`** | State leaks between navigations; second visit to a page shows stale data from the first visit | Register cubits as factories (`registerFactory`) except `AuthCubit`, which is the only cubit allowed as a singleton |
| 6 | **`build_runner` not run after adding a Retrofit endpoint or DTO** | `*.g.dart` file is stale or absent; `flutter analyze` reports missing generated symbols | Run `dart run build_runner build --delete-conflicting-outputs` after every DTO or Retrofit change; add it to the CI step before `flutter analyze` |
| 7 | **`WidgetsFlutterBinding.ensureInitialized()` called after async work in `main()`** | `MissingPluginException` or blank screen on startup when plugins are accessed before binding is ready | Call `WidgetsFlutterBinding.ensureInitialized()` as the very first line of `main()`, before any `await` |
| 8 | **`FlutterError.onError` and `PlatformDispatcher.instance.onError` not wired in bootstrap** | Uncaught Flutter framework errors and platform-level isolate errors are silently swallowed; no log or crash report | Wire both handlers inside `bootstrap()` using the `AppLogger` singleton; if Crashlytics is active, also call `crashReporter.recordError()` in each handler |

---

## Quick Summary

- **Exact version pins in pubspec** — never `^`. Reproducible builds across environments.
- **Three flavored entry points** — `main_dev.dart`, `main_uat.dart`, `main_prod.dart`, each calling `bootstrap(Env.x)`.
- **Every third-party package is wrapped** — feature code never imports `package:dio`, `package:logger`, etc. directly. Only `*_impl.dart` files import the package.
- **Composition root** — `configureDependencies()` in `service_locator.dart` is the single place all dependencies are registered.
- **Blocs/cubits are factories, never singletons** (except `AuthCubit` which holds global session state).
- **Codegen is a first-class build step** — run `dart run build_runner build --delete-conflicting-outputs` after any DTO or Retrofit change.
- **Do not add Firebase, Sentry, analytics, or CI unless requested** — full setup means runnable with the core stack wired end-to-end.

## Cross-references

- [flutter-di](../../flutter-di/references/template.md) — `configureDependencies()` composition-root rule, wrapper rule, and singleton vs. factory lifetime decisions
- [flutter-flavors](../../flutter-flavors/references/template.md) — `Env` enum, `EnvConfig`, `AppConfig`, and per-flavor entry points (`main_dev.dart`, `main_uat.dart`, `main_prod.dart`)
- [flutter-theme](../../flutter-theme/references/template.md) — `AppColors`, `AppSpacing`, `AppTypography`, and `AppTheme` token setup wired in the root widget
- [flutter-routing](../../flutter-routing/references/template.md) — `GoRouter` instance bootstrapped and injected from `service_locator.dart`; auth guard wired at startup
- [flutter-logging](../../flutter-logging/references/template.md) — `AppLogger` singleton wired in bootstrap; `FlutterError.onError` and `PlatformDispatcher.instance.onError` handlers
- [flutter-auth](../../flutter-auth/references/template.md) — `AuthCubit` registered as the sole singleton cubit; session state drives the auth guard in GoRouter

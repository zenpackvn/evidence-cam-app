# Template — Flavors & Environment Config

Per-environment configuration with typed config, separate entry points, and `--dart-define` overrides. No third-party package needed — flavors use pure Dart enums and multiple `main_*.dart` entry points.

Part of the project layout in [template-app-shell.md](template-app-shell.md).

## Topics

| Topic | File |
|---|---|
| `Env` enum, `EnvConfig` per-env values, `AppConfig` with `--dart-define` override support | [env_and_config.md](env_and_config.md) |
| Entry points (`main_dev`, `main_uat`, `main_prod`), updated bootstrap, DI composition root | [entry_points_and_bootstrap.md](entry_points_and_bootstrap.md) |
| VS Code launch configs, Android/iOS native flavors, testing with DI overrides, anti-patterns | [tooling_and_native_flavors.md](tooling_and_native_flavors.md) |

## ⚠️ Common Mistakes

> These are the most frequent flavor and environment-config bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **Hardcoding base URLs or API keys in feature code** | Changing environment requires editing feature files; wrong URL ships to prod | All env-specific values belong in `EnvConfig`; feature code reads only from `AppConfig` injected via DI |
| 2 | **Calling `String.fromEnvironment()` in feature or service files** | `--dart-define` values scatter across the codebase; overrides are invisible at a glance | `String.fromEnvironment()` is called only inside `AppConfig.fromEnv()` — that is the single merge point for `--dart-define` overrides |
| 3 | **Committing secrets (API keys, signing creds) in `EnvConfig` source** | Credentials leak to version control and any developer who clones the repo | Inject secrets at CI time via `--dart-define=API_KEY=$SECRET`; read them only in `AppConfig`; add `.env` to `.gitignore` |
| 4 | **Using `bool isProduction = true/false` instead of the `Env` enum** | Adding UAT requires changing every `if/else` branch; exhaustive `switch` checking is lost | Use the `Env` enum and pattern-match with `switch`; `EnvConfig.fromEnv(env)` selects values without scattered conditionals |
| 5 | **Entry points (`main_dev.dart`) contain bootstrap logic beyond `guardedMain()`** | Logic is duplicated across entry points; a change must be made in three files | Entry points call only `guardedMain(Env.x, const App())`; all bootstrap steps live in `bootstrap(env)` inside `app_bootstrap.dart` |
| 6 | **`AppConfig` not registered first in the DI composition root** | Services that read `AppConfig` during their own registration throw `Not registered` errors | Register `AppConfig` as the very first singleton in `configureDependencies(env)`, before any service that depends on it |
| 7 | **Native `productFlavors` added when only Dart-level env differences are needed** | Unnecessary Gradle and Xcode complexity; CI build commands grow more complicated | Native flavors are opt-in — add them only when different bundle IDs, app icons, or signing configs are required per environment |
| 8 | **Tests instantiate real `AppConfig` with prod values** | Tests hit production URLs or require production secrets to be available locally | In `setUp`, register `AppConfig.fromEnv(Env.dev)` directly in DI — no flavor machinery needed; override specific values as needed |

## Quick Summary

- **All env-specific values in `EnvConfig`** — never hardcode URLs, keys, or flags in feature code.
- **`AppConfig` is the single source of truth** — registered as the first singleton in DI, injected via constructor; no `String.fromEnvironment()` calls scattered in feature code.
- **Keep entry points minimal** — the only difference between `main_dev.dart` and `main_prod.dart` is the `Env` enum value passed to `bootstrap()`.
- **Secrets never go in Dart source** — use `--dart-define` from CI or `.env` files excluded from VCS.
- **Native flavors are opt-in** — only add Android `productFlavors` / iOS schemes when different bundle IDs, icons, or signing per environment are actually required.
- **Tests use DI overrides** — no flavor machinery needed in tests; register `AppConfig.fromEnv(Env.dev)` directly in `setUp`.

## Cross-references

- [flutter-app-shell](../../flutter-app-shell/references/template.md) — project layout and per-flavor entry point files
- [flutter-di](../../flutter-di/references/template.md) — `AppConfig` registered at the top of the DI registration order
- [flutter-security](../../flutter-security/references/template.md) — secret management via `--dart-define` and CI secrets, never in Dart source

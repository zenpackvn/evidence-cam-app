---
name: flutter-flavors
description: Use this skill when working on Flutter app flavors or environments — dev/uat/prod environments, Env enum, EnvConfig, AppConfig, flavor entry points, environment-specific configuration, API base URLs per environment, logging configuration, app title per flavor, VS Code launch configurations, or separating development and production builds.
---

# Flutter Flavors

Full reference: [`template.md`](references/template.md)

## Key rules

- Three environments: `Env.dev`, `Env.uat`, `Env.prod`. Each has its own entry point.
- `Env` is a simple enum (`dev | uat | prod`) with helper getters (`isDev`, `isUat`, `isProd`).
- `EnvConfig` maps `Env` → config values (API base URL, app title, logging enabled, timeouts).
- `AppConfig.fromEnv(env)` is the single config object. Created once in `main_*.dart` and passed to `appBootstrap()`.
- Three entry points: `lib/main_dev.dart`, `lib/main_uat.dart`, `lib/main_prod.dart`. Each calls `appBootstrap(Env.x)`.
- **`API_BASE_URL` env var** overrides the config — useful for pointing a dev build at a local server: `--dart-define=API_BASE_URL=http://localhost:3000`.
- No `kDebugMode` or `kReleaseMode` checks — use `AppConfig.env` instead (testable, not build-mode-coupled).

## Files

```
lib/
  main_dev.dart         ← appBootstrap(Env.dev)
  main_uat.dart         ← appBootstrap(Env.uat)
  main_prod.dart        ← appBootstrap(Env.prod)
lib/src/core/config/
  env.dart              ← enum Env { dev, uat, prod }
  env_config.dart       ← EnvConfig.fromEnv(env) → base config values
  app_config.dart       ← AppConfig(env, apiBaseUrl, appTitle, …)
```

## Co-load with

- `flutter-app-shell` — entry point wiring
- `flutter-di` — `AppConfig` registered first in service_locator
- `flutter-logging` — log level depends on env

---
name: flutter-app-shell
description: Use this skill when initializing or scaffolding a new Flutter project — pubspec.yaml setup, folder structure, entry points (main_dev/uat/prod), app bootstrap, app.dart, DI composition root, opinionated stack selection, dependency choices, package versions, project layout, or setting up the base architecture skeleton of a Flutter app.
---

# Flutter App Shell

Full reference: [`template.md`](references/template.md)

## Folder structure

```
lib/
  main_dev.dart / main_uat.dart / main_prod.dart   ← flavor entry points
  src/
    app/
      app.dart                 ← MaterialApp.router, ThemeCubit, LocalizationService
      router/                  ← GoRouter, route constants
      theme/                   ← AppColors, AppSpacing, AppTypography, AppTheme
    core/
      base/                    ← BaseCubit, BaseState, UseCase, BaseRepository …
      config/                  ← Env, EnvConfig, AppConfig
      di/                      ← service_locator.dart (composition root)
      error/                   ← Failure hierarchy
      logging/                 ← AppLogger interface + LoggerImpl wrapper
      network/                 ← DioClient, ApiClient, interceptors
      …
    features/
      <feature>/
        data/   domain/   presentation/
```

## Key rules

- One `pubspec.yaml` at the Flutter root — exact version pins (no `^`).
- Three entry points: `main_dev.dart`, `main_uat.dart`, `main_prod.dart`. Each calls `appBootstrap(Env.x)`.
- `service_locator.dart` is the single composition root — `getIt` only registered there or in feature DI modules.
- `app.dart` reads `ThemeCubit` and `LocalizationService` from `getIt`; never instantiates them directly.
- All third-party packages are wrapped behind app-owned interfaces — **never import a third-party package outside its designated wrapper file**.
- Run `flutter pub get` → `build_runner` (if codegen) → `flutter analyze` → `flutter test` after setup.

## Co-load with

- `flutter-di` — composition root rules
- `flutter-flavors` — Env / AppConfig
- `flutter-theme` — token setup
- `flutter-routing` — GoRouter bootstrap
- `flutter-logging` — AppLogger setup

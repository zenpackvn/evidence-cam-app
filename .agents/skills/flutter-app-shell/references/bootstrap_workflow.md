# App Shell — Bootstrap Workflow & Architecture Notes

## Bootstrap Workflow

When creating a new project from scratch:

1. **Create target** with `flutter create --org <org> --platforms <platforms> --project-name <name>`.
2. **Inspect** generated `pubspec.yaml`, `analysis_options.yaml`, `lib/main.dart`, `test/`.
3. **Replace** sample counter app with the opinionated baseline — use the folder structure above and templates.
4. **Configure dependencies** — add all packages from the pubspec excerpt. Exact version pins, never `^`.
5. **Wire DI composition root** — see [template-di.md](template-di.md) for registration order.
6. **Add flavors** — `main_dev.dart`, `main_uat.dart`, `main_prod.dart`. See [template-flavors.md](template-flavors.md).
7. **Add tests** — one smoke test + one `bloc_test`. See [template-tests.md](template-tests.md).
8. **Verify**:
   ```
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   flutter analyze
   flutter test
   flutter run -t lib/main_dev.dart
   ```

### What "full setup" means

- Runnable immediately with the opinionated stack wired end-to-end.
- Composition root with exact registration order.
- One example feature wired through DI.
- Do NOT add Firebase, Sentry, analytics, CI, or native customizations unless requested.

---

## Architecture Notes

- `lib/src/app/` — app shell (root widget, router, theme, localization, bootstrap).
- `lib/src/core/` — cross-feature infrastructure (DI composition root, logger, network, storage, error types, config, shared widgets).
- `lib/src/features/` — feature-first code (presentation / domain / data). Skip domain or data layers for trivial features.
- Do not force clean architecture onto tiny screens. The layers exist when they pay off.
- **Presentation → domain → data** dependency flow.
- **Typed failures** at the data boundary. Raw `DioException` never leaks past the data layer.
- **Blocs/cubits are always factories, never singletons.** State leaks across screens otherwise.
- **Exact version pins.** Ensures reproducible builds.
- **Codegen is part of the build.** `dart run build_runner build --delete-conflicting-outputs` is a first-class verification step.

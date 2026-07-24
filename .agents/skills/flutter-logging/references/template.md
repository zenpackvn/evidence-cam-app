# Template — Logging & Observability

Wrapped logger following the wrapper rule: only `logger_impl.dart` imports `package:logger`. Every other file depends on the `AppLogger` interface. Includes automatic BLoC state/error logging via `AppBlocObserver` and screen logging via `AppRouteObserver`.

## Topic Files

| Topic | File |
|---|---|
| `AppLogger` interface, `LoggerImpl`, DI registration, test fake | [app_logger.md](app_logger.md) |
| `AppBlocObserver` (state/error logging) + `AppRouteObserver` (screen logging) | [bloc_observer_and_route_observer.md](bloc_observer_and_route_observer.md) |
| Rules, observability patterns, anti-patterns | [rules_and_antipatterns.md](rules_and_antipatterns.md) |

## ⚠️ Common Mistakes

> These are the most frequent logging bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **Importing `package:logger` outside `logger_impl.dart`** | Violates the wrapper rule — swapping the logger package requires editing every import site | Only `logger_impl.dart` imports `package:logger`; all other files depend on the `AppLogger` interface only |
| 2 | **Using `print()` or `debugPrint()` instead of `AppLogger`** | Output is unstructured, has no log level, cannot be filtered per environment, and never reaches crash reporter breadcrumbs | Replace every `print`/`debugPrint` call with `logger.debug(...)`, `logger.info(...)`, `logger.warn(...)`, or `logger.error(...)` |
| 3 | **Logging sensitive data — tokens, passwords, emails, or phone numbers** | PII ends up in crash reports, log aggregators, and device log files; security/compliance violation | Log only non-sensitive identifiers (e.g., `userId`, `screen`, `action`); never include tokens, passwords, or contact details in any log message |
| 4 | **Log level not filtered per environment — verbose logs ship to production** | Production log output is noisy and may leak internal details; `AppConfig.enableLogging` flag is ignored | Pass `verbose: getIt<AppConfig>().enableLogging` to `LoggerImpl`; use `DevelopmentFilter` when verbose, `ProductionFilter` otherwise |
| 5 | **`AppLogger` registered as `factory` instead of `lazySingleton`** | A new logger instance is created for every consumer — log output is fragmented and unconfigurable at a central point | Register with `getIt.registerLazySingleton<AppLogger>(LoggerImpl.new)` so the same configured instance is shared across the app |
| 6 | **`AppBlocObserver` instantiated inside a widget or cubit** | Observer is registered multiple times or not at all; bloc errors are never routed to `ErrorHandler` | Assign `Bloc.observer = AppBlocObserver(logger: getIt(), errorHandler: getIt())` once in `bootstrap()`, after DI configuration |
| 7 | **`AppRouteObserver` not added to `GoRouter`'s `observers` list** | Screen push/pop events are never logged; navigation flow is invisible in debug output and breadcrumbs | Add `AppRouteObserver(logger: getIt<AppLogger>())` to the `observers` list when constructing `GoRouter` |
| 8 | **Logger output not fed to `CrashReporter` breadcrumbs** | Crash reports have no navigation or state context — root-causing crashes is much harder | In `LoggerImpl` (or `ErrorHandlerImpl`), call `crashReporter.addBreadcrumb(message, category: level)` alongside each log write |

## Quick Summary

- **Wrapper rule**: Only `logger_impl.dart` imports `package:logger`. All other code uses `AppLogger`.
- **Never `print()` or `debugPrint()`** — use `AppLogger` for structured, level-aware, filterable output.
- **Filter by environment** — verbose/debug in dev, warning+ in prod via `AppConfig.enableLogging`.
- **No PII in logs** — never log tokens, passwords, emails, or phone numbers.
- **`AppBlocObserver` wired in bootstrap** (not DI) — logs every state transition and routes errors to `ErrorHandler`.
- **`AppRouteObserver` added to GoRouter `observers`** — logs screen pushes and pops automatically.

## Cross-references

- [template-di.md](template-di.md) — registration order and lifetime rules
- [template-flavors.md](template-flavors.md) — `AppConfig.enableLogging` for level filtering
- [template-analytics.md](template-analytics.md) — `CrashReporter` integration for breadcrumbs
- [template-error-handling.md](template-error-handling.md) — `ErrorHandler` wired into `AppBlocObserver`

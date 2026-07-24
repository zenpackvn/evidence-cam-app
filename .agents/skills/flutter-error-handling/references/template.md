# Error Handling

Global error boundary system: zone-based catching, Flutter framework errors, platform errors, custom error UI, error boundary widget, and the complete error flow from source to crash reporter.

Depends on: [template-logging.md](template-logging.md) (AppLogger), [template-analytics.md](template-analytics.md) (CrashReporter), [template-network.md](template-network.md) (Failure hierarchy).

## Topics

| Topic | File |
|---|---|
| Error flow diagram, folder structure, expected vs unexpected errors | [error_flow_and_folder.md](error_flow_and_folder.md) |
| `ErrorHandler` interface + `ErrorHandlerImpl`, DI registration | [error_handler_service.md](error_handler_service.md) |
| Bootstrap wiring: `guardedMain`, zone guard, entry points, BlocObserver | [bootstrap_wiring.md](bootstrap_wiring.md) |
| `AppErrorWidget` (release UI), `ErrorBoundary`, `RetryErrorBoundary` | [error_widgets.md](error_widgets.md) |
| `AppBlocObserver` — routes bloc errors to `ErrorHandler` | [bloc_observer_integration.md](bloc_observer_integration.md) |
| Async error do/don't patterns | [async_error_patterns.md](async_error_patterns.md) |
| `FakeErrorHandler`, unit tests, widget tests | [testing.md](testing.md) |

## ⚠️ Common Mistakes

> These are the most frequent error-handling bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **Calling `runApp()` directly instead of `guardedMain()`** | Unawaited future errors silently disappear — no zone guard catches them | Every `main_*.dart` entry point calls `guardedMain(Env.x, const App())`, never raw `runApp()` |
| 2 | **`CrashReporter.init()` called after `runApp`** | Startup crashes before `runApp` are never captured in crash reports | Call `crashReporter.init()` inside `bootstrap()`, before `runApp()` is invoked |
| 3 | **Setting `ErrorWidget.builder` in debug mode** | Red error screen disappears in debug builds, hiding rendering bugs | Wrap `ErrorWidget.builder = ...` in `if (kReleaseMode)` — keep the red screen in debug |
| 4 | **Zone error handler assumes DI is ready** | Crash on startup if an error occurs before `configureDependencies()` completes | Check `GetIt.I.isRegistered<ErrorHandler>()` before using DI; fall back to `debugPrint` |
| 5 | **Swallowing errors silently with empty `catch`** | Errors are lost — no log, no crash report, no visible failure | Every `catch` block must call `getIt<ErrorHandler>().handleError(e, s, ...)`, emit a state, or rethrow |
| 6 | **Widget catches error without routing to `ErrorHandler`** | Error shows `hasError = true` in UI but never appears in crash reports | Report via `getIt<ErrorHandler>().handleError(e, s, reason: '...')` even when recovering locally |
| 7 | **`ErrorHandlerImpl` imports a concrete crash reporter package directly** | Violates wrapper rule — couples the error layer to a specific SDK | `ErrorHandlerImpl` depends only on `CrashReporter` and `AppLogger` interfaces; SDK import lives in `*_impl.dart` |
| 8 | **`BlocObserver` not wired after DI in bootstrap** | Bloc errors are never routed to `ErrorHandler` or logged | Add `Bloc.observer = AppBlocObserver(logger: getIt(), errorHandler: getIt())` inside `bootstrap()`, after `configureDependencies()` |

## Quick Summary

- **All error layers delegate to one `ErrorHandler`** — `FlutterError.onError`, `PlatformDispatcher.onError`, `runZonedGuarded`, and `BlocObserver.onError` all call the single service. No handler logs or reports directly.
- **Always use `guardedMain()`** — every `main_*.dart` calls `guardedMain()`, never raw `runApp()`. The zone guard catches unawaited future errors.
- **Init `CrashReporter` before `runApp`** — startup crashes must be captured; `CrashReporter.init()` runs inside `bootstrap()`.
- **Custom error UI in release only** — set `ErrorWidget.builder` when `kReleaseMode` is true; keep the red screen in debug.
- **Expected vs unexpected** — typed `Failure` hierarchy for network/auth/validation errors (handled in cubit states); `ErrorHandler` for widget crashes, zone leaks, and platform errors.
- **Never swallow errors silently** — every `catch` block must emit a state, log, or report.
- **Pre-DI fallback** — zone handler checks `GetIt.I.isRegistered<ErrorHandler>()` before using DI.
- **Wrapper rule** — `ErrorHandlerImpl` depends on `AppLogger` and `CrashReporter` interfaces, never on concrete packages.

## Cross-references

- [flutter-logging](../../flutter-logging/references/template.md) — `ErrorHandler` delegates all error logging to `AppLogger.error()`
- [flutter-analytics](../../flutter-analytics/references/template.md) — unexpected errors are forwarded to `CrashReporter` for crash reporting
- [flutter-di](../../flutter-di/references/template.md) — `ErrorHandler` is registered as a singleton and wired in bootstrap before `runApp()`
- [flutter-flavors](../../flutter-flavors/references/template.md) — error detail verbosity (stack traces, error messages) varies by `Env`
- [flutter-network](../../flutter-network/references/template.md) — typed `Failure` hierarchy originates in the network layer and surfaces through `ErrorHandler`

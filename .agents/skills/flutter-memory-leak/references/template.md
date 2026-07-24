# Template — Memory Leak Detection & Prevention

Systematic approach to finding, fixing, and preventing memory leaks in Flutter apps. Covers dispose patterns, `leak_tracker` integration, DevTools workflow, and automated auditing.

## Reference Files

Load only the file(s) relevant to the task.

| Topic | File |
|---|---|
| Dispose contract for StatefulWidget (controllers, subscriptions, timers) | [dispose_contract.md](dispose_contract.md) |
| Cubit / BLoC stream and timer cleanup in `close()` | [cubit_cleanup.md](cubit_cleanup.md) |
| `mounted` guard — prevent BuildContext use after `await` | [mounted_guard.md](mounted_guard.md) |
| `leak_tracker` test setup and per-test opt-out | [leak_tracker_integration.md](leak_tracker_integration.md) |
| Image cache bounding — bootstrap config + `AppCachedImage` | [image_cache_bounding.md](image_cache_bounding.md) |
| Common leak patterns (StreamController, ChangeNotifier, GlobalKey) | [common_leak_patterns.md](common_leak_patterns.md) |
| Static audit script + DevTools memory workflow | [audit_and_devtools.md](audit_and_devtools.md) |

---

## ⚠️ Common Mistakes

> These are the most frequent memory-leak bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **`super.dispose()` called first** | Framework throws assertion errors; lifecycle hooks called on a disposed widget | Always call `super.dispose()` last — after all controller and subscription cancellations |
| 2 | **`StreamSubscription` result ignored** | Stream listener keeps running after widget is removed; state emitted to a closed cubit | Store every `.listen()` return value in a `StreamSubscription?` field and call `?.cancel()` in `dispose()` |
| 3 | **Missing `mounted` guard after `await`** | `setState()` or `context.go()` throws "called after dispose" in async widget methods | Add `if (!mounted) return;` immediately after every `await` that precedes a `context` or `setState` use |
| 4 | **Timer not cancelled in cubit `close()`** | Timer fires after cubit is closed; `emit()` after close throws in debug mode | Override `close()` in every cubit that creates a `Timer`, call `_timer?.cancel()` before `super.close()` |
| 5 | **`StreamController` never closed** | Dart VM reports the `StreamController` as a leak; `_controller.stream` listeners accumulate | Override `dispose()` (widget) or `close()` (cubit), call `_controller.close()` there |
| 6 | **`ChangeNotifier.addListener` without `removeListener`** | Notifier holds a reference to the `State` object long after the widget is unmounted | Always pair `someNotifier.addListener(_handler)` in `initState` with `someNotifier.removeListener(_handler)` in `dispose()` |
| 7 | **`GlobalKey` stored in a static field or singleton** | Widget it points to can never be garbage-collected; heap keeps growing across navigations | Move `GlobalKey` to the `State` field that owns the widget; never store it in a static or service-locator singleton |
| 8 | **`AppCachedImage` used without `memCacheWidth`/`memCacheHeight`** | Full-resolution images decoded and cached in memory; OOM crash on image-heavy feeds | Always pass `memCacheWidth`/`memCacheHeight` (matching display size) to `AppCachedImage`; call `_configureImageCache()` in bootstrap |

---

## Quick Summary

- `super.dispose()` is **always the last call** in `dispose()` — never first.
- Every controller/subscription/timer created in `initState` must be disposed in `dispose()`.
- Every `StreamSubscription` in a cubit must be cancelled in `close()`.
- Always check `if (!mounted) return;` after any `await` that uses `BuildContext`.
- Enable `LeakTesting` globally in `test/flutter_test_config.dart` — no per-test setup.
- Bound the image cache in `appBootstrap()` before `runApp`; always pass `memCacheWidth`/`memCacheHeight` to `AppCachedImage`.
- Run `scripts/check_leaks.sh` in CI to catch missing dispose calls statically.

## Cross-references

- [flutter-performance](../../flutter-performance/references/template.md) — memory leaks cause sustained frame drops and jank; the two skills share const rules and rebuild minimization
- [flutter-tests](../../flutter-tests/references/template.md) — `leak_tracker` is enabled globally in `test/flutter_test_config.dart` and runs as part of the widget test suite
- [flutter-base-classes](../../flutter-base-classes/references/template.md) — `BaseCubit.close()` is the canonical hook for cancelling subscriptions and timers in cubits
- [flutter-error-handling](../../flutter-error-handling/references/template.md) — leaks that escape `dispose()` surface as zone or platform errors caught by `ErrorHandler`

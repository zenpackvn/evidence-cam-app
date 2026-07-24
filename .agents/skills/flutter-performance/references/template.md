# Template — Performance

Flutter performance patterns covering const widgets, rebuild minimization, lazy lists, isolates, image optimization, build method purity, and memory management. No third-party packages — pure Flutter/Dart guidance.

## Topic Index

| Topic | File |
|---|---|
| Const widget rules | [const_widget_rules.md](const_widget_rules.md) |
| Rebuild minimization (BlocSelector, buildWhen) | [rebuild_minimization.md](rebuild_minimization.md) |
| List performance (builder, itemExtent, keys) | [list_performance.md](list_performance.md) |
| RepaintBoundary and isolates | [repaint_boundary_and_isolates.md](repaint_boundary_and_isolates.md) |
| Image optimization and state management performance | [image_and_state_performance.md](image_and_state_performance.md) |
| Build method rules and memory management | [build_method_and_memory.md](build_method_and_memory.md) |
| Anti-patterns and DevTools profiling workflow | [anti_patterns_and_profiling.md](anti_patterns_and_profiling.md) |

## ⚠️ Common Mistakes

> These are the most frequent performance bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **`FutureBuilder` / `StreamBuilder` in `build()`** | Future re-fires on every rebuild; spinner flickers; no typed error handling | Model async state in a cubit; use `BlocBuilder` to react to `loading / loaded / error` states |
| 2 | **Wrapping entire page in a single `BlocBuilder`** | Every field change triggers a full page rebuild including expensive static subtrees | Extract state-dependent fields into focused `BlocSelector` widgets; mark static subtrees `const` |
| 3 | **`ListView(children: items.map(...).toList())`** | All items built eagerly regardless of visibility; app freezes on large lists | Replace with `ListView.builder`; add `itemExtent` or `prototypeItem` for uniform-height rows |
| 4 | **Large JSON decoded on the main isolate** | UI jank during network responses with hundreds of items; frames exceed 16 ms | Offload parsing to `Isolate.run(() => _parseItems(jsonString))`; function must be top-level or static |
| 5 | **`getIt<T>()` called inside `build()`** | DI lookup on every frame; potential side effects in a pure build method | Resolve the cubit once in `BlocProvider.create` or pass it as a constructor argument; never call `getIt` from `build()` |
| 6 | **Custom painter without `RepaintBoundary`** | Animation repaints the entire ancestor subtree on every frame; jank on mid-range devices | Wrap the `CustomPaint` widget in `RepaintBoundary` to isolate its repaint layer |
| 7 | **New objects or closures created in `build()`** | Framework cannot reuse the widget; `shouldRepaint` / `shouldRebuild` always returns true | Hoist constant decorations, styles, and callbacks to `static const` or cache them in `State` |
| 8 | **Optimizing before profiling** | Wrong bottleneck targeted; const-sprinkling with no measurable improvement | Run `flutter run --profile` and record in DevTools Performance tab first; fix only frames that exceed 16 ms |

## Quick Summary

- **`const` everywhere** — mark constructors `const` when all fields are final; propagate `const` through widget trees so the framework skips `build()` entirely for unchanged subtrees.
- **Minimize rebuilds** — use `BlocSelector` for single-field reads, `buildWhen` for conditional rebuilds, and extract static subtrees as `const` widgets.
- **Lazy lists only** — always use `ListView.builder` / `GridView.builder`; never `ListView(children: [...])` for dynamic or large sets. Use `itemExtent` or `prototypeItem` for uniform-height items.
- **Isolate heavy work** — use `Isolate.run()` for JSON parsing of large payloads, image processing, and data transformations. Keep the main isolate free of CPU-bound work.
- **Decode images at display size** — always set `cacheWidth` / `cacheHeight` on `Image.asset`. Use `AppCachedImage` for network images.
- **Pure `build()` methods** — no side effects, no async calls, no `getIt<T>()` calls inside `build()`. Create cubits in `BlocProvider.create`.
- **Dispose everything** — cancel timers, subscriptions, and animation controllers in `dispose()` (widgets) or `close()` (cubits). No `FutureBuilder` / `StreamBuilder` — model async state in cubits.
- **Profile before optimizing** — use `flutter run --profile` and DevTools Performance + Memory tabs. Measure first, then fix.

## Cross-references

- [flutter-common-widgets](../../../flutter-common-widgets/references/template.md) — app widgets (`AppCachedImage`, `SuperListView`) already embed const and lazy-list optimizations
- [flutter-animations](../../../flutter-animations/references/template.md) — animation code must stay within 16 ms per frame; `RepaintBoundary` isolation applies to animated subtrees
- [flutter-base-classes](../../../flutter-base-classes/references/template.md) — `BaseCubit` and `BaseState` underpin the `BlocSelector` / `buildWhen` rebuild-minimization patterns
- [flutter-di](../../../flutter-di/references/template.md) — cubits must be resolved via `BlocProvider.create`, never via `getIt<T>()` inside `build()`

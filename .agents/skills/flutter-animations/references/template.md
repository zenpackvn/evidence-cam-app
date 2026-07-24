# Template — Animations

Animation utilities, declarative animation chains, and Lottie playback wrapped behind app-owned interfaces. Only `app_animate_impl.dart` imports `package:flutter_animate`. Only `app_lottie_impl.dart` imports `package:lottie`. The wrapper rule applies.

## Reference Files

Load only the file(s) relevant to the task.

| Topic | File |
|---|---|
| Folder structure, pubspec additions, `AppAnimations` constants, barrel export | [animation_constants.md](animation_constants.md) |
| `AppAnimatePresets` interface, `AppAnimatePresetsImpl`, `AppAnimateX` extension, DI registration, usage examples, anti-patterns | [flutter_animate_wrapper.md](flutter_animate_wrapper.md) |
| `AppLottie` widget, `AppLottieImpl`, controlled Lottie, `LottieAssets` constants, usage examples, anti-patterns | [lottie_wrapper.md](lottie_wrapper.md) |
| Hero transitions, route fade/slide/shared-axis transitions with GoRouter | [hero_transitions.md](hero_transitions.md) |
| `AnimatedListWrapper` — typed animated list with insert/remove transitions | [animated_list_wrapper.md](animated_list_wrapper.md) |
| Widget tests, Lottie fallback test, stagger test, mock presets | [animation_testing.md](animation_testing.md) |

---

## ⚠️ Common Mistakes

> These are the most frequent animations bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **Direct `flutter_animate` import in a page** | Review comment: wrapper rule violated; grep finds `import 'package:flutter_animate'` outside `app_animate_impl.dart` | Move all `flutter_animate` usage into `app_animate_impl.dart`; call it only through `AppAnimatePresets` or `AppAnimateX` extension methods |
| 2 | **Direct `lottie` import in a page** | Review comment: wrapper rule violated; grep finds `import 'package:lottie'` outside `app_lottie_impl.dart` | Use `AppLottie.create(asset: LottieAssets.x)` everywhere except `app_lottie_impl.dart` |
| 3 | **Inline `Duration(milliseconds: 300)` in widgets** | Inconsistent timings across the app; impossible to tune globally | Replace with `AppAnimations.durationMedium`, `AppAnimations.durationSlow`, etc. from `app_animations.dart` |
| 4 | **Raw `Curves.*` in `AnimatedContainer` / `AnimationController`** | Inconsistent easing; hard to audit | Use `AppAnimations.curveStandard`, `AppAnimations.curveSharp`, etc. |
| 5 | **Manual `AnimationController` + `Tween` for standard effects** | 30+ lines of boilerplate; controller dispose often forgotten | Use `widget.appEntrance()`, `.appFadeIn()`, `.appSlideUp()`, etc. from `AppAnimateX`; reserve manual controllers only for Lottie controlled mode |
| 6 | **Missing `errorBuilder` on Lottie** | App crashes with `FlutterError` when an animation asset is absent or misnamed | Always include `errorBuilder` in `AppLottieImpl.build()`; it must return a `SizedBox` fallback, never throw |
| 7 | **Non-unique Hero tags** | Hero transition throws assertion error or animates to wrong target when the same tag appears twice on screen (e.g., in a list) | Use `'type-${item.id}'` format (e.g., `'product-${product.id}'`) so each tag is unique per screen |
| 8 | **Animating the entire widget subtree** | Unnecessary repaints; jank on low-end devices; siblings re-animate when only one element changed | Animate only the changing element; wrap frequently animating widgets in `RepaintBoundary`; never call `.appFadeIn()` on a `Column` with static children |

---

## Quick Summary

- **Wrapper rule** — only `app_animate_impl.dart` imports `package:flutter_animate`; only `app_lottie_impl.dart` imports `package:lottie`. No other file may import these packages.
- **Centralize durations and curves** — use `AppAnimations` constants everywhere. No inline `Duration(milliseconds: 300)` or raw `Curves.*` in widgets.
- **Use `AppAnimateX` extension** — one-liner declarative animations (`widget.appEntrance()`, `.appFadeIn()`, `.appStaggeredItem(index: i)`). Never write manual `AnimationController` + `Tween` boilerplate for standard effects.
- **Use `AppLottie.create()`** — never call `Lottie.asset(...)` directly outside `app_lottie_impl.dart`. Always define asset paths in `LottieAssets`.
- **Always provide `errorBuilder`** in Lottie — missing assets must fall back gracefully, not crash.
- **Hero tag uniqueness** — use `'type-id'` format (e.g., `'product-${product.id}'`).
- **Keep animations short** — standard 200–300ms, page transitions 300–400ms, never exceed 600ms.
- **`RepaintBoundary`** — wrap frequently animating widgets to avoid repainting siblings.

## Cross-references

- [flutter-theme](../../flutter-theme/references/template.md) — `AppAnimations` duration and curve constants follow design tokens defined in `AppColors`, `AppSpacing`, and `AppTypography`
- [flutter-performance](../../flutter-performance/references/template.md) — `RepaintBoundary` usage, rebuild minimization, and jank avoidance rules that animations must satisfy
- [flutter-di](../../flutter-di/references/template.md) — `AppAnimatePresets` registered in `configureDependencies()` as a singleton; wrapper rule applies to `app_animate_impl.dart` and `app_lottie_impl.dart`
- [flutter-routing](../../flutter-routing/references/template.md) — route fade/slide/shared-axis transitions and Hero transitions wired through GoRouter

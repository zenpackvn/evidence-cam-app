# Template — Loading & List States

Reusable loading, shimmer, error, empty, pull-to-refresh, load-more, and button loading widgets. Each of the three third-party packages (`flutter_spinkit`, `shimmer_animation`, `pullex`) is wrapped behind a single app-owned file — all consumers use the wrapper.

## Topic Files

| Topic | File |
|---|---|
| `AppLoadingIndicator` (flutter_spinkit wrapper) | [app_loading_indicator.md](app_loading_indicator.md) |
| `ScreenLoading` + `LoadingOverlay` | [screen_loading_and_overlay.md](screen_loading_and_overlay.md) |
| `AppShimmer`, `ShimmerListItem`, `ShimmerListSkeleton` (shimmer_animation wrapper) | [app_shimmer.md](app_shimmer.md) |
| `SuperListView` — all-in-one paginated list (pullex wrapper) | [super_list_view.md](super_list_view.md) |
| `LoadingButton`, `LoadingOutlinedButton` | [loading_button.md](loading_button.md) |
| Barrel export, when-to-use table, rules, anti-patterns | [loading_barrel_and_rules.md](loading_barrel_and_rules.md) |

## ⚠️ Common Mistakes

> These are the most frequent loading/list-state bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **Using `CircularProgressIndicator` directly** | Spinner appearance is inconsistent; changing the spinner library requires editing every file that uses it | Replace with `AppLoadingIndicator()`; it is the only file that imports `flutter_spinkit`, making the package swappable in one place |
| 2 | **Importing `pullex` or `shimmer_animation` outside their wrapper files** | A feature widget `import 'package:pullex/pullex.dart'` — breaks the wrapper rule | Only `super_list_view.dart` imports `pullex`; only `app_shimmer.dart` imports `shimmer_animation`; all consumers use the app-owned wrappers |
| 3 | **Managing `RefreshController` in the cubit** | Cubit imports `pullex`, owns the controller, and calls `refreshCompleted()` directly — cubit is no longer testable without a UI dependency | `RefreshController` is a UI concern; it lives entirely inside `SuperListView` and is synced via `didUpdateWidget`; the cubit only overrides `fetchPage()` |
| 4 | **Not handling error and empty states (infinite spinner)** | Network failure leaves the user staring at a spinner with no retry option; `PaginatedError` and `PaginatedEmpty` states are silently swallowed | Use `SuperListView` which covers all four states automatically, or explicitly handle every sealed state variant including error and empty with a retry callback |
| 5 | **Managing `isLoading` booleans inside widgets** | Widget has a local `bool isLoading = false` toggled in `setState`; loading state drifts out of sync with the cubit | Cubit emits `SignInSubmitting` (or equivalent loading state); widget reacts via `BlocBuilder` and passes `state is SignInSubmitting` to `LoadingButton(isLoading: ...)` |
| 6 | **Mixing declarative and imperative loading for the same operation** | Both `LoadingOverlay(isLoading: ...)` and `AppDialog.showLoading()` are active for the same async operation; double overlay or dismiss race condition | Pick exactly one approach per operation: `LoadingOverlay` for declarative (driven by bloc state in `builder`), or `AppDialog.showLoading()` for imperative (triggered from `BlocListener`) |
| 7 | **Hardcoded strings and magic numbers in loading widgets** | `Text('No items found')` or `EdgeInsets.symmetric(vertical: 16)` appear in list empty/error states; fails localization and spacing audits | All user-facing labels use `context.tr('key')`; all spacing uses `AppSpacing.*` constants; never write literal strings or pixel values |
| 8 | **Passing a builder function to `separator` instead of a widget** | `SuperListView(separatorBuilder: (ctx, i) => const Divider())` — `separatorBuilder` does not exist on `SuperListView` | Pass a plain widget to the `separator:` parameter: `SuperListView(separator: const AppDivider())`; `SuperListView` wraps it in a builder internally |

## Quick Summary

- **Wrapper rule**: Only `app_loading_indicator.dart` imports `flutter_spinkit`; only `app_shimmer.dart` imports `shimmer_animation`; only `super_list_view.dart` imports `pullex`. To swap any package, edit one file.
- **`SuperListView` for every paginated list** — handles shimmer → error → empty → data+refresh automatically; the cubit only overrides `fetchPage()`.
- **`RefreshController` stays inside `SuperListView`** — cubits must never import or reference it.
- **Model loading in state, not widgets** — cubit emits a loading state; the widget reacts. No `isLoading` booleans inside widgets.
- **`ScreenLoading` for non-list pages, `LoadingOverlay` for declarative blocking, `AppDialog.showLoading()` for imperative one-off blocking** — pick one per operation.
- **No hard strings, no magic numbers** — all labels via `context.tr()`, all spacing via `AppSpacing.*`.
- **`separator:` takes a `Widget?`** — never a builder function.

## Cross-references

- [flutter-dialog](../../flutter-dialog/references/template.md) — `LoadingOverlay` uses `AppDialog.showLoading()` for imperative blocking overlays
- [flutter-common-widgets](../../flutter-common-widgets/references/template.md) — `AppEmptyState` and `AppErrorState` are rendered by `SuperListView` for empty and error states
- [flutter-base-classes](../../flutter-base-classes/references/template.md) — `BasePaginatedCubit` provides the `fetchPage()` contract that `SuperListView` drives

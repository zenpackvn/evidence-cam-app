---
name: flutter-loading
description: Use this skill when implementing Flutter loading states — shimmer loading, pull-to-refresh, load-more pagination, SuperListView, AppShimmer, AppLoadingIndicator, ScreenLoading, LoadingOverlay, LoadingButton, skeleton screens, empty state, error state in lists, or any loading/data/error/empty state management in list or detail views.
---

# Flutter Loading

Full reference: [`template.md`](references/template.md)

## Key rules

- `SuperListView` is the **single widget** for all paginated lists. It renders: shimmer (loading) → error/empty → data + pull-to-refresh + load-more. Never build this manually with nested conditionals.
- `AppShimmer` wraps `shimmer_animation`. Only `app_shimmer.dart` imports `shimmer_animation`.
- `AppLoadingIndicator` wraps `flutter_spinkit`. Only `app_loading_indicator.dart` imports `flutter_spinkit`.
- `ScreenLoading` = full-screen shimmer while initial data is loading.
- `LoadingOverlay` = semi-transparent overlay for in-progress mutations (save, delete). Backed by `AppDialog.showLoading()`.
- `LoadingButton` = `ElevatedButton` that shows a spinner in its `isLoading` state.
- Empty and error states use `AppEmptyState` and `AppErrorState` — never raw `Column + Icon + Text`.
- Shimmer placeholder dimensions must match the real content dimensions exactly.

## Co-load with

- `flutter-dialog` — `LoadingOverlay` uses `AppDialog.showLoading()`
- `flutter-common-widgets` — `AppEmptyState`, `AppErrorState`
- `flutter-base-classes` — `BasePaginatedCubit` drives `SuperListView`

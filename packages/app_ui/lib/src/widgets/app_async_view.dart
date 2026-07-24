import 'package:flutter/material.dart';

import '../../app_ui.dart';

/// Which of the four canonical async states a data view is in.
enum AppAsyncStatus { loading, error, empty, data }

/// Collapses the repeated `loading → error → empty → data` ladder that data
/// screens hand-roll into one declarative switch, wired to the shared
/// [AppSkeletonList] / [AppErrorView] / [AppEmptyView] placeholders.
///
/// It deliberately owns *only* the state switch — not list rendering, refresh,
/// or pagination. Each feature keeps its own data widget (a masonry grid, a
/// paged list, ...) and passes it via [data]. Compute [status] from the
/// feature's own state (e.g. `state.isLoading && state.items.isEmpty` →
/// [AppAsyncStatus.loading]) and let this widget pick the placeholder, so the
/// four-way branch and its default-widget wiring live in one place.
///
/// Because app_ui carries no localization, the built-in error/empty defaults
/// use neutral fallback copy; pass [errorMessage] / [emptyMessage] (localized
/// by the caller, as [AppErrorView] already expects) or supply a fully built
/// [error] / [empty] widget.
class AppAsyncView extends StatelessWidget {
  const AppAsyncView({
    super.key,
    required this.status,
    required this.data,
    this.loading,
    this.error,
    this.empty,
    this.errorMessage,
    this.onRetry,
    this.emptyTitle,
    this.emptyMessage,
    this.hasLeadingSkeleton = true,
  });

  final AppAsyncStatus status;

  /// The content for [AppAsyncStatus.data]. Built lazily so it is only
  /// constructed when actually shown.
  final WidgetBuilder data;

  /// Full overrides for the default placeholders. When null, a default built
  /// from the shared primitives is used.
  final Widget? loading;
  final Widget? error;
  final Widget? empty;

  /// Feeds the built-in [AppErrorView] when [error] is null.
  final String? errorMessage;
  final VoidCallback? onRetry;

  /// Feeds the built-in [AppEmptyView] when [empty] is null.
  final String? emptyTitle;
  final String? emptyMessage;

  /// Whether the default loading skeleton renders a leading square per row.
  final bool hasLeadingSkeleton;

  @override
  Widget build(BuildContext context) => switch (status) {
    AppAsyncStatus.loading =>
      loading ?? AppSkeletonList(hasLeading: hasLeadingSkeleton),
    AppAsyncStatus.error =>
      error ??
          AppErrorView(
            message: errorMessage ?? 'Something went wrong.',
            onRetry: onRetry,
          ),
    AppAsyncStatus.empty =>
      empty ??
          AppEmptyView(
            title: emptyTitle,
            message: emptyMessage ?? 'Nothing here yet.',
          ),
    AppAsyncStatus.data => data(context),
  };
}

import '../../domain/home_data.dart';

/// State of the Home dashboard (SM-004).
class HomeState {
  const HomeState({
    this.data = HomeData.empty,
    this.isLoading = false,
    this.error,
    this.isOffline = false,
  });

  final HomeData data;
  final bool isLoading;
  final String? error;

  /// Whether the device currently has no network link (SM-004 BR-07): the
  /// already-loaded [data] stays on screen behind an offline notice.
  final bool isOffline;

  /// Whether a pull-to-refresh may run (SM-004 BR-07 / AC-06: refreshing is
  /// disabled while offline, so the shown data cannot be wiped).
  bool get canRefresh => !isOffline;

  HomeState copyWith({
    HomeData? data,
    bool? isLoading,
    String? error,
    bool? isOffline,
  }) => HomeState(
    data: data ?? this.data,
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
    isOffline: isOffline ?? this.isOffline,
  );
}

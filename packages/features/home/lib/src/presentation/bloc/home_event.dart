part of 'home_bloc.dart';

sealed class HomeEvent {
  const HomeEvent();
}

final class HomeLoadRequested extends HomeEvent {
  const HomeLoadRequested({this.isRefresh = false});

  /// Whether this is a user-triggered refresh (pull-to-refresh) rather than
  /// the screen's initial load. Offline, a refresh is a no-op (SM-004 BR-07 /
  /// AC-06) while the initial load still runs — the loader is offline-first,
  /// so it fills the screen from cache rather than leaving it blank (BR-06).
  final bool isRefresh;
}

/// Emitted on every connectivity transition, so the offline notice appears and
/// clears without a reload (SM-004 BR-07).
final class HomeConnectivityChanged extends HomeEvent {
  const HomeConnectivityChanged({required this.isOnline});

  final bool isOnline;
}

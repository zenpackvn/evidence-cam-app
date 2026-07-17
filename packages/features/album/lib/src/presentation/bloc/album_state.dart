import 'package:flutter/foundation.dart';

import '../../domain/entities/stamp.dart';

/// The two Album display modes (SM-022 BR-04): a dense grid or a roomier list.
enum AlbumViewMode { grid, list }

/// The Album screen's state (SM-022): the loaded stamps plus loading/error
/// flags, the current view mode, and whether the device is offline. Stamps are
/// newest-first as the repository returns them.
@immutable
class AlbumState {
  const AlbumState({
    this.stamps = const [],
    this.loading = true,
    this.error = false,
    this.viewMode = AlbumViewMode.grid,
    this.isOffline = false,
  });

  final List<Stamp> stamps;
  final bool loading;
  final bool error;
  final AlbumViewMode viewMode;

  /// Whether the device currently has no network link (SM-022 BR-10): the
  /// list still renders from the local store, with an offline notice on top.
  final bool isOffline;

  bool get isEmpty => !loading && !error && stamps.isEmpty;

  /// Whether the network-bound write actions — rename and delete — are
  /// available (SM-022 BR-11 / AC-10: they are disabled while offline).
  bool get canMutate => !isOffline;

  AlbumState copyWith({
    List<Stamp>? stamps,
    bool? loading,
    bool? error,
    AlbumViewMode? viewMode,
    bool? isOffline,
  }) => AlbumState(
    stamps: stamps ?? this.stamps,
    loading: loading ?? this.loading,
    error: error ?? this.error,
    viewMode: viewMode ?? this.viewMode,
    isOffline: isOffline ?? this.isOffline,
  );
}

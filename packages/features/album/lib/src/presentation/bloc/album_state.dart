import 'package:flutter/foundation.dart';

import '../../domain/entities/stamp.dart';

/// The two Album display modes (SM-022 BR-04): a dense grid or a roomier list.
enum AlbumViewMode { grid, list }

/// The Album screen's state (SM-022): the loaded stamps plus loading/error
/// flags and the current view mode. Stamps are newest-first as the repository
/// returns them.
@immutable
class AlbumState {
  const AlbumState({
    this.stamps = const [],
    this.loading = true,
    this.error = false,
    this.viewMode = AlbumViewMode.grid,
  });

  final List<Stamp> stamps;
  final bool loading;
  final bool error;
  final AlbumViewMode viewMode;

  bool get isEmpty => !loading && !error && stamps.isEmpty;

  AlbumState copyWith({
    List<Stamp>? stamps,
    bool? loading,
    bool? error,
    AlbumViewMode? viewMode,
  }) => AlbumState(
    stamps: stamps ?? this.stamps,
    loading: loading ?? this.loading,
    error: error ?? this.error,
    viewMode: viewMode ?? this.viewMode,
  );
}

import 'package:flutter/foundation.dart';

import '../../domain/entities/stamp.dart';

/// The Album screen's state (SM-022): the loaded stamps plus loading/error
/// flags. Stamps are newest-first as the repository returns them.
@immutable
class AlbumState {
  const AlbumState({
    this.stamps = const [],
    this.loading = true,
    this.error = false,
  });

  final List<Stamp> stamps;
  final bool loading;
  final bool error;

  bool get isEmpty => !loading && !error && stamps.isEmpty;

  AlbumState copyWith({
    List<Stamp>? stamps,
    bool? loading,
    bool? error,
  }) => AlbumState(
    stamps: stamps ?? this.stamps,
    loading: loading ?? this.loading,
    error: error ?? this.error,
  );
}

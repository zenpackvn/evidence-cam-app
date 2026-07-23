import 'package:app_ui/app_ui.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/stamp.dart';

/// The two Album display modes (SM-022 BR-04): a dense grid or a roomier list.
enum AlbumViewMode { grid, list }

/// Sort orders for the Album (filter button next to search).
enum AlbumSort { newest, oldest, name }

/// The Album screen's state (SM-022): the loaded stamps plus loading/error
/// flags, the current view mode, search query, sort order, and whether the
/// device is offline. Stamps are newest-first as the repository returns them.
@immutable
class AlbumState {
  const AlbumState({
    this.stamps = const [],
    this.loading = true,
    this.error = false,
    this.viewMode = AlbumViewMode.grid,
    this.isOffline = false,
    this.query = '',
    this.sort = AlbumSort.newest,
  });

  final List<Stamp> stamps;
  final bool loading;
  final bool error;
  final AlbumViewMode viewMode;

  /// Whether the device currently has no network link (SM-022 BR-10): the
  /// list still renders from the local store, with an offline notice on top.
  final bool isOffline;

  /// The live search query (diacritic-insensitive match on stamp names).
  final String query;

  /// The active sort order.
  final AlbumSort sort;

  bool get isEmpty => !loading && !error && stamps.isEmpty;

  /// Whether the network-bound write actions — rename and delete — are
  /// available (SM-022 BR-11 / AC-10: they are disabled while offline).
  bool get canMutate => !isOffline;

  /// The stamps surviving [query], in [sort] order. The name match folds
  /// Vietnamese diacritics ("hoa" finds "Hoa sen"); unnamed stamps match on
  /// their dd/MM/yyyy save date.
  List<Stamp> get visibleStamps {
    final q = stripDiacritics(query.toLowerCase());
    final out = [
      for (final s in stamps)
        if (q.isEmpty ||
            stripDiacritics(_labelFor(s).toLowerCase()).contains(q))
          s,
    ];
    switch (sort) {
      case AlbumSort.newest:
        out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case AlbumSort.oldest:
        out.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case AlbumSort.name:
        out.sort(
          (a, b) =>
              _labelFor(a).toLowerCase().compareTo(_labelFor(b).toLowerCase()),
        );
    }
    return out;
  }

  static String _labelFor(Stamp s) => s.name.isNotEmpty
      ? s.name
      : '${s.createdAt.day.toString().padLeft(2, '0')}/'
            '${s.createdAt.month.toString().padLeft(2, '0')}/'
            '${s.createdAt.year}';

  AlbumState copyWith({
    List<Stamp>? stamps,
    bool? loading,
    bool? error,
    AlbumViewMode? viewMode,
    bool? isOffline,
    String? query,
    AlbumSort? sort,
  }) => AlbumState(
    stamps: stamps ?? this.stamps,
    loading: loading ?? this.loading,
    error: error ?? this.error,
    viewMode: viewMode ?? this.viewMode,
    isOffline: isOffline ?? this.isOffline,
    query: query ?? this.query,
    sort: sort ?? this.sort,
  );
}

import 'package:flutter/foundation.dart';

import '../../domain/entities/sample_stamp.dart';

/// The sample-stamp browser's state (SM-035): the catalog, the theme filter,
/// and which samples the user has already saved to their album.
@immutable
class SampleStampsState {
  const SampleStampsState({
    this.all = const [],
    this.selectedTheme,
    this.savedIds = const {},
    this.loading = true,
    this.error = false,
  });

  /// The full catalog (all themes).
  final List<SampleStamp> all;

  /// The theme currently filtered to, or null for "all".
  final String? selectedTheme;

  /// Ids of samples already saved to the album (SM-035 BR-03 — dedupe).
  final Set<String> savedIds;

  final bool loading;
  final bool error;

  /// The distinct themes present in the catalog, in first-seen order (BR-02).
  List<String> get themes {
    final seen = <String>[];
    for (final s in all) {
      if (!seen.contains(s.theme)) seen.add(s.theme);
    }
    return seen;
  }

  /// The samples to show given [selectedTheme].
  List<SampleStamp> get visible => selectedTheme == null
      ? all
      : all.where((s) => s.theme == selectedTheme).toList();

  bool get isEmpty => !loading && !error && all.isEmpty;

  SampleStampsState copyWith({
    List<SampleStamp>? all,
    String? Function()? selectedTheme,
    Set<String>? savedIds,
    bool? loading,
    bool? error,
  }) => SampleStampsState(
    all: all ?? this.all,
    selectedTheme:
        selectedTheme != null ? selectedTheme() : this.selectedTheme,
    savedIds: savedIds ?? this.savedIds,
    loading: loading ?? this.loading,
    error: error ?? this.error,
  );
}

import 'dart:async';

import 'package:architecture/architecture.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:rev_sync/rev_sync.dart';

import '../../domain/entities/stamp.dart';
import '../../domain/repositories/stamps_repository.dart';
import 'album_state.dart';

/// Drives the Album screen (SM-022): loads the user's stamps from the
/// offline-first repository (local first, background sync), tracks the
/// connectivity state, and exposes delete/rename/refresh.
///
/// Offline behaviour (BR-10 / BR-11): the list keeps rendering from the local
/// store while [AlbumState.isOffline] drives the screen's offline notice, and
/// the network-bound writes (rename, delete) are refused rather than queued.
@injectable
class AlbumCubit extends Cubit<AlbumState> {
  AlbumCubit(this._stamps, this._connectivity) : super(const AlbumState()) {
    _onlineSub = _connectivity.onOnlineChanged.listen(_onOnlineChanged);
  }

  final StampsRepository _stamps;
  final ConnectivitySource _connectivity;
  late final StreamSubscription<bool> _onlineSub;

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: false));
    // BR-10: reads serve from the local store, so an offline load still fills
    // the list — the flag only drives the notice and the disabled actions.
    final isOffline = !await _connectivity.isOnline();
    final result = await _stamps.list();
    switch (result) {
      case Ok(:final value):
        emit(AlbumState(stamps: value, loading: false, isOffline: isOffline));
      case Err():
        emit(state.copyWith(loading: false, error: true, isOffline: isOffline));
    }
  }

  /// Deletes a stamp (SM-022 BR-09). Refused while offline (BR-11 / AC-10);
  /// the screen surfaces the "reconnect" notice.
  Future<void> delete(String id) async {
    if (!state.canMutate) return;
    final result = await _stamps.delete(id);
    if (result is Ok) {
      emit(
        state.copyWith(
          stamps: state.stamps.where((s) => s.id != id).toList(),
        ),
      );
    }
  }

  /// Renames a stamp (SM-022 BR-08) and reflects the new name in the list.
  /// Refused while offline (BR-11 / AC-10).
  Future<void> rename(String id, String name) async {
    if (!state.canMutate) return;
    final result = await _stamps.rename(id, name);
    if (result is Ok<Stamp>) {
      emit(
        state.copyWith(
          stamps: [
            for (final s in state.stamps)
              if (s.id == id) result.value else s,
          ],
        ),
      );
    }
  }

  /// Toggles between the grid and list view modes (SM-022 BR-04).
  void setViewMode(AlbumViewMode mode) {
    if (mode != state.viewMode) emit(state.copyWith(viewMode: mode));
  }

  void _onOnlineChanged(bool isOnline) {
    if (isClosed) return;
    final isOffline = !isOnline;
    if (isOffline == state.isOffline) return;
    emit(state.copyWith(isOffline: isOffline));
  }

  @override
  Future<void> close() {
    unawaited(_onlineSub.cancel());
    return super.close();
  }
}

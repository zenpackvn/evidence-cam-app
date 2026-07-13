import 'package:architecture/architecture.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/stamps_repository.dart';
import 'album_state.dart';

/// Drives the Album screen (SM-022): loads the user's stamps from the
/// offline-first repository (local first, background sync) and exposes
/// delete/refresh.
@injectable
class AlbumCubit extends Cubit<AlbumState> {
  AlbumCubit(this._stamps) : super(const AlbumState());

  final StampsRepository _stamps;

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: false));
    final result = await _stamps.list();
    switch (result) {
      case Ok(:final value):
        emit(AlbumState(stamps: value, loading: false));
      case Err():
        emit(state.copyWith(loading: false, error: true));
    }
  }

  Future<void> delete(String id) async {
    final result = await _stamps.delete(id);
    if (result is Ok) {
      emit(
        state.copyWith(
          stamps: state.stamps.where((s) => s.id != id).toList(),
        ),
      );
    }
  }
}

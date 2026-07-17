import 'package:architecture/architecture.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/sample_stamp.dart';
import '../../domain/entities/stamp.dart';
import '../../domain/repositories/sample_stamps_repository.dart';
import '../../domain/repositories/stamps_repository.dart';
import 'sample_stamps_state.dart';

/// Drives the sample-stamp browser (SM-035): loads the catalog, filters by
/// theme, and saves a sample into the personal album (deduped, free).
@injectable
class SampleStampsCubit extends Cubit<SampleStampsState> {
  SampleStampsCubit(this._samples, this._stamps)
    : super(const SampleStampsState());

  final SampleStampsRepository _samples;
  final StampsRepository _stamps;

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: false));
    final result = await _samples.list();
    switch (result) {
      case Ok(:final value):
        emit(state.copyWith(all: value, loading: false));
      case Err():
        emit(state.copyWith(loading: false, error: true));
    }
  }

  /// Filters the grid to [theme], or null to show all (SM-035 AC-01).
  void selectTheme(String? theme) =>
      emit(state.copyWith(selectedTheme: () => theme));

  /// Saves [sample] into the album (SM-035 BR-03/BR-05). Reuses the sample id
  /// so a repeat save is a no-op (AC-05); marks it saved on success.
  Future<void> save(SampleStamp sample) async {
    if (state.savedIds.contains(sample.id)) return;
    final result = await _stamps.save(
      StampInput(
        id: sample.id,
        imageUrl: sample.imageUrl,
        thumbUrl: sample.thumbUrl,
      ),
    );
    if (result is Ok<Stamp>) {
      emit(state.copyWith(savedIds: {...state.savedIds, sample.id}));
    }
  }
}

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/home_data.dart';
import 'home_state.dart';

part 'home_event.dart';

/// Loads the Home dashboard (SM-004): unread letters, recent stamps, and
/// recent sent letters, via the app-provided [HomeDataLoader].
@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._loader) : super(const HomeState(isLoading: true)) {
    on<HomeLoadRequested>(_onLoadRequested, transformer: droppable());
  }

  final HomeDataLoader _loader;

  Future<void> _onLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeState(data: state.data, isLoading: true));
    try {
      emit(HomeState(data: await _loader.load()));
    } on Exception catch (e) {
      // Keep whatever was on screen (SM-004 BR-06) and surface the error.
      emit(HomeState(data: state.data, error: e.toString()));
    }
  }
}

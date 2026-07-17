import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:rev_sync/rev_sync.dart';

import '../../domain/home_data.dart';
import 'home_state.dart';

part 'home_event.dart';

/// Loads the Home dashboard (SM-004): unread letters, recent stamps, and
/// recent sent letters, via the app-provided [HomeDataLoader], and tracks the
/// connectivity state that drives the offline notice.
@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._loader, this._connectivity)
    : super(const HomeState(isLoading: true)) {
    on<HomeLoadRequested>(_onLoadRequested, transformer: droppable());
    on<HomeConnectivityChanged>(_onConnectivityChanged);
    _onlineSub = _connectivity.onOnlineChanged.listen(
      (isOnline) => add(HomeConnectivityChanged(isOnline: isOnline)),
    );
  }

  final HomeDataLoader _loader;
  final ConnectivitySource _connectivity;
  late final StreamSubscription<bool> _onlineSub;

  Future<void> _onLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    final isOffline = !await _connectivity.isOnline();

    // BR-07 / AC-06: offline, a pull-to-refresh changes nothing — the data
    // stays as last loaded and no full-page error appears.
    if (event.isRefresh && isOffline) {
      emit(state.copyWith(isLoading: false, isOffline: true));
      return;
    }

    emit(HomeState(data: state.data, isLoading: true, isOffline: isOffline));
    try {
      emit(HomeState(data: await _loader.load(), isOffline: isOffline));
    } on Exception catch (e) {
      // Keep whatever was on screen (SM-004 BR-06) and surface the error.
      emit(
        HomeState(data: state.data, error: e.toString(), isOffline: isOffline),
      );
    }
  }

  void _onConnectivityChanged(
    HomeConnectivityChanged event,
    Emitter<HomeState> emit,
  ) {
    final isOffline = !event.isOnline;
    if (isOffline == state.isOffline) return;
    emit(state.copyWith(isOffline: isOffline));
  }

  @override
  Future<void> close() {
    unawaited(_onlineSub.cancel());
    return super.close();
  }
}

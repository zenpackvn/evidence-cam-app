import 'package:bloc/bloc.dart';

/// Guards against the "emit after close" hazard: a bloc or cubit that emits from
/// an asynchronous callback (a `Future` continuation, a stream listener, a
/// timer) which resolves after the bloc has been closed. Bare `emit` throws a
/// `StateError` in that case.
///
/// Mix this into a [Bloc] or [Cubit] and call [safeEmit] instead of `emit` at
/// async emit sites, replacing hand-rolled `if (!isClosed) emit(...)` guards
/// that were previously applied inconsistently across features.
///
/// ```dart
/// class SearchCubit extends Cubit<SearchState> with SafeEmitMixin {
///   Future<void> search(String q) async {
///     final results = await _repo.search(q); // may outlive the cubit
///     safeEmit(SearchState.results(results)); // no-op if already closed
///   }
/// }
/// ```
///
/// Lives in the pure-Dart `architecture` package (on top of `package:bloc`,
/// which is itself Flutter-free) so any feature's bloc/cubit can reuse it.
mixin SafeEmitMixin<State> on BlocBase<State> {
  /// Emits [state] only while this bloc/cubit is still open; a no-op once it
  /// has been closed.
  void safeEmit(State state) {
    if (!isClosed) emit(state);
  }
}

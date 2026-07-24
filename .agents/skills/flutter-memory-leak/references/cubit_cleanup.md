# Cubit / BLoC Cleanup

Cubits that subscribe to streams or hold resources **must** cancel in `close()`.

## Pattern

```dart
class TaskListCubit extends BaseCubit<TaskListState> {
  TaskListCubit({
    required GetTasksUseCase getTasksUseCase,
    required ConnectivityService connectivityService,
    required super.logger,
  })  : _getTasksUseCase = getTasksUseCase,
        _connectivityService = connectivityService,
        super(const TaskListInitial());

  final GetTasksUseCase _getTasksUseCase;
  final ConnectivityService _connectivityService;
  StreamSubscription<ConnectivityStatus>? _connectivitySub;

  void init() {
    _connectivitySub = _connectivityService.statusStream.listen(
      (status) {
        if (status == ConnectivityStatus.online) load();
      },
    );
  }

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    return super.close(); // BaseCubit.close() calls safeClose
  }
}
```

## Timer cancellation in cubits

```dart
// DON'T
class SearchCubit extends BaseCubit<SearchState> {
  Timer? _debounce;

  void onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(query));
    // Timer not cancelled on close()
  }
}

// DO
@override
Future<void> close() {
  _debounce?.cancel();
  return super.close();
}
```

## Rules

- All `StreamSubscription` fields in a cubit must be cancelled in `close()`.
- All `Timer` fields must be cancelled in `close()`.
- Call `super.close()` last — it emits the final state and closes the stream.

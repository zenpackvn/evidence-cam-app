# BLoC and Cubit Patterns

## When to Use Cubit vs BLoC

- Use **Cubit** for straightforward command-to-state flows: forms, detail loading, toggles, simple async actions.
- Use **full BLoC** when explicit events materially help with multiple inputs, event sequencing, debouncing, cancellation, pagination, or richer workflow semantics.
- Keep each bloc or cubit focused on one screen flow or bounded concern.

## State Modeling

- Model durable UI state with sealed variants (`initial`, `loading`, `success`, `empty`, `error`) — not boolean flag combinations.
- Keep state immutable and self-sufficient for the UI to render.
- Treat snack bars, dialogs, navigation as **listener concerns** — not sticky state.
- All state classes must extend `Equatable` and list all fields in `props`.

## Widget Usage Rules

- Name Cubit methods as clear user actions. Name BLoC events after meaningful intents.
- Keep `BuildContext` out of blocs and cubits.
- Provide blocs or cubits at route/feature boundaries, not deep in leaf widgets.
- Use `BlocBuilder` for rendering, `BlocListener` for one-off effects, `BlocConsumer` only when both are needed.
- Use selectors or smaller widgets to avoid full-screen rebuilds.

## Async Safety

- Guard overlapping async work for search, refresh, submit, pagination flows.
- Use `safeEmit()` from `BaseCubit` (via `SafeEmitMixin`) — never call raw `emit()` after an `await` without checking `isClosed`.
- Keep repositories, APIs, persistence out of the widget tree — cubits coordinate those.
- Test with `bloc_test` to verify state sequences, error handling, retry, duplicate-action guards.

## Anti-Patterns

### 1. Putting business logic in widgets

```dart
// DON'T — fetching data and transforming it inside a widget
class _HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt<ApiClient>().get('/greetings'),
      builder: (context, snapshot) {
        final filtered = snapshot.data?.where((g) => g.isActive).toList();
        // ...
      },
    );
  }
}

// DO — keep business logic in the cubit, widget only renders state
class HomeCubit extends BaseCubit<List<Greeting>> {
  // fetchData() is the only method to implement — BaseCubit handles
  // load/refresh lifecycle, safeEmit, and error mapping.
  @override
  Future<List<Greeting>> fetchData() => _repository.fetchActiveGreetings();
}
```

### 2. Using setState for async/shared state instead of Cubit

```dart
// DON'T
class _HomeViewState extends State<_HomeView> {
  List<String>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await getIt<HomeRepository>().fetchGreetings();
    setState(() { _data = data; _loading = false; });
  }
}

// DO — use Cubit for async/shared state; reserve setState for local-only UI concerns
BlocBuilder<HomeCubit, HomeState>(
  builder: (context, state) => switch (state) {
    HomeLoading() => const ScreenLoading(),
    HomeLoaded(:final greetings) => GreetingList(greetings: greetings),
    // ...
  },
)
```

### 3. Emitting states after async gap without checking isClosed

```dart
// DON'T — cubit may have been closed while awaiting
Future<void> load() async {
  emit(const HomeLoading());
  final data = await _repository.fetchGreetings();
  emit(HomeLoaded(data)); // crashes if cubit was disposed
}

// DO — use safeEmit() from SafeEmitMixin (inherited by BaseCubit)
// safeEmit checks isClosed before every emit — no manual guards needed
Future<void> load() async {
  safeEmit(const HomeLoading());
  final data = await _repository.fetchGreetings();
  safeEmit(HomeLoaded(data));
}
```

### 4. Mixing UI side-effects (navigation, dialogs) with state emission

```dart
// DON'T — cubit navigates or shows dialogs directly
class HomeCubit extends BaseCubit<Home> {
  final AppNavigator _navigator;

  Future<void> submit() async {
    await _repository.save();
    _navigator.goHome(); // side-effect coupled to cubit
  }
}

// DO — emit a state, let BlocListener handle the side-effect
// cubit:
safeEmit(const HomeSubmitSuccess());

// widget:
BlocListener<HomeCubit, HomeState>(
  listenWhen: (prev, curr) => curr is HomeSubmitSuccess,
  listener: (context, state) => navigator(context).goHome(),
)
```

### 5. Not making states Equatable

```dart
// DON'T — BlocBuilder cannot detect duplicate states, rebuilds every time
class HomeLoaded extends HomeState {
  const HomeLoaded(this.greetings);
  final List<String> greetings;
  // missing props override
}

// DO — extend Equatable and list all fields in props
class HomeLoaded extends HomeState {
  const HomeLoaded(this.greetings);
  final List<String> greetings;
  @override
  List<Object?> get props => [greetings];
}
```

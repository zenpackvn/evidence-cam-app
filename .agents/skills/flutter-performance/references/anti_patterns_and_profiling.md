# Anti-Patterns and DevTools Profiling

## Anti-Patterns (DON'T)

### DON'T: `FutureBuilder` in `build()` — use cubit instead

```dart
// BAD: Re-fires the future on every rebuild, no error handling.
@override
Widget build(BuildContext context) {
  return FutureBuilder<User>(
    future: fetchUser(), // Creates a new Future on every build!
    builder: (context, snapshot) {
      if (snapshot.hasData) return Text(snapshot.data!.name);
      return const CircularProgressIndicator();
    },
  );
}

// GOOD: Cubit fetches once; widget reacts to state.
class UserCubit extends Cubit<UserState> {
  UserCubit({required this.userRepository}) : super(const UserLoading());

  final UserRepository userRepository;

  Future<void> load() async {
    try {
      final user = await userRepository.getUser();
      emit(UserLoaded(user: user));
    } on FailureException catch (e) {
      emit(UserError(failure: e.failure));
    }
  }
}

// Widget — no FutureBuilder needed.
@override
Widget build(BuildContext context) {
  return BlocBuilder<UserCubit, UserState>(
    builder: (context, state) {
      return switch (state) {
        UserLoading() => const ScreenLoading(),
        UserLoaded(:final user) => Text(user.name),
        UserError(:final failure) => ErrorView(failure: failure),
      };
    },
  );
}
```

### DON'T: Rebuild entire page when only a counter changes

```dart
// BAD
BlocBuilder<DashboardCubit, DashboardState>(
  builder: (context, state) {
    return Column(
      children: [
        ExpensiveChart(data: chartData),    // rebuilds unnecessarily
        Text('Count: ${state.counter}'),
      ],
    );
  },
);

// GOOD: Only the counter rebuilds.
Column(
  children: [
    const ExpensiveChart(data: chartData),  // const — never rebuilds
    BlocSelector<DashboardCubit, DashboardState, int>(
      selector: (state) => state.counter,
      builder: (context, counter) => Text('Count: $counter'),
    ),
  ],
);
```

### DON'T: `ListView(children: items.map(...).toList())`

```dart
// BAD: All items built eagerly.
ListView(
  children: items.map((item) => ItemTile(item: item)).toList(),
);

// GOOD: Only visible items built.
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemTile(
    key: ValueKey(items[index].id),
    item: items[index],
  ),
);
```

### DON'T: Parse JSON on main thread for large payloads

```dart
// BAD
final list = jsonDecode(bigJsonString) as List;
final orders = list.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();

// GOOD
final orders = await Isolate.run(() => _parseOrders(bigJsonString));
```

### DON'T: Create new closures/objects in `build()` that could be const or cached

```dart
// BAD: New InputDecoration created on every rebuild.
@override
Widget build(BuildContext context) {
  return TextField(
    decoration: InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

// GOOD: Const or static decoration.
static const _inputDecoration = InputDecoration(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusSm)),
  ),
);

@override
Widget build(BuildContext context) {
  return const TextField(decoration: _inputDecoration);
}
```

### DON'T: Use `GlobalKey` for simple state — use cubit or `ValueNotifier`

```dart
// BAD: GlobalKey to read state of another widget.
final _formKey = GlobalKey<_MyFormState>();

void _submit() {
  _formKey.currentState?.save();
}

// GOOD: Form state lives in a cubit.
class FormCubit extends Cubit<FormDataState> {
  FormCubit() : super(const FormDataState());

  void updateName(String name) => emit(state.copyWith(name: name));

  Future<void> submit() async {
    // Validation and submission logic here.
  }
}
```

---

## DevTools Profiling Workflow

1. **Run in profile mode** — `flutter run --profile` (release-like performance with DevTools enabled).
2. **Open DevTools** — URL printed in the terminal, or press `d` in the CLI.
3. **Performance tab** — Record a user flow (scroll a list, open a screen, tap buttons).
4. **Identify jank** — Look for frames exceeding 16 ms in the flame chart.
5. **Widget Rebuild Stats** — Enable "Track Widget Rebuilds" to find widgets that rebuild too often.
6. **Memory tab** — Take heap snapshots before and after navigation to detect leaks. Objects retained after popping a screen are suspect.
7. **Fix and re-profile** — Apply the patterns above, then re-run the same flow to confirm improvement.

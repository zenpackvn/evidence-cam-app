# Build Method Rules and Memory Management

## Build Method Rules

Keep `build()` pure: no side effects, no async calls, no service locator lookups. Extract complex subtrees into separate widget classes. Use `Builder` to scope `Theme.of(context)` or `MediaQuery.of(context)` lookups to the smallest subtree.

### CORRECT

```dart
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // build() is pure — it only returns a widget tree.
    return BlocProvider(
      create: (_) => getIt<SettingsCubit>()..load(),
      child: const _SettingsBody(),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return switch (state) {
          SettingsLoading() => const ScreenLoading(),
          SettingsLoaded(:final settings) => ListView(
              children: [
                Text('Settings', style: theme.textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.md),
                _ThemeToggle(isDark: settings.isDarkMode),
              ],
            ),
          SettingsError(:final failure) => ErrorView(failure: failure),
        };
      },
    );
  }
}
```

### WRONG

```dart
// BAD: Side effects and DI lookups inside build().
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // BAD: Service locator call in build — runs on every rebuild.
    final cubit = getIt<SettingsCubit>();
    // BAD: Side effect in build.
    cubit.load();

    return BlocBuilder<SettingsCubit, SettingsState>(
      bloc: cubit,
      builder: (context, state) {
        return const Placeholder();
      },
    );
  }
}
```

---

## Memory Management

Cancel timers, animation controllers, and stream subscriptions in `dispose()` (widgets) or `close()` (cubits). Profile with DevTools Memory tab to detect leaks.

### CORRECT

```dart
class CountdownTimer extends StatefulWidget {
  const CountdownTimer({super.key, required this.seconds});

  final int seconds;

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  late int _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining > 0) {
        setState(() => _remaining--);
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Always cancel in dispose.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('$_remaining s');
  }
}
```

### WRONG

```dart
// BAD: Timer never cancelled — keeps firing after widget is removed.
class _CountdownTimerState extends State<CountdownTimer> {
  int _remaining = 60;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _remaining--); // setState on disposed widget = crash.
    });
  }

  // No dispose() — timer leaks.

  @override
  Widget build(BuildContext context) => Text('$_remaining s');
}
```

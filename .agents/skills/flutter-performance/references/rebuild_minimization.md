# Rebuild Minimization

Use `BlocSelector` to select a single field and `BlocBuilder` with `buildWhen` to skip unnecessary rebuilds. Extract child widgets that do not depend on state as separate `const` widgets.

## CORRECT

```dart
/// State with many fields — only the counter matters to CounterLabel.
class DashboardState extends Equatable {
  const DashboardState({
    this.counter = 0,
    this.userName = '',
    this.notifications = const [],
    this.isOnline = false,
  });

  final int counter;
  final String userName;
  final List<String> notifications;
  final bool isOnline;

  @override
  List<Object?> get props => [counter, userName, notifications, isOnline];

  DashboardState copyWith({
    int? counter,
    String? userName,
    List<String>? notifications,
    bool? isOnline,
  }) {
    return DashboardState(
      counter: counter ?? this.counter,
      userName: userName ?? this.userName,
      notifications: notifications ?? this.notifications,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

/// Only rebuilds when `counter` changes — ignores userName, notifications, etc.
class CounterLabel extends StatelessWidget {
  const CounterLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<DashboardCubit, DashboardState, int>(
      selector: (state) => state.counter,
      builder: (context, counter) {
        return Text('Count: $counter');
      },
    );
  }
}

/// BlocBuilder with buildWhen — rebuilds only when isOnline changes.
class OnlineIndicator extends StatelessWidget {
  const OnlineIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      buildWhen: (prev, curr) => prev.isOnline != curr.isOnline,
      builder: (context, state) {
        return Icon(
          state.isOnline ? Icons.cloud_done : Icons.cloud_off,
          color: state.isOnline
              ? AppColors.success
              : AppColors.textSecondary,
        );
      },
    );
  }
}

/// Page composes focused widgets — static parts are const.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DashboardCubit>(),
      child: const Column(
        children: [
          _DashboardHeader(),   // const — never rebuilds from cubit
          CounterLabel(),       // rebuilds only on counter change
          OnlineIndicator(),    // rebuilds only on isOnline change
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Text('Dashboard'),
    );
  }
}
```

## WRONG

```dart
// BAD: Entire page rebuilds on every state change.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        // Everything in here rebuilds when ANY field changes.
        return Column(
          children: [
            Text('Dashboard'),             // static — shouldn't rebuild
            Text('Count: ${state.counter}'),
            Icon(state.isOnline ? Icons.cloud_done : Icons.cloud_off),
          ],
        );
      },
    );
  }
}
```

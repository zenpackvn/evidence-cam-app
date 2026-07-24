# Main Shell and Tab Navigation

## `lib/src/app/router/tab_refresh_notifier.dart`

One `ValueNotifier<int>` per tab. Incrementing a counter causes pages using `ValueKey` on their `BlocProvider` to recreate — triggering a fresh data load.

```dart
import 'package:flutter/foundation.dart';

class TabRefreshNotifier {
  TabRefreshNotifier(int tabCount)
      : _notifiers = List.generate(tabCount, (_) => ValueNotifier<int>(0));

  final List<ValueNotifier<int>> _notifiers;

  ValueNotifier<int> forTab(int index) => _notifiers[index];

  void refresh(int index) {
    if (index >= 0 && index < _notifiers.length) {
      _notifiers[index].value++;
    }
  }

  void dispose() {
    for (final n in _notifiers) n.dispose();
  }
}
```

Register in DI:
```dart
getIt.registerSingleton<TabRefreshNotifier>(TabRefreshNotifier(4));
```

## `lib/src/app/router/main_shell.dart`

`StatefulWidget` — tracks double-tap timing to distinguish a reload gesture from normal navigation. `StatefulNavigationShell` owns the `IndexedStack` and current-index, so no manual location parsing is needed.

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/service_locator.dart';
import 'tab_refresh_notifier.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _doubleTapWindow = Duration(milliseconds: 300);

  int? _lastTappedIndex;
  DateTime? _lastTapTime;

  void _onDestinationSelected(int index) {
    final now = DateTime.now();
    final isDoubleTap = _lastTappedIndex == index &&
        _lastTapTime != null &&
        now.difference(_lastTapTime!) <= _doubleTapWindow;

    if (isDoubleTap) {
      // Double-tap: reload tab data and reset tracker.
      getIt<TabRefreshNotifier>().refresh(index);
      _lastTappedIndex = null;
      _lastTapTime = null;
    } else {
      _lastTappedIndex = index;
      _lastTapTime = now;
    }

    widget.shell.goBranch(
      index,
      // Pop to branch root if already on this tab.
      initialLocation: index == widget.shell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.shell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.article), label: 'Posts'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
```

## Tab page reload pattern

Wrap each tab page's `BlocProvider` with `ValueListenableBuilder` + `ValueKey`. When the notifier increments, the key changes → Flutter destroys and recreates the `BlocProvider` → `create` fires again with fresh data load.

```dart
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: getIt<TabRefreshNotifier>().forTab(0), // tab index
      builder: (context, version, _) => BlocProvider<HomeCubit>(
        key: ValueKey(version),
        create: (_) => getIt<HomeCubit>()..load(),
        child: const _HomeView(),
      ),
    );
  }
}
```

- `forTab(0)` — matches the branch index in `StatefulShellRoute`
- `ValueKey(version)` — changing key forces `BlocProvider` recreation
- Works for `MultiBlocProvider` too — put the key on the provider, not the child

## Custom Transitions

```dart
GoRoute(
  path: '/posts/:id',
  pageBuilder: (context, state) {
    final postId = int.parse(state.pathParameters['id']!);
    return CustomTransitionPage(
      key: state.pageKey,
      child: PostDetailPage(postId: postId),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      },
    );
  },
),
```

## Widget test with real router

```dart
Widget buildTestApp({required String initialLocation}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomePage()),
      GoRoute(
        path: '/posts/:id',
        builder: (_, state) {
          final id = int.parse(state.pathParameters['id']!);
          return PostDetailPage(postId: id);
        },
      ),
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

testWidgets('navigates to post detail', (tester) async {
  await tester.pumpWidget(buildTestApp(initialLocation: '/posts/42'));
  await tester.pumpAndSettle();
  expect(find.text('Post Detail'), findsOneWidget);
});
```

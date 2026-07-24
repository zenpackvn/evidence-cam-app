---
name: flutter-memory-leak
description: Use this skill when detecting or fixing Flutter memory leaks — disposing controllers, cancelling StreamSubscriptions, leak_tracker integration, Flutter DevTools memory profiling, StatefulWidget dispose, AnimationController leaks, TextEditingController leaks, ScrollController leaks, FocusNode leaks, StreamController leaks, BuildContext leaks, widget test leak assertions, or auditing a Flutter app for memory leak sources.
---

# Flutter Memory Leak

Full reference: [`template.md`](references/template.md)

## Key rules

### Dispose everything in StatefulWidget
Every controller, subscription, and notifier created in `initState` or `State` fields **must** be disposed in `dispose()`. No exceptions.

```dart
class _MyPageState extends State<MyPage> {
  late final TextEditingController _text;
  late final AnimationController _anim;
  late final ScrollController _scroll;
  late final FocusNode _focus;
  StreamSubscription<dynamic>? _sub;

  @override
  void initState() {
    super.initState();
    _text   = TextEditingController();
    _anim   = AnimationController(vsync: this, duration: Durations.medium2);
    _scroll = ScrollController();
    _focus  = FocusNode();
    _sub    = someStream.listen(_onEvent);
  }

  @override
  void dispose() {
    _text.dispose();
    _anim.dispose();
    _scroll.dispose();
    _focus.dispose();
    _sub?.cancel();
    super.dispose();
  }
}
```

### Cubits: cancel subscriptions in `close()`

```dart
class MyCubit extends BaseCubit<MyState> {
  MyCubit({...}) : super(const MyInitial());
  StreamSubscription<dynamic>? _sub;

  void init() {
    _sub = someStream.listen(_onEvent);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
```

### Never capture `BuildContext` across async gaps without `mounted` check
```dart
// DON'T
Future<void> _submit() async {
  await someAsyncOp();
  context.go('/next'); // context may be stale
}

// DO
Future<void> _submit() async {
  await someAsyncOp();
  if (!mounted) return;
  context.go('/next');
}
```

### Enable `leak_tracker` globally

Add `leak_tracker_flutter_testing: 3.0.9` to `dev_dependencies`, then create a global test config:

```dart
// test/flutter_test_config.dart — auto-loaded by test runner for ALL test files
import 'dart:async';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  LeakTesting.enable();
  await testMain();
}
```

No per-test setup needed. Every `testWidgets` automatically checks for undisposed `Disposable` objects.

**Opt out for known platform leaks** (rare — only for widgets outside your control):

```dart
testWidgets(
  'platform widget with known leak',
  (tester) async { ... },
  leakTrackingConfig: const LeakTesting.settings.withIgnoredAll(),
);
```

### Leak test pattern — verify dispose on unmount

```dart
testWidgets('disposes cleanly on unmount', (tester) async {
  await tester.pumpWidget(
    BlocProvider(
      create: (_) => MockTaskListCubit(),
      child: const MaterialApp(home: TaskListPage()),
    ),
  );
  await tester.pumpAndSettle();

  // Navigate away → triggers dispose
  await tester.pumpWidget(const SizedBox());
  await tester.pumpAndSettle();

  // leak_tracker asserts no leaks at test teardown
});
```

### Audit checklist

Run before every release:

**1. Static — find controllers with no matching dispose:**

```bash
grep -rn "TextEditingController()\|AnimationController(\|ScrollController()\|FocusNode()" lib/ \
  | grep -v "_test.dart"
# Then verify each file has .dispose() for every match
```

**2. Static — find subscriptions with no matching cancel:**

```bash
grep -rn "\.listen(" lib/ --include="*.dart" | grep -v "_impl.dart" | grep -v "_test.dart"
# Then verify each file has .cancel() for every match
```

**3. Static — find StreamControllers with no matching close:**

```bash
grep -rn "StreamController(" lib/ | grep -v "_test.dart"
# Then verify each file has .close() in dispose()
```

**4. Static — find Timers with no matching cancel:**

```bash
grep -rn "Timer\.\|Timer(" lib/ | grep -v "_test.dart"
# Then verify each file has .cancel() in dispose()/close()
```

**5. Runtime** — Flutter DevTools → Memory tab → GC → look for retained widget/cubit instances

**6. leak_tracker** — `flutter test` (enabled globally via `flutter_test_config.dart`)

## Common leak sources

| Source | Fix |
|---|---|
| `TextEditingController` in `State` | `dispose()` in `State.dispose()` |
| `AnimationController` | `dispose()` in `State.dispose()` |
| `ScrollController` / `FocusNode` | `dispose()` in `State.dispose()` |
| `StreamSubscription` | `cancel()` in `State.dispose()` or `Cubit.close()` |
| `StreamController` | `close()` in `dispose()` |
| `Timer` | `cancel()` in `dispose()` |
| Cubit holding a stream | `cancel()` in `Cubit.close()` |
| `ChangeNotifier` listener | `removeListener()` in `dispose()` |
| Image cache not bounded | Set `PaintingBinding.instance.imageCache.maximumSizeBytes` |
| `GlobalKey` held in `State` field beyond route lifetime | Use local key, don't store in singletons |

## Co-load with

- `flutter-performance` — memory leaks cause frame drops and jank
- `flutter-tests` — `leak_tracker` runs in widget tests
- `flutter-base-classes` — `BaseCubit.close()` is the hook for cubit cleanup
- `flutter-error-handling` — `ErrorHandler` catches leaks that escape `dispose()` as zone/platform errors

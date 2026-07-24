# Common Leak Patterns — DON'T / DO

## StreamController not closed

```dart
// DON'T
class MyState extends State<MyWidget> {
  final _controller = StreamController<int>();
  // never closed → leak
}

// DO
class MyState extends State<MyWidget> {
  final _controller = StreamController<int>();

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}
```

## ChangeNotifier listener not removed

```dart
// DON'T
class MyState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
    someNotifier.addListener(_rebuild);
  }
  // never removed → notifier holds reference to State
}

// DO
@override
void initState() {
  super.initState();
  someNotifier.addListener(_rebuild);
}

@override
void dispose() {
  someNotifier.removeListener(_rebuild);
  super.dispose();
}
```

## GlobalKey stored in a singleton

```dart
// DON'T — prevents widget from being GCed
class AppRouter {
  static final _scaffoldKey = GlobalKey<ScaffoldState>(); // lives forever
}

// DO — own the key at the widget level
class _MyPageState extends State<MyPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
}
```

## Anti-Patterns Summary

| Anti-pattern | Fix |
|---|---|
| `initState` creates controller, no `dispose()` override | Add `dispose()`, call `controller.dispose()` |
| `listen()` result ignored (`void`) | Store `StreamSubscription`, cancel in `dispose()` |
| `context.go()` after `await` without `mounted` | Add `if (!mounted) return;` |
| `GlobalKey` in static field | Move to `State` field |
| Image loaded without size constraints | Add `width`/`height` + `memCacheWidth`/`memCacheHeight` |
| `Timer.periodic` in cubit, no `close()` override | Cancel in `Cubit.close()` |
| `ChangeNotifier.addListener` without `removeListener` | Always pair `addListener` with `removeListener` in `dispose()` |

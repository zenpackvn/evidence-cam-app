# Dispose Contract — StatefulWidget

Every `StatefulWidget` that creates any resource **owns** that resource and **must** release it in `dispose()`. This is the memory-leak equivalent of the wrapper rule.

## pubspec.yaml additions

```yaml
dev_dependencies:
  leak_tracker_flutter_testing: 3.0.10
```

> `leak_tracker_flutter_testing` wraps `leak_tracker` for widget test integration.
> No production dependency needed — it's dev-only.

---

## Full dispose pattern

```dart
class _FeaturePageState extends State<FeaturePage>
    with SingleTickerProviderStateMixin {
  // Controllers
  late final TextEditingController _searchController;
  late final AnimationController _animController;
  late final ScrollController _scrollController;
  late final FocusNode _searchFocus;

  // Subscriptions
  StreamSubscription<ConnectivityStatus>? _connectivitySub;
  StreamSubscription<AuthStatus>? _authSub;

  // Timers
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _animController = AnimationController(
      vsync: this,
      duration: AppAnimations.medium,
    );
    _scrollController = ScrollController();
    _searchFocus = FocusNode();

    _connectivitySub = getIt<ConnectivityService>()
        .statusStream
        .listen(_onConnectivityChanged);
    _authSub = getIt<AuthService>().statusStream.listen(_onAuthChanged);
  }

  @override
  void dispose() {
    // Controllers
    _searchController.dispose();
    _animController.dispose();
    _scrollController.dispose();
    _searchFocus.dispose();

    // Subscriptions
    _connectivitySub?.cancel();
    _authSub?.cancel();

    // Timers
    _debounceTimer?.cancel();

    super.dispose(); // always last
  }
}
```

## Rules

1. `super.dispose()` is **always the last call** in `dispose()`.
2. All `late final` fields must be disposed — the compiler won't catch missing dispose calls.
3. Nullable subscriptions (`StreamSubscription?`) use `?.cancel()` — safe even if never assigned.
4. Use `late final` for controllers (assigned exactly once in `initState`) — prevents accidental reassignment.

# Image Optimization and State Management Performance

## Image Optimization

Use `cacheWidth` / `cacheHeight` on `Image.asset` to decode images at display size rather than full resolution. For network images, use the app-owned `AppCachedImage` wrapper (see template-common-widgets.md). Use WebP for photos and SVG for icons.

### CORRECT

```dart
class ProductThumbnail extends StatelessWidget {
  const ProductThumbnail({super.key, required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    // Decode at 2x the display size for retina, not the full 4000px original.
    return Image.asset(
      assetPath,
      width: 120,
      height: 120,
      cacheWidth: 240,   // 2x for device pixel ratio
      cacheHeight: 240,
      fit: BoxFit.cover,
    );
  }
}
```

### WRONG

```dart
// BAD: Full-resolution decode into memory for a 120x120 display area.
class ProductThumbnail extends StatelessWidget {
  const ProductThumbnail({super.key, required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: 120,
      height: 120,
      fit: BoxFit.cover,
      // No cacheWidth/cacheHeight — decodes the full 4000x3000 image.
    );
  }
}
```

---

## State Management Performance

Cubits are created as factories through DI — never singletons. This prevents state from leaking between screens or user sessions. Dispose streams and controllers in `close()`. Rely on `Equatable` to skip identical-state emissions.

### CORRECT

```dart
class OrderListCubit extends Cubit<OrderListState> {
  OrderListCubit({required this.orderRepository})
      : super(const OrderListInitial());

  final OrderRepository orderRepository;

  StreamSubscription<List<Order>>? _subscription;

  Future<void> watch() async {
    _subscription = orderRepository.watchOrders().distinct().listen(
      (orders) {
        if (orders.isEmpty) {
          emit(const OrderListEmpty());
        } else {
          emit(OrderListLoaded(orders: orders));
        }
      },
      onError: (Object e, StackTrace s) {
        emit(const OrderListError(failure: UnknownFailure()));
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
```

### WRONG

```dart
// BAD: Cubit registered as singleton — state persists across screen visits.
// BAD: StreamSubscription never cancelled — memory leak.
class OrderListCubit extends Cubit<OrderListState> {
  OrderListCubit({required this.orderRepository})
      : super(const OrderListInitial());

  final OrderRepository orderRepository;

  Future<void> watch() async {
    // Subscription is not stored — can never be cancelled.
    orderRepository.watchOrders().listen((orders) {
      emit(OrderListLoaded(orders: orders));
    });
  }

  // No close() override — subscription leaks.
}
```

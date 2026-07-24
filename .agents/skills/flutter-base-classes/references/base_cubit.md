# BaseCubit

Base cubit for standard fetch-data flows. Provides safe emit, load/refresh lifecycle, error handling, and logger access. Subclasses only implement `fetchData()`.

## File

`lib/src/core/base/base_cubit.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../error/failure.dart';
import '../logging/app_logger.dart';
import 'base_state.dart';
import 'safe_emit_mixin.dart';

/// Base cubit with common patterns:
/// - Safe emit (checks `isClosed` before emitting)
/// - Standard load/refresh lifecycle
/// - Error handling with typed failures
/// - Logger access
///
/// Type [T] is the data type for [BaseState<T>].
abstract class BaseCubit<T> extends Cubit<BaseState<T>>
    with SafeEmitMixin<BaseState<T>> {
  BaseCubit({required this.logger}) : super(const BaseInitial());

  final AppLogger logger;

  /// Implement this — the actual data fetch.
  Future<T> fetchData();

  /// Whether an empty result should emit [BaseEmpty] or [BaseSuccess] with empty data.
  /// Override to return `false` if empty data is still a valid success.
  bool get emitEmptyState => true;

  /// Check if data is empty. Override for non-list types.
  bool isEmpty(T data) {
    if (data is List) return data.isEmpty;
    if (data is Map) return data.isEmpty;
    return false;
  }

  // ── Lifecycle ──

  /// Load data (shows loading indicator).
  Future<void> load() async {
    safeEmit(const BaseLoading());
    await _fetch();
  }

  /// Refresh data (no loading indicator — for pull-to-refresh).
  Future<void> refresh() async {
    await _fetch();
  }

  Future<void> _fetch() async {
    try {
      final data = await fetchData();
      if (emitEmptyState && isEmpty(data)) {
        safeEmit(const BaseEmpty());
      } else {
        safeEmit(BaseSuccess(data));
      }
    } on FailureException catch (e) {
      safeEmit(BaseError(e.failure));
    } catch (e, s) {
      logger.error('${runtimeType}.fetchData() failed', error: e, stackTrace: s);
      safeEmit(const BaseError(UnknownFailure()));
    }
  }

  // safeEmit() inherited from SafeEmitMixin — checks isClosed before emitting.
}
```

## Usage

### Minimal — just override `fetchData()`

```dart
import '../../../core/base/base_cubit.dart';
import '../domain/entities/user.dart';
import '../domain/repositories/user_repository.dart';

class UserDetailCubit extends BaseCubit<User> {
  UserDetailCubit({
    required this.userRepository,
    required super.logger,
    required this.userId,
  });

  final UserRepository userRepository;
  final String userId;

  @override
  Future<User> fetchData() => userRepository.getUser(userId);
}
```

### With additional actions

```dart
class ProductListCubit extends BaseCubit<List<Product>> {
  ProductListCubit({
    required this.productRepository,
    required super.logger,
  });

  final ProductRepository productRepository;

  @override
  Future<List<Product>> fetchData() => productRepository.getProducts();

  Future<void> toggleFavorite(String productId) async {
    try {
      await productRepository.toggleFavorite(productId);
      await refresh();
    } on FailureException catch (e) {
      safeEmit(BaseError(e.failure));
    }
  }
}
```

## When to use `BaseCubit` vs alternatives

| Scenario | Use |
|--|--|
| Fetch and display data | `BaseCubit<T>` |
| Mutations, form submissions | `Cubit<S> with SafeEmitMixin<S>` |
| State persisted across restarts | `BaseHydratedCubit<S>` |
| Paginated lists | `BasePaginatedCubit<T>` |

## Testing

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLogger extends Mock implements AppLogger {}

class TestCubit extends BaseCubit<String> {
  TestCubit({required this.fetchFn, required super.logger});
  final Future<String> Function() fetchFn;

  @override
  Future<String> fetchData() => fetchFn();
}

void main() {
  late MockLogger mockLogger;
  setUp(() => mockLogger = MockLogger());

  blocTest<TestCubit, BaseState<String>>(
    'emits [loading, success] on successful fetch',
    build: () => TestCubit(fetchFn: () async => 'hello', logger: mockLogger),
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<BaseLoading<String>>(),
      isA<BaseSuccess<String>>().having((s) => s.data, 'data', 'hello'),
    ],
  );

  blocTest<TestCubit, BaseState<String>>(
    'emits [loading, error] on FailureException',
    build: () => TestCubit(
      fetchFn: () async => throw const FailureException(ServerFailure('oops')),
      logger: mockLogger,
    ),
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<BaseLoading<String>>(),
      isA<BaseError<String>>().having((s) => s.failure, 'failure', isA<ServerFailure>()),
    ],
  );

  blocTest<TestCubit, BaseState<String>>(
    'refresh does not emit loading state',
    build: () => TestCubit(fetchFn: () async => 'refreshed', logger: mockLogger),
    act: (cubit) => cubit.refresh(),
    expect: () => [
      isA<BaseSuccess<String>>().having((s) => s.data, 'data', 'refreshed'),
    ],
  );
}
```

## Rules

- Override only `fetchData()` for standard flows. `load()`, `refresh()`, error handling, and safe emit are inherited.
- Use `safeEmit()` for any custom actions — never raw `emit()`.
- Test base classes once; feature cubits only test `fetchData()` and custom actions.

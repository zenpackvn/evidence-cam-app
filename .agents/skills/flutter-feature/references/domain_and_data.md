# Feature — Domain Repository and Data Implementation

Domain repository interface and data-layer implementation for a feature slice.

## `lib/src/features/home/domain/home_repository.dart`

```dart
abstract interface class HomeRepository {
  Future<List<String>> fetchGreetings();
}
```

## `lib/src/features/home/data/home_repository_impl.dart`

```dart
import '../../../core/error/failure.dart';
import '../../../core/logging/app_logger.dart';
import '../domain/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({required this.logger});
  final AppLogger logger;

  @override
  Future<List<String>> fetchGreetings() async {
    try {
      // Replace with apiClient.fetchGreetings() once the endpoint is wired.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return const ['Hello', 'Xin chào'];
    } catch (e, s) {
      logger.warn('fetchGreetings failed', error: e, stackTrace: s);
      throw const FailureException(UnknownFailure());
    }
  }
}
```

## Rules

- The domain repository is an abstract `interface class` — no logic, no imports from `data/`.
- The impl catches all exceptions and rethrows as `FailureException` — callers never see raw exceptions.
- For real API features replace the stub `Future.delayed` with `apiClient.method()` from [flutter-network](../flutter-network/references/template.md).
- `HomeRepositoryImpl` imports only `AppLogger` (from core) and `HomeRepository` (from domain) — no third-party imports.

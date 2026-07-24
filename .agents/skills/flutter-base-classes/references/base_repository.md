# BaseRepository

Mixin with common try/catch → `FailureException` pattern. Eliminates repetitive boilerplate in every repository method.

## File

`lib/src/core/base/base_repository.dart`

```dart
import '../error/failure.dart';
import '../logging/app_logger.dart';

/// Base repository mixin with common try/catch → FailureException pattern.
///
/// Use as a mixin on repository implementations to eliminate
/// repetitive try/catch blocks.
mixin BaseRepository {
  AppLogger get logger;

  /// Execute [action] with standard error handling.
  /// Catches all exceptions and wraps them in [FailureException].
  Future<T> safeCall<T>(
    Future<T> Function() action, {
    required String tag,
    Failure Function(Object error)? mapError,
  }) async {
    try {
      return await action();
    } on FailureException {
      rethrow; // Already wrapped — don't double-wrap.
    } catch (e, s) {
      logger.error('$tag failed', error: e, stackTrace: s);
      final failure = mapError?.call(e) ?? const UnknownFailure();
      throw FailureException(failure);
    }
  }

  /// Convert a list of DTOs to entities.
  List<E> mapToEntities<D, E>(List<D> dtos, E Function(D) mapper) {
    return dtos.map(mapper).toList();
  }
}
```

## Usage

```dart
import '../../../core/base/base_repository.dart';
import '../../../core/error/failure.dart';
import '../../../core/logging/app_logger.dart';
import '../domain/entities/user.dart';
import '../domain/repositories/user_repository.dart';
import 'sources/user_remote_source.dart';

class UserRepositoryImpl implements UserRepository with BaseRepository {
  UserRepositoryImpl({
    required this.remoteSource,
    required this.logger,
  });

  final UserRemoteSource remoteSource;

  @override
  final AppLogger logger;

  @override
  Future<User> getUser(String id) => safeCall(
        () async {
          final dto = await remoteSource.getUser(id);
          return dto.toEntity();
        },
        tag: 'getUser($id)',
      );

  @override
  Future<List<User>> getUsers() => safeCall(
        () async {
          final dtos = await remoteSource.getUsers();
          return mapToEntities(dtos, (d) => d.toEntity());
        },
        tag: 'getUsers',
      );

  @override
  Future<void> deleteUser(String id) => safeCall(
        () => remoteSource.deleteUser(id),
        tag: 'deleteUser($id)',
        mapError: (e) => const ServerFailure('Failed to delete user.'),
      );
}
```

## Testing

```dart
class MockLogger extends Mock implements AppLogger {}

class TestRepo with BaseRepository {
  TestRepo(this.logger);

  @override
  final AppLogger logger;
}

void main() {
  late TestRepo repo;
  late MockLogger mockLogger;

  setUp(() {
    mockLogger = MockLogger();
    repo = TestRepo(mockLogger);
  });

  test('safeCall returns result on success', () async {
    final result = await repo.safeCall(() async => 42, tag: 'test');
    expect(result, 42);
  });

  test('safeCall rethrows FailureException', () async {
    expect(
      () => repo.safeCall(
        () async => throw const FailureException(ServerFailure('fail')),
        tag: 'test',
      ),
      throwsA(isA<FailureException>()),
    );
  });

  test('safeCall wraps unknown errors in UnknownFailure', () async {
    expect(
      () => repo.safeCall(() async => throw Exception('boom'), tag: 'test'),
      throwsA(isA<FailureException>().having((e) => e.failure, 'failure', isA<UnknownFailure>())),
    );
  });

  test('safeCall uses custom error mapper', () async {
    expect(
      () => repo.safeCall(
        () async => throw Exception('boom'),
        tag: 'test',
        mapError: (_) => const ServerFailure('custom'),
      ),
      throwsA(isA<FailureException>().having((e) => e.failure.message, 'message', 'custom')),
    );
  });
}
```

## Rules

- Use `with BaseRepository` (mixin) so the impl can still `implements` the domain interface.
- `safeCall()` does not double-wrap `FailureException` — it re-throws it.
- Always provide a meaningful `tag` for log traceability.
- Use `mapError` to return a specific failure type when needed.

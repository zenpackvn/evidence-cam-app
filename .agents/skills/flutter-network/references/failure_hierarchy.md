# Failure Hierarchy

Sealed `Failure` types and `FailureException` used across the data boundary.

## pubspec.yaml additions

```yaml
dependencies:
  dio: 5.9.2
  dio_smart_retry: 7.0.1
  retrofit: 4.9.2
```

## `lib/src/core/error/failure.dart`

```dart
import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network unavailable.']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timed out.']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found.']);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.statusCode});
  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong.']);
}

class FailureException implements Exception {
  const FailureException(this.failure);
  final Failure failure;

  @override
  String toString() => 'FailureException(${failure.runtimeType}: ${failure.message})';
}
```

## Usage rule

Repositories `throw FailureException(...)` at the data boundary; blocs/cubits catch it and map to UI state. Raw `DioException` must never reach the UI layer.

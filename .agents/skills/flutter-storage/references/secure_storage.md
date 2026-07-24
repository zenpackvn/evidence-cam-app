# Secure Storage

Only `secure_storage_impl.dart` imports `package:flutter_secure_storage`. Use for all authentication tokens, PII, and sensitive strings.

## `lib/src/core/storage/secure_storage.dart`

```dart
abstract interface class SecureStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> deleteAll();
}
```

## `lib/src/core/storage/secure_storage_impl.dart`

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'secure_storage.dart';

class SecureStorageImpl implements SecureStorage {
  SecureStorageImpl([FlutterSecureStorage? delegate])
      : _delegate = delegate ?? const FlutterSecureStorage();

  final FlutterSecureStorage _delegate;

  @override
  Future<String?> read(String key) => _delegate.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _delegate.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _delegate.delete(key: key);

  @override
  Future<void> deleteAll() => _delegate.deleteAll();
}
```

## DI registration

```dart
getIt.registerLazySingleton<SecureStorage>(SecureStorageImpl.new);
```

## Test fake

```dart
class FakeSecureStorage implements SecureStorage {
  final _store = <String, String>{};

  @override
  Future<String?> read(String key) async => _store[key];

  @override
  Future<void> write(String key, String value) async => _store[key] = value;

  @override
  Future<void> delete(String key) async => _store.remove(key);

  @override
  Future<void> deleteAll() async => _store.clear();
}
```

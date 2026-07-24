# Secure Storage and Storage Keys

All authentication tokens, PII, and user credentials go in `SecureStorage`. Never `SharedPreferences` or drift DB for sensitive values.

## Interface

```dart
// lib/src/core/storage/secure_storage.dart (interface)
abstract interface class SecureStorage {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
  Future<void> deleteAll();
}
```

## Implementation

```dart
// lib/src/core/storage/secure_storage_impl.dart (impl — only file importing flutter_secure_storage)
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final class SecureStorageImpl implements SecureStorage {
  SecureStorageImpl()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        );

  final FlutterSecureStorage _storage;

  @override
  Future<void> write({required String key, required String value}) =>
      _storage.write(key: key, value: value);

  @override
  Future<String?> read({required String key}) => _storage.read(key: key);

  @override
  Future<void> delete({required String key}) => _storage.delete(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();
}
```

## Storage key constants

```dart
// lib/src/core/storage/storage_keys.dart
abstract final class StorageKeys {
  static const authToken    = 'auth_token';
  static const refreshToken = 'refresh_token';
  static const userId       = 'user_id';
  // Add all keys here — never use raw strings at call sites
}
```

# Key-Value Storage

Only `key_value_store_impl.dart` imports `package:shared_preferences`. Use for non-sensitive preferences, flags, and settings.

## `lib/src/core/storage/key_value_store.dart`

```dart
abstract interface class KeyValueStore {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<bool?> getBool(String key);
  Future<void> setBool(String key, {required bool value});
  Future<int?> getInt(String key);
  Future<void> setInt(String key, {required int value});
  Future<void> remove(String key);
  Future<void> clear();
}
```

## `lib/src/core/storage/key_value_store_impl.dart`

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'key_value_store.dart';

class KeyValueStoreImpl implements KeyValueStore {
  KeyValueStoreImpl(this._prefs);
  final SharedPreferences _prefs;

  @override
  Future<String?> getString(String key) async => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) async =>
      _prefs.setString(key, value);

  @override
  Future<bool?> getBool(String key) async => _prefs.getBool(key);

  @override
  Future<void> setBool(String key, {required bool value}) async =>
      _prefs.setBool(key, value);

  @override
  Future<int?> getInt(String key) async => _prefs.getInt(key);

  @override
  Future<void> setInt(String key, {required int value}) async =>
      _prefs.setInt(key, value);

  @override
  Future<void> remove(String key) async => _prefs.remove(key);

  @override
  Future<void> clear() async => _prefs.clear();
}
```

## DI registration

`SharedPreferences.getInstance()` is async — resolve it in `configureDependencies()` before registering:

```dart
final prefs = await SharedPreferences.getInstance();
getIt.registerLazySingleton<KeyValueStore>(() => KeyValueStoreImpl(prefs));
```

## Test fake

```dart
class FakeKeyValueStore implements KeyValueStore {
  final _data = <String, Object>{};

  @override
  Future<String?> getString(String key) async => _data[key] as String?;
  @override
  Future<void> setString(String key, String value) async => _data[key] = value;
  @override
  Future<bool?> getBool(String key) async => _data[key] as bool?;
  @override
  Future<void> setBool(String key, {required bool value}) async =>
      _data[key] = value;
  @override
  Future<int?> getInt(String key) async => _data[key] as int?;
  @override
  Future<void> setInt(String key, {required int value}) async =>
      _data[key] = value;
  @override
  Future<void> remove(String key) async => _data.remove(key);
  @override
  Future<void> clear() async => _data.clear();
}
```

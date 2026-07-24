// Positional bool setters (setBool(key, value)) intentionally mirror the
// SharedPreferences API this wraps, so callers reading like the platform's own.
// ignore_for_file: avoid_positional_boolean_parameters
import 'package:shared_preferences/shared_preferences.dart';

/// A narrow, app-owned wrapper over non-sensitive key/value persistence.
///
/// Depend on this instead of taking a raw [SharedPreferences] so the plugin
/// stays behind the storage package boundary (the wrapper rule) and call sites
/// are trivially fakeable in tests. For secrets (tokens, credentials) use the
/// secure-storage-backed stores instead — never this.
///
/// Getters are synchronous (the backing store is loaded once at startup);
/// writes are asynchronous.
abstract class KeyValueStore {
  String? getString(String key);
  Future<void> setString(String key, String value);

  bool? getBool(String key);
  Future<void> setBool(String key, bool value);

  int? getInt(String key);
  Future<void> setInt(String key, int value);

  double? getDouble(String key);
  Future<void> setDouble(String key, double value);

  bool containsKey(String key);
  Future<void> remove(String key);

  /// Removes every key this store owns.
  Future<void> clear();
}

/// A [KeyValueStore] backed by `shared_preferences`. The only place the plugin
/// is used directly.
class SharedPreferencesKeyValueStore implements KeyValueStore {
  const SharedPreferencesKeyValueStore(this._prefs);

  final SharedPreferences _prefs;

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  bool? getBool(String key) => _prefs.getBool(key);

  @override
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  @override
  int? getInt(String key) => _prefs.getInt(key);

  @override
  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);

  @override
  double? getDouble(String key) => _prefs.getDouble(key);

  @override
  Future<void> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);

  @override
  bool containsKey(String key) => _prefs.containsKey(key);

  @override
  Future<void> remove(String key) => _prefs.remove(key);

  @override
  Future<void> clear() => _prefs.clear();
}

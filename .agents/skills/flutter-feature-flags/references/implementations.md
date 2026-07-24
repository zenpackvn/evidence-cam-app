# Implementations

## Firebase Implementation — `feature_flag_service_impl.dart`

```dart
import 'package:firebase_remote_config/firebase_remote_config.dart';

import 'feature_flag.dart';
import 'feature_flag_service.dart';

/// Firebase Remote Config wrapper.
/// Only file in the project that imports `firebase_remote_config`.
class FeatureFlagServiceImpl implements FeatureFlagService {
  FeatureFlagServiceImpl();

  late final FirebaseRemoteConfig _remoteConfig;
  final List<void Function()> _listeners = [];

  @override
  Future<void> init() async {
    _remoteConfig = FirebaseRemoteConfig.instance;

    // Set defaults from FeatureFlag enum.
    await _remoteConfig.setDefaults({
      for (final flag in FeatureFlag.values) flag.key: flag.defaultValue,
    });

    // Configure fetch settings.
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    // Fetch and activate.
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (_) {
      // Silently fall back to defaults — flags should never crash the app.
    }

    // Listen for real-time updates (Firebase Remote Config v2).
    _remoteConfig.onConfigUpdated.listen((event) async {
      await _remoteConfig.activate();
      _notifyListeners();
    });
  }

  @override
  bool isEnabled(FeatureFlag flag) => _remoteConfig.getBool(flag.key);

  @override
  String getString(FeatureFlag flag) => _remoteConfig.getString(flag.key);

  @override
  int getInt(FeatureFlag flag) => _remoteConfig.getInt(flag.key);

  @override
  double getDouble(FeatureFlag flag) => _remoteConfig.getDouble(flag.key);

  @override
  Future<void> refresh() async {
    try {
      await _remoteConfig.fetchAndActivate();
      _notifyListeners();
    } catch (_) {
      // Fail silently — stale flags are better than a crash.
    }
  }

  @override
  void addListener(void Function() onChanged) => _listeners.add(onChanged);

  @override
  void removeListener(void Function() onChanged) => _listeners.remove(onChanged);

  void _notifyListeners() {
    for (final listener in List.of(_listeners)) {
      listener();
    }
  }
}
```

## Local Implementation — `local_feature_flag_service.dart`

For dev builds and tests — no Firebase dependency, flags controlled in-memory.

```dart
import 'feature_flag.dart';
import 'feature_flag_service.dart';

/// Local-only feature flag service for dev and test environments.
/// Flags default to [FeatureFlag.defaultValue] but can be overridden at runtime.
class LocalFeatureFlagService implements FeatureFlagService {
  LocalFeatureFlagService();

  final Map<String, Object> _overrides = {};
  final List<void Function()> _listeners = [];

  @override
  Future<void> init() async {
    // No-op — no remote to fetch from.
  }

  /// Set a flag value at runtime (dev menu, test setup).
  void setFlag(FeatureFlag flag, Object value) {
    _overrides[flag.key] = value;
    _notifyListeners();
  }

  /// Clear a single override, reverting to default.
  void clearFlag(FeatureFlag flag) {
    _overrides.remove(flag.key);
    _notifyListeners();
  }

  /// Clear all overrides.
  void clearAll() {
    _overrides.clear();
    _notifyListeners();
  }

  Object _resolve(FeatureFlag flag) => _overrides[flag.key] ?? flag.defaultValue;

  @override
  bool isEnabled(FeatureFlag flag) {
    final value = _resolve(flag);
    return value is bool ? value : value.toString().toLowerCase() == 'true';
  }

  @override
  String getString(FeatureFlag flag) => _resolve(flag).toString();

  @override
  int getInt(FeatureFlag flag) {
    final value = _resolve(flag);
    return value is int ? value : int.tryParse(value.toString()) ?? 0;
  }

  @override
  double getDouble(FeatureFlag flag) {
    final value = _resolve(flag);
    return value is double ? value : double.tryParse(value.toString()) ?? 0.0;
  }

  @override
  Future<void> refresh() async {
    // No-op for local.
  }

  @override
  void addListener(void Function() onChanged) => _listeners.add(onChanged);

  @override
  void removeListener(void Function() onChanged) => _listeners.remove(onChanged);

  void _notifyListeners() {
    for (final listener in List.of(_listeners)) {
      listener();
    }
  }
}
```

## DI Registration

```dart
// lib/src/core/di/service_locator.dart

import '../feature_flags/feature_flag_service.dart';
import '../feature_flags/feature_flag_service_impl.dart';
import '../feature_flags/local_feature_flag_service.dart';

// Inside configureDependencies(Env env):

if (env == Env.dev) {
  getIt.registerSingleton<FeatureFlagService>(LocalFeatureFlagService());
} else {
  getIt.registerSingleton<FeatureFlagService>(FeatureFlagServiceImpl());
}

await getIt<FeatureFlagService>().init();
```

**Registration order**: After Firebase init and `AppConfig`, before features that read flags.

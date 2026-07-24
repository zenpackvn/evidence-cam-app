# Kill Switch Pattern

## Maintenance Mode

```dart
// In the router guard or app root:
class MaintenanceGuard {
  MaintenanceGuard({required FeatureFlagService featureFlags})
      : _featureFlags = featureFlags;

  final FeatureFlagService _featureFlags;

  bool get isInMaintenance =>
      _featureFlags.isEnabled(FeatureFlag.maintenanceMode);
}
```

```dart
// In GoRouter redirect:
redirect: (context, state) {
  final guard = getIt<MaintenanceGuard>();
  if (guard.isInMaintenance && state.matchedLocation != '/maintenance') {
    return '/maintenance';
  }
  return null;
},
```

## Force Update

```dart
import 'package:package_info_plus/package_info_plus.dart';

class ForceUpdateChecker {
  ForceUpdateChecker({
    required FeatureFlagService featureFlags,
  }) : _featureFlags = featureFlags;

  final FeatureFlagService _featureFlags;

  /// Returns true if the current app version is below the minimum.
  Future<bool> shouldForceUpdate() async {
    final minVersion = _featureFlags.getString(FeatureFlag.forceUpdate);
    final info = await PackageInfo.fromPlatform();
    return _isVersionBelow(info.version, minVersion);
  }

  bool _isVersionBelow(String current, String minimum) {
    final currentParts = current.split('.').map(int.parse).toList();
    final minParts = minimum.split('.').map(int.parse).toList();

    for (var i = 0; i < 3; i++) {
      final c = i < currentParts.length ? currentParts[i] : 0;
      final m = i < minParts.length ? minParts[i] : 0;
      if (c < m) return true;
      if (c > m) return false;
    }
    return false;
  }
}
```

## Key Rule

Kill switches (maintenance mode, force update) must be checked in **router guards**, before any feature code loads. Never check them only inside a feature screen.

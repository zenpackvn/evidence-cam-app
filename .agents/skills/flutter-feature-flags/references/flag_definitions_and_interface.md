# Flag Definitions & Interface

## Package

```yaml
# pubspec.yaml (excerpt)
dependencies:
  firebase_remote_config: 5.3.0
  firebase_core: 3.8.0    # already in stack
```

## Folder Structure

```
lib/src/core/
  feature_flags/
    feature_flag.dart                    ← Flag definitions (enum + metadata)
    feature_flag_service.dart            ← App-owned interface
    feature_flag_service_impl.dart       ← Firebase Remote Config wrapper (only import)
    local_feature_flag_service.dart      ← Local-only implementation (dev/test)
  di/
    service_locator.dart                 ← Registers FeatureFlagService
```

## Flag Definitions — `feature_flag.dart`

```dart
/// All feature flags in the app.
///
/// Each flag has:
/// - [key]: matches the Remote Config parameter name exactly.
/// - [defaultValue]: used when remote fetch fails or flag is absent.
/// - [description]: human-readable purpose (for dashboards and code review).
enum FeatureFlag {
  // ── Rollout flags ──────────────────────────────────
  newOnboarding(
    key: 'new_onboarding_v2',
    defaultValue: false,
    description: 'New onboarding flow with video intro',
  ),
  offlineMode(
    key: 'offline_mode_enabled',
    defaultValue: false,
    description: 'Enable offline-first data sync',
  ),

  // ── A/B experiment flags ───────────────────────────
  checkoutLayout(
    key: 'checkout_layout_variant',
    defaultValue: 'control',
    description: 'A/B test: control vs single_page checkout',
  ),
  homeCardStyle(
    key: 'home_card_style',
    defaultValue: 'standard',
    description: 'A/B test: standard vs compact home cards',
  ),

  // ── Kill switches ──────────────────────────────────
  maintenanceMode(
    key: 'maintenance_mode',
    defaultValue: false,
    description: 'Show maintenance screen, disable all API calls',
  ),
  forceUpdate(
    key: 'force_update_min_version',
    defaultValue: '0.0.0',
    description: 'Minimum app version — show force-update dialog if below',
  ),

  // ── Ops flags ──────────────────────────────────────
  verboseLogging(
    key: 'verbose_logging',
    defaultValue: false,
    description: 'Enable verbose logging in production for debugging',
  );

  const FeatureFlag({
    required this.key,
    required this.defaultValue,
    required this.description,
  });

  /// Remote Config parameter key. Must match the dashboard exactly.
  final String key;

  /// Default value when remote is unavailable. Type is dynamic:
  /// - `bool` for on/off toggles
  /// - `String` for variant names, version strings, JSON config
  final Object defaultValue;

  /// Human-readable description.
  final String description;
}
```

## Interface — `feature_flag_service.dart`

```dart
/// App-owned feature flag contract.
///
/// No widget, cubit, or repository imports a feature flag provider directly.
/// Only [FeatureFlagServiceImpl] imports the remote config package.
abstract interface class FeatureFlagService {
  /// Initialize and fetch remote values.
  /// Call once during bootstrap, after Firebase init.
  Future<void> init();

  /// Whether a boolean flag is enabled.
  bool isEnabled(FeatureFlag flag);

  /// Get a string flag value (for A/B variants, version strings, JSON).
  String getString(FeatureFlag flag);

  /// Get an int flag value.
  int getInt(FeatureFlag flag);

  /// Get a double flag value.
  double getDouble(FeatureFlag flag);

  /// Force re-fetch from remote. Call on app resume or pull-to-refresh.
  Future<void> refresh();

  /// Register a listener for when remote values change.
  void addListener(void Function() onChanged);

  /// Remove a previously registered listener.
  void removeListener(void Function() onChanged);
}
```

## Notes

- `FeatureFlag` is the **single source of truth** for all flag keys. No magic strings elsewhere.
- Every flag must have a `defaultValue` — the app must work correctly when remote fetch fails.
- Only `feature_flag_service_impl.dart` imports `firebase_remote_config`.

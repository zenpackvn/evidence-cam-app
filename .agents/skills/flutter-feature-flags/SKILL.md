---
name: flutter-feature-flags
description: Use this skill when implementing Flutter feature flags — FeatureFlagService, Firebase Remote Config, A/B testing, kill switches, gradual rollout, dev/debug menu for flags, FeatureGate widget, remote feature toggles, local feature flags, or controlling feature availability per environment or user segment.
---

# Flutter Feature Flags

Full reference: [`template.md`](references/template.md)

## Key rules

- `FeatureFlagService` is the app-owned interface. **Never import `firebase_remote_config`** outside `remote_config_feature_flag_service_impl.dart`.
- Default values: defined at build time in the impl — Remote Config just overrides them. App works correctly without network.
- `FeatureGate` widget: `FeatureGate(flag: FeatureFlags.newCheckout, child: NewWidget(), fallback: OldWidget())`. No `if (flag)` scattered in build methods.
- `LocalFeatureFlagService`: in-memory impl for dev/test — allows toggling flags without Remote Config.
- Dev menu: only visible when `AppConfig.env.isDev`. Shows all flags with toggles. Uses `LocalFeatureFlagService` override.
- Fetch + activate Remote Config on app start in `appBootstrap()`. Set min fetch interval to 1 hour prod / 0 dev.
- Kill switches: a `false` flag disables a broken feature without a release. Design every feature to have a kill switch from day 1.

## Files

```
lib/src/core/feature_flags/
  feature_flag_service.dart                      ← interface (isEnabled(flag))
  feature_flags.dart                             ← constants (static const String newCheckout = 'new_checkout')
  local_feature_flag_service.dart                ← in-memory impl (dev/test)
  remote_config_feature_flag_service_impl.dart   ← only import of firebase_remote_config
  feature_gate.dart                              ← widget (shows child or fallback based on flag)
```

## Co-load with

- `flutter-di` — register `FeatureFlagService` based on env
- `flutter-flavors` — `LocalFeatureFlagService` in dev
- `flutter-analytics` — log which flag variant the user sees

# Feature Flags

Remote config wrapper, local feature toggles, A/B testing pattern, and gradual rollout. All behind an app-owned interface — only the implementation file imports Firebase Remote Config or any other provider.

Depends on: [template-di.md](template-di.md), [template-flavors.md](template-flavors.md), [template-analytics.md](template-analytics.md), [template-storage.md](template-storage.md).

## Topics

| Topic | File |
|---|---|
| `FeatureFlag` enum, `FeatureFlagService` interface, folder structure | [flag_definitions_and_interface.md](flag_definitions_and_interface.md) |
| Firebase impl, `LocalFeatureFlagService`, DI registration | [implementations.md](implementations.md) |
| A/B testing: variant enum, cubit resolution, exposure/outcome tracking, gradual rollout | [ab_testing_pattern.md](ab_testing_pattern.md) |
| Kill switches: maintenance mode, force update, router guard wiring | [kill_switches.md](kill_switches.md) |
| `FeatureGate` widget, dev menu for flag overrides | [feature_gate_widget.md](feature_gate_widget.md) |
| Unit tests, cubit tests, widget tests with `LocalFeatureFlagService` | [testing.md](testing.md) |

## ⚠️ Common Mistakes

> These are the most frequent feature-flag bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **Importing `firebase_remote_config` outside `feature_flag_service_impl.dart`** | Violates wrapper rule — cubits, widgets, or repositories depend on the Firebase SDK directly | Only `feature_flag_service_impl.dart` imports `firebase_remote_config`; all other files use the `FeatureFlagService` interface |
| 2 | **Using magic strings for flag keys instead of the `FeatureFlag` enum** | Typos in key strings produce silent mismatches — the flag always returns its default | Define every flag in the `FeatureFlag` enum with a `key`, `defaultValue`, and `description`; never pass raw strings to `isEnabled()` |
| 3 | **Flag has no `defaultValue` and app crashes when remote fetch fails** | Network error during launch → `fetchAndActivate()` throws → app crashes or renders incorrectly | Every `FeatureFlag` entry must declare a valid `defaultValue`; wrap `fetchAndActivate()` in `try/catch` and fall back silently |
| 4 | **Reading flags directly in widgets with `isEnabled()` calls in `build()`** | Flag changes don't rebuild the widget; UI is stale after remote config updates | Resolve flags in a cubit, emit a new state when the `addListener` callback fires, and let the widget render from state |
| 5 | **`FeatureFlagService` not initialized before features read flags** | Flags return default values or throw on first access because `init()` was never called | Call `await getIt<FeatureFlagService>().init()` in DI registration, after Firebase init and `AppConfig` but before feature modules |
| 6 | **Kill switch checked inside a feature screen, not in a router guard** | User enters a feature route before maintenance-mode or force-update check runs | Wire `MaintenanceGuard` and `ForceUpdateChecker` into `GoRouter`'s `redirect`, not inside screen `build()` or `initState()` |
| 7 | **Using `FeatureFlagServiceImpl` (Firebase) in dev/test builds** | Test suite requires Firebase credentials; flag state is uncontrollable in unit tests | Register `LocalFeatureFlagService` for `Env.dev`; use `setFlag()` / `clearFlag()` in tests and dev menu overrides |
| 8 | **A/B exposure event not fired when variant is shown** | Experiment data is incomplete — conversion rates can't be attributed to the correct variant | Fire `experiment_exposure` via `AnalyticsService` when the variant widget first renders; include variant name in all conversion events |

## Quick Summary

- **Wrapper rule**: only `feature_flag_service_impl.dart` imports `firebase_remote_config`; all other code uses the `FeatureFlagService` interface.
- **Single source of truth**: all flags defined in the `FeatureFlag` enum — no magic strings for flag keys anywhere else.
- **Defaults are mandatory**: every flag has a `defaultValue`; the app must work correctly when remote fetch fails.
- **Flags never crash the app**: wrap `fetchAndActivate()` in try/catch; stale values are preferable to a crash.
- **Dev uses `LocalFeatureFlagService`**: no Firebase dependency in dev/test builds; flags controlled via dev menu or `setFlag()`.
- **Resolve flags in cubit, not widgets**: cubit reads flags once and emits state; widget renders from state.
- **Track exposure and outcome**: fire `experiment_exposure` when variant is shown; include variant in conversion events.
- **Kill switches run in router guards**: maintenance mode and force-update checks happen before feature code loads.

## Cross-references

- [flutter-di](../../flutter-di/references/template.md) — `FeatureFlagService` is registered based on env; `LocalFeatureFlagService` for dev, `FeatureFlagServiceImpl` for prod
- [flutter-flavors](../../flutter-flavors/references/template.md) — `Env` controls which `FeatureFlagService` implementation is wired; dev uses local overrides
- [flutter-analytics](../../flutter-analytics/references/template.md) — `experiment_exposure` and conversion events are fired via `AnalyticsService` when a variant is shown
- [flutter-routing](../../flutter-routing/references/template.md) — kill switches (maintenance mode, force-update) are enforced in `GoRouter` redirect guards
- [flutter-storage](../../flutter-storage/references/template.md) — `LocalFeatureFlagService` persists dev flag overrides via `KeyValueStore`

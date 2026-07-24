# App Shell — SDK Version & pubspec.yaml

## SDK Version Compatibility

This skill targets **Flutter 3.27.x** (stable channel) with **Dart 3.6.x**. All package versions in the pubspec below are tested against this SDK range.

| Requirement | Version | Notes |
|---|---|---|
| Flutter SDK | `>= 3.27.0 < 4.0.0` | Stable channel. Sealed classes require Dart 3.0+; class modifiers require 3.3+ |
| Dart SDK | `>= 3.6.0 < 4.0.0` | Implied by the Flutter constraint |
| Minimum deployment | Android API 21 / iOS 13 | Required by `firebase_core`, `flutter_secure_storage` |
| Java/Kotlin | JDK 17, Kotlin 1.9+ | Required by Android Gradle Plugin 8.x |
| Xcode | 15.0+ | Required by iOS 17 SDK |
| CocoaPods | 1.15+ | Required by latest Firebase iOS pods |

**When to bump**: Update the SDK constraint when a package in the stack drops support for the lower bound or when a new Dart language feature (like macros) becomes stable and templates use it.

**Checking your version**:
```bash
flutter --version          # Should show Flutter 3.27.x, Dart 3.6.x
flutter doctor             # Verify toolchain health
```

---

## `pubspec.yaml` excerpt

**Rule: use exact versions, never `^`.** Pinning exact versions prevents unexpected breaking changes from minor/patch updates and ensures reproducible builds across environments.

**Rule: validate ecosystem compatibility.** Packages in the same ecosystem (Firebase, Google, AWS, etc.) share transitive constraints. When pinning exact versions, run `flutter pub get` after adding each ecosystem group to catch conflicts immediately. If package A requires `package_core ^X.Y.Z`, every other package in that ecosystem must be pinned to a version compatible with that constraint. Check `pub.dev` dependency tabs to verify cross-package compatibility before pinning.

```yaml
environment:
  sdk: ">= 3.6.0 < 4.0.0"
  flutter: ">= 3.27.0 < 4.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: 8.1.6
  bloc: 8.1.4
  get_it: 7.7.0
  dio: 5.7.0
  retrofit: 4.4.1
  json_annotation: 4.9.0
  logger: 2.4.0
  equatable: 2.0.5
  go_router: 14.6.1
  flutter_localization: 0.2.2
  intl: 0.19.0
  flutter_secure_storage: 9.2.2
  shared_preferences: 2.3.3
  google_fonts: 8.0.2
  flutter_spinkit: 5.2.1
  pullex: 1.0.4
  shimmer_animation: 2.2.1
  flutter_smart_dialog: 4.9.7+3
  cached_network_image: 3.4.1
  # Auth & security
  local_auth: 2.3.0
  # Analytics & crash reporting
  firebase_core: 3.8.0
  firebase_analytics: 11.4.0
  sentry_flutter: 8.11.0
  # State restoration
  hydrated_bloc: 9.1.5
  path_provider: 2.1.4
  # Feature flags / remote config
  firebase_remote_config: 5.3.0
  # Permissions
  permission_handler: 11.3.1
  # Push notifications
  firebase_messaging: 15.1.6
  flutter_local_notifications: 18.0.1
  # Connectivity
  connectivity_plus: 6.1.0
  # Database
  drift: 2.22.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: 5.0.0
  build_runner: 2.4.13
  retrofit_generator: 9.1.5
  json_serializable: 6.8.0
  bloc_test: 9.1.7
  mocktail: 1.0.4
  drift_dev: 2.22.1

flutter:
  uses-material-design: true
  assets:
    - assets/i18n/en.json
    - assets/i18n/vi.json
```

Pin to the latest compatible stable when creating a new project. Always use exact versions (e.g. `8.1.6`), never caret syntax (`^8.1.6`).

### Package version update procedure

When updating packages for a newer Flutter SDK:

1. Run `flutter pub outdated` to see available updates.
2. Update one category at a time (state → networking → storage → UI → firebase → dev).
3. For ecosystem packages (Firebase, Google, etc.), check `pub.dev` dependency tabs to find a compatible version set — update the entire group together so transitive constraints align.
4. After each category, run `flutter pub get && flutter analyze && flutter test`.
5. If a package requires a new minimum Dart SDK, bump the `environment:` constraint.
6. Update the SDK Version Compatibility table above.
7. Run the eval suite: `./evals/run-evals.sh check` to verify templates still produce compliant code.

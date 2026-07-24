# Phase 3: Harden (2–4 PRs)

## PR 3.1 — Global error handling

Add `ErrorHandler`, `guardedMain`, and `AppErrorWidget` from [template-error-handling.md](template-error-handling.md).

## PR 3.2 — Test infrastructure

Add test fakes for all wrapped services:

```dart
// test/fakes/
//   fake_app_logger.dart
//   fake_api_client.dart
//   fake_key_value_store.dart
//   fake_secure_storage.dart
//   fake_analytics_service.dart
```

Set up DI overrides for tests:

```dart
// test/helpers/test_di.dart

void registerTestDependencies() {
  getIt
    ..registerSingleton<AppLogger>(FakeAppLogger())
    ..registerSingleton<KeyValueStore>(FakeKeyValueStore())
    ..registerSingleton<SecureStorage>(FakeSecureStorage());
}
```

## PR 3.3 — Coverage baseline

Add `flutter test --coverage` to CI. Don't set a high gate initially — just establish the baseline and prevent regression.

```yaml
# Start with a low gate and ratchet up over time
coverage_threshold: 40  # raise by 5% each sprint
```

See [template-ci.md](template-ci.md) and [template-tests.md](template-tests.md).

## Phase 4: Polish (optional, ongoing)

These can happen in any order, as time allows:

| Task | Template | Priority |
|---|---|---|
| Centralize theme tokens | [template-theme.md](template-theme.md) | High if you have hardcoded colors/spacing |
| Route localized strings | [template-localization.md](template-localization.md) | High if multi-language |
| Add flavors (dev/uat/prod) | [template-flavors.md](template-flavors.md) | Medium |
| Accessibility pass | [template-accessibility.md](template-accessibility.md) | Medium |
| Performance audit | [template-performance.md](template-performance.md) | Low (do when you notice jank) |
| State restoration | [template-state-restoration.md](template-state-restoration.md) | Low (do for form-heavy screens) |
| Feature flags | [template-feature-flags.md](template-feature-flags.md) | Low (do when needed) |

# Secret Management

Secrets must never appear in Dart source, `pubspec.yaml`, or any committed file.

## Approach: `--dart-define` at build time

```bash
# CI / Fastlane — inject at build, not stored in repo
flutter build apk --release \
  --dart-define=API_BASE_URL=https://api.prod.example.com \
  --dart-define=API_KEY=prod-key-from-ci-secret
```

## `AppConfig` reads compile-time defines

```dart
// lib/src/core/config/app_config.dart
final class AppConfig {
  const AppConfig._();

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.dev.example.com',
  );

  static const apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: '', // empty → fail fast in dev if not set
  );
}
```

## Rules

- `String.fromEnvironment` values are inlined at compile time — not readable at runtime via reflection.
- Never use `dotenv` in production — `.env` files get bundled into the APK.
- CI secrets go in GitHub Secrets / Fastlane `.env.secret` (gitignored).

# App Shell — Config & Flavors

Config is split into three files: `env.dart` (enum), `env_config.dart` (per-env values), `app_config.dart` (merges env + `--dart-define` overrides). See [template-flavors.md](template-flavors.md) for the full code of all three.

---

## `lib/src/core/config/app_config.dart` (summary)

```dart
import 'env.dart';
import 'env_config.dart';

class AppConfig {
  const AppConfig({
    required this.env,
    required this.apiBaseUrl,
    required this.appTitle,
    required this.enableLogging,
    required this.connectTimeoutSeconds,
    required this.receiveTimeoutSeconds,
  });

  factory AppConfig.fromEnv(Env env) {
    final config = EnvConfig.fromEnv(env);
    // --dart-define can override the base URL for local testing / CI
    const defineUrl = String.fromEnvironment('API_BASE_URL');
    return AppConfig(
      env: env,
      apiBaseUrl: defineUrl.isNotEmpty ? defineUrl : config.apiBaseUrl,
      appTitle: config.appTitle,
      enableLogging: config.enableLogging,
      connectTimeoutSeconds: config.connectTimeoutSeconds,
      receiveTimeoutSeconds: config.receiveTimeoutSeconds,
    );
  }

  final Env env;
  final String apiBaseUrl;
  final String appTitle;
  final bool enableLogging;
  final int connectTimeoutSeconds;
  final int receiveTimeoutSeconds;

  bool get isProduction => env.isProd;
}
```

---

## Running with flavors

```
flutter run -t lib/main_dev.dart
flutter run -t lib/main_uat.dart
flutter run -t lib/main_prod.dart --release
```

Override base URL for local testing:

```
flutter run -t lib/main_dev.dart --dart-define=API_BASE_URL=http://localhost:8080
```

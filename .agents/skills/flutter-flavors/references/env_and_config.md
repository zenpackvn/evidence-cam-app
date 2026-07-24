# Env Enum & Config Classes

No third-party package needed — flavors use pure Dart enums, `--dart-define`, and multiple `main_*.dart` entry points.

## Folder Structure

```text
lib/
  main_dev.dart
  main_uat.dart
  main_prod.dart
  src/
    core/
      config/
        env.dart                 ← Enum: dev, uat, prod
        env_config.dart          ← Per-env values (URLs, flags)
        app_config.dart          ← Typed config built from Env + --dart-define overrides
```

## `lib/src/core/config/env.dart`

```dart
enum Env {
  dev,
  uat,
  prod;

  bool get isDev => this == Env.dev;
  bool get isUat => this == Env.uat;
  bool get isProd => this == Env.prod;

  /// Allow --dart-define override: `--dart-define=ENVIRONMENT=uat`
  static Env fromString(String value) => switch (value.toLowerCase()) {
        'dev' => Env.dev,
        'uat' => Env.uat,
        'prod' => Env.prod,
        _ => Env.dev,
      };
}
```

## `lib/src/core/config/env_config.dart`

Each environment defines its own URLs, feature flags, and logging level. Add fields as needed — keep all env-specific values here, never scattered in feature code.

```dart
import 'env.dart';

class EnvConfig {
  const EnvConfig({
    required this.env,
    required this.apiBaseUrl,
    required this.appTitle,
    this.enableLogging = true,
    this.connectTimeoutSeconds = 15,
    this.receiveTimeoutSeconds = 20,
    this.enableSslPinning = false,
    this.sslPins = const <String>{},
  });

  final Env env;
  final String apiBaseUrl;
  final String appTitle;
  final bool enableLogging;
  final int connectTimeoutSeconds;
  final int receiveTimeoutSeconds;
  final bool enableSslPinning;
  final Set<String> sslPins;

  static const dev = EnvConfig(
    env: Env.dev,
    apiBaseUrl: 'https://api-dev.example.com',
    appTitle: 'App [DEV]',
    enableLogging: true,
    // No SSL pinning — dev may use self-signed certs
  );

  static const uat = EnvConfig(
    env: Env.uat,
    apiBaseUrl: 'https://api-uat.example.com',
    appTitle: 'App [UAT]',
    enableLogging: true,
    enableSslPinning: true,
    sslPins: <String>{
      'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=', // UAT cert pin
    },
  );

  static const prod = EnvConfig(
    env: Env.prod,
    apiBaseUrl: 'https://api.example.com',
    appTitle: 'App',
    enableLogging: false,
    connectTimeoutSeconds: 10,
    receiveTimeoutSeconds: 15,
    enableSslPinning: true,
    sslPins: <String>{
      'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=', // primary
      'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=', // backup
    },
  );

  static EnvConfig fromEnv(Env env) => switch (env) {
        Env.dev => dev,
        Env.uat => uat,
        Env.prod => prod,
      };
}
```

## `lib/src/core/config/app_config.dart`

Replaces the basic `AppConfig` from the app shell template. Merges the static `EnvConfig` with optional `--dart-define` overrides.

```dart
import 'env.dart';
import 'env_config.dart';

class AppConfig {
  const AppConfig._({
    required this.env,
    required this.apiBaseUrl,
    required this.appTitle,
    required this.enableLogging,
    required this.connectTimeoutSeconds,
    required this.receiveTimeoutSeconds,
    required this.enableSslPinning,
    required this.sslPins,
  });

  /// Build from a known [Env], with optional --dart-define overrides.
  factory AppConfig.fromEnv(Env env) {
    final base = EnvConfig.fromEnv(env);

    // --dart-define overrides (useful for CI or local testing)
    const apiOverride = String.fromEnvironment('API_BASE_URL');

    return AppConfig._(
      env: env,
      apiBaseUrl: apiOverride.isNotEmpty ? apiOverride : base.apiBaseUrl,
      appTitle: base.appTitle,
      enableLogging: base.enableLogging,
      connectTimeoutSeconds: base.connectTimeoutSeconds,
      receiveTimeoutSeconds: base.receiveTimeoutSeconds,
      enableSslPinning: base.enableSslPinning,
      sslPins: base.sslPins,
    );
  }

  final Env env;
  final String apiBaseUrl;
  final String appTitle;
  final bool enableLogging;
  final int connectTimeoutSeconds;
  final int receiveTimeoutSeconds;
  final bool enableSslPinning;
  final Set<String> sslPins;

  bool get isProduction => env.isProd;
}
```

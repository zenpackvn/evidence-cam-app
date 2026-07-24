# Tooling, Native Flavors & Testing

## VS Code Launch Configurations

### `.vscode/launch.json`

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Dev",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_dev.dart",
      "args": []
    },
    {
      "name": "UAT",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_uat.dart",
      "args": []
    },
    {
      "name": "Prod (debug)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_prod.dart",
      "args": []
    },
    {
      "name": "Prod (release)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_prod.dart",
      "flutterMode": "release",
      "args": []
    }
  ]
}
```

## Android / iOS Native Flavors (Optional)

Use native flavors only when you need **different app icons, bundle IDs, or signing configs per environment**. For most apps, multiple `main_*.dart` entry points with `--dart-define` are sufficient.

### Android (`android/app/build.gradle`)

```groovy
android {
    flavorDimensions "env"
    productFlavors {
        dev {
            dimension "env"
            applicationIdSuffix ".dev"
            resValue "string", "app_name", "App [DEV]"
        }
        uat {
            dimension "env"
            applicationIdSuffix ".uat"
            resValue "string", "app_name", "App [UAT]"
        }
        prod {
            dimension "env"
            resValue "string", "app_name", "App"
        }
    }
}
```

### iOS (`ios/`)

Create separate schemes in Xcode (Dev, UAT, Prod) with different bundle identifiers and Info.plist values. Each scheme maps to its `main_*.dart` entry point.

### Run with Native Flavors

```bash
flutter run --flavor dev -t lib/main_dev.dart
flutter run --flavor uat -t lib/main_uat.dart
flutter run --flavor prod -t lib/main_prod.dart --release
```

## Testing with Flavors

Tests don't need flavors — they use DI overrides. Register a test `AppConfig` directly:

```dart
setUp(() async {
  await getIt.reset();
  getIt.registerSingleton<AppConfig>(
    AppConfig.fromEnv(Env.dev),
  );
  // ... register other fakes
});
```

## Anti-Patterns

### 1. Hardcoding environment values instead of using EnvConfig

```dart
// DON'T — base URLs and flags scattered in feature code
class ApiClient {
  static const _baseUrl = 'https://api-dev.example.com'; // hardcoded
}

// DO — read from AppConfig, which is built from EnvConfig and registered in DI
class ApiClient {
  ApiClient(this._config);
  final AppConfig _config;

  Uri _buildUri(String path) => Uri.parse('${_config.apiBaseUrl}$path');
}
```

### 2. Using bool flags (isProduction) instead of Env enum

```dart
// DON'T — booleans don't scale; adding UAT means changing every if/else
const bool isProduction = false;
const bool isStaging = true;

final url = isProduction ? 'https://api.example.com' : 'https://api-dev.example.com';
// Where does UAT go?

// DO — use the Env enum and pattern matching
final url = switch (config.env) {
  Env.dev  => 'handled by EnvConfig',
  Env.uat  => 'handled by EnvConfig',
  Env.prod => 'handled by EnvConfig',
};
// Better yet, just use config.apiBaseUrl — the switch already happened in EnvConfig.
```

### 3. Committing secrets in flavor config files

```dart
// DON'T — API keys, signing credentials, or tokens in source control
class EnvConfig {
  static const dev = EnvConfig(
    apiKey: 'sk-live-abc123secretkey',  // leaked to version control
    sentryDsn: 'https://examplePublicKey@sentry.io/1',
  );
}

// DO — inject secrets via --dart-define from CI or .env files excluded from VCS
// CI pipeline:
//   flutter build --dart-define=API_KEY=$API_KEY --dart-define=SENTRY_DSN=$SENTRY_DSN
const apiKey = String.fromEnvironment('API_KEY'); // read only in AppConfig
```

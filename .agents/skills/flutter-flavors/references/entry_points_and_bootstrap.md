# Entry Points & Bootstrap

Each flavor has its own `main_*.dart`. The only difference is the `Env` passed to `bootstrap()`.

## `lib/main_dev.dart`

```dart
import 'package:flutter/widgets.dart';
import 'src/app/app.dart';
import 'src/app/bootstrap/app_bootstrap.dart';
import 'src/core/config/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap(Env.dev);
  runApp(const App());
}
```

## `lib/main_uat.dart`

```dart
import 'package:flutter/widgets.dart';
import 'src/app/app.dart';
import 'src/app/bootstrap/app_bootstrap.dart';
import 'src/core/config/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap(Env.uat);
  runApp(const App());
}
```

## `lib/main_prod.dart`

```dart
import 'package:flutter/widgets.dart';
import 'src/app/app.dart';
import 'src/app/bootstrap/app_bootstrap.dart';
import 'src/core/config/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap(Env.prod);
  runApp(const App());
}
```

## Updated `app_bootstrap.dart`

`bootstrap()` accepts an `Env` and builds `AppConfig` from it.

```dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localization/flutter_localization.dart';
import '../../core/config/env.dart';
import '../../core/di/service_locator.dart';
import '../../core/logging/app_logger.dart';

Future<void> bootstrap(Env env) async {
  await configureDependencies(env);
  await FlutterLocalization.instance.ensureInitialized();

  final logger = getIt<AppLogger>();

  FlutterError.onError = (details) {
    logger.error(
      'FlutterError',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    logger.error('PlatformDispatcher', error: error, stackTrace: stack);
    return true;
  };
}
```

## Updated DI Composition Root (config section)

```dart
// lib/src/core/di/service_locator.dart (config section only)

import '../config/app_config.dart';
import '../config/env.dart';

Future<void> configureDependencies(Env env) async {
  // 1. Config
  final config = AppConfig.fromEnv(env);
  getIt.registerSingleton<AppConfig>(config);

  // 2. Logger — conditionally configure based on config.enableLogging
  // ... rest of registration order unchanged
}
```

## Run Commands

```bash
# Dev
flutter run -t lib/main_dev.dart

# UAT
flutter run -t lib/main_uat.dart

# Prod (release)
flutter run -t lib/main_prod.dart --release

# Override API URL for any flavor
flutter run -t lib/main_dev.dart --dart-define=API_BASE_URL=http://localhost:8080
```

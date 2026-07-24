# App Shell — Entry Points & Bootstrap

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

Copy for `main_uat.dart` (pass `Env.uat`) and `main_prod.dart` (pass `Env.prod`). See [template-flavors.md](template-flavors.md) for all three entry points.

---

## `lib/src/app/bootstrap/app_bootstrap.dart`

```dart
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localization/flutter_localization.dart';
import '../../core/config/env.dart';
import '../../core/di/service_locator.dart';
import '../../core/logging/app_logger.dart';

Future<void> bootstrap(Env env) async {
  // 0. Firebase — must be initialized before any Firebase service (Firestore,
  //    FCM, Analytics, Crashlytics). Always first, before DI.
  await Firebase.initializeApp();

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

---

## `lib/src/app/app.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: AppRouter.instance,
      supportedLocales: FlutterLocalization.instance.supportedLocales,
      localizationsDelegates: FlutterLocalization.instance.localizationsDelegates,
      builder: FlutterSmartDialog.init(),
    );
  }
}
```

> **Note:** When the auth skill is wired in, `App` wraps `MaterialApp.router` in a `BlocProvider<AuthCubit>`. See [template-auth.md](template-auth.md) for the updated version.

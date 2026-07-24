# Golden Tests and Integration Tests

## Golden Tests

Golden tests compare widget rendering against reference images. Catch visual regressions automatically.

### `test/helpers/golden_config.dart`

```dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Call once in `setUpAll` to configure golden file directory.
void setupGoldenConfig() {
  goldenFileComparator = LocalFileComparator(
    Uri.parse('${Directory.current.path}/test/goldens/'),
  );
}
```

### Golden test example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/src/features/home/presentation/cubit/home_cubit.dart';
import 'package:app/src/features/home/presentation/cubit/home_state.dart';
import 'package:app/src/features/home/presentation/pages/home_page.dart';
import '../../helpers/golden_config.dart';
import '../../helpers/pump_app.dart';

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

void main() {
  setUpAll(setupGoldenConfig);

  late MockHomeCubit cubit;

  setUp(() => cubit = MockHomeCubit());

  testWidgets('home_page_loaded golden', (tester) async {
    when(() => cubit.state).thenReturn(const HomeLoaded(['Hello', 'World']));

    await tester.pumpApp(
      BlocProvider<HomeCubit>.value(
        value: cubit,
        child: const HomePage(),
      ),
    );

    await expectLater(
      find.byType(HomePage),
      matchesGoldenFile('home_page_loaded.png'),
    );
  });

  testWidgets('home_page_error golden', (tester) async {
    when(() => cubit.state).thenReturn(const HomeError(NetworkFailure()));

    await tester.pumpApp(
      BlocProvider<HomeCubit>.value(
        value: cubit,
        child: const HomePage(),
      ),
    );

    await expectLater(
      find.byType(HomePage),
      matchesGoldenFile('home_page_error.png'),
    );
  });
}
```

### Golden test commands

```bash
# Generate/update golden files
flutter test --update-goldens

# Run golden comparisons
flutter test --tags golden

# Run only golden tests
flutter test test/goldens/
```

### Tagging golden tests

```dart
@Tags(['golden'])
library;

import 'package:flutter_test/flutter_test.dart';
// ...
```

---

## Integration Tests

End-to-end tests that run on a real device or emulator.

### `integration_test/app_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:app/main_dev.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end', () {
    testWidgets('full app smoke test', (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('sign in flow', (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('email')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password')),
        'password123',
      );

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('navigation between tabs', (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Posts'));
      await tester.pumpAndSettle();
      expect(find.text('Posts'), findsWidgets);

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Profile'), findsOneWidget);
    });
  });
}
```

### Running integration tests

```bash
# Run on connected device/emulator
flutter test integration_test/

# Run specific test
flutter test integration_test/app_test.dart

# Run on Chrome (web)
flutter test integration_test/ -d chrome
```

---

## Smoke Test

### `test/app_smoke_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/src/core/di/service_locator.dart';
import 'package:app/src/core/logging/app_logger.dart';
import 'package:app/src/features/home/domain/home_repository.dart';
import 'package:app/src/features/home/presentation/cubit/home_cubit.dart';
import 'package:app/src/features/home/presentation/pages/home_page.dart';
import 'helpers/fakes.dart';

class _StubHomeRepository implements HomeRepository {
  @override
  Future<List<String>> fetchGreetings() async => const ['hello'];
}

void main() {
  testWidgets('home page renders loaded state', (tester) async {
    await getIt.reset();
    getIt.registerSingleton<AppLogger>(NoopLogger());
    getIt.registerSingleton<HomeRepository>(_StubHomeRepository());
    getIt.registerFactory<HomeCubit>(
      () => HomeCubit(getIt<HomeRepository>()),
    );

    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pumpAndSettle();

    expect(find.text('hello'), findsOneWidget);
  });
}
```

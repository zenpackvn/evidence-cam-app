# State Restoration Testing

## Testing Process Death — Android Emulator

```bash
# 1. Launch the app
flutter run -t lib/main_dev.dart

# 2. Navigate to a form, type some data, scroll, switch tabs.

# 3. Put the app in the background
adb shell input keyevent KEYCODE_HOME

# 4. Simulate process death (kills the app but preserves restoration state)
adb shell am kill com.example.app

# 5. Reopen the app from the recents menu
adb shell am start -n com.example.app/.MainActivity

# 6. Verify: form fields, scroll position, tab index, navigation stack preserved.
```

## Testing Process Death — Developer Options

1. Enable **Developer options** on the device.
2. Turn on **Don't keep activities**.
3. Every time you navigate away from an activity (including backgrounding), the system destroys it immediately.
4. This is aggressive but great for catching restoration bugs early.

```bash
# Enable aggressive activity destruction for testing
adb shell settings put global always_finish_activities 1

# Disable when done
adb shell settings put global always_finish_activities 0
```

## Testing Process Death — iOS

```bash
# Simulate memory pressure on simulator
xcrun simctl terminate booted com.example.app

# For reliable testing, use the Xcode memory debugger:
# 1. Run app from Xcode
# 2. Background the app
# 3. Xcode → Debug → Simulate Memory Warning
```

## Unit Test — HydratedCubit

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/src/features/settings/cubit/settings_cubit.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  late Storage mockStorage;

  setUp(() {
    mockStorage = MockStorage();
    when(() => mockStorage.read(any())).thenReturn(null);
    when(() => mockStorage.write(any(), any<dynamic>()))
        .thenAnswer((_) async {});
    when(() => mockStorage.delete(any())).thenAnswer((_) async {});
    when(() => mockStorage.clear()).thenAnswer((_) async {});
    HydratedBloc.storage = mockStorage;
  });

  test('toJson serializes state correctly', () {
    final cubit = SettingsCubit();
    final json = cubit.toJson(
      const SettingsState(isDarkMode: true, languageCode: 'vi'),
    );

    expect(json, {'isDarkMode': true, 'languageCode': 'vi'});
    cubit.close();
  });

  test('fromJson deserializes state correctly', () {
    final cubit = SettingsCubit();
    final state = cubit.fromJson({
      'isDarkMode': true,
      'languageCode': 'vi',
    });

    expect(state?.isDarkMode, isTrue);
    expect(state?.languageCode, 'vi');
    cubit.close();
  });

  test('fromJson handles null/missing fields', () {
    final cubit = SettingsCubit();
    final state = cubit.fromJson({});

    expect(state?.isDarkMode, isFalse);
    expect(state?.languageCode, 'en');
    cubit.close();
  });

  test('fromJson handles corrupt data', () {
    final cubit = SettingsCubit();
    final state = cubit.fromJson({'isDarkMode': 'not_a_bool'});

    // Should return default rather than crash.
    expect(state?.isDarkMode, isFalse);
    cubit.close();
  });
}
```

## Unit Test — RestorableEnum

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app/src/core/restoration/restorable_enum.dart';

enum SortOrder { newest, oldest, popular }

void main() {
  test('toPrimitives returns index', () {
    final prop = RestorableEnum(SortOrder.newest, values: SortOrder.values);
    prop.value = SortOrder.popular;
    expect(prop.toPrimitives(), 2);
  });

  test('fromPrimitives restores correct enum', () {
    final prop = RestorableEnum(SortOrder.newest, values: SortOrder.values);
    final restored = prop.fromPrimitives(1);
    expect(restored, SortOrder.oldest);
  });

  test('fromPrimitives falls back to default for out-of-range', () {
    final prop = RestorableEnum(SortOrder.newest, values: SortOrder.values);
    final restored = prop.fromPrimitives(99);
    expect(restored, SortOrder.newest);
  });
}
```

## Widget Test — RestorationMixin

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('RestorationMixin restores text field', (tester) async {
    await tester.pumpWidget(
      const RootRestorationScope(
        restorationId: 'test',
        child: MaterialApp(
          restorationScopeId: 'app',
          home: _TestRestorablePage(),
        ),
      ),
    );

    // Type text
    await tester.enterText(find.byType(TextField), 'Hello');
    expect(find.text('Hello'), findsOneWidget);

    // Simulate restoration cycle by rebuilding widget
    await tester.restartAndRestore();
    await tester.pumpAndSettle();

    // Text should be preserved
    expect(find.text('Hello'), findsOneWidget);
  });
}

class _TestRestorablePage extends StatefulWidget {
  const _TestRestorablePage();

  @override
  State<_TestRestorablePage> createState() => _TestRestorablePageState();
}

class _TestRestorablePageState extends State<_TestRestorablePage>
    with RestorationMixin {
  final _controller = RestorableTextEditingController();

  @override
  String? get restorationId => 'test_page';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_controller, 'text');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: TextField(controller: _controller.value));
  }
}
```

## Process Death Testing Checklist

| Screen | Form fields | Scroll offset | Tab/page index | Filter/sort | Nav stack |
|---|---|---|---|---|---|
| Checkout | Name, email, address | — | — | — | /checkout |
| Post list | — | Y | — | Category | /posts |
| Main shell | — | — | Tab index | — | branch 0/1/2 |
| Search | Query text | Results scroll | — | Sort order | /search |
| Settings | — | — | — | — | /settings |

For each cell marked, verify it survives `adb shell am kill` + reopen from recents.

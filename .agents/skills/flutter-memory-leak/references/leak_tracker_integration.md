# `leak_tracker` Integration

Automated leak detection in widget tests using `leak_tracker_flutter_testing`.

## Test setup

```dart
// test/flutter_test_config.dart
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  LeakTesting.enable();
  await testMain();
}
```

`flutter_test_config.dart` is automatically loaded by the test runner — no per-test setup needed.

## Per-test override (opt-out for known leaks)

```dart
testWidgets(
  'my widget',
  (tester) async {
    await tester.pumpWidget(const MyWidget());
    await tester.pumpAndSettle();
    // test body
  },
  // Opt out only for platform widgets that can't be fixed
  leakTrackingConfig: const LeakTesting.settings.withIgnoredAll(),
);
```

## What `leak_tracker` catches

- `Disposable` objects not disposed before GC (TextEditingController, AnimationController, etc.)
- Objects that were disposed but still referenced (not-disposed-and-not-GCed)
- Custom classes annotated with `@pragma('vm:notify-debugger-on-exception')`

## Test example

```dart
// test/features/task/presentation/task_list_page_test.dart
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

void main() {
  group('TaskListPage memory', () {
    testWidgets(
      'disposes cleanly on unmount',
      (tester) async {
        await tester.pumpWidget(
          BlocProvider(
            create: (_) => MockTaskListCubit(),
            child: const MaterialApp(home: TaskListPage()),
          ),
        );
        await tester.pumpAndSettle();

        // Navigate away to trigger dispose
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();

        // leak_tracker will assert no leaks at test teardown
      },
    );
  });
}
```

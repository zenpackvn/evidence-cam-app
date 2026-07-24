# Animation Testing

Widget tests and mock patterns for animation code.

## Golden test for Lottie placeholder

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:app/src/core/animations/app_lottie.dart';

void main() {
  testWidgets('AppLottie shows fallback when asset missing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppLottieImpl(
            asset: 'nonexistent.json',
            width: 200,
            height: 200,
          ),
        ),
      ),
    );

    // Fallback SizedBox rendered, no crash.
    expect(find.byType(SizedBox), findsOneWidget);
  });
}
```

## Testing staggered entrance

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('staggered items appear with delay', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              for (var i = 0; i < 5; i++)
                Text('Item $i').appStaggeredItem(index: i),
            ],
          ),
        ),
      ),
    );

    // Initially items are invisible (opacity 0).
    await tester.pump();

    // After enough time, all items visible.
    await tester.pumpAndSettle();
    for (var i = 0; i < 5; i++) {
      expect(find.text('Item $i'), findsOneWidget);
    }
  });
}
```

## Testing AnimatedListWrapper

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:app/src/core/animations/animated_list_wrapper.dart';

void main() {
  testWidgets('AnimatedListWrapper inserts and removes items', (tester) async {
    final items = ['A', 'B', 'C'];
    late AnimatedListWrapperState<String> wrapperState;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedListWrapper<String>(
            items: items,
            itemBuilder: (context, item, animation) => Text(item),
          ),
        ),
      ),
    );

    wrapperState = tester.state(find.byType(AnimatedListWrapper<String>));

    // Insert item.
    wrapperState.insertItem(1, 'X');
    await tester.pumpAndSettle();
    expect(find.text('X'), findsOneWidget);

    // Remove item.
    wrapperState.removeItem(1);
    await tester.pumpAndSettle();
    expect(find.text('X'), findsNothing);
  });
}
```

## Bloc test with animation presets mock

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/src/core/animations/app_animate.dart';

class MockAppAnimatePresets extends Mock implements AppAnimatePresets {}

void main() {
  late MockAppAnimatePresets mockPresets;

  setUp(() {
    mockPresets = MockAppAnimatePresets();
    initAppAnimatePresets(mockPresets);
  });

  test('mock presets return child unchanged for testing', () {
    // In tests, presets can pass-through the child without animation.
    when(() => mockPresets.fadeIn(any(), duration: any(named: 'duration'), delay: any(named: 'delay')))
        .thenAnswer((invocation) => invocation.positionalArguments[0] as Widget);
  });
}
```

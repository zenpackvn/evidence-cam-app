# Accessibility Testing

Widget tests verify the semantics tree and tap target sizes. Use screen readers for manual flow testing.

## Screen reader setup

- **iOS (VoiceOver)**: Settings > Accessibility > VoiceOver > On. Or triple-click the side button if configured.
- **Android (TalkBack)**: Settings > Accessibility > TalkBack > On.

## Flutter Semantics Debugger

Enable during development to overlay the semantics tree on screen:

```dart
MaterialApp(
  showSemanticsDebugger: true, // Remove before release.
  // ...
);
```

## Widget tests for semantic labels and tap targets

```dart
@Tags(['accessibility'])
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FavoriteButton accessibility', () {
    testWidgets('has correct semantic label when not favorited', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FavoriteButton(
              isFavorite: false,
              onToggle: () {},
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(FavoriteButton));
      expect(semantics.label, 'Add to favorites');
      expect(semantics.hasAction(SemanticsAction.tap), isTrue);
    });

    testWidgets('has correct semantic label when favorited', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FavoriteButton(
              isFavorite: true,
              onToggle: () {},
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(FavoriteButton));
      expect(semantics.label, 'Remove from favorites');
    });

    testWidgets('tap target meets minimum 48x48', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FavoriteButton(
              isFavorite: false,
              onToggle: () {},
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(FavoriteButton));
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));
    });
  });

  group('StarRating accessibility', () {
    testWidgets('announces current rating value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StarRating(
              rating: 3,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(StarRating));
      expect(semantics.label, 'Rating');
      expect(semantics.value, '3 out of 5 stars');
    });
  });

  group('StatusChip accessibility', () {
    testWidgets('announces status type and label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusChip(type: StatusType.error, label: 'Payment failed'),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(StatusChip));
      expect(semantics.label, contains('error'));
      expect(semantics.label, contains('Payment failed'));
    });
  });
}
```

## Running accessibility tests

```bash
flutter test --tags accessibility
```

## Screen reader testing checklist

1. Navigate every screen with VoiceOver / TalkBack enabled.
2. Verify all buttons are announced with their action (e.g., "Add to cart, button").
3. Verify all images have a meaningful `semanticLabel` or are excluded via `ExcludeSemantics`.
4. Verify all state changes are announced (e.g., "Loading", "3 items loaded").
5. Verify focus order matches the visual top-to-bottom, left-to-right reading order.
6. Verify dialogs trap focus and return it on dismissal.

## Rules

- **Tag accessibility tests** with `@Tags(['accessibility'])` so they can run as a targeted suite: `flutter test --tags accessibility`.
- **Test semantics in CI** — Verify semantic labels, values, and tap target sizes in widget tests.
- **Profile with real screen readers** — Automated tests catch structural issues. Manual testing with VoiceOver and TalkBack catches flow and comprehension issues.

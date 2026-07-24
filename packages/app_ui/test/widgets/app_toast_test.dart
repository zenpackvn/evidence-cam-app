import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppToast', () {
    testWidgets('shows a snackbar with the message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => AppToast.success(context, 'Saved!'),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('go'));
      await tester.pump(); // let the snackbar animate in

      expect(find.widgetWithText(SnackBar, 'Saved!'), findsOneWidget);
    });

    testWidgets('renders an action when label + callback are given', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => AppToast.error(
                  context,
                  'Oops',
                  actionLabel: 'Retry',
                  onAction: () => tapped = true,
                ),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('go'));
      // Let the snackbar finish sliding in so its action is hittable.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Retry'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(tapped, isTrue);
    });

    testWidgets('replaces the in-flight snackbar instead of queuing', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Column(
                children: [
                  ElevatedButton(
                    onPressed: () => AppToast.info(context, 'first'),
                    child: const Text('a'),
                  ),
                  ElevatedButton(
                    onPressed: () => AppToast.info(context, 'second'),
                    child: const Text('b'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('a'));
      await tester.pump();
      await tester.tap(find.text('b'));
      await tester.pump();

      expect(find.text('second'), findsOneWidget);
      expect(find.text('first'), findsNothing);
    });
  });
}

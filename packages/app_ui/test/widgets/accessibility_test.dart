import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('AppButton accessibility', () {
    testWidgets('meets tap-target and labeled-tappable guidelines', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          Center(
            child: AppButton(label: 'Save', onPressed: () {}),
          ),
        ),
      );

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });

    testWidgets('keeps an accessible name while loading', (tester) async {
      await tester.pumpWidget(
        _app(
          const Center(
            child: AppButton(label: 'Save', onPressed: null, isLoading: true),
          ),
        ),
      );

      // The visible text is gone, but the spinner carries the label so the
      // control is not announced as unlabelled.
      final spinner = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(spinner.semanticsLabel, 'Save');
    });
  });

  group('AppLoading accessibility', () {
    testWidgets('labels the spinner for screen readers', (tester) async {
      await tester.pumpWidget(_app(const AppLoading()));
      await tester.pump(AppDurations.fast);

      final spinner = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(spinner.semanticsLabel, 'Loading');
    });

    testWidgets('prefers the provided label', (tester) async {
      await tester.pumpWidget(_app(const AppLoading(label: 'Saving…')));
      await tester.pump(AppDurations.fast);

      final spinner = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(spinner.semanticsLabel, 'Saving…');
    });
  });
}

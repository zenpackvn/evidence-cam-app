import 'package:app_ui/app_ui.dart';
import 'package:feature_letters/feature_letters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: child,
);

void main() {
  group('TemplateListScreen reply mode (SM-020 BR-01)', () {
    testWidgets('default mode shows the plain title, no recipient', (tester) async {
      await tester.pumpWidget(_host(TemplateListScreen(onPick: (_) {})));
      expect(find.text('Chọn template'), findsOneWidget);
      expect(find.textContaining('Gửi tới'), findsNothing);
    });

    testWidgets('reply mode prefills the original sender as recipient',
        (tester) async {
      await tester.pumpWidget(
        _host(TemplateListScreen(onPick: (_) {}, replyToName: 'An')),
      );
      expect(find.text('Trả lời'), findsOneWidget);
      expect(find.text('Gửi tới An'), findsOneWidget);
    });

    testWidgets('an empty reply name falls back to the default title',
        (tester) async {
      await tester.pumpWidget(
        _host(TemplateListScreen(onPick: (_) {}, replyToName: '')),
      );
      expect(find.text('Chọn template'), findsOneWidget);
      expect(find.textContaining('Gửi tới'), findsNothing);
    });
  });
}

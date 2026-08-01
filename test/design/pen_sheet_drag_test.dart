import 'package:ec_ui/ec_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PenSheet drag-to-dismiss', () {
    Future<bool> dragBy(WidgetTester tester, Offset delta) async {
      var dismissed = false;
      await tester.pumpWidget(
        CupertinoApp(
          home: PenSheet(
            onDismiss: () => dismissed = true,
            children: const [SizedBox(height: 200, child: Text('body'))],
          ),
        ),
      );
      await tester.drag(find.text('body'), delta);
      await tester.pumpAndSettle();
      return dismissed;
    }

    testWidgets('dismisses on a long drag down', (tester) async {
      expect(await dragBy(tester, const Offset(0, 150)), isTrue);
    });

    testWidgets('snaps back on a short drag down', (tester) async {
      expect(await dragBy(tester, const Offset(0, 30)), isFalse);
    });

    testWidgets('ignores upward drags', (tester) async {
      expect(await dragBy(tester, const Offset(0, -150)), isFalse);
    });
  });
}

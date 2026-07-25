import 'package:flutter/material.dart';
import 'package:flutter_starter_template/screens/ec_record_route.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'degrades to the idle screen when no camera is available',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: EcRecordRoute()));
      // The test environment has no camera plugin, so setup fails; let the
      // async failure land in the error/idle state.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // No exception escaped, and the idle "wait for bill" screen is shown
      // (recording never started).
      expect(tester.takeException(), isNull);
      expect(find.text('Đưa bill vào khung để bắt đầu'), findsOneWidget);
    },
  );
}

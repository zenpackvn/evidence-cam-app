import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Boom extends StatelessWidget {
  const _Boom();

  @override
  Widget build(BuildContext context) => throw StateError('boom');
}

void main() {
  // AppErrorBoundary swaps the global ErrorWidget.builder; snapshot and restore
  // it per test so a throwing case can't leak a stale builder into the next.
  late ErrorWidgetBuilder original;
  setUp(() => original = ErrorWidget.builder);
  tearDown(() => ErrorWidget.builder = original);

  group('AppErrorBoundary', () {
    testWidgets('renders the default fallback when a child build throws', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppErrorBoundary(child: _Boom()),
        ),
      );
      // Settle the default fallback's entrance animation (flutter_animate).
      await tester.pump(const Duration(seconds: 1));

      // The framework still records the caught build error; acknowledge it so
      // the test passes on the *handled* outcome rather than the raw throw.
      expect(tester.takeException(), isStateError);
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('routes the error to onError', (tester) async {
      Object? captured;
      await tester.pumpWidget(
        MaterialApp(
          home: AppErrorBoundary(
            onError: (details) => captured = details.exception,
            child: const _Boom(),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isStateError);
      expect(captured, isStateError);
    });

    testWidgets('uses a custom fallbackBuilder when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppErrorBoundary(
            fallbackBuilder: (_) => const Text('custom fallback'),
            child: const _Boom(),
          ),
        ),
      );

      expect(tester.takeException(), isStateError);
      expect(find.text('custom fallback'), findsOneWidget);
    });

    testWidgets('passes a healthy child through untouched', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppErrorBoundary(child: Text('all good')),
        ),
      );

      expect(find.text('all good'), findsOneWidget);
      expect(find.text('Something went wrong'), findsNothing);
    });
  });
}

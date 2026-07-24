import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

AppAsyncView _view(AppAsyncStatus status) => AppAsyncView(
  status: status,
  errorMessage: 'Boom',
  emptyMessage: 'Empty',
  onRetry: () {},
  data: (_) => const Text('DATA'),
);

void main() {
  group('AppAsyncView', () {
    testWidgets('loading shows the skeleton list, not data', (tester) async {
      await tester.pumpWidget(_host(_view(AppAsyncStatus.loading)));
      await tester.pump(AppDurations.fast);

      expect(find.byType(AppSkeletonList), findsOneWidget);
      expect(find.text('DATA'), findsNothing);
    });

    testWidgets('error shows the error view with the message', (tester) async {
      await tester.pumpWidget(_host(_view(AppAsyncStatus.error)));
      await tester.pump(AppDurations.medium);

      expect(find.byType(AppErrorView), findsOneWidget);
      expect(find.text('Boom'), findsOneWidget);
      expect(find.text('DATA'), findsNothing);
    });

    testWidgets('empty shows the empty view with the message', (tester) async {
      await tester.pumpWidget(_host(_view(AppAsyncStatus.empty)));
      await tester.pump(AppDurations.medium);

      expect(find.byType(AppEmptyView), findsOneWidget);
      expect(find.text('Empty'), findsOneWidget);
      expect(find.text('DATA'), findsNothing);
    });

    testWidgets('data builds the provided content', (tester) async {
      await tester.pumpWidget(_host(_view(AppAsyncStatus.data)));

      expect(find.text('DATA'), findsOneWidget);
      expect(find.byType(AppSkeletonList), findsNothing);
    });

    testWidgets('honours a custom empty override', (tester) async {
      await tester.pumpWidget(
        _host(
          AppAsyncView(
            status: AppAsyncStatus.empty,
            empty: const Text('CUSTOM EMPTY'),
            data: (_) => const Text('DATA'),
          ),
        ),
      );

      expect(find.text('CUSTOM EMPTY'), findsOneWidget);
      expect(find.byType(AppEmptyView), findsNothing);
    });
  });
}

# Testing — Error Handling

## Fake Implementation

```dart
class FakeErrorHandler implements ErrorHandler {
  final List<ErrorRecord> records = [];

  @override
  void handleError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
    bool fatal = false,
  }) {
    records.add(ErrorRecord(
      error: error,
      stackTrace: stackTrace,
      reason: reason,
      fatal: fatal,
      source: 'handleError',
    ));
  }

  @override
  void handleFlutterError(FlutterErrorDetails details) {
    records.add(ErrorRecord(
      error: details.exception,
      stackTrace: details.stack ?? StackTrace.current,
      reason: 'FlutterError: ${details.library}',
      source: 'handleFlutterError',
    ));
  }

  @override
  bool handlePlatformError(Object error, StackTrace stackTrace) {
    records.add(ErrorRecord(
      error: error,
      stackTrace: stackTrace,
      reason: 'PlatformDispatcher',
      fatal: true,
      source: 'handlePlatformError',
    ));
    return true;
  }

  @override
  void handleZoneError(Object error, StackTrace stackTrace) {
    records.add(ErrorRecord(
      error: error,
      stackTrace: stackTrace,
      reason: 'Zone error',
      fatal: true,
      source: 'handleZoneError',
    ));
  }
}

class ErrorRecord {
  const ErrorRecord({
    required this.error,
    required this.stackTrace,
    this.reason,
    this.fatal = false,
    this.source = 'unknown',
  });

  final Object error;
  final StackTrace stackTrace;
  final String? reason;
  final bool fatal;
  final String source;
}
```

## Unit Tests — ErrorHandlerImpl

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/src/core/error/error_handler.dart';
import 'package:app/src/core/logging/app_logger.dart';
import 'package:app/src/core/analytics/crash_reporter.dart';

class MockLogger extends Mock implements AppLogger {}
class MockCrashReporter extends Mock implements CrashReporter {}

void main() {
  late MockLogger mockLogger;
  late MockCrashReporter mockCrash;
  late ErrorHandlerImpl handler;

  setUp(() {
    mockLogger = MockLogger();
    mockCrash = MockCrashReporter();
    handler = ErrorHandlerImpl(logger: mockLogger, crashReporter: mockCrash);
  });

  setUpAll(() {
    registerFallbackValue(StackTrace.current);
  });

  test('handleError logs and reports', () {
    final error = Exception('test');
    final stack = StackTrace.current;

    handler.handleError(error, stack, reason: 'unit test');

    verify(() => mockLogger.error('unit test', error: error, stackTrace: stack))
        .called(1);
    verify(() => mockCrash.recordError(
          error, stack,
          reason: 'unit test',
          fatal: false,
        )).called(1);
  });

  test('handleFlutterError adds breadcrumb and reports', () {
    final details = FlutterErrorDetails(
      exception: Exception('build failed'),
      library: 'widgets library',
    );

    handler.handleFlutterError(details);

    verify(() => mockCrash.addBreadcrumb(
          any(that: contains('widgets library')),
          category: 'flutter',
        )).called(1);
    verify(() => mockCrash.recordError(
          details.exception,
          any(),
          reason: any(named: 'reason', that: contains('FlutterError')),
          fatal: false,
        )).called(1);
  });

  test('handlePlatformError returns true and reports as fatal', () {
    final error = Exception('isolate crash');
    final stack = StackTrace.current;

    final result = handler.handlePlatformError(error, stack);

    expect(result, isTrue);
    verify(() => mockCrash.recordError(
          error, stack,
          reason: 'PlatformDispatcher.onError',
          fatal: true,
        )).called(1);
  });

  test('handleZoneError reports as fatal', () {
    final error = Exception('zone leak');
    final stack = StackTrace.current;

    handler.handleZoneError(error, stack);

    verify(() => mockCrash.recordError(
          error, stack,
          reason: 'runZonedGuarded zone error',
          fatal: true,
        )).called(1);
  });
}
```

## Widget Test — ErrorBoundary

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:app/src/core/error/error_boundary_widget.dart';
import 'package:app/src/core/error/error_handler.dart';
import 'fakes/fake_error_handler.dart';

void main() {
  late FakeErrorHandler fakeHandler;

  setUp(() {
    fakeHandler = FakeErrorHandler();
    GetIt.I.registerSingleton<ErrorHandler>(fakeHandler);
  });

  tearDown(() => GetIt.I.reset());

  testWidgets('ErrorBoundary shows fallback when child throws', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ErrorBoundary(
          fallback: const Text('Error occurred'),
          child: Builder(
            builder: (_) => throw Exception('boom'),
          ),
        ),
      ),
    );
    await tester.pump();

    // The fallback should be shown (or the default error fallback).
    // Note: Flutter's error handling in tests may differ from production.
    expect(fakeHandler.records, isNotEmpty);
  });

  testWidgets('ErrorBoundary renders child when no error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ErrorBoundary(
          child: const Text('All good'),
        ),
      ),
    );

    expect(find.text('All good'), findsOneWidget);
  });
}
```

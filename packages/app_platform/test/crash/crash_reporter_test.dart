import 'package:app_platform/app_platform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingReporter implements CrashReporter {
  final errors = <Object>[];

  @override
  Future<void> install() async {}

  @override
  Future<void> recordError(
    Object error,
    StackTrace stack, {
    String? reason,
    bool fatal = false,
  }) async {
    errors.add(error);
  }
}

void main() {
  group('installGlobalErrorHandlers', () {
    final previousOnError = FlutterError.onError;
    final previousDispatcherOnError = PlatformDispatcher.instance.onError;

    tearDown(() {
      FlutterError.onError = previousOnError;
      PlatformDispatcher.instance.onError = previousDispatcherOnError;
    });

    test('routes framework errors through the reporter', () {
      final reporter = _RecordingReporter();
      installGlobalErrorHandlers(reporter);

      FlutterError.onError!(
        FlutterErrorDetails(exception: StateError('boom')),
      );

      expect(reporter.errors.single, isA<StateError>());
    });

    test('routes platform-dispatcher errors and returns handled', () {
      final reporter = _RecordingReporter();
      installGlobalErrorHandlers(reporter);

      final handled = PlatformDispatcher.instance.onError!(
        ArgumentError('nope'),
        StackTrace.current,
      );

      expect(handled, isTrue);
      expect(reporter.errors.single, isA<ArgumentError>());
    });

    test('installs even with a no-op reporter (never throws)', () {
      expect(
        () => installGlobalErrorHandlers(const NoOpCrashReporter()),
        returnsNormally,
      );
      expect(
        () => FlutterError.onError!(
          FlutterErrorDetails(exception: Exception('x')),
        ),
        returnsNormally,
      );
    });
  });
}

import 'package:app_platform/app_platform.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _CapturedLog {
  _CapturedLog(this.level, this.message, this.error);
  final String level;
  final String message;
  final Object? error;
}

class _FakeLogger implements AppLogger {
  final logs = <_CapturedLog>[];

  @override
  void debug(String m, {String? name, Object? error, StackTrace? stackTrace}) =>
      logs.add(_CapturedLog('debug', m, error));

  @override
  void info(String m, {String? name, Object? error, StackTrace? stackTrace}) =>
      logs.add(_CapturedLog('info', m, error));

  @override
  void warn(String m, {String? name, Object? error, StackTrace? stackTrace}) =>
      logs.add(_CapturedLog('warn', m, error));

  @override
  void error(String m, {String? name, Object? error, StackTrace? stackTrace}) =>
      logs.add(_CapturedLog('error', m, error));
}

class _FakeCrashReporter implements CrashReporter {
  final recorded = <Object>[];

  @override
  Future<void> install() async {}

  @override
  Future<void> recordError(
    Object error,
    StackTrace stack, {
    String? reason,
    bool fatal = false,
  }) async {
    recorded.add(error);
  }
}

class _CounterCubit extends Cubit<int> {
  _CounterCubit() : super(0);
  void inc() => emit(state + 1);
}

void main() {
  group('AppBlocObserver', () {
    test('logs state changes at debug level when enabled', () {
      final logger = _FakeLogger();
      final observer = AppBlocObserver(logger);
      final cubit = _CounterCubit();

      observer.onChange(cubit, const Change(currentState: 0, nextState: 1));

      expect(logger.logs.single.level, 'debug');
      cubit.close();
    });

    test('does not log state changes when disabled', () {
      final logger = _FakeLogger();
      final observer = AppBlocObserver(logger, logStateChanges: false);
      final cubit = _CounterCubit();

      observer.onChange(cubit, const Change(currentState: 0, nextState: 1));

      expect(logger.logs, isEmpty);
      cubit.close();
    });

    test('logs errors and forwards them to the crash reporter', () {
      final logger = _FakeLogger();
      final crash = _FakeCrashReporter();
      final observer = AppBlocObserver(logger, crashReporter: crash);
      final cubit = _CounterCubit();
      final error = StateError('boom');

      observer.onError(cubit, error, StackTrace.current);

      expect(logger.logs.single.level, 'error');
      expect(logger.logs.single.error, error);
      expect(crash.recorded.single, error);
      cubit.close();
    });

    test('works without a crash reporter', () {
      final logger = _FakeLogger();
      final observer = AppBlocObserver(logger);
      final cubit = _CounterCubit();

      expect(
        () => observer.onError(cubit, Exception('x'), StackTrace.current),
        returnsNormally,
      );
      expect(logger.logs.single.level, 'error');
      cubit.close();
    });
  });
}

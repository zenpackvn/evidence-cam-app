# Test Fakes

Fake implementations for `AnalyticsService` and `CrashReporter` that record calls for assertion in unit tests.

## `FakeAnalyticsService`

```dart
class FakeAnalyticsService implements AnalyticsService {
  final List<AnalyticsCall> calls = [];

  @override
  Future<void> trackEvent(String name, {Map<String, Object>? params}) async {
    calls.add(AnalyticsCall('trackEvent', name, params));
  }

  @override
  Future<void> trackScreen(String name, {Map<String, Object>? params}) async {
    calls.add(AnalyticsCall('trackScreen', name, params));
  }

  @override
  Future<void> setUserId(String? id) async {
    calls.add(AnalyticsCall('setUserId', id, null));
  }

  @override
  Future<void> setUserProperty({
    required String key,
    required String value,
  }) async {
    calls.add(AnalyticsCall('setUserProperty', key, {'value': value}));
  }

  @override
  Future<void> reset() async {
    calls.add(AnalyticsCall('reset', null, null));
  }
}

class AnalyticsCall {
  const AnalyticsCall(this.method, this.name, this.params);
  final String method;
  final Object? name;
  final Map<String, Object>? params;

  @override
  String toString() => 'AnalyticsCall($method, $name, $params)';
}
```

## `FakeCrashReporter`

```dart
class FakeCrashReporter implements CrashReporter {
  final List<CrashReportCall> calls = [];

  @override
  Future<void> init() async {
    calls.add(const CrashReportCall('init'));
  }

  @override
  void recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
    String? reason,
  }) {
    calls.add(CrashReportCall('recordError', error: error, reason: reason));
  }

  @override
  void addBreadcrumb(String message, {String? category}) {
    calls.add(CrashReportCall('addBreadcrumb', reason: message));
  }

  @override
  void setUserId(String? userId) {
    calls.add(CrashReportCall('setUserId', userId: userId));
  }
}

class CrashReportCall {
  const CrashReportCall(
    this.method, {
    this.error,
    this.reason,
    this.userId,
  });
  final String method;
  final Object? error;
  final String? reason;
  final String? userId;

  @override
  String toString() => 'CrashReportCall($method, error: $error, reason: $reason)';
}
```

## Test setup example

```dart
late FakeAnalyticsService fakeAnalytics;
late FakeCrashReporter fakeCrash;

setUp(() async {
  await getIt.reset();

  fakeAnalytics = FakeAnalyticsService();
  fakeCrash = FakeCrashReporter();

  getIt
    ..registerSingleton<AnalyticsService>(fakeAnalytics)
    ..registerSingleton<CrashReporter>(fakeCrash);
});

test('tracks event on post like', () async {
  // act
  await cubit.likePost('42');

  // assert
  expect(
    fakeAnalytics.calls,
    contains(
      isA<AnalyticsCall>()
          .having((c) => c.method, 'method', 'trackEvent')
          .having((c) => c.name, 'name', 'post_liked'),
    ),
  );
});
```

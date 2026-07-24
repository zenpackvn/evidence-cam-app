import 'dart:async';

import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

/// Automatically loaded by the Flutter test runner for every test file under
/// this directory. Enables leak tracking globally — undisposed controllers,
/// subscriptions, and other disposable objects will fail the test.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  LeakTesting.enable();
  await testMain();
}

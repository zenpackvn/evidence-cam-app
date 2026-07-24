# Test Fakes and Example Tests

Never depend on real FCM or local notification plugins in unit or widget tests. Use exposed stream controllers to simulate push events.

## `test/fakes/fake_push_notification_service.dart`

```dart
import 'dart:async';

import 'package:your_app/src/core/push/notification_payload.dart';
import 'package:your_app/src/core/push/push_notification_service.dart';

class FakePushNotificationService implements PushNotificationService {
  final foregroundController =
      StreamController<NotificationPayload>.broadcast();
  final openedAppController =
      StreamController<NotificationPayload>.broadcast();
  final tokenRefreshController = StreamController<String>.broadcast();

  String? tokenToReturn;
  NotificationPayload? initialMessageToReturn;
  bool initCalled = false;
  bool permissionRequested = false;
  final subscribedTopics = <String>{};

  @override
  Future<void> init() async => initCalled = true;

  @override
  Future<String?> getToken() async => tokenToReturn;

  @override
  Stream<String> get onTokenRefresh => tokenRefreshController.stream;

  @override
  Stream<NotificationPayload> get onForegroundMessage =>
      foregroundController.stream;

  @override
  Stream<NotificationPayload> get onMessageOpenedApp =>
      openedAppController.stream;

  @override
  Future<NotificationPayload?> getInitialMessage() async =>
      initialMessageToReturn;

  @override
  Future<void> requestPermission() async => permissionRequested = true;

  @override
  Future<void> subscribeToTopic(String topic) async =>
      subscribedTopics.add(topic);

  @override
  Future<void> unsubscribeFromTopic(String topic) async =>
      subscribedTopics.remove(topic);

  void dispose() {
    foregroundController.close();
    openedAppController.close();
    tokenRefreshController.close();
  }
}
```

## `test/fakes/fake_local_notification_service.dart`

```dart
import 'dart:async';

import 'package:your_app/src/core/push/local_notification_service.dart';

class FakeLocalNotificationService implements LocalNotificationService {
  final tapController = StreamController<String?>.broadcast();
  final shownNotifications = <({int id, String title, String? body, String? payload})>[];
  final cancelledIds = <int>[];
  bool initCalled = false;
  bool allCancelled = false;

  @override
  Future<void> init() async => initCalled = true;

  @override
  Future<void> show({
    required int id,
    required String title,
    String? body,
    String? payload,
  }) async {
    shownNotifications.add((id: id, title: title, body: body, payload: payload));
  }

  @override
  Future<void> cancel(int id) async => cancelledIds.add(id);

  @override
  Future<void> cancelAll() async => allCancelled = true;

  @override
  Stream<String?> get onNotificationTapped => tapController.stream;

  void dispose() {
    tapController.close();
  }
}
```

## Example Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/src/core/push/notification_handler.dart';
import 'package:your_app/src/core/push/notification_payload.dart';

import '../fakes/fake_push_notification_service.dart';
import 'package:app/src/core/logging/app_logger.dart';

void main() {
  late FakePushNotificationService fakePush;
  late List<String> navigatedPaths;
  late NotificationHandler handler;

  setUp(() {
    fakePush = FakePushNotificationService();
    navigatedPaths = [];
    handler = NotificationHandler(
      navigate: navigatedPaths.add,
      logger: NoOpLogger(),
    );
  });

  tearDown(() {
    fakePush.dispose();
  });

  test('routes post notification to post detail', () {
    final payload = NotificationPayload(
      title: 'New post',
      type: 'post',
      data: {'post_id': '42'},
    );

    handler.handle(payload);

    expect(navigatedPaths, ['/post/42']);
  });

  test('routes chat notification to chat screen', () {
    final payload = NotificationPayload(
      title: 'New message',
      type: 'chat',
      data: {'chat_id': 'abc123'},
    );

    handler.handle(payload);

    expect(navigatedPaths, ['/chat/abc123']);
  });

  test('ignores unknown notification types', () {
    final payload = NotificationPayload(
      title: 'Unknown',
      type: 'promo',
    );

    handler.handle(payload);

    expect(navigatedPaths, isEmpty);
  });

  test('foreground message stream emits payload', () async {
    final payload = NotificationPayload(title: 'Hello');

    expectLater(
      fakePush.onForegroundMessage,
      emits(payload),
    );

    fakePush.foregroundController.add(payload);
  });
}
```

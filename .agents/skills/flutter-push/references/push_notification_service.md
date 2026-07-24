# Push Notification Service

App-owned interface and FCM-backed implementation for push notifications. Only `push_notification_service_impl.dart` imports `package:firebase_messaging`. All other layers depend on the app-owned interface and `NotificationPayload`.

## Folder Structure

```text
lib/src/core/
  push/
    push_notification_service.dart         ← App-owned push interface
    push_notification_service_impl.dart    ← Wraps firebase_messaging (only import)
    local_notification_service.dart        ← App-owned local notification interface
    local_notification_service_impl.dart   ← Wraps flutter_local_notifications (only import)
    notification_payload.dart              ← App-owned notification data model
    notification_handler.dart              ← Routes notifications to features
```

## pubspec.yaml additions

```yaml
dependencies:
  firebase_messaging: 15.1.6
  firebase_core: 3.8.0
  flutter_local_notifications: 21.0.0
```

---

## `lib/src/core/push/notification_payload.dart`

```dart
/// App-owned notification data model.
/// No Firebase types leak past this boundary.
class NotificationPayload {
  const NotificationPayload({
    required this.title,
    this.body,
    this.data,
    this.type,
  });

  final String title;
  final String? body;
  final Map<String, dynamic>? data;
  final String? type;

  @override
  String toString() =>
      'NotificationPayload(title: $title, type: $type, data: $data)';
}
```

---

## `lib/src/core/push/push_notification_service.dart`

```dart
import 'notification_payload.dart';

/// App-owned interface for push notification management.
/// Consumers depend on this — never on firebase_messaging directly.
abstract interface class PushNotificationService {
  /// Initialise the push subsystem. Call once after authentication.
  Future<void> init();

  /// Returns the current FCM registration token, or null if unavailable.
  Future<String?> getToken();

  /// Emits a new token whenever FCM rotates it.
  Stream<String> get onTokenRefresh;

  /// Emits payloads for messages received while the app is in the foreground.
  Stream<NotificationPayload> get onForegroundMessage;

  /// Emits payloads when the user taps a notification while the app is in
  /// the background (but still alive).
  Stream<NotificationPayload> get onMessageOpenedApp;

  /// Returns the payload that launched the app from a terminated state,
  /// or null if the app was not opened via a notification.
  Future<NotificationPayload?> getInitialMessage();

  /// Requests notification permission from the OS.
  Future<void> requestPermission();

  /// Subscribes to an FCM topic.
  Future<void> subscribeToTopic(String topic);

  /// Unsubscribes from an FCM topic.
  Future<void> unsubscribeFromTopic(String topic);
}
```

---

## `lib/src/core/push/push_notification_service_impl.dart`

```dart
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'notification_payload.dart';
import 'push_notification_service.dart';

/// Top-level function required by FCM for background/terminated messages.
/// Must remain a top-level or static function — cannot be an instance method.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Heavy work (e.g. local DB writes) can happen here.
  // Keep it short — the OS may kill long-running isolates.
}

class PushNotificationServiceImpl implements PushNotificationService {
  PushNotificationServiceImpl([FirebaseMessaging? delegate])
      : _messaging = delegate ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  final _foregroundController =
      StreamController<NotificationPayload>.broadcast();
  final _openedAppController =
      StreamController<NotificationPayload>.broadcast();
  final _tokenRefreshController = StreamController<String>.broadcast();

  // ── Init ──────────────────────────────────────────────────────────────

  @override
  Future<void> init() async {
    // Register the background handler.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground messages.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final payload = _mapRemoteMessage(message);
      if (payload != null) _foregroundController.add(payload);
    });

    // User tapped notification while app was backgrounded.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final payload = _mapRemoteMessage(message);
      if (payload != null) _openedAppController.add(payload);
    });

    // Token refresh.
    _messaging.onTokenRefresh.listen(_tokenRefreshController.add);
  }

  // ── Token ─────────────────────────────────────────────────────────────

  @override
  Future<String?> getToken() => _messaging.getToken();

  @override
  Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  // ── Messages ──────────────────────────────────────────────────────────

  @override
  Stream<NotificationPayload> get onForegroundMessage =>
      _foregroundController.stream;

  @override
  Stream<NotificationPayload> get onMessageOpenedApp =>
      _openedAppController.stream;

  @override
  Future<NotificationPayload?> getInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    return message == null ? null : _mapRemoteMessage(message);
  }

  // ── Permission ────────────────────────────────────────────────────────

  @override
  Future<void> requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  // ── Topics ────────────────────────────────────────────────────────────

  @override
  Future<void> subscribeToTopic(String topic) =>
      _messaging.subscribeToTopic(topic);

  @override
  Future<void> unsubscribeFromTopic(String topic) =>
      _messaging.unsubscribeFromTopic(topic);

  // ── Mapping ───────────────────────────────────────────────────────────

  NotificationPayload? _mapRemoteMessage(RemoteMessage message) {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title'] as String?;
    if (title == null) return null;

    return NotificationPayload(
      title: title,
      body: notification?.body ?? message.data['body'] as String?,
      data: message.data,
      type: message.data['type'] as String?,
    );
  }
}
```

---

## No-op Implementation

For dev builds or when Firebase is not configured — register this in DI instead of the real impl.

```dart
/// No-op push notification service for dev builds without Firebase.
class NoOpPushNotificationService implements PushNotificationService {
  @override
  Future<void> init() async {}

  @override
  Future<String?> getToken() async => null;

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();

  @override
  Stream<NotificationPayload> get onForegroundMessage => const Stream.empty();

  @override
  Stream<NotificationPayload> get onMessageOpenedApp => const Stream.empty();

  @override
  Future<NotificationPayload?> getInitialMessage() async => null;

  @override
  Future<void> requestPermission() async {}

  @override
  Future<void> subscribeToTopic(String topic) async {}

  @override
  Future<void> unsubscribeFromTopic(String topic) async {}
}
```

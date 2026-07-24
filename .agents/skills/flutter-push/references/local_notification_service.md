# Local Notification Service

App-owned interface and implementation for on-device notifications. Only `local_notification_service_impl.dart` imports `package:flutter_local_notifications`.

## `lib/src/core/push/local_notification_service.dart`

```dart
/// App-owned interface for local (on-device) notifications.
/// Consumers depend on this — never on flutter_local_notifications directly.
abstract interface class LocalNotificationService {
  /// Initialise platform channels. Call once during bootstrap.
  Future<void> init();

  /// Display a local notification immediately.
  Future<void> show({
    required int id,
    required String title,
    String? body,
    String? payload,
  });

  /// Cancel a single notification by [id].
  Future<void> cancel(int id);

  /// Cancel all active notifications.
  Future<void> cancelAll();

  /// Emits the payload string when the user taps a local notification.
  Stream<String?> get onNotificationTapped;
}
```

---

## `lib/src/core/push/local_notification_service_impl.dart`

```dart
import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'local_notification_service.dart';

class LocalNotificationServiceImpl implements LocalNotificationService {
  LocalNotificationServiceImpl([FlutterLocalNotificationsPlugin? delegate])
      : _plugin = delegate ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final _tapController = StreamController<String?>.broadcast();

  static const _androidChannelId = 'default_channel';
  static const _androidChannelName = 'Default';
  static const _androidChannelDescription = 'Default notification channel';

  // ── Init ──────────────────────────────────────────────────────────────

  @override
  Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Create the Android notification channel.
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _androidChannelId,
              _androidChannelName,
              description: _androidChannelDescription,
              importance: Importance.high,
            ),
          );
    }
  }

  // ── Show / Cancel ─────────────────────────────────────────────────────

  @override
  Future<void> show({
    required int id,
    required String title,
    String? body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _androidChannelId,
      _androidChannelName,
      channelDescription: _androidChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: payload,
    );
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  // ── Tap handling ──────────────────────────────────────────────────────

  @override
  Stream<String?> get onNotificationTapped => _tapController.stream;

  void _onNotificationResponse(NotificationResponse response) {
    _tapController.add(response.payload);
  }
}
```

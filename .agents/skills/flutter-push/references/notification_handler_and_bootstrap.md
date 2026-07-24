# Notification Handler and Bootstrap

## `lib/src/core/push/notification_handler.dart`

Central router that maps notification types to navigation actions. Keeps feature-specific routing out of the push service layer. The `navigate` callback is wired to `AppRouter.instance.go` in DI, keeping this class free of GoRouter and BuildContext dependencies.

```dart
import '../logging/app_logger.dart';
import 'notification_payload.dart';

/// Central router that maps notification types to navigation actions.
/// Keeps feature-specific routing out of the push service layer.
///
/// The [navigate] callback is wired to [AppRouter.instance.go] in DI,
/// keeping this class free of GoRouter and BuildContext dependencies.
///
/// Add app-specific cases as new notification types are introduced.
class NotificationHandler {
  NotificationHandler({
    required void Function(String path) navigate,
    required AppLogger logger,
  })  : _navigate = navigate,
        _logger = logger;

  final void Function(String path) _navigate;
  final AppLogger _logger;

  void handle(NotificationPayload payload) {
    _logger.info('NotificationHandler: type=${payload.type}');
    final data = payload.data;

    switch (payload.type) {
      case 'post':
        final postId = data?['post_id'];
        if (postId != null) _navigate('/post/$postId');
      case 'chat':
        final chatId = data?['chat_id'];
        if (chatId != null) _navigate('/chat/$chatId');
      case 'profile':
        _navigate('/profile');
      default:
        break;
    }
  }
}
```

---

## `lib/src/core/push/push_bootstrap.dart`

Initialises push notification infrastructure. Call this after the user has signed in.

```dart
import 'dart:async';

import '../logging/app_logger.dart';
import 'local_notification_service.dart';
import 'notification_handler.dart';
import 'notification_payload.dart';
import 'push_notification_service.dart';

/// Initialises push notification infrastructure.
/// Call this after the user has signed in.
class PushBootstrap {
  PushBootstrap({
    required PushNotificationService pushService,
    required LocalNotificationService localService,
    required NotificationHandler handler,
    required AppLogger logger,
  })  : _pushService = pushService,
        _localService = localService,
        _handler = handler,
        _logger = logger;

  final PushNotificationService _pushService;
  final LocalNotificationService _localService;
  final NotificationHandler _handler;
  final AppLogger _logger;

  final List<StreamSubscription<dynamic>> _subscriptions = [];

  /// Initialise both services, wire listeners, and check for a cold-start
  /// notification.
  Future<void> init() async {
    await _pushService.init();
    await _localService.init();

    // Foreground FCM messages → show local notification.
    _subscriptions.add(
      _pushService.onForegroundMessage.listen(_showLocalNotification),
    );

    // User tapped a notification while app was backgrounded.
    _subscriptions.add(
      _pushService.onMessageOpenedApp.listen(
        (payload) => _handler.handle(payload),
      ),
    );

    // User tapped a local notification.
    _subscriptions.add(
      _localService.onNotificationTapped.listen(_onLocalTap),
    );

    // Cold start: the notification that launched the app from terminated.
    final initial = await _pushService.getInitialMessage();
    if (initial != null) {
      _handler.handle(initial);
    }

    _logger.info('Push notifications initialised');
  }

  /// Request OS-level permission. Call at an appropriate moment in the UX,
  /// not on first launch.
  Future<void> requestPermission() => _pushService.requestPermission();

  /// Returns the current FCM token (to send to your backend).
  Future<String?> getToken() => _pushService.getToken();

  /// Listens for token refreshes (re-send to your backend).
  Stream<String> get onTokenRefresh => _pushService.onTokenRefresh;

  /// Tear down subscriptions (e.g. on sign-out).
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  // ── Private ───────────────────────────────────────────────────────────

  int _notificationIdCounter = 0;

  void _showLocalNotification(NotificationPayload payload) {
    _localService.show(
      id: _notificationIdCounter++,
      title: payload.title,
      body: payload.body,
      payload: payload.type,
    );
  }

  void _onLocalTap(String? payload) {
    if (payload == null) return;
    // Re-create a minimal NotificationPayload for the handler.
    _handler.handle(NotificationPayload(title: '', type: payload));
  }
}
```

## Usage in `main.dart` / Auth Flow

```dart
// After successful sign-in:
final pushBootstrap = PushBootstrap(
  pushService: getIt<PushNotificationService>(),
  localService: getIt<LocalNotificationService>(),
  handler: getIt<NotificationHandler>(),
  logger: getIt<AppLogger>(),
);
await pushBootstrap.init();
await pushBootstrap.requestPermission();

// Send token to your backend.
final token = await pushBootstrap.getToken();
if (token != null) {
  await getIt<ApiClient>().registerDeviceToken(token);
}

// Listen for token refreshes.
pushBootstrap.onTokenRefresh.listen((newToken) {
  getIt<ApiClient>().registerDeviceToken(newToken);
});
```

```dart
// On sign-out:
pushBootstrap.dispose();
```

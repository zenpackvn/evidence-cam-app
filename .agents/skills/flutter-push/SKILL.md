---
name: flutter-push
description: Use this skill when implementing Flutter push notifications — FCM, Firebase Cloud Messaging, PushNotificationService, local notifications, flutter_local_notifications, notification handling, notification tap routing, background messages, foreground notification display, notification channels (Android), APNs (iOS), PushBootstrap, or any push notification feature.
---

# Flutter Push Notifications

Full reference: [`template.md`](references/template.md)

## Key rules

- Two interfaces: `PushNotificationService` (FCM tokens, remote message handling) and `LocalNotificationService` (display local notifications).
- **Never import** `firebase_messaging` or `flutter_local_notifications` outside their `*_impl.dart` files.
- **`PushBootstrap`** is the orchestration layer — it wires both services together, handles all three notification entry points, and owns subscription lifecycle. Feature code only calls `init()` / `dispose()`.
- Call `pushBootstrap.init()` **after authentication** (not at app start — permissions may not be granted yet). Call `pushBootstrap.dispose()` on sign-out.
- Background message handler must be a **top-level function** (FCM requirement).
- Three notification entry points handled by `PushBootstrap.init()`:
  - **Foreground**: `pushService.onForegroundMessage` → show local notification
  - **Backgrounded**: `pushService.onMessageOpenedApp` → route via `NotificationHandler`
  - **Cold start**: `pushService.getInitialMessage()` → route via `NotificationHandler`
- FCM token refresh: listen to `pushBootstrap.onTokenRefresh` stream and update the backend.
- Android notification channel must be created before showing the first notification (required Android 8+).
- iOS: request notification permission via `PermissionService` at an appropriate UX moment — not on cold start.

## `PushBootstrap` pattern

```dart
// After sign-in (e.g., in AuthCubit):
_pushBootstrap.init().catchError((_) {}); // errors must not break auth flow

// On sign-out:
_pushBootstrap.dispose();
```

## Files

```
lib/src/core/push/
  push_bootstrap.dart                     ← orchestrator (init/dispose, wires all streams)
  push_notification_service.dart          ← interface (init, getToken, onForegroundMessage, onMessageOpenedApp, getInitialMessage, onTokenRefresh, requestPermission)
  push_notification_service_impl.dart     ← only import of firebase_messaging
  local_notification_service.dart         ← interface (init, show, cancel, cancelAll, onNotificationTapped)
  local_notification_service_impl.dart    ← only import of flutter_local_notifications
  notification_handler.dart               ← routes NotificationPayload to GoRouter
  notification_payload.dart               ← value object (title, body, type)
```

## Co-load with

- `flutter-di` — register both services + PushBootstrap as singletons
- `flutter-permissions` — notification permission request
- `flutter-routing` — notification tap → navigate
- `flutter-auth` — init/dispose tied to auth lifecycle

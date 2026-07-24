# Template — Push Notifications

Push notification handling (FCM + local notifications) wrapped behind app-owned interfaces. Only `push_notification_service_impl.dart` imports `package:firebase_messaging`; only `local_notification_service_impl.dart` imports `package:flutter_local_notifications`. No Firebase types leak outside these impl files.

## Topic Index

| Topic | File |
|---|---|
| PushNotificationService interface, impl, and no-op | [push_notification_service.md](push_notification_service.md) |
| LocalNotificationService interface and impl | [local_notification_service.md](local_notification_service.md) |
| NotificationHandler (routing) and PushBootstrap | [notification_handler_and_bootstrap.md](notification_handler_and_bootstrap.md) |
| DI registration, Android setup, iOS setup | [di_and_platform_setup.md](di_and_platform_setup.md) |
| FakePushNotificationService, FakeLocalNotificationService, example tests | [test_fakes.md](test_fakes.md) |

## ⚠️ Common Mistakes

> These are the most frequent push notification bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **Firebase types leaking outside impl** | `RemoteMessage` or `FirebaseMessaging` imported in feature/handler files; analyzer flags missing package | Keep all `firebase_messaging` imports exclusively in `push_notification_service_impl.dart`; expose only `NotificationPayload` (plain Dart class) to the rest of the app |
| 2 | **Permission requested on first launch** | App Store review rejection; users see permission prompt before understanding the value | Call `requestPermission()` from a post-onboarding or post-login moment, never from `main()` or `bootstrap()` |
| 3 | **Missing terminated-state handler** | Notifications tapped when app is fully killed never navigate to the correct screen | Call `getInitialMessage()` inside `PushBootstrap.init()` and pass the result to `NotificationHandler.handle()` |
| 4 | **FCM token not refreshed after rotation** | Backend sends to stale token; notifications silently stop delivering | Listen to `onTokenRefresh` stream and re-register the new token with the backend on every rotation |
| 5 | **Raw payloads interpreted in feature code** | Notification routing logic scattered across multiple features; hard to audit | Route all notification types through `NotificationHandler` with a `switch` on `payload.type`; features never read raw `data` maps directly |
| 6 | **Android channel ID mismatch** | Notifications delivered silently (no sound/heads-up) on Android 8+ | Create the channel with `Importance.high` in `LocalNotificationServiceImpl.init()` and set the matching channel ID in `AndroidManifest.xml` `<meta-data>` |
| 7 | **StreamControllers not cancelled on logout** | Memory leak; stale listeners fire after the user logs out and logs in again | Call `PushBootstrap.dispose()` on sign-out to cancel all `StreamSubscription`s in `_subscriptions` |
| 8 | **Real FCM used in tests** | Tests require a Firebase-connected device; CI fails or hangs indefinitely | Inject `FakePushNotificationService` and `FakeLocalNotificationService` with exposed `StreamController`s; never depend on real Firebase in unit or widget tests |

## Quick Summary

- **Wrapper rule** — only `push_notification_service_impl.dart` imports `package:firebase_messaging`; only `local_notification_service_impl.dart` imports `package:flutter_local_notifications`. Any other import is a defect.
- **Init after auth** — initialise the push service after the user is authenticated; do not request OS permission on first launch.
- **Token lifecycle** — send the FCM token to the backend on login; clear or invalidate it on logout. Re-send on `onTokenRefresh`.
- **Three message states** — handle foreground (show local notification), background (`onMessageOpenedApp`), and terminated (`getInitialMessage` cold start). Missing any state is a defect.
- **Centralised routing** — use `NotificationHandler` for all notification-to-navigation mapping. Features do not interpret raw payloads.
- **No Firebase leakage** — `NotificationPayload` is a plain Dart class; no `RemoteMessage` or Firebase types appear outside the impl file.
- **Android channel** — create the notification channel with `Importance.high`. Match the channel ID in `AndroidManifest.xml` metadata.
- **Test with fakes** — use `FakePushNotificationService` and `FakeLocalNotificationService` with exposed stream controllers. Never depend on real FCM in tests.

## Cross-references

- [flutter-di](../../../flutter-di/references/template.md) — register `PushNotificationService`, `LocalNotificationService`, and `PushBootstrap` as singletons in the composition root
- [flutter-permissions](../../../flutter-permissions/references/template.md) — request notification permission via `PermissionService` at an appropriate UX moment, not on cold start
- [flutter-routing](../../../flutter-routing/references/template.md) — `NotificationHandler` routes notification tap payloads to screens via `AppNavigator`
- [flutter-auth](../../../flutter-auth/references/template.md) — `PushBootstrap.init()` is called after sign-in and `dispose()` on sign-out to tie push lifecycle to the auth lifecycle

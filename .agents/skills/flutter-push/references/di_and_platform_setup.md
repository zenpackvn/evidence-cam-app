# DI Registration and Platform Setup

## DI Registration

Add to `service_locator.dart` or a dedicated `push_module.dart`:

```dart
import '../push/push_notification_service.dart';
import '../push/push_notification_service_impl.dart';
import '../push/local_notification_service.dart';
import '../push/local_notification_service_impl.dart';
import '../push/notification_handler.dart';

void registerPushModule(GetIt getIt) {
  // Lazy singletons — shared across the app lifetime.
  getIt.registerLazySingleton<PushNotificationService>(
    PushNotificationServiceImpl.new,
  );
  getIt.registerLazySingleton<LocalNotificationService>(
    LocalNotificationServiceImpl.new,
  );

  // Singleton — callback is wired to the router at registration time,
  // keeping NotificationHandler free of BuildContext dependencies.
  getIt.registerLazySingleton<NotificationHandler>(
    () => NotificationHandler(
      navigate: AppRouter.instance.go,
      logger: getIt<AppLogger>(),
    ),
  );
}
```

Called from `configureDependencies()`:

```dart
Future<void> configureDependencies(Env env) async {
  // ... config, logging, storage, network ...

  // 6. Push notifications
  registerPushModule(getIt);
}
```

---

## Android Setup

### 1. `google-services.json`

Place the file downloaded from the Firebase Console at:

```
android/app/google-services.json
```

### 2. `android/build.gradle` (project-level)

```groovy
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.2'
    }
}
```

### 3. `android/app/build.gradle`

```groovy
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        minSdk = 21
    }
}
```

### 4. `android/app/src/main/AndroidManifest.xml`

Add inside `<application>`:

```xml
<!-- Default notification channel for FCM -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="default_channel" />

<!-- Default notification icon -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_icon"
    android:resource="@mipmap/ic_launcher" />

<!-- Required for flutter_local_notifications on Android 13+ -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

---

## iOS Setup

### 1. `GoogleService-Info.plist`

Place the file downloaded from the Firebase Console at:

```
ios/Runner/GoogleService-Info.plist
```

Add it to the Xcode project under the `Runner` target so it is included in the bundle.

### 2. Enable Capabilities in Xcode

Open `ios/Runner.xcworkspace` and under the **Runner** target → **Signing & Capabilities**:

- Add **Push Notifications**.
- Add **Background Modes** and check **Remote notifications**.

### 3. APNs Key

1. In the Apple Developer portal, create an APNs Authentication Key (`.p8` file).
2. In the Firebase Console → Project Settings → Cloud Messaging → iOS app, upload the `.p8` key.
3. Enter the Key ID and Team ID.

### 4. `ios/Runner/AppDelegate.swift`

```swift
import Flutter
import UIKit
import FirebaseCore
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)

    // Required for iOS foreground notification display.
    UNUserNotificationCenter.current().delegate = self

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Forward APNs token to FCM.
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
}
```

# Platform Setup

Required platform configuration for `permission_handler` on iOS and Android.

## iOS Info.plist Keys

Add the keys your app actually uses. Apple rejects apps with generic or missing descriptions.

```xml
<!-- Camera -->
<key>NSCameraUsageDescription</key>
<string>We need camera access to take photos for your profile.</string>

<!-- Photo Library -->
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to select a profile picture.</string>

<!-- Location (when-in-use) -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>We use your location to show nearby places.</string>

<!-- Location (always) -->
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We use your location in the background to track your run.</string>

<!-- Microphone -->
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access to record audio during video capture.</string>

<!-- Contacts -->
<key>NSContactsUsageDescription</key>
<string>We use your contacts to help you find friends on the app.</string>
```

> **Tip**: notifications on iOS do not require a plist entry. `permission_handler` delegates to `UNUserNotificationCenter` automatically.

## Android Permissions

Add to `android/app/src/main/AndroidManifest.xml` inside the `<manifest>` tag, **above** `<application>`.

```xml
<!-- Camera -->
<uses-permission android:name="android.permission.CAMERA" />

<!-- Photos / media (Android 13+) -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<!-- Pre-Android-13 fallback -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />

<!-- Location -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

<!-- Microphone -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />

<!-- Notifications (Android 13+) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

<!-- Storage (pre-Android-13) -->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />

<!-- Contacts -->
<uses-permission android:name="android.permission.READ_CONTACTS" />
```

> Only declare permissions your app actually uses. Google Play flags over-declared permissions.

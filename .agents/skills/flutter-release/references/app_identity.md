# App Identity — Name, Icon, Bundle ID

## App ID / Bundle Identifier

The app ID uniquely identifies your app on the store. **Set it once before first release — it cannot be changed later.**

**Android** — `android/app/build.gradle.kts`:

```kotlin
android {
    namespace = "com.example.myapp"
    defaultConfig {
        applicationId = "com.example.myapp"
        // ...
    }
}
```

**iOS** — `ios/Runner.xcodeproj` (or in Xcode → Runner → General → Bundle Identifier):

```
PRODUCT_BUNDLE_IDENTIFIER = com.example.myapp
```

**Naming convention**: `com.company.appname` — lowercase, no hyphens, no spaces.

Per-flavor bundle IDs (for separate store listings per environment):

```kotlin
// android/app/build.gradle.kts
productFlavors {
    create("dev")  { applicationId = "com.example.myapp.dev" }
    create("uat")  { applicationId = "com.example.myapp.uat" }
    create("prod") { applicationId = "com.example.myapp" }
}
```

---

## App Name

**Android** — `android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:label="My App"
    android:icon="@mipmap/ic_launcher">
```

Per-flavor app names (see [template-flavors.md](template-flavors.md)):

```kotlin
productFlavors {
    create("dev")  { resValue("string", "app_name", "My App [DEV]") }
    create("uat")  { resValue("string", "app_name", "My App [UAT]") }
    create("prod") { resValue("string", "app_name", "My App") }
}
```

Then in `AndroidManifest.xml`:

```xml
<application android:label="@string/app_name">
```

**iOS** — `ios/Runner/Info.plist`:

```xml
<key>CFBundleDisplayName</key>
<string>My App</string>
<key>CFBundleName</key>
<string>MyApp</string>
```

---

## App Icon — `flutter_launcher_icons`

Use `flutter_launcher_icons` to generate all icon sizes from a single master image.

**pubspec addition**:

```yaml
dev_dependencies:
  flutter_launcher_icons: 0.14.3
```

**`flutter_launcher_icons.yaml`** (project root):

```yaml
flutter_launcher_icons:
  # Master icon — 1024×1024 PNG, no transparency for iOS.
  image_path: "assets/icons/icon.png"

  # ── Android ──
  android: true
  min_sdk_android: 21
  # Adaptive icon (Android 8+): foreground + background.
  adaptive_icon_foreground: "assets/icons/icon-foreground.png"
  adaptive_icon_background: "#FFFFFF"
  # Round icon for older launchers.
  adaptive_icon_round: true

  # ── iOS ──
  ios: true
  # Remove the alpha channel (App Store rejects icons with transparency).
  remove_alpha_ios: true

  # ── Web (optional) ──
  web:
    generate: true
    image_path: "assets/icons/icon.png"
    background_color: "#FFFFFF"
    theme_color: "#000000"
```

**Generate icons**:

```bash
dart run flutter_launcher_icons
```

This generates:
- `android/app/src/main/res/mipmap-*` — All Android density buckets (mdpi to xxxhdpi)
- `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` — Adaptive icon
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/` — All iOS icon sizes
- Updates `Contents.json` automatically

### Icon design requirements

| Platform | Size | Shape | Notes |
|---|---|---|---|
| Android adaptive | 1024×1024 foreground | Circle/squircle (system decides) | Foreground centered in 66% safe zone |
| Android legacy | 1024×1024 | Square with rounded corners | Fallback for API < 26 |
| iOS | 1024×1024 | Squircle (system applies) | No transparency, no alpha channel |
| Play Store | 512×512 | 32px rounded corners | Upload to Play Console |
| App Store | 1024×1024 | No corners (Apple applies) | Upload in App Store Connect |

### Per-flavor icons

For different icons per environment (dev has a debug banner, prod is clean):

```yaml
# flutter_launcher_icons-dev.yaml
flutter_launcher_icons:
  image_path: "assets/icons/icon-dev.png"
  android: true
  ios: true

# flutter_launcher_icons-prod.yaml
flutter_launcher_icons:
  image_path: "assets/icons/icon.png"
  android: true
  ios: true
```

```bash
# Generate for specific flavor
dart run flutter_launcher_icons --flavor dev
dart run flutter_launcher_icons --flavor prod
```

---

## Native Splash Screen — `flutter_native_splash` (optional)

```yaml
dev_dependencies:
  flutter_native_splash: 2.4.5
```

**`flutter_native_splash.yaml`**:

```yaml
flutter_native_splash:
  color: "#FFFFFF"
  image: "assets/icons/splash-logo.png"
  android_12:
    color: "#FFFFFF"
    icon_background_color: "#FFFFFF"
    image: "assets/icons/splash-logo.png"
  ios: true
  web: false
```

```bash
dart run flutter_native_splash:create
```

**Remove splash after app loads** (in `main.dart` or bootstrap):

```dart
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // ... DI init, Firebase init, etc.

  FlutterNativeSplash.remove(); // Call when ready to show app.
  runApp(const App());
}
```

# Deep Linking

## Platform manifest configuration

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="https" android:host="example.com" />
</intent-filter>
```

```xml
<!-- ios/Runner/Info.plist -->
<key>FlutterDeepLinkingEnabled</key>
<true/>
```

## iOS Universal Links — Full Setup

```xml
<!-- ios/Runner/Runner.entitlements -->
<key>com.apple.developer.associated-domains</key>
<array>
  <string>applinks:example.com</string>
</array>
```

Host `apple-app-site-association` at `https://example.com/.well-known/apple-app-site-association`:

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.com.example.app",
        "paths": ["/posts/*", "/profile/*", "/settings"]
      }
    ]
  }
}
```

## Android App Links — Full Setup

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="https" android:host="example.com" />
</intent-filter>
```

Host `assetlinks.json` at `https://example.com/.well-known/assetlinks.json`:

```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.example.app",
    "sha256_cert_fingerprints": ["YOUR_SHA256_FINGERPRINT"]
  }
}]
```

## Custom Scheme (for dev/testing without domain verification)

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="myapp" android:host="open" />
</intent-filter>
```

```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>myapp</string>
    </array>
  </dict>
</array>
```

## Deep Link Store — Preserving Intent Through Auth

```dart
// lib/src/core/routing/deep_link_store.dart

/// Stores the intended deep link path when the user is redirected to sign-in.
/// After auth completes, consume the pending path and navigate there.
class DeepLinkStore {
  String? _pendingPath;

  /// Save the path the user intended to visit.
  void savePendingPath(String path) => _pendingPath = path;

  /// Consume and return the pending path (returns null if none).
  String? consumePendingPath() {
    final path = _pendingPath;
    _pendingPath = null;
    return path;
  }

  bool get hasPendingPath => _pendingPath != null;
}
```

Register as singleton in DI:

```dart
getIt.registerSingleton<DeepLinkStore>(DeepLinkStore());
```

Use in the auth guard redirect:

```dart
redirect: (context, state) {
  final isLoggedIn = getIt<AuthService>().isLoggedIn;
  final isOnSignIn = state.matchedLocation == RoutePaths.signIn;

  if (!isLoggedIn && !isOnSignIn) {
    getIt<DeepLinkStore>().savePendingPath(state.uri.toString());
    return RoutePaths.signIn;
  }

  if (isLoggedIn && isOnSignIn) {
    return getIt<DeepLinkStore>().consumePendingPath() ?? RoutePaths.home;
  }

  return null;
},
```

## Deep Link Testing

### Manual Testing — adb (Android)

```bash
# Test custom scheme
adb shell am start -a android.intent.action.VIEW \
  -d "myapp://open/posts/42" \
  com.example.app

# Test https App Links
adb shell am start -a android.intent.action.VIEW \
  -d "https://example.com/posts/42" \
  com.example.app

# Test cold start (kill app first)
adb shell am force-stop com.example.app
adb shell am start -a android.intent.action.VIEW \
  -d "https://example.com/posts/42" \
  com.example.app

# Verify App Links domain verification
adb shell pm get-app-links com.example.app
```

### Manual Testing — xcrun (iOS Simulator)

```bash
# Test custom scheme
xcrun simctl openurl booted "myapp://open/posts/42"

# Test Universal Links
xcrun simctl openurl booted "https://example.com/posts/42"

# Test cold start (kill app first, then open URL)
xcrun simctl terminate booted com.example.app
xcrun simctl openurl booted "https://example.com/posts/42"
```

### Deep Link Test Matrix

| Scenario | How to test | What to verify |
|---|---|---|
| Cold start (app killed) | Force-stop + open URL | Correct screen, data loaded |
| Warm start (app backgrounded) | Home + open URL | Navigates to correct screen |
| Unauthenticated | Log out + open URL | Redirects to sign-in, then to intended screen |
| Invalid path | Open `/nonexistent/path` | Falls back to home or 404 screen |
| Invalid param | Open `/posts/abc` (expects int) | Graceful error, no crash |
| Query params | Open with `?tab=2&ref=push` | Params parsed correctly |

### Unit Tests — DeepLinkStore

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app/src/core/routing/deep_link_store.dart';

void main() {
  late DeepLinkStore store;

  setUp(() => store = DeepLinkStore());

  test('initially has no pending path', () {
    expect(store.hasPendingPath, isFalse);
    expect(store.consumePendingPath(), isNull);
  });

  test('savePendingPath stores the path', () {
    store.savePendingPath('/posts/42');
    expect(store.hasPendingPath, isTrue);
  });

  test('consumePendingPath returns and clears', () {
    store.savePendingPath('/posts/42');
    expect(store.consumePendingPath(), '/posts/42');
    expect(store.hasPendingPath, isFalse);
    expect(store.consumePendingPath(), isNull);
  });

  test('latest savePendingPath wins', () {
    store.savePendingPath('/posts/1');
    store.savePendingPath('/profile');
    expect(store.consumePendingPath(), '/profile');
  });
}
```

### CI Deep Link Smoke Test Script

```bash
#!/bin/bash
# scripts/test_deep_links.sh
set -e

PACKAGE="com.example.app"
LINKS=(
  "myapp://open/posts/42"
  "myapp://open/profile"
  "myapp://open/settings"
  "https://example.com/posts/42"
  "https://example.com/profile"
)

echo "=== Deep Link Smoke Tests ==="

for link in "${LINKS[@]}"; do
  echo "Testing: $link"
  adb shell am start -a android.intent.action.VIEW -d "$link" "$PACKAGE"
  sleep 3

  if ! adb shell pidof "$PACKAGE" > /dev/null 2>&1; then
    echo "FAIL: App crashed on $link"
    exit 1
  fi

  echo "PASS: $link"
  adb shell input keyevent KEYCODE_BACK
  sleep 1
done

echo "=== All deep link smoke tests passed ==="
```

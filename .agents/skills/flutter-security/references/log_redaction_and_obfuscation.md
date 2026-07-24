# Log Redaction and Obfuscation

## Log Redaction

Sensitive fields must never appear in log output.

```dart
// lib/src/core/network/logging_interceptor.dart
final class LoggingInterceptor extends Interceptor {
  static final _sensitiveFields = RegExp(
    r'"(password|token|refresh_token|access_token|api_key|secret|cvv|card_number)"'
    r'\s*:\s*"[^"]*"',
    caseSensitive: false,
  );

  String _redact(String? body) {
    if (body == null || body.isEmpty) return '';
    return body.replaceAllMapped(
      _sensitiveFields,
      (m) => '"${m.group(1)}":"[REDACTED]"',
    );
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.debug('[REQ] ${options.method} ${options.path} '
        'body=${_redact(options.data?.toString())}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.debug('[RES] ${response.statusCode} '
        'body=${_redact(response.data?.toString())}');
    handler.next(response);
  }
}
```

### Rules

- Redact before logging — never log and redact after.
- Redact in both request (body) and response (body).
- Never log headers containing `Authorization` or `Cookie`.

```dart
// Also strip auth headers from logs
final safeHeaders = Map<String, dynamic>.from(options.headers)
  ..remove('Authorization')
  ..remove('Cookie');
logger.debug('[REQ] headers=${safeHeaders}');
```

## Obfuscation & Binary Protection

### Release build flags (required)

```bash
# Android APK
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/debug-info/android

# Android AAB
flutter build appbundle --release \
  --obfuscate \
  --split-debug-info=build/debug-info/android

# iOS
flutter build ipa --release \
  --obfuscate \
  --split-debug-info=build/debug-info/ios
```

Upload `build/debug-info/` to CI as an artifact — needed for symbolication of production crashes.

### ProGuard / R8 rules (`android/app/proguard-rules.pro`)

```pro
# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep JNI-called methods
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Retrofit / Gson (if used)
-keepattributes Signature
-keepattributes *Annotation*
```

### `android/app/build.gradle.kts` — enable minification

```kotlin
buildTypes {
    release {
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```

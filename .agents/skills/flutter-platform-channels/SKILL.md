---
name: flutter-platform-channels
description: Use this skill when implementing Flutter platform channels — MethodChannel, EventChannel, BasicMessageChannel, native Kotlin/Android code, native Swift/iOS code, calling native APIs from Flutter, receiving native events, platform-specific functionality, or bridging Flutter and native platform code.
---

# Flutter Platform Channels

Full reference: [`template.md`](references/template.md)

## Key rules

- `PlatformChannelService` wraps **all** platform channel calls. **Never use `MethodChannel`, `EventChannel`, or `BasicMessageChannel` directly** outside `platform_channel_service_impl.dart`.
- Channel naming: `com.yourcompany.appname/feature` (reverse-domain + feature path). Consistent across Dart, Kotlin, Swift.
- Failures: channel errors (e.g., method not found, exception in native) are mapped to `PlatformChannelFailure` → wrapped in `FailureException(UnknownFailure(...))` at the repository.
- Null-safety: native return values are `Object?` — always null-check and cast defensively.
- `EventChannel` provides a broadcast stream — wrap it in `PlatformChannelService.sensorStream()` and expose as `Stream<T>`.
- Native handlers: Kotlin in `MainActivity.kt` or separate `FlutterPlugin`. Swift in `AppDelegate.swift` or separate plugin.
- Test with mocks: `TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(...)`.

## Files

```
lib/src/core/platform/
  platform_channel_service.dart         ← interface
  platform_channel_service_impl.dart    ← only file using MethodChannel/EventChannel
  platform_channel_failure.dart         ← PlatformChannelFailure type
android/app/src/main/kotlin/…/MainActivity.kt   ← Kotlin handlers
ios/Runner/AppDelegate.swift                    ← Swift handlers
```

## Co-load with

- `flutter-di` — register `PlatformChannelService` as lazySingleton
- `flutter-network` — `PlatformChannelFailure` → `FailureException(UnknownFailure(...))`

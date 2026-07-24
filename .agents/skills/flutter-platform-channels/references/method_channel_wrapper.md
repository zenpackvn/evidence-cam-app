# MethodChannel Wrapper

App-owned interface and implementation for platform method calls. Only `*_impl.dart` files import `package:flutter/services.dart`. All other layers depend on the app-owned interfaces.

## Folder Structure

```text
lib/src/core/
  platform/
    platform_channel_service.dart          ← App-owned interface for method calls
    platform_channel_service_impl.dart     ← Wraps MethodChannel (only import)
    event_channel_service.dart             ← App-owned interface for event streams
    event_channel_service_impl.dart        ← Wraps EventChannel (only import)
    platform_codec.dart                    ← App-owned codec helpers (optional)
    channel_names.dart                     ← Channel name constants (single source of truth)
    platform_channel_failure.dart          ← Typed failure for platform errors

android/app/src/main/kotlin/.../
  channels/
    AppMethodChannelHandler.kt             ← Kotlin side of method channels
    AppEventChannelHandler.kt              ← Kotlin side of event channels

ios/Runner/
  Channels/
    AppMethodChannelHandler.swift          ← Swift side of method channels
    AppEventChannelHandler.swift           ← Swift side of event channels
```

---

## `lib/src/core/platform/platform_channel_service.dart`

```dart
/// App-owned interface for platform method calls.
/// No Flutter services import leaks past this boundary.
abstract interface class PlatformChannelService {
  /// Invoke a method on the native side and return the result.
  Future<T?> invokeMethod<T>(String method, [dynamic arguments]);

  /// Check if a method is available on the native side.
  Future<bool> isMethodAvailable(String method);
}
```

---

## `lib/src/core/platform/platform_channel_service_impl.dart`

```dart
import 'package:flutter/services.dart'; // ← ONLY file that imports this

import 'platform_channel_service.dart';

/// Wraps [MethodChannel] behind the app-owned [PlatformChannelService].
class PlatformChannelServiceImpl implements PlatformChannelService {
  PlatformChannelServiceImpl({
    required String channelName,
    MethodCodec codec = const StandardMethodCodec(),
  }) : _channel = MethodChannel(channelName, codec);

  final MethodChannel _channel;

  @override
  Future<T?> invokeMethod<T>(String method, [dynamic arguments]) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on PlatformException catch (e) {
      throw PlatformChannelFailure(
        code: e.code,
        message: e.message,
        details: e.details,
      );
    } on MissingPluginException {
      throw PlatformChannelFailure(
        code: 'MISSING_PLUGIN',
        message: 'No implementation found for method "$method" '
            'on channel "${_channel.name}"',
      );
    }
  }

  @override
  Future<bool> isMethodAvailable(String method) async {
    try {
      await _channel.invokeMethod<void>(method);
      return true;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      // Method exists but may have failed — still "available"
      return true;
    }
  }

  /// Register a handler for calls FROM native → Dart.
  void setMethodCallHandler(
    Future<dynamic> Function(String method, dynamic arguments)? handler,
  ) {
    if (handler == null) {
      _channel.setMethodCallHandler(null);
      return;
    }
    _channel.setMethodCallHandler((call) => handler(call.method, call.arguments));
  }
}
```

---

## `lib/src/core/platform/platform_channel_failure.dart`

```dart
/// Typed failure for platform channel errors.
/// Sits in the app's Failure hierarchy (see template-network.md).
class PlatformChannelFailure implements Exception {
  const PlatformChannelFailure({
    required this.code,
    this.message,
    this.details,
  });

  final String code;
  final String? message;
  final dynamic details;

  @override
  String toString() => 'PlatformChannelFailure($code: $message)';
}
```

---

## Channel Name Constants

Define all channel names in a single file to avoid duplication across Dart, Kotlin, and Swift:

```dart
// lib/src/core/platform/channel_names.dart
abstract final class ChannelNames {
  static const battery = 'com.example.app/battery';
  static const sensors = 'com.example.app/sensors';
  static const config = 'com.example.app/config';
}
```

Use reverse-domain notation matching your app's package:

```text
com.example.app/battery          ← MethodChannel
com.example.app/sensors          ← EventChannel
com.example.app/config           ← BasicMessageChannel
com.example.app/feature/payment  ← Feature-scoped channel
```

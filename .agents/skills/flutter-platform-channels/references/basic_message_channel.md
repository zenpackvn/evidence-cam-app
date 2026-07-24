# BasicMessageChannel — Structured Messaging

For structured data exchange (JSON, binary) use `BasicMessageChannel`. Only `*_impl.dart` files import `package:flutter/services.dart`.

## `lib/src/core/platform/basic_message_service.dart`

```dart
/// App-owned interface for structured message passing.
abstract interface class BasicMessageService<T> {
  /// Send a structured message and receive a reply.
  Future<T?> send(T message);

  /// Listen for messages from the native side.
  void setMessageHandler(Future<T?> Function(T? message)? handler);
}
```

## `lib/src/core/platform/basic_message_service_impl.dart`

```dart
import 'package:flutter/services.dart'; // ← ONLY file that imports this

import 'basic_message_service.dart';

/// Wraps [BasicMessageChannel] behind [BasicMessageService].
class BasicMessageServiceImpl<T> implements BasicMessageService<T> {
  BasicMessageServiceImpl({
    required String channelName,
    required MessageCodec<T> codec,
  }) : _channel = BasicMessageChannel<T>(channelName, codec);

  final BasicMessageChannel<T> _channel;

  @override
  Future<T?> send(T message) => _channel.send(message);

  @override
  void setMessageHandler(Future<T?> Function(T? message)? handler) {
    _channel.setMessageHandler(handler);
  }
}
```

## Codec Selection

| Codec | Use When |
|---|---|
| `StandardMethodCodec` (default) | Simple types: int, String, bool, List, Map |
| `JSONMethodCodec` | Complex maps/structures |
| `BasicMessageChannel` + `JSONMessageCodec` | Structured bidirectional messaging |

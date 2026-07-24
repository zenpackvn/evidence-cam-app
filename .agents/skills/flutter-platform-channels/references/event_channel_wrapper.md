# EventChannel Wrapper

App-owned interface and implementation for native → Dart event streams. Only `event_channel_service_impl.dart` imports `package:flutter/services.dart`.

## `lib/src/core/platform/event_channel_service.dart`

```dart
/// App-owned interface for native → Dart event streams.
/// No Flutter services import leaks past this boundary.
abstract interface class EventChannelService {
  /// Listen to a continuous stream of events from the native side.
  Stream<T> receiveEvents<T>({
    T Function(dynamic event)? decoder,
  });

  /// Cancel the native stream.
  void dispose();
}
```

---

## `lib/src/core/platform/event_channel_service_impl.dart`

```dart
import 'dart:async';

import 'package:flutter/services.dart'; // ← ONLY file that imports this

import 'event_channel_service.dart';
import 'platform_channel_failure.dart';

/// Wraps [EventChannel] behind the app-owned [EventChannelService].
class EventChannelServiceImpl implements EventChannelService {
  EventChannelServiceImpl({
    required String channelName,
    MethodCodec codec = const StandardMethodCodec(),
  }) : _channel = EventChannel(channelName, codec);

  final EventChannel _channel;
  StreamSubscription<dynamic>? _subscription;

  @override
  Stream<T> receiveEvents<T>({
    T Function(dynamic event)? decoder,
  }) {
    return _channel.receiveBroadcastStream().map<T>((event) {
      if (decoder != null) return decoder(event);
      return event as T;
    }).handleError((Object error) {
      if (error is PlatformException) {
        throw PlatformChannelFailure(
          code: error.code,
          message: error.message,
          details: error.details,
        );
      }
      throw error;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
```

---

## EventChannel Feature Usage — Sensor Stream

### `lib/src/features/sensors/data/sensor_repository.dart`

```dart
import '../../../core/platform/event_channel_service.dart';

abstract interface class SensorRepository {
  Stream<SensorReading> accelerometerStream();
}

class SensorRepositoryImpl implements SensorRepository {
  const SensorRepositoryImpl({required this.eventChannel});

  final EventChannelService eventChannel;

  @override
  Stream<SensorReading> accelerometerStream() {
    return eventChannel.receiveEvents<SensorReading>(
      decoder: (event) {
        final map = Map<String, dynamic>.from(event as Map);
        return SensorReading(
          x: (map['x'] as num).toDouble(),
          y: (map['y'] as num).toDouble(),
          z: (map['z'] as num).toDouble(),
        );
      },
    );
  }
}

class SensorReading {
  const SensorReading({required this.x, required this.y, required this.z});
  final double x;
  final double y;
  final double z;
}
```

### `lib/src/features/sensors/presentation/sensor_cubit.dart`

```dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/sensor_repository.dart';

class SensorCubit extends Cubit<SensorState> {
  SensorCubit({required this.sensorRepository}) : super(const SensorDisconnected());

  final SensorRepository sensorRepository;
  StreamSubscription<SensorReading>? _subscription;

  void startListening() {
    emit(const SensorConnecting());
    _subscription = sensorRepository.accelerometerStream().listen(
      (reading) => emit(SensorActive(reading: reading)),
      onError: (Object error) => emit(SensorError(message: error.toString())),
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    emit(const SensorDisconnected());
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

sealed class SensorState {
  const SensorState();
}

class SensorDisconnected extends SensorState {
  const SensorDisconnected();
}

class SensorConnecting extends SensorState {
  const SensorConnecting();
}

class SensorActive extends SensorState {
  const SensorActive({required this.reading});
  final SensorReading reading;
}

class SensorError extends SensorState {
  const SensorError({required this.message});
  final String message;
}
```

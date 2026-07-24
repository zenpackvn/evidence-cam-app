# DI Registration and Feature Usage

## DI Registration — `lib/src/core/di/platform_module.dart`

```dart
import 'package:get_it/get_it.dart';

import '../platform/platform_channel_service.dart';
import '../platform/platform_channel_service_impl.dart';
import '../platform/event_channel_service.dart';
import '../platform/event_channel_service_impl.dart';

void registerPlatformModule(GetIt di) {
  // ── Battery example ──
  di.registerLazySingleton<PlatformChannelService>(
    () => PlatformChannelServiceImpl(
      channelName: 'com.example.app/battery',
    ),
    instanceName: 'battery',
  );

  // ── Sensor stream example ──
  di.registerLazySingleton<EventChannelService>(
    () => EventChannelServiceImpl(
      channelName: 'com.example.app/sensors',
    ),
    instanceName: 'sensors',
  );
}
```

## Named Instances Pattern

When an app has multiple channels (battery, sensors, device info, etc.), use `instanceName` in DI:

```dart
// Registration
di.registerLazySingleton<PlatformChannelService>(
  () => PlatformChannelServiceImpl(channelName: 'com.example.app/battery'),
  instanceName: 'battery',
);
di.registerLazySingleton<PlatformChannelService>(
  () => PlatformChannelServiceImpl(channelName: 'com.example.app/device_info'),
  instanceName: 'deviceInfo',
);

// Injection — pass named instance to consumer
di.registerFactory<BatteryRepository>(
  () => BatteryRepositoryImpl(
    platformChannel: di<PlatformChannelService>(instanceName: 'battery'),
  ),
);
```

---

## Feature-Level Usage — Battery Example

### `lib/src/features/battery/data/battery_repository.dart`

```dart
import '../../../core/platform/platform_channel_service.dart';

abstract interface class BatteryRepository {
  Future<int> getBatteryLevel();
}

class BatteryRepositoryImpl implements BatteryRepository {
  const BatteryRepositoryImpl({required this.platformChannel});

  final PlatformChannelService platformChannel;

  @override
  Future<int> getBatteryLevel() async {
    final level = await platformChannel.invokeMethod<int>('getBatteryLevel');
    return level ?? -1;
  }
}
```

### `lib/src/features/battery/presentation/battery_cubit.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/battery_repository.dart';
import '../../../core/platform/platform_channel_failure.dart';

class BatteryCubit extends Cubit<BatteryState> {
  BatteryCubit({required this.batteryRepository}) : super(const BatteryInitial());

  final BatteryRepository batteryRepository;

  Future<void> fetchBatteryLevel() async {
    emit(const BatteryLoading());
    try {
      final level = await batteryRepository.getBatteryLevel();
      emit(BatteryLoaded(level: level));
    } on PlatformChannelFailure catch (e) {
      emit(BatteryError(message: e.message ?? 'Unknown error'));
    }
  }
}

sealed class BatteryState {
  const BatteryState();
}

class BatteryInitial extends BatteryState {
  const BatteryInitial();
}

class BatteryLoading extends BatteryState {
  const BatteryLoading();
}

class BatteryLoaded extends BatteryState {
  const BatteryLoaded({required this.level});
  final int level;
}

class BatteryError extends BatteryState {
  const BatteryError({required this.message});
  final String message;
}
```

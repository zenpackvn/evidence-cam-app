# Testing Platform Channels

Mock the app-owned interface (`PlatformChannelService`), not the `MethodChannel` directly. Use `setMockMethodCallHandler` only in widget/integration tests that need real channel behavior.

## Unit Test — PlatformChannelService Mock

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/src/core/platform/platform_channel_service.dart';
import 'package:app/src/features/battery/data/battery_repository.dart';

class MockPlatformChannelService extends Mock implements PlatformChannelService {}

void main() {
  late MockPlatformChannelService mockChannel;
  late BatteryRepositoryImpl repository;

  setUp(() {
    mockChannel = MockPlatformChannelService();
    repository = BatteryRepositoryImpl(platformChannel: mockChannel);
  });

  test('getBatteryLevel returns level from platform', () async {
    when(() => mockChannel.invokeMethod<int>('getBatteryLevel'))
        .thenAnswer((_) async => 85);

    final level = await repository.getBatteryLevel();
    expect(level, 85);
  });

  test('getBatteryLevel returns -1 when null', () async {
    when(() => mockChannel.invokeMethod<int>('getBatteryLevel'))
        .thenAnswer((_) async => null);

    final level = await repository.getBatteryLevel();
    expect(level, -1);
  });
}
```

## Widget Test — MethodChannel Fake

```dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const channel = MethodChannel('com.example.app/battery');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getBatteryLevel') return 42;
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('battery channel returns mocked value', () async {
    final result = await channel.invokeMethod<int>('getBatteryLevel');
    expect(result, 42);
  });
}
```

## Bloc Test — BatteryCubit

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/src/features/battery/data/battery_repository.dart';
import 'package:app/src/features/battery/presentation/battery_cubit.dart';

class MockBatteryRepository extends Mock implements BatteryRepository {}

void main() {
  late MockBatteryRepository mockRepo;

  setUp(() => mockRepo = MockBatteryRepository());

  blocTest<BatteryCubit, BatteryState>(
    'emits [loading, loaded] on success',
    build: () {
      when(() => mockRepo.getBatteryLevel()).thenAnswer((_) async => 85);
      return BatteryCubit(batteryRepository: mockRepo);
    },
    act: (cubit) => cubit.fetchBatteryLevel(),
    expect: () => [
      isA<BatteryLoading>(),
      isA<BatteryLoaded>().having((s) => s.level, 'level', 85),
    ],
  );

  blocTest<BatteryCubit, BatteryState>(
    'emits [loading, error] on PlatformChannelFailure',
    build: () {
      when(() => mockRepo.getBatteryLevel())
          .thenThrow(const PlatformChannelFailure(code: 'UNAVAILABLE'));
      return BatteryCubit(batteryRepository: mockRepo);
    },
    act: (cubit) => cubit.fetchBatteryLevel(),
    expect: () => [
      isA<BatteryLoading>(),
      isA<BatteryError>(),
    ],
  );
}
```

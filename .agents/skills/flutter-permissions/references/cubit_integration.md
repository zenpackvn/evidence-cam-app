# Cubit Integration

Full cubit pattern for managing permission state: state definitions, cubit logic, page wiring, and tests.

## `lib/src/features/camera/presentation/cubit/camera_permission_state.dart`

```dart
import 'package:equatable/equatable.dart';

import '../../../../core/permissions/app_permission_status.dart';

sealed class CameraPermissionState extends Equatable {
  const CameraPermissionState();

  @override
  List<Object?> get props => const [];
}

class CameraPermissionInitial extends CameraPermissionState {
  const CameraPermissionInitial();
}

class CameraPermissionChecking extends CameraPermissionState {
  const CameraPermissionChecking();
}

class CameraPermissionGranted extends CameraPermissionState {
  const CameraPermissionGranted();
}

class CameraPermissionDenied extends CameraPermissionState {
  const CameraPermissionDenied({required this.status});
  final AppPermissionStatus status;

  @override
  List<Object?> get props => [status];
}
```

## `lib/src/features/camera/presentation/cubit/camera_permission_cubit.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/permissions/app_permission.dart';
import '../../../../core/permissions/app_permission_status.dart';
import '../../../../core/permissions/permission_service.dart';
import 'camera_permission_state.dart';

class CameraPermissionCubit extends Cubit<CameraPermissionState> {
  CameraPermissionCubit({required PermissionService permissionService})
      : _permissionService = permissionService,
        super(const CameraPermissionInitial());

  final PermissionService _permissionService;

  /// Check the current camera permission status without prompting.
  Future<void> checkPermission() async {
    emit(const CameraPermissionChecking());

    final status = await _permissionService.check(AppPermission.camera);

    if (status == AppPermissionStatus.granted) {
      emit(const CameraPermissionGranted());
    } else {
      emit(CameraPermissionDenied(status: status));
    }
  }

  /// Request camera permission from the user.
  Future<void> requestCamera() async {
    emit(const CameraPermissionChecking());

    final status = await _permissionService.request(AppPermission.camera);

    if (status == AppPermissionStatus.granted) {
      emit(const CameraPermissionGranted());
    } else {
      emit(CameraPermissionDenied(status: status));
    }
  }

  /// Open OS settings. Call when status is [AppPermissionStatus.permanentlyDenied].
  Future<void> openSettings() async {
    await _permissionService.openAppSettings();
    // Re-check after user returns from Settings.
    await checkPermission();
  }
}
```

## Cubit Usage in a Page

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/permissions/app_permission_status.dart';
import '../../../core/permissions/permission_service.dart';
import 'cubit/camera_permission_cubit.dart';
import 'cubit/camera_permission_state.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CameraPermissionCubit(
        permissionService: getIt<PermissionService>(),
      )..checkPermission(),
      child: const _CameraView(),
    );
  }
}

class _CameraView extends StatelessWidget {
  const _CameraView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      body: BlocBuilder<CameraPermissionCubit, CameraPermissionState>(
        builder: (context, state) => switch (state) {
          CameraPermissionInitial() ||
          CameraPermissionChecking() =>
            const Center(child: CircularProgressIndicator()),
          CameraPermissionGranted() => const Center(
              child: Text('Camera access granted — show viewfinder here.'),
            ),
          CameraPermissionDenied(:final status) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    status == AppPermissionStatus.permanentlyDenied
                        ? 'Camera access denied. Please enable it in Settings.'
                        : 'Camera access is needed to take photos.',
                  ),
                  const SizedBox(height: 16),
                  if (status == AppPermissionStatus.permanentlyDenied)
                    FilledButton(
                      onPressed: () => context
                          .read<CameraPermissionCubit>()
                          .openSettings(),
                      child: const Text('Open Settings'),
                    )
                  else
                    FilledButton(
                      onPressed: () => context
                          .read<CameraPermissionCubit>()
                          .requestCamera(),
                      child: const Text('Grant Camera Access'),
                    ),
                ],
              ),
            ),
        },
      ),
    );
  }
}
```

## Cubit Test

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/src/core/permissions/app_permission.dart';
import 'package:my_app/src/core/permissions/app_permission_status.dart';
import 'package:my_app/src/features/camera/presentation/cubit/camera_permission_cubit.dart';
import 'package:my_app/src/features/camera/presentation/cubit/camera_permission_state.dart';

import '../../../../helpers/fake_permission_service.dart';

void main() {
  late FakePermissionService fakePermissions;

  setUp(() {
    fakePermissions = FakePermissionService();
  });

  CameraPermissionCubit buildCubit() => CameraPermissionCubit(
        permissionService: fakePermissions,
      );

  group('CameraPermissionCubit', () {
    blocTest<CameraPermissionCubit, CameraPermissionState>(
      'emits [checking, granted] when camera is already granted',
      setUp: () => fakePermissions.grant(AppPermission.camera),
      build: buildCubit,
      act: (cubit) => cubit.checkPermission(),
      expect: () => const [
        CameraPermissionChecking(),
        CameraPermissionGranted(),
      ],
    );

    blocTest<CameraPermissionCubit, CameraPermissionState>(
      'emits [checking, denied] when camera is denied',
      build: buildCubit,
      act: (cubit) => cubit.checkPermission(),
      expect: () => const [
        CameraPermissionChecking(),
        CameraPermissionDenied(status: AppPermissionStatus.denied),
      ],
    );

    blocTest<CameraPermissionCubit, CameraPermissionState>(
      'emits [checking, granted] after user grants request',
      setUp: () => fakePermissions.grant(AppPermission.camera),
      build: buildCubit,
      act: (cubit) => cubit.requestCamera(),
      expect: () => const [
        CameraPermissionChecking(),
        CameraPermissionGranted(),
      ],
      verify: (_) {
        expect(
          fakePermissions.requestLog,
          contains(AppPermission.camera),
        );
      },
    );

    blocTest<CameraPermissionCubit, CameraPermissionState>(
      'openSettings opens settings then re-checks',
      setUp: () => fakePermissions.grant(AppPermission.camera),
      build: buildCubit,
      act: (cubit) => cubit.openSettings(),
      expect: () => const [
        CameraPermissionChecking(),
        CameraPermissionGranted(),
      ],
      verify: (_) {
        expect(fakePermissions.didOpenSettings, isTrue);
      },
    );
  });
}
```

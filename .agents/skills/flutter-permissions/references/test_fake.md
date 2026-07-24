# Test Fake — FakePermissionService

In-memory fake for tests. Configure per-permission status before acting. Never depend on real device permissions in unit or widget tests.

## `test/helpers/fake_permission_service.dart`

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/src/core/permissions/app_permission.dart';
import 'package:my_app/src/core/permissions/app_permission_status.dart';
import 'package:my_app/src/core/permissions/permission_service.dart';

/// In-memory fake for tests. Configure per-permission status before acting.
class FakePermissionService implements PermissionService {
  /// Pre-configured status for each permission. Defaults to [AppPermissionStatus.denied].
  final Map<AppPermission, AppPermissionStatus> statusMap = {};

  /// Whether [shouldShowRationale] returns `true` for a permission.
  final Set<AppPermission> rationalePermissions = {};

  /// Tracks every call to [request] for assertions.
  final List<AppPermission> requestLog = [];

  /// Whether [openAppSettings] was called.
  bool didOpenSettings = false;

  @override
  Future<AppPermissionStatus> check(AppPermission permission) async =>
      statusMap[permission] ?? AppPermissionStatus.denied;

  @override
  Future<AppPermissionStatus> request(AppPermission permission) async {
    requestLog.add(permission);
    return statusMap[permission] ?? AppPermissionStatus.denied;
  }

  @override
  Future<Map<AppPermission, AppPermissionStatus>> requestMultiple(
    List<AppPermission> permissions,
  ) async {
    requestLog.addAll(permissions);
    return {
      for (final p in permissions)
        p: statusMap[p] ?? AppPermissionStatus.denied,
    };
  }

  @override
  Future<bool> openAppSettings() async {
    didOpenSettings = true;
    return true;
  }

  @override
  Future<bool> shouldShowRationale(AppPermission permission) async =>
      rationalePermissions.contains(permission);

  /// Grant a permission in the fake (simulates the user tapping "Allow").
  void grant(AppPermission permission) {
    statusMap[permission] = AppPermissionStatus.granted;
  }

  /// Deny a permission in the fake.
  void deny(AppPermission permission) {
    statusMap[permission] = AppPermissionStatus.denied;
  }

  /// Permanently deny a permission in the fake.
  void permanentlyDeny(AppPermission permission) {
    statusMap[permission] = AppPermissionStatus.permanentlyDenied;
  }

  /// Reset all state.
  void reset() {
    statusMap.clear();
    rationalePermissions.clear();
    requestLog.clear();
    didOpenSettings = false;
  }
}
```

## Usage in Tests

```dart
late FakePermissionService fakePermissions;

setUp(() {
  fakePermissions = FakePermissionService();
  getIt.registerSingleton<PermissionService>(fakePermissions);
});

tearDown(() => getIt.reset());

test('cubit emits granted when camera is allowed', () async {
  fakePermissions.grant(AppPermission.camera);

  final cubit = CameraPermissionCubit(
    permissionService: getIt<PermissionService>(),
  );

  await cubit.requestCamera();

  expect(cubit.state, const CameraPermissionGranted());
  expect(fakePermissions.requestLog, contains(AppPermission.camera));
});
```

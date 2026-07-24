# Permission Service Implementation

Concrete implementation of `PermissionService` backed by `package:permission_handler`. This is the only file that imports the third-party package.

## `lib/src/core/permissions/permission_service_impl.dart`

```dart
import 'package:permission_handler/permission_handler.dart' as pkg;

import 'app_permission.dart';
import 'app_permission_status.dart';
import 'permission_service.dart';

/// Concrete implementation backed by `package:permission_handler`.
///
/// This is the **only** file that imports the third-party package.
class PermissionServiceImpl implements PermissionService {
  // ---------------------------------------------------------------------------
  // Mapping helpers
  // ---------------------------------------------------------------------------

  static pkg.Permission _toPackagePermission(AppPermission p) => switch (p) {
        AppPermission.camera => pkg.Permission.camera,
        AppPermission.photos => pkg.Permission.photos,
        AppPermission.location => pkg.Permission.location,
        AppPermission.locationAlways => pkg.Permission.locationAlways,
        AppPermission.notifications => pkg.Permission.notification,
        AppPermission.microphone => pkg.Permission.microphone,
        AppPermission.storage => pkg.Permission.storage,
        AppPermission.contacts => pkg.Permission.contacts,
      };

  static AppPermissionStatus _fromPackageStatus(pkg.PermissionStatus s) {
    if (s.isGranted) return AppPermissionStatus.granted;
    if (s.isPermanentlyDenied) return AppPermissionStatus.permanentlyDenied;
    if (s.isRestricted) return AppPermissionStatus.restricted;
    if (s.isLimited) return AppPermissionStatus.limited;
    return AppPermissionStatus.denied;
  }

  // ---------------------------------------------------------------------------
  // PermissionService
  // ---------------------------------------------------------------------------

  @override
  Future<AppPermissionStatus> check(AppPermission permission) async {
    final status = await _toPackagePermission(permission).status;
    return _fromPackageStatus(status);
  }

  @override
  Future<AppPermissionStatus> request(AppPermission permission) async {
    final status = await _toPackagePermission(permission).request();
    return _fromPackageStatus(status);
  }

  @override
  Future<Map<AppPermission, AppPermissionStatus>> requestMultiple(
    List<AppPermission> permissions,
  ) async {
    final pkgPermissions = permissions.map(_toPackagePermission).toList();
    final results = await pkgPermissions.request();

    final mapped = <AppPermission, AppPermissionStatus>{};
    for (final permission in permissions) {
      final pkgPerm = _toPackagePermission(permission);
      final status = results[pkgPerm];
      mapped[permission] = status != null
          ? _fromPackageStatus(status)
          : AppPermissionStatus.denied;
    }
    return mapped;
  }

  @override
  Future<bool> openAppSettings() => pkg.openAppSettings();

  @override
  Future<bool> shouldShowRationale(AppPermission permission) =>
      _toPackagePermission(permission).shouldShowRequestRationale;
}
```

## DI Registration

Add to `service_locator.dart` in the core services section (after logging, before network):

```dart
import '../permissions/permission_service.dart';
import '../permissions/permission_service_impl.dart';

// Inside configureDependencies():
getIt.registerLazySingleton<PermissionService>(PermissionServiceImpl.new);
```

# Permission Service Interface

App-owned types and interface for runtime permission handling. Only `permission_service_impl.dart` imports `package:permission_handler`. All feature code depends exclusively on these app-owned types.

## Folder Structure

```text
lib/src/core/
  permissions/
    permission_service.dart          <- App-owned permission interface
    permission_service_impl.dart     <- Wraps permission_handler (only import)
    app_permission.dart              <- App-owned permission type enum
    app_permission_status.dart       <- App-owned status enum
```

## pubspec.yaml additions

```yaml
dependencies:
  permission_handler: 11.3.1
```

---

## `lib/src/core/permissions/app_permission.dart`

```dart
/// App-owned permission type.
///
/// Feature code uses this enum exclusively.
/// The mapping to `package:permission_handler` lives only in
/// `permission_service_impl.dart`.
enum AppPermission {
  camera,
  photos,
  location,
  locationAlways,
  notifications,
  microphone,
  storage,
  contacts,
}
```

## `lib/src/core/permissions/app_permission_status.dart`

```dart
/// App-owned permission status.
///
/// Feature code pattern-matches on this enum.
/// The mapping from `package:permission_handler`'s `PermissionStatus` lives
/// only in `permission_service_impl.dart`.
enum AppPermissionStatus {
  /// The user granted the permission.
  granted,

  /// The user denied the permission (can still request again).
  denied,

  /// The user denied the permission and selected "Don't ask again" (Android)
  /// or the permission is restricted by policy (iOS).
  permanentlyDenied,

  /// The OS restricts access (e.g. parental controls on iOS).
  restricted,

  /// The user granted limited access (e.g. selected photos on iOS 14+).
  limited,
}
```

## `lib/src/core/permissions/permission_service.dart`

```dart
import 'app_permission.dart';
import 'app_permission_status.dart';

/// App-owned permission service interface.
///
/// Inject via DI — never instantiate the impl directly in feature code.
abstract interface class PermissionService {
  /// Check the current status of [permission] without prompting the user.
  Future<AppPermissionStatus> check(AppPermission permission);

  /// Request [permission] from the user. Returns the resulting status.
  Future<AppPermissionStatus> request(AppPermission permission);

  /// Request multiple permissions at once. Returns a map of each permission
  /// to its resulting status.
  Future<Map<AppPermission, AppPermissionStatus>> requestMultiple(
    List<AppPermission> permissions,
  );

  /// Open the OS app-settings page so the user can manually toggle
  /// permissions. Returns `true` if the settings page was opened.
  Future<bool> openAppSettings();

  /// Whether the OS recommends showing a rationale dialog before requesting
  /// [permission]. Always returns `false` on iOS.
  Future<bool> shouldShowRationale(AppPermission permission);
}
```

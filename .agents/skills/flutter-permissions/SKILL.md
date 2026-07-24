---
name: flutter-permissions
description: Use this skill when working on Flutter app permissions — camera permission, location permission, notification permission, microphone permission, contacts permission, storage permission, permission_handler wrapper, PermissionService, permission rationale dialogs, permanently denied handling, or requesting any device permission.
---

# Flutter Permissions

Full reference: [`template.md`](references/template.md)

## Key rules

- `PermissionService` is the app-owned interface. **Never import `permission_handler`** outside `permission_service_impl.dart`.
- Permission request flow:
  1. `check(permission)` — if `granted`, proceed immediately.
  2. `shouldShowRationale(permission)` — if `true`, show explanation dialog first (Android only).
  3. `request(permission)` — if result is `permanentlyDenied`, call `openAppSettings()`.
- All feature code uses `AppPermission` enum — never reference `permission_handler` types.
- Platform config: `AndroidManifest.xml` `<uses-permission>` entries + iOS `Info.plist` usage description keys — **both required** or the request will fail silently.
- Never call `permission_handler` APIs from widgets — always via `PermissionService` injected into a cubit.

## `PermissionService` interface

```dart
abstract interface class PermissionService {
  Future<AppPermissionStatus> check(AppPermission permission);
  Future<AppPermissionStatus> request(AppPermission permission);
  Future<Map<AppPermission, AppPermissionStatus>> requestMultiple(List<AppPermission> permissions);
  Future<bool> openAppSettings();
  Future<bool> shouldShowRationale(AppPermission permission);
}
```

## `AppPermission` enum

```dart
enum AppPermission {
  camera, photos, location, locationAlways,
  notifications, microphone, storage, contacts,
}
```

## `AppPermissionStatus` enum

```dart
enum AppPermissionStatus { granted, denied, permanentlyDenied, restricted, limited }
```

## Usage pattern

```dart
// In cubit — inject PermissionService, never call permission_handler directly
Future<void> requestCamera() async {
  final status = await _permissionService.request(AppPermission.camera);
  if (status == AppPermissionStatus.permanentlyDenied) {
    await _permissionService.openAppSettings();
  }
  // Optionally show result via AppDialog
  _dialog.showToast('Camera: ${status.name}');
}
```

## Files

```
lib/src/core/permissions/
  app_permission.dart             ← AppPermission enum (feature code uses this only)
  app_permission_status.dart      ← AppPermissionStatus enum (granted, denied, permanentlyDenied, restricted, limited)
  permission_service.dart         ← interface (check, request, requestMultiple, openAppSettings, shouldShowRationale)
  permission_service_impl.dart    ← only file importing permission_handler
```

## Co-load with

- `flutter-di` — register as lazySingleton
- `flutter-dialog` — rationale and settings dialogs via `AppDialog`

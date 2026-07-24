# Permission Usage Patterns

Common flows for requesting permissions with rationale dialogs, multi-permission requests, and location upgrade patterns.

## Request with Rationale Dialog

Check first, show a rationale when the OS suggests it, guide to Settings when permanently denied.

```dart
import 'package:flutter/widgets.dart';
import '../core/di/service_locator.dart';
import '../core/permissions/app_permission.dart';
import '../core/permissions/app_permission_status.dart';
import '../core/permissions/permission_service.dart';

/// Request camera permission with a rationale flow.
///
/// Returns `true` when access is granted, `false` otherwise.
Future<bool> requestCameraWithRationale(BuildContext context) async {
  final service = getIt<PermissionService>();

  // 1. Check current status — never request blindly.
  var status = await service.check(AppPermission.camera);
  if (status == AppPermissionStatus.granted) return true;

  // 2. Permanently denied — the OS will not show a prompt; guide to Settings.
  if (status == AppPermissionStatus.permanentlyDenied) {
    final openSettings = await showAdaptiveDialog<bool>(
      context: context,
      builder: (_) => _SettingsDialog(
        title: 'Camera Permission Required',
        message: 'Camera access has been denied. '
            'Please enable it in Settings to continue.',
      ),
    );
    if (openSettings ?? false) await service.openAppSettings();
    return false;
  }

  // 3. Show rationale before requesting (Android-only; iOS always false).
  if (await service.shouldShowRationale(AppPermission.camera)) {
    final proceed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (_) => _RationaleDialog(
        title: 'Camera Access',
        message: 'We need camera access to take photos for your profile.',
      ),
    );
    if (proceed != true) return false;
  }

  // 4. Request.
  status = await service.request(AppPermission.camera);
  return status == AppPermissionStatus.granted;
}
```

## Multiple Permissions at Once

Request camera and microphone together for video recording.

```dart
Future<bool> requestVideoRecordingPermissions(BuildContext context) async {
  final service = getIt<PermissionService>();

  final results = await service.requestMultiple([
    AppPermission.camera,
    AppPermission.microphone,
  ]);

  final cameraGranted =
      results[AppPermission.camera] == AppPermissionStatus.granted;
  final micGranted =
      results[AppPermission.microphone] == AppPermissionStatus.granted;

  if (cameraGranted && micGranted) return true;

  // Check if any were permanently denied and guide to Settings.
  final permanentlyDenied = results.entries
      .where((e) => e.value == AppPermissionStatus.permanentlyDenied)
      .map((e) => e.key)
      .toList();

  if (permanentlyDenied.isNotEmpty) {
    final names = permanentlyDenied.map(_permissionLabel).join(' and ');
    final openSettings = await showAdaptiveDialog<bool>(
      context: context,
      builder: (_) => _SettingsDialog(
        title: 'Permissions Required',
        message: '$names access has been permanently denied. '
            'Please enable it in Settings.',
      ),
    );
    if (openSettings ?? false) await service.openAppSettings();
  }

  return false;
}

String _permissionLabel(AppPermission p) => switch (p) {
      AppPermission.camera => 'Camera',
      AppPermission.photos => 'Photos',
      AppPermission.location => 'Location',
      AppPermission.locationAlways => 'Background Location',
      AppPermission.notifications => 'Notifications',
      AppPermission.microphone => 'Microphone',
      AppPermission.storage => 'Storage',
      AppPermission.contacts => 'Contacts',
    };
```

## Location Permission Flow

Check, request when-in-use, then optionally upgrade to always.

```dart
Future<bool> requestLocationPermissions(BuildContext context) async {
  final service = getIt<PermissionService>();

  // 1. Check when-in-use first.
  var status = await service.check(AppPermission.location);

  if (status == AppPermissionStatus.permanentlyDenied) {
    await _guideToSettings(
      context,
      title: 'Location Required',
      message: 'Location access has been denied. '
          'Please enable it in Settings.',
    );
    return false;
  }

  if (status != AppPermissionStatus.granted) {
    status = await service.request(AppPermission.location);
    if (status != AppPermissionStatus.granted) return false;
  }

  // 2. Optionally upgrade to always-on for background tracking.
  final alwaysStatus = await service.check(AppPermission.locationAlways);
  if (alwaysStatus == AppPermissionStatus.granted) return true;

  final wantsAlways = await showAdaptiveDialog<bool>(
    context: context,
    builder: (_) => _RationaleDialog(
      title: 'Background Location',
      message: 'Allow background location so we can track your run even '
          'when the app is in the background.',
    ),
  );

  if (wantsAlways == true) {
    final result = await service.request(AppPermission.locationAlways);
    return result == AppPermissionStatus.granted;
  }

  // When-in-use is enough.
  return true;
}

Future<void> _guideToSettings(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final service = getIt<PermissionService>();
  final openSettings = await showAdaptiveDialog<bool>(
    context: context,
    builder: (_) => _SettingsDialog(title: title, message: message),
  );
  if (openSettings ?? false) await service.openAppSettings();
}
```

# Permission Anti-Patterns

## 1. Requesting Permissions Without Showing Rationale First

**DON'T** — Call `request()` immediately; the user sees a system prompt with no context and denies reflexively:

```dart
// BAD: no rationale — user has no idea why the app needs camera
Future<void> onTakePhoto() async {
  final status = await permissionService.request(AppPermission.camera);
  if (status != AppPermissionStatus.granted) return;
  _openCamera();
}
```

**DO** — Check first, show a rationale dialog when the OS suggests it, then request:

```dart
// GOOD: explain why before prompting
Future<void> onTakePhoto(BuildContext context) async {
  var status = await permissionService.check(AppPermission.camera);
  if (status == AppPermissionStatus.granted) {
    _openCamera();
    return;
  }

  if (await permissionService.shouldShowRationale(AppPermission.camera)) {
    final proceed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (_) => _RationaleDialog(
        message: 'Camera access is needed to take a profile photo.',
      ),
    );
    if (proceed != true) return;
  }

  status = await permissionService.request(AppPermission.camera);
  if (status == AppPermissionStatus.granted) _openCamera();
}
```

## 2. Not Handling "Permanently Denied" State

**DON'T** — Keep calling `request()` when the permission is permanently denied; the OS silently ignores it and the user sees nothing:

```dart
// BAD: request() is a no-op when permanently denied — user is stuck
Future<void> onTakePhoto() async {
  final status = await permissionService.request(AppPermission.camera);
  if (status != AppPermissionStatus.granted) {
    showSnackBar('Permission denied'); // unhelpful, no way out
  }
}
```

**DO** — Detect `permanentlyDenied` and guide the user to the OS Settings page:

```dart
// GOOD: detect permanently denied and offer a path forward
Future<void> onTakePhoto(BuildContext context) async {
  final status = await permissionService.check(AppPermission.camera);

  if (status == AppPermissionStatus.permanentlyDenied) {
    final openSettings = await showAdaptiveDialog<bool>(
      context: context,
      builder: (_) => _SettingsDialog(
        message: 'Camera access was denied. '
            'Please enable it in Settings to take photos.',
      ),
    );
    if (openSettings ?? false) await permissionService.openAppSettings();
    return;
  }

  if (status != AppPermissionStatus.granted) {
    final result = await permissionService.request(AppPermission.camera);
    if (result != AppPermissionStatus.granted) return;
  }

  _openCamera();
}
```

## 3. Checking Permissions on Every `build()` Call

**DON'T** — Call the async permission check inside `build()`, which runs on every frame rebuild:

```dart
// BAD: async permission check on every rebuild — janky UI, wasted I/O
class CameraView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppPermissionStatus>(
      // This fires on EVERY rebuild
      future: getIt<PermissionService>().check(AppPermission.camera),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        if (snapshot.data == AppPermissionStatus.granted) {
          return const CameraPreview();
        }
        return const Text('No camera access');
      },
    );
  }
}
```

**DO** — Check once in a cubit and cache the result; re-check only on explicit user action or when returning from Settings:

```dart
// GOOD: cubit checks once, caches state, re-checks only when needed
class CameraPermissionCubit extends Cubit<CameraPermissionState> {
  CameraPermissionCubit(this._permissionService)
      : super(const CameraPermissionInitial());
  final PermissionService _permissionService;

  Future<void> checkPermission() async {
    emit(const CameraPermissionChecking());
    final status = await _permissionService.check(AppPermission.camera);
    if (status == AppPermissionStatus.granted) {
      emit(const CameraPermissionGranted());
    } else {
      emit(CameraPermissionDenied(status: status));
    }
  }

  Future<void> openSettings() async {
    await _permissionService.openAppSettings();
    await checkPermission(); // re-check only after returning from Settings
  }
}
```

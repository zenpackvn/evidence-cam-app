# Auth — BiometricService Interface & Implementation

## `pubspec.yaml` additions

```yaml
dependencies:
  local_auth: 2.3.0    # exact version, never ^
```

---

## `lib/src/core/auth/biometric_service.dart`

```dart
/// App-owned biometric auth interface.
/// Feature code depends on this — never on `package:local_auth`.
abstract interface class BiometricService {
  /// Returns `true` if the device supports biometric authentication
  /// and the user has enrolled at least one biometric.
  Future<bool> isAvailable();

  /// Prompt the user for biometric authentication.
  /// [reason] is shown in the system dialog (e.g. "Verify your identity").
  /// Returns `true` if authenticated, `false` if cancelled or failed.
  Future<bool> authenticate({required String reason});
}
```

---

## `lib/src/core/auth/biometric_service_impl.dart`

The **only file** that imports `package:local_auth`.

```dart
import 'package:local_auth/local_auth.dart';

import 'biometric_service.dart';

class BiometricServiceImpl implements BiometricService {
  BiometricServiceImpl([LocalAuthentication? delegate])
      : _auth = delegate ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
```

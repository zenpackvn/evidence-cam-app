# Screenshot Prevention, Deep Link Validation, and Input Validation

## Screenshot Prevention

Prevent sensitive screens from appearing in recent apps / being screenshotted.

### `ScreenSecurityService` interface + wrapper

```dart
// lib/src/core/security/screen_security_service.dart
abstract interface class ScreenSecurityService {
  Future<void> enableSecureMode();
  Future<void> disableSecureMode();
}

// lib/src/core/security/screen_security_service_impl.dart
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

final class ScreenSecurityServiceImpl implements ScreenSecurityService {
  @override
  Future<void> enableSecureMode() =>
      FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  Future<void> disableSecureMode() =>
      FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
}
```

### Usage — per sensitive page

```dart
class _CardDetailsPageState extends State<CardDetailsPage> {
  @override
  void initState() {
    super.initState();
    getIt<ScreenSecurityService>().enableSecureMode();
  }

  @override
  void dispose() {
    getIt<ScreenSecurityService>().disableSecureMode();
    super.dispose();
  }
}
```

---

## Deep Link Validation

Never trust incoming deep link URIs. Validate host, scheme, and path before acting.

```dart
// lib/src/app/router/app_router.dart
redirect: (context, state) {
  final uri = state.uri;

  // Reject unknown hosts
  if (uri.host.isNotEmpty && uri.host != 'app.yourdomain.com') {
    logger.warn('Blocked deep link from unknown host: ${uri.host}');
    return '/';
  }

  // Reject non-HTTPS scheme (except app:// custom scheme)
  if (uri.scheme != 'https' && uri.scheme != 'yourapp') {
    return '/';
  }

  return null; // allow
},
```

---

## Input Validation

All user input must be validated before use. Never pass unsanitized strings to SQL, file paths, or network requests.

```dart
// lib/src/core/forms/form_validator.dart
abstract final class FormValidator {
  /// Rejects strings containing SQL meta-characters.
  static String? noSqlInjection(String? value) {
    if (value == null || value.isEmpty) return null;
    final dangerous = RegExp(r"['\";\\]|--|\b(SELECT|INSERT|UPDATE|DELETE|DROP)\b",
        caseSensitive: false);
    if (dangerous.hasMatch(value)) return 'Invalid characters';
    return null;
  }

  /// Allows only safe filename characters.
  static String? safeFilename(String? value) {
    if (value == null || value.isEmpty) return null;
    if (RegExp(r'[/\\:*?"<>|]').hasMatch(value)) return 'Invalid filename';
    return null;
  }
}
```

Drift (SQLite) uses parameterized queries by default — never interpolate user input into raw SQL strings.

```dart
// DON'T
db.customQuery('SELECT * FROM tasks WHERE title = "$userInput"');

// DO — Drift generates parameterized queries automatically
db.managers.tasks.filter((t) => t.title.equals(userInput));
```

---
name: flutter-security
description: Use this skill when hardening a Flutter app's security — certificate pinning, secure storage, secret management, API key protection, root/jailbreak detection, screenshot prevention, obfuscation, ProGuard R8 rules, biometric auth, deep link validation, sensitive data in logs, SQL injection prevention, OWASP Mobile Top 10, token storage, network security config, app transport security, or any mobile security audit.
---

# Flutter Security

Full reference: [`template.md`](references/template.md)

## Key rules

### Never hardcode secrets
```dart
// DON'T
const apiKey = 'sk-live-abc123'; // committed to git → leaked

// DO — load from EnvConfig, injected at build time via --dart-define
final apiKey = getIt<AppConfig>().apiKey; // reads from compile-time env
```

### All sensitive data in `SecureStorage` — never `SharedPreferences`
```dart
// DON'T
prefs.setString('auth_token', token); // plain text, unencrypted

// DO
await getIt<SecureStorage>().write(key: StorageKeys.authToken, value: token);
```

### Certificate pinning — flavor-configurable

```dart
// SecurityInterceptor is registered in DI and injected into buildDio
// Pins configured per flavor in EnvConfig (enableSslPinning + sslPins)
getIt.registerLazySingleton<SecurityInterceptor>(
  () => SecurityInterceptor(config: getIt<AppConfig>()),
);
// In buildDio — bypasses when enableSslPinning is false or sslPins is empty
security.apply(dio);
```

Use `SecurityInterceptor` with SHA-256 pin matching. Pins live in `EnvConfig`, not in the interceptor. Never disable in prod.

### Strip sensitive data from logs

```dart
// In LoggingInterceptor — redact before logging
String _redact(String body) => body
    .replaceAll(RegExp(r'"password"\s*:\s*"[^"]*"'), '"password":"[REDACTED]"')
    .replaceAll(RegExp(r'"token"\s*:\s*"[^"]*"'), '"token":"[REDACTED]"');
```

### Obfuscate every release build
```bash
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
flutter build ipa --release --obfuscate --split-debug-info=build/debug-info
```
Never ship a release build without `--obfuscate`.

### Validate deep links — never trust the URI blindly
```dart
// In GoRouter redirect
if (uri.host != 'app.yourdomain.com') return '/';
```

### Screenshot prevention (sensitive screens)
```dart
// Android: in MainActivity.kt
window.setFlags(WindowManager.LayoutParams.FLAG_SECURE,
                WindowManager.LayoutParams.FLAG_SECURE)

// Flutter side — call via MethodChannel wrapper
getIt<ScreenSecurityService>().enableSecureMode();
```

## Security audit checklist

```bash
# 1. No secrets in source
grep -rn "api_key\|apiKey\|secret\|password\|token" lib/ --include="*.dart" \
  | grep -v "StorageKeys\|AppConfig\|_redact\|test"

# 2. No SharedPreferences for sensitive keys
grep -rn "prefs.set\|SharedPreferences" lib/ --include="*.dart" \
  | grep -iv "theme\|locale\|settings"

# 3. All release builds obfuscated (check CI build.yml)
grep "obfuscate" .github/workflows/build.yml

# 4. No sensitive fields in analytics/logging
grep -rn "logEvent\|AppLogger\|analytics" lib/ --include="*.dart" \
  | grep -i "password\|token\|secret"
```

## OWASP Mobile Top 10 mapping

| OWASP | Flutter mitigation |
|---|---|
| M1 Improper credential usage | `SecureStorage` + `--dart-define` secrets |
| M2 Inadequate supply chain | Exact version pins, `pub audit` |
| M3 Insecure auth | `TokenManager` + refresh, biometric via `BiometricService` |
| M4 Insufficient input/output validation | Validators on all form inputs, deep link guard |
| M5 Insecure comms | Certificate pinning, ATS/NSC enforced |
| M6 Inadequate privacy controls | Log redaction, `FLAG_SECURE` on sensitive screens |
| M7 Insufficient binary protection | `--obfuscate`, ProGuard R8, strip debug symbols |
| M8 Security misconfiguration | Flavors: debug config never in prod build |
| M9 Insecure data storage | `SecureStorage` for tokens, never plain prefs |
| M10 Insufficient cryptography | Use platform keystore via `flutter_secure_storage` |

## Co-load with

- `flutter-storage` — `SecureStorage` is the secure data layer
- `flutter-auth` — `TokenManager` + `BiometricService` are auth security primitives
- `flutter-network` — `SecurityInterceptor` for certificate pinning
- `flutter-flavors` — debug vs prod security config split
- `flutter-release` — obfuscation flags in build commands

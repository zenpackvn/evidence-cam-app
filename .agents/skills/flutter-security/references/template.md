# Template — Security Hardening

Systematic security hardening for Flutter apps covering OWASP Mobile Top 10: secret management, secure storage, certificate pinning, log redaction, obfuscation, input validation, screenshot prevention, and deep link validation.

## Topics

| Topic | File |
|---|---|
| Secret management (`--dart-define`, `AppConfig`, CI secrets) | [secret_management.md](secret_management.md) |
| Secure storage interface, impl, key constants | [secure_storage_and_keys.md](secure_storage_and_keys.md) |
| Certificate pinning, network security config, ATS | [certificate_pinning.md](certificate_pinning.md) |
| Log redaction, obfuscation, ProGuard | [log_redaction_and_obfuscation.md](log_redaction_and_obfuscation.md) |
| Screenshot prevention, deep link validation, input sanitization | [screenshot_and_input_validation.md](screenshot_and_input_validation.md) |
| Security audit script and anti-patterns | [security_audit.md](security_audit.md) |

## ⚠️ Common Mistakes

> These are the most frequent security bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **Hardcoded API key or secret in Dart source** | Key visible in decompiled APK; `check_security.sh` grep check fails | Use `String.fromEnvironment('API_KEY')` in `AppConfig` and inject via `--dart-define` in CI; never use `dotenv` (`.env` files are bundled in the APK) |
| 2 | **Auth token stored in `SharedPreferences`** | Token readable in plain text on rooted devices; `check_security.sh` SharedPreferences check fails | Store all tokens and PII exclusively in `SecureStorage` (`flutter_secure_storage` with `encryptedSharedPreferences: true` on Android) |
| 3 | **`badCertificateCallback` returns `true`** | Certificate pinning silently disabled; MITM attacks succeed without any error | Implement SHA-256 pin comparison in `SecurityInterceptor._validateCertificate`; return `true` only when `_pins.contains(pin)` |
| 4 | **`Authorization` or `Cookie` header logged by `LoggingInterceptor`** | Bearer tokens appear in device logs readable by other apps on non-sandboxed devices | Strip auth headers in `LoggingInterceptor` before writing to the log; replace sensitive JSON field values with `[REDACTED]` |
| 5 | **Certificate pinning disabled in prod/UAT flavors** | Production traffic unprotected against MITM even though `SecurityInterceptor` exists | Set `enableSslPinning: true` and provide at least two SHA-256 pins (primary + backup) in `EnvConfig.prod` and `EnvConfig.uat`; dev can remain unpinned |
| 6 | **Deep link host and scheme not validated** | Malicious app opens an arbitrary URI via your deep link scheme; unauthorized navigation or data exfiltration | Validate host and scheme in the GoRouter `redirect` callback; reject any URI that is not HTTPS or not in the app's known host list |
| 7 | **Sensitive page visible in the recent-apps screen** | Credit card numbers, credentials, or PII captured in the OS task switcher screenshot | Apply `FLAG_SECURE` on sensitive pages via `ScreenSecurityService`; call `enable()` in `initState` and `disable()` in `dispose` |
| 8 | **`dart pub audit` not run in CI** | Known-vulnerable dependency ships to production undetected | Add a `dart pub audit` step to the CI `analyze` job; fail the build on any high-severity finding |

## Quick Summary

- **No secrets in source** — Use `String.fromEnvironment` with `--dart-define` at build time. Never use `dotenv` in production; `.env` files get bundled in the APK.
- **Tokens in `SecureStorage` only** — Never `SharedPreferences` or drift for auth tokens or PII. Use `encryptedSharedPreferences: true` on Android.
- **Always obfuscate release builds** — Every release build needs `--obfuscate --split-debug-info`. Upload debug symbols to Sentry/Crashlytics.
- **Redact before logging** — Strip `Authorization`/`Cookie` headers. Replace sensitive JSON fields with `[REDACTED]` in `LoggingInterceptor` before writing to the log.
- **Certificate pinning in prod/UAT** — Configure `SecurityInterceptor` with SHA-256 pins per flavor. Never let `badCertificateCallback` return `true`.
- **Validate all deep link URIs** — Reject unknown hosts and non-HTTPS schemes in the GoRouter `redirect` callback.
- **`ScreenSecurityService` on sensitive pages** — Apply `FLAG_SECURE` on pages showing PAN, credentials, or personal data.
- **Run `dart pub audit` in CI** — Catch known vulnerabilities in dependencies.

## Cross-references

- [flutter-storage](../../flutter-storage/references/template.md) — `SecureStorage` is the encrypted data layer for tokens and PII
- [flutter-auth](../../flutter-auth/references/template.md) — `TokenManager` and `BiometricService` are the primary auth security primitives
- [flutter-network](../../flutter-network/references/template.md) — `SecurityInterceptor` implements certificate pinning and strips sensitive headers
- [flutter-flavors](../../flutter-flavors/references/template.md) — splits debug vs prod security config (pinning enabled only in prod/UAT)
- [flutter-release](../../flutter-release/references/template.md) — `--obfuscate --split-debug-info` flags and ProGuard rules for release builds
- [flutter-routing](../../flutter-routing/references/template.md) — GoRouter `redirect` callback is where deep-link host/scheme validation is enforced

# Security Audit Script

```bash
#!/usr/bin/env bash
# scripts/check_security.sh
set -euo pipefail

ERRORS=0

echo "=== 1. Secrets in source ==="
if grep -rn \
  'apiKey\s*=\s*"[^"]\+"\|secret\s*=\s*"[^"]\+"\|password\s*=\s*"[^"]\+"\|Bearer [A-Za-z0-9]' \
  lib/ --include="*.dart" | grep -v "fromEnvironment\|REDACTED\|StorageKeys\|_test"; then
  echo "FAIL: Potential hardcoded secrets found"
  ((ERRORS++)) || true
else
  echo "PASS"
fi

echo ""
echo "=== 2. SharedPreferences for sensitive data ==="
if grep -rn "prefs\.set\|SharedPreferences" lib/ --include="*.dart" \
  | grep -v "theme\|locale\|onboarding\|settings"; then
  echo "FAIL: SharedPreferences may hold sensitive data"
  ((ERRORS++)) || true
else
  echo "PASS"
fi

echo ""
echo "=== 3. Obfuscation in CI build ==="
if grep -q "\-\-obfuscate" .github/workflows/build.yml; then
  echo "PASS"
else
  echo "FAIL: --obfuscate missing from build.yml"
  ((ERRORS++)) || true
fi

echo ""
echo "=== 4. Certificate pinning in prod DioClient ==="
if grep -q "SecurityInterceptor\|badCertificateCallback" \
  lib/src/core/network/dio_client.dart 2>/dev/null; then
  echo "PASS"
else
  echo "WARN: No certificate pinning found in DioClient"
fi

echo ""
echo "=== 5. Cleartext disabled (Android) ==="
if grep -q "cleartextTrafficPermitted=\"false\"" \
  android/app/src/main/res/xml/network_security_config.xml 2>/dev/null; then
  echo "PASS"
else
  echo "FAIL: Cleartext traffic not disabled"
  ((ERRORS++)) || true
fi

echo ""
if [[ $ERRORS -eq 0 ]]; then
  echo "Security audit PASSED."
else
  echo "Security audit FAILED with $ERRORS issue(s)."
  exit 1
fi
```

## Anti-Patterns Reference

| Anti-pattern | Fix |
|---|---|
| Hardcoded API key in Dart source | `String.fromEnvironment` + CI secret injection |
| Token in `SharedPreferences` | `SecureStorage` with `encryptedSharedPreferences: true` |
| No `--obfuscate` in release build | Add to every `flutter build` command + CI |
| Raw SQL string interpolation | Drift parameterized queries / ORM filter API |
| `Authorization` header logged | Strip auth headers in `LoggingInterceptor` |
| Deep link host not validated | Validate host + scheme in GoRouter `redirect` |
| `NSAllowsArbitraryLoads: true` in prod | Remove from prod `Info.plist` |
| `badCertificateCallback` returns `true` | Implement SHA-256 pin comparison |
| Sensitive screen in recent apps | `FLAG_SECURE` via `ScreenSecurityService` wrapper |
| `pub audit` never run | Add `dart pub audit` step to CI `analyze` job |

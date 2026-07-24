# Checklists & Verification Scripts

## Wrapper Migration Checklist

Use this checklist for each dependency you wrap:

```markdown
## Wrapping: [package_name]

- [ ] Created interface: `lib/src/core/<concern>/<name>.dart`
- [ ] Created implementation: `lib/src/core/<concern>/<name>_impl.dart`
- [ ] Implementation is the ONLY file that imports `package:<package_name>`
- [ ] Registered in composition root: `lib/src/core/di/service_locator.dart`
- [ ] All consumers updated to use the interface (constructor injection)
- [ ] Grep confirms zero direct imports outside `*_impl.dart`:
      `grep -r "package:<package_name>" lib/src/ | grep -v "_impl.dart"`
- [ ] Created test fake: `test/fakes/fake_<name>.dart`
- [ ] `flutter analyze` passes
- [ ] `flutter test` passes
```

## Verification Script

Run this after each migration PR to check compliance:

```bash
#!/bin/bash
# scripts/check_wrapper_rule.sh

set -e
echo "=== Wrapper Rule Check ==="

VIOLATIONS=0

# Packages that should only be imported in *_impl.dart
WRAPPED_PACKAGES=(
  "package:dio"
  "package:logger"
  "package:shared_preferences"
  "package:flutter_secure_storage"
  "package:firebase_analytics"
  "package:sentry_flutter"
  "package:firebase_remote_config"
  "package:firebase_messaging"
  "package:flutter_local_notifications"
  "package:permission_handler"
  "package:connectivity_plus"
  "package:cached_network_image"
  "package:flutter_smart_dialog"
  "package:flutter_localization"
  "package:local_auth"
  "package:hydrated_bloc"
)

for pkg in "${WRAPPED_PACKAGES[@]}"; do
  # Find imports outside _impl.dart, di/, and bootstrap files
  MATCHES=$(grep -rn "import '$pkg" lib/src/ \
    | grep -v "_impl.dart" \
    | grep -v "core/di/" \
    | grep -v "bootstrap" \
    | grep -v "// wrapper-exempt" \
    || true)

  if [ -n "$MATCHES" ]; then
    echo "VIOLATION: $pkg imported outside wrapper:"
    echo "$MATCHES"
    VIOLATIONS=$((VIOLATIONS + 1))
  fi
done

echo ""
echo "=== Composition Root Check ==="

# Find registrations outside allowed locations
REG_VIOLATIONS=$(grep -rn "register\(Singleton\|Factory\|LazySingleton\)" lib/ \
  | grep -v "core/di/" \
  | grep -v "features/.*/di/" \
  | grep -v "_test.dart" \
  || true)

if [ -n "$REG_VIOLATIONS" ]; then
  echo "VIOLATION: registrations outside composition root:"
  echo "$REG_VIOLATIONS"
  VIOLATIONS=$((VIOLATIONS + 1))
fi

echo ""
echo "=== Service Location Check ==="

# Find getIt<T>() calls outside allowed boundaries
SL_VIOLATIONS=$(grep -rn "getIt<" lib/src/ \
  | grep -v "core/di/" \
  | grep -v "features/.*/di/" \
  | grep -v "BlocProvider" \
  | grep -v "RepositoryProvider" \
  | grep -v "// composition-boundary" \
  || true)

if [ -n "$SL_VIOLATIONS" ]; then
  echo "WARNING: getIt<T>() calls outside composition boundaries:"
  echo "$SL_VIOLATIONS"
  echo "(Review these — some may be legitimate composition boundaries)"
fi

echo ""
if [ $VIOLATIONS -eq 0 ]; then
  echo "All checks passed."
else
  echo "$VIOLATIONS violation(s) found."
  exit 1
fi
```

Add `check_wrapper_rule.sh` to your CI pipeline after Phase 1 so new code can't introduce direct imports.

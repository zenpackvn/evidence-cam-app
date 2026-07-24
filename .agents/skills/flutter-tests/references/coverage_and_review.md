# Coverage Enforcement and Review Checklist

## Coverage Enforcement

### Generate coverage locally

```bash
# Run tests with coverage
flutter test --coverage

# Generate HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Check coverage percentage
lcov --summary coverage/lcov.info
```

### Coverage threshold script

`tool/check_coverage.sh`:

```bash
#!/bin/bash
set -e

THRESHOLD=${1:-80}

flutter test --coverage

COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | grep "lines" | sed 's/.*: //' | sed 's/%.*//')

echo "Coverage: ${COVERAGE}%"
echo "Threshold: ${THRESHOLD}%"

PASS=$(echo "$COVERAGE $THRESHOLD" | awk '{print ($1 >= $2)}')

if [ "$PASS" -eq 0 ]; then
  echo "FAIL: Coverage ${COVERAGE}% is below threshold ${THRESHOLD}%"
  exit 1
fi

echo "PASS: Coverage meets threshold"
```

### Excluding files from coverage

`tool/filter_coverage.sh`:

```bash
#!/bin/bash
set -e

flutter test --coverage

lcov --remove coverage/lcov.info \
  '*.g.dart' \
  '*.freezed.dart' \
  '*/di/*' \
  '*/generated/*' \
  -o coverage/lcov_filtered.info

genhtml coverage/lcov_filtered.info -o coverage/html
```

---

## Review Checklist

### Dart Pitfalls

- Avoid implicit `dynamic`; prefer strict analyzer settings.
- Prefer null-safe control flow over `!` and unnecessary `late`.
- Catch specific exception types instead of broad `catch (e)`.
- Flag ignored futures unless intentionally `unawaited`.
- Prefer `final` and `const` where values do not change.
- Prefer `package:` imports.
- Avoid exposing mutable collections from public APIs or state objects.
- Flag `print()` in production code — prefer structured logging.

### Widgets And UI

- Split oversized widgets by responsibility and rebuild boundary.
- Keep `build()` side-effect free: no I/O, subscriptions, heavy computation.
- Use theme tokens instead of hardcoded colors, sizes, spacing.
- Check keys in reorderable or stateful lists.
- Verify layouts for overflow, text scaling, safe areas, screen sizes.

### State Management

- Keep business logic in cubits/blocs/controllers, not widgets.
- Inject dependencies — don't construct inside state managers.
- Prefer explicit async states over boolean flag soup.
- Scope rebuild listeners narrowly. Dispose subscriptions, timers, controllers.
- Guard `BuildContext` and `setState` after `await` with `mounted` checks.

### Security

- Never store secrets/tokens in plaintext or hardcode in Dart source.
- Validate user input and deep links before use.
- Prefer HTTPS. Avoid logging sensitive data.
- Review token refresh, expiration, retry carefully.

### Wrapper And DI Checks

- Grep for direct third-party imports outside `lib/src/core/**` — any match is a defect.
- Grep for `getIt.register...` outside `lib/src/core/di/` and `lib/src/features/*/di/` — any match is a defect.
- Flag `getIt<T>()` inside widget `build()`, bloc, cubit, use case, or repository.
- Blocs/cubits as singletons = defect (state leaks across screens).
- New third-party plugin without app-owned wrapper = defect.
- Tests without `getIt.reset()` and explicit fakes = defect.

## Anti-Patterns

- **DON'T** use `when(repo.method)` with mocktail — use `when(() => repo.method())`. The closure syntax is mandatory.
- **DON'T** test implementation details — test behavior and state transitions.
- **DON'T** use real HTTP/storage/platform in unit tests — always inject fakes.
- **DON'T** skip `getIt.reset()` in setUp — state leaks between tests cause flaky failures.
- **DON'T** use `tester.pump()` when you need `tester.pumpAndSettle()` — async operations need settle.
- **DON'T** commit broken golden files — run `--update-goldens` locally and review the diff.

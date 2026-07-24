# CI — Coverage Script & Local Workflow

## `scripts/check_coverage.sh`

Parses `coverage/lcov.info` and fails the build if line coverage drops below the threshold. No external tools required beyond `awk`.

```bash
#!/usr/bin/env bash
set -euo pipefail

THRESHOLD="${1:-80}"
LCOV_FILE="coverage/lcov.info"

if [ ! -f "$LCOV_FILE" ]; then
  echo "ERROR: $LCOV_FILE not found. Run 'flutter test --coverage' first."
  exit 1
fi

# Sum hit/found lines from lcov
LINES_FOUND=$(awk -F: '/^LF:/ { total += $2 } END { print total }' "$LCOV_FILE")
LINES_HIT=$(awk -F: '/^LH:/ { total += $2 } END { print total }' "$LCOV_FILE")

if [ "$LINES_FOUND" -eq 0 ]; then
  echo "ERROR: No lines found in coverage report."
  exit 1
fi

COVERAGE=$(awk "BEGIN { printf \"%.2f\", ($LINES_HIT / $LINES_FOUND) * 100 }")

echo "Coverage: $COVERAGE% ($LINES_HIT / $LINES_FOUND lines)"
echo "Threshold: $THRESHOLD%"

PASS=$(awk "BEGIN { print ($COVERAGE >= $THRESHOLD) ? 1 : 0 }")

if [ "$PASS" -eq 0 ]; then
  echo "FAIL: Coverage $COVERAGE% is below the $THRESHOLD% threshold."
  exit 1
fi

echo "PASS: Coverage meets the threshold."
```

---

## Local coverage workflow

Generate and view coverage locally before pushing:

```bash
# Run tests with coverage
flutter test --coverage

# Generate HTML report (requires lcov — install via brew/apt)
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html        # macOS
xdg-open coverage/html/index.html    # Linux
```

Check coverage threshold locally with the same script CI uses:

```bash
chmod +x scripts/check_coverage.sh
./scripts/check_coverage.sh 80
```

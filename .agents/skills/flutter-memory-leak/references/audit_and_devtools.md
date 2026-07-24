# Audit Script & DevTools Memory Workflow

## Static Audit Script

```bash
#!/usr/bin/env bash
# scripts/check_leaks.sh — static heuristic scan for missing dispose calls
set -euo pipefail

ERRORS=0

echo "=== Scanning for undisposed controllers ==="

# Find State classes that create controllers but may not dispose them
for f in $(grep -rl "TextEditingController()\|AnimationController(\|ScrollController()\|FocusNode()" lib/ --include="*.dart"); do
  if ! grep -q "\.dispose()" "$f"; then
    echo "  WARN: $f — creates controller but no .dispose() found"
    ((ERRORS++)) || true
  fi
done

echo ""
echo "=== Scanning for uncancelled subscriptions ==="
for f in $(grep -rl "\.listen(" lib/ --include="*.dart" | grep -v "_impl.dart"); do
  if ! grep -q "\.cancel()" "$f"; then
    echo "  WARN: $f — .listen() without matching .cancel()"
    ((ERRORS++)) || true
  fi
done

echo ""
if [[ $ERRORS -eq 0 ]]; then
  echo "No leak patterns found."
else
  echo "Found $ERRORS potential leak(s). Review manually."
  exit 1
fi
```

## DevTools Memory Workflow

1. Run app in **profile mode**: `flutter run --profile`
2. Open [Flutter DevTools](https://docs.flutter.dev/tools/devtools) → **Memory** tab
3. Trigger the suspected flow (open page, navigate away, repeat 3×)
4. Click **GC** to force garbage collection
5. Click **Snapshot** and filter for your widget/cubit class names
6. Any retained instances after GC = leak

## Key DevTools signals

- Widget/cubit class count grows across navigation cycles → leak
- `ImageCache` size keeps growing → missing `memCacheWidth`/`memCacheHeight`
- `_StreamController` instances not reclaimed → stream not closed

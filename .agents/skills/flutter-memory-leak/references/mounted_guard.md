# `mounted` Guard — Prevent BuildContext Leaks

Always check `mounted` before using `BuildContext` after an `await`.

## DON'T / DO

```dart
// DON'T — context may reference a disposed element
Future<void> _handleSubmit() async {
  await _cubit.submit();
  context.go('/success'); // potential crash + context leak
}

// DO
Future<void> _handleSubmit() async {
  await _cubit.submit();
  if (!mounted) return;
  context.go('/success');
}
```

## Extension helper for non-State contexts

For cases where `mounted` is not directly available (e.g., extension methods on `BuildContext`):

```dart
extension BuildContextX on BuildContext {
  bool get isMounted {
    try {
      // ignore: invalid_use_of_protected_member
      return (this as Element).mounted;
    } catch (_) {
      return false;
    }
  }
}
```

## Rule

Every `await` inside a widget method that uses `context` afterward **must** be guarded by `if (!mounted) return;`.

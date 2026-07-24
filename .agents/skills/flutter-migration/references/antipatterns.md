# Migration Anti-Patterns

## DON'T — Rewrite the entire app in one PR

```
# BAD: 847 files changed, 12,000 insertions, 8,000 deletions
# "Migrate to clean architecture"
# Unreviewable, untestable, guaranteed conflicts
```

## DO — One dependency, one PR

```
# GOOD: 6 files changed, 180 insertions, 45 deletions
# "Wrap logger behind AppLogger interface"
# Clear scope, easy review, safe rollback
```

---

## DON'T — Change state management AND wrap dependencies in the same PR

```dart
// BAD: migrating from Provider to BLoC AND wrapping Dio at the same time
// Two unrelated changes — if either breaks, you can't isolate the cause
```

## DO — Separate concerns into separate PRs

```
PR 1: Wrap Dio behind DioClient (keep Provider)
PR 2: Migrate PostScreen from Provider to Cubit (keep DioClient)
```

---

## DON'T — Skip the audit

```
// BAD: "I'll just start wrapping things"
// You miss 6 files that import package:dio in a utils/ folder.
// A month later, someone finds an unwrapped import in production.
```

## DO — Audit first, then migrate systematically

```bash
# GOOD: know your baseline before you start
grep -r "^import 'package:dio" lib/ | wc -l  # → 14 files
# After wrapping: should be 1 (dio_client_impl.dart)
```

---

## DON'T — Add wrapper rule but leave legacy code untouched

```dart
// BAD: new code uses AppLogger, old code still imports package:logger
// The rule exists but isn't enforced — entropy wins
```

## DO — Add the verification script to CI after Phase 1

```yaml
# GOOD: CI blocks any new direct import
- name: Check wrapper rule
  run: bash scripts/check_wrapper_rule.sh
```

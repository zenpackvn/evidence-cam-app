# Phase 0: Audit (1 PR)

Before changing any code, assess the current state.

## Step 0.1 — Find direct third-party imports

```bash
# List every third-party import outside pubspec-generated files
grep -r "^import 'package:" lib/src/ \
  | grep -v "package:flutter" \
  | grep -v "package:your_app_name" \
  | sort | uniq -c | sort -rn
```

This shows which packages are imported most widely. The most-imported package is your highest-priority wrapping target.

## Step 0.2 — Find scattered DI registrations

```bash
# Find all getIt.register* or GetIt.I.register* calls
grep -rn "register\(Singleton\|Factory\|LazySingleton\)" lib/
```

If registrations appear in multiple files (features, widgets, screens), you need a composition root.

## Step 0.3 — Find service locator calls in wrong places

```bash
# Find getIt<T>() or GetIt.I<T>() calls outside DI boundary
grep -rn "getIt<\|GetIt\.I<\|GetIt\.instance<" lib/src/
```

Calls inside cubits, repositories, widgets, or use cases violate constructor-injection. Note these for later.

## Step 0.4 — Create the audit report

```markdown
## Migration Audit

### Direct third-party imports (to wrap)
- `package:dio` — 14 files
- `package:shared_preferences` — 8 files
- `package:firebase_analytics` — 5 files
- `package:logger` — 12 files

### DI registrations (to centralize)
- lib/features/auth/auth_module.dart — 3 registrations
- lib/features/posts/post_module.dart — 2 registrations
- lib/main.dart — 7 registrations
- lib/app/app.dart — 1 registration (scattered!)

### Constructor-injection violations
- lib/features/posts/post_cubit.dart:15 — getIt<PostRepo>() in constructor body
- lib/widgets/avatar.dart:22 — GetIt.I<ImageService>() in build()

### Missing wrappers (priority order)
1. Logger (12 files) — highest blast radius
2. Dio/HTTP (14 files) — but mostly in repos, lower widget impact
3. SharedPreferences (8 files)
4. Firebase Analytics (5 files)
```

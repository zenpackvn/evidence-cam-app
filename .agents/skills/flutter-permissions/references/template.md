# Template — Permissions

Runtime permission handling wrapped behind an app-owned interface. Only `permission_service_impl.dart` imports `package:permission_handler`; all feature code depends on `PermissionService`, `AppPermission`, and `AppPermissionStatus` — all app-owned types.

## Topic Index

| Topic | File |
|---|---|
| App-owned interface, enums, and folder structure | [permission_service_interface.md](permission_service_interface.md) |
| Concrete implementation (permission_handler wrapper) and DI | [permission_service_impl.md](permission_service_impl.md) |
| Usage patterns: rationale, multi-permission, location flow | [usage_patterns.md](usage_patterns.md) |
| iOS plist keys and Android manifest permissions | [platform_setup.md](platform_setup.md) |
| Cubit integration, page wiring, and cubit tests | [cubit_integration.md](cubit_integration.md) |
| FakePermissionService for unit and widget tests | [test_fake.md](test_fake.md) |
| Anti-patterns (no rationale, permanently denied, FutureBuilder) | [anti_patterns.md](anti_patterns.md) |

## ⚠️ Common Mistakes

> These are the most frequent permission bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **Importing `package:permission_handler` outside the impl file** | Wrapper rule violated; feature code couples to the third-party package directly | Only `permission_service_impl.dart` may import `package:permission_handler`; all other code depends on `PermissionService`, `AppPermission`, and `AppPermissionStatus` |
| 2 | **Calling `request()` without checking first** | User sees a cold OS prompt with no context and reflexively denies it | Call `check()` first; if not granted and not permanently denied, call `shouldShowRationale()` and show a rationale dialog before `request()` |
| 3 | **Permanently denied state not handled** | `request()` is a silent no-op; user is stuck with no path forward | Detect `AppPermissionStatus.permanentlyDenied`; show a Settings dialog and call `permissionService.openAppSettings()` |
| 4 | **Requesting permissions on app launch** | App rejected by Apple/Google; users denied before they understand why they need the permission | Request at the point of use — only when the feature that requires the permission is about to be invoked |
| 5 | **Async permission check inside `build()` or a `FutureBuilder`** | Permission I/O fires on every rebuild; janky UI, excessive system calls | Check once in a cubit's initialisation method; cache the `AppPermissionStatus` in state; re-check only on explicit user action or after returning from Settings |
| 6 | **iOS `Info.plist` description missing or generic** | Apple review rejects the app for insufficient permission justification | Add a user-friendly usage description for every permission declared; follow the platform_setup.md keys list exactly |
| 7 | **Android manifest declares permissions the app never uses** | Google Play flags the app for over-privileged permission requests; may trigger review | Declare only the permissions actually used; remove any copy-pasted extras from boilerplate |
| 8 | **Unit tests depend on real device permission state** | Tests pass on the CI machine but fail on devices where the permission was previously denied | Inject `FakePermissionService` (from test_fake.md) in all unit and widget tests; never call the real `PermissionService` in tests |

## Quick Summary

- **Wrapper rule** — only `permission_service_impl.dart` imports `package:permission_handler`. Feature code depends on `PermissionService`, `AppPermission`, and `AppPermissionStatus` exclusively.
- **Check before requesting** — call `check()` first; skip the prompt when already granted, route to Settings when permanently denied.
- **Show rationale** — when `shouldShowRationale()` returns `true` (Android only), explain why before calling `request()`.
- **Handle permanently denied** — the OS will not show a prompt; guide the user to Settings with a clear explanation.
- **Request at point of use** — never on app launch; ask only when the feature that needs the permission is about to be used.
- **Cache in cubit** — check once in a cubit and re-check only on explicit user action or after returning from Settings. Never call async permission checks in `build()`.
- **Test with FakePermissionService** — never depend on real device permissions in unit or widget tests.
- **iOS plist descriptions must be user-friendly** — Apple rejects generic descriptions. Only declare Android permissions you actually use.

## Cross-references

- [flutter-di](../../../flutter-di/references/template.md) — `PermissionService` must be registered as a `lazySingleton` in the DI composition root
- [flutter-dialog](../../../flutter-dialog/references/template.md) — rationale dialogs and "open Settings" prompts are shown via `AppDialog`, not raw `showDialog`
- [flutter-base-classes](../../../flutter-base-classes/references/template.md) — permission-requesting cubits extend `BaseCubit` to use safe emit and standard loading/error states

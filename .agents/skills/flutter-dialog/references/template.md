# Template — Dialogs, Toasts & Notifications

All dialogs, toasts, notification banners, and loading overlays wrapped behind an app-owned `AppDialog` interface backed by `flutter_smart_dialog`. Only `app_dialog_impl.dart` imports the vendor package — the wrapper rule applies throughout.

## Topics

| Topic | File |
|---|---|
| `AppDialog` interface, folder structure, enums, barrel export | [app_dialog_interface.md](app_dialog_interface.md) |
| `AppDialogImpl`, app-level setup, DI registration | [app_dialog_impl.md](app_dialog_impl.md) |
| Usage — toast, notification, confirm, loading, custom, attached, BlocListener, cubit callback, bottom sheet | [dialog_usage.md](dialog_usage.md) |
| `FakeDialog`, bloc test patterns, DI override in tests | [dialog_testing.md](dialog_testing.md) |
| Anti-patterns | [dialog_anti_patterns.md](dialog_anti_patterns.md) |

## ⚠️ Common Mistakes

> These are the most frequent dialog bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **Importing `flutter_smart_dialog` outside `app_dialog_impl.dart`** | Wrapper rule violated — swapping the dialog library now requires editing every feature file that imports it | Only `app_dialog_impl.dart` may import `package:flutter_smart_dialog/`; feature code imports only `AppDialog`; grep for violations before marking done |
| 2 | **Calling `FlutterSmartDialog.init()` directly in `app.dart`** | `flutter_smart_dialog` is imported into `app.dart`, breaking the wrapper rule and creating a direct coupling | Use `getIt<AppDialog>().wrapApp(context, child)` in `MaterialApp.builder`; `AppDialogImpl` calls `FlutterSmartDialog.init()` internally |
| 3 | **Showing dialogs from inside `build()`** | `build()` re-runs on every rebuild; duplicate dialogs stack on screen with no way to dismiss them | Move all dialog calls into `BlocListener`'s `listener` callback, which fires exactly once per state transition |
| 4 | **Not dismissing loading dialog on error path** | Loading overlay stays visible forever after an exception; user is stuck and cannot interact with the app | Wrap async calls in `try/catch/finally` or explicitly call `dialog.dismissLoading()` in both success and error branches before showing result feedback |
| 5 | **Calling `AppDialog` from inside a cubit** | Cubits have no `BuildContext`; `getIt<AppDialog>()` from a cubit couples business logic to a UI concern and makes unit testing impossible | Never call `AppDialog` from a cubit; show dialogs from `BlocListener` in the widget layer; if mid-flow confirmation is needed, pass a `Future<bool> Function() confirmDelete` callback from the widget |
| 6 | **Using raw `showDialog(...)` instead of `AppDialog.showConfirm`** | Bypasses the wrapper — dialog styling and behavior is inconsistent; swapping the dialog library requires touching every feature file | Use `getIt<AppDialog>().showConfirm(title: ..., message: ..., isDangerousAction: true)` for all confirmation dialogs |
| 7 | **Destructive action dialog without `isDangerousAction: true`** | Confirm button is styled as a normal action; users do not get the visual warning that the action is irreversible | Always pass `isDangerousAction: true` to `showConfirm` for delete, sign-out, cancel-subscription, and other irreversible operations — it renders an `AppDangerButton` |
| 8 | **Hardcoded colors in custom dialog builders** | Custom dialog ignores dark mode; color clashes when the user switches theme | Use `Theme.of(context).colorScheme.*` inside every custom dialog `builder` callback; no inline `Color(0xFF...)` or `Colors.*` literals |

## Quick Summary

- **Wrapper rule**: only `app_dialog_impl.dart` imports `flutter_smart_dialog`. Feature code only imports `AppDialog`. Grep for `import 'package:flutter_smart_dialog/` outside `lib/src/core/widgets/dialog/` — any match is a defect.
- **Wire via `wrapApp`**: `app.dart` calls `getIt<AppDialog>().wrapApp(context, child)` in `MaterialApp.builder`. Never call `FlutterSmartDialog.init()` directly in `app.dart`.
- **Dialogs from `BlocListener`, not `build()`**: `build()` can re-run many times; dialogs triggered there spawn duplicates.
- **Never call `AppDialog` from inside a cubit** — cubits have no `BuildContext` and must not own UI concerns. Pass a confirmation callback from the widget layer when user input is needed mid-flow.
- **Always `dismissLoading()` before showing result feedback** — stacked overlays confuse users. Use a `try/catch/finally` or handle both paths explicitly.
- **Use `showConfirm` with `isDangerousAction: true`** for destructive actions (delete, sign out, cancel subscription).
- **Tag dialogs** with the `tag` parameter when you need to dismiss a specific overlay with `dismiss(tag: 'my-tag')`.
- **Use theme colors** in all dialog widgets — never hardcode colors. Reference `Theme.of(context).colorScheme`.

## Cross-references

- [flutter-di](../../flutter-di/references/template.md) — `AppDialog` must be registered as a singleton in the composition root; `AppDialogImpl` is the only registration
- [flutter-loading](../../flutter-loading/references/template.md) — `LoadingOverlay` and `LoadingButton` are backed by `AppDialog.showLoading()` / `dismissLoading()`

---
name: flutter-dialog
description: Use this skill when working on Flutter dialogs, toasts, snack bars, notifications, confirmations, alerts, loading dialogs, bottom sheets, or any in-app messaging — AppDialog interface, flutter_smart_dialog wrapper, toast messages, confirmation dialogs with confirm/cancel, notification banners, custom dialogs, or attached dialogs anchored to widgets.
---

# Flutter Dialog

Full reference: [`template.md`](references/template.md)

## Key rules

- `AppDialog` is the app-owned interface. **Never use `ScaffoldMessenger`** or `showDialog()` directly in feature code — always `getIt<AppDialog>()`.
- **Never import `flutter_smart_dialog`** outside `app_dialog_impl.dart`.
- `wrapApp(BuildContext, Widget?)` — call once in `MaterialApp.router`'s `builder`. Keeps the `flutter_smart_dialog` init inside the wrapper, out of `app.dart`.
- Five dialog types:
  1. `showToast(message)` — brief dismissing message (bottom of screen)
  2. `showNotification({message, type})` — info/success/warning/error banner
  3. `showConfirm({title, message, ...})` → `Future<bool>` — destructive actions
  4. `showLoading({message})` + `dismissLoading()` — async operation indicator
  5. Custom dialog via `showCustom(builder: ...)` — any widget
- `showLoading()` / `dismissLoading()` calls must be balanced — always dismiss in `finally` blocks.
- Confirm dialogs for destructive actions set `isDangerousAction: true` to show red confirm button.
- Call `AppDialog` from cubits (via constructor injection) or from BlocListener in pages — never from `build()`.

## Files

```
lib/src/core/dialog/
  app_dialog.dart          ← interface
  app_dialog_impl.dart     ← only file importing flutter_smart_dialog
```

## Co-load with

- `flutter-di` — register `AppDialog` as singleton
- `flutter-loading` — `LoadingOverlay` backed by `AppDialog.showLoading()`

# AppDialog Interface

The app-owned wrapper interface for all dialogs, toasts, and notifications. Feature code depends on this — never on `package:flutter_smart_dialog`.

## Folder structure

```text
lib/src/core/
  widgets/
    dialog/
      app_dialog.dart              ← App-owned interface (no flutter_smart_dialog import)
      app_dialog_impl.dart         ← Only file importing flutter_smart_dialog
      dialog.dart                  ← Barrel export
```

## `pubspec.yaml` addition

```yaml
dependencies:
  flutter_smart_dialog: 4.9.7+3    # exact version, never ^
```

## `lib/src/core/widgets/dialog/app_dialog.dart`

```dart
import 'package:flutter/widgets.dart';

/// Toast display position.
enum AppToastPosition { top, center, bottom }

/// Notification type — drives icon and color in the notification banner.
enum AppNotifyType { success, failure, warning, alert, error }

/// App-owned dialog interface.
/// Feature code calls this instead of SmartDialog directly.
abstract interface class AppDialog {
  // ── App-level setup ──

  /// Wraps the widget tree with the dialog system initializer.
  /// Call once inside `MaterialApp.router`'s `builder` parameter.
  /// Never call `FlutterSmartDialog.init()` directly in app.dart.
  Widget wrapApp(BuildContext context, Widget? child);

  // ── Toast ──

  /// Show a brief toast message.
  void showToast(
    String message, {
    AppToastPosition position,
    Duration displayTime,
  });

  // ── Notification banner ──

  /// Show a notification banner at the top of the screen.
  void showNotification({
    required String message,
    AppNotifyType type,
    Duration displayTime,
  });

  // ── Confirm dialog ──

  /// Show a confirm dialog with title, message, and two actions.
  /// Returns `true` if confirmed, `false` if cancelled or dismissed.
  Future<bool> showConfirm({
    required String title,
    String? message,
    String confirmText,
    String cancelText,
    bool isDangerousAction,
  });

  // ── Custom dialog ──

  /// Show a fully custom dialog widget.
  Future<T?> showCustom<T>({
    required Widget Function(BuildContext context) builder,
    bool clickMaskDismiss,
    bool usePenetrate,
    Alignment alignment,
    String? tag,
  });

  // ── Loading dialog ──

  /// Show a modal loading dialog. Call [dismissLoading] when done.
  void showLoading({String? message});

  /// Dismiss the current loading dialog.
  void dismissLoading();

  // ── Attached dialog ──

  /// Show a dialog attached to a target widget (tooltip, dropdown).
  Future<T?> showAttached<T>({
    required BuildContext targetContext,
    required Widget Function(BuildContext context) builder,
    Alignment targetAlignment,
    Alignment followerAlignment,
    bool clickMaskDismiss,
    String? tag,
  });

  // ── Dismiss ──

  /// Dismiss all dialogs, toasts, and notifications.
  void dismissAll();

  /// Dismiss a specific dialog by tag.
  void dismiss({String? tag});
}
```

## Barrel export — `dialog.dart`

```dart
export 'app_dialog.dart';
export 'app_dialog_impl.dart';
```

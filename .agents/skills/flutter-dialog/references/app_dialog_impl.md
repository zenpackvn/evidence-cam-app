# AppDialogImpl

The **only file** that imports `flutter_smart_dialog`. Translates the app-owned `AppDialog` API to `SmartDialog` calls.

## App-level setup

`flutter_smart_dialog` requires wiring into `MaterialApp.builder`. **Do not import `flutter_smart_dialog` in `app.dart`** — use `AppDialog.wrapApp()` instead.

### `lib/src/app/app.dart` (updated)

```dart
import 'package:flutter/material.dart';
import '../core/di/service_locator.dart';
import '../core/dialog/app_dialog.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: AppRouter.instance,
      // ── dialog system init — no flutter_smart_dialog import needed ──
      builder: (context, child) => getIt<AppDialog>().wrapApp(context, child),
    );
  }
}
```

## DI Registration

```dart
// In service_locator.dart
import '../widgets/dialog/app_dialog.dart';
import '../widgets/dialog/app_dialog_impl.dart';

getIt.registerLazySingleton<AppDialog>(() => const AppDialogImpl());
```

## `lib/src/core/widgets/dialog/app_dialog_impl.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import '../common/app_button.dart';
import 'app_dialog.dart';

class AppDialogImpl implements AppDialog {
  // Cache the TransitionBuilder so FlutterSmartDialog.init() is called once.
  final _smartDialogBuilder = FlutterSmartDialog.init();

  // ── App-level setup ──

  @override
  Widget wrapApp(BuildContext context, Widget? child) =>
      _smartDialogBuilder(context, child);

  // ── Toast ──

  @override
  void showToast(
    String message, {
    AppToastPosition position = AppToastPosition.bottom,
    Duration displayTime = const Duration(milliseconds: 2000),
  }) {
    SmartDialog.showToast(
      message,
      displayTime: displayTime,
      alignment: _mapToastPosition(position),
    );
  }

  // ── Notification banner ──

  @override
  void showNotification({
    required String message,
    AppNotifyType type = AppNotifyType.success,
    Duration displayTime = const Duration(milliseconds: 3000),
  }) {
    SmartDialog.showNotify(
      msg: message,
      notifyType: _mapNotifyType(type),
      displayTime: displayTime,
    );
  }

  // ── Confirm dialog ──

  @override
  Future<bool> showConfirm({
    required String title,
    String? message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDangerousAction = false,
  }) async {
    var confirmed = false;

    await SmartDialog.show(
      clickMaskDismiss: true,
      builder: (context) {
        final theme = Theme.of(context);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 12),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppTextButton(
                    onPressed: () => SmartDialog.dismiss(),
                    label: cancelText,
                  ),
                  const SizedBox(width: 8),
                  if (isDangerousAction)
                    AppDangerButton(
                      onPressed: () {
                        confirmed = true;
                        SmartDialog.dismiss();
                      },
                      label: confirmText,
                    )
                  else
                    AppButton(
                      onPressed: () {
                        confirmed = true;
                        SmartDialog.dismiss();
                      },
                      label: confirmText,
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );

    return confirmed;
  }

  // ── Custom dialog ──

  @override
  Future<T?> showCustom<T>({
    required Widget Function(BuildContext context) builder,
    bool clickMaskDismiss = true,
    bool usePenetrate = false,
    Alignment alignment = Alignment.center,
    String? tag,
  }) async {
    T? result;

    await SmartDialog.show(
      clickMaskDismiss: clickMaskDismiss,
      usePenetrate: usePenetrate,
      alignment: alignment,
      tag: tag,
      builder: (context) => builder(context),
    );

    return result;
  }

  // ── Loading dialog ──

  @override
  void showLoading({String? message}) {
    SmartDialog.showLoading(msg: message ?? '');
  }

  @override
  void dismissLoading() {
    SmartDialog.dismiss(status: SmartStatus.loading);
  }

  // ── Attached dialog ──

  @override
  Future<T?> showAttached<T>({
    required BuildContext targetContext,
    required Widget Function(BuildContext context) builder,
    Alignment targetAlignment = Alignment.bottomCenter,
    Alignment followerAlignment = Alignment.topCenter,
    bool clickMaskDismiss = true,
    String? tag,
  }) async {
    await SmartDialog.showAttach(
      targetContext: targetContext,
      alignment: followerAlignment,
      clickMaskDismiss: clickMaskDismiss,
      tag: tag,
      builder: (context) => builder(context),
    );

    return null;
  }

  // ── Dismiss ──

  @override
  void dismissAll() {
    SmartDialog.dismiss(status: SmartStatus.allDialog);
    SmartDialog.dismiss(status: SmartStatus.allToast);
    SmartDialog.dismiss(status: SmartStatus.loading);
  }

  @override
  void dismiss({String? tag}) {
    SmartDialog.dismiss(tag: tag);
  }

  // ── Private mappers ──

  Alignment _mapToastPosition(AppToastPosition position) => switch (position) {
        AppToastPosition.top => Alignment.topCenter,
        AppToastPosition.center => Alignment.center,
        AppToastPosition.bottom => Alignment.bottomCenter,
      };

  NotifyType _mapNotifyType(AppNotifyType type) => switch (type) {
        AppNotifyType.success => NotifyType.success,
        AppNotifyType.failure => NotifyType.failure,
        AppNotifyType.warning => NotifyType.warning,
        AppNotifyType.alert => NotifyType.alert,
        AppNotifyType.error => NotifyType.error,
      };
}
```

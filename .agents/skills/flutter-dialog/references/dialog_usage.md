# Dialog Usage in Feature Code

Feature code imports `AppDialog` (the interface) — **never** `package:flutter_smart_dialog`.

## Toast

```dart
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/dialog/app_dialog.dart';

// From a widget
getIt<AppDialog>().showToast('Item saved successfully');

// Position variants
getIt<AppDialog>().showToast('Copied!', position: AppToastPosition.center);
getIt<AppDialog>().showToast(
  'Network error',
  position: AppToastPosition.top,
  displayTime: const Duration(seconds: 3),
);
```

## Notification banner

```dart
getIt<AppDialog>().showNotification(
  message: 'Profile updated',
  type: AppNotifyType.success,
);

getIt<AppDialog>().showNotification(
  message: 'Failed to save changes',
  type: AppNotifyType.error,
);

getIt<AppDialog>().showNotification(
  message: 'Your session will expire soon',
  type: AppNotifyType.warning,
  displayTime: const Duration(seconds: 5),
);
```

## Confirm dialog

```dart
// Standard confirm
final confirmed = await getIt<AppDialog>().showConfirm(
  title: 'Delete post?',
  message: 'This action cannot be undone.',
  confirmText: 'Delete',
  cancelText: 'Keep',
  isDangerousAction: true,
);

if (confirmed) {
  cubit.deletePost(postId);
}
```

## Loading dialog

```dart
final dialog = getIt<AppDialog>();

dialog.showLoading(message: 'Uploading...');
try {
  await repository.uploadFile(file);
  dialog.dismissLoading();
  dialog.showToast('Upload complete');
} catch (e) {
  dialog.dismissLoading();
  dialog.showNotification(
    message: 'Upload failed',
    type: AppNotifyType.error,
  );
}
```

## Custom dialog

```dart
await getIt<AppDialog>().showCustom(
  builder: (context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text('Payment successful!', style: theme.textTheme.titleLarge),
          const SizedBox(height: 24),
          AppButton(
            onPressed: () => SmartDialog.dismiss(),
            label: 'Done',
          ),
        ],
      ),
    );
  },
);
```

> **Note on custom dialog builders:** The `builder` callback runs inside `SmartDialog` overlay. If the builder needs to dismiss itself, import `SmartDialog.dismiss()` in the calling file **only if** that file is under `core/widgets/dialog/`. Otherwise, pass a dismiss callback from the wrapper.

## Attached dialog (tooltip / dropdown)

```dart
// In a widget — attach to the button's BuildContext
IconButton(
  onPressed: () {
    getIt<AppDialog>().showAttached(
      targetContext: context,
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'This is a tooltip',
          style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface),
        ),
      ),
    );
  },
  icon: const Icon(Icons.info_outline),
)
```

## Usage in BlocListener

Show dialogs from `BlocListener` — keep navigation and UI effects out of cubits.

```dart
BlocListener<CheckoutCubit, CheckoutState>(
  listenWhen: (prev, curr) => prev != curr,
  listener: (context, state) {
    final dialog = getIt<AppDialog>();

    switch (state) {
      case CheckoutSubmitting():
        dialog.showLoading(message: 'Processing payment...');
      case CheckoutSuccess():
        dialog.dismissLoading();
        dialog.showNotification(
          message: 'Payment successful!',
          type: AppNotifyType.success,
        );
        navigator(context).goHome();
      case CheckoutError(:final failure):
        dialog.dismissLoading();
        dialog.showNotification(
          message: failure.message,
          type: AppNotifyType.error,
        );
      default:
        break;
    }
  },
  child: const CheckoutForm(),
)
```

## Usage in Cubit (via callback)

Cubits should **not** call `AppDialog` directly — they have no `BuildContext` and should not own UI concerns. Use `BlocListener` in the widget layer. If you need to confirm an action mid-flow, pass a confirmation callback:

```dart
class PostCubit extends Cubit<PostState> {
  PostCubit(this._repository) : super(const PostInitial());

  final PostRepository _repository;

  /// [confirmDelete] is provided by the widget layer.
  Future<void> deletePost(
    int postId, {
    required Future<bool> Function() confirmDelete,
  }) async {
    final confirmed = await confirmDelete();
    if (!confirmed) return;

    emit(const PostDeleting());
    try {
      await _repository.deletePost(postId);
      emit(const PostDeleted());
    } on FailureException catch (e) {
      emit(PostError(e.failure));
    }
  }
}

// Widget layer — passes confirm callback
onPressed: () => cubit.deletePost(
  post.id,
  confirmDelete: () => getIt<AppDialog>().showConfirm(
    title: 'Delete post?',
    message: 'This action cannot be undone.',
    isDangerousAction: true,
  ),
),
```

## Custom dialog variants

### Info dialog (single action)

```dart
Future<void> showInfo({
  required String title,
  String? message,
  String buttonText = 'OK',
}) async {
  await SmartDialog.show(
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
            Text(title, style: theme.textTheme.titleLarge),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(message, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: AppButton(
                onPressed: () => SmartDialog.dismiss(),
                label: buttonText,
              ),
            ),
          ],
        ),
      );
    },
  );
}
```

Add this to `AppDialog` interface and `AppDialogImpl` when needed.

### Bottom sheet dialog

```dart
await getIt<AppDialog>().showCustom(
  alignment: Alignment.bottomCenter,
  builder: (context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // content
          const Text('Select an option'),
          // ... list tiles, buttons, etc.
        ],
      ),
    );
  },
);
```

## When to use which

| Scenario | Method | Example |
|---|---|---|
| Brief feedback after action | `showToast` | "Copied!", "Saved", "Sent" |
| Success / error / warning banner | `showNotification` | "Profile updated", "Upload failed" |
| Destructive action confirmation | `showConfirm` | Delete post, cancel subscription, sign out |
| Blocking async — **imperative** (one-off from listener) | `showLoading` + `dismissLoading` | Payment processing, file upload |
| Blocking async — **declarative** (driven by bloc state) | `LoadingOverlay` → [template-loading.md](template-loading.md) | Wrapping a form/page during submission |
| Rich custom content | `showCustom` | Custom form dialog, image preview, bottom sheet picker |
| Context-anchored popup | `showAttached` | Tooltip, dropdown, contextual menu |
| Dismiss everything | `dismissAll` | Session timeout, force logout |

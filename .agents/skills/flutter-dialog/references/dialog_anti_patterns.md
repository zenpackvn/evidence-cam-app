# Anti-Patterns — Dialogs

## 1. Showing dialogs from inside `build()`

```dart
// DON'T — build() can run many times, spawning duplicate dialogs
@override
Widget build(BuildContext context) {
  if (state is CheckoutError) {
    getIt<AppDialog>().showNotification(message: 'Error!', type: AppNotifyType.error);
  }
  return const CheckoutForm();
}

// DO — show dialogs from BlocListener, which fires once per state transition
BlocListener<CheckoutCubit, CheckoutState>(
  listenWhen: (prev, curr) => curr is CheckoutError,
  listener: (context, state) {
    getIt<AppDialog>().showNotification(message: 'Error!', type: AppNotifyType.error);
  },
  child: const CheckoutForm(),
)
```

## 2. Not dismissing loading dialogs on error

```dart
// DON'T — loading dialog stays visible forever if the request fails
dialog.showLoading(message: 'Saving...');
await repository.save(); // throws
dialog.dismissLoading();  // never reached

// DO — always dismiss in a finally block or handle both success and error paths
dialog.showLoading(message: 'Saving...');
try {
  await repository.save();
  dialog.dismissLoading();
  dialog.showToast('Saved');
} catch (e) {
  dialog.dismissLoading();
  dialog.showNotification(message: 'Save failed', type: AppNotifyType.error);
}
```

## 3. Using `showDialog` directly instead of `AppDialog` wrapper

```dart
// DON'T — bypasses the wrapper rule, couples feature code to Material/flutter_smart_dialog
showDialog(
  context: context,
  builder: (_) => AlertDialog(title: Text('Delete?'), /* ... */),
);

// DO — use AppDialog so the dialog implementation is centralized and swappable
final confirmed = await getIt<AppDialog>().showConfirm(
  title: 'Delete?',
  message: 'This cannot be undone.',
  isDangerousAction: true,
);
```

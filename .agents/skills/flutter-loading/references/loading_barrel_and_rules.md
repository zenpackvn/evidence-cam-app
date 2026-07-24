# Loading — Barrel Export, When-to-Use Table, Rules, and Anti-Patterns

## Barrel export — `lib/src/core/widgets/loading/loading.dart`

```dart
export 'app_loading_indicator.dart';
export 'app_shimmer.dart';
export 'loading_button.dart';
export 'loading_overlay.dart';
export 'screen_loading.dart';
export 'super_list_view.dart';
```

---

## When to use which widget

| Scenario | Widget |
|---|---|
| Full list lifecycle (shimmer → error/empty → data+refresh) | `SuperListView` |
| Shimmer skeleton for any widget | `AppShimmer` / `ShimmerListSkeleton` |
| Page waiting for non-list data | `ScreenLoading` |
| Blocking operation — declarative (driven by bloc state) | `LoadingOverlay` |
| Blocking operation — imperative (one-off) | `AppDialog.showLoading()` |
| Button with async action | `LoadingButton` |
| Custom inline indicator | `AppLoadingIndicator` |

---

## Rules

- **Wrapper rule**: Only `app_loading_indicator.dart` imports `flutter_spinkit`. Only `super_list_view.dart` imports `pullex`. Only `app_shimmer.dart` imports `shimmer_animation`. To swap any package, edit one file.
- **Use theme colors**: Always derive spinner color from `Theme.of(context).colorScheme`, never hardcode.
- **Disable interaction during loading**: `LoadingButton` disables `onPressed` when loading. `LoadingOverlay` blocks taps on the underlying content.
- **Model loading in state, not in widgets**: The cubit/bloc emits a loading state; the widget reacts. Don't manage `isLoading` booleans inside widgets.
- **`RefreshController` belongs in `SuperListView`**: It is a UI concern from `pullex`. The cubit must not import or reference it. `SuperListView` owns, signals, and disposes the controller internally via `didUpdateWidget`.
- **No hard strings**: Every user-facing label uses `context.tr('key')`. Never write `Text('No items found')` or `Text('Retry')`.
- **No magic numbers**: All padding and sizing reference `AppSpacing.*`. Never write `EdgeInsets.symmetric(vertical: 16)`.

---

## Anti-Patterns

### 1. Using CircularProgressIndicator directly

```dart
// DON'T — bypasses the wrapper rule; changing the spinner means editing every file
const Center(child: CircularProgressIndicator())

// DO — use the app-owned wrapper; swap the spinner library in one place
const Center(child: AppLoadingIndicator())
```

### 2. Not handling error/empty states (infinite spinner)

```dart
// DON'T — user sees a spinner forever on failure
builder: (context, state) => switch (state) {
  PostListLoading() => const ScreenLoading(),
  PostListLoaded(:final posts) => ListView(children: [/* ... */]),
  _ => const SizedBox.shrink(), // error and empty silently swallowed
}

// DO — handle all states, or use SuperListView which covers them all
SuperListView<Post>(
  state: state,
  onRetry: cubit.load,
  itemBuilder: /* ... */,
  // ...
)
```

### 3. Mixing declarative and imperative loading for the same operation

```dart
// DON'T — using LoadingOverlay AND AppDialog.showLoading() for the same flow
BlocConsumer<CheckoutCubit, CheckoutState>(
  listener: (context, state) {
    if (state is CheckoutSubmitting) dialog.showLoading(); // imperative
  },
  builder: (context, state) {
    return LoadingOverlay(
      isLoading: state is CheckoutSubmitting, // declarative
      child: const CheckoutForm(),
    );
  },
)

// DO — pick one approach per operation
// Declarative (in-tree, driven by bloc state):
LoadingOverlay(isLoading: state is CheckoutSubmitting, child: const CheckoutForm())

// OR imperative (one-off from BlocListener):
listener: (context, state) {
  if (state is CheckoutSubmitting) dialog.showLoading();
  if (state is CheckoutSuccess) dialog.dismissLoading();
}
```

---
name: flutter-common-widgets
description: Use this skill when building Flutter shared/common widgets — app bars, buttons (primary, secondary, text, icon, loading), text fields, password fields, search fields, cards, list tiles, dividers, badges, chips, tags, avatars, cached images, empty states, error states, spacers, or any reusable UI component that should live in core/widgets/.
---

# Flutter Common Widgets

Full reference: [`template.md`](references/template.md)

## Mandatory replacement table

Never use raw Material widgets in feature code — use the App equivalent:

| Raw (banned in features) | App replacement |
|---|---|
| `AppBar(...)` | `AppTopBar` / `AppSliverTopBar` |
| `ElevatedButton(...)` | `AppPrimaryButton` |
| `OutlinedButton(...)` | `AppSecondaryButton` |
| `TextButton(...)` | `AppTextButton` |
| `FilledButton(...)` | `AppPrimaryButton` |
| `TextFormField(...)` | `AppTextField` / `AppPasswordField` / `AppSearchField` |
| `Card(...)` in feature | `AppCard` |
| `ListTile(...)` | `AppListTile` |
| `Divider(...)` | `AppDivider` |
| `SizedBox(height: N)` spacer | `AppSpacing.vXs` etc. or `VerticalSpace` |
| `CircleAvatar(...)` | `AppAvatar` |
| `Chip(...)` | `AppStatusChip` / `AppTag` |
| `Badge(...)` | `AppBadge` |
| `CircularProgressIndicator(...)` | `AppLoadingIndicator` |
| `LinearProgressIndicator(...)` | AppLoadingIndicator variant |
| `SnackBar` / `ScaffoldMessenger` | `AppDialog.showToast()` |
| raw empty `Column+Icon+Text` | `AppEmptyState` |
| raw error `Column+Icon+Text` | `AppErrorState` |
| `Image.network(...)` | `AppCachedImage` |

## Key rules

- All app widgets read colors/sizes from `AppTheme`/`AppColors`/`AppSpacing` — never hardcode.
- App widgets are in `lib/src/core/widgets/`. Feature-private widgets stay in `features/<feature>/presentation/widgets/`.
- Before writing a new widget, check if an App equivalent already exists.

## DI context

Most App widgets are **pure** — constructed inline with `const` or `new`, no DI needed:

```dart
const AppPrimaryButton(onPressed: _submit, child: Text('Save'))
```

Widgets that depend on a service (e.g., `AppCachedImage` wraps `cached_network_image`) are self-contained — the wrapper import is internal. Feature code just passes data:

```dart
AppCachedImage(url: user.avatarUrl, width: 48, height: 48)
```

Only `AppDialog` is DI-registered (as a singleton via `flutter-di`) because it needs `BuildContext`-free access for cubit-driven toasts/confirms.

## Co-load with

- `flutter-theme` — tokens used by every widget
- `flutter-loading` — `AppEmptyState`, `AppErrorState`, `AppLoadingIndicator`
- `flutter-dialog` — `AppDialog` for snack-bar replacements
- `flutter-di` — `AppDialog` registered as singleton; all other widgets are pure (no DI)

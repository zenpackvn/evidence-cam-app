# Template — Common Widgets

Reusable app-wide widgets that build on top of `AppTheme` tokens. Part of the project layout in [template-app-shell.md](template-app-shell.md).

Every widget here reads styling from `Theme.of(context)` — which is configured by [template-theme.md](template-theme.md). No hardcoded colors, spacing, or text styles. No duplication of what `ThemeData` already provides.

Only `app_cached_image.dart` imports a third-party package (`cached_network_image`). The wrapper rule applies to it.

## What lives elsewhere — do not duplicate

| Concern | Already in | Template |
|---|---|---|
| Button with loading spinner | `LoadingButton`, `LoadingOutlinedButton` | [template-loading.md](template-loading.md) |
| Dialogs, toasts, confirm popups | `AppDialog` | [template-dialog.md](template-dialog.md) |
| List shimmer, empty, error states | `SuperListView` | [template-loading.md](template-loading.md) |
| Full-screen loading | `ScreenLoading` | [template-loading.md](template-loading.md) |
| Modal loading overlay | `LoadingOverlay` | [template-loading.md](template-loading.md) |
| Button/input/card/divider/chip base styling | `AppTheme` component themes | [template-theme.md](template-theme.md) |

## Widget Reference Files

Each widget has its own file. Load only the file(s) relevant to the task.

| Widget(s) | File |
|---|---|
| `AppTopBar` | [app_top_bar.md](app_top_bar.md) |
| `AppSearchBar`, `AppSliverBar` | [app_search_bar.md](app_search_bar.md) |
| `AppButton`, `AppOutlinedButton`, `AppTextButton`, `AppDangerButton`, `AppIconButton` | [app_button.md](app_button.md) |
| `AppTextField` | [app_text_field.md](app_text_field.md) |
| `AppPasswordField` | [app_password_field.md](app_password_field.md) |
| `AppSearchField` | [app_search_field.md](app_search_field.md) |
| `AppTextArea` | [app_text_area.md](app_text_area.md) |
| `AppCard` | [app_card.md](app_card.md) |
| `AppSelectableCard` | [app_selectable_card.md](app_selectable_card.md) |
| `AppListTile` | [app_list_tile.md](app_list_tile.md) |
| `AppDivider`, `AppVerticalDivider` | [app_divider.md](app_divider.md) |
| `AppSectionHeader` | [app_section_header.md](app_section_header.md) |
| `AppBadge` | [app_badge.md](app_badge.md) |
| `AppStatusChip` | [app_status_chip.md](app_status_chip.md) |
| `AppTag` | [app_tag.md](app_tag.md) |
| `AppAvatar` | [app_avatar.md](app_avatar.md) |
| `AppCachedImage` | [app_cached_image.md](app_cached_image.md) |
| `AppEmptyState` | [app_empty_state.md](app_empty_state.md) |
| `AppErrorState` | [app_error_state.md](app_error_state.md) |
| `AppKeyboardDismisser` | [app_keyboard_dismisser.md](app_keyboard_dismisser.md) |
| `AppSpacerV`, `AppSpacerH` | [app_spacer.md](app_spacer.md) |
| Barrel export (`common.dart`) | [common_barrel.md](common_barrel.md) |

## Folder structure

```text
lib/src/core/widgets/
  common/
    app_top_bar.dart
    app_search_bar.dart
    app_button.dart
    app_text_field.dart
    app_password_field.dart
    app_search_field.dart
    app_text_area.dart
    app_card.dart
    app_selectable_card.dart
    app_list_tile.dart
    app_divider.dart
    app_section_header.dart
    app_badge.dart
    app_status_chip.dart
    app_tag.dart
    app_avatar.dart
    app_cached_image.dart
    app_empty_state.dart
    app_error_state.dart
    app_keyboard_dismisser.dart
    app_spacer.dart
    common.dart                    ← Barrel export
```

## `pubspec.yaml` additions

```yaml
dependencies:
  cached_network_image: 3.4.1    # exact version, never ^
  keyboard_dismisser: 3.0.0      # exact version, never ^
```

---

## Rules

- **MANDATORY REPLACEMENT**: ALL Dart files in the project (including `core/widgets/`) MUST use the App widget, not the raw Material widget. If a common widget exists for it, the raw version is banned everywhere — not just in `features/`.

| Raw Material widget (BANNED in features) | Use instead |
|---|---|
| `AppBar(...)` | `AppTopBar(title: ...)` |
| `TextFormField(...)` / `TextField(...)` | `AppTextField(...)` |
| `TextField(obscureText: true, ...)` | `AppPasswordField(...)` |
| `TextFormField(maxLines: >1, ...)` | `AppTextArea(...)` |
| `FilledButton(...)` / `ElevatedButton(...)` | `AppButton(label: ..., onPressed: ...)` |
| `FilledButton` with `errorColor` / destructive action | `AppDangerButton(label: ..., onPressed: ...)` |
| `OutlinedButton(...)` | `AppOutlinedButton(label: ..., onPressed: ...)` |
| `TextButton(...)` | `AppTextButton(label: ..., onPressed: ...)` |
| `IconButton(...)` | `AppIconButton(icon: ..., onPressed: ...)` |
| `Card(...)` | `AppCard(child: ...)` |
| `ListTile(...)` | `AppListTile(title: ...)` |
| `Divider(...)` | `AppDivider(...)` |
| `SizedBox(height: AppSpacing.*)` | `AppSpacerV.md()` etc. |
| `SizedBox(width: AppSpacing.*)` | `AppSpacerH.md()` etc. |
| `CircleAvatar(...)` | `AppAvatar(...)` |
| `CachedNetworkImage(...)` | `AppCachedImage(imageUrl: ...)` |
| `Badge(...)` | `AppBadge(child: ...)` |
| `Chip(...)` | `AppStatusChip(...)` or `AppTag(...)` |
| `SearchBar(...)` / `SearchAnchor(...)` | `AppSearchBar(...)` or `AppSearchField(...)` |
| `GestureDetector(child: Text(...))` | `AppTextButton(label: ..., onPressed: ...)` |
| `Column([Icon(...), SizedBox(...), Text(...)])` as empty state | `AppEmptyState(...)` |
| `Column([Icon(error_outline), ..., AppButton(...)])` as error state | `AppErrorState(...)` |

**Exception**: `Scaffold`, `Column`, `Row`, `Padding`, `Container`, `Text`, `Icon`, `Form`, `Navigator`, layout widgets, and Material widgets with no App equivalent are fine.

- **All styling from AppTheme**: Widgets inherit colors, shapes, text styles from `Theme.of(context)`. No hardcoded `Color(0xFF...)`, magic-number padding, or inline `TextStyle(fontSize: ...)`.
- **Spacing from `AppSpacing`**: Use `AppSpacing.md`, `AppSpacerV.md()`, etc. Never `SizedBox(height: 16)` with magic numbers.
- **Colors from `AppColors`**: Semantic colors (`error`, `success`, `warning`, `info`, `disabled`) come from the central token file.
- **Wrapper rule**: Only `app_cached_image.dart` imports `cached_network_image`. Only `app_keyboard_dismisser.dart` imports `keyboard_dismisser`. To swap a library, edit one file.
- **Don't duplicate**: `LoadingButton` lives in [template-loading.md](template-loading.md). `AppDialog` lives in [template-dialog.md](template-dialog.md). `SuperListView` empty/error states live in [template-loading.md](template-loading.md). This template covers everything else.
- **Prefer composition**: Use `AppCard` + `AppListTile` + `AppStatusChip` together rather than building a mega-widget.
- **State in cubit, not widget**: Buttons, cards, fields reflect state emitted by cubits. Don't manage `isSelected` booleans in widget state unless it's purely local UI concern (like password visibility).
- **Localize labels**: All user-visible strings (`title`, `hint`, `actionLabel`, etc.) should go through the localization layer in production code.

## ⚠️ Common Mistakes

> These are the most frequent common-widgets bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **Using raw `FilledButton` / `ElevatedButton` instead of `AppButton`** | Inconsistent button height, shape, or color across features; the design system token changes don't propagate | Replace every `FilledButton(...)` and `ElevatedButton(...)` with `AppButton(label: ..., onPressed: ...)` — raw Material buttons are banned everywhere in the project |
| 2 | **Hardcoded colors or `Color(0xFF...)` literals in widget files** | Buttons or containers ignore dark mode; design token updates require manual hunt-and-replace across files | Use `Theme.of(context).colorScheme.*` for dynamic colors and `AppColors.*` for semantic tokens; no inline `Color(0xFF...)` |
| 3 | **Magic-number spacing (`SizedBox(height: 16)`)** | Spacing drifts across features; a spacing-scale update requires manual grep | Use `AppSpacerV.md()` / `AppSpacerH.sm()` or `const EdgeInsets.all(AppSpacing.md)`; never hardcode pixel values |
| 4 | **Importing `cached_network_image` outside `app_cached_image.dart`** | Wrapper rule violated — swapping the image cache library now requires editing every importing file | Only `app_cached_image.dart` may import `cached_network_image`; all other files use `AppCachedImage(imageUrl: ...)` |
| 5 | **Using `AppButton` for loading state instead of `LoadingButton`** | Spinner must be manually managed in widget state; button does not disable itself during async operation | Use `LoadingButton` from `template-loading.md` for any button that triggers an async action |
| 6 | **Building a custom empty/error column instead of `AppEmptyState` / `AppErrorState`** | Empty and error UI diverges across features; retry callback wiring is duplicated | Replace ad-hoc `Column([Icon, SizedBox, Text, AppButton])` empty/error patterns with `AppEmptyState(message: ...)` and `AppErrorState(message: ..., onRetry: ...)` |
| 7 | **Common widget imports a feature-specific model** | Coupling core widgets to a feature prevents reuse; the widget cannot be used in other features without pulling in unrelated dependencies | Keep common widgets generic — accept primitive parameters (`String`, `bool`, enum) not domain entities; feature-specific compositions belong in the feature folder |
| 8 | **Using raw `TextField` / `TextFormField` instead of `AppTextField` / `AppPasswordField`** | Field styling (border, label, error text) deviates from the design system; obscure-text toggle must be rebuilt per-field | Use `AppTextField(label: ..., hint: ...)` for text input and `AppPasswordField(label: ...)` for password input everywhere in the project |

## Quick Summary

- **Raw Material widgets are banned** — any widget in the table above has an `App*` replacement; use it everywhere, not just in features.
- **Wrapper rule**: only `app_cached_image.dart` imports `cached_network_image`; only `app_keyboard_dismisser.dart` imports `keyboard_dismisser`. To swap a package, edit one file.
- **All styling from tokens** — colors from `AppColors.*` or `Theme.of(context).colorScheme.*`, spacing from `AppSpacing.*`, text styles from `AppTypography.*` or `Theme.of(context).textTheme.*`. No hardcoded values anywhere.
- **Loading state → `LoadingButton`**, not `AppButton` — async actions belong in `flutter-loading`, not here.
- **Empty/error states → `AppEmptyState` / `AppErrorState`** — never build ad-hoc `Column([Icon, SizedBox, Text, Button])` patterns.
- **Common widgets are generic** — accept primitives or enums, never domain entities. Feature-specific compositions belong in the feature folder.
- **State in cubit, not widget** — `isSelected`, `isLoading`, and similar flags are emitted by the cubit; widgets only read and render them.
- **Don't duplicate** — `LoadingButton`, `AppDialog`, and `SuperListView` states live in their own skills. This skill covers everything else.

## Anti-Patterns

### 1. Hardcoding colors/spacing instead of using AppTheme tokens

```dart
// DON'T
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Color(0xFFF5F5F5),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text('Hello', style: TextStyle(fontSize: 14, color: Colors.grey)),
)

// DO
Container(
  padding: const EdgeInsets.all(AppSpacing.md),
  decoration: BoxDecoration(
    color: theme.colorScheme.surfaceContainerHighest,
    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
  ),
  child: Text('Hello', style: theme.textTheme.bodyMedium),
)
```

### 2. Duplicating widget code instead of using shared components

```dart
// DON'T — every feature builds its own card
Card(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  child: Padding(padding: EdgeInsets.all(16), child: content),
)

// DO
AppCard(child: content, onTap: () {})
```

### 3. Making common widgets too specific to one feature

```dart
// DON'T — a "common" widget that imports feature-specific models
import '../../features/orders/domain/order.dart';
class OrderStatusCard extends StatelessWidget {
  final Order order; // ties core widget to a feature
}

// DO — keep common widgets generic; feature-specific compositions live in the feature folder
AppStatusChip(label: 'Active', status: AppChipStatus.active)
```

## Cross-references

- [flutter-theme](../../flutter-theme/references/template.md) — `AppColors`, `AppSpacing`, `AppTypography` tokens used by every widget here
- [flutter-loading](../../flutter-loading/references/template.md) — `LoadingButton`, `AppEmptyState`, `AppErrorState`, `SuperListView` (do not duplicate here)
- [flutter-dialog](../../flutter-dialog/references/template.md) — `AppDialog` for toasts and confirms (snack-bar replacements)
- [flutter-di](../../flutter-di/references/template.md) — `AppCachedImage` wrapper registered as singleton; other widgets are pure

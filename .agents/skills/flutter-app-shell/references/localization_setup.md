# App Shell — Localization Setup

Uses `flutter_localization` with JSON assets. Initialize once in bootstrap, wire into app root.

## Rules

- Keep translation keys in `lib/src/core/localization/app_locale.dart`.
- Keep translated values in `assets/i18n/<language_code>.json`.
- Call `FlutterLocalization.instance.ensureInitialized()` in `bootstrap()` before `runApp()`.
- Wrap `FlutterLocalization` behind a `LocalizationService` interface for runtime locale switching.
- Use stable keys grouped by feature: `common_save`, `home_title`, `post_detail_title`.
- Route every user-visible string through the localization layer.
- Use parameterized messages, plurals, and selects instead of string concatenation.
- Use locale-aware formatting for dates, times, numbers, currencies.

**Full guide**: See [template-localization.md](template-localization.md) for wrapper interface, plurals, RTL support, dynamic switching, date/number/currency formatting, and testing.

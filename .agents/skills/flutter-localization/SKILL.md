---
name: flutter-localization
description: Use this skill when working on Flutter localization or internationalization — LocalizationService, flutter_localization wrapper, translation keys, JSON translation files, plural strings, RTL support, locale switching, dynamic locale change, date formatting, number formatting, currency formatting, intl package, or adding/modifying any user-facing text.
---

# Flutter Localization

Full reference: [`template.md`](references/template.md)

## Key rules

- `LocalizationService` is the app-owned interface. **Never import `flutter_localization`** outside `localization_service_impl.dart`.
- All user-facing strings live in `assets/i18n/<locale>.json`. **No hardcoded strings** in widget or cubit code.
- Translation key access: `context.tr('key')` in build methods (auto-rebuilds on locale change via `context.watch<LocaleCubit>()`). Never call `getIt<LocalizationService>().translate()` directly in widgets — use `context.tr()`.
- Plural support: keys are `key_zero`, `key_one`, `key_other`. Call `localizationService.plural('key', count)`.
- Dynamic locale switch: `LocaleCubit.setLanguage(locale)` → `safeEmit(locale)` → all widgets calling `context.tr()` rebuild (via `context.watch<LocaleCubit>()`). Provide `LocaleCubit` at the app root. `MaterialApp` rebuilds via `BlocBuilder<LocaleCubit, Locale>`.
- RTL: `LocalizationService.isRtl` → use `Directionality` widget or `TextDirection.rtl` for affected widgets.
- Date/number/currency formatting: use `AppFormatter` (wraps `intl`) — never `DateFormat(...)` directly in widgets.
- Validator error messages must use localization keys, never raw strings.
- Add new locales: add `<locale>.json`, register locale in `LocalizationServiceImpl`, declare in `MaterialApp.router`.

## Files

```
assets/i18n/
  en.json    ← source of truth for keys
  vi.json    ← secondary locale
lib/src/core/localization/
  localization_service.dart          ← interface
  localization_service_impl.dart     ← only file importing flutter_localization
  locale_cubit.dart                  ← Cubit<Locale> — drives reactive locale switching
  app_formatter.dart                 ← date/number/currency formatters (wraps intl)
```

## Co-load with

- `flutter-di` — `LocalizationService` + `AppFormatter` + `LocaleCubit` registration
- `flutter-storage` — persist selected locale in `KeyValueStore`
- `flutter-theme` — locale affects text direction
- `flutter-base-classes` — `LocaleCubit` uses `SafeEmitMixin`

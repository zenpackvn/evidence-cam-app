# Template — Localization

Full internationalization (i18n) and localization (l10n): `LocalizationService` wrapper, JSON/in-code translation maps, plurals, parameterized messages, RTL support, dynamic locale switching, date/number/currency formatting, and testing.

## Topic Files

| Topic | File |
|---|---|
| `LocalizationService` interface + `LocalizationServiceImpl` (flutter_localization wrapper) | [localization_service.md](localization_service.md) |
| `LocaleCubit` + `AppLocale` translation key constants | [locale_cubit_and_keys.md](locale_cubit_and_keys.md) |
| DI registration, app root integration, dynamic locale switching, JSON asset alternative | [di_and_app_integration.md](di_and_app_integration.md) |
| `LocalizationX` extension (`context.tr`) + `AppFormatter` (intl wrapper) | [extensions_and_formatter.md](extensions_and_formatter.md) |
| RTL support — directional layouts, icon flipping, `RtlContext` extension | [rtl_support.md](rtl_support.md) |
| Testing — `FakeLocalizationService`, unit tests, widget tests | [testing.md](testing.md) |
| Rules and anti-patterns | [rules_and_antipatterns.md](rules_and_antipatterns.md) |

## ⚠️ Common Mistakes

> These are the most frequent localization bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **Importing `flutter_localization` or `intl` outside the designated wrapper files** | Violates the wrapper rule — switching translation providers requires editing feature code | Only `localization_service_impl.dart` imports `flutter_localization`; only `app_formatter.dart` imports `intl`; all other code uses the app-owned interfaces |
| 2 | **Hardcoded user-visible strings in widgets** | Strings don't change when locale switches; review comment flags every hardcoded literal | Every user-visible string goes through `context.tr('key')` or `LocalizationService.translate('key')` — no bare string literals in widgets |
| 3 | **Concatenating translated strings with `+` or string interpolation** | Breaks in languages with different word order (e.g., Arabic, Vietnamese); `'\$greeting \$name'` is always wrong | Use `context.trParams('key', params: {'name': name})` or `translateWithNamedParams` so the translator controls word order |
| 4 | **Branching plurals in widget code with `count == 1 ? … : …`** | Fails for Arabic (6 plural forms), Russian (3 forms), and other languages with complex plural rules | Use `context.trPlural('item_count', count)` with `_zero`, `_one`, `_other` suffixes in the JSON assets |
| 5 | **Using `EdgeInsets.only(left/right)` or `Alignment.centerLeft/Right` for layout** | Layout breaks in RTL locales — padding and alignment are mirror-inverted | Use `EdgeInsetsDirectional.only(start/end)` and `AlignmentDirectional.centerStart/End` throughout |
| 6 | **Locale choice not persisted across app restarts** | App resets to the default locale every launch, ignoring the user's preference | Store the selected locale code in `KeyValueStore` and restore it in `LocaleCubit` during bootstrap |
| 7 | **Hand-formatting dates, numbers, or currencies** | Displays `4/16/2026` in a locale that expects `16 Apr 2026`; decimals use wrong separator | Use `context.formatter.dateShort(d)`, `.currencyFormat(amount)`, etc. from `AppFormatter` — the `intl` wrapper handles all locale rules |
| 8 | **Adding a translation key to one language file without updating all others** | Missing keys render the raw key string (e.g., `"new_feature_title"`) to the user in other locales | When adding any key to `en.json`, add a matching entry to every other language file (`vi.json`, `ar.json`, …) in the same commit |

## Quick Summary

- **Wrapper rule**: Only `localization_service_impl.dart` imports `flutter_localization`. Only `app_formatter.dart` imports `intl`. All other code uses the app-owned interfaces.
- **No hardcoded user-visible strings** — every string goes through `context.tr()`.
- **No string concatenation for translated text** — use `translateWithParams` / `translateWithNamedParams` to let translators control word order.
- **Plurals via suffix convention** — `_zero`, `_one`, `_other`. Never branch `count == 1 ? … : …` in widget code.
- **RTL via directional APIs** — `EdgeInsetsDirectional`, `AlignmentDirectional`. Never hardcode `left`/`right` for layout.
- **Persist locale choice in `KeyValueStore`** — so the app remembers language across restarts.
- **Use `intl` for all date/number/currency formatting** — never hand-format.

## Folder Structure

```text
lib/src/
  core/
    localization/
      localization_service.dart          ← App-owned interface
      localization_service_impl.dart     ← flutter_localization wrapper (only file that imports it)
      locale_cubit.dart                  ← Cubit<Locale> — drives reactive locale switching
      app_locale.dart                    ← Translation key constants
      localization_extensions.dart       ← context.tr(), context.trParams(), context.trPlural()
      app_formatter.dart                 ← intl wrapper (only file that imports intl)
assets/
  i18n/
    en.json                              ← English (source of truth)
    vi.json                              ← Vietnamese
    ar.json                              ← Arabic (RTL example)
```

## Cross-references

- [template-di.md](template-di.md) — registration order and lifetimes
- [template-app-shell.md](template-app-shell.md) — bootstrap order
- [template-storage.md](template-storage.md) — `KeyValueStore` for persisting locale choice
- [template-theme.md](template-theme.md) — text scaling, responsive layout

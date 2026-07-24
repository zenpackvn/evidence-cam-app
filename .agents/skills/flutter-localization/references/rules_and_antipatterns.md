# Localization — Rules and Anti-Patterns

## Rules

1. **Wrapper rule applies**: Only `localization_service_impl.dart` imports `flutter_localization`. Only `app_formatter.dart` imports `intl`. All other code uses `LocalizationService` and `AppFormatter` interfaces.
2. **No hardcoded user-visible strings**: Every string the user sees goes through `context.tr()` or `LocalizationService.translate()`.
3. **No string concatenation for translated text**: Use `translateWithParams` or `translateWithNamedParams` instead of `'$greeting $name'`.
4. **Plurals use the suffix convention**: `_zero`, `_one`, `_other`. Never use `count == 1 ? singular : plural` in widget code.
5. **Use directional-aware APIs**: `EdgeInsetsDirectional`, `AlignmentDirectional`, `TextDirection`-aware widgets. Never hardcode `left`/`right` for layout.
6. **Persist locale choice**: Store in `KeyValueStore` so the app remembers the user's language across restarts.
7. **Use `intl` for date/number/currency formatting**: Never hand-format dates or currencies. Locale rules are complex (comma vs period for decimals, date order, RTL digits).
8. **Keep translations in sync**: When adding a key to one language, add it to all languages immediately. Missing keys return the raw key string.
9. **Test with RTL**: If the app supports any RTL language, run the app in that locale and verify layout doesn't break.
10. **Register before features**: `LocalizationService` goes in core DI, registered after storage but before any feature module that needs translations.

---

## Anti-Patterns

### DON'T — Concatenate translated strings

```dart
// BAD: breaks in languages with different word order
final message = '${l10n.translate('you_have')} $count ${l10n.translate('items')}';
```

### DO — Use parameterized messages

```dart
// GOOD: translator controls word order
final message = l10n.translateWithNamedParams(
  'order_summary',
  namedParams: {'count': '$count', 'item': itemName},
);
// en: "You ordered 3 books."
// vi: "Bạn đã đặt 3 sách."
// ar: ".كتب 3 لقد طلبت"
```

---

### DON'T — Hardcode directional padding

```dart
// BAD: breaks in RTL
Padding(padding: EdgeInsets.only(left: 16, right: 8))
```

### DO — Use directional insets

```dart
// GOOD: automatically correct in both LTR and RTL
Padding(padding: EdgeInsetsDirectional.only(start: 16, end: 8))
```

---

### DON'T — Format dates manually

```dart
// BAD: wrong for non-US locales
final date = '${d.month}/${d.day}/${d.year}';
```

### DO — Use locale-aware formatting

```dart
// GOOD: respects locale conventions
final date = context.formatter.dateShort(d);
// en: "Apr 16, 2026"
// vi: "16 thg 4, 2026"
// ar: "١٦ أبريل ٢٠٢٦"
```

---

### DON'T — Branch plurals in widget code

```dart
// BAD: doesn't handle zero, dual, or complex plural rules (Arabic has 6 forms!)
Text(count == 1 ? '1 item' : '$count items')
```

### DO — Use the plural system

```dart
// GOOD: handles all plural forms per locale
Text(context.trPlural('item_count', count))
```

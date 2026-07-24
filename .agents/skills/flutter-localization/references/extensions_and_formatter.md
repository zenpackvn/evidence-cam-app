# Localization — Extensions and AppFormatter

## Extension for clean widget access — `lib/src/core/localization/localization_extensions.dart`

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../di/service_locator.dart';
import 'locale_cubit.dart';
import 'localization_service.dart';
import 'app_formatter.dart';

extension LocalizationX on BuildContext {
  LocalizationService get l10n => getIt<LocalizationService>();
  AppFormatter get formatter => getIt<AppFormatter>();

  /// Shorthand: context.tr('home_title')
  /// Calls watch<LocaleCubit>() so this widget rebuilds on locale change.
  String tr(String key) {
    watch<LocaleCubit>(); // registers rebuild dependency on locale change
    return l10n.translate(key);
  }

  /// Shorthand: context.trParams('greeting', params: ['Alice'])
  String trParams(String key, {required List<String> params}) {
    watch<LocaleCubit>();
    return l10n.translateWithParams(key, params: params);
  }

  /// Shorthand: context.trPlural('item_count', 5)
  String trPlural(String key, int count) {
    watch<LocaleCubit>();
    return l10n.plural(key, count);
  }
}
```

### Usage in widgets

```dart
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      Text(context.tr('home_title')),
      Text(context.trParams('common_greeting', params: [userName])),
      Text(context.trPlural('item_count', items.length)),
      Text(context.formatter.dateShort(createdAt)),
      Text(context.formatter.currency(price, symbol: 'VND')),
    ],
  );
}
```

---

## AppFormatter — `lib/src/core/localization/app_formatter.dart`

The **only file** that imports `package:intl`. Wraps all date, number, and currency formatting.

```dart
import 'package:intl/intl.dart';
import 'localization_service.dart';

/// Locale-aware formatting utilities.
/// Wraps `intl` package — only this file imports it.
class AppFormatter {
  AppFormatter({required LocalizationService localizationService})
      : _l10n = localizationService;

  final LocalizationService _l10n;

  String _locale() => _l10n.currentLocale.languageCode;

  // ── Dates ──────────────────────────────────────────────

  /// "Apr 16, 2026"
  String dateShort(DateTime date) =>
      DateFormat.yMMMd(_locale()).format(date);

  /// "Thursday, April 16, 2026"
  String dateFull(DateTime date) =>
      DateFormat.yMMMMEEEEd(_locale()).format(date);

  /// "2:30 PM" or "14:30" depending on locale
  String time(DateTime date) =>
      DateFormat.jm(_locale()).format(date);

  /// "Apr 16, 2026 2:30 PM"
  String dateTime(DateTime date) =>
      DateFormat.yMMMd(_locale()).add_jm().format(date);

  /// Relative: "2 hours ago", "yesterday", "3 days ago"
  String relativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return _l10n.translate('time_just_now');
    if (diff.inMinutes < 60) {
      return _l10n.plural('time_minutes_ago', diff.inMinutes);
    }
    if (diff.inHours < 24) {
      return _l10n.plural('time_hours_ago', diff.inHours);
    }
    if (diff.inDays < 7) {
      return _l10n.plural('time_days_ago', diff.inDays);
    }
    return dateShort(date);
  }

  // ── Numbers ────────────────────────────────────────────

  /// "1,234,567"
  String number(num value) =>
      NumberFormat.decimalPattern(_locale()).format(value);

  /// "1,234.56"
  String decimal(num value, {int decimalDigits = 2}) =>
      NumberFormat.decimalPatternDigits(
        locale: _locale(),
        decimalDigits: decimalDigits,
      ).format(value);

  /// "45%"
  String percent(double value) =>
      NumberFormat.percentPattern(_locale()).format(value);

  // ── Currency ───────────────────────────────────────────

  /// "$1,234.56" / "1.234,56 €" depending on locale + currency
  String currency(num value, {String symbol = 'USD'}) =>
      NumberFormat.currency(locale: _locale(), name: symbol).format(value);

  /// "1,234.56 VND" — compact with custom symbol
  String currencyCompact(num value, {String symbol = 'USD'}) =>
      NumberFormat.compactCurrency(locale: _locale(), name: symbol)
          .format(value);
}
```

# Localization — Service Interface and Implementation

## Interface — `lib/src/core/localization/localization_service.dart`

```dart
import 'dart:ui';

/// App-owned localization contract.
/// No widget, cubit, or repository imports flutter_localization directly.
abstract interface class LocalizationService {
  /// Currently active locale.
  Locale get currentLocale;

  /// All locales the app supports.
  List<Locale> get supportedLocales;

  /// Localization delegates for MaterialApp.
  Iterable<LocalizationsDelegate<dynamic>> get delegates;

  /// Switch locale at runtime. Persists the choice.
  Future<void> setLocale(Locale locale);

  /// Translate a key. Returns the key itself if no translation found.
  String translate(String key);

  /// Translate with positional parameters.
  /// Example: translate('greeting', params: ['Alice']) → "Hello, Alice!"
  String translateWithParams(String key, {required List<String> params});

  /// Translate with named parameters.
  /// Example: translateNamed('order', namedParams: {'count': '3', 'item': 'books'})
  String translateWithNamedParams(
    String key, {
    required Map<String, String> namedParams,
  });

  /// Plural-aware translation.
  /// Resolves the correct plural form (zero / one / other) for [count].
  String plural(String key, int count);

  /// Whether the current locale is RTL.
  bool get isRtl;
}
```

---

## Implementation — `lib/src/core/localization/localization_service_impl.dart`

The **only file** that imports `package:flutter_localization`.

```dart
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../storage/key_value_store.dart';
import 'app_locale.dart';
import 'localization_service.dart';

class LocalizationServiceImpl implements LocalizationService {
  LocalizationServiceImpl({required KeyValueStore storage})
      : _storage = storage;

  final KeyValueStore _storage;
  final FlutterLocalization _localization = FlutterLocalization.instance;

  static const _localeKey = 'app_locale';
  static const _defaultLocale = Locale('en');

  /// Call once during bootstrap, before runApp.
  Future<void> init() async {
    await _localization.ensureInitialized();

    _localization.init(
      mapLocales: [
        MapLocale('en', AppLocale.en),
        MapLocale('vi', AppLocale.vi),
        MapLocale('ar', AppLocale.ar),
      ],
      initLanguageCode: await _restoredLanguageCode(),
    );
  }

  Future<String> _restoredLanguageCode() async {
    final saved = await _storage.getString(_localeKey);
    return saved ?? _defaultLocale.languageCode;
  }

  @override
  Locale get currentLocale => _localization.currentLocale ?? _defaultLocale;

  @override
  List<Locale> get supportedLocales => _localization.supportedLocales;

  @override
  Iterable<LocalizationsDelegate<dynamic>> get delegates =>
      _localization.localizationsDelegates;

  @override
  Future<void> setLocale(Locale locale) async {
    _localization.translate(locale.languageCode);
    await _storage.setString(_localeKey, locale.languageCode);
  }

  @override
  String translate(String key) => _localization.getString(key);

  @override
  String translateWithParams(String key, {required List<String> params}) =>
      _localization.getString(key, params: params);

  @override
  String translateWithNamedParams(
    String key, {
    required Map<String, String> namedParams,
  }) {
    var result = _localization.getString(key);
    for (final entry in namedParams.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value);
    }
    return result;
  }

  @override
  String plural(String key, int count) {
    // Convention: keys use _zero, _one, _other suffixes.
    final suffix = switch (count) {
      0 => '_zero',
      1 => '_one',
      _ => '_other',
    };
    final pluralKey = '${key}$suffix';
    final result = _localization.getString(pluralKey);
    return result.replaceAll('%d', count.toString());
  }

  @override
  bool get isRtl {
    const rtlLanguages = {'ar', 'he', 'fa', 'ur', 'ps', 'ku', 'yi'};
    return rtlLanguages.contains(currentLocale.languageCode);
  }
}
```

---

## `pubspec.yaml`

```yaml
dependencies:
  flutter_localization: 0.2.2
  intl: 0.19.0          # date/number/currency formatting
```

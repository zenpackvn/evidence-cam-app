# Localization — Testing

## Fake Implementation

```dart
import 'dart:ui';
import '../localization_service.dart';

class FakeLocalizationService implements LocalizationService {
  FakeLocalizationService({this.locale = const Locale('en')});

  Locale locale;
  final Map<String, String> _overrides = {};

  /// Set custom translations for tests.
  void setTranslation(String key, String value) => _overrides[key] = value;

  @override
  Locale get currentLocale => locale;

  @override
  List<Locale> get supportedLocales => const [Locale('en'), Locale('vi')];

  @override
  Iterable<LocalizationsDelegate<dynamic>> get delegates => const [];

  @override
  Future<void> setLocale(Locale newLocale) async {
    locale = newLocale;
  }

  @override
  String translate(String key) => _overrides[key] ?? key;

  @override
  String translateWithParams(String key, {required List<String> params}) {
    var result = translate(key);
    for (var i = 0; i < params.length; i++) {
      result = result.replaceFirst('%s', params[i]);
    }
    return result;
  }

  @override
  String translateWithNamedParams(
    String key, {
    required Map<String, String> namedParams,
  }) {
    var result = translate(key);
    for (final entry in namedParams.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value);
    }
    return result;
  }

  @override
  String plural(String key, int count) {
    final suffix = switch (count) {
      0 => '_zero',
      1 => '_one',
      _ => '_other',
    };
    return translate('$key$suffix').replaceAll('%d', count.toString());
  }

  @override
  bool get isRtl => const {'ar', 'he', 'fa'}.contains(locale.languageCode);
}
```

---

## Unit Test — Locale Switching and Translation

```dart
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'fakes/fake_localization_service.dart';

void main() {
  late FakeLocalizationService service;

  setUp(() {
    service = FakeLocalizationService();
  });

  test('default locale is English', () {
    expect(service.currentLocale, const Locale('en'));
  });

  test('setLocale changes current locale', () async {
    await service.setLocale(const Locale('vi'));
    expect(service.currentLocale, const Locale('vi'));
  });

  test('isRtl returns true for Arabic', () async {
    await service.setLocale(const Locale('ar'));
    expect(service.isRtl, isTrue);
  });

  test('isRtl returns false for English', () {
    expect(service.isRtl, isFalse);
  });

  test('translate returns key when no override set', () {
    expect(service.translate('home_title'), 'home_title');
  });

  test('translate returns override when set', () {
    service.setTranslation('home_title', 'Home');
    expect(service.translate('home_title'), 'Home');
  });

  test('translateWithParams replaces positional params', () {
    service.setTranslation('common_greeting', 'Hello, %s!');
    expect(
      service.translateWithParams('common_greeting', params: ['Alice']),
      'Hello, Alice!',
    );
  });

  test('plural resolves zero/one/other', () {
    service.setTranslation('item_count_zero', 'No items');
    service.setTranslation('item_count_one', '1 item');
    service.setTranslation('item_count_other', '%d items');

    expect(service.plural('item_count', 0), 'No items');
    expect(service.plural('item_count', 1), '1 item');
    expect(service.plural('item_count', 5), '5 items');
  });
}
```

---

## Widget Test — Translated Text

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:app/src/core/localization/localization_service.dart';
import 'fakes/fake_localization_service.dart';

void main() {
  late FakeLocalizationService fakeL10n;

  setUp(() {
    fakeL10n = FakeLocalizationService();
    fakeL10n.setTranslation('home_title', 'Home');
    GetIt.I.registerSingleton<LocalizationService>(fakeL10n);
  });

  tearDown(() {
    GetIt.I.reset();
  });

  testWidgets('displays translated title', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Text(context.tr('home_title')),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
  });
}
```

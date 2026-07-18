import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_starter_template/core/locale/locale_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_utils.dart';

void main() {
  late MockSharedPreferences prefs;
  late LocaleBloc bloc;

  setUp(() {
    prefs = MockSharedPreferences();
    registerFallbackValue('');
    when(() => prefs.getString(any())).thenReturn(null);
    when(() => prefs.setString(any(), any())).thenAnswer((_) async => true);
    bloc = LocaleBloc(prefs);
  });

  tearDown(() => bloc.close());

  group('LocaleBloc', () {
    test('defaults to Vietnamese when nothing is persisted', () {
      expect(bloc.state.locale, const Locale('vi'));
    });

    test('reads the persisted language at startup', () {
      when(() => prefs.getString('app.locale')).thenReturn('en');
      final b = LocaleBloc(prefs);
      expect(b.state.locale, const Locale('en'));
      b.close();
    });

    test('ignores a persisted language with no bundled translation', () {
      // Someone hand-edited prefs, or a previously-supported locale was
      // dropped: fall back rather than boot into an untranslatable locale.
      when(() => prefs.getString('app.locale')).thenReturn('ko');
      final b = LocaleBloc(prefs);
      expect(b.state.locale, const Locale('vi'));
      b.close();
    });

    blocTest<LocaleBloc, LocaleState>(
      'switches to a supported language and persists it',
      build: () => bloc,
      act: (b) => b.add(const LocaleChanged('en')),
      expect: () => [const LocaleState(Locale('en'))],
      verify: (_) =>
          verify(() => prefs.setString('app.locale', 'en')).called(1),
    );

    // The picker shows ko/ja rows by design; choosing one must not switch the
    // app into a locale it has no translations for.
    blocTest<LocaleBloc, LocaleState>(
      'ignores an unsupported language and does not persist',
      build: () => bloc,
      act: (b) => b.add(const LocaleChanged('ko')),
      expect: () => <LocaleState>[],
      verify: (_) => verifyNever(() => prefs.setString(any(), any())),
    );

    blocTest<LocaleBloc, LocaleState>(
      'ignores selecting the language already active',
      build: () => bloc, // starts at 'vi'
      act: (b) => b.add(const LocaleChanged('vi')),
      expect: () => <LocaleState>[],
      verify: (_) => verifyNever(() => prefs.setString(any(), any())),
    );
  });
}

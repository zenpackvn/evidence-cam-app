import 'package:bloc_test/bloc_test.dart';
import 'package:evidence_cam/core/locale/locale_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/test_utils.dart';

void main() {
  late MockSharedPreferences prefs;

  setUp(() {
    prefs = MockSharedPreferences();
    registerFallbackValue('');
    when(() => prefs.getString(any())).thenReturn(null);
    when(() => prefs.setString(any(), any())).thenAnswer((_) async => true);
  });

  group('LocaleBloc', () {
    test('defaults to the default locale when nothing is persisted', () {
      expect(LocaleBloc(prefs).state.locale, LocaleState.defaultLocale);
    });

    test('reads a persisted, supported locale at startup', () {
      when(() => prefs.getString('app.locale')).thenReturn('vi');
      expect(LocaleBloc(prefs).state.locale, const Locale('vi'));
    });

    test('ignores a persisted locale with no bundled translation', () {
      when(() => prefs.getString('app.locale')).thenReturn('xx');
      expect(LocaleBloc(prefs).state.locale, LocaleState.defaultLocale);
    });

    blocTest<LocaleBloc, LocaleState>(
      'switches to a supported language and persists it',
      build: () => LocaleBloc(prefs),
      act: (b) => b.add(const LocaleChanged('vi')),
      expect: () => [const LocaleState(Locale('vi'))],
      verify: (_) =>
          verify(() => prefs.setString('app.locale', 'vi')).called(1),
    );

    blocTest<LocaleBloc, LocaleState>(
      'ignores an unsupported language and does not persist',
      build: () => LocaleBloc(prefs),
      act: (b) => b.add(const LocaleChanged('xx')),
      expect: () => <LocaleState>[],
      verify: (_) => verifyNever(() => prefs.setString(any(), any())),
    );
  });
}

import 'package:app_ui/app_ui.dart';
import 'package:ec_ui/ec_ui.dart';
import 'package:feature_shift/feature_shift.dart';
import 'package:flutter/cupertino.dart' show CupertinoTextField;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';

/// These screens read their copy through `context.l10n`, so the harness has to
/// install the delegates — without them `AppLocalizations.of` returns null and
/// every screen in this file throws on build. Pinned to `vi`, which is what
/// the expectations below are written against.
Future<void> _pump(WidgetTester tester, Widget screen) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
    tester.view.reset();
  });
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('vi'),
      supportedLocales: const [Locale('vi'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: screen,
    ),
  );
}

void main() {
  group('EcSplashScreen', () {
    testWidgets('shows brand, tagline and start button', (tester) async {
      await _pump(tester, const EcSplashScreen());
      expect(find.text('ZenPack'), findsOneWidget);
      expect(find.text('Mỗi kiện hàng.'), findsOneWidget);
      expect(find.text('Bảo vệ doanh thu của bạn.'), findsOneWidget);
      expect(find.text('Bắt đầu'), findsOneWidget);
      expect(find.text('v1.0.0'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('start button fires callback', (tester) async {
      var tapped = false;
      await _pump(tester, EcSplashScreen(onStart: () => tapped = true));
      await tester.tap(find.text('Bắt đầu'));
      expect(tapped, isTrue);
    });
  });

  group('EcLoginScreen', () {
    testWidgets('renders the whole login layout without overflow', (
      tester,
    ) async {
      await _pump(tester, const EcLoginScreen());
      expect(find.text('Đăng nhập'), findsWidgets);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Mật khẩu'), findsOneWidget);
      expect(find.text('Quên mật khẩu?'), findsOneWidget);
      expect(find.text('Đăng nhập với Google'), findsOneWidget);
      expect(find.text('Đăng nhập với Apple'), findsOneWidget);
      expect(find.text('Đăng ký'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('social + register callbacks fire', (tester) async {
      var google = false;
      var register = false;
      await _pump(
        tester,
        EcLoginScreen(
          onGoogle: () => google = true,
          onRegister: () => register = true,
        ),
      );
      await tester.tap(find.text('Đăng nhập với Google'));
      await tester.tap(find.text('Đăng ký'));
      expect(google, isTrue);
      expect(register, isTrue);
    });

    testWidgets('password eye toggles obscureText', (tester) async {
      await _pump(tester, const EcLoginScreen());

      bool passwordObscured() => tester
          .widgetList<CupertinoTextField>(find.byType(CupertinoTextField))
          .any((f) => f.obscureText);

      // Starts hidden with the "reveal" eye; tapping shows the password and
      // swaps to the "hide" eye; tapping again hides it once more.
      expect(passwordObscured(), isTrue);
      expect(find.byIcon(LucideIcons.eye), findsOneWidget);

      await tester.tap(find.byIcon(LucideIcons.eye));
      await tester.pump();
      expect(passwordObscured(), isFalse);
      expect(find.byIcon(LucideIcons.eyeOff), findsOneWidget);

      await tester.tap(find.byIcon(LucideIcons.eyeOff));
      await tester.pump();
      expect(passwordObscured(), isTrue);
    });
  });
}

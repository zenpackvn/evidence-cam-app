import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_starter_template/screens/ec_screens.dart';
import 'package:flutter_test/flutter_test.dart';

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
  return tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: screen));
}

void main() {
  group('EcSplashScreen', () {
    testWidgets('shows brand, tagline and start button', (tester) async {
      await _pump(tester, const EcSplashScreen());
      expect(find.text('ZenPack'), findsOneWidget);
      expect(find.textContaining('bằng chứng đóng hàng'), findsOneWidget);
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
  });
}

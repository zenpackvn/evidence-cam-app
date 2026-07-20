// Unit/widget coverage for `product-spec/001-auth/test-cases.md`.
//
// Each group cites the TC ids it asserts at the unit level; the full journeys
// stay E2E per the doc's classification (✅ Maestro / 🔲 Manual).
import 'package:architecture/architecture.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:feature_auth/src/presentation/bloc/auth_bloc.dart';
import 'package:feature_auth/src/presentation/bloc/auth_state.dart';
import 'package:feature_auth/src/presentation/bloc/change_password_cubit.dart';
import 'package:feature_auth/src/presentation/bloc/change_password_state.dart';
import 'package:feature_auth/src/presentation/screens/forgot_password_screen.dart';
import 'package:feature_auth/src/presentation/screens/login_screen.dart';
import 'package:feature_auth/src/presentation/screens/register_screen.dart';
import 'package:feature_auth/src/presentation/screens/verify_email_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:shared_contracts/shared_contracts.dart';

import '../support.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

const _testUser = AuthUser(id: 'u1', username: 'sunny');

Widget _wrap(Widget child, {AuthBloc? bloc}) {
  return MaterialApp.router(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('vi'),
    routerConfig: GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => bloc == null
              ? child
              : BlocProvider<AuthBloc>.value(value: bloc, child: child),
        ),
      ],
    ),
  );
}

MockAnalyticsService _analytics() {
  final a = MockAnalyticsService();
  stubAnalyticsService(a);
  return a;
}

MockAuthBloc _idleBloc() {
  final bloc = MockAuthBloc();
  when(() => bloc.state).thenReturn(const AuthState.initial());
  when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
  when(() => bloc.add(any())).thenReturn(null);
  return bloc;
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const AuthSignInRequested(username: '', password: ''),
    );
    registerFallbackValue((username: '', password: ''));
    registerFallbackValue((currentPassword: '', newPassword: ''));
  });

  // ── TC-01-011..014 · đăng nhập (email + Google qua bloc) ────────────────
  group('AuthBloc sign-in (TC-01-011, TC-01-012)', () {
    late MockSignIn signIn;
    late MockSignInWithGoogle google;

    AuthBloc build() => AuthBloc(
      signIn: signIn,
      register: MockRegister(),
      signOut: MockSignOut(),
      restoreSession: MockRestoreSession(),
      analytics: _analytics(),
      signInWithGoogle: google,
    );

    setUp(() {
      signIn = MockSignIn();
      google = MockSignInWithGoogle();
    });

    blocTest<AuthBloc, AuthState>(
      'TC-01-011: email+password đúng → authenticated',
      build: () {
        when(() => signIn(any())).thenAnswer((_) async => const Ok(_testUser));
        return build();
      },
      act: (bloc) =>
          bloc.add(const AuthSignInRequested(username: 'a@b.c', password: 'x')),
      expect: () => [
        const AuthState.submitting(),
        const AuthState.authenticated(_testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'TC-01-012: Google thành công → authenticated',
      build: () {
        when(() => google(null)).thenAnswer((_) async => const Ok(_testUser));
        return build();
      },
      act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
      expect: () => [
        const AuthState.submitting(),
        const AuthState.authenticated(_testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'TC-01-036 (đăng nhập sai) → failure(InvalidCredentials)',
      build: () {
        when(() => signIn(any())).thenAnswer(
          (_) async => const Err(InvalidCredentialsFailure('sai')),
        );
        return build();
      },
      act: (bloc) =>
          bloc.add(const AuthSignInRequested(username: 'a@b.c', password: 'x')),
      expect: () => [
        const AuthState.submitting(),
        isA<AuthFailure>(),
      ],
    );
  });

  // ── TC-01-029/032/033 · lỗi tại ô — màn đăng nhập ───────────────────────
  group('LoginScreen field errors', () {
    testWidgets('TC-01-029: email trống báo lỗi tại ô', (tester) async {
      final bloc = _idleBloc();
      await tester.pumpWidget(_wrap(const LoginScreen(), bloc: bloc));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Đăng nhập').first);
      await tester.tap(find.text('Đăng nhập').first, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập email'), findsOneWidget);
      verifyNever(() => bloc.add(any(that: isA<AuthSignInRequested>())));
    });

    testWidgets('TC-01-033: mật khẩu trống báo lỗi tại ô', (tester) async {
      final bloc = _idleBloc();
      await tester.pumpWidget(_wrap(const LoginScreen(), bloc: bloc));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).first,
        'sunny@stampmail.dev',
      );
      await tester.ensureVisible(find.text('Đăng nhập').first);
      await tester.tap(find.text('Đăng nhập').first, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);
      verifyNever(() => bloc.add(any(that: isA<AuthSignInRequested>())));
    });
  });

  // ── TC-01-017/018 · khoá tạm + banner lỗi form (F01-S04/S05) ────────────
  group('LoginScreen failure states', () {
    testWidgets(
      'TC-01-036: sai thông tin → banner "Đăng nhập không thành công"',
      (tester) async {
        final bloc = MockAuthBloc();
        when(() => bloc.state).thenReturn(const AuthState.initial());
        when(() => bloc.stream).thenAnswer(
          (_) => Stream.value(
            const AuthState.failure(InvalidCredentialsFailure('x')),
          ),
        );
        when(() => bloc.add(any())).thenReturn(null);

        await tester.pumpWidget(_wrap(const LoginScreen(), bloc: bloc));
        await tester.pumpAndSettle();

        expect(
          find.text('Đăng nhập không thành công. Sai email hoặc mật khẩu.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'TC-01-017: bị khoá → banner khoá + đếm ngược + CTA vô hiệu',
      (tester) async {
        final bloc = MockAuthBloc();
        when(() => bloc.state).thenReturn(const AuthState.initial());
        when(() => bloc.stream).thenAnswer(
          (_) => Stream.value(
            const AuthState.failure(PermissionFailure('locked')),
          ),
        );
        when(() => bloc.add(any())).thenReturn(null);

        await tester.pumpWidget(_wrap(const LoginScreen(), bloc: bloc));
        await tester.pump();
        await tester.pump();

        expect(
          find.textContaining('Tài khoản đang bị khóa tạm thời'),
          findsOneWidget,
        );
        expect(find.textContaining('Thử lại sau'), findsOneWidget);
        // CTA disabled while locked: tapping must not dispatch sign-in.
        await tester.ensureVisible(find.text('Đăng nhập').first);
        await tester.tap(find.text('Đăng nhập').first, warnIfMissed: false);
        verifyNever(() => bloc.add(any(that: isA<AuthSignInRequested>())));
        // Let the 1s countdown timer finish cleanly.
        await tester.pump(const Duration(minutes: 16));
      },
    );
  });

  // ── TC-01-008/009/030/032/034 · validate màn đăng ký ────────────────────
  group('RegisterScreen validation', () {
    Future<void> pumpRegister(WidgetTester tester, MockAuthBloc bloc) async {
      await tester.pumpWidget(_wrap(const RegisterScreen(), bloc: bloc));
      await tester.pumpAndSettle();
    }

    testWidgets('TC-01-030: email trống báo lỗi tại ô', (tester) async {
      final bloc = _idleBloc();
      await pumpRegister(tester, bloc);
      await tester.ensureVisible(find.text('Tạo tài khoản').first);
      await tester.tap(find.text('Tạo tài khoản').first, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Vui lòng nhập email'), findsOneWidget);
    });

    testWidgets('TC-01-032: email sai định dạng bị báo lỗi', (tester) async {
      final bloc = _idleBloc();
      await pumpRegister(tester, bloc);
      await tester.enterText(find.byType(TextFormField).at(0), 'sunny@.mail');
      await tester.ensureVisible(find.text('Tạo tài khoản').first);
      await tester.tap(find.text('Tạo tài khoản').first, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Email không hợp lệ'), findsOneWidget);
    });

    testWidgets('TC-01-008: mật khẩu dưới 6 ký tự bị từ chối', (tester) async {
      final bloc = _idleBloc();
      await pumpRegister(tester, bloc);
      await tester.enterText(find.byType(TextFormField).at(0), 'a@b.com');
      await tester.enterText(find.byType(TextFormField).at(1), '12345');
      await tester.ensureVisible(find.text('Tạo tài khoản').first);
      await tester.tap(find.text('Tạo tài khoản').first, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Mật khẩu phải có ít nhất 6 ký tự'), findsOneWidget);
      verifyNever(() => bloc.add(any(that: isA<AuthRegisterRequested>())));
    });

    testWidgets('TC-01-034: xác nhận mật khẩu không khớp', (tester) async {
      final bloc = _idleBloc();
      await pumpRegister(tester, bloc);
      await tester.enterText(find.byType(TextFormField).at(0), 'a@b.com');
      await tester.enterText(find.byType(TextFormField).at(1), '123456');
      await tester.enterText(find.byType(TextFormField).at(2), '654321');
      await tester.ensureVisible(find.text('Tạo tài khoản').first);
      await tester.tap(find.text('Tạo tài khoản').first, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Mật khẩu không khớp'), findsOneWidget);
    });

    testWidgets('TC-01-009: chưa tick 13+ thì không đăng ký', (tester) async {
      final bloc = _idleBloc();
      await pumpRegister(tester, bloc);
      await tester.enterText(find.byType(TextFormField).at(0), 'a@b.com');
      await tester.enterText(find.byType(TextFormField).at(1), '123456');
      await tester.enterText(find.byType(TextFormField).at(2), '123456');
      await tester.ensureVisible(find.text('Tạo tài khoản').first);
      await tester.tap(find.text('Tạo tài khoản').first, warnIfMissed: false);
      await tester.pumpAndSettle();
      verifyNever(() => bloc.add(any(that: isA<AuthRegisterRequested>())));
    });
  });

  // ── TC-01-020/023/031 + BR-12 reset qua link email ───────────────────────
  group('ForgotPasswordScreen flow (TC-01-020, TC-01-031)', () {
    testWidgets('TC-01-031: email trống báo lỗi tại ô', (tester) async {
      await tester.pumpWidget(_wrap(const ForgotPasswordScreen()));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Gửi link đặt lại').first);
      await tester.tap(
        find.text('Gửi link đặt lại').first,
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(find.text('Vui lòng nhập email'), findsOneWidget);
    });

    testWidgets(
      'TC-01-020: email hợp lệ → bước "Kiểm tra email" (link + đếm ngược 30 '
      'phút, gửi lại sau 60s)',
      (tester) async {
        String? sentTo;
        await tester.pumpWidget(
          _wrap(
            ForgotPasswordScreen(onSendReset: (email) async => sentTo = email),
          ),
        );
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byType(TextFormField).first,
          'sunny@stampmail.dev',
        );
        await tester.ensureVisible(find.text('Gửi link đặt lại').first);
        await tester.tap(
          find.text('Gửi link đặt lại').first,
          warnIfMissed: false,
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(sentTo, 'sunny@stampmail.dev');
        expect(find.text('Kiểm tra email của bạn ✨'), findsOneWidget);
        expect(find.text('sunny@stampmail.dev'), findsOneWidget);
        expect(find.textContaining('Link sẽ hết hạn sau'), findsOneWidget);
        // Không còn bước nhập mã — không có ô OTP nào.
        expect(find.text('Tiếp tục'), findsNothing);
        // Dừng ticker để test thoát sạch.
        await tester.pumpWidget(const SizedBox());
      },
    );
  });

  // ── TC-01-025 · đổi mật khẩu cần đúng mật khẩu hiện tại ──────────────────
  group('ChangePasswordCubit (TC-01-024, TC-01-025)', () {
    blocTest<ChangePasswordCubit, ChangePasswordState>(
      'TC-01-025: sai mật khẩu hiện tại → failure',
      build: () {
        final change = MockChangePassword();
        when(() => change(any())).thenAnswer(
          (_) async => const Err(InvalidCredentialsFailure('wrong')),
        );
        return ChangePasswordCubit(change);
      },
      act: (cubit) => cubit.submit(currentPassword: 'sai', newPassword: 'x6ky'),
      expect: () => [
        const ChangePasswordState.submitting(),
        isA<ChangePasswordFailure>(),
      ],
    );

    blocTest<ChangePasswordCubit, ChangePasswordState>(
      'TC-01-024: đổi mật khẩu thành công → success',
      build: () {
        final change = MockChangePassword();
        when(() => change(any())).thenAnswer((_) async => const Ok(null));
        return ChangePasswordCubit(change);
      },
      act: (cubit) =>
          cubit.submit(currentPassword: 'dung', newPassword: 'moi123'),
      expect: () => [
        const ChangePasswordState.submitting(),
        const ChangePasswordState.success(),
      ],
    );
  });

  // ── Verify email — màn chờ bấm link (SM-001 BR-02) ───────────────────────
  group('VerifyEmailScreen waiting (TC-01-00x xác nhận email)', () {
    testWidgets('hiển thị chờ-bấm-link; "Tôi đã xác nhận" khi chưa verify '
        'thì báo lỗi, khi đã verify thì đi tiếp', (tester) async {
      var verified = false;
      var advanced = false;
      await tester.pumpWidget(
        _wrap(
          VerifyEmailScreen(
            email: 'sunny@stampmail.dev',
            onCheckVerified: () async => verified,
            onVerified: () => advanced = true,
          ),
        ),
      );
      await tester.pump();

      // Màn chờ: không có ô nhập mã, có countdown link + nút xác nhận.
      expect(find.byType(TextField), findsNothing);
      expect(find.textContaining('Link sẽ hết hạn sau'), findsOneWidget);

      await tester.ensureVisible(find.text('Tôi đã xác nhận'));
      await tester.tap(find.text('Tôi đã xác nhận'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(advanced, isFalse);
      expect(
        find.text(
          'Email chưa được xác nhận. Hãy bấm vào link trong email trước.',
        ),
        findsOneWidget,
      );

      verified = true;
      await tester.tap(find.text('Tôi đã xác nhận'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(advanced, isTrue);

      // Dừng ticker để test thoát sạch.
      await tester.pumpWidget(const SizedBox());
    });
  });

  // ── F01-S07 · sheet chọn cách đăng ký (TC-01-002..004 UI gate) ──────────
  group('Social choice sheet (TC-01-002..004)', () {
    testWidgets('chạm nút MXH ở Register mở sheet với 3 lựa chọn + Huỷ', (
      tester,
    ) async {
      final bloc = _idleBloc();
      await tester.pumpWidget(_wrap(const RegisterScreen(), bloc: bloc));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Tiếp tục với Google'));
      await tester.tap(find.text('Tiếp tục với Google'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Chọn cách đăng ký'), findsOneWidget);
      expect(find.text('Hủy'), findsOneWidget);
      // 3 provider trong sheet + 3 nút inline phía sau.
      expect(find.text('Tiếp tục với Apple'), findsNWidgets(2));
    });
  });
}

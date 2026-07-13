import 'package:feature_auth/src/presentation/bloc/auth_bloc.dart';
import 'package:feature_auth/src/presentation/bloc/auth_state.dart';
import 'package:feature_auth/src/presentation/screens/login_screen.dart';
import 'package:feature_auth/src/presentation/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

import '../../support.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

Widget wrapWithDependencies(AuthBloc bloc) {
  return MaterialApp.router(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => BlocProvider<AuthBloc>.value(
            value: bloc,
            child: const RegisterScreen(),
          ),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
      ],
    ),
  );
}

void main() {
  late MockAuthBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(
      const AuthRegisterRequested(username: '', password: ''),
    );
  });

  setUp(() {
    mockBloc = MockAuthBloc();
    when(() => mockBloc.state).thenReturn(const AuthState.initial());
    when(
      () => mockBloc.stream,
    ).thenAnswer((_) => Stream.value(const AuthState.initial()));
    when(() => mockBloc.add(any())).thenReturn(null);
  });

  group('RegisterScreen', () {
    testWidgets('renders register form fields', (tester) async {
      await tester.pumpWidget(wrapWithDependencies(mockBloc));
      await tester.pumpAndSettle();

      expect(find.text('Create account'), findsAtLeast(1));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm password'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('shows validation errors on empty submit', (tester) async {
      await tester.pumpWidget(wrapWithDependencies(mockBloc));
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.text('Create account'),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.text('Create account'),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Please enter your email'), findsAtLeast(1));
    });

    testWidgets('shows validation error for short password', (tester) async {
      await tester.pumpWidget(wrapWithDependencies(mockBloc));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'jane@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'short');
      await tester.ensureVisible(
        find.text('Create account'),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.text('Create account'),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
      verifyNever(() => mockBloc.add(any()));
    });

    testWidgets('shows validation error for malformed email', (tester) async {
      await tester.pumpWidget(wrapWithDependencies(mockBloc));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'not-an-email');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.ensureVisible(
        find.text('Create account'),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.text('Create account'),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Invalid email'), findsOneWidget);
      verifyNever(() => mockBloc.add(any()));
    });

    testWidgets('calls register with entered credentials', (tester) async {
      await tester.pumpWidget(wrapWithDependencies(mockBloc));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'jane@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      // Confirm password + the 13+ age checkbox are required to submit.
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Create account'));
      await tester.tap(find.text('Create account'));
      await tester.pump(const Duration(milliseconds: 100));

      verify(
        () => mockBloc.add(
          any(
            that: isA<AuthRegisterRequested>()
                .having(
                  (event) => event.username,
                  'username',
                  'jane@example.com',
                )
                .having(
                  (event) => event.password,
                  'password',
                  'password123',
                ),
          ),
        ),
      ).called(1);
    });

    testWidgets('does not submit again while already submitting', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(const AuthState.submitting());
      when(
        () => mockBloc.stream,
      ).thenAnswer((_) => Stream.value(const AuthState.submitting()));

      await tester.pumpWidget(wrapWithDependencies(mockBloc));
      // Submitting shows a spinner (never settles), so pump a fixed duration.
      await tester.pump(const Duration(seconds: 1));

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'jane@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump(const Duration(milliseconds: 100));

      verifyNever(() => mockBloc.add(any()));
    });

    // Password-visibility toggle is covered by login_screen_test; the
    // failure-message test was removed (errors surface via the bloc listener,
    // covered by auth_bloc_test).
  });
}

import 'package:feature_auth/src/presentation/bloc/auth_bloc.dart';
import 'package:feature_auth/src/presentation/bloc/auth_state.dart';
import 'package:feature_auth/src/presentation/screens/login_screen.dart';
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
            child: const LoginScreen(),
          ),
        ),
      ],
    ),
  );
}

void main() {
  late MockAuthBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(
      const AuthSignInRequested(username: '', password: ''),
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

  group('LoginScreen', () {
    testWidgets('renders login form fields', (tester) async {
      await tester.pumpWidget(wrapWithDependencies(mockBloc));
      await tester.pumpAndSettle();

      expect(find.text('Welcome back! 👋'), findsOneWidget);
      expect(find.text('Email or username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Apple'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('shows validation errors on empty submit', (tester) async {
      await tester.pumpWidget(wrapWithDependencies(mockBloc));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign in'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Please enter your email'), findsAtLeast(1));
    });

    testWidgets('calls signIn with entered credentials', (tester) async {
      await tester.pumpWidget(wrapWithDependencies(mockBloc));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'alice@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'hunter2');
      await tester.tap(find.text('Sign in'));
      await tester.pump(const Duration(milliseconds: 100));

      verify(
        () => mockBloc.add(
          any(
            that: isA<AuthSignInRequested>()
                .having(
                  (event) => event.username,
                  'username',
                  'alice@example.com',
                )
                .having((event) => event.password, 'password', 'hunter2'),
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
        'alice@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'hunter2');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump(const Duration(milliseconds: 100));

      verifyNever(() => mockBloc.add(any()));
    });

    testWidgets('toggles password visibility', (tester) async {
      await tester.pumpWidget(wrapWithDependencies(mockBloc));
      await tester.pumpAndSettle();

      expect(
        tester.widget<EditableText>(find.byType(EditableText).last).obscureText,
        isTrue,
      );

      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();

      expect(find.byTooltip('Hide password'), findsOneWidget);
      expect(
        tester.widget<EditableText>(find.byType(EditableText).last).obscureText,
        isFalse,
      );
    });

    // Forgot-password now navigates to a dedicated screen and social sign-in
    // wiring is in progress (ponytail), so the old "unavailable" snackbar tests
    // were removed; navigation is covered by auth_routes_test / E4 journey.

    // The submitting-spinner and inline failure-message tests were removed:
    // the screen now disables submit while submitting and surfaces auth errors
    // through the bloc listener path, not a _FormError widget the mocked bloc
    // can drive here. The failure→UI mapping is covered by auth_bloc_test.
  });
}

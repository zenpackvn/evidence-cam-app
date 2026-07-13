import 'package:architecture/architecture.dart';
import 'package:checks/checks.dart';
import 'package:feature_auth/src/presentation/bloc/auth_bloc.dart';
import 'package:feature_auth/src/presentation/bloc/auth_state.dart';
import 'package:feature_home/feature_home.dart';
// fst:feature:notifications:start
import 'package:feature_notifications/feature_notifications.dart';
// fst:feature:notifications:end
import 'package:feature_onboarding/feature_onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_starter_template/app/app.dart';
import 'package:flutter_starter_template/app/di/injection.dart';
import 'package:flutter_starter_template/app/feature_module.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storage/storage.dart';
import 'package:theme/theme.dart';

import 'test_utils.dart';

final class _NoOpSyncModule extends FeatureModule {
  @override
  FeatureSyncController get syncController => _NoOpSync();
}

final class _NoOpSync implements FeatureSyncController {
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}
}

void main() {
  late MockAnalyticsService analytics;
  late AuthBloc authBloc;
  late ThemeBloc themeBloc;
  HomeBloc? homeBloc;

  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    analytics = MockAnalyticsService();
    stubAnalyticsService(analytics);

    final signIn = MockSignIn();
    when(() => signIn((username: 'alice', password: 'hunter2'))).thenAnswer((
      _,
    ) async {
      return const Ok(testUser);
    });

    final restoreSession = MockRestoreSession();
    when(
      restoreSession.call,
    ).thenAnswer((_) async => const Err(testFailure));

    final signOut = MockSignOut();
    when(signOut.call).thenAnswer((_) async => const Ok(null));

    authBloc = AuthBloc(
      signIn: signIn,
      register: MockRegister(),
      signOut: signOut,
      restoreSession: restoreSession,
      analytics: analytics,
      signInWithGoogle: MockSignInWithGoogle(),
    );
    themeBloc = ThemeBloc(await SharedPreferences.getInstance(), analytics);

    getIt.registerFactory<HomeBloc>(() {
      final bloc = HomeBloc(_EmptyHomeLoader());
      homeBloc = bloc;
      return bloc;
    });

    // fst:feature:notifications:start
    final notificationsBloc = MockNotificationsBloc();
    when(() => notificationsBloc.state).thenReturn(const NotificationsState());
    getIt.registerFactory<NotificationsBloc>(() => notificationsBloc);
    // fst:feature:notifications:end

    final prefs = await SharedPreferences.getInstance();
    getIt.registerLazySingleton<OnboardingStore>(() => OnboardingStore(prefs));
  });

  tearDown(() async {
    await getIt.reset();
    final bloc = homeBloc;
    if (bloc != null && !bloc.isClosed) {
      await bloc.close();
    }
    await themeBloc.close();
    await authBloc.close();
  });

  testWidgets('signs in and lands on home screen', (tester) async {
    await tester.pumpWidget(
      App(
        authBloc: authBloc,
        themeBloc: themeBloc,
        features: [_NoOpSyncModule(), _NoOpSyncModule(), _NoOpSyncModule()],
        navigatorObservers: const [],
        videoPlayerService: MockVideoPlayerService(),
      ),
    );
    await tester.pump();
    await tester.idle();
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pump(const Duration(seconds: 3));
    await tester.idle();
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pump();
    for (var i = 0; i < 40 && find.text('Sign in').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    check(find.text('Sign in').evaluate()).isNotEmpty();

    await tester.enterText(find.byType(TextFormField).at(0), 'alice');
    await tester.enterText(find.byType(TextFormField).at(1), 'hunter2');

    // The CTA can sit just below the 600px test viewport; bring it on-screen
    // before tapping (real devices are taller).
    await tester.ensureVisible(find.text('Sign in'));
    await tester.pump();
    await tester.tap(find.text('Sign in'));
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pumpAndSettle();
    for (
      var i = 0;
      i < 20 && find.text('Chào alice 👋').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // The StampMail home dashboard greets the signed-in user (F01-S15).
    expect(find.text('Chào alice 👋'), findsOneWidget);
    expect(homeBloc, isNotNull);
    expect(authBloc.state, isA<AuthAuthenticated>());
    expect(
      (authBloc.state as AuthAuthenticated).user.username,
      'alice',
    );
  });
}

class _EmptyHomeLoader implements HomeDataLoader {
  @override
  Future<HomeData> load() async => HomeData.empty;
}

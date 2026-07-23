import 'dart:async';
import 'dart:developer' as developer;

import 'package:analytics/analytics.dart';
import 'package:app_platform/app_platform.dart';
import 'package:app_ui/app_ui.dart';
import 'package:config/config.dart';
import 'package:database/database.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:feature_letters/feature_letters.dart';
// fst:feature:notifications:start
import 'package:feature_notifications/feature_notifications.dart';
// fst:feature:notifications:end
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_contracts/shared_contracts.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:storage/storage.dart';
import 'package:theme/theme.dart';

import '../core/extensions/build_context_extensions.dart';
import '../core/locale/locale_bloc.dart';
import 'di/injection.dart';
import 'feature_module.dart';
import 'features.dart';
import 'router.dart';
import 'widgets/force_update_gate.dart';

class App extends StatefulWidget {
  const App({
    super.key,
    this.authBloc,
    this.themeBloc,
    this.localeBloc,
    this.features,
    this.navigatorObservers,
    this.session,
    this.videoPlayerService,
  });

  final AuthBloc? authBloc;
  final ThemeBloc? themeBloc;
  final LocaleBloc? localeBloc;

  /// Optional feature overrides — primarily for testing. Defaults to
  /// [enabledFeatures] from `features.dart`.
  final List<FeatureModule>? features;
  final List<NavigatorObserver>? navigatorObservers;
  final Session? session;
  final VideoPlayerService? videoPlayerService;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthBloc _authBloc;
  late final ThemeBloc _themeBloc;
  late final LocaleBloc _localeBloc;
  late final Session _session;
  late final GoRouter _router;
  late final DeepLinkState _deepLink;
  late final List<FeatureSyncController> _syncControllers;
  late final VideoPlayerService _videoPlayerService;
  StreamSubscription<AuthState>? _authSub;

  /// Whether an account was signed in during this app run. Gates the sign-out
  /// wipe so it fires only on an actual logout (authenticated → AuthInitial),
  /// never on the plain AuthInitial the app boots into before any sign-in.
  bool _wasAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _authBloc = widget.authBloc ?? getIt<AuthBloc>();
    _themeBloc = widget.themeBloc ?? getIt<ThemeBloc>();
    _localeBloc = widget.localeBloc ?? getIt<LocaleBloc>();
    _session = widget.session ?? AuthSession(_authBloc);
    final features = widget.features ?? enabledFeatures;
    final result = buildRouterWithDeepLink(
      _authBloc,
      featureRoutes: [
        ...authRoutes,
        for (final f in features) ...f.routes,
      ],
      observers: widget.navigatorObservers ?? [getIt<AnalyticsRouteObserver>()],
    );
    _router = result.router;
    _deepLink = result.deepLink;
    _wireNotificationTaps();
    _syncControllers = features
        .map((f) => f.syncController)
        .whereType<FeatureSyncController>()
        .toList(growable: false);
    _videoPlayerService =
        widget.videoPlayerService ?? getIt<VideoPlayerService>();
    _authSub = _authBloc.stream.listen(_onAuthChanged);
  }

  /// SM-026 BR-04: route a notification tap to the screen for its kind. The
  /// FCM service invokes this with the message data; `kind` mirrors the backend
  /// push kinds (letter_opened / letter_received / quota_low).
  void _wireNotificationTaps() {
    if (!getIt.isRegistered<FirebaseMessagingService>()) return;
    getIt<FirebaseMessagingService>().onNotificationTap = (data) {
      final kind = data?['kind']?.toString();
      switch (kind) {
        case 'letter_opened':
          // "Đã mở thư của bạn" → the sent mailbox (SM-021).
          _router.go('/letters');
        case 'letter_received':
          final linkId = data?['link_id']?.toString();
          if (linkId != null && linkId.isNotEmpty) {
            _router.go('/letter/$linkId');
          }
        case 'quota_low':
          // The upgrade screen (SM-028). Premium is disabled in v1 (D17); the
          // route still shows the locked plan info.
          _router.go('/settings');
      }
    };
  }

  /// SM-026 BR-02: on sign-in, subscribe the device to each enabled
  /// notification kind's topic (defaults on), so pushes start arriving. Toggling
  /// in settings later unsubscribes individual kinds.
  void _syncNotificationSubscriptions(String uid) {
    if (!getIt.isRegistered<FirebaseMessagingService>()) return;
    final fcm = getIt<FirebaseMessagingService>();
    final prefs = getIt.isRegistered<SharedPreferences>()
        ? getIt<SharedPreferences>()
        : null;
    for (final kind in FirebaseMessagingService.notificationKinds) {
      final enabled = prefs?.getBool('notif_enabled_kind_$kind') ?? true;
      unawaited(fcm.setKindEnabled(uid: uid, kind: kind, enabled: enabled));
    }
  }

  static const _lastUidKey = 'last_synced_uid';

  /// Ensures the local cache belongs to the account signing in. When it can't
  /// be confirmed (a different uid last synced here, or none is recorded — e.g.
  /// the first run after this fix, or a device that already holds someone
  /// else's stamps), drop the cached rows + sync cursors so this user pulls
  /// their own data from the server instead of seeing leftovers / reusing a
  /// stale cursor.
  void _resetLocalDataOnAccountSwitch(String uid) {
    final prefs = getIt.isRegistered<SharedPreferences>()
        ? getIt<SharedPreferences>()
        : null;
    final last = prefs?.getString(_lastUidKey);
    if (last != uid && getIt.isRegistered<ObjectBox>()) {
      getIt<ObjectBox>().clearUserData();
    }
    unawaited(prefs?.setString(_lastUidKey, uid));
  }

  /// Erases every trace of the signed-out account from this device: the
  /// ObjectBox stores (stamps, albums, …) + sync cursors, the letters
  /// SharedPreferences caches, the account-switch sentinel, and the in-memory
  /// Premium entitlement. Device-level preferences (theme, locale, onboarding,
  /// notification toggles) are intentionally kept. The server stays the source
  /// of truth, so signing back in re-downloads everything.
  Future<void> _clearLocalAccountData() async {
    // Stop any in-flight sync first so a pull mid-flight can't write rows back
    // after the wipe.
    await Future.wait([
      for (final c in _syncControllers)
        c.stop().catchError((Object _, StackTrace _) {}),
    ]);
    if (getIt.isRegistered<ObjectBox>()) {
      getIt<ObjectBox>().clearUserData();
    }
    if (getIt.isRegistered<LettersRepository>()) {
      await getIt<LettersRepository>().clearLocalCache();
    }
    final prefs = getIt.isRegistered<SharedPreferences>()
        ? getIt<SharedPreferences>()
        : null;
    await prefs?.remove(_lastUidKey);
    // Drop the cached entitlement so the next account can't inherit Premium; a
    // fresh reader re-fetches it from the server on the next read.
    if (getIt.isRegistered<EntitlementReader>()) {
      getIt.resetLazySingleton<EntitlementReader>();
    }
  }

  void _onAuthChanged(AuthState state) {
    if (state is AuthAuthenticated) {
      _wasAuthenticated = true;
      // Must run before the sync controllers start (below) so the pull starts
      // from a clean slate for the freshly-signed-in account.
      _resetLocalDataOnAccountSwitch(state.user.id);
      _syncNotificationSubscriptions(state.user.id);
    } else if (state is AuthInitial && _wasAuthenticated) {
      // The user signed out (or deleted their account / signed out everywhere)
      // — AuthInitial is the definitive logged-out state (AuthSigningOut still
      // holds the user). Wipe their data so nothing leaks to the next person.
      _wasAuthenticated = false;
      unawaited(_clearLocalAccountData());
    }
    for (final c in _syncControllers) {
      unawaited(
        (state is AuthAuthenticated ? c.start() : c.stop()).catchError(
          (Object error, StackTrace stackTrace) {
            developer.log(
              'Feature sync lifecycle failed',
              name: 'App',
              error: error,
              stackTrace: stackTrace,
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    for (final c in _syncControllers) {
      unawaited(
        c.stop().catchError((Object error, StackTrace stackTrace) {
          developer.log(
            'Feature sync stop failed during dispose',
            name: 'App',
            error: error,
            stackTrace: stackTrace,
          );
        }),
      );
    }
    _session.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // App-wide UI fallback: a widget that throws during build degrades to a
    // friendly screen instead of Flutter's red error widget. Crash *reporting*
    // is already installed globally by CrashReporter.install() in main, so the
    // boundary stays UI-only and does not double-report.
    return AppErrorBoundary(
      child: DeepLinkScope(
        deepLink: _deepLink,
        child: SessionScope(
          session: _session,
          child: RepositoryProvider<VideoPlayerService>.value(
            value: _videoPlayerService,
            child: MultiBlocProvider(
              providers: [
                BlocProvider.value(value: _authBloc),
                BlocProvider.value(value: _themeBloc),
                BlocProvider.value(value: _localeBloc),
                // fst:feature:notifications:start
                BlocProvider.value(value: getIt<NotificationsBloc>()),
                // fst:feature:notifications:end
              ],
              // Theme and locale both drive MaterialApp, so both blocs gate its
              // rebuild. Nested rather than a Bloc-tuple to keep each concern
              // independent.
              child: BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, themeState) =>
                    BlocBuilder<LocaleBloc, LocaleState>(
                      builder: (context, localeState) => MaterialApp.router(
                        debugShowCheckedModeBanner: false,
                        onGenerateTitle: (context) => context.l10n.appTitle,
                        theme: AppTheme.light(scheme: themeState.scheme),
                        darkTheme: AppTheme.dark(scheme: themeState.scheme),
                        // Locked to light for now — the dark theme isn't
                        // designed yet, so following the system (themeState.mode)
                        // renders an unfinished dark UI. Restore
                        // `themeState.mode` once dark is done.
                        themeMode: ThemeMode.light,
                        locale: localeState.locale,
                        localizationsDelegates:
                            AppLocalizations.localizationsDelegates,
                        supportedLocales: AppLocalizations.supportedLocales,
                        routerConfig: _router,
                        builder: (context, child) => ForceUpdateGate(
                          remoteConfig:
                              getIt.isRegistered<RemoteConfigService>()
                              ? getIt<RemoteConfigService>()
                              : null,
                          child: child ?? const SizedBox.shrink(),
                        ),
                      ),
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

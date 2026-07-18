import 'dart:async';
import 'dart:developer' as developer;

import 'package:analytics/analytics.dart';
import 'package:app_platform/app_platform.dart';
import 'package:app_ui/app_ui.dart';
import 'package:config/config.dart';
import 'package:feature_auth/feature_auth.dart';
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

  void _onAuthChanged(AuthState state) {
    if (state is AuthAuthenticated) {
      _syncNotificationSubscriptions(state.user.id);
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
                        themeMode: themeState.mode,
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

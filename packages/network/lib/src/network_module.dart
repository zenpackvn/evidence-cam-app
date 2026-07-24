import 'dart:developer' as developer;

import 'package:config/config.dart';
import 'package:dio/dio.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:injectable/injectable.dart';
import 'package:storage/storage.dart';

import 'auth_interceptor.dart';
import 'cache_interceptor.dart';
import 'certificate_pinning.dart';
import 'idempotency_interceptor.dart';
import 'performance_interceptor.dart';
import 'retry_interceptor.dart';
import 'token_provider.dart';
import 'token_refresher.dart';

BaseOptions apiBaseOptions(
  String baseUrl, {
  Duration timeout = const Duration(seconds: 10),
}) => BaseOptions(
  baseUrl: baseUrl,
  connectTimeout: timeout,
  receiveTimeout: timeout,
  contentType: 'application/json',
);

/// Verbose request/response logging for development builds only. Routes Dio's
/// output through `dart:developer` (not `print`) so it integrates with
/// DevTools and stays off the release console. Gate the call site on
/// [EnvConfig.isDev].
///
/// [LogInterceptor] dumps request/response *headers* and bodies verbatim,
/// which includes the `Authorization: Bearer <token>` header the
/// [AuthInterceptor] attaches, plus any `password`/`token` fields in a JSON
/// body. Every logged line is passed through [redactSensitive] first so those
/// secrets never reach the log sink — defense in depth even though this
/// interceptor is already dev-gated (a demo screen recording, a mis-set
/// `isDev`, or piping dev logs to an aggregator would otherwise leak them).
Interceptor devLogInterceptor() => LogInterceptor(
  requestBody: true,
  responseBody: true,
  logPrint: (object) =>
      developer.log(redactSensitive(object.toString()), name: 'dio'),
);

/// Bearer tokens in an `Authorization` header line.
final _bearerHeader = RegExp(
  r'(authorization:\s*bearer\s+)\S+',
  caseSensitive: false,
);

/// `"password": "..."` / `token: ...` style key/value pairs in a JSON or
/// header dump. Group 1 is the key + separator; group 2 is the value, kept so
/// its quoting can be preserved. `authorization` is handled by [_bearerHeader]
/// and deliberately excluded here to avoid double-redacting the `Bearer` word.
final _sensitiveField = RegExp(
  r'''((?:password|pass|pwd|access_token|refresh_token|token|secret|api_?key)["']?\s*[:=]\s*)("[^"]*"|'[^']*'|[^\s,}]+)''',
  caseSensitive: false,
);

/// Replaces token/credential values in a log line with `[REDACTED]`, leaving
/// the surrounding structure (keys, quotes) intact so the log is still useful.
/// Exposed for unit testing.
String redactSensitive(String input) => input
    .replaceAllMapped(_bearerHeader, (m) => '${m[1]}[REDACTED]')
    .replaceAllMapped(_sensitiveField, (m) {
      final value = m[2]!;
      final quote = value.startsWith('"')
          ? '"'
          : value.startsWith("'")
          ? "'"
          : '';
      return '${m[1]}$quote[REDACTED]$quote';
    });

@module
abstract class NetworkModule {
  /// Plain Dio with no auth/refresh wiring. Used by callers that must bypass
  /// application-level interceptors.
  @lazySingleton
  @Named('plain')
  Dio providePlainDio(EnvConfig env) =>
      Dio(apiBaseOptions(env.apiBaseUrl, timeout: env.apiTimeout));

  /// The bearer-token holder, bound to Firebase by the auth feature at startup.
  /// Network-owned so the `Dio` doesn't depend on the auth package: the auth
  /// feature calls [AuthTokenProvider.bind] after Firebase is available instead
  /// of the network package importing `firebase_auth` (which would invert the
  /// layering). Unbound, the interceptor falls back to the persisted token store.
  @lazySingleton
  AuthTokenProvider provideTokenProvider() => AuthTokenProvider();

  /// Authenticated Dio used by the app: attaches the Bearer token and, on 401,
  /// transparently refreshes once and retries the request.
  ///
  /// Interceptor order matters. [PerformanceInterceptor] runs first (outside
  /// dev) so it times the full request including retries; [AuthInterceptor]
  /// owns the 401 → refresh path; the cache interceptor sits after auth so it
  /// only ever stores authenticated responses and can short-circuit a repeat
  /// GET before [RetryInterceptor], which handles transient failures with
  /// backoff. In dev a [devLogInterceptor] is appended last so it observes the
  /// final, token-bearing requests.
  @lazySingleton
  Dio provideDio(
    AuthTokenStore tokens,
    TokenRefresher refresher,
    EnvConfig env,
    FirebasePerformance performance,
    AuthTokenProvider tokenProvider,
  ) {
    final dio = Dio(apiBaseOptions(env.apiBaseUrl, timeout: env.apiTimeout));
    // Pin the server cert when fingerprints are configured (prod); a no-op in
    // dev where the pin list is empty.
    applyCertificatePinning(dio, env.certSha256Pins);
    if (!env.isDev) {
      dio.interceptors.add(PerformanceInterceptor(performance));
    }
    dio.interceptors.add(
      AuthInterceptor(tokens, refresher, dio, tokenProvider: tokenProvider),
    );
    dio.interceptors.add(IdempotencyInterceptor());
    dio.interceptors.add(cacheInterceptor());
    dio.interceptors.add(RetryInterceptor(dio));
    if (env.isDev) {
      dio.interceptors.add(devLogInterceptor());
    }
    return dio;
  }
}

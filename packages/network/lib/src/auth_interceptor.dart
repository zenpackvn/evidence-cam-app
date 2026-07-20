import 'package:dio/dio.dart';
import 'package:storage/storage.dart';

import 'token_provider.dart';
import 'token_refresher.dart';

/// Attaches the access token to outgoing requests and, on 401, transparently
/// refreshes the token once and retries the original request.
///
/// When a [TokenProvider] is supplied (Firebase `getIdToken()`), it is the
/// source of the bearer token per request — the provider caches and refreshes
/// the token itself. Without one, the token is read from the persisted store
/// (the legacy REST session path). Requests already carrying `__auth_retried__`
/// in their extras skip the retry path so a doomed refresh can never loop.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(
    this._tokens,
    this._refresher,
    this._dio, {
    this._tokenProvider,
  });

  final AuthTokenStore _tokens;
  final TokenRefresher _refresher;
  final Dio _dio;
  final AuthTokenProvider? _tokenProvider;

  static const _retriedKey = '__auth_retried__';

  /// Fresh token: the Firebase provider when bound, else the persisted store.
  Future<String?> _token() async {
    final p = _tokenProvider;
    if (p != null && p.isBound) return p.getToken();
    return _tokens.accessToken;
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _token();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final request = err.requestOptions;
    final alreadyRetried = request.extra[_retriedKey] == true;

    if (response?.statusCode != 401 || alreadyRetried) {
      handler.next(err);
      return;
    }

    // Obtain a fresh token. With a bound provider (Firebase) a 401 means the
    // cached ID token expired mid-flight; asking again returns a just-refreshed
    // one. Otherwise fall back to the REST refresh flow.
    final String? freshToken;
    final provider = _tokenProvider;
    if (provider != null && provider.isBound) {
      freshToken = await provider.getToken();
      if (freshToken == null) {
        handler.next(err);
        return;
      }
    } else {
      final outcome = await _refresher.refresh();
      if (outcome != RefreshOutcome.refreshed) {
        handler.next(err);
        return;
      }
      freshToken = _tokens.accessToken;
    }

    try {
      final retried = await _dio.fetch<dynamic>(
        request
          ..extra[_retriedKey] = true
          ..headers['Authorization'] = 'Bearer $freshToken',
      );
      handler.resolve(retried);
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}

# Auth — AuthInterceptor (401 → Refresh → Retry)

Replaces the simpler version in [template-network.md](template-network.md). Handles 401 → refresh → retry. Multiple concurrent 401s trigger only one refresh.

## `lib/src/core/network/interceptors/auth_interceptor.dart`

```dart
import 'dart:async';

import 'package:dio/dio.dart';
import '../../auth/auth_service.dart';
import '../../auth/token_manager.dart';
import '../../logging/app_logger.dart';

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required TokenManager tokenManager,
    required AuthService authService,
    required Dio dio,
    required AppLogger logger,
  })  : _tokenManager = tokenManager,
        _authService = authService,
        _dio = dio,
        _logger = logger;

  final TokenManager _tokenManager;
  final AuthService _authService;
  final Dio _dio;
  final AppLogger _logger;

  /// Completer that serialises refresh attempts.
  /// While a refresh is in-flight, subsequent 401 handlers wait on the same future.
  Completer<bool>? _refreshCompleter;

  // ── Inject access token on every request ──

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenManager.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  // ── Handle 401 — refresh once, retry original request ──

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Skip refresh for the refresh-token endpoint itself to avoid infinite loops.
    final isRefreshCall =
        err.requestOptions.path.contains('/auth/refresh');
    if (isRefreshCall) {
      return handler.next(err);
    }

    final refreshed = await _tryRefresh();
    if (!refreshed) {
      return handler.next(err);
    }

    // Retry the original request with the new token.
    try {
      final token = await _tokenManager.getAccessToken();
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.fetch<dynamic>(opts);
      return handler.resolve(response);
    } on DioException catch (retryError) {
      return handler.next(retryError);
    }
  }

  // ── Race-condition safe refresh ──

  Future<bool> _tryRefresh() async {
    // If another request already started a refresh, wait for it.
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();

    try {
      await _authService.refreshToken();
      _refreshCompleter!.complete(true);
      return true;
    } catch (e, s) {
      _logger.error('Token refresh in interceptor failed', error: e, stackTrace: s);
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }
}
```

**Why `QueuedInterceptor`?** Dio's `QueuedInterceptor` serialises interceptor calls, ensuring only one request enters `onError` at a time. Combined with `_refreshCompleter`, this guarantees a single refresh for N concurrent 401s.

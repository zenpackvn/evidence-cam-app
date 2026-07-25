import 'package:network/network.dart'
    show BaseOptions, Dio, Interceptor, RequestInterceptorHandler, RequestOptions;

import 'ec_api.dart';
import 'ec_auth.dart';
import 'ec_repository.dart';

/// Builds the data source.
///
/// With a backend URL (the `EC_API_URL` override, else `API_BASE_URL` from the
/// dart-define env file) it returns the live [RemoteEcRepository] whose Dio
/// attaches [auth]'s Firebase ID token to every request. Without a URL it falls
/// back to [FakeEcRepository] (tests / offline).
EcRepository buildRepository({
  EcAuth? auth,
  String url = const String.fromEnvironment(
    'EC_API_URL',
    defaultValue: String.fromEnvironment('API_BASE_URL'),
  ),
}) {
  if (url.isEmpty) return const FakeEcRepository();
  final dio = Dio(BaseOptions(baseUrl: url));
  if (auth != null) dio.interceptors.add(_BearerTokenInterceptor(auth));
  return RemoteEcRepository(EcApi(dio));
}

/// Attaches `Authorization: Bearer <firebase-id-token>` to each request.
/// Firebase's `getIdToken()` refreshes the token itself when it nears expiry,
/// so no manual refresh/retry machinery is needed here.
class _BearerTokenInterceptor extends Interceptor {
  _BearerTokenInterceptor(this._auth);

  final EcAuth _auth;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _auth.idToken();
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }
}

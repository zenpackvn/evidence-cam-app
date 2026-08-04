import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:network/network.dart'
    show
        BaseOptions,
        Dio,
        IdempotencyInterceptor,
        Interceptor,
        RequestInterceptorHandler,
        RequestOptions,
        RetryInterceptor;

import 'ec_api.dart';
import 'ec_auth.dart';
import 'ec_feedback.dart';
import 'ec_repository.dart';

/// Production API origin — where a build lands when no dart-define points it
/// anywhere else.
const kDefaultApiBaseUrl = 'https://api.zenpack.vn';

/// The backend origin this build talks to, resolved at compile time:
/// `EC_API_URL` override → `API_BASE_URL` from the dart-define env file →
/// [kDefaultApiBaseUrl].
///
/// The default is a real origin, not the empty string: an empty URL selects the
/// offline [FakeEcRepository] below, so a plain `flutter build` used to ship an
/// app that showed empty lists forever. Pass `--dart-define=EC_API_URL=` (empty)
/// to ask for that offline build deliberately.
const kApiBaseUrl = String.fromEnvironment(
  'EC_API_URL',
  defaultValue: String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: kDefaultApiBaseUrl,
  ),
);

/// Origin của Zentam CMS nhận góp ý, phân giải lúc biên dịch:
/// `EC_FEEDBACK_URL` → `FEEDBACK_BASE_URL` trong file env → mặc định.
///
/// Rỗng nghĩa là build này KHÔNG gửi góp ý đi đâu cả (test, bản offline) — bên
/// gọi kiểm và tự bỏ nút, xem [buildFeedback].
const kFeedbackBaseUrl = String.fromEnvironment(
  'EC_FEEDBACK_URL',
  defaultValue: String.fromEnvironment(
    'FEEDBACK_BASE_URL',
    defaultValue: kDefaultFeedbackBaseUrl,
  ),
);

/// Client gửi góp ý, hoặc `null` khi build không cấu hình đích đến.
EcFeedback? buildFeedback({String url = kFeedbackBaseUrl}) =>
    url.isEmpty ? null : EcFeedback(baseUrl: url);

/// Builds the data source.
///
/// With a backend URL (see [kApiBaseUrl]) it returns the live
/// [RemoteEcRepository] whose Dio attaches [auth]'s Firebase ID token to every
/// request. With an empty URL it falls back to the empty [FakeEcRepository]
/// (tests / offline).
EcRepository buildRepository({EcAuth? auth, String url = kApiBaseUrl}) {
  if (url.isEmpty) return const FakeEcRepository();
  return RemoteEcRepository(buildApi(auth: auth, url: url));
}

/// Builds the authenticated API client used by both repositories and uploaders.
EcApi buildApi({EcAuth? auth, String url = kApiBaseUrl}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: url,
      // Without these, a dead connection hangs forever — the upload queue
      // is strictly serial, so one stuck request blocks every clip behind
      // it with no error ever surfacing.
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );
  if (auth != null) dio.interceptors.add(_BearerTokenInterceptor(auth));
  // A stable key per logical request lets the backend dedupe a replayed
  // POST/PATCH (see IdempotencyInterceptor's doc comment); RetryInterceptor
  // then safely retries a 500/502/503/504/429 — which means the request was
  // never fully processed — on *any* method, including the upload flow's
  // completeUpload/completeMultipartUpload. Neither was wired onto this Dio
  // before, unlike the DI-provided one (see NetworkModule.provideDio), which
  // meant every upload-path request went out with no retry protection at all.
  dio.interceptors.add(IdempotencyInterceptor());
  dio.interceptors.add(RetryInterceptor(dio));
  return EcApi(dio);
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

/// SDK key công khai của RevenueCat cho bản iOS (`appl_…`). Đây là khoá **công
/// khai** — nó chỉ định danh app với RevenueCat, không ký được giao dịch nào,
/// nên nằm trong bundle là đúng chỗ. Khoá bí mật (`sk_…`) tuyệt đối không.
const kRevenueCatIosKey = String.fromEnvironment('RC_IOS_API_KEY');

/// Khoá công khai của RevenueCat cho bản Android (`goog_…`). Chưa cấu hình —
/// Google Play chưa có sản phẩm nào.
const kRevenueCatAndroidKey = String.fromEnvironment('RC_ANDROID_API_KEY');

/// Khoá đúng cho nền tảng đang chạy, rỗng nếu nền tảng đó chưa cấu hình.
///
/// Mỗi nền tảng có khoá RIÊNG. Đưa khoá `appl_…` cho bản Android thì
/// `Purchases.configure` nhận nhưng mọi lời gọi sau đó đều hỏng, và hỏng theo
/// kiểu khó đoán chứ không báo "sai khoá" — nên phải chọn theo nền tảng chứ
/// không dùng chung một hằng số.
String get kRevenueCatKey => switch (defaultTargetPlatform) {
  TargetPlatform.iOS => kRevenueCatIosKey,
  TargetPlatform.android => kRevenueCatAndroidKey,
  _ => '',
};

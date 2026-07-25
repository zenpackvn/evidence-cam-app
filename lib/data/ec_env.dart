import 'package:network/network.dart' show BaseOptions, Dio;

import 'ec_api.dart';
import 'ec_repository.dart';

/// Chooses the data source from the `EC_API_URL` build define:
/// - empty (default) → [FakeEcRepository] (sample data, app runs offline);
/// - a URL → live backend via [RemoteEcRepository] + [EcApi].
///
/// After deploying the Worker, run the app with the URL and it goes live:
/// `fvm flutter run -t lib/main_ec.dart --dart-define=EC_API_URL=https://…workers.dev`
///
/// ponytail: a bare Dio for now — the auth-token interceptor
/// (network's AuthTokenProvider) is attached in B1 once Firebase auth lands.
EcRepository buildRepository({
  String url = const String.fromEnvironment('EC_API_URL'),
}) {
  if (url.isEmpty) return const FakeEcRepository();
  return RemoteEcRepository(EcApi(Dio(BaseOptions(baseUrl: url))));
}

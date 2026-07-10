import 'package:network/network.dart';

import '../models/entitlement_dto.dart';

part 'entitlement_remote_data_source.g.dart';

/// StampMail entitlement REST API. The server mirrors RevenueCat's entitlement
/// (TD-007); this reads the current Premium state.
@RestApi()
// Retrofit requires an abstract class even for a single endpoint; more
// endpoints (restore, products) land here later.
// ignore: one_member_abstracts
abstract class EntitlementRemoteDataSource {
  factory EntitlementRemoteDataSource(Dio dio, {String baseUrl}) =
      _EntitlementRemoteDataSource;

  @GET('/api/sm/entitlement')
  Future<EntitlementDto> get();
}

import 'package:injectable/injectable.dart';
import 'package:network/network.dart';

import 'entitlement_remote_data_source.dart';

@module
abstract class EntitlementRemoteModule {
  @lazySingleton
  EntitlementRemoteDataSource provideEntitlementRemoteDataSource(Dio dio) =>
      EntitlementRemoteDataSource(dio);
}

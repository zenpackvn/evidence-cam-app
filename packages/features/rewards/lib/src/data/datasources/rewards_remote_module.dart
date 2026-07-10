import 'package:injectable/injectable.dart';
import 'package:network/network.dart';

import 'rewards_remote_data_source.dart';

@module
abstract class RewardsRemoteModule {
  @lazySingleton
  RewardsRemoteDataSource provideRewardsRemoteDataSource(Dio dio) =>
      RewardsRemoteDataSource(dio);
}

import 'package:injectable/injectable.dart';
import 'package:network/network.dart';

import 'profile_remote_data_source.dart';

@module
abstract class ProfileRemoteModule {
  @lazySingleton
  ProfileRemoteDataSource provideProfileRemoteDataSource(Dio dio) =>
      ProfileRemoteDataSource(dio);
}

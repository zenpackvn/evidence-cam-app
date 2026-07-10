import 'package:injectable/injectable.dart';
import 'package:network/network.dart';

import 'stamps_remote_data_source.dart';

@module
abstract class StampsRemoteModule {
  @lazySingleton
  StampsRemoteDataSource provideStampsRemoteDataSource(Dio dio) =>
      StampsRemoteDataSource(dio);
}

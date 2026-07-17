import 'package:injectable/injectable.dart';
import 'package:network/network.dart';

import 'sample_stamps_remote_data_source.dart';

@module
abstract class SampleStampsRemoteModule {
  @lazySingleton
  SampleStampsRemoteDataSource provideSampleStampsRemoteDataSource(Dio dio) =>
      SampleStampsRemoteDataSource(dio);
}

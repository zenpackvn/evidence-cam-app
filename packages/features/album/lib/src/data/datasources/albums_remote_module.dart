import 'package:injectable/injectable.dart';
import 'package:network/network.dart';

import 'albums_remote_data_source.dart';

@module
abstract class AlbumsRemoteModule {
  @lazySingleton
  AlbumsRemoteDataSource provideAlbumsRemoteDataSource(Dio dio) =>
      AlbumsRemoteDataSource(dio);
}

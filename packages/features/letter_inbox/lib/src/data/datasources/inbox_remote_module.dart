import 'package:injectable/injectable.dart';
import 'package:network/network.dart';

import 'inbox_remote_data_source.dart';

@module
abstract class InboxRemoteModule {
  @lazySingleton
  InboxRemoteDataSource provideInboxRemoteDataSource(Dio dio) =>
      InboxRemoteDataSource(dio);
}

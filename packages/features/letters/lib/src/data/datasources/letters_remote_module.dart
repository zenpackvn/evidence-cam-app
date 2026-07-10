import 'package:injectable/injectable.dart';
import 'package:network/network.dart';

import 'letters_remote_data_source.dart';

@module
abstract class LettersRemoteModule {
  @lazySingleton
  LettersRemoteDataSource provideLettersRemoteDataSource(Dio dio) =>
      LettersRemoteDataSource(dio);
}

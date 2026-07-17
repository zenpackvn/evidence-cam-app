import 'package:network/network.dart';

import '../models/profile_dto.dart';

part 'profile_remote_data_source.g.dart';

/// StampMail profile REST API (SM-024).
@RestApi()
abstract class ProfileRemoteDataSource {
  factory ProfileRemoteDataSource(Dio dio, {String baseUrl}) =
      _ProfileRemoteDataSource;

  @GET('/api/sm/me')
  Future<ProfileDto> me();

  /// Partially updates the profile. The body is an untyped map because PATCH
  /// semantics need three states per field that a typed model cannot express:
  /// absent (leave alone), explicit null (clear — `date_of_birth`, AC-07), or a
  /// value. `ProfileRepositoryImpl` builds it.
  @PATCH('/api/sm/me')
  Future<ProfileDto> update(@Body() Map<String, dynamic> body);
}

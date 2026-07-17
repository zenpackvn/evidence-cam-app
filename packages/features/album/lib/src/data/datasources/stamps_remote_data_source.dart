import 'package:network/network.dart';

import '../models/stamp_dto.dart';
import '../models/stamp_request.dart';

part 'stamps_remote_data_source.g.dart';

/// StampMail stamps REST API. The image and recipe are immutable (re-editing
/// makes a new stamp); the only mutable field is the user-set name (SM-022
/// BR-08), exposed via [rename].
@RestApi()
abstract class StampsRemoteDataSource {
  factory StampsRemoteDataSource(Dio dio, {String baseUrl}) =
      _StampsRemoteDataSource;

  /// Lists stamps. With [since], returns the delta (changed rows including
  /// tombstones) whose server revision is greater than it; without it, the
  /// full live list.
  @GET('/api/sm/stamps')
  Future<List<StampDto>> list({@Query('since') int? since});

  @POST('/api/sm/stamps')
  Future<StampDto> create(@Body() StampRequest body);

  @PATCH('/api/sm/stamps/{id}')
  Future<StampDto> rename(
    @Path('id') String id,
    @Body() StampRenameRequest body,
    @Header('X-Expected-Rev') int? expectedRev,
  );

  @DELETE('/api/sm/stamps/{id}')
  Future<void> delete(
    @Path('id') String id,
    @Header('X-Expected-Rev') int? expectedRev,
  );
}

import 'package:network/network.dart';

import '../models/stamp_dto.dart';
import '../models/stamp_request.dart';

part 'stamps_remote_data_source.g.dart';

/// StampMail stamps REST API. Stamps are immutable (re-editing makes a new
/// stamp), so there is no update endpoint.
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

  @DELETE('/api/sm/stamps/{id}')
  Future<void> delete(
    @Path('id') String id,
    @Header('X-Expected-Rev') int? expectedRev,
  );
}

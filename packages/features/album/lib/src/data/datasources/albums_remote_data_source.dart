import 'package:network/network.dart';

import '../models/album_dto.dart';
import '../models/album_request.dart';

part 'albums_remote_data_source.g.dart';

/// StampMail custom-albums REST API.
@RestApi()
abstract class AlbumsRemoteDataSource {
  factory AlbumsRemoteDataSource(Dio dio, {String baseUrl}) =
      _AlbumsRemoteDataSource;

  @GET('/api/sm/albums')
  Future<List<AlbumDto>> list({@Query('since') int? since});

  @POST('/api/sm/albums')
  Future<AlbumDto> create(@Body() AlbumRequest body);

  @PUT('/api/sm/albums/{id}')
  Future<AlbumDto> update(
    @Path('id') String id,
    @Body() AlbumRequest body,
    @Header('X-Expected-Rev') int? expectedRev,
  );

  @DELETE('/api/sm/albums/{id}')
  Future<void> delete(
    @Path('id') String id,
    @Header('X-Expected-Rev') int? expectedRev,
  );
}

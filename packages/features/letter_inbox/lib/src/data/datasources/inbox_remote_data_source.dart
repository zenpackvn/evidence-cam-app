import 'package:network/network.dart';

import '../models/public_letter_dto.dart';

part 'inbox_remote_data_source.g.dart';

/// The public open-link endpoint (SM-017). When a signed-in viewer opens a
/// link, the viewer uid is passed so the server allows the same viewer to
/// re-open it. Received letters are never listed or stored (SM-017 BR-10).
@RestApi()
// ignore: one_member_abstracts — retrofit requires an abstract class.
abstract class InboxRemoteDataSource {
  factory InboxRemoteDataSource(Dio dio, {String baseUrl}) =
      _InboxRemoteDataSource;

  @GET('/public/letter/{id}')
  Future<PublicLetterDto> open(
    @Path('id') String linkId,
    @Query('viewer') String? viewer,
  );
}

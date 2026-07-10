import 'package:network/network.dart';

import '../models/public_letter_dto.dart';

part 'inbox_remote_data_source.g.dart';

/// Opens a letter link via the public endpoint. Public (no auth required); when
/// a signed-in viewer opens it, the viewer uid is passed so the server can
/// credit the sender and attribute a referral.
@RestApi()
// Retrofit requires an abstract class even for a single endpoint.
// ignore: one_member_abstracts
abstract class InboxRemoteDataSource {
  factory InboxRemoteDataSource(Dio dio, {String baseUrl}) =
      _InboxRemoteDataSource;

  @GET('/public/letter/{id}')
  Future<PublicLetterDto> open(
    @Path('id') String linkId,
    @Query('viewer') String? viewer,
  );
}

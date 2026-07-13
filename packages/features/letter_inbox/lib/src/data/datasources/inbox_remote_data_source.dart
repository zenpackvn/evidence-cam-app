import 'package:network/network.dart';

import '../models/inbox_entry_dto.dart';
import '../models/public_letter_dto.dart';

part 'inbox_remote_data_source.g.dart';

/// Inbox endpoints: the public open-link endpoint plus the authenticated
/// received-letters list/count (A17). When a signed-in viewer opens a link,
/// the viewer uid is passed so the server can record the inbox row and
/// credit the sender.
@RestApi()
abstract class InboxRemoteDataSource {
  factory InboxRemoteDataSource(Dio dio, {String baseUrl}) =
      _InboxRemoteDataSource;

  @GET('/public/letter/{id}')
  Future<PublicLetterDto> open(
    @Path('id') String linkId,
    @Query('viewer') String? viewer,
  );

  @GET('/api/sm/inbox')
  Future<List<InboxEntryDto>> list();

  @GET('/api/sm/inbox/count')
  Future<InboxCountDto> count();
}

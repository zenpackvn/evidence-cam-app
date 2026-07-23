import 'package:network/network.dart';

import '../models/letter_dto.dart';
import '../models/letter_requests.dart';
import '../models/link_dto.dart';

part 'letters_remote_data_source.g.dart';

/// StampMail letters + links REST API.
@RestApi()
abstract class LettersRemoteDataSource {
  factory LettersRemoteDataSource(Dio dio, {String baseUrl}) =
      _LettersRemoteDataSource;

  @POST('/api/sm/letters')
  Future<LetterDto> create(@Body() CreateLetterRequest body);

  @POST('/api/sm/letters/{id}/links')
  Future<LinkDto> createLink(
    @Path('id') String letterId,
    @Body() CreateLinkRequest body,
  );

  @GET('/api/sm/sent')
  Future<List<LinkDto>> sent();

  /// The caller's live letters, newest first (SM-021 detail view). Older
  /// servers without this route answer 404/405 — callers treat that as "no
  /// letter documents available" rather than an error.
  @GET('/api/sm/letters')
  Future<List<LetterDto>> list();
}

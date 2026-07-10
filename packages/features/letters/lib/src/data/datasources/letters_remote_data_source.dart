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
}

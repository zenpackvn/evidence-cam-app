import 'package:network/network.dart';

import '../models/sample_stamp_dto.dart';

part 'sample_stamps_remote_data_source.g.dart';

/// StampMail sample-stamp catalog API (SM-035). Read-only.
@RestApi()
// A retrofit @RestApi surface — retrofit generates the single method's impl.
// ignore: one_member_abstracts
abstract class SampleStampsRemoteDataSource {
  factory SampleStampsRemoteDataSource(Dio dio, {String baseUrl}) =
      _SampleStampsRemoteDataSource;

  /// The catalog, optionally filtered to one [theme] (SM-035 BR-02 / AC-01).
  @GET('/api/sm/sample-stamps')
  Future<List<SampleStampDto>> list({@Query('theme') String? theme});
}

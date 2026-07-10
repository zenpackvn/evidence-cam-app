import 'package:network/network.dart';

import '../models/seal_dtos.dart';

part 'rewards_remote_data_source.g.dart';

/// StampMail seals (Dấu) REST API. The spend endpoint returns 402 with a
/// SpendResultDto body when the balance is insufficient — the repository reads
/// that body rather than treating it as a hard error.
@RestApi()
abstract class RewardsRemoteDataSource {
  factory RewardsRemoteDataSource(Dio dio, {String baseUrl}) =
      _RewardsRemoteDataSource;

  @GET('/api/sm/seals')
  Future<SealBalanceDto> balance();

  @POST('/api/sm/seals/share')
  Future<ShareResultDto> awardShare();

  @POST('/api/sm/seals/spend')
  Future<SpendResultDto> spend(@Body() SpendRequest body);
}

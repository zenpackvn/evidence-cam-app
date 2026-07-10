import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';
import 'package:network/network.dart';

import '../../domain/entities/seal_ledger.dart';
import '../../domain/entities/unlock.dart';
import '../../domain/repositories/rewards_repository.dart';
import '../datasources/rewards_remote_data_source.dart';
import '../models/seal_dtos.dart';

@LazySingleton(as: RewardsRepository)
class RewardsRepositoryImpl implements RewardsRepository {
  RewardsRepositoryImpl(this._remote);

  final RewardsRemoteDataSource _remote;

  @override
  Future<Result<SealBalance>> balance() async {
    try {
      final dto = await _remote.balance();
      return Ok(
        SealBalance(
          balance: dto.balance,
          history: [
            for (final e in dto.history)
              SealEntry(
                amount: e.amount,
                reason: SealReason.fromWire(e.reason),
                refId: e.refId.isEmpty ? null : e.refId,
                createdAt: e.createdAt,
              ),
          ],
        ),
      );
    } on DioException catch (e) {
      return Err(_mapDioError(e));
    }
  }

  @override
  Future<Result<ShareReward>> awardShare() async {
    try {
      final dto = await _remote.awardShare();
      return Ok(ShareReward(awarded: dto.awarded, newBalance: dto.newBalance));
    } on DioException catch (e) {
      return Err(_mapDioError(e));
    }
  }

  @override
  Future<Result<SpendOutcome>> spend(UnlockType type, String itemId) async {
    try {
      final dto = await _remote.spend(
        SpendRequest(itemType: type.wire, itemId: itemId),
      );
      return Ok(
        SpendOutcome(unlocked: dto.unlocked, newBalance: dto.newBalance),
      );
    } on DioException catch (e) {
      // 402 Payment Required is a valid business outcome: not enough seals. The
      // body carries the shortfall, so surface it as a successful Result with
      // unlocked=false rather than an error.
      if (e.response?.statusCode == 402) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          final parsed = SpendResultDto.fromJson(data);
          return Ok(
            SpendOutcome(
              unlocked: false,
              newBalance: parsed.newBalance,
              shortfall: parsed.shortfall,
            ),
          );
        }
      }
      return Err(_mapDioError(e));
    }
  }

  Failure _mapDioError(DioException e) {
    final body = e.response?.data;
    if (body is Map<String, dynamic> && body['message'] is String) {
      return UnknownFailure(body['message'] as String);
    }
    return UnknownFailure(e.message ?? 'Network error');
  }
}

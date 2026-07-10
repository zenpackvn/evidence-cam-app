import 'package:architecture/architecture.dart';

import '../entities/seal_ledger.dart';
import '../entities/unlock.dart';

/// Reads the seal balance/history and requests server-side seal mutations
/// (SM-033). The client never computes balances — the server is the source of
/// truth (anti-fraud); this repository just relays.
abstract interface class RewardsRepository {
  /// Current balance + recent history (SM-033).
  Future<Result<SealBalance>> balance();

  /// Credits +10 seals for sharing a stamp, capped 3/week (BR-05/06). Past the
  /// cap [ShareReward.awarded] is false but the share still happens.
  Future<Result<ShareReward>> awardShare();

  /// Spends seals to permanently unlock [type]/[itemId] (BR-11/12/13). On an
  /// insufficient balance the outcome reports [SpendOutcome.shortfall].
  Future<Result<SpendOutcome>> spend(UnlockType type, String itemId);
}

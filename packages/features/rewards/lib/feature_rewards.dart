/// StampMail Rewards feature: the Seal (Dấu) economy — balance, history,
/// earning via share, and spending to unlock items (SM-033). All mutations are
/// server-side; the client reads and requests through `RewardsRepository`.
library;

export 'src/di.module.dart' show FeatureRewardsPackageModule;
export 'src/domain/entities/seal_ledger.dart';
export 'src/domain/entities/unlock.dart';
export 'src/domain/repositories/rewards_repository.dart';

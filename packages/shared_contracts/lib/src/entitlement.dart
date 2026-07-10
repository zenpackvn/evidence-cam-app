import 'package:architecture/architecture.dart';

/// A user's Premium subscription state, mirrored from the server's
/// `entitlements` row (RevenueCat webhook → Go server, tech-stack TD-007).
///
/// The client caches this so Premium filters still work offline (SM-006 BR-08);
/// a missing/unknown entitlement reads as [Entitlement.free].
class Entitlement {
  const Entitlement({
    required this.isPremium,
    this.productId,
    this.expiresAt,
  });

  /// The default non-premium state used when nothing is known yet.
  static const free = Entitlement(isPremium: false);

  final bool isPremium;

  /// Monthly/yearly SKU backing the subscription, if any.
  final String? productId;

  /// When the current subscription lapses, if known.
  final DateTime? expiresAt;
}

/// Reads the current user's [Entitlement]. Implemented by the premium feature
/// (which owns the RevenueCat/server sync) and consumed through `shared` by the
/// stamp creator and letters features to gate Premium content.
abstract class EntitlementReader extends NoParamUseCase<Entitlement> {
  const EntitlementReader();
}

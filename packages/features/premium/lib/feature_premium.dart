/// StampMail Premium feature: reads the user's entitlement from the server and
/// exposes it as the shared `EntitlementReader` so the stamp creator and
/// letters can gate Premium content (SM-028, TD-007).
///
/// The purchase/paywall flow (RevenueCat SDK) is added separately; the server
/// (fed by the RevenueCat webhook) is the source of truth for entitlement.
library;

export 'src/di.module.dart' show FeaturePremiumPackageModule;

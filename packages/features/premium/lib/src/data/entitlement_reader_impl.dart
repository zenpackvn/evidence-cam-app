import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';
import 'package:network/network.dart';
import 'package:shared_contracts/shared_contracts.dart';

import 'datasources/entitlement_remote_data_source.dart';

/// Reads the current user's [Entitlement] from the server and caches the last
/// known value so Premium gates keep working offline (SM-006 BR-08). Registered
/// as the shared [EntitlementReader] the stamp creator and letters resolve.
@LazySingleton(as: EntitlementReader)
class EntitlementReaderImpl extends EntitlementReader {
  EntitlementReaderImpl(this._remote);

  final EntitlementRemoteDataSource _remote;

  /// Last successfully fetched entitlement, served when the network is down.
  Entitlement _cached = Entitlement.free;

  @override
  Future<Result<Entitlement>> call([NoParams param = noParams]) async {
    // Creator/dev build: everything unlocked — always report Premium so no
    // feature is gated. We still hit the server to keep the cache warm, but the
    // result is forced Premium. Remove this override for production so the real
    // entitlement (RevenueCat/server) applies again.
    try {
      final dto = await _remote.get();
      _cached = Entitlement(
        isPremium: true,
        productId: dto.productId.isEmpty ? null : dto.productId,
        expiresAt: dto.expiresAt,
      );
    } on DioException {
      _cached = const Entitlement(isPremium: true);
    }
    return Ok(_cached);
  }
}

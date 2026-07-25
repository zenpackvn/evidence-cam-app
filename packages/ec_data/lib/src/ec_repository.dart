import 'ec_api.dart';
import 'ec_models.dart';

/// The seam screens read through. Today the app binds [FakeEcRepository]
/// (sample data, no network); pointing it at the live backend is swapping in
/// [RemoteEcRepository] once the Worker base URL is set — no screen changes.
abstract interface class EcRepository {
  Future<List<ShopDto>> shops();
  Future<QuotaDto> quota();
  Future<List<OrderSummaryDto>> orders(String shopId, {int? before});
  Future<OrderDto> createOrder(String shopId, String tracking);
  Future<DossierDto> shareDossier(String shopId, String orderId);
}

/// Live implementation — delegates straight to the typed [EcApi].
class RemoteEcRepository implements EcRepository {
  const RemoteEcRepository(this._api);

  final EcApi _api;

  @override
  Future<List<ShopDto>> shops() => _api.listShops();

  @override
  Future<QuotaDto> quota() => _api.getQuota();

  @override
  Future<List<OrderSummaryDto>> orders(String shopId, {int? before}) =>
      _api.listOrders(shopId, before: before);

  @override
  Future<OrderDto> createOrder(String shopId, String tracking) =>
      _api.findOrCreateOrder(shopId, tracking);

  @override
  Future<DossierDto> shareDossier(String shopId, String orderId) =>
      _api.createDossier(shopId, orderId);
}

/// In-memory sample data so the app runs end-to-end before the backend is
/// deployed. Same shapes the real API returns.
class FakeEcRepository implements EcRepository {
  const FakeEcRepository();

  @override
  Future<List<ShopDto>> shops() async => const [
    ShopDto(
      id: 's1',
      name: 'Shop ABC',
      platform: 'shopee',
      resolution: '720p',
      role: 'owner',
    ),
    ShopDto(
      id: 's2',
      name: 'Shop XYZ',
      platform: 'tiktok',
      resolution: '480p',
      role: 'manager',
    ),
  ];

  @override
  Future<QuotaDto> quota() async =>
      const QuotaDto(used: 263, cap: 500, remaining: 237, periodEnd: 0);

  @override
  Future<List<OrderSummaryDto>> orders(String shopId, {int? before}) async {
    // First page only; a cursor older than the sample data returns empty so
    // infinite scroll terminates. The live backend paginates for real.
    if (before != null) return const [];
    return const [
      OrderSummaryDto(
        id: 'o1',
        tracking: 'SPXVN024567890',
        createdAt: 3,
        evidenceCount: 2,
      ),
      OrderSummaryDto(
        id: 'o2',
        tracking: 'SPXVN024567321',
        createdAt: 2,
        evidenceCount: 1,
      ),
      OrderSummaryDto(
        id: 'o3',
        tracking: 'SPXVN024560012',
        createdAt: 1,
        evidenceCount: 3,
      ),
    ];
  }

  @override
  Future<OrderDto> createOrder(String shopId, String tracking) async =>
      OrderDto(id: 'new', tracking: tracking, createdAt: 0);

  @override
  Future<DossierDto> shareDossier(String shopId, String orderId) async =>
      const DossierDto(
        shareToken: 'demo-token',
        revoked: false,
        status: 'draft',
      );
}

import 'package:network/network.dart' show Dio;

import 'ec_models.dart';

/// Typed client for the EvidenceCam Workers API. Paths mirror
/// `evidencecam-backend` exactly. The [Dio] passed in carries the auth token
/// (via the network package's `AuthTokenProvider`, Core-4) and the base URL —
/// so this class stays free of auth/config concerns.
///
/// Presentational screens keep working on sample data today; wiring a screen to
/// live data is just calling the matching method here once the Worker URL is set.
class EcApi {
  const EcApi(this._dio);

  final Dio _dio;

  Future<T> _get<T>(
    String path,
    T Function(Map<String, dynamic>) parse, {
    Map<String, dynamic>? query,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: query,
    );
    return parse(res.data!);
  }

  Future<List<T>> _getList<T>(
    String path,
    T Function(Map<String, dynamic>) parse, {
    Map<String, dynamic>? query,
  }) async {
    final res = await _dio.get<List<dynamic>>(path, queryParameters: query);
    return res.data!.map((e) => parse(e as Map<String, dynamic>)).toList();
  }

  // --- account / quota (FR-15, FR-08) ---
  Future<AccountDto> getMe() => _get('/api/me', AccountDto.fromJson);

  Future<AccountDto> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
  }) async {
    final res = await _dio.put<Map<String, dynamic>>(
      '/api/me',
      data: {'name': ?name, 'phone': ?phone, 'avatar_url': ?avatarUrl},
    );
    return AccountDto.fromJson(res.data!);
  }

  Future<QuotaDto> getQuota() => _get('/api/quota', QuotaDto.fromJson);

  // --- shops / members (FR-05) ---
  Future<List<ShopDto>> listShops() => _getList('/api/shops', ShopDto.fromJson);

  Future<ShopDto> createShop({
    required String name,
    required String platform,
    String? resolution,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/shops',
      data: {'name': name, 'platform': platform, 'resolution': ?resolution},
    );
    return ShopDto.fromJson(res.data!);
  }

  Future<List<MemberDto>> listMembers(String shopId) =>
      _getList('/api/shops/$shopId/members', MemberDto.fromJson);

  Future<List<VideoTypeDto>> listVideoTypes(String shopId) =>
      _getList('/api/shops/$shopId/video-types', VideoTypeDto.fromJson);

  // --- orders / search (FR-04, FR-01) ---
  Future<List<OrderSummaryDto>> listOrders(String shopId, {int? before}) =>
      _getList(
        '/api/shops/$shopId/orders',
        OrderSummaryDto.fromJson,
        query: before == null ? null : {'before': before},
      );

  Future<List<OrderSummaryDto>> searchOrders(String shopId, String query) =>
      _getList(
        '/api/shops/$shopId/orders',
        OrderSummaryDto.fromJson,
        query: {'q': query},
      );

  Future<OrderDto> findOrCreateOrder(String shopId, String tracking) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/shops/$shopId/orders',
      data: {'tracking': tracking},
    );
    return OrderDto.fromJson(res.data!);
  }

  Future<OrderDetailDto> getOrder(String shopId, String orderId) =>
      _get('/api/shops/$shopId/orders/$orderId', OrderDetailDto.fromJson);

  // --- uploads (FR-03) ---
  Future<PresignDto> presignUpload(
    String shopId,
    String orderId, {
    required String kind,
    required int capturedAt,
    String? videoTypeId,
    String? device,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/shops/$shopId/orders/$orderId/uploads/presign',
      data: {
        'kind': kind,
        'capturedAt': capturedAt,
        'videoTypeId': ?videoTypeId,
        'device': ?device,
      },
    );
    return PresignDto.fromJson(res.data!);
  }

  Future<String> completeUpload(
    String shopId,
    String orderId,
    String evidenceId,
  ) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/shops/$shopId/orders/$orderId/uploads/$evidenceId/complete',
    );
    return res.data!['status'] as String;
  }

  // --- dossier (FR-07) ---
  Future<DossierDto> createDossier(String shopId, String orderId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/shops/$shopId/orders/$orderId/dossier',
    );
    return DossierDto.fromJson(res.data!);
  }

  Future<void> revokeDossier(String shopId, String orderId) =>
      _dio.delete<void>('/api/shops/$shopId/orders/$orderId/dossier');
}

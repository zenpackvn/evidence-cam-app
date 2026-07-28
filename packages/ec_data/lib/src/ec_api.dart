import 'package:network/network.dart' show Dio;

import 'ec_models.dart';

/// Typed client for the EvidenceCam Workers API. Paths mirror
/// `evidencecam-backend` exactly. The [Dio] passed in carries the auth token
/// (via the network package's `AuthTokenProvider`, Core-4) and the base URL —
/// so this class stays free of auth/config concerns.
///
/// Presentational screens wire to live data by calling the matching method here
/// once the Worker URL is set.
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

  Future<ShopDto> updateShop(
    String shopId, {
    String? name,
    String? platform,
    String? resolution,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/api/shops/$shopId',
      data: {
        'name': ?name,
        'platform': ?platform,
        'resolution': ?resolution,
      },
    );
    return ShopDto.fromJson(res.data!);
  }

  Future<List<MemberDto>> listMembers(String shopId) =>
      _getList('/api/shops/$shopId/members', MemberDto.fromJson);

  Future<void> addMember(
    String shopId, {
    required String accountUid,
    required String role,
  }) => _dio.post<void>(
    '/api/shops/$shopId/members',
    data: {'account_uid': accountUid, 'role': role},
  );

  Future<ShopInviteDto> sendShopInvite(
    String shopId, {
    required String contact,
    required String role,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/shops/$shopId/invites',
      data: {'contact': contact, 'role': role},
    );
    return ShopInviteDto.fromJson(res.data!);
  }

  Future<void> updateMemberRole(
    String shopId, {
    required String accountUid,
    required String role,
  }) => _dio.patch<void>(
    '/api/shops/$shopId/members/$accountUid',
    data: {'role': role},
  );

  Future<void> removeMember(String shopId, String accountUid) =>
      _dio.delete<void>('/api/shops/$shopId/members/$accountUid');

  Future<List<VideoTypeDto>> listVideoTypes(String shopId) =>
      _getList('/api/shops/$shopId/video-types', VideoTypeDto.fromJson);

  Future<VideoTypeDto> addVideoType(String shopId, String name) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/shops/$shopId/video-types',
      data: {'name': name},
    );
    return VideoTypeDto.fromJson(res.data!);
  }

  Future<VideoTypeDto> renameVideoType(
    String shopId,
    String typeId,
    String name,
  ) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/api/shops/$shopId/video-types/$typeId',
      data: {'name': name},
    );
    return VideoTypeDto.fromJson(res.data!);
  }

  Future<void> deleteVideoType(String shopId, String typeId) =>
      _dio.delete<void>('/api/shops/$shopId/video-types/$typeId');

  // --- orders / search (FR-04, FR-01) ---
  /// Lists a page of orders, newest first.
  ///
  /// [uploadState] (`pending` | `error` | `done`), [fromTs] and [videoTypeId]
  /// map onto the backend's `upload_state` / `from` / `video_type_id` query
  /// params. Filtering has to happen server-side: the list is paged, so
  /// filtering only the loaded page would quietly hide matches still on the
  /// next one.
  Future<List<OrderSummaryDto>> listOrders(
    String shopId, {
    int? before,
    String? uploadState,
    int? fromTs,
    String? videoTypeId,
  }) => _getList(
    '/api/shops/$shopId/orders',
    OrderSummaryDto.fromJson,
    query: {
      'before': ?before,
      'upload_state': ?uploadState,
      'from': ?fromTs,
      'video_type_id': ?videoTypeId,
    },
  );

  Future<List<OrderSummaryDto>> searchOrders(String shopId, String query) =>
      _getList(
        '/api/shops/$shopId/orders',
        OrderSummaryDto.fromJson,
        query: {'q': query},
      );

  Future<OrderDto> findOrCreateOrder(
    String shopId,
    String tracking, {
    int? capturedAt,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/shops/$shopId/orders',
      data: {'tracking': tracking, 'capturedAt': ?capturedAt},
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

  Future<MultipartUploadDto> createMultipartUpload(
    String shopId,
    String orderId, {
    required String kind,
    required int capturedAt,
    String? videoTypeId,
    String? device,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/shops/$shopId/orders/$orderId/uploads/multipart',
      data: {
        'kind': kind,
        'capturedAt': capturedAt,
        'videoTypeId': ?videoTypeId,
        'device': ?device,
      },
    );
    return MultipartUploadDto.fromJson(res.data!);
  }

  Future<List<MultipartPartUrlDto>> presignMultipartParts(
    String shopId,
    String orderId,
    String evidenceId, {
    required String uploadId,
    required List<int> partNumbers,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/shops/$shopId/orders/$orderId/uploads/$evidenceId/multipart/parts',
      data: {'uploadId': uploadId, 'partNumbers': partNumbers},
    );
    final parts = res.data!['parts'] as List<dynamic>;
    return parts
        .map((e) => MultipartPartUrlDto.fromJson(e as Map<String, dynamic>))
        .toList();
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

  Future<String> completeMultipartUpload(
    String shopId,
    String orderId,
    String evidenceId, {
    required String uploadId,
    required List<UploadedPartDto> parts,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/shops/$shopId/orders/$orderId/uploads/$evidenceId/multipart/complete',
      data: {
        'uploadId': uploadId,
        'parts': parts.map((p) => p.toJson()).toList(),
      },
    );
    return res.data!['status'] as String;
  }

  Future<void> abortMultipartUpload(
    String shopId,
    String orderId,
    String evidenceId, {
    required String uploadId,
  }) => _dio.post<void>(
    '/api/shops/$shopId/orders/$orderId/uploads/$evidenceId/multipart/abort',
    data: {'uploadId': uploadId},
  );

  Future<void> deleteEvidence(
    String shopId,
    String orderId,
    String evidenceId,
  ) => _dio.delete<void>(
    '/api/shops/$shopId/orders/$orderId/evidence/$evidenceId',
  );

  // --- dossier (FR-07) ---
  Future<DossierDto?> getDossier(String shopId, String orderId) async {
    final res = await _dio.get<Map<String, dynamic>?>(
      '/api/shops/$shopId/orders/$orderId/dossier',
      queryParameters: null,
    );
    final data = res.data;
    return data == null ? null : DossierDto.fromJson(data);
  }

  Future<DossierDto> createDossier(String shopId, String orderId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/shops/$shopId/orders/$orderId/dossier',
    );
    return DossierDto.fromJson(res.data!);
  }

  Future<void> revokeDossier(String shopId, String orderId) =>
      _dio.delete<void>('/api/shops/$shopId/orders/$orderId/dossier');

  Future<String> exportCsv(String shopId, {int? from, int? to}) async {
    final res = await _dio.get<String>(
      '/api/shops/$shopId/export',
      queryParameters: {
        'from': ?from,
        'to': ?to,
      },
    );
    return res.data!;
  }

  Future<void> deleteAccount({bool force = false, bool dryRun = false}) =>
      _dio.delete<void>(
        '/api/me',
        queryParameters: {'force': force, 'dry_run': dryRun},
      );
}

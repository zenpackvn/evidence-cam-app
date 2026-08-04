import 'package:ec_data/ec_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';
import 'package:test_utils/test_utils.dart';

class _MockDio extends Mock implements Dio {}

Response<T> _res<T>(String path, T data) => Response<T>(
  data: data,
  requestOptions: RequestOptions(path: path),
);

void main() {
  late _MockDio dio;
  late EcApi api;

  setUp(() {
    dio = _MockDio();
    api = EcApi(dio);
  });

  test('getMe parses the account', () async {
    when(
      () => dio.get<Map<String, dynamic>>(
        '/api/me',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async =>
          _res('/api/me', {'uid': 'u1', 'email': 'a@b.co', 'name': 'A'}),
    );

    final me = await api.getMe();
    expect(me.uid, 'u1');
    expect(me.email, 'a@b.co');
  });

  test('getQuota parses storage bytes', () async {
    when(
      () => dio.get<Map<String, dynamic>>(
        '/api/quota',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => _res('/api/quota', {
        'plan_code': 'basic',
        'used_bytes': 3,
        'cap_bytes': 100,
        'remaining_bytes': 97,
        'retention_days': 25,
      }),
    );

    final q = await api.getQuota();
    expect(q.remainingBytes, 97);
    expect(q.capBytes, 100);
    expect(q.planCode, 'basic');
    expect(q.retentionDays, 25);
  });

  test('listShops maps the list with roles', () async {
    when(
      () => dio.get<List<dynamic>>(
        '/api/shops',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => _res('/api/shops', <dynamic>[
        {
          'id': 's1',
          'name': 'Shop A',
          'platform': 'shopee',
          'resolution': '720p',
          'role': 'owner',
        },
        {
          'id': 's2',
          'name': 'Shop B',
          'platform': 'tiktok',
          'resolution': '480p',
          'role': 'staff',
        },
      ]),
    );

    final shops = await api.listShops();
    expect(shops, hasLength(2));
    expect(shops.first.role, 'owner');
    expect(shops[1].platform, 'tiktok');
  });

  test('findOrCreateOrder posts the tracking and parses the order', () async {
    when(
      () => dio.post<Map<String, dynamic>>(
        '/api/shops/s1/orders',
        data: any(named: 'data'),
      ),
    ).thenAnswer(
      (_) async => _res('/api/shops/s1/orders', {
        'id': 'o1',
        'tracking_raw': 'SPXVN1',
        'created_at': 111,
      }),
    );

    final order = await api.findOrCreateOrder('s1', 'SPXVN1');
    expect(order.id, 'o1');
    expect(order.tracking, 'SPXVN1');
    final captured =
        verify(
              () => dio.post<Map<String, dynamic>>(
                '/api/shops/s1/orders',
                data: captureAny(named: 'data'),
              ),
            ).captured.single
            as Map<String, dynamic>;
    expect(captured['tracking'], 'SPXVN1');
  });

  test(
    'findOrCreateOrder can include capturedAt for historical queued clips',
    () async {
      when(
        () => dio.post<Map<String, dynamic>>(
          '/api/shops/s1/orders',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => _res('/api/shops/s1/orders', {
          'id': 'o1',
          'tracking_raw': 'SPXVN1',
          'created_at': 111,
        }),
      );

      await api.findOrCreateOrder('s1', 'SPXVN1', capturedAt: 222);
      final captured =
          verify(
                () => dio.post<Map<String, dynamic>>(
                  '/api/shops/s1/orders',
                  data: captureAny(named: 'data'),
                ),
              ).captured.single
              as Map<String, dynamic>;

      expect(captured, {'tracking': 'SPXVN1', 'capturedAt': 222});
    },
  );

  test('listOrders parses live summary metadata', () async {
    when(
      () => dio.get<List<dynamic>>(
        '/api/shops/s1/orders',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => _res('/api/shops/s1/orders', <dynamic>[
        {
          'id': 'o1',
          'tracking_raw': 'SPXVN1',
          'created_at': 111,
          'evidence_count': 5,
          'video_count': 2,
          'last_captured_at': 222,
          'latest_type': 'Đóng hàng',
          'error_count': 1,
        },
      ]),
    );

    final page = await api.listOrders('s1');
    final order = page.items.single;

    expect(order.latestType, 'Đóng hàng');
    expect(order.lastCapturedAt, 222);
    expect(order.errorCount, 1);
    // Số video KHÁC số bản ghi bằng chứng: ảnh, clip hỏng và clip đã xoá vẫn
    // nằm trong `evidence_count` nhưng không mở ra xem được.
    expect(order.evidenceCount, 5);
    expect(order.videoCount, 2);
    // Không có header tổng thì cộng tạm trang đang xem.
    expect(page.totalVideos, 2);
    // Không có header phân trang thì trang này là tất cả — thà mất thanh
    // phân trang còn hơn vẽ ra số trang bịa.
    expect(page.total, 1);
    expect(page.pageCount, 1);
  });

  test('listOrders reads the total and page size from the headers', () async {
    when(
      () => dio.get<List<dynamic>>(
        '/api/shops/s1/orders',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => Response<List<dynamic>>(
        data: <dynamic>[
          for (var i = 0; i < 10; i++)
            {
              'id': 'o\$i',
              'tracking_raw': 'SPXVN\$i',
              'created_at': i,
              'evidence_count': 1,
            },
        ],
        headers: Headers.fromMap({
          'x-total-count': ['128'],
          'x-total-videos': ['640'],
          'x-page-size': ['10'],
        }),
        requestOptions: RequestOptions(path: '/api/shops/s1/orders'),
      ),
    );

    final page = await api.listOrders('s1', page: 2);

    expect(page.total, 128);
    expect(page.pageCount, 13);
    expect(page.firstIndex, 11);
    expect(page.lastIndex, 20);
    // Tổng của cả shop, không phải tổng 10 dòng đang xem.
    expect(page.totalVideos, 640);
  });

  test('getOrder parses playable evidence URLs', () async {
    when(
      () => dio.get<Map<String, dynamic>>(
        '/api/shops/s1/orders/o1',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => _res('/api/shops/s1/orders/o1', {
        'order': {
          'id': 'o1',
          'tracking_raw': 'SPXVN1',
          'created_at': 111,
        },
        'evidence': [
          {
            'id': 'e1',
            'kind': 'video',
            'captured_at': 222,
            'upload_status': 'done',
            'url': 'https://cdn.example/e1.mp4',
          },
        ],
      }),
    );

    final detail = await api.getOrder('s1', 'o1');

    expect(detail.evidence.single.url, 'https://cdn.example/e1.mp4');
  });

  test(
    'listMembers parses pending invites, which carry no account_uid',
    () async {
      when(
        () => dio.get<List<dynamic>>(
          '/api/shops/s1/members',
          queryParameters: null,
        ),
      ).thenAnswer(
        (_) async => _res('/api/shops/s1/members', <dynamic>[
          {
            'account_uid': 'u1',
            'role': 'owner',
            'name': 'Chủ shop',
            'email': 'owner@b.co',
            'status': 'active',
            'invite_contact': null,
            'invite_id': null,
          },
          {
            'account_uid': null,
            'role': 'staff',
            'name': null,
            'email': null,
            'status': 'pending',
            'invite_contact': 'moi@b.co',
            'invite_id': 'i1',
          },
        ]),
      );

      final members = await api.listMembers('s1');

      expect(members.first.accountUid, 'u1');
      expect(members.last.accountUid, isNull);
      expect(members.last.status, 'pending');
      expect(members.last.inviteContact, 'moi@b.co');
    },
  );

  test('member mutations call the shop member endpoints', () async {
    when(
      () => dio.post<void>('/api/shops/s1/members', data: any(named: 'data')),
    ).thenAnswer((_) async => _res('/api/shops/s1/members', null));
    when(
      () => dio.patch<void>(
        '/api/shops/s1/members/u2',
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => _res('/api/shops/s1/members/u2', null));
    when(
      () => dio.delete<void>('/api/shops/s1/members/u2'),
    ).thenAnswer((_) async => _res('/api/shops/s1/members/u2', null));

    await api.addMember('s1', accountUid: 'u2', role: 'staff');
    await api.updateMemberRole('s1', accountUid: 'u2', role: 'manager');
    await api.removeMember('s1', 'u2');

    verify(
      () => dio.post<void>(
        '/api/shops/s1/members',
        data: {
          'account_uid': 'u2',
          'role': 'staff',
        },
      ),
    ).called(1);
    verify(
      () => dio.patch<void>(
        '/api/shops/s1/members/u2',
        data: {
          'role': 'manager',
        },
      ),
    ).called(1);
    verify(() => dio.delete<void>('/api/shops/s1/members/u2')).called(1);
  });

  test(
    'sendShopInvite posts contact and role then parses invite status',
    () async {
      when(
        () => dio.post<Map<String, dynamic>>(
          '/api/shops/s1/invites',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => _res('/api/shops/s1/invites', {
          'id': 'i1',
          'shop_id': 's1',
          'contact': 'new@b.com',
          'role': 'staff',
          'status': 'pending',
          'invite_token': 'tok',
        }),
      );

      final invite = await api.sendShopInvite(
        's1',
        contact: 'new@b.com',
        role: 'staff',
      );

      expect(invite.status, 'pending');
      expect(invite.inviteToken, 'tok');
      verify(
        () => dio.post<Map<String, dynamic>>(
          '/api/shops/s1/invites',
          data: {'contact': 'new@b.com', 'role': 'staff'},
        ),
      ).called(1);
    },
  );

  test('video type mutations call the video-type endpoints', () async {
    when(
      () => dio.post<Map<String, dynamic>>(
        '/api/shops/s1/video-types',
        data: any(named: 'data'),
      ),
    ).thenAnswer(
      (_) async => _res('/api/shops/s1/video-types', {
        'id': 'vt1',
        'name': 'Cân hàng',
        'is_default': 0,
      }),
    );
    when(
      () => dio.patch<Map<String, dynamic>>(
        '/api/shops/s1/video-types/vt1',
        data: any(named: 'data'),
      ),
    ).thenAnswer(
      (_) async => _res('/api/shops/s1/video-types/vt1', {
        'id': 'vt1',
        'name': 'Cân ký',
        'is_default': 0,
      }),
    );
    when(
      () => dio.delete<void>('/api/shops/s1/video-types/vt1'),
    ).thenAnswer((_) async => _res('/api/shops/s1/video-types/vt1', null));

    expect((await api.addVideoType('s1', 'Cân hàng')).name, 'Cân hàng');
    expect((await api.renameVideoType('s1', 'vt1', 'Cân ký')).name, 'Cân ký');
    await api.deleteVideoType('s1', 'vt1');

    verify(
      () => dio.post<Map<String, dynamic>>(
        '/api/shops/s1/video-types',
        data: {'name': 'Cân hàng'},
      ),
    ).called(1);
    verify(
      () => dio.patch<Map<String, dynamic>>(
        '/api/shops/s1/video-types/vt1',
        data: {'name': 'Cân ký'},
      ),
    ).called(1);
  });

  test('export and account deletion endpoints', () async {
    when(
      () => dio.get<String>(
        '/api/shops/s1/export',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((_) async => _res('/api/shops/s1/export', 'tracking\n'));
    when(
      () => dio.delete<void>(
        '/api/me',
        queryParameters: {'force': true, 'dry_run': false},
      ),
    ).thenAnswer((_) async => _res('/api/me', null));
    when(
      () => dio.delete<void>(
        '/api/me',
        queryParameters: {'force': true, 'dry_run': true},
      ),
    ).thenAnswer((_) async => _res('/api/me', null));

    expect(await api.exportCsv('s1'), 'tracking\n');
    await api.deleteAccount(force: true);
    await api.deleteAccount(force: true, dryRun: true);
  });

  test('multipart upload endpoints are exposed', () async {
    when(
      () => dio.post<Map<String, dynamic>>(
        '/api/shops/s1/orders/o1/uploads/multipart',
        data: any(named: 'data'),
      ),
    ).thenAnswer(
      (_) async => _res('/api/shops/s1/orders/o1/uploads/multipart', {
        'evidenceId': 'ev1',
        'key': 'evidence/s1/o1/ev1.mp4',
        'uploadId': 'up1',
      }),
    );
    when(
      () => dio.post<Map<String, dynamic>>(
        '/api/shops/s1/orders/o1/uploads/ev1/multipart/parts',
        data: any(named: 'data'),
      ),
    ).thenAnswer(
      (_) async => _res(
        '/api/shops/s1/orders/o1/uploads/ev1/multipart/parts',
        {
          'parts': [
            {'partNumber': 1, 'uploadUrl': 'https://r2/part1'},
          ],
        },
      ),
    );
    when(
      () => dio.post<Map<String, dynamic>>(
        '/api/shops/s1/orders/o1/uploads/ev1/multipart/complete',
        data: any(named: 'data'),
      ),
    ).thenAnswer(
      (_) async => _res(
        '/api/shops/s1/orders/o1/uploads/ev1/multipart/complete',
        {'status': 'done'},
      ),
    );
    when(
      () => dio.post<void>(
        '/api/shops/s1/orders/o1/uploads/ev1/multipart/abort',
        data: any(named: 'data'),
      ),
    ).thenAnswer(
      (_) async => _res(
        '/api/shops/s1/orders/o1/uploads/ev1/multipart/abort',
        null,
      ),
    );

    final created = await api.createMultipartUpload(
      's1',
      'o1',
      kind: 'video',
      capturedAt: 100,
    );
    expect(created.uploadId, 'up1');
    expect(
      (await api.presignMultipartParts(
        's1',
        'o1',
        'ev1',
        uploadId: 'up1',
        partNumbers: [1],
      )).single.uploadUrl,
      'https://r2/part1',
    );
    expect(
      await api.completeMultipartUpload(
        's1',
        'o1',
        'ev1',
        uploadId: 'up1',
        parts: const [UploadedPartDto(partNumber: 1, etag: 'etag1')],
      ),
      'done',
    );
    await api.abortMultipartUpload('s1', 'o1', 'ev1', uploadId: 'up1');
  });
}

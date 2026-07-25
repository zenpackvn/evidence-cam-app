import 'package:flutter_starter_template/data/ec_api.dart';
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

  test('getQuota parses remaining', () async {
    when(
      () => dio.get<Map<String, dynamic>>(
        '/api/quota',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => _res('/api/quota', {
        'used': 3,
        'cap': 100,
        'remaining': 97,
        'period_end': 123,
      }),
    );

    final q = await api.getQuota();
    expect(q.remaining, 97);
    expect(q.cap, 100);
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
}

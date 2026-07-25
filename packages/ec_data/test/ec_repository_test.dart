import 'package:ec_data/ec_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/test_utils.dart';

class _MockApi extends Mock implements EcApi {}

void main() {
  group('FakeEcRepository', () {
    const repo = FakeEcRepository();

    test('returns sample shops and orders (app runs offline)', () async {
      expect(await repo.shops(), isNotEmpty);
      final orders = await repo.orders('s1');
      expect(orders.first.tracking, startsWith('SPXVN'));
    });
  });

  group('RemoteEcRepository', () {
    late _MockApi api;
    late RemoteEcRepository repo;

    setUp(() {
      api = _MockApi();
      repo = RemoteEcRepository(api);
    });

    test('delegates shops() to the API', () async {
      when(() => api.listShops()).thenAnswer(
        (_) async => const [
          ShopDto(
            id: 's1',
            name: 'A',
            platform: 'shopee',
            resolution: '720p',
            role: 'owner',
          ),
        ],
      );
      final shops = await repo.shops();
      expect(shops.single.id, 's1');
      verify(() => api.listShops()).called(1);
    });

    test('delegates createOrder() to findOrCreateOrder', () async {
      when(() => api.findOrCreateOrder('s1', 'SPXVN9')).thenAnswer(
        (_) async => const OrderDto(id: 'o9', tracking: 'SPXVN9', createdAt: 0),
      );
      final order = await repo.createOrder('s1', 'SPXVN9');
      expect(order.id, 'o9');
      verify(() => api.findOrCreateOrder('s1', 'SPXVN9')).called(1);
    });
  });
}

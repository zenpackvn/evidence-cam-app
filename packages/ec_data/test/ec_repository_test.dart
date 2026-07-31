import 'package:ec_data/ec_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/test_utils.dart';

class _MockApi extends Mock implements EcApi {}

void main() {
  group('FakeEcRepository', () {
    const repo = FakeEcRepository();

    test(
      'returns empty offline data instead of demo business records',
      () async {
        expect(await repo.shops(), isEmpty);
        expect((await repo.orders('s1')).items, isEmpty);
        expect(await repo.videoTypes('s1'), isEmpty);
      },
    );
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

    test('delegates searchOrders() to the API', () async {
      when(() => api.searchOrders('s1', 'SPXVN9')).thenAnswer(
        (_) async => const [
          OrderSummaryDto(
            id: 'o9',
            tracking: 'SPXVN9',
            createdAt: 0,
            evidenceCount: 2,
          ),
        ],
      );
      final orders = await repo.searchOrders('s1', 'SPXVN9');
      expect(orders.single.id, 'o9');
      verify(() => api.searchOrders('s1', 'SPXVN9')).called(1);
    });
  });
}

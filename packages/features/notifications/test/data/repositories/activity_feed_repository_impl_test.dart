import 'package:architecture/architecture.dart';
import 'package:feature_notifications/feature_notifications.dart';
import 'package:feature_notifications/src/data/datasources/notifications_remote_data_source.dart';
import 'package:feature_notifications/src/data/models/user_activity_dto.dart';
import 'package:feature_notifications/src/data/repositories/activity_feed_repository_impl.dart';
import 'package:feature_notifications/src/domain/entities/activity_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';

import '../../support.dart';

class MockNotificationsRemoteDataSource extends Mock
    implements NotificationsRemoteDataSource {}

void main() {
  late MockNotificationsRemoteDataSource remote;
  late ActivityFeedRepositoryImpl repository;

  final now = DateTime(2026, 6, 1, 12);

  setUp(() {
    remote = MockNotificationsRemoteDataSource();
    repository = ActivityFeedRepositoryImpl(remote);
  });

  group('ActivityFeedRepositoryImpl.page', () {
    test('passes the cursor through and maps the page to domain', () async {
      when(
        () => remote.activityFeed(cursor: 'c0', limit: 20),
      ).thenAnswer(
        (_) async => UserActivityPageDto(
          items: [
            UserActivityDto(
              id: 'a-1',
              description: 'Signed in',
              type: 'signed_in',
              createdAt: now,
            ),
            UserActivityDto(
              id: 'a-2',
              description: 'Something',
              type: 'unexpected',
              createdAt: now,
            ),
          ],
          nextCursor: 'c1',
        ),
      );

      final result = await repository.page(cursor: 'c0', limit: 20);

      final ok = result as Ok<ActivityPage>;
      expect(ok.value.items, hasLength(2));
      expect(ok.value.items[0].type, UserActivityType.signedIn);
      expect(ok.value.items[1].type, UserActivityType.other);
      expect(ok.value.nextCursor, 'c1');
      verify(() => remote.activityFeed(cursor: 'c0', limit: 20)).called(1);
    });

    test('null nextCursor signals the last page', () async {
      when(
        () => remote.activityFeed(cursor: null, limit: 20),
      ).thenAnswer(
        (_) async => const UserActivityPageDto(items: [], nextCursor: null),
      );

      final result = await repository.page(limit: 20);

      final ok = result as Ok<ActivityPage>;
      expect(ok.value.items, isEmpty);
      expect(ok.value.nextCursor, isNull);
    });

    test('maps a DioException to a Failure instead of throwing', () async {
      when(() => remote.activityFeed(cursor: null, limit: 20)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/activity/feed'),
        ),
      );

      final result = await repository.page(limit: 20);

      expect(result, isA<Err<ActivityPage>>());
    });
  });
}

import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';
import 'package:network/network.dart';

import '../../domain/entities/activity_page.dart';
import '../../domain/entities/user_activity.dart';
import '../../domain/repositories/activity_feed_repository.dart';
import '../datasources/notifications_remote_data_source.dart';
import '../local/activity_entity_mapper.dart';

/// Online-only cursor pagination over `/api/activity/feed`. Network errors are
/// mapped to [Failure]s and returned via [Result] — never thrown — so the UI
/// can render an error page without a try/catch at the call site.
@LazySingleton(as: ActivityFeedRepository)
class ActivityFeedRepositoryImpl implements ActivityFeedRepository {
  ActivityFeedRepositoryImpl(this._remote);

  final NotificationsRemoteDataSource _remote;

  @override
  Future<Result<ActivityPage>> page({String? cursor, int limit = 20}) async {
    try {
      final dto = await _remote.activityFeed(cursor: cursor, limit: limit);
      final items = dto.items
          .map(
            (e) => UserActivity(
              id: e.id,
              description: e.description,
              type: activityTypeFromRaw(e.type),
              createdAt: e.createdAt,
            ),
          )
          .toList(growable: false);
      return Ok(ActivityPage(items: items, nextCursor: dto.nextCursor));
    } on DioException catch (e) {
      return Err(UnknownFailure(e.message ?? 'Network error'));
    } on Object {
      return const Err(UnknownFailure('Unexpected server response'));
    }
  }
}

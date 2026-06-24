import 'package:network/network.dart';

import '../models/notification_dto.dart';
import '../models/user_activity_dto.dart';

part 'notifications_remote_data_source.g.dart';

@RestApi()
abstract class NotificationsRemoteDataSource {
  factory NotificationsRemoteDataSource(Dio dio, {String baseUrl}) =
      _NotificationsRemoteDataSource;

  @GET('/api/notifications')
  Future<List<NotificationDto>> listNotifications();

  @GET('/api/activity')
  Future<List<UserActivityDto>> listActivity();

  /// Cursor-paginated activity feed. Pass [cursor] from the previous page's
  /// `next_cursor` (null for the first page); [limit] caps the page size.
  @GET('/api/activity/feed')
  Future<UserActivityPageDto> activityFeed({
    @Query('cursor') String? cursor,
    @Query('limit') int? limit,
  });

  @PATCH('/api/notifications/{id}/read')
  Future<void> markRead(@Path('id') String id);
}

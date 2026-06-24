import 'package:architecture/architecture.dart';

import '../entities/activity_page.dart';

/// Reads the cursor-paginated activity feed straight from the server.
///
/// Unlike the offline-first notifications repository this is online-only by
/// design: it is the reference for cursor pagination of a server-owned list too
/// large to fully sync. Pass `cursor` from the previous page (null for the
/// first page). Kept an interface so the data layer binds it via DI, matching
/// the other feature repositories.
// ignore: one_member_abstracts
abstract interface class ActivityFeedRepository {
  Future<Result<ActivityPage>> page({String? cursor, int limit});
}

import 'user_activity.dart';

/// One page of the activity feed plus the cursor to fetch the next one.
///
/// [nextCursor] is null when this is the last page. This is the cursor
/// pagination contract the reference feed UI consumes; it is intentionally
/// separate from the offline-first notifications feed, which syncs the whole
/// list rather than paging it.
class ActivityPage {
  const ActivityPage({required this.items, required this.nextCursor});

  final List<UserActivity> items;
  final String? nextCursor;
}

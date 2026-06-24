import 'package:architecture/architecture.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../domain/entities/user_activity.dart';
import '../../domain/repositories/activity_feed_repository.dart';
import '../../locator.dart';

/// Reference implementation of cursor-based infinite-scroll pagination.
///
/// This is the pattern to copy when a screen reads a server-owned list too
/// large to fully sync: a [PagingController] keyed by an opaque `String?`
/// cursor drives a [PagedListView]. Page 1 uses a null cursor; each fetched
/// page returns the cursor for the next, and a null cursor ends the feed.
class ActivityFeedScreen extends StatefulWidget {
  const ActivityFeedScreen({super.key});

  @override
  State<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends State<ActivityFeedScreen> {
  static const _pageSize = 20;

  late final PagingController<String?, UserActivity> _controller =
      PagingController<String?, UserActivity>(
        getNextPageKey: (state) {
          // First page: null cursor. Subsequent: the cursor the last page
          // returned; null ends pagination.
          if (state.pages == null || state.pages!.isEmpty) return null;
          return _lastCursor;
        },
        fetchPage: _fetchPage,
      );

  // The cursor returned by the most recently fetched page. Held outside the
  // controller because the page items are UserActivity, not the cursor.
  String? _lastCursor;

  Future<List<UserActivity>> _fetchPage(String? cursor) async {
    final result = await getIt<ActivityFeedRepository>().page(
      cursor: cursor,
      limit: _pageSize,
    );
    switch (result) {
      case Ok(:final value):
        _lastCursor = value.nextCursor;
        return value.items;
      case Err(:final failure):
        // The controller surfaces a thrown error to its error builder.
        throw Exception(failure.message);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity')),
      body: RefreshIndicator(
        onRefresh: () async {
          _lastCursor = null;
          _controller.refresh();
        },
        child: PagingListener<String?, UserActivity>(
          controller: _controller,
          builder: (context, state, fetchNextPage) =>
              PagedListView<String?, UserActivity>.separated(
                state: state,
                fetchNextPage: fetchNextPage,
                separatorBuilder: (_, _) => const Divider(height: 1),
                builderDelegate: PagedChildBuilderDelegate<UserActivity>(
                  itemBuilder: (context, item, index) => ListTile(
                    title: Text(item.description),
                    subtitle: Text(item.type.name),
                  ),
                  firstPageErrorIndicatorBuilder: (context) =>
                      _RetryMessage(onRetry: _controller.refresh),
                  newPageErrorIndicatorBuilder: (context) =>
                      _RetryMessage(onRetry: _controller.fetchNextPage),
                  noItemsFoundIndicatorBuilder: (context) =>
                      const Center(child: Text('No activity yet')),
                ),
              ),
        ),
      ),
    );
  }
}

class _RetryMessage extends StatelessWidget {
  const _RetryMessage({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Something went wrong'),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

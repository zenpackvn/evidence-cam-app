import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/inbox_entry.dart';
import '../bloc/inbox_list_cubit.dart';
import 'inbox_list_screen.dart';

/// Hosts [InboxListScreen] behind [InboxListCubit], mapping the domain inbox
/// entries onto the screen's row view-model (SM-018, F04-S07).
class InboxListPage extends StatelessWidget {
  const InboxListPage({
    required this.createCubit,
    this.onOpen,
    this.onCompose,
    super.key,
  });

  /// Builds the cubit (from the host's DI); the page owns and disposes it.
  final InboxListCubit Function() createCubit;

  final ValueChanged<InboxItem>? onOpen;

  /// Forwarded to the sent tab's "Tạo thư đầu tiên" CTA (F04-S07d).
  final VoidCallback? onCompose;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createCubit()..load(),
      child: BlocBuilder<InboxListCubit, InboxListState>(
        builder: (context, state) => InboxListScreen(
          items: [for (final e in state.entries) _toItem(e)],
          onOpen: onOpen,
          onCompose: onCompose,
        ),
      ),
    );
  }

  InboxItem _toItem(InboxEntry e) => InboxItem(
    linkId: e.linkId,
    // ponytail: the inbox row carries only sender_uid — display names need a
    // backend enrichment of GET /api/sm/inbox (A17 follow-up).
    senderName: 'Người gửi ẩn danh',
    preview: 'Chạm để đọc thư 💌',
    time: _formatDate(e.openedAt.toLocal()),
    unread: !e.read,
  );

  static String _formatDate(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }
}

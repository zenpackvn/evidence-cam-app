import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// SM-018 — "Hộp thư" (F04-S07 / F04-S07d): the received-letters list behind a
/// "Hộp thư đến / Thư đã gửi" segmented pill, with the search field and the
/// white list card from the design. The sent tab shows its empty state until
/// the sent-letters listing (A5.2) is wired.
class InboxListScreen extends StatefulWidget {
  const InboxListScreen({
    this.items = const [],
    this.onOpen,
    this.onCompose,
    super.key,
  });

  final List<InboxItem> items;
  final ValueChanged<InboxItem>? onOpen;

  /// Called by the "Tạo thư đầu tiên" CTA on the sent tab (F04-S07d).
  final VoidCallback? onCompose;

  @override
  State<InboxListScreen> createState() => _InboxListScreenState();
}

class _InboxListScreenState extends State<InboxListScreen> {
  static const _ground = Color(0xFFFBF4EC);

  bool _sentTab = false;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Scaffold(
      backgroundColor: _ground,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.lg,
                AppSpacing.xxl,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hộp thư đến 🌸',
                    style: context.textTheme.displayMedium?.copyWith(
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Những bức thư yêu thương đang chờ bạn ✨',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _SearchPill(),
                  const SizedBox(height: 10),
                  _Segments(
                    sentTab: _sentTab,
                    onChanged: (sent) => setState(() => _sentTab = sent),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _sentTab
                  ? _SentEmpty(onCompose: widget.onCompose)
                  : widget.items.isEmpty
                  ? const _InboxEmpty()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xxl,
                        AppSpacing.md,
                        AppSpacing.xxl,
                        AppSpacing.xxl,
                      ),
                      child: _ListCard(
                        items: widget.items,
                        onOpen: widget.onOpen,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A row in the inbox list.
class InboxItem {
  const InboxItem({
    required this.linkId,
    required this.senderName,
    required this.preview,
    required this.time,
    this.unread = false,
    this.avatarUrl,
    this.unreadCount = 1,
  });

  final String linkId;
  final String senderName;
  final String preview;
  final String time;
  final bool unread;

  /// Sender avatar (http or `asset:`); an icon placeholder when null.
  final String? avatarUrl;

  /// Number shown in the coral badge when [unread].
  final int unreadCount;
}

/// .pen search pill: #F3EBE2, h46, radius-pill, 18px glyph + body-md hint.
class _SearchPill extends StatelessWidget {
  const _SearchPill();

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: const BoxDecoration(
        color: Color(0xFFF3EBE2),
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Text(
            'Tìm thư, người gửi, chủ đề...',
            style: context.textTheme.bodyMedium?.copyWith(
              color: scheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

/// .pen segments: #F1EBE4 pill (h44, 4px inset); the active side is a white
/// pill with coral w700 label.
class _Segments extends StatelessWidget {
  const _Segments({required this.sentTab, required this.onChanged});

  final bool sentTab;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: Color(0xFFF1EBE4),
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
      child: Row(
        children: [
          _Segment(
            label: 'Hộp thư đến',
            active: !sentTab,
            onTap: () => onChanged(false),
          ),
          const SizedBox(width: AppSpacing.xs),
          _Segment(
            label: 'Thư đã gửi',
            active: sentTab,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: active ? context.brand.surfaceElevated : Colors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(999)),
          ),
          child: Center(
            child: Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: active ? scheme.primary : scheme.onSurfaceVariant,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The white list card (radius-20) with hairline-divided rows.
class _ListCard extends StatelessWidget {
  const _ListCard({required this.items, required this.onOpen});

  final List<InboxItem> items;
  final ValueChanged<InboxItem>? onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs,
        horizontal: 14,
      ),
      decoration: BoxDecoration(
        color: context.brand.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        children: [
          for (final (i, item) in items.indexed) ...[
            if (i > 0) Divider(height: 1, color: context.brand.borderSubtle),
            _InboxRow(item: item, onTap: () => onOpen?.call(item)),
          ],
        ],
      ),
    );
  }
}

class _InboxRow extends StatelessWidget {
  const _InboxRow({required this.item, required this.onTap});

  final InboxItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.avatarUrl != null)
              AppNetworkImage(
                imageUrl: item.avatarUrl!,
                width: 56,
                height: 56,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              )
            else
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(Icons.person, color: scheme.onPrimaryContainer),
              ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.senderName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (item.unread) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(item.time, style: context.textTheme.bodySmall),
                if (item.unread) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${item.unreadCount}',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// F04-S07d — the sent tab's empty state: illustration, Baloo title, body-lg
/// subtitle, and the 290×54 coral CTA.
class _SentEmpty extends StatelessWidget {
  const _SentEmpty({required this.onCompose});

  final VoidCallback? onCompose;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        children: [
          const SizedBox(height: 100),
          Image.asset(
            'assets/illustrations/f5-empty-sent.png',
            package: 'feature_letter_inbox',
            width: 240,
            excludeFromSemantics: true,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'Bạn chưa gửi thư nào',
            style: context.textTheme.displayMedium?.copyWith(fontSize: 30),
          ),
          const SizedBox(height: 10),
          Text(
            'Hãy tạo thư đầu tiên để gửi yêu thương\ntheo cách của riêng bạn.',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: 290,
            height: 54,
            child: FilledButton(
              onPressed: onCompose,
              style: FilledButton.styleFrom(
                backgroundColor: context.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                textStyle: context.textTheme.titleMedium,
              ),
              child: const Text('Tạo thư đầu tiên'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InboxEmpty extends StatelessWidget {
  const _InboxEmpty();

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mark_email_unread_outlined,
              size: 56,
              color: scheme.primary,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Chưa có thư nào',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Khi ai đó mở thư bạn gửi hoặc gửi thư cho bạn,\nthư sẽ xuất hiện ở đây.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

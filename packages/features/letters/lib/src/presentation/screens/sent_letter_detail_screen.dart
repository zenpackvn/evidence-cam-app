import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/letter.dart';
import '../../domain/entities/letter_link.dart';
import '../bloc/sent_letters_cubit.dart';

/// SM-021 — "Xem thư đã gửi" (mockup 5-3 "Hộp thư đã gửi"): one letter's
/// content card (title, sent time, body), the "Trạng thái link" list with a
/// per-link description and timestamp, and the actions — "Gia hạn link"
/// (BR-04, blocked once opened per BR-05) and "Xem trước thư".
///
/// Reads from the mailbox's [SentLettersCubit] (provided above this route) so
/// list and detail share one source of truth; a renewal here shows in the
/// list immediately.
class SentLetterDetailScreen extends StatefulWidget {
  const SentLetterDetailScreen({required this.letterId, super.key});

  final String letterId;

  @override
  State<SentLetterDetailScreen> createState() => _SentLetterDetailScreenState();
}

class _SentLetterDetailScreenState extends State<SentLetterDetailScreen> {
  static const _ground = Color(0xFFFAF4EC);

  bool _expanded = false;

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _renew(SentLetter expired) async {
    final ok = await context.read<SentLettersCubit>().recreateLink(expired);
    if (!mounted) return;
    _snack(ok ? 'Đã tạo link mới.' : 'Không tạo được link mới. Thử lại.');
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SentLettersCubit>().state;
    final links = state.linksFor(widget.letterId);
    final letter = state.letterFor(widget.letterId);
    final anyOpened = links.any((l) => l.status == SentStatus.opened);
    final expired = links
        .where((l) => l.status == SentStatus.expired)
        .firstOrNull;
    final busy = state.recreatingLetterId == widget.letterId;
    return Scaffold(
      backgroundColor: _ground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TopNav(onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: links.isEmpty
                  ? const Center(child: Text('Không tìm thấy thư.'))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xxl,
                        AppSpacing.sm,
                        AppSpacing.xxl,
                        AppSpacing.xxl,
                      ),
                      children: [
                        Text(
                          'Hộp thư đã gửi',
                          style: AppSerif.style(
                            fontSize: 30,
                            color: context.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _LetterCard(
                          letter: letter,
                          fallbackLink: links.first,
                          expanded: _expanded,
                          onToggle: () =>
                              setState(() => _expanded = !_expanded),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'Trạng thái link',
                          style: AppSerif.style(
                            fontSize: 22,
                            color: context.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        for (final (i, sent) in links.indexed) ...[
                          _LinkCard(
                            sent: sent,
                            isPrimary: i == links.length - 1,
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                        SizedBox(
                          height: 54,
                          child: FilledButton.icon(
                            // BR-04: renewal targets an expired link; BR-05: a
                            // letter that was opened mints no more links.
                            onPressed: (expired == null || anyOpened || busy)
                                ? null
                                : () => _renew(expired),
                            icon: busy
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.refresh),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                              ),
                            ),
                            label: const Text('Gia hạn link'),
                          ),
                        ),
                        if (letter != null) ...[
                          const SizedBox(height: AppSpacing.sm + 2),
                          SizedBox(
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.of(context).push<void>(
                                MaterialPageRoute(
                                  builder: (_) => _LetterView(letter: letter),
                                ),
                              ),
                              icon: const Icon(Icons.mail_outline),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.lg,
                                  ),
                                ),
                              ),
                              label: const Text('Xem trước thư'),
                            ),
                          ),
                        ],
                        if (anyOpened)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.md),
                            child: Text(
                              'Thư đã được nhận — không thể tạo link mới.',
                              textAlign: TextAlign.center,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Top nav (mockup 5-3): back arrow + centred wordmark.
class _TopNav extends StatelessWidget {
  const _TopNav({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(Icons.arrow_back, color: scheme.onSurface),
          ),
          Expanded(
            child: Center(
              // scaleDown keeps the wordmark from overflowing narrow widths.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'StampMail',
                    style: AppSerif.style(fontSize: 26, color: scheme.primary),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.waves,
                    size: 16,
                    color: scheme.primary.withValues(alpha: 0.7),
                  ),
                ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

/// The letter content card (mockup 5-3): title, sent time, body preview with
/// "Xem thêm". Falls back to the link's platform when the server doesn't
/// expose letter documents yet.
class _LetterCard extends StatelessWidget {
  const _LetterCard({
    required this.letter,
    required this.fallbackLink,
    required this.expanded,
    required this.onToggle,
  });

  final Letter? letter;
  final SentLetter fallbackLink;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final letter = this.letter;
    final title = (letter?.content.title.isNotEmpty ?? false)
        ? letter!.content.title
        : 'Thư gửi qua ${_platformLabel(fallbackLink)}';
    final sentAt = letter?.createdAt ?? fallbackLink.link.createdAt;
    final body = letter?.content.text ?? '';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.brand.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F24211F),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppSerif.style(fontSize: 24, color: scheme.onSurface)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Đã gửi lúc ${_formatTime(sentAt.toLocal())}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (letter != null && letter.stampIds.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(
                  Icons.local_post_office_outlined,
                  size: 14,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${letter.stampIds.length} tem đính kèm',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
          if (body.isNotEmpty) ...[
            Divider(height: AppSpacing.xxl, color: context.brand.borderSubtle),
            Text(
              body,
              maxLines: expanded ? null : 4,
              overflow: expanded ? null : TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: onToggle,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    expanded ? 'Thu gọn' : 'Xem thêm',
                    style: context.textTheme.labelLarge?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    expanded ? Icons.expand_less : Icons.chevron_right,
                    size: 16,
                    color: scheme.primary,
                  ),
                ],
              ),
            ),
          ] else if (letter == null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Nội dung thư chưa khả dụng trên máy chủ này.',
              style: context.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// One link's status card (mockup 5-3 `Trạng thái link`): a tinted icon
/// circle, "Link chính/dự phòng", a plain-words description, the relevant
/// timestamp, and the status pill.
class _LinkCard extends StatelessWidget {
  const _LinkCard({required this.sent, required this.isPrimary});

  final SentLetter sent;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final brand = context.brand;
    final link = sent.link;
    final (circleBg, circleFg, icon) = switch (sent.status) {
      SentStatus.opened => (
        brand.softSage,
        const Color(0xFF2F7A55),
        Icons.verified_user_outlined,
      ),
      SentStatus.expired => (brand.softCoral, brand.coral, Icons.link),
      SentStatus.pending => (brand.softSky, brand.link, Icons.link),
    };
    final description = switch (sent.status) {
      SentStatus.expired => 'Link đã hết hạn sau 7 ngày vì chưa được mở.',
      SentStatus.opened => 'Thư đã được mở bởi người nhận.',
      SentStatus.pending => 'Link còn hiệu lực, chưa được mở.',
    };
    final time = switch (sent.status) {
      SentStatus.expired =>
        'Hết hạn lúc ${_formatTime(link.expiresAt.toLocal())}',
      SentStatus.opened when link.openedAt != null =>
        'Đã mở lúc ${_formatTime(link.openedAt!.toLocal())}',
      SentStatus.opened => 'Đã mở',
      SentStatus.pending =>
        'Hết hạn ngày ${_formatDate(link.expiresAt.toLocal())}',
    };
    final name = isPrimary ? 'Link chính' : 'Link dự phòng';
    final platform = link.platform;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.brand.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F24211F),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: circleBg, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: circleFg),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        platform != null && platform.isNotEmpty
                            ? '$name · ${_capitalize(platform)}'
                            : name,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _StatusPill(status: sent.status),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        time,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final SentStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final (label, fg, bg) = switch (status) {
      SentStatus.opened => ('Đã mở', scheme.onPrimary, scheme.primary),
      SentStatus.pending => (
        'Chưa mở',
        scheme.primary,
        scheme.primaryContainer,
      ),
      SentStatus.expired => (
        'Hết hạn',
        scheme.onSurfaceVariant,
        context.brand.borderSubtle,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Read-only rendering of the sent letter ("Xem trước thư"): the letter's
/// paper with its title and full body — no editor chrome.
class _LetterView extends StatelessWidget {
  const _LetterView({required this.letter});

  final Letter letter;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final paper = Color(letter.content.paperColor ?? 0xFFFFFDF6);
    return Scaffold(
      backgroundColor: const Color(0xFFFAF4EC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Xem trước thư',
          style: AppSerif.style(fontSize: 22, color: scheme.onSurface),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 420),
          padding: const EdgeInsets.all(AppSpacing.xxl),
          decoration: BoxDecoration(
            color: paper,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: context.brand.borderSubtle),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1424211F),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (letter.content.title.isNotEmpty) ...[
                Text(
                  letter.content.title,
                  style: AppSerif.style(fontSize: 24, color: scheme.onSurface),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              Text(
                letter.content.text.isNotEmpty
                    ? letter.content.text
                    : '(Thư không có nội dung)',
                style: context.textTheme.bodyLarge?.copyWith(height: 1.7),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _formatDate(letter.createdAt.toLocal()),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _platformLabel(SentLetter sent) {
  final p = sent.link.platform;
  return (p == null || p.isEmpty) ? 'link chia sẻ' : _capitalize(p);
}

String _capitalize(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

String _formatDate(DateTime d) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year}';
}

String _formatTime(DateTime d) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(d.hour)}:${two(d.minute)} · ${two(d.day)}/${two(d.month)}/${d.year}';
}

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/letter_link.dart';

/// SM-021 — the "Thư" tab: the sender's sent letters with each link's status.
/// This is the whole tab — there is no received-letters list (SM-017 BR-10).
/// Empty state per F04-S07d.
class SentLettersScreen extends StatelessWidget {
  const SentLettersScreen({
    this.letters = const [],
    this.onCompose,
    super.key,
  });

  final List<SentLetter> letters;

  /// Called by the "Tạo thư đầu tiên" CTA in the empty state (F04-S07d).
  final VoidCallback? onCompose;

  static const _ground = Color(0xFFFBF4EC);

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
                    'Thư đã gửi 💌',
                    style: context.textTheme.displayMedium?.copyWith(
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Theo dõi những bức thư bạn đã gửi đi ✨',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: letters.isEmpty
                  ? _SentEmpty(onCompose: onCompose)
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xxl,
                        AppSpacing.md,
                        AppSpacing.xxl,
                        AppSpacing.xxl,
                      ),
                      child: _ListCard(letters: letters),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The white list card (radius-20) with hairline-divided rows.
class _ListCard extends StatelessWidget {
  const _ListCard({required this.letters});

  final List<SentLetter> letters;

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
          for (final (i, letter) in letters.indexed) ...[
            if (i > 0) Divider(height: 1, color: context.brand.borderSubtle),
            _SentRow(letter: letter),
          ],
        ],
      ),
    );
  }
}

class _SentRow extends StatelessWidget {
  const _SentRow({required this.letter});

  final SentLetter letter;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final link = letter.link;
    final platform = (link.platform?.isNotEmpty ?? false)
        ? link.platform!
        : 'Link chia sẻ';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(Icons.mail_outline, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thư gửi qua $platform',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatDate(link.createdAt.toLocal()),
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _StatusChip(status: letter.status),
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }
}

/// Link status pill: Đã mở (primary) / Chưa mở (outline) / Hết hạn (muted).
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

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

/// F04-S07d — empty state: illustration, Baloo title, body-lg subtitle, and
/// the 290×54 coral CTA.
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
            package: 'feature_letters',
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

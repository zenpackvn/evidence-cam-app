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
    this.onRecreate,
    this.recreatingLetterId,
    super.key,
  });

  final List<SentLetter> letters;

  /// Called by the "Tạo thư đầu tiên" CTA in the empty state (F04-S07d).
  final VoidCallback? onCompose;

  /// Recreates a share link for an expired letter (SM-021 BR-04). Null hides
  /// the action.
  final ValueChanged<SentLetter>? onRecreate;

  /// The letterId whose link is currently being recreated (shows a spinner).
  final String? recreatingLetterId;

  static const _ground = Color(0xFFFBF4EC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ground,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // F04-S07d topnav (☰ · StampMail · 🔍) + "Hộp thư" heading with the
            // coral add-letter button.
            const _InboxTopNav(),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.sm,
                AppSpacing.xxl,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Hộp thư',
                      style: context.textTheme.displayMedium?.copyWith(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (onCompose != null) _AddButton(onTap: onCompose!),
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
                      child: _ListCard(
                        letters: letters,
                        onRecreate: onRecreate,
                        recreatingLetterId: recreatingLetterId,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The top nav (F04-S07d `topnav`): a menu affordance, the centred "StampMail"
/// wordmark, and a search icon (both inert here — the tab has no search yet).
class _InboxTopNav extends StatelessWidget {
  const _InboxTopNav();

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Icon(Icons.menu, size: 24, color: scheme.onSurface),
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'StampMail',
                    style: context.textTheme.headlineSmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
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
          Icon(Icons.search, size: 22, color: scheme.onSurface),
        ],
      ),
    );
  }
}

/// The coral round add-letter button (F04-S07d `addBtn`) → composes a letter.
class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Material(
      color: scheme.primary,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: const Color(0x3324211F),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(Icons.add, size: 24, color: scheme.onPrimary),
        ),
      ),
    );
  }
}

/// The white list card (radius-20) with hairline-divided rows.
class _ListCard extends StatelessWidget {
  const _ListCard({
    required this.letters,
    this.onRecreate,
    this.recreatingLetterId,
  });

  final List<SentLetter> letters;
  final ValueChanged<SentLetter>? onRecreate;
  final String? recreatingLetterId;

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
            _SentRow(
              letter: letter,
              onRecreate: onRecreate,
              recreating: recreatingLetterId == letter.link.letterId,
            ),
          ],
        ],
      ),
    );
  }
}

class _SentRow extends StatelessWidget {
  const _SentRow({
    required this.letter,
    this.onRecreate,
    this.recreating = false,
  });

  final SentLetter letter;
  final ValueChanged<SentLetter>? onRecreate;
  final bool recreating;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final link = letter.link;
    final platform = (link.platform?.isNotEmpty ?? false)
        ? link.platform!
        : 'Link chia sẻ';
    // SM-021 BR-04/BR-05: recreate only offered for an expired link, never an
    // opened one (already reached its recipient).
    final canRecreate =
        onRecreate != null && letter.status == SentStatus.expired;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.mail_outline,
                  color: scheme.onPrimaryContainer,
                ),
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
          if (canRecreate) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: recreating ? null : () => onRecreate!(letter),
                icon: recreating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh, size: 18),
                label: const Text('Tạo link mới'),
              ),
            ),
          ],
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

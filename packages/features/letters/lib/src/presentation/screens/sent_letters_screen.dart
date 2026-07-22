import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/letter_link.dart';
import '../bloc/sent_letters_cubit.dart';

/// SM-021 — the "Thư" tab: the sender's sent letters with each link's status.
/// This is the whole tab — there is no received-letters list (SM-017 BR-10).
/// Empty state per F04-S07d.
class SentLettersScreen extends StatelessWidget {
  const SentLettersScreen({
    this.letters = const [],
    this.onCompose,
    this.onRecreate,
    this.onView,
    this.recreatingLetterId,
    super.key,
  });

  final List<SentLetterView> letters;

  /// Called by the "Tạo thư đầu tiên" CTA in the empty state (F04-S07d).
  final VoidCallback? onCompose;

  /// Recreates a share link for an expired letter (SM-021 BR-04). Null hides
  /// the action.
  final ValueChanged<SentLetter>? onRecreate;

  /// Tapping a row opens the letter's content (from the local cache). Null
  /// makes the rows non-interactive.
  final ValueChanged<SentLetter>? onView;

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
                        onView: onView,
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
    this.onView,
    this.recreatingLetterId,
  });

  final List<SentLetterView> letters;
  final ValueChanged<SentLetter>? onRecreate;
  final ValueChanged<SentLetter>? onView;
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
          for (final (i, view) in letters.indexed) ...[
            if (i > 0) Divider(height: 1, color: context.brand.borderSubtle),
            _SentRow(
              view: view,
              onRecreate: onRecreate,
              onView: onView,
              recreating: recreatingLetterId == view.sent.link.letterId,
            ),
          ],
        ],
      ),
    );
  }
}

class _SentRow extends StatelessWidget {
  const _SentRow({
    required this.view,
    this.onRecreate,
    this.onView,
    this.recreating = false,
  });

  final SentLetterView view;
  final ValueChanged<SentLetter>? onRecreate;
  final ValueChanged<SentLetter>? onView;
  final bool recreating;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final letter = view.sent;
    final link = letter.link;
    // SM-021 BR-04/BR-05: recreate only offered for an expired link, never an
    // opened one (already reached its recipient).
    final canRecreate =
        onRecreate != null && letter.status == SentStatus.expired;
    // Same three-part shape as the Home "Thư gần đây" card: envelope + occasion
    // symbol · title + status/date · attached stamp.
    final row = Row(
      children: [
        _OccasionEnvelope(icon: view.icon),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                view.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _StatusChip(status: letter.status),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      _formatDate(link.createdAt.toLocal()),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _StampThumb(imageUrl: view.stampImageUrl),
        if (onView != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Icon(Icons.chevron_right, size: 18, color: scheme.outline),
        ],
      ],
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        children: [
          if (onView != null)
            InkWell(
              onTap: () => onView!(letter),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: row,
            )
          else
            row,
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

/// Left tile: an open envelope with the occasion symbol on a little note —
/// same picture as the Home "Thư gần đây" card (F01-S16).
class _OccasionEnvelope extends StatelessWidget {
  const _OccasionEnvelope({required this.icon});

  final String icon;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: context.brand.softPeach,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.brand.borderSubtle),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 6,
            child: Icon(
              Icons.drafts,
              size: 34,
              color: scheme.primary.withValues(alpha: 0.5),
            ),
          ),
          Positioned(
            top: 4,
            child: Container(
              width: 30,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: context.brand.borderSubtle),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Text(icon, style: const TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Right tile: the letter's attached stamp, framed like postage. A soft
/// placeholder shows when the letter has no cached stamp.
class _StampThumb extends StatelessWidget {
  const _StampThumb({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null) {
      return Container(
        width: 46,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.brand.softPeach,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: context.brand.borderSubtle),
        ),
        child: Icon(
          Icons.local_post_office_outlined,
          size: 18,
          color: context.colorScheme.outline,
        ),
      );
    }
    // Show the stamp exactly as the user made it — no extra frame or crop.
    return SizedBox(
      width: 52,
      height: 56,
      child: AppNetworkImage(imageUrl: url, fit: BoxFit.contain),
    );
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

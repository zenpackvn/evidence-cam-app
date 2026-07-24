import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/letter_link.dart';
import '../bloc/sent_letters_cubit.dart';

/// SM-021 — the "Thư" tab: the sender's sent letters, each row enriched with
/// the letter's title, occasion symbol and attached stamp. Sent-only — there
/// is no received-letters list (SM-017 BR-10). Empty state per F04-S07d.
///
/// Every affordance works: the search icon expands an in-place filter over the
/// row titles/platforms, the menu (☰) opens an action sheet (refresh + status
/// filter), and tapping a row opens the "xem thư đã gửi" detail. Link renewal
/// lives in the detail screen ("Gia hạn link"), not on the rows.
class SentLettersScreen extends StatefulWidget {
  const SentLettersScreen({
    this.letters = const [],
    this.onCompose,
    this.onView,
    this.onRefresh,
    super.key,
  });

  final List<SentLetterView> letters;

  /// Called by the "Tạo thư đầu tiên" CTA in the empty state (F04-S07d) and the
  /// coral add button next to the heading.
  final VoidCallback? onCompose;

  /// Tapping a row opens the letter's detail ("xem thư đã gửi"). Null makes the
  /// rows non-interactive.
  final ValueChanged<SentLetter>? onView;

  /// Reloads the list (pull-to-refresh + menu → "Làm mới"). Returns a future so
  /// the pull-to-refresh spinner stays until the reload finishes.
  final Future<void> Function()? onRefresh;

  static const _ground = Color(0xFFFAF4EC);

  @override
  State<SentLettersScreen> createState() => _SentLettersScreenState();
}

class _SentLettersScreenState extends State<SentLettersScreen> {
  final _searchController = TextEditingController();
  bool _searching = false;
  String _query = '';
  SentStatus? _statusFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
      if (!_searching) {
        _searchController.clear();
        _query = '';
      }
    });
  }

  /// The rows surviving the search query and the menu's status filter. The
  /// match folds Vietnamese diacritics so "hoi an" finds "Hội An".
  List<SentLetterView> get _visible {
    final q = stripDiacritics(_query.toLowerCase());
    return [
      for (final v in widget.letters)
        if (_statusFilter == null || v.sent.status == _statusFilter)
          if (q.isEmpty ||
              stripDiacritics(v.title.toLowerCase()).contains(q) ||
              stripDiacritics(
                (v.sent.link.platform ?? '').toLowerCase(),
              ).contains(q))
            v,
    ];
  }

  Future<void> _openMenu() async {
    final result = await showModalBottomSheet<Object>(
      context: context,
      backgroundColor: context.brand.surfaceElevated,
      builder: (_) => _MailboxMenuSheet(activeFilter: _statusFilter),
    );
    if (!mounted || result == null) return;
    if (result is _StatusChoice) {
      setState(() => _statusFilter = result.status);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final hasFilter = _query.isNotEmpty || _statusFilter != null;
    return Scaffold(
      backgroundColor: SentLettersScreen._ground,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InboxTopNav(
              searching: _searching,
              onMenu: _openMenu,
              onSearch: _toggleSearch,
            ),
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
                      style: AppSerif.style(
                        fontSize: 38,
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (widget.onCompose != null)
                    _AddButton(onTap: widget.onCompose!),
                ],
              ),
            ),
            if (_searching)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.md,
                  AppSpacing.xxl,
                  0,
                ),
                child: _SearchField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  onClear: _toggleSearch,
                ),
              ),
            if (_statusFilter != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.md,
                  AppSpacing.xxl,
                  0,
                ),
                child: Row(
                  children: [
                    InputChip(
                      label: Text('Lọc: ${_statusLabel(_statusFilter!)}'),
                      onDeleted: () => setState(() => _statusFilter = null),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: widget.onRefresh ?? () async {},
                child: widget.letters.isEmpty
                    ? _PullToRefreshFill(
                        child: _SentEmpty(onCompose: widget.onCompose),
                      )
                    : visible.isEmpty && hasFilter
                    ? const _PullToRefreshFill(child: _NoMatches())
                    : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xxl,
                          AppSpacing.md,
                          AppSpacing.xxl,
                          AppSpacing.xxl,
                        ),
                        child: _ListCard(
                          letters: visible,
                          onView: widget.onView,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lets a non-scrolling body (the empty / no-match states) fill the viewport
/// and still respond to pull-to-refresh, so the mailbox refreshes by pulling
/// down even when the list is empty — matching the Home screen.
class _PullToRefreshFill extends StatelessWidget {
  const _PullToRefreshFill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: child,
        ),
      ),
    );
  }
}

/// A status choice from the menu sheet; null [status] clears the filter.
class _StatusChoice {
  const _StatusChoice(this.status);

  final SentStatus? status;
}

String _statusLabel(SentStatus s) => switch (s) {
  SentStatus.opened => 'Đã mở',
  SentStatus.pending => 'Chưa mở',
  SentStatus.expired => 'Hết hạn',
};

/// The ☰ action sheet: a status filter for the list.
class _MailboxMenuSheet extends StatelessWidget {
  const _MailboxMenuSheet({this.activeFilter});

  final SentStatus? activeFilter;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    Widget statusTile(SentStatus? status, String label) {
      final selected = activeFilter == status;
      return ListTile(
        leading: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: selected ? scheme.primary : scheme.onSurfaceVariant,
        ),
        title: Text(label),
        onTap: () => Navigator.pop(context, _StatusChoice(status)),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.sm,
                AppSpacing.xxl,
                AppSpacing.xs,
              ),
              child: Text(
                'Hộp thư',
                style: AppSerif.style(fontSize: 22, color: scheme.onSurface),
              ),
            ),
            Divider(height: 1, color: context.brand.borderSubtle),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.md,
                AppSpacing.xxl,
                0,
              ),
              child: Text(
                'Lọc theo trạng thái',
                style: context.textTheme.labelLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            statusTile(null, 'Tất cả'),
            statusTile(SentStatus.pending, 'Chưa mở'),
            statusTile(SentStatus.opened, 'Đã mở'),
            statusTile(SentStatus.expired, 'Hết hạn'),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

/// The expanding search field (🔍): filters by letter title or platform.
class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: true,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Tìm theo tiêu đề hoặc nền tảng...',
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: onClear,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }
}

/// Empty result for an active search/filter (distinct from the true empty
/// state, which invites composing).
class _NoMatches extends StatelessWidget {
  const _NoMatches();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 40,
              color: context.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Không tìm thấy thư phù hợp.',
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The top nav (F04-S07d `topnav`): the menu (☰) opens the action sheet, the
/// centred "StampMail" wordmark, and the search toggle.
class _InboxTopNav extends StatelessWidget {
  const _InboxTopNav({
    required this.searching,
    required this.onMenu,
    required this.onSearch,
  });

  final bool searching;
  final VoidCallback onMenu;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onMenu,
            tooltip: 'Menu',
            icon: Icon(Icons.menu, size: 24, color: scheme.onSurface),
          ),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'StampMail',
                      style: AppSerif.style(
                        fontSize: 26,
                        color: scheme.primary,
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
          ),
          IconButton(
            onPressed: onSearch,
            tooltip: 'Tìm kiếm',
            icon: Icon(
              searching ? Icons.search_off : Icons.search,
              size: 22,
              color: searching ? scheme.primary : scheme.onSurface,
            ),
          ),
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
  const _ListCard({required this.letters, this.onView});

  final List<SentLetterView> letters;
  final ValueChanged<SentLetter>? onView;

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
            _SentRow(view: view, onView: onView),
          ],
        ],
      ),
    );
  }
}

class _SentRow extends StatelessWidget {
  const _SentRow({required this.view, this.onView});

  final SentLetterView view;

  /// Opens this letter's detail view ("xem thư đã gửi").
  final ValueChanged<SentLetter>? onView;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final letter = view.sent;
    final link = letter.link;
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
      child: onView != null
          ? InkWell(
              onTap: () => onView!(letter),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: row,
            )
          : row,
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
          // The envelope, a bit bigger, near the bottom.
          Positioned(
            bottom: 5,
            child: Icon(
              Icons.drafts,
              size: 40,
              color: scheme.primary.withValues(alpha: 0.5),
            ),
          ),
          // The note tucked into the envelope — centred, smaller, and low enough
          // to look like it's sitting inside rather than floating above.
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 22,
                height: 16,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: context.brand.borderSubtle),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(icon, style: const TextStyle(fontSize: 11)),
              ),
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

/// F04-S07d — empty state: illustration, serif title, body-lg subtitle, and
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
            style: AppSerif.style(
              fontSize: 30,
              color: context.colorScheme.onSurface,
            ),
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

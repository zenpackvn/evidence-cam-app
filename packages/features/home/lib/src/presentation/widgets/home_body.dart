import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_contracts/shared_contracts.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../domain/home_data.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_state.dart';

/// The Home dashboard body, matched to `pencil-new.pen` F01-S15 (empty) and
/// F01-S16 (loaded) frame by frame.
class HomeBody extends StatelessWidget {
  const HomeBody({
    this.onCreateStamp,
    this.onOpenAlbum,
    this.onOpenLetters,
    this.onOpenStamp,
    this.onOpenLetter,
    super.key,
  });

  final VoidCallback? onCreateStamp;
  final VoidCallback? onOpenAlbum;

  /// "Thư gần đây" see-all → the sent-letters tab (SM-021).
  final VoidCallback? onOpenLetters;

  /// Tapping a single "Tem gần đây" card → open that stamp.
  final ValueChanged<StampRef>? onOpenStamp;

  /// Tapping a single "Thư gần đây" card → open that sent letter.
  final ValueChanged<HomeLetterItem>? onOpenLetter;

  /// .pen Home ground (slightly warmer than `surface-primary`).
  static const ground = Color(0xFFFCF6EF);

  static const package = 'feature_home';

  /// SM-004 BR-07 / AC-05 copy.
  static const offlineLabel = 'Đang xem ngoại tuyến';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ground,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final name = _displayName(context);
          final empty = state.data.isEmpty && !state.isLoading;
          final body = SafeArea(
            bottom: false,
            child: empty
                ? _EmptyHome(name: name, onCreateStamp: onCreateStamp)
                : _LoadedHome(
                    name: name,
                    data: state.data,
                    onCreateStamp: onCreateStamp,
                    onOpenAlbum: onOpenAlbum,
                    onOpenLetters: onOpenLetters,
                    onOpenStamp: onOpenStamp,
                    onOpenLetter: onOpenLetter,
                  ),
          );
          final scrollArea = RefreshIndicator(
            onRefresh: () async => context.read<HomeBloc>().add(
              const HomeLoadRequested(isRefresh: true),
            ),
            // BR-07 / AC-06: offline the pull-to-refresh gesture is disabled
            // outright, so the loaded content can't be swapped for an error.
            notificationPredicate: state.canRefresh
                ? defaultScrollNotificationPredicate
                : (_) => false,
            child: empty
                // Corner decor exists only on the empty frame (F01-S15).
                ? Stack(
                    children: [
                      Positioned(
                        top: 8,
                        left: 4,
                        child: Image.asset(
                          'assets/illustrations/corner-left-flowers.png',
                          package: package,
                          width: 70,
                          excludeFromSemantics: true,
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 0,
                        child: Image.asset(
                          'assets/illustrations/corner-right-stamp.png',
                          package: package,
                          width: 92,
                          excludeFromSemantics: true,
                        ),
                      ),
                      body,
                    ],
                  )
                : body,
          );

          // BR-07: the notice is pinned above the scroll area — in the layout
          // flow, so it never covers the content it annotates (AC-05).
          return Column(
            children: [
              if (state.isOffline)
                const SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.xxl,
                      AppSpacing.sm,
                      AppSpacing.xxl,
                      0,
                    ),
                    child: OfflineBanner(
                      isOffline: true,
                      label: offlineLabel,
                    ),
                  ),
                ),
              Expanded(child: scrollArea),
            ],
          );
        },
      ),
    );
  }

  String _displayName(BuildContext context) {
    final user = SessionScope.of(context).currentUser;
    final username = user?.username ?? '';
    return username.isEmpty ? 'bạn' : username;
  }
}

// ── Loaded (F01-S16) ────────────────────────────────────────────────────────

class _LoadedHome extends StatelessWidget {
  const _LoadedHome({
    required this.name,
    required this.data,
    this.onCreateStamp,
    this.onOpenAlbum,
    this.onOpenLetters,
    this.onOpenStamp,
    this.onOpenLetter,
  });

  final String name;
  final HomeData data;
  final VoidCallback? onCreateStamp;
  final VoidCallback? onOpenAlbum;
  final VoidCallback? onOpenLetters;
  final ValueChanged<StampRef>? onOpenStamp;
  final ValueChanged<HomeLetterItem>? onOpenLetter;

  @override
  Widget build(BuildContext context) {
    return ListView(
      // Bottom inset now just breathing room — the create button moved into
      // the bottom bar, so the old FAB-clearance gap (120) is gone.
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        18,
        AppSpacing.xxl,
        AppSpacing.xxl,
      ),
      children: [
        _Header(name: name),
        const SizedBox(height: 14),
        // SM-030: low-quota nudge — hidden unless the Free user is under the
        // 20% threshold; QuotaNudgeBanner handles the visibility itself.
        QuotaNudgeBanner(
          quota: data.quota,
          labels: QuotaNudgeLabels(
            stampRemaining: (n) => 'Còn $n tem trong tháng này',
            letterRemaining: (n) => 'Còn $n thư trong tháng này',
            offlineMessage: 'Không có kết nối. Vui lòng thử lại khi có mạng.',
          ),
        ),
        _CreateCard(onCreate: onCreateStamp),
        const SizedBox(height: AppSpacing.lg),
        _SectionHeader(title: 'Tem gần đây', onSeeAll: onOpenAlbum),
        const SizedBox(height: 10),
        _StampRow(
          stamps: data.recentStamps,
          onCreate: onCreateStamp,
          onOpenStamp: onOpenStamp,
        ),
        const SizedBox(height: 14),
        _SectionHeader(title: 'Thư gần đây', onSeeAll: onOpenLetters),
        const SizedBox(height: 10),
        if (data.recentLetters.isEmpty)
          const _EmptyStateRow(
            asset: 'he-mailbox.png',
            title: 'Chưa có thư nào',
            subtitle: 'Hãy tạo thư đầu tiên để gửi gắm yêu thương.',
          )
        else
          for (final (i, letter) in data.recentLetters.indexed) ...[
            if (i > 0) const SizedBox(height: 10),
            _LetterCard(
              letter: letter,
              onTap: onOpenLetter == null ? null : () => onOpenLetter!(letter),
            ),
          ],
      ],
    );
  }
}

/// Header (F01-S16): 48px avatar, Baloo-26 greeting + body-sm subline, then
/// the bell glyph. No unread badge — received letters aren't stored, so there
/// is no unread count (SM-004, SM-017 BR-10).
class _Header extends StatelessWidget {
  const _Header({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    // The name + avatar mirror the Profile edits (via ProfileHeaderStore), so
    // changing them there updates this greeting immediately.
    return ListenableBuilder(
      listenable: ProfileHeaderStore.instance,
      builder: (context, _) {
        final header = ProfileHeaderStore.instance.value;
        final shown = (header?.displayName?.trim().isNotEmpty ?? false)
            ? header!.displayName!.trim()
            : name;
        final avatarUrl = header?.avatarUrl;
        return Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: scheme.primaryContainer,
              foregroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                  ? NetworkImage(avatarUrl)
                  : null,
              child: Text(
                shown.characters.first.toUpperCase(),
                style: context.textTheme.titleLarge?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chào $shown 👋',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.displayMedium?.copyWith(
                      fontSize: 26,
                    ),
                  ),
                ],
              ),
            ),
            // .pen F01-S16 header is avatar + greeting only — no bell glyph.
          ],
        );
      },
    );
  }
}

/// Create card (F01-S16): soft-peach r24 card with Baloo-24 title, body-sm
/// copy, the h46/r12 coral CTA, and the 133×100 illustration.
class _CreateCard extends StatelessWidget {
  const _CreateCard({this.onCreate});

  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
      decoration: BoxDecoration(
        color: context.brand.softPeach,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: context.brand.borderSubtle),
        // .pen F01-S16 createCard: outer shadow blur 6, offset (0,2), #24211F @ 6%.
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tạo tem mới ✨',
                  style: context.textTheme.displayMedium?.copyWith(
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Thiết kế tem cá nhân hóa\nvà gửi thật nhiều yêu thương.',
                  style: context.textTheme.bodySmall,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 46,
                  child: FilledButton(
                    onPressed: onCreate,
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.primary,
                      // .pen btnCreate: coral pill, outer shadow blur 12,
                      // offset (0,4), #24211F @ 8%.
                      elevation: 4,
                      shadowColor: const Color(0x2624211F),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      textStyle: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Tạo tem / Viết thư ✨'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Image.asset(
              'assets/illustrations/hl-create-illust.png',
              package: HomeBody.package,
              width: 133,
              height: 100,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
          ),
        ],
      ),
    );
  }
}

/// .pen `Content/SectionHeader`: Baloo-20 title + coral "Xem tất cả" link.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Row(
      children: [
        Text(
          title,
          style: context.textTheme.displayMedium?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
        ),
        const Spacer(),
        if (onSeeAll != null)
          InkWell(
            onTap: onSeeAll,
            child: Row(
              children: [
                Text(
                  'Xem tất cả',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 2),
                FaIcon(
                  FontAwesomeIcons.chevronRight,
                  size: 16,
                  color: scheme.primary,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StampRow extends StatelessWidget {
  const _StampRow({required this.stamps, this.onCreate, this.onOpenStamp});

  final List<StampRef> stamps;
  final VoidCallback? onCreate;
  final ValueChanged<StampRef>? onOpenStamp;

  @override
  Widget build(BuildContext context) {
    if (stamps.isEmpty) {
      return _EmptyStateRow(
        asset: 'he-stamps.png',
        title: 'Chưa có con tem nào',
        subtitle: 'Tạo con tem đầu tiên để bắt đầu bộ sưu tập. ✨',
        onTap: onCreate,
      );
    }
    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: stamps.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) => _StampCard(
          stamp: stamps[index],
          onTap: onOpenStamp == null ? null : () => onOpenStamp!(stamps[index]),
        ),
      ),
    );
  }
}

/// .pen `Content/StampCard` (F01-S16 variant): 111px card, 95×97 art, name
/// 13 w600, date 12 + heart 15.
class _StampCard extends StatelessWidget {
  const _StampCard({required this.stamp, this.onTap});

  final StampRef stamp;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        width: 111,
        // 7px + the 1px border = the .pen card's 8px inset (stroke there is
        // inner-aligned and doesn't consume layout).
        padding: const EdgeInsets.fromLTRB(7, 7, 7, 9),
        decoration: BoxDecoration(
          color: context.brand.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: context.brand.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppNetworkImage(
              imageUrl: stamp.displayUrl,
              width: double.infinity,
              height: 97,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stamp.name ?? 'Tem của bạn',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          _formatDate(stamp.createdAt),
                          maxLines: 1,
                          // .pen caption: 12/16 regular, no tracking (the M3
                          // labelSmall letterSpacing would overflow the card).
                          style: context.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      FaIcon(
                        FontAwesomeIcons.heart,
                        size: 15,
                        color: scheme.outline,
                      ),
                    ],
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

/// .pen `Content/LetterCard`: 58×48 envelope art, title 17 w600 + meta 13,
/// 38×42 stamp mini, tertiary chevron.
class _LetterCard extends StatelessWidget {
  const _LetterCard({required this.letter, this.onTap});

  final HomeLetterItem letter;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: context.brand.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: context.brand.borderSubtle),
        ),
        // Three parts (F01-S16): the envelope with its occasion symbol on the
        // left, the letter's title in the middle, and its stamp on the right.
        child: Row(
          children: [
            _OccasionEnvelope(icon: letter.icon),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    letter.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    letter.meta,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            _StampThumb(imageUrl: letter.stampImageUrl),
          ],
        ),
      ),
    );
  }
}

/// Left tile: an OPEN letter with the occasion symbol inside it — a little
/// white note carrying the emoji (🎂 for a birthday…) rising out of an open
/// envelope, matching the demo's per-letter picture (F01-S16).
class _OccasionEnvelope extends StatelessWidget {
  const _OccasionEnvelope({required this.icon});

  final String icon;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: context.brand.softPeach,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.brand.borderSubtle),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The open envelope — a bit bigger, near the bottom.
          Positioned(
            bottom: 5,
            child: FaIcon(
              FontAwesomeIcons.solidEnvelopeOpen,
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

/// Right tile: the letter's attached stamp, framed like a postage stamp. Shows
/// a soft placeholder when the letter has no cached stamp.
class _StampThumb extends StatelessWidget {
  const _StampThumb({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null) {
      return Container(
        width: 46,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.brand.softPeach,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: context.brand.borderSubtle),
        ),
        child: FaIcon(
          FontAwesomeIcons.stamp,
          size: 18,
          color: context.colorScheme.outline,
        ),
      );
    }
    // Show the stamp exactly as the user made it — no extra frame or crop
    // (BoxFit.contain), so its own design/border stays intact.
    return SizedBox(
      width: 52,
      height: 56,
      child: AppNetworkImage(imageUrl: url, fit: BoxFit.contain),
    );
  }
}

// ── Empty (F01-S15) ─────────────────────────────────────────────────────────

class _EmptyHome extends StatelessWidget {
  const _EmptyHome({required this.name, this.onCreateStamp});

  final String name;
  final VoidCallback? onCreateStamp;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        16,
        AppSpacing.xxl,
        120,
      ),
      children: [
        // .pen F01-S15 logoRow: the shared brand lockup (cAuthLogo).
        const StampMailBrandmark(),
        const SizedBox(height: 10),
        Text(
          'Chào $name 👋',
          style: context.textTheme.displayMedium?.copyWith(fontSize: 30),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Chào mừng bạn đến với StampMail!\n'
          'Hãy bắt đầu tạo những lá thư và con tem\n'
          'đầy cảm xúc nhé. ❤️',
          style: context.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        _EmptyHeroCard(onCreateStamp: onCreateStamp),
        const SizedBox(height: 18),
        const _SectionHeader(title: 'Thư gần đây'),
        const SizedBox(height: 10),
        const _EmptyStateRow(
          asset: 'he-mailbox.png',
          title: 'Chưa có thư nào',
          subtitle: 'Hãy tạo thư đầu tiên để gửi gắm yêu thương.',
        ),
        const SizedBox(height: AppSpacing.lg),
        const _SectionHeader(title: 'Bộ sưu tập của bạn'),
        const SizedBox(height: 10),
        _EmptyStateRow(
          asset: 'he-stamps.png',
          title: 'Chưa có con tem nào',
          subtitle: 'Tạo con tem đầu tiên để bắt đầu bộ sưu tập. ✨',
          onTap: onCreateStamp,
        ),
      ],
    );
  }
}

/// Hero invite card (F01-S15): Baloo-24 headline, body-sm copy, coral +
/// outline CTAs, and the 137×134 illustration.
class _EmptyHeroCard extends StatelessWidget {
  const _EmptyHeroCard({this.onCreateStamp});

  final VoidCallback? onCreateStamp;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
      decoration: BoxDecoration(
        color: context.brand.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: context.brand.borderSubtle),
        // .pen F01-S15 heroCard: outer shadow blur 12, offset (0,4), #24211F @ 8%.
        boxShadow: const [
          BoxShadow(
            color: Color(0x1424211F),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bạn chưa có\nbức thư hay\ncon tem nào.',
                  style: context.textTheme.displayMedium?.copyWith(
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tạo tem và viết thư đầu tiên\nđể lưu giữ những cảm xúc\n'
                  'đáng nhớ. ✨',
                  style: context.textTheme.bodySmall,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 44,
                  child: FilledButton.icon(
                    onPressed: onCreateStamp,
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.primary,
                      // .pen btnCreate: coral pill with an outer shadow
                      // (blur 12, offset (0,4), #24211F @ 8%).
                      elevation: 4,
                      shadowColor: const Color(0x2624211F),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      textStyle: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    icon: const FaIcon(FontAwesomeIcons.plus, size: 18),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Tạo tem đầu tiên'),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: onCreateStamp,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: scheme.primary,
                      backgroundColor: context.brand.surfaceElevated,
                      side: BorderSide(color: scheme.primary, width: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      textStyle: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    icon: const FaIcon(FontAwesomeIcons.solidGem, size: 18),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Khám phá tem mẫu'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Image.asset(
              'assets/illustrations/he-empty-illust.png',
              package: HomeBody.package,
              width: 137,
              height: 134,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
          ),
        ],
      ),
    );
  }
}

/// .pen `Feedback/EmptyState/Row`: white r20 card with a 58px illustration,
/// body-lg w600 title and body-sm subtitle.
class _EmptyStateRow extends StatelessWidget {
  const _EmptyStateRow({
    required this.asset,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String asset;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        decoration: BoxDecoration(
          color: context.brand.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: context.brand.borderSubtle),
          // .pen cEmptyRow: outer shadow blur 6, offset (0,2), #24211F @ 6%.
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F24211F),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/illustrations/$asset',
              package: HomeBody.package,
              width: 58,
              excludeFromSemantics: true,
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle, style: context.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime d) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year}';
}

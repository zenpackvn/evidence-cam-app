import 'dart:typed_data';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../domain/entities/stamp.dart';
import '../bloc/album_cubit.dart';
import '../bloc/album_state.dart';
import '../widgets/album_search_bar.dart';
import '../widgets/album_stats_banner.dart';
import '../widgets/stamp_tile.dart';
import 'share_stamp_screen.dart';
import 'stamp_detail_screen.dart';

/// SM-022 — "Bộ sưu tập của bạn" (F02-S10): the flat list of the user's stamps
/// (grid or list, BR-04) with a search bar and a total-count banner. Tapping a
/// stamp opens its detail (rename/delete wired to the cubit here so they run
/// inside the Album's BlocProvider); the empty state (F02-S19) invites creating
/// one.
class AlbumScreen extends StatelessWidget {
  const AlbumScreen({
    this.onCreate,
    this.onAttachStamp,
    this.onBrowseSamples,
    this.onShareImage,
    this.onSaveImageToGallery,
    super.key,
  });

  final VoidCallback? onCreate;

  /// Navigates to the letter composer with the given stamp preselected
  /// (SM-022 BR-07).
  final ValueChanged<Stamp>? onAttachStamp;

  /// Opens the sample-stamp catalog (SM-035), a separate browse area.
  final VoidCallback? onBrowseSamples;

  /// Shares a captured post PNG via the native share sheet (SM-025 BR-07). The
  /// host owns share_plus / temp-file writing so this feature stays
  /// platform-agnostic.
  final Future<void> Function(Uint8List png)? onShareImage;

  /// Saves a captured post PNG to the device gallery (SM-025 BR-05); returns
  /// whether it succeeded. The host owns the gallery plugin.
  final Future<bool> Function(Uint8List png)? onSaveImageToGallery;

  static const _ground = Color(0xFFFCF6EF);

  /// SM-022 BR-10 / AC-09 copy.
  static const offlineLabel = 'Đang xem ngoại tuyến';

  /// SM-022 BR-11 / AC-10 copy, shown when a write is attempted offline.
  static const offlineActionMessage =
      'Không có kết nối. Vui lòng thử lại khi có mạng.';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<AlbumCubit>()..load(),
      child: Scaffold(
        backgroundColor: _ground,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<AlbumCubit, AlbumState>(
            builder: (context, state) {
              // BR-10: the notice sits above the list rather than over it, and
              // shows in every branch (loading / error / loaded).
              return Column(
                children: [
                  if (state.isOffline)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.xxl,
                        AppSpacing.md,
                        AppSpacing.xxl,
                        0,
                      ),
                      child: OfflineBanner(
                        isOffline: true,
                        label: offlineLabel,
                      ),
                    ),
                  Expanded(child: _content(context, state)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, AlbumState state) {
    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error) {
      return _AlbumError(onRetry: context.read<AlbumCubit>().load);
    }
    return _AlbumBody(
      state: state,
      onOpenStamp: (stamp) => _openDetail(context, stamp),
      onCreate: onCreate,
      onBrowseSamples: onBrowseSamples,
    );
  }

  void _openDetail(BuildContext context, Stamp stamp) {
    final cubit = context.read<AlbumCubit>();
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        // BR-11 / AC-10: rebuild the detail on connectivity changes so its
        // rename/delete affordances enable again the moment the link returns.
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: BlocBuilder<AlbumCubit, AlbumState>(
            builder: (context, state) => StampDetailScreen(
              // AC-06: read the stamp back out of the state so a rename shows
              // on the detail immediately, not just in the list behind it. It
              // is gone from the list the moment a delete lands, hence the
              // fallback to the stamp this route was opened with.
              stamp: state.stamps.firstWhere(
                (s) => s.id == stamp.id,
                orElse: () => stamp,
              ),
              canMutate: state.canMutate,
              onBack: () => Navigator.of(context).maybePop(),
              onMutateBlocked: () => messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text(offlineActionMessage)),
                ),
              onRename: (name) => cubit.rename(stamp.id, name),
              onDelete: () {
                cubit.delete(stamp.id);
                Navigator.of(context).maybePop();
              },
              onAttach: onAttachStamp == null
                  ? null
                  : () => onAttachStamp!(stamp),
              onShare: onShareImage == null
                  ? null
                  : () => Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) => ShareStampScreen(
                          stampImageUrl: stamp.imageUrl,
                          onShareImage: onShareImage!,
                          onSaveToGallery: onSaveImageToGallery,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AlbumBody extends StatefulWidget {
  const _AlbumBody({
    required this.state,
    required this.onOpenStamp,
    this.onCreate,
    this.onBrowseSamples,
  });

  final AlbumState state;
  final ValueChanged<Stamp> onOpenStamp;
  final VoidCallback? onCreate;
  final VoidCallback? onBrowseSamples;

  @override
  State<_AlbumBody> createState() => _AlbumBodyState();
}

class _AlbumBodyState extends State<_AlbumBody> {
  final _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _openMenu() async {
    final cubit = context.read<AlbumCubit>();
    final result = await showModalBottomSheet<_AlbumMenuAction>(
      context: context,
      backgroundColor: context.brand.surfaceElevated,
      builder: (_) => _AlbumMenuSheet(showSamples: widget.onBrowseSamples != null),
    );
    if (!mounted || result == null) return;
    switch (result) {
      case _AlbumMenuAction.refresh:
        await cubit.load();
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Đã làm mới bộ sưu tập.')),
          );
      case _AlbumMenuAction.samples:
        widget.onBrowseSamples?.call();
    }
  }

  Future<void> _openSort() async {
    final cubit = context.read<AlbumCubit>();
    final sort = await showModalBottomSheet<AlbumSort>(
      context: context,
      backgroundColor: context.brand.surfaceElevated,
      builder: (_) => _SortSheet(active: widget.state.sort),
    );
    if (sort != null) cubit.setSort(sort);
  }

  void _focusSearch() {
    if (widget.state.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Chưa có tem để tìm kiếm.')),
        );
      return;
    }
    _searchFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    // F02-S19: an empty album is a clean invite — the StampMail top nav +
    // illustration + CTA, without the search bar or stats header.
    if (state.isEmpty) {
      return Column(
        children: [
          _AlbumTopNav(onMenu: _openMenu, onSearch: _focusSearch),
          Expanded(child: _AlbumEmpty(onCreate: widget.onCreate)),
        ],
      );
    }
    final visible = state.visibleStamps;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _AlbumTopNav(onMenu: _openMenu, onSearch: _focusSearch),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            0,
            AppSpacing.xxl,
            AppSpacing.md,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page h1 in the flow-5 serif, mirroring the mailbox tab —
                // collection screens lead with a large title above search.
                Text(
                  'Sưu tầm',
                  style: AppSerif.style(
                    fontSize: 38,
                    color: context.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Tất cả những con tem xinh xắn bạn đã tạo.',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (widget.onBrowseSamples != null)
                      TextButton.icon(
                        onPressed: widget.onBrowseSamples,
                        icon: const Icon(
                          Icons.auto_awesome_outlined,
                          size: 18,
                        ),
                        label: const Text('Tem mẫu'),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                AlbumSearchBar(
                  focusNode: _searchFocus,
                  onChanged: context.read<AlbumCubit>().setQuery,
                  onFilter: _openSort,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: AlbumStatsBanner(count: state.stamps.length),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _ViewModeToggle(
                      mode: state.viewMode,
                      onChanged: context.read<AlbumCubit>().setViewMode,
                    ),
                  ],
                ),
                if (state.sort != AlbumSort.newest)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: Row(
                      children: [
                        InputChip(
                          label: Text('Sắp xếp: ${_sortLabel(state.sort)}'),
                          onDeleted: () => context
                              .read<AlbumCubit>()
                              .setSort(AlbumSort.newest),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (visible.isEmpty && state.query.isNotEmpty)
          const SliverToBoxAdapter(child: _NoStampMatches())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              0,
              AppSpacing.xxl,
              AppSpacing.xxl,
            ),
            sliver: switch (state.viewMode) {
              AlbumViewMode.grid => SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.md,
                  // 3/4 image plus one caption line under it (StampTile).
                  childAspectRatio: 0.62,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => StampTile(
                    stamp: visible[i],
                    onTap: () => widget.onOpenStamp(visible[i]),
                  ),
                  childCount: visible.length,
                ),
              ),
              AlbumViewMode.list => SliverList.separated(
                itemCount: visible.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, i) => _StampListItem(
                  stamp: visible[i],
                  onTap: () => widget.onOpenStamp(visible[i]),
                ),
              ),
            },
          ),
      ],
    );
  }
}

enum _AlbumMenuAction { refresh, samples }

String _sortLabel(AlbumSort s) => switch (s) {
  AlbumSort.newest => 'Mới nhất',
  AlbumSort.oldest => 'Cũ nhất',
  AlbumSort.name => 'Theo tên A–Z',
};

/// The ☰ action sheet: refresh and the sample-stamp catalog shortcut.
class _AlbumMenuSheet extends StatelessWidget {
  const _AlbumMenuSheet({required this.showSamples});

  final bool showSamples;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
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
                'Sưu tầm',
                style: AppSerif.style(fontSize: 22, color: scheme.onSurface),
              ),
            ),
            ListTile(
              leading: Icon(Icons.refresh, color: scheme.onSurface),
              title: const Text('Làm mới bộ sưu tập'),
              onTap: () => Navigator.pop(context, _AlbumMenuAction.refresh),
            ),
            if (showSamples)
              ListTile(
                leading: Icon(
                  Icons.auto_awesome_outlined,
                  color: scheme.onSurface,
                ),
                title: const Text('Bộ tem mẫu'),
                onTap: () => Navigator.pop(context, _AlbumMenuAction.samples),
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

/// The sort sheet behind the search row's filter button.
class _SortSheet extends StatelessWidget {
  const _SortSheet({required this.active});

  final AlbumSort active;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    Widget tile(AlbumSort sort) {
      final selected = active == sort;
      return ListTile(
        leading: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: selected ? scheme.primary : scheme.onSurfaceVariant,
        ),
        title: Text(_sortLabel(sort)),
        onTap: () => Navigator.pop(context, sort),
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
                'Sắp xếp',
                style: AppSerif.style(fontSize: 22, color: scheme.onSurface),
              ),
            ),
            tile(AlbumSort.newest),
            tile(AlbumSort.oldest),
            tile(AlbumSort.name),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

/// Empty result for an active search (distinct from the true empty state).
class _NoStampMatches extends StatelessWidget {
  const _NoStampMatches();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 40,
            color: context.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Không tìm thấy tem phù hợp.',
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// SM-022 BR-04: grid / list switch. Two icon buttons; the active one is
/// highlighted.
class _ViewModeToggle extends StatelessWidget {
  const _ViewModeToggle({required this.mode, required this.onChanged});

  final AlbumViewMode mode;
  final ValueChanged<AlbumViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    Widget button(AlbumViewMode m, IconData icon, String tip) {
      final active = m == mode;
      return IconButton(
        tooltip: tip,
        onPressed: active ? null : () => onChanged(m),
        icon: Icon(icon),
        color: active ? scheme.primary : scheme.onSurfaceVariant,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        button(AlbumViewMode.grid, Icons.grid_view_rounded, 'Xem lưới'),
        button(AlbumViewMode.list, Icons.view_list_rounded, 'Xem danh sách'),
      ],
    );
  }
}

/// A single stamp row in list mode: thumbnail + name (or the creation date when
/// unnamed — BR-08).
class _StampListItem extends StatelessWidget {
  const _StampListItem({required this.stamp, required this.onTap});

  final Stamp stamp;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final title = stamp.name.isNotEmpty
        ? stamp.name
        : _formatDate(stamp.createdAt);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: SizedBox(
              width: 56,
              height: 72,
              child: AppNetworkImage(
                imageUrl: stamp.thumbUrl ?? stamp.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Đã lưu ${_formatDate(stamp.createdAt)}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';
}

/// The Album top nav (F02-S19 `topnav`): the menu (☰) opens the action sheet
/// (refresh, sample catalog), the centred "StampMail" wordmark, and the
/// search icon focuses the search bar (or explains when the album is empty).
class _AlbumTopNav extends StatelessWidget {
  const _AlbumTopNav({required this.onMenu, required this.onSearch});

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
              // scaleDown keeps the wordmark from overflowing narrow widths.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'StampMail',
                    // F02-S19 wordmark: Playfair Display 26.
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
          IconButton(
            onPressed: onSearch,
            tooltip: 'Tìm kiếm',
            icon: Icon(Icons.search, size: 22, color: scheme.onSurface),
          ),
        ],
      ),
    );
  }
}

class _AlbumEmpty extends StatelessWidget {
  const _AlbumEmpty({this.onCreate});

  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    // Scrollable so small viewports never overflow the fixed-height column.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xxl),
          // F02-S19 `illust` (315×263) — envelope + stamps illustration.
          Image.asset(
            'assets/illustrations/album-empty.png',
            package: 'feature_album',
            width: 315,
            height: 263,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Album của bạn đang trống',
            textAlign: TextAlign.center,
            // F02-S19 title: Playfair Display 30, lh 1.21.
            style: AppSerif.style(fontSize: 30, color: scheme.onSurface),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 320,
            child: Text(
              'Tạo tem đầu tiên của bạn để bắt đầu sưu tầm nhé!',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          if (onCreate != null) ...[
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: 290,
              height: 54,
              child: FilledButton(
                onPressed: onCreate,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: const Text('Tạo tem ngay'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AlbumError extends StatelessWidget {
  const _AlbumError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Không tải được bộ sưu tập.'),
          const SizedBox(height: AppSpacing.md),
          TextButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}

import 'dart:typed_data';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../domain/entities/sample_stamp.dart';
import '../../domain/entities/stamp.dart';
import '../bloc/album_cubit.dart';
import '../bloc/album_state.dart';
import '../bloc/sample_stamps_cubit.dart';
import '../bloc/sample_stamps_state.dart';
import '../widgets/album_search_bar.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => GetIt.instance<AlbumCubit>()..load()),
        BlocProvider(
          create: (_) => GetIt.instance<SampleStampsCubit>()..load(),
        ),
      ],
      child: Scaffold(
        backgroundColor: _ground,
        // Tapping anywhere outside the search field dismisses the keyboard.
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
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
    final result = await showModalBottomSheet<_AlbumMenuAction>(
      context: context,
      backgroundColor: context.brand.surfaceElevated,
      builder: (_) =>
          _AlbumMenuSheet(showSamples: widget.onBrowseSamples != null),
    );
    if (!mounted || result == null) return;
    switch (result) {
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

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final visible = state.visibleStamps;
    return RefreshIndicator(
      onRefresh: () async {
        final album = context.read<AlbumCubit>();
        final samples = context.read<SampleStampsCubit>();
        await album.load();
        await samples.load();
      },
      // Samples come from their own cubit; the whole scroll rebuilds with their
      // state so the "Bộ tem mẫu" grid can be a sliver in the same list.
      child: BlocBuilder<SampleStampsCubit, SampleStampsState>(
        builder: (context, sampleState) => CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _AlbumTopNav(onMenu: _openMenu)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.sm,
                AppSpacing.xxl,
                AppSpacing.md,
              ),
              sliver: SliverToBoxAdapter(
                child: AlbumSearchBar(
                  focusNode: _searchFocus,
                  onChanged: context.read<AlbumCubit>().setQuery,
                  onFilter: _openSort,
                ),
              ),
            ),
            // "Tem của bạn" — a horizontal strip of the user's own stamps.
            const SliverToBoxAdapter(
              child: _SectionHeader(title: 'Tem của bạn'),
            ),
            SliverToBoxAdapter(
              child: _MyStampsRow(
                stamps: visible,
                searching: state.query.isNotEmpty,
                onOpenStamp: widget.onOpenStamp,
                onCreate: widget.onCreate,
              ),
            ),
            // "Bộ tem mẫu" — the sample catalog, scrolling on down the page.
            const SliverToBoxAdapter(
              child: _SectionHeader(title: 'Bộ tem mẫu'),
            ),
            _sampleSliver(context, sampleState),
          ],
        ),
      ),
    );
  }

  Widget _sampleSliver(BuildContext context, SampleStampsState state) {
    if (state.loading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    final samples = state.visible;
    if (samples.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            0,
            AppSpacing.xxl,
            AppSpacing.xxl,
          ),
          child: Text(
            'Bộ tem mẫu sắp ra mắt.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        0,
        AppSpacing.xxl,
        AppSpacing.xxl,
      ),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) => _SampleCard(
            sample: samples[i],
            saved: state.savedIds.contains(samples[i].id),
          ),
          childCount: samples.length,
        ),
      ),
    );
  }
}

/// A section title on the album page ("Tem của bạn" / "Bộ tem mẫu").
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.sm,
        AppSpacing.xxl,
        AppSpacing.sm,
      ),
      child: Text(
        title,
        style: AppSerif.style(
          fontSize: 22,
          color: context.colorScheme.onSurface,
        ),
      ),
    );
  }
}

/// "Tem của bạn": the user's own stamps in a horizontal strip. Empty shows a
/// hint (or a "no matches" note while searching), with a create shortcut.
class _MyStampsRow extends StatelessWidget {
  const _MyStampsRow({
    required this.stamps,
    required this.searching,
    required this.onOpenStamp,
    this.onCreate,
  });

  final List<Stamp> stamps;
  final bool searching;
  final ValueChanged<Stamp> onOpenStamp;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    if (stamps.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          0,
          AppSpacing.xxl,
          AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                searching
                    ? 'Không tìm thấy tem phù hợp.'
                    : 'Bạn chưa có con tem nào.',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (!searching && onCreate != null)
              TextButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tạo tem'),
              ),
          ],
        ),
      );
    }
    return SizedBox(
      height: 172,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          0,
          AppSpacing.xxl,
          AppSpacing.md,
        ),
        itemCount: stamps.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, i) => SizedBox(
          width: 108,
          child: StampTile(
            stamp: stamps[i],
            onTap: () => onOpenStamp(stamps[i]),
          ),
        ),
      ),
    );
  }
}

/// One sample-stamp cell: its image, a saved check, and a tap that saves it
/// into the album (SM-035; the cubit dedupes already-saved samples).
class _SampleCard extends StatelessWidget {
  const _SampleCard({required this.sample, required this.saved});

  final SampleStamp sample;
  final bool saved;

  Future<void> _save(BuildContext context) async {
    final cubit = context.read<SampleStampsCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final result = await cubit.save(sample);
    final text = switch (result) {
      SampleSaveResult.saved => 'Đã lưu vào bộ sưu tập.',
      SampleSaveResult.alreadySaved => 'Tem này đã có trong bộ sưu tập.',
      SampleSaveResult.failed => 'Không lưu được. Vui lòng thử lại.',
    };
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return GestureDetector(
      onTap: saved ? null : () => _save(context),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F24211F),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: AppNetworkImage(
                        imageUrl: sample.thumbUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (saved)
                    Positioned(
                      top: AppSpacing.xs,
                      right: AppSpacing.xs,
                      child: Icon(
                        Icons.check_circle,
                        color: scheme.primary,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              sample.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}

enum _AlbumMenuAction { samples }

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

/// The Album top nav (F02-S19 `topnav`): the menu (☰) opens the action sheet
/// (refresh, sample catalog) and the centred "StampMail" wordmark. Search lives
/// in the dedicated bar below the title, so there is no top-nav search icon.
class _AlbumTopNav extends StatelessWidget {
  const _AlbumTopNav({required this.onMenu});

  final VoidCallback onMenu;

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
          // Balances the leading menu button so the wordmark stays centred now
          // that the top-nav search icon is gone (search is in the bar below).
          const SizedBox(width: 48),
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

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

class _AlbumBody extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // F02-S19: an empty album is a clean invite — the StampMail top nav +
    // illustration + CTA, without the search bar or stats header.
    if (state.isEmpty) {
      return Column(
        children: [
          const _AlbumTopNav(),
          Expanded(child: _AlbumEmpty(onCreate: onCreate)),
        ],
      );
    }
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.xxl,
            AppSpacing.xxl,
            AppSpacing.md,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    if (onBrowseSamples != null)
                      TextButton.icon(
                        onPressed: onBrowseSamples,
                        icon: const Icon(
                          Icons.auto_awesome_outlined,
                          size: 18,
                        ),
                        label: const Text('Tem mẫu'),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const AlbumSearchBar(),
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
              ],
            ),
          ),
        ),
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
                mainAxisSpacing: AppSpacing.sm,
                childAspectRatio: 3 / 4,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => StampTile(
                  stamp: state.stamps[i],
                  onTap: () => onOpenStamp(state.stamps[i]),
                ),
                childCount: state.stamps.length,
              ),
            ),
            AlbumViewMode.list => SliverList.separated(
              itemCount: state.stamps.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) => _StampListItem(
                stamp: state.stamps[i],
                onTap: () => onOpenStamp(state.stamps[i]),
              ),
            ),
          },
        ),
      ],
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

/// The top nav for the empty album (F02-S19 `topnav`): a menu affordance, the
/// centred "StampMail" wordmark, and a search icon. Search/menu are inert on the
/// empty state (there's nothing to search yet) — they're here for visual parity.
class _AlbumTopNav extends StatelessWidget {
  const _AlbumTopNav();

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

class _AlbumEmpty extends StatelessWidget {
  const _AlbumEmpty({this.onCreate});

  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // F02-S19 `illust` — the envelope + stamps empty illustration.
            Image.asset(
              'assets/illustrations/album-empty.png',
              package: 'feature_album',
              width: 240,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Album của bạn đang trống',
              textAlign: TextAlign.center,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tạo tem đầu tiên của bạn để bắt đầu sưu tầm nhé!',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
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

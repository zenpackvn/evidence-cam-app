import 'dart:typed_data';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

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
            },
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, Stamp stamp) {
    final cubit = context.read<AlbumCubit>();
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => StampDetailScreen(
          stamp: stamp,
          onBack: () => Navigator.of(context).maybePop(),
          onRename: (name) => cubit.rename(stamp.id, name),
          onDelete: () {
            cubit.delete(stamp.id);
            Navigator.of(context).maybePop();
          },
          onAttach: onAttachStamp == null ? null : () => onAttachStamp!(stamp),
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
                        icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                        label: const Text('Tem mẫu'),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const AlbumSearchBar(),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(child: AlbumStatsBanner(count: state.stamps.length)),
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
        if (state.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _AlbumEmpty(onCreate: onCreate),
          )
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
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
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
    final title = stamp.name.isNotEmpty ? stamp.name : _formatDate(stamp.createdAt);
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
            Icon(Icons.photo_library_outlined, size: 56, color: scheme.primary),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Bộ sưu tập còn trống',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tạo con tem đầu tiên từ một bức ảnh của bạn.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            if (onCreate != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              FilledButton(
                onPressed: onCreate,
                child: const Text('Tạo tem ngay'),
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

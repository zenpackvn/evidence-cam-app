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

/// SM-022 — "Bộ sưu tập của bạn" (F02-S10): the flat grid of the user's stamps
/// (created + received) with a search bar and a total-count banner. Tapping a
/// stamp opens its detail; the empty state (F02-S19) invites creating one.
class AlbumScreen extends StatelessWidget {
  const AlbumScreen({required this.onOpenStamp, this.onCreate, super.key});

  final ValueChanged<Stamp> onOpenStamp;
  final VoidCallback? onCreate;

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
                onOpenStamp: onOpenStamp,
                onCreate: onCreate,
              );
            },
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
  });

  final AlbumState state;
  final ValueChanged<Stamp> onOpenStamp;
  final VoidCallback? onCreate;

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
                Text(
                  'Tất cả những con tem xinh xắn bạn đã tạo.',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const AlbumSearchBar(),
                const SizedBox(height: AppSpacing.md),
                AlbumStatsBanner(count: state.stamps.length),
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
            sliver: SliverGrid(
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
          ),
      ],
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

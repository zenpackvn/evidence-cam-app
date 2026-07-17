import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../domain/entities/sample_stamp.dart';
import '../bloc/sample_stamps_cubit.dart';
import '../bloc/sample_stamps_state.dart';

/// SM-035 — "Bộ tem mẫu": browse the curated catalog by theme and save a stamp
/// into the personal album (free, deduped). Separate from the Album (BR-01).
class SampleStampsScreen extends StatelessWidget {
  const SampleStampsScreen({super.key});

  static const _ground = Color(0xFFFCF6EF);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<SampleStampsCubit>()..load(),
      child: Scaffold(
        backgroundColor: _ground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Bộ tem mẫu',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: BlocBuilder<SampleStampsCubit, SampleStampsState>(
            builder: (context, state) {
              if (state.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.error) {
                return _Error(onRetry: context.read<SampleStampsCubit>().load);
              }
              if (state.isEmpty) {
                return const Center(child: Text('Chưa có tem mẫu nào.'));
              }
              return _Body(state: state);
            },
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});

  final SampleStampsState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SampleStampsCubit>();
    return Column(
      children: [
        _ThemeChips(
          themes: state.themes,
          selected: state.selectedTheme,
          onSelect: cubit.selectTheme,
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.xl),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              childAspectRatio: 3 / 4,
            ),
            itemCount: state.visible.length,
            itemBuilder: (context, i) {
              final sample = state.visible[i];
              return _SampleTile(
                sample: sample,
                saved: state.savedIds.contains(sample.id),
                onTap: () => _openDetail(context, sample),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openDetail(BuildContext context, SampleStamp sample) {
    final cubit = context.read<SampleStampsCubit>();
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: _SampleDetail(sample: sample),
        ),
      ),
    );
  }
}

class _ThemeChips extends StatelessWidget {
  const _ThemeChips({
    required this.themes,
    required this.selected,
    required this.onSelect,
  });

  final List<String> themes;
  final String? selected;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        children: [
          _Chip(label: 'Tất cả', active: selected == null, onTap: () => onSelect(null)),
          for (final t in themes)
            _Chip(label: t, active: selected == t, onTap: () => onSelect(t)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: ChoiceChip(
        label: Text(label),
        selected: active,
        onSelected: (_) => onTap(),
        selectedColor: scheme.primaryContainer,
      ),
    );
  }
}

class _SampleTile extends StatelessWidget {
  const _SampleTile({
    required this.sample,
    required this.saved,
    required this.onTap,
  });

  final SampleStamp sample;
  final bool saved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: AppNetworkImage(
              imageUrl: sample.thumbUrl,
              fit: BoxFit.cover,
            ),
          ),
          if (sample.isNew)
            Positioned(
              top: AppSpacing.xs,
              left: AppSpacing.xs,
              child: _Badge(label: 'Mới', color: scheme.tertiary),
            ),
          if (saved)
            Positioned(
              top: AppSpacing.xs,
              right: AppSpacing.xs,
              child: Icon(Icons.check_circle, color: scheme.primary, size: 20),
            ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colorScheme.onTertiary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// SM-035 BR-07: preview a sample large, then save it (free). Pinch-to-zoom via
/// InteractiveViewer (AC-03).
class _SampleDetail extends StatelessWidget {
  const _SampleDetail({required this.sample});

  final SampleStamp sample;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<SampleStampsCubit, SampleStampsState>(
          builder: (context, state) {
            final saved = state.savedIds.contains(sample.id);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                children: [
                  const Spacer(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: AspectRatio(
                      aspectRatio: 3 / 4,
                      child: InteractiveViewer(
                        maxScale: 4,
                        child: AppNetworkImage(imageUrl: sample.imageUrl),
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: saved
                          ? null
                          : () => context.read<SampleStampsCubit>().save(sample),
                      icon: Icon(saved ? Icons.check : Icons.download_outlined),
                      label: Text(saved ? 'Đã lưu vào Album' : 'Lưu vào Album'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Không tải được bộ tem mẫu.'),
          const SizedBox(height: AppSpacing.md),
          TextButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}

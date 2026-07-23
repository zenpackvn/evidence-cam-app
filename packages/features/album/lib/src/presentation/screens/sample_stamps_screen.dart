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
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TopNav(onBack: () => Navigator.of(context).maybePop()),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.xs,
                  AppSpacing.xxl,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bộ tem mẫu',
                      style: AppSerif.style(
                        fontSize: 34,
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Chọn một mẫu có sẵn và lưu vào Album — hoàn toàn miễn phí.',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<SampleStampsCubit, SampleStampsState>(
                  builder: (context, state) {
                    if (state.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.error) {
                      return _Error(
                        onRetry: context.read<SampleStampsCubit>().load,
                      );
                    }
                    if (state.isEmpty) {
                      return const Center(
                        child: Text('Chưa có tem mẫu nào.'),
                      );
                    }
                    return _Body(state: state);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Top nav (mockup 5-11): back arrow + centred wordmark.
class _TopNav extends StatelessWidget {
  const _TopNav({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(Icons.arrow_back, color: scheme.onSurface),
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
          const SizedBox(width: 48),
        ],
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
    final visible = state.visible;
    return Column(
      children: [
        _ThemeChips(
          themes: state.themes,
          selected: state.selectedTheme,
          onSelect: cubit.selectTheme,
        ),
        Expanded(
          child: visible.isEmpty
              ? Center(
                  child: Text(
                    'Chủ đề này sắp ra mắt.',
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: 0.66,
                      ),
                  itemCount: visible.length,
                  itemBuilder: (context, i) {
                    final sample = visible[i];
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
          _Chip(
            label: 'Tất cả',
            active: selected == null,
            onTap: () => onSelect(null),
          ),
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

/// A catalog tile (mockup 5-11): the artwork, a "Mới"/saved badge, the stamp
/// name, and the free chip.
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
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
                  if (sample.isNew)
                    Positioned(
                      top: AppSpacing.xs,
                      left: AppSpacing.xs,
                      child: _Badge(label: 'Mới', color: scheme.primary),
                    ),
                  if (saved)
                    Positioned(
                      top: AppSpacing.xs,
                      right: AppSpacing.xs,
                      child: Icon(
                        Icons.check_circle,
                        color: scheme.primary,
                        size: 22,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              sample.name.isNotEmpty ? sample.name : 'Tem mẫu',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Center(child: _Badge(label: 'Miễn phí', color: scheme.tertiary)),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
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

  Future<void> _save(BuildContext context) async {
    final result = await context.read<SampleStampsCubit>().save(sample);
    if (!context.mounted) return;
    final message = switch (result) {
      SampleSaveResult.saved => 'Đã lưu vào Album.',
      SampleSaveResult.alreadySaved => 'Tem này đã có trong Album của bạn.',
      SampleSaveResult.failed => 'Không lưu được. Vui lòng thử lại.',
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Scaffold(
      backgroundColor: const Color(0xFFFCF6EF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: Text(
          'Chi tiết tem mẫu',
          style: AppSerif.style(fontSize: 22, color: scheme.onSurface),
        ),
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<SampleStampsCubit, SampleStampsState>(
          builder: (context, state) {
            final saved = state.savedIds.contains(sample.id);
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.md,
                AppSpacing.xxl,
                AppSpacing.xxl,
              ),
              children: [
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 320),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A24211F),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: InteractiveViewer(
                          maxScale: 4,
                          child: AppNetworkImage(imageUrl: sample.imageUrl),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    _Badge(label: 'Miễn phí', color: scheme.tertiary),
                    if (sample.isNew) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Mới',
                        style: context.textTheme.labelLarge?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  sample.name.isNotEmpty ? sample.name : 'Tem mẫu',
                  style: AppSerif.style(fontSize: 28, color: scheme.onSurface),
                ),
                if (sample.theme.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    sample.theme,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: saved ? null : () => _save(context),
                    icon: Icon(
                      saved ? Icons.check : Icons.bookmark_add_outlined,
                    ),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                    label: Text(saved ? 'Đã lưu vào Album' : 'Lưu vào Album'),
                  ),
                ),
              ],
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

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/filters.dart';
import '../../domain/stamp_draft.dart';
import '../bloc/creator_cubit.dart';
import '../bloc/creator_state.dart';
import '../widgets/stamp_frame.dart';

/// SM-006 — "Chọn bộ lọc màu" + "Chỉnh ảnh thủ công". A live-filtered preview
/// over a tool switcher: the "Bộ lọc" tab shows category chips + filter
/// thumbnails; the "Chỉnh tay" tab shows the four adjustment sliders.
class FilterStep extends StatefulWidget {
  const FilterStep({super.key});

  @override
  State<FilterStep> createState() => _FilterStepState();
}

enum _Tool { filters, adjust }

class _FilterStepState extends State<FilterStep> {
  _Tool _tool = _Tool.filters;
  FilterCategory _category = FilterCategory.classic;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CreatorCubit>().state;
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: StampFrame(draft: state.draft),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _ToolSwitcher(
          tool: _tool,
          onChanged: (t) => setState(() => _tool = t),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 118,
          child: _tool == _Tool.filters
              ? _FiltersPanel(
                  category: _category,
                  onCategory: (c) => setState(() => _category = c),
                  state: state,
                )
              : _AdjustPanel(state: state),
        ),
      ],
    );
  }
}

class _ToolSwitcher extends StatelessWidget {
  const _ToolSwitcher({required this.tool, required this.onChanged});

  final _Tool tool;
  final ValueChanged<_Tool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ToolTab(
          icon: Icons.gradient,
          label: 'Bộ lọc',
          active: tool == _Tool.filters,
          onTap: () => onChanged(_Tool.filters),
        ),
        _ToolTab(
          icon: Icons.tune,
          label: 'Chỉnh tay',
          active: tool == _Tool.adjust,
          onTap: () => onChanged(_Tool.adjust),
        ),
      ],
    );
  }
}

class _ToolTab extends StatelessWidget {
  const _ToolTab({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final color = active ? scheme.primary : scheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FiltersPanel extends StatelessWidget {
  const _FiltersPanel({
    required this.category,
    required this.onCategory,
    required this.state,
  });

  final FilterCategory category;
  final ValueChanged<FilterCategory> onCategory;
  final CreatorState state;

  static const Map<FilterCategory, String> _categoryLabels = {
    FilterCategory.classic: 'Cổ điển',
    FilterCategory.retro: 'Retro',
    FilterCategory.mood: 'Tâm trạng',
    FilterCategory.season: 'Mùa',
  };

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreatorCubit>();
    final filters = stampFilters
        .where((f) => f.category == category || f.id == StampDraft.kOriginalFilter)
        .toList();
    return Column(
      children: [
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final entry in _categoryLabels.entries)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: _CategoryChip(
                    label: entry.value,
                    active: entry.key == category,
                    onTap: () => onCategory(entry.key),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, i) {
              final filter = filters[i];
              final locked = filter.premium && !state.isPremium;
              return _FilterThumb(
                filter: filter,
                selected: state.draft.filterId == filter.id,
                locked: locked,
                onTap: () {
                  if (locked) {
                    _showPremiumHint(context);
                  } else {
                    cubit.selectFilter(filter.id);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showPremiumHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bộ lọc này chỉ dành cho Premium ✨')),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: active ? scheme.surfaceContainerLowest : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: active
              ? Border.all(color: scheme.primary, width: 1.5)
              : null,
        ),
        child: Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            color: active ? scheme.primary : scheme.onSurfaceVariant,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _FilterThumb extends StatelessWidget {
  const _FilterThumb({
    required this.filter,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  final StampFilter filter;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: selected
                    ? Border.all(color: scheme.primary, width: 2)
                    : null,
              ),
              child: locked
                  ? Icon(Icons.lock, size: 18, color: scheme.onSurfaceVariant)
                  : null,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              filter.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelSmall?.copyWith(
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdjustPanel extends StatelessWidget {
  const _AdjustPanel({required this.state});

  final CreatorState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreatorCubit>();
    final a = state.draft.adjustments;
    return ListView(
      children: [
        _AdjustSlider(
          label: 'Độ sáng',
          value: a.brightness,
          onChanged: (v) => cubit.setAdjustments(a.copyWith(brightness: v)),
        ),
        _AdjustSlider(
          label: 'Tương phản',
          value: a.contrast,
          onChanged: (v) => cubit.setAdjustments(a.copyWith(contrast: v)),
        ),
        _AdjustSlider(
          label: 'Ấm / Lạnh',
          value: a.warmth,
          onChanged: (v) => cubit.setAdjustments(a.copyWith(warmth: v)),
        ),
        _AdjustSlider(
          label: 'Bão hòa',
          value: a.saturation,
          onChanged: (v) => cubit.setAdjustments(a.copyWith(saturation: v)),
        ),
      ],
    );
  }
}

class _AdjustSlider extends StatelessWidget {
  const _AdjustSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 84,
          child: Text(label, style: context.textTheme.bodySmall),
        ),
        Expanded(
          child: Slider(value: value, min: -1, max: 1, onChanged: onChanged),
        ),
        SizedBox(
          width: 36,
          child: Text(
            '${(value * 100).round()}',
            textAlign: TextAlign.end,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

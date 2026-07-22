import 'dart:io';

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

  /// The selected filter group, or `null` for the standalone "Gốc" (original) tab.
  FilterCategory? _category = FilterCategory.classic;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CreatorCubit>().state;
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            // The framed tem (same as "Xem trước ảnh" / decorate) so the live
            // filter is seen inside the stamp. On a warm backdrop so the white
            // stamp stands out from the cream ground.
            child: Center(
              child: StampBackdrop(child: StampFrame(draft: state.draft)),
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
          height: 134,
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

  /// The selected group, or `null` for the "Gốc" (original / no-filter) tab.
  final FilterCategory? category;
  final ValueChanged<FilterCategory?> onCategory;
  final CreatorState state;

  /// The four filter groups (SM-006 BR: 4 nhóm). The standalone "Gốc" (original /
  /// no-filter) tab is a presentation convenience — a `null` category — and is
  /// not one of the business groups.
  static const Map<FilterCategory, String> _categoryLabels = {
    FilterCategory.classic: 'Cổ điển',
    FilterCategory.retro: 'Retro/Vintage',
    FilterCategory.mood: 'Tâm trạng',
    FilterCategory.season: 'Mùa',
  };

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreatorCubit>();
    // "Gốc" lives only in its own tab (category == null → just the original);
    // each group tab shows only that group's presets, no duplicated "Gốc".
    final filters = category == null
        ? stampFilters.where((f) => f.id == StampDraft.kOriginalFilter).toList()
        : stampFilters
              .where(
                (f) =>
                    f.category == category &&
                    f.id != StampDraft.kOriginalFilter,
              )
              .toList();
    return Column(
      children: [
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Leading standalone "Gốc" (original / no-filter) tab.
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: _CategoryChip(
                  label: 'Gốc',
                  active: category == null,
                  onTap: () => onCategory(null),
                ),
              ),
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
        // The thumbnails fill the row evenly (F02-S04 `thumbRow`), each a
        // filtered preview of the photo with the name overlaid at the bottom.
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, filter) in filters.indexed) ...[
                if (i > 0) const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _FilterThumb(
                    filter: filter,
                    imagePath: state.draft.imagePath,
                    selected: state.draft.filterId == filter.id,
                    locked: filter.premium && !state.isPremium,
                    onTap: () {
                      if (filter.premium && !state.isPremium) {
                        _showPremiumHint(context);
                      } else {
                        cubit.selectFilter(filter.id);
                      }
                    },
                  ),
                ),
              ],
            ],
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
          border: active ? Border.all(color: scheme.primary, width: 1.5) : null,
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

/// A filter preview tile (F02-S04 `th-*`): the photo with this filter applied,
/// a dark bottom gradient, and the filter name overlaid bottom-left. Selected
/// tiles get a coral border; locked (Premium) tiles show a lock.
class _FilterThumb extends StatelessWidget {
  const _FilterThumb({
    required this.filter,
    required this.imagePath,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  final StampFilter filter;
  final String imagePath;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final file = File(imagePath);
    var photo = file.existsSync()
        ? Image.file(file, fit: BoxFit.cover) as Widget
        : ColoredBox(color: scheme.secondaryContainer);
    final matrix = filter.matrix;
    if (matrix != null) {
      photo = ColorFiltered(
        colorFilter: ColorFilter.matrix(matrix),
        child: photo,
      );
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: selected ? Border.all(color: scheme.primary, width: 2) : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Stack(
            fit: StackFit.expand,
            children: [
              photo,
              // Bottom scrim so the white label stays legible.
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xB3000000)],
                  ),
                ),
              ),
              Positioned(
                left: 5,
                right: 3,
                bottom: 4,
                child: Text(
                  filter.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    letterSpacing: 0,
                  ),
                ),
              ),
              if (locked)
                const Center(
                  child: Icon(Icons.lock, size: 16, color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The manual-adjust tools (F02-S05 `toolRow`).
enum _Adjust { brightness, contrast, warmth, saturation, sharpness }

/// "Chỉnh tay" (F02-S05): one slider for the active tool over a row of tool
/// buttons — tap a tool to edit it, drag the slider to set its amount.
class _AdjustPanel extends StatefulWidget {
  const _AdjustPanel({required this.state});

  final CreatorState state;

  @override
  State<_AdjustPanel> createState() => _AdjustPanelState();
}

class _AdjustPanelState extends State<_AdjustPanel> {
  _Adjust _active = _Adjust.brightness;

  static const Map<_Adjust, String> _labels = {
    _Adjust.brightness: 'Độ sáng',
    _Adjust.contrast: 'Tương phản',
    _Adjust.warmth: 'Ấm / Lạnh',
    _Adjust.saturation: 'Bão hòa',
    _Adjust.sharpness: 'Độ nét',
  };
  static const Map<_Adjust, IconData> _icons = {
    _Adjust.brightness: Icons.wb_sunny_outlined,
    _Adjust.contrast: Icons.contrast,
    _Adjust.warmth: Icons.thermostat,
    _Adjust.saturation: Icons.water_drop_outlined,
    _Adjust.sharpness: Icons.center_focus_strong_outlined,
  };

  double _valueOf(Adjustments a) => switch (_active) {
    _Adjust.brightness => a.brightness,
    _Adjust.contrast => a.contrast,
    _Adjust.warmth => a.warmth,
    _Adjust.saturation => a.saturation,
    _Adjust.sharpness => a.sharpness,
  };

  void _apply(Adjustments a, double v) {
    final next = switch (_active) {
      _Adjust.brightness => a.copyWith(brightness: v),
      _Adjust.contrast => a.copyWith(contrast: v),
      _Adjust.warmth => a.copyWith(warmth: v),
      _Adjust.saturation => a.copyWith(saturation: v),
      _Adjust.sharpness => a.copyWith(sharpness: v),
    };
    context.read<CreatorCubit>().setAdjustments(next);
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.state.draft.adjustments;
    final value = _valueOf(a);
    final scheme = context.colorScheme;
    return Column(
      children: [
        Row(
          children: [
            Text(_labels[_active]!, style: context.textTheme.bodyMedium),
            const Spacer(),
            Text(
              '${value >= 0 ? '+' : ''}${(value * 100).round()}',
              style: context.textTheme.bodyMedium?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Slider(
            value: value,
            min: -1,
            max: 1,
            onChanged: (v) => _apply(a, v),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            for (final tool in _Adjust.values)
              Expanded(
                child: _ToolButton(
                  icon: _icons[tool]!,
                  label: _labels[tool]!,
                  active: tool == _active,
                  onTap: () => setState(() => _active = tool),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// A circular adjust-tool button with its label (F02-S05 `AdjustTool`).
class _ToolButton extends StatelessWidget {
  const _ToolButton({
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? scheme.primary : context.brand.surfaceElevated,
            ),
            child: Icon(
              icon,
              size: 20,
              color: active ? scheme.onPrimary : scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelSmall?.copyWith(
              color: active ? scheme.primary : scheme.onSurfaceVariant,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

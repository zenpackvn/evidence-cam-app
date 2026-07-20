import 'dart:math' as math;

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/borders.dart';
import '../../domain/stamp_draft.dart';
import '../bloc/creator_cubit.dart';
import '../bloc/creator_state.dart';
import '../widgets/stamp_frame.dart';

/// SM-008/009 — "Trang trí con tem": the stamp preview over an elevated panel
/// (F02-S07 `panel`) with three tabs — Sticker (a grid you tap to drop),
/// Viền tem (borders), and Nền (paper colour). Placed stickers land near center
/// with a little random scatter so repeats don't stack exactly.
class DecorateStep extends StatefulWidget {
  const DecorateStep({super.key});

  @override
  State<DecorateStep> createState() => _DecorateStepState();
}

enum _Panel { stickers, borders, paper }

/// SM-009 "Nền" paper colours.
const _paperColors = <int>[
  0xFFFFFFFF,
  0xFFFBF3EA,
  0xFFFDE7EC,
  0xFFFCE9D6,
  0xFFE9F5E9,
  0xFFE3F1FB,
  0xFFEDE7F6,
  0xFFF4E1E1,
];

class _DecorateStepState extends State<DecorateStep> {
  _Panel _panel = _Panel.stickers;
  final _rand = math.Random();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CreatorCubit>().state;
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: StampFrame(
                draft: state.draft,
                interactive: true,
                onStickerMoved: (i, dx, dy) =>
                    context.read<CreatorCubit>().moveSticker(i, dx, dy),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _DecoratePanel(
          panel: _panel,
          onTab: (p) => setState(() => _panel = p),
          state: state,
          onPickSticker: _dropSticker,
        ),
      ],
    );
  }

  void _dropSticker(String glyph) {
    double jitter() => 0.4 + _rand.nextDouble() * 0.2;
    context.read<CreatorCubit>().addSticker(
      StickerPlacement(glyph: glyph, dx: jitter(), dy: jitter()),
    );
  }
}

/// The elevated card holding the tabs and the active tool grid (F02-S07 `panel`).
class _DecoratePanel extends StatelessWidget {
  const _DecoratePanel({
    required this.panel,
    required this.onTab,
    required this.state,
    required this.onPickSticker,
  });

  final _Panel panel;
  final ValueChanged<_Panel> onTab;
  final CreatorState state;
  final ValueChanged<String> onPickSticker;

  @override
  Widget build(BuildContext context) {
    final Widget content = switch (panel) {
      _Panel.stickers => _StickerGrid(onPick: onPickSticker),
      _Panel.borders => _BorderGrid(state: state),
      _Panel.paper => _PaperGrid(state: state),
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: context.brand.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1424211F),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SegTabs(panel: panel, onTab: onTab),
          const SizedBox(height: 10),
          SizedBox(height: 132, child: _ToolCard(child: content)),
        ],
      ),
    );
  }
}

/// The three full-width segment tabs (F02-S07 `tabs`, from `Editor/SegTab`).
class _SegTabs extends StatelessWidget {
  const _SegTabs({required this.panel, required this.onTab});

  final _Panel panel;
  final ValueChanged<_Panel> onTab;

  static const Map<_Panel, String> _labels = {
    _Panel.stickers: 'Sticker',
    _Panel.borders: 'Viền tem',
    _Panel.paper: 'Nền',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Row(
      children: [
        for (final entry in _labels.entries)
          Expanded(
            child: InkWell(
              onTap: () => onTab(entry.key),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.value,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: panel == entry.key
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                        fontWeight: panel == entry.key
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 3,
                      width: 40,
                      decoration: BoxDecoration(
                        color: panel == entry.key
                            ? scheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// The inner tinted card that frames each tool grid (F02-S07 `stickerGrid`).
class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF4EC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}

class _StickerGrid extends StatelessWidget {
  const _StickerGrid({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 6,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: EdgeInsets.zero,
      children: [
        for (final glyph in stickerGlyphs)
          InkWell(
            onTap: () => onPick(glyph),
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.brand.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(glyph, style: const TextStyle(fontSize: 22)),
            ),
          ),
      ],
    );
  }
}

class _BorderGrid extends StatelessWidget {
  const _BorderGrid({required this.state});

  final CreatorState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreatorCubit>();
    final scheme = context.colorScheme;
    return GridView.count(
      crossAxisCount: 4,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: EdgeInsets.zero,
      childAspectRatio: 1.6,
      children: [
        for (final border in stampBorders)
          Builder(
            builder: (context) {
              final locked = border.premium && !state.isPremium;
              final selected = state.draft.borderId == border.id;
              return InkWell(
                onTap: () {
                  if (locked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Viền này chỉ dành cho Premium ✨'),
                      ),
                    );
                  } else {
                    cubit.selectBorder(border.id);
                  }
                },
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.brand.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: selected
                        ? Border.all(color: scheme.primary, width: 2)
                        : null,
                  ),
                  child: locked
                      ? Icon(
                          Icons.lock,
                          size: 16,
                          color: scheme.onSurfaceVariant,
                        )
                      : Text(
                          border.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.labelSmall?.copyWith(
                            color: selected
                                ? scheme.primary
                                : scheme.onSurfaceVariant,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _PaperGrid extends StatelessWidget {
  const _PaperGrid({required this.state});

  final CreatorState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreatorCubit>();
    final scheme = context.colorScheme;
    final current = state.draft.paperColor ?? 0xFFFFFFFF;
    return GridView.count(
      crossAxisCount: 6,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: EdgeInsets.zero,
      children: [
        for (final color in _paperColors)
          InkWell(
            onTap: () => cubit.selectPaper(color),
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              decoration: BoxDecoration(
                color: Color(color),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: current == color
                      ? scheme.primary
                      : scheme.outlineVariant,
                  width: current == color ? 2 : 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

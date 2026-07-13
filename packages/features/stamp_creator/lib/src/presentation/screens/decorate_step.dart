import 'dart:math' as math;

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/borders.dart';
import '../../domain/stamp_draft.dart';
import '../bloc/creator_cubit.dart';
import '../bloc/creator_state.dart';
import '../widgets/stamp_frame.dart';

/// SM-008/009 — "Trang trí con tem": the stamp preview over a tabbed panel of
/// stickers (tap to drop one) and borders (tap to select). Placed stickers land
/// near center with a little random scatter so repeats don't stack exactly.
class DecorateStep extends StatefulWidget {
  const DecorateStep({super.key});

  @override
  State<DecorateStep> createState() => _DecorateStepState();
}

enum _Panel { stickers, borders }

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
              child: StampFrame(draft: state.draft, interactive: true),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _PanelTabs(panel: _panel, onChanged: (p) => setState(() => _panel = p)),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 96,
          child: _panel == _Panel.stickers
              ? _StickerGrid(onPick: _dropSticker)
              : _BorderRow(state: state),
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

class _PanelTabs extends StatelessWidget {
  const _PanelTabs({required this.panel, required this.onChanged});

  final _Panel panel;
  final ValueChanged<_Panel> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Tab(
          label: 'Sticker',
          active: panel == _Panel.stickers,
          onTap: () => onChanged(_Panel.stickers),
        ),
        const SizedBox(width: AppSpacing.xxl),
        _Tab(
          label: 'Viền tem',
          active: panel == _Panel.borders,
          onTap: () => onChanged(_Panel.borders),
        ),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                color: active ? scheme.primary : scheme.onSurfaceVariant,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                color: active ? scheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickerGrid extends StatelessWidget {
  const _StickerGrid({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        for (final glyph in stickerGlyphs)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: InkWell(
              onTap: () => onPick(glyph),
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(glyph, style: const TextStyle(fontSize: 26)),
              ),
            ),
          ),
      ],
    );
  }
}

class _BorderRow extends StatelessWidget {
  const _BorderRow({required this.state});

  final CreatorState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreatorCubit>();
    final scheme = context.colorScheme;
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        for (final border in stampBorders)
          Builder(
            builder: (context) {
              final locked = border.premium && !state.isPremium;
              final selected = state.draft.borderId == border.id;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: InkWell(
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
                  child: SizedBox(
                    width: 72,
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: selected
                                ? Border.all(color: scheme.primary, width: 2)
                                : null,
                          ),
                          child: locked
                              ? Icon(
                                  Icons.lock,
                                  size: 18,
                                  color: scheme.onSurfaceVariant,
                                )
                              : Icon(
                                  Icons.crop_portrait,
                                  color: scheme.onSurfaceVariant,
                                ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          border.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.labelSmall?.copyWith(
                            color: selected
                                ? scheme.primary
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
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

import 'package:app_ui/app_ui.dart';
import 'package:feature_album/feature_album.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/letter.dart';
import '../../domain/entities/letter_content.dart';
import '../bloc/composer_cubit.dart';
import '../bloc/composer_state.dart';
import '../widgets/letter_paper.dart';

/// SM-014 — "Đính tem" (F03-S07): pick up to 3 stamps from the Album to attach
/// to the letter. The letter preview at the top shows the picked stamps, which
/// can be dragged to reposition and double-tapped to rotate; the grid selects
/// which stamps (max 3).
class AttachStampsScreen extends StatefulWidget {
  const AttachStampsScreen({
    required this.stamps,
    required this.onBack,
    required this.onDone,
    super.key,
  });

  /// The user's stamps (loaded by the host from the Album repository).
  final List<Stamp> stamps;
  final VoidCallback onBack;
  final VoidCallback onDone;

  @override
  State<AttachStampsScreen> createState() => _AttachStampsScreenState();
}

class _AttachStampsScreenState extends State<AttachStampsScreen> {
  static const _ground = Color(0xFFFBF5EC);
  static const _previewHeight = 210.0;

  /// Local, ephemeral placement (normalized 0..1 + rotation) of each picked
  /// stamp on the letter preview.
  final Map<String, ({double dx, double dy, double rot})> _placements = {};

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ComposerCubit, ComposerState>(
      builder: (context, state) {
        final cubit = context.read<ComposerCubit>();
        // Keep placements in sync with the selection: a default spot for each
        // newly picked stamp, and drop any that were deselected.
        for (final (i, id) in state.stampIds.indexed) {
          _placements.putIfAbsent(
            id,
            () => (dx: 0.35 + i * 0.18, dy: 0.68, rot: 0),
          );
        }
        _placements.removeWhere((id, _) => !state.stampIds.contains(id));

        return Scaffold(
          backgroundColor: _ground,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: _AttachHeader(onBack: widget.onBack),
                ),
                // F03-S07 `letter`: the composed letter with the picked stamps.
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: _LetterPreview(
                    content: state.content,
                    stamps: widget.stamps,
                    stampIds: state.stampIds,
                    placements: _placements,
                    height: _previewHeight,
                    onMove: (id, dx, dy) => setState(
                      () => _placements[id] = (
                        dx: dx,
                        dy: dy,
                        rot: _placements[id]?.rot ?? 0,
                      ),
                    ),
                    onRotate: (id) => setState(
                      () => _placements[id] = (
                        dx: _placements[id]?.dx ?? 0.5,
                        dy: _placements[id]?.dy ?? 0.6,
                        rot: (_placements[id]?.rot ?? 0) + 0.26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: widget.stamps.isEmpty
                      ? const _NoStamps()
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.xl,
                            0,
                            AppSpacing.xl,
                            AppSpacing.md,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                // .pen F03-S07: 4-up stamp grid.
                                crossAxisCount: 4,
                                mainAxisSpacing: AppSpacing.sm,
                                crossAxisSpacing: AppSpacing.sm,
                                childAspectRatio: 0.82,
                              ),
                          itemCount: widget.stamps.length,
                          itemBuilder: (context, i) {
                            final stamp = widget.stamps[i];
                            final selected = state.stampIds.contains(stamp.id);
                            final atLimit =
                                state.stampIds.length >= LetterInput.maxStamps;
                            return _StampPick(
                              key: ValueKey('stamp-pick-${stamp.id}'),
                              stamp: stamp,
                              selected: selected,
                              onTap: () {
                                // SM-014 AC-02: picking a 4th stamp is blocked
                                // and the user is told the 3-per-letter limit.
                                if (!selected && atLimit) {
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Mỗi thư chỉ đính được tối đa '
                                          '${LetterInput.maxStamps} con tem.',
                                        ),
                                      ),
                                    );
                                  return;
                                }
                                cubit.toggleStamp(stamp.id);
                              },
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.sm,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: state.stampIds.isEmpty ? null : widget.onDone,
                      icon: const Icon(Icons.local_post_office_outlined),
                      label: const Text('Đính tem này'),
                    ),
                  ),
                ),
                // F03-S07 hint.
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: 'Kéo thả để di chuyển'),
                        TextSpan(
                          text: '  ·  ',
                          style: TextStyle(
                            color: context.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const TextSpan(text: 'Nhấn đúp để xoay'),
                      ],
                    ),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The composed letter with the picked stamps overlaid (F03-S07 `letter`).
/// Stamps drag to reposition and double-tap to rotate.
class _LetterPreview extends StatelessWidget {
  const _LetterPreview({
    required this.content,
    required this.stamps,
    required this.stampIds,
    required this.placements,
    required this.height,
    required this.onMove,
    required this.onRotate,
  });

  final LetterContent content;
  final List<Stamp> stamps;
  final List<String> stampIds;
  final Map<String, ({double dx, double dy, double rot})> placements;
  final double height;
  final void Function(String id, double dx, double dy) onMove;
  final ValueChanged<String> onRotate;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          return ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Stack(
              children: [
                // The top of the actual letter, clipped to the preview height.
                Positioned.fill(
                  child: OverflowBox(
                    alignment: Alignment.topCenter,
                    minHeight: 0,
                    maxHeight: double.infinity,
                    child: ReadOnlyLetterPaper(content: content),
                  ),
                ),
                for (final id in stampIds)
                  if (_stampById(id) case final stamp?)
                    _PlacedStamp(
                      stamp: stamp,
                      placement: placements[id] ?? (dx: 0.5, dy: 0.6, rot: 0),
                      width: w,
                      height: height,
                      onMove: (dx, dy) => onMove(id, dx, dy),
                      onRotate: () => onRotate(id),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }

  Stamp? _stampById(String id) {
    for (final s in stamps) {
      if (s.id == id) return s;
    }
    return null;
  }
}

/// A draggable, rotatable stamp on the letter preview.
class _PlacedStamp extends StatelessWidget {
  const _PlacedStamp({
    required this.stamp,
    required this.placement,
    required this.width,
    required this.height,
    required this.onMove,
    required this.onRotate,
  });

  static const _size = 52.0;

  final Stamp stamp;
  final ({double dx, double dy, double rot}) placement;
  final double width;
  final double height;
  final void Function(double dx, double dy) onMove;
  final VoidCallback onRotate;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: placement.dx * width - _size / 2,
      top: placement.dy * height - _size / 2,
      child: GestureDetector(
        onDoubleTap: onRotate,
        onPanUpdate: (d) {
          final nx = ((placement.dx * width + d.delta.dx) / width).clamp(
            0.0,
            1.0,
          );
          final ny = ((placement.dy * height + d.delta.dy) / height).clamp(
            0.0,
            1.0,
          );
          onMove(nx, ny);
        },
        child: Transform.rotate(
          angle: placement.rot,
          child: Container(
            width: _size,
            height: _size,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: AppNetworkImage(
              imageUrl: stamp.thumbUrl ?? stamp.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

/// Back button, "Đính tem" title, and a help button (`.pen` F03-S07 topbar).
class _AttachHeader extends StatelessWidget {
  const _AttachHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HeaderButton(icon: Icons.chevron_left, onTap: onBack),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Đính tem',
          style: context.textTheme.displayMedium?.copyWith(fontSize: 26),
        ),
        const Spacer(),
        _HeaderButton(icon: Icons.help_outline, onTap: () {}),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.brand.surfaceElevated,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 22, color: context.colorScheme.onSurface),
        ),
      ),
    );
  }
}

class _StampPick extends StatelessWidget {
  const _StampPick({
    required this.stamp,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final Stamp stamp;
  final bool selected;
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
              imageUrl: stamp.thumbUrl ?? stamp.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          if (selected)
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: scheme.primary, width: 2.5),
                color: scheme.primary.withValues(alpha: 0.12),
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: CircleAvatar(
                    radius: 11,
                    backgroundColor: scheme.primary,
                    child: Icon(
                      Icons.check,
                      size: 14,
                      color: scheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NoStamps extends StatelessWidget {
  const _NoStamps();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Text(
          'Bạn chưa có con tem nào.\nTạo một con tem trước khi gửi thư.',
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

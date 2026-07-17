import 'package:app_ui/app_ui.dart';
import 'package:feature_album/feature_album.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/letter.dart';
import '../bloc/composer_cubit.dart';
import '../bloc/composer_state.dart';

/// SM-014 — "Đính tem" (F03-S07): pick up to 3 stamps from the Album to attach
/// to the letter. Selected stamps show a check; the picker enforces the max.
class AttachStampsScreen extends StatelessWidget {
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

  static const _ground = Color(0xFFFBF5EC);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ComposerCubit, ComposerState>(
      builder: (context, state) {
        final cubit = context.read<ComposerCubit>();
        return Scaffold(
          backgroundColor: _ground,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: BackButton(onPressed: onBack),
            title: Text(
              'Đính tem (${state.stampIds.length}/${LetterInput.maxStamps})',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child: stamps.isEmpty
                      ? const _NoStamps()
                      : GridView.builder(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: AppSpacing.sm,
                                crossAxisSpacing: AppSpacing.sm,
                                childAspectRatio: 3 / 4,
                              ),
                          itemCount: stamps.length,
                          itemBuilder: (context, i) {
                            final stamp = stamps[i];
                            final selected = state.stampIds.contains(stamp.id);
                            final atLimit =
                                state.stampIds.length >= LetterInput.maxStamps;
                            return _StampPick(
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
                    AppSpacing.xxl,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: state.stampIds.isEmpty ? null : onDone,
                      icon: const Icon(Icons.local_post_office_outlined),
                      label: const Text('Đính tem này'),
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

class _StampPick extends StatelessWidget {
  const _StampPick({
    required this.stamp,
    required this.selected,
    required this.onTap,
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

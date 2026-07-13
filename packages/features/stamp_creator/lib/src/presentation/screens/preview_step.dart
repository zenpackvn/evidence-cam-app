import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/creator_cubit.dart';
import '../widgets/stamp_frame.dart';

/// SM-010 — "Xem trước": the finished stamp shown large before saving. The
/// watermark that a Free user gets is composited into the captured PNG at save
/// time (SM-011); here it previews as a subtle overlay.
class PreviewStep extends StatelessWidget {
  const PreviewStep({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<CreatorCubit>();
    final state = cubit.state;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
        // The boundary is what save() captures to PNG, so the watermark inside
        // it is composited into the saved image (SM-011), not just an overlay.
        child: RepaintBoundary(
          key: cubit.repaintKey,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              StampFrame(draft: state.draft),
              if (!state.isPremium)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    'StampMail',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

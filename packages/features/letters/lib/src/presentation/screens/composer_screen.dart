import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/composer_cubit.dart';
import '../bloc/composer_state.dart';
import '../composer_catalog.dart';
import '../widgets/composer_editor_panel.dart';
import '../widgets/letter_paper.dart';

/// SM-012..015 — "Soạn thư" (F03-S04/S05/S06): the letter paper with the
/// editable body over the tabbed editor sheet (Giấy nền · Căn lề · Màu nền ·
/// Sticker), a live character counter (≤500), and the design's circular
/// top-bar actions. Rich per-selection formatting is a later upgrade
/// (flutter_quill); this is the composing + font/paper/color slice.
class ComposerScreen extends StatelessWidget {
  const ComposerScreen({
    required this.onBack,
    required this.onNext,
    super.key,
  });

  final VoidCallback onBack;

  /// Called when the user proceeds to attach stamps / send.
  final VoidCallback onNext;

  static const _ground = Color(0xFFFBF5EC);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ComposerCubit, ComposerState>(
      builder: (context, state) {
        final cubit = context.read<ComposerCubit>();
        return Scaffold(
          backgroundColor: _ground,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: _TopBar(canSend: state.canSend, onBack: onBack, onDone: onNext),
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: LetterPaper(
                      content: state.content,
                      onTextChanged: cubit.setText,
                    ),
                  ),
                ),
                _CharCounter(count: state.charCount),
                ComposerEditorPanel(
                  selectedFont: state.content.fontFamily,
                  selectedPaper: state.content.paperColor,
                  ruled: state.content.ruled,
                  onFont: cubit.selectFont,
                  onPaper: cubit.selectPaper,
                  onRuled: (ruled) => cubit.setRuled(ruled: ruled),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The design's top bar (F03-S05): circular back button, Baloo "Soạn thư"
/// title, then undo / redo / preview circles and the coral done button.
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.canSend,
    required this.onBack,
    required this.onDone,
  });

  final bool canSend;
  final VoidCallback onBack;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Row(
      children: [
        _CircleAction(size: 44, icon: Icons.arrow_back, onTap: onBack),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Soạn thư',
          style: context.textTheme.displayMedium?.copyWith(fontSize: 24),
        ),
        const Spacer(),
        // ponytail: undo/redo are visual until the composer keeps history.
        _CircleAction(size: 40, icon: Icons.undo, onTap: () {}),
        const SizedBox(width: AppSpacing.sm),
        _CircleAction(size: 40, icon: Icons.redo, onTap: () {}),
        const SizedBox(width: AppSpacing.sm),
        _CircleAction(
          size: 40,
          icon: Icons.check,
          fill: scheme.primary,
          iconColor: scheme.onPrimary,
          onTap: canSend ? onDone : null,
        ),
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.size,
    required this.icon,
    required this.onTap,
    this.fill,
    this.iconColor,
  });

  final double size;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? fill;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: fill ?? context.brand.surfaceElevated,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: size < 44 ? 18 : 20,
            color: (iconColor ?? context.colorScheme.onSurface)
                .withValues(alpha: enabled ? 1 : 0.4),
          ),
        ),
      ),
    );
  }
}

class _CharCounter extends StatelessWidget {
  const _CharCounter({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final near = count >= letterCharLimit - 20;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$count / $letterCharLimit ký tự',
            style: context.textTheme.bodySmall?.copyWith(
              color: near
                  ? context.colorScheme.error
                  : context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

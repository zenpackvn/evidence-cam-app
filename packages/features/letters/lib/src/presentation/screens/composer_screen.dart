import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../domain/entities/letter_content.dart';
import '../bloc/composer_cubit.dart';
import '../bloc/composer_state.dart';
import '../letter_document.dart';
import '../widgets/composer_editor_panel.dart';
import '../widgets/letter_paper.dart';

/// SM-012..015 — "Soạn thư" (F03-S04/S05/S06): the letter paper with the rich
/// body over the editor sheet (formatting row + Giấy nền · Căn lề · Màu chữ ·
/// Màu nền · Sticker), a live character counter (≤500), and the design's
/// circular top-bar actions.
///
/// This screen owns the [QuillController]: the paper renders it and the sheet's
/// toolbar formats its selection, so both must share one instance. The document
/// — not the cubit — is the live source of truth while editing; each edit is
/// pushed into the cubit as Delta so the rest of the flow (preview, send) reads
/// plain [ComposerState].
class ComposerScreen extends StatefulWidget {
  const ComposerScreen({
    required this.onBack,
    required this.onNext,
    super.key,
  });

  final VoidCallback onBack;

  /// Called when the user proceeds to attach stamps / send.
  final VoidCallback onNext;

  @override
  State<ComposerScreen> createState() => _ComposerScreenState();
}

class _ComposerScreenState extends State<ComposerScreen> {
  static const _ground = Color(0xFFFBF5EC);

  /// The editor sheet never takes more than this share of the body: past it the
  /// sheet scrolls inside itself, so the paper — and the line being typed —
  /// stay visible on short screens and with the keyboard open.
  static const _panelMaxHeightFraction = 0.62;

  late final QuillController _controller;
  late final StreamSubscription<DocChange> _changes;
  final FocusNode _focusNode = FocusNode();

  /// Guards the re-entrant edit [_enforceCharLimit] makes.
  bool _clipping = false;

  @override
  void initState() {
    super.initState();
    // Seeded once from the draft: re-seeding on rebuild would fight the caret.
    _controller = letterController(context.read<ComposerCubit>().state.content);
    _changes = _controller.document.changes.listen((_) => _onDocumentChanged());
  }

  @override
  void dispose() {
    unawaited(_changes.cancel());
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onDocumentChanged() {
    if (_clipping) return;
    _enforceCharLimit();
    context.read<ComposerCubit>().setRichBody(letterDeltaOf(_controller.document));
  }

  /// SM-013 BR-04 / AC-04: refuse characters past the limit. Trimming the
  /// overflow (rather than rejecting the whole edit) keeps the formatting of
  /// everything already written, and covers paste as well as typing.
  void _enforceCharLimit() {
    // `document.length` counts the closing newline, which is not the user's.
    final length = _controller.document.length - 1;
    if (length <= letterCharLimit) return;
    _clipping = true;
    _controller.replaceText(
      letterCharLimit,
      length - letterCharLimit,
      '',
      const TextSelection.collapsed(offset: letterCharLimit),
    );
    _clipping = false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ComposerCubit, ComposerState>(
      builder: (context, state) {
        final cubit = context.read<ComposerCubit>();
        return Scaffold(
          backgroundColor: _ground,
          body: SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) => Column(
                children: [
                  const SizedBox(height: AppSpacing.md),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: _TopBar(
                      canSend: state.canSend,
                      onBack: widget.onBack,
                      onDone: widget.onNext,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: LetterPaper(
                        content: state.content,
                        controller: _controller,
                        focusNode: _focusNode,
                      ),
                    ),
                  ),
                  _CharCounter(count: state.charCount),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight * _panelMaxHeightFraction,
                    ),
                    child: ComposerEditorPanel(
                      controller: _controller,
                      selectedFont: state.content.fontFamily,
                      selectedPaper: state.content.paperColor,
                      ruled: state.content.ruled,
                      onFont: cubit.selectFont,
                      onPaper: cubit.selectPaper,
                      onRuled: (ruled) => cubit.setRuled(ruled: ruled),
                    ),
                  ),
                ],
              ),
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
        // Takes the slack between the back button and the actions (the old
        // Spacer's job) while staying shrinkable, so the title can never push
        // the actions off a narrow screen.
        Expanded(
          child: Text(
            'Soạn thư',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.displayMedium?.copyWith(fontSize: 24),
          ),
        ),
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

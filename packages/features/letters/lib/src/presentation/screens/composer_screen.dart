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
  late final TextEditingController _titleController;
  final FocusNode _focusNode = FocusNode();

  /// Guards the re-entrant edit [_enforceCharLimit] makes.
  bool _clipping = false;

  @override
  void initState() {
    super.initState();
    // Seeded once from the draft: re-seeding on rebuild would fight the caret.
    _controller = letterController(context.read<ComposerCubit>().state.content);
    _titleController = TextEditingController(
      text: context.read<ComposerCubit>().state.content.title,
    );
    _changes = _controller.document.changes.listen((_) => _onDocumentChanged());
  }

  @override
  void dispose() {
    unawaited(_changes.cancel());
    _controller.dispose();
    _titleController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onDocumentChanged() {
    if (_clipping) return;
    _enforceCharLimit();
    context.read<ComposerCubit>().setRichBody(
      letterDeltaOf(_controller.document),
    );
  }

  /// SM-013 BR-04 / AC-04: refuse characters past the limit. Trimming the
  /// overflow (rather than rejecting the whole edit) keeps the formatting of
  /// everything already written, and covers paste as well as typing.
  void _enforceCharLimit() {
    // `document.length` counts the closing newline, which is not the user's.
    final length = _controller.document.length - 1;
    if (length <= letterCharLimit) return;
    _clipping = true;
    // The trim is deliberately left in the undo history. Quill's History merges
    // changes recorded within its 400ms interval, and this one lands in the same
    // frame as the edit that overflowed — so the two collapse into a single undo
    // step and one undo drops the whole over-limit paste.
    //
    // Do not "fix" this by setting history.ignoreChange around the replace: the
    // recorded inverse is computed against the document as it was, so skipping
    // the trim leaves history describing a document that no longer exists, and
    // undo then restores the overflow. Covered by composer_undo_redo_test.dart.
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
        // While the keyboard is up the toolbar would cover the very lines being
        // typed, so hide it then — the paper fills the space above the keyboard.
        // It comes back when the keyboard is dismissed (tap out / drag down).
        final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
        return Scaffold(
          backgroundColor: _ground,
          body: SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) => GestureDetector(
                // Tapping outside the editor (or dragging the paper down)
                // dismisses the keyboard, so you can stop typing either way.
                behavior: HitTestBehavior.translucent,
                onTap: () => FocusScope.of(context).unfocus(),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: _TopBar(
                        canSend: state.canSend,
                        controller: _controller,
                        onBack: widget.onBack,
                        onDone: widget.onNext,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Expanded(
                      child: SingleChildScrollView(
                        // Dragging the paper down dismisses the keyboard, so you
                        // can stop typing with a swipe. AlwaysScrollable makes the
                        // drag register even when the body already fits.
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: Column(
                          children: [
                            _TitleField(
                              controller: _titleController,
                              onChanged: cubit.setTitle,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            LetterPaper(
                              content: state.content,
                              controller: _controller,
                              focusNode: _focusNode,
                            ),
                          ],
                        ),
                      ),
                    ),
                    _CharCounter(count: state.charCount),
                    // Hidden while typing so the tools never cover the text.
                    if (!keyboardOpen)
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight:
                              constraints.maxHeight * _panelMaxHeightFraction,
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
    required this.controller,
    required this.onBack,
    required this.onDone,
  });

  final bool canSend;

  /// Undo/redo delegate to the editor's own history — Quill's [Document]
  /// already records every change, so the composer keeps none of its own.
  final QuillController controller;

  final VoidCallback onBack;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Row(
      children: [
        _CircleAction(size: 44, icon: Icons.chevron_left, onTap: onBack),
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
        // Rebuilt from the controller rather than the bloc state: an undo that
        // lands on identical content emits no new state, which would leave
        // these buttons showing the previous history's enablement.
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) => Row(
            children: [
              _CircleAction(
                size: 40,
                icon: Icons.undo,
                onTap: controller.hasUndo ? controller.undo : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              _CircleAction(
                size: 40,
                icon: Icons.redo,
                onTap: controller.hasRedo ? controller.redo : null,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _CircleAction(size: 40, icon: Icons.visibility_outlined, onTap: () {}),
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
            color: (iconColor ?? context.colorScheme.onSurface).withValues(
              alpha: enabled ? 1 : 0.4,
            ),
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
    final scheme = context.colorScheme;
    final semantic = context.semanticColors;
    final near = count >= letterCharLimit - 20;
    // .pen counter: a surface-elevated card — bold count + "/ 500 ký tự", then
    // an encouraging "Tốt lắm!" pill while there's room left.
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.brand.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$count',
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: near ? scheme.error : scheme.onSurface,
                      ),
                    ),
                    TextSpan(
                      text: ' / $letterCharLimit ký tự',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (count > 0 && !near) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: semantic.successContainer,
                  shape: const StadiumBorder(),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 12, color: semantic.success),
                    const SizedBox(width: 4),
                    Text(
                      'Tốt lắm!',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: semantic.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// SM-013 — the letter's title, above the paper. Shown later on the Home
/// "Thư gần đây" card. Auto-correct is off so Vietnamese diacritics type.
class _TitleField extends StatelessWidget {
  const _TitleField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      autocorrect: false,
      textCapitalization: TextCapitalization.sentences,
      textAlign: TextAlign.center,
      maxLength: 60,
      style: context.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        counterText: '',
        hintText: 'Tiêu đề thư (vd: Chúc mừng sinh nhật)',
        hintStyle: context.textTheme.titleMedium?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: context.brand.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: context.brand.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: context.brand.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: context.colorScheme.primary),
        ),
      ),
    );
  }
}

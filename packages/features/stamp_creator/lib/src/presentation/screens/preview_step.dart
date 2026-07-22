import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/creator_cubit.dart';
import '../bloc/creator_state.dart';
import '../widgets/stamp_frame.dart';

/// SM-010 — "Xem trước & hoàn thiện" (F02-S08): the finished stamp shown large,
/// then a finish form (name / tags / note) to check the last details before
/// saving into the album. The watermark a Free user gets is composited into the
/// captured PNG at save time (SM-011); here it previews as a subtle overlay.
class PreviewStep extends StatefulWidget {
  const PreviewStep({super.key});

  @override
  State<PreviewStep> createState() => _PreviewStepState();
}

class _PreviewStepState extends State<PreviewStep> {
  late final TextEditingController _name;
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<CreatorCubit>();
    _name = TextEditingController(text: cubit.state.name);
    _note = TextEditingController(text: cubit.state.note);
  }

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<CreatorCubit>();
    final state = cubit.state;
    return SingleChildScrollView(
      child: Column(
        children: [
          _StampPreview(cubit: cubit, state: state),
          const SizedBox(height: AppSpacing.xl),
          _FinishForm(
            cubit: cubit,
            state: state,
            nameController: _name,
            noteController: _note,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

/// The composed stamp, wrapped in the RepaintBoundary [CreatorCubit.save]
/// captures to PNG. The Free watermark sits inside the boundary so it composites
/// into the saved image rather than being a throwaway overlay.
class _StampPreview extends StatelessWidget {
  const _StampPreview({required this.cubit, required this.state});

  final CreatorCubit cubit;
  final CreatorState state;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 224,
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

/// The elevated "hoàn thiện" card: stamp name, tags, and a personal note. Matches
/// the F02-S08 `form` frame.
class _FinishForm extends StatelessWidget {
  const _FinishForm({
    required this.cubit,
    required this.state,
    required this.nameController,
    required this.noteController,
  });

  static const _cardFill = Color(0xFFFDF8F1);
  static const _divider = Color(0xFFEFE6DA);

  final CreatorCubit cubit;
  final CreatorState state;
  final TextEditingController nameController;
  final TextEditingController noteController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: _cardFill,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('Tên tem'),
          const SizedBox(height: AppSpacing.xxs),
          TextField(
            controller: nameController,
            autocorrect: false,
            onChanged: cubit.setStampName,
            textInputAction: TextInputAction.done,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: 'Đặt tên cho con tem',
              hintStyle: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(color: _divider, height: 1),
          const SizedBox(height: AppSpacing.md),
          const _FieldLabel('Tags'),
          const SizedBox(height: AppSpacing.sm),
          _TagRow(cubit: cubit, tags: state.tags),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: _divider, height: 1),
          const SizedBox(height: AppSpacing.md),
          const _FieldLabel('Ghi chú'),
          const SizedBox(height: AppSpacing.sm),
          _NoteBox(controller: noteController, onChanged: cubit.setNote),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.textTheme.labelMedium?.copyWith(
        color: context.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// The wrap of tag pills plus a trailing "+" that adds a tag via a small dialog.
class _TagRow extends StatelessWidget {
  const _TagRow({required this.cubit, required this.tags});

  static const _pillFill = Color(0xFFF4EBE1);
  static const _addBorder = Color(0xFFE0D5C4);

  final CreatorCubit cubit;
  final List<String> tags;

  Future<void> _addTag(BuildContext context) async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => const _AddTagDialog(),
    );
    if (value != null) cubit.addTag(value);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final (i, tag) in tags.indexed)
          Container(
            height: 40,
            padding: const EdgeInsets.only(left: AppSpacing.lg, right: 6),
            decoration: BoxDecoration(
              color: _pillFill,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tag,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: AppSpacing.xxs),
                InkWell(
                  onTap: () => cubit.removeTag(i),
                  customBorder: const CircleBorder(),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        // The trailing "+" add button (F02-S08 tag "add").
        Material(
          color: context.colorScheme.surfaceContainerLowest,
          shape: const CircleBorder(
            side: BorderSide(color: _addBorder),
          ),
          child: InkWell(
            onTap: () => _addTag(context),
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.add,
                size: 20,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The small "Thêm tag" dialog. It owns its own [TextEditingController] and
/// disposes it in [State.dispose], so the controller outlives the exit
/// animation instead of being freed while the field is still on screen.
class _AddTagDialog extends StatefulWidget {
  const _AddTagDialog();

  @override
  State<_AddTagDialog> createState() => _AddTagDialogState();
}

class _AddTagDialogState extends State<_AddTagDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.colorScheme.surface,
      title: const Text('Thêm tag'),
      content: TextField(
        controller: _controller,
        autocorrect: false,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(hintText: 'Ví dụ: du lịch'),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Huỷ'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Thêm'),
        ),
      ],
    );
  }
}

class _NoteBox extends StatelessWidget {
  const _NoteBox({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: const Color(0xFFEFE6DA)),
      ),
      child: TextField(
        controller: controller,
        autocorrect: false,
        onChanged: onChanged,
        maxLines: 3,
        minLines: 2,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          hintText: 'Thêm cảm nghĩ hoặc kỷ niệm gắn với con tem này…',
          hintStyle: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

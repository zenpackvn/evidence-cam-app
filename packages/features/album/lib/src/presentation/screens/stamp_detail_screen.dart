import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/stamp.dart';

/// SM-022 detail (F02-S18) — "Chi tiết tem": the stamp shown large on a warm
/// mat, its name + date, and actions. "Attach to a letter" is wired by the
/// letters feature; delete and rename are provided by the host.
class StampDetailScreen extends StatelessWidget {
  const StampDetailScreen({
    required this.stamp,
    required this.onBack,
    this.onAttach,
    this.onDelete,
    this.onRename,
    super.key,
  });

  final Stamp stamp;
  final VoidCallback onBack;
  final VoidCallback? onAttach;
  final VoidCallback? onDelete;

  /// Called with the new name when the user renames the stamp (SM-022 BR-08).
  final ValueChanged<String>? onRename;

  static const _ground = Color(0xFFFAF4EC);

  /// SM-022 BR-08: a stamp name is at most 30 characters.
  static const _maxNameLen = 30;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Scaffold(
      backgroundColor: _ground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(onPressed: onBack),
        actions: [
          if (onDelete != null)
            IconButton(
              onPressed: () => _confirmDelete(context),
              icon: Icon(Icons.delete_outline, color: scheme.onSurfaceVariant),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFAF1E6), Color(0xFFF2E4D2)],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: AppNetworkImage(imageUrl: stamp.imageUrl),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _MetaCard(
                stamp: stamp,
                onRename: onRename == null
                    ? null
                    : () => _promptRename(context),
              ),
              const Spacer(),
              if (onAttach != null)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onAttach,
                    icon: const Icon(Icons.mail_outline),
                    label: const Text('Gắn lên thư'),
                  ),
                ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoá con tem?'),
        content: const Text('Con tem này sẽ bị xoá khỏi bộ sưu tập.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (ok ?? false) onDelete?.call();
  }

  Future<void> _promptRename(BuildContext context) async {
    final controller = TextEditingController(text: stamp.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đổi tên tem'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: _maxNameLen,
          decoration: const InputDecoration(hintText: 'Tên con tem'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name != null) onRename?.call(name);
  }
}

class _MetaCard extends StatelessWidget {
  const _MetaCard({required this.stamp, this.onRename});

  final Stamp stamp;
  final VoidCallback? onRename;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    // SM-022 BR-03: no source label. BR-06/BR-08: show the stamp name, or the
    // creation date when unnamed; tapping the name row renames it.
    final title = stamp.name.isNotEmpty ? stamp.name : _formatDate(stamp.createdAt);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onRename,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (onRename != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Icon(Icons.edit_outlined, size: 16, color: scheme.primary),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Đã lưu ${_formatDate(stamp.createdAt)}',
            style: context.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';
}

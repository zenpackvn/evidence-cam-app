import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/stamp.dart';

/// SM-022 detail (F02-S18) — "Chi tiết tem": the stamp shown large on a warm
/// mat, its name + date, and actions. "Attach to a letter" is wired by the
/// letters feature; delete and rename are provided by the host.
///
/// The write actions (rename, delete) need a network link. While [canMutate]
/// is false they are shown disabled and a tap reports [onMutateBlocked]
/// instead of running (SM-022 BR-11 / AC-10).
class StampDetailScreen extends StatelessWidget {
  const StampDetailScreen({
    required this.stamp,
    required this.onBack,
    this.canMutate = true,
    this.onMutateBlocked,
    this.onAttach,
    this.onDelete,
    this.onRename,
    this.onShare,
    super.key,
  });

  final Stamp stamp;
  final VoidCallback onBack;

  /// Whether the network-bound writes (rename, delete) are available
  /// (SM-022 BR-11): false while the device is offline.
  final bool canMutate;

  /// Invoked instead of a write when [canMutate] is false — the host surfaces
  /// the "reconnect" notice (SM-022 AC-10).
  final VoidCallback? onMutateBlocked;

  final VoidCallback? onAttach;
  final VoidCallback? onDelete;

  /// Called with the new name when the user renames the stamp (SM-022 BR-08).
  final ValueChanged<String>? onRename;

  /// Opens the share-to-social flow for this stamp (SM-022 BR-07 → SM-025).
  final VoidCallback? onShare;

  static const _ground = Color(0xFFFAF4EC);

  /// SM-022 BR-08: a stamp name is at most 30 characters.
  static const _maxNameLen = 30;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    // BR-11: offline, the write actions report the blocked action rather than
    // running. These wrappers fold that in so every entry point behaves alike.
    final renameAction = onRename == null
        ? null
        : () => canMutate ? _promptRename(context) : onMutateBlocked?.call();
    final deleteAction = onDelete == null
        ? null
        : () => canMutate ? _confirmDelete(context) : onMutateBlocked?.call();
    final title = stamp.name.isNotEmpty
        ? stamp.name
        : _formatDate(stamp.createdAt);

    return Scaffold(
      backgroundColor: _ground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(onPressed: onBack),
        title: const _Wordmark(),
        actions: [
          if (renameAction != null || deleteAction != null)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_horiz, color: scheme.onSurface),
              onSelected: (v) {
                if (v == 'rename') renameAction?.call();
                if (v == 'delete') deleteAction?.call();
              },
              itemBuilder: (_) => [
                if (renameAction != null)
                  const PopupMenuItem(
                    value: 'rename',
                    child: Text('Đổi tên tem'),
                  ),
                if (deleteAction != null)
                  const PopupMenuItem(value: 'delete', child: Text('Xoá tem')),
              ],
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.sm,
            AppSpacing.xxl,
            AppSpacing.xl,
          ),
          child: Column(
            children: [
              _HeroMat(imageUrl: stamp.imageUrl),
              const SizedBox(height: AppSpacing.md),
              _NameRow(
                title: title,
                onRename: renameAction,
                canRename: canMutate,
              ),
              const SizedBox(height: AppSpacing.md),
              _InfoCard(createdAt: stamp.createdAt),
              const SizedBox(height: AppSpacing.lg),
              if (onAttach != null)
                _PrimaryAction(
                  label: 'Gắn lên thư',
                  icon: Icons.mail_outline,
                  onTap: onAttach!,
                ),
              if (onShare != null || deleteAction != null) ...[
                const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
                Row(
                  children: [
                    if (onShare != null)
                      Expanded(
                        child: _SecondaryAction(
                          label: 'Chia sẻ',
                          icon: Icons.ios_share,
                          onTap: onShare!,
                        ),
                      ),
                    if (onShare != null && deleteAction != null)
                      const SizedBox(width: AppSpacing.sm + AppSpacing.xxs),
                    if (deleteAction != null)
                      Expanded(
                        child: _SecondaryAction(
                          label: 'Xóa',
                          icon: Icons.delete_outline,
                          onTap: deleteAction,
                          danger: true,
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
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
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _RenameDialog(initialName: stamp.name),
    );
    if (name != null) onRename?.call(name);
  }
}

/// The rename prompt (SM-022 BR-08). A [StatefulWidget] so its
/// [TextEditingController] lives exactly as long as the dialog route: disposing
/// it right after `showDialog` returns would tear it down while the dialog's
/// exit transition is still rebuilding the field.
class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.initialName});

  final String initialName;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final _controller = TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Đổi tên tem'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: StampDetailScreen._maxNameLen,
        decoration: const InputDecoration(hintText: 'Tên con tem'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Huỷ'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}

String _formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/'
    '${d.month.toString().padLeft(2, '0')}/${d.year}';

String _formatDateTime(DateTime d) =>
    '${_formatDate(d)} · '
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// The centred "StampMail" wordmark in the top nav (F02-S18 `wm`).
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    final primary = context.colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'StampMail',
          style: context.textTheme.headlineSmall?.copyWith(
            color: primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Icon(Icons.waves, size: 16, color: primary.withValues(alpha: 0.7)),
      ],
    );
  }
}

/// The warm mat holding the stamp image (F02-S18 `heroMat`).
class _HeroMat extends StatelessWidget {
  const _HeroMat({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xxl,
        horizontal: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFAF1E6), Color(0xFFF2E4D2)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: context.colorScheme.outlineVariant),
      ),
      child: Center(
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x2924211F),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: AppNetworkImage(imageUrl: imageUrl),
            ),
          ),
        ),
      ),
    );
  }
}

/// The big stamp name with a pencil affordance (F02-S18 `nm`). Tapping it
/// renames (or reports the blocked action offline).
class _NameRow extends StatelessWidget {
  const _NameRow({
    required this.title,
    required this.onRename,
    required this.canRename,
  });

  final String title;
  final VoidCallback? onRename;
  final bool canRename;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return InkWell(
      onTap: onRename,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ),
          if (onRename != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.edit_outlined,
              size: 20,
              color: canRename
                  ? scheme.primary
                  : Theme.of(context).disabledColor,
            ),
          ],
        ],
      ),
    );
  }
}

/// The elevated info card — creation date/time (F02-S18 `info`). Tags aren't
/// persisted for created stamps yet, so only the date row is shown.
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.createdAt});

  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 18,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Ngày tạo',
            style: context.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _formatDateTime(createdAt),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The primary coral action ("Gắn lên thư") — F02-S18 `ab-Gắn lên`.
class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            height: 54,
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: scheme.onPrimary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  label,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A secondary elevated action ("Chia sẻ" / "Xóa") — F02-S18 `r1`. [danger]
/// tints it for the destructive delete.
class _SecondaryAction extends StatelessWidget {
  const _SecondaryAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.danger = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final fg = danger ? scheme.error : scheme.onSurface;
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: danger ? scheme.error : scheme.tertiary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

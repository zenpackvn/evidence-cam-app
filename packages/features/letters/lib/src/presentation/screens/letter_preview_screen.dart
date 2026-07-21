import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/letter_content.dart';
import '../composer_catalog.dart';
import '../widgets/letter_paper.dart';

/// F03-S09 — "Xem trước thư": the rendered letter over an info card (template,
/// attached stamp, recipient) with "Chỉnh sửa" / "Gửi thư" pills. The
/// empty-letter warning modal (F03-S10) is exposed via
/// [showEmptyLetterWarning].
class LetterPreviewScreen extends StatelessWidget {
  const LetterPreviewScreen({
    required this.content,
    required this.onEdit,
    required this.onSend,
    this.stampName,
    this.stampImageUrl,
    this.onChangeTemplate,
    this.onChangeStamp,
    super.key,
  });

  final LetterContent content;
  final VoidCallback onEdit;
  final VoidCallback onSend;

  /// Attached stamp summary (name + preview); the row hides when null.
  final String? stampName;
  final String? stampImageUrl;

  final VoidCallback? onChangeTemplate;
  final VoidCallback? onChangeStamp;

  static const _ground = Color(0xFFFBF5EC);

  @override
  Widget build(BuildContext context) {
    final template = templateById(content.templateId);
    return Scaffold(
      backgroundColor: _ground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  _CircleButton(
                    size: 44,
                    icon: Icons.chevron_left,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      _CircleButton(
                        size: 40,
                        icon: Icons.ios_share,
                        onTap: onSend,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Chia sẻ',
                        style: context.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                'Xem trước thư',
                style: context.textTheme.displayMedium?.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 10),
              // The real letter rendered read-only on its paper — same widget,
              // same Delta, so the preview matches the composer exactly
              // (SM-015 BR-01).
              // Fills the space between the header and the info card so the
              // card + buttons sit at the bottom (no empty gap).
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: OverflowBox(
                          alignment: Alignment.topCenter,
                          minHeight: 0,
                          maxHeight: double.infinity,
                          child: AbsorbPointer(
                            child: ReadOnlyLetterPaper(content: content),
                          ),
                        ),
                      ),
                      // The attached stamp shown on the letter (top-right, like
                      // a postage stamp).
                      if (stampImageUrl != null)
                        Positioned(
                          top: AppSpacing.lg,
                          right: AppSpacing.lg,
                          child: Container(
                            width: 58,
                            height: 62,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: AppNetworkImage(
                              imageUrl: stampImageUrl!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  color: context.brand.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      leading: const _IconBox(
                        color: Color(0xFFF2EAFE),
                        icon: Icons.mail_outline,
                        iconColor: Color(0xFF8B6BD8),
                      ),
                      label: 'Mẫu thư',
                      value: template.label,
                      action: onChangeTemplate == null
                          ? null
                          : _PillAction(
                              label: 'Đổi mẫu',
                              onTap: onChangeTemplate!,
                            ),
                    ),
                    Divider(height: 21, color: context.brand.borderSubtle),
                    if (stampName != null)
                      _InfoRow(
                        leading: stampImageUrl != null
                            ? AppNetworkImage(
                                imageUrl: stampImageUrl!,
                                width: 44,
                                height: 46,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
                                ),
                              )
                            : const _IconBox(
                                color: Color(0xFFFDEBE2),
                                icon: Icons.local_post_office_outlined,
                                iconColor: Color(0xFFF35B43),
                              ),
                        label: 'Tem đã dán',
                        value: stampName!,
                        action: onChangeStamp == null
                            ? null
                            : _PillAction(
                                label: 'Đổi tem',
                                onTap: onChangeStamp!,
                              ),
                      )
                    else
                      const _InfoRow(
                        leading: _IconBox(
                          color: Color(0xFFFDEBE2),
                          icon: Icons.local_post_office_outlined,
                          iconColor: Color(0xFFF35B43),
                        ),
                        label: 'Tem đã dán',
                        value: 'Chưa dán tem',
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  SizedBox(
                    width: 130,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: onEdit,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.colorScheme.primary,
                        backgroundColor: context.brand.surfaceElevated,
                        side: BorderSide(
                          color: context.colorScheme.primary,
                          width: 1.5,
                        ),
                        shape: const StadiumBorder(),
                        textStyle: context.textTheme.titleMedium,
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Chỉnh sửa'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: onSend,
                        style: FilledButton.styleFrom(
                          backgroundColor: context.colorScheme.primary,
                          shape: const StadiumBorder(),
                          textStyle: context.textTheme.titleMedium,
                        ),
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: const Text('Gửi thư'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

/// F03-S10 — the empty-letter warning: a centered modal card (mailbox art,
/// Baloo title, "Vẫn gửi" / "Quay lại"). Returns `true` to send anyway.
Future<bool> showEmptyLetterWarning(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: const Color(0xB34A342C),
    builder: (dialogContext) => Dialog(
      backgroundColor: Theme.of(dialogContext).brightness == Brightness.dark
          ? dialogContext.brand.surfaceElevated
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'packages/feature_letters/assets/templates/f3-mailbox.png',
              width: 200,
              height: 146,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
            const SizedBox(height: 10),
            Text(
              'Thư chưa có nội dung, vẫn gửi?',
              textAlign: TextAlign.center,
              style: dialogContext.textTheme.displayMedium?.copyWith(
                fontSize: 21,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Thư của bạn đang trống. Bạn vẫn có thể gửi link để người '
              'nhận viết ra lời nhắn cho bạn.',
              textAlign: TextAlign.center,
              style: dialogContext.textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: 290,
              height: 50,
              child: FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: dialogContext.colorScheme.primary,
                  shape: const StadiumBorder(),
                  textStyle: dialogContext.textTheme.titleMedium,
                ),
                child: const Text('Vẫn gửi'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 290,
              height: 50,
              child: FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF6F0E8),
                  foregroundColor: dialogContext.colorScheme.onSurface,
                  shape: const StadiumBorder(),
                  textStyle: dialogContext.textTheme.titleMedium,
                ),
                child: const Text('Quay lại'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.size,
    required this.icon,
    required this.onTap,
  });

  final double size;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.brand.surfaceElevated,
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
            color: context.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({
    required this.color,
    required this.icon,
    required this.iconColor,
  });

  final Color color;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(icon, size: 20, color: iconColor),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.leading,
    required this.label,
    required this.value,
    this.action,
  });

  final Widget leading;
  final String label;
  final String value;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        leading,
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: context.textTheme.bodySmall),
              const SizedBox(height: 1),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        ?action,
      ],
    );
  }
}

class _PillAction extends StatelessWidget {
  const _PillAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.brand.softCoral,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

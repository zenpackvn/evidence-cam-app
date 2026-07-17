import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../composer_catalog.dart';

/// SM-012 — "Danh sách template" (F03-S01): pick a letter template to start
/// composing. Free templates are selectable; Premium ones show a lock and, when
/// tapped by a Free user, hint at upgrading.
///
/// When [replyToName] is set the screen is entered as a reply (SM-020): the
/// original sender is shown as the recipient so the user doesn't re-enter it
/// (BR-01).
class TemplateListScreen extends StatelessWidget {
  const TemplateListScreen({
    required this.onPick,
    this.isPremium = false,
    this.replyToName,
    super.key,
  });

  final ValueChanged<LetterTemplate> onPick;
  final bool isPremium;

  /// The original sender's name when composing a reply (SM-020 BR-01).
  final String? replyToName;

  static const _ground = Color(0xFFFBF5EC);

  @override
  Widget build(BuildContext context) {
    final isReply = replyToName != null && replyToName!.isNotEmpty;
    return Scaffold(
      backgroundColor: _ground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isReply ? 'Trả lời' : 'Chọn mẫu thư',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (isReply)
              Text(
                'Gửi tới $replyToName',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.xl),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.lg,
            crossAxisSpacing: AppSpacing.lg,
            childAspectRatio: 3 / 4,
          ),
          itemCount: letterTemplates.length,
          itemBuilder: (context, i) {
            final template = letterTemplates[i];
            final locked = template.premium && !isPremium;
            return _TemplateCard(
              template: template,
              locked: locked,
              onTap: () {
                if (locked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mẫu thư này chỉ dành cho Premium ✨'),
                    ),
                  );
                } else {
                  onPick(template);
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.locked,
    required this.onTap,
  });

  final LetterTemplate template;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Color(template.paperColor),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: scheme.outlineVariant),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F24211F),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (template.artAsset != null)
              Image.asset(template.artAsset!, fit: BoxFit.cover)
            else
              Center(
                child: Icon(
                  Icons.mail_outline,
                  size: 40,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
              ),
            Positioned(
              left: AppSpacing.md,
              bottom: AppSpacing.md,
              child: Text(
                template.label,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ),
            if (locked)
              Positioned(
                top: AppSpacing.md,
                right: AppSpacing.md,
                child: Icon(Icons.lock, size: 18, color: scheme.primary),
              ),
          ],
        ),
      ),
    );
  }
}

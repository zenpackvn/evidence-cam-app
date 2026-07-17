import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../composer_catalog.dart';
import 'template_preview_screen.dart';

/// SM-012 — "Danh sách template" (F03-S01): pick a letter template to start
/// composing. Tapping any card opens the full preview first (BR-04): Free
/// templates preview with a "Dùng template này" CTA, Premium ones show the same
/// full preview with a lock and an upgrade CTA instead (BR-03).
///
/// When [replyToName] is set the screen is entered as a reply (SM-020): the
/// original sender is shown as the recipient so the user doesn't re-enter it
/// (BR-01).
class TemplateListScreen extends StatelessWidget {
  const TemplateListScreen({
    required this.onPick,
    this.isPremium = false,
    this.replyToName,
    this.onUpgrade,
    super.key,
  });

  final ValueChanged<LetterTemplate> onPick;
  final bool isPremium;

  /// The original sender's name when composing a reply (SM-020 BR-01).
  final String? replyToName;

  /// Routes to the Premium upgrade screen (SM-028) when a Free user confirms a
  /// locked template's preview (BR-03). No-op when null.
  final VoidCallback? onUpgrade;

  static const _ground = Color(0xFFFBF5EC);

  /// SM-012 BR-04/AC-02..03/AC-07: open the full preview for [index]. Free →
  /// "Dùng template này" starts composing; Premium (locked for a Free user) →
  /// full preview with an upgrade CTA that routes to SM-028.
  void _openPreview(BuildContext context, int index) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => TemplatePreviewScreen(
          templates: letterTemplates,
          initialIndex: index,
          isPremium: isPremium,
          onUse: (template) {
            Navigator.of(context).pop();
            onPick(template);
          },
          onUpgrade: onUpgrade == null
              ? null
              : () {
                  Navigator.of(context).pop();
                  onUpgrade!.call();
                },
        ),
      ),
    );
  }

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
              // BR-04 / AC-02..03: every card opens the full preview first;
              // locked cards still preview fully, then show the upgrade CTA.
              onTap: () => _openPreview(context, i),
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

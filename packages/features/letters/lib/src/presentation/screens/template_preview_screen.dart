import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../composer_catalog.dart';

/// F03-S02 / F03-S03 — template preview: swipeable paper preview with page
/// dots, an info card (name, FREE/Premium pill, blurb), and a pill CTA that
/// either starts composing (Free) or points at the Premium upgrade (locked).
///
// ponytail: preview art is the template's paper color + label until the final
// template illustrations land ([ẢNH TẠM] per the .pen asset note).
class TemplatePreviewScreen extends StatefulWidget {
  const TemplatePreviewScreen({
    required this.templates,
    required this.initialIndex,
    required this.onUse,
    this.isPremium = false,
    this.onUpgrade,
    super.key,
  });

  final List<LetterTemplate> templates;
  final int initialIndex;

  /// Called with the chosen template when the user taps "Dùng template này".
  final ValueChanged<LetterTemplate> onUse;

  final bool isPremium;
  final VoidCallback? onUpgrade;

  @override
  State<TemplatePreviewScreen> createState() => _TemplatePreviewScreenState();
}

class _TemplatePreviewScreenState extends State<TemplatePreviewScreen> {
  static const _ground = Color(0xFFFBF5EC);

  late final PageController _pageController;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageController = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final template = widget.templates[_index];
    final locked = template.premium && !widget.isPremium;
    return Scaffold(
      backgroundColor: _ground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 14),
              Row(
                children: [
                  _CircleButton(
                    icon: Icons.chevron_left,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  _CircleButton(
                    icon: Icons.favorite,
                    color: scheme.primary,
                    onTap: () {},
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _CircleButton(icon: Icons.ios_share, onTap: () {}),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Xem trước template',
                style: context.textTheme.displayMedium?.copyWith(fontSize: 30),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemCount: widget.templates.length,
                  itemBuilder: (context, i) =>
                      _PaperPreview(template: widget.templates[i]),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < widget.templates.length; i++) ...[
                    if (i > 0) const SizedBox(width: 7),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _index
                            ? scheme.primary
                            : const Color(0xFFE4D8CC),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              _InfoCard(template: template),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: locked
                      ? widget.onUpgrade
                      : () => widget.onUse(template),
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.primary,
                    shape: const StadiumBorder(),
                    textStyle: context.textTheme.titleMedium,
                  ),
                  icon: Icon(
                    locked ? Icons.workspace_premium_outlined : Icons.send,
                    size: 20,
                  ),
                  label: Text(
                    locked ? 'Nâng cấp Premium' : 'Dùng template này',
                  ),
                ),
              ),
              if (locked) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '✦ Template Premium chỉ mở khóa khi nâng cấp tài khoản.',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap, this.color});

  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.brand.surfaceElevated,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            size: 20,
            color: color ?? context.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _PaperPreview extends StatelessWidget {
  const _PaperPreview({required this.template});

  final LetterTemplate template;

  @override
  Widget build(BuildContext context) {
    final art = template.previewAsset ?? template.artAsset;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Color(template.paperColor),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: art != null
          ? Image.asset(art, fit: BoxFit.cover, width: double.infinity)
          : Center(
              child: Text(
                template.label,
                style: context.textTheme.displayMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.template});

  final LetterTemplate template;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final semantic = context.semanticColors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: context.brand.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Color(template.paperColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: (template.thumbAsset ?? template.artAsset) != null
                    ? Image.asset(
                        template.thumbAsset ?? template.artAsset!,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            template.label,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (template.premium) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.workspace_premium,
                            size: 16,
                            color: context.brand.gold,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: template.premium ? 'Premium' : 'Miễn phí',
                            style: TextStyle(
                              color: scheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: '  ·  ${template.pages} trang',
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (!template.premium)
                Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: semantic.successContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'FREE',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: semantic.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                Icon(Icons.lock_outline, size: 20, color: scheme.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 6),
          Text(template.description, style: context.textTheme.bodySmall),
        ],
      ),
    );
  }
}

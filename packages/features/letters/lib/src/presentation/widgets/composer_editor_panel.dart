import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import 'font_chip_row.dart';

/// The bottom editor sheet of the composer (F03-S04/S05/S06): four tabs —
/// Giấy nền · Căn lề · Màu nền · Sticker — over a white sheet with 24px top
/// radius, per the .pen `Editor/EditorTab` / `Editor/PaperCard` /
/// `Content/FilterChip` components.
///
// ponytail: alignment + stickers are UI-only until LetterContent carries them
// (rich-text upgrade, SM-011); paper/color/font wire to the cubit today.
class ComposerEditorPanel extends StatefulWidget {
  const ComposerEditorPanel({
    required this.selectedFont,
    required this.selectedPaper,
    required this.ruled,
    required this.onFont,
    required this.onPaper,
    required this.onRuled,
    super.key,
  });

  final String? selectedFont;
  final int? selectedPaper;

  /// Whether ruled lines are on (SM-013 BR-08).
  final bool ruled;
  final ValueChanged<String> onFont;
  final ValueChanged<int> onPaper;
  final ValueChanged<bool> onRuled;

  @override
  State<ComposerEditorPanel> createState() => _ComposerEditorPanelState();
}

enum _EditorTab { paper, align, color, sticker }

class _ComposerEditorPanelState extends State<ComposerEditorPanel> {
  _EditorTab _tab = _EditorTab.paper;
  TextAlign _align = TextAlign.left;
  int _stickerCategory = 0;

  static const _papers = <(String, int)>[
    ('Giấy bìa cũ', 0xFFC4A574),
    ('Giấy A4', 0xFFFBFBF8),
    ('Giấy nhám', 0xFFDAD0C0),
    ('Giấy cổ điển', 0xFFEFE4D2),
    ('Giấy kẻ ô', 0xFFE8E4D8),
    ('Giấy màu', 0xFFF3D9DE),
  ];

  static const _colors = <int>[
    0xFFFDF6EC,
    0xFFFBF3F4,
    0xFFF3E7D3,
    0xFFFDF0F5,
    0xFFEFF6EF,
    0xFFFCEDEE,
    0xFFF1F8FC,
    0xFFFFF3D5,
  ];

  static const _stickerCategories = <String>[
    'Yêu thích',
    'Hoa lá',
    'Du lịch',
    'Sparkle',
    'Doodle',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 38),
      decoration: BoxDecoration(
        color: context.brand.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _TabItem(
                icon: Icons.description_outlined,
                label: 'Giấy nền',
                active: _tab == _EditorTab.paper,
                onTap: () => setState(() => _tab = _EditorTab.paper),
              ),
              _TabItem(
                icon: Icons.format_align_center,
                label: 'Căn lề',
                active: _tab == _EditorTab.align,
                onTap: () => setState(() => _tab = _EditorTab.align),
              ),
              _TabItem(
                icon: Icons.format_color_fill,
                label: 'Màu nền',
                active: _tab == _EditorTab.color,
                onTap: () => setState(() => _tab = _EditorTab.color),
              ),
              _TabItem(
                icon: Icons.emoji_emotions_outlined,
                label: 'Sticker',
                active: _tab == _EditorTab.sticker,
                onTap: () => setState(() => _tab = _EditorTab.sticker),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          // Khi bàn phím mở, panel bị bóp chiều cao — cho nội dung tab cuộn
          // trong phần còn lại thay vì overflow.
          Flexible(
            child: SingleChildScrollView(
              child: switch (_tab) {
                _EditorTab.paper => _PaperTab(
                  papers: _papers,
                  selectedFont: widget.selectedFont,
                  selectedPaper: widget.selectedPaper,
                  ruled: widget.ruled,
                  onFont: widget.onFont,
                  onPaper: widget.onPaper,
                  onRuled: widget.onRuled,
                ),
                _EditorTab.align => _AlignTab(
                  align: _align,
                  onChanged: (a) => setState(() => _align = a),
                ),
                _EditorTab.color => _ColorTab(
                  colors: _colors,
                  selected: widget.selectedPaper,
                  onPick: widget.onPaper,
                ),
                _EditorTab.sticker => _StickerTab(
                  categories: _stickerCategories,
                  selected: _stickerCategory,
                  onCategory: (i) => setState(() => _stickerCategory = i),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// .pen `Editor/EditorTab`: 20px glyph + caption label, coral when active with
/// a 40×3 underline.
class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final color = active ? scheme.primary : scheme.onSurfaceVariant;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                color: active ? scheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaperTab extends StatelessWidget {
  const _PaperTab({
    required this.papers,
    required this.selectedFont,
    required this.selectedPaper,
    required this.ruled,
    required this.onFont,
    required this.onPaper,
    required this.onRuled,
  });

  final List<(String, int)> papers;
  final String? selectedFont;
  final int? selectedPaper;
  final bool ruled;
  final ValueChanged<String> onFont;
  final ValueChanged<int> onPaper;
  final ValueChanged<bool> onRuled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Font chữ',
          style: context.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        FontChipRow(selected: selectedFont, onSelected: onFont),
        const SizedBox(height: AppSpacing.lg),
        // SM-013 BR-08: ruled vs plain paper.
        Text(
          'Kẻ dòng',
          style: context.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(
              value: false,
              icon: Icon(Icons.crop_portrait),
              label: Text('Không kẻ dòng'),
            ),
            ButtonSegment(
              value: true,
              icon: Icon(Icons.notes),
              label: Text('Kẻ dòng'),
            ),
          ],
          selected: {ruled},
          onSelectionChanged: (set) => onRuled(set.first),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Giấy nền',
          style: context.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (var row = 0; row < 2; row++) ...[
          if (row > 0) const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              for (var col = 0; col < 3; col++) ...[
                if (col > 0) const SizedBox(width: 10),
                Expanded(
                  child: _PaperCard(
                    label: papers[row * 3 + col].$1,
                    color: papers[row * 3 + col].$2,
                    selected: selectedPaper == papers[row * 3 + col].$2,
                    onTap: () => onPaper(papers[row * 3 + col].$2),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

/// .pen `Editor/PaperCard`: 46px swatch (radius-12) + caption label; the
/// selected card gets a coral 1.5 stroke and coral w600 label.
class _PaperCard extends StatelessWidget {
  const _PaperCard({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: Color(color),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: selected ? scheme.primary : context.brand.borderSubtle,
                width: selected ? 1.5 : 1,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelSmall?.copyWith(
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlignTab extends StatelessWidget {
  const _AlignTab({required this.align, required this.onChanged});

  final TextAlign align;
  final ValueChanged<TextAlign> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TextAlign>(
      segments: const [
        ButtonSegment(
          value: TextAlign.left,
          icon: Icon(Icons.format_align_left),
          label: Text('Trái'),
        ),
        ButtonSegment(
          value: TextAlign.center,
          icon: Icon(Icons.format_align_center),
          label: Text('Giữa'),
        ),
        ButtonSegment(
          value: TextAlign.right,
          icon: Icon(Icons.format_align_right),
          label: Text('Phải'),
        ),
      ],
      selected: {align},
      onSelectionChanged: (set) => onChanged(set.first),
    );
  }
}

class _ColorTab extends StatelessWidget {
  const _ColorTab({
    required this.colors,
    required this.selected,
    required this.onPick,
  });

  final List<int> colors;
  final int? selected;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final color in colors)
          GestureDetector(
            onTap: () => onPick(color),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Color(color),
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected == color
                      ? scheme.primary
                      : context.brand.borderSubtle,
                  width: selected == color ? 2 : 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _StickerTab extends StatelessWidget {
  const _StickerTab({
    required this.categories,
    required this.selected,
    required this.onCategory,
  });

  final List<String> categories;
  final int selected;
  final ValueChanged<int> onCategory;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final (i, cat) in categories.indexed) ...[
                if (i > 0) const SizedBox(width: AppSpacing.sm),
                _FilterChip(
                  label: cat,
                  selected: i == selected,
                  onTap: () => onCategory(i),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // ponytail: tapping will drop a sticker on the letter once
        // LetterContent carries decorations (rich-text SM-011).
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var i = 1; i <= 10; i++)
              Container(
                width: 64,
                height: 64,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: context.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Image.asset(
                  'packages/feature_letters/assets/stickers/'
                  'f3-stk-${i.toString().padLeft(2, '0')}.png',
                  fit: BoxFit.contain,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '✦ Sticker Premium mở khoá khi nâng cấp tài khoản.',
          style: context.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// .pen `Content/FilterChip`: pill h40 (42 in the composer), border-subtle
/// 1.5, body-md w600 label; the active chip fills coral with inverse text.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? scheme.primary : context.brand.surfaceElevated,
          borderRadius: BorderRadius.circular(999),
          border: selected
              ? null
              : Border.all(color: context.brand.borderSubtle, width: 1.5),
        ),
        child: Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            color: selected ? scheme.onPrimary : scheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

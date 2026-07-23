import 'package:flutter/widgets.dart' show Key, TextStyle;
import 'package:google_fonts/google_fonts.dart';

/// Resolves a letter font family (SM-013 BR-03) to a loaded [TextStyle] via
/// `google_fonts`, so the body and the font chips actually render in that font.
/// Falls back to [base] for a null/unknown family.
TextStyle letterFontStyle(String? family, TextStyle base) {
  if (family == null || family.isEmpty) return base;
  try {
    return GoogleFonts.getFont(family, textStyle: base);
  } on Exception {
    return base;
  }
}

/// A letter template (SM-012). D15 revised: every template is Free — the
/// [premium] flag stays for compatibility but no template sets it.
/// `paperColor` is the default paper tint the composer opens with.
class LetterTemplate {
  const LetterTemplate({
    required this.id,
    required this.label,
    required this.paperColor,
    this.premium = false,
    this.pages = 1,
    this.description = '',
    this.artAsset,
    this.previewAsset,
    this.thumbAsset,
  });

  final String id;
  final String label;
  final int paperColor;
  final bool premium;

  /// Number of letter pages the template ships with (shown on the preview).
  final int pages;

  /// Short marketing blurb for the preview screen (F03-S02/S03).
  final String description;

  /// Card artwork in the template grid (full asset key incl. package prefix).
  final String? artAsset;

  /// Large preview artwork (F03-S02); falls back to [artAsset].
  final String? previewAsset;

  /// 48px thumb on the preview info card; falls back to [artAsset].
  final String? thumbAsset;
}

const _tplAssets = 'packages/feature_letters/assets/templates';

/// The letter templates (SM-012, D15 revised: all templates are Free). Names
/// and artwork match the `.pen` template set — the name is baked into each art,
/// so cards render the art alone. Ids stay stable (`LetterContent.templateId`).
const letterTemplates = <LetterTemplate>[
  LetterTemplate(
    id: 'classic',
    label: 'Ngày mới rực rỡ',
    paperColor: 0xFFFDF6EC,
    artAsset: '$_tplAssets/f3-tpl-1.png',
    description:
        'Nắng sớm rực rỡ cho một khởi đầu tràn đầy năng lượng — '
        'gửi lời chào ngày mới thật tươi.',
  ),
  LetterTemplate(
    id: 'floral',
    label: 'Cảm ơn chân thành',
    paperColor: 0xFFFBF3F4,
    artAsset: '$_tplAssets/f3-tpl-2.png',
    description:
        'Trang giấy kẻ ô nhẹ nhàng điểm hoa cỏ — hợp để nói lời '
        'cảm ơn từ tận đáy lòng.',
  ),
  LetterTemplate(
    id: 'birthday',
    label: 'Chúc mừng sinh nhật',
    paperColor: 0xFFFDF0F5,
    artAsset: '$_tplAssets/f3-tpl-3.png',
    description:
        'Bánh kem, bóng bay và sắc pastel ngọt ngào cho lời chúc '
        'sinh nhật thật đáng nhớ.',
  ),
  LetterTemplate(
    id: 'love',
    label: 'Ký gửi yêu thương',
    paperColor: 0xFFFCEDEE,
    artAsset: '$_tplAssets/f3-tpl-4.png',
    description:
        'Một lá thư dịu dàng gửi trọn yêu thương đến người bạn '
        'trân quý nhất.',
  ),
  LetterTemplate(
    id: 'kraft',
    label: 'Nhật ký nhỏ',
    paperColor: 0xFFF3E7D3,
    artAsset: '$_tplAssets/f3-tpl-5c.png',
    description:
        'Chất giấy kraft ấm áp, hoài niệm — hợp với những dòng '
        'tâm sự chân thành mỗi ngày.',
  ),
  LetterTemplate(
    id: 'holiday',
    label: 'Hành trình mỗi ngày',
    paperColor: 0xFFEFF6EF,
    artAsset: '$_tplAssets/f3-tpl-6c.png',
    description:
        'Ghi lại từng chặng đường và khoảnh khắc đẹp trên hành '
        'trình của bạn.',
  ),
  // Premium templates (F03-S01 `secPrem`): locked for Free users; the art carries
  // the crown + lock. Tapping opens the preview with an upgrade CTA (BR-03).
  LetterTemplate(
    id: 'p-love',
    label: 'Yêu thương trao đi',
    paperColor: 0xFFFCEEF0,
    premium: true,
    artAsset: '$_tplAssets/f3-tpl-p1.png',
    description:
        'Sắc hồng lãng mạn cùng những đoá hồng — gửi trọn yêu '
        'thương theo cách sang trọng nhất.',
  ),
  LetterTemplate(
    id: 'p-elegant',
    label: 'Thanh lịch',
    paperColor: 0xFFF6EFE6,
    premium: true,
    artAsset: '$_tplAssets/f3-tpl-p2.png',
    description: 'Mẫu thư cao cấp với tông màu tinh tế, thanh lịch.',
  ),
  LetterTemplate(
    id: 'p-luxe',
    label: 'Cao cấp',
    paperColor: 0xFFF3EEF6,
    premium: true,
    artAsset: '$_tplAssets/f3-tpl-p3.png',
    description: 'Thiết kế cao cấp, nổi bật cho những dịp đặc biệt.',
  ),
];

LetterTemplate templateById(String id) => letterTemplates.firstWhere(
  (t) => t.id == id,
  orElse: () => letterTemplates.first,
);

/// A decorative accent colour per template, used for the letter's border frame
/// on the composer / preview / send screens so the letter "wears" its template.
int templateAccentColor(String templateId) => switch (templateId) {
  'birthday' => 0xFF9B6BD8, // tím pastel sinh nhật
  'love' || 'p-love' => 0xFFE8618C, // hồng yêu thương
  'floral' => 0xFF6FA36B, // xanh lá hoa cỏ
  'kraft' => 0xFF9C7A4E, // nâu kraft
  'holiday' => 0xFF3F8F5F, // xanh hành trình
  'p-elegant' => 0xFF9C8563, // taupe thanh lịch
  'p-luxe' => 0xFF8B6BD8, // tím cao cấp
  _ => 0xFFE0A43B, // classic — vàng nắng ấm
};

/// Decorative emoji per template, placed around the letter frame (e.g. a
/// birthday letter gets 🎂🎈🎉). The written content stays the letter body.
List<String> templateIcons(String templateId) => switch (templateId) {
  'birthday' => ['🎂', '🎈', '🎉', '🎁'],
  'love' || 'p-love' => ['❤️', '💌', '🌹', '💕'],
  'floral' => ['🌸', '🌿', '🌼', '🌷'],
  'kraft' => ['✒️', '📖', '🍂', '🕰️'],
  'holiday' => ['🌿', '🧳', '☀️', '✈️'],
  'p-elegant' => ['✨', '🕊️', '🤍', '🌙'],
  'p-luxe' => ['👑', '✨', '💎', '🥂'],
  _ => ['☀️', '🌼', '🌈', '🍃'], // classic
};

/// The handwriting/display fonts offered in the composer (SM-013, from the .pen
/// font chips). All are Google Fonts available at build time.
const letterFonts = <String>[
  'Playfair Display',
  'Quicksand',
  'Pacifico',
  'Lobster',
  'Caveat',
  'Lora',
  'Satisfy',
  'Kalam',
];

/// The default ink the body is written in when no color is applied (SM-013
/// BR-09: "đoạn chưa chọn màu giữ màu mặc định").
const letterDefaultInk = 0xFF3A322C;

/// The ink palette offered by the "Màu chữ" tab (SM-013 BR-09). Warm tones that
/// stay legible on every paper in [letterTemplates]; the first is
/// [letterDefaultInk] so the user can always return to the default.
const letterInkColors = <(String, int)>[
  ('Mực thường', letterDefaultInk),
  ('San hô', 0xFFF35B43),
  ('Đỏ thắm', 0xFFD7263D),
  ('Hồng', 0xFFE8618C),
  ('Tím', 0xFF8B6BD8),
  ('Xanh dương', 0xFF2F6FB5),
  ('Xanh lá', 0xFF3F8F5F),
  ('Nâu', 0xFF8B5E3C),
];

/// Formats an ARGB color as the `#RRGGBB` string a Delta `color` attribute
/// carries. Hex is what Quill parses and what CSS takes verbatim, so the web
/// viewer (D1.5) renders the same ink with no translation table.
String inkHex(int argb) =>
    '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

/// Identifies one swatch in the "Màu chữ" palette, for tests and e2e.
Key letterInkSwatchKey(int argb) => Key('letter-ink-${inkHex(argb)}');

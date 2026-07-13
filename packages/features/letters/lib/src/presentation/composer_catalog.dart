/// A letter template (SM-012): Free gets 3, the rest are Premium (D15 — the
/// exact Premium set is finalized with pricing). `paperColor` is the default
/// paper tint the composer opens with.
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

/// Free 3 + Premium templates (D15).
const letterTemplates = <LetterTemplate>[
  LetterTemplate(
    id: 'classic',
    label: 'Cổ điển',
    paperColor: 0xFFFDF6EC,
    artAsset: '$_tplAssets/f3-tpl-1.png',
    description: 'Nét mộc mạc, tinh tế cho mọi lời nhắn. '
        'Một khởi đầu nhẹ nhàng để gửi gắm yêu thương.',
  ),
  LetterTemplate(
    id: 'floral',
    label: 'Hoa lá',
    paperColor: 0xFFFBF3F4,
    artAsset: '$_tplAssets/f3-tpl-1.png',
    description: 'Sắc hoa dịu dàng cho những lời chúc tươi mới, '
        'gửi đến người bạn trân quý.',
  ),
  LetterTemplate(
    id: 'kraft',
    label: 'Giấy kraft',
    paperColor: 0xFFF3E7D3,
    artAsset: '$_tplAssets/f3-tpl-1.png',
    description: 'Chất giấy kraft ấm áp, hoài niệm — hợp với những '
        'dòng tâm sự chân thành.',
  ),
  LetterTemplate(
    id: 'birthday',
    label: 'Sinh nhật',
    paperColor: 0xFFFDF0F5,
    premium: true,
    artAsset: '$_tplAssets/f3-tpl-p1.png',
    previewAsset: '$_tplAssets/f3-preview-bday.png',
    thumbAsset: '$_tplAssets/f3-thumb-bday.png',
    description: 'Template sinh nhật pastel nhẹ nhàng với bánh kem, '
        'hoa tươi, bóng bay và những lời chúc ngọt ngào.',
  ),
  LetterTemplate(
    id: 'holiday',
    label: 'Lễ hội',
    paperColor: 0xFFEFF6EF,
    premium: true,
    artAsset: '$_tplAssets/f3-tpl-p1.png',
    description: 'Không khí lễ hội rộn ràng cho mùa sum vầy, '
        'gửi lời chúc an lành đến mọi người.',
  ),
  LetterTemplate(
    id: 'love',
    label: 'Tình yêu',
    paperColor: 0xFFFCEDEE,
    premium: true,
    artAsset: '$_tplAssets/f3-tpl-p1.png',
    previewAsset: '$_tplAssets/f3-preview-self.png',
    thumbAsset: '$_tplAssets/f3-thumb-self.png',
    description: 'Một lá thư dịu dàng gửi đến người thương. '
        'Trân trọng từng khoảnh khắc bên nhau.',
  ),
];

LetterTemplate templateById(String id) => letterTemplates.firstWhere(
  (t) => t.id == id,
  orElse: () => letterTemplates.first,
);

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

/// Max characters in a letter body (SM-013).
const letterCharLimit = 500;

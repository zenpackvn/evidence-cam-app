import 'stamp_draft.dart';

/// A stamp border style (SM-009). 3 free + 4 premium (SM-009 / D6: "Hoa văn
/// nổi" among the locked four). The perforated stamp edge is drawn by
/// `StampFrame`; [assetOverlay] optionally names a decorative overlay.
class StampBorder {
  const StampBorder({
    required this.id,
    required this.label,
    this.premium = false,
    this.assetOverlay,
  });

  final String id;
  final String label;
  final bool premium;
  final String? assetOverlay;
}

/// The 7-border catalog (SM-009, D6: 3 free / 4 locked).
const stampBorders = <StampBorder>[
  StampBorder(id: StampDraft.kDefaultBorder, label: 'Cổ điển'),
  StampBorder(id: 'rounded', label: 'Bo tròn'),
  StampBorder(id: 'scalloped', label: 'Sóng'),
  StampBorder(id: 'ornate', label: 'Hoa văn nổi', premium: true),
  StampBorder(id: 'gold', label: 'Viền vàng', premium: true),
  StampBorder(id: 'floral', label: 'Hoa lá', premium: true),
  StampBorder(id: 'deco', label: 'Art Deco', premium: true),
];

StampBorder borderById(String id) => stampBorders.firstWhere(
  (b) => b.id == id,
  orElse: () => stampBorders.first,
);

/// The sticker glyphs offered on the decorate step (SM-008). Emoji keep it
/// asset-free for the MVP; the design's lucide glyphs can replace these later.
const stickerGlyphs = <String>[
  '🌸', '🌿', '❤️', '✨', '⭐', '🌟', '☀️', '☁️',
  '🎁', '🎵', '📷', '🍦', '☕', '🌈', '🦋', '🌻',
];

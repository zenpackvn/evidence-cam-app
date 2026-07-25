import 'package:flutter/material.dart';

/// EvidenceCam brand palette — exact tokens from
/// `specs/projects/evidencecam/design-spec/pencil-new.pen` (`variables`).
/// Keep these hex values in sync with the design file (pixel-perfect).
abstract final class BrandColors {
  /// Primary text / active nav & icons.
  static const ink = Color(0xFF0F1F3A);

  /// Muted / secondary text, inactive nav.
  static const mut = Color(0xFF64748B);

  /// Hairline borders & dividers.
  static const line = Color(0xFFE4E9F2);

  /// Soft fills — chips, queue badge, filled inputs.
  static const soft = Color(0xFFEEF3FB);

  /// Brand primary — primary buttons, brand accents.
  static const dark = Color(0xFF123A6B);

  /// App background.
  static const bg = Color(0xFFFFFFFF);

  /// Recording indicator.
  static const rec = Color(0xFFE23B2E);

  // Marketplace colors for shop badges (1 shop = 1 gian hàng trên 1 sàn).
  static const shopee = Color(0xFFEE4D2D);
  static const tiktok = Color(0xFF161823);
  static const lazada = Color(0xFF0F146D);
  static const tiki = Color(0xFF1A94FF);

  /// The accent color for a marketplace platform id, or [mut] if unknown.
  static Color platform(String p) => switch (p) {
    'shopee' => shopee,
    'tiktok' => tiktok,
    'lazada' => lazada,
    'tiki' => tiki,
    _ => mut,
  };
}

/// Centralized corner-radius scale.
///
/// Use these tokens with `BorderRadius.circular` (or `Radius.circular`) instead
/// of hardcoded pixel values so rounding stays consistent across cards, inputs,
/// chips, and overlays, and can be tuned in one place.
abstract final class AppRadius {
  /// 4px - tiny indicators (e.g. carousel dots).
  static const double xs = 4;

  /// 8px - chips, thumbnails, small previews.
  static const double sm = 8;

  /// 12px - icon boxes, small tinted containers (.pen radius-12).
  static const double md = 12;

  /// 16px - cards and text fields.
  static const double lg = 16;

  /// 20px - elevated overlays and dialogs.
  static const double xl = 20;

  /// 24px - large hero cards and bottom sheets (.pen radius-24).
  static const double xxl = 24;
}

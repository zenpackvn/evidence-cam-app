import 'package:flutter/foundation.dart';

/// The wizard steps, in order. `source` is SM-005, `filter` is SM-006,
/// `decorate` is SM-008/009 (stickers + border), `preview` is SM-010 before the
/// save in SM-011.
enum CreatorStep { source, filter, decorate, preview }

/// A placed sticker on the stamp canvas (SM-008): a glyph plus its transform,
/// stored normalized (0..1) to the canvas so it survives resizes.
@immutable
class StickerPlacement {
  const StickerPlacement({
    required this.glyph,
    required this.dx,
    required this.dy,
    this.scale = 1,
    this.rotation = 0,
  });

  /// Sticker identifier (an emoji or an asset key).
  final String glyph;

  /// Center position, normalized to the canvas [0,1].
  final double dx;
  final double dy;
  final double scale;

  /// Rotation in radians.
  final double rotation;

  StickerPlacement copyWith({
    double? dx,
    double? dy,
    double? scale,
    double? rotation,
  }) => StickerPlacement(
    glyph: glyph,
    dx: dx ?? this.dx,
    dy: dy ?? this.dy,
    scale: scale ?? this.scale,
    rotation: rotation ?? this.rotation,
  );
}

/// Image adjustments (SM-006 "Chỉnh tay"), each a signed amount in [-1, 1] that
/// maps onto a `ColorFilter.matrix`. Zero is the untouched original.
@immutable
class Adjustments {
  const Adjustments({
    this.brightness = 0,
    this.contrast = 0,
    this.warmth = 0,
    this.saturation = 0,
  });

  final double brightness;
  final double contrast;
  final double warmth;
  final double saturation;

  bool get isIdentity =>
      brightness == 0 && contrast == 0 && warmth == 0 && saturation == 0;

  Adjustments copyWith({
    double? brightness,
    double? contrast,
    double? warmth,
    double? saturation,
  }) => Adjustments(
    brightness: brightness ?? this.brightness,
    contrast: contrast ?? this.contrast,
    warmth: warmth ?? this.warmth,
    saturation: saturation ?? this.saturation,
  );
}

/// The immutable stamp being composed across the wizard. Every edit returns a
/// new draft (no in-place mutation), so going back a step never corrupts the
/// original (SM-005 BR-06 / SM-006 BR-06: the source image is preserved).
@immutable
class StampDraft {
  const StampDraft({
    required this.imagePath,
    this.filterId = kOriginalFilter,
    this.adjustments = const Adjustments(),
    this.stickers = const [],
    this.borderId = kDefaultBorder,
  });

  /// Local path of the picked source photo (SM-005).
  final String imagePath;

  /// Selected color filter (SM-006). [kOriginalFilter] = the untouched photo.
  final String filterId;

  /// Manual adjustments layered on top of the filter (SM-006 "Chỉnh tay").
  final Adjustments adjustments;

  /// Placed stickers (SM-008).
  final List<StickerPlacement> stickers;

  /// Selected border style (SM-009).
  final String borderId;

  static const kOriginalFilter = 'original';
  static const kDefaultBorder = 'classic';

  StampDraft copyWith({
    String? imagePath,
    String? filterId,
    Adjustments? adjustments,
    List<StickerPlacement>? stickers,
    String? borderId,
  }) => StampDraft(
    imagePath: imagePath ?? this.imagePath,
    filterId: filterId ?? this.filterId,
    adjustments: adjustments ?? this.adjustments,
    stickers: stickers ?? this.stickers,
    borderId: borderId ?? this.borderId,
  );
}

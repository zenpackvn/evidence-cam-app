import 'package:flutter/material.dart';

/// Creator-flow surface colors taken verbatim from the Flow-2 designs
/// (`pencil-new.pen`). These warm cream grounds are specific to the stamp
/// creator canvas and are not part of the app-wide semantic token set, so they
/// live here rather than in the shared theme.
abstract final class CreatorColors {
  /// The wizard background (`#FBF5EC` in the .pen frames).
  static const ground = Color(0xFFFBF5EC);

  /// The soft-peach info/tip panel fill (`#FFF4EF`).
  static const tip = Color(0xFFFFF4EF);

  /// The tinted icon-box behind a leading glyph (`#FBF3EA`).
  static const iconBox = Color(0xFFFBF3EA);
}

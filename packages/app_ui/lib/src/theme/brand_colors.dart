import 'package:flutter/material.dart';

/// StampMail brand tokens that fall outside Material's [ColorScheme].
///
/// Material 3 covers the core brand/neutral/error roles; StampMail additionally
/// leans on a family of *soft* tinted surfaces (coral, peach, sage, sky) and a
/// set of decorative accent hues used across illustrations and highlights.
/// Registering these as a [ThemeExtension] keeps them theme-aware (they lerp
/// across light/dark) instead of being hardcoded at call sites.
///
/// Access via `Theme.of(context).extension<BrandColors>()` or the
/// `context.brand` getter.
///
/// Values mirror the design tokens in `stampmail/flows/pencil-new.pen`
/// (Foundations/Colors — Light ☀ / Dark ☾).
@immutable
class BrandColors extends ThemeExtension<BrandColors> {
  const BrandColors({
    required this.coral,
    required this.coralDark,
    required this.orange,
    required this.peach,
    required this.pink,
    required this.sage,
    required this.sky,
    required this.gold,
    required this.softCoral,
    required this.softPeach,
    required this.softSage,
    required this.softSky,
    required this.link,
  });

  /// Light-theme brand tokens.
  static const light = BrandColors(
    coral: Color(0xFFF35B43),
    coralDark: Color(0xFFD94B36),
    orange: Color(0xFFF47A43),
    peach: Color(0xFFF8D2C5),
    pink: Color(0xFFEFA6A4),
    sage: Color(0xFFAFC6AE),
    sky: Color(0xFFA9D4EB),
    gold: Color(0xFFF5BC58),
    softCoral: Color(0xFFFFF0EC),
    softPeach: Color(0xFFFFF4EF),
    softSage: Color(0xFFF0F6EF),
    softSky: Color(0xFFF1F8FC),
    link: Color(0xFF3399F3),
  );

  /// Dark-theme brand tokens.
  static const dark = BrandColors(
    coral: Color(0xFFF86A50),
    coralDark: Color(0xFFE4573F),
    orange: Color(0xFFF98A52),
    peach: Color(0xFF8A5D4E),
    pink: Color(0xFF9C5F5D),
    sage: Color(0xFF5F7A5E),
    sky: Color(0xFF4E7A96),
    gold: Color(0xFFD9A344),
    softCoral: Color(0xFF3A2A25),
    softPeach: Color(0xFF382E27),
    softSage: Color(0xFF2A322A),
    softSky: Color(0xFF263038),
    link: Color(0xFF7AB8FF),
  );

  /// Primary brand hue — warm coral.
  final Color coral;

  /// Deeper coral used for pressed/hover states and gradients.
  final Color coralDark;

  /// Sunset orange accent.
  final Color orange;

  /// Soft peach accent.
  final Color peach;

  /// Dusty pink accent.
  final Color pink;

  /// Sage green accent.
  final Color sage;

  /// Sky blue accent.
  final Color sky;

  /// Golden yellow accent.
  final Color gold;

  /// Tinted coral surface (banners, selected chips).
  final Color softCoral;

  /// Tinted peach surface.
  final Color softPeach;

  /// Tinted sage surface.
  final Color softSage;

  /// Tinted sky surface.
  final Color softSky;

  /// Hyperlink / inline-action text color (distinct from [coral]).
  final Color link;

  @override
  BrandColors copyWith({
    Color? coral,
    Color? coralDark,
    Color? orange,
    Color? peach,
    Color? pink,
    Color? sage,
    Color? sky,
    Color? gold,
    Color? softCoral,
    Color? softPeach,
    Color? softSage,
    Color? softSky,
    Color? link,
  }) {
    return BrandColors(
      coral: coral ?? this.coral,
      coralDark: coralDark ?? this.coralDark,
      orange: orange ?? this.orange,
      peach: peach ?? this.peach,
      pink: pink ?? this.pink,
      sage: sage ?? this.sage,
      sky: sky ?? this.sky,
      gold: gold ?? this.gold,
      softCoral: softCoral ?? this.softCoral,
      softPeach: softPeach ?? this.softPeach,
      softSage: softSage ?? this.softSage,
      softSky: softSky ?? this.softSky,
      link: link ?? this.link,
    );
  }

  @override
  BrandColors lerp(ThemeExtension<BrandColors>? other, double t) {
    if (other is! BrandColors) return this;
    return BrandColors(
      coral: Color.lerp(coral, other.coral, t)!,
      coralDark: Color.lerp(coralDark, other.coralDark, t)!,
      orange: Color.lerp(orange, other.orange, t)!,
      peach: Color.lerp(peach, other.peach, t)!,
      pink: Color.lerp(pink, other.pink, t)!,
      sage: Color.lerp(sage, other.sage, t)!,
      sky: Color.lerp(sky, other.sky, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      softCoral: Color.lerp(softCoral, other.softCoral, t)!,
      softPeach: Color.lerp(softPeach, other.softPeach, t)!,
      softSage: Color.lerp(softSage, other.softSage, t)!,
      softSky: Color.lerp(softSky, other.softSky, t)!,
      link: Color.lerp(link, other.link, t)!,
    );
  }
}

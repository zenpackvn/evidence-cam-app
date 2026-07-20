import 'package:flutter/material.dart';

import '../../app_ui.dart';

/// The StampMail brand lockup — the stamp mark above the "StampMail" wordmark —
/// shared by every flow that shows it (auth headers, onboarding, splash, the
/// empty home). The `.pen` `Brand/AuthLogo` is the default; the [light] variant
/// is the larger white lockup used on the coral splash ground.
///
/// The wordmark is a brand name, not localized copy, so it is intentionally the
/// literal "StampMail" (keeping this design-system widget free of a localization
/// dependency).
class StampMailBrandmark extends StatelessWidget {
  const StampMailBrandmark({
    super.key,
    this.logoWidth = 65,
    this.logoHeight = 71,
    this.gap = AppSpacing.xxs,
    this.wordmarkSize = 30,
    this.light = false,
  });

  /// The larger white-on-coral lockup for the splash screen: 125×149 mark,
  /// 18px gap, 44px white wordmark.
  const StampMailBrandmark.splash({super.key})
    : logoWidth = 125,
      logoHeight = 149,
      gap = 18,
      wordmarkSize = 44,
      light = true;

  final double logoWidth;
  final double logoHeight;
  final double gap;
  final double wordmarkSize;

  /// Uses the white stamp mark and a white wordmark (splash); otherwise the
  /// coral mark and the brand-coral wordmark.
  final bool light;

  static const _wordmark = 'StampMail';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          light ? 'assets/brand/stamp-white.png' : 'assets/brand/stamp-coral.png',
          package: 'app_ui',
          width: logoWidth,
          height: logoHeight,
          excludeFromSemantics: true,
        ),
        SizedBox(height: gap),
        Text(
          _wordmark,
          // .pen wordmark: Baloo 2 (display), w700, line-height 1.21.
          style: context.textTheme.displayMedium?.copyWith(
            color: light ? Colors.white : context.colorScheme.primary,
            fontSize: wordmarkSize,
            height: 1.21,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

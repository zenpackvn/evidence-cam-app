import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

/// The StampMail splash: a full-bleed coral ground with soft decorative blobs,
/// the white stamp logo, the wordmark, and an emotional tagline.
///
/// Pinned to the brand coral regardless of system brightness — the splash is a
/// branded moment, not a themed surface.
class SplashContent extends StatelessWidget {
  const SplashContent({super.key});

  /// Matches the opaque coral baked into `splash-stamp-white.png` so the logo
  /// asset blends seamlessly into the background instead of showing a seam.
  static const _coral = Color(0xFFF5503A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _coral,
      body: DecoratedBox(
        decoration: const BoxDecoration(color: _coral),
        child: Stack(
          children: [
            // Decor per the F01-S01 frame: three warm blobs plus scattered
            // dots and sparkles at fixed design coordinates (393×852 canvas).
            const Positioned(
              left: 240,
              top: -160,
              child: _Blob(
                width: 420,
                height: 420,
                color: Color(0x8CFF8A6E),
              ),
            ),
            const Positioned(
              left: -180,
              top: 620,
              child: _Blob(
                width: 360,
                height: 320,
                color: Color(0x80FF8A6E),
              ),
            ),
            const Positioned(
              left: -40,
              top: 470,
              child: _Blob(width: 140, height: 90, color: Color(0x80FF9E86)),
            ),
            const Positioned(
              left: 40,
              top: 86,
              child: _Blob(width: 14, height: 14, color: Color(0xE6F9DFA6)),
            ),
            const Positioned(
              left: 64,
              top: 112,
              child: _Blob(width: 10, height: 10, color: Color(0xE6F6BDB4)),
            ),
            const Positioned(
              left: 292,
              top: 498,
              child: _Blob(width: 12, height: 12, color: Color(0xCCE9A8E0)),
            ),
            const Positioned(
              left: 268,
              top: 648,
              child: _Blob(width: 16, height: 16, color: Color(0xCCF2A9C4)),
            ),
            const Positioned(
              left: 52,
              top: 64,
              child: Icon(Icons.auto_awesome, size: 18, color: Color(0xFFF9D9A0)),
            ),
            const Positioned(
              left: 318,
              top: 104,
              child: Icon(Icons.favorite, size: 22, color: Color(0xFFFFD9CE)),
            ),
            const Positioned(
              left: 322,
              top: 286,
              child: Icon(Icons.auto_awesome, size: 20, color: Color(0xE6FFFFFF)),
            ),
            const Positioned(
              left: 88,
              top: 580,
              child: Icon(Icons.auto_awesome, size: 16, color: Color(0xFFFBE7BC)),
            ),
            const Positioned(
              left: 300,
              top: 560,
              child: Icon(Icons.auto_awesome, size: 22, color: Color(0xFFFCD98F)),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // .pen F01-S01: white 125×149 mark + 44px white wordmark.
                  const StampMailBrandmark.splash().animateScale(),
                  const SizedBox(height: 10),
                  Text(
                    context.l10n.splashTagline,
                    textAlign: TextAlign.center,
                    // .pen: Baloo 2, 21px, w600, lh 1.35.
                    style: context.textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ).animateFadeIn(delay: AppDurations.slow),
                  const SizedBox(height: 22),
                  // .pen F01-S01: a 26px white heart closes the lockup.
                  // ponytail: Material solid heart ≈ Lucide `heart` filled;
                  // swap to a Lucide glyph if literal glyph parity is needed.
                  const Icon(
                    Icons.favorite,
                    size: 26,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.width, required this.height, required this.color});

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(
          Radius.elliptical(width / 2, height / 2),
        ),
      ),
    );
  }
}

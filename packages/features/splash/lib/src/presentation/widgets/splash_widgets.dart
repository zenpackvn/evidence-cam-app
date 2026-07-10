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
  static const _coral = Color(0xFFF74E33);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _coral,
      body: DecoratedBox(
        decoration: const BoxDecoration(color: _coral),
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -50,
              child: _Blob(
                size: 220,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
            Positioned(
              bottom: -70,
              left: -60,
              child: _Blob(
                size: 260,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/illustrations/splash-stamp-white.png',
                    package: 'feature_splash',
                    width: 168,
                    height: 168,
                    excludeFromSemantics: true,
                  ).animateScale(),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    context.l10n.appTitle,
                    style: context.textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ).animateSlideUp(delay: AppDurations.medium),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    context.l10n.splashTagline,
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ).animateFadeIn(delay: AppDurations.slow),
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
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

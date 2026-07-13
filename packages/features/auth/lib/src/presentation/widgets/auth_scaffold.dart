import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// Shared chrome for every auth screen: the warm cream background, decorative
/// corner illustrations (flowers top-left, a stamp top-right), and — when
/// [showBottomArt] is set — the open-envelope artwork below the content.
///
/// The [child] is laid out in a centered, scrollable column constrained to a
/// comfortable reading width. The bottom illustration is the *last item in the
/// scroll flow* (not a `Positioned` overlay), so it always sits below the form
/// and can never collide with it when the content is taller than the viewport.
///
/// The auth flow is **pinned to the light theme** regardless of the system
/// brightness: the StampMail onboarding/auth artwork is hand-painted on a warm
/// cream ground, so a dark background would leave the illustrations floating on
/// opaque light rectangles. Forcing light here keeps every auth screen matching
/// the design one-for-one.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.child,
    this.showBottomArt = true,
    this.bottomAsset = 'auth-bottom-envelope.png',
    this.bottomWidth,
    this.topLeftAsset = 'corner-left-flowers.png',
    this.topLeftWidth = 88,
    this.topRightAsset = 'corner-right-stamp.png',
    this.topRightWidth = 105,
    this.bottomLeftAsset,
    this.bottomRightAsset,
    super.key,
  });

  final Widget child;

  /// Whether to paint the bottom illustration. Screens with tall content
  /// (e.g. the register form) hide it to avoid overlap.
  final bool showBottomArt;

  /// Optional bottom-corner decors overlaid at the screen edges (the register
  /// frame adds `reg-bottom-left/right` on top of the envelope art).
  final String? bottomLeftAsset;
  final String? bottomRightAsset;

  /// The bottom illustration filename (under `assets/illustrations/`). Each
  /// screen supplies its own art to match the design (envelope-with-check on
  /// verify, letter-in-envelope on choose-username, …).
  final String bottomAsset;

  /// Bottom illustration render width; `null` spans the full screen width.
  /// (verify uses a 338px centered artwork, choose-username 205px).
  final double? bottomWidth;

  /// The top-left corner illustration (flowers by default; verify/username
  /// swap in the letter artwork) and its design width.
  final String topLeftAsset;
  final double topLeftWidth;

  /// The top-right corner illustration filename (a stamp by default; the
  /// register screen swaps in a paper plane to match the design) and width.
  final String topRightAsset;
  final double topRightWidth;

  static const _package = 'feature_auth';

  @override
  Widget build(BuildContext context) {
    // Pin the whole auth flow to the light theme (see class doc).
    return Theme(
      data: AppTheme.light(),
      child: Builder(builder: _buildScaffold),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: DecoratedBox(
        decoration: BoxDecoration(color: colorScheme.surface),
        child: Stack(
          children: [
            // Decor sizes/offsets mirror the .pen auth frames: flowers 88px
            // wide at (8, 10), stamp 105px wide flush right at y 8.
            Positioned(
              top: 10,
              left: 8,
              child: Image.asset(
                'assets/illustrations/$topLeftAsset',
                package: _package,
                width: topLeftWidth,
                excludeFromSemantics: true,
              ).animateFadeIn(),
            ),
            Positioned(
              top: 8,
              right: 0,
              child: Image.asset(
                'assets/illustrations/$topRightAsset',
                package: _package,
                width: topRightWidth,
                excludeFromSemantics: true,
              ).animateFadeIn(delay: 80.ms),
            ),
            if (bottomLeftAsset != null)
              Positioned(
                bottom: 0,
                left: 0,
                child: IgnorePointer(
                  child: Image.asset(
                    'assets/illustrations/$bottomLeftAsset',
                    package: _package,
                    width: 96,
                    excludeFromSemantics: true,
                  ).animateFadeIn(delay: 160.ms),
                ),
              ),
            if (bottomRightAsset != null)
              Positioned(
                bottom: 0,
                right: 0,
                child: IgnorePointer(
                  child: Image.asset(
                    'assets/illustrations/$bottomRightAsset',
                    package: _package,
                    width: 107,
                    excludeFromSemantics: true,
                  ).animateFadeIn(delay: 200.ms),
                ),
              ),
            SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: showBottomArt
                            ? MainAxisAlignment.spaceBetween
                            : MainAxisAlignment.start,
                        children: [
                          Padding(
                            // .pen auth frames: 313px-wide form column
                            // ((393 − 313) / 2 = 40px side margins), first
                            // element 30px below the top.
                            padding: const EdgeInsets.only(
                              left: AppSpacing.xxxxl,
                              right: AppSpacing.xxxxl,
                              top: 30,
                              bottom: AppSpacing.xxxl,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 313,
                                ),
                                child: child,
                              ),
                            ),
                          ),
                          if (showBottomArt)
                            IgnorePointer(
                              child: Center(
                                child: Image.asset(
                                  'assets/illustrations/$bottomAsset',
                                  package: _package,
                                  width: bottomWidth ?? double.infinity,
                                  fit: BoxFit.fitWidth,
                                  excludeFromSemantics: true,
                                ).animateSlideUp(delay: 200.ms),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

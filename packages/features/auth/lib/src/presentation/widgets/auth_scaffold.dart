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
    this.topRightAsset = 'corner-right-stamp.png',
    super.key,
  });

  final Widget child;

  /// Whether to paint the bottom illustration. Screens with tall content
  /// (e.g. the register form) hide it to avoid overlap.
  final bool showBottomArt;

  /// The bottom illustration filename (under `assets/illustrations/`). Each
  /// screen supplies its own art to match the design (envelope-with-check on
  /// verify, letter-in-envelope on choose-username, …).
  final String bottomAsset;

  /// The top-right corner illustration filename (a stamp by default; the
  /// register screen swaps in a paper plane to match the design).
  final String topRightAsset;

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
            Positioned(
              top: 0,
              left: 0,
              child: Image.asset(
                'assets/illustrations/corner-left-flowers.png',
                package: _package,
                width: 132,
                excludeFromSemantics: true,
              ).animateFadeIn(),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Image.asset(
                'assets/illustrations/$topRightAsset',
                package: _package,
                width: 128,
                excludeFromSemantics: true,
              ).animateFadeIn(delay: 80.ms),
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
                            padding: const EdgeInsets.only(
                              left: AppSpacing.xl,
                              right: AppSpacing.xl,
                              top: AppSpacing.xxxxl,
                              bottom: AppSpacing.xxxl,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 400,
                                ),
                                child: child,
                              ),
                            ),
                          ),
                          if (showBottomArt)
                            IgnorePointer(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: FractionallySizedBox(
                                  widthFactor: 0.82,
                                  child: Image.asset(
                                    'assets/illustrations/$bottomAsset',
                                    package: _package,
                                    fit: BoxFit.fitWidth,
                                    excludeFromSemantics: true,
                                  ).animateSlideUp(delay: 200.ms),
                                ),
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

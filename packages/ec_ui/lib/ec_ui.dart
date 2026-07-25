/// Shared Cupertino building blocks for the EvidenceCam screens.
///
/// The EC surface is hosted by [CupertinoApp] (see `ec_app.dart`), so it uses
/// iOS-native chrome: continuous-corner "squircle" shapes, tap haptics,
/// press-to-fade tappables, and an overlay toast (there is no
/// `ScaffoldMessenger` under Cupertino).
library;

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:smooth_corner/smooth_corner.dart';

export 'package:smooth_corner/smooth_corner.dart'
    show SmoothCard, SmoothClipRRect, SmoothContainer, SmoothRectangleBorder;

/// Figma-style corner smoothing used for every squircle. `0.6` matches the
/// iOS app-icon / control curve closely without the over-rounding of Flutter's
/// built-in `ContinuousRectangleBorder`.
const double ecCornerSmoothing = 0.6;

/// A squircle [OutlinedBorder] for `shape:` slots (buttons, cards, decorations).
SmoothRectangleBorder ecSquircle(
  double radius, {
  BorderSide side = BorderSide.none,
}) => SmoothRectangleBorder(
  smoothness: ecCornerSmoothing,
  borderRadius: BorderRadius.circular(radius),
  side: side,
);

/// A squircle [ShapeDecoration] for `Container`/`DecoratedBox` — the drop-in for
/// `BoxDecoration` with a rounded rect, keeping color/gradient/border/shadow.
ShapeDecoration ecSquircleDecoration({
  required double radius,
  Color? color,
  Gradient? gradient,
  BorderSide side = BorderSide.none,
  List<BoxShadow> shadows = const [],
}) => ShapeDecoration(
  color: color,
  gradient: gradient,
  shadows: shadows,
  shape: ecSquircle(radius, side: side),
);

/// Thin wrappers over [HapticFeedback] so intent reads at the call site.
abstract final class EcHaptics {
  /// Light tick for selections, taps, and navigation.
  static void tap() => HapticFeedback.selectionClick();

  /// A slightly firmer bump for primary actions.
  static void impact() => HapticFeedback.lightImpact();

  /// Confirmation of a completed/destructive action.
  static void success() => HapticFeedback.mediumImpact();
}

/// iOS-style tappable: fades on press and fires a light haptic on tap. The
/// Cupertino replacement for `InkWell` (iOS has no ripple). Non-interactive
/// when [onTap] is `null`.
class EcTap extends StatefulWidget {
  const EcTap({
    required this.child,
    this.onTap,
    this.pressedOpacity = 0.55,
    this.haptic = true,
    this.behavior = HitTestBehavior.opaque,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedOpacity;
  final bool haptic;
  final HitTestBehavior behavior;

  @override
  State<EcTap> createState() => _EcTapState();
}

class _EcTapState extends State<EcTap> {
  bool _pressed = false;

  bool get _enabled => widget.onTap != null;

  void _set(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  void _handleTap() {
    if (widget.haptic) EcHaptics.tap();
    widget.onTap!.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: _enabled ? (_) => _set(true) : null,
      onTapUp: _enabled ? (_) => _set(false) : null,
      onTapCancel: _enabled ? () => _set(false) : null,
      onTap: _enabled ? _handleTap : null,
      child: AnimatedOpacity(
        opacity: _pressed ? widget.pressedOpacity : 1,
        duration: const Duration(milliseconds: 90),
        child: widget.child,
      ),
    );
  }
}

/// Shows a brief bottom toast in the app [Overlay]. Cupertino has no
/// `ScaffoldMessenger`, so this is the EC replacement for a `SnackBar`.
void ecToast(
  BuildContext context,
  String message, {
  Duration duration = const Duration(milliseconds: 1400),
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _EcToast(
      message: message,
      duration: duration,
      onDismissed: entry.remove,
    ),
  );
  overlay.insert(entry);
}

class _EcToast extends StatefulWidget {
  const _EcToast({
    required this.message,
    required this.duration,
    required this.onDismissed,
  });

  final String message;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_EcToast> createState() => _EcToastState();
}

class _EcToastState extends State<_EcToast> {
  static const _fade = Duration(milliseconds: 200);
  double _opacity = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _opacity = 1);
    });
    _timer = Timer(widget.duration, () {
      if (mounted) setState(() => _opacity = 0);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 24,
      right: 24,
      bottom: MediaQuery.of(context).padding.bottom + 32,
      child: IgnorePointer(
        child: Center(
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: _fade,
            onEnd: () {
              if (_opacity == 0) widget.onDismissed();
            },
            child: DecoratedBox(
              decoration: ecSquircleDecoration(
                radius: 14,
                color: const Color(0xE6111111),
                shadows: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                child: Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

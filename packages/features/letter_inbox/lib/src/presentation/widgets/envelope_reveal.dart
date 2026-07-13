import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// The letter-open animation (SM-019, D2 — built in code, not Rive for the MVP).
/// Four beats over one controller: the sealed envelope settles, the flap lifts,
/// the letter slides up out of the envelope, and the content fades in. Calls
/// [onRevealed] when the letter has fully emerged so the host can swap in the
/// readable letter.
///
/// The keyframes follow Flow-4 Keyframe A/B in `pencil-new.pen`; a Rive upgrade
/// can replace this widget behind the same trigger later.
class EnvelopeReveal extends StatefulWidget {
  const EnvelopeReveal({required this.onRevealed, super.key});

  final VoidCallback onRevealed;

  @override
  State<EnvelopeReveal> createState() => _EnvelopeRevealState();
}

class _EnvelopeRevealState extends State<EnvelopeReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  // Beat boundaries (0..1): settle → flap → slide → fade.
  late final Animation<double> _flap = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.15, 0.45, curve: Curves.easeOutBack),
  );
  late final Animation<double> _slide = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.45, 0.8, curve: Curves.easeOutCubic),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.8, 1, curve: Curves.easeIn),
  );

  @override
  void initState() {
    super.initState();
    _c.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onRevealed();
    });
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Center(
          child: SizedBox(
            width: 260,
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // The letter sliding up out of the envelope.
                Align(
                  alignment: Alignment.topCenter,
                  child: Transform.translate(
                    offset: Offset(0, 120 - _slide.value * 120),
                    child: Opacity(
                      opacity: _slide.value,
                      child: Container(
                        width: 210,
                        height: 200,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1F24211F),
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Opacity(
                          opacity: _fade.value,
                          child: const Padding(
                            padding: EdgeInsets.all(AppSpacing.lg),
                            child: _LetterLines(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Envelope body.
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 260,
                    height: 170,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E7D3),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                  ),
                ),
                // The flap, lifting open.
                Align(
                  alignment: Alignment.topCenter,
                  child: Transform(
                    alignment: Alignment.topCenter,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateX(-_flap.value * 2.6),
                    child: ClipPath(
                      clipper: _TriangleClipper(),
                      child: Container(
                        width: 260,
                        height: 110,
                        color: const Color(0xFFE9D8BE),
                      ),
                    ),
                  ),
                ),
                // Wax seal, fading out as the flap opens.
                Opacity(
                  opacity: (1 - _flap.value).clamp(0.0, 1.0),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: scheme.onPrimary, width: 2),
                    ),
                    child: Icon(
                      Icons.favorite,
                      size: 20,
                      color: scheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LetterLines extends StatelessWidget {
  const _LetterLines();

  @override
  Widget build(BuildContext context) {
    final line = Container(
      height: 8,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(4),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [line, line, line, SizedBox(width: 80, child: line)],
    );
  }
}

/// Clips a downward triangle for the envelope flap.
class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, 0)
    ..lineTo(size.width, 0)
    ..lineTo(size.width / 2, size.height)
    ..close();

  @override
  bool shouldReclip(_TriangleClipper oldClipper) => false;
}

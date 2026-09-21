/// Runtime primitives that mirror the node vocabulary of the Pencil design
/// file (`specs/projects/evidencecam/design-spec/pencil-app-dna.pen`).
///
/// The `.pen` format is a flexbox tree: every node is a `frame` (auto-layout
/// box), `text`, `icon`, `path`, `ellipse` or `rectangle`. These widgets are a
/// 1:1 mapping of that vocabulary, so screen code generated from the design
/// file (`tool/pen2dart.py`) reads like the design file and lands on the exact
/// pixel values the designer set.
///
/// Nothing here carries business meaning — it is the transport between the
/// design file and Flutter.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Flex direction of a `frame`. `stack` is the design file's `layout: none`,
/// where children are absolutely positioned by `x`/`y`.
enum PenAxis { row, column, stack }

/// ponytail: the `.pen` artboard runs hot against iOS norms — headings sit at
/// 18–26pt where a native app uses 16–22, and frame padding at 16–26 where iOS
/// uses 12–20. Rather than retouch ~20k generated lines that `pen2dart.py`
/// would overwrite on the next run, the two knobs below rescale at the single
/// runtime chokepoint every generated node already passes through.
///
/// Body text (<= [penTypePivot]) and icon/box geometry are already correct, so
/// they are left untouched: a flat multiplier would drag 14pt body copy down to
/// 12 and shrink hairlines and glyph boxes with it.
///
/// Set [penTypeCompress] and [penDensityScale] to `1` to render the artboard
/// pixel-true again — that is what [PenScale.pixelTrue] does for the design
/// golden tests, which compare against the artboard, not against the app.
const double penTypePivot = 14;
double get penTypeCompress => PenScale.typeCompress;
double get penDensityScale => PenScale.densityScale;

/// Hai núm vặn kể trên, đặt được lúc chạy (chỉ dành cho test).
///
/// Từng là `const`, nên harness golden THIẾT KẾ không tắt được chúng và so ảnh
/// gốc (artboard pixel-true, sinh 31/07 — một ngày TRƯỚC khi hai núm này vào
/// mã) với bản đã nén 0,72/0,85. Đó là nguồn của "58 màn trôi, trung vị 22%"
/// ở thẻ D-07 — không phải thiết kế trôi. Đo lại 17/09.
abstract final class PenScale {
  static double typeCompress = 0.72;
  static double densityScale = 0.85;

  /// Tắt nén để vẽ đúng artboard. Gọi trong `setUpAll` của golden thiết kế.
  @visibleForTesting
  static void pixelTrue() {
    typeCompress = 1;
    densityScale = 1;
  }

  /// Trả về mức app đang dùng.
  @visibleForTesting
  static void appScale() {
    typeCompress = 0.72;
    densityScale = 0.85;
  }
}

/// Compresses the top of the type scale toward the iOS ramp, leaving every
/// size at or below [penTypePivot] exactly as the designer set it.
double penTextSize(double size) => size <= penTypePivot
    ? size
    : penTypePivot + (size - penTypePivot) * penTypeCompress;

/// A `frame` node: a box with optional fill, corner radius, 1px stroke, drop
/// shadow, padding, and an auto-layout of [children] along [axis].
class PenBox extends StatelessWidget {
  const PenBox({
    super.key,
    this.width,
    this.height,
    this.fill,
    this.gradient,
    this.image,
    this.imageFit = BoxFit.cover,
    this.radius = 0,
    this.borderRadius,
    this.stroke,
    this.strokeWidth = 1,
    this.shadows = const [],
    this.padding = EdgeInsets.zero,
    this.axis,
    this.gap = 0,
    this.main = MainAxisAlignment.start,
    this.cross,
    this.hugMain = false,
    this.clip = false,
    this.rotation = 0,
    this.opacity = 1,
    this.onTap,
    this.children = const <Widget>[],
  });

  final double? width;
  final double? height;
  final Color? fill;
  final Gradient? gradient;
  final ImageProvider<Object>? image;
  final BoxFit imageFit;

  /// Uniform corner radius; ignored when [borderRadius] is set.
  final double radius;
  final BorderRadius? borderRadius;
  final Color? stroke;
  final double strokeWidth;
  final List<BoxShadow> shadows;
  final EdgeInsets padding;

  /// `null` renders a leaf box (no auto-layout).
  final PenAxis? axis;
  final double gap;
  final MainAxisAlignment main;
  final CrossAxisAlignment? cross;

  /// `mainAxisSize.min` — a frame that hugs its content on the main axis.
  final bool hugMain;
  final bool clip;

  /// Degrees, clockwise, about the box centre.
  final double rotation;
  final double opacity;
  final VoidCallback? onTap;
  final List<Widget> children;

  BorderRadius get _radius =>
      borderRadius ?? BorderRadius.circular(radius.clamp(0, 9999));

  @override
  Widget build(BuildContext context) {
    var content = _content();
    if (padding != EdgeInsets.zero && content != null) {
      content = Padding(padding: padding * penDensityScale, child: content);
    }

    final hasBox =
        fill != null ||
        gradient != null ||
        image != null ||
        stroke != null ||
        shadows.isNotEmpty;

    Widget node = SizedBox(width: width, height: height, child: content);

    if (clip && radius <= 0 && borderRadius == null) {
      node = ClipRect(child: node);
    } else if (clip) {
      node = ClipRRect(borderRadius: _radius, child: node);
    }

    if (hasBox) {
      node = DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          gradient: gradient,
          image: image == null
              ? null
              : DecorationImage(image: image!, fit: imageFit),
          borderRadius: _radius,
          border: stroke == null
              ? null
              : Border.all(color: stroke!, width: strokeWidth),
          boxShadow: shadows,
        ),
        // The size lives on the inner SizedBox so the decoration wraps it.
        child: node,
      );
    }

    if (opacity != 1) node = Opacity(opacity: opacity, child: node);
    if (rotation != 0) {
      node = Transform.rotate(
        angle: rotation * 3.1415926535897932 / 180,
        child: node,
      );
    }
    if (onTap != null) {
      node = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: node,
      );
    }
    return node;
  }

  Widget? _content() {
    if (children.isEmpty) return null;
    switch (axis) {
      case null:
        return children.length == 1
            ? children.first
            : Stack(children: children);
      case PenAxis.stack:
        return Stack(clipBehavior: Clip.none, children: children);
      case PenAxis.row:
        return Row(
          mainAxisAlignment: main,
          crossAxisAlignment: cross ?? CrossAxisAlignment.center,
          mainAxisSize: hugMain ? MainAxisSize.min : MainAxisSize.max,
          children: _gapped(horizontal: true),
        );
      case PenAxis.column:
        return Column(
          mainAxisAlignment: main,
          crossAxisAlignment: cross ?? CrossAxisAlignment.start,
          mainAxisSize: hugMain ? MainAxisSize.min : MainAxisSize.max,
          children: _gapped(horizontal: false),
        );
    }
  }

  List<Widget> _gapped({required bool horizontal}) {
    if (gap <= 0 || children.length < 2) return children;
    final g = gap * penDensityScale;
    final spacer = horizontal ? SizedBox(width: g) : SizedBox(height: g);
    return <Widget>[
      for (var i = 0; i < children.length; i++) ...[
        if (i > 0) spacer,
        children[i],
      ],
    ];
  }
}

/// A `text` node. The font family comes from the app text theme (Inter).
class PenText extends StatelessWidget {
  const PenText(
    this.content, {
    required this.size,
    required this.color,
    this.weight = FontWeight.w400,
    this.align,
    this.lineHeight,
    this.letterSpacing,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.softWrap = true,
    super.key,
  });

  final String content;
  final double size;
  final Color color;
  final FontWeight weight;
  final TextAlign? align;
  final double? lineHeight;
  final double? letterSpacing;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDecoration? decoration;

  /// The design file's `textGrowth`: a node that hugs its content is laid out
  /// on one line there, so it must not reflow here either.
  final bool softWrap;

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      textAlign: align,
      maxLines: maxLines,
      softWrap: softWrap,
      overflow: overflow,
      style: TextStyle(
        fontSize: penTextSize(size),
        color: color,
        fontWeight: weight,
        height: lineHeight,
        letterSpacing: letterSpacing,
        decoration: decoration,
      ),
    );
  }
}

/// A `path` node: raw SVG path geometry drawn at [width] x [height].
class PenPath extends StatelessWidget {
  const PenPath(
    this.geometry, {
    required this.viewBox,
    required this.width,
    required this.height,
    required this.color,
    this.strokeWidth,
    this.roundCap = false,
    super.key,
  });

  final String geometry;
  final List<double> viewBox;
  final double width;
  final double height;
  final Color color;

  /// When set the path is stroked instead of filled (the design file's
  /// `strokeWidth` on a `path`).
  final double? strokeWidth;
  final bool roundCap;

  String get _svg {
    final vb = viewBox.map(_num).join(' ');
    final hex =
        '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
    final opacity = color.a;
    final paint = strokeWidth == null
        ? 'fill="$hex" fill-opacity="$opacity"'
        : 'fill="none" stroke="$hex" stroke-opacity="$opacity" '
              'stroke-width="${_num(strokeWidth!)}"'
              '${roundCap ? ' stroke-linecap="round" stroke-linejoin="round"' : ''}';
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="$vb">'
        '<path d="$geometry" $paint/></svg>';
  }

  static String _num(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(_svg, width: width, height: height);
  }
}

/// An `ellipse` node. [ring] is the design file's `innerRadius` (0..1) — a
/// donut/track shape; [sweep] and [start] cut it down to an arc.
class PenEllipse extends StatelessWidget {
  const PenEllipse({
    required this.width,
    required this.height,
    required this.color,
    this.ring,
    this.start,
    this.sweep,
    this.rotation = 0,
    super.key,
  });

  final double width;
  final double height;
  final Color color;
  final double? ring;
  final double? start;
  final double? sweep;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    Widget node = SizedBox(
      width: width,
      height: height,
      child: ring == null && sweep == null
          ? DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            )
          : CustomPaint(
              painter: _RingPainter(
                color: color,
                inner: ring ?? 0,
                start: start ?? -90,
                sweep: sweep ?? 360,
              ),
            ),
    );
    if (rotation != 0) {
      node = Transform.rotate(
        angle: rotation * 3.1415926535897932 / 180,
        child: node,
      );
    }
    return node;
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.color,
    required this.inner,
    required this.start,
    required this.sweep,
  });

  final Color color;
  final double inner;
  final double start;
  final double sweep;

  @override
  void paint(Canvas canvas, Size size) {
    const deg = 3.1415926535897932 / 180;
    final rect = Offset.zero & size;
    if (inner <= 0) {
      canvas.drawArc(
        rect,
        start * deg,
        sweep * deg,
        true,
        Paint()..color = color,
      );
      return;
    }
    final thickness = size.shortestSide * (1 - inner) / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;
    canvas.drawArc(
      rect.deflate(thickness / 2),
      start * deg,
      sweep * deg,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.color != color ||
      old.inner != inner ||
      old.start != start ||
      old.sweep != sweep;
}

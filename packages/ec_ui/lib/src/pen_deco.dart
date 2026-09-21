/// Bộ trang trí "cam-trắng" (bộ mock `ZenPack_App_Ban1_ChiTiet`, 18/09/2026):
/// nền loang cam nhạt với khối kiện hàng mờ, ô biểu tượng tô nhạt, viên trạng
/// thái, tiêu đề nhóm có vạch cam.
///
/// Tất cả đều là LỚP VẼ, không mang dữ liệu và không nhận chạm (trừ những gì
/// bên gọi bọc `EcTap` bên ngoài). Màu lấy từ [PenColors] nên đổi chế độ
/// sáng/tối là đổi theo.
library;

import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import 'pen.dart';
import 'pen_kit.dart';

/// Nền trang trí của các màn không có dải cam: hai vệt sáng cam loang ở góc
/// trên, một khối kiện hàng mờ góc dưới phải, vài lưới chấm nhỏ.
///
/// Đặt vào `PenScreen.decorations` — nó tự phủ kín màn và bỏ qua mọi cú chạm.
/// Không vẽ thêm gì ở nửa trên bên trái: đó là chỗ của tiêu đề, và tiêu đề đọc
/// trên nền phẳng dễ hơn nền loang.
class PenBackdrop extends StatelessWidget {
  const PenBackdrop({
    this.cube = true,
    this.dots = true,
    this.strength = 1,
    super.key,
  });

  /// Khối kiện hàng mờ ở góc dưới phải.
  final bool cube;

  /// Lưới chấm nhỏ.
  final bool dots;

  /// Hệ số nhân độ đậm của mọi lớp (1 = mặc định). Màn có nhiều thẻ trắng thì
  /// hạ xuống 0,7 để nền không tranh với thẻ.
  final double strength;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: IgnorePointer(
      child: CustomPaint(
        painter: _BackdropPainter(
          primary: PenColors.primary,
          cube: cube,
          dots: dots,
          strength: strength,
          dark: PenColors.dangToi,
        ),
      ),
    ),
  );
}

class _BackdropPainter extends CustomPainter {
  const _BackdropPainter({
    required this.primary,
    required this.cube,
    required this.dots,
    required this.strength,
    required this.dark,
  });

  final Color primary;
  final bool cube;
  final bool dots;
  final double strength;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Nền tối thì vệt sáng phải nhạt hơn nhiều: cam 20% trên nền gần đen đọc
    // như một vết bẩn chứ không như ánh sáng.
    final k = strength * (dark ? 0.45 : 1);

    void glow(Offset c, double r, double a) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            primary.withValues(alpha: a * k),
            primary.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: r));
      canvas.drawCircle(c, r, paint);
    }

    glow(Offset(w * 0.92, -h * 0.02), w * 0.75, 0.22);
    glow(Offset(-w * 0.05, h * 0.16), w * 0.55, 0.10);
    glow(Offset(w * 0.5, h * 1.02), w * 0.9, 0.11);

    if (cube) {
      penPaintCube(
        canvas,
        center: Offset(w * 0.86, h * 0.72),
        size: w * 0.34,
        color: primary,
        alpha: 0.055 * k,
      );
    }
    if (dots) {
      _dotGrid(canvas, Offset(w * 0.06, h * 0.63), 5, 5, primary, 0.28 * k);
      _dotGrid(canvas, Offset(w * 0.9, h * 0.63), 3, 6, primary, 0.2 * k);
    }
  }

  void _dotGrid(
    Canvas canvas,
    Offset origin,
    int cols,
    int rows,
    Color color,
    double alpha,
  ) {
    final paint = Paint()..color = color.withValues(alpha: alpha);
    const step = 12.0;
    for (var x = 0; x < cols; x++) {
      for (var y = 0; y < rows; y++) {
        canvas.drawCircle(origin + Offset(x * step, y * step), 2.1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_BackdropPainter old) =>
      old.primary != primary ||
      old.cube != cube ||
      old.dots != dots ||
      old.strength != strength ||
      old.dark != dark;
}

/// Vệt ấm ở đầu phần trắng: dải dọc từ [PenColors.selected] (cam rất nhạt)
/// tan vào nền trong [height] điểm. Cách các app thật (Shopee, Grab) cho màu
/// thương hiệu "chảy" từ đầu màn xuống nội dung — có hơi ấm mà không có hoa
/// văn. Đặt vào `decorations` (không nhận chạm) hoặc chồng dưới thân màn.
class PenWarmTop extends StatelessWidget {
  const PenWarmTop({this.height = 180, this.top = 0, super.key});

  final double height;

  /// Toạ độ bắt đầu (đáy dải cam, hoặc 0 ở màn không có dải).
  final double top;

  @override
  Widget build(BuildContext context) => Positioned(
    top: top,
    left: 0,
    right: 0,
    height: height,
    child: IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              PenColors.selected.withValues(
                alpha: PenColors.dangToi ? 0.55 : 0.9,
              ),
              PenColors.selected.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Vẽ một khối kiện hàng isometric (ba mặt) tâm [center], cạnh [size].
///
/// Ba mặt ba độ đậm khác nhau để khối có chiều sâu mà không cần viền.
void penPaintCube(
  Canvas canvas, {
  required Offset center,
  required double size,
  required Color color,
  required double alpha,
  bool outline = false,
}) {
  final s = size / 2;
  final dx = s * math.sqrt(3) / 2;
  final dy = s / 2;
  final top = Path()
    ..moveTo(center.dx, center.dy - s)
    ..lineTo(center.dx + dx, center.dy - dy)
    ..lineTo(center.dx, center.dy)
    ..lineTo(center.dx - dx, center.dy - dy)
    ..close();
  final left = Path()
    ..moveTo(center.dx - dx, center.dy - dy)
    ..lineTo(center.dx, center.dy)
    ..lineTo(center.dx, center.dy + s)
    ..lineTo(center.dx - dx, center.dy + dy)
    ..close();
  final right = Path()
    ..moveTo(center.dx + dx, center.dy - dy)
    ..lineTo(center.dx, center.dy)
    ..lineTo(center.dx, center.dy + s)
    ..lineTo(center.dx + dx, center.dy + dy)
    ..close();
  // Chỉ nét: khối kiện hàng vẽ bằng đường mảnh màu [color] với độ đậm
  // [alpha], không tô mặt — dùng làm hoa văn trên dải cam, nơi một khối tô
  // đặc dù mờ vẫn đọc như một mảng sáng dán lên.
  if (outline) {
    final edge = Paint()
      ..color = color.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(top, edge);
    canvas.drawPath(left, edge);
    canvas.drawPath(right, edge);
    return;
  }
  canvas.drawPath(top, Paint()..color = color.withValues(alpha: alpha * 1.5));
  canvas.drawPath(left, Paint()..color = color.withValues(alpha: alpha));
  canvas.drawPath(right, Paint()..color = color.withValues(alpha: alpha * 0.7));
  // Đường gân trắng mảnh viền cả ba mặt — thứ làm khối đọc ra là "kiện
  // hàng" chứ không phải một vệt màu lục giác (chỉ viền mặt trên thì nó là
  // một hình thoi).
  final edge = Paint()
    ..color = const Color(0xFFFFFFFF).withValues(alpha: alpha * 4)
    ..style = PaintingStyle.stroke
    ..strokeWidth = math.max(1, size / 60);
  canvas.drawPath(top, edge);
  canvas.drawPath(left, edge);
  canvas.drawPath(right, edge);
}

/// Khối kiện hàng mờ đặt được ở bất kỳ đâu — dải cam của trang chủ và Tài
/// khoản dùng nó ở góc phải trên, tô trắng.
class PenCubeMark extends StatelessWidget {
  const PenCubeMark({
    required this.size,
    this.color = const Color(0xFFFFFFFF),
    this.alpha = 0.12,
    this.outline = false,
    super.key,
  });

  final double size;
  final Color color;
  final double alpha;

  /// Chỉ vẽ nét, không tô mặt.
  final bool outline;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: CustomPaint(
      size: Size(size, size),
      painter: _CubePainter(color: color, alpha: alpha, outline: outline),
    ),
  );
}

class _CubePainter extends CustomPainter {
  const _CubePainter({
    required this.color,
    required this.alpha,
    required this.outline,
  });

  final Color color;
  final double alpha;
  final bool outline;

  @override
  void paint(Canvas canvas, Size size) => penPaintCube(
    canvas,
    center: Offset(size.width / 2, size.height / 2),
    size: size.width,
    color: color,
    alpha: alpha,
    outline: outline,
  );

  @override
  bool shouldRepaint(_CubePainter old) =>
      old.color != color || old.alpha != alpha || old.outline != outline;
}

/// Vài đốm sáng nhỏ rải trên dải cam — "lấp lánh" của bộ mock. Mỗi đốm là một
/// vòng sáng trắng mờ dần ra ngoài; không nhận chạm.
class PenSparkles extends StatelessWidget {
  const PenSparkles({super.key});

  @override
  Widget build(BuildContext context) => const IgnorePointer(
    child: CustomPaint(size: Size.infinite, painter: _SparklePainter()),
  );
}

class _SparklePainter extends CustomPainter {
  const _SparklePainter();

  // Toạ độ theo tỉ lệ khung: (x, y, bán kính, độ đậm).
  static const _dots = <(double, double, double, double)>[
    (0.30, 0.22, 2.2, 0.85),
    (0.56, 0.12, 1.6, 0.7),
    (0.72, 0.38, 2.6, 0.6),
    (0.14, 0.62, 1.4, 0.6),
    (0.90, 0.70, 1.8, 0.5),
    (0.44, 0.80, 1.2, 0.5),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final (x, y, r, a) in _dots) {
      final c = Offset(size.width * x, size.height * y);
      // Quầng mờ rộng gấp 4 bán kính, rồi một chấm đặc ở tâm.
      canvas.drawCircle(
        c,
        r * 4,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFFFFFF).withValues(alpha: a * 0.35),
              const Color(0x00FFFFFF),
            ],
          ).createShader(Rect.fromCircle(center: c, radius: r * 4)),
      );
      canvas.drawCircle(
        c,
        r,
        Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: a),
      );
    }
  }

  @override
  bool shouldRepaint(_SparklePainter old) => false;
}

/// Ô biểu tượng tô nhạt: nền cam rất nhạt ([PenColors.selected]), biểu tượng
/// cam ([PenColors.primary]). Đứng đầu mọi hàng cài đặt, hàng thông tin, thẻ
/// hành động của bộ mock.
///
/// Truyền [color] để đổi màu biểu tượng (loại video tự chọn màu, hàng xoá tô
/// đỏ); nền tự pha từ chính màu đó với [tintAlpha].
class PenIconTile extends StatelessWidget {
  const PenIconTile(
    this.icon, {
    this.size = 40,
    this.iconSize,
    this.color,
    this.fill,
    this.radius = 12,
    this.tintAlpha = 0.12,
    super.key,
  });

  final IconData icon;
  final double size;
  final double? iconSize;
  final Color? color;
  final Color? fill;
  final double radius;
  final double tintAlpha;

  @override
  Widget build(BuildContext context) {
    final ink = color ?? PenColors.primary;
    return PenBox(
      width: size,
      height: size,
      fill:
          fill ??
          (color == null
              ? PenColors.selected
              : color!.withValues(alpha: tintAlpha)),
      radius: radius,
      axis: PenAxis.row,
      main: MainAxisAlignment.center,
      cross: CrossAxisAlignment.center,
      children: [Icon(icon, size: iconSize ?? size * 0.55, color: ink)],
    );
  }
}

/// Viên nhãn tô nhạt: nền là [ink] pha 12%, chữ và biểu tượng màu [ink].
///
/// Dùng cho vai trò ("Chủ shop"), trạng thái ("Đã quay", "Chờ tải"), niêm
/// phong. Không có [fill] riêng: viên nào cũng pha từ chính màu chữ của nó, nên
/// một hàng năm viên năm màu vẫn cùng một độ đậm.
class PenPill extends StatelessWidget {
  const PenPill({
    required this.label,
    required this.ink,
    this.icon,
    this.dot = false,
    this.fill,
    this.size = 12,
    this.iconSize,
    this.weight = FontWeight.w600,
    this.padding = const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
    super.key,
  });

  final String label;
  final Color ink;
  final IconData? icon;

  /// Chấm tròn 6pt màu [ink] trước nhãn — viên trạng thái kiểu "● Đã quay".
  final bool dot;
  final Color? fill;
  final double size;
  final double? iconSize;
  final FontWeight weight;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => PenBox(
    fill: fill ?? ink.withValues(alpha: 0.12),
    radius: 999,
    axis: PenAxis.row,
    gap: 5,
    cross: CrossAxisAlignment.center,
    hugMain: true,
    padding: padding,
    children: [
      if (dot) PenEllipse(width: 6, height: 6, color: ink),
      if (icon != null) Icon(icon, size: iconSize ?? size + 2, color: ink),
      Flexible(
        child: PenText(
          label,
          size: size,
          color: ink,
          weight: weight,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

/// Tiêu đề nhóm: vạch cam 4×18 đứng trước nhãn in hoa đậm, tuỳ chọn một thứ
/// ở mép phải (nút "+ Thêm loại", liên kết).
///
/// Thay cho nhãn xám nhạt 14/600 trước đây — nhãn đó lẫn vào nền, còn vạch cam
/// thì nói "một nhóm mới bắt đầu ở đây" ngay cả khi lướt nhanh.
class PenSectionTitle extends StatelessWidget {
  const PenSectionTitle(
    this.label, {
    this.icon,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(4, 0, 4, 8),
    super.key,
  });

  final String label;

  /// Biểu tượng đứng thay vạch cam (Chi tiết cửa hàng dùng biểu tượng nhóm).
  final IconData? icon;
  final Widget? trailing;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: Row(
      children: [
        // Nhãn nhóm nhỏ, in hoa, màu nhạt — kiểu nhãn nhóm của Shopee/Grab
        // trên Mobbin — mở đầu bằng một vạch cam mảnh 3×12: một chấm thương
        // hiệu đủ để trang không đơn điệu, không đủ để thành hoa văn (18/09).
        // Icon nhóm (nếu có) thay vạch, màu nhạt, nhỏ.
        if (icon != null) ...[
          Icon(icon, size: 18, color: PenColors.mut),
          const SizedBox(width: 8),
        ] else ...[
          PenBox(width: 3, height: 12, fill: PenColors.primary, radius: 2),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: PenText(
            label.toUpperCase(),
            size: 12.5,
            color: PenColors.mut,
            weight: FontWeight.w600,
            letterSpacing: 0.8,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

/// Dải cam của một màn được ĐẨY (Chi tiết vận đơn, Chi tiết cửa hàng): thấp
/// hơn dải của hai tab gốc, có khối kiện hàng mờ góc phải, và phần thân trắng
/// bo góc đè lên mép dưới của nó.
///
/// [header] nằm trong vùng an toàn, trên dải; [child] là thân màn, kéo lên đè
/// dải [overlap] điểm. Cuộn thì thân trượt dưới dải.
class PenBannerPage extends StatelessWidget {
  const PenBannerPage({
    required this.header,
    required this.child,
    this.bannerHeight = 104,
    this.overlap = 22,
    this.bottom,
    super.key,
  });

  final Widget header;
  final Widget child;

  /// Phần dải NẰM DƯỚI tai thỏ; `PenBrandBanner` tự cộng vùng an toàn.
  final double bannerHeight;
  final double overlap;

  /// Thứ ghim đáy màn (hàng nút), ngoài vùng cuộn.
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return CupertinoPageScaffold(
      backgroundColor: PenColors.bg,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: PenBrandBanner(height: bannerHeight, watermark: true),
          ),
          // Vệt ấm ngay dưới dải cam, để phần trắng không cắt lạnh khỏi dải.
          PenWarmTop(top: top + bannerHeight, height: 140),
          Positioned.fill(
            child: Column(
              children: [
                SizedBox(height: top),
                SizedBox(height: bannerHeight - overlap, child: header),
                Expanded(child: child),
                ?bottom,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Hộp viền ĐỨT: nền tuỳ chọn, bo góc, nét đứt 6/4 màu [color]. Dùng cho
/// những ô "chưa có gì ở đây, thêm vào đi" — mời thành viên, kéo tệp.
class PenDashedBox extends StatelessWidget {
  const PenDashedBox({
    required this.child,
    required this.color,
    this.fill,
    this.radius = 16,
    this.strokeWidth = 1.5,
    super.key,
  });

  final Widget child;
  final Color color;
  final Color? fill;
  final double radius;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _DashedPainter(
      color: color,
      fill: fill,
      radius: radius,
      strokeWidth: strokeWidth,
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: child,
    ),
  );
}

class _DashedPainter extends CustomPainter {
  const _DashedPainter({
    required this.color,
    required this.fill,
    required this.radius,
    required this.strokeWidth,
  });

  final Color color;
  final Color? fill;
  final double radius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(radius),
    );
    if (fill != null) {
      canvas.drawRRect(rrect, Paint()..color = fill!);
    }
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final path = Path()..addRRect(rrect);
    const dash = 6.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        final end = math.min(d + dash, metric.length);
        canvas.drawPath(metric.extractPath(d, end), paint);
        d = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedPainter old) =>
      old.color != color ||
      old.fill != fill ||
      old.radius != radius ||
      old.strokeWidth != strokeWidth;
}

import 'dart:async';

import 'package:ec_ui/ec_ui.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

import 'ec_huong_dan.dart';

/// Một chặng của tour: chỉ vào MỘT nút và giải thích nút đó.
///
/// Đích xác định theo MỘT trong hai cách:
///
///   · [neo] — khoá gắn thẳng vào widget. Chính xác tuyệt đối, nhưng phải sửa
///     vào trong màn để gắn khoá.
///   · [chu] — NHÃN CHỮ của nút. Tour tự dò trong cây widget. Không phải sửa
///     một dòng nào của màn.
///
/// Cách thứ hai là mặc định nên dùng. Mười màn của app dựng ở bốn gói khác
/// nhau, nhiều màn đặt theo toạ độ pixel từ tệp thiết kế — chèn khoá vào từng
/// chỗ là mười lần cơ hội làm gãy bố cục, mà đổi lại chẳng thêm gì so với dò
/// theo nhãn. Nút không có nhãn chữ (chỉ biểu tượng) thì mới cần [neo].
///
/// Đích không tìm thấy — nút ẩn theo quyền, danh sách rỗng, nhãn đổi — thì
/// chặng bị BỎ QUA, không khoét lỗ vào chỗ trống.
class EcChiDanBuoc {
  const EcChiDanBuoc({
    required this.tieuDe,
    required this.than,
    this.neo,
    this.chu,
  }) : assert(neo != null || chu != null, 'phải có neo hoặc chu');

  final GlobalKey? neo;

  /// Nhãn chữ của nút cần chỉ vào, đúng như người dùng đọc thấy.
  final String? chu;
  final String tieuDe;
  final String than;
}

/// Tour chỉ vào từng nút, chạy MỘT LẦN ở lần đầu người này vào màn.
///
/// Đây là bản Flutter của thứ web làm bằng `react-joyride`: tối cả màn, khoét
/// một lỗ quanh đúng nút đang nói tới, và đặt bong bóng giải thích cạnh nó.
///
/// **Vì sao chỉ vào nút chứ không phải một thẻ chữ ở đầu màn.** Thẻ chữ bắt
/// người đọc tự dò xem "nút quét mã" là nút nào trong mười thứ trên màn. Khoét
/// lỗ thì không phải dò: chỗ sáng chính là chỗ phải bấm.
class EcChiDan extends StatefulWidget {
  const EcChiDan({
    required this.kho,
    required this.man,
    required this.buoc,
    required this.child,
    super.key,
  });

  final EcHuongDanKho kho;
  final EcMan man;

  /// Dựng LẠI mỗi lần vẽ (các khoá là hằng của State bên gọi), nên chuỗi dịch
  /// luôn đúng thứ tiếng đang chọn.
  final List<EcChiDanBuoc> Function() buoc;
  final Widget child;

  @override
  State<EcChiDan> createState() => _EcChiDanState();
}

class _EcChiDanState extends State<EcChiDan> {
  /// `-1` = chưa chạy. Bắt đầu ở 0 sau khung hình đầu.
  int _chang = -1;
  List<EcChiDanBuoc> _buoc = const [];

  /// Ô của chặng đang mở, TÍNH SẴN.
  ///
  /// Không tính trong `build`: dò theo nhãn phải duyệt cây widget, mà
  /// `visitChildElements()` bị cấm gọi trong lúc dựng — danh sách con lúc đó
  /// còn đang thay đổi. Nên tính ở post-frame rồi giữ lại.
  Rect? _o;

  @override
  void initState() {
    super.initState();
    // Sau khung hình đầu: trước đó các widget đích chưa có kích thước, nên
    // không tính được ô để khoét.
    WidgetsBinding.instance.addPostFrameCallback((_) => _batDau());
  }

  /// Số lần thử tìm đích trước khi bỏ cuộc, và giãn cách giữa hai lần.
  ///
  /// Phần lớn màn nạp dữ liệu bất đồng bộ: lúc khung hình đầu vẽ xong thì danh
  /// sách, nút, nhãn đều chưa có. Dò đúng một lần ở đó là tour im lặng không
  /// bao giờ chạy — và không có gì báo, vì "không tìm thấy đích" vốn cũng là
  /// một đường hợp lệ (nút ẩn theo quyền).
  ///
  /// 12 × 250ms = 3 giây: đủ cho một lượt gọi mạng bình thường; màn thật sự
  /// không có đích thì tour chỉ lặng lẽ thôi, không treo gì.
  static const _soLanThu = 12;
  static const _gianCach = Duration(milliseconds: 250);

  int _daThu = 0;

  /// Hẹn giờ của lượt thử lại. PHẢI huỷ khi tháo màn — `Future.delayed` để lại
  /// một hẹn giờ treo sau khi cây widget đã biến mất, và bộ kiểm thử bắt đúng
  /// điều đó ("A Timer is still pending"). Trên máy thật nó là một lượt gọi
  /// vào một State đã chết.
  Timer? _hen;

  void _batDau() {
    if (!mounted || widget.kho.daXem(widget.man)) return;
    final ds = widget.buoc().where(_dungDuoc).toList();
    if (ds.isEmpty) {
      // Chưa thấy đích nào — có thể màn còn đang nạp. Thử lại vài nhịp.
      if (++_daThu >= _soLanThu) return;
      _hen?.cancel();
      _hen = Timer(_gianCach, () {
        if (mounted) _batDau();
      });
      return;
    }
    // Đánh dấu NGAY khi mở, không phải lúc đóng: thoát app giữa chừng mà chưa
    // đánh dấu thì tour bám theo người dùng ở mọi lần vào sau.
    widget.kho.danhDau(widget.man);
    setState(() {
      _buoc = ds;
      _chang = 0;
      _o = _oCua(ds.first);
    });
  }

  /// Đích đã dựng ra và có kích thước thật.
  bool _dungDuoc(EcChiDanBuoc b) => _oCua(b) != null;

  Rect? _oCua(EcChiDanBuoc b) {
    final o = b.neo != null
        ? b.neo!.currentContext?.findRenderObject()
        : _timTheoChu(b.chu!);
    if (o is! RenderBox || !o.hasSize || o.size.isEmpty) return null;
    return o.localToGlobal(Offset.zero) & o.size;
  }

  /// Dò trong cây widget của chính màn này để tìm chữ [chu].
  ///
  /// Tìm được rồi thì LEO NGƯỢC lên vài bậc để lấy cả cái nút chứ không chỉ
  /// mấy chữ: khoét lỗ ôm sát chữ trông như một lỗi hiển thị, còn ôm cả nút
  /// thì người dùng thấy ngay hình dáng thứ mình phải bấm.
  ///
  /// Dừng leo khi ô vượt quá nửa màn — leo quá tay thì "nút" thành cả trang.
  RenderBox? _timTheoChu(String chu) {
    Element? thay;
    void di(Element e) {
      if (thay != null) return;
      final w = e.widget;
      final noiDung = w is Text
          ? w.data
          : (w is RichText ? w.text.toPlainText() : null);
      if (noiDung != null && noiDung.trim() == chu.trim()) {
        thay = e;
        return;
      }
      e.visitChildren(di);
    }

    final goc = context.findRenderObject();
    if (goc == null) return null;
    context.visitChildElements(di);
    if (thay == null) return null;

    var o = thay!.findRenderObject();
    if (o is! RenderBox || !o.hasSize) return null;
    final man = MediaQuery.sizeOf(context);
    var cha = o.parent;
    while (cha is RenderBox && cha.hasSize) {
      if (cha.size.width > man.width * 0.92 ||
          cha.size.height > man.height * 0.5) {
        break;
      }
      o = cha;
      cha = cha.parent;
    }
    return o is RenderBox ? o : null;
  }

  void _tiep() {
    if (_chang >= _buoc.length - 1) return setState(() => _chang = -1);
    // Tính ô ở đây, KHÔNG trong `build` — xem [_o].
    final sau = _chang + 1;
    final o = _oCua(_buoc[sau]);
    setState(() {
      _chang = sau;
      _o = o;
    });
  }

  void _dong() => setState(() => _chang = -1);

  @override
  void dispose() {
    _hen?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chang < 0 || _chang >= _buoc.length) return widget.child;
    final b = _buoc[_chang];
    final o = _o;
    // Đích biến mất giữa chừng (màn cuộn, danh sách đổi): đóng tour thay vì
    // khoét một lỗ ở chỗ chẳng còn gì.
    if (o == null) return widget.child;
    return Stack(
      children: [
        widget.child,
        _LopPhu(
          o: o,
          buoc: b,
          soChang: _buoc.length,
          chang: _chang,
          onTiep: _tiep,
          onDong: _dong,
        ),
      ],
    );
  }
}

class _LopPhu extends StatelessWidget {
  const _LopPhu({
    required this.o,
    required this.buoc,
    required this.chang,
    required this.soChang,
    required this.onTiep,
    required this.onDong,
  });

  final Rect o;
  final EcChiDanBuoc buoc;
  final int chang;
  final int soChang;
  final VoidCallback onTiep;
  final VoidCallback onDong;

  /// Khoảng thở quanh nút, để viền sáng không dính sát mép nút.
  static const _dem = 6.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final man = MediaQuery.sizeOf(context);
    final lo = o.inflate(_dem);
    // Bong bóng đặt DƯỚI nút nếu còn chỗ, không thì đặt trên. Đặt cứng một
    // phía thì nút ở đáy màn sẽ có bong bóng tràn ra ngoài.
    final duoi = lo.bottom + 190 < man.height;
    return Positioned.fill(
      child: Stack(
        children: [
          // Chạm ra ngoài = đi tiếp. Không cho chạm xuyên xuống nút bên dưới:
          // người dùng đang đọc, chạm nhầm vào nút thật là mất chỗ đang đứng.
          Positioned.fill(
            child: GestureDetector(
              onTap: onTiep,
              child: CustomPaint(painter: _KhoetLo(lo)),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            top: duoi ? lo.bottom + 12 : null,
            bottom: duoi ? null : man.height - lo.top + 12,
            child: _BongBong(
              buoc: buoc,
              chang: chang,
              soChang: soChang,
              onTiep: onTiep,
              onDong: onDong,
              l10n: l10n,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tô tối cả màn TRỪ ô của nút đang nói tới.
class _KhoetLo extends CustomPainter {
  const _KhoetLo(this.lo);

  final Rect lo;

  @override
  void paint(Canvas canvas, Size size) {
    final ca = Path()..addRect(Offset.zero & size);
    final trong = Path()
      ..addRRect(RRect.fromRectAndRadius(lo, const Radius.circular(12)));
    canvas.drawPath(
      Path.combine(PathOperation.difference, ca, trong),
      Paint()..color = const Color(0xB3161616),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(lo, const Radius.circular(12)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = PenColors.card,
    );
  }

  @override
  bool shouldRepaint(_KhoetLo cu) => cu.lo != lo;
}

class _BongBong extends StatelessWidget {
  const _BongBong({
    required this.buoc,
    required this.chang,
    required this.soChang,
    required this.onTiep,
    required this.onDong,
    required this.l10n,
  });

  final EcChiDanBuoc buoc;
  final int chang;
  final int soChang;
  final VoidCallback onTiep;
  final VoidCallback onDong;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final cuoi = chang == soChang - 1;
    return Material(
      color: PenColors.card,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              buoc.tieuDe,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: PenColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              buoc.than,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: PenColors.mut,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '${chang + 1}/$soChang',
                  style: TextStyle(fontSize: 13, color: PenColors.mut),
                ),
                const Spacer(),
                if (!cuoi)
                  TextButton(
                    onPressed: onDong,
                    child: Text(
                      l10n.gtBoQua,
                      style: TextStyle(color: PenColors.mut),
                    ),
                  ),
                TextButton(
                  onPressed: onTiep,
                  child: Text(cuoi ? l10n.hdDaHieu : l10n.gtTiep),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

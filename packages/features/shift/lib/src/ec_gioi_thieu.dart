import 'dart:async';

import 'package:ec_ui/ec_ui.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

/// Ba màn giới thiệu, chỉ hiện lần đầu mở app trên máy này.
///
/// **Bỏ qua được, ngay từ trang đầu.** Người tải app phần lớn đã biết mình cần
/// gì; giữ họ lại ba trang bắt buộc là đổi một chút thông tin lấy sự khó chịu
/// ngay ở phút đầu tiên. Ai muốn đọc thì đọc.
///
/// **Vuốt được cả hai chiều** — quay lại trang trước là chuyện người dùng chờ
/// đợi ở dạng màn này, và chặn lại thì không được gì.
///
/// **Tự lướt sang trang sau mỗi 2 giây, nhưng DỪNG HẲN khi người dùng tự
/// chạm.** Ai đang đọc dở mà bị giật sang trang khác sẽ đọc ra là app lỗi, và
/// không có cách nào lấy lại trang vừa mất ngoài vuốt ngược — rồi lại bị giật
/// đi lần nữa. Chạm một cái là họ đang cầm lái, đồng hồ tắt vĩnh viễn.
///
/// Tới trang cuối thì cũng tắt: không quay vòng về trang đầu. Vòng lặp vô tận
/// ở màn giới thiệu là cái bẫy — người dùng không biết mình đã xem hết chưa.
class EcGioiThieuScreen extends StatefulWidget {
  const EcGioiThieuScreen({required this.onXong, super.key});

  /// Gọi khi người dùng bấm "Bắt đầu" HOẶC "Bỏ qua". Một lối ra duy nhất: cả
  /// hai đều nghĩa là "đừng hiện lại nữa".
  final VoidCallback onXong;

  @override
  State<EcGioiThieuScreen> createState() => _EcGioiThieuScreenState();
}

class _EcGioiThieuScreenState extends State<EcGioiThieuScreen> {
  final _trang = PageController();
  int _hienTai = 0;
  Timer? _dongHo;

  /// Ảnh của từng trang. Danh sách này là NGUỒN DUY NHẤT quyết định số trang —
  /// đồng hồ tự lướt và phần dựng giao diện cùng đọc nó. Viết cứng số 3 ở một
  /// chỗ và dựng danh sách ở chỗ khác thì thêm trang thứ tư sẽ làm tự lướt
  /// dừng sớm, mà không có gì báo.
  static const _anhs = [
    'assets/design/flow1-zenpack-hero-art-splash.png',
    'assets/design/flow1-zenpack-hero-art-create-shop.png',
    'assets/design/flow1-zenpack-hero-art-support.png',
  ];

  int get _soTrang => _anhs.length;

  /// Mỗi 2 giây sang một trang. Bằng đúng con số chủ sản phẩm chọn.
  static const _nhip = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _dongHo = Timer.periodic(_nhip, (_) => _tuLuot());
  }

  @override
  void dispose() {
    _dongHo?.cancel();
    _trang.dispose();
    super.dispose();
  }

  void _tuLuot() {
    if (!mounted || _hienTai >= _soTrang - 1) return _tatTuLuot();
    _trang.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
    );
  }

  /// Tắt hẳn, không hẹn lại. Gọi khi người dùng tự chạm hoặc đã tới trang cuối.
  void _tatTuLuot() {
    _dongHo?.cancel();
    _dongHo = null;
  }

  void _tiep(int tong) {
    // Bấm nút cũng là cầm lái: từ đây người dùng tự đi, đồng hồ không chen vào.
    _tatTuLuot();
    if (_hienTai >= tong - 1) return widget.onXong();
    _trang.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final chu = <({String tieuDe, String than})>[
      (tieuDe: l10n.gt1Title, than: l10n.gt1Body),
      (tieuDe: l10n.gt2Title, than: l10n.gt2Body),
      (tieuDe: l10n.gt3Title, than: l10n.gt3Body),
    ];
    assert(
      chu.length == _anhs.length,
      'Số ảnh và số đoạn chữ phải khớp — thêm trang thì thêm ở CẢ HAI.',
    );
    final trangs = [
      for (var i = 0; i < _anhs.length; i++)
        (anh: _anhs[i], tieuDe: chu[i].tieuDe, than: chu[i].than),
    ];
    final cuoi = _hienTai == trangs.length - 1;

    return Scaffold(
      backgroundColor: PenColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: widget.onXong,
                child: Text(
                  l10n.gtBoQua,
                  style: TextStyle(color: PenColors.mut),
                ),
              ),
            ),
            Expanded(
              // Bắt lượt VUỐT TAY để tắt đồng hồ. `onPageChanged` không phân
              // biệt được: nó nổ cho cả lượt tự lướt lẫn lượt người vuốt, nên
              // dùng nó thì đồng hồ tự tắt ngay ở lần tự lướt đầu tiên.
              child: NotificationListener<ScrollStartNotification>(
                onNotification: (n) {
                  if (n.dragDetails != null) _tatTuLuot();
                  return false;
                },
                child: PageView.builder(
                  controller: _trang,
                  itemCount: trangs.length,
                  onPageChanged: (i) => setState(() => _hienTai = i),
                  itemBuilder: (context, i) {
                    final t = trangs[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Image.asset(
                              t.anh,
                              package: 'ec_ui',
                              fit: BoxFit.contain,
                              // Ảnh hỏng hoặc thiếu thì bỏ trống chứ KHÔNG để
                              // Flutter vẽ ô lỗi: cả màn giới thiệu sập vì một
                              // tệp ảnh là đổi quá đắt cho phần trang trí.
                              errorBuilder: (_, _, _) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            t.tieuDe,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: PenColors.ink,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t.than,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: PenColors.mut,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < trangs.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _hienTai ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _hienTai ? PenColors.primary : PenColors.line,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: PenPrimaryButton(
                  label: cuoi ? l10n.gtBatDau : l10n.gtTiep,
                  // Mũi tên chỉ ở trang cuối, và đặt SAU chữ — nó chỉ vào chỗ
                  // sắp tới. Ở các trang giữa thì không: nút "Tiếp" đã nói rõ
                  // rồi, thêm mũi tên chỉ là trang trí.
                  iconCuoi: cuoi ? LucideIcons.arrowRight : null,
                  onPressed: () => _tiep(trangs.length),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

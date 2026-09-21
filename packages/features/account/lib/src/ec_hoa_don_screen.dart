import 'package:ec_ui/ec_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:localization/localization.dart';

/// Một bộ thông tin xuất hoá đơn, đúng như người dùng nhập.
class EcHoaDon {
  const EcHoaDon({
    this.loai = 'company',
    this.ten = '',
    this.maSoThue = '',
    this.diaChi = '',
    this.email = '',
    this.ghiChu = '',
  });

  /// 'company' = Công ty / Hộ kinh doanh, 'individual' = Cá nhân.
  final String loai;
  final String ten;
  final String maSoThue;
  final String diaChi;
  final String email;
  final String ghiChu;
}

/// Mã số thuế Việt Nam: 10 chữ số, hoặc 10 kèm đuôi 3 số của đơn vị phụ thuộc.
final _mst = RegExp(r'^\d{10}(-\d{3})?$');

/// Bỏ khoảng trắng và dấu chấm.
///
/// Người ta chép mã số thuế từ giấy phép kinh doanh, và ở đó nó hay có dấu cách
/// hoặc dấu chấm. Từ chối vì một ký tự trắng là bắt họ tự đoán mình sai chỗ nào.
String chuanMaSoThue(String v) => v.replaceAll(RegExp(r'[\s.]'), '');

/// Thông tin xuất hoá đơn của TÀI KHOẢN — không phải của cửa hàng.
///
/// Ở tài khoản vì hoá đơn xuất cho người TRẢ TIỀN: gói cước tính theo tài
/// khoản, và một người có nhiều cửa hàng nhưng chỉ một pháp nhân đứng tên
/// hoá đơn.
///
/// CÓ nút Lưu, khác các màn cài đặt khác trong app. Ở đó mỗi ô là một tuỳ chọn
/// độc lập và thấy ngay kết quả; ở đây sáu ô hợp thành MỘT hồ sơ, và một hồ sơ
/// nửa vời (có tên, chưa có mã số thuế) không dùng được để xuất hoá đơn.
class EcHoaDonScreen extends StatefulWidget {
  const EcHoaDonScreen({
    required this.banDau,
    required this.onLuu,
    this.onBack,
    super.key,
  });

  final EcHoaDon banDau;

  /// Trả về thông báo lỗi từ máy chủ, hoặc `null` nếu lưu xong.
  final Future<String?> Function(EcHoaDon) onLuu;

  final VoidCallback? onBack;

  @override
  State<EcHoaDonScreen> createState() => _EcHoaDonScreenState();
}

class _EcHoaDonScreenState extends State<EcHoaDonScreen> {
  late String _loai = widget.banDau.loai;
  late final _ten = TextEditingController(text: widget.banDau.ten);
  late final _mstO = TextEditingController(text: widget.banDau.maSoThue);
  late final _diaChi = TextEditingController(text: widget.banDau.diaChi);
  late final _email = TextEditingController(text: widget.banDau.email);
  late final _ghiChu = TextEditingController(text: widget.banDau.ghiChu);

  Map<String, String> _loi = const {};
  bool _dangLuu = false;

  bool get _laCongTy => _loai == 'company';

  @override
  void dispose() {
    for (final o in [_ten, _mstO, _diaChi, _email, _ghiChu]) {
      o.dispose();
    }
    super.dispose();
  }

  Future<void> _luu() async {
    final l10n = context.l10n;
    final loi = <String, String>{};
    final mst = chuanMaSoThue(_mstO.text);
    if (_ten.text.trim().isEmpty) loi['ten'] = l10n.invNameRequired;
    // Cá nhân KHÔNG bắt mã số thuế: người mua lẻ ở Việt Nam thường không có
    // MST cá nhân, và bắt nhập là chặn đúng nhóm khách nhỏ nhất.
    if (_laCongTy && mst.isEmpty) {
      loi['mst'] = l10n.invTaxRequired;
    } else if (mst.isNotEmpty && !_mst.hasMatch(mst)) {
      loi['mst'] = l10n.invTaxInvalid;
    }
    final email = _email.text.trim();
    if (email.isNotEmpty &&
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      loi['email'] = l10n.invEmailInvalid;
    }
    setState(() => _loi = loi);
    if (loi.isNotEmpty) return;

    setState(() => _dangLuu = true);
    final loiMayChu = await widget.onLuu(
      EcHoaDon(
        loai: _loai,
        ten: _ten.text.trim(),
        maSoThue: mst,
        diaChi: _diaChi.text.trim(),
        email: email,
        ghiChu: _ghiChu.text.trim(),
      ),
    );
    if (!mounted) return;
    setState(() {
      _dangLuu = false;
      // Máy chủ kiểm lại một lượt nữa và có thể từ chối vì lý do client chưa
      // biết. Hiện đúng câu nó trả về, đừng nuốt.
      _loi = loiMayChu == null ? const {} : {'chung': loiMayChu};
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PenScreen(
      bottomBar: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
        child: PenPrimaryButton(
          label: l10n.invSave,
          onPressed: _dangLuu ? null : _luu,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                PenBackButton(onTap: widget.onBack),
                const SizedBox(width: 12),
                Expanded(
                  child: PenText(
                    l10n.invTitle,
                    size: 22,
                    color: PenColors.ink,
                    weight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            PenText(l10n.invHint, size: 13, color: PenColors.mut),
            const SizedBox(height: 18),

            PenText(l10n.invKind, size: 14, color: PenColors.ink),
            const SizedBox(height: 8),
            // Hai nút gạt thay vì danh sách: chỉ có hai lựa chọn, và lựa chọn
            // này đổi cả nhãn lẫn ràng buộc của hai ô ngay dưới — cho thấy cả
            // hai cùng lúc thì người dùng hiểu ngay mình đang ở nhánh nào.
            _GatHai(
              trai: l10n.invKindCompany,
              phai: l10n.invKindPerson,
              chonTrai: _laCongTy,
              onDoi: (trai) => setState(() {
                _loai = trai ? 'company' : 'individual';
                _loi = const {};
              }),
            ),
            const SizedBox(height: 18),

            _O(
              nhan: _laCongTy ? l10n.invName : l10n.invNamePerson,
              batBuoc: true,
              goiY: _laCongTy ? l10n.invNamePh : l10n.invNamePersonPh,
              o: _ten,
              loi: _loi['ten'],
            ),
            _O(
              nhan: _laCongTy ? l10n.invTax : l10n.invTaxOptional,
              batBuoc: _laCongTy,
              goiY: l10n.invTaxPh,
              o: _mstO,
              loi: _loi['mst'],
              soLieu: true,
            ),
            _O(nhan: l10n.invAddress, goiY: l10n.invAddressPh, o: _diaChi),
            _O(
              nhan: l10n.invEmail,
              goiY: l10n.invEmailPh,
              o: _email,
              loi: _loi['email'],
            ),
            _O(nhan: l10n.invNote, goiY: l10n.invNotePh, o: _ghiChu, dong: 3),

            if (_loi['chung'] != null) ...[
              const SizedBox(height: 8),
              PenText(_loi['chung']!, size: 13, color: PenColors.danger),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _GatHai extends StatelessWidget {
  const _GatHai({
    required this.trai,
    required this.phai,
    required this.chonTrai,
    required this.onDoi,
  });

  final String trai;
  final String phai;
  final bool chonTrai;
  final ValueChanged<bool> onDoi;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: PenColors.soft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(child: _nut(trai, chonTrai, () => onDoi(true))),
          Expanded(child: _nut(phai, !chonTrai, () => onDoi(false))),
        ],
      ),
    );
  }

  Widget _nut(String nhan, bool dangChon, VoidCallback onTap) => Semantics(
    label: nhan,
    selected: dangChon,
    button: true,
    child: EcTap(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: dangChon ? PenColors.primary : null,
          borderRadius: BorderRadius.circular(999),
        ),
        child: PenText(
          nhan,
          size: 14,
          weight: FontWeight.w700,
          color: dangChon ? PenColors.card : PenColors.mut,
        ),
      ),
    ),
  );
}

class _O extends StatelessWidget {
  const _O({
    required this.nhan,
    required this.goiY,
    required this.o,
    this.batBuoc = false,
    this.loi,
    this.dong = 1,
    this.soLieu = false,
  });

  final String nhan;
  final String goiY;
  final TextEditingController o;
  final bool batBuoc;
  final String? loi;
  final int dong;
  final bool soLieu;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PenText(nhan, size: 14, color: PenColors.ink),
              if (batBuoc)
                Padding(
                  padding: const EdgeInsets.only(left: 3),
                  child: PenText('*', size: 14, color: PenColors.danger),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Semantics(
            label: nhan,
            textField: true,
            child: CupertinoTextField(
              controller: o,
              placeholder: goiY,
              maxLines: dong,
              keyboardType: soLieu ? TextInputType.number : null,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: PenColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: loi == null ? PenColors.line : PenColors.danger,
                ),
              ),
            ),
          ),
          if (loi != null) ...[
            const SizedBox(height: 5),
            PenText(loi!, size: 12, color: PenColors.danger),
          ],
        ],
      ),
    );
  }
}
